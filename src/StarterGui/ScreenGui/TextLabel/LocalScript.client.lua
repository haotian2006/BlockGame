local functions = require(game.ReplicatedStorage.Functions)
while true do
	task.wait(0.5)
	local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	local position = character.PrimaryPart.Position
	local CX,CY = functions.GetChunk(position)
	script.Parent.Text = "Chunk "..CX.."|"..CY
end