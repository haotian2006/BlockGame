local functions = require(game.ReplicatedStorage.Functions)
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local refunction = require(game.ReplicatedStorage.Functions)
local remotes = game.ReplicatedStorage.Events
local currentlylookingat 
local collision_handler = require(game.ReplicatedStorage.CollsionHandler3)
local a = 3
local controlls = {
    KeyBoard = {
        Place = "MouseButton2",
        Destroy = "MouseButton1",
        Foward = "W",
        Backward = "S",
        Left = "A",
        Right = "D",
        Jump = "Space",
    },
    Controller = {
    
    },
    TouchScreen = {
    
    },
}
local keypressed = {}
controlls.FallTicks = 0
controlls.PlayerNbt = nil
controlls.PStuff = nil
controlls.IsOnGround = false
controlls.PlayerPosition = nil
local ButtonsWork = true
controlls.Update = controlls.Update or {}
local update = controlls.Update
local function GetNormalFromFace(part, normalId)
    return CFrame.new(part.position):VectorToWorldSpace(Vector3.FromNormalId(normalId))
end
local function getkeyfromiput(input)
    if input.KeyCode then
        return input.KeyCode.Name
    elseif input.UserInputType then
        return input.UserInputType.Name
    end
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
local function pn(value)
    local values = value/math.abs(value)
    if values ~= values then
        values = 1
    end
    return values
end
function lerp(start, finish, alpha)
    return start + (finish - start)*alpha
end
function LerpVector3(self,finish, alpha)
    self = refunction.convertPositionto(self,"vector3")
    finish = refunction.convertPositionto(finish,"vector3")
    -- implicit definition of self being the Vector3 Lerp is applied on
    return Vector3.new(
        lerp(self.x, finish.x, alpha),
        lerp(self.y, finish.y, alpha),
        lerp(self.z, finish.z, alpha)
    )
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
    local Connection
    repeat
            remotes.Block.DestroyBlock:FireServer( currentlylookingat and currentlylookingat.Position)  
            task.wait()
    until keypressed[getkeyfromiput(input)] == nil
end
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if  input.UserInputType  then
        keypressed[input.UserInputType.Name] = true
    end
    if input.KeyCode then
        keypressed[input.KeyCode.Name] = true
    end
    for i,v in pairs(controlls.KeyBoard)do
        if v == input.KeyCode.Name or v == input.UserInputType.Name then
            if controlls[i] then
                controlls[i](input,gameProcessedEvent)
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if  input.UserInputType  then
        keypressed[input.UserInputType.Name] = nil
    end
    if input.KeyCode then
        keypressed[input.KeyCode.Name] = nil
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
function update.UpdatePosition(delta)
        local entity =  controlls.PlayerNbt
        if not entity then return end 
        if not entity.NotSaved then
            entity.NotSaved = {}
        end
        local Velocity =entity.NotSaved.Velocity
        local total = {0,0,0}
        if  typeof(Velocity) ~= "table"  then return end
        for i,v in pairs(Velocity) do
            total[1] += v[1]
            total[2] += v[2]
            total[3] += v[3]
        end	
        entity.Position = controlls.PlayerPosition
        controlls.IsOnGround = collision_handler.IsGrounded(entity)
       -- print(controlls.IsOnGround )
        local pos = collision_handler.entityvsterrain(entity,total)

        -- total =LerpVector3(entity.Position,goal,delta),"table"
        --local diffrence = refunction.convertPositionto(refunction.SubPosition(goal,total),"table")
       -- controlls.PStuff =   refunction.convertPositionto( entity.Position ,"table" )
        --entity.Position = refunction.convertPositionto(refunction.convertPositionto(refunction.convertPositionto(total,"vector3") +refunction.convertPositionto(entity.Position,"vector3")),"table")
    --    local newposition = collision_handler.Handle(entity,total,controlls.PStuff)
       -- entity.NotSaved.Velocity.Jump = {0,0,0}
       controlls.PlayerPosition = pos
end
local speed = 0.6
function update.Movement(deltatime)
    controlls.PlayerNbt = game.ReplicatedStorage.Events.Entitys.GetPlayer:InvokeServer(controlls.PlayerPosition)
    controlls.PlayerPosition = controlls.PlayerPosition or controlls.PlayerNbt.Position
    controlls.PlayerNbt.Position =  controlls.PlayerPosition
    controlls.FallRate = controlls.FallRate or   controlls.PlayerNbt.NotSaved.Velocity.Fall
    local LookVector = camera.CFrame.LookVector
    local RightVector = camera.CFrame.RightVector
    local velocity ={0,0,0}
    controlls.PlayerNbt.NotSaved.Velocity.Fall =  controlls.FallRate
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z)
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z)
    local foward = LookVector* speed*(keypressed[controlls.KeyBoard.Foward]and 1 or 0)
    local Back = LookVector* -speed*(keypressed[controlls.KeyBoard.Backward]and 1 or 0)
    local Left = RightVector* -speed*(keypressed[controlls.KeyBoard.Left]and 1 or 0)
    local Right = RightVector* speed*(keypressed[controlls.KeyBoard.Right]and 1 or 0)
    local Jump = keypressed[controlls.KeyBoard.Jump]
   local velocity = refunction.convertPositionto(refunction.AddPosition(refunction.AddPosition(foward,Back),refunction.AddPosition(Right,Left)),"table")
   controlls.PlayerNbt.NotSaved.Velocity.PlayerMovement = velocity
   controlls.PlayerNbt.NotSaved.Velocity.Jump = Jump and {0,4,0} or {0,0,0}
   if workspace.Entity:FindFirstChild(Player.Name) then
    game:GetService("TweenService"):Create(workspace.Entity:FindFirstChild(Player.Name),TweenInfo.new(0),{CFrame= CFrame.new(refunction.convertPositionto(controlls.PlayerPosition,"vector3"))}):Play()
   end
end
function  update.HandleFall()
    local entity =   controlls.PlayerNbt
    if not entity then return end 
    local pos =  controlls.PlayerPosition
    local ccx,ccz = refunction.GetChunck(pos)
    if not workspace.Chunck:FindFirstChild(ccx.."x"..ccz) then return end
    entity.NotSaved.Velocity  = entity.NotSaved.Velocity  or {}
    local ysize = entity.HitBoxSize.y or 0

    local fallendistance = entity.FallDistance
    local fallrate = (((0.98^controlls.FallTicks)-1)*entity.maxfallvelocity)
   local ypos = pos[2]
    if controlls.IsOnGround or not entity.CanFall  then
        controlls.FallTicks = 0
        controlls.FallRate = {0,0,0}
    elseif not controlls.IsOnGround and entity.CanFall then
        controlls.FallTicks += 1
        controlls.FallRate = {0,fallrate,0}
    end
end
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    for i,v in pairs(update)do
        task.spawn(function()
            v(deltaTime)
        end)
    end
end)
function controlls.canMove(velocity)
    local entity = controlls.PlayerNbt
    if not entity then return velocity end
    local hitbox = entity.HitBoxSize
    local pos = controlls.PlayerPosition
        for i,v in ipairs(velocity)do
                local currentblock1,normal1,minentry1 = get(velocity,i)
                if i == 2 then
                    --print(currentblock1 and true or false)
                 --"))
                end
                if currentblock1 then
                    pos[i] += velocity[i]*minentry1

                    velocity[i]= normal1[i] ~= 0 and 0 or  velocity[i]
        end
    end
    return velocity
end
return controlls