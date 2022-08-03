local mainhandler = require(game.ServerStorage.MainHandler)
local pathfinding ={}
local function returnstringcomponets(data:string)
    local splited = string.split(data,",")
    return splited[1],splited[2],splited[3]
end
local function convertPositionto(cout,etype)
    return functions.convertPositionto(cout,etype)
end
local function convertheighttomax(height)
    local divided = height / 4
	local rounded = 4 * math.floor(divided)
	if rounded < height then
		rounded +=4
	end
    return rounded
end
local function can(coord:string,currenty,model)
    local x,y,z = returnstringcomponets(coord)
    local height = model.Size.Y
    local width = model.Size.X
    local diffrence = y - currenty
    if diffrence == -4 then
        height+=4  
    end
    local can = false
    if mainhandler.LoadedBlocks[coord] then
        can = true
        for i = 1 ,convertheighttomax(height),1 do
            if mainhandler.LoadedBlocks[convertPositionto({x,y+4*i,z,"string"})]then
                if mainhandler.BlockNbt[convertPositionto({x,y+4*i,z,"string"})] then
                    if  mainhandler.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].Open and mainhandler.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].Open.Value then
                        continue
                    end
                    if  mainhandler.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].CanCollide and  mainhandler.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].CanCollide.Value == true then
                        return false
                    end
                else
                    return false
                end
            end
        end
        for i = 1 ,convertheighttomax(width),1 do
            
        end
        local mx,my,mz = x - cx , y- cy, z-cz
        if (mx == 4 and (mz == 4 or mz == -4)) or (mz == 4 and (mx == 4 or mx == -4))   then -- check if this is a corner
        local C1,C2 = true,true 
            for i = 1 ,convertheighttomax(height),1 do -- checks if the height fits
                local positon = convertPositionto({cx+mx,y+4*i,cz},"string")
                local positon1 = convertPositionto({cx,y+4*i,cz+mz},"string")
                if mainhandler.LoadedBlocks[positon]then
                    if mainhandler.BlockNbt[positon] then
                        if  mainhandler.BlockNbt[positon].Open and mainhandler.BlockNbt[positon].Open.Value then
                            continue
                        end
                        if  mainhandler.BlockNbt[positon].CanCollide and  mainhandler.BlockNbt[positon].CanCollide.Value == true then
                            C1 = false
                            break
                        end
                    else
                        C1 = false
                        break
                    end
                end
                if mainhandler.LoadedBlocks[positon1]then
                    if mainhandler.BlockNbt[positon1] then
                        if  mainhandler.BlockNbt[positon1].Open and mainhandler.BlockNbt[positon1].Open.Value then
                            continue
                        end
                        if  mainhandler.BlockNbt[positon1].CanCollide and  mainhandler.BlockNbt[positon1].CanCollide.Value == true then
                            C2= false
                            break
                        end
                    else
                        C2 = false
                        break
                    end
                end
            end 

        end
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