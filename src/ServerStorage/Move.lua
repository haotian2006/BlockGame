local move = {}
move.Moving = {}
local maindata = require(game.ServerStorage.MainData)
local refunction = require(game.ReplicatedStorage.Functions)
local ValueListener = require(game.ServerStorage.ValueListener)
local collision_handler = require(game.ReplicatedStorage.CollsionHandler3)
function move.Jump(uuid)
    local entity =  maindata.LoadedEntitys[uuid]
    entity.Jumping = entity.Jumping or false
    if not entity or entity.Jumping == true then return end
    local jumpheight = entity.MaxJump or 5.9
    local e 
    local jumpedamount =0 
    e = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        local jump = jumpheight*deltaTime*4.5
        if entity.IsOnGround  and entity.Jumping == false then
            if jumpedamount == 0 then
                jumpedamount += jumpheight*deltaTime*4.5
               -- jump = 4.1*deltatime
            end 
           end
        if (jumpedamount > 0 and jumpedamount <=jumpheight)  or not maindata.LoadedEntitys[uuid] then
         jumpedamount += jumpheight*deltaTime*4.5
         jump = jumpheight*deltaTime*4.5
         entity.Jumping = true
         else
            entity.Jumping = false
             jump = 0
             jumpedamount = 0
             e:Disconnect()
        end
        entity.NotSaved.Velocity.Jump ={0,jump,0}
    end)
      
end
local oldvelocity = {}
function interpolate(startVector3, finishVector3, alpha)
    local function currentState(start, finish, alpha)
        return start + (finish - start)*alpha

    end

    return {
        currentState(startVector3[1], finishVector3[1], alpha),
        currentState(startVector3[2], finishVector3[2], alpha),
        currentState(startVector3[3], finishVector3[3], alpha)
    }
end
function move.update(uuid,delta)
    local entity =  maindata.LoadedEntitys[uuid]
    if not entity then return end 
    if not entity.NotSaved then
        entity.NotSaved = {}
    end
    local Velocity =entity.NotSaved.Velocity
    local total = {0,0,0}
    if  typeof(Velocity) ~= "table"  then return end
    for i,v in pairs(Velocity) do
        total[1] += v[1]
        total[2] += v[2]
        total[3] += v[3]
    end	
    entity.IsOnGround = collision_handler.IsGrounded(entity)
    local pos = collision_handler.entityvsterrain(entity,total)
    entity.Position = interpolate(entity.Position,pos,delta) 
end
function move.MoveTo(uuid,goal)
    goal = refunction.convertPositionto(goal,"table")
    local currentnumber = move.Moving["uuid"] and move.Moving["uuid"]+1  or 0
    move.Moving["uuid"] = currentnumber 
    local pos = maindata.LoadedEntitys[uuid].Position
    maindata.LoadedEntitys[uuid].NotSaved.Velocity = maindata.LoadedEntitys[uuid].NotSaved.Velocity or {}
    maindata.LoadedEntitys[uuid].NotSaved.Velocity.Move  = maindata.LoadedEntitys[uuid].NotSaved.Velocity.Move  or {}
	local timestart = os.time()
	local direaction = refunction.GetUnit(goal,pos)/7
	direaction = Vector3.new(direaction.X,0,direaction.Z)
	maindata.LoadedEntitys[uuid].NotSaved.Velocity.Move = refunction.convertPositionto(direaction,"table")
	local magnit = refunction.GetMagnituide(goal,pos)
    local timetotake = magnit/7
    repeat
        pos = maindata.LoadedEntitys[uuid].Position
        -- local block,bpostion = refunction.RayCast(pos,direaction) 
        -- local goingtobe =  refunction.ConvertPositionToReal(refunction.AddPosition(pos,direaction))
        -- if block  then
		-- 	if refunction.GetMagnituide(pos,bpostion) <= refunction.GetMagnituide(pos,goingtobe) then
		-- 		print("jump")
        --         move.Jump(uuid)
        --     end
        -- end
        task.wait()
    until refunction.GetMagnituide({pos[1],goal[2],pos[3]},goal) <= 0.5 or move.Moving["uuid"] ~= currentnumber or  os.time()-timestart >= timetotake+5
   -- print("reached",uuid,move.Moving["uuid"], currentnumber,maindata.LoadedEntitys[uuid])
   if  os.time()-timestart >= timetotake+5  then
    warn(uuid,"has Yeilded")
   end
    if  move.Moving["uuid"] == currentnumber then
    maindata.LoadedEntitys[uuid].NotSaved.Velocity.Move = {0,0,0}
    move.Moving["uuid"] = nil
    end
    return (move.Moving["uuid"] == currentnumber ) and "Done" or "Stopped"
end

local oldpos = {}
function  move.HandleFall(uuid)
    local entity =  maindata.LoadedEntitys[uuid]
    if not entity then return end 
    
    local pos =  entity.Position
    local ccx,ccz = refunction.GetChunk(pos)
    if not maindata.Chunk[ccx.."x"..ccz]  then return end
    entity.NotSaved.Velocity  = entity.NotSaved.Velocity  or {}
    local ysize = entity.HitBoxSize.y or 0

    local fallendistance = entity.FallDistance

    local fallrate = ((((0.98)^entity.FallTicks or 0 )-1)*(entity.MaxFallRate or  3.92) )/1.3

   local ypos = pos[2]
    if entity.IsOnGround or not entity.CanFall or entity.Jumping == true then
        entity.FallTicks = 0
        entity.NotSaved.Velocity.Fall = {0,0,0}
    elseif not entity.IsOnGround and entity.CanFall then
        entity.FallTicks += 1
        entity.NotSaved.Velocity.Fall = {0,fallrate,0}
    end
end
return move
--[[function move.canMove(uuid,velocity)
	local entity =  maindata.LoadedEntitys[uuid]
    local goalposition = {entity.Position[1]+velocity[1],entity.Position[2]+velocity[2],entity.Position[3]+velocity[3]}
	local hitboxsize =entity.HitBoxSize
    --local x,y,z = hitboxsize["x"]/2, hitboxsize["y"]/2, hitboxsize["z"]/2
    local blocksthatwillbecollided = {}
    local pos = {entity.Position[1],entity.Position[2]-1,entity.Position[3]}
    local fowardblock,fp = refunction.RayCast(pos,{velocity[1],0,0})
    local SideBlock,sp = refunction.RayCast(pos,{0,0,velocity[3]})
	local UpBlock,up = refunction.RayCast(pos,{0,velocity[2],0})

    local hx =(entity.Position[1]+(hitboxsize.x*0.5)*(velocity[1]/math.abs(velocity[1]))) 
    local hz = (entity.Position[3]+(hitboxsize.z*0.5)*(velocity[3]/math.abs(velocity[3]))) 
    local hy = (entity.Position[2]+(hitboxsize.y*0.5)*(velocity[2]/math.abs(velocity[2]))) 
   -- print(velocity[1])
	--   local frontmost,sidemost,feetmost = 
    local vx,vy,vz = velocity[1] ~=0 and velocity[1] or 1, velocity[2] ~= 0 and velocity[2] or 1 ,velocity[3] ~= 0 and velocity[3] or 1
    local addx,addy,addz = (velocity[1] <= 4*(vx/math.abs(vx))) and velocity[1] or 4*(vx/math.abs(vx)),(velocity[2] <= 4*(vy/math.abs(vy))) and velocity[2] or 4*(vy/math.abs(vy)),(velocity[3] <= 4*(vz/math.abs(vz))) and velocity[3] or 4*(vz/math.abs(vz))
    local xr = (hitboxsize.x/2*(vx/math.abs(vx)))+addx
    local zr = (hitboxsize.z/2*(vz/math.abs(vz)))+addz
    local yr = (hitboxsize.y/2*(vy/math.abs(vy)))+addy
    local fixed = refunction.convertPositionto({xr,yr,zr},"table")
    xr = fixed[1]+refunction.ConvertPositionToReal(entity.Position)[1]
    zr =fixed[3]+refunction.ConvertPositionToReal(entity.Position)[3]
    yr =fixed[2]+refunction.ConvertPositionToReal(entity.Position)[2]
    local sxr =hitboxsize.x/2*-(vx/math.abs(vx))
    local syr = hitboxsize.y/2*-(vy/math.abs(vy))
    local szr = hitboxsize.z/2*-(vz/math.abs(vz))
    fixed = refunction.convertPositionto({sxr,syr,szr},"table")
    sxr = fixed [1]+refunction.ConvertPositionToReal(entity.Position)[1]
    syr = fixed[2]+refunction.ConvertPositionToReal(entity.Position)[2]
    szr = fixed[3]+refunction.ConvertPositionToReal(entity.Position)[3]
    --print(vx,vy,vz)
 --   print(yr,syr,4*(vy/math.abs(vy)))
    local nearbyblocks ={}
    for x = sxr, xr,4*(vx/math.abs(vx)) do
        for y = syr, yr,4*(vy/math.abs(vy)) do
            for z = szr, zr,4*(vz/math.abs(vz)) do
                local block,pos = refunction.GetBlock({x,y,z},false)
                if block and refunction.CheckForCollision(entity.Position,{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,{x,y,z},{4,4,4},nil) then
                    print("e")
                    nearbyblocks[pos] = block
                end
            end
        end
    end
    --print(xr,velocity[1])
	if fowardblock then
        fp = refunction.convertPositionto(fp,"vector3")
        fp = fp.X
        fp = fp+2*(velocity[1]/math.abs(velocity[1]))
        if hx - velocity[1] <= fp  then
            velocity[1] =  (velocity[1] >=0.001 or velocity[1] <= -0.001  ) and hx-(fp ) or 0
           -- print(velocity[1],"X",hx,fp )
        end  
    end
    if SideBlock then
        sp = refunction.convertPositionto(sp,"vector3")
        sp = sp.Z
        sp = sp+2*-(velocity[3]/math.abs(velocity[3]))
        if hz - velocity[3] <= sp  then
            velocity[3] =  (velocity[3] >=0.001 or velocity[3] <= -0.001  ) and hz-(sp ) or 0
           -- print(velocity[3],"z",hz,sp )
        end  
    end
    if UpBlock then
        up = refunction.convertPositionto(up,"vector3")
        up = up.Y
        up = up+2*-(velocity[2]/math.abs(velocity[2]))
        if hy - velocity[2] <= up   then
            velocity[2] =  velocity[2] ~=0 and hy- (up ) or 0
        end  
    end
    return velocity
end]]
--[[
    local function get(uuid,velocity,value)
    local entity = maindata.LoadedEntitys[uuid] 
    if not entity then return velocity end
    local hitbox = entity.HitBoxSize
    local pos = entity.Position
    local vx = pn(velocity[1])
    local vy = pn(velocity[2])
    local vz = pn(velocity[3])
    local startx = pos[1]+(hitbox.x*0.5+math.abs(velocity[1]))*vx
    local endx =   pos[1]-(hitbox.x*0.5)*vx
    local starty = pos[2]+(hitbox.y*0.5+math.abs(velocity[2]))*vy
    local endy =  pos[2]-(hitbox.y*0.5)*vy
    local startz =pos[3]+(hitbox.z*0.5+math.abs(velocity[3]))*vz
    local endz =  pos[3]-(hitbox.z*0.5)*vz
    local detected = {}
    local currentblock
    local minentry = 1
    local normal 
    local broadphasePOS,SIZE = refunction.GetSweaptBroadPhase(pos,{hitbox.x,hitbox.y,hitbox.z},nil,velocity)
    for x = (startx),(endx),1*-vx do
         for z = (startz),(endz),1*-vz do
            for y = (starty),(endy),1*-vy do
                local block,bpos = refunction.GetBlock({x,y,z},false)
                if block and not detected[bpos]  then
                    bpos = refunction.convertPositionto(bpos,"table") 
                    if  refunction.AABBCheck(broadphasePOS,SIZE,nil,bpos,{4,4,4},nil,velocity) then
                    local entry,normala = refunction.SweapAABB(pos,{hitbox.x,hitbox.y,hitbox.z},nil,bpos,{4,4,4},nil,velocity)
                    if entry < minentry then
                        currentblock = bpos
                        minentry = entry
                        normal = normala
                    end
                    detected[bpos] = {entry,normala}
                    
                    end
                end
            end
        end
    end
    return currentblock,normal,minentry
end
function move.canMove(uuid,velocity)
    local entity = maindata.LoadedEntitys[uuid] 
    if not entity then return velocity end
    local hitbox = entity.HitBoxSize
    local pos = entity.Position
    local newveloicty = {0,0,0}
        for i,v in ipairs(velocity)do
                local currentblock1,normal1,minentry1 = get(uuid,velocity,i)
                if currentblock1 then
                    pos[1] += velocity[1]*minentry1
                    pos[2] += velocity[2]*minentry1
                    pos[3] += velocity[3]*minentry1
                     velocity[1] = normal1[1] ~= 0 and 0 or  velocity[1]
                    velocity[2]= normal1[2] ~= 0 and 0 or  velocity[2]
                    velocity[3]= normal1[3] ~= 0 and 0 or  velocity[3]
                    print(refunction.convertPositionto(velocity,"string")) 
                    if normal1[1] ~= 0 then
                        newveloicty[1] = velocity[1]
                    end
                    if normal1[2] ~= 0 then
                        newveloicty[2] = velocity[2]
                    end
                    if normal1[3] ~= 0 then
                        newveloicty[3] = velocity[3]
                    end
        end
    end
    if refunction.convertPositionto(newveloicty,"string") == "0,0,0" then
        newveloicty = velocity
    end
    return newveloicty
end
]]