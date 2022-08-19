require(game.ServerStorage.MainHandler)
game.ReplicatedStorage.Debuh.OnServerEvent:Connect(function()
	require(game.ReplicatedStorage.Debughandler):printglobal()
end)
local mainenetity = require(game.ServerStorage.MainEntityHandler)
local data = require(game.ServerStorage.MainData)
local amount = 0
if true then
  --  return
end
for i = 0,amount,1 do
    mainenetity.CreateEntity("Mar",{-math.random(30,120),84,-math.random(80,200)})
end

print(data.Entitys)