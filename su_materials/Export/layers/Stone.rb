class Stone
    def initialize(param, lod, noid, generate, coordinate_system, groupsurfaces, actbuildingid)
      @stone = param
      @lod = lod
      @noid = noid
      @generate = generate
      @coordinate_system = coordinate_system
      @groupsurfaces = groupsurfaces
      @actbuildingid = actbuildingid
    end
    def run
      handle = ""
      @stone.each_pair {|key, value|
            if(key != "" and key != nil and !@noid)
              handle << "<bldg:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<bldg:Stone>\n"
              else
                handle << "<bldg:Stone gml:id=\"#{key}\">\n"
              end
              
              handle << "<#{@lod}>\n"
              handle << "<gml:MultiSurface"
              if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
              handle << ">\n"
              handle << value
              handle << "</gml:MultiSurface>\n"
              handle << "</#{@lod}>\n"
              handle << "</bldg:Stone>\n"
              handle << "</bldg:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<bldg:boundedBy>\n"
                  if(@noid or !@generate)
                    handle << "<bldg:Stone>\n"
                  else
                    key = "#{@actbuildingid}_Stone_#{pos}" if(@generate)
                    pos += 1
                    handle << "<bldg:Stone gml:id=\"#{key}\">\n"
                  end

                  handle << "<#{@lod}>\n"
                  handle << "<gml:MultiSurface"
                  if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
                  handle << ">\n"
                  handle << v
                  handle << "</gml:MultiSurface>\n"
                  handle << "</#{@lod}>\n"
                  handle << "</bldg:Stone>\n"
                  handle << "</bldg:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<bldg:boundedBy>\n"
                if(@noid or !@generate)
                  handle << "<bldg:Stone>\n"
                else
                  key = "#{@actbuildingid}_Stone_#{pos}" if(@generate)
                  handle << "<bldg:Stone gml:id=\"#{key}\">\n"
                end

                handle << "<#{@lod}>\n"
                handle << "<gml:MultiSurface"
                if(!@coordinate_system.nil?)
                handle << " srsName=\"" << @coordinate_system << "\" srsDimension=\"3\""
              end
                handle << ">\n"
                value.each do |v|
                  handle << v
                end
                handle << "</gml:MultiSurface>\n"
                handle << "</#{@lod}>\n"
                handle << "</bldg:Stone>\n"
                handle << "</bldg:boundedBy>\n"
              end
            end
          }
          return handle
    end
end