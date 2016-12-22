module FHGelsenkirchenTunnels
  class SelectBackMaterialSurfaces
    def initialize()
      model = Sketchup.active_model
      @selection = model.selection
      @selection.clear

      findBackMaterial(model.entities)
      UI.messagebox "Selected Surfaces: #{@selection.count}", MB_OK
    end

    def findBackMaterial(entity)
      entity.each do |e|
        if(e.class ==Sketchup::Group)
          findBackMaterial(e.entities)
        elsif(e.class == Sketchup::ComponentInstance)
          findBackMaterial(e.definition.entities)
        elsif(e.class == Sketchup::Face)
          if(e.back_material != nil)
            @selection.add e
          end
        end
      end
    end
  end
end