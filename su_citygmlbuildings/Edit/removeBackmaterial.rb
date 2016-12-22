module FHGelsenkirchenBuildings
  class RemoveBackmaterial
    def initialize(entity)
      if(entity == nil)
        puts "Failed to remove backmaterials! Nothing selected!";
        return;
      end
      entity.each do |e|
        begin
          Sketchup.active_model.start_operation("Remove Backmaterial", false, false, true);
          remove(e)
          Sketchup.active_model.commit_operation();
        rescue => e
          Sketchup.active_model.abort_operation();
        end
      end
      Sketchup.active_model.materials.purge_unused
    end

    def remove(entity)
      if(entity.class == Sketchup::Entities)
        entity.each do |e|
          remove(e)
        end
      elsif(entity.class == Sketchup::Group)
        remove(entity.entities)
      elsif(entity.class == Sketchup::ComponentInstance)
        remove(entity.definition.entities)
      elsif(entity.class == Sketchup::Face)
        begin
          entity.back_material = nil
        rescue => e
          raise e
        end
      end
    end
  end
end