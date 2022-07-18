local event = game.ReplicatedStorage.Events.Entitys.NearByEntitys
local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
runservice.Stepped:Connect(function(time, deltaTime)
	local data = event:InvokeServer(17)
    for i,v in ipairs(workspace.Entity:GetChildren())do
        if data[v.Name] then
            tweenservice:Create(v,TweenInfo.new(0.5),{CFrame= CFrame.new(unpack(data[v.Name]["Position"]))*CFrame.Angles(
                math.rad((data[v.Name].Rotation[1])),
                math.rad((data[v.Name].Rotation[2])),
                math.rad((data[v.Name].Rotation[3]))
            )}):Play()
          --  v.CFrame = CFrame.new(unpack(data[v.Name]["CFrame"]))
            data[v.Name] = nil
        else
            v:Destroy()
        end
    end
    
    for uuid,nbt in pairs(data)do
        local entity = game.Workspace:FindFirstChild(nbt["Name"]):Clone()
        entity.Parent = game.Workspace.Entity
        entity.Name = uuid
        entity.Position = Vector3.new(unpack(nbt["Position"]))
        entity.Orientation = unpack(nbt["Rotation"])
		entity.Anchored = true
	end
end)