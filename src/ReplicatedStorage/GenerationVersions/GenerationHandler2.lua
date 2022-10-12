local Generation = {}
local Block_Info 
local refunction 
local allmoudlescripts = {}
local a,b = pcall(require,game.ReplicatedStorage.BlockInfo)
if a then
	Block_Info = b
	for i,v in ipairs(game.ReplicatedStorage.GenerationVersions:GetChildren()) do
		if v.Name == "GenerationHandler2" then continue end
		allmoudlescripts[v.Name] = require(v)
	end
end
task.delay(0.1,function()
	local a,b = pcall(require,game.ReplicatedStorage.Functions)
	if a then
		refunction = b
	end
end)
function Generation.GetVersion(versiontouse)
	versiontouse = versiontouse or game.ReplicatedStorage.Version.Value
	local latest,touse= 0,"pa_1.0-2.0"
	if versiontouse then
		for i,v in ipairs(game.ReplicatedStorage.GenerationVersions:GetChildren())do
			local unpacked = unpack(string.split(v.Name,"_"))
			local typ,version = unpacked[1],unpacked[2]
			version = version and string.split(version,"-")
			if not version then continue end
			local v1,v2 = version[1],version[2]
			v1,v2 = tonumber(v1),tonumber(v2)
			if v1 then
				if latest < v1 then
					latest = v1
					touse = v.Name
				end
			end
			if v2 then
				if latest < v2 then
					latest = v2
					touse = v.Name
				end
			end
		end		
	end
	return touse
end
local function pack2(x,y,z)
	return x..","..y..","..z
end
local function convetcunktostring(cx,cz)
	return cx..","..cz
end
local function checkoneblock(tabl,direaction)
	return tabl[direaction] and Block_Info[tabl[direaction][1]] and not Block_Info[tabl[direaction][1]]["IsTransparent"]
end
local function checksurroundblock(tabl,x,y,z,ignore,a,nearbychunks)
	local parts  = 0
	ignore = ignore or {}
	a = a or 0
	local aa = {}
	if checkoneblock(tabl,pack2(x+4,y,z))  then
		parts+=1
	elseif ignore["x4"]  then
		local block = nearbychunks[1][pack2(x+4,y,z)]
		local ppt = {[pack2(x+4,y,z)] = block}
		if checkoneblock(ppt,pack2(x+4,y,z)) then
			parts+=1
		end
	end
	if checkoneblock(tabl,pack2(x-4,y,z))  then
		parts+=1
	elseif ignore["x-4"]  then
		local block = nearbychunks[2][pack2(x-4,y,z)]
		local ppt = {[pack2(x-4,y,z)] = block}
		if checkoneblock(ppt,pack2(x-4,y,z)) then
			parts+=1
		end
	end
	if checkoneblock(tabl,pack2(x,y+4,z)) then 
		parts+=1
	end
	if checkoneblock(tabl,pack2(x,y-4,z)) then 
		parts+=1
	end
	if checkoneblock(tabl,pack2(x,y,z-4))  then  
		parts+=1
	elseif ignore["z-4"]  then
		local block = nearbychunks[4][pack2(x,y,z-4)]
		local ppt = {[pack2(x,y,z-4)] = block}
		if checkoneblock(ppt,pack2(x,y,z-4)) then
			parts+=1
		end
	end
	if checkoneblock(tabl,pack2(x,y,z+4))  then
		parts+=1
	elseif ignore["z4"]  then
		local block = nearbychunks[3][pack2(x,y,z+4)]
		local ppt = {[pack2(x,y,z+4)] = block}
		if checkoneblock(ppt,pack2(x,y,z+4)) then
			parts+=1
		end
	end
	return parts == (6)
end
local function checkifiswall(tabl,x,y,z)
	--local ch= convetcunktostring(refunction.GetChunk({x,y,z}))
	local walls = {}
	local ammount = 0
	if not tabl[pack2(x+4,y,z)] then
		walls['x4'] = true
		ammount +=1
	end
	if not tabl[pack2(x-4,y,z)] then
		walls['x-4'] = true
		ammount +=1
	end
	if not tabl[pack2(x,y,z-4)] then
		walls['z-4'] = true
		ammount +=1
	end
	if not tabl[pack2(x,y,z+4)] then
		walls['z4'] = true
		ammount +=1
	end
	--if convetcunktostring(refunction.GetChunk(pack2(x+4,y,z))) ~= ch then
	--	walls['x4'] = true
	--	ammount +=1
	--end
	--if 	convetcunktostring(refunction.GetChunk(pack2(x-4,y,z))) ~= ch then
	--	walls['x-4'] = true
	--	ammount +=1
	--end
	--if convetcunktostring(refunction.GetChunk(pack2(x,y,z+4))) ~= ch then
	--	walls['z4'] = true
	--	ammount +=1
	--end
	--if 	convetcunktostring(refunction.GetChunk(pack2(x,y,z-4))) ~= ch then
	--	walls['z-4'] = true
	--	ammount +=1
	--end
	return not(#walls == 0),walls,ammount
end
local function can(position,tabl,player,blockdata,nearbychunks)
	if  blockdata[1] == "air" or blockdata[1] == nil or blockdata[100] then
		return false
	end
	local c = true
	local splittedstring = string.split(position,",")
	local x,y,z = tonumber(splittedstring[1]),tonumber(splittedstring[2]),tonumber(splittedstring[3])
	local wall,near,ammount = checkifiswall(tabl,x,y,z)
	if position == "312,28,-596" then
		print("C") 
		local part = Instance.new("Part",workspace)
		part.Anchored = true
		part.Position = Vector3.new(x,y,z)
		part.Name = "cdas"
		checksurroundblock(tabl,x,y,z,near,ammount,nearbychunks)
	end
	if checksurroundblock(tabl,x,y,z,near,ammount,nearbychunks) then -- checks if it is surrorunded
		return false
	end
	--if wall then
	--	--return true
	--end
	--if (( not tabl[pack2(x,y+4,z)]  or (tabl[pack2(x,y+4,z)] and tabl[pack2(x,y+4,z)][1] and Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"]))  or ( not tabl[pack2(x,y-4,z)]  or (tabl[pack2(x,y-4,z)] and tabl[pack2(x,y-4,z)][1] and Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"]))) or not blockdata[6]  then 
	--		c = true
	--end
	--if (tabl[pack2(x+4,y,z)] and not tabl[pack2(x+4,y,z)][1] or tabl[pack2(x-4,y,z)] and not tabl[pack2(x-4,y,z)][1]) or (tabl[pack2(x,y+4,z)] and not tabl[pack2(x,y+4,z)][1] or tabl[pack2(x,y-4,z)] and not tabl[pack2(x,y-4,z)][1]) or (tabl[pack2(x,y,z+4)] and not tabl[pack2(x,y,z+4)][1] or tabl[pack2(x,y,z-4)] and not tabl[pack2(x,y,z-4)][1]) then
	--	c = true
	--end
	return c
end
function Generation.GetSortedTable(Data,Chunk,should,nearbychunks,other)
	local size = 0
	other = other or {}
	local lc = {}
	for coord,data in pairs(Data) do
		if coord == "-96,52,-124" then
			--print(data[6])
		end
		if (should and should[coord]) or can(coord,Data,0,data,nearbychunks) or other[coord] then	
			other[coord] = nil
			lc[coord] ={data[1],data[2],data[3],Chunk, not Block_Info[data[1]]["IsTransparent"]}
		end
		size +=1
	end
	return lc
end

function Generation.GetBlock(Block,versiontouse)
	versiontouse = versiontouse or game.ReplicatedStorage.Version.Value
	local genh = Generation.GetVersion(versiontouse)
	if genh then
		genh = allmoudlescripts[genh]
		return genh.GetBlock(Block)
	end

end
function Generation.GetChunks(chunk,alrloaded)
	local versiontouse = game.ReplicatedStorage.Version.Value
	if alrloaded and next(alrloaded) then
		versiontouse = alrloaded["Settings"]["Version"]
	end
	local data = {}
	local genh = Generation.GetVersion(versiontouse)
	genh =  allmoudlescripts[genh]
	if genh then

		data = genh.GetChunks(chunk)
		if alrloaded then
			for pos,bdata in pairs(alrloaded) do
				data[pos] = bdata
			end
		end
	end

	return data
end
function Generation.DoStuff(allss,sendgen,Block_Info1,refunction1,functiontocall,...)
	refunction = refunction1
	Block_Info = Block_Info1
	allmoudlescripts = allss or allmoudlescripts
	if Generation[functiontocall] then
		return Generation[functiontocall](...)
	end
end
return Generation
