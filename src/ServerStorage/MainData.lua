local compresser = require(game.ReplicatedStorage.Compresser)
local refunctions = game.ReplicatedStorage.GetFunctions:Invoke()
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
local fuc = Data.Func
function fuc.GetChunkParent(Chunk)
	local cx,cz = string.split(Chunk,"x")
	local x = math.floor(tonumber(cx)/200)
	local z = math.floor(tonumber(cz)/200)
	return x.."-"..z
end
function fuc.CompressAllDC()
	for c,d in pairs(dc) do
		local newcompressed = compresser.compress(dc[c])
		Data.Chunk[fuc.GetChunkParent(c)][c] = newcompressed
		dc[c] = nil
	end
end
function fuc.GetChunk(Chunk:string):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	if not Data.Chunk[fuc.GetChunkParent(Chunk)] or not Data.Chunk[fuc.GetChunkParent(Chunk)][Chunk] then
		return {}
	end
	local data = compresser.decompress(Data.Chunk[fuc.GetChunkParent(Chunk)][Chunk])
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
		Data.Chunk[fuc.GetChunkParent(Chunk)][Chunk] = newcompressed
		dc[Chunk] = nil
	end)
	return dc[Chunk]
end
function fuc.LoadEntitys(Chunk:string)
	local parent = fuc.GetChunkParent(Chunk)
	if Data.Entitys[parent] and Data.Entitys[Chunk] then
		local decodeddata = compresser.decompress(Data.Entitys[Chunk])
	end
end
return Data