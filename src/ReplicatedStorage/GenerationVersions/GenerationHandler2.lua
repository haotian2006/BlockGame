local Generation = {}
local Block_Info = require(game.ReplicatedStorage.BlockInfo)
local refunction = require(game.ReplicatedStorage.Functions)
function Generation.GetVersion(versiontouse)
	versiontouse = versiontouse or game.ReplicatedStorage.Version.Value
	local latest,touse= 0,game.ReplicatedStorage.GenerationVersions["pa_1.0-2.0"] 
   if versiontouse then
	   for i,v in ipairs(game.ReplicatedStorage.GenerationVersions:GetChildren())do
		   local typ,version = unpack(string.split(v.Name,"_"))
		   local version = string.split(version,"-")
		   local v1,v2 = version[1],version[2]
		   v1,v2 = tonumber(v1),tonumber(v2)
		   if v1 then
			   if latest < v1 then
				   latest = v1
				   touse = v
			   end
		   end
		   if v2 then
			   if latest < v2 then
				   latest = v2
				   touse = v
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
local function can(position,tabl,player,blockdata)
	if  blockdata[1] == "air" or blockdata[1] == nil then
		return false
	end
	local c = false
	local splittedstring = string.split(position,",")
	local x,y,z = tonumber(splittedstring[1]),tonumber(splittedstring[2]),tonumber(splittedstring[3])
	local ch= convetcunktostring(refunction.GetChunk(position))
	if tabl[pack2(x+4,y,z)] and Block_Info[tabl[pack2(x+4,y,z)][1]] and not Block_Info[tabl[pack2(x+4,y,z)][1]]["IsTransparent"] and  tabl[pack2(x-4,y,z)] and  tabl[pack2(x-4,y,z)][1] and  not Block_Info[tabl[pack2(x-4,y,z)][1]]["IsTransparent"] and tabl[pack2(x,y+4,z)]and tabl[pack2(x,y+4,z)][1] and not Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"] and tabl[pack2(x,y-4,z)] and tabl[pack2(x,y-4,z)][1] and not Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"]  and  tabl[pack2(x,y,z-4)] and tabl[pack2(x,y,z-4)][1] and not Block_Info[tabl[pack2(x,y,z-4)][1]]["IsTransparent"] and  tabl[pack2(x,y,z+4)] and tabl[pack2(x,y,z+4)][1] and not Block_Info[tabl[pack2(x,y,z+4)][1]]["IsTransparent"] --[[and math.abs(player -y) <=16*(render)]] then
	elseif convetcunktostring(refunction.GetChunk(pack2(x+4,y,z))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x-4,y,z))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x,y,z+4))) == ch and  convetcunktostring(refunction.GetChunk(pack2(x,y,z-4))) == ch  then
			c = true
	elseif ( not tabl[pack2(x,y+4,z)]  or (tabl[pack2(x,y+4,z)] and tabl[pack2(x,y+4,z)][1] and Block_Info[tabl[pack2(x,y+4,z)][1]]["IsTransparent"]))  or ( not tabl[pack2(x,y-4,z)]  or (tabl[pack2(x,y-4,z)] and tabl[pack2(x,y-4,z)][1] and Block_Info[tabl[pack2(x,y-4,z)][1]]["IsTransparent"])) or not blockdata[6]   then 
			c = true
	end
	return c
end
function Generation.GetSortedTable(Data,Chunk)
	local size = 0
	local lc = {}
	for coord,data in pairs(Data) do
		if can(coord,Data,0,data)  then	
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
		genh = require(genh)
		genh.GetBlock(Block)
	end

end
function Generation.GetChunks(chunck,alrloaded)
	local versiontouse = game.ReplicatedStorage.Version.Value
	if alrloaded and next(alrloaded) then
		versiontouse = alrloaded["Settings"]["Version"]
	end
	local data = {}
	local genh = Generation.GetVersion(versiontouse)
	if genh then
		genh = require(genh)
		data = genh.GetChunks(chunck)
		if alrloaded then
			for pos,bdata in pairs(alrloaded) do
				data[pos] = bdata
			end
		end
	end

	return data
end
return Generation
