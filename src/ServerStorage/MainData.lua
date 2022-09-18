local compresser = require(game.ReplicatedStorage.Compresser)
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
task.spawn(function()
	local refunctions = Data.refunctions
	repeat
		refunctions = Data.refunctions
		task.wait(0.1)
	until refunctions
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
	local cx,cz = unpack(string.split(Chunk,"x"))
	local x = math.floor(tonumber(cx)/200)
	local z = math.floor(tonumber(cz)/200)
	return x.."-"..z
end
function Data.CompressAllDC()
	for c,d in pairs(dc) do
		local newcompressed = compresser.compress(c,dc[c])
		Data.Chunk[Data.GetChunkParent(c)][c] = newcompressed
		dc[c] = nil
	end
end
local setted = {}
local ab = true
function  Data.SetChunkTimer(Chunk)
	task.spawn(function()
		if  setted[Chunk] then return end
		setted[Chunk] = true
		local cx,cz = unpack(string.split(Chunk,"x"))
		cx = tonumber(cx)
		cz = tonumber(cz)
		local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
		local time = math.clamp(100-30*#game.Players:GetPlayers(),50,100)
		while true do
			if Chunk == "-1x-1" then
				print(time)
			end
			task.wait(1)
			time -= 1
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,5*16*4,"Close")
			if not closestplayer then
				if Chunk == "-1x-1" then
				end
			end
			if closestplayer then
				time = math.clamp(100-100*#game.Players:GetPlayers(),5,100)
			end
			if time <= 0 or not Data.DecodedChunks[Chunk] then
				break
			end
		end
		setted[Chunk] = nil
		if  Data.DecodedChunks[Chunk] then
			Data.UpdateChunk(Chunk,true)
			Data.UpdateEntitysInChunk(Chunk,true)
		end
	end)
end
function Data.GetChunk(Chunk:string):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	if not Data.Chunk[Data.GetChunkParent(Chunk)] or not Data.Chunk[Data.GetChunkParent(Chunk)][Chunk] then
		return nil
	end
	local data = Data.Chunk[Data.GetChunkParent(Chunk)][Chunk]
	data = compresser.decompress(Chunk,data)
	dc[Chunk] = data
	Data.LoadEntitysInChunk(Chunk)
	Data.SetChunkTimer(Chunk)
	return dc[Chunk]
end
function Data.PlaceChunk(chunk:string,data,deload)
		if Data.DecodedChunks[chunk] then
			Data.DecodedChunks[chunk] = data
			return
		end
		Data.DecodedChunks[chunk] = data
		Data.SetChunkTimer(chunk)
		data = compresser.compress(chunk,data)
		local parenta = Data.GetChunkParent(chunk)
		Data.Chunk[parenta] = Data.Chunk[parenta] or {}
		Data.Chunk[parenta][chunk] = data
	return
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
	data = compresser.compress(uuid,data)
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
	data = compresser.rcompress(data)
	local parenta = Data.GetChunkParent(chunk)
	Data.Chunk[parenta][chunk] = data
end
function Data.UpdateChunk(chunk:string,Deload:boolean)
	local parentc = Data.GetChunkParent(chunk)
	if Data.DecodedChunks[chunk] then
		local data = compresser.compress(chunk,Data.DecodedChunks[chunk])
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
	for uuid,nbt in pairs(Data.LoadedEntitys)do
			local x,y = nbt.Position and refunctions.GetChunk(nbt.Position) or 0,0
			if nbt["IsPlayer"] then continue end
			if x..","..y == chunk then
				newtable[uuid] = nbt
			end
	end
	local parentc = Data.GetChunkParent(chunk)
	compresser.compress(chunk,newtable)
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
			for uuid,nbt in pairs(Data.Entitys[parent][Chunk])do
				local decodeddata = compresser.decompress(uuid,nbt)
				Data.LoadedEntitys[uuid] = decodeddata
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
end)
return Data