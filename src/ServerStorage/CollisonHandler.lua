local Collison = {}
local reFunction = require(game.ReplicatedStorage.Functions)
local rotationstuffaaaa = {
	["0,0,0"] = function(datao) return datao end,
	["0,1,0"] = function(datao) return {datao[3],datao[2],datao[1]} end,
	["0,1,1"] = function(datao) return {datao[3],datao[1],datao[2]} end,
	["1,1,0"] = function(datao) return {datao[2],datao[3],datao[1]} end,
	["1,0,0"] = function(datao) return {datao[1],datao[3],datao[2]} end,
	["0,0,1"] = function(datao) return {datao[2],datao[1],datao[3]} end,
}
function Collison.CheckForCollision(P1,S1,O1,P2,S2,O2)
	P1 = reFunction.convertPositionto(P1,"table")
	P2 = reFunction.convertPositionto(P2,"table")
	S1 = reFunction.convertPositionto(S1,"table")
	S2 = reFunction.convertPositionto(S2,"table")
	if O1 then
		O1 = reFunction.convertPositionto(O1,"table")
		local setup = {
			math.abs(O1[1])== 90 and 1 or 0,
			math.abs(O1[2])== 90 and 1 or 0,
			math.abs(O1[3])== 90 and 1 or 0,
		}
		S1 = rotationstuffaaaa[reFunction.convertPositionto(setup,"string")] and rotationstuffaaaa[reFunction.convertPositionto(setup,"string")](S1) or S2
	end
	if O2 then
		O2 = reFunction.convertPositionto(O2,"table")
		local setup = {
			math.abs(O2[1])== 90 and 1 or 0,
			math.abs(O2[2])== 90 and 1 or 0,
			math.abs(O2[3])== 90 and 1 or 0,
		}
		S2 = rotationstuffaaaa[reFunction.convertPositionto(setup,"string")] and rotationstuffaaaa[reFunction.convertPositionto(setup,"string")](S2) or S2
	end
	local xmax = P1[1] + S1[1]*0.5
	local xmin = P1[1] - S1[1]*0.5
	local ymax = P1[2] + S1[2]*0.5
	local ymin = P1[2] - S1[2]*0.5
	local zmax = P1[3] + S1[3]*0.5
	local zmin = P1[3] - S1[3]*0.5
	local xmax2 = P2[1] + S2[1]*0.5
	local xmin2 = P2[1] - S2[1]*0.5
	local ymax2 = P2[2] + S2[2]*0.5
	local ymin2 = P2[2] - S2[2]*0.5
	local zmax2 = P2[3] + S2[3]*0.5
	local zmin2 = P2[3] - S2[3]*0.5
	return(xmin <= xmax2 and xmax >= xmin2) and
		  (ymin <= ymax2 and ymax >= ymin2) and
		  (zmin <= zmax2 and zmax >= zmin2)
end
--[[function Collison.FixVelocity(P1,S1,O1,V1,P2,S2,O2,V2)
    local hx =(P1[1]+(hitboxsize.x*0.5)*(velocity[1]/math.abs(velocity[1]))) 
    local hz = (P1[3]+(hitboxsize.z*0.5)*(velocity[3]/math.abs(velocity[3]))) 
    local hy = (P1[2]+(hitboxsize.y*0.5)*(velocity[2]/math.abs(velocity[2]))) 
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

    for x = sxr, xr,4*(vx/math.abs(vx)) do
        for y = syr, yr,4*(vy/math.abs(vy)) do
            for z = szr, zr,4*(vz/math.abs(vz)) do
                local block,pos = refunction.GetBlock({x,y,z},false)
                if block and refunction.CheckForCollision(entity.Position,{hitboxsize.x,hitboxsize.y,hitboxsize.z},nil,{x,y,z},{4,4,4},nil) then
                    pos = refunction.convertPositionto(pos,"table")
                    if not closestx then
                        closestx = pos
                    end
                    if not closesty then
                        closesty = pos
                    end
                    if not closestz then
                        closestz = pos
                    end
                    if pos[1] < closestx[1] then
                        closestx = pos
                    end
                    if pos[2] < closesty[2] then
                        closesty = pos
                    end
                    if pos[3] < closestz[3] then
                        closestz = pos
                    end
                    --nearbyblocks[pos] = block
                end
            end
        end
    end
end]]
return Collison