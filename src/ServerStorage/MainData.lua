local compresser = require(game.ReplicatedStorage.Compresser)
local refunctions = game.ReplicatedStorage.GetFunctions:Invoke()
local https = game:GetService("HttpService")
local Data = {
    ["Chunk"] ={
	--[[
		["1-1"]={
			["0x0"] = {"Stone",1,{0,90,0},{0,0,0},"0x0",false}--(name,State,rotation,Position,Chunk,IsNatural)
		}
	]]
	},
	["Players"] ={
	--[[	
		["Haotian2006"]= { 
			["Name"] = "Example",
			["Age"] = "0",
			["Position"] = {},
			["IsChild"] = false,
		}]]		
	},
	["Entitys"] ={
	--[[	
	["1-1"]= {
		[0x0] = {
			["190-099-3210"] ={ -- a uuid
			["Name"] = "Example",
			["Age"] = "0",
			["Position"] = {},
			["IsChild"] = false,
			}	
		}
		}

	]]
		
	},
	["LoadedEntitys"] ={},
	DecodedChunks = {}
}
local dc = Data["DecodedChunks"]
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
function Data.GetChunkParent(Chunk)
	local cx,cz = string.split(Chunk,"x")
	local x = math.floor(tonumber(cx)/200)
	local z = math.floor(tonumber(cz)/200)
	return x.."-"..z
end
function Data.CompressAllDC()
	for c,d in pairs(dc) do
		local newcompressed = compresser.compress(dc[c])
		Data.Chunk[Data.GetChunkParent(c)][c] = newcompressed
		dc[c] = nil
	end
end
function Data.GetChunk(Chunk:string):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	if not Data.Chunk[Data.GetChunkParent(Chunk)] or not Data.Chunk[Data.GetChunkParent(Chunk)][Chunk] then
		return nil
	end
	local data = compresser.decompress(Data.Chunk[Data.GetChunkParent(Chunk)][Chunk])
	dc[Chunk] = data
	local cx,cz = string.split(Chunk,"x")
	cx = tonumber(cx)
	cz = tonumber(cz)
	local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
	Data.LoadEntitysInChunk(Chunk)
	task.spawn(function()	
		local time = math.clamp(100-10*#game.Players:GetPlayers(),50,100)
		while true do
			task.wait(1)
			time -= 1
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,"Close",10*16*4)
			if closestplayer then
				time = math.clamp(100-10*#game.Players:GetPlayers(),50,100)
			end
			if time <= 0 then
				break
			end
		end
		Data.UpdateChunk(Chunk,true)
		Data.UpdateEntitysInChunk(Chunk,true)
	end)
	return dc[Chunk]
end
function Data.PlaceChunk(chunk:string,data)
	if Data.DecodedChunks[chunk] then
		Data.DecodedChunks[chunk] = data
		return
	end
	data = https:JSONEncode(data)
	data = compresser.compress(data)
	local parenta = Data.GetChunkParent(chunk)
	Data.Chunk[parenta][chunk] = data
end
function Data.PlaceEntity(uuid:string,data,Deload)
	local Coord = data.Position or Vector3.new(0,0,0)
	Coord = refunctions.convertPositionto(Coord,"string")
	local cx,cz = refunctions.GetChunk(Coord)
	local chunk = cx..","..cz
	if not Deload and(Data.LoadedEntitys[uuid] or Data.DecodedChunks[chunk]) then
		Data.LoadedEntitys[uuid] = data
		return
	end
	if Deload then
		 Data.Entitys.LoadedEntitys[uuid] = nil
	end
	data = https:JSONEncode(data)
	data = compresser.compress(data)
	local parenta = Data.GetChunkParent(chunk)
	Data.Entitys[parenta][chunk][uuid] = data
end
function Data.PlaceBlock(Coord,data)
	Coord = refunctions.convertPositionto(Coord,"string")
	local cx,cz = refunctions.GetChunk(Coord)
	local chunk = cx..","..cz
	if Data.DecodedChunks[chunk] then
		Data.DecodedChunks[chunk][Coord] = data
		return
	end
	local data = Data.GetChunk(cx..","..cz)
	data[Coord] = data
	data = https:JSONEncode(data)
	data = compresser.compress(data)
	local parenta = Data.GetChunkParent(chunk)
	Data.Chunk[parenta][chunk] = data
end
function Data.UpdateChunk(chunk:string,Deload:boolean)
	local parentc = Data.GetChunkParent(chunk)
	if Data.DecodedChunks[chunk] then
		local data = https:JSONEncode(Data.DecodedChunks[chunk])
		data = compresser.compress(data)
		Data.Chunk[parentc] = Data.Chunk[parentc] or {}
		Data.Chunk[parentc][chunk] = data
		if Deload then
			Data.DecodedChunks[chunk] = nil
		end
		return 	Data.Chunk[parentc][chunk]
	end
	return nil
end

function Data.UpdateEntitysInChunk(chunk,Deload:boolean)
	local newtable = {}
	if not Data.LoadedEntitys[chunk] then return end
	for uuid,nbt in pairs(Data.LoadedEntitys)do
			local x,y = nbt.Position and refunctions.GetChunk(nbt.Position) or 0,0
			if x..","..y == chunk then
				newtable[uuid] = nbt
			end
	end
	local parentc = Data.GetChunkParent(chunk)
	compresser.compress(https:JSONEncode(newtable))
	if not Deload then
		return newtable
	end
	Data.Entitys[parentc] = Data.Entitys[parentc] or {}
	Data.Entitys[parentc][chunk] = newtable	
	return Data.Entitys[parentc][chunk] 
end
function Data.LoadEntitysInChunk(Chunk:string)
	local parent = Data.GetChunkParent(Chunk)
	if Data.Entitys[parent]then
		if Data.Entitys[parent][Chunk] then
			local decodeddata = compresser.decompress(Data.Entitys[parent][Chunk])
			decodeddata = https.JSONDecode(decodeddata)
			for uuid,nbt in pairs(decodeddata)do
				Data.LoadedEntitys[uuid] = deepCopy(nbt)
			end
			Data.Entitys[parent][Chunk] = nil
		end
	end
end
function Data.SaveAll()
	
end
task.spawn(function()
	while true do
		task.wait(100)

	end
end)
return Data