# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

# A class defining a generic script event, subclass will define specific
# types of events and should be used in scripts.
class Event

    # 
    def initialize(comment, *value)
        @value = value
        @comment = comment    
    end
    
    attr_reader :value, :comment

    def to_s
        return "Value: #{@value}#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}\n#{@comment}"
    end
end
