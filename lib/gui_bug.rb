# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.
#
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: gui_bug.xrc 
# Generated at: Mon Jun 14 18:12:24 -0400 2010

class GUIBug < Wx::Dialog
	
	attr_reader :label_1, :list_steps_text, :reproduce_check,
              :past_check, :static_line_1, :label_2, :text_ctrl_1,
              :static_line_2, :submit_btn
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load("gui_bug.xrc")
		xml.load_dialog_subclass(self, parent, "bug_dialog")

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
		
		@label_1 = finder.call("label_1")
		@list_steps_text = finder.call("list_steps_text")
		@reproduce_check = finder.call("reproduce_check")
		@past_check = finder.call("past_check")
		@static_line_1 = finder.call("static_line_1")
		@label_2 = finder.call("label_2")
		@description_text = finder.call("text_ctrl_1")
		@static_line_2 = finder.call("static_line_2")
		@submit_btn = finder.call("submit_btn")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


