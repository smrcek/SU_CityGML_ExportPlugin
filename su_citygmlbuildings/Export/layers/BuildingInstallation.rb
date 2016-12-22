class BuildingInstallation
    def initialize(param, lod, noid, generate, coordinate_system, groupsurfaces, actbuildingid)
      @buildinginstallations = param
      @lod = lod
      @noid = noid
      @generate = generate
      @coordinate_system = coordinate_system
      @groupsurfaces = groupsurfaces
      @actbuildingid = actbuildingid
    end
    def run
        handle = ""
        @buildinginstallations.each_pair {|key, value|
            if(key != "" and key != nil and !@noid)
              handle << "<bldg:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<bldg:BuildingInstallation>\n"
              else
                handle << "<bldg:BuildingInstallation gml:id=\"#{key}\">\n"
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
              #handle << "</#{@lod}>\n"
			  tmp_str = tmp_str[1, tmp_str.length-3]
              handle << "</#{tmp_str}>\n"
              handle << "</bldg:BuildingInstallation>\n"
              handle << "</bldg:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<bldg:boundedBy>\n"
                  if(@noid or !@generate)
                    handle << "<bldg:BuildingInstallation>\n"
                  else
                    key = "#{@actbuildingid}_BuildingInstallation_#{pos}" if(@generate)
                    pos += 1
                    handle << "<bldg:BuildingInstallation gml:id=\"#{key}\">\n"
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
                  handle << "</bldg:BuildingInstallation>\n"
                  handle << "</bldg:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<bldg:boundedBy>\n"
                if(@noid or !@generate)
                  handle << "<bldg:BuildingInstallation>\n"
                else
                  key = "#{@actbuildingid}_BuildingInstallation_#{pos}" if(@generate)
                  handle << "<bldg:BuildingInstallation gml:id=\"#{key}\">\n"
                end

                #handle << "<#{@lod}>\n"
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
                handle << "</bldg:BuildingInstallation>\n"
                handle << "</bldg:boundedBy>\n"
              end
            end
          }
          return handle
    end
end