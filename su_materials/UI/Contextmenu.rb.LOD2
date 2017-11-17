require 'CityGML/Edit/reverseMaterial'
require 'CityGML/Edit/removeBackmaterial'
require 'CityGML/Attribute/attribute'
require 'CityGML/Attribute/AttributeDialog'
require 'CityGML/Attribute/AttributeRescue'

module FHGelsenkirchen
  begin
    UI::add_context_menu_handler do |menu|
      menu.add_separator

      if(Sketchup.active_model.selection.count >= 1)
        if(FHGelsenkirchen::hasface?(Sketchup.active_model.selection))
          correctionMenu = menu.add_submenu("Correction functions")

          correctionMenu.add_item("Reverse Faces"){
            ReverseMaterial.new(Sketchup.active_model.selection)
          }
          correctionMenu.add_item("Remove Backmaterial"){
            RemoveBackmaterial.new(Sketchup.active_model.selection)
          }
        end
      end

      $wallsurface = false
      $roofsurface = false
      $groundsurface = false
      $relieffeature = false
      if(Sketchup.active_model.selection.count >= 1)
        if(Sketchup.active_model.selection.count == 1)
          subMenu = menu.add_submenu("CityGML Attribute");
          subMenu.add_item("Edit") {
            AttributeEdit.new
          }
          subMenu.add_item("Copy") {
            AttributeRescue.new.copy_attribute(Sketchup.active_model.selection.first)
          }
          subMenu.add_item("Insert") {
            AttributeRescue.new.paste_attribute(Sketchup.active_model.selection.first)
          }
        end
        if(FHGelsenkirchen::hasface?(Sketchup.active_model.selection))
          subMenu = menu.add_submenu("CityGML Surfacetype");

          itemground = subMenu.add_item("GroundSurface") {
            FHGelsenkirchen::setsurfacetype(Sketchup.active_model.selection, "GroundSurface")
          }
          itemroof = subMenu.add_item("RoofSurface") {
            FHGelsenkirchen::setsurfacetype(Sketchup.active_model.selection, "RoofSurface")
          }
          itemwall = subMenu.add_item("WallSurface") {
            FHGelsenkirchen::setsurfacetype(Sketchup.active_model.selection, "WallSurface")
          }
          itemnone = subMenu.add_item("None") {
            FHGelsenkirchen::setsurfacetype(Sketchup.active_model.selection, nil)
          }
          #surfaceid = subMenu.add_item("BoundarySurfaceType ID") {
          #  idhash = FHGelsenkirchen::setsurfaceid(Sketchup.active_model.selection, Hash.new())
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
          #    FHGelsenkirchen::setid(Sketchup.active_model.selection, input[0]) if(input)
          #  else
          #    UI.messagebox("The selected faces are not on the same layer")
          #  end
          #}
          subMenu.set_validation_proc(itemground) {

            if $groundsurface == true
              MF_CHECKED
            else $groundsurface == false
              MF_UNCHECKED
            end
          }
          subMenu.set_validation_proc(itemroof) {

            if $roofsurface == true
              MF_CHECKED
            else $roofsurface == false
              MF_UNCHECKED
            end
          }
          subMenu.set_validation_proc(itemwall) {
            if $wallsurface == true
              MF_CHECKED
            else $wallsurface == false
              MF_UNCHECKED
            end
          }
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
        FHGelsenkirchen::findtype(entities, typehash)

        if(typehash.size == 1)
          if(typehash["WallSurface"] != nil)
            $wallsurface = true
            $groundsurface = false
            $roofsurface = false
            $relieffeature = false
          elsif(typehash["RoofSurface"] != nil)
            $wallsurface = false
            $groundsurface = false
            $roofsurface = true
            $relieffeature = false
          elsif(typehash["GroundSurface"] != nil)
            $wallsurface = false
            $groundsurface = true
            $roofsurface = false
            $relieffeature = false
          elsif(typehash["ReliefFeature"] != nil)
            $wallsurface = false
            $groundsurface = false
            $roofsurface = false
            $relieffeature = true
          end
        end
      end
    end
  rescue => e
    puts e
    puts e.backtrace
  end
end