local loadchunk = {}
local GenHandler = require(game.ServerStorage.GenerationHandler)
local refunction = require(game.ReplicatedStorage.Functions)
local function pack(pos:Vector3)
	local statement = pos.X..","..pos.Y..","..pos.Z
	return statement
end
function loadchunk.Load(Chunk)
    local blocks = {}
    for index,coord in ipairs(refunction.XZCoordInChunk(Chunk)) do
        for y = 0,80,4 do
            --task.spawn(function()
                local coords = string.split(coord,"x")
                local position = Vector3.new(coords[1],y,coords[2])
                local block,id = GenHandler.GetBlock(position)
                id = 0
                if  block ~= nil and block ~="Air" then
                    local packpos = pack(position)
                    blocks[packpos] = {block,id,nil,packpos}

                end
            --end)
        end
    end
    
    return blocks
end
return loadchunk