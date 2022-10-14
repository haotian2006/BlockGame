
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RS = game:GetService("ReplicatedStorage")
local refunction = require(RS.Functions)
local Block_Textures = RS.Block_Texture
local Block_Info = require(RS.BlockInfo)
local events = RS.Events
local lp = game.Players.LocalPlayer
local render = 4
game.Lighting.FogStart = render*4*16
game.Lighting.FogEnd = render*4*16*1.5
local debug = require(game.ReplicatedStorage.Debughandler)
local workthingyt = require(game.ReplicatedStorage.WorkerThreads)
local loadthread = workthingyt.New(script.Parent:WaitForChild("ChunksToBeLoaded"),"LoadChunk",40)
local compressor = require(game.ReplicatedStorage.Compresser)
local GenHandler = require(RS.GenerationHandler1)
local g2 = require(RS.GenerationVersions.GenerationHandler2)
local chunkstorage = require(RS.ClientChunks)
local toload = {}
local old
local firsttime = false
local oldchunks = {}
local char = game.Workspace.Entity:WaitForChild(lp.Name,math.huge)
task.spawn(function()
	while true do
		task.wait(1)
		for i,v in ipairs(oldchunks)do
			v:Destroy()
			task.wait(.5)
		end
	end
end)
local function garbage(pos,size:number)
	local currentChunk = refunction.GetChunk(pos,true)
	local rendered = {}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(refunction.GetChunk(pos))
		if (vector-currentvecotr).Magnitude > (size) then
			v.Parent = nil
			table.insert(oldchunks,v)

		else
			rendered[v.Name] = true
			end
	end
	for v,i in pairs(chunkstorage.Chunk) do
		local splited = v:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(refunction.GetChunk(pos))
		if (vector-currentvecotr).Magnitude > (size-1) then
			chunkstorage.Chunk[v] = nil
		else
			rendered[v] = true
			end
	end
	return rendered
end
local function renderblock(chunk,blocktable)
	blocktable = loadthread:DoWork(blocktable)
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
				v[1][1] = model:FindFirstChild("MainPart")

			end
		elseif v[8] == 3 then
			if v[7] then
				v[1][1] = v[7]:Clone()
				model = v[1][1]
			end
		else
			model = v[1][1]
		end

		v[1][1].CFrame = v[2]
		model.Parent = Folder
		model:SetAttribute("Name",v[3])
		model:SetAttribute("State",v[4])
		v[1][1].Anchored = true
		if v[8] == 1 then
			v[1][4].Parent = v[1][1]
			v[1][1].Size = v[5]
			v[1][4].MeshId = v[1][3] 
			v[1][4].TextureId = v[1][2] 
		end
		model.Name = refunction.convertPositionto(v[6],"string")
		
	end
	if game.Workspace.Chunk:FindFirstChild(Folder.Name) then
		Folder:Destroy()
	else
		Folder.Parent = game.Workspace.Chunk
	end
end
local function findclosest(orig,chunks)
	chunks = chunks or {}
	local cx = orig:split("x")
	local cx,cy = tonumber(cx[1]),tonumber(cx[2])
	local tablea ={}
	for i,v in chunks do
		local vx = i:split("x")
		local vx,vy = tonumber(vx[1]),tonumber(vx[2])
		local mag = math.sqrt((vx-cx)^2+(vy+cy)^2)
		table.insert(tablea,{i,mag})
	end
	table.sort(tablea,function(a,b)
		return a[2] < b[2]
	end)
	return tablea 
end
task.spawn(function()
	while true do
		task.wait(.2)
		for v,i in ipairs(findclosest(refunction.GetChunk(char.PrimaryPart.Position,true),chunkstorage.Chunk))do
			local i = i[1]
			local v = chunkstorage.Chunk[i]
			if not game.Workspace.Chunk:FindFirstChild(i) then
				local cx = i:split("x")
				local cx,cy = cx[1],cx[2]
				cx,cy = tonumber(cx),tonumber(cy) 
				if chunkstorage.Chunk[(cx+1).."x"..cy] and chunkstorage.Chunk[(cx-1).."x"..cy] and chunkstorage.Chunk[(cx).."x"..(cy+1)] and chunkstorage.Chunk[(cx).."x"..(cy-1)] then
					renderblock(i,g2.GetSortedTable(
					v[1],i,v[2],{chunkstorage.Chunk[(cx+1).."x"..cy][1],
					chunkstorage.Chunk[(cx-1).."x"..cy][1],
					chunkstorage.Chunk[(cx).."x"..(cy+1)][1],
					chunkstorage.Chunk[(cx).."x"..(cy-1)][1]
				},chunkstorage.update ))
					break
				end
			end
		end
	end
end)
local function arender(char,range,FastLoad)
	local ck = refunction.GetChunk(char.Position,true)
	local rendered = garbage(char.Position,range+2)
	local nearbychunks = {}
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,3)) do
		table.insert(nearbychunks,v)
	end
	local c = 25
	for i,v in ipairs(nearbychunks)do
		if rendered[v] then
			c -=1
		end
	end
	for i,v in ipairs(refunction.GetSurroundingChunk(char.Position,range)) do
		if not table.find(nearbychunks,v) then
			table.insert(nearbychunks,v)	
		end
	end
	for i,v in ipairs(nearbychunks)do
		if rendered[v] then
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
	local threadsdone,amm = 0,0
	local done = false
	local curentlyload = {}
	local loaded,should = events.Block.GetChunk:InvokeServer(nearbychunks)
	for i,c in pairs(sortedtoload)do
		for pos,v in pairs(c)do
			loaded[c][pos] = v
			should[pos] = true
		end
	end
	local done = 0 
	for i,chunk in ipairs(nearbychunks)do
		if i > c and ck ~= refunction.GetChunk(char.Position,true) then
			done +=1
			return
		end
		task.spawn(function()
			local Blocks,air = GenHandler.GetGeneration(chunk)
			local p = Instance.new("Part",workspace)
			p.Anchored = true
			local cx = chunk:split("x")
			local cx,cy = tonumber(cx[1])*16*4,tonumber(cx[2])*64
			p.Position = Vector3.new(cx,120,cy) 
			p.BrickColor = BrickColor.new("Bright orange")
			p.Material = Enum.Material.Neon
					if loaded and type(loaded) == "table" and loaded[chunk] then
						for i,v in pairs(loaded[chunk])do
							Blocks[i] = v
						end
					end
					chunkstorage.Chunk[chunk] = 	{Blocks,should}
			done +=1
		end)
		task.wait(.1)
	end
	repeat
		task.wait()
	until done == #nearbychunks
	return
end
local function frender(char,FastLoad)
	local currentChunk,c = refunction.GetChunk(char.Position)
	currentChunk = currentChunk.."x"..c
	local renderedchunks ={}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(refunction.GetChunk(char.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
			v.Parent = nil
			table.insert(oldchunks,v)

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
	local threadsdone,amm = 0,0
	local done = false
	local curentlyload = {}
	local loaded,should = events.Block.GetChunk:InvokeServer(nearbychunks)
	task.wait(.2)
	for i,c in pairs(sortedtoload)do
		for pos,v in pairs(c)do
			loaded[c][pos] = v
			should[pos] = true
		end
	end
	for i2,chunk in ipairs(nearbychunks)do
		amm +=1
		if renderedchunks[chunk] then 
			threadsdone+=1 
			if next(nearbychunks,i2) == nil then
				done = true
			end
			continue 
		end
		local new,cnew = refunction.GetChunk(char.Position)
		new = new.."x"..cnew

		if new ~= currentChunk and threadsdone >=5  then
			repeat
				task.wait()
			until #curentlyload ==0
			return
		end
		local Blocks
		if i2%1 == 0 then
			Blocks = GenHandler.GetGeneration(chunk,true)
			if loaded and type(loaded) == "table" and loaded[chunk] then
				for i,v in pairs(loaded[chunk])do
					Blocks[i] = v
				end
			end
			Blocks = g2.GetSortedTable(Blocks,chunk,should)
			task.wait(.1)
		end
		task.spawn(function()
			if  FastLoad then
				Blocks = GenHandler.GetGeneration(chunk,true)
				if loaded and type(loaded) == "table" and loaded[chunk] then
				for i,v in pairs(loaded[chunk])do
					Blocks[i] = v
				end
			end
			Blocks = g2.GetSortedTable(Blocks,chunk,should)
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
			if next(nearbychunks,i2) == nil then
				done = true
			end
			table.remove(curentlyload,table.find(curentlyload,currena))
		end)
		task.wait(.1)
	end
	repeat
		task.wait()
	until (threadsdone == amm and done) or threadsdone == 0
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
			local cx,cz = refunction.GetChunk(i)
			--if chunkstorage.Chunk[cx..'x'..cz] and chunkstorage.Chunk[cx..'x'..cz][refunction.convertPositionto(i)]  then
				chunkstorage.update[refunction.convertPositionto(i)] = true
				--chunkstorage.Chunk[cx..'x'..cz][refunction.convertPositionto(i)][100] = true
			--end
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
		if chunkstorage.Chunk[cx..'x'..cz] and chunkstorage.Chunk[cx..'x'..cz][refunction.convertPositionto(data[4])] then
			chunkstorage.Chunk[cx..'x'..cz][refunction.convertPositionto(data[4])] = data
		end
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
		if chunkstorage.Chunk[cx..'x'..cz] and chunkstorage.Chunk[cx..'x'..cz][Pos] then
			chunkstorage.Chunk[cx..'x'..cz][Pos] = nil
		end
	end
end) 
local oldchunk =""
--	QuickRender(char.PrimaryPart)
task.wait(.5)
print("e")
	--newload(char.PrimaryPart)
	arender(char.PrimaryPart,render)
	print("done")
	while char do
		local currentChunk,c = refunction.GetChunk(char.PrimaryPart.Position)
		currentChunk = currentChunk.."x"..c
		--shouldprint(currentChunk ~= oldchunk)
		if currentChunk ~= oldchunk and true then
			oldchunk = currentChunk
		--	newload(char.PrimaryPart)
			arender(char.PrimaryPart,render)
		end
	task.wait(0.1)
end
