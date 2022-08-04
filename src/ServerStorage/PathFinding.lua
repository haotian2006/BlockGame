local MainData = require(game.ServerStorage.MainData)
local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)

-- debugging
local visualise = true
local OnlyvisualiseFinal = false

local pathfinding ={}
local function convertPositionto(cout,etype)
    return functions.convertPositionto(cout,etype)
end
local function returnstringcomponets(data)
    data = convertPositionto(data,"string")
    local splited = string.split(data,",")
    return splited[1],splited[2],splited[3]
end
local function convertheighttomax(height)
    local divided = height / 4
	local rounded = 4 * math.floor(divided)
	if rounded < height then
		rounded +=4
	end
    return rounded
end
local onceeeee = true
local function getblockfromchunck(coordnites)
    local chunck,z = functions.GetChunck(convertPositionto(coordnites,"vector3"))
    chunck = MainData.Chunck[chunck.."x"..z]
    if chunck then
    return chunck[coordnites] or nil
    else
        return nil
    end
end
local function can(coord:string,current,model)
    local cx,cy,cz = returnstringcomponets(current.position)
   
local vector =  {functions.GetBlockCoords(convertPositionto(coord,"vector3"))}

    local gridpos = convertPositionto(
        
            {vector[1]*4,vector[2]*4,vector[3]*4}
        
    ,"string")
    local x,y,z = returnstringcomponets(coord)
    local height = 4--model.Size.Y
   -- local width = model.Size.X
    local diffrence = y - cy
    if diffrence == -4 then
        height+=4  
    end
    x,y,z = returnstringcomponets(gridpos)
    local can = false
    if getblockfromchunck(gridpos) then
        can = true
        for i = 1 ,convertheighttomax(height),1 do -- checks if the height fits
            if MainData.LoadedBlocks[convertPositionto({x,y+4*i,z},"string")]then
                if MainData.BlockNbt[convertPositionto({x,y+4*i,z},"string")] then
                    if  MainData.BlockNbt[convertPositionto({x,y+4*i,z},"string")].Open and MainData.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].Open.Value then
                        continue
                    end
                    if  MainData.BlockNbt[convertPositionto({x,y+4*i,z},"string")].CanCollide and  MainData.BlockNbt[convertPositionto({x,y+4*i,z,"string"})].CanCollide.Value == true then
                        return false
                    end
                else
                    return false
                end
            end
        end
        -- checks if its wide enought wip
      --  for i = 1 ,convertheighttomax(width),1 do
            
        --end
       --[[ local mx,my,mz = x - cx , y- cy, z-cz
        if (mx == 4 and (mz == 4 or mz == -4)) or (mz == 4 and (mx == 4 or mx == -4))   then -- check if this is a corner
        local C1,C2 = true,true 
            for i = 1 ,convertheighttomax(height),1 do -- checks if the height fits
                local positon = convertPositionto({cx+mx,y+4*i,cz},"string")
                local positon1 = convertPositionto({cx,y+4*i,cz+mz},"string")
                if MainData.LoadedBlocks[positon]then
                    if MainData.BlockNbt[positon] then
                        if  MainData.BlockNbt[positon].Open and MainData.BlockNbt[positon].Open.Value then
                            continue
                        end
                        if  MainData.BlockNbt[positon].CanCollide and  MainData.BlockNbt[positon].CanCollide.Value == true then
                            C1 = false
                            break
                        end
                    else
                        C1 = false
                        break
                    end
                end
                if MainData.LoadedBlocks[positon1]then
                    if MainData.BlockNbt[positon1] then
                        if  MainData.BlockNbt[positon1].Open and MainData.BlockNbt[positon1].Open.Value then
                            continue
                        end
                        if  MainData.BlockNbt[positon1].CanCollide and  MainData.BlockNbt[positon1].CanCollide.Value == true then
                            C2= false
                            break
                        end
                    else
                        C2 = false
                        break
                    end
                end
            end 
            if not C1 and not C2 then
                return false
            end
        end]]
    end
    return can
end
local function ReverseTable(t:table)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

local function getdistance(pos1,pos2)
    return functions.GetMagnituide(pos1,pos2)
end
local function getneighbours(coords:string,start)
    local x,y,z = returnstringcomponets(coords)
    local data = {}
    for cx = x+4 ,x-4,-4 do
        for cy = y+4 ,y-4,-4 do
            for cz = z+4 ,z-4,-4 do
                    table.insert(data,{position =cx..","..cy..","..cz,gcost = getdistance(cx..","..cy..","..cz,start)})
            end
        end
    end
    return data
end
local function visulise(position,yes)
    local part = yes and script.Debug:clone() or Instance.new("Part")
    part.Size = Vector3.new(1,1,1)
    part.Position = convertPositionto(position,"vector3")
    part.Anchored = true
    part.Material = Enum.Material.Neon
    part.Parent = workspace
    part.Name = "debugged"
end
function  pathfinding.GetPath(startposition:table,goal:table,nbtdata:table,uuid:string,model)
    local open ={}
    local open2 ={}
    local closed ={}
    local closed2 ={}
    local path 
    local current2 
    table.insert(open,{position = startposition,gcost = 0,fcost =0,hcost = 0})
     table.insert(open2,startposition)
    while #open >0 and  #closed <200 do
        
        local current = open[1]
        for index,node in ipairs(open)do
            if node.fcost < current.fcost or node.fcost == current.fcost then
                if node.hcost <current.hcost then
                    current = node
                end
            end
        end
        current2 = current
        table.remove(open,table.find(open2,current.position))
        table.remove(open2,table.find(open2,current.position))
        table.insert(closed,current)
        table.insert(closed2,current.position)
        if visualise  then
            visulise(current.position)
        end
        if convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string") == convertPositionto({functions.GetBlockCoords(convertPositionto(goal,"vector3"))},"string") then
            print(#closed)
        --    print( convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string")," | ", convertPositionto({functions.GetBlockCoords(convertPositionto(goal,"vector3"))},"string"))
            return pathfinding.retracepath(convertPositionto(startposition,"string"),current),true
        end
    

        for index,neighbor in ipairs(getneighbours(current.position,startposition))do
            if table.find(closed2,neighbor.position) or not can(neighbor.position,current) then continue end
            local newcost = current.gcost + getdistance(current.position,neighbor.position)
            if (newcost<neighbor.gcost) or not table.find(open2,neighbor.position) then
                neighbor.gcost = newcost
                neighbor.hcost = getdistance(neighbor.position,goal)
                neighbor.fcost = neighbor.hcost + getdistance(neighbor.position,startposition)
                neighbor.parent =current
                if not table.find(open2,neighbor.position) then
                        table.insert(open,neighbor)
                        table.insert(open2,neighbor.position)
                end
             end
        end
    end
    print("not dsone")
    return current2 and pathfinding.retracepath(convertPositionto(startposition,"string"),current2) or nil,false
end
function pathfinding.retracepath(start,goal)
    local path = {}
    local current = goal
    while convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string") ~= convertPositionto({functions.GetBlockCoords(convertPositionto(start,"vector3"))},"string") do
        table.insert(path,current)
        if  OnlyvisualiseFinal then
            visulise(current.position,true)
        end
        current = current.parent
    end
    return ReverseTable(path)
end
return pathfinding