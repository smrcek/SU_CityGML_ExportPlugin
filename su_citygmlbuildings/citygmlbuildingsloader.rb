#Es werden nur Klassen geladen, die sich direkt im Plugins-Ordner befinden
#Deshalb müssen alle Dateien aus dem Unterordner CityGML beim Starten bekannt gemacht werden

require 'su_citygmlbuildings/Win32API'

require 'su_citygmlbuildings/Export/CityGMLExport'
require 'su_citygmlbuildings/Export/BatchExporter'

require 'su_citygmlbuildings/UI/Menu'
require 'su_citygmlbuildings/UI/Contextmenu'

require 'su_citygmlbuildings/External/rubytoolbar'
require 'su_citygmlbuildings/External/htmlentities'