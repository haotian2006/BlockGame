require(game.ServerStorage.MainHandler)
game.ReplicatedStorage.Debuh.OnServerEvent:Connect(function()
	require(game.ReplicatedStorage.Debughandler):printglobal()
end)
local data = require(game.ServerStorage.MainData)
local amount = 50
if true then
  --  return
end
for i = 0,amount,1 do
     data.Entitys["a"..i] = { -- a uuid
     ["Name"] = "Mar",
     ["Age"] = "0",
     ["Position"] = {-math.random(30,120),84,-math.random(80,200)},
     ["IsChild"] = false,
     Rotation = {0,0,0},
     Events = {}
 }
	print(data.Entitys["a"..i],"a"..i)
end
print(  data.Entitys)