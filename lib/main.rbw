#!/usr/bin/env ruby

# Author: Al Scott
# Date Created: 01/19/2010
# Author Email: scottaj2@udmercy.edu
# 
# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'rubygems'
require 'wx'
require 'wx_sugar'
require 'gui_main_event'
require 'gui'
require 'script'

include Wx
include GUI

class FwApp < App
    def on_init
        t = Timer.new(self, 55)
        evt_timer(55) {Thread.pass}
        t.start(10)
        GUIMainEvent.new.show
    end
end

def main
    FwApp.new.main_loop
end

main if __FILE__ == $0
