local event = game.ReplicatedStorage.Events.Entitys.NearByEntitys
local Players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local runservice = game:GetService("RunService")
local controlls = require(script.Parent:WaitForChild("Controlls"))
local entityinfo = require(game.ReplicatedStorage.EntityInfo)
local function createselectionbox(name,color,addorne,size)
    local sel = Instance.new("SelectionBox")
    sel.Color3 = color
    sel.Name = name
    sel.LineThickness = size
    sel.Adornee = addorne
    return sel
end
runservice.Stepped:Connect(function(time, deltaTime)
    if Players.LocalPlayer.Character and Players.LocalPlayer.Character.PrimaryPart and Players.LocalPlayer.Character.PrimaryPart.Position then
    else
        return
    end
	local data = event:InvokeServer(17)
    for i,v in ipairs(workspace.Entity:GetChildren())do

        if data[v.Name] and v.Name ~= game.Players.LocalPlayer.Name  then
            tweenservice:Create(v.PrimaryPart,TweenInfo.new(0),{CFrame= CFrame.new(unpack(data[v.Name]["Position"]))*CFrame.fromOrientation(
                math.rad((data[v.Name].Rotation[1])),
                math.rad((data[v.Name].Rotation[2])),
                math.rad((data[v.Name].Rotation[3]))
            )}):Play()
            local neck = v:FindFirstChild("Neck",true)
            local MainWeld = v:FindFirstChild("MainWeld",true)
            if data[v.Name].NotSaved.NeckRotation then
                tweenservice:Create(neck,TweenInfo.new(0.1),{C0= CFrame.new(neck.C0.Position)*
                    CFrame.fromOrientation(unpack(data[v.Name].NotSaved.NeckRotation))}):Play()
            end
            if data[v.Name].NotSaved.BodyRotation then
                tweenservice:Create(MainWeld,TweenInfo.new(0.1),{C0= CFrame.new(MainWeld.C0.Position)*
                CFrame.fromOrientation(unpack(data[v.Name].NotSaved.BodyRotation))}):Play()
            end
        elseif v.Name ~= game.Players.LocalPlayer.Name then
            v:Destroy()
        end

        data[v.Name] = nil
    end
    
    for uuid,nbt in pairs(data)do
        local entity = game.Workspace:FindFirstChild(nbt["Name"]):Clone()
        local model = Instance.new("Model")
        if nbt.HitBoxSize then
            entity.Size = Vector3.new( nbt.HitBoxSize.x, nbt.HitBoxSize.y, nbt.HitBoxSize.z)
        end
  
        model.Parent = game.Workspace.Entity
        entity.Name = "HitBox"
        entity.CFrame = CFrame.new(0,0,0)
        entity.Parent = model
        model.Name = uuid
        model.PrimaryPart = entity
        local ori = {unpack(nbt["Rotation"])}
		entity.Anchored = true
        entity.CFrame = CFrame.new(unpack(nbt["Position"]))*CFrame.fromOrientation(math.rad(ori[1]),math.rad(ori[2]),math.rad(ori[3]))
        local eyebox = Instance.new("Part")
        eyebox.Color = Color3.new(0.921568, 0, 0)
        eyebox.Material = Enum.Material.Plastic
        eyebox.Size = Vector3.new( nbt.HitBoxSize.x, 0.01, nbt.HitBoxSize.z)
        eyebox.Name = "EyeSight"
        local weld = Instance.new("Weld")
        weld.Part0 = eyebox
        weld.Part1 = entity
        weld.Parent = entity
        eyebox.Parent = entity
        eyebox.Anchored = false
        eyebox.Position = Vector3.new(nbt["Position"][1],nbt["Position"][2]-nbt.HitBoxSize.y/2*math.sign(nbt["Position"][2])+(nbt.EyeOffset or 0 ),nbt.Position[3])
        local eyese = createselectionbox("EyeSelection",Color3.new(1, 0, 0),eyebox,0.025)
        eyese.Parent = model
        local Hiboxes = createselectionbox("HitBoxSelection",Color3.new(0.345098, 0.725490, 0.945098),entity,0.027)
        Hiboxes.Parent = model
        entity.Transparency = 1
        eyebox.Transparency = 1
        local model2
        if entityinfo[nbt.Name] and true then
            local hitboxfloor = entity.CFrame.Y-entity.Size.Y/2
            model2 = entityinfo[nbt.Name].Model:Clone()
            model2.PrimaryPart.Anchored = false
            local middle = hitboxfloor+(model2.PrimaryPart.Position.Y-(model2.PrimaryPart.Position.Y-model2.PrimaryPart.Size.Y/2))
            model2.PrimaryPart.CFrame = CFrame.new(entity.CFrame.X,middle,entity.CFrame.Z)
            local weld2 =Instance.new("Weld")
            weld2.Name = "Entity_To_Model"
            weld2.Part0 = model2.PrimaryPart
            model2.Name = "Model"
            model2.Parent = model
            weld2.Part1 =entity
            weld2.Parent = entity

        end

        if uuid == game.Players.LocalPlayer.Name  then
            
            game.Workspace.CurrentCamera.CameraSubject = eyebox
            game.Players.LocalPlayer.Character.PrimaryPart.Anchored = true
           -- game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(entity.Position.X,  entity.Position.Y,  entity.Position.Z)
        end
	end
end)