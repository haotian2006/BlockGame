local move = {}
move.Moving = {}
local maindata = require(game.ServerStorage.MainData)
local refunction = require(game.ReplicatedStorage.Functions)
function move.MoveTo(uuid,goal)
    local currentnumber = move.Moving["uuid"] and move.Moving["uuid"]+1  or 0
    move.Moving["uuid"] = currentnumber 
    local pos = maindata.LoadedEntitys[uuid].Position
    repeat
        local direaction = refunction.GetUnit(goal,pos)/7
        maindata.LoadedEntitys[uuid].NotSaved.Velocity = refunction.convertPositionto(direaction,"table")
        pos = maindata.LoadedEntitys[uuid].Position
        task.wait()
    until refunction.GetMagnituide(pos,goal) <= 0.5 or move.Moving["uuid"] ~= currentnumber
    if not move.Moving["uuid"] ~= currentnumber then
    maindata.LoadedEntitys[uuid].NotSaved.Velocity = {0,0,0}
    end
    move.Moving["uuid"] = nil
    return not move.Moving["uuid"] or false
end
return move