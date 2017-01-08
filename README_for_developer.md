CityGML export plugin
=====================

#The Next Possible step to implement

It would be cool to create model switching mechanism for this project to separate 
bridges, buildings and tunnels model types in system menu and context menu.

Now these three model types are standalone plugins and they are loaded all at once, 
so there are all possible layers from these plugins loaded in context menu. 

The next goal is then load only relevant layers (in context menu) and exports (in system menu)
according to current selected model type.

Now plugins are loaded by three plugin loaders su_citygmlbridges.rb, su_citygmlbuildings.rb, su_citygmltunnels.rb
staticaly and layers are loaded by listing layer files in 'Export/layers' directories.

I wish you good luck in this step ;).

#Creating new surfaces

For creating new layer types is needed to create new class in a new file located at <Sketchup_plugins_folder>/<plugin_name>/Export/layers'. Both with name of intended layer name.
The layer class must have two methods: run and initialize.
- The run method is called to generate part of the resulting gml which is related to this new layer type. 
    This part of the gml file is returned by the run method in a String format.
- The initialize method is used to get all useful and necessary informations related to this new layer type stored in method parameters.

