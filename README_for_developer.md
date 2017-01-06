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
