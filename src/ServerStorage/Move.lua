local move = {}
move.Moving = {}
local maindata = require(game.ServerStorage.MainData)
local refunction = require(game.ReplicatedStorage.Functions)
function move.Jump()
    
end
local oldvelocity = {}
local function Round(to_round,near)
    local divided = to_round / near
    local rounded = near * math.floor(divided)
    return rounded
end
function move.canMove(uuid,velocity)
    print(velocity[2])
	local entity =  maindata.LoadedEntitys[uuid]
    local goalposition = {entity.Position[1]+velocity[1],entity.Position[2]+velocity[2],entity.Position[3]+velocity[3]}
	local hitboxsize =entity.HitBoxSize
    --local x,y,z = hitboxsize["x"]/2, hitboxsize["y"]/2, hitboxsize["z"]/2
    local blocksthatwillbecollided = {}
    --local fowardblock,fp = refunction.RayCast(pos,{velocity[1],0,0})
    --local SideBlock,sp = refunction.RayCast(pos,{0,0,velocity[3]})
	--local UpBlock,up = refunction.RayCast(pos,{0,velocity[2],0})

    local vx,vy,vz = velocity[1] ~=0 and velocity[1] or 1, velocity[2] ~= 0 and velocity[2] or 1 ,velocity[3] ~= 0 and velocity[3] or 1
    local addx,addy,addz = --(velocity[1] <= 4 and velocity[1] >= -4) and velocity[1] or 4*(vx/math.abs(vx)),
                            --(velocity[2] <= 4 and velocity[2] >= -4) and velocity[2] or 4*(vy/math.abs(vy)),
                            --(velocity[3] <= 4 and velocity[3] >= -4) and velocity[3] or 4*(vz/math.abs(vz))
                            4*(vx/math.abs(vx)),4*(vy/math.abs(vy)),4*(vz/math.abs(vz))
   if oldvelocity[uuid]  then
        if oldvelocity[1] then
            --print(oldvelocity[uuid][1][1], vx/math.abs(vx),entity.Position[1], oldvelocity[uuid][1][2] )
        end
        if oldvelocity[uuid][1] and oldvelocity[uuid][1][1] == vx/math.abs(vx) and  velocity[1] ~= 0 then
            if oldvelocity[uuid][1][2] == entity.Position[1] then
                if  refunction.CheckForCollision(entity.Position,{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,oldvelocity[uuid][1][3] ,{4,4,4},nil,false) then
                    --print(refunction.convertPositionto(entity.Position,"string"))
                  --  print(refunction.convertPositionto(oldvelocity[uuid][1][3],"string"))
                    velocity[1] = 0 
                end
        
               -- print("x")
            end
        end
        if oldvelocity[uuid][2] and oldvelocity[uuid][2][1] == vy/math.abs(vy) and  velocity[2] ~= 0 then
            if oldvelocity[uuid][2][2] == entity.Position[2] then
                if  refunction.CheckForCollision(entity.Position,{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,oldvelocity[uuid][2][3] ,{4,4,4},nil) then
                    velocity[2] = 0 
                end
            end
        end
        if oldvelocity[uuid][3] and oldvelocity[uuid][3][1] == vz/math.abs(vz) and  velocity[3] ~= 0 then
            if oldvelocity[uuid][3][2] == entity.Position[3] then
                if  refunction.CheckForCollision(entity.Position,{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,oldvelocity[uuid][3][3] ,{4,4,4},nil) then
                    velocity[3] = 0 
                end
            end
        end
    end
    if refunction.convertPositionto(velocity,"string") == "0,0,0" then
        return velocity
    end
    entity.NotSaved["yvelocity"] =  velocity[2]
    local xr = (hitboxsize.x/2*(vx/math.abs(vx)))+((velocity[1]==0) and 0 or addx)
    local zr = (hitboxsize.z/2*(vz/math.abs(vz)))+((velocity[3]==0) and 0 or addz)
    local yr = (hitboxsize.y/2*(vy/math.abs(vy)))+((velocity[3]==0) and 0 or addz)
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
    local closestx 
    local closesty
    local closestz
    local hitingyblock 
    for x = sxr, xr,4*(vx/math.abs(vx)) do
        for z = szr, zr,4*(vz/math.abs(vz)) do
             for y = syr, yr,4*(vy/math.abs(vy)) do
                local block,pos = refunction.GetBlock({x,y,z},false)
                if pos then
                    pos = refunction.convertPositionto(pos,"table")
                  
                end
               -- print(entity.Position[2],velocity[2]
                if block and refunction.CheckForCollision({entity.Position[1],entity.Position[2],entity.Position[3]},{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,pos,{4,4,4},nil) then
                    local endhitboxX = (entity.Position[1] + (hitboxsize.x/2)*(vx/math.abs(vx)))+velocity[1]
                    local endhitboxZ = (entity.Position[3] + (hitboxsize.z/2)*(vz/math.abs(vz)))+velocity[3]
                    local endhitboxY = (entity.Position[2] + (hitboxsize.y/2)*(vy/math.abs(vy)))+velocity[2]
                    endhitboxX = {endhitboxX,entity.Position[2],entity.Position[3]}
                    endhitboxZ = {entity.Position[1],entity.Position[2],endhitboxZ}
                    endhitboxY = {entity.Position[1],endhitboxY,entity.Position[3]}
                    if not closestx and velocity[1] ~=0 then
                        closestx = pos
                    end
                    if not closesty and velocity[2] ~=0 then
                        closesty = pos
                        --print("e")
                    end
                    if not closestz and velocity[3] ~=0 then
                        closestz = pos
                    end
                    if velocity[1] ~=0  and refunction.GetMagnituide(endhitboxX,closestx) > refunction.GetMagnituide(endhitboxX,pos) then
                        closestx = pos
                    end
                    if velocity[2] ~=0  and refunction.GetMagnituide(endhitboxY,closesty) > refunction.GetMagnituide(endhitboxY,pos)then
                        closesty = pos
                      --  print("ec")
                    end
                    if velocity[3] ~=0  and refunction.GetMagnituide(endhitboxZ,closestz) > refunction.GetMagnituide(endhitboxZ,pos) then
                        closestz = pos

                    end
                    --nearbyblocks[pos] = block
                end
            end
        end
    end
    if not    oldvelocity[uuid]  then
        oldvelocity[uuid] = {}
    end 
  --  print(velocity[1],velocity[3])
	--print(xr,velocity[1])
	if closestx and closestz then
		if refunction.convertPositionto(closestx,"string") == refunction.convertPositionto(closestz,"string") then
			local endhitboxX = (entity.Position[1] + (hitboxsize.x/2)*(vx/math.abs(vx)))+velocity[1]
			local endhitboxZ = (entity.Position[3] + (hitboxsize.z/2)*(vz/math.abs(vz)))+velocity[3]
            endhitboxX = {endhitboxX,entity.Position[2],entity.Position[3]}
            endhitboxZ = {entity.Position[1],entity.Position[2],endhitboxZ}
			if refunction.GetMagnituide(endhitboxX,closestx) < refunction.GetMagnituide(endhitboxZ,closestx)then
			closestz = nil
		else
			closestx = nil
		end
		end
	end
    if closestx and closesty then
		if refunction.convertPositionto(closestx,"string") == refunction.convertPositionto(closesty,"string") then
			local endhitboxX = (entity.Position[1] + (hitboxsize.x/2)*(vx/math.abs(vx)))+velocity[1]
			local endhitboxY = (entity.Position[2] + (hitboxsize.y/2)*(vy/math.abs(vy)))+velocity[2]
            endhitboxX = {endhitboxX,entity.Position[2],entity.Position[3]}
            endhitboxY = {entity.Position[1],endhitboxY,entity.Position[3]}
			if refunction.GetMagnituide(endhitboxX,closestx) < refunction.GetMagnituide(endhitboxY,closesty)then
			closesty = nil
		else
			closestx = nil
		end
		end
	end
    if closestz and closesty then
		if refunction.convertPositionto(closestz,"string") == refunction.convertPositionto(closesty,"string") then
			local endhitboxZ = (entity.Position[3] + (hitboxsize.z/2)*(vz/math.abs(vz)))+velocity[3]
			local endhitboxY = (entity.Position[2] + (hitboxsize.y/2)*(vy/math.abs(vy)))+velocity[2]
            endhitboxZ = {entity.Position[1],entity.Position[2],endhitboxZ}
            endhitboxY = {entity.Position[1],endhitboxY,entity.Position[3]}
			if refunction.GetMagnituide(endhitboxZ,closestz) < refunction.GetMagnituide(endhitboxY,closesty)then
			closesty = nil
		else
			closestz = nil
		end
		end
	end
   -- print(entity.Position[1])
--print(closesty,velocity[2])
	if closestx then
        local endhitboxX = (entity.Position[1] + (hitboxsize.x/2)*(vx/math.abs(vx)))+velocity[1]
        local enhitboxclose = closestx[1] + (4/2)*(-(vx/math.abs(vx)))
        local distance = endhitboxX-enhitboxclose
        if distance ~= 0 then
         --  distance= distance+0.1*(vx/math.abs(vx))
          --  print(distance, velocity[1],"X")
            velocity[1] = (velocity[1]-(velocity[1]*distance)/velocity[1]) ~= (velocity[1]-(velocity[1]*distance)/velocity[1]) and  velocity[1] or (velocity[1]-(velocity[1]*distance)/velocity[1])
            oldvelocity[uuid][1] = {(vx/math.abs(vx)),entity.Position[1]}
            oldvelocity[uuid][1][3] =  closestx
        end
    end
    if closestz then
        local endhitboxX = (entity.Position[3] + (hitboxsize.z/2)*(vz/math.abs(vz)))+velocity[3]
		local enhitboxclose = closestz[3] + (4/2)*(-(vz/math.abs(vz)))
        local distance = endhitboxX-enhitboxclose
        if distance ~= 0 then
          -- distance= distance+0.1*(vz/math.abs(vz))
        --    print(distance, velocity[3],"Z")
          oldvelocity[uuid][3] = {(vz/math.abs(vz)),entity.Position[3]}
            velocity[3] = (velocity[3]-(velocity[3]*distance)/velocity[3]) ~= (velocity[3]-(velocity[3]*distance)/velocity[3]) and  velocity[3] or (velocity[3]-(velocity[3]*distance)/velocity[3])
            oldvelocity[uuid][3][3] =  closestz
        end
    end
    if closesty  then
        local endhitboxX = (entity.Position[2] + (hitboxsize.y/2)*(vy/math.abs(vy)))+velocity[2]
		local enhitboxclose = closesty[2] + (4/2)*(-(vy/math.abs(vy)))
        local distance = endhitboxX-enhitboxclose
        if distance ~= 0 then
           -- distance= distance+0.01*(vz/math.abs(vz))
            oldvelocity[uuid][2] = {(vy/math.abs(vy)),entity.Position[2]}
            velocity[2] = (velocity[2]-(velocity[2]*distance)/velocity[2]) ~= (velocity[2]-(velocity[2]*distance)/velocity[2]) and  velocity[2] or (velocity[2]-(velocity[2]*distance)/velocity[2])
            oldvelocity[uuid][2][3] =  closesty
        end
    end
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
function move.update(uuid)
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
    Velocity = move.canMove(uuid,total)
    maindata.LoadedEntitys[uuid].NotSaved.Velocity.Jump = {0,0,0}
	entity.Position = refunction.convertPositionto(refunction.convertPositionto(Velocity,"vector3")+refunction.convertPositionto(entity.Position,"vector3"),"table")

end
function  move.HandleFall(uuid)
    local entity =  maindata.LoadedEntitys[uuid]
    local pos = maindata.LoadedEntitys[uuid].Position
    local ccx,ccz = refunction.GetChunck(pos)
    if not maindata.LoadedChuncks[ccx.."x"..ccz] then return end

    maindata.LoadedEntitys[uuid].NotSaved.Velocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity  or {}
    local velocity =   maindata.LoadedEntitys[uuid].NotSaved.Velocity 
   -- local downvelocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity.DownVelocity
   local hitboxsize = entity.HitBoxSize
    local ysize = entity.HitBoxSize.y or 0
    local feetposition = pos[2] - (ysize/2)
    local fallendistance = entity.FallDistance
    entity.FallTicks += 1
    local fallrate = (((0.98^entity.FallTicks)-1)*entity.maxfallvelocity)/3
   -- if velocity[2]
   local ypos = pos[2]
    local featblock 
    for x = pos[1]-hitboxsize.x/2,  pos[1]+hitboxsize.x/2,4 do
        for z = pos[3]-hitboxsize.z/2,  pos[3]+hitboxsize.z/2,4 do
            local y = feetposition-2
                local block,pos = refunction.GetBlock({x,y,z},false)
                if pos then
                    pos = refunction.convertPositionto(pos,"table")                
                end
               -- print(entity.Position[2],velocity[2]
                if block and refunction.CheckForCollision({entity.Position[1],entity.Position[2],entity.Position[3]},{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,pos,{4,4,4},nil) then
                    featblock = pos
                end
        end
    end
    if featblock then
        entity.FallTicks = 0
        velocity.Fall = {0,0,0}
    else
        velocity.Fall = {0,fallrate,0}
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