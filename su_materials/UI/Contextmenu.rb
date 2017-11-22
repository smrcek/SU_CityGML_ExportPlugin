require 'su_materials/Attribute/attribute'
require 'su_materials/Attribute/AttributeDialog'
require 'su_materials/Attribute/AttributeRescue'

module FHGelsenkirchenMaterials
  begin
    UI::add_context_menu_handler do |menu|
      menu.add_separator

      layers = Array.new
      Dir.foreach(File.dirname(__FILE__) + "/../Export/layers/") do |item|
        items = item.split('.')
            if(!items[0].nil?)
              layers << items[0]
            end
      end

      $layersSurfacesTunnels = Hash.new
      layers.each do |item|
        $layersSurfacesTunnels[item] = false;
      end

      ##
      if(Sketchup.active_model.selection.count >= 1)
        if(Sketchup.active_model.selection.count == 1)
          subMenu = menu.add_submenu("CityGML_Time_From_To");
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
        if(FHGelsenkirchenMaterials::hasface?(Sketchup.active_model.selection))
          subMenu = menu.add_submenu("CityGML_Material Type");

          layersItems = Hash.new
          layers.each do |item|
              layersItems[item] = subMenu.add_item(item) {
                FHGelsenkirchenMaterials::setsurfacetype(Sketchup.active_model.selection, item)
              }
          end
          layersItems["None"] = subMenu.add_item("None") {
            FHGelsenkirchenMaterials::setsurfacetype(Sketchup.active_model.selection, nil)
          }

          #surfaceid = subMenu.add_item("BoundarySurfaceType ID") {
          #  idhash = FHGelsenkirchenMaterials::setsurfaceid(Sketchup.active_model.selection, Hash.new())
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
          #    FHGelsenkirchenMaterials::setid(Sketchup.active_model.selection, input[0]) if(input)
          #  else
          #    UI.messagebox("The selected faces are not on the same layer")
          #  end
          #}
         
          layers.each {|layer|
            subMenu.set_validation_proc(layersItems[layer]) { 
              if $layersSurfacesTunnels[layer] == true
                MF_CHECKED
              else $layersSurfacesTunnels[layer] == false
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
        FHGelsenkirchenMaterials::findtype(entities, typehash)

        if(typehash.size == 1) 
          
          layers.each{ |layer|
            if(typehash[layer] != nil)
              layers.each{ |surface|
                $layersSurfacesTunnels[surface] = false;
              }
              $layersSurfacesTunnels[layer] = true
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