#Es werden nur Klassen geladen, die sich direkt im Plugins-Ordner befinden
#Deshalb müssen alle Dateien aus dem Unterordner CityGML beim Starten bekannt gemacht werden

require 'su_citygmltunnels/Win32API'

require 'su_citygmltunnels/Export/CityGMLExport'
require 'su_citygmltunnels/Export/BatchExporter'

require 'su_citygmltunnels/UI/Menu'
require 'su_citygmltunnels/UI/Contextmenu'

require 'su_citygmltunnels/External/rubytoolbar'
require 'su_citygmltunnels/External/htmlentities'