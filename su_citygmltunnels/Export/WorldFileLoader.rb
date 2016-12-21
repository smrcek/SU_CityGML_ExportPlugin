module FHGelsenkirchenTunnels
  #Klasse zum Laden einer WorldFile.
  #Dient zum Transformieren von Koordinaten beim Exportieren
  class WorldFileLoader
    #Worldfile speichert 4 Informationen
    attr_accessor :x  #Offset auf X-Koordinate
    attr_accessor :y  #Offset auf Y-Koordinate
    attr_accessor :z  #Offset auf Z-Koordinate
    attr_accessor :yaw  #Yaw ist Winkel, um den das Model rotiert werden soll
    def initialize
      
    end

    #Läd Worldfile und speichert Informationen im Model
    def loadworldfile
      filename = UI.openpanel "Open Worldfile", nil, "*.dxt"
      return if(filename == nil)
      f = File.new(filename, "r")
      lines = f.readlines
      f.close
      if(lines.length != 4)
        UI.messagebox("Not a valid Worldfile")
        return false;
      else
        #model = Sketchup.active_model
        #model.set_attribute("Attribute", "Offset_X", lines[0].to_f)
        #model.set_attribute("Attribute", "Offset_Y", lines[1].to_f)
        #model.set_attribute("Attribute", "Offset_Z", lines[2].to_f)
        #model.set_attribute("Attribute", "Yaw", lines[3].to_f)
        self.x = lines[0].to_f
        self.y = lines[1].to_f
        self.z = lines[2].to_f
        self.yaw = lines[3].to_f
        return true;
      end
      return false;
    end
  end
end
