local workers = require(game.ReplicatedStorage.WorkerThreads)
local amountofworkers = 20
local getchunk = workers.New(script.Parent.GenerationVersions.GenerationHandler2,"DoStuff",amountofworkers)
local g2 = require(script.Parent.GenerationVersions.GenerationHandler2)
local func = {}
local queue ={}
local done = {}
local Block_Info = require(game.ReplicatedStorage.BlockInfo)
local refunction = require(game.ReplicatedStorage.Functions)
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
local function divide(original,times)
	local tables = {}
	for i =1,times do
		tables[i] = {}
	end
	local length = 0
	for i,v in pairs(original)do
		length +=1
		for t =times,1,-1 do
			if length%t ==0 then
				tables[t][i] = v
				break
			end
		end
		original[i] = nil
	end
	return tables
end
function func.GetGeneration(Chunk)
    if not queue[Chunk] then
	queue[Chunk] = refunction.XZCoordInChunk(Chunk)
    end
    repeat
        task.wait(0)
    until done[Chunk]
    task.delay(.2,function()
        queue[Chunk] = nil
		done[Chunk] = nil
	end)
	return done[Chunk]
end
task.spawn(function()
    while true do
        local splitter = divide(queue,amountofworkers)
        for i,v in pairs(splitter)do
            task.spawn(function()
			   local newcs = getchunk:DoWork("SendGen",Block_Info,refunction,"GetChunks",v)
               for is,vs in pairs(newcs)do
                done[is] = vs
                end
            end)
        end
        task.wait(.2)
    end
end)
return func