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
	return require(name)
end


--<----blockcomponets---->
--true = add false == remove
function Data.componet.ageable(blockdata,data,d)
	local duration = data["duration"]
	local feeditems = data["feeditems"]
	local grow_up = data["grow_up"]
	if d then
		
	else
	
	end
end


function  Data.OnPlaced(data)
	local blockhandler = getBlockhandlerfromname(data[1])
	if not blockhandler then return data end
	for name,data in pairs(blockhandler.block.components)do
		
	end
	return data
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