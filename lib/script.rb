# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'time_event'
require 'write_event'
require 'read_event'
require 'wait_event'
require 'thread'

# Class for a fireworks script, which contains an array of events and
# methods to add, remove, and run those events.
class Script
    
    def initialize()
        @script = []
        @modified = false
        @pause = false
    end
    
    attr_accessor :modified
    attr_reader :script
    attr_writer :pause

    # Adds an event to the script at the given position.
    def add_event(event, position = false)
        if position
            @script.insert(position, event)
        else
            @script.push(event)
        end
        @modified = true
    end

    # Removes the event at the given position.
    def remove_event(position)
        @script.delete_at(position)
        @modified = true
    end

    # Moves an event up or down in the script.
    # Change should be either 1 or -1.
    def move_event(position, change)
        temp = @script[position]
        @script[position] = @script[position + change]
        @script[position + change] = temp
        @modified = true
    end

    # Runs the script out the given hardware addresses.
    def run(addresses, delays, start = false, loop = 1)
        data_addr = addresses[0]
        ctrl_addr = addresses[1]
        read_addr = addresses[2]
        event_delay = delays[0]
        fire_delay = delays[1]
        prog = 0
        script = @script
        script = script[start..-1] if start
        threads = []
        
        begin
            inc = (2560/script.length).to_i
        rescue ZeroDivisionError
            inc = 2560
        end

        if loop > 0
            counter = 0
        else
            counter = 1
        end
        
        while counter != loop
            unless counter == 0
                prog = 0
                yield prog, "Starting next iteration"
            end
            script.each_index do |i|
                Thread.stop if @pause
                event = script[i]
                value = event.value
                comment = event.comment
                prog += inc

                if event.instance_of?(TimeEvent)
                    yield prog, "#{i+1}/#{script.length}: Waiting until #{value}.\n- #{comment}\n"
                    event.exec
                elsif event.instance_of?(WaitEvent)
                    yield prog, "#{i+1}/#{script.length}: Pausing for #{value} seconds.\n- #{comment}\n"
                    event.exec
                elsif event.instance_of?(ReadEvent)
                    yield prog, "#{i+1}/#{script.length}: Waiting for read address to change.\n- #{comment}\n"
                    event.exec(read_addr)
                elsif event.instance_of?(WriteEvent)
                    if value[1] > 255
                        event.strobe(ctrl_addr)
                        event.exec(data_addr)
                        event.strobe(ctrl_addr, false)
                    else
                        event.exec(data_addr)
                    end
                    yield prog, "#{i+1}/#{script.length}: Telling #{value[0]} at position #{value[1]} to fire.\n- #{comment}\n"
                    t = Thread.new do
                        sleep(fire_delay)
                        yield prog, "#{value[0]} at position #{value[1]} should be firing NOW!"
                    end
                    threads.push(t)
                end
                sleep(event_delay)
            end
            counter += 1
        end
        threads.each {|t| t.join}
        yield 2560, "Execution Finished!"
    end

    # Runs the script without sending data to any hardware addresses.
    def dry_run(read_addr, delays)
        event_delay = delays[0]
        fire_delay = delays[1]
        prog = 0
        script = @script
        threads = []

        begin
            inc = (2560/script.length).to_i
        rescue ZeroDivisionError
            inc = 2560
        end

        script.each_index do |i|
            Thread.stop if @pause
            event = script[i]
            value = event.value
            comment = event.comment
            prog += inc

            if event.instance_of?(TimeEvent)
                yield prog, "#{i+1}/#{script.length}: Waiting until #{value}.\n- #{comment}\n"
                event.exec
            elsif event.instance_of?(WaitEvent)
                yield prog, "#{i+1}/#{script.length}: Pausing for #{value} seconds.\n- #{comment}\n"
                event.exec
            elsif event.instance_of?(ReadEvent)
                yield prog, "#{i+1}/#{script.length}: Waiting for read address to change.\n- #{comment}\n"
                event.exec(read_addr)
            elsif event.instance_of?(WriteEvent)
                yield prog, "#{i+1}/#{script.length}: Simulating telling #{value[0]} at position #{value[1]} to fire.\n- #{comment}\n"
                t = Thread.new do
                    sleep(fire_delay)
                    yield prog, "#{value[0]} at position #{value[1]} would be firing NOW!"
                end
                threads.push(t)
            end
        sleep(event_delay)
        end
        threads.each {|t| t.join}
        yield 2560, "Execution Finished!"
    end

    def to_s()
        str = []
        @script.each_index {|i| str.push("Command #{i+1}/#{@script.length}: #{@script[i].to_s}")}
        str.join("&&&")
    end
end
