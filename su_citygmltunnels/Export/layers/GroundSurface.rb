class GroundSurface
    def initialize(param, lod, noid, generate, coordinate_system, groupsurfaces, actbuildingid)
      @groundsurfaces = param
      @lod = lod
      @noid = noid
      @generate = generate
      @coordinate_system = coordinate_system
      @groupsurfaces = groupsurfaces
      @actbuildingid = actbuildingid
    end
    def run
      handle = ""
      @groundsurfaces.each_pair {|key, value|
            if(key != ""  and key != nil and !@noid)
              handle << "<tun:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<tun:GroundSurface>\n"
              else
                handle << "<tun:GroundSurface gml:id=\"#{key}\">\n"
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
              handle << "</tun:GroundSurface>\n"
              handle << "</tun:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<tun:boundedBy>\n"
                  if(@noid or !@generate )
                    handle << "<tun:GroundSurface>\n"
                  else
                    key = "#{@actbuildingid}_GroundSurface_#{pos}" if(@generate)
                    pos += 1
                    handle << "<tun:GroundSurface gml:id=\"#{key}\">\n"
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
                  handle << "</tun:GroundSurface>\n"
                  handle << "</tun:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<tun:boundedBy>\n"
                if(@noid or !@generate )
                  handle << "<tun:GroundSurface>\n"
                else
                  key = "#{@actbuildingid}GroundSurface_#{pos}" if(@generate)
                  handle << "<tun:GroundSurface gml:id=\"#{key}\">\n"
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
                handle << "</tun:GroundSurface>\n"
                handle << "</tun:boundedBy>\n"
              end
            end
          }
          return handle
    end
end