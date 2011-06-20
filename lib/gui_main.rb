# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.
# 
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: /home/home/wx/gui_main.xrc 
# Generated at: Thu Jul 15 07:44:22 -0600 2010

class GUIMain < Wx::Frame
	
	attr_reader :window_menubar, :object_1, :object_2, :run_run,
              :run_run_from, :run_loop, :run_dryrun, :menu_tools,
              :tools_conf, :menu_help, :help_bug, :window_notebook,
              :notebook_editor, :event_choice, :command_choice,
              :label_1, :data_text, :label_2, :comment_text,
              :static_line_1, :insert_btn, :static_line_2,
              :script_display, :static_line_3, :edit_btn,
              :notebook_log, :log_text, :notebook_output, :run_box,
              :gauge_1, :play_btn, :pause_btn
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load("gui_main.xrc")
		xml.load_frame_subclass(self, parent, "window")

		finder = lambda do | x | 
			int_id = Wx::xrcid(x)
			begin
				Wx::Window.find_window_by_id(int_id, self) || int_id
			# Temporary hack to work around regression in 1.9.2; remove
			# begin/rescue clause in later versions
			rescue RuntimeError
				int_id
			end
		end
		
		@window_menubar = finder.call("window_menubar")
		@object_1 = finder.call("object_1")
		@object_2 = finder.call("object_2")
		@run_run = finder.call("run_run")
		@run_run_from = finder.call("run_run_from")
        @run_loop = finder.call("run_loop")
		@run_dryrun = finder.call("run_dryrun")
		@menu_tools = finder.call("menu_tools")
		@tools_conf = finder.call("tools_conf")
		@menu_help = finder.call("menu_help")
		@help_bug = finder.call("help_bug")
		@window_notebook = finder.call("window_notebook")
		@notebook_editor = finder.call("notebook_editor")
		@event_choice = finder.call("event_choice")
		@command_choice = finder.call("command_choice")
		@label_1 = finder.call("label_1")
		@data_text = finder.call("data_text")
		@label_2 = finder.call("label_2")
		@comment_text = finder.call("comment_text")
		@static_line_1 = finder.call("static_line_1")
		@insert_btn = finder.call("insert_btn")
		@static_line_2 = finder.call("static_line_2")
		@script_display = finder.call("script_display")
		@static_line_3 = finder.call("static_line_3")
		@edit_btn = finder.call("edit_btn")
		@notebook_log = finder.call("notebook_log")
		@log_text = finder.call("log_text")
		@notebook_output = finder.call("notebook_output")
		@run_box = finder.call("run_box")
		@gauge_1 = finder.call("gauge_1")
		@play_btn = finder.call("play_btn")
		@pause_btn = finder.call("pause_btn")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


