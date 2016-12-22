CityGML export plugin
=====================

[CityGML](http://www.citygml.org/) is a general information model and XML coding. It serves for describing models with assigning surface types to models. 

This is a modification of CityGML plugin version 1.8 for use in [SketchUp 2015](http://www.sketchup.com). There are some differences like versions of Ruby, plugin sources paths and so on, between SketchUp 2013 and 2015.


#Instalation

1. Download this repo to Plugins path of your SketchUp. In windows it will be typically in `C:\Users\<Username>\AppData\Roaming\SketchUp\SketchUp 2015\SketchUp\Plugins\` .
2. If the plugin is not visible in SketchUp, go to SketchUp menu WINDOWS -> PREFERENCES -> EXTENSION and check the CityGML plugin.
3. Check if setting "Extensions Policy" is "unrestricted".
4. Start using plugin.


#Main features

* This plugin serves for exporting only
* Adjusted for Sketchup 2015 and newer
* Load proper Win32Api
* Support of objects (according to [OGC standards](http://www.opengeospatial.org/standards/citygml)): buildings, tunnels, bridges
    

#Some examples
Models and their surface types (visualisation of surface types are from [FZKViewer](http://iai-typo3.iai.fzk.de/www-extern/index.php?id=1931)).

![Used surface types in this building model](https://cloud.githubusercontent.com/assets/18631402/21408406/39923984-c7d5-11e6-8605-ef718e1af12d.jpg "Used CityGML surface types in this building model")

![Used surface types in this bridge](https://cloud.githubusercontent.com/assets/18631402/21408593/27db4efa-c7d6-11e6-8ecc-61b8afe59fa0.jpg "Used CityGML surface types in this bridge")

![CityGML surface types in this tunnel](https://cloud.githubusercontent.com/assets/18631402/21408478/a21f27fa-c7d5-11e6-99b4-f9490a1c2301.jpg "CityGML surface types in this tunnel")
