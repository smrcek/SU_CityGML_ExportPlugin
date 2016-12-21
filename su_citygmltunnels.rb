# Create an entry in the Extension list that loads a script called
# stairTools.rb.
require 'sketchup'
require 'extensions'

if RUBY_PLATFORM.match(/mswin/i)
  ENV['PATH'] += ";#{File.dirname(__FILE__)}"
  ENV['PATH'] += ";#{File.dirname(__FILE__)}/ruby/bin"
end

module FHGelsenkirchenTunnels
  CITYGML_VERSION = '1.8'
  CITYGML_BUILD = '5842'
  CITYGML_CREATOR = "Westfaelische Hochschule"
  CITYGML_COPYRIGHT = "2012, Westfaelische Hochschule"
end

cityGML_extension = SketchupExtension.new("City GML - Tunnels", "su_citygmltunnels/citygmltunnelsloader.rb")
cityGML_extension.version = FHGelsenkirchenTunnels::CITYGML_VERSION
cityGML_extension.creator = FHGelsenkirchenTunnels::CITYGML_CREATOR
cityGML_extension.copyright = FHGelsenkirchenTunnels::CITYGML_COPYRIGHT
cityGML_extension.description = "Tools for the usage of CityGML."
cityGML_extension.name = "City GML - Tunnels"
Sketchup.register_extension(cityGML_extension, true)