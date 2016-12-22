require 'su_citygmlbridges/Edit/selectBackMaterialSurfaces.rb'
require 'su_citygmlbridges/Services/ExternalService'

module FHGelsenkirchenBridges
  #Plugin wird erst ab Version 7.0 angezeigt
  version_required = 7.0
  begin
    if (Sketchup.version.to_f < version_required)
      UI.messagebox("You need SketchUp " + version_required.to_s +
          " to run the CityGML-Plugin. You can download it at www.sketchup.google.com")
    else
      tool_menu = UI.menu "Plugins"
      m2 = tool_menu.add_submenu("CityGML_Bridges"){}
      m2.add_item("Import"){
        ImportService.new()
      }
      m2.add_item("Export"){
        CityGMLExport.new(false,nil)
      }
      m2.add_item("Batch Export"){
        BatchExporter.new()
      }
      m2.add_separator
      m2.add_item("Feedback"){
        FeedbackService.new()
      }
      m2.add_item("Search for Updates"){
        UpdateService.new()
      }
      m2.add_separator
      m2.add_item("Changelog"){
        ChangelogService.new()
      }
      m2.add_separator
      m2.add_item("Select surfaces with back materials"){
        SelectBackMaterialSurfaces.new()
      }
      m2.add_item("Reverse Faces"){
        ReverseMaterial.new(Sketchup.active_model.selection)
      }
      m2.add_item("Remove Backmaterial"){
        RemoveBackmaterial.new(Sketchup.active_model.selection)
      }

      help_menu = UI.menu("Help")
      help_menu.add_item("About CityGML-Editor"){
        dlg = UI::WebDialog.new("About CityGML-Editor", false, "About CityGML", 465, 640, 150, 150, false);
        dlg.set_file(File.dirname(__FILE__) + "/../About/about.html")
        dlg.add_action_callback("get_version_build") {|d,p|
          script = 'print_version_build( "' + FHGelsenkirchenBridges::CITYGML_VERSION + '", "' + FHGelsenkirchenBridges::CITYGML_BUILD + '" );'
          d.execute_script(script)
        }
        dlg.add_action_callback("exit") do |dlg, params|
          dlg.close
        end

        dlg.show
      }
    end
  rescue => e
    puts e
    puts e.backtrace
  end
end