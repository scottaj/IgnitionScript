# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'script'

# Module containing all non class specific code, constants, globals,
# and extra functions for the application.
module GUI

    # Script attributes
    $attr = {
        :name => nil,
        :delay => 0.01,
        :fire_delay => 0,
        :read_addr => 0x379,
        :data_addr => 0x378,
        :control_addr => 0x37a,
        :groups => {},
        :used => [],
        :reuse => false
    }

    # Script
    $script = Script.new

    # Flag determining if edits have been made since the last save.
    $edit = false

    # Thread running the script.
    $run = nil

    # Turns an array of numbers into a string with ranges of numbers
    # represented accordingly.
    def neaten_numbers(nums)
        nums.sort!
        str = nil
        range = nil
        nums.each_index do |index|
            if nums[index+1] == nums[index]+1
                range = nums[index] unless range
            else
                if range
                    if str
                        str = "#{str}, #{range}-#{nums[index]}"
                    else
                        str = "#{range}-#{nums[index]}"
                    end
                    range = nil
                else
                    if str
                        str = "#{str}, #{nums[index]}"
                    else
                        str = "#{nums[index]}"
                    end
                end
            end
        end
        return str
    end

    # Turns strings of numbers with ranges into arrays containing all the
    # included numbers.
    def expand_ranges(nums)
        values = []
        nums = nums.split(",").each {|x| x.strip!}
        nums.each do |range|
            if range.match(/-/)
                range = range.split("-")
                (range[0].to_i..range[1].to_i).each {|num| values.push(num)}
            else
                values.push(range.to_i)
            end
        end
        return values.uniq
    end

    # Populates a listbox with data from an array.
    def populate_list(list)
        list.clear
        events = $script.to_s.split("&&&")
        list.insert_items(events, 0)
    end

    # Dialog displaying program information.
    class MyAboutBox < Wx::Dialog
        def initialize(parent)
            super(parent, -1, "About Fireworks Script Utility")
            sizer = BoxSizer.new(HORIZONTAL)
            set_size(Size.new(510,300))
            header_font = Font.new(28, SWISS, NORMAL, NORMAL)
            body_font = Font.new(12, SWISS, NORMAL, NORMAL)
            title = StaticText.new(self, -1, "Fireworks Script Utility", Point.new(20, 20))
            title.set_font(header_font)

            r_version = StaticText.new(self, -1, "Running on Ruby version " + RUBY_VERSION + " on " + RUBY_PLATFORM, Point.new(20,100))
            r_version.set_font(body_font)
            r_version.set_foreground_colour(RED)

            wx_version = StaticText.new(self, -1, VERSION_STRING, Point.new(20,120))
            wx_version.set_font(body_font)
            wx_version.set_foreground_colour(BLUE)

            str = "Fireworks Script Utility version 0.1.0\nCopyright 2010\nDeveloped by Al Scott\nThis is free software licensed under the GNU GPL v3"
            body = StaticText.new(self, -1, str, Point.new(20, 160))
            body.set_font(body_font)

            self.centre_on_parent(BOTH)
        end
    end
end
