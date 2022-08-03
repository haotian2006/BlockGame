local events ={loops ={}}
local MainHandler = require(game.ServerStorage.MainData)
local function getentityfromuuid(uuid)
	return MainHandler.LoadedEntitys[uuid] or  MainHandler.Entitys[uuid]
end
function events.listen(event,uuid,value,Target,time,increaseing)
    time = time or 1
  if  not uuid.events then
    uuid.events ={}
  end
  local entity = getentityfromuuid(uuid)
  events.loops[uuid][event] = {value,Target,time,increaseing}
  local value = entity[value]
  while events.loops[uuid][event]  do
    if increaseing and not entity.Frozen then
        value += increaseing
    end
    if value == Target then

        break
    end
    task.wait(time)
  end
end
return events