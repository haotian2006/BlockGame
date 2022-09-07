local data = {}
local refunctions = require(game.ReplicatedStorage.Functions)
local Block_Path = require(game.ReplicatedStorage.BlockInfo)
function data.LoadChunk(blocks)
local folder = {}
  for pos,data in pairs(blocks)do

    local part
    local name = data[1]
    local model =  Block_Path[name].Model
    if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
        part = model.MainPart
    elseif not model:IsA("Model") then
        part = Block_Path[name].Model
    end
    local mesh = Instance.new("MeshPart")
    local offset = refunctions.convertPositionto(refunctions.GetOffset(name),"CFrame")
    local id = data[2]
    local ori = data[3]
    if ori then
		ori = refunctions.convertPositionto(ori,"vector3")
	else
		ori = Vector3.new(0,0,0)
	end
    local cframe = refunctions.convertPositionto(pos,"CFrame")* CFrame.Angles(math.rad(ori.X),math.rad(ori.Y),math.rad(ori.Z))*offset
    table.insert(folder,{mesh,cframe,name,id,part.Size})
  end
  return folder
end
return data