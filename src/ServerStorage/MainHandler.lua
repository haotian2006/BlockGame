local LocalizationService = game:GetService("LocalizationService")
local RS = game:GetService("ReplicatedStorage")
local HTTPs = game:GetService("HttpService")
local refunction = require(RS.Functions)
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Info = require(RS.BlockInfo)
local GenHandler = require(game:GetService("ServerStorage").GenerationHandler)
local entityhandler = require(game.ServerStorage.MainEntityHandler)
local pathfinding = require(game.ServerStorage.PathFinding)
local maindata = require(game.ServerStorage.MainData)
local runservice = game:GetService("RunService")
local EntitysDeloadDistance = 7 --chunks
local moverefunction = require(game.ServerStorage.Move)
local value_changer = require(game.ServerStorage.ValueListener)
local workthingyt = require(game.ReplicatedStorage.WorkerThreads)
local loadthread = workthingyt.New(script.Parent:WaitForChild("LoadChunkIdk"),"Load",100)

local new 
local Main = {
	
}

local Connections = {}
local function Echeckfornearbyplayers(uuid,Distance)
	local deload = false
	local player 
	if game.Players:FindFirstChild(uuid) then
		return false,game.Players:FindFirstChild(uuid)
	end
	for i,v in ipairs(game.Players:GetPlayers()) do
		local char = maindata.LoadedEntitys[v.Name] or maindata.Entitys[v.Name]
		if char  then
			player = v
			if (refunction.convertPositionto(char.Position,"vector3")-Vector3.new(unpack(maindata.LoadedEntitys[uuid].Position))).Magnitude > EntitysDeloadDistance*16*4 then
				break
			end
		end
	end
	return deload,player
end
local paths ={
	--[[
		["startpos"] ={
			class = familytype
			path ={path}
		}
	]]
}
local function behaviors()
	
end
local function move(uuid)
	--[[local entity =  maindata.LoadedEntitys[uuid]
	if not entity.NotSaved then
		entity.NotSaved = {}
	end
	local Velocity = maindata.LoadedEntitys[uuid].NotSaved.Velocity
	if not Velocity  then return end
	entity.Position = refunction.convertPositionto(refunction.convertPositionto(Velocity,"vector3")+refunction.convertPositionto(entity.Position,"vector3"),"table")
	--print(Velocity)]]
end
function Main.runentity(uuid)
	if not Connections[uuid] then
		local self
		local startclock = os.clock()
		local timepassed = 0
		local once = false
		local oldplayerpos = "0,1a"
		for behavior,dataa in pairs(maindata.LoadedEntitys[uuid].behaviors)do
			if not entityhandler.behavior[behavior].runonupdate then
				task.spawn(function()
					entityhandler.behavior[behavior].func(uuid,dataa)
				end)
			end
		end
		local elapsed = 0
		self = runservice.Heartbeat:Connect(function( deltaTime)
			elapsed += deltaTime
			if elapsed > .05 then
				--eachtick
				elapsed = 0
			end
			moverefunction.HandleFall(uuid)
			moverefunction.update(uuid,deltaTime)
			local entity = 	maindata.LoadedEntitys[uuid]
			local player, closestplayer =  Echeckfornearbyplayers(uuid)
			if not Connections[uuid] or not maindata.Entitys[uuid] or  player or not maindata.LoadedEntitys[uuid] then
			--	print(not Connections[uuid] , not Main.LoadedEntitys[uuid] , Echeckfornearbyplayers(uuid))
				Connections[uuid] = nil
				maindata.Entitys[uuid] = maindata.Entitys[uuid] and maindata.LoadedEntitys[uuid] or nil
				maindata.LoadedEntitys[uuid] = nil
				--print(maindata.Entitys[uuid] )
				print(player)
				value_changer:DcAll(uuid)
				self:Disconnect()
			end
			if os.clock() - startclock >0.1 then
				startclock = os.clock()
				timepassed += 1
				
				for behavior,dataa in pairs(maindata.LoadedEntitys[uuid].behaviors)do
					if entityhandler.behavior[behavior].runonupdate then
						task.spawn(function()
							entityhandler.behavior[behavior].func(uuid,dataa)
						end)
					end
				end
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
			-- 	local playerpos = maindata.LoadedEntitys[uuid] or maindata.Entitys[uuid]
			-- 	playerpos = refunction.convertPositionto(playerpos.Position,"vector3")
			-- 	playerpos = Main.GetFloor(playerpos,true)
			-- --	print(playerpos)
			-- 	local px,py,pz = refunction.GetBlockCoords(playerpos)
			-- 	if (timepassed*0.1)%(2) == 0 and once == false and oldplayerpos ~= px..","..pz and playerpos then
			-- 		--print("newpathfind")
			-- 		--once = true
			-- 		oldplayerpos = px..","..pz
			-- 		--{entity.Position[1],entity.Position[2]-4,entity.Position[3]}
			-- 	local path =pathfinding.Queue(uuid,closestplayer.Name,uuid)
			-- 	--print("eeae")
			-- 		if path and true then
			-- 			local lplayerpos = oldplayerpos
			-- 			for i,v in ipairs(path)do
			-- 				if oldplayerpos ~= lplayerpos then
			-- 					break
			-- 				end
			-- 				local goalpos = refunction.convertPositionto(v.position,"table")
			-- 			--	print(goalpos)
			-- 				local done = moverefunction.MoveTo(uuid,{goalpos[1],goalpos[2]+4,goalpos[3]})
			-- 				--entity.Position = {entity.Position[1],entity.Position[2]+4,entity.Position[3]}
			-- 				--task.wait(0.5)
			-- 			end
			-- 		end	
			-- 	end
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
function Main.Move()
	
end
function Main.new(Name:string,Position:Vector3)
	local newblock = GetPath(Name):Clone()
	return newblock
end 
local function pack2(x,y,z)
	return x..","..y..","..z
end
local function convetcunktostring(cx,cz)
	return cx..","..cz
end
local function can(position,tabl,player,blockdata)
	
	local c = false
	local splittedstring = string.split(position,",")
	local x,y,z = splittedstring[1],splittedstring[2],splittedstring[3]
	local ch= convetcunktostring(refunction.GetChunk(position))
	if tabl[pack2(x+4,y,z)] and not Block_Info[tabl[pack2(x+4,y,z)][1]]["IsTransparent"] and  tabl[pack2(x-4,y,z)] and  not Block_Info[tabl[pack2(x-4,y,z)][1]]["IsTransparent"] and tabl[pack2(x,y+4,z)]and  not Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"] and tabl[pack2(x,y-4,z)] and not Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"]  and  tabl[pack2(x,y,z-4)] and  not Block_Info[tabl[pack2(x,y,z-4)][1]]["IsTransparent"] and  tabl[pack2(x,y,z+4)] and not Block_Info[tabl[pack2(x,y,z+4)][1]]["IsTransparent"] --[[and math.abs(player -y) <=16*(render)]] then
	elseif convetcunktostring(refunction.GetChunk(pack2(x+4,y,z))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x-4,y,z))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x,y,z+4))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x,y,z-4))) == ch  then
			c = true
	elseif ( not tabl[pack2(x,y+4,z)]  or (tabl[pack2(x,y+4,z)] and Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"]))  or ( not tabl[pack2(x,y-4,z)]  or (tabl[pack2(x,y-4,z)] and Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"])) or not blockdata[6]   then 
			c = true
	end
	return c
end
function Main.GetSortedTable(Data,Chunk,lc,Player)
	local char = maindata.LoadedEntitys[Player.Name] or maindata.Entitys[Player.Name]
	char = refunction.convertPositionto(char.Position,"vector3")
	local size = 0
	for coord,data in pairs(Data) do
		if can(coord,Data,char.Y,data)  then	
		lc[coord] ={data[1],data[2],data[3],Chunk, not Block_Info[data[1]]["IsTransparent"]}
		end
		maindata["LoadedBlocks"][Chunk] = maindata["LoadedBlocks"][Chunk] or {}
		maindata["LoadedBlocks"][Chunk][coord] ={data[1],data[2],data[3],coord,Chunk, data[6],not Block_Info[data[1]]["IsTransparent"]}
		size +=1
	end
	return lc
end
function Main.GetSurFace(X,Z)
	local chunk = refunction.GetChunk(Vector3.new(X,0,Z))
	
end
function Main.CheckForBlock(x,y,z,CanBeTransParent)
	local cx,cz = refunction.GetChunk(refunction.ConvertGridToReal(Vector3.new(x,0,z),"vector3"))
	if not maindata.Chunk[cx.."x"..cz] then
		return false
	end
	local bock = maindata.Chunk[cx.."x"..cz][x..','..y..","..z]
	if bock then
		return true,bock[1],bock[2]
	end
	return false
end
function Main.RayCast(Origion:Vector3,Direaction:Vector3,Range:number,Velocity:number,WhiteList)
--	local pos1,pos2,pos3 = Origion
end
function Main.GetFloor(pos,CanBeTransParent)
	pos = refunction.convertPositionto(pos,"vector3")
	local x,y,z = refunction.returnDatastringcomponets(refunction.ConvertGridToReal({refunction.GetBlockCoords(pos)},"string"))
	local cx,cz = refunction.GetChunk(Vector3.new(pos.X,0,pos.Z))
	for i = y , 0,-1 do
		if maindata.Chunk[cx.."x"..cz] and maindata.Chunk[cx.."x"..cz][x..","..i..","..z] then
			return Vector3.new(x,i,z)
		end
	end
	return nil
end
function Main.GetChunk(Player,Chunk,firsttime)
		updateentitytable(Player,EntitysDeloadDistance-2,(maindata.LoadedEntitys[Player.Name]) or Player.Character.PrimaryPart.Position)	
	local lc = {}
	if not maindata.Chunk[Chunk] then
		--maindata.Chunk[Chunk] = loadthread:DoWork(Chunk)
		maindata.Chunk[Chunk] = {}
		for index,coord in ipairs(refunction.XZCoordInChunk(Chunk)) do
				for y = 0,80,4 do
					--task.spawn(function()
						local coords = string.split(coord,"x")
						local position = Vector3.new(coords[1],y,coords[2])
						local block,id = GenHandler.GetBlock(position)
						id = 0
						if  block ~= nil and block ~="Air" then
							local packpos = pack(position)
							maindata.Chunk[Chunk][packpos] = {block,id,{0,0,0},packpos,Chunk,true}
	
						end
					--end)
				end
			end

		end
	return Main.GetSortedTable(maindata.Chunk[Chunk],Chunk,{},Player)
end

function Main.render(Player,RD,RenderedChunks)
	local lc = {}
	local char = maindata.LoadedEntitys[Player.Name] or maindata.Entitys[Player.Name]
	if not char then return end
	char = refunction.convertPositionto(char.Position,"vector3")
	local nearbychunks = refunction.GetSurroundingChunk(char,RD)
	local incease = 0
	updateentitytable(Player,EntitysDeloadDistance-2,Player.Character.Position)	
	for i,v in ipairs(nearbychunks)do
		if RenderedChunks[v] then continue end
		if not maindata.Chunk[v] then
			maindata.Chunk[v] = {}
			for index,coord in ipairs(refunction.XZCoordInChunk(v)) do
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
						maindata.Chunk[v][packpos] = {block,id}

					end
				end
			end
	
		end
		lc = Main.GetSortedTable(maindata.Chunk[v],v,RenderedChunks,lc)
	end
	return lc--,array
end
function Main.CreateEntity(Name,customname)
	local uuid = HTTPs:GenerateGUID()
	maindata.Entitys[uuid] = entityhandler.BasicNbt
	maindata.Entitys[uuid].Name = Name
	maindata.Entitys[uuid].CustomName = customname
	maindata.Entitys[uuid].Position = {refunction.GetVector3Componnets(Main.GetFloor(0,80,0))}
end
function updateentitytable(Player,Distance,pos)
	local char = pos or maindata.LoadedEntitys[Player.Name] or maindata.Entitys[Player.Name]
	if not char then return end
	char = pos or refunction.convertPositionto(char.Position,"vector3")
	if char then
		local player_Distance = Vector3.new(unpack(char))
		for uuid,nbt in pairs(maindata.Entitys) do
		--	print(nbt)
				if maindata.LoadedEntitys[uuid] then continue end	
				local EntityPos = Vector3.new(unpack(nbt.Position))
				if (player_Distance - EntityPos).Magnitude <= Distance*16*4 then
					maindata.LoadedEntitys[uuid] = nbt
					Main.runentity(uuid)	
			end
		end		
	end
end
function Main.GetNearByEntitys(Player,Distance)
	local placeentity = {}
	local char = maindata.LoadedEntitys[Player.Name] or maindata.Entitys[Player.Name]
	if not char then return end
	char = refunction.convertPositionto(char.Position,"vector3")
	if char then
		local playerpos = char
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
function Main.GetPlayersWithChunk(Position)
	local cx,cz = refunction.GetChunk(Position)
	local playerss= {}
	local chunk = cx.."x"..cz
	for i,v in ipairs(game.Players:GetPlayers())do
		local char = maindata.LoadedEntitys[v.Name] or maindata.Entitys[v.Name]
		if not char then continue end
		char = refunction.convertPositionto(char.Position,"vector3")
		local chunks = refunction.GetSurroundingChunk(char,14)
		for ic,vc in ipairs(chunks) do
			if vc == chunk then
					table.insert(playerss,v)
				break
			end
		end
	end
	return playerss
end
function Main.Place(player,block,Position,Orientation)
	if not Position or not block then return end
	local oldpos =Position
	Position = refunction.ConvertPositionToReal(Position,"vector3")
	local cx,cz = refunction.GetChunk(Position)
	if maindata.Chunk[cx.."x"..cz] and not maindata.Chunk[cx.."x"..cz][refunction.convertPositionto(Position,"string")] then
		maindata.Chunk[cx.."x"..cz][refunction.convertPositionto(Position,"string")] = {block,1,Orientation,refunction.convertPositionto(Position,"string")}
		maindata.LoadedBlocks[cx.."x"..cz][refunction.convertPositionto(Position,"string")] = {block,1,Orientation,refunction.convertPositionto(Position,"string")}
		for i,v in ipairs(Main.GetPlayersWithChunk(Position)) do
			RS.Events.Block.PlaceClient:FireClient(v,{maindata.Chunk[cx.."x"..cz][refunction.convertPositionto(Position,"string")]})
		end
	else
		return false
	end 
	return true
end

function Main.destroyblock(player,pos)
	if not pos then return end
	local oldpos =pos
	pos = refunction.ConvertPositionToReal(pos,"vector3")
	pos = refunction.convertPositionto(pos,"table")
	local cx,cz = refunction.GetChunk(pos)
	if maindata.Chunk[cx.."x"..cz] and  maindata.Chunk[cx.."x"..cz][refunction.convertPositionto(pos,"string")] then
		maindata.Chunk[cx.."x"..cz][refunction.convertPositionto(pos,"string")]  = nil
		 maindata.LoadedBlocks[cx.."x"..cz][refunction.convertPositionto(pos,"string")] = nil
		 local placee = {}
		 local top = (refunction.GetBlock({pos[1],pos[2]+4,pos[3]}))
		 local bottem = (refunction.GetBlock({pos[1],pos[2]-4,pos[3]}))
		 local front = (refunction.GetBlock({pos[1]+4,pos[2],pos[3]}))
		 local back = (refunction.GetBlock({pos[1]-4,pos[2],pos[3]}))
		 local right = (refunction.GetBlock({pos[1],pos[2],pos[3]+4}))
		 local left = (refunction.GetBlock({pos[1],pos[2],pos[3]-4}))
		 if top then
			table.insert(placee,top)
			top[6] = false
		 end
		 if bottem then
			table.insert(placee,bottem)
			bottem[6] = false
		 end
		 if front then
			table.insert(placee,front)
			front[6] = false
		 end
		 if back then
			table.insert(placee,back)
			back[6] = false
		 end
		 if right then
			table.insert(placee,right)
			right[6] = false
		 end
		 if left then
			table.insert(placee,left)
			left[6] = false
		 end
		 for i,v in ipairs(Main.GetPlayersWithChunk(pos)) do
			RS.Events.Block.PlaceClient:FireClient(v,placee)
			RS.Events.Block.DestroyBlock:FireClient(v,{refunction.convertPositionto(pos,"string")})
		end
	end
end
function Main.GetPlayer(player,Pos,a,neck,Body)
	local player = maindata.LoadedEntitys[player.Name] or maindata.Entitys[player.Name]
	player.NotSaved.NeckRotation = neck
	player.NotSaved.BodyRotation = Body
	player.Position = Pos and refunction.convertPositionto(Pos,"table") or player.Position
		return player	

end
 --name,CFrame,type(block or entity),newblockpos,newblockorienation,raycastinfo,IsCroucing
function Main.OnInteract(player,data)
	if data[3] == "Block" then

	elseif data[3] == "Entity" then
		entityhandler.Intereact(data[1],data)
	else 

	end
end
function Main.GetBlock(Player,Pos)
	Pos = refunction.convertPositionto(Pos,"table")
	local Player = maindata.LoadedEntitys[Player.Name] or maindata.Entitys[Player.Name]
	local position = Player.Position
	if refunction.GetMagnituide({position[1],position[2],position[3]},{Pos[1],position[2],Pos[3]}) <= 16*math.max(math.max(Player.HitBoxSize.x,Player.HitBoxSize.z),Player.HitBoxSize.y) then
		local cx,cy = refunction.GetChunk(position)
		if maindata.LoadedBlocks[cx.."x"..cy] and maindata.LoadedBlocks[cx.."x"..cy][Pos[1]..","..Pos[2]..","..Pos[3]] then
			return maindata.LoadedBlocks[cx.."x"..cy][Pos[1]..","..Pos[2]..","..Pos[3]],Pos[1]..","..Pos[2]..","..Pos[3]
		else
			return nil
		end 
	end 
end
RS.Events.Block.DestroyBlock.OnServerEvent:Connect(Main.destroyblock)
RS.Events.Block.GetChunk.OnServerInvoke = Main.GetChunk
RS.Events.Block.QuickRender.OnServerInvoke = Main.render
RS.Events.Interact.OnServerEvent:Connect(Main.OnInteract)
RS.Events.Entitys.NearByEntitys.OnServerInvoke = Main.GetNearByEntitys
RS.Events.Entitys.GetPlayer.OnServerInvoke = Main.GetPlayer
RS.Events.Block.GetBlock.OnServerInvoke = Main.GetBlock
return Main

