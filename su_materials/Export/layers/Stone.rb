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
              handle << "<mtrl:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<mtrl:Stone>\n"
              else
                handle << "<mtrl:Stone gml:id=\"#{key}\">\n"
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
              handle << "</mtrl:Stone>\n"
              handle << "</mtrl:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<mtrl:boundedBy>\n"
                  if(@noid or !@generate)
                    handle << "<mtrl:Stone>\n"
                  else
                    key = "#{@actbuildingid}_Stone_#{pos}" if(@generate)
                    pos += 1
                    handle << "<mtrl:Stone gml:id=\"#{key}\">\n"
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
                  handle << "</mtrl:Stone>\n"
                  handle << "</mtrl:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<mtrl:boundedBy>\n"
                if(@noid or !@generate)
                  handle << "<mtrl:Stone>\n"
                else
                  key = "#{@actbuildingid}_Stone_#{pos}" if(@generate)
                  handle << "<mtrl:Stone gml:id=\"#{key}\">\n"
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
                handle << "</mtrl:Stone>\n"
                handle << "</mtrl:boundedBy>\n"
              end
            end
          }
          return handle
    end
end