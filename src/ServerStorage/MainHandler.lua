---@diagnostic disable: unused-function
local RS = game:GetService("ReplicatedStorage")
local HTTPs = game:GetService("HttpService")
local functions = require(RS.Functions)
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Info = require(RS.BlockInfo)
local GenHandler = require(game:GetService("ServerStorage").GenerationHandler)
local runservice = game:GetService("RunService")
local exampleentity = {
	["Name"] = "Example",
	["Age"] = "0",
	["CFrame"] = {},
	["IsChild"] = false,
}
local EntitysDeloadDistance = 7 --chuncks
local Main = {
	["Chunck"] ={
		--[["0x0"] ={t
			["Stone"]={
				["Position"] = {{0,0,0},{4,0,4},{4,-4,8},{8,-4,8},{4,-4,16},{4,-4,12},{4,-4,24},{-32,-4,-32},{28,-4,28},{-32, -4, 28}},
				["Id"] ={0,0,0,0}
			} --Old Saving Method
		};]]
	--[["0x0"] ={
		["0,0,0"] = {1,1{}}--(name,state,nbt)
	};]]-- New Method Easier to get blocks less resorce intensive
	},
	["LoadedBlocks"] ={

	},
	["Entitys"] ={
	--[[	["190-099-3210"] { -- a uuid
			["Name"] = "Example",
			["Age"] = "0",
			["CFrame"] = {},
			["IsChild"] = false,
		}]]
	},
	["LoadedEntitys"] ={}
}

local Connections = {}
local function Echeckfornearbyplayers(uuid,Distance)
	local deload = false
	for i,v in ipairs(game.Players:GetPlayers()) do
		if v.Character and v.character.PrimaryPart then
			if (v.character.PrimaryPart.position-Main.LoadedEntitys[uuid].CFrame.position).magnitude < EntitysDeloadDistance*16 then
				deload = true
				break
			end
		end
	end
	return deload
end
local function runentity(uuid)
	if not Connections[uuid] then
		local self
		self = runservice.Stepped:Connect(function(time, deltaTime)
			if not Connections[uuid] or not Main.LoadedEntitys[uuid] or Echeckfornearbyplayers(uuid) then
				Connections[uuid] = nil
				self:Disconnect()
			end
		end)
		Connections[uuid] = self
	end
end
local function pack(pos:Vector3)
	local statement = pos.X..","..pos.Y..","..pos.Z
	return statement
end
local function GetPath(block:string)
	return Block_Path[block].Model
end

function Main.new(Name:string,Position:Vector3)
	local newblock = GetPath(Name):Clone()
	return newblock
end 
function Main.GetSortedTable(Data,Chunck,lc)
	for coord,data in pairs(Data) do
		lc[coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
		Main["LoadedBlocks"][coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
	end
	return lc
end
function Main.GetSurFace(X,Z)
	local chunck = functions.GetChunck(Vector3.new(X,0,Z))
	
end
function Main.CheckForBlock(x,y,z,CanBeTransParent)
	x,z,y  = functions.GetBlockCoords(Vector3.new(x,y,z))
	local cx,cz = functions.GetChunck(Vector3.new(x,0,z))
	local bock = Main.Chunck[cx.."x"..cz][x..y..z]
	if bock then
		return bock[1],bock[2]
	end
	return false
end
function Main.RayCast(Origion:Vector3,Direaction:Vector3,Range:number,Velocity:number,WhiteList)
--	local pos1,pos2,pos3 = Origion
end
function Main.GetFloor(x,y,z)
	x,z,y  = functions.GetBlockCoords(Vector3.new(x,y,z))
	local cx,cz = functions.GetChunck(Vector3.new(x,0,z))
	for i = y , 0,-1 do
		if not Main.CheckForBlock(x,i,z) then
			return Vector3.new(x,i+1,z)
		end
	end
end

function Main.GetChunck(Player,Chunck,firsttime)
	local lc = {}
	if not Main.Chunck[Chunck] then
		Main.Chunck[Chunck] = {}
		for index,coord in ipairs(functions.XZCoordInChunck(Chunck)) do
				for y = 0,80,4 do
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = GenHandler.GetBlock(position)
					id = 0
					if  block ~= nil and block ~="Air" then
						local packpos = pack(position)
						Main.Chunck[Chunck][packpos] = {block,id}

					end
				end
			end

		end
	return Main.GetSortedTable(Main.Chunck[Chunck],Chunck,{})--,array
end
function Main.render(Player,RD,RenderedChuncks)
	local lc = {}
	local nearbychuncks = functions.GetSurroundingChunck(Player.Character.PrimaryPart.Position,RD)
	local incease = 0
	for i,v in ipairs(nearbychuncks)do
		if RenderedChuncks[v] then continue end
		if not Main.Chunck[v] then
			Main.Chunck[v] = {}
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
						Main.Chunck[v][packpos] = {block,id}

					end
				end
			end
	
		end
		lc = Main.GetSortedTable(Main.Chunck[v],v,RenderedChuncks,lc)
	end
	return lc--,array
end
function Main.CreateEntity(Name)
	local uuid = HTTPs:GenerateGUID()
	Main.Entitys[uuid] =exampleentity
	Main.Entitys[uuid].Name = Name
	Main.Entitys[uuid].CFrame = {CFrame.new(Main.GetFloor(0,80,0)):GetComponents()}
end
function updateentitytable(Player,Distance)
	if Player and Player.Character and Player.Character.PrimaryPart then
		local player_Distance = Player.Character.PrimaryPart.Position
		for uuid,nbt in pairs(Main.Entitys) do
				if Main.LoadedEntitys[uuid] then continue end	
				runentity(uuid)	
				local EntityPos = CFrame.new(unpack(nbt.CFrame)).Position
				if (player_Distance - EntityPos).magnitude <= Distance then
				Main.LoadedEntitys[uuid] = nbt
			end
		end		
	end
end
function Main.GetNearByEntitys(Player,Distance)
	local placeentity = {}
	for uuid,nbt in pairs(Main.Entitys) do
			
	end
end

RS.Events.Block.GetChunck.OnServerInvoke = Main.GetChunck
RS.Events.Block.QuickRender.OnServerInvoke = Main.render
RS.Events.Entitys.NearByEntitys.OnServerInvoke = Main.GetNearByEntitys
return Main
