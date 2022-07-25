local MainHandler = require(game.ServerStorage.MainHandler)
local Data ={
   BasicNbt ={
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

   }
}
--localfunctions
local function getentityfromuuid(uuid)
	return MainHandler.LoadedEntitys[uuid] or  MainHandler.Entitys[uuid]
end
local function addevent(event,entity,values,time)
	entity.Events[event] = {values,time} --{value,endgoal,increase}
end
--mobcomponets
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