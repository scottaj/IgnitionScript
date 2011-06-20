# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'event'
require 'pport'
include Pport

# Class defining a write event which writes data to a hardware address(generally
# a parallel port) to be processed externally. Value should be a
# decimal number that does not exceed 256 in a single port configuration or 512
# in a two port configuration.
class WriteEvent < Event

    def initialize(comment, *value)
        super
    end

    # Calls platform appropriate binary for communication with the port and
    # passes data to it.
    def exec(address)
        if value[1] < 256
            GenPport.new(address).write(value[1])
        else
            GenPport.new(address).write(value[1] - 256)
        end
    end

    # Activates the strobe pin which is given by <em>address<em>, _on_ is a
    # boolean telling whether to turn the pin on or off.
    def strobe(address, on = true)
        if on
            GenPport.new(address).write(1)
        else
            GenPport.new(address).write(0)
        end
    end

    def to_s
        return "Fire #{@value[0]} from position #{@value[1]}#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}\n#{@comment}"
    end
end
