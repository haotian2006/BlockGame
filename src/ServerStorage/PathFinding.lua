local mainhandler = require(game.ServerStorage.MainHandler)
local pathfinding ={}
local function converttovector3(data:table)
    return Vector3.new(unpack(data))   
end
local function converttable(data:Vector3)
    return {data.X,data.Y,data.Z} 
end
local function convertstringtotabl(data:string)
    local splited = string.split(data,",")
    return {splited[1],splited[2],splited[3]}
end
local function converttabletostring(data:table)
    return table[1]..","..table[2]","..table[3]
end
local function can(coord:string)
    
end
local function getneighbours(coords)
    return    
end
function  pathfinding.GetPath(startposition:table,goal:table,nbtdata:table,uuid:string)
    local open ={}
    local closed ={}
    open[converttabletostring(startposition)] ={0,nil}
    while true do
        local current 
        if current == converttabletostring(goal) then
            break
        end

    end
end
return pathfinding