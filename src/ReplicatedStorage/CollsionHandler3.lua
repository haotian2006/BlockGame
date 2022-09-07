local collisions ={}
local refunction = require(script.Parent.Functions)
local function getincreased(min,goal2,increased2)
	local direaction = min - goal2
	return goal2 +increased2*-math.sign(direaction)
end

function collisions.DealWithRotation(blockdata)
    return refunction.DealWithRotation(blockdata)
end
function  collisions.IsGrounded(entity)
    local position = entity.Position
    local hitbox = entity.HitBoxSize
    local min ={
        position[1]-hitbox.x/2,
        position[2]-(hitbox.y/2+0.5),
        position[3]-hitbox.z/2,
    }
    local max ={
        position[1]+hitbox.x/2,
        position[2]-(hitbox.y/2),
        position[3]+hitbox.z/2,  
    }
    local gridsize = 4
--a
    for x = min[1],getincreased(min[1],max[1],gridsize),gridsize do    
        for y = min[2],getincreased(min[2],max[2],gridsize),gridsize do
            for z = min[3],getincreased(min[3],max[3],gridsize),gridsize do
                local block,a = refunction.GetBlock({x,y,z})
                if block then
                    if a == "-68,80,-120" then
                        --local a2 = refunction.convertPositionto(a,"table")
                         -- print(collisions.AABBcheck({position[1], position[2]-1,position[3]},a2,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil)  )
                    end
                   local a2 = refunction.convertPositionto(a,"table")
                   local newpos ,newsize = collisions.DealWithRotation(block)
                   if  collisions.AABBcheck({position[1], position[2]-1,position[3]},newpos,{hitbox.x,hitbox.y,hitbox.z},newsize) then 

                    return true,block
                    end   
                end
            end 
        end 
    end 
    return false
end
function  collisions.entityvsterrain(entity,velocity)
    local position = entity.Position
   -- print(velocity[2])
    local remainingtime = 1
    local MinTime
    local normal = {0,0,0}
    local hitbox = entity.HitBoxSize
    local originaly = velocity[2]
    for i =1,3,1 do
      
    velocity[1] *= (1-math.abs(normal[1]))*remainingtime
    velocity[2] *= (1-math.abs(normal[2]))*remainingtime
    velocity[3] *= (1-math.abs(normal[3]))*remainingtime
        local bb
        normal = {0,0,0}
        MinTime,normal,bb = collisions.entityvsterrainloop(entity,position,velocity)
       -- game.Players.LocalPlayer.PlayerGui.ScreenGui.Printa.Text = aaaa
        -- entity.Position[1] += velocity[1]*MinTime
        -- entity.Position[2] += velocity[2]*MinTime
        -- entity.Position[3] += velocity[3]*MinTime
        local placevelocity = {}
        placevelocity[1] = velocity[1]*MinTime
        placevelocity[2] = velocity[2]*MinTime
        placevelocity[3] = velocity[3]*MinTime
        --so basicly i need to check if the velocity is colliding with the curreny normal
    --    if bb then 
    --     print(collisions.SweaptAABB(entity.Position,bb,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil,{velocity[1],0,0},1) == 1)
    --    end
    --     if placevelocity[1] == 0 and velocity[1]~= 0 and bb and collisions.SweaptAABB(entity.Position,bb,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil,{velocity[1],0,0},1) == 1 then
        
    --      placevelocity[1] = velocity[1]
    --     end
    --     if placevelocity[2] == 0 and velocity[2]~= 0 and bb and collisions.SweaptAABB(entity.Position,bb,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil,{0,velocity[2],0},1) == 1 then
    --      placevelocity[2] = velocity[2]
    --     end
    --     if placevelocity[3] == 0 and velocity[3]~= 0  and bb and collisions.SweaptAABB(entity.Position,bb,{hitbox.x,hitbox.y,hitbox.z},{4,4,4},nil,nil,{0,0,velocity[3]},1) == 1 then
    --      placevelocity[3] = velocity[3]
    --     end
        position[1] += placevelocity[1]
        position[2] += placevelocity[2]
        position[3] += placevelocity[3]
        if MinTime <1 then
            --epsilon 
            if velocity[1] >0 then
                position[1] -= 0.001
            elseif velocity[1] <0 then
                position[1] += 0.001
            end
            if velocity[2] >0 then
                position[2] -= 0.001
            elseif velocity[2] <0 then
                position[2] += 0.001
            end
            if velocity[3] >0 then
                position[3] -= 0.00001
            elseif velocity[3] <0 then
                position[3] += 0.00001
            end
        end
        remainingtime = 1.0-MinTime
        if remainingtime <=0 then break end
        
    end
    velocity = {0,0,0}
    return  position
end
--[[function collisions.QuickAABBCheck(b1,b2,s1,s2,o1,o2,velocity)
    b1 = {b1[1]-s1[1]/2,b1[2]-s1[2]/2,b1[3]-s1[3]/2}
    b2 = {b2[1]-s2[1]/2,b2[2]-s2[2]/2,b2[3]-s2[3]/2}
    local originalb1 = b1
    local distance_fromblock = refunction.GetMagnituide(b1,b2)
    b1 = refunction.convertPositionto(refunction.AddPosition(b1,velocity),"table")
    local distance_fromnew= refunction.GetMagnituide(b1,originalb1)

end]]
function collisions.GetBroadPhase(b1,s1,velocity)
    b1 = {b1[1]-s1[1]/2,b1[2]-s1[2]/2,b1[3]-s1[3]/2}
    local position = {}
    local size = {}
    position[1] = velocity[1] >0 and b1[1] or b1[1] + velocity[1]
    position[2] = velocity[2] >0 and b1[2] or b1[2] + velocity[2]
    position[3] = velocity[3] >0 and b1[3] or b1[3] + velocity[3]
    size[1] = velocity[1] >0 and velocity[1]+s1[1] or s1[1] - velocity[1]
    size[2] = velocity[2] >0 and velocity[2]+s1[2] or s1[2] - velocity[2]
    size[3] = velocity[3] >0 and velocity[3]+s1[3] or s1[3] - velocity[3]
    return position,size
end
function collisions.AABBcheck(b1,b2,s1,s2,isbp)
    if  isbp == true then
    else
        b1 = {b1[1]-s1[1]/2,b1[2]-s1[2]/2,b1[3]-s1[3]/2}
    end
    b2 = {b2[1]-s2[1]/2,b2[2]-s2[2]/2,b2[3]-s2[3]/2}
    if refunction.convertPositionto(b2,"string") == "-70,78,-122" and not isbp then
       -- print(b1[2])
    end
    return not (b1[1]+s1[1] < b2[1] or 
                b1[1]>b2[1]+s2[1] or
                b1[2]+s1[2] < b2[2] or 
                b1[2]>b2[2]+s2[2] or                                       
                b1[3]+s1[3] < b2[3] or 
                b1[3]>b2[3]+s2[3] )                                      
end

function collisions.entityvsterrainloop(entity,position,velocity)
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
    local zack 
    local gridsize = 4
    local bppos,bpsize = collisions.GetBroadPhase(position,{hitbox.x,hitbox.y,hitbox.z},velocity)
    for x = min[1],getincreased(min[1],max[1],gridsize),gridsize do    
        for y = min[2],getincreased(min[2],max[2],gridsize),gridsize do
            for z = min[3],getincreased(min[3],max[3],gridsize),gridsize do
                local block,a = refunction.GetBlock({x,y,z},false,position)
                if block then
                   local a2 = refunction.convertPositionto(a,"table")
                   local newpos ,newsize = collisions.DealWithRotation(block)
                   if not collisions.AABBcheck(bppos,newpos,bpsize,newsize,true) then continue end
                    local collisiontime,newnormal = collisions.SweaptAABB(position,newpos,{hitbox.x,hitbox.y,hitbox.z},newsize,velocity,mintime)
                    game.Players.LocalPlayer.PlayerGui.ScreenGui.Printa.Text = (typeof(newnormal) == "table" and newnormal[3] or 6)
                    if collisiontime < mintime then
                       zack = a2
                        mintime = collisiontime
                        normal = newnormal
                    end
                end
            end 
        end 
    end 
    return mintime,normal,zack
end
--b1:entitypos b2:blockpos s1:entitysize s2:blocksize o1:entity orientation o2:block orientation 
function  collisions.SweaptAABB(b1,b2,s1,s2,velocity,mintime)
    local aaa = b2
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
    local a 
    if entrytime == Entry[1] then
        a = "a" 
    elseif entrytime == Entry[2] then
        a = "b" 
    else
        a = "c" 
    end
    if entrytime >= mintime then return 1.0,1 end
    if entrytime < 0 then return 1.0,entrytime end

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
       if a == "b" then
   --   print(refunction.convertPositionto(aaa))
       end
    return entrytime,normal
end
return collisions
