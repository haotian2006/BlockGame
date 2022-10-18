local Chunk = {}

Chunk.__index = Chunk
function Chunk.new(cx,cz,data)
    if not cx or not cz then
        warn("Unable to create chunk")
        return nil
    end
    local ch = {}
    setmetatable(ch,Chunk)
    ch.Setttings = data and data.Setttings or {}
    ch.Blocks = {}--data and data.Blocks or {}
    ch.Chunk = {cx,cz}
    return ch
end

function Chunk:GetBlock(x,y,z,debug)
    if x and not tonumber(z) then
        x,y,z,debug = x[1],x[2],x[3],debug
    end
    x,y,z = tonumber(x),tonumber(y),tonumber(z)
    if self.Blocks[x] and self.Blocks[x][y] then
        if debug then
            return nil
        end
        return self.Blocks[x][y][z]
    end
end
function Chunk:GetBlocks()
    return self.Blocks
end
function Chunk:Generate()
    self.Blocks = require(game.ReplicatedStorage.GenerationVersions["pa_1.0-2.0"]).GetChunk(self.Chunk[1]..'x'..self.Chunk[2])
end
function Chunk:InsertBlock(x,y,z,data)
    if x and not tonumber(z) then
        x,y,z,data = x[1],x[2],x[3],y
    end
    self.Blocks[x] = self.Blocks[x] or {}
    self.Blocks[x][y] = self.Blocks[x][y] or {}
    self.Blocks[x][y][z] = data or self.Blocks[x][y][z]
    return self.Blocks[x][y][z]
end
function Chunk:GetNString():string
    return self.Chunk[1].."x"..self.Chunk[2]
end
function Chunk:GetNTuple():IntValue|IntValue
    return self.Chunk[1],self.Chunk[2]
end
function Chunk:Destroy()
    setmetatable(self, nil)
end
return Chunk