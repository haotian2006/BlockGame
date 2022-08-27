local functions = require(game.ReplicatedStorage.Functions)
local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local refunction = require(game.ReplicatedStorage.Functions)
local remotes = game.ReplicatedStorage.Events
local currentlylookingat 
local a = 3
local controlls = {
    KeyBoard = {
        Place = "MouseButton2",
        Destroy = "MouseButton1",
        Foward = "W",
        Backward = "S",
        Left = "A",
        Right = "D",
        Jump = " ",
    },
    Controller = {
    
    },
    TouchScreen = {
    
    },
}
local PlayerNbt 
local ButtonsWork = true
controlls.Update = controlls.Update or {}
local update = controlls.Update
local function GetNormalFromFace(part, normalId)
    return CFrame.new(part.position):VectorToWorldSpace(Vector3.FromNormalId(normalId))
end
local function NormalToFace(normalVector, part)
    local TOLERANCE_VALUE = 1 - 0.001
    local allFaceNormalIds = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Bottom,
        Enum.NormalId.Top,
        Enum.NormalId.Left,
        Enum.NormalId.Right
    }    
    for _, normalId in pairs( allFaceNormalIds ) do
        -- If the two vectors are almost parallel,
        if GetNormalFromFace(part, normalId):Dot(normalVector) > TOLERANCE_VALUE then
            return normalId.Name -- We found it!
        end
    end
    
    return nil -- None found within tolerance.

end
local faces = {
    Front = {0,0,-4},
    Back = {0,0,4},
    Top = {0,4,0},
    Bottom = {0,-4,0},
    Left = {-4,0,0},
    Right = {4,0,0},
}

local function getangle(originalRayVector)
    local new = Vector3.new(1,originalRayVector.Y,1)
    return math.deg(math.atan(new.Unit:Dot(Vector3.new(1,0,1).Unit)))*(originalRayVector.Y/math.abs(originalRayVector.Y))
end
function controlls.Foward(input,gameProcessedEvent)
    local keypressed = false
    local Connection
    Connection = UserInputService.InputEnded:Connect(function(key)
        if key.UserInputType == input or key.KeyCode == input then
            keypressed = true
            remotes.Block.DestroyBlock:FireServer(nil)
            Connection:Disconnect()
        end
    end)
    repeat
            remotes.Block.DestroyBlock:FireServer( currentlylookingat and currentlylookingat.Position)  
        task.wait(0.2)
    until keypressed
end
function controlls.Place(input,gameProcessedEvent)
    if gameProcessedEvent or not ButtonsWork then return end
    local mousepos = UserInputService:GetMouseLocation()
    local pos = camera.CFrame.Position
    local direaction = camera.CFrame.LookVector
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Player.Character}
    local raycast = workspace:Raycast(Player.Character.Head.Position,direaction*16,raycastParams)
    if raycast then
        if raycast.Instance and raycast.Instance:IsDescendantOf(game.Workspace.Chunck) then
            local orientation = {0,0,0}
            local angle =getangle(direaction)
             local dx = math.abs(direaction.X)
             local dz = math.abs(direaction.Z)
             if dx < dz then
                dx = 0
                dz = direaction.Z / dz
             else
                dz = 0
                dx = direaction.X/dx
             end
             if dx == -1 then
                orientation[2] = -90
             elseif dx == 1 then
                orientation[2] = 90
             elseif dz == -1 then
                orientation[2] = 180
             elseif  dz == 1 then
                orientation[2] = 0
             end
            local face = NormalToFace(raycast.Normal,raycast.Instance)
            if not face then return end
            local ddd = Player.Character.Head.Position- raycast.Instance.position
            if angle >=-40 and angle <= - 39 then
                orientation[1] = 90
            elseif angle >= 39 and angle <=  40 then
                orientation[1] = -90
            end
            local newpos = refunction.convertPositionto(refunction.AddPosition(raycast.Instance.position,faces[face]),"table")
            remotes.Block.Place:InvokeServer("Stone",newpos,orientation)


           -- raycast.Instance.Color = Color3.new(0.525490, 0.164705, 0.164705)
        end
    end
end
function controlls.Destroy(input,gameProcessedEvent)
    if gameProcessedEvent or not ButtonsWork then return end
    local keypressed = false
    local Connection
    Connection = UserInputService.InputEnded:Connect(function(key)

        if key.UserInputType == input or key.KeyCode == input then
            keypressed = true
            remotes.Block.DestroyBlock:FireServer(nil)
            Connection:Disconnect()
        end
    end)
    repeat
            remotes.Block.DestroyBlock:FireServer( currentlylookingat and currentlylookingat.Position)  
        task.wait(0.2)
    until keypressed
end
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    for i,v in pairs(controlls.KeyBoard)do
        if v == input.KeyCode.Name or v == input.UserInputType.Name then
            if controlls[i] then
                controlls[i](input,gameProcessedEvent)
            end
        end
    end
end)

function update.OutLines()
    if not Player.Character or not Player.Character.PrimaryPart then return end
    local mousepos = UserInputService:GetMouseLocation()
    local pos = camera.CFrame.Position
    local direaction = camera.CFrame.LookVector*16
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Player.Character}
    local raycast = workspace:Raycast(Player.Character.Head.Position,direaction,raycastParams)
    if raycast then
        if raycast.Instance and raycast.Instance:IsDescendantOf(game.Workspace.Chunck) then
            local angle = math.atan(raycast.Instance.position.Y - Player.Character.Head.Position.Y)
           workspace.Assets.SelectionBox.Adornee = raycast.Instance
           currentlylookingat = raycast.Instance
        else
            workspace.Assets.SelectionBox.Adornee = nil
            currentlylookingat =nil
        end
    else
        workspace.Assets.SelectionBox.Adornee = nil
        currentlylookingat =nil
    end
end
function update.Movement(deltatime)
    PlayerNbt = game.ReplicatedStorage.Events.GetPlayer:InvokeServer(PlayerNbt)
    local LookVector = camera.CFrame.LookVector
    local RightVector = camera.CFrame.RightVector
    local velocity ={0,0,0}
    local keypressed = UserInputService:GetKeysPressed()
    local Foward 
end
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    for i,v in pairs(update)do
        task.spawn(function()
            v(deltaTime)
        end)
    end
end)
return controlls