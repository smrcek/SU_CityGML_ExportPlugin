require 'sketchup'

module FHGelsenkirchenMaterials
  #Zeigt den Feedback Client an
  class FeedbackService
    def initialize
      path = File.dirname(__FILE__).force_encoding("UTF-8")
      str = path + "/FeedbackClient/FeedbackClient.exe Editor "
      str = str.encode("WINDOWS-1252")
      result = ""
      result << %Q["#{str}"] +' '+ FHGelsenkirchenMaterials::CITYGML_VERSION.to_s + ' ' + FHGelsenkirchenMaterials::CITYGML_BUILD.to_s
      IO.popen(result)
    end
  end

  #Startet Update Service
  class UpdateService
    def initialize
      path = File.dirname(__FILE__).force_encoding("UTF-8")
      str = path + "UpdateClient/UpdateClient.exe " 
      str = str.encode("WINDOWS-1252")
      result = ""
      result << %Q["#{str}"] +' '+ 'Editor '+ FHGelsenkirchenMaterials::CITYGML_VERSION.to_s+' '+ FHGelsenkirchenMaterials::CITYGML_BUILD.to_s
      IO.popen(result)
    end
  end

  #Starte SkpWriter
  class ImportService
    def initialize
      path = File.dirname(__FILE__).force_encoding("UTF-8")
      str = path + " \\../Import/SkpWriterGUI.exe "  
      str = str.encode("WINDOWS-1252")
      result = ""
      result << %Q["#{str}"] +' '+ FHGelsenkirchenMaterials::CITYGML_VERSION.to_s + ' ' + FHGelsenkirchenMaterials::CITYGML_BUILD.to_s
      
      IO.popen(result)
      #.encode("WINDOWS-1252")
    end
  end

  #Öffnet Changelog
  class ChangelogService
    def initialize
      path = File.dirname(__FILE__).force_encoding("UTF-8")
      str = path + "/OpenFile/OpenFile.exe " 
      str = str.encode("WINDOWS-1252")
      result = ""
      result << %Q["#{str}"] +' '+ '../../Changelog.pdf'
      IO.popen(result)
    end
  end
end