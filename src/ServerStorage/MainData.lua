local LocalizationService = game:GetService("LocalizationService")
local compresser = require(game.ReplicatedStorage.Compresser)
local blockinfo = require(game.ReplicatedStorage.BlockInfo)
local SaveInStudio = false
local DataStore 
local MainGameStore 
local allkeys = {}
if SaveInStudio or not game:GetService("RunService"):IsStudio() then
	DataStore = game:GetService("DataStoreService")
	MainGameStore = DataStore:GetDataStore("c")
end
local exsisting = {}
if MainGameStore then
	local data
	local sus = pcall(function()
		data = MainGameStore:GetAsync("IfChunkE")
	end)
	if sus and data then
		allkeys = compresser.decompress("IfChunkE",data)
	end
end
local https = game:GetService("HttpService")
-- BlockLayout = {"Stone",1,{0,90,0},{0,0,0},{cx,cy},false,{},}--(name,State,rotation,Position,Chunk,IsNatural,nbt)
local Data = {
    ["Chunk"] ={
		
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
	ChunkChanges = {},
	["LoadedEntitys"] ={},
	DecodedChunks = {}
}
task.spawn(function()
	local refunctions = Data.refunctions
	repeat
		refunctions = Data.refunctions
		task.wait()
	until refunctions
	function Data.GetChunk(cx,cz)
		Data.DecodedChunks[cx] = Data.DecodedChunks[cx] or {}
		return Data.DecodedChunks[cx][cz]
	end
	function Data.InsertChunk(cx,cz,data)
		Data.DecodedChunks[cx] = Data.DecodedChunks[cx] or {}
		Data.DecodedChunks[cx][cz] = data or Data.DecodedChunks[cx][cz] or {}
		return Data.DecodedChunks[cx][cz]
	end
	function Data.IsTransparent(x,y,z,ch)
		local block = Data.GetBlock(x,y,z,ch)
		if block then
			if blockinfo[block[1]] then
				return blockinfo[block[1]]["IsTransparent"]
			end
		end
		return
	end
	function Data.IsAir(x,y,z,ch)
		local block = Data.GetBlock(x,y,z,ch)
		if block then
			return block[1] == "Air"
		end
		return
	end
	function Data.GetBlock(x,y,z,chunk)
		local chunk = chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z}))
		if chunk and chunk[x] and chunk[x][y] then
			return chunk[x][y][z]
		end
	end
	function Data.InsertBlock(x,y,z,data,chunk)
		Data.InsertChunk(chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z})))
		local chunk = chunk and Data.GetChunk(unpack(chunk)) or Data.GetChunk(refunctions.GetChunk({x,y,z}))
		if chunk then
			chunk[x] = chunk[x] or {}
			chunk[x][y] = chunk[x][y] or {}
			chunk[x][y][z] = data or {} 
		end
	end
end)
return Data