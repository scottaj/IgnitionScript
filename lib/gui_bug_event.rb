# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'gui_bug'
require 'gui'

# Class describing the actions and event in the bug reporting dialog.
class GUIBugEvent < GUIBug

    # The bug report window is initialized.
    def initialize(parent)
        super

        @parent = parent
        evt_close()                     {exit_dlg}
        evt_button(@submit_btn)         {create_report()}
    end

    # Exits the dialog and shows the main window.
    def exit_dlg()
        @parent.show
        self.destroy
    end

    # Creates a bug report and saves it to the bug folder so it can be emailed
    # to a developer.
    def create_report()
        report = <<STR_END
#### STEPS TO REPRODUCE BUG ####

#{@list_steps_text.get_value}


#### DESCRIPTION OF BUG ####

#{@description_text.get_value}

--#{@reproduce_check.get_value}
--#{@past_check.get_value}


#### SESSION LOG ####

#{@parent.log_text.get_value}


--------------------------------------------------------------------------------
#{IO.readlines($attr[:name]).join("\n") if $attr[:name]}
STR_END
        
        fname = "bugs/#{Time.now.to_s.split(" ").join("_")}_#{$attr[:name].split(/[\/\\]/).join("_") if $attr[:name]}_bug"
        File.open(fname, 'w') {|fout| fout.write(report)}
        prompt = MessageDialog.new(self, "Bug report saved to file: #{fname}\nPlease email this file to the developer!",
                "Bug Report Created", OK)
        exit_dlg() if prompt.show_modal == ID_OK
    end
end
