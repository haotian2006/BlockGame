local LocalizationService = game:GetService("LocalizationService")
--Thank 1waffle1 for making this its such an life saver
local workers = require(game.ReplicatedStorage.WorkerThreads)
local amountofworkers = 20
local Compress = workers.New(script.Parent.cc2,"doc",amountofworkers)
local SlowCompress = workers.New(script.Parent.cc2,"Slowdoc",amountofworkers)
local DeCompress = workers.New(script.Parent.cc2,"dedoc",amountofworkers)
local dictionary, length = {}, 0
for i = 32, 127 do
	if i ~= 34 and i ~= 92 then
		local c = string.char(i)
		dictionary[c], dictionary[length] = length, c
		length = length + 1
	end
end

local escapemap = {}
local cqueue ={}
local cdone = {}
local dqueue ={}
local ddone = {}
for i = 1, 34 do
	i = ({34, 92, 127})[i-31] or i
	local c, e = string.char(i), string.char(i + 31)
	escapemap[c], escapemap[e] = e, c
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
local function escape(s)
	return (s:gsub("[%c\"\\]", function(c)
		return "\127"..escapemap[c]
	end))
end

local function unescape(s)
	return (s:gsub("\127(.)", function(c)
		return escapemap[c]
	end))
end

local function copy(t)
	local new = {}
	for k, v in pairs(t) do
		new[k] = v
	end
	return new
end

local function tobase93(n)
	local value = ""
	repeat
		local remainder = n%93
		value = dictionary[remainder]..value
		n = (n - remainder)/93
	until n == 0
	return value
end

local function tobase10(value)
	local n = 0
	for i = 1, #value do
		n = n + 93^(i-1)*dictionary[value:sub(-i, -i)]
	end
	return n
end

local function compress(text)
	local dictionary = copy(dictionary)
	local key, sequence, size = "", {}, #dictionary
	local width, spans, span = 1, {}, 0
	local function listkey(key)
		local value = tobase93(dictionary[key])
		if #value > width then
			width, span, spans[width] = #value, 0, span
		end
		sequence[#sequence+1] = (" "):rep(width - #value)..value
		span = span + 1
	end
	text = escape(text)
	for i = 1, #text do
		local c = text:sub(i, i)
		local new = key..c
		if dictionary[new] then
			key = new
		else
			listkey(key)
			key, size = c, size+1
			dictionary[new], dictionary[size] = size, new
		end
	end
    listkey(key)
	spans[width] = span
    return table.concat(spans, ",").."|"..table.concat(sequence)
end
local function queuecompress(key,text)
	if not cqueue[key] then
	cqueue[key] = text
	end
	repeat
		task.wait(0)
	until cdone[key]
	task.delay(.2,function()
		cdone[key] = nil
	end)
	return cdone[key]
end
local once = true
local function queuedecompress(key,text)
	if not dqueue[key] then
		dqueue[key] = text
	end
	repeat
		task.wait(0)
	until ddone[key]
	task.delay(.2,function()
		ddone[key] = nil
	end)
	return ddone[key]
end
local function decompress(text,a)
	local dictionary = copy(dictionary)
	local sequence, spans, content = {}, text:match("(.-)|(.*)")
	local groups, start = {}, 1
	for span in spans:gmatch("%d+") do
		local width = #groups+1
		groups[width] = content:sub(start, start + span*width - 1)
		start = start + span*width
	end
	local previous;
	for width = 1, #groups do
		for value in groups[width]:gmatch(('.'):rep(width)) do
			local entry = dictionary[tobase10(value)]
			if previous then
				if entry then
					sequence[#sequence+1] = entry
					dictionary[#dictionary+1] = previous..entry:sub(1, 1)
				else
					entry = previous..previous:sub(1, 1)
					sequence[#sequence+1] = entry
					dictionary[#dictionary+1] = entry
				end
			else
				sequence[1] = entry
			end
			previous = entry
		end
	end
	return unescape(table.concat(sequence))
end
local function slowcomp(table,ad)
	local splitted = divide(table,amountofworkers)
	local new_table = {}
	local current,done= coroutine.running(),false
	local amount = 0
	for i,v in ipairs(splitted) do
			task.spawn(function()
				local e = SlowCompress:DoWork(v)
				for ci,cv in pairs(e)do
					new_table[ci] = cv
				end
				amount+=1
				if amount ==#splitted then
					coroutine.resume(current)
					done = true
					end
				if i == #splitted then
					if amount ==#splitted then
					coroutine.resume(current)
					end
				end
			end)
	end
	if not done then
	coroutine.yield()
	end
	return new_table
end
local function  CheckInQd(key)
	if dqueue[key] then
		return true
	end
	return false
end
local function start()
	task.spawn(function()
		while true do
			local splitted = divide(cqueue,amountofworkers)
			for i,v in ipairs(splitted) do
				task.spawn(function()
					local newtable = Compress:DoWork(v)
					for i,v in pairs(newtable)do
						cdone[i] = v
					end
				end)
				task.wait(.3)
			end
			task.wait(.2)
		end
	end)
	while true do
		local splitted = divide(dqueue,amountofworkers)
		for i,v in ipairs(splitted) do
			task.spawn(function()
				local newtable = DeCompress:DoWork(v)
				for i,v in pairs(newtable)do
					ddone[i] = v
				end
			end)
		end
		task.wait(.2)
	end
end
return {compress = queuecompress, decompress = queuedecompress,rcompress = compress, rdecompress = decompress,cqueue= cqueue,dqueue=dqueue,slowcomp=slowcomp,start = start,CheckInQd=CheckInQd}
--return {compress = compress, decompress = decompress}