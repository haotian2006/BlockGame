local ProximityPromptService = game:GetService("ProximityPromptService")
local data = {}
local refunctions = require(game.ReplicatedStorage.Functions)
local Block_Path = require(game.ReplicatedStorage.BlockInfo)
local tex = game.ReplicatedStorage.Block_Texture
function data.LoadChunk(blocks)
local folder = {}
local index = 0
  for pos,data in pairs(blocks)do
    index +=1
    if index%350==0 then
      task.wait(.05)
    end
    local part
    local name = data[1]
    local fr = 1
    if not Block_Path[name] then
      continue
    end
    local model =  Block_Path[name].Model
    local sp 
    local text,meshid = tex:FindFirstChild(name) and tex:FindFirstChild(name):FindFirstChild("Decal") and  tex:FindFirstChild(name):FindFirstChild("Decal").Texture
    if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
        part = model
        fr = 2
    elseif not model:IsA("Model") and #model:GetChildren() ~= 0 then
      part = model
      fr = 3
    elseif not model:IsA("Model") then
        part = Block_Path[name].Model
        meshid = model.MeshId
        model = nil
        sp = Instance.new("SpecialMesh")
    end
    local clonepart = fr ~=1 and part
    local mesh = (fr == 1 and nil) or Instance.new("Part")
    local offset = refunctions.convertPositionto(refunctions.GetOffset(name),"CFrame")
    local id = data[2]
    local ori = data[3]
    if ori then
		ori = refunctions.convertPositionto(ori,"vector3")
	else
		ori = Vector3.new(0,0,0)
	end
    local cframe = refunctions.convertPositionto(pos,"CFrame")* CFrame.Angles(math.rad(ori.X),math.rad(ori.Y),math.rad(ori.Z))*offset:Inverse()
    table.insert(folder,{{mesh,text,meshid,sp},cframe,name,id,fr ==1 and part.Size,pos,clonepart,fr})
  end
 -- print(index)
  return folder
end
return data