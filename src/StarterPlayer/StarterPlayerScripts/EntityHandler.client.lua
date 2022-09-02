local event = game.ReplicatedStorage.Events.Entitys.NearByEntitys
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
local controlls = require(script.Parent:WaitForChild("Controlls"))
runservice.Stepped:Connect(function(time, deltaTime)
    if Players.LocalPlayer.Character and Players.LocalPlayer.Character.PrimaryPart and Players.LocalPlayer.Character.PrimaryPart.Position then
    else
        return
    end
	local data = event:InvokeServer(17)
    for i,v in ipairs(workspace.Entity:GetChildren())do

        if data[v.Name] and v.Name ~= game.Players.LocalPlayer.Name  then
            tweenservice:Create(v,TweenInfo.new(0.4),{CFrame= CFrame.new(unpack(data[v.Name]["Position"]))*CFrame.Angles(
                math.rad((data[v.Name].Rotation[1])),
                math.rad((data[v.Name].Rotation[2])),
                math.rad((data[v.Name].Rotation[3]))
            )}):Play()
        elseif v.Name ~= game.Players.LocalPlayer.Name then
            v:Destroy()
        end

        data[v.Name] = nil
    end
    
    for uuid,nbt in pairs(data)do
        local entity = game.Workspace:FindFirstChild(nbt["Name"]):Clone()
        if nbt.HitBoxSize then
            entity.Size = Vector3.new( nbt.HitBoxSize.x, nbt.HitBoxSize.y, nbt.HitBoxSize.z)
        end
        entity.Parent = game.Workspace.Entity
        entity.Name = uuid
        entity.Position = Vector3.new(unpack(nbt["Position"]))
        entity.Orientation = Vector3.new(unpack(nbt["Rotation"]))
		entity.Anchored = true
        if uuid == game.Players.LocalPlayer.Name  then
            
            game.Workspace.CurrentCamera.CameraSubject = entity
            game.Players.LocalPlayer.Character.PrimaryPart.Anchored = true
            game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(entity.Position.X,  entity.Position.Y,  entity.Position.Z)
        end
	end
end)