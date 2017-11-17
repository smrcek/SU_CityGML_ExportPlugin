require 'sketchup'

module FHGelsenkirchenMaterials
  class BatchExporter
    def initialize
      @files = Hash.new()
      @filepath = ""
      @recursive = false;

      JF::RubyToolbar::openConsole
      prompts = ["directory","include subdirectories"]
      defaults = ["","no"]
      list = ["","yes|no"]
      input = UI.inputbox(prompts,defaults,list,"Batchexport")

      if(input.class == Array)
        @filepath = input[0]
        @recursive = (input[1] == "yes") ? true : false
        export()
      end

      #getDirectory()
    end

    def getDirectory()
      width = 400
      height = 200
      dlg = UI::WebDialog.new("CityGML Batch Exporter", true, "CityGML Batch Exporter", width, height, 0, 0, true)
      dlg.max_width = width
      dlg.min_width = width
      dlg.max_height = height
      dlg.min_height = height
      dlg.set_html(filePathhtml())

      dlg.add_action_callback("FilePath") {|dialog, params|
        parameters =  params.split(";")
        @filepath = parameters[0];
        @recursive = (parameters[1] == "1") ? true : false;
        dlg.close()
        export()
      }

      dlg.show()
    end

    def export()
      begin
        if(findDirectories(@filepath))
          CityGMLExport.new(true,@files)
        else
          puts "Directorie not found!"
        end
      rescue => e
        puts e
        puts e.backtrace
      end
    end

    def findDirectories(path)
      begin
        Dir.chdir(path)
        fileList = Dir["*.skp"]
        fileList.each do |file|
          xmlname = path + "\\" + file.chomp(File.extname(file)) + ".xml"
          @files[path + "\\" + file] = xmlname
        end
        if(@recursive)
          subdir_list=Dir["*"].reject{|o| not File.directory?(o)}
          subdir_list.each do |subdir|
            findDirectories(path + "\\" + subdir)
          end
        end
      rescue => e
        return false
      end
      return true
    end

    def filePathhtml()
      html = '
       <html>
       <head>

       </head>
       <body>
       <script type="text/javascript">
        function transmit()
        {
          parameter = document.getElementById("path").value;
          parameter += ";";
          if(document.getElementById("recursive").checked)
            parameter += "1";
          else
            parameter += "0";
          window.location = "skp:FilePath@" + parameter;
        }
       </script>
       Directory:&nbsp<input id="path" name="path" type="text" size="50" maxlength="100" value=""><br />
       <input type="button" name="ok_button" value="Ok" onclick="transmit()">
       <input name="recursive" id="recursive" type="checkbox" unchecked>Subdirectories included
       </body>
       </html>
      '
      return html
    end
  end
end