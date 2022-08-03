local RS = game:GetService("ReplicatedStorage")
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Texture = RS.Block_Texture

local Function = {}

local function Round(x:number)
	return math.floor(x+0.5)
end
function Function.GetVector3Componnets(pos:Vector3)
	return pos.X,pos.Y,pos.Z
end
function Function.GetBlockCoords(Position:Vector3)
	local x = Round((0 + Position.X)/4)
	local z = Round((0 + Position.Z)/4)
	local y = Round((0 + Position.Y)/4)
	return x,y,z
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
function Function.GetChunck(Position:Vector3)
	local x,z = Function.GetBlockCoords(Position)
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
		warn(cout.." is a(n) "..ty.." which is not a valid input")
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
		warn(etype.." is not a valid input")
    end
    return ret
end 
function Function.LoadCharacter(Player)
	
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

return Function
