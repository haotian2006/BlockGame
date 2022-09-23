local LocalizationService = game:GetService("LocalizationService")
local compresser = require(game.ReplicatedStorage.Compresser)
local SaveInStudio = true
local DataStore 
local MainGameStore 
local allkeys = {}
if SaveInStudio or not game:GetService("RunService"):IsStudio() then
	DataStore = game:GetService("DataStoreService")
	MainGameStore = DataStore:GetDataStore("Test4c3")
	-- local options = Instance.new("DataStoreOptions")
	-- options.AllScopes  = true
	-- local e =DataStore:GetDataStore("Test3","",options)
	-- local pages 
	-- task.spawn(function()
	-- 	local sus,erro = pcall(function()
	-- 		pages = e:ListKeysAsync()
	-- 	end)
	-- 	while sus do
	-- 	local items = pages:GetCurrentPage()
	-- 	local ammount = 0
	-- 	for _, v in ipairs(items) do
	-- 		ammount+=1
	-- 		allkeys[v.KeyName] = true
	-- 	end
	-- 	if pages.IsFinished or ammount ==0 then
	-- 		break
	-- 	end
	-- 	print(items)
	-- 	pages:AdvanceToNextPageAsync()
	-- end
	-- end)

end

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
	ChunkChanges = {},
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
function Data.Compress(key,data)
	return compresser.compress(key,data)
end
function Data.DeCompress(key,data)
	return compresser.decompress(key,data)
end
function Data.GetChunkParent(Chunk)
	local cx,cz = unpack(string.split(Chunk,"x"))
	local x = math.floor(tonumber(cx)/7)
	local z = math.floor(tonumber(cz)/7)
	return x.."|"..z
end
-- function Data.GetChunkParentParent(Chunk)
-- 	local cx,cz = unpack(string.split(Chunk,"|"))
-- 	local x = math.floor(tonumber(cx)/2)
-- 	local z = math.floor(tonumber(cz)/2)
-- 	return x.."/"..z
-- end
-- local x = (tonumber(cx)/2)
-- 	local z = (tonumber(cz)/2)
-- 	x = x <0 and math.ceil(x) or math.floor(x)
-- 	z = z <0 and math.ceil(z) or math.floor(z)
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
	do
		if false then
		return true
		end
	end
	task.spawn(function()
		if  setted[Chunk] then return end
		setted[Chunk] = true
		local cx,cz = unpack(string.split(Chunk,"x"))
		cx = tonumber(cx)
		cz = tonumber(cz)
		local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
		local time = math.clamp(100-20*#game.Players:GetPlayers(),50,100)
		while true do
			if Chunk == "-1x-1" then
				print(time)
			end
			task.wait(1)
			time -= 1
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,10*16*4,"Close")
			if not closestplayer then
				if Chunk == "-1x-1" then
				end
			end
			if closestplayer then
				time = math.clamp(100-90*#game.Players:GetPlayers(),10,100)
			end
			if time <= 0 or not Data.DecodedChunks[Chunk] then
				break
			end
		end
		setted[Chunk] = nil
		if  Data.DecodedChunks[Chunk] then
			Data.ReturnChunk(Chunk,true)
			Data.UpdateEntitysInChunk(Chunk,true)
		end
	end)
end
local oncea = true
function Data.GetChunk(Chunk:string,load:boolean):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	local parent = Data.GetChunkParent(Chunk)
	local partdata
	if Data.ChunkChanges[parent] and Data.ChunkChanges[parent][Chunk] then
		partdata = Data.ChunkChanges[parent][Chunk]
	end
	--Data.Chunk[Data.GetChunkParent(Chunk)] = compresser.decompress(Data.GetChunkParent(Chunk).."x"..Chunk,{})
	if  not Data.Chunk[parent] and not partdata then
		local sdata 
		local sus,errors = pcall(function()
			sdata = MainGameStore:GetAsync("Chunk "..Data.GetChunkParent(Chunk))
		end)
		if not sus then
			sus = pcall(function()
			   sdata = MainGameStore:GetAsync("Chunk "..Data.GetChunkParent(Chunk))
		  	 end)
		end
		Data.Chunk[parent] = sdata
	end
	if Data.Chunk[parent] and not partdata then
		local blocks = compresser.decompress(parent.."|",Data.Chunk[parent])
		Data.ChunkChanges[parent] = Data.ChunkChanges[parent] or {}
		for chunk,v in pairs(blocks) do
			Data.ChunkChanges[parent][chunk] = v
			--print(next(v,"Settings"),chunk)
		end
	end
	local GenHandler = require(game:GetService("ServerStorage").GenerationMutit)
	local data = GenHandler.GetGeneration(Chunk)
	if  not Data.ChunkChanges[parent] or not Data.ChunkChanges[parent][Chunk] or next(Data.ChunkChanges[parent][Chunk]) == nil then
		data["Settings"] = {}
		data["Settings"]["Version"] = 0.1
	else
		for id,value in pairs(Data.ChunkChanges[parent][Chunk])do
			data[id] = value
		end
	end
	Data.DecodedChunks[Chunk] = data
	Data.LoadEntitysInChunk(Chunk)
	Data.SetChunkTimer(Chunk)
	return data
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
		local cx,cz = unpack(string.split(chunk,"x"))
		cx = tonumber(cx)
		cz = tonumber(cz)
		local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
		if Deload  then
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
	local cx,cz = unpack(string.split(chunk,"x"))
		cx = tonumber(cx)
		cz = tonumber(cz)
		local chunckpos = Vector3.new(cx*16*4,"0",cz*16*4)
	if Deload and not refunctions.GetNearByPlayers(chunckpos,5*16*4,"Close") then
		Data.Entitys[parentc] = Data.Entitys[parentc] or {}
		Data.Entitys[parentc][chunk] = newtable	
		Data.DeLoadEntitysInChunk(chunk)
		return Data.Entitys[parentc][chunk] 
	end
	return
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
function Data.DeLoadEntitysInChunk(Chunk:string)
	local parent = Data.GetChunkParent(Chunk)
	for uuid,nbt in pairs(Data.LoadedEntitys)do
		if refunctions.GetChunk(nbt.Position) == Chunk then
			Data.LoadedEntitys[uuid]  = nil
		end
	end
	Data.Entitys[parent][Chunk] = nil
end
function Data.FullyDestroyTable(table:table)
	for k, v in pairs(table) do
		if type(v) == "table" then
			v = deepCopy(v)
			table[k] = nil
		else
			table[k] = nil
		end
	end
	table = nil
end
function Data.ReturnChunk(chunk,destroy)
	local parent = Data.GetChunkParent(chunk)
	if Data.DecodedChunks[chunk] then
		local version = Data.DecodedChunks[chunk]['Settings']["Version"]
		local newstuff = {}
		newstuff['Settings'] = {Version = version}
		for i,v in pairs(Data.DecodedChunks[chunk])do
			if not v[6] then
				newstuff[i] = v
			end
		end
		Data.ChunkChanges[parent] = Data.ChunkChanges[parent] or {}
		Data.ChunkChanges[parent][chunk] = newstuff	
		if destroy then
			Data.DecodedChunks[chunk] = nil
		end
	end
end
function Data.CompressAllChanges(pchunk,fast)
	if pchunk and Data.ChunkChanges[pchunk] then
		local newcompressed = compresser.compress(pchunk.."|a",Data.ChunkChanges[pchunk])
		Data.Chunk[pchunk] = newcompressed
		return
	end
	if fast then
		compresser.slowcomp(Data.ChunkChanges)
		return
	end
	local done,ad,reached = 0,0,false
	for chunk,block in pairs(Data.ChunkChanges)do
		done +=1
		task.spawn(function()
			if Data.ChunkChanges[chunk] then
			local newcompressed = compresser.compress(chunk.."|a",block)
			Data.Chunk[chunk] = newcompressed				
			end
			if next(Data.ChunkChanges,chunk) == nil then
				reached = true
			end
			ad +=1
		end)
	end	
	repeat
		task.wait()
	until (done == ad and reached) or done == 0
end
function Data.SaveAll()
	print("started")
	local starttime = os.time()
	for chunk,block in pairs(Data.DecodedChunks)do
		Data.ReturnChunk(chunk)
	end
	print("stage 1/3 done")
	task.wait(.4)
	Data.CompressAllChanges()
	print("stage 2/3 done")
	local msg,sus
	local done,ad,reached = 0,0,false
	for i,v in pairs(Data.Chunk)do
		done += 1
		task.spawn(function()
			local success, errorMessage = pcall(function()
				MainGameStore:SetAsync("Chunk "..i,v)
			end)
			msg = not success and errorMessage or msg
			sus = not success and success or sus
			if not success then
				local success, errorMessage = pcall(function()
					MainGameStore:SetAsync("Chunk "..i,v)
				end)
			end
			if next(Data.Chunk,i) == nil then
				reached = true
			end
			ad+=1
		end)
		task.wait(0.5)
	end
	repeat
		task.wait()
	until (done == ad and reached) or done == 0
	print("It Took",os.time()- starttime,"Seconds To Save",done,"6x6 group chunks" )
	print("stage 3/3 done",msg,sus)
end
task.spawn(function()
	while true do
		task.wait(100)

	end
end)

end)
return Data