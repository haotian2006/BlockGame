local LocalizationService = game:GetService("LocalizationService")
local compresser = require(game.ReplicatedStorage.Compresser)
local SaveInStudio = true
local DataStore 
local MainGameStore 
local allkeys = {}
if SaveInStudio or not game:GetService("RunService"):IsStudio() then
	DataStore = game:GetService("DataStoreService")
	MainGameStore = DataStore:GetDataStore("Test45")
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
	local x = math.floor(tonumber(cx)/6)
	local z = math.floor(tonumber(cz)/6)
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
		if true then
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
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,5*16*4,"Close")
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
			Data.UpdateChunk(Chunk,true)
			Data.UpdateEntitysInChunk(Chunk,true)
		end
	end)
end
local oncea = true
function Data.GetChunk(Chunk:string):table
	if dc[Chunk] then
		return dc[Chunk]
	end
	if not allkeys[Data.GetChunkParent(Chunk)]  and not Data.Chunk[Data.GetChunkParent(Chunk)] then
		if compresser.CheckInQd(Data.GetChunkParent(Chunk).."x"..Chunk)then
			print("c")
			Data.Chunk[Data.GetChunkParent(Chunk)] = compresser.decompress(Data.GetChunkParent(Chunk).."x"..Chunk,{})
		else
		local sdata 
		local sus,errors = pcall(function()
			sdata = MainGameStore:GetAsync("Chunk "..Data.GetChunkParent(Chunk))
		end)
		if not sus then
			sus = pcall(function()
			   sdata = MainGameStore:GetAsync("Chunk "..Data.GetChunkParent(Chunk))
		   end)
	   end
		if not sus then
			print(errors)
		else
			allkeys[Data.GetChunkParent(Chunk)] = true
			if sdata == nil then
				print("a")
			else
				if oncea then
				--print(sdata)
				oncea = false
				end
			Data.Chunk[Data.GetChunkParent(Chunk)] = compresser.decompress(Data.GetChunkParent(Chunk).."x"..Chunk,sdata)
			print("e")
			end
			end
		end
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
function Data.SaveAll()
	print("started")
	local tocompress = deepCopy(Data.Chunk)
	local placehold = compresser.slowcomp(Data.DecodedChunks)
	print("stage 0 done")
	for i,v in pairs(placehold)do
		task.spawn(function()
			local cx,cz = unpack(string.split(i,"x"))
			cx = tonumber(cx)
			cz = tonumber(cz)
			local chunckpos = Vector3.new(cx*16*4,0,cz*16*4)
			local closestplayer = refunctions.GetNearByPlayers(chunckpos,15*16*4,"Close")
			if not closestplayer then
				task.spawn(function()
					Data.UpdateChunk(i,true)
				end)
			end
		end)
		tocompress[Data.GetChunkParent(i)]  = tocompress[Data.GetChunkParent(i)]  or {}
		tocompress[Data.GetChunkParent(i)][i] = v
	end
	print("stage 1 done")
	tocompress = compresser.slowcomp(tocompress,true)
	print("stage 2 done")
	local msg,sus
	for i,v in pairs(tocompress)do
		task.spawn(function()
			
			local ccx,ccz = unpack(string.split(i,"|"))
			ccx = tonumber(ccx)*6
			ccz = tonumber(ccz)*6
			local pos = Vector3.new(ccx*16*4,0,ccz*16*4)
			local closestplayer = refunctions.GetNearByPlayers(pos,45*16*4,"Close")
			if not closestplayer then
				Data.Chunk[i] = nil
			end
		end)
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
		task.wait(0.5)
	end
	print("stage 3 done",msg,sus)
end
task.spawn(function()
	while true do
		task.wait(100)

	end
end)

end)
return Data