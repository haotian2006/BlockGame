local MainData = require(game.ServerStorage.MainData)
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)
local heapmanager = require(game.ServerStorage.HeapManager)
-- debugging
local visualisecurrent = false
local visualiseneightborhs = false
local OnlyvisualiseFinal = true
local gettimeper = true
local removeold = true

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
    if diffrence == -4  then  
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

local function getdistance(pos1,pos2,uuid,debuguuid)
    return functions.GetMagnituide(pos1,pos2)
end
local function visulise(position,yes,uuid,debuguuid)

    local folder = game.Workspace:FindFirstChild("DebugFolder") or Instance.new("Folder",workspace)
    folder.Name = "DebugFolder"
    local foldertwo = folder:FindFirstChild("debug") or folder:FindFirstChild("uuid") or Instance.new("Folder",folder)
    foldertwo.Name = debuguuid and uuid or "debug"
    local folder3 = debuguuid and (foldertwo:FindFirstChild(debuguuid)or Instance.new("Folder",foldertwo))
    if folder3 then
        folder3.Name = debuguuid
        for i,v in ipairs(foldertwo:GetChildren())do
            if v.Name ~= debuguuid then
                v:Destroy()
            end
        end
    end
    local part = yes and script.Parent.Debug:clone() or Instance.new("Part")
    part.Size = Vector3.new(1,1,1)
    part.Position = convertPositionto(position,"vector3")
    part.Position = Vector3.new(part.Position.X, part.Position.Y+4, part.Position.Z)
    part.Anchored = true
    part.Material = Enum.Material.Neon
    part.Parent = folder3 or foldertwo
    part.Name = "debugged"
    part.CanCollide = false
    part.Transparency = 0.5
end
local function getneighbours(coords:string,start,uuid,debugfolder)
    local x,y,z = returnstringcomponets(coords)
    local data = {}
    for cx = x+4 ,x-4,-4 do
        for cy = y+4 ,y-4,-4 do
            for cz = z+4 ,z-4,-4 do
                    table.insert(data,{position =cx..","..cy..","..cz,gcost = getdistance(cx..","..cy..","..cz,start)})
                    if visualiseneightborhs then
                    visulise(cx..","..cy..","..cz,false,uuid,debugfolder)                 
                 end
            end
        end
    end
    return data
end

function  pathfinding.GetPath(startposition,goal,uuid:string,model)
    startposition = convertPositionto(startposition,"vector3")
    goal = convertPositionto(goal,"vector3")
    local open ={}
    local open2 ={}
    local closed ={}
    local closed2 ={}
    local path 
    local current2 
    
    local debugfolder = nil
    if removeold then
        debugfolder = HttpService:GenerateGUID()
    end
    local heap = heapmanager.new(10)
     table.insert(open2,startposition)
    heap:add({position = startposition,gcost = 0,fcost =0,hcost = 0})
    open = heap.Items
    local starttime = DateTime.now().UnixTimestampMillis
    local timesreachedgoal = 0
    local index = 0
    local maxsize =math.clamp(math.abs(startposition.X- goal.X)/4,1,math.huge)*math.clamp(math.abs(startposition.Y- goal.Y)/4,1,math.huge)*math.clamp(math.abs(startposition.Z- goal.Z)/4,1,math.huge)
    maxsize = maxsize + maxsize/3
    print(math.abs(startposition.Z- goal.Z)/4,math.abs(startposition.Y- goal.Y)/4,math.abs(startposition.X- goal.X)/4,"  ",maxsize)
    startposition = convertPositionto(startposition,"string")
    while heap.CurrentSize >0 do--#closed < 400
        if timesreachedgoal >1 then
            break
        end
        index += 1 
        local current = heap:RemoveFirst() 
        current2 = current
        table.remove(open2,table.find(open2,current.position))
        table.insert(closed,current)
        table.insert(closed2,current.position)
        if visualisecurrent  then
            visulise(current.position,false,uuid,debugfolder)
        end
        if convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string") == convertPositionto({functions.GetBlockCoords(convertPositionto(goal,"vector3"))},"string") then
                if gettimeper then
                    print(DateTime.now().UnixTimestampMillis-starttime.." ms |", convertPositionto(goal,"string").." goal")
                end
            return pathfinding.retracepath(convertPositionto(startposition,"string"),current,uuid,debugfolder),true
        end
    
        for index,neighbor in ipairs(getneighbours(current.position,startposition,uuid,debugfolder))do
            if convertPositionto({goal.X,convertPositionto(neighbor.position,"vector3").Y,goal.Y},"string") == neighbor.position then
                timesreachedgoal+= 1 
            end
            if table.find(closed2,neighbor.position) or not can(neighbor.position,current)   then continue end
            local newcost = current.gcost + getdistance(current.position,neighbor.position)
            if (newcost<neighbor.gcost) or not table.find(open2,neighbor.position) then
                neighbor.gcost = newcost
                neighbor.hcost = getdistance(neighbor.position,goal)
                neighbor.fcost = neighbor.hcost + newcost--getdistance(neighbor.position,startposition)
                neighbor.parent =current
                if not table.find(open2,neighbor.position) then
                        table.insert(open2,neighbor.position)
                        heap:add(neighbor)
                end
             end
        end
    end
    if gettimeper then
        print(DateTime.now().UnixTimestampMillis-starttime.." ms |", convertPositionto(goal,"string").." goal")
    end

    print("not dsone")
    return {position = convertPositionto(goal,"string")}
end
function pathfinding.retracepath(start,goal,uuid,debugfolder)
    local path = {}
    local current = goal
    while convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string") ~= convertPositionto({functions.GetBlockCoords(convertPositionto(start,"vector3"))},"string") do
        table.insert(path,current)
        if  OnlyvisualiseFinal then
            visulise(current.position,true,uuid,debugfolder)
        end
        current = current.parent
    end
    return ReverseTable(path)
end
return pathfinding