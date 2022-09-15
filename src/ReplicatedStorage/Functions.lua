local RS = game:GetService("ReplicatedStorage")
local Block_Path = require(RS.BlockInfo)
local Block_Modle = RS.Block_Models
local Block_Texture = RS.Block_Texture
local maindata 
local Function = {}
script.Parent.GetFunctions.OnInvoke = function()
	return Function
end
if game:GetService("RunService"):IsServer() then
	maindata = require(game.ServerStorage.MainData)
end

local function Round(x:number)
	local m = x/math.abs(x)
	--x = math.abs(x)
	return math.floor(x+0.5)
end
local function Round2(x:number)
	local m = x/math.abs(x)
	x = math.abs(x)
	return math.floor(x+0.5)*m
end
function Function.GetVector3Componnets(pos:Vector3)
	return pos.X,pos.Y,pos.Z
end
function Function.ConvertValuetoablock(value)
	return Round((0 + value)/4)
end
function Function.convertvaluetoreal(value,typ,size)
	local size = size or 4
	if typ == -1 then
		return Round2((0 + value)/size)*size
	end
	return Round((0 + value)/size)*size
end
function Function.returnDatastringcomponets(data:string)
    local splited = string.split(data,",")
    return splited[1],splited[2],splited[3]
end

function Function.GetMagnituide(pos1:string,pos2:string)
	pos1 = Function.convertPositionto(pos1,"string")
    pos2 = Function.convertPositionto(pos2,"string")
	local x,y,z = Function.returnDatastringcomponets(pos1)
	local x2,y2,z2 = Function.returnDatastringcomponets(pos2)
	return math.sqrt((x2-x)^2+(y2-y)^2+(z2-z)^2)
end
function Function.GetUnit(pos1,pos2)
	pos1 = Function.convertPositionto(pos1,"vector3")
	pos2 = Function.convertPositionto(pos2,"vector3")
	return (pos1-pos2).Unit
end
function Function.GetBlockCoords(Position,retype)
	local Position = Function.convertPositionto(Position,"vector3")
	local x = Round((0 + Position.X)/4)
	local z = Round((0 + Position.Z)/4)
	local y = Round((0 + Position.Y)/4)
	if retype then
		return Function.convertPositionto({x,y,z},retype) 
	end
	return x,y,z
end
function Function.GetChunk(Position)
	Position = Function.convertPositionto(Position,"vector3")
	local x,y,z = Function.GetBlockCoords(Position)
	local cx =	Round(x/16)
	local cz= 	Round(z/16)
	return cx,cz
end
function Function.convertPositionto(cout,etype)
	etype = etype or "string"
    local ty = typeof(cout)
	ty = string.lower(ty)
	etype = string.lower(etype)
    local x,y,z 
    local ret 
    if ty == "string" then
        local splited = string.split(cout,",")
        x,y,z = unpack(splited)
    elseif ty == "table" then
        x,y,z = unpack(cout)
    elseif ty =="vector3" or ty =="cframe" then
        x,y,z = cout.X,cout.Y,cout.Z
	else
		warn(cout,"is a(n) "..ty.." which is not a valid input")
		etype ="skip"
    end
	x,y,z = tonumber(x),tonumber(y),tonumber(z)
    if etype == "string" then
        ret = x..","..y..","..z
    elseif etype == "table" then
        ret = {x,y,z}
     elseif etype =="vector3" then
        ret = Vector3.new(x,y,z)
	elseif etype =="cframe" then
		ret = CFrame.new(x,y,z)
	elseif etype =="skip" then
	 else
		warn(etype,"is not a valid input")
    end
    return ret
end 
function Function.LoadCharacter(Player)
	
end
function Function.GetBlock(pos,HasToBeLoaded,playerpos)
	pos = Function.ConvertPositionToReal(pos,"table")
	local pcx,pcz 
	if playerpos then
		pcx,pcz = Function.GetChunk(playerpos)

	end
	if maindata then  
	pos = Function.convertPositionto(pos,"vector3")
	local x,y,z = Function.returnDatastringcomponets(Function.ConvertGridToReal(Function.GetBlockCoords(pos,"table"),"string"))
	local cx,cz = Function.GetChunk(Vector3.new(pos.X,y,pos.Z))
	if maindata.DecodedChunks[cx.."x"..cz] and maindata.DecodedChunks[cx.."x"..cz][x..","..y..","..z] and not HasToBeLoaded then
		return maindata.DecodedChunks[cx.."x"..cz][x..","..y..","..z],x..","..y..","..z
	elseif maindata.DecodedChunks[cx.."x"..cz] and maindata.DecodedChunks[cx.."x"..cz][x..","..y..","..z]  and HasToBeLoaded then
		return maindata.DecodedChunks[cx.."x"..cz][x..","..y..","..z],x..","..y..","..z
	elseif not maindata.DecodedChunks[cx.."x"..cz] and  playerpos and (pcx ~= cx or pcz ~= cz) then
		return {"Stone",1,{0,0,0},{x,y,z}},x..","..y..","..z
	end
	return nil
	else
		pos = Function.ConvertPositionToReal(pos,"string")
		local cx,cz = Function.GetChunk(pos)
		if workspace.Chunk:FindFirstChild(cx.."x"..cz) and workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(pos) then
			local blocka = workspace.Chunk:FindFirstChild(cx.."x"..cz):FindFirstChild(pos)
			local mainbb 
			if blocka:IsA("Model") then
				mainbb = blocka:FindFirstChild("MainPart") or blocka.PrimaryPart or blocka
			end
			return {blocka:GetAttribute("Name"),blocka:GetAttribute("State"),Function.convertPositionto(mainbb and mainbb.Orientation or blocka.Orientation,"table"),Function.convertPositionto(pos,"table")},pos
		elseif not workspace.Chunk:FindFirstChild(cx.."x"..cz) and playerpos and (pcx ~= cx or pcz ~= cz) then
			--("e")
			return {"Stone",1,{0,0,0},Function.convertPositionto(pos,"table")},pos
		end
		if  not workspace.Chunk:FindFirstChild(cx.."x"..cz) and playerpos then
			--print(pcx ~= cx or pcz ~= cz) 
		end
		return nil
	end
end
function Function.ConvertGridToReal(positon,typeofp)
	local converted = Function.convertPositionto(positon,"table")
	return Function.convertPositionto({converted[1]*4,converted[2]*4,converted[3]*4},typeofp)
end
function Function.ConvertPositionToReal(position,typ)
	if typ then
		return Function.ConvertGridToReal(Function.GetBlockCoords(position,"table"),typ)
	end
	return Function.ConvertGridToReal(Function.GetBlockCoords(position,"table"),"table")
end 
function Function.GetSurroundingChunk(Position:Vector3,render:number)
	local cx,cz =  Function.GetChunk(Position)
	local coords ={cx.."x"..cz}
	for i = 1,render,1 do
		local placeholder = {unpack(coords)}
		for index,name in ipairs(placeholder)do
			local c_coords = string.split(name,"x")
			local x,z =tonumber(c_coords[1]),tonumber(c_coords[2])
			if not table.find(coords,(x-1).."x"..z) then table.insert(coords,(x-1).."x"..z) end
			if not table.find(coords,(x+1).."x"..z) then table.insert(coords,(x+1).."x"..z) end
			if not table.find(coords,x.."x"..(z-1)) then table.insert(coords,x.."x"..(z-1)) end
			if not table.find(coords,x.."x"..(z+1)) then table.insert(coords,x.."x"..(z+1)) end
		end
	end
	return coords
end
function Function.XZCoordInChunk(chunk:string)
	local name =string.split(chunk,"x")
	local cx,cz = name[1],name[2]
	local coord0chunkoffset =  Vector3.new(cx*4*16,0,cz*4*16)
	local coord0chunk = Vector3.new(0,0,0) + coord0chunkoffset
	local Cornerx,Cornerz =Vector2.new(-32+cx*64,-32+cz*64) ,Vector2.new(28+cx*64,28+cz*64)
	local pos = {}
	for x = Cornerx.X, Cornerz.X,4 do
		for z = Cornerx.Y,Cornerz.Y,4 do
			table.insert(pos,x.."x"..z)
		end
	end
	return pos
end
function Function.AddPosition(Position,Position2)
	return Function.convertPositionto(Position,"vector3") + Function.convertPositionto(Position2,"vector3")
end
function Function.SubPosition(Position,Position2)
	return Function.convertPositionto(Position,"vector3") - Function.convertPositionto(Position2,"vector3")
end
local rotationstuffaaaa = {
	["0,0,0"] = function(datao) return datao end,
	["0,1,0"] = function(datao) return {datao[3],datao[2],datao[1]} end,
	["0,1,1"] = function(datao) return {datao[3],datao[1],datao[2]} end,
	["1,1,0"] = function(datao) return {datao[2],datao[3],datao[1]} end,
	["1,0,0"] = function(datao) return {datao[1],datao[3],datao[2]} end,
	["0,0,1"] = function(datao) return {datao[2],datao[1],datao[3]} end,
}
function Function.DealWithRotation(blockdata)
    local hpos = blockdata[4]
    local orientation = blockdata[3]
    local setup = {
        math.abs(orientation[1])== 90 and 1 or 0,
        math.abs(orientation[2])== 90 and 1 or 0,
        math.abs(orientation[3])== 90 and 1 or 0,
    }
    local offset = {0,0,0}
    local size = {4,4,4}
	local size2
	local offset2
	local size3
	local offset3
	local size4
	local offset4
	if Block_Path[blockdata[1]] then
        local model = Block_Path[blockdata[1]].Model
        if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
            size = Function.convertPositionto(model:FindFirstChild("MainPart").Size,"table")
            offset = Function.convertPositionto(model:FindFirstChild("BasePart").Position - model:FindFirstChild("MainPart").Position,"table")
			model = model.MainPart
        elseif not model:IsA("Model") then

        else
            warn("error with model",blockdata[1])
        end
		if model:FindFirstChild("MainPart") then
				size2 = Function.convertPositionto(model:FindFirstChild("MainPart").Size,"table")
				offset2 = Function.convertPositionto((model.Parent:FindFirstChild("BasePart").Position or model.Position) - model:FindFirstChild("MainPart").Position,"table")
				model = model.MainPart
				if model:FindFirstChild("MainPart") then
					size3 = Function.convertPositionto(model:FindFirstChild("MainPart").Size,"table")
					offset3 = Function.convertPositionto((model.Parent.Parent:FindFirstChild("BasePart").Position or model.Parent.Position) - model:FindFirstChild("MainPart").Position,"table")
					model = model:FindFirstChild("MainPart") 
					if model:FindFirstChild("MainPart") then
						size4 = Function.convertPositionto(model:FindFirstChild("MainPart").Size,"table")
						offset4 = Function.convertPositionto((model.Parent.Parent.Parent:FindFirstChild("BasePart").Position or model.Parent.Parent.Position) - model:FindFirstChild("MainPart").Position,"table")
						model = model:FindFirstChild("MainPart") 
					end
				end
		end
    end
    local NewPos = Function.convertPositionto((Function.convertPositionto(hpos,"CFrame")*
  	  CFrame.fromOrientation(math.rad(orientation[1]),math.rad(orientation[2]),math.rad(orientation[3]))*
    	(Function.convertPositionto(offset,"CFrame"):Inverse())
    		).Position,"table")
    local newsize = rotationstuffaaaa[Function.convertPositionto(setup)](size)
	local NewPos2
	local newsize2
	local NewPos3
	local newsize3
	local NewPos4
	local newsize4
   if size2 then
	 NewPos2 = Function.convertPositionto((Function.convertPositionto(hpos,"CFrame")*
	CFrame.fromOrientation(math.rad(orientation[1]),math.rad(orientation[2]),math.rad(orientation[3]))*
	(Function.convertPositionto(offset2,"CFrame"):Inverse())
		).Position,"table")
 	newsize2 = rotationstuffaaaa[Function.convertPositionto(setup)](size2)
   end
   if size3 then
	NewPos3 = Function.convertPositionto((Function.convertPositionto(hpos,"CFrame")*
   CFrame.fromOrientation(math.rad(orientation[1]),math.rad(orientation[2]),math.rad(orientation[3]))*
   (Function.convertPositionto(offset3,"CFrame"):Inverse())
	   ).Position,"table")
	   newsize3 = rotationstuffaaaa[Function.convertPositionto(setup)](size3)
  end
  if size4 then
	NewPos4 = Function.convertPositionto((Function.convertPositionto(hpos,"CFrame")*
   CFrame.fromOrientation(math.rad(orientation[1]),math.rad(orientation[2]),math.rad(orientation[3]))*
   (Function.convertPositionto(offset4,"CFrame"):Inverse())
	   ).Position,"table")
	   newsize4 = rotationstuffaaaa[Function.convertPositionto(setup)](size4)
  end
    return  NewPos,newsize,NewPos2,newsize2,NewPos3,newsize3,NewPos4,newsize4
end
function Function.GetOffset(name)
    local offset = {0,0,0}
    local size = {4,4,4}
    if Block_Path[name] then
        local model = Block_Path[name].Model
        if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
            offset = Function.convertPositionto(model:FindFirstChild("BasePart").Position - model:FindFirstChild("MainPart").Position,"table")
        elseif not model:IsA("Model") then

        else
            warn("error with model",name)
        end
    end
	return offset
end
function Function.PlaceBlock(Name:string,Position,Id:number,Orientation,paren)
	if Position then
		Position = Function.convertPositionto(Position,"vector3")
	else
		warn("Position Is Nil")
		return
	end
	if Orientation then
		Orientation = Function.convertPositionto(Orientation,"vector3")
	else
		Orientation = Vector3.new(0,0,0)
	end
	local cx,cz = Function.GetChunk(Position)
	local chunkname = cx.."x"..cz
	local chunkfolder =workspace.Chunk:FindFirstChild(chunkname) or Instance.new("Folder",workspace.Chunk)
	chunkfolder.Name = chunkname
	if Block_Path[Name] and not chunkfolder:FindFirstChild(Function.convertPositionto(Position,"string")) then
		local model =  Block_Path[Name].Model
		local clonedblock
		local offset = Function.convertPositionto(Function.GetOffset(Name),"CFrame")
        if model and model:FindFirstChild("BasePart") and  model:FindFirstChild("MainPart") then
			 clonedblock = model:Clone()
		elseif not model:IsA("Model") then
			clonedblock = Block_Path[Name].Model:Clone()
        end
		--for i,v in ipairs(Block_Texture:FindFirstChild(Name):GetChildren())do
			--v:Clone().Parent = clonedblock
		--end
		clonedblock.Name = Function.ConvertPositionToReal(Position,"string")
		if clonedblock:IsA("Model") then
			if clonedblock:FindFirstChild("BasePart") then
				clonedblock:FindFirstChild("BasePart"):Destroy()
			end
			clonedblock.MainPart.CFrame = CFrame.new(Position) * CFrame.fromOrientation(math.rad(Orientation.X),math.rad(Orientation.Y),math.rad(Orientation.Z))*offset:Inverse()
		else
			clonedblock.CFrame = CFrame.new(Position) * CFrame.fromOrientation(math.rad(Orientation.X),math.rad(Orientation.Y),math.rad(Orientation.Z))*offset:Inverse()
		end
		clonedblock:SetAttribute("Name",Name)
		clonedblock:SetAttribute("State",Id)
		clonedblock.Parent =paren or chunkfolder

	end
end
function Function.worldCFrameToC0ObjectSpace(motor6DJoint:Motor6D,worldCFrame:CFrame):CFrame
	local part1CF = motor6DJoint.Part1.CFrame
	local c1Store = motor6DJoint.C1
	local c0Store = motor6DJoint.C0
	local relativeToPart1 =c0Store*c1Store:Inverse()*part1CF:Inverse()*worldCFrame*c1Store
	relativeToPart1 -= relativeToPart1.Position
	
	local goalC0CFrame = relativeToPart1+c0Store.Position--New orientation but keep old C0 joint position
	return goalC0CFrame
end
local rotationstuffaaaa = {
	["0,0,0"] = function(datao) return datao end,
	["0,1,0"] = function(datao) return {datao[3],datao[2],datao[1]} end,
	["0,1,1"] = function(datao) return {datao[3],datao[1],datao[2]} end,
	["1,1,0"] = function(datao) return {datao[2],datao[3],datao[1]} end,
	["1,0,0"] = function(datao) return {datao[1],datao[3],datao[2]} end,
	["0,0,1"] = function(datao) return {datao[2],datao[1],datao[3]} end,
}
--<Server_functions>
if maindata then 
function Function.GetFloor(pos,CanBeTransParent)
	pos = Function.convertPositionto(pos,"vector3")

	local x,y,z = Function.returnDatastringcomponets(Function.ConvertGridToReal({Function.GetBlockCoords(pos)},"string"))
	local cx,cz = Function.GetChunk(Vector3.new(pos.X,0,pos.Z))
	--print(x,y,z,cx,cz)
	for i = y , 0,-1 do
		if maindata.DecodedChunks[cx.."x"..cz] and maindata.DecodedChunks[cx.."x"..cz][x..","..i..","..z] then
			return Vector3.new(x,i,z)
		end
	end
	return nil
end
function Function.RayCast(StartingPosition,Direaction)
	local StartingPosition,Direaction = Function.convertPositionto(StartingPosition,"table"),Function.convertPositionto(Direaction,"table")
	local curentdireaction = {0,0,0}
	local pos  = StartingPosition
	while true do
		local added = 0
		if curentdireaction[1] < Direaction[1] then
			curentdireaction[1] += 0.1
			added +=1
		end
		if curentdireaction[2] < Direaction[2] then
			curentdireaction[2] += 0.1
			added +=1
		end
		if curentdireaction[3] < Direaction[3] then
			curentdireaction[3] += 0.1
			added +=1
		end
		pos = Function.AddPosition(curentdireaction,pos)
		if Function.GetBlock(pos) then
			return Function.GetBlock(pos)
		end
		if added == 0 then break end
	end
	return nil
end
function Function.GetNearByPlayers(Position,Distance,Typ)
	Position = Function.convertPositionto(Position,"vector3")
	Typ = Typ or "Close"
	local deload = false
	local loadedplayers = {}
	for i,v in ipairs(game.Players:GetPlayers()) do
		local char = maindata.LoadedEntitys[v.Name] 
		if char and char.Position then
			if (Function.convertPositionto({char.Position[1],0,char.Position[3]},"vector3")-Vector3.new(Position.X,0,Position.Z)).Magnitude > (Distance) then
				table.insert(loadedplayers,char)
				if Typ == "Close" then
					break
				end
			end
		end
	end
	return Typ == "Close" and loadedplayers[1] or loadedplayers
end











end
return Function



-- function Function.GetSweaptBroadPhase(P1,S1,O1,velocity)
-- 	-- P1 = {P1[1]-S1[1]/2,P1[2]-S1[2]/2,P1[3]-S1[3]/2}
-- 	 local Pos = {
-- 		velocity[1] >0 and P1[1] or P1[1] + velocity[1],
-- 		velocity[2] >0 and P1[2] or P1[2] + velocity[2],
-- 		velocity[3] >0 and P1[3] or P1[3] + velocity[3]
-- 	 }
-- 	 local size ={
-- 		velocity[1] >0 and velocity[1] + S1[1] or S1[1] - velocity[1],
-- 		velocity[2] >0 and velocity[2] + S1[2] or S1[2] - velocity[2],
-- 		velocity[3] >0 and velocity[3] + S1[3] or S1[3] - velocity[3],
-- 	 }
-- 	 return Pos,size
-- end
-- function  Function.AABBCheck(P1,S1,O1,P2,S2,O2,velocity)
-- 	local P2 = {P2[1]-S2[1]/2,P2[2]-S2[2]/2,P2[3]-S2[3]/2}
-- 	return not(
-- 		P1[1] + S1[1] < P2[1] or
-- 		P1[1] > P2[1]+S2[1] or
-- 		P1[2] + S1[2] < P2[2] or
-- 		P1[2] > P2[2]+S2[2] or
-- 		P1[3] + S1[3] < P2[3] or
-- 		P1[3] > P2[3]+S2[3]
-- 	)
-- end
-- function Function.SweapAABB(P1,S1,O1,P2,S2,O2,velocity,value)
-- 	local normalvelocity = {0,0,0}
-- 	local xmax = P1[1] + S1[1]*0.5
-- 	local xmin = P1[1] - S1[1]*0.5
-- 	local ymax = P1[2] + S1[2]*0.5
-- 	local ymin = P1[2] - S1[2]*0.5
-- 	local zmax = P1[3] + S1[3]*0.5
-- 	local zmin = P1[3] - S1[3]*0.5
-- 	local xmax2 = P2[1] + S2[1]*0.5
-- 	local xmin2 = P2[1] - S2[1]*0.5
-- 	local ymax2 = P2[2] + S2[2]*0.5
-- 	local ymin2 = P2[2] - S2[2]*0.5
-- 	local zmax2 = P2[3] + S2[3]*0.5
-- 	local zmin2 = P2[3] - S2[3]*0.5
-- 	local P1Leftcorners = {P1[1]-S1[1]/2,P1[2]-S1[2]/2,P1[3]-S1[3]/2}
-- 	local P2Leftcorners = {P2[1]-S2[1]/2,P2[2]-S2[2]/2,P2[3]-S2[3]/2}
-- 	-- P1Leftcorners = P1
-- 	-- P2Leftcorners= P2
-- 	--P1Leftcorners = P1
-- 	--P2Leftcorners = P2
-- 	local xInvEntry,yInvEntry,zInvEntry
--     local xInvExit,yInvExit,zInvExit
-- 	if velocity[1] > 0.0 then
-- 		xInvEntry = P2Leftcorners[1] - (P1Leftcorners[1] +S1[1] )
-- 		xInvExit = (P2Leftcorners[1] +S2[1] ) - P1Leftcorners[1] 
-- 	else
-- 		xInvEntry = (P2Leftcorners[1] +S2[1] ) - P1Leftcorners[1]
-- 		xInvExit =  P2Leftcorners[1] - (P1Leftcorners[1] +S1[1] )
-- 	end
-- 	if velocity[2] > 0.0 then
-- 		yInvEntry = P2Leftcorners[2] - (P1Leftcorners[2] +S1[2] )
-- 		yInvExit = (P2Leftcorners[2] +S2[2] ) - P1Leftcorners[2] 
-- 	else
-- 		yInvEntry = (P2Leftcorners[2] +S2[2] ) - P1Leftcorners[2]
-- 		yInvExit =  P2Leftcorners[2] - (P1Leftcorners[2] +S1[2] )
-- 	end
-- 	if velocity[3] > 0.0 then
-- 		zInvEntry = P2Leftcorners[3] - (P1Leftcorners[3] +S1[3] )
-- 		zInvExit = (P2Leftcorners[3] +S2[3] ) - P1Leftcorners[3] 
-- 	else
-- 		zInvEntry = (P2Leftcorners[3] +S2[3] ) - P1Leftcorners[3]
-- 		zInvExit =  P2Leftcorners[3] - (P1Leftcorners[3] +S1[3] )
-- 	end
-- 	local xEntry , yEntry, zEntry
-- 	local xExit , yExit, zExit
-- 	if velocity[1] == 0 then
-- 		xEntry = -math.huge
-- 		xExit = math.huge
-- 	else
-- 		xEntry = xInvEntry / velocity[1]
-- 		xExit = xInvExit / velocity[1]
-- 	end
-- 	if velocity[2] == 0 then
-- 		yEntry = -math.huge
-- 		yExit = math.huge
-- 	else
-- 		yEntry = yInvEntry / velocity[2]
-- 		yExit = yInvExit / velocity[2]
-- 	end
-- 	if velocity[3] == 0 then
-- 		zEntry = -math.huge
-- 		zExit = math.huge
-- 	else
-- 		zEntry = zInvEntry / velocity[3]
-- 		zExit = zInvExit / velocity[3]
-- 	end
-- 	if xEntry > 1 then xEntry = -math.huge end
-- 	if yEntry > 1 then yEntry = -math.huge end
-- 	if zEntry > 1 then zEntry = -math.huge end
-- 	local entrytime = math.max(math.max(xEntry,zEntry),yEntry)
-- 	local exittime = math.min(math.min(xExit,zExit),yExit)
-- 	 --print(entrytime > exittime or (xEntry < 0.0 and yEntry<0.0 and zEntry<0.0) or xEntry > 1.0 or yEntry >1.0 or zEntry >1.0)
-- 	 --or xEntry < 0.0 and yEntry<0.0 and zEntry<0.0 or xEntry > 1.0 or yEntry >1.0 or zEntry >1.0

-- 	if entrytime > exittime then return 1,2 end
-- 	if value == 2 then
-- 		--print(  yEntry)
-- 	end
-- 	if xEntry <0.0 and yEntry <0.0 and zEntry<0.0 then return 3,3 end
-- 	if xEntry <0 then
-- 		if xmax2 < xmin or xmin2 > xmax then return 1,4 end
-- 	end

-- 	if yEntry <0 then
-- 		if ymax2 < ymin or ymin2 > ymax then return 1,5 end
-- 	end

-- 	if zEntry <0 then
-- 		if zmax2 < zmin or zmin2 > zmax then  return 1,6 end
-- 	end
-- 	if value == 2 then
-- 		print(  "E")
-- 	end
-- 		if xEntry > yEntry then
-- 			if xEntry > zEntry then
-- 				normalvelocity[1] = -math.sign(velocity[1])
-- 				normalvelocity[2] = 0
-- 				normalvelocity[3] = 0
-- 			else
-- 				normalvelocity[1] = 0
-- 				normalvelocity[2] = 0
-- 				normalvelocity[3] = -math.sign(velocity[3])
-- 			end
-- 		else
-- 			if yEntry > zEntry then
-- 				normalvelocity[1] = 0
-- 				normalvelocity[2] = -math.sign(velocity[2])
-- 				normalvelocity[3] = 0
-- 			else
-- 				normalvelocity[1] = 0
-- 				normalvelocity[2] = 0
-- 				normalvelocity[3] = -math.sign(velocity[3])
-- 			end
-- 		end
-- 		return entrytime,normalvelocity
-- end
-- function Function.CheckForCollision(P1,S1,O1,P2,S2,O2,velocity,a)
-- 	P1 = Function.convertPositionto(P1,"table")
-- 	P2 = Function.convertPositionto(P2,"table")
-- 	S1 = Function.convertPositionto(S1,"table")
-- 	S2 = Function.convertPositionto(S2,"table")
-- 	if O1 then
-- 		O1 = Function.convertPositionto(O1,"table")
-- 		local setup = {
-- 			math.abs(O1[1])== 90 and 1 or 0,
-- 			math.abs(O1[2])== 90 and 1 or 0,
-- 			math.abs(O1[3])== 90 and 1 or 0,
-- 		}
-- 		S1 = rotationstuffaaaa[Function.convertPositionto(setup,"string")] and rotationstuffaaaa[Function.convertPositionto(setup,"string")](S1) or S2
-- 	end
-- 	if O2 then
-- 		O2 = Function.convertPositionto(O2,"table")
-- 		local setup = {
-- 			math.abs(O2[1])== 90 and 1 or 0,
-- 			math.abs(O2[2])== 90 and 1 or 0,
-- 			math.abs(O2[3])== 90 and 1 or 0,
-- 		}
-- 		S2 = rotationstuffaaaa[Function.convertPositionto(setup,"string")] and rotationstuffaaaa[Function.convertPositionto(setup,"string")](S2) or S2
-- 	end
-- 	 --print(P1[2])
-- 	--  P1[1] = math.abs(P1[1])
-- 	--  P1[2] = math.abs(P1[2])
-- 	--  P1[3] = math.abs(P1[3])
-- 	--  P2[1] = math.abs(P2[1])
-- 	--  P2[2] = math.abs(P2[2])
-- 	--  P2[3] = math.abs(P2[3])
-- 	local xmax = P1[1] + S1[1]*0.5
-- 	local xmin = P1[1] - S1[1]*0.5
-- 	local ymax = P1[2] + S1[2]*0.5
-- 	local ymin = P1[2] - S1[2]*0.5
-- 	local zmax = P1[3] + S1[3]*0.5
-- 	local zmin = P1[3] - S1[3]*0.5
-- 	local xmax2 = P2[1] + S2[1]*0.5
-- 	local xmin2 = P2[1] - S2[1]*0.5
-- 	local ymax2 = P2[2] + S2[2]*0.5
-- 	local ymin2 = P2[2] - S2[2]*0.5
-- 	local zmax2 = P2[3] + S2[3]*0.5
-- 	local zmin2 = P2[3] - S2[3]*0.5

-- --[[	if velocity[1]>0 then
-- 		xmax+=velocity[1]
-- 	else
-- 		xmin+=velocity[1]
-- 	end
-- 	if velocity[2]>0 then
-- 		ymax+=velocity[2]
-- 	else
-- 		ymin+=velocity[2]
-- 	end
-- 	if velocity[3]>0 then
-- 		zmax+=velocity[3]
-- 	else
-- 		zmin+=velocity[3]
-- 	end]]
-- 	local p1Max = Vector3.new(P1[1]+S1[1],P1[2]+S1[2],P1[3]+S1[3])
-- 	local p1Min = Vector3.new(P1[1],P1[2],P1[3])
-- 	local p2Max = Vector3.new(P2[1]+S2[1],P2[2]+S2[2],P2[3]+S2[3])
-- 	local p2Min = Vector3.new(P2[1],P2[2],P2[3])

-- 	-- return p2Max.X > p1Min.X and p2Min.X < p1Max.X and
-- 	-- 	   p2Max.Y > p1Min.Y and p2Min.Y < p1Max.Y and
-- 	-- 	   p2Max.Z > p1Min.Z and p2Min.Z < p1Max.Z
-- 		--print(zmin , zmax2 , zmax , zmin2)
-- 		if a then
-- 			print (ymin , ymax2 , ymax , ymin2)
-- 		end
-- 	return(xmin <= xmax2 and xmax >= xmin2) and
-- 		  (ymin <= ymax2 and ymax >= ymin2) and
-- 		  (zmin <= zmax2 and zmax >= zmin2)
-- end