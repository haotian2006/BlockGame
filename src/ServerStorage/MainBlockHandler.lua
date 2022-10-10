local MainData = require(game.ServerStorage.MainData)
local handlers = game.ServerStorage.BlockHandlers
local httpsservice = game:GetService("HttpService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ValueListener = require(game.ServerStorage.ValueListener)
local refunction = require(game.ReplicatedStorage.Functions)
local GenHandler = require(game:GetService("ServerStorage").GenerationMutit)
local Data = {
   ["BasicNbt"] ={
	
   },
   Events ={

   },
   conditions ={

   },
   componet ={

   },
   statements ={
	
   },
   behavior = {

   },
   events ={

   },

}
--<----localfunctions---->
local function getentityfromuuid(uuid)
	return MainData.LoadedEntitys[uuid] 
end
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
local function addevent(event,entity,values,time)
	entity.Events[event] = {values,time} --{}
end
local function getBlockhandlerfromname(name)
	if not handlers[name] then return nil end
	return require(handlers[name])
end


--<----blockcomponets---->
--true = add false == remove
--<----events---->
function  Data.OnPlaced(data)
	local blockhandler = getBlockhandlerfromname(data[1])
	if not blockhandler then return data end
	for name,data in pairs(blockhandler.block.components)do
		
	end
	return data
end
function Data.OnInteract(Position)
	local part = refunction.GetBlock(Position,nil,nil,true)
	if not part then return end
	local handler = getBlockhandlerfromname(part[1])
	if handler["event"] and handler.event["On_Interact"] then
		handler.event["On_Interact"].func(part)
	end
end
function  Data.OnTouched(Position,id)
	local part = refunction.GetBlock(Position,nil,nil,true)
	local entity = getentityfromuuid(id)
	if not entity then return end
	local surface = refunction.getSurface(entity.Position,Position,part[3])
	local handler = getBlockhandlerfromname(part[1])
	if handler["event"] and handler.event["On_Touch"] then
		handler.event["On_Touch"].func(part,entity,surface)
	end
end
function  Data.OnUpdate(data)
	local blockhandler = getBlockhandlerfromname(data[1])
	if data[6] == true then
		data[6] = nil
		Data.OnPlaced(data)
	end
	if not blockhandler then return data end

	return data
end
return Data 