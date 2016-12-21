class IntBridgeInstallation
    def initialize(param, lod, noid, generate, coordinate_system, groupsurfaces, actbuildingid)
      @intbridgeinstallations = param
      @lod = lod
      @noid = noid
      @generate = generate
      @coordinate_system = coordinate_system
      @groupsurfaces = groupsurfaces
      @actbuildingid = actbuildingid
    end
    def run
        handle = ""
        @intbridgeinstallations.each_pair {|key, value|
            if(key != "" and key != nil and !@noid)
              handle << "<brid:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<brid:IntBridgeInstallation>\n"
              else
                handle << "<brid:IntBridgeInstallation gml:id=\"#{key}\">\n"
              end
              
              #handle << "<#{lod}>\n"
			  tmp_str = "<#{@lod}>\n"
			  tmp_str = tmp_str.sub! 'MultiSurface', 'Geometry'
			  handle << tmp_str
              handle << "<gml:MultiSurface"
              if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
              handle << ">\n"
              handle << value
              handle << "</gml:MultiSurface>\n"
              #handle << "</#{lod}>\n"
			  tmp_str = tmp_str[1, tmp_str.length-3]
              handle << "</#{tmp_str}>\n"
              handle << "</brid:IntBridgeInstallation>\n"
              handle << "</brid:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<brid:boundedBy>\n"
                  if(@noid or !@generate)
                    handle << "<brid:IntBridgeInstallation>\n"
                  else
                    key = "#{@actbuildingid}_IntBridgeInstallation_#{pos}" if(@generate)
                    pos += 1
                    handle << "<brid:IntBridgeInstallation gml:id=\"#{key}\">\n"
                  end

                  #handle << "<#{lod}>\n"
			      tmp_str = "<#{@lod}>\n"
			      tmp_str = tmp_str.sub! 'MultiSurface', 'Geometry'
			      handle << tmp_str
                  handle << "<gml:MultiSurface"
                  if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
                  handle << ">\n"
                  handle << v
                  handle << "</gml:MultiSurface>\n"
                  #handle << "</#{lod}>\n"
			      tmp_str = tmp_str[1, tmp_str.length-3]
                  handle << "</#{tmp_str}>\n"
                  handle << "</brid:IntBridgeInstallation>\n"
                  handle << "</brid:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<brid:boundedBy>\n"
                if(@noid or !@generate)
                  handle << "<brid:IntBridgeInstallation>\n"
                else
                  key = "#{@actbuildingid}_IntBridgeInstallation_#{pos}" if(@generate)
                  handle << "<brid:IntBridgeInstallation gml:id=\"#{key}\">\n"
                end

                #handle << "<#{lod}>\n"
			    tmp_str = "<#{@lod}>\n"
			    tmp_str = tmp_str.sub! 'MultiSurface', 'Geometry'
			    handle << tmp_str
                handle << "<gml:MultiSurface"
                if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
                handle << ">\n"
                value.each do |v|
                  handle << v
                end
                handle << "</gml:MultiSurface>\n"
                #handle << "</#{@lod}>\n"
			    tmp_str = tmp_str[1, tmp_str.length-3]
                handle << "</#{tmp_str}>\n"
                handle << "</brid:IntBridgeInstallation>\n"
                handle << "</brid:boundedBy>\n"
              end
            end
          }
          return handle
    end
end