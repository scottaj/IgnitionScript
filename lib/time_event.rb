# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'event'

# Class defining a time event that pauses execution of the script until a
# certain time. Times should be given as a 24 hour string seperated by
# colons, i.e. 21 or 11:30 or 0:26:15. Minutes and seconds are optional.
class TimeEvent < Event

     def initialize(comment, *value)
        super
     end

     # Executes the command. pauses execution and tests passed value against
     # system time every second until there is a match.
     def exec()
         hour = Time.now.hour
         minute = Time.now.min
         second = Time.now.sec

         time = @value.split(":")

         sleep(1) unless hour == time[0] and (minute == time[1] or time.length < 2) and (second == time[2] or time.length < 3)
     end

     def to_s
         return "Sleep until time: #{@value}#{" -- " if RUBY_PLATFORM.match(/mswin/i) or RUBY_PLATFORM.match(/mingw/i)}\n#{@comment}"
     end
end
