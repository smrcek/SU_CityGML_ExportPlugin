require 'su_materials\UI\ProgressBar'

module FHGelsenkirchenMaterials
  class AttributeEdit
    @@stdAvailableBuildingAttributes = ['id','description','name','creationDate','terminationDate','class','function','usage','yearOfConstruction','yearOfDemolition','roofType','measuredHeight','storeysAboveGround','storeysBelowGround','storeyHeightsAboveGround','storeyHeightsBelowGround']
    @@stdAvailableSurfaceAttributes = ['FromDate','ToDate','BoundarySurfaceType ID','PolygonID','LinearRingID']

    def self.AvailableBuildingAttributes
      @@stdAvailableBuildingAttributes
    end

    def initialize
      @entity = Sketchup.active_model.selection.first
      if(@entity.class != Sketchup::Face and @entity.class != Sketchup::Group and @entity.class != Sketchup::ComponentInstance)
        return;
      end

      Sketchup.active_model.start_operation("Edit attributes");

      @stdDict = @entity.attribute_dictionary("Standard attribute",true)
      @genDict = @entity.attribute_dictionary("Generic attribute",true)

      @dlgOpen = true;
      @dlg = UI::WebDialog.new("Edit attributes", true, "AM");
      @dlg.set_file(File.dirname(__FILE__) + "/../Dialog/edit.html");
      @dlg.set_size 600, 500;
      @dlg.add_action_callback("LoadAvailableStdAttributes") {|dialog, params| OnLoadAvailableStdAttributes(dialog,params);}
      @dlg.add_action_callback("ImportStandardAttributes") {|dialog, params|  OnImportStandardAttributes(dialog,params); }
      @dlg.add_action_callback("ImportGenericAttributes") {|dialog, params|  OnImportGenericAttributes(dialog,params); }

      @dlg.add_action_callback("AddAttribute") {|dialog, params|  OnAddAttribute(dialog, params); }
      @dlg.add_action_callback("RemoveAttribute") {|dialog, params|  OnRemoveAttribute(dialog, params); }

      @dlg.add_action_callback("Accept") {|dialog, params| OnAccept(dialog,params);}
      @dlg.add_action_callback("Cancel") {|dialog, params| OnCancel(dialog,params);}
      @dlg.set_on_close { OnClose();}
      @dlg.show();
    end

    def OnLoadAvailableStdAttributes(dialog, params)
      script = "OnLoadAvailableStdAttributes('";
      first = true;

      if(@entity.class == Sketchup::Face)
        stdAttributes = @@stdAvailableSurfaceAttributes
      else
        stdAttributes = @@stdAvailableBuildingAttributes
      end
      stdAttributes.each do |e|
        if(!first)
          script << "|"
        else
          first = false
        end
        script << e
      end
      script << "')";
      @dlg.execute_script(script);
    end

    def OnImportStandardAttributes(dialog, params)
      script = "OnImportStandardAttributes('{";
      first = true;
      @stdDict.each do |k,v|
        if(first)
          first = false;
        else
          script << ',';
        end
        script << '"' << FHGelsenkirchenMaterials::stringDecode(k) << '":"' << FHGelsenkirchenMaterials::stringDecode(v) << '"'
      end
      script << "}');";
      @dlg.execute_script(script);
    end

    def OnImportGenericAttributes(dialog, params)
      script = "OnImportGenericAttributes('{";
      first = true;
      @genDict.each do |k,v|
        if(first)
          first = false;
        else
          script << ',';
        end
        script << '"' << FHGelsenkirchenMaterials::stringDecode(k) << '":"' << FHGelsenkirchenMaterials::stringDecode(v) << '"'
      end
      script << "}');";
      @dlg.execute_script(script);
    end

    def OnAddAttribute(dialog, params)
      p = params.split('##||##')
      if(p.length == 3)
        if(p[0] == 'std')
          @entity.set_attribute("Standard attribute",FHGelsenkirchenMaterials::stringEncode(p[1]),FHGelsenkirchenMaterials::stringEncode(p[2]));
        elsif(p[0] == 'gen')
          @entity.set_attribute("Generic attribute",FHGelsenkirchenMaterials::stringEncode(p[1]),FHGelsenkirchenMaterials::stringEncode(p[2]));
        end
      end
    end

    def OnRemoveAttribute(dialog, params)
      p = params.split('##||##')
      if(p.length == 2)
        if(p[0] == 'std')
          @entity.delete_attribute("Standard attribute",FHGelsenkirchenMaterials::stringEncode(p[1]));
        elsif(p[0] == 'gen')
          @entity.delete_attribute("Generic attribute",FHGelsenkirchenMaterials::stringEncode(p[1]));
        end
      end
    end

    def OnAccept(dialog, params)
      @dlgOpen = false;
      Sketchup.active_model.commit_operation();
      @dlg.close();
    end

    def OnCancel(dialog, params)
      @dlgOpen = false;
      Sketchup.active_model.abort_operation();
      @dlg.close();
    end

    def OnClose()
      if(@dlgOpen)
        Sketchup.active_model.abort_operation();
      end
    end
  end

  def FHGelsenkirchenMaterials::setid(entities, id)
    entities.each do |e|
      if(e.class == Sketchup::Face)
        begin
          #e.set_attribute "Standard attribute", "SurfaceType", type
          e.set_attribute("Standard attribute", "BoundarySurfaceType ID", id)
        rescue => err
          puts err
        end
      elsif(e.class == Sketchup::Group)
        setid(e.entities, id)
      elsif(e.class == Sketchup::ComponentInstance)
        setid(e.definition.entities, id)
      end
    end
  end

  def FHGelsenkirchenMaterials::setsurfacetype(entities, type)
	total_entities = entities.count
	pb = ProgressBar.new(total_entities, "Progress...")
	count_elements = 0
    
    entities.each do |e|
	  count_elements += 1
	  pb.update_progress_bar(count_elements)
      if(e.class == Sketchup::Face)
        if(type != nil)
          begin
            #e.set_attribute "Standard attribute", "SurfaceType", type
            e.layer= type
          rescue => err
            e.layer= Sketchup.active_model.layers.add(type)
          end
        else
          begin
            #e.delete_attribute "Standard attribute", "SurfaceType"
            face.layer= "No Surfacetype"
          rescue => err
            e.layer= Sketchup.active_model.layers.add("No Surfacetype")
          end
        end
      elsif(e.class == Sketchup::Group)
        setsurfacetype(e.entities, type)
      elsif(e.class == Sketchup::ComponentInstance)
        setsurfacetype(e.definition.entities, type)
      end
    end
	dlg_report = UI::WebDialog.new("C", false, nil, 0, 0, 0, 0,false)
	dlg_report.set_position(400, 400)
	dlg_report.set_on_close{
		UI.messagebox("Surfacetype(s) changed!", MB_OK)
	}
	dlg_report.show()
	dlg_report.close()
  end

  def FHGelsenkirchenMaterials::setsurfaceid(entities, hash)
    entities.each do |e|
      if(e.class == Sketchup::Face)
        id = e.get_attribute("Standard attribute", "BoundarySurfaceType ID", "")
        if(hash[e.layer.name] == nil)
          hash[e.layer.name] = Hash.new
        end
        if(hash[e.layer.name][id] == nil)
          hash[e.layer.name][id] = 1
        else
          hash[e.layer.name][id] += 1
        end
      elsif(e.class == Sketchup::Group)
        setsurfaceid(e.entities, hash)
      elsif(e.class == Sketchup::ComponentInstance)
        setsurfaceid(e.definition.entities, hash)
      end
    end
    return hash
  end

  def FHGelsenkirchenMaterials::hasface?(entities)
    entities.each do |e|
      if(e.class == Sketchup::Face)
        return true
      elsif(e.class == Sketchup::Group)
        return hasface?(e.entities)
      elsif(e.class == Sketchup::ComponentInstance)
        return hasface?(e.definition.entities)
      end
    end
    return false
  end

  def FHGelsenkirchenMaterials::findtype(entities, typehash)
    
    layers = Array.new
    Dir.foreach(File.dirname(__FILE__) + "/../Export/layers/") do |item|
      items = item.split('.')
          if(!items[0].nil?)
            layers << items[0]
          end
    end

    entities.each do |e|
      if(e.class == Sketchup::Face)
        value = nil #= e.get_attribute "Standard attribute", "SurfaceType", nil
        #value = e.layer.name
        #if(e.layer.name != value) ## doplnit vybrane typy ploch / floorsurface
        #if(e.layer.name == "GroundSurface" or e.layer.name == "WallSurface" or e.layer.name == "FloorSurface" or e.layer.name == "RoofSurface" or e.layer.name == "ReliefFeature" or e.layer.name == "OuterFloorSurface" or e.layer.name == "IntBuildingInstallation" or e.layer.name == "BuildingInstallation" or e.layer.name == "Door" or e.layer.name == "Window" or e.layer.name == "CeilingSurface" or e.layer.name == "InteriorWallSurface" or e.layer.name == "No Surfacetype")
    if(layers.include? e.layer.name or e.layer.name == "No Surfacetype")
          #e.set_attribute "Standard attribute", "SurfaceType", e.layer.name
          value = e.layer.name
        end
        #end
        if(value != nil)
          if(typehash[value] == nil)
            typehash[value] = 1
          else
            typehash[value] += 1
          end
        end
      elsif(e.class == Sketchup::Group)
        findtype(e.entities, typehash)
      elsif(e.class == Sketchup::ComponentInstance)
        findtype(e.definition.entities, typehash)
      end
    end
  end

  def FHGelsenkirchenMaterials::stringEncode(s)
    if(s == nil)
      return nil
    end
    coder = HTMLEntities.new
    return coder.encode(str_filter(s), :named)
  end

  def FHGelsenkirchenMaterials::stringDecode(s)
    if(s == nil)
      return nil
    end
    coder = HTMLEntities.new
    return coder.decode(s)
  end

  def FHGelsenkirchenMaterials::str_filter(s)
    if(s == nil)
      return nil
    end
    str = s;

    str.gsub!("\x80".force_encoding('binary'),'€')
    str.gsub!("\x83".force_encoding('binary'),'ƒ')
    str.gsub!("\x89".force_encoding('binary'),'‰')

    str.gsub!("\xA7".force_encoding('binary'),'§')
    str.gsub!("\xA9".force_encoding('binary'),'©')

    str.gsub!("\xB0".force_encoding('binary'),'°')
    str.gsub!("\xB5".force_encoding('binary'),'µ')

    str.gsub!("\xC4".force_encoding('binary'),'Ä')

    str.gsub!("\xD6".force_encoding('binary'),'Ö')
    str.gsub!("\xDC".force_encoding('binary'),'Ü')
    str.gsub!("\xDF".force_encoding('binary'),'ß')

    str.gsub!("\xE4".force_encoding('binary'),'ä')

    str.gsub!("\xF6".force_encoding('binary'),'ö')
    str.gsub!("\xFC".force_encoding('binary'),'ü')

    return str
  end
end