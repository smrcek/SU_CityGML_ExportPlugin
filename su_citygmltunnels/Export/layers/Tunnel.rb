class Tunnel
    def initialize(param, lod, noid, generate, coordinate_system, groupsurfaces, actbuildingid)
      @tunnel = param
      @lod = lod
      @noid = noid
      @generate = generate
      @coordinate_system = coordinate_system
      @groupsurfaces = groupsurfaces
      @actbuildingid = actbuildingid
    end
    def run
      handle = ""
      @tunnel.each_pair {|key, value|
            if(key != "" and key != nil and !@noid)
              handle << "<tun:boundedBy>\n"
              if(@noid or (key == nil and !@generate) )
                handle << "<tun:Tunnel>\n"
              else
                handle << "<tun:Tunnel gml:id=\"#{key}\">\n"
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
              handle << "</tun:Tunnel>\n"
              handle << "</tun:boundedBy>\n"
            else
              if(!@groupsurfaces)
                pos = 1
                value.each do |v|
                  handle << "<tun:boundedBy>\n"
                  if(@noid or !@generate)
                    handle << "<tun:Tunnel>\n"
                  else
                    key = "#{@actbuildingid}_Tunnel_#{pos}" if(@generate)
                    pos += 1
                    handle << "<tun:Tunnel gml:id=\"#{key}\">\n"
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
                  handle << "</tun:Tunnel>\n"
                  handle << "</tun:boundedBy>\n"
                end
              else
                pos = 1
                handle << "<tun:boundedBy>\n"
                if(@noid or !@generate)
                  handle << "<tun:Tunnel>\n"
                else
                  key = "#{@actbuildingid}_Tunnel_#{pos}" if(@generate)
                  handle << "<tun:Tunnel gml:id=\"#{key}\">\n"
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
                handle << "</tun:Tunnel>\n"
                handle << "</tun:boundedBy>\n"
              end
            end
          }
          return handle
    end
end