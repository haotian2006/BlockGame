local collisions ={}
local refunction = require(script.Parent.Functions)
function  collisions.entityvsterrain(entity,velocity)
    local remainingtime = 1
    local MinTime
    local normal = {0,0,0}
    for i =1,3,1 do
    
        velocity[1] *= (1-math.abs(normal[1]))*remainingtime
        velocity[2] *= (1-math.abs(normal[2]))*remainingtime
         velocity[3] *= (1-math.abs(normal[3]))*remainingtime
    
        normal = {0,0,0}
        MinTime,normal = collisions.entityvsterrainloop(entity,velocity)
       -- game.Players.LocalPlayer.PlayerGui.ScreenGui.Printa.Text = aaaa
        entity.Position[1] += velocity[1]*MinTime
        entity.Position[2] += velocity[2]*MinTime
        entity.Position[3] += velocity[3]*MinTime
        if MinTime <1 and false  then
            entity.Position[1] *= normal[1]*0.00000000001
            entity.Position[2] *= normal[2]*0.00000000001
            entity.Position[3] *= normal[3]*0.00000000001
            
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    velocity = {0,0,0}
    return  entity.Position
end
function collisions.entityvsterrainloop(entity,velocity)
    local position = entity.Position
    local hitbox = entity.HitBoxSize
    local min ={
        position[1]-hitbox.x/2+(velocity[1] <0 and velocity[1]-1 or 0)   ,
        position[2]-hitbox.y/2+(velocity[2] <0 and velocity[2]-1 or 0), 
        position[3]-hitbox.z/2+(velocity[3] <0 and velocity[3]-1 or 0)   
    }
    local max ={
        position[1]+hitbox.x/2 +(velocity[1] >0 and velocity[1]+1 or 0),
        position[2]+hitbox.y/2+(velocity[2] >0 and velocity[2]+1 or 0), 
        position[3]+hitbox.z/2+(velocity[3] >0 and velocity[3]+1 or 0)   
    }
    local normal = {0,0,0}
    local mintime = 1
    local cc
    for x = min[1],max[1],1 do
        for y = min[2],max[2],1 do
            for z = min[3],max[3],1 do
                local block,a = refunction.GetBlock({x,y,z})
                if block  then
                   local a2 = refunction.convertPositionto(a,"table")
                   position = entity.Position
                    local collisiontime,newnormal = collisions.SweaptAABB(position,a2,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil,velocity,mintime)
                    cc = (typeof(newnormal) ~= "table" and newnormal or "AAA")
                    game.Players.LocalPlayer.PlayerGui.ScreenGui.Printa.Text = cc.." || "..mintime
                    if collisiontime < mintime then
                        mintime = collisiontime
                        normal = newnormal
                    end
                end
            end 
        end 
    end 
    return mintime,normal
end
function  collisions.SweaptAABB(b1,b2,s1,s2,o1,o2,velocity,mintime)
    b1 = {b1[1]-s1[1]/2,b1[2]-s1[2]/2,b1[3]-s1[3]/2}--get the bottem left corners
    b2 = {b2[1]-s2[1]/2,b2[2]-s2[2]/2,b2[3]-s2[3]/2}
    local InvEntry = {}
    local InvExit = {}
    local Entry = {}
    local Exit = {}
    if velocity[1]> 0 then
        InvEntry[1] = b2[1] - (b1[1]+s1[1])
        InvExit[1] = (b2[1]+s2[1]) - b1[1]

        Entry[1] = InvEntry[1]/velocity[1]
        Exit[1] = InvExit[1]/velocity[1]
    elseif velocity[1] <0 then
        InvEntry[1] = (b2[1]+s2[1]) - b1[1]
        InvExit[1] = b2[1] - (b1[1]+s1[1])
       
        Entry[1] = InvEntry[1]/velocity[1]
        Exit[1] = InvExit[1]/velocity[1]
    else
        InvEntry[1] = (b2[1]+s2[1]) - b1[1]
        InvExit[1] = b2[1] - (b1[1]+s1[1])

        Entry[1] = -math.huge
        Exit[1] = math.huge
    end

    if velocity[2]> 0 then
        InvEntry[2] = b2[2] - (b1[2]+s1[2])
        InvExit[2] = (b2[2]+s2[2]) - b1[2]
        Entry[2] = InvEntry[2]/velocity[2]
        Exit[2] = InvExit[2]/velocity[2]
    elseif velocity[2] <0 then
        InvEntry[2] = (b2[2]+s2[2]) - b1[2]
        InvExit[2] = b2[2] - (b1[2]+s1[2])
        Entry[2] = InvEntry[2]/velocity[2]
        Exit[2] = InvExit[2]/velocity[2]
    else
        InvEntry[2] = (b2[2]+s2[2]) - b1[2]
        InvExit[2] = b2[2] - (b1[2]+s1[2])

        Entry[2] = -math.huge
        Exit[2] = math.huge
    end
2
    if velocity[3]> 0 then
        InvEntry[3] = b2[3] - (b1[3]+s1[3])
        InvExit[3] = (b2[3]+s2[3]) - b1[3]
        Entry[3] = InvEntry[3]/velocity[3]
        Exit[3] = InvExit[3]/velocity[3]
    elseif velocity[3] <0 then
        InvEntry[3] = (b2[3]+s2[3]) - b1[3]
        InvExit[3] = b2[3] - (b1[3]+s1[3])
        Entry[3] = InvEntry[3]/velocity[3]
        Exit[3] = InvExit[3]/velocity[3]
    else
        InvEntry[3] = (b2[3]+s2[3]) - b1[3]
        InvExit[3] = b2[3] - (b1[3]+s1[3])

        Entry[3] = -math.huge
        Exit[3] = math.huge
    end
    local entrytime = math.max(math.max(Entry[1],Entry[3]),Entry[2])
    if entrytime >= mintime then return 1.0,1 end
    if entrytime < 0 then return 1.0,2 end

    local exittime = math.min(math.min(Exit[1],Exit[3]),Exit[2])
    if entrytime > exittime then return 1.0,3 end
    if Entry[1] > 1 then
        if b2[1] + s2[1] <b1[1] or b1[1] + s1[1] > b2[1]then
            return 1,4
        end
    end
    if Entry[2] > 1 then
        if b2[2] + s2[2] <b1[2] or b1[2] + s1[2] > b2[2]then
            return 1,5
        end
    end
    if Entry[3] > 1 then
        if b2[3] + s2[3] <b1[3] or b1[3] + s1[3] > b2[3]then
            return 1,6
        end
    end
    local normal = {0,0,0}
    if Entry[1] > Entry[3] then
        if Entry[1] > Entry[2] then
            normal[1] = -math.sign(velocity[1])
            normal[2] = 0
            normal[3] = 0
        else
            normal[1] = 0
            normal[2] = -math.sign(velocity[2])
            normal[3] = 0
        end
    else
        if Entry[3] > Entry[2] then
            normal[1] = 0
            normal[2] = 0
            normal[3] = -math.sign(velocity[1])
        else
            normal[1] = 0
            normal[2] = -math.sign(velocity[2])
            normal[3] = 0
        end 
    end
    return entrytime,normal
end
return collisions
