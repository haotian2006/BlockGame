local a = 5
local movmenetstuff = {
	["W"] = {1/a,0,0},
    ["D"] = {0,0,1/a},
    ["S"] = {-1/a,0,0},
    ["A"] = {0,0,-1/a},
    [" "] = {0,4,0}
}
local secondtable = {
    ["W"] = 1,
    ["D"] = 3,
    ["S"] = 1,
    ["A"] = 3,
    [" "] = 2
}
local maindata = require(game.ServerStorage.MainData)
local refunch = require(game.ReplicatedStorage.Functions)
game.ReplicatedStorage.Events.Entitys.PlayerMove.OnServerEvent:Connect(function(player,code)
    local entity = maindata.LoadedEntitys[player.Name]
    if not entity then return end
    entity.NotSaved.Velocity = {}
    entity.NotSaved.Velocity.PlayerMove =   entity.NotSaved.Velocity.PlayerMove  or {0,0,0}
    for i,v in pairs(movmenetstuff)do
           if code[i] then
            if i == " " then
                entity.NotSaved.Velocity.Jump = v
                continue
            end
            if  entity.NotSaved.Velocity.PlayerMove[secondtable[i]] ~=  v[secondtable[i]] then
                entity.NotSaved.Velocity.PlayerMove[secondtable[i]] =  v[secondtable[i]]
                end
           else
                if  entity.NotSaved.Velocity.PlayerMove[secondtable[i]] ==  v[secondtable[i]] then
                    entity.NotSaved.Velocity.PlayerMove[secondtable[i]] =  0
                end
        end
    end
end)
