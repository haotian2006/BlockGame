local MainData = require(game.ServerStorage.MainData)
local handlers = game.ServerStorage.EntityHandlers
local moveto = require(game.ServerStorage.Move)
local httpsservice = game:GetService("HttpService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ValueListener = require(game.ServerStorage.ValueListener)
local refunction = require(game.ReplicatedStorage.Functions)
local GenHandler = require(game:GetService("ServerStorage").GenerationMutit)
local Data = {
   ["BasicNbt"] ={
	--nbtstuff
	Name = nil,
	Air = 20,
	MaxAir = 20,
	CurrentSpeed = 0, -- this is the speed used 
	Speed = 0,
	CustomName = nil,
	CanFall = true,
	CustomNameRenderHoverDistance = 0, --*4
	CustomNameRenderDistance = 0, --*4
	Position  = {0,0,0},
	Rotation = {0,0,0},
	EyeOffset = 6.7,
	FallDistance = 0,
	MaxJump = 5.9,
	MaxFallRate = 3.92,
	FallTicks = 0,
	CanTakeDamage = true,
	FireLast = 0,
	RenderFire = true,
	IgnoreBlocks ={},
	IgnoreMobs ={},
	RegenRate = 0,
	AutoJump = true,
	JumpWhen = {
		FullJump = 4,
		SmallJump = 2,
	},
	--otherstuff
	["NotSaved"] = {},
	["behaviors"] = {},
	["NotReplicated"] = {},
	Events = {},
	Effects ={},
   },
   Events ={

   },
   conditions ={

   },
   componet ={

   },
   statements ={
	
   },
   behavior = {

   },
   events ={

   },

}
--<----localfunctions---->
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
local function getentityfromuuid(uuid)
	return MainData.LoadedEntitys[uuid] 
end
local function addevent(event,entity,values,time)
	entity.Events[event] = {values,time} --{}
end
local function getentityhandlerfromuuid(uuid)
	if not getentityfromuuid(uuid) or not handlers[getentityfromuuid(uuid).Name] then return nil end
	return require(handlers[getentityfromuuid(uuid).Name])
end
local function getentityhandlerfromname(name)
	if not handlers[name] then return nil end
	return require(handlers[name])
end
local function spit_component(stuff)
	local a = string.split(stuff,".")
	return a[1], a[2]
end
local function gettrashbehfromuuid(uuid)
	local entity = getentityfromuuid(uuid)
	if not entity then return nil end
	local bh = entity["NotSaved"]
	if not bh then
		entity["NotSaved"] = {}
		bh = entity["NotSaved"]
	end
	if not bh["behaviors"] then
		bh["behaviors"] = {}
	end
	bh = bh["behaviors"]
	return bh
end
local function getypeofbeh(beh)
	return Data.behavior[beh].btype
end
local function comparebeh(beh1,beh2)
	beh1 =getypeofbeh(beh1)
	beh2 = getypeofbeh(beh2)
	if typeof(beh1) == "string" then
		if typeof(beh2) == "string" then
			return  beh2 == beh1
		else
			for i,v in ipairs(beh2) do
				if beh1 == v then
					return true
				end
			end
		end
	else
		if typeof(beh2) == "string" then
			for i,v in ipairs(beh1) do
				if beh2 == v then
					return true
				end
			end
		else
			for i,v in ipairs(beh2) do
				for i,v1 in ipairs(beh1) do
					if v1 == v then
						return true
					end
				end
			end
		end
	end
	return false
end
local function behcanrun(uuid,beh,Stop,canbesame)
	local garbage = gettrashbehfromuuid(uuid)
	if not garbage then return end
	local behs = getentityfromuuid(uuid).behaviors
	local priority  = behs[beh].priority
	local ishighest = true
	for bename,value in pairs(garbage) do
		if comparebeh(beh,bename) and value  then
			if (bename == beh and not canbesame) then
				ishighest = false
			end
			if behs[bename].priority > priority then--if the other valve is lower
				ishighest = false
				if Stop then
					garbage[bename] = false
				else
					break
				end
			else--if they are the same or value is higher
								
			end
		end
	end
	return ishighest
end
local function add(uuid_or_entity:string|table,bfullhname:string,data:table,isadd:boolean)
	local entity = (typeof(uuid_or_entity) == "table") and uuid_or_entity or getentityfromuuid(uuid_or_entity)
	local splited_string = string.split(bfullhname,".")
	if 	Data[splited_string[1]] and Data[splited_string[1]].add then
		Data[splited_string[1]].add(entity,splited_string[2],data,isadd)
	end
end
--<----statements---->
function  Data.statements.readcomponet(component,componentdata,uuid,add)
	local entity = getentityfromuuid(uuid)
	local index,name = spit_component(component)
	if index == "componet" then
		Data.componet[name](uuid,componentdata,add)
	elseif index == "behavior" then
	end
end
function  Data.statements.dosomething(data,uuid,add)
local module = getentityhandlerfromuuid(uuid)
if not module then return nil end
local componetgroups = module.entity.component_groups
	 for i,component in ipairs(data) do
		if componetgroups[component] then
			for sub,info in pairs(componetgroups[component]) do
				
			end
		end
	end
end
function  Data.statements.remove(data,uuid)
	
end
function  Data.statements.add(data,uuid)
	
end

--<----mobcomponets---->
--true = add false == remove
function Data.componet.ageable(entity,data,d)
	local duration = data["duration"]
	local feeditems = data["feeditems"]
	local grow_up = data["grow_up"]
	if d then
		entity["Age"] = -duration
	else
		entity["Age"] = 0
	end
end
function Data.componet.health(entity,data,isadd)
	local value = data["value"] 
	local max = data["max"] 
	if isadd then
		ValueListener.Change(entity,"health",value)	
		ValueListener.Change(entity,"maxhealth",max)	
	else
		ValueListener.Change(entity,"health",nil)	
		ValueListener.Change(entity,"maxhealth",nil)	
	end
end
function Data.componet.on_interact(entity,data,isadd)
	local func = data["func"]
	entity.on_interact = entity.on_interact or {}
	if isadd then
		ValueListener.Change(entity,"on_interact.func",func)	
	else
		ValueListener.Change(entity,"on_interact.func",nil)	
	end
end
function Data.componet.HitBoxSize(entity,data,isadd)
	local x = data["x"]  or 0
	local y = data["y"] or 0
	local z = data["z"] or data["x"] 
	entity.HitBoxSize = entity.HitBoxSize or {}
	if isadd then
		ValueListener.Change(entity,"HitBoxSize.x",x)	
		ValueListener.Change(entity,"HitBoxSize.y",y)	
		ValueListener.Change(entity,"HitBoxSize.z",z)	
	else
		ValueListener.Change(entity,"HitBoxSize",nil)	
	end
end
--<----mob_behavior---->
Data.behavior.nearest_attackable_target = {
	func = function (uuid,data,d)
		local priority = data.priority 
		local must_see = data.must_see or false 
		local reselect_targets = data.reselect_targets or false
		local within_radius = data.within_radius or 0 
	
	end,
	btype = "Target"
}
local chun = 4
-- Data.behavior.LoadChunk = {
-- 	func = function (uuid,data,d)
-- 		if game.Players:FindFirstChild(uuid) then
-- 			local lastchunk = ""
-- 			while true do
-- 				task.wait(1)
-- 				if game.Players:FindFirstChild(uuid) and MainData.LoadedEntitys[uuid] then
-- 					local pos = MainData.LoadedEntitys[uuid].Position
-- 					local cx,cz = refunction.GetChunk(pos)
-- 					if cx..","..cz ~= lastchunk then
-- 						local loaded = {}
-- 						for i = 0,chun,1 do
-- 							local chuncks = refunction.GetSurroundingChunk(pos,i)
-- 							for i,v in ipairs(chuncks) do
-- 								if not loaded[v] then
-- 									loaded[v] = true
-- 									local data = MainData.GetChunk()
-- 									if not data then							
-- 										local data = GenHandler.GetGeneration(v)
-- 										MainData.DecodedChunks[v] =data 
-- 									end
-- 									local newtable =  MainData.Compress(tostring(uuid)..v.."*",refunction.GetSortedTable(data,v))
-- 									game.ReplicatedStorage.Events.Block.SendChunk:FireClient(game.Players:FindFirstChild(uuid),newtable,tostring(uuid)..v.."*")
-- 								end
-- 							end 
-- 							task.wait(0.1)
-- 						end
-- 					end
-- 				else
-- 					return
-- 				end
-- 			end
-- 		end
-- 	end,
-- 	btype = "Load"
-- }
Data.behavior.random_stroll = {
	func = function (uuid,data)
		local interval = data.interval or 120
		local entity = getentityfromuuid(uuid)
		if math.random(1,interval) ~= 1 then return end
		if not behcanrun(uuid,"random_stroll",true,false) then return end

		local priority = data.priority 
		local speed_multiplier = data.speed_multiplier or 1 
		local xz_dist = (data.xz_dist or 10)*4
		local y_dist = (data.y_dist or 7)*4

		local bh = gettrashbehfromuuid(uuid)
		local EPosition = entity.Position
		local offsetx = math.random(-xz_dist,xz_dist)
		local offsetz = math.random(-xz_dist,xz_dist)
		local offsety = math.random(-y_dist,y_dist)
		local targetpos = {EPosition[1]+offsetx,EPosition[2]+offsety,EPosition[3]+offsetz}
		bh.random_stroll = true
		moveto.MoveTo(uuid,targetpos)
		bh.random_stroll = false
		return
	end,
	runonupdate = true,
	btype = "Movement"
}

--<----mainfunctions---->
function  Data.behavior.add(entity,bhname,data,isadd:boolean)
	local bead = entity.behaviors
	if not bead then
		entity.behaviors = {}
		bead = entity.behaviors
	end
	if not data.priority then
		warn(bhname,"Does not have a set priority in entity", bead.Name)
	end
	if isadd then
		bead[bhname] = data
	else
		bead[bhname] = nil
	end
end
function  Data.componet.add(entity,cname,data,isadd:boolean)
	Data.componet[cname](entity,data,isadd)
end
function  Data.Intereact(uuid,data)
	local handler = getentityhandlerfromuuid(uuid)
	local entity = getentityfromuuid(uuid)
	if handler and entity and entity["on_interact"] then
		if handler.functions[entity["on_interact"].func] then
			handler.functions[entity["on_interact"].func](uuid)
		end
	end
end

function  Data.CreateEntity(entityName,Position,CustomName)
	local generateduuid = httpsservice:GenerateGUID(false)
	local current_nbt = deepCopy(Data.BasicNbt)
	current_nbt.Name = entityName
	current_nbt.CustomName = CustomName
	current_nbt.uuid = generateduuid
	local entityhandler = getentityhandlerfromname(entityName)
	current_nbt.Position = Position
	for name,data in pairs(entityhandler.entity.components)do
		add(current_nbt,name,data,true)
	end
	--MainData.PlaceEntity(generateduuid,current_nbt)
	return generateduuid
end
return Data 