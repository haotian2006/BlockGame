local ProximityPromptService = game:GetService("ProximityPromptService")
local Data = {Chunk = {},update = {}}
local ChunkObj = require(game.ReplicatedStorage.ChunkObj)
local refunctions = {}
local function Round(x:number)
	local m = x/math.abs(x)
	--x = math.abs(x)
	return math.floor(x+0.5)
end
do
    function refunctions.convertPositionto(cout,etype)
	etype = etype or "string"
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
    elseif ty =="vector3" or ty =="cframe" then
        x,y,z = cout.X,cout.Y,cout.Z
	else
		warn(cout,"is a(n) "..ty.." which is not a valid input")
		etype ="skip"
    end
	x,y,z = tonumber(x),tonumber(y),tonumber(z)
    if etype == "string" then
        ret = x..","..y..","..z
    elseif etype == "table" then
        ret = {x,y,z}
     elseif etype =="vector3" then
        ret = Vector3.new(x,y,z)
	elseif etype =="cframe" then
		ret = CFrame.new(x,y,z)
	elseif etype == "tuple" then
		return x,y,z
	elseif etype =="skip" then
	 else
		warn(etype,"is not a valid input")
    end
    return ret
end 
function refunctions.GetBlockCoords(Position,retype)
	local Position = refunctions.convertPositionto(Position,"vector3")
	local x = Round((0 + Position.X)*0.25)
	local z = Round((0 + Position.Z)*0.25)
	local y = Round((0 + Position.Y)*0.25)
	if retype then
		return refunctions.convertPositionto({x,y,z},retype) 
	end
	return x,y,z
end
function refunctions.GetChunk(Position,converttostring)
	Position = refunctions.convertPositionto(Position,"vector3")
	local x,y,z = refunctions.GetBlockCoords(Position)
	local cx =	Round(x*0.0625)
	local cz= 	Round(z*0.0625)
	if converttostring then
		return cx.."x"..cz
	end
	return cx,cz
end
end
local blockinfo = require(game.ReplicatedStorage.BlockInfo)
function Data.Generate(cx,cz)
    
end
function Data.GetChunk(cx,cz)
    Data.Chunk[cx] = Data.Chunk[cx] or {}
    Data.Chunk[cx][cz] = Data.Chunk[cx][cz]
    if not Data.Chunk[cx][cz] then
        
    end
    return Data.Chunk[cx][cz]
end
function Data.InsertChunk(cx,cz,data)
    Data.Chunk[cx] = Data.Chunk[cx] or {}
    Data.Chunk[cx][cz] = {ChunkObj.new(cx,cz,data[1]),data[2]}
    return Data.Chunk[cx][cz]
end
function Data.DestroyChunk(cx,cz)
    Data.Chunk[cx] = Data.Chunk[cx] or {}
    local ch = Data.Chunk[cx][cz]
    if ch then
        ch[1]:Destroy()
        Data.Chunk[cx][cz] = nil
    end
end
function Data.IsTransparent(x,y,z,ch)
    if x and not tonumber(z) then
        x,y,z,ch = x[1],x[2],x[3],y
    end
    local block = Data.GetBlock(x,y,z,ch)
    if block then
        if blockinfo[block[1]] then
            return blockinfo[block[1]]["IsTransparent"]
        end
    end
    return
end
function Data.IsAir(x,y,z,ch)
    if x and not tonumber(z) then
        x,y,z,ch = x[1],x[2],x[3],y
    end
    local block = Data.GetBlock(x,y,z,ch)
    if block then
        return block[1] == "Air"
    end
    return
end
function Data.GetBlock(x,y,z,chunk)
    if x and not tonumber(z) then
        x,y,z,chunk = x[1],x[2],x[3],y
    end
    local cd = chunk
    local chunk = chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z}))
    if chunk then
        
        return chunk[1]:GetBlock(x,y,z)
    end
end
function Data.InsertBlock(x,y,z,data,chunk)
    if x and not tonumber(z) then
        x,y,z,data,chunk = x[1],x[2],x[3],y,z
    end
    Data.InsertChunk(chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z})))
    local chunk = chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z}))
    if chunk then
        chunk[1]:InsertBlock(x,y,z,data)
    end
end
return Data