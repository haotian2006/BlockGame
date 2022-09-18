local workers = require(game.ReplicatedStorage.WorkerThreads)
local amountofworkers = 20
local getchunk = workers.New(script.Parent.GenerationHandler,"GetChunks",amountofworkers)
local refunction = require(game.ReplicatedStorage.Functions)
local func = {}
local queue ={}
local done = {}
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
        task.wait(0.1)
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
               local newcs = getchunk:DoWork(v)
               for i,v in pairs(newcs)do
                done[i] = v
                end
            end)
        end
        task.wait(.5)
    end
end)
return func