module FHGelsenkirchenTunnels
  class ReverseMaterial
    def initialize(entity)
      @succeeded = 0
      @failed = 0
      if(entity == nil)
        puts "Failed to reverse materials! Nothing selected!";
        return;
      end
      entity.each do |e|
        begin
          Sketchup.active_model.start_operation("Reverse Face", false, false, true);
          reverse(e)
          Sketchup.active_model.commit_operation();
        rescue => e
          Sketchup.active_model.abort_operation();
        end
      end
      puts "successfully reversed: " + @succeeded.to_s + ", failed: " + @failed.to_s
    end
    
    def reverse(entity)
      if(entity.class == Sketchup::Entities)
        entity.each do |e|
          reverse(e)
        end
      elsif(entity.class == Sketchup::Group)
        reverse(entity.entities)
      elsif(entity.class == Sketchup::ComponentInstance)
        reverse(entity.definition.entities)
      elsif(entity.class == Sketchup::Face)
        begin
          uvFront = []
          uvBack = []
          loop = []

          frontMaterial = entity.material
          backMaterial = entity.back_material

          tw = Sketchup.create_texture_writer
          uv_helper = entity.get_UVHelper true, true, tw

          entity.outer_loop.vertices.each do |vertex|
            loop << vertex.position
            uvq = uv_helper.get_front_UVQ(vertex.position)
            uvFront << flattenUVQ(uvq)

            uvq = uv_helper.get_back_UVQ(vertex.position)
            uvBack << flattenUVQ(uvq)
          end

          entity.reverse!

          setTexture(entity,backMaterial,loop,uvBack,true)
          setTexture(entity,frontMaterial,loop,uvFront,false)
          @succeeded += 1
        rescue => e
          @failed += 1
          raise e
        end
      end
    end

    def flattenUVQ(uvq)
     return Geom::Point3d.new(uvq.x / uvq.z, uvq.y / uvq.z, 1.0)
    end

    def setTexture face, material, pts, texturcords, front
      begin        
        if(material == nil || material.texture == nil)
          if(front)
            face.material = material
          else
            face.back_material = material
          end
          return
        end

        if(pts.length  != texturcords.length)
          return
        end
        cords = []
        texturcords.each do |v|
          cords << [v.x, v.y]
        end
        ptsarray = []

        if(pts.length() > 4)
          #Setzt Werte für Rechts Oben/Unten und Links Oben/Unten
          #Es wird jeweils der größte und kleinste Wert für X und Y gesucht
          ro_x = cords[0][0]
          ro_y = cords[0][1]
          lu_x = cords[0][0]
          lu_y = cords[0][1]
          for i in 1..(cords.length() - 1)
            ro_x = cords[i][0] if(cords[i][0] > ro_x)
            ro_y = cords[i][1] if(cords[i][1] > ro_y)
            lu_x = cords[i][0] if(cords[i][0] < lu_x)
            lu_y = cords[i][1] if(cords[i][1] < lu_y)
          end
          #Mit den jeweils 2 Koordinaten für X und Y werden jetzt weitere Punkte
          #berechnet, so wird nen Rechteck erzeugt
          ru_x = ro_x
          ru_y = lu_y
          lo_x = lu_x
          lo_y = ro_y
          abs_ro = []
          abs_ru = []
          abs_lu = []
          abs_lo = []
          for i in 0..(cords.length() - 1)
            abs_ro << [(ro_x - cords[i][0]) * (ro_x - cords[i][0]) + (ro_y - cords[i][1]) * (ro_y - cords[i][1]), i]
            abs_ru << [(ru_x - cords[i][0]) * (ru_x - cords[i][0]) + (ru_y - cords[i][1]) * (ru_y - cords[i][1]), i]
            abs_lu << [(cords[i][0] - lu_x) * (cords[i][0] - lu_x) + (cords[i][1] - lu_y) * (cords[i][1] - lu_y), i]
            abs_lo << [(cords[i][0] - lo_x) * (cords[i][0] - lo_x) + (cords[i][1] - lo_y) * (cords[i][1] - lo_y), i]
          end
          n = abs_ro.length() -1
          abs_ro.sort!
          abs_lo.sort!
          abs_ru.sort!
          abs_lu.sort!
          pos_ru = abs_ru[0][1]
          pos_lu = abs_lu[0][1]
          pos_ro = abs_ro[0][1]
          pos_lo = abs_lo[0][1]
          #Überprüfung, dass ein Eckpunkt nicht doppelt gewählt wird
          if(pos_lu != pos_ru and pos_lu != pos_ro and pos_lu != pos_lo)
            ptsarray << Geom::Point3d.new(pts[pos_lu][0], pts[pos_lu][1], pts[pos_lu][2])
            ptsarray << Geom::Point3d.new(cords[pos_lu][0], cords[pos_lu][1])
          end

          if(pos_ru != pos_ro and pos_ru != pos_lo)
            ptsarray << Geom::Point3d.new(pts[pos_ru][0], pts[pos_ru][1], pts[pos_ru][2])
            ptsarray << Geom::Point3d.new(cords[pos_ru][0], cords[pos_ru][1])
          end

          if(pos_ro != pos_lo)
            ptsarray << Geom::Point3d.new(pts[pos_ro][0], pts[pos_ro][1], pts[pos_ro][2])
            ptsarray << Geom::Point3d.new(cords[pos_ro][0], cords[pos_ro][1])
          end

          ptsarray << Geom::Point3d.new(pts[pos_lo][0], pts[pos_lo][1], pts[pos_lo][2])
          ptsarray << Geom::Point3d.new(cords[pos_lo][0], cords[pos_lo][1])
        else
          for i in 0..(pts.length() - 1)
            ptsarray << Geom::Point3d.new(pts[i])
            ptsarray << Geom::Point3d.new(cords[i][0], cords[i][1])
          end
        end

        begin
          face.position_material(material, ptsarray, front)
        rescue => e
          raise e
          #Wenn hier rein, dann wurden Koordinaten falsch gewählt
        end
      rescue => e
        raise e
      end
    end
  end
end
