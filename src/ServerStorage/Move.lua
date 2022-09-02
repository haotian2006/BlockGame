local move = {}
move.Moving = {}
local maindata = require(game.ServerStorage.MainData)
local refunction = require(game.ReplicatedStorage.Functions)
local ValueListener = require(game.ServerStorage.ValueListener)
function move.Jump()
    
end
local oldvelocity = {}
local function Round(to_round,near)
    local divided = to_round / near
    local rounded = near * math.floor(divided)
    return rounded
end
local function pn(value)
    local values = value/math.abs(value)
    if values ~= values then
        values = 1
    end
    return values
end
function lerp(start, finish, alpha)
    return start + (finish - start)*alpha
end
function move.Lerp(self,finish, alpha)
    self = refunction.convertPositionto(self,"vector3")
    finish = refunction.convertPositionto(finish,"vector3")
    -- implicit definition of self being the Vector3 Lerp is applied on
    return Vector3.new(
        lerp(self.x, finish.x, alpha),
        lerp(self.y, finish.y, alpha),
        lerp(self.z, finish.z, alpha)
    )
end
function move.canMove(uuid,velocity)
    local entity = maindata.LoadedEntitys[uuid] 
    
    local oldvelocity = entity.NotSaved.OldVelocity
    oldvelocity = oldvelocity or {}
    if not entity then return velocity end
    local hitbox = entity.HitBoxSize
    local pos = entity.Position
   -- local goalpos = refunction.AddPosition(pos,velocity)
    local vx = pn(velocity[1])
    local vy = pn(velocity[2])
    local vz = pn(velocity[3])
     vx = pn(velocity[1])
     vy = pn(velocity[2])*(velocity[2]==0 and -1 or 1)
     vz = pn(velocity[3])
    local startx = pos[1]+((hitbox.x-0.001)*0.5+(velocity[1] == 0 and 0 or (5-hitbox.x >0 and 5-hitbox.x or 1) ))*vx
    local endx =   pos[1]-(hitbox.x*0.5)*vx
    local starty = pos[2]+((hitbox.y-0.001)*0.5+(5-hitbox.y >0 and 5-hitbox.y or 1) )*vy
    local endy =  pos[2]-(hitbox.y*0.5)*vy
    local startz =pos[3]+((hitbox.z-0.001)*0.5+(velocity[3] == 0 and 0 or (5-hitbox.z >0 and 5-hitbox.z or 1) ))*vz
    local endz =  pos[3]-(hitbox.z*0.5)*vz
    local detected = {}
    local currentx
    local currenty
    local currentz
    local OnGround
    if velocity[1] ~= 0 then
       -- print((hitbox.x*0.5+(velocity[1] == 0 and 0 or 1 ))*vx)
    end
    for x = startx,endx,1*-vx do
         for z = startz,endz,1*-vz do
            for y = starty,endy,1*-vy do
              local  xx = refunction.convertvaluetoreal(x,vx)
              local  yy = refunction.convertvaluetoreal(y,vy)
              local  zz = refunction.convertvaluetoreal(z,vz)
                local block,bpos = refunction.GetBlock({xx,yy,zz},false)
                if block and not detected[bpos] then
                    detected[bpos] = true
                    bpos = refunction.convertPositionto(bpos,"table") 
                    if refunction.CheckForCollision(pos,{hitbox.x,hitbox.y,hitbox.z},nil,bpos,{4,4,4},nil) then

                        if ((refunction.convertvaluetoreal(x) ~= refunction.convertvaluetoreal(startx)) or velocity[1] == 0 )and ((refunction.convertvaluetoreal(z) ~= refunction.convertvaluetoreal(startz))or velocity[3] == 0) then
                           if velocity[2] == 0 and refunction.convertvaluetoreal(y)==refunction.convertvaluetoreal(starty)  then
                                OnGround = true
                                continue
                            end
                            currenty = currenty or (velocity[2]~=0 and bpos) 
                            if currenty and math.abs(pos[2]-currenty[2]) > math.abs(pos[2]-bpos[2])  then
                                currenty = bpos
                            end
                        end
						if (refunction.convertvaluetoreal(y) ~= refunction.convertvaluetoreal(starty)) and ((refunction.convertvaluetoreal(z) ~= refunction.convertvaluetoreal(startz ))or velocity[3] == 0) then
                            currentx =  currentx or (velocity[1]~=0 and bpos) 
                            if currentx and math.abs(pos[1]-currentx[1]) > math.abs(pos[1]-bpos[1])  then
                                currentx = bpos
                            end
                        end
						if ((refunction.convertvaluetoreal(x) ~= refunction.convertvaluetoreal(startx))or velocity[1] == 0) and (refunction.convertvaluetoreal(y) ~= refunction.convertvaluetoreal(starty)) then
                            currentz =  currentz or (velocity[3]~=0 and bpos) 
                            if currentz and math.abs(pos[3]-currentz[3]) > math.abs(pos[3]-bpos[3])  then
                                currentz = bpos
                            end
                        end
                    end
                end
            end
        end
    end
    if currentx then
        --print(currentx.X)
     --   local unit = refunction.GetUnit(currentx,pos)
        --if pn(unit.X) == vx then
        --refunction.CheckForCollision(pos,{hitbox.x,hitbox.y,hitbox.z},nil,currentx,{4,4,4},nil,true)
       --print(refunction.convertPositionto(currentx,"string"))
        oldvelocity[1] = {vx,pos[1],currentx}
     --   print(refunction.convertPositionto(currentx,"string"))
        local hitboxend = startx
        local currentend = currentx[1]+2*-vx
        pos[1] = currentend+hitbox.x/2*-vx
        velocity[1] = 0
        
       -- end
    end
    if currentz then
     --   local unit = refunction.GetUnit(currentz,pos)
     --   if pn(unit.Z) == vz then

        local hitboxend = startz
        local currentend = currentz[3]+2*-vz
        pos[3] = currentend+hitbox.z/2*-vz
        velocity[3] = 0
        
      --  end
    end
  --  print( math.floor( velocity[2]+0.5) , (currenty and true or false),(hitbox.y*0.5+(velocity[2] == 0 and 0 or 1 ))*vy)
    if currenty  then
     --   local unit = refunction.GetUnit(currenty,pos)
     --   if pn(unit.Y) == vy then
        oldvelocity[2] = {vy,pos[2],currenty}
    
      --  print(currenty)
        local hitboxend = starty
        local currentend = currenty[2]+2*-vy
        local distance = hitboxend-currentend*-vy
        -- if distance ~= 0 then
        --         velocity[2] -= distance
        -- end
        pos[2] = currentend+hitbox.y/2
        velocity[2] = 0
        
      --  end
    end
    if (currenty or OnGround) and vy == -1  then
        ValueListener.Change(uuid,"IsOnGround",true)
    elseif not currenty or  (vy == 1 and velocity[2] ~= 0) then
        ValueListener.Change(uuid,"IsOnGround",false)

    end
    --print(starty)
    return velocity
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
        local block,bpostion = refunction.RayCast(pos,direaction) 
        local goingtobe =  refunction.ConvertPositionToReal(refunction.AddPosition(pos,direaction))
        if block and false then
			if refunction.GetMagnituide(pos,bpostion) <= refunction.GetMagnituide(pos,goingtobe) then
				print("jump")
              --  maindata.LoadedEntitys[uuid].NotSaved.Velocity.Jump = {0,1,0}
            end
        end
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
function move.update(uuid,delta)
	local entity =  maindata.LoadedEntitys[uuid]
	if not entity.NotSaved then
		entity.NotSaved = {}
	end
	local Velocity = maindata.LoadedEntitys[uuid].NotSaved.Velocity
    local total = {0,0,0}
    if  typeof(Velocity) ~= "table"  then return end
    for i,v in pairs(Velocity) do
        total[1] += v[1]
        total[2] += v[2]
        total[3] += v[3]
    end	
    local goal = refunction.AddPosition(entity.Position,total)
     total =move.Lerp(entity.Position,goal,delta),"table"
    local diffrence = refunction.convertPositionto(refunction.SubPosition(goal,total),"table")
    Velocity = move.canMove(uuid,diffrence)
    maindata.LoadedEntitys[uuid].NotSaved.Velocity.Jump = {0,0,0}
	entity.Position = refunction.convertPositionto(refunction.convertPositionto(Velocity,"vector3")+refunction.convertPositionto(entity.Position,"vector3"),"table")

end
local oldpos = {}
function  move.HandleFall(uuid)
    local entity =  maindata.LoadedEntitys[uuid]
    local pos = maindata.LoadedEntitys[uuid].Position
    local ccx,ccz = refunction.GetChunck(pos)
    if not maindata.LoadedBlocks[ccx.."x"..ccz] then return end

    maindata.LoadedEntitys[uuid].NotSaved.Velocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity  or {}
    local velocity =   maindata.LoadedEntitys[uuid].NotSaved.Velocity 
   -- local downvelocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity.DownVelocity
    local ysize = entity.HitBoxSize.y or 0
    local feetposition = pos[2] - (ysize/2)
    local featblock = refunction.GetBlock({pos[1],feetposition,pos[3]},false)
    local fallendistance = entity.FallDistance
    entity.FallTicks += 1
    local fallrate = (((0.98^entity.FallTicks)-1)*entity.maxfallvelocity)
    local lowestblock = refunction.GetFloor(pos)
   -- if velocity[2]
   local ypos = pos[2]
    if entity.IsOnGround or not entity.CanFall  then
     --   entity.NotSaved["LastYBlock"] = nil
       -- print("e")
        entity.FallTicks = 0
        velocity.Fall = {0,0,0}
    elseif not entity.IsOnGround and entity.CanFall then
       -- velocity.Fall = {0,fallrate,0}
    end
    if ypos ~=   oldpos[uuid] then
    oldpos[uuid] = ypos
    
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