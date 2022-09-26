
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
local GenHandler = require(RS.GenerationMutit)
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
			v.Parent = nil
			storedchunk[v.Name] = v
		else
			renderedchunks[v.Name] = true
			end
	end
	task.spawn(function()
		local nearbychunks = refunction.GetSurroundingChunk(char.Position,9)
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
	if new ~= currentChunk and threadsdone >=5  then
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
		Blocks = events.Block.GetChunk:InvokeServer(chunk,firsttime)
	end
	task.spawn(function()
		if i%2 == 0 then
			--Blocks = events.Block.GetChunk:InvokeServer(chunk,firsttime)
		end
		local currena = chunk
		table.insert(curentlyload,currena)
		local blocktable = loadthread:DoWork(Blocks)
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
		task.wait(2)
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
