local RS = game:GetService("ReplicatedStorage")
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Texture = RS.Block_Texture
local maindata 
if game:GetService("RunService"):IsServer() then
	maindata = require(game.ServerStorage.MainData)
end
local Function = {}

local function Round(x:number)
	return math.floor(x+0.5)
end
function Function.GetVector3Componnets(pos:Vector3)
	return pos.X,pos.Y,pos.Z
end
function Function.ConvertValuetoablock(value)
	return Round((0 + value)/4)
end
function Function.convertvaluetoreal(value)
	return Round((0 + value)/4)*4
end
function Function.returnDatastringcomponets(data:string)
    local splited = string.split(data,",")
    return splited[1],splited[2],splited[3]
end
function Function.GetMagnituide(pos1:string,pos2:string)
	pos1 = Function.convertPositionto(pos1,"string")
    pos2 = Function.convertPositionto(pos2,"string")
	local x,y,z = Function.returnDatastringcomponets(pos1)
	local x2,y2,z2 = Function.returnDatastringcomponets(pos2)
	return math.sqrt((x2-x)^2+(y2-y)^2+(z2-z)^2)
end
function Function.GetUnit(pos1,pos2)
	pos1 = Function.convertPositionto(pos1,"vector3")
	pos2 = Function.convertPositionto(pos2,"vector3")
	return (pos1-pos2).Unit
end
function Function.GetBlockCoords(Position,retype)
	local Position = Function.convertPositionto(Position,"vector3")
	local x = Round((0 + Position.X)/4)
	local z = Round((0 + Position.Z)/4)
	local y = Round((0 + Position.Y)/4)
	if retype then
		return Function.convertPositionto({x,y,z},retype) 
	end
	return x,y,z
end
function Function.GetChunck(Position:Vector3)
	local x,y,z = Function.GetBlockCoords(Position)
	local cx =	Round(x/16)
	local cz= 	Round(z/16)
	return cx,cz
end
function Function.convertPositionto(cout,etype)
    local ty = typeof(cout)
	ty = string.lower(ty)
	etype = string.lower(etype)
    local x,y,z 
    local ret 
    if ty == "string" then
        local splited = string.split(cout,",")
        x,y,z = unpack(splited)
    elseif ty == "table" then
        x,y,z = unpack(cout)
    elseif ty =="vector3" then
        x,y,z = cout.X,cout.Y,cout.Z
	else
		warn(cout,"is a(n) "..ty.." which is not a valid input")
		etype ="skip"
    end
    if etype == "string" then
        ret = x..","..y..","..z
    elseif etype == "table" then
        ret = {x,y,z}
     elseif etype =="vector3" then
        ret = Vector3.new(x,y,z)
	elseif etype =="skip" then
	 else
		warn(etype,"is not a valid input")
    end
    return ret
end 
function Function.LoadCharacter(Player)
	
end
function Function.ConvertGridToReal(positon,typeofp)
	local converted = Function.convertPositionto(positon,"table")
	return Function.convertPositionto({converted[1]*4,converted[2]*4,converted[3]*4},typeofp)
end
function Function.ConvertPositionToReal(position,typ)
	if typ then
		return Function.ConvertGridToReal(Function.GetBlockCoords(position,"table"),typ)
	end
	return Function.ConvertGridToReal(Function.GetBlockCoords(position,"table"),"table")
end 
function Function.GetSurroundingChunck(Position:Vector3,render:number)
	local cx,cz =  Function.GetChunck(Position)
	local coords ={cx.."x"..cz}
	for i = 1,render,1 do
		local placeholder = {unpack(coords)}
		for index,name in ipairs(placeholder)do
			local c_coords = string.split(name,"x")
			local x,z =tonumber(c_coords[1]),tonumber(c_coords[2])
			if not table.find(coords,(x-1).."x"..z) then table.insert(coords,(x-1).."x"..z) end
			if not table.find(coords,(x+1).."x"..z) then table.insert(coords,(x+1).."x"..z) end
			if not table.find(coords,x.."x"..(z-1)) then table.insert(coords,x.."x"..(z-1)) end
			if not table.find(coords,x.."x"..(z+1)) then table.insert(coords,x.."x"..(z+1)) end
		end
	end
	return coords
end
function Function.XZCoordInChunck(chunck:string)
	local name =string.split(chunck,"x")
	local cx,cz = name[1],name[2]
	local coord0chunckoffset =  Vector3.new(cx*4*16,0,cz*4*16)
	local coord0chunck = Vector3.new(0,0,0) + coord0chunckoffset
	local Cornerx,Cornerz =Vector2.new(-32+cx*64,-32+cz*64) ,Vector2.new(28+cx*64,28+cz*64)
	local pos = {}
	for x = Cornerx.X, Cornerz.X,4 do
		for z = Cornerx.Y,Cornerz.Y,4 do
			table.insert(pos,x.."x"..z)
		end
	end
	return pos
end
function Function.AddPosition(Position,Position2)
	return Function.convertPositionto(Position,"vector3") + Function.convertPositionto(Position2,"vector3")
end
function Function.SubPosition(Position,Position2)
	return Function.convertPositionto(Position,"vector3") - Function.convertPositionto(Position2,"vector3")
end
function Function.PlaceBlock(Name:string,Position,Id:number)
	if typeof(Position) ~= Vector3 then
		local splited = string.split(Position,",")
		Position  = Vector3.new(splited[1],splited[2],splited[3])
	end
	local cx,cz = Function.GetChunck(Position)
	local chunckname = cx.."x"..cz
	local chunckfolder =workspace.Chunk:FindFirstChild(chunckname) or Instance.new("Folder",workspace.Chunk)
	chunckfolder.Name = chunckname
	if Block_Path[Name] then
		local clonedblock = Block_Path[Name].Model:Clone()
		--for i,v in ipairs(Block_Texture:FindFirstChild(Name):GetChildren())do
			--v:Clone().Parent = clonedblock
		--end
		clonedblock.Position = Position
		clonedblock.Parent =chunckfolder
	end
end
local rotationstuffaaaa = {
	["0,0,0"] = function(datao) return datao end,
	["0,1,0"] = function(datao) return {datao[3],datao[2],datao[1]} end,
	["0,1,1"] = function(datao) return {datao[3],datao[1],datao[2]} end,
	["1,1,0"] = function(datao) return {datao[2],datao[3],datao[1]} end,
	["1,0,0"] = function(datao) return {datao[1],datao[3],datao[2]} end,
	["0,0,1"] = function(datao) return {datao[2],datao[1],datao[3]} end,
}
function Function.CheckForCollision(P1,S1,O1,P2,S2,O2,printa)
	P1 = Function.convertPositionto(P1,"table")
	P2 = Function.convertPositionto(P2,"table")
	S1 = Function.convertPositionto(S1,"table")
	S2 = Function.convertPositionto(S2,"table")
	if O1 then
		O1 = Function.convertPositionto(O1,"table")
		local setup = {
			math.abs(O1[1])== 90 and 1 or 0,
			math.abs(O1[2])== 90 and 1 or 0,
			math.abs(O1[3])== 90 and 1 or 0,
		}
		S1 = rotationstuffaaaa[Function.convertPositionto(setup,"string")] and rotationstuffaaaa[Function.convertPositionto(setup,"string")](S1) or S2
	end
	if O2 then
		O2 = Function.convertPositionto(O2,"table")
		local setup = {
			math.abs(O2[1])== 90 and 1 or 0,
			math.abs(O2[2])== 90 and 1 or 0,
			math.abs(O2[3])== 90 and 1 or 0,
		}
		S2 = rotationstuffaaaa[Function.convertPositionto(setup,"string")] and rotationstuffaaaa[Function.convertPositionto(setup,"string")](S2) or S2
	end
	 --print(P1[2])
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
	--print(ymin, ymax2 , ymax >= ymin2)
	--print(xmax2,xmin2,ymax2,ymin2,zmax2,zmin2)
	local p1Max = Vector3.new(P1[1]+S1[1],P1[2]+S1[2],P1[3]+S1[3])
	local p1Min = Vector3.new(P1[1],P1[2],P1[3])
	local p2Max = Vector3.new(P2[1]+S2[1],P2[2]+S2[2],P2[3]+S2[3])
	local p2Min = Vector3.new(P2[1],P2[2],P2[3])
	if printa then
		print(zmin <= zmax2 , zmax >= zmin2)
		--print(P2)
		-- print(p1Max)
		-- print(p1Min)
		-- print(p2Min)
		
	end
	-- return p2Max.X > p1Min.X and p2Min.X < p1Max.X and
	-- 	   p2Max.Y > p1Min.Y and p2Min.Y < p1Max.Y and
	-- 	   p2Max.Z > p1Min.Z and p2Min.Z < p1Max.Z
		--print(zmin , zmax2 , zmax , zmin2)
	return(xmin <= xmax2 and xmax >= xmin2) and
		  (ymin <= ymax2 and ymax >= ymin2) and
		  (zmin <= zmax2 and zmax >= zmin2)
end
--<Server_functions>
if maindata then 
function Function.GetFloor(pos,CanBeTransParent)
	pos = Function.convertPositionto(pos,"vector3")

	local x,y,z = Function.returnDatastringcomponets(Function.ConvertGridToReal({Function.GetBlockCoords(pos)},"string"))
	local cx,cz = Function.GetChunck(Vector3.new(pos.X,0,pos.Z))
	--print(x,y,z,cx,cz)
	for i = y , 0,-1 do
		if maindata.Chunck[cx.."x"..cz] and maindata.Chunck[cx.."x"..cz][x..","..i..","..z] then
			return Vector3.new(x,i,z)
		end
	end
	return nil
end
function Function.GetBlock(pos,HasToBeLoaded)

	pos = Function.convertPositionto(pos,"vector3")
	local x,y,z = Function.returnDatastringcomponets(Function.ConvertGridToReal(Function.GetBlockCoords(pos,"table"),"string"))
	local cx,cz = Function.GetChunck(Vector3.new(pos.X,y,pos.Z))
	if maindata.Chunck[cx.."x"..cz] and maindata.Chunck[cx.."x"..cz][x..","..y..","..z] and not HasToBeLoaded then
		return maindata.Chunck[cx.."x"..cz][x..","..y..","..z],x..","..y..","..z
	elseif maindata.LoadedBlocks[x..","..y..","..z]  and HasToBeLoaded then
		return maindata.LoadedBlocks[x..","..y..","..z],x..","..y..","..z
	end
	return nil
end
function Function.RayCast(StartingPosition,Direaction)
	local StartingPosition,Direaction = Function.convertPositionto(StartingPosition,"table"),Function.convertPositionto(Direaction,"table")
	local curentdireaction = {0,0,0}
	local pos  = StartingPosition
	while true do
		local added = 0
		if curentdireaction[1] < Direaction[1] then
			curentdireaction[1] += 0.1
			added +=1
		end
		if curentdireaction[2] < Direaction[2] then
			curentdireaction[2] += 0.1
			added +=1
		end
		if curentdireaction[3] < Direaction[3] then
			curentdireaction[3] += 0.1
			added +=1
		end
		pos = Function.AddPosition(curentdireaction,pos)
		if Function.GetBlock(pos) then
			return Function.GetBlock(pos)
		end
		if added == 0 then break end
	end
	return nil
end












end
return Function
