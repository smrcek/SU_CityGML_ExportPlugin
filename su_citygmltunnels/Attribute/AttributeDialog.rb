#Erzeugt Dialog zum wiederherstellen von Attributen

module FHGelsenkirchenTunnels
  class AttributeDialog

    #Erzeugt den Dialog
    def createhtml(attributeArray)
      html = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
           "http://www.w3.org/TR/html4/strict.dtd">
        <html>
        <head>
        <title>Attribute</title>
        <script type="text/javascript">
        function move_to_center() {
          window.location = "skp:move@" + screen.width + "," + screen.height + ":" + document.body.offsetWidth + "," + document.body.offsetHeight;
         }
        function saveAttribute(){
          window.location = \'skp:saveAttribute@\' + document.AttributeSelection.attrselection.selectedIndex;
        }
        function deleteAttribute(){
          window.location = \'skp:deleteAttribute@\' + document.AttributeSelection.attrselection.selectedIndex;
        }
      '
      html += 'function getText(pos) {'
      pos = 0
      html += 'text = new Array(' + attributeArray.length().to_s() + ')
      '
      #Erzeugt Array, in dem alle Attribute gespeichert werden.
      attributeArray.each do |attributes|
        html += 'text[' + pos.to_s() + '] = ""
        '
        attributes.each do |attribute|
          html += 'text[' + pos.to_s() + '] += "' + attribute[1].to_s().gsub(/[\"]/, "\\\"") + " = " + attribute[2].to_s.gsub(/[\"]/, "\\\"") + "<\\/br>\";\n"
        end
        pos += 1
      end
      html += 'return text[pos];
      }
      '
      #Läd das HTML neu, wenn Vorschau für anderes AttributSet geladen werden soll
      html += 'function Reload () {
        pos = document.AttributeSelection.attrselection.selectedIndex;
        text = getText(pos);
        document.getElementById("attribute").innerHTML = text;
        move_to_center()
      }
      </script>
      </head>
      <body onload="Reload()">

      <table border="0" rules="groups">
        <tbody>
            <tr>
          <td>
          <form name ="AttributeSelection" action="select.htm">
          <p>
          <select id="attsel" name="attrselection" size="10"
            onchange="Reload()">'
      pos = 1
      attributeArray.each do |attributes|
        if (pos== 1)
          html += '<option selected>AttributeSet' + pos.to_s() + '</option>'
        else
          html += '<option>AttributeSet' + pos.to_s() + '</option>'
        end
        pos += 1
      end
      html += '</select>
          </p>
          </form>
        </td>
        <td>
        <p id="attribute">1</p>
        </td>
        </tr>
        </tbody>
      </table>
      <input type="button" name="attribute_waehlen" value="Accept choice  " onclick="saveAttribute()">
      <input type="button" name="attribute_waehlen" value="Reset choice" onclick="deleteAttribute()">
      </body>
      </html>
      '
      return html
    end

    #
    def initialize(attributeArray, entity)
      facearray = []
      buildingarray = []
      #Kopiert alle Attribute von Faces in das facearray, Attribute aller Gruppen
      #in das buildingarray
      attributeArray.each do |attribute|
        if(attribute[1] == "Face")
          facearray << attribute[0]
        else
          buildingarray << attribute[0]
        end
      end

      if(entity.class == Sketchup::Face)
        #Gab es überhaupt schon gespeicherte Attribute für Faces? Wenn nicht, Fehlermeldung
        #und beendet die Funktion
        if(facearray.length > 0)
          #Erzeugt den Dialog und zeigt alle Attribute von Faces an
          html = createhtml(facearray)
        else
          UI.messagebox("No attributes saved", MB_OK)
          return;
        end
      else
        #Das Gleiche wie oben, nur für Gruppen
        if(buildingarray.length > 0)
          html = createhtml(buildingarray)
        else
          UI.messagebox("No attributes saved", MB_OK)
          return;
        end
      end
      #WebDialog mit Attributen anzeigen
      @dialog = UI::WebDialog.new("Attribute insert", true, "Attribute #{rand(1000)}", 358, 293);
      @dialog.set_html(html)
      #Callback, wenn die Attribute gelöscht werden sollen
      @dialog.add_action_callback("deleteAttribute") {|dialog, params|
        pos = params.to_s().to_i()
        attributeArray.delete_at(pos)
        html = createhtml(attributeArray)
        @dialog.set_html(html)
      }
      #Zentriert Dialog auf der Mitte des Bildschirms
      #Code aus dem SketchUp-Forum
      @dialog.add_action_callback("move") { |d, a|
        xy, wh = a.split(":")

        x, y = xy.split(",")
        x = x.to_i
        y = y.to_i

        w, h = wh.split(",")
        w = w.to_i
        h = h.to_i

        d.set_position((x - w)/2, (y - h)/2)
      }
      #Callback, der aufgerufen wird, wenn Benutzer Attribute speichern möchte
      @dialog.add_action_callback("saveAttribute") {|dialog, params|
        pos = params.to_s().to_i()
        dicts = entity.attribute_dictionaries()
        if(dicts != nil)
          dicts.each do  |d|
            dicts.delete(d)
          end
        end
        @dialog.close()
        puts "Attribute gespeichert"
        attributeArray[pos][0].each do |attr|
          puts attr
          entity.set_attribute(attr[0], attr[1], attr[2])
        end
      }
      @dialog.show()
    end
  end
end