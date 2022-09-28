
task.spawn(function()
	local compresser = require(game.ReplicatedStorage.Compresser)
	compresser.start()
end)
local copy = { -- a uuid
["Name"] = "Mar",
["Age"] = "0",
["Position"] = {-68,90,-120},
HitBoxSize = {x =2.2,y=7.5,z=2.2},
behaviors = {
},
["NotReplicated"] = {},
EyeOffset = 6.7,
CanFall = true,
MaxJump = 5.9,
JumpWhen = {
	FullJump = 4,
	SmallJump = 2,
},
AutoJump= false,
      Rotation = {0,0,0},
      Events = {},
["NotSaved"] = {Velocity={}},
FallTicks = 0,
MaxFallRate = 3.92,
FallDistance = 0,
}
game.Players.PlayerAdded:Connect(function(player)
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
local maindata = require(game.ServerStorage.MainData)
  maindata.LoadedEntitys[player.Name] = deepCopy(copy)
  maindata.LoadedEntitys[player.Name].uuid = player.Name
  maindata.LoadedEntitys[player.Name].IsPlayer = true
  maindata.LoadedEntitys[player.Name].CustomName = player.Name
  maindata.LoadedEntitys[player.Name] = maindata.LoadedEntitys[player.Name]
end)
require(game.ServerStorage.MainHandler)
game.ReplicatedStorage.Debuh.OnServerEvent:Connect(function()
	require(game.ReplicatedStorage.Debughandler):printglobal()
end)
local mainenetity = require(game.ServerStorage.MainEntityHandler)
local data = require(game.ServerStorage.MainData)
local amount = 9
if true then
  --  return
end
for i = 0,amount,1 do
    mainenetity.CreateEntity("Mar",{-math.random(30,120),89,-math.random(80,200)},"Bob"..i)
	if i ==0 then
	end
end

