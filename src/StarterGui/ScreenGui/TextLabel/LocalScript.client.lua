local functions = require(game.ReplicatedStorage.Functions)
while true do
	task.wait(0.5)
	local character = game.Workspace.Entity:WaitForChild(game.Players.LocalPlayer.Name)
	local position = character.PrimaryPart.Position
	local CX,CY = functions.GetChunk(position)
	script.Parent.Text = "Chunk "..CX.."|"..CY
end