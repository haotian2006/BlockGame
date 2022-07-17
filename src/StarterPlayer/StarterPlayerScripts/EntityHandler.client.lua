local event = game.ReplicatedStorage.Events.Entitys.NearByEntitys
local runservice = game:GetService("RunService")
runservice.Stepped:Connect(function(time, deltaTime)
    local data = event:InvokeServer(3)
    for i,v in ipairs(workspace.Entity:GetChildren())do
        if data[v.Name] then
            v.CFrame = CFrame.new(unpack(data[v.Name]["CFrame"]))
            data[v.Name] = nil
        else
            v:Destroy()
        end
    end
    for uuid,nbt in pairs(data)do
        local entity = game.Workspace:FindFirstChild(nbt["Name"]):Clone()
        entity.Parent = game.Workspace.Entity
        entity.Name = uuid
        entity.CFrame = CFrame.new(unpack(nbt["CFrame"]))

    end
end)