local Entitys = {}
local blockmodule = require(game.ServerStorage.BlockModule)
function Entitys.Move(Target:Vector3)
	
end
function Entitys.Spawn(Entity,Position)
	local entity = game.Workspace:FindFirstChild(Entity)
	if entity then
		--Entitys[Entity]  
	end
end
return Entitys
