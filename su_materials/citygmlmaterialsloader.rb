#Es werden nur Klassen geladen, die sich direkt im Plugins-Ordner befinden
#Deshalb müssen alle Dateien aus dem Unterordner CityGML beim Starten bekannt gemacht werden

require 'su_materials/Win32API'

require 'su_materials/Export/CityGMLExport'
require 'su_materials/Export/BatchExporter'

require 'su_materials/UI/Menu'
require 'su_materials/UI/Contextmenu'

require 'su_materials/External/rubytoolbar'
require 'su_materials/External/htmlentities'