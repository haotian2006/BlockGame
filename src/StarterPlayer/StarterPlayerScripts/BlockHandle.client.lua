
local HttpService = game:GetService("HttpService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RS = game:GetService("ReplicatedStorage")
local refunction = require(RS.Functions)
local Block_Textures = RS.Block_Texture
local Block_Info = require(RS.BlockInfo)
local events = RS.Events
local lp = game.Players.LocalPlayer
local render = 5
game.Lighting.FogStart = render*4*16
game.Lighting.FogEnd = render*4*16*1.5
local debug = require(game.ReplicatedStorage.Debughandler)
local workthingyt = require(game.ReplicatedStorage.WorkerThreads)
local storedchunk = require(script.Parent:WaitForChild("ChunksToBeLoaded"))
local loadthread = workthingyt.New(script.Parent:WaitForChild("ChunksToBeLoaded"),"LoadChunk",100)
local compressor = require(game.ReplicatedStorage.Compresser)
local function WaitForDescendant(descendantOf, str)
	assert(typeof(descendantOf) == "Instance", "Invalid type for argument 1 (descendatOf)")
	assert(typeof(str) == "string", "Invalid type for argument 2 (str)")
	
	if descendantOf:FindFirstChild(str, true) then
		return descendantOf:FindFirstChild(str, true)
	else
		local t = {tick(), false}

		repeat
			if not t[2] and tick() - t[1] > 10 then 
				warn("Infinite yield possible on "..tostring(descendantOf)..":WaitForDescendant("..str..")")
				t[2] = true
			end
			
			descendantOf.DescendantAdded:Wait()
		until descendantOf:FindFirstChild(str, true)
		
		return descendantOf:FindFirstChild(str, true)
	end
end
local function getpart(name)
	local part
	local ismodel = false
	local model = Block_Info[name].Model
	if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
	  part = model.MainPart:Clone()
	  ismodel = true
	elseif not model:IsA("Model") then
	  part = Block_Info[name].Model:Clone()
	end
	return part,ismodel
	end
local function pack(x,y,z)
	return x..","..y..","..z
end
local function GetPosition(Table)
	local Position ={}
	for chunk,DATA in pairs(Table) do
		if game.Workspace.Chunk:FindFirstChild(chunk) then
		continue
		end
		for block,blockdata in pairs(DATA) do
			for i,v in pairs(blockdata.Position) do
				if not Block_Info[block]["IsTransparent"] then
					local x,y,z = unpack(v)
					Position[x..","..y..","..z] =  block
				end
			end
		end
	end
	return Position
end
local function can(position,tabl,player)
	--[[local c = false
	local splittedstring = string.split(position,",")
	local x,y,z = splittedstring[1],splittedstring[2],splittedstring[3]
	if tabl[pack(x+4,y,z)] and tabl[pack(x+4,y,z)][4] and  tabl[pack(x-4,y,z)] and  tabl[pack(x-4,y,z)][4]  and tabl[pack(x,y+4,z)]and  tabl[pack(x,y+4,z)][4] and tabl[pack(x,y-4,z)] and tabl[pack(x,y-4,z)][4]  and  tabl[pack(x,y,z-4)] and  tabl[pack(x,y,z-4)][4] and  tabl[pack(x,y,z+4)] and tabl[pack(x,y,z+4)][4] --[[and math.abs(player -y) <=16*(render) then
	else
		c = true
	end]]
	return true
end
local old
local firsttime = false
local function sortchunk(TAB,POS)
	local chunkst ={}
	local cx,cz = refunction.GetChunk(POS or game.Workspace.Entity:FindFirstChild(lp.Name).PrimaryPart.Position)
	local currentvec = Vector2.new(cx,cz)
	for incex,chunk in ipairs(TAB) do
		local chunkx = string.split(chunk,"x")
		chunkx = chunkx[1]
		local chunkz = chunkx[2]
		local cvector = Vector2.new(chunkx,chunkz)
		local mag = (cvector - currentvec).Magnitude
		table.insert(chunkst,{chunk,mag})
	end
	 table.sort(chunkst,function(a,b)
		return a[2] < b[2]
	end)
	return chunkst
end
local function removechunk(chunk)
	task.spawn(function()
		for i,v in pairs(chunk:GetChildren()) do
			if i%100 == 0 and firsttime then
				task.wait(0.01)
			end
			v:Destroy()
		end
		chunk:Destroy()
	end)
end
local function QuickRender(char)

		local renderedchunks ={}
		for i,v in ipairs(workspace.Chunk:GetChildren())do
			local splited = v.Name:split("x")
			local vector = Vector2.new(splited[1],splited[2])
			local currentvecotr = Vector2.new(refunction.GetChunk(char.Position))
			if (vector-currentvecotr).Magnitude > (render+3) then
				v.Parent = nil
				storedchunk[v.Name] = v
			else
				renderedchunks[v.Name] = true
				end
		end
		local nearbychunks = (refunction.GetSurroundingChunk(char.Position,render))
		local newchunks = {}
		local thread = coroutine.running()
		local threadsdone = 0
		local done = false
		for i,chunk in ipairs(nearbychunks)do
			chunk = chunk
			if storedchunk[chunk] then
				table.insert(newchunks,storedchunk[chunk])
				threadsdone+=1
				--print(threadsdone , #nearbychunks)
				if threadsdone == #nearbychunks then
					coroutine.resume(thread)
					done = true
				end
				continue
			end
			if renderedchunks[chunk] then 
				threadsdone+=1 
				--print(threadsdone , #nearbychunks)
			if threadsdone == #nearbychunks then
				coroutine.resume(thread)
				done = true
			end
			continue end
			task.spawn(function()
		local Blocks = events.Block.GetChunk:InvokeServer(chunk,firsttime)
		local index = 0
			local blocktable = loadthread:DoWork(Blocks)
			local Folder = Instance.new("Folder")
			Folder.Name = chunk
			for i,v in ipairs(blocktable)do
				v[1].CFrame = v[2]
				v[1].Parent = Folder
				v[1]:SetAttribute("Name",v[3])
				v[1]:SetAttribute("State",v[4])
				v[1].Anchored = true
				v[1].Size = v[5]
				v[1].Name = refunction.convertPositionto(v[6],"string")
				
			end
			table.insert(newchunks,Folder)
			threadsdone+=1
			--print(threadsdone , #nearbychunks)
			if threadsdone == #nearbychunks then
				coroutine.resume(thread)
				done = true
			end
		end)
		if threadsdone == #nearbychunks then
			coroutine.resume(thread)
			done = true
		end
		end
		if not done then 
			coroutine.yield()
		end
		for i,v in ipairs(newchunks)do
			v.Parent = workspace.Chunk
			v = nil
		end
		firsttime = true
		return
end
local function frender(char)
	local currentChunk,c = refunction.GetChunk(char.Position)
	currentChunk = currentChunk.."x"..c
	local renderedchunks ={}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(refunction.GetChunk(char.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
			v.Parent = nil
			storedchunk[v.Name] = v
		else
			renderedchunks[v.Name] = true
			end
	end
	task.spawn(function()
		local nearbychunks = refunction.GetSurroundingChunk(char.Position,12)
		for i,v in pairs(storedchunk)do
			if typeof(v) == "Instance" then
				if table.find(nearbychunks,i)  then
				else
					storedchunk[i] = nil
				end
			end
		end
	end)
	local nearbychunks = {}
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,2)) do
		table.insert(nearbychunks,v)
	end
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,render)) do
		if not table.find(nearbychunks,v) then
		table.insert(nearbychunks,v)	
		end
	end
	local newchunks = {}
	local thread = coroutine.running()
	local threadsdone = 0
	local done = false
	local curentlyload = {}
	for i,chunk in ipairs(nearbychunks)do
		if storedchunk[chunk] then
			storedchunk[chunk].Parent = workspace.Chunk
			storedchunk[chunk] = nil
			threadsdone+=1
			if threadsdone == #nearbychunks then
				coroutine.resume(thread)
				done = true
			end
			continue
		end
		if renderedchunks[chunk] then 
			threadsdone+=1 
		if threadsdone == #nearbychunks then
			coroutine.resume(thread)
			done = true
		end
		continue end
		local new,cnew = refunction.GetChunk(char.Position)
		new = new.."x"..cnew
		if threadsdone == #nearbychunks then
			coroutine.resume(thread)
			done = true
		end
	if new ~= currentChunk and threadsdone >=13  then
		repeat
			task.wait()
		until #curentlyload ==0
		frender(char)
		coroutine.resume(thread)
		threadsdone = #nearbychunks
		done = true
		continue
	end
	local Blocks = events.Block.GetChunk:InvokeServer(chunk,firsttime)
	--Blocks = HttpService:JSONDecode(compressor.decompress(Blocks))
	task.spawn(function()
	local index = 0
		local currena = chunk
		table.insert(curentlyload,currena)
		local blocktable = loadthread:DoWork(Blocks)
		local Folder = Instance.new("Folder")
		Folder.Name = chunk
		local model
		for i,v in ipairs(blocktable)do
			if v[8] == 2 then
				if v[7] then
					model = v[7]:Clone()
					if model:FindFirstChild("BasePart") then
						model:FindFirstChild("BasePart"):Destroy()
					end
					v[1] = model:FindFirstChild("MainPart")

				end
			elseif v[8] == 3 then
				if v[7] then
					v[1] = v[7]:Clone()
					model = v[1]
				end
			else
				model = v[1]
			end

			v[1].CFrame = v[2]
			model.Parent = Folder
			model:SetAttribute("Name",v[3])
			model:SetAttribute("State",v[4])
			v[1].Anchored = true
			if v[8] == 1 then
				v[1].Size = v[5]
			end
			model.Name = refunction.convertPositionto(v[6],"string")
			
		end
		Folder.Parent = game.Workspace.Chunk
		threadsdone+=1
		if threadsdone == #nearbychunks then
			coroutine.resume(thread)
			done = true
		end
		table.remove(curentlyload,table.find(curentlyload,currena))
	end)
	if threadsdone == #nearbychunks then
		coroutine.resume(thread)
		done = true
	end
	end
	if not done then 
		coroutine.yield()
	end
	task.wait(0.5)
	for i,v in ipairs(newchunks)do
		v.Parent = workspace.Chunk
		v = nil
		task.wait(0.1)
	end
	firsttime = true
	return
end
game.ReplicatedStorage.Events.Block.PlaceClient.OnClientEvent:Connect(function(blocks)
	for i,data in ipairs(blocks)do
		local cx,cz = refunction.GetChunk(data[4])
		refunction.PlaceBlock(data[1],data[4],data[2],data[3],storedchunk[cx..'x'..cz])
	end
end)
game.ReplicatedStorage.Events.Block.DestroyBlock.OnClientEvent:Connect(function(blocks)
	for i,Pos in ipairs(blocks)do
		local cx,cz = refunction.GetChunk(Pos)
		if game.Workspace.Chunk:FindFirstChild(cx.."x"..cz) and game.Workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos) then
			game.Workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos):Destroy()
		elseif storedchunk[cx.."x"..cz] and  storedchunk[cx.."x"..cz]:FindFirstChild(Pos) then
			storedchunk[cx.."x"..cz]:FindFirstChild(Pos):Destroy()
		end
	end
end)
local oldchunk =""
local char = game.Workspace.Entity:WaitForChild(lp.Name)
	QuickRender(char.PrimaryPart)
	while char do
		local currentChunk,c = refunction.GetChunk(char.PrimaryPart.Position)
		currentChunk = currentChunk.."x"..c
		if currentChunk ~= oldchunk and true then
			oldchunk = currentChunk
			frender(char.PrimaryPart)
		end
	task.wait(0.1)
end
