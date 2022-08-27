local a = 0.6
local movmenetstuff = {
	["W"] = {1/a,0,0},
    ["D"] = {0,0,1/a},
    ["S"] = {-1/a,0,0},
    ["A"] = {0,0,-1/a},
    [" "] = {0,8,0}
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
local jump = false
game.ReplicatedStorage.Events.Entitys.PlayerMove.OnServerEvent:Connect(function(player,code,direaction,rightd)
    local entity = maindata.LoadedEntitys[player.Name]
    if not entity then return end
    direaction = Vector3.new(direaction.X,0,direaction.Z)
    rightd =Vector3.new(rightd.X,0,rightd.Z)
    --print(entity.IsOnGround)
    local px = direaction*a*(code["W"]and 1 or 0)
    local nx = direaction*-a*(code["S"]and 1 or 0)
    local Right = rightd*a*(code["D"]and 1 or 0)
    local Left = rightd*-a*(code["A"]and 1 or 0)
    entity.NotSaved.Velocity.PlayerMove = refunch.convertPositionto(refunch.AddPosition(refunch.AddPosition(px,nx),refunch.AddPosition(Right,Left)),"table")
    for i,v in pairs(movmenetstuff)do
           if code[i] then
            if i == " "and entity.IsOnGround then
                entity.NotSaved.Velocity.Jump = v

                continue
            end
            if  entity.NotSaved.Velocity.PlayerMove[secondtable[i]] ~=  v[secondtable[i]] then
              --  entity.NotSaved.Velocity.PlayerMove[secondtable[i]] =  v[secondtable[i]]
                end
           else
                if  entity.NotSaved.Velocity.PlayerMove[secondtable[i]] ==  v[secondtable[i]] then
                    --entity.NotSaved.Velocity.PlayerMove[secondtable[i]] =  0
                end
        end
    end
end)
