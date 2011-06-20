# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.
# 
# This class was automatically generated from XRC source. It is not
# recommended that this file is edited directly; instead, inherit from
# this class and extend its behaviour there.  
#
# Source file: gui_conf.xrc 
# Generated at: Fri Jul 23 13:07:11 -0600 2010

class GUIConf < Wx::Frame
	
	attr_reader :label_1, :label_2, :conf_group_name_text,
              :conf_group_values_text, :static_line_2, :label_3,
              :conf_delay_text, :conf_fire_delay_text, :static_line_3,
              :label_4, :label_5, :label_6, :conf_hread_text,
              :conf_hdata_text, :conf_hcontrol_text, :allow_reuse_chk,
              :static_line_1, :conf_group_list, :conf_edit_btn
	
	def initialize(parent = nil)
		super()
		xml = Wx::XmlResource.get
		xml.flags = 2 # Wx::XRC_NO_SUBCLASSING
		xml.init_all_handlers
		xml.load("gui_conf.xrc")
		xml.load_frame_subclass(self, parent, "conf_window")

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
		@label_2 = finder.call("label_2")
		@conf_group_name_text = finder.call("conf_group_name_text")
		@conf_group_values_text = finder.call("conf_group_values_text")
		@static_line_2 = finder.call("static_line_2")
		@label_3 = finder.call("label_3")
		@conf_delay_text = finder.call("conf_delay_text")
		@conf_fire_delay_text = finder.call("conf_fire_delay_text")
		@static_line_3 = finder.call("static_line_3")
		@label_4 = finder.call("label_4")
		@label_5 = finder.call("label_5")
		@label_6 = finder.call("label_6")
		@conf_hread_text = finder.call("conf_hread_text")
		@conf_hdata_text = finder.call("conf_hdata_text")
		@conf_hcontrol_text = finder.call("conf_hcontrol_text")
		@allow_reuse_chk = finder.call("allow_reuse_chk")
		@static_line_1 = finder.call("static_line_1")
		@conf_group_list = finder.call("conf_group_list")
		@conf_edit_btn = finder.call("conf_edit_btn")
		if self.class.method_defined? "on_init"
			self.on_init()
		end
	end
end


