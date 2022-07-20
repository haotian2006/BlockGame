local MainHander = require(game.ServerStorage.MainHandler)
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
}
Data.Events.Baby_Grow_Up = function(uuid)
    
end