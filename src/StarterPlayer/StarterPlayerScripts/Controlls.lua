local functions = require(game.ReplicatedStorage.Functions)
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local refunction = require(game.ReplicatedStorage.Functions)
local remotes = game.ReplicatedStorage.Events
local currentlylookingat 
local collision_handler = require(game.ReplicatedStorage.CollsionHandler3)
local Current_Entity 
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
local function HandleRotation(bodyjoint,neckjoint,maxrotation,velocity)
	local bx,by,bz = bodyjoint.C0:ToOrientation()
    local nx,ny,nz = neckjoint.C0:ToOrientation()

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
function interpolate(startVector3, finishVector3, alpha)
    local function currentState(start, finish, alpha)
        return start + (finish - start)*alpha

    end

    return {
        currentState(startVector3[1], finishVector3[1], alpha),
        currentState(startVector3[2], finishVector3[2], alpha),
        currentState(startVector3[3], finishVector3[3], alpha)
    }
end
function controlls.Place(input,gameProcessedEvent)
    if gameProcessedEvent or not ButtonsWork then return end
    if  not Current_Entity or not Current_Entity.HitBox or not Current_Entity.HitBox.EyeSight then return end
    local mousepos = UserInputService:GetMouseLocation()
    local pos = camera.CFrame.Position
    local direaction = camera.CFrame.LookVector
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Current_Entity}
    local raycast = workspace:Raycast(Current_Entity.HitBox.EyeSight.Position,direaction*16,raycastParams)
    if raycast then
        if raycast.Instance and raycast.Instance:IsDescendantOf(game.Workspace.Chunk) then
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
             end
             if dz == -1 then
               -- orientation[3] = 180
             elseif  dz == 1 then
                orientation[3] = 0
             end
            local face = NormalToFace(raycast.Normal,raycast.Instance)
            if not face then return end
            local ddd = Player.Character.Head.Position- raycast.Instance.position
            if angle >=-40 and angle <= - 39 then
                orientation[1] = 90
            elseif angle >= 39 and angle <=  40 then
                orientation[1] = -90
            end
            print(orientation)
            local newpos = refunction.convertPositionto(refunction.AddPosition(raycast.Instance.position,faces[face]),"table")
            remotes.Block.Place:InvokeServer("Slab",newpos,orientation)


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
    if  not Current_Entity or not Current_Entity.HitBox or not Current_Entity.HitBox.EyeSight then return end
    local mousepos = UserInputService:GetMouseLocation()
    local pos = camera.CFrame.Position
    local direaction = camera.CFrame.LookVector*16
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {Current_Entity}
    local raycast = workspace:Raycast(Current_Entity.HitBox.EyeSight.Position,direaction,raycastParams)
    if raycast then
        if raycast.Instance and raycast.Instance:IsDescendantOf(game.Workspace.Chunk) then
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
        if total[2] > 0 then 
            --print( total[2])
        end
        entity.Position = controlls.PlayerPosition
        controlls.IsOnGround = collision_handler.IsGrounded(entity)
       -- print(controlls.IsOnGround )
        local pos = collision_handler.entityvsterrain(entity,total)
       controlls.PlayerPosition = interpolate(controlls.PlayerPosition,pos,delta)
end
local speed = 1
local jumpedamount =0 
local jumpheight = 8.7
function update.Movement(deltatime)
    if not controlls.PlayerNbt then   
       local b = game.ReplicatedStorage.Events.Entitys.GetPlayer:InvokeServer(controlls.PlayerPosition)     
       if b then
        controlls.PlayerPosition = b.Position
       controlls.PlayerNbt = b
       else 
        return
       end
    end 
    controlls.PlayerNbt.Position =  controlls.PlayerPosition
    controlls.FallRate = controlls.FallRate or   controlls.PlayerNbt.NotSaved.Velocity.Fall
    local LookVector = camera.CFrame.LookVector
    local RightVector = camera.CFrame.RightVector
    local velocity ={0,0,0}
    controlls.PlayerNbt.NotSaved.Velocity.Fall =  controlls.FallRate
    LookVector = Vector3.new(LookVector.X,0,LookVector.Z).Unit
    RightVector = Vector3.new(RightVector.X,0,RightVector.Z).Unit

    local foward = LookVector* speed*(keypressed[controlls.KeyBoard.Foward]and 1 or 0)
    local Back = LookVector* -speed*(keypressed[controlls.KeyBoard.Backward]and 1 or 0)
    local Left = RightVector* -speed*(keypressed[controlls.KeyBoard.Left]and 1 or 0)
    local Right = RightVector* speed*(keypressed[controlls.KeyBoard.Right]and 1 or 0)
    local Jump = keypressed[controlls.KeyBoard.Jump]
    velocity = refunction.convertPositionto(refunction.AddPosition(refunction.AddPosition(foward,Back),refunction.AddPosition(Right,Left)),"table")
   controlls.PlayerNbt.NotSaved.Velocity.PlayerMovement = velocity
   local jump = jumpheight*deltatime*4.5
   if jumpedamount > 0 and jumpedamount <=jumpheight  then
    jumpedamount += jumpheight*deltatime*4.5
    jump = jumpheight*deltatime*4.5
    controlls.Jumping = true
    else
        controlls.Jumping = false
        jump = 0
        jumpedamount = 0
   end
   if controlls.IsOnGround and Jump and controlls.Jumping == false then
    if jumpedamount == 0 then
        jumpedamount += jumpheight*deltatime*4.5
       -- jump = 4.1*deltatime
    end 
   end
   controlls.PlayerNbt.NotSaved.Velocity.Jump ={0,jump,0}
   if workspace.Entity:FindFirstChild(Player.Name) then
    workspace.Entity:FindFirstChild(Player.Name).PrimaryPart.CFrame = refunction.convertPositionto(controlls.PlayerPosition,"CFrame")
    --game:GetService("TweenService"):Create(workspace.Entity:FindFirstChild(Player.Name),TweenInfo.new(0),{CFrame= CFrame.new(refunction.convertPositionto(controlls.PlayerPosition,"vector3"))}):Play()
   end
end
function  update.HandleFall()
    local entity =   controlls.PlayerNbt
    if not entity then return end 
    local pos =  controlls.PlayerPosition
    local ccx,ccz = refunction.GetChunk(pos)
    if not workspace.Chunk:FindFirstChild(ccx.."x"..ccz)  then return end
    entity.NotSaved.Velocity  = entity.NotSaved.Velocity  or {}
    local ysize = entity.HitBoxSize.y or 0

    local fallendistance = entity.FallDistance
    local fallrate = ((((0.98)^controlls.FallTicks)-1)*entity.maxfallvelocity)/1.3

   local ypos = pos[2]
    if controlls.IsOnGround or not entity.CanFall or controlls.Jumping == true then
        controlls.FallTicks = 0
        entity.NotSaved.Velocity.Fall = {0,0,0}
    elseif not controlls.IsOnGround and entity.CanFall then
        controlls.FallTicks += 1
        entity.NotSaved.Velocity.Fall = {0,fallrate,0}
    end
end
local elapsed = 0
function update.Entity(deltaTime)
    if game.Workspace.Entity:FindFirstChild(Player.Name) then
        Current_Entity =  game.Workspace.Entity:FindFirstChild(Player.Name)
    end
    elapsed += deltaTime
		if elapsed > 0.25 and Current_Entity then
        local neck =  Current_Entity:FindFirstChild("Neck",true)
        local MainWeld = Current_Entity:FindFirstChild("MainWeld",true)
        if neck then
            neck = {neck.C0:ToOrientation()}
        end
        if MainWeld then
            MainWeld = {MainWeld.C0:ToOrientation()}
        end
       local a = game.ReplicatedStorage.Events.Entitys.GetPlayer:InvokeServer(controlls.PlayerPosition,true,neck,MainWeld)
     if a then
        a.Position = nil
     end
       controlls.PlayerNbt = a
        elapsed = 0
	end
end
local follow = false
local oldyy = 180
function update.Camera()
    if game.Workspace.Entity:FindFirstChild(Player.Name) then
        local muti
        local entityw = game.Workspace.Entity:FindFirstChild(Player.Name)
        local Torso = entityw:FindFirstChild("Torso",true)
       local neck =  entityw:FindFirstChild("Neck",true)
       local MainWeld = entityw:FindFirstChild("MainWeld",true)
       if neck and Torso and MainWeld then
        local upordown = math.sign(camera.CFrame.LookVector.Unit:Dot(Vector3.new(0,1,0)))
        local goalCF = CFrame.lookAt(neck.Part1.Position, neck.Part1.Position+camera.CFrame.LookVector, Torso.CFrame.UpVector)
        local xx, yy, zz = refunction.worldCFrameToC0ObjectSpace(neck,goalCF):ToOrientation()
        if math.abs(math.deg(yy)) <= 125 and upordown ==-1 then
           follow = true
        end
        if math.abs(math.deg(yy)) >= 55 and upordown == 1 then
            follow = true
         end
        if (oldyy < math.abs(yy) and upordown == -1 )or  (oldyy > math.abs(yy) and upordown == 1 ) then
            follow = false
        end

        if (keypressed["W"] and not keypressed["S"] or not keypressed["W"] and keypressed["S"] ) and not keypressed["A"] and not keypressed["D"] then
            muti = 0
        end
        if (keypressed["W"] and keypressed["A"] ) or  keypressed["A"] and not keypressed["S"] and not keypressed["D"] then
            muti = 120
        end
        if (keypressed["W"] and keypressed["D"]) or keypressed["D"] and not keypressed["A"] and  not keypressed["S"]  then
            muti = -120
        end
        if not keypressed["W"] and not keypressed["A"] and  keypressed["S"] and  keypressed["D"] then
            muti = 120
        end
        if not keypressed["W"] and  keypressed["A"] and   keypressed["S"]  and keypressed["A"] then
            muti = -120
        end
        if follow ==true or muti then
            local pos =  MainWeld.C0.Position
            local mad = muti
             muti = muti or (upordown == 1 and 50 or 120)
             xx, yy, zz = refunction.worldCFrameToC0ObjectSpace(MainWeld,goalCF*CFrame.fromOrientation(0,muti*(mad and 1 or math.sign(yy)),0)):ToOrientation()
             game:GetService("TweenService"):Create(MainWeld,TweenInfo.new(0.1),{C0 = CFrame.new(pos.X, pos.Y, pos.Z)*CFrame.fromOrientation(0,yy,0)}):Play()
             -- MainWeld.C0 = CFrame.new(pos.X, pos.Y, pos.Z)*CFrame.fromOrientation(0,yy,0)
         end
         xx, yy, zz = refunction.worldCFrameToC0ObjectSpace(neck,goalCF):ToOrientation()
        -- game:GetService("TweenService"):Create(neck,TweenInfo.new(1),{C0 = CFrame.new( neck.C0.X,  neck.C0.Y,  neck.C0.Z)*CFrame.fromOrientation(xx,yy,zz)}):Play()
     neck.C0 = CFrame.new( neck.C0.X,  neck.C0.Y,  neck.C0.Z)*CFrame.fromOrientation(xx,yy,zz)--refunction.worldCFrameToC0ObjectSpace(neck,goalCF)
         oldyy = math.abs(yy)
    end
    end
end
local delayrun = {}
game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    for i,v in pairs(update)do
        task.spawn(function()
            if not delayrun[i] then   
                delayrun[i] = true
                v(deltaTime)
                delayrun[i] = false
            end
        end)
    end
end)
return controlls