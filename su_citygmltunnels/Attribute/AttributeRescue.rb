#Sichert Attribute, um auf andere zu kopieren

module FHGelsenkirchenTunnels
  class AttributeRescue
    #Array speichert Attribute. Statische Variable, die solange das SketchUp nicht beendet wird
    #gültig bleibt
    @@clipboard = []
    def initialize()
    end

    #Sichert alle Attribute eines Faces oder einer Group
    def copy_attribute(entity)
      dicts = entity.attribute_dictionaries
      tmp = []
      #Schleife läuft über alle Dictionarys, sollten üblicherweise die Dictionarys
      # "StandardAttributes" und "GenericAttributes sein"
      dicts.each do |d|
        #Jedes Key/Value Paar wird kopiert
        d.each_pair { | key, value |
          #puts "#{key}, #{value}"
          #im Array speichern, erster Wert ist Name des Dictionary, zweiter Wert ist Key
          #dritter Wert ist value
          tmp << [d.name.to_s, key.to_s, value.to_s]
        }
      end
      #Es soll nur möglich sein, Attribute von Gruppen auch wieder auf Gruppen zu kopieren
      #Das Gleiche gilt für Faces. Deshalb wird zusätzlich zum Array aller Attribute
      #gespeichert, ob es von einem Face oder Group kopiert wurde
      if(entity.class == Sketchup::Face)
        @@clipboard << [tmp,"Face"]
      else
        @@clipboard << [tmp,"Group"]
      end
    end

    #Erzeugt Dialog, der alle bereits gespeicherten Attribute anzeigt
    def paste_attribute(entity)
      AttributeDialog.new(@@clipboard, entity)
    end
  end
end