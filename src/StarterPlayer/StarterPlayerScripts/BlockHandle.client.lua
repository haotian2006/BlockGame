
local HttpService = game:GetService("HttpService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RS = game:GetService("ReplicatedStorage")
local refunction = require(RS.Functions)
local Block_Textures = RS.Block_Texture
local Block_Info = require(RS.BlockInfo)
local events = RS.Events
local lp = game.Players.LocalPlayer
local render = 10
game.Lighting.FogStart = render*4*16
game.Lighting.FogEnd = render*4*16*1.5
local debug = require(game.ReplicatedStorage.Debughandler)
local workthingyt = require(game.ReplicatedStorage.WorkerThreads)
local loadthread = workthingyt.New(script.Parent:WaitForChild("ChunksToBeLoaded"),"LoadChunk",40)
local compressor = require(game.ReplicatedStorage.Compresser)
local GenHandler = require(RS.GenerationHandler1)
local g2 = require(RS.GenerationVersions.GenerationHandler2)
local toload = {}
local old
local firsttime = false
local function frender(char)
	local currentChunk,c = refunction.GetChunk(char.Position)
	currentChunk = currentChunk.."x"..c
	local renderedchunks ={}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(refunction.GetChunk(char.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
			v:Destroy()

		else
			renderedchunks[v.Name] = true
			end
	end
	local nearbychunks = {}
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,2)) do
		table.insert(nearbychunks,v)
	end
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,render)) do
		if not table.find(nearbychunks,v) then
		table.insert(nearbychunks,v)	
		end
	end
	for i,v in ipairs(nearbychunks)do
		if game.Workspace.Chunk:FindFirstChild(v) then
			table.remove(nearbychunks,i)
		end
	end
	local sortedtoload = {}
	for i,v in pairs(toload)do
		local timea =v[2]
		local data = v[1]
		local c = refunction.GetChunk(i,true)
		if table.find(nearbychunks,c) then
			sortedtoload[c] = sortedtoload[c] or {}
			sortedtoload[c][i] = data
			toload[i] = nil
		end
		if os.clock()-timea >= 30 then
			toload[i] = nil
		end
	end
	local threadsdone = 0
	local done = false
	local curentlyload = {}
	local loaded,should = events.Block.GetChunk:InvokeServer(nearbychunks)
	local thread = coroutine.running()
	for i,c in pairs(sortedtoload)do
		for pos,v in pairs(c)do
			loaded[c][pos] = v
			should[pos] = true
		end
	end
	for i,chunk in ipairs(nearbychunks)do
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
		local Blocks
		if i%1 == 0 then
			Blocks = GenHandler.GetGeneration(chunk)
		end
		task.spawn(function()
			if loaded and loaded[chunk] then
				for i,v in pairs(loaded[chunk])do
					Blocks[i] = v
				end
			end
			Blocks = g2.GetSortedTable(Blocks,chunk,should)
			if i%3 == 0 then
				task.wait(math.random(2,4)/10)
			end
			local currena = chunk
			table.insert(curentlyload,currena)
			local blocktable = loadthread:DoWork(Blocks)
			Blocks = nil
			local Folder = Instance.new("Folder")
			Folder.Name = chunk
			for i,v in ipairs(blocktable)do
				local model
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
			if game.Workspace.Chunk:FindFirstChild(Folder.Name) then
				Folder:Destroy()
			else
				Folder.Parent = game.Workspace.Chunk
			end

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
	if firsttime == false then
		--task.wait(2)
	end
	firsttime = true
	return
end
game.ReplicatedStorage.Events.Block.PlaceClient.OnClientEvent:Connect(function(blocks)
	if blocks["1"] == "Load" then
		local fn = {}
		blocks["1"] = nil
	--	print(blocks["2"])
		for pos,data in pairs(blocks["2"])do
			if pos[1] then
				refunction.PlaceBlock(data[1],data[4],data[2],data[3])
			end
			blocks[pos] = nil
		end
		blocks["2"] = nil
		for i,v in pairs(blocks)do
			local data = g2.GetBlock(refunction.convertPositionto(i,"vector3"),v)
			if data then
				refunction.PlaceBlock(data[1],data[4],data[2],data[3])
			end
		end
	end
	for i,data in ipairs(blocks)do
		local cx,cz = refunction.GetChunk(data[4])
		if not game.Workspace.Chunk:FindFirstChild(cx.."x"..cz) or (game.Workspace.Chunk:FindFirstChild(cx.."x"..cz) and not game.Workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(refunction.convertPositionto(data[4]))) then
			toload[refunction.convertPositionto(data[4])] = {data,os.clock()}
		end
		refunction.PlaceBlock(data[1],data[4],data[2],data[3])
	end
end)
game.ReplicatedStorage.Events.Block.DestroyBlock.OnClientEvent:Connect(function(blocks)
	for i,Pos in ipairs(blocks)do
		local cx,cz = refunction.GetChunk(Pos)
		if game.Workspace.Chunk:FindFirstChild(cx.."x"..cz) and game.Workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos) then
			game.Workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos):Destroy()
		else
			toload[Pos] = {nil,os.clock()}
		end
	end
end)
local oldchunk =""
local char = game.Workspace.Entity:WaitForChild(lp.Name)
--	QuickRender(char.PrimaryPart)
	while char do
		local currentChunk,c = refunction.GetChunk(char.PrimaryPart.Position)
		currentChunk = currentChunk.."x"..c
		if currentChunk ~= oldchunk and true then
			oldchunk = currentChunk
			frender(char.PrimaryPart)
		end
	task.wait(0.1)
end
