# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'event'
require 'pport'
include Pport

# Class defining an event that reads a hardware address and waits fora change
# to the value read to continue execution.
class ReadEvent < Event

    def initialize(comment, *value)
        super
    end

    # Calls platform appropriate code for communication with the port and
    # reads data from it.
    def exec(address)
        loop do
            reader = GenPport.new(address)
            val = reader.read()
            if @value[0] < 0
                break if val != reader.read
            else
                break if val == @value[0]
            end
            sleep(0.01)
        end
    end

    def to_s
        return "Wait for change to read address\n#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}#{@comment}" if @value[0] < 0
        return "Wait for read address to have value: #{@value}\n#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}#{@comment}"
    end
end
