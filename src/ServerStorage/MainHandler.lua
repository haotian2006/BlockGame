local LocalizationService = game:GetService("LocalizationService")
local RS = game:GetService("ReplicatedStorage")
local HTTPs = game:GetService("HttpService")
local functions = require(RS.Functions)
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Info = require(RS.BlockInfo)
local GenHandler = require(game:GetService("ServerStorage").GenerationHandler)
local entityhandler = require(game.ServerStorage.MainEntityHandler)
local pathfinding = require(game.ServerStorage.PathFinding)
local maindata = require(game.ServerStorage.MainData)
local runservice = game:GetService("RunService")
local entityhandler = require(game.ServerStorage.MainEntityHandler)
local EntitysDeloadDistance = 7 --chuncks


local Main = {
	
}

local Connections = {}
local function Echeckfornearbyplayers(uuid,Distance)
	local deload = false
	local player 
	for i,v in ipairs(game.Players:GetPlayers()) do
		if v.Character and v.character.PrimaryPart and v.character.PrimaryPart.position then
			player = v
			--print( (v.character.PrimaryPart.position-Vector3.new(unpack(Main.LoadedEntitys[uuid].Position))).magnitude )
			if (v.character.PrimaryPart.position-Vector3.new(unpack(maindata.LoadedEntitys[uuid].Position))).magnitude > EntitysDeloadDistance*16*4 then
				deload = true
				break
			end
		end
	end
	return deload,player
end
local function runentity(uuid)
	if not Connections[uuid] then
		local self
		local startclock = os.clock()
		local timepassed = 0
		local once = false
		local oldplayerpos = "0,1a"
		self = runservice.Stepped:Connect(function(time, deltaTime)
			local entity = 	maindata.LoadedEntitys[uuid]
			local player, closestplayer =  Echeckfornearbyplayers(uuid)
			if not Connections[uuid] or not maindata.Entitys[uuid] or player then
			--	print(not Connections[uuid] , not Main.LoadedEntitys[uuid] , Echeckfornearbyplayers(uuid))
				Connections[uuid] = nil
				maindata.Entitys[uuid] = maindata.Entitys[uuid] and maindata.LoadedEntitys[uuid] or nil
				maindata.LoadedEntitys[uuid] = nil
				self:Disconnect()
			end
			if os.clock() - startclock >0.1 then
				startclock = os.clock()
				timepassed += 1
				for eventname,info in pairs(maindata.LoadedEntitys[uuid].Events)do
					if (timepassed*0.1)%(info[2] or 1) == 0 then
							for index,stuff in ipairs(info[1])do
								local value,goal,increase = stuff[1],stuff[2],stuff[3]
								if type(value) == "string" then
									value = maindata.LoadedEntitys[uuid][value] or goal
								end
								if increase then
								value += increase
								end
								if value == goal then
									
									continue
								end
							end
					end
				end
				--print(entity)
				local playerpos = closestplayer.Character.PrimaryPart.position
				playerpos = Main.GetFloor(playerpos,true)
			--	print(playerpos)
				local px,py,pz = functions.GetBlockCoords(playerpos)
				if (timepassed*0.1)%(1) == 0 and once == false and oldplayerpos ~= px..","..pz and playerpos then
					--print("newpathfind")
					oldplayerpos = px..","..pz
				local path =pathfinding.GetPath({entity.Position[1],entity.Position[2]-4,entity.Position[3]},playerpos)
					if path then
						local lplayerpos = oldplayerpos
						for i,v in ipairs(path)do
							if oldplayerpos ~= lplayerpos then
								break
							end
							entity.Position = functions.convertPositionto(v.position,"table")
							entity.Position = {entity.Position[1],entity.Position[2]+4,entity.Position[3]}
							task.wait(1)
						end
					end	
				end
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
local function pack2(x,y,z)
	return x..","..y..","..z
end
local function can(position,tabl,player)
	local c = false
	local splittedstring = string.split(position,",")
	local x,y,z = splittedstring[1],splittedstring[2],splittedstring[3]
	if tabl[pack2(x+4,y,z)] and not Block_Info[tabl[pack2(x+4,y,z)][1]]["IsTransparent"] and  tabl[pack2(x-4,y,z)] and  not Block_Info[tabl[pack2(x-4,y,z)][1]]["IsTransparent"] and tabl[pack2(x,y+4,z)]and  not Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"] and tabl[pack2(x,y-4,z)] and not Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"]  and  tabl[pack2(x,y,z-4)] and  not Block_Info[tabl[pack2(x,y,z-4)][1]]["IsTransparent"] and  tabl[pack2(x,y,z+4)] and not Block_Info[tabl[pack2(x,y,z+4)][1]]["IsTransparent"] --[[and math.abs(player -y) <=16*(render)]] then
	else
		c = true
	end
	return c
end
function Main.GetSortedTable(Data,Chunck,lc,Player)
	for coord,data in pairs(Data) do
		if can(coord,Data,Player.Character.PrimaryPart.Position.Y)  then	
		lc[coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
		end
		maindata["LoadedBlocks"][coord] ={data[1],data[2],Chunck, not Block_Info[data[1]]["IsTransparent"]}
	end
	return lc
end
function Main.GetSurFace(X,Z)
	local chunck = functions.GetChunck(Vector3.new(X,0,Z))
	
end
function Main.CheckForBlock(x,y,z,CanBeTransParent)
	local cx,cz = functions.GetChunck(functions.ConvertGridToReal(Vector3.new(x,0,z),"vector3"))
	if not maindata.Chunck[cx.."x"..cz] then
		return false
	end
	local bock = maindata.Chunck[cx.."x"..cz][x..','..y..","..z]
	if bock then
		return true,bock[1],bock[2]
	end
	return false
end
function Main.RayCast(Origion:Vector3,Direaction:Vector3,Range:number,Velocity:number,WhiteList)
--	local pos1,pos2,pos3 = Origion
end
function Main.GetFloor(pos,CanBeTransParent)
	pos = functions.convertPositionto(pos,"vector3")
	local x,y,z = functions.returnDatastringcomponets(functions.ConvertGridToReal({functions.GetBlockCoords(pos)},"string"))
	local cx,cz = functions.GetChunck(Vector3.new(pos.X,0,pos.Z))
	for i = y , 0,-1 do
		if maindata.Chunck[cx.."x"..cz] and maindata.Chunck[cx.."x"..cz][x..","..i..","..z] then
			return Vector3.new(x,i,z)
		end
	end
	return nil
end
function Main.GetChunck(Player,Chunck,firsttime)
	if not firsttime then
		updateentitytable(Player,EntitysDeloadDistance-2)	
	end
	local lc = {}
	if not maindata.Chunck[Chunck] then
		maindata.Chunck[Chunck] = {}
		for index,coord in ipairs(functions.XZCoordInChunck(Chunck)) do
				for y = 0,80,4 do
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = GenHandler.GetBlock(position)
					id = 0
					if  block ~= nil and block ~="Air" then
						local packpos = pack(position)
						maindata.Chunck[Chunck][packpos] = {block,id}

					end
				end
			end

		end
	return Main.GetSortedTable(maindata.Chunck[Chunck],Chunck,{},Player)--,array
end
function Main.render(Player,RD,RenderedChuncks)
	--print(Player.Character.PrimaryPart.Position)
	local lc = {}
	local nearbychuncks = functions.GetSurroundingChunck(Player.Character.PrimaryPart.Position,RD)
	local incease = 0
	updateentitytable(Player,EntitysDeloadDistance-2)	
	for i,v in ipairs(nearbychuncks)do
		if RenderedChuncks[v] then continue end
		if not maindata.Chunck[v] then
			maindata.Chunck[v] = {}
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
						maindata.Chunck[v][packpos] = {block,id}

					end
				end
			end
	
		end
		lc = Main.GetSortedTable(maindata.Chunck[v],v,RenderedChuncks,lc)
	end
	return lc--,array
end
function Main.CreateEntity(Name)
	local uuid = HTTPs:GenerateGUID()
	maindata.Entitys[uuid] = entityhandler.BasicNbt
	maindata.Entitys[uuid].Name = Name
	maindata.Entitys[uuid].Position = {functions.GetVector3Componnets(Main.GetFloor(0,80,0))}
end
function updateentitytable(Player,Distance)
	if Player and Player.Character and Player.Character.PrimaryPart then
		local player_Distance = Player.Character.PrimaryPart.Position
		for uuid,nbt in pairs(maindata.Entitys) do
		--	print(nbt)
				if maindata.LoadedEntitys[uuid] then continue end	
				local EntityPos = Vector3.new(unpack(nbt.Position))
				if (player_Distance - EntityPos).magnitude <= Distance*16*4 then
					maindata.LoadedEntitys[uuid] = nbt
					runentity(uuid)	
			end
		end		
	end
end
function Main.GetNearByEntitys(Player,Distance)
	local placeentity = {}
	if Player and Player.character and Player.character.PrimaryPart then
		local playerpos = Player.character.PrimaryPart.position
		--print(maindata.LoadedEntitys)
		for uuid,nbt in pairs(maindata.LoadedEntitys) do
				local position =Vector3.new(unpack(nbt.Position))
				if (playerpos-position).magnitude <= Distance*16*4 then
					placeentity[uuid] = nbt
				end
		end
	end
	return placeentity
end

RS.Events.Block.GetChunck.OnServerInvoke = Main.GetChunck
RS.Events.Block.QuickRender.OnServerInvoke = Main.render
RS.Events.Entitys.NearByEntitys.OnServerInvoke = Main.GetNearByEntitys
return Main
