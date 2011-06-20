# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'gui'
require "gui_conf"

include GUI

# Class with event code for the configuration dialog.
class GUIConfEvent < GUIConf

    # Initializes the configuration window.
    def initialize(parent)
        super

        @parent = parent

        @conf_delay_text.set_value($attr[:delay].to_s)
        @conf_fire_delay_text.set_value($attr[:fire_delay].to_s)
        @conf_hread_text.set_value("0x#{$attr[:read_addr].to_s(16)}")
        @conf_hdata_text.set_value("0x#{$attr[:data_addr].to_s(16)}")
        @conf_hcontrol_text.set_value("0x#{$attr[:control_addr].to_s(16)}")
        @allow_reuse_chk.set_value($attr[:reuse])
        write_groups()

        # Events
        evt_close()                     {conf_exit()}
        
        evt_button(ID_APPLY)            {add_group()}
        evt_button(ID_CLEAR)            {clear_group()}
        evt_button(@conf_edit_btn)      {edit_group()}

        evt_checkbox(@allow_reuse_chk)  {toggle_reuse()}
    end

    # Writes all current groups to the list.
    def write_groups()
        @conf_group_list.clear
        $attr[:groups].each_pair {|group, values| @conf_group_list.insert("#{group}: #{neaten_numbers(values)}", 0)}
    end

    # Destroys the configuration window and shows the parent window.
    # Called when the close button is pressed.
    def conf_exit()
        $attr[:delay] = @conf_delay_text.get_value.to_f
        $attr[:fire_delay] = @conf_fire_delay_text.get_value.to_f
        $attr[:read_addr] = @conf_hread_text.get_value.to_i(16)
        $attr[:data_addr] = @conf_hdata_text.get_value.to_i(16)
        $attr[:control_addr] = @conf_hcontrol_text.get_value.to_i(16)
        @parent.show
        self.destroy
    end

    # Adds a group from the data given in the adjacent text fields.
    # Called when the "Apply" button is pressed.
    def add_group()
        group_name = @conf_group_name_text.get_value
        group_values = @conf_group_values_text.get_value

        group_values = expand_ranges(group_values)
        begin
            errval = nil
            group_values.each do |val|
                $attr[:groups].each_value do |arr|
                    if arr.include?(val)
                        errval = val
                        fail
                    end
                end
            end
        rescue RuntimeError
            MessageDialog.new(self, "Value #{errval} is already in use by another group!",
            "Error Creating Group", OK).show_modal
            return
        end
        $attr[:groups][group_name] = group_values
        write_groups()
    end

    # Clears the selected group from the list.
    # Called when the "Clear" button is pressed.
    def clear_group()
        begin
            selection = @conf_group_list.get_string_selection
            selection = selection.split(":")[0]
            selection.strip!
            $attr[:groups].delete(selection)
            @conf_group_list.delete(@conf_group_list.get_selection)
        rescue NoMethodError # Raised if no group selected from list.
        end
    end

    # Edits the currently selected group.
    # Called when the "Edit" button is pressed.
    def edit_group()
        begin
            selection = @conf_group_list.get_string_selection
            selection = selection.split(":")
            @conf_group_name_text.set_value(selection[0].strip)
            @conf_group_values_text.set_value(selection[1].strip)
            clear_group()
        rescue NoMethodError # Raised if no group selected from list.
        end
    end

    # Toggles ability to reuse group values in a script.
    # Called when the Reuse chechbox is checked or unchecked.
    def toggle_reuse()
        if @allow_reuse_chk.is_checked
            $attr[:reuse] = true
        else
            $attr[:reuse] = false
        end
    end
end
