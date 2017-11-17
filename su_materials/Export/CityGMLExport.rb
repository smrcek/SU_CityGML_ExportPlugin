require 'su_materials\Export\WorldFileLoader'
require 'su_materials\Export\GMLExportDialog'
require 'su_materials/Attribute/attribute'
require 'su_materials\UI\ProgressBar'

module FHGelsenkirchenMaterials
  #Klasse zum Exportieren von Modellen
  class CityGMLExport
    #Es gibt Probleme, da Ruby 1.8 beim Schreiben von Datein kein UTF-8 genutzt wird
    #Methode zum Ersetzen von Sonderzeichen. Texturnamen werden mit Umlauten exportiert
    #Im XML sind keine Umlaute möglich, da UTF-8 nicht funktioniert
    #Parameter 1: Pfad, in dem Exportiert werden soll
    def cleanfilenames(path)
      begin
        if(@texturepath == "")
          dir = Dir.entries(path)
        else
          dir = Dir.entries(path + "//" + @texturepath)
        end
        dir.each do  |p|
          if(p != "." and p != "..")
            #if p =~ /\.(jpe?g|tiff?|bmp|png)$/
            #  aaa = "xxx"
            #end

            if p.rindex(".jpg") or p.rindex(".jpeg") or p.rindex(".bmp") or p.rindex(".tif") or p.rindex(".png")
              x = []
              y = ""
              p.each_byte do |c|
                x << c
                #puts c
                #puts c.chr
              end
              for i in 0..(x.length() -2)
                a = x[i]
                y << "ss" if(a == 223)
                y << "oe" if(a == 246)
                y << "ae" if(a == 228)
                y << "ue" if(a == 252)
                y << "Oe" if(a == 214)
                y << "Ae" if(a == 196)
                y << "__" if(a == 38)
                y << "Ue" if(a == 220)
                y << a if(a < 128 and a != 38)
              end
              y << x[-1] if (x[-1] < 128)
              begin
                if(@texturepath == "")
                  File.rename(path + "//" + p , path + "//" + y)
                else
                  File.rename(path + "//" + @texturepath + "//" + p , path + "//" + @texturepath + "//" + y)
                end
                  #puts "#{p}, #{y}"
              rescue => e
                puts e
              end
              @filenames[p] = y
            end
          end
        end
      rescue =>e
        puts e
        puts e.backtrace
      end
    end

    def filebasename(filepath)
      return File.basename(filepath, File.extname(filepath))
    end

    # append ".xml" to filename, if no extension present
    def filename_with_type(filepath)
      filepath += ".xml" if File.extname(filepath).empty?
      return filepath
    end

    def exportGmlCoreAttributes(dictionaries)
      return if(dictionaries == nil)

      stdDict = dictionaries["Standard attribute"];
      if(stdDict != nil)
        available = AttributeEdit.AvailableBuildingAttributes
        available.each do |key|
          # Generische Attribute müssen nach den core und vor den bldg Attributen
          if(key == "class")
            return;
          end
          value = FHGelsenkirchenMaterials::stringDecode(stdDict[key]);
          if(value == nil)
            next;
          end
          case key
            when "description"
              @handle << "<gml:description>#{value.to_s()}</gml:description>\n"
            when "name"
              @handle << "<gml:name>#{value.to_s()}</gml:name>\n"
            when "creationDate"
              @handle << "<core:creationDate>#{value.to_s()}</core:creationDate>\n"
            when "terminationDate"
              @handle << "<core:terminationDate>#{value.to_s()}</core:terminationDate>\n"
          end
        end
      end
    end

    def exportGenAttributes(dictionaries)
      return if(dictionaries == nil)

      genDict = dictionaries["Generic attribute"];
      if(genDict != nil)
        genDict.each do |k,v|
          key = FHGelsenkirchenMaterials::stringDecode(k);
          value = FHGelsenkirchenMaterials::stringDecode(v);
          @handle << "<gen:stringAttribute name=\"#{key.to_s()}\">"
          @handle << "<gen:value>#{value.to_s()}</gen:value>"
          @handle << "</gen:stringAttribute>\n"
        end
      end

      write = false;
      stdDict = dictionaries["Standard attribute"];
      if(stdDict != nil)
        available = AttributeEdit.AvailableBuildingAttributes
        available.each do |key|
          # Generische Attribute müssen nach den core und vor den bldg Attributen
          if(key == "class")
            write = true;
          end
          if(!write)
            next;
          end
          value = FHGelsenkirchenMaterials::stringDecode(stdDict[key]);
          if(value == nil)
            next;
          end
          case key
            when "measuredHeight"
              @handle << "<bldg:measuredHeight uom=\"m\">#{value.to_s()}</bldg:measuredHeight>\n"
            when "storeysAboveGround"
              @handle << "<bldg:storeysAboveGround>#{value.to_s()}</bldg:storeysAboveGround>\n"
            when "storeysBelowGround"
              @handle << "<bldg:storeysBelowGround>#{value.to_s()}</bldg:storeysBelowGround>\n"
            when "class"
              @handle << "<bldg:class>#{value.to_s()}</bldg:class>\n"
            when "function"
              @handle << "<bldg:function>#{value.to_s()}</bldg:function>\n"
            when "usage"
              @handle << "<bldg:usage>#{value.to_s()}</bldg:usage>\n"
            when "yearOfConstruction"
              @handle << "<bldg:yearOfConstruction>#{value.to_s()}</bldg:yearOfConstruction>\n"
            when "yearOfDemolition"
              @handle << "<bldg:yearOfDemolition>#{value.to_s()}</bldg:yearOfDemolition>\n"
            when "storeyHeightsAboveGround"
              @handle << "<bldg:storeyHeightsAboveGround uom=\"m\">#{value.to_s()}</bldg:storeyHeightsAboveGround>\n"
            when "storeyHeightsBelowGround"
              @handle << "<bldg:storeyHeightsBelowGround uom=\"m\">#{value.to_s()}</bldg:storeyHeightsBelowGround>\n"
            when "roofType"
              @handle << "<bldg:roofType>#{value.to_s()}</bldg:roofType>\n"
            when "description"
              @handle << "<gml:description>#{value.to_s()}</gml:description>\n"
            when "name"
              @handle << "<gml:name>#{value.to_s()}</gml:name>\n"
            when "creationDate"
              @handle << "<core:creationDate>#{value.to_s()}</core:creationDate>\n"
            when "terminationDate"
              @handle << "<core:terminationDate>#{value.to_s()}</core:terminationDate>\n"
          end
        end
      end
    end

    #Findet alle Attribute und exportiert diese
    #Parameter 1:Die dictionaries, in denen alle Attribute gespeichert sind
    #Parameter 2: Bool, ob Attribute Exportiert werden sollen oder nicht. Wird
    #am Anfang verwendet, um Informationen zu finden, die nicht in die XML-Datei
    #gespeichert werden sollen
    def export_attributes(attribute_dictionaries)
      return if(attribute_dictionaries == nil)

      attrDict = attribute_dictionaries['Attribute'];
      if(attrDict != nil)
        attrDict.each do |k, v|
          next if(v == nil or v == "")
          key = FHGelsenkirchenMaterials::stringDecode(k)
          value = FHGelsenkirchenMaterials::stringDecode(v)
          case key
            when "Offset_X"
              #@offsetx = value.to_f()
            when "Offset_Y"
              #@offsety = value.to_f()
            when "Offset_Z"
              #@offsetz = value.to_f()
            when "Yaw"
              #@yaw = value.to_f()
            when "PolygonID"
            when "id"
            when "LinearRingID"
            when "import"
              #puts "wurde importiert"
              @faktor = 1
              @offsetfaktor = 1
            when "offset"
              #mach nichts
          end
        end
      end
    end

    #Hauptfunktion beim Exportieren
    def initialize(isbatch,files)
      begin
        @filename_pur = ""
        @ringerror = false
        @polygonerror = false
        @buildingerror = false
        @offsetx = 0
        @offsety = 0
        @offsetz = 0
        @yaw = nil

        JF::RubyToolbar::openConsole
        model = Sketchup.active_model
        #name = model.name
        #name = "Untitled" if(name.empty?)
        if(!isbatch)
          savepath = UI.savepanel("CityGML File", nil, "*.gml|*.gml|*.xml|*.xml||")
          return if(savepath == nil)
          savepath = filename_with_type(savepath)
          @filename_pur = filebasename(savepath)
        end

        #Exportoptionen anzeigen
        #juen        dlg = UI::WebDialog.new("CityGML Export", true,  "GMLExport #{rand(1000)}", 470, 900, 400, 400, true)
        if(JF::RubyToolbar::consoleOpen? and !isbatch)
          JF::RubyToolbar::clearConsole
        end

        width = 670
        height = 600
        dlg = UI::WebDialog.new("CityGML Export", true, nil, width, height)
        dlg.max_width = width
        dlg.min_width = width
        dlg.max_height = height
        dlg.min_height = height
        dlg.set_position(100,50)
        #Sketchup.send_action "showRubyPanel:"
        layers = []
        #Layer auslesen und für Anzeige im Dialog vorbereiten
        active_layer = model.active_layer
        model.layers.each do |layer|
          if(layer == active_layer)
            layers << [layer.name, layer.visible?, true]
          else
            layers << [layer.name, layer.visible?, false]
          end
        end
        #html = GMLExportDialog::createDialog(layers,isbatch)
        dlg.set_file(File.dirname(__FILE__) + "/../Dialog/export.html");
        #CallBack, wenn ein Layer im Dialog aktiviert/deaktiviert wird
        dlg.add_action_callback("Layervisible") {|dialog, params|
          begin
            model = Sketchup.active_model
            parameters = params.split(";")
            #puts parameters
            layer = model.layers[parameters[0]]
            if(parameters[1] == "true")
              layer.visible= true
            else
              layer.visible= false
            end
          rescue =>e
            #puts e.backtrace
          end
        }
        dlg.add_action_callback("GetLayer") {|dialog, params|
          script = "OnGetLayer('{"

          first = true
          model.layers.each do |layer|
            if(first)
              first = false
            else
              script << ","
            end
            script << '"' << layer.name << '": '
            if(layer == active_layer)
              script << '2'
            else
              if(layer.visible?)
                script << '1'
              else
                script << '0'
              end
            end
          end
          script << "}');"
          dialog.execute_script(script)
        }
        #Callback, wennn abgebrochen wird
        dlg.add_action_callback("Abort") {|dialog, params|
          dialog.close()
        }
        dlg.add_action_callback("IsBatch") {|dialog, params|
          dialog.execute_script("OnIsBatch(#{isbatch});")
        }
        dlg.add_action_callback("saveOffset") {|dialog, params|
          model = Sketchup.active_model
          model.set_attribute("Attribute", "Offset_X", dialog.get_element_value("offset_x").gsub(/[,]/, '.'))
          model.set_attribute("Attribute", "Offset_Y", dialog.get_element_value("offset_y").gsub(/[,]/, '.'))
          model.set_attribute("Attribute", "Offset_Z", dialog.get_element_value("offset_z").gsub(/[,]/, '.'))
          model.set_attribute("Attribute", "Yaw", dialog.get_element_value("yaw").gsub(/[,]/, '.'))
        }
        #Callback, wenn die Geolocation angefordert wird
        dlg.add_action_callback("get_Geolocation") {|dialog, params|
          java_script = "latitude = #{Sketchup.active_model.shadow_info["Latitude"].to_f};\n"
          java_script << "longitude = #{Sketchup.active_model.shadow_info["Longitude"].to_f};\n"

          dialog.execute_script(java_script)
        }
        #Callback, wenn Button zum Laden der Worldfile gedrückt wird
        dlg.add_action_callback("loadworldfile") {|dialog, params|
          worldfile = WorldFileLoader.new
          if(worldfile.loadworldfile)
            #JavaScript im Webdialog ausführen, damit Werte auch angezeigt werden
            #java_script = "document.Daten.offset_x.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_X", 0.0))}';\n"
            #java_script << "document.Daten.offset_y.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_Y", 0.0))}';\n"
            #java_script << "document.Daten.offset_z.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_Z", 0.0))}';\n"
            #java_script << "document.Daten.yaw.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Yaw", 0.0))}';\n"
            java_script = "document.Daten.offset_x.value = '#{worldfile.x}';\n"
            java_script << "document.Daten.offset_y.value = '#{worldfile.y}';\n"
            java_script << "document.Daten.offset_z.value = '#{worldfile.z}';\n"
            java_script << "document.Daten.yaw.value = '#{worldfile.yaw}';\n"

            dialog.execute_script(java_script)
          end
        }
        #Callback zum Zentrieren des Dialogs
        dlg.add_action_callback("move") { |d, a|
          #x, y = xy.split(",").map{ |b| b.to_i }
          #w, h = wh.split(",").map{ |b| b.to_i }

          xy, wh = a.split(":")

          x, y = xy.split(",")
          x = x.to_i
          y = y.to_i

          w, h = wh.split(",")
          w = w.to_i
          h = h.to_i

          d.set_position((x - w)/2, (y - h)/2)
        }
        dlg.add_action_callback("LoadOffset") { |d, a|
          begin
            java_script = "document.Daten.offset_x.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_X", 0.0))}';\n"
            java_script << "document.Daten.offset_y.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_Y", 0.0))}';\n"
            java_script << "document.Daten.offset_z.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Offset_Z", 0.0))}';\n"
            java_script << "document.Daten.yaw.value = '#{(Sketchup.active_model.get_attribute("Attribute", "Yaw", 0.0))}';\n"

            d.execute_script(java_script)
          rescue => e
            puts e
            puts e.backtrace
          end
        }
        #Callback, der den Export startet
        dlg.add_action_callback("GmlExport") {|dialog, params|
          begin
            #model = Sketchup.active_model
            #model.set_attribute("Attribute", "Offset_X", dialog.get_element_value("offset_x").gsub(/[,]/, '.'))
            #model.set_attribute("Attribute", "Offset_Y", dialog.get_element_value("offset_y").gsub(/[,]/, '.'))
            #model.set_attribute("Attribute", "Offset_Z", dialog.get_element_value("offset_z").gsub(/[,]/, '.'))
            #model.set_attribute("Attribute", "Yaw", dialog.get_element_value("yaw").gsub(/[,]/, '.'))
            @offsetx = dialog.get_element_value("offset_x").gsub(/[,]/, '.').to_f
            @offsety = dialog.get_element_value("offset_y").gsub(/[,]/, '.').to_f
            @offsetz = dialog.get_element_value("offset_z").gsub(/[,]/, '.').to_f
            @yaw = dialog.get_element_value("yaw").gsub(/[,]/, '.').to_f
          rescue => e
            puts e
          end
          #puts params
          begin
            #Exportparameter werden durch ; getrennt
            parameters =  params.split(";")
            #Parameter 9 gibt an, ob Easting und Nothing getauscht werden sollen
            #Dann muss X und Y wert getauscht werden UND Reihenfolge der Punkte gedreht werden
            if(parameters[8] == "1")
              @switch = false
            else
              @switch = true
            end
            #puts @switch
            #Prameter 2 ist das LOD, muss noch Addiert werden um 1, da Position
            #in Checkbox übergeben wird
            @lodNum = parameters[1].to_i();

            layernames = Hash.new()
            #Alle Layernamen werden durch | getrennt, sind im Parameter 1 gespeichert
            parameters[0].split("|").each do |p|
              #puts p
              layernames[p] = 1
            end
            #im Paramameter 3 ist ein optionaler Texturpfad angegeben
            if(parameters[2])
              @texturepath = parameters[2]
            else
              @texturepath = ""
            end
            #Parameter 4 gibt an, ob Appearance gruppiert werden sollen
            if(parameters[3] == "1")
              @groupappearance = true
            else
              @groupappearance = false
            end
            #Parameter 5 gibt an, ob Materialien gruppiert werden sollen
            if(parameters[4] == "1")
              @groupmaterials = true
            else
              @groupmaterials = false
            end
            #Parameter 6 gibt an, ob Id's generiert werden sollen bzw. Id's
            #überhaupt exportiert werden sollen. 3 Möglichkeiten
            #Variante 1: IDs nur für Buildings, nicht generieren
            #Variante 2: IDs für alle Elemente, generieren wenn keine
            #Variante 3: IDs für alles, aber nur wenn vorhanden
            if(parameters[5] == "1")
              @noid = true
              @generate = false
            elsif (parameters[5] == "2")
              @noid = false
              @generate = true
            else
              @noid = false
              @generate = false
            end

            #Parameter 7 aktiviert das gruppieren von Surfaces des gleichen Typs
            if(parameters[6] == "1")
              @groupsurfaces = true
            else
              @groupsurfaces = false
            end
            #Parameter 8 aktiviert das überprüfen, ob doppelte IDs vorkommen
            if(parameters[7] == "1")
              @collisiondetection = true
            else
              @collisiondetection = false
            end
            #Parameter 10: String des Coordinate system
            if(parameters[9])
              @coordinate_system = parameters[9]
            else
              @coordinate_system = ""
            end

            #Parameter 11: 0= MultiSurface; 1= Solid
            @gmlType = parameters[10].to_i();

            #Speichert den XML-Tag für das LOD
            @lod = "mtrl:lod" + @lodNum.to_s();
            #if(@gmlType == 1)
            #@lod += "Solid"
            #else
            @lod += "MultiSurface"
            #end

            dlg.close()

            if(!isbatch)
              export(savepath)
            else
              files.each do |skpN,xmlN|
                if(Sketchup.open_file(skpN))
                  xmlFileName = ""
                  index = 0
                  if(File.exists?(xmlN))
                    while(true)
                      xmlFileName = File.dirname(xmlN) + "\\" + filebasename(xmlN) + "_" + index.to_s + ".xml";
                      index += 1;
                      if(!File.exists?(xmlFileName))
                        break;
                      end
                    end
                  else
                    xmlFileName = xmlN
                  end
                  @filename_pur = filebasename(xmlFileName)
                  @texturepath = "textures for " + @filename_pur
                  @offsetx = Sketchup.active_model.get_attribute("Attribute", "Offset_X", "0.0").gsub(/[,]/, '.').to_f
                  @offsety = Sketchup.active_model.get_attribute("Attribute", "Offset_Y", "0.0").gsub(/[,]/, '.').to_f
                  @offsetz = Sketchup.active_model.get_attribute("Attribute", "Offset_Z", "0.0").gsub(/[,]/, '.').to_f
                  @yaw = Sketchup.active_model.get_attribute("Attribute", "Yaw", "0.0").gsub(/[,]/, '.').to_f
                  @filename_pur = FHGelsenkirchenMaterials::str_filter(@filename_pur)
                  export(xmlFileName)
                end
              end
            end
          end
        }

        dlg.show();

      rescue => e
        puts e
        puts e.backtrace
      end

    end

    def export(savepath)
      @faktor = 0.0254
      @offsetfaktor = 39.3700787
      @buildinggennr = 1
      @entities = []
      @exportedid = Hash.new()
      @filenames = Hash.new()
      @oldbuildingids = Hash.new()
      @texturehash = Hash.new()
      @pointhash = Hash.new()
      @maxtiefe = 0
      @interiorpointhash = Hash.new()
      @polygonidhash = Hash.new()
      @ringidhash = Hash.new()
      @exportet_texture_hash = Hash.new()
      @parameterizedTextureHash = Hash.new
      @x3dmaterial = Hash.new()
      @valid = 0
      @backMaterialCount = 0
## doplnena funkce dle pozadovaneho typu
      stdbuilding = ""
      stdbuildingid = ""
      stdnosurfacetype = ""
      stdpolygonpos = 0

#Read all layers from "layers" directory and makes hash of layers hashes
#Lee todos layers de directory "layers" y hace hash
      readLayers = Hash.new
      stdLayers = Hash.new
      Dir.foreach(File.dirname(__FILE__) + "/layers/") do |item|
        items = item.split('.')
        if(!items[0].nil?)
          readLayers[items[0]] = Hash.new
          stdLayers[items[0]] = Hash.new
        end
      end




      nosurfacetype = ""

      model = Sketchup.active_model
#Erzeuge XML-Datei
      @handle = File.open(savepath, "w")
      @handle << "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
      @handle << "<!-- Exported with Google SketchUp CityGML-Plugin < version #{FHGelsenkirchenMaterials::CITYGML_VERSION} Build #{FHGelsenkirchenMaterials::CITYGML_BUILD} > - #{FHGelsenkirchenMaterials::CITYGML_CREATOR} -->\n"
#Header für CityGML 1.0
      @handle << "<core:CityModel xmlns:core=\"http://www.opengis.net/citygml/1.0\" xmlns:gen=\"http://www.opengis.net/citygml/generics/1.0\" xmlns:bldg=\"http://www.opengis.net/citygml/building/1.0\" xmlns:app=\"http://www.opengis.net/citygml/appearance/1.0\" xmlns:dem=\"http://www.opengis.net/citygml/relief/1.0\" xmlns:gml=\"http://www.opengis.net/gml\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.opengis.net/citygml/building/1.0 http://schemas.opengis.net/citygml/building/1.0/building.xsd http://www.opengis.net/citygml/appearance/1.0 http://schemas.opengis.net/citygml/appearance/1.0/appearance.xsd http://www.opengis.net/citygml/relief/1.0 http://schemas.opengis.net/citygml/relief/1.0/relief.xsd http://www.opengis.net/citygml/1.0 http://schemas.opengis.net/citygml/1.0/cityGMLBase.xsd http://www.opengis.net/citygml/generics/1.0 http://schemas.opengis.net/citygml/generics/1.0/generics.xsd\">\n"
      export_attributes(model.attribute_dictionaries())
#Sucht alle möglichen Entities, die Exportiert werden können.
#Face, Group, ComponentEntities werden unterstützt
      model.entities.each do |entity|
        next if( !entity.layer.visible?)
        if(entity.class == Sketchup::Group or entity.class == Sketchup::Face or entity.class == Sketchup::ComponentInstance)
          @entities << entity if(!entity.hidden? and entity.visible?)
          #UI.messagebox(model.entities.length)
          #abort
        end
      end

# count recursively all entities (to display progress in status bar)
      def count_entities(entities)
        total = 0

        entities.each do |entity|
          if(entity.class == Sketchup::ComponentInstance)
            total += count_entities(entity.definition.entities())
          elsif (entity.class == Sketchup::Group)
            total += count_entities(entity.entities())
          elsif (entity.class == Sketchup::Face)
            total += 1
          end
        end

        return total
      end

      $total_entities = count_entities(Sketchup.active_model.entities)
      $exported_entities = 0
      $pb = ProgressBar.new($total_entities,"Progress...")


      tw = Sketchup.create_texture_writer
#Sucht alle Texturen im Modell
      findtextures(@entities,tw)
      if(@backMaterialCount > 0)
        puts ">> #{@backMaterialCount} backmaterials detected!\n>> These will NOT be exported!"
      end

      if(tw.length() > 0)
        begin
          begin
            Dir.mkdir(File.dirname(savepath) + "//" + @texturepath)
          rescue =>e
          end
          #Speichert alle Texturen im Ordner
          tw.write_all(File.dirname(savepath)+ "//" + @texturepath, false)
          #Dateinamen säubern, da Umlaute nicht funktionieren im XML
          cleanfilenames(File.dirname(savepath))
        rescue => e
          puts e
          puts e.backtrace
        end
      end
      polygonpos = 0
#Iteration über alle entities, jetzt wird Geometrie exportiert
      @entities.each do |entity|
        polygonpos = 0

        if(entity.class ==Sketchup::Group or entity.class == Sketchup::ComponentInstance)
          buildingid = nil
          #Für jede Group und ComponentInstance entsteht ein neues Building
          actbuildingid = newrandombuildingid()
          begin
            t = nil
            #Attribute auslesen, stehen bei ComponentInstance an anderer Stelle
            #als bei einer Gruppe
            if(entity.class == Sketchup::ComponentInstance)
              t = entity.definition.attribute_dictionaries()
            else
              t = entity.attribute_dictionaries()
            end

            t.each do |t2|
              t2.each_pair { | key, value |
                if(key == "id" || key == "ID")
                  buildingid = FHGelsenkirchenMaterials::stringDecode(value.to_s())
                  #ID schon exportiert?
                  if(@exportedid[buildingid] != nil)
                    if(@collisiondetection)
                      if(!@buildingerror)
                        puts "There are buildings with the same gml:id"
                        @buildingerror = true
                      end
                      anz = @exportedid[buildingid]
                      @exportedid[buildingid] += 1
                      buildingid += ".#{anz}"
                    else
                      raise("BuildingException")
                    end
                    break;
                  end
                end
              }
            end
          rescue =>e
            if(e.message == "BuildingException" )
              raise("BuildingException")
            end
          end
          #Entities stehen bei Group und ComponentInstance an unterschiedlichen Stellen
          if(entity.class == Sketchup::ComponentInstance)
            explodedentities = entity.definition.entities()
          else
            explodedentities = entity.entities()
          end
          actbuildingid = buildingid if(buildingid != nil)
          transformation = entity.transformation


          explodedentities.each do |explode|
            if(explode.class == Sketchup::Face)
              polygonpos += 1
              #Face wird exportiert ## doplneny pozadovany typ
              nosurfacetype << writeface(explode, transformation,1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
              #Wird erneut eine Group/ComponentInstance gefunden, Methode writegroup aufgerufen
            elsif(explode.class ==Sketchup::Group)
              if(explode.name != "")
                puts "exporting #{explode.name}"
              end ## doplneny pozadovany typ
              polygonpos = writegroup(explode.entities(), transformation * explode.transformation, 1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
            elsif(explode.class == Sketchup::ComponentInstance)
              if(explode.name != "")
                puts "exporting #{explode.name}"
              end ## doplneny pozadovany typ
              polygonpos = writegroup(explode.definition.entities, transformation * explode.transformation, 1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
            end
          end
          #Alle Entities sind in Buffern gespeichert und können in XML-Datei
          #gespeichert werden ##doplneny pozadovany typ

          proceed = false
          readLayers.each do |key, value|
            if(value.size > 0)
              proceed = true
              break
            end
          end

          if(proceed or nosurfacetype != "")
            @handle << "<core:cityObjectMember>\n"
            if(buildingid != nil and buildingid != "" )
              if(@exportedid[buildingid] == nil)
                puts "Building \"#{buildingid}\" exported"
                @handle << "<mtrl:Building gml:id=\"" + buildingid.to_s() + "\">\n"
                actbuildingid = buildingid
                @exportedid[buildingid] = 1
              else
                @exportedid[buildingid] += 1
                tmppos = 1
                while (@exportedid[buildingid + "_#{tmppos}"] != nil )
                  tmppos += 1
                end
                actbuildingid = buildingid + "_#{tmppos}"
                puts "Building \"#{actbuildingid}\" exported"
                @handle << "<mtrl:Building gml:id=\"" + actbuildingid.to_s() + "\">\n"
                @exportedid[actbuildingid] = 1
              end
            else
              if(@generate)
                @handle << "<mtrl:Building gml:id=\"" + actbuildingid.to_s() + "\">\n"
                @exportedid[actbuildingid] = 1
                puts "Building \"#{actbuildingid}\" exported"
              else
                @handle << "<mtrl:Building>\n"
              end
            end

            #Export der gml und core Attribute
            curr_entity = nil
            if(entity.class == Sketchup::ComponentInstance)
              curr_entity = entity.definition
            else
              curr_entity = entity
            end
            exportGmlCoreAttributes(curr_entity.attribute_dictionaries)

            #Texturen/Materialien sollen im Building gespeichert werden
            if(!@groupappearance)
              if(!@parameterizedTextureHash.empty? or !@x3dmaterial.empty?)
                if(@groupmaterials)
                  @handle << "<app:appearance>\n"
                  @handle << "<app:Appearance>\n"
                  @parameterizedTextureHash.each_pair { |key, value|
                    @handle << "\n<app:surfaceDataMember>\n"
                    @handle << "<app:ParameterizedTexture>\n"
                    if(@texturepath != "")
                      @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
                    else
                      @handle << "<app:imageURI>#{key}</app:imageURI>\n"
                    end
                    @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
                    @handle << value
                    @handle << "</app:ParameterizedTexture>\n"
                    @handle << "</app:surfaceDataMember>\n"
                  }
                  @parameterizedTextureHash = Hash.new()

                  if(!@x3dmaterial.empty?)
                    @x3dmaterial.each_value do |value|
                      @handle << value
                      @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
                    end
                  end
                  @handle << "</app:Appearance>\n"
                  @handle << "</app:appearance>\n"
                  @x3dmaterial = Hash.new
                else
                  @parameterizedTextureHash.each_pair { |key, value|
                    @handle << "<app:appearance>\n"
                    @handle << "<app:Appearance>\n"
                    @handle << "\n<app:surfaceDataMember>\n"
                    @handle << "<app:ParameterizedTexture>\n"
                    if(@texturepath != "")
                      @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
                    else
                      @handle << "<app:imageURI>#{key}</app:imageURI>\n"
                    end
                    @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
                    @handle << value
                    @handle << "</app:ParameterizedTexture>\n"
                    @handle << "</app:surfaceDataMember>\n"
                    @handle << "</app:Appearance>\n"
                    @handle << "</app:appearance>\n"
                  }
                  @parameterizedTextureHash = Hash.new()
                  if(!@x3dmaterial.empty?)
                    @x3dmaterial.each_value do |value|
                      @handle << "<app:appearance>\n"
                      @handle << "<app:Appearance>\n"
                      @handle << value
                      @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
                      @handle << "</app:Appearance>\n"
                      @handle << "</app:appearance>\n"
                    end
                  end
                  @x3dmaterial = Hash.new
                end
              end
            end
            exportGenAttributes(curr_entity.attribute_dictionaries) ## doplneny pozadovany typ
            writebuffers(@lod, nosurfacetype, actbuildingid, readLayers)
            nosurfacetype = ""
            @handle << "</mtrl:Building>\n"
            @handle << "</core:cityObjectMember>\n"
          end
          #Jedes Face, welches keiner Gruppe angehört, wird in stdbuilding
          #gespeichert und werden zum Schluß in einem Building gruppiert
        elsif(entity.class == Sketchup::Face)
          if(stdbuilding == "")
            if(@generate)
              stdbuildingid = newrandombuildingid()
              stdbuilding << "<core:cityObjectMember>\n"
              stdbuilding << "<mtrl:Building gml:id=\""+ stdbuildingid.to_s()+ "\">\n"
              @exportedid[stdbuildingid.to_s()] = 1
              puts "Building \"#{stdbuildingid}\" exported"
            else
              stdbuilding << "<core:cityObjectMember>\n"
              stdbuilding << "<mtrl:Building>\n"
            end
          end
          stdpolygonpos += 1 ## doplneny pozadovany typ
          stdnosurfacetype << writeface(entity,Geom::Transformation.new, 1, tw, stdbuildingid, stdpolygonpos, stdnosurfacetype, stdLayers)
        end

      end
      if(stdbuilding != "")
        @handle << stdbuilding
        #Texturen sollen im Building gespeichert werden?
        if(!@groupappearance)
          if(!@parameterizedTextureHash.empty? or !@x3dmaterial.empty?)
            if(@groupmaterials)
              @handle << "<app:appearance>\n"
              @handle << "<app:Appearance>\n"
              @parameterizedTextureHash.each_pair { |key, value|
                @handle << "\n<app:surfaceDataMember>\n"
                @handle << "<app:ParameterizedTexture>\n"
                if(@texturepath != "")
                  @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
                else
                  @handle << "<app:imageURI>#{key}</app:imageURI>\n"
                end
                @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
                @handle << value
                @handle << "</app:ParameterizedTexture>\n"
                @handle << "</app:surfaceDataMember>\n"
              }
              @parameterizedTextureHash = Hash.new()

              if(!@x3dmaterial.empty?)
                @x3dmaterial.each_value do |value|
                  @handle << value
                  @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
                end
              end
              @handle << "</app:Appearance>\n"
              @handle << "</app:appearance>\n"
              @x3dmaterial = Hash.new
            else
              @parameterizedTextureHash.each_pair { |key, value|
                @handle << "<app:appearance>\n"
                @handle << "<app:Appearance>\n"
                @handle << "\n<app:surfaceDataMember>\n"
                @handle << "<app:ParameterizedTexture>\n"
                if(@texturepath != "")
                  @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
                else
                  @handle << "<app:imageURI>#{key}</app:imageURI>\n"
                end
                @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
                @handle << value
                @handle << "</app:ParameterizedTexture>\n"
                @handle << "</app:surfaceDataMember>\n"
                @handle << "</app:Appearance>\n"
                @handle << "</app:appearance>\n"
              }
              @parameterizedTextureHash = Hash.new()
              if(!@x3dmaterial.empty?)
                @x3dmaterial.each_value do |value|
                  @handle << "<app:appearance>\n"
                  @handle << "<app:Appearance>\n"
                  @handle << value
                  @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
                  @handle << "</app:Appearance>\n"
                  @handle << "</app:appearance>\n"
                end
              end
              @x3dmaterial = Hash.new
            end
          end
        end
        ## doplneny pozadovany typ
        writebuffers(@lod, stdnosurfacetype, stdbuildingid, stdLayers)
        @handle << "</mtrl:Building>\n"
        @handle << "</core:cityObjectMember>\n"
      end
#Wenn @parameterizedTextureHash bzw @x3dmaterial nicht leer sind
#werden diese global am Ende der Datei exportiert
      if(!@parameterizedTextureHash.empty? or !@x3dmaterial.empty?)
        if(@groupmaterials)
          @handle << "<app:appearanceMember>\n"
          @handle << "<app:Appearance>\n"
          @parameterizedTextureHash.each_pair { |key, value|
            @handle << "\n<app:surfaceDataMember>\n"
            @handle << "<app:ParameterizedTexture>\n"
            if(@texturepath != "")
              @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
            else
              @handle << "<app:imageURI>#{key}</app:imageURI>\n"
            end
            @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
            @handle << value
            @handle << "</app:ParameterizedTexture>\n"
            @handle << "</app:surfaceDataMember>\n"

          }
          if(!@x3dmaterial.empty?)
            @x3dmaterial.each_value do |value|
              @handle << value
              @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
            end
          end
          @handle << "</app:Appearance>\n"
          @handle << "</app:appearanceMember>\n"
        else
          @parameterizedTextureHash.each_pair { |key, value|
            @handle << "<app:appearanceMember>\n"
            @handle << "<app:Appearance>\n"
            @handle << "\n<app:surfaceDataMember>\n"
            @handle << "<app:ParameterizedTexture>\n"
            if(@texturepath != "")
              @handle << "<app:imageURI>/#{@texturepath}/#{key}</app:imageURI>\n"
            else
              @handle << "<app:imageURI>#{key}</app:imageURI>\n"
            end
            @handle << "<app:wrapMode>wrap</app:wrapMode>\n"
            @handle << value
            @handle << "</app:ParameterizedTexture>\n"
            @handle << "</app:surfaceDataMember>\n"
            @handle << "</app:Appearance>\n"
            @handle << "</app:appearanceMember>\n"
          }
          @parameterizedTextureHash = Hash.new()
          if(!@x3dmaterial.empty?)
            @x3dmaterial.each_value do |value|
              @handle << "<app:appearanceMember>\n"
              @handle << "<app:Appearance>\n"
              @handle << value
              @handle << "</app:X3DMaterial>\n</app:surfaceDataMember>\n"
              @handle << "</app:Appearance>\n"
              @handle << "</app:appearanceMember>\n"
            end
          end
        end

      end
      @handle << "</core:CityModel>"
#Export fertig
      @handle.close()
      puts "#{savepath} successfully written."
      begin
        dlg_str = UI::WebDialog.new("C", false, nil, 0, 0, 0, 0, false)
        dlg_str.set_position(400, 400)
        dlg_str.set_on_close{
          UI.messagebox("Export completed!", MB_OK)
        }
        puts "#{File.size(savepath)} bytes written."
        puts "Export completed!"
        puts "Console can be closed"
        dlg_str.show()
        dlg_str.close()
      rescue => e
      end
    rescue => e
      #@debug.close()
      if(e.message == "LinearRingException")
        UI.messagebox("DEBUG")
        UI.messagebox("There are surfaces with same LinearRing-ID.\nTry the fix option or correct the ids\nExport canceled", MB_OK )
      elsif(e.message == "PolygonException")
        UI.messagebox("DEBUG")
        UI.messagebox("There are surfaces with same Polygon-ID.\nTry the fix option or correct the ids\nExport canceled", MB_OK )
      elsif(e.message == "BuildingException")
        UI.messagebox("DEBUG")
        UI.messagebox("There are buildings with same Building-ID.\nTry the fix option or correct the ids\nExport canceled", MB_OK )
      else
        puts e
        puts e.backtrace
      end
    end

    #Schreibt alle Buffer in die Textdatei
    #Parameter 1: Lod, gibt an, welches LOD die Multisurfaces haben
    #Parameter 2: groundsurfaces beinhaltet alle GroundSurfaces
    #Parameter 3: wallsurfaces beeinhaltet alle WallSurfaces
    #Parameter 4: roofsurfaces beinhaltet alle RoofSurfaces
    #Parameter 5: nosurfacetype beinhaltet alle Surfaces, die keinen Typ haben
    #Parameter 6: actbuildingid, gibt die ID des aktuellen Buildings an ## doplneny pozadovany typ
    def writebuffers(lod, nosurfacetype, actbuildingid, readLayers)## doplneny pozadovany typ
      n = false
      readLayers.each do |key,value|
        if(value.size > 0)
          n = true
        end
      end

      return if(!n and nosurfacetype == "")
      if(nosurfacetype != "")
        @handle << "<#{lod}>\n"
        #if(@gmlType == 1)
        #@handle << "<gml:CompositeSolid>\n"
        #else
        @handle << "<gml:MultiSurface"
        coordinateSystemString()
        @handle << ">\n"
        #end

        @handle << nosurfacetype

        #if(@gmlType == 1)
        #@handle << "</gml:CompositeSolid>\n"
        #else
        @handle << "</gml:MultiSurface>\n"
        #end

        @handle << "</#{lod}>\n"
      end
      #Gibt es Surfaces mit Typ, werden diese im boundedBy-Tag gespeichert ## doplneny pozadovany typ
      readLayers.each do |key, value|
        if(value.size > 0)
          require 'su_materials/Export/layers/' << key
          t = eval(key).new(value, lod, @noid, @generate, @coordinate_system, @groupsurfaces, actbuildingid)
          @handle << t.run
          #value.clear
        end
      end

    end

    #Generiert eine neue BuildingId
    def newrandombuildingid()
      while(true)
        #id = @filename_pur.match(/^_/) ? "" : "_"

        if(@filename_pur.match(/^_/))
          id = ""
        else
          id = "_"
        end
        id += "#{@filename_pur}_BD.#{@buildinggennr}"
        if(@exportedid[id] == nil)
          break;
        end
        @buildinggennr += 1
      end
      return id
    end

    def newpoligonid(buildingid)
      index_id = 1
      while(true)
        id = buildingid.to_s() + "_PG." + index_id.to_s()
        if(@exportedid[id] == nil)
          break;
        end
        index_id += 1
      end
      return id
    end

    def newlinearringid(polygonid)
      index_id = 1
      while(true)
        id = polygonid.to_s() + "_LR." + index_id.to_s()
        if(@exportedid[id] == nil)
          break;
        end
        index_id += 1
      end
      return id
    end

    def coordinateSystemString()
      if(@coordinate_system != "")
        @handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
      end
    end

    #Analysiert eine Groupe/ComponentInstance und findet alle Entities, die exportiert werden können
    #Parameter 1: entities beinhaltet alle Entities einer Gruppe/ComponentInstance
    #Parameter 2: transformation wird für die Transformation der Koordinaten benötigt
    #Parameter 3: za ist Debug und gibt die maximale Tiefe von Verschachtelungen an
    #Parameter 4: tw ist Texturwriter, wird nur durchgereicht und später vernwedet
    #Parameter 5: actbuildingid ist ID von Building
    #Parameter 6: polygonpos zählt Anzahl Polygone hoch
    #Parameter 7: groundsurfaces ist Buffer für GroundSurfaces
    #Parameter 8: roofsurfaces ist Buffer für Roofsurface
    #Parameter 9: wallsurfaces ist Buffer für WallSurfaces ## doplneny pozadovany typ a precislovano
    #Parameter 10: floorsurfaces ist Buffer für FloorSurfaces
    #Parameter 11: nosurfacetype ist Buffer für alle Flächen ohne Surfacetyp
    def writegroup(entities, transformation, za, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
      if(za > @maxtiefe)
        @maxtiefe += 1
      end
      entities.each do |entity|
        if(entity.class == Sketchup::Face)
          polygonpos += 1 ## doplneny pozadovany typ
          nosurfacetype << writeface(entity, transformation, za + 1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)

          #Bei Gruppen und ComponentInstance rekursiver aufruf
        elsif(entity.class ==Sketchup::Group)
          if(entity.name != "")
            puts "Exportiere #{entity.name}"
          end
          #Neue Transformation berechnen ## doplneny pozadovany typ
          polygonpos = writegroup(entity.entities, transformation *  entity.transformation, za + 1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
        elsif(entity.class == Sketchup::ComponentInstance)
          if(entity.name != "")
            puts "Exportiere #{entity.name}"
          end
          #Neue Transformation berechnen
          #Geometrie bei ComponentInstance steckt in der Definition! ## doplneny pozadovany typ
          polygonpos = writegroup(entity.definition.entities, transformation * entity.transformation , za + 1, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)
        end
      end
      return polygonpos
    end

    #Sucht alle Texturen im Model
    #Texturen werden nur in Writer geladen, noch nicht exportiert
    #Parameter 1: Entities Objekt
    #Parameter 2: Texturwriter
    def findtextures(ent, tw)
      ent.each do |e|
        if(e.class ==Sketchup::Group)
          findMaterialModellingError(e)
          findtextures(e.entities, tw)
        elsif(e.class == Sketchup::ComponentInstance)
          findtextures(e.definition.entities, tw)
        elsif(e.class == Sketchup::Face)
          #Überprüfen, ob Textur auf der Vorderseite des Faces ist
          if(e.material != nil and e.material.texture != nil)
            tw.load(e, true) if(!e.hidden? and e.visible?)
          end
          @backMaterialCount += 1 if(e.back_material != nil)
          #Überprüfen, ob sich eine Textur auf der Rückseite befindet
          #if(e.back_material != nil and e.back_material.texture != nil)
          #  tw.load(e, false) if(!e.hidden? and e.visible?)
          #end
        end
      end
    end

    #Gibt einen Fehler aus, wenn im Model eine group / compenentInstance Material hat
    def findMaterialModellingError(entity)
      if(entity == nil)
        return
      end
      if(entity.material != nil)
        if(entity.class == Sketchup::Group)
          dicts = entity.attribute_dictionaries()

          if(dicts != nil)
            dicts.each do |dict|
              dict.each_pair { | key, value |
                if(key == "id" || key == "ID")
                  buildingid = FHGelsenkirchenMaterials::stringDecode(value.to_s())
                  puts "Group material ignored in the following building with id: " + buildingid.to_s
                  return
                end
              }
            end
          end
          # Wenn keine id Flächen zahl ausgeben
          surfaceCount = 0
          entity.entities.each do |ent|
            if(ent.class == Sketchup::Face)
              surfaceCount += 1
            end
          end
          puts "Group material ignored in the following building with " + surfaceCount.to_s + " surfaces"
        end
      end
    end

    #Löscht Zeichen aus String, die kaputt gehen beim Exportieren, da kein UTF-8
    def replacecharacter(input)
      return nil if(input == nil)
      input = input.gsub(/[ß]/, "ss")
      input = input.gsub(/[ä]/, "ae")
      input = input.gsub(/[ü]/, "ue")
      input = input.gsub(/[ö]/, "oe")
      input = input.gsub(/[Ä]/, "Ae")
      input = input.gsub(/[Ö]/, "Oe")
      input = input.gsub(/[Ü]/, "Ue")
      input = input.gsub(/[&]/, "__")
      return input
    end

    #Exportiert ein Face
    #Parameter 1: Das Face
    #Parameter 2: Transformations-Objekt
    #Parameter 3: za, nur für Debug da
    #Parameter 4: tw Texturwriter
    #Parameter 5: actbuildingid ID vom Building
    #Parameter 6: polygonpos gibt Anzahl der Polygone an
    #Parameter 7: groundsurfaces ist Buffer für GroundSurfaces
    #Parameter 8: roofsurfaces ist Buffer für Roofsurface
    #Parameter 9: wallsurfaces ist Buffer für WallSurfaces ## doplneny pozadovany typ a precislovano
    #Parameter 10: floorsurfaces ist Buffer für FloorSurfaces
    #Parameter 11: nosurfacetype ist Buffer für alle Flächen ohne Surfacetyp
    def writeface(face, transformation, za, tw, actbuildingid, polygonpos, nosurfacetype, readLayers)

      #result = Sketchup.set_status_text "#{$exported_entities.to_s()}/#{$total_entities.to_s()} entities exported!", SB_PROMPT
      $pb.update_progress_bar($exported_entities)
      $exported_entities += 1

      #puts $exported_entities.to_s()

      #if $exported_entities % 1000 == 0
      #UI.messagebox($exported_entities.to_s())

      #end

      #Wenn Nicht sichtbarer Layer, export überspringen
      return "" if(!face.layer.visible?)
      tmpfile = ""
      has_material = false
      layer = face.layer.name
      #modus = 0
      # if(@gmlType == 0 and @lodNum > 1) # MultiSurface + Lod größer als 1 ## doplneny pozadovany typ
      #   if(layer == "GroundSurface")
      #     modus = 1
      #   elsif(layer == "WallSurface")
      #     modus = 3
      #   elsif(layer == "RoofSurface")
      #     modus = 2
      # elsif(layer == "FloorSurface")
      #     modus = 5 ##
      #   elsif(layer == "OuterFloorSurface")
      #     modus = 7 ##
      #   elsif(layer == "IntBuildingInstallation")
      #     modus = 8 ##
      #   elsif(layer == "BuildingInstallation")
      #     modus = 6 ##
      #   elsif(layer == "Door")
      #     modus = 4 ##
      #   elsif(layer == "Window")
      #     modus = 9 ##
      #   elsif(layer == "CeilingSurface")
      #     modus = 10 ##
      #   elsif(layer == "InteriorWallSurface")
      #     modus = 11 ##
      #   end
      # end
      if(za > @maxtiefe)
        @maxtiefe += 1
      end
      @valid += 1 if(!face.valid?)
      return "" if(!face.valid?)

      material = face.material
      has_material = (material != nil) ? true : false
      hastexture = (has_material and material.texture != nil) ? true : false

      begin
        #GML:ID suchen
        polygonID = FHGelsenkirchenMaterials::stringDecode(face.get_attribute("Standard attribute", "PolygonID"))
        #gmlid = nil if(gmlid == "")
        #Überprüfen, ob GML:ID bereits vergeben ist
        if(@exportedid[polygonID] != nil and polygonID != nil)
          if(!@polygonerror)
            raise("PolygonException") if(!@collisiondetection)
            puts "There are surfaces with the same PolygonID"
            @polygonerror = true
          end
          anz = @exportedid[polygonID]
          @exportedid[polygonID] += 1
          polygonID << "." << anz.to_s()
        end
      rescue =>e
        puts e
      end
      begin
        #RingID suchen
        linearRingID = FHGelsenkirchenMaterials::stringDecode(face.get_attribute("Standard attribute", "LinearRingID"))
          # linearRingID = tmp if(tmp != "")
          #linearRingID = nil if(linearRingID == "")
      rescue => e
        puts e
      end
      begin
        #FromDate suchen
        fromDate = FHGelsenkirchenMaterials::stringDecode(face.get_attribute("Standard attribute", "FromDate"))
      rescue => e
        puts e
      end
      begin
        #ToDate suchen
        toDate = FHGelsenkirchenMaterials::stringDecode(face.get_attribute("Standard attribute", "ToDate"))
      rescue => e
        puts e
      end
      # begin
      # polygonID = face.get_attribute("Standard attribute", "PolygonID")
      # polygonID = tmp if(tmp != nil)
      #rescue => e
      #puts e
      #end

      #if(@gmlType == 1)
      #tmpfile << "<gml:solidMember>\n"
      #tmpfile << "<gml:Solid>\n"
      #tmpfile << "<gml:exterior>\n"
      #else
      tmpfile << "<gml:surfaceMember>\n"
      #end
      if fromDate != nil
          tmpfile << "<mtrl:FromDate mtrl:fromDate=\"" + fromDate.to_s() + "\"/>\n"
      end

      if toDate != nil
          tmpfile << "<mtrl:ToDate mtrl:toDate=\"" + toDate.to_s() + "\"/>\n"
      end

      #gml:id vorhanden? sonst generieren, wenn vorher erlaubt wurde
      if(polygonID != nil)
        if(!@noid or has_material)
          tmpfile << "<gml:Polygon gml:id=\"" + polygonID.to_s() + "\">\n"
          @exportedid[polygonID] = 1
        else
          tmpfile << "<gml:Polygon>\n"
        end
      else
        #Wenn Material vorhanden, muss Face eine ID haben, da über diese referenziert wird
        if((@generate and !@noid) or has_material)
          polygonID = newpoligonid(actbuildingid)
          tmpfile << "<gml:Polygon gml:id=\"" + polygonID.to_s() +"\">\n"
          @exportedid[polygonID] = 1
        else
          tmpfile << "<gml:Polygon>\n"
        end
      end

      if(@exportedid[linearRingID] != nil and linearRingID != nil)
        if(!@ringerror)
          raise("LinearRingException") if(!@collisiondetection)
          puts "There are surfaces with the same LinearRingID"
          @ringerror = true
        end
        anz = @exportedid[linearRingID]
        @exportedid[linearRingID] += 1
        linearRingID += ".#{anz}"
      end

      loops = face.loops
      ringpos = 1

      texFile = ""
      #Material mit Texture
      if(hastexture)
        #Material mit Textur
        #Im Texturwriter laden, damit Texturkoordinaten bestimmt werden können
        handle = tw.load(face, true)
        if(handle <= 0)
          puts "Loading texture from surface unsuccessful!"
          return ""
        end

        texFile = tw.filename(handle).to_s
        #uvHelper bietet Funktionen zum berechnen der Texturkoordinaten
        #uvHelper = face.get_UVHelper(true, true, tw)
        tmptexture = ""
        begin
          tmptexture = String.new(@parameterizedTextureHash.fetch(replacecharacter(texFile)))
        rescue => e
        end
        tmptexture << "<app:target uri=\"##{polygonID.to_s}\">\n"
      elsif(has_material)
        begin
          saved_material = @x3dmaterial.fetch(material.name)
          #if(polygonID != nil)
          saved_material << "\t<app:target>##{polygonID.to_s}</app:target>\n"
          #else
          # saved_material << "<app:target>##{actbuildingid}_Polygon_#{polygonpos}</app:target>\n"
          #end
          @x3dmaterial[material.name] = saved_material
        rescue => e
          if(e.message == "key not found")
          else
            puts e
            puts e.backtrace
          end
          color = material.color

          materialbuf = "\n<app:surfaceDataMember>\n"
          materialbuf << "<app:X3DMaterial>\n"
          materialbuf << "\t<app:ambientIntensity>0.2</app:ambientIntensity>\n"
          materialbuf << "\t<app:diffuseColor>#{color.red.to_f / 255} #{color.green.to_f / 255} #{color.blue.to_f / 255}</app:diffuseColor>\n"
          materialbuf << "\t<app:emissiveColor>0.0 0.0 0.0</app:emissiveColor>\n"
          materialbuf << "\t<app:specularColor>1.0 1.0 1.0</app:specularColor>\n"
          materialbuf << "\t<app:shininess>0.2</app:shininess>\n"
          materialbuf << "\t<app:transparency>#{1.0 - material.alpha.to_f()}</app:transparency>\n"
          materialbuf << "\t<app:isSmooth>false</app:isSmooth>\n"
          #if(polygonID != nil)
          materialbuf << "\t<app:target>##{polygonID.to_s}</app:target>\n"
          #else
          #   materialbuf << "<app:target>##{actbuildingid}_Polygon_#{polygonpos}</app:target>\n"
          # end
          @x3dmaterial[material.name] = materialbuf
        end
      end
      #Iteration über alle Loops
      loops.each do |loop|
        cords = ""
        exteriorpts = []
        uvqs = []
        #Interior oder Exterior
        if(loop.outer?)
          tmpfile << "<gml:exterior>\n"
        else
          tmpfile << "<gml:interior>\n"
        end
        if(linearRingID != nil)
          if(!@noid or has_material)
            if(@exportedid[linearRingID] != nil)
              linearRingID = newlinearringid(polygonID)
            end
            tmpfile << "<gml:LinearRing gml:id=\"" + linearRingID.to_s() + "\">\n"
            @exportedid[linearRingID] = 1
            if(hastexture)
              tmptexture << "<app:TexCoordList>\n" if(loop.outer?)
              tmptexture << "<app:textureCoordinates ring=\"#" + linearRingID.to_s() + "\">\n"
            end
          else
            tmpfile << "<gml:LinearRing>\n"
          end
        else
          if(@generate or hastexture)
            if(polygonID == nil)
              polygonID = newpoligonid(actbuildingid)
            end
            linearRingID = newlinearringid(polygonID)
            tmpfile << "<gml:LinearRing gml:id=\"" + linearRingID + "\">\n"
            @exportedid[linearRingID] = 1
          else
            tmpfile << "<gml:LinearRing>\n"
            linearRingID = nil
          end
          if(hastexture and linearRingID != nil)
            tmptexture << "<app:TexCoordList>\n" if(loop.outer?)
            tmptexture << "<app:textureCoordinates ring=\"#"+ linearRingID +"\">\n"
            begin
              @ringidhash.fetch(material.name) << linearRingID
            rescue => e
              @ringidhash[material.name] = []
              @ringidhash[material.name] << linearRingID
            end
          end
        end
        uvHelper = face.get_UVHelper(true, false, tw)
        vertices = loop.vertices()
        vertices.each do |vertex|
          pos = vertex.position()
          exteriorpts << [pos.x.to_f(), pos.y.to_f(), pos.z.to_f()]
          if(hastexture)
            uvqs << uvHelper.get_front_UVQ( pos)
          end
        end

        cleaned_points = []
        cleaned_uvqs = []
        cleaned_points = exteriorpts
        cleaned_uvqs = uvqs
        begin
          cleaned_points << cleaned_points[0].clone
          cleaned_uvqs << cleaned_uvqs[0].clone if(hastexture)
        rescue => e
        end
        if (cleaned_points.size < 4)
          return ""
        end
        cleaned_points.reverse! if(@switch)
        cleaned_uvqs.reverse! if(@switch)
        cords << "<gml:posList srsDimension=\"3\">"
        cleaned_points.each do |pt|
          begin
            p2 = transformation * pt
            #die neue Formel, wenn Yaw gesetzt ist muss Modell rotiert werden
            if(@yaw)
              x = (Math.cos(@yaw)*p2[0].to_f() - Math.sin(@yaw)*p2[1].to_f() +  @offsetx * @offsetfaktor) * @faktor
              y = (Math.sin(@yaw)*p2[0].to_f() + Math.cos(@yaw)*p2[1].to_f() +  @offsety * @offsetfaktor) * @faktor
              z = (p2[2].to_f() + @offsetz * @offsetfaktor) * @faktor
            else
              #die alte Formel
              x = ((p2[0].to_f()).to_f() + @offsetx * @offsetfaktor) * @faktor
              y = ((p2[1].to_f()).to_f() + @offsety * @offsetfaktor) * @faktor
              z = ((p2[2].to_f()).to_f() + @offsetz * @offsetfaktor) * @faktor
            end
            if(@switch)
              cords << "\n" + y.to_s() + " " + x.to_s() + " " + z.to_s()
            else
              cords << "\n" + x.to_s() + " " + y.to_s() + " " + z.to_s()
            end
          rescue =>e
            puts e
          end
        end
        cords << "\n</gml:posList>\n"

        tmpfile << cords.to_s
        if(hastexture)
          cleaned_uvqs.each do |uvq|
            tmptexture << uvq.x.to_f().to_s() + " " + uvq.y.to_f().to_s() + " "
          end
          tmptexture << "</app:textureCoordinates>\n"
        end
        tmpfile << "</gml:LinearRing>\n"
        if(loop.outer?)
          tmpfile << "</gml:exterior>\n"
        else
          tmpfile << "</gml:interior>\n"
        end
        ringpos += 1
      end
      if(hastexture)
        tmptexture << "</app:TexCoordList>"
        tmptexture << "</app:target>\n"
        @parameterizedTextureHash[replacecharacter(texFile)] = tmptexture
      end
      tmpfile << "</gml:Polygon>\n"

      #if(@gmlType == 1)
      #tmpfile << "</gml:exterior>\n"
      #tmpfile << "</gml:Solid>\n"
      #tmpfile << "</gml:solidMember>\n"
      #else
      tmpfile << "</gml:surfaceMember>\n"
      #end

      surfaceid = FHGelsenkirchenMaterials::stringDecode(face.get_attribute("Standard attribute", "BoundarySurfaceType ID"))
      if(@gmlType == 0 and @lodNum > 1) # MultiSurface + Lod größer als 1 ## doplneny pozadovany typ
        readLayers.each do |key , value|
          if(key == layer)
            if(value[surfaceid] == nil)
              value[surfaceid] = []
            end
            value[surfaceid] << tmpfile
          end
        end

      end

      return tmpfile
    end
  end
end
