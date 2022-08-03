local MainHandler = require(game.ServerStorage.MainData)
local handlers = game.ServerStorage.EntityHandlers
local Data = {
   ["BasicNbt"] ={
    Effects ={},
	Name = nil,
	Air = 20,
	MaxAir = 20,
	CurrentSpeed = 0, -- this is the speed used 
	Speed = 0,
	CustomName = nil,
	CustomNameRenderHoverDistance = 0, --*4
	CustomNameRenderDistance = 0, --*4
	Position  = {},
	Rotation = {},
	Health = 0,
	MaxHealth = 0,
	FallDistance = 0,
	CanTakeDamage = true,
	FireLast = 0,
	RenderFire = true,
	IgnoreBlocks ={},
	IgnoreMobs ={},
	RegenRate = 0,
   },
   Events ={

   },
   conditions ={

   },
   componets ={

   },
   statements ={
	
   }

}
--<----localfunctions---->
local function getentityfromuuid(uuid)
	return MainHandler.LoadedEntitys[uuid] or  MainHandler.Entitys[uuid]
end
local function addevent(event,entity,values,time)
	entity.Events[event] = {values,time} --{}
end
local function getentityhandlerfromuuid(uuid)
	return require(handlers[getentityfromuuid(uuid).Name])
end
local function spit_component(stuff)
	local a = string.split(stuff,".")
	return a[1], a[2]
end
--<----statements---->
function  Data.statements.readcomponet(component,componentdata,uuid,add)
	local entity = getentityfromuuid(uuid)
	local index,name = spit_component(component)
	if index == "componet" then
		Data.componets[name](uuid,componentdata,add)
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
function  Data.componets.ageable(uuid,data,d)
	local entity = getentityfromuuid(uuid)
	local duration = data["duration"]
	local feeditems = data["feeditems"]
	local grow_up = data["grow_up"]
	if d then
		entity["Age"] = -duration
	else
		entity["Age"] = 0
	end
end
--<----mainfunctions---->
function  Data.EventRead(data)
	
end
return Data