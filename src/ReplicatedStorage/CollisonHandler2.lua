local collisions = {}
local AABBH = require(script.Parent.AABB)
local refunction = require(script.Parent.Functions)
local function floordiv(x,y)
    return math.floor(x/y)
end 
local function floormod(x,y)
    return (x-(floordiv(x,y)*y))
end 
local function CorrectChunkPos(chunk,pos)
    return chunk + floordiv(pos,64)
end 
function collisions.new(uuid)
    local data = {}
    collisions[uuid] = data
     function data:entityvsterrain(entity,velocity)
        local AABB = AABBH.createCenterSize(Vector3.new(entity.Position[1],entity.Position[2],entity.Position[3]),entity.HitBoxSize.x,entity.HitBoxSize.y,entity.HitBoxSize.z)
        local Aura = Vector3.new(
            math.ceil(AABB.size.X)+1,
            math.ceil(AABB.size.Y)+1,
            math.ceil(AABB.size.Z)+1 
        )
        local normal = self.normal
        local MinTime
        local remainingtime = 1
        for i = 1,3 ,1 do
            velocity[1] *= (1-math.abs(normal[1]))*remainingtime
            velocity[2] *= (1-math.abs(normal[2]))*remainingtime
            velocity[3] *= (1-math.abs(normal[3]))*remainingtime
            self.normal = {0,0,0}
            MinTime = self:entityvsterrainloop(entity,velocity,AABB,Aura)

            entity.Position[1] += velocity[1]*MinTime
            entity.Position[2] += velocity[2]*MinTime
            entity.Position[3] += velocity[3]*MinTime
            if MinTime <1.0 then
                entity.Position[1] += normal[1]*0.0001
                entity.Position[2] += normal[2]*0.0001
                entity.Position[3] += normal[3]*0.0001
            end
            remainingtime = 1.0-MinTime
            if remainingtime <=0 then break end
        end
        velocity = {0,0,0} 
    end
    
     function data:entityvsterrainloop(entity,velocity,AABB,Aura)
        local Chunk = self.Chunk
        local maxInint = self.maxInint
        local minInint = self.minInint
        local maxI = self.maxI
        local minI = self.minI
        local max = self.max
        local min = self.min
        local real = self.real
        real = entity.Position
        minI = {AABB.min.X+real[1],AABB.min.Y+real[2],AABB.min.Z+real[3]}
        maxI = {AABB.max.X+real[1],AABB.max.Y+real[2],AABB.max.Z+real[3]}
        -- maxI[1] /=2
        -- maxI[2] /=2
        -- maxI[3] /=2
        -- minI[1] /=2
        -- minI[2] /=2
        -- minI[3] /=2
        self.minI = minI
        self.maxI = maxI
        minInint = {math.floor(minI[1]),math.floor(minI[2]),math.floor(minI[3])}
        maxInint = {math.floor(maxI[1]),math.floor(maxI[2]),math.floor(maxI[3])}
        self.minI = minInint
        self.maxI = maxInint
       real  = refunction.convertPositionto(refunction.AddPosition(real,velocity),"table")
       self.real = real
        min = {AABB.min.X + real[1],AABB.min.Y + real[2], AABB.min.Z + real[3]}
        max = {AABB.max.X + real[1],AABB.max.Y + real[2], AABB.max.Z + real[3]}
        -- max[1] /= 2
        -- max[2] /= 2
        -- max[3] /= 2
        -- min[1] /= 2
        -- min[2] /= 2
        -- min[3] /= 2
        self.min = min 
        self.max = max 
        local minX = math.floor(math.min(min[1],minI[1]))
        local minY = math.floor(math.min(min[2],minI[2]))
        local minZ = math.floor(math.min(min[3],minI[3]))

        local maxX = math.floor(math.min(max[1],maxI[1]))
        local maxY = math.floor(math.min(max[2],maxI[2]))
        local maxZ = math.floor(math.min(max[3],maxI[3]))
        local minTime = 1.0
        local chunk = {refunction.GetChunk(entity.Position)}
        for x = minX, maxX,1 do
            local rx = floormod(x,64)
            Chunk[1] = CorrectChunkPos(chunk[1],x)

            local xOklength = x >= minInint[1] and x <= maxInint[1]
            local xOK = x == minInint[1] -1 or x == maxInint[1] + 1
            for z = minZ, maxZ,1 do
                local rz = floormod(z,64)
                Chunk[2] = CorrectChunkPos(chunk[2],z)
    
                local zOK = (xOklength and (z == minInint[3]-1 or z == maxInint[3]+1)) or 
                            (xOK and z >= minInint[3] and z <= maxInint[3])
                 for y = minY, maxY,1 do
                    local block,a = refunction.GetBlock({x,y,z})
                    if y >=0 and block  then
                        a = refunction.convertPositionto(a,"table")
                        local collisontime = self:SweptAABB(velocity,a,minTime)
                        if y == minInint[2] and collisontime < 1 and zOK then
                            
                        end
                        if collisontime < minTime then
                            minTime = collisontime

                        end
                    end
                end 
            end
        end
        return minTime
    end
    data.real = {0,0,0}
    data.min = {0,0,0}
    data.max = {0,0,0}
    data.minI = {0,0,0}
    data.maxI = {0,0,0}
    data.minInint = {0,0,0}
    data.maxInint = {0,0,0}
    data.Chunk = {0,0}

    data.InvEntry = {0,0,0}
    data.invExit = {0,0,0}
    data.entry = {0,0,0}
    data.exit = {0,0,0}
    
    data.normal = {0,0,0}
     function data:SweptAABB(velocity,Position2,MinTime)

        local maxI = self.maxI
        local minI = self.minI
        local max = self.max
        local min = self.min
        local real = self.real

        local InvEntry,invExit,entry,exit = self.InvEntry,self.invExit,self.entry,self.exit
        local normal = self.normal
        if velocity[1] > 0.0 then
            InvEntry[1] = Position2[1] - maxI[1]
            entry[1] = InvEntry[1]/velocity[1]
            invExit[1] = Position2[1]+1  - minI[1]
            exit[1] = invExit[1]/velocity[1]
        elseif velocity[1] <0.0 then
            InvEntry[1] = Position2[1] +1 - minI[1]
            entry[1] = InvEntry[1]/velocity[1]
            invExit[1] = Position2[1] -maxI[1]
            exit[1] = invExit[1]/velocity[1]
        else
            InvEntry[1] = Position2[1] +1 - minI[1]
            invExit[1] = Position2[1] - maxI[1]
            entry[1] = -math.huge
            exit[1] = math.huge
        end
        if velocity[2] > 0.0 then
            InvEntry[2] = Position2[2] - maxI[2]
            entry[2] = InvEntry[2]/velocity[2]
            invExit[2] = Position2[2]  +1 - minI[2]
            exit[2] = invExit[2]/velocity[2]
        elseif velocity[2] <0.0 then
            InvEntry[2] = Position2[2] +1 - minI[2]
            entry[2] = InvEntry[2]/velocity[2]
            invExit[2] = Position2[2] -maxI[2]
            exit[2] = invExit[2]/velocity[2]
        else
            InvEntry[2] = Position2[2] +1 - minI[2]
            invExit[2] = Position2[2] - maxI[2]
            entry[2] = -math.huge
            exit[2] = math.huge
        end
        if velocity[3] > 0.0 then
            InvEntry[3] = Position2[3] - maxI[3]
            entry[3] = InvEntry[3]/velocity[3]
            invExit[3] = Position2[3]  +1 - minI[3]
            exit[3] = invExit[3]/velocity[3]
        elseif velocity[3] <0.0 then
            InvEntry[3] = Position2[3] +1 - minI[3]
            entry[3] = InvEntry[3]/velocity[3]
            invExit[3] = Position2[3] -maxI[3]
            exit[3] = invExit[3]/velocity[3]
        else
            InvEntry[3] = Position2[3] +1 - minI[3]
            invExit[3] = Position2[3] - maxI[3]
            entry[3] = -math.huge
            exit[3] = math.huge
        end
    
        local entrytime = math.max(math.max(entry[1],entry[3]),entry[2])
        if entrytime >= MinTime then return 1.0 end
        if entrytime < 0 then return 1.0 end
    
        local exittime = math.min(math.min(exit[1],exit[3]),exit[2])
    
        if entrytime > exittime then return 1.0 end
    
        if entry[1] > 1.0 then
            if max[1] < Position2[1] or min[1] > Position2[1] +1 then
                return 1.0
            end
        end
        if entry[2] > 1.0 then
            if max[2] < Position2[2] or min[2] > Position2[2] +1 then
                return 1.0
            end
        end
        if entry[3] > 1.0 then
            if max[3] < Position2[3] or min[3] > Position2[3] +1 then
                return 1.0
            end
        end
        
        if entry[1] > entry[3] then
            if entry[1] > entry[2] then
                normal[1] = -math.sign(velocity[1])
                normal[2] = 0
                normal[3] = 0
            else
                normal[1] = 0
                normal[2] = -math.sign(velocity[2])
                normal[3] = 0
            end
        else
            if entry[3] > entry[2] then
                normal[1] = 0
                normal[2] = 0
                normal[3] = -math.sign(velocity[1])
            else
                normal[1] = 0
                normal[2] = -math.sign(velocity[2])
                normal[3] = 0
            end 
        end
        self.normal = normal
        return entrytime
    end
    return data
end
return collisions