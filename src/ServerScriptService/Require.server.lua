require(game.ServerStorage.MainHandler)
local maindata = require(game.ServerStorage.MainData)
local copy = { -- a uuid
["Name"] = "Mar",
["Age"] = "0",
["Position"] = {-68,90,-120},
HitBoxSize = {x =2.2,y=7.5,z=2.2},
behaviors = {
},
EyeOffset = 6.7,
CanFall = true,
JumpWhen = {
	FullJump = 4,
	SmallJump = 2,
},
AutoJump= true,
      Rotation = {0,0,0},
      Events = {},
["NotSaved"] = {Velocity={}},
FallTicks = 0,
MaxFallRate = 3.92,
FallDistance = 0,
}
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
game.Players.PlayerAdded:Connect(function(player)
  maindata.Entitys[player.Name] = deepCopy(copy)
  maindata.Entitys[player.Name].uuid = player.Name
  maindata.Entitys[player.Name].CustomName = player.Name
  maindata.LoadedEntitys[player.Name] = maindata.Entitys[player.Name]
end)
game.ReplicatedStorage.Debuh.OnServerEvent:Connect(function()
	require(game.ReplicatedStorage.Debughandler):printglobal()
end)
local mainenetity = require(game.ServerStorage.MainEntityHandler)
local data = require(game.ServerStorage.MainData)
local amount = 2
if true then
  --  return
end
for i = 0,amount,1 do
    mainenetity.CreateEntity("Mar",{-math.random(30,120),89,-math.random(80,200)},"Bob"..i)
end
