#Es werden nur Klassen geladen, die sich direkt im Plugins-Ordner befinden
#Deshalb müssen alle Dateien aus dem Unterordner CityGML beim Starten bekannt gemacht werden

require 'su_citygmlbridges/Win32API'

require 'su_citygmlbridges/Export/CityGMLExport'
require 'su_citygmlbridges/Export/BatchExporter'

require 'su_citygmlbridges/UI/Menu'
require 'su_citygmlbridges/UI/Contextmenu'

require 'su_citygmlbridges/External/rubytoolbar'
require 'su_citygmlbridges/External/htmlentities'