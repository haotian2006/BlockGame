local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)
local Block_Textures = RS.Block_Texture
local Block_Info = require(RS.BlockInfo)
local events = RS.Events
local lp = game.Players.LocalPlayer
game.Players.PlayerAdded:Connect(function(player)
	player.ChildAdded:Connect(function(character)
		character:Destroy()
	end)
end)

local render = 4
local function pack(x,y,z)
	return x..","..y..","..z
end
local function GetPosition(Table)
	local Position ={}
	for chunck,DATA in pairs(Table) do
		if game.Workspace.Chunk:FindFirstChild(chunck) then
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
local function sortchunck(TAB)
	local chunckst ={}
	local cx,cz = functions.GetChunck(lp.Character.PrimaryPart.Position)
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
	for i,v in pairs(chunck:GetChildren()) do
		if i%50 == 0 and firsttime then
			task.wait(0.01)
		end
		v:Destroy()
	end
	chunck:Destroy()
end
local function QuickRender(char)
	local nearbychuncks = sortchunck(functions.GetSurroundingChunck(char.PrimaryPart.Position,render))
	for i,chunk in ipairs(nearbychuncks)do
		chunk = chunk[1]
	local Blocks = events.Block.GetChunck:InvokeServer(chunk,firsttime)
	firsttime = true
	for Position,blockdata in pairs(Blocks) do
		if can(Position,Blocks,char.PrimaryPart.Position.Y)  then		
					functions.PlaceBlock(blockdata[1],Position,blockdata[2])
		end
		end
	end
	return
end
local function frender(char)
	local renderedchuncks ={}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(functions.GetChunck(char.PrimaryPart.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
				removechunck(v)
		else
			renderedchuncks[v.Name] = true
			end
	end
	local nearbychuncks = sortchunck(functions.GetSurroundingChunck(char.PrimaryPart.Position,render))
	for i,chunk in ipairs(nearbychuncks)do
		chunk = chunk[1]
		if renderedchuncks[chunk] then continue end
	local Blocks = events.Block.GetChunck:InvokeServer(chunk,firsttime)
	local index = 0
	for Position,blockdata in pairs(Blocks) do
		if can(Position,Blocks,char.PrimaryPart.Position.Y)  then		
					functions.PlaceBlock(blockdata[1],Position,blockdata[2])
			index+=1
			if index == 200 and firsttime then
				index = 0
				task.wait()
			end
		end
		end
	end
	firsttime = true
	return
end
local oldchunck =""
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait()
	QuickRender(char)
	while char do
		local currentChunck,c = functions.GetChunck(char.PrimaryPart.Position)
		currentChunck = currentChunck.."x"..c
		if currentChunck ~= oldchunck  then
			oldchunck = currentChunck
			frender(char)
		end
		task.wait(0.1)
	end
end)
