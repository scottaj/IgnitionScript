# Copyright(c) 2010 Al Scott
# License details can be found in the LICENSE file.

require 'gui_main'
require 'gui_conf_event'
require 'gui_bug_event'
require 'gui'
require 'yaml'
require 'thread'
require 'fileutils'

include GUI

# Class containing event code for the main GUI window.
class GUIMainEvent < GUIMain

    # Initializes Events for the main GUI window.
    def initialize
        super
        
        log(1, "Program Started")
        log(0, "Initialization started")

        log(0, "Checking directories")
        FileUtils.mkdir "logs" unless `ls`.match(/logs/)
        FileUtils.mkdir "bugs" unless `ls`.match(/bugs/)

        # Events
        
        # Close button in top corner.
        evt_close()                         {close_prog()}

        # "File" menu.
        evt_menu(ID_NEW)                    {new_script()}
        evt_menu(ID_OPEN)                   {open_script()}
        evt_menu(ID_SAVE)                   {save_script()}
        evt_menu(ID_SAVEAS)                 {saveas_script()}
        evt_menu(ID_EXIT)                   {close_prog()}

        # "Run" menu.
        evt_menu(@run_run)                  {run_script()}
        evt_menu(@run_run_from)             {run_script(1)}
        evt_menu(@run_loop)                 {run_script(2)}
        evt_menu(@run_dryrun)               {run_script(-1)}

        # "Tools" menu.
        evt_menu(@tools_conf)               {display_conf_window()}

        # "Help" menu.
        evt_menu(ID_ABOUT)                  {about()}
        evt_menu(@help_bug)                 {report_bug()}

        # Other widgets.
        evt_choice(@event_choice)           {event_type_selected()}
        evt_choice(@command_choice)         {event_subtype_selected()}

        evt_button(ID_ADD)                  {add_event()}
        evt_button(@insert_btn)             {add_event(true)}

        evt_button(ID_UP)                   {move_event(-1)}
        evt_button(ID_DOWN)                 {move_event(1)}
        evt_button(ID_DELETE)               {delete_event()}
        evt_button(@edit_btn)               {edit_event()}\

        evt_listbox_dclick(@script_display) {copy_event()}

        evt_button(ID_STOP)                 {stop_run()}
        evt_button(@play_btn)               {continue_run()}
        evt_button(@pause_btn)              {pause_run()}
          
        log(0, "Initialization complete")
    end

    # Writes a log message to the screen on the log tab.
    #
    # <i>level</i>: An integer, either 0, 1, or 2 which correspond respectivly
    #                "low", "normal", and "high" priority messages.
    # <i>message</i>: A log message as a string.
    def log(level, message)
        levels = ["Low", "Normal", "High"]
        @log_text.set_insertion_point_end
        @log_text.write_text("#{Time.now}: Urgency level #{levels[level]} -- #{message}\n\r")
    end

    # Closes the program, prompting the user to save first.
    # Called when either the
    def close_prog()
        log(1, "Program closing")
        new_script()
        log(0, "Writing log to file")
        File.open("logs/#{Time.now.month}-#{Time.now.day}-#{Time.now.year}.log", 'w') unless File.exist?(".logs/#{Time.now.month}-#{Time.now.day}-#{Time.now.year}.log")
        File.open("logs/#{Time.now.month}-#{Time.now.day}-#{Time.now.year}.log", 'a') {|log_out| log_out.write(@log_text.get_value)}
        self.destroy
    end

    # Creates a new script, first prompting user to save the current script.
    def new_script()
        log(0, "Checking save status")
        if $script.modified
            log(0, "Launching save prompt")
            prompt = MessageDialog.new(self, "Would you like to save?",
                "UNSAVED CHANGES!", YES_NO)
            if prompt.show_modal == ID_YES
                log(0, "Save prompt accepted")
                save_script()
            end
        end
        $script = Script.new
        populate_list(@script_display)
        log(1, "Blank script created")
    end

    # Opens a previously saved script
    def open_script()
        log(1, "Opening load dialog")
        dlg = FileDialog.new(self, "Choose a file", Dir.getwd(), "", "Pport Script (*.scp)|*.scp", OPEN)
        if dlg.show_modal() == ID_OK
            log(0, "File selected")
            file = dlg.get_path
            begin
                File.open(file, 'r') do |fin|
                data = YAML.load(fin)
                $script = data[0]
                $attr = data[1]
            end
                log(0, "Script loaded")
            rescue
                log(2, "Exception handled in open_script()")
            end
        end
        populate_list(@script_display)
    end

    # Saves the current script.
    def save_script()
        if $attr[:name]
            log(1, "Saving script to #{$attr[:name]}")
            File.open($attr[:name], 'w') {|fout| YAML.dump([$script, $attr], fout)}
            log(0, "Script saved")
            $script.modified = false
        else
            saveas_script()
        end
    end

    # Allows the user to select a directory and filename to save their
    # script to.
    def saveas_script()
        log(1, "Opening save dialog")
        dlg = FileDialog.new(self, "Save file as...", Dir.getwd(), "", "Pport Script (*.scp)|*.scp", SAVE)
        if dlg.show_modal() == Wx::ID_OK
            log(0, "File selected")
            $attr[:name] = dlg.get_path()
            save_script()
        end
    end

    # Runs the current script. the mod variable determines what type of run is
    # started:
    #
    # <i>mod</i>:
    # * mod==-1 is a dry run where no data is output
    # * mod==0 is a normal run starting from the beginning of the script
    # * mod==1 finds the currently selected command and starts the
    #   run from there.
    # * mod==2 Is a looped run.
    def run_script(mod = 0)
        begin
            @window_notebook.set_selection(2)
            return if $run
            sync = Mutex.new
            @gauge_1.set_value(0)
            @run_box.clear
            return if MessageDialog.new(self, "Are you certain that you want to begin\nrunning the script?", "ARM SHOW!", YES_NO).show_modal == ID_NO unless mod == -1

            if mod == -1
                log(1, "Beginning dry run")           
                $run = Thread.new do
                    $script.dry_run($attr[:read_addr], [$attr[:delay], $attr[:fire_delay]]) do |prog, msg|
                        sync.synchronize do
                            @gauge_1.set_value(prog)
                            @run_box.set_insertion_point_end
                            @run_box.write_text("#{msg}\n")
                        end
                    end
                    log(1, "Run Ended")
                    $run = nil
                end
            elsif mod == 0    
                log(1, "Beginning run")
                $run = Thread.new do
                    $script.run([$attr[:data_addr], $attr[:control_addr], $attr[:read_addr]], [$attr[:delay], $attr[:fire_delay]]) do |prog, msg|
                        sync.synchronize do
                            @gauge_1.set_value(prog)
                            @run_box.set_insertion_point_end
                            @run_box.write_text("#{msg}\n")
                        end
                    end
                    log(1, "Run Ended")
                    $run = nil
                end
            elsif mod == 1
                log(1, "Beginning run from command #{@script_display.get_selection}")
                $run = Thread.new do
                    $script.run([$attr[:data_addr], $attr[:control_addr], $attr[:read_addr]], [$attr[:delay], $attr[:fire_delay]], @script_display.get_selection) do |prog, msg|
                        sync.synchronize do
                            @gauge_1.set_value(prog)
                            @run_box.set_insertion_point_end
                            @run_box.write_text("#{msg}\n")
                        end
                    end
                    log(1, "Run Ended")
                    $run = nil
                end
            elsif mod == 2
                dlg = TextEntryDialog.new(self, "Please enter the number of times you want the script to loop.\n\nIf you make this number 0, the script will loop infinetly\n until you stop it manually")
                if dlg.show_modal == ID_OK
                    loop = dlg.get_value.to_i
                else
                    return
                end

                log(1, "Beginning run")
                $run = Thread.new do
                    $script.run([$attr[:data_addr], $attr[:control_addr], $attr[:read_addr]], [$attr[:delay], $attr[:fire_delay]], false, loop) do |prog, msg|
                        sync.synchronize do
                            @gauge_1.set_value(prog)
                            @run_box.set_insertion_point_end
                            @run_box.write_text("#{msg}\n")
                        end
                    end
                    log(1, "Run Ended")
                    $run = nil
                end
            end
        rescue NoMethodError
            log(2, "Exception handled in run_script()")
            MessageDialog.new(self, "No starting point selected for run!",
                "Run from...", OK)
        end
        log(0, "Returning to main thread")
    end

    # Hides the main window and displays the configuration window.
    def display_conf_window()
        log(1, "Opening configuration window")
        GUIConfEvent.new(self).show
        log(0, "Hiding main window")
        self.hide
        $script.modified = true
    end

    # Diplays a dialog with program information.
    def about()
        log(1, "Displaying about dialog")
        MyAboutBox.new(self).show
    end

    # Displays the bug report creation dialog.
    def report_bug()
        log(1, "Displaying bug report dialog")
        GUIBugEvent.new(self).show
        log(0, "Hiding main window")
        self.hide
    end

    # Sets sub events to the appropriate values for the event type selected.
    def event_type_selected()
        log(1, "Event type selected")
        @data_text.clear
        choice = @event_choice.get_string_selection
        if choice.match(/write/i)
            log(0, "Write event selected")
            @command_choice.clear
            $attr[:groups].each_key {|group_name| @command_choice.append(group_name)}
        elsif choice.match(/time/i)
            log(0, "Time based event selected")
            @command_choice.clear
            @command_choice.append("Pause for time")
            @command_choice.append("Pause until time")
        elsif choice.match(/read/i)
            log(0, "Read event selected")
            @command_choice.clear
            @command_choice.append("Wait for read port to change")
            @command_choice.append("Wait for read port to have specific value")
        elsif choice.match(/script/i)
            log(0, "Script event selected")
            @command_choice.clear
            @command_choice.append("Pause script")
            @command_choice.append("Play script")
            @command_choice.append("Load and start another script")
        else
            log(0, "Other selected")
            @command_choice.clear
            @command_choice.append("Subtype")
        end
    end

    # Fills in command values for external events when a group is selected.
    def event_subtype_selected()
        log(1, "Event subtype selected")
        begin
            choice = @command_choice.get_string_selection
            if @event_choice.get_string_selection.match(/write/i)
                log(0, "Looking for group auto-value")
                group = $attr[:groups][choice]
                value = nil
                group.each {|val| value = val and break unless $attr[:used].include?(val)}
                value = group[0] if $attr[:reuse] and not value
                if value
                    log(0, "Auto-value #{value} found")
                    @data_text.set_value(value.to_s)
                else
                    log(0, "No value found")
                    MessageDialog.new(self, "No free values are availible for this group!",
                    "Group Empty", OK).show_modal
                end
            end
        rescue NoMethodError
            log(2, "Exception handled in event_subtype_selected()")
        end
    end

    # Adds an event to the script.
    #
    # <i>pos</i>: an optional argument that gives a
    #             position to insert the event at, otherwise the event
    #             is just added to the end of the script.
    def add_event(pos = false)
        log(1, "Adding event #{"at position#{pos}" if pos}")
        if $edit
            log(0, "Replacing previous command number #{$edit}")
            pos = $edit
            delete_event(pos)
            $edit = pos
        end
        
        event = nil
        log(0, "Gathering event data")
        event_type = @event_choice.get_string_selection
        event_subtype = @command_choice.get_string_selection
        if event_type.match(/write/i)
            log(0, "Creating write event")
            begin
                fail if $attr[:used].include?(@data_text.get_value.to_i) unless $attr[:reuse]
                fail if not ($attr[:groups][event_subtype].include?(@data_text.get_value.to_i))
                fail if @data_text.get_value.to_i < 0 or @data_text.get_value.to_i > 511
                event = WriteEvent.new(@comment_text.get_value, event_subtype, @data_text.get_value.to_i)
                $attr[:used].push(@data_text.get_value.to_i) unless $attr[:used].include?(@data_text.get_value.to_i)
            rescue RuntimeError
                log(2, "Exception handled in add_event()")
                MessageDialog.new(self, "Given value is invalid for this command.",
                "Invalid Input!", OK).show_modal
                @data_text.clear
                return
            end
        elsif event_type.match(/time/i)
            log(0, "Creating time event")
            if event_subtype.match(/for/i)
                event = WaitEvent.new(@comment_text.get_value, @data_text.get_value.to_f)
            elsif event_subtype.match(/until/i)
                event = TimeEvent.new(@comment_text.get_value, @data_text.get_value)
            end
        elsif event_type.match(/read/i)
            log(0, "Creating read event")
            if event_subtype.match(/change/)
                event = ReadEvent.new(@comment_text.get_value, -1)
            elsif event_subtype.match(/value/)
                event = ReadEvent.new(@comment_text.get_value, @data_text.get_value.to_i)
            end
        end

        if event
            log(0, "Adding event to script")
            if pos
                begin
                    pos = @script_display.get_selection unless pos == $edit
                    $script.add_event(event, pos)
                rescue NoMethodError
                    log(2, "Exception handled in add_event()")
                end
            else
                $script.add_event(event)
            end
            @comment_text.clear()
            populate_list(@script_display)
            event_subtype_selected()
        end
        $edit = false
    end

    # Moves an event up or down in the script.
    #
    # <i>dir</i>: A number
    #             
    # * If dir is negative then the selected item is
    #   moved up <i>dir</i> places.
    # * If dir is positive then the selected item is
    #   moved down <i>dir</i> places.
    def move_event(dir)
        log(1, "Moving event #{"up" if dir<0}#{"down" if dir>0}")
        begin
            to_move = @script_display.get_selection
        rescue NoMethodError
            log(2, "Exception handled in move_event()")
            return
        end
        $script.move_event(to_move, dir)
        populate_list(@script_display)
        @script_display.set_selection(to_move+dir)
        $edit = false
    end

    # Removes an event from the script.
    #
    # <i>pos</i>:
    # * If pos is false or nil the currently selected event is deleted.
    # * If pos is a number then the script item at that position is deleted.
    def delete_event(pos = false)
        log(1, "Deleting event")
        if pos
            log(0, "Deleting event at position #{pos}")
            $attr[:used].delete_if {|num| num == $script.script[pos].value[1]}
            $script.remove_event(pos)
            populate_list(@script_display)
        else
            begin
                to_delete = @script_display.get_selection
            rescue NoMethodError
                log(2, "Exception handled in delete_event()")
                return
            end
            log(0, "Deleting selected event")
            $attr[:used].delete_if {|num| num == $script.script[to_delete].value[1]}
            $script.remove_event(to_delete)
            populate_list(@script_display)
            
        end
        $edit = false
    end

    # Edits an event in the script.
    def edit_event()
        log(1, "Editing current event")
        begin
            $edit = @script_display.get_selection
        rescue NoMethodError
            $edit = false
            log(2, "Exception handled in edit_event()")
            return
        end
        if $edit
            to_edit = $script.script[$edit]
            
            if to_edit.instance_of?(WriteEvent)
                log(0, "Editing write event")
                @event_choice.set_string_selection("Write Event")
                event_type_selected()
                @command_choice.set_string_selection(to_edit.value[0])
                @data_text.set_value(to_edit.value[1].to_s)
                @comment_text.set_value(to_edit.comment)
            elsif to_edit.instance_of?(WaitEvent) or to_edit.instance_of?(TimeEvent)
                log(0, "Editing time event")
                @event_choice.set_string_selection("Time Event")
                event_type_selected()
                @command_choice.set_string_selection("Pause for time") if to_edit.instance_of?(WaitEvent)
                @command_choice.set_string_selection("Pause until time") if to_edit.instance_of?(TimeEvent)
                @data_text.set_value(to_edit.value[0].to_s)
                @comment_text.set_value(to_edit.comment)
            elsif to_edit.instance_of?(ReadEvent)
                log(0, "Editing read event")
                @event_choice.set_string_selection("Read Event")
                event_type_selected()
                @command_choice.set_string_selection("Wait for read port to have specific value")
                @command_choice.set_string_selection("Wait for read port to change") if to_edit.value[0] == -1
                @data_text.set_value(to_edit.value[0].to_s) unless to_edit.value[0] == -1
                @comment_text.set_value(to_edit.comment)
            end
        end
    end

    # Copies an event to the end of the list.
    def copy_event()
        log(1, "Event copied.")
		edit_event()
        $edit = false
        event_subtype_selected() unless $attr[:reuse]
        add_event()
    end

    # Stops any currently running script, killing the thread it is running in.
    def stop_run()
        log(0, "Script told to stop.")
		return unless $run
        log(1, "Stopping script.")
        $run.kill!
        $run = nil
    end

    # Restarts any paused script.
    def continue_run()
		log(0, "Script told to restart.")
        return unless $run
		log(0, "Script restarting.")
        $script.pause = false
        $run.run
    end

    # Pauses any currently running script, a currently executing command will
    # still finish.
    def pause_run()
        log(0, "Script told to pause.")
		return unless $run
		log(0, "Script pausing.")
        $script.pause = true
    end
end