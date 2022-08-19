local move = {}
move.Moving = {}
local maindata = require(game.ServerStorage.MainData)
local refunction = require(game.ReplicatedStorage.Functions)
function move.Jump()
    
end
function move.canMove(uuid,velocity)
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
                maindata.LoadedEntitys[uuid].NotSaved.Velocity.Jump = {0,1,0}
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
    maindata.LoadedEntitys[uuid].NotSaved.Velocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity  or {}
    local velocity =   maindata.LoadedEntitys[uuid].NotSaved.Velocity 
   -- local downvelocity  = maindata.LoadedEntitys[uuid].NotSaved.Velocity.DownVelocity
    local ysize = entity.HitBoxSize.y or 0
    local feetposition = pos[2] - (ysize/2)
    local featblock = refunction.GetBlock({pos[1],feetposition,pos[3]},false)
    local fallendistance = entity.FallDistance
    entity.FallTicks += 1
    local fallrate = (((0.98^entity.FallTicks)-1)*entity.maxfallvelocity)/3
    local lowestblock = refunction.GetFloor(pos)
    if featblock or not lowestblock then
        entity.FallTicks = 0
        velocity.Fall = {0,0,0}
    else
        if feetposition-fallrate <= lowestblock.Y +2 then
           -- fallrate = math.abs(feetposition-(lowestblock.Y +2))
        end
        velocity.Fall = {0,fallrate,0}
    end
end
return move
--[[function move.canMove(uuid,goalposition)
    goalposition = refunction.convertPositionto(goalposition,"table")
	local entity =  maindata.LoadedEntitys[uuid]
	local hitboxsize =entity.HitBoxSize
    local x,y,z = hitboxsize["x"]/2, hitboxsize["y"]/2, hitboxsize["z"]/2
	local pb = refunction.GetBlock(goalposition,false)
    local xb = refunction.GetBlock({goalposition[1]+x,goalposition[2],goalposition[3]},false)
    local nxb = refunction.GetBlock({goalposition[1]-x,goalposition[2],goalposition[3]},false)
    local yb = refunction.GetBlock({goalposition[1],goalposition[2]+y,goalposition[3]},false)
    local nyb = refunction.GetBlock({goalposition[1],goalposition[2]-y,goalposition[3]},false)
    local zb = refunction.GetBlock({goalposition[1],goalposition[2],goalposition[3]+z},false)
    local nzb = refunction.GetBlock({goalposition[1],goalposition[2],goalposition[3]-z},false)
    if pb or xb or nxb or zb or nzb then
        return false
    end
    return true
end
	local Middle = {refunction.GetBlock(goalposition,false)}
    local Front ={ refunction.GetBlock({goalposition[1]+x,goalposition[2],goalposition[3]},false)}
    local Back = {refunction.GetBlock({goalposition[1]-x,goalposition[2],goalposition[3]},false)}
    local head = {refunction.GetBlock({goalposition[1],goalposition[2]+y,goalposition[3]},false)}
    local Feet = {refunction.GetBlock({goalposition[1],goalposition[2]-y,goalposition[3]},false)}
    local Left = {refunction.GetBlock({goalposition[1],goalposition[2],goalposition[3]+z},false)}
    local Right = {refunction.GetBlock({goalposition[1],goalposition[2],goalposition[3]-z},false)}
    if Middle then
--         blocksthatwillbecollided[Middle[2]]-- = Middle[1]
--   --  end
--     if Front then
--         blocksthatwillbecollided[Front[2]] = Front[1]
--     end
--     if Back then
--         blocksthatwillbecollided[Back[2]] = Back[1]
--     end
--     if head then
--         blocksthatwillbecollided[head[2]] = head[1]
--     end
--     if Feet then
--         blocksthatwillbecollided[Feet[2]] = Feet[1]
--     end
--     if Left then
--         blocksthatwillbecollided[Left[2]] = Left[1]
--     end
--     if Right then
--         blocksthatwillbecollided[Right[2]] = Right[1]
--     end
--     for i,v in pairs(blocksthatwillbecollided) do
--         local direaction = refunction.GetUnit(i,entity.Position)
--     end
--]]
--[[function move.canMove(uuid,velocity)
	local entity =  maindata.LoadedEntitys[uuid]
    local goalposition = {entity.Position[1]+velocity[1],entity.Position[2]+velocity[2],entity.Position[3]+velocity[3]}
	local hitboxsize =entity.HitBoxSize
    local x,y,z = hitboxsize["x"]/2, hitboxsize["y"]/2, hitboxsize["z"]/2
    local blocksthatwillbecollided = {}
    local fowardblock,fp = refunction.RayCast(entity.Position,{velocity[1],0,0})
    local SideBlock,sp = refunction.RayCast(entity.Position,{0,0,velocity[3]})
	local UpBlock,up = refunction.RayCast(entity.Position,{0,velocity[2],0})
	--   local frontmost,sidemost,feetmost = 
	if fowardblock then
        fp = refunction.convertPositionto(fp,"vector3")
        if (entity.Position[1]-(hitboxsize.x*0.5)) - velocity[1] <= fp.X +2  then
            velocity[1] =  velocity[1] ~=0 and (entity.Position[1]-(hitboxsize.x*0.5)*(entity.Position[1]/math.abs(entity.Position[1])))-(fp.X +(2*(fp.X/math.abs(fp.X))))or 0
            print(velocity[1],"X" )
        end  
    end
    if SideBlock then
        sp = refunction.convertPositionto(sp,"vector3")
        if (entity.Position[3]-(hitboxsize.z*0.5)) - velocity[3] <= sp.Z +2 then
            velocity[3] =  velocity[3] ~=0 and (entity.Position[3]-(hitboxsize.z*0.5)*(entity.Position[3]/math.abs(entity.Position[3])))-(sp.Z +(2*(sp.Z/math.abs(sp.Z))))or 0
            print(velocity[3],"z" )
        end  
    end
    if UpBlock then
        up = refunction.convertPositionto(up,"vector3")
        if (entity.Position[2]-(hitboxsize.y*0.5)) - velocity[2] <= up.Y +2  then
            velocity[2] =  velocity[2] ~=0 and (entity.Position[2]-(hitboxsize.y*0.5)*(entity.Position[2]/math.abs(entity.Position[2])))-(up.Y +(2*(up.Y/math.abs(up.Y))))or 0
        end  
    end
    return velocity
end
    end]]