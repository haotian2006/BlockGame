local uis = game:GetService("UserInputService")
local movmenetstuff = {
	["W"] = {1,0,0},
    ["A"] = {0,0,1},
    ["S"] = {0,1,-1},
    ["D"] = {-1,0,0},
    [" "] = {0,4,0}
}
local currentlypressing = {}
uis.InputBegan:Connect(function(input, gameProcessedEvent)
	if movmenetstuff[uis:GetStringForKeyCode(input.KeyCode)] then
        currentlypressing[uis:GetStringForKeyCode(input.KeyCode)] = true
    end
end)
uis.InputEnded:Connect(function(input, gameProcessedEvent)
	if movmenetstuff[uis:GetStringForKeyCode(input.KeyCode)] then
        currentlypressing[uis:GetStringForKeyCode(input.KeyCode)] = nil
    end
end)
while true do
	local text = ""
	for i,v in pairs(currentlypressing)do
		text ..= i..","
	end
    local LookVector = workspace.CurrentCamera.CFrame.LookVector
    local roundedvec = {LookVector.X/math.abs(LookVector.X),LookVector.Y/math.abs(LookVector.Y),LookVector.Z/math.abs(LookVector.Z)}
	game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("keys").Text = "KeysPress: "..text
    game.ReplicatedStorage.Events.Entitys.PlayerMove:FireServer(currentlypressing,LookVector,workspace.CurrentCamera.CFrame.RightVector)
    task.wait()
end