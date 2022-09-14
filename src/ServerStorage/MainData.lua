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
Data.Func = {}
local dc = Data["DecodedChunks"]
local func = Data.Func
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
function func.GetChunkParent(Chunk)
	local cx,cz = string.split(Chunk,"x")
	local x = math.floor(tonumber(cx)/200)
	local z = math.floor(tonumber(cz)/200)
	return x.."-"..z
end
function func.CompressAllDC()
	for c,d in pairs(dc) do
		local newcompressed = compresser.compress(dc[c])
		Data.Chunk[func.GetChunkParent(c)][c] = newcompressed
		dc[c] = nil
	end
end
function func.GetChunk(Chunk:string):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	if not Data.Chunk[func.GetChunkParent(Chunk)] or not Data.Chunk[func.GetChunkParent(Chunk)][Chunk] then
		return {}
	end
	local data = compresser.decompress(Data.Chunk[func.GetChunkParent(Chunk)][Chunk])
	dc[Chunk] = data
	local cx,cz = string.split(Chunk,"x")
	cx = tonumber(cx)
	cz = tonumber(cz)
	local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
	task.spawn(function()	
		local time = 60
		while true do
			task.wait(1)
			time -= 1
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,"Close",10*16*4)
			if closestplayer then
				time = 60
			end
			if time <= 0 then
				break
			end
		end
		local newcompressed = compresser.compress(dc[Chunk])
		Data.Chunk[func.GetChunkParent(Chunk)][Chunk] = newcompressed
		dc[Chunk] = nil
	end)
	return dc[Chunk]
end
function func.DeloadChunk(chunk,IsASave)
	
end
function func.DeLoadEntitysInChunk(chunk,IsASave)
	local newtable = {}
	for uuid,nbt in pairs(Data.LoadedEntitys)do
			local x,y = nbt.Position and refunctions.GetChunk(nbt.Position) or 0,0
			if x..","..y == chunk then
				newtable[uuid] = nbt
			end
	end
	local parentc = func.GetChunkParent(chunk)
	compresser.compress(https:JSONEncode(newtable))
	if IsASave then
		return newtable
	end
	Data.Entitys[parentc] = Data.Entitys[parentc] or {}
	Data.Entitys[parentc][chunk] = newtable	
end
function func.LoadEntitysInChunk(Chunk:string)
	local parent = func.GetChunkParent(Chunk)
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
function func.SaveAll()
	
end
task.spawn(function()
	while true do
		task.wait(60)

	end
end)
return Data