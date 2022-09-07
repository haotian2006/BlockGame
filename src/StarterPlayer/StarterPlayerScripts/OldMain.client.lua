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

local render = 6
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
	local c = false
	local splittedstring = string.split(position,",")
	local x,y,z = splittedstring[1],splittedstring[2],splittedstring[3]
	if tabl[pack(x+4,y,z)] and tabl[pack(x+4,y,z)][4] and  tabl[pack(x-4,y,z)] and  tabl[pack(x-4,y,z)][4]  and tabl[pack(x,y+4,z)]and  tabl[pack(x,y+4,z)][4] and tabl[pack(x,y-4,z)] and tabl[pack(x,y-4,z)][4]  and  tabl[pack(x,y,z-4)] and  tabl[pack(x,y,z-4)][4] and  tabl[pack(x,y,z+4)] and tabl[pack(x,y,z+4)][4] --[[and math.abs(player -y) <=16*(render)]] then
	else
		c = true
	end
	return c
end
local old
local firsttime = false
local function sortchunk(TAB)
	local chunkst ={}
	local cx,cz = functions.GetChunk(lp.Character.PrimaryPart.Position)
	local currentvec = Vector2.new(cx,cz)
	for chunk,DATA in pairs(TAB) do
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
	for i,v in pairs(chunk:GetChildren()) do
		if i%100 == 0 and firsttime then
			task.wait(0.01)
		end
		v:Destroy()
	end
	chunk:Destroy()
end
local function frender(char)
	local renderedchunks ={}
	for i,v in ipairs(workspace.Chunk:GetChildren())do
		local splited = v.Name:split("x")
		local vector = Vector2.new(splited[1],splited[2])
		local currentvecotr = Vector2.new(functions.GetChunk(char.PrimaryPart.Position))
		if (vector-currentvecotr).Magnitude > (render+3) then
			removechunk(v)
		else
			renderedchunks[v.Name] = true
			end
		end
	local Blocks = events.Block.GetChunk:InvokeServer(render,renderedchunks,firsttime)
	local index = 0
	for Position,blockdata in pairs(Blocks) do
		if can(Position,Blocks,char.PrimaryPart.Position.Y)  then		
			functions.PlaceBlock(blockdata[1],Position,blockdata[2])
			index+=1
			if index == 90 and firsttime then
				index = 0
				--task.wait(0.01)
			end
		end
	end
	firsttime = true
	return
end
local oldchunk =""
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait()
	while char do
		local currentChunk,c = functions.GetChunk(char.PrimaryPart.Position)
		currentChunk = currentChunk.."x"..c
		if currentChunk ~= oldchunk  then
			oldchunk = currentChunk
			frender(char)
			print("c")
		end
		task.wait(0.1)
	end
end)
