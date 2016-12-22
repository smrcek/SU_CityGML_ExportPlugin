# RubyPanel Toolbar (C) 2007 jim.foltz@gmail.com
#
# With special thanks to Chris Phillips (Sketchy Physics)
# for the Win32API code examples. 

# 2011-01-05 <jim.foltz@gmail.com>
#   * Changed Toolbar name from "Ruby COnsole" to "Ruby Toolbar"  (TT)
#     http://forums.sketchucation.com/viewtopic.php?f=323&t=1542&p=298587#p298587
#   * Wrapped in addition module RubyToolbar
#   * Use $suString.GetSting to get proper "Ruby Console" name string.
#   * Better check if TB was previously visible
#   * Use UI.start_timer to restore Toolbar

require 'sketchup'
require 'su_citygmltunnels/Win32API'

module JF
    module RubyToolbar

        case Sketchup.os_language
        when "FR"
            @wname = "Console Ruby"
        when "EN"
        else
            @wname = "Ruby Console"
        end
        #@wname = $suStrings.GetString("Ruby Console")

        # Read default position from registry
       # @rect = Sketchup.read_default("RubyToolbar", "Position")
       # unless @rect.nil?
       #     @rect = @rect.split(",").map{|e| e.to_i}
       # end
       # @recent = Sketchup.read_default("RubyToolbar", "Recent")
       # @mrud = Sketchup.read_default("RubyToolbar", "MRUD")
      #  p @recent

        # Win32API calls
        def self.findWindow 
            Win32API.new("user32.dll", "FindWindow", ['P','P'], 'N')
        end

        def self.sendMessage 
            Win32API.new("user32.dll", "SendMessage", ['N','N','N','P'], 'N')
        end

        def self.getConsole
            return findWindow.call(0, @wname)
        end

        def self.consoleOpen?
            return (getConsole() != 0)
        end
        def self.consoleClosed?
            return (not consoleOpen?)
        end


        def self.closeConsole
            #find the ruby console
            pw = getConsole()
            #send the control a "WM_CLOSE" message (0x0010)
            sendMessage.call(pw,0x0010,0,"")
        end 

        def self.openConsole
            res = Sketchup.send_action "showRubyPanel:"
            #if @rect
           #     UI.start_timer(0.1) { moveConsole(@rect) }
           # end
        end

        def self.clearConsole   
          #  moveConsole(@rect)
            #setup the win32 calls
            findWindowEx = Win32API.new("user32.dll", "FindWindowEx", ['N','N','P','P'], 'N')
            if(findWindowEx == nil)
              return
            end
            #find the ruby console
            pw = getConsole
            if(pw == nil)
              return
            end
            #get the first child control. Its the text input control.
            h=findWindowEx.call(pw,0,"Edit",0) 

            #get the second child control. its the ruby output control. 
            h=findWindowEx.call(pw,h,"Edit",0) 

            if(h == nil)
              return
            end
            #send the control a "WM_SETTEXT" message (0x000C) with an empty string.
            sendMessage.call(h,0x000C,0,"")			
            puts ""
        end



        def self.moveConsole(rect)
            x, y, w, h = rect
            #setup the win32 calls
            setWindowPos= Win32API.new("user32.dll", "SetWindowPos", ['P','P','N','N','N','N','N'], 'N') 
            #find the ruby console
            #pw=findWindow.call(0,"Ruby Console")
            pw = getConsole
            setWindowPos.call(pw,0,x,y,w,h,0)
        end 

        def self.getConsoleLocation
            getWindowRect= Win32API.new("user32.dll", "GetWindowRect",['P','PP'],'N')
            #pw=findWindow.call(0,"Ruby Console")
            pw = getConsole

            #create a char buffer large enough for the rectangle(4 ints)
            rect=Array.new.fill(0.chr,0..4*4).join
            getWindowRect.call(pw,rect);
            #turn char buffer into an array of ints.
            rect=rect.unpack("i*")

            #turn rectangle into x,y,w,h
            rect[2]=rect[2]-rect[0] #w=x2-x1
            rect[3]=rect[3]-rect[1] #h=y2-y1
            return rect
        end 

        def self.toggle
            if consoleClosed?
                openConsole
            else
                @rect = getConsoleLocation
                closeConsole
                Sketchup.write_default("RubyToolbar", "Position", @rect.join(","))
            end
        end

        def self.rt_load
            #openConsole
            unless @mrud
                @mrud = Sketchup.find_support_file("Plugins")# + "/"
            end
            @mrud.gsub!("/", "\\\\")
            f = UI.openpanel("Load Script", @mrud, "*.rb")
            return unless f
            @mrud = File.dirname(f)
            begin
                load f
                Sketchup.set_status_text "#{File.basename(f)} loaded. (#{Time.now.strftime('%H:%M:%S')})"
                @recent = f
                @recent.gsub!(/[\\]+/, '/')
                @mrud.gsub!(/[\\]+/, '/')
                Sketchup.write_default("RubyToolbar", "Recent", @recent)
                Sketchup.write_default("RubyToolbar", "MRUD", @mrud)
            rescue
                UI.messagebox("Couldn't load #{File.basename(f)}:\n #{$!}")
                #openConsole
                #puts $!
            end
        end

        def self.rt_reload
            if @recent.nil?
                rt_load
            else
                load @recent
                Sketchup.set_status_text "#{File.basename(@recent)} Reloaded. "+Time.now.strftime("%H:%M:%S")
            end
        end



        #imgdir = File.join(File.dirname(__FILE__), File.basename(__FILE__, ".rb"))
        #plugins = Sketchup.find_support_file("Plugins")
       # plugins = File.dirname(File.expand_path(__FILE__))
        #imgdir = File.join(plugins, "rubytoolbar")
       # imgdir = plugins

        # create toolbar
       # tb = UI::Toolbar.new("Ruby Toolbar")

        # Toggle console cmd
       # cmd = UI::Command.new("Show/Hide") { toggle }
       # cmd.large_icon = cmd.small_icon = File.join(imgdir, "rubypanel.png")
       # cmd.status_bar_text = cmd.tooltip = "Show/Hide Ruby Console"
       # tb.add_item cmd

        # Clear Console
       # cmd = UI::Command.new("Clear") { clearConsole }
       # cmd.status_bar_text = cmd.tooltip = "Clear Console"
       # cmd.large_icon = cmd.small_icon = File.join(imgdir, "Delete24.png")
       # tb.add_item cmd

        #cmd = UI::Command.new("LoadScript") { rt_load }
        #cmd.large_icon = cmd.small_icon = File.join(imgdir, "doc_ruby.png")
        #cmd.tooltip = cmd.status_bar_text = "Load Script"
        #tb.add_item cmd

        #cmd = UI::Command.new("Reload") { rt_reload }
        #cmd.large_icon = cmd.small_icon = File.join(imgdir, "reload.png")
        #cmd.status_bar_text = cmd.tooltip = "Reload Script"
        #tb.add_item cmd

        # dev dir
        #cmd = UI::Command.new("PluginsDir") {
            #UI.openURL("c:\\program files\\google\\google sketchup 6\\plugins")
         #   UI.openURL(@mrud)
        #}
        #cmd.tooltip = cmd.status_bar_text = "Browse Plugins Folder"
        #cmd.large_icon = cmd.small_icon = File.join(imgdir, "open_folder.png")
        #tb.add_item cmd

        #if tb.get_last_state == TB_VISIBLE
        #    UI.start_timer(0.1, false) { tb.restore }
        #end

    end # RubyToolbar
end # module JF
