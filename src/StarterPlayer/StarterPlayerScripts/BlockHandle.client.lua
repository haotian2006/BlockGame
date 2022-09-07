local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)
local Block_Textures = RS.Block_Texture
local Block_Info = require(RS.BlockInfo)
local events = RS.Events
local lp = game.Players.LocalPlayer
local render = 6
game.Lighting.FogStart = render*4*16
game.Lighting.FogEnd = render*4*16*1.5
local debug = require(game.ReplicatedStorage.Debughandler)
local workthingyt = require(game.ReplicatedStorage.WorkerThreads)
local storedchunck = require(script.Parent:WaitForChild("ChuncksToBeLoaded"))
local loadthread = workthingyt.New(script.Parent:WaitForChild("ChuncksToBeLoaded"),"LoadChunck",100)
local function pack(x,y,z)
	return x..","..y..","..z
end
local function GetPosition(Table)
	local Position ={}
	for chunck,DATA in pairs(Table) do
		if game.Workspace.Chunck:FindFirstChild(chunck) then
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
local function sortchunck(TAB,POS)
	local chunckst ={}
	local cx,cz = functions.GetChunck(POS or game.Workspace.Entity:FindFirstChild(lp.Name).PrimaryPart.Position)
	local currentvec = Vector2.new(cx,cz)
	for incex,chunck in ipairs(TAB) do
		local chunckx = string.split(chunck,"x")
		chunckx = chunckx[1]
		local chunckz = chunckx[2]
		local cvector = Vector2.new(chunckx,chunckz)
		local mag = (cvector - currentvec).Magnitude
		table.insert(chunckst,{chunck,mag})
	end
	 table.sort(chunckst,function(a,b)
		return a[2] < b[2]
	end)
	return chunckst
end
local function removechunck(chunck)
	task.spawn(function()
		for i,v in pairs(chunck:GetChildren()) do
			if i%100 == 0 and firsttime then
				task.wait(0.01)
			end
			v:Destroy()
		end
		chunck:Destroy()
	end)
end
local function QuickRender(char)

		local renderedchuncks ={}
		for i,v in ipairs(workspace.Chunck:GetChildren())do
			local splited = v.Name:split("x")
			local vector = Vector2.new(splited[1],splited[2])
			local currentvecotr = Vector2.new(functions.GetChunck(char.Position))
			if (vector-currentvecotr).Magnitude > (render+3) then
				v.Parent = nil
				storedchunck[v.Name] = v
			else
				renderedchuncks[v.Name] = true
				end
		end
		local nearbychuncks = (functions.GetSurroundingChunck(char.Position,render))
		local newchuncks = {}
		local thread = coroutine.running()
		local threadsdone = 0
		local done = false
		for i,chunk in ipairs(nearbychuncks)do
			chunk = chunk
			if storedchunck[chunk] then
				table.insert(newchuncks,storedchunck[chunk])
				threadsdone+=1
				--print(threadsdone , #nearbychuncks)
				if threadsdone == #nearbychuncks then
					coroutine.resume(thread)
					done = true
				end
				continue
			end
			if renderedchuncks[chunk] then 
				threadsdone+=1 
				--print(threadsdone , #nearbychuncks)
			if threadsdone == #nearbychuncks then
				coroutine.resume(thread)
				done = true
			end
			continue end
			task.spawn(function()
		local Blocks = events.Block.GetChunck:InvokeServer(chunk,firsttime)
		local index = 0
			local blocktable = loadthread:DoWork(Blocks)
			local moduel = Instance.new("Folder")
			moduel.Name = chunk
			for i,v in ipairs(blocktable)do
				v[1].CFrame = v[2]
				v[1].Parent = moduel
				v[1]:SetAttribute("Name",v[3])
				v[1]:SetAttribute("State",v[4])
				v[1].Anchored = true
				v[1].Size = v[5]
				v[1].Name = functions.convertPositionto(v[2].Position,"string")
				
			end
			table.insert(newchuncks,moduel)
			threadsdone+=1
			--print(threadsdone , #nearbychuncks)
			--print(threadsdone , #nearbychuncks)
			if threadsdone == #nearbychuncks then
				coroutine.resume(thread)
				done = true
			end
		end)
		if threadsdone == #nearbychuncks then
			coroutine.resume(thread)
			done = true
		end
		end
		if not done then 
			coroutine.yield()
		end
		for i,v in ipairs(newchuncks)do
			v.Parent = workspace.Chunck
			v = nil
		end
		firsttime = true
		return
end
local function frender(char)

	local renderedchuncks ={}
	for i,v in ipairs(workspace.Chunck:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(functions.GetChunck(char.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
			v.Parent = nil
			storedchunck[v.Name] = v
		else
			renderedchuncks[v.Name] = true
			end
	end
	task.spawn(function()
		local nearbychuncks = functions.GetSurroundingChunck(char.Position,12)
		for i,v in pairs(storedchunck)do
			if typeof(v) == "Instance" then
				if table.find(nearbychuncks,i)  then
				else
					storedchunck[i] = nil
				end
			end
		end
	end)
	local nearbychuncks = (functions.GetSurroundingChunck(char.Position,render))
	local newchuncks = {}
	local thread = coroutine.running()
	local threadsdone = 0
	local done = false
	for i,chunk in ipairs(nearbychuncks)do
		chunk = chunk
		if storedchunck[chunk] then
			table.insert(newchuncks,storedchunck[chunk])
			threadsdone+=1
			--print(threadsdone , #nearbychuncks)
			if threadsdone == #nearbychuncks then
				coroutine.resume(thread)
				done = true
			end
			continue
		end
		if renderedchuncks[chunk] then 
			threadsdone+=1 
			--print(threadsdone , #nearbychuncks)
		if threadsdone == #nearbychuncks then
			coroutine.resume(thread)
			done = true
		end
		continue end

	local Blocks = events.Block.GetChunck:InvokeServer(chunk,firsttime)
	local index = 0
	task.spawn(function()
		local blocktable = loadthread:DoWork(Blocks)
		local moduel = Instance.new("Folder")
		moduel.Name = chunk
		for i,v in ipairs(blocktable)do
			v[1].CFrame = v[2]
			v[1].Parent = moduel
			v[1]:SetAttribute("Name",v[3])
			v[1]:SetAttribute("State",v[4])
			v[1].Anchored = true
			v[1].Size = v[5]
			v[1].Name = functions.convertPositionto(v[2].Position,"string")
			
		end
		table.insert(newchuncks,moduel)
		threadsdone+=1
		--print(threadsdone , #nearbychuncks)
		--print(threadsdone , #nearbychuncks)
		if threadsdone == #nearbychuncks then
			coroutine.resume(thread)
			done = true
		end
	end)
	if threadsdone == #nearbychuncks then
		coroutine.resume(thread)
		done = true
	end
	--[[for Position,blockdata in pairs(Blocks) do	

					functions.PlaceBlock(blockdata[1],Position,blockdata[2],blockdata[3])
			index+=1
			if index == 200 and firsttime then
				index = 0
				task.wait()
		--	end
		end
		end]]
	end
	if not done then 
		coroutine.yield()
	end
	task.wait(0.5)
	for i,v in ipairs(newchuncks)do
		v.Parent = workspace.Chunck
		v = nil
		task.wait(0.1)
	end
	firsttime = true
	return
end
game.ReplicatedStorage.Events.Block.PlaceClient.OnClientEvent:Connect(function(blocks)
	for i,data in ipairs(blocks)do
		local cx,cz = functions.GetChunck(data[4])
		functions.PlaceBlock(data[1],data[4],data[2],data[3],storedchunck[cx..'x'..cz])
	end
end)
game.ReplicatedStorage.Events.Block.DestroyBlock.OnClientEvent:Connect(function(blocks)
	for i,Pos in ipairs(blocks)do
		local cx,cz = functions.GetChunck(Pos)
		if game.Workspace.Chunck:FindFirstChild(cx.."x"..cz) and game.Workspace.Chunck:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos) then
			game.Workspace.Chunck:FindFirstChild(cx.."x"..cz):FindFirstChild(Pos):Destroy()
		elseif storedchunck[cx.."x"..cz] and  storedchunck[cx.."x"..cz]:FindFirstChild(Pos) then
			storedchunck[cx.."x"..cz]:FindFirstChild(Pos):Destroy()
		end
	end
end)
local oldchunck =""
local char = game.Workspace.Entity:WaitForChild(lp.Name)
	QuickRender(char.PrimaryPart)
	while char do
		local currentChunck,c = functions.GetChunck(char.PrimaryPart.Position)
		currentChunck = currentChunck.."x"..c
		if currentChunck ~= oldchunck and true then
			oldchunck = currentChunck
			frender(char.PrimaryPart)
		end
	task.wait(0.1)
end
