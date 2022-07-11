local functions = require(game.ReplicatedStorage.Functions)
while true do
	task.wait(0.5)
	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local position = character.PrimaryPart.Position
	local CX,CY = functions.GetChunck(position)
	script.Parent.Text = "Chunck "..CX.."|"..CY
end