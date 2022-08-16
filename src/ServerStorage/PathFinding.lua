local MainData = require(game.ServerStorage.MainData)
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local functions = require(RS.Functions)
local heapmanager = require(game.ServerStorage.HeapManager)
local debug = require(game.ReplicatedStorage.Debughandler)
-- debugging
local visualise = false
local OnlyvisualiseFinal = true
local gettimeper = true
local removeold = true
local haveonlyone = true
local displaytext = false

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
    if false then
        return true 
    end
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
local debugcolor ={}
local function visulise(position,yes,uuid,debuguuid)

    local folder = game.Workspace:FindFirstChild("DebugFolder") or Instance.new("Folder",workspace)
    folder.Name = "DebugFolder"

    local foldertwo = folder:FindFirstChild("debug") or folder:FindFirstChild(uuid) or Instance.new("Folder",folder)
    foldertwo.Name = (debuguuid and not haveonlyone) and uuid or "debug"
    local folder3 =  debuguuid and (foldertwo:FindFirstChild(debuguuid)or Instance.new("Folder",foldertwo))
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
    part.BrickColor =  yes and (debugcolor[uuid] or  part.BrickColor)
    if part.bil then
        part.bil.Enabled = displaytext
    end
end
local currentq = {}
local inqueue = {}
local indexxx = 0
function pathfinding.Queue(startposition:table,goal:table,uuid:string,model)
    table.insert(inqueue,uuid)
    while true do
        if #currentq < 2 then
        --    print(uuid,"eee")
            table.insert(currentq,uuid)
            table.remove(inqueue,table.find(inqueue,uuid))
            break
        end
        task.wait()
    end
    indexxx += 1
    task.wait(0.05+(#inqueue/50/10)) 
  --[[ if indexxx >= 50/(#inqueue+1) then
        task.wait(0.05)
        indexxx = 0
    end]]
  --  print(#current)
    if typeof(goal) ~= "table" then
        local playerpos = game.Players:FindFirstChild(goal).Character.PrimaryPart.position
				playerpos = functions.GetFloor(playerpos,true)
			--	print(playerpos)
        goal = convertPositionto(playerpos,"table")
    end
    if typeof(startposition) ~= "table" then
      --  print(MainData.LoadedEntitys[startposition].Position)
				--local pos = convertPositionto(MainData.LoadedEntitys[startposition].Position,"vector3")
             --   print(MainData.LoadedEntitys[startposition].Position)
              local  pos = functions.GetFloor(MainData.LoadedEntitys[startposition].Position)
				--print(pos)
            startposition = pos
    end
   -- print(startposition)
    local path = pathfinding.GetPath(startposition,goal,uuid)
    table.remove(currentq,table.find(currentq,uuid))
    return path
end
local function getRandomBrickColor()
    local randomR = math.random();
    local randomG = math.random();
    local randomB = math.random();
    local randomBrickColor = BrickColor.new(randomR, randomG, randomB);
    return randomBrickColor;
end
function  pathfinding.GetPath(startposition:table,goal:table,uuid:string,model)
  --  print(startposition)
    startposition = convertPositionto(startposition,"vector3")
  --  print(startposition)
    goal = convertPositionto(goal,"vector3")
    local open ={}
    local open2 ={}
    local closed ={}
    local closed2 ={}
    local path 
    local current2 
    local debugfolder = nil
    if removeold then
        debugcolor[uuid] = debugcolor[uuid] or getRandomBrickColor()
        debugfolder = HttpService:GenerateGUID()
    end
    local maxsize =math.clamp(math.abs(startposition.X- goal.X)/4,1,math.huge)*math.clamp(math.abs(startposition.Y- goal.Y)/4,1,math.huge)*math.clamp(math.abs(startposition.Z- goal.Z)/4,1,math.huge)
    --print(math.abs(startposition.Z- goal.Z)/4,math.abs(startposition.Y- goal.Y)/4,math.abs(startposition.X- goal.X)/4,"  ",maxsize)
    startposition = convertPositionto(startposition,"string")
    table.insert(open,{position = startposition,gcost = 0,fcost =0,hcost = 0})
     table.insert(open2,startposition)
   -- heap:add({position = startposition,gcost = 0,fcost =0,hcost = 0})
    local starttimes = DateTime.now().UnixTimestampMillis
    local timesreachedgoal = 0
    local index = 0
    local deb = debug.new(true)
    while #open >0  do--#closed < 400
        if timesreachedgoal >2 then
            break
        end

        local current,index = open[1],1 --eap:RemoveFirst() 
        --print("a")
        
        for index,node in ipairs(open)do
            if node.fcost < current.fcost or node.fcost == current.fcost then
                if node.hcost <current.hcost then
                    current = node
                    index = index
                end
            end
        end
       if DateTime.now().UnixTimestampMillis-starttimes >= 150 -#currentq*3 then break end 
        current2 = current
        table.remove(open,index)
        open2[current2.position] = nil
        table.insert(closed,current)
        closed2[current.position] = true
        if visualise  then
            visulise(current.position,false,uuid,debugfolder)
     end
       -- print(DateTime.now().UnixTimestampMillis-starttime.." ms |")
       deb:set("a")
      --  print("b")
        if convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string") == convertPositionto({functions.GetBlockCoords(convertPositionto(goal,"vector3"))},"string") then
                if gettimeper then
                 --   deb:gettime()
                    print(DateTime.now().UnixTimestampMillis-starttimes.." ms |", convertPositionto(goal,"string").." goal")
                end

        --    print( convertPositionto({functions.GetBlockCoords(convertPositionto(current.position,"vector3"))},"string")," | ", convertPositionto({functions.GetBlockCoords(convertPositionto(goal,"vector3"))},"string"))
            return pathfinding.retracepath(convertPositionto(startposition,"string"),current,uuid,debugfolder),true
        end
     --   print(DateTime.now().UnixTimestampMillis-starttime.." ms |")
     deb:set("b")
  --  print("c")
        for index,neighbor in ipairs(getneighbours(current.position,startposition))do
            --[[if convertPositionto({goal.X,convertPositionto(neighbor.position,"vector3").Y,goal.Y},"string") == neighbor.position then
                timesreachedgoal+= 1 
            end]]
            deb:set("e")
            if     closed2[neighbor.position] or not can(neighbor.position,current) then continue end
            deb:set("eA")
            local newcost = current.gcost + getdistance(current.position,neighbor.position)
            if (newcost<neighbor.gcost) or not open2[neighbor.position] then
                neighbor.gcost = newcost
                neighbor.hcost = getdistance(neighbor.position,goal)
                neighbor.fcost = neighbor.hcost + newcost--getdistance(neighbor.position,startposition)
                neighbor.parent =current
                if not   open2[neighbor.position] then
                        table.insert(open,neighbor)
                        open2[neighbor.position] = "a"
                        deb:set("d")
                        --heap:add(neighbor)
                end
             end
        end
    --    print(DateTime.now().UnixTimestampMillis-starttime.." ms |")

      --  print("d")
    end
    if gettimeper then
        print(DateTime.now().UnixTimestampMillis-starttimes.." ms |", convertPositionto(goal,"string").." goal")
    end

    print("not dsone")
    return {{position = convertPositionto(goal,"string")}}
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