module FHGelsenkirchenMaterials
  #Erzeugt den Dialog, der beim Exportieren angezeigt wird
  class GMLExportDialog
    #Gibt HTML zurück
    #Parameter 1: Array von Namen der Layer, ob diese Visible sind und activ sind
    def self.createDialog(layers,isbatch)
      html = '
<html>
<head>
  <link type="text/css" href="../Dialog/css/smoothness/jquery-ui-1.8.21.custom.css" rel="stylesheet" />
  <link type="text/css" href="../Dialog/css/jquery.ui.selectmenu.css" rel="stylesheet" />
  <link type="text/css" href="../Dialog/css/editor.css" rel="stylesheet" />
  <script type="text/javascript" src="../Dialog/js/jquery-1.7.2.min.js"></script>
  <script type="text/javascript" src="../Dialog/js/jquery-ui-1.8.21.custom.min.js"></script>
  <script type="text/javascript" src="../Dialog/js/jquery.json-2.3.min.js"></script>
  <script type="text/javascript" src="../Dialog/js/jquery.ui.selectmenu.js"></script>
  <script type="text/javascript" src="export.js"></script>
</head>

<body onLoad="move_to_center()">
<form name="Daten">

<ul id="nav">
  <li><a id="tab0" class="selected" href="#" onclick="return swapContent(0)">Layer/LOD/textures</a></li>
  <li><a id="tab1" class="unselected" href="#" onclick="return swapContent(1)">Coordinate system</a></li>
  <li><a id="tab2" class="unselected" href="#" onclick="return swapContent(2)">CityGML options</a></li>
</ul>

<div id="content_all">
  <!-- ------------------------------------------------------------------------------ -->
  <!-- Layer/LOD/textures -->
  <div id="content0">
    <span class="headline1">Subdirectory for textures</span>
    <p class="einruecken">
      <input id="texture" name="texture" type="text" size="40" maxlength="100" '
      if(isbatch)
        html += 'value="textures for < Filebasename >" disabled>'
      else
        html += 'value="textures">'
      end
      html += '
    </p>

    <span class="headline1">Assigned LOD in the CityGML model</span><br/>
    <p class="einruecken lh05">
      <input type="radio" name="LOD" value="1">LOD1<br/><br/>
      <input type="radio" name="LOD" value="2" checked>LOD2<br/><br/>
      <input type="radio" name="LOD" value="3">LOD3<br/><br/>
      <input type="radio" name="LOD" value="4">LOD4
    </p>

    <span class="headline1">Layers to be exported</span><br/>
    <p class="einruecken lh05">'
      if(!isbatch)
        layers.each do |layer|
          html += '<input name="layer" type="checkbox"'
          html += ' checked 'if(layer[1] == true)
          html += ' disabled ' if(layer[2] == true) #Der aktive Layer in SketchUp kann nicht abgewählt werden. Deshalb disabled.
          html += 'id="' + layer[0] + '" onclick="Layervisible(\'' + layer[0] + '\')">' + layer[0]
          html += " (active)" if(layer[2] == true)
          html += '<br/><br/>'
        end
      else
        html += '<input name="layer" type="checkbox" checked disabled id="allLayer"> All layers'
      end
      html += '
    </p>
  </div>

  <!-- ------------------------------------------------------------------------------ -->
  <!-- Coordinate system -->
  <div id="content1" style="display: none">
    <span class="headline1">Orientation</span></br>
    <p class="einruecken lh05">
      <input type="radio" name="orientation" value="1" checked>Easting, Northing<br/><br/>
      <input type="radio" name="orientation" value="2">Northing, Easting
    </p>

    <span class="headline1">Offset</span>
    <input type="button" name="saveOffset_Button" value="Safe Offset" style="margin-left:125px" onclick="saveOffset()"'
    html += ' disabled' if(isbatch) 
    html += '><br/>

    <p class="einruecken">
      <label for="offset_x">X</label><input id="offset_x" name="offset_x" type="text" size="30" maxlength="30" value="0"'
      html += ' disabled' if(isbatch)
      html += '><br/><br/>
      <label for="offset_y">Y</label><input id="offset_y" name="offset_y" type="text" size="30" maxlength="30" value="0"'
      html += ' disabled' if(isbatch)
      html += '><br/><br/>
      <label for="offset_z">Z</label><input id="offset_z" name="offset_z" type="text" size="30" maxlength="30" value="0"'
      html += ' disabled' if(isbatch)
      html += '><br/><br/>
      <label for="yaw">Yaw</label><input id="yaw" name="yaw" type="text" size="30" maxlength="30" value="0"'
      html += ' disabled' if(isbatch)
      html += '><br/><br/>

      <input type="button" name="convert_GK_Button" value="Lat/Lon->GK" onclick="convert_GK()"'
      html += ' disabled' if(isbatch)
      html += '>
      <input type="button" name="convert_UTM_Button" value="Lat/Lon->UTM" onclick="convert_UTM()"'
      html += ' disabled' if(isbatch)
      html += '>
      <input type="button" name="loadworldfilebutton" value="Load Worldfile" onclick="loadworldfile()"'
      html += ' disabled' if(isbatch)
      html += '>
    </p>

    <span class="headline1">Coordinate system (CityGML attribute srsName)</span><br/>
    <p class="einruecken lh05">
      <input id="coordinate_system" name="coordinate_system" type="text" size="50" maxlength="50" value="">
    </p>
  </div>

  <!-- ------------------------------------------------------------------------------ -->
  <!-- CityGML options -->
  <div id="content2" style="display: none">

    <span class="headline1">Appearance</span><br/>
    <p class="einruecken lh05">
      <input type="radio" name="appearance" value="1">Outside of Building element<br/><br/>
      <input type="radio" name="appearance" value="2" checked>Inside of Building element
    </p>
    
    <span class="headline1">Group materials</span><br/>
    <p class="einruecken lh05">
      <input type="radio" name="mat" value="1" checked>All materials in one Appearance element<br/><br/>
      <input type="radio" name="mat" value="2">One material per Appearance element
    </p>
    
    <span class="headline1">GML:IDs</span><br/>
    <p class="einruecken lh05">
      <input type="radio" name="ids" value="1">ID for buildings only <i>( missing building ID\'s will <b>not</b> be generated )</i><br/><br/>
      <input type="radio" name="ids" value="2" checked>ID for all elements <i>( missing ID\'s will be generated )</i><br/><br/>
      <input type="radio" name="ids" value="3">ID for all elements with exististing ID<br/><br/>
      <input id= "groupsurfacetype" type="checkbox" name="groupsurfacetype">Group surfaces without SurfaceType-ID</br><br/>
      <input id= "collision_correct_id" type="checkbox" name="collision_correct_id" checked>Check and correct IDs
    </p>

  </div>
  <div id="abort_start">
    <table>
      <tr>
        <td valign="top"><input type="button" name="abort_button" value="Abort" onclick="abortExport()"></td>
        <td valign="top"><input type="button" name="start_export_button" value="Start export" onclick="GmlExport()"></td>
      </tr>
    </table>
  </div>
</div>

</form>
</body>
</html>
      '
      return html
    end
  end
end
