require 'su_citygmlbridges/Edit/reverseMaterial'
require 'su_citygmlbridges/Edit/removeBackmaterial'
require 'su_citygmlbridges/Attribute/attribute'
require 'su_citygmlbridges/Attribute/AttributeDialog'
require 'su_citygmlbridges/Attribute/AttributeRescue'

module FHGelsenkirchenBridges
  begin
    UI::add_context_menu_handler do |menu|
      menu.add_separator

      if(Sketchup.active_model.selection.count >= 1)
        if(FHGelsenkirchenBridges::hasface?(Sketchup.active_model.selection))
          correctionMenu = menu.add_submenu("Correction functions")

          correctionMenu.add_item("Reverse Faces"){
            ReverseMaterial.new(Sketchup.active_model.selection)
          }
          correctionMenu.add_item("Remove Backmaterial"){
            RemoveBackmaterial.new(Sketchup.active_model.selection)
          }
        end
      end

      layers = Array.new
      Dir.foreach(File.dirname(__FILE__) + "/../Export/layers/") do |item|
        items = item.split('.')
            if(!items[0].nil?)
              layers << items[0]
            end
      end

      $layersSurfacesBridges = Hash.new
      layers.each do |item|
        $layersSurfacesBridges[item] = false;
      end

      ##
      if(Sketchup.active_model.selection.count >= 1)
        if(Sketchup.active_model.selection.count == 1)
          subMenu = menu.add_submenu("CityGML_Bridges Attribute");
          subMenu.add_item("Edit") {
            AttributeEdit.new
          }
          subMenu.add_item("Copy") {
            AttributeRescue.new.copy_attribute(Sketchup.active_model.selection.first)
          }
          subMenu.add_item("Insert") {
            AttributeRescue.new.paste_attribute(Sketchup.active_model.selection.first)
          }
        end ## doplnit vybrane typy
        if(FHGelsenkirchenBridges::hasface?(Sketchup.active_model.selection))
          subMenu = menu.add_submenu("CityGML_Bridges Surfacetype");

          layersItems = Hash.new
          layers.each do |item|
              layersItems[item] = subMenu.add_item(item) {
                FHGelsenkirchenBridges::setsurfacetype(Sketchup.active_model.selection, item)
              }
          end
          layersItems["None"] = subMenu.add_item("None") {
            FHGelsenkirchenBridges::setsurfacetype(Sketchup.active_model.selection, nil)
          }

          #surfaceid = subMenu.add_item("BoundarySurfaceType ID") {
          #  idhash = FHGelsenkirchenBridges::setsurfaceid(Sketchup.active_model.selection, Hash.new())
          #  defaults = []
          #  prompts = ["SurfaceType ID"]
          #  if(idhash.size == 1)
          #    idhash.each_pair {|key, value|
          #      if(value.size == 1)
          #        value.each_pair {|key2, value2|
          #          defaults = [key2]
          #        }
          #      end
          #    }

          #    input = UI.inputbox prompts, defaults, "BoundarySurfaceType ID"
          #    FHGelsenkirchenBridges::setid(Sketchup.active_model.selection, input[0]) if(input)
          #  else
          #    UI.messagebox("The selected faces are not on the same layer")
          #  end
          #}
         
          layers.each {|layer|
            subMenu.set_validation_proc(layersItems[layer]) { 
              if $layersSurfacesBridges[layer] == true
                MF_CHECKED
              else $layersSurfacesBridges[layer] == false
                MF_UNCHECKED
              end
            }
          }

          
          ##
          #subMenu.set_validation_proc(itemrelief) {
          #  if $relieffeature == true
          #   MF_CHECKED
          # else $relieffeature == false
          #   MF_UNCHECKED
          # end
          # }
        end
        entities = Sketchup.active_model.selection
        typehash = Hash.new()
        FHGelsenkirchenBridges::findtype(entities, typehash)

        if(typehash.size == 1) 
          
          layers.each{ |layer|
            if(typehash[layer] != nil)
              layers.each{ |surface|
                $layersSurfacesBridges[surface] = false;
              }
              $layersSurfacesBridges[layer] = true
              break
            end
          }

        end

      end
    end
  rescue => e
    puts e
    puts e.backtrace
  end
end