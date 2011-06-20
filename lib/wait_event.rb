# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'event'

# Class defining an event that pausesa for a given number of seconds before
# continuing execution
class WaitEvent < Event

    def initialize(comment, *value)
        super
    end

    def exec()
        sleep(@value[0])
    end

    def to_s
        return "Sleep for #{@value} seconds#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}\n#{@comment}"
    end
end
