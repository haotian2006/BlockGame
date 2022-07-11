local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Info = require(RS.BlockInfo)
local GenHandler = require(game:GetService("ServerStorage").GenerationHandler)
local Block = {
	["Chunck"] ={
		--[["0x0"] ={t
			["Stone"]={
				["Position"] = {{0,0,0},{4,0,4},{4,-4,8},{8,-4,8},{4,-4,16},{4,-4,12},{4,-4,24},{-32,-4,-32},{28,-4,28},{-32, -4, 28}},
				["Id"] ={0,0,0,0}
			}
		};]]
	--[["0x0"] ={
		["0,0,0"] = {"Stone",1}
	};]]
	},
	["LoadedBlocks"] ={

	}
	["Entitys"]
}

local function pack(pos:Vector3)
	local statement = pos.X..","..pos.Y..","..pos.Z
	return statement
end
local function GetPath(block:string)
	return Block_Path[block].Model
end

function Block.new(Name:string,Position:Vector3)
	local newblock = GetPath(Name):Clone()
	return newblock
end 
function Block.GetSortedTable(Data,Chunck,lc)
	for coord,data in pairs(Data) do
		lc[coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
		Block["LoadedBlocks"][coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
	end
	return lc
end
function Block.GetSurFace(X,Z)
	local chunck = functions.GetChunck(Vector3.new(X,0,Z))
	
end
function Block.CheckForBlock(x,y,z,CanBeTransParent)
	x,z,y  = functions.GetBlockCoords(Vector3.new(x,y,z))
	local cx,cz = functions.GetChunck(Vector3.new(x,0,z))
	local bock = Block.Chunck[cx.."x"..cz][x..y..z]
	if bock then
		return bock[1],bock[2]
	end
	return false
end
function Block.GetFloor(x,y,z)
	x,z,y  = functions.GetBlockCoords(Vector3.new(x,y,z))
	local cx,cz = functions.GetChunck(Vector3.new(x,0,z))
	for i = y , 0,-1 do
		if not Block.CheckForBlock(x,i,z) then
			return Vector3.new(x,i+1,z)
		end
	end
end

function Block.GetChunck(Player,Chunck,firsttime)
	local lc = {}
	if not Block.Chunck[Chunck] then
		Block.Chunck[Chunck] = {}
		for index,coord in ipairs(functions.XZCoordInChunck(Chunck)) do
				if index%90 == 0 and firsttime then
					--task.wait(0)
				end
				for y = 0,80,4 do
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = GenHandler.GetBlock(position)
					id = 0
					if  block ~= nil and block ~="Air" then
						local packpos = pack(position)
					Block.Chunck[Chunck][packpos] = {block,id}

					end
				end
			end

		end
	return Block.GetSortedTable(Block.Chunck[Chunck],Chunck,{})--,array
end
function Block.render(Player,RD,RenderedChuncks)
	local lc = {}
	local nearbychuncks = functions.GetSurroundingChunck(Player.Character.PrimaryPart.Position,RD)
	local incease = 0
	for i,v in ipairs(nearbychuncks)do
		if RenderedChuncks[v] then continue end
		if not Block.Chunck[v] then
			Block.Chunck[v] = {}
			for index,coord in ipairs(functions.XZCoordInChunck(v)) do
				incease += 1
				if index%200 == 0  then
					task.wait()
				end
				for y = 0,80,4 do
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = GenHandler.GetBlock(position)
					id = 0
					if  block ~= nil and block ~="Air" then
						local packpos = pack(position)
						Block.Chunck[v][packpos] = {block,id}

					end
				end
			end
	
		end
		lc = Block.GetSortedTable(Block.Chunck[v],v,RenderedChuncks,lc)
	end
	return lc--,array
end
function Block.Old(Player,RD,firsttime)
	local array ={}
	local lc = {}
	local nearbychuncks = functions.GetSurroundingChunck(Player.Character.PrimaryPart.Position,RD)
	for i,v in ipairs(nearbychuncks)do
		if not Block.Chunck[v] then
			Block.Chunck[v] = {}
			for index,coord in ipairs(functions.XZCoordInChunck(v)) do
				if index%20 == 0 and firsttime then
					task.wait(0.015)
				end
				for y = 0,80,4 do
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = GenHandler.GetBlock(position)
					if  block ~= nil and block ~="Air" then
						local packpos = pack(position)
						Block.Chunck[v][packpos] = {block,id}
						if not Block_Info[block]["IsTransparent"] then
							array[packpos] = {block,id}
						end

					end
				end
			end


		end
		lc[v] =Block.Chunck[v]
	end
	--print(lc)

	return lc,array
end
RS.Events.Block.GetChunck.OnServerInvoke = Block.GetChunck
RS.Events.Block.QuickRender.OnServerInvoke = Block.render
RS.Events.Entitys.NearByEntitys.OnServerInvoke = Block.render
return Block
