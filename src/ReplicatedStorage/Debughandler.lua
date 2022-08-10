local debug = {}
debug.__index = debug
local global = {}
function debug.new(global)
    local f = {}
    setmetatable(f,debug)
    f.Items = {}
    f.StartTime = DateTime.now().UnixTimestampMillis
    f.Global = global
    return f
end
function debug:gettime()
    for i,v in pairs(self.Items)do
        print(i.."|"..v.."ms")
    end
end
function debug:set(index:string)
    local timea = DateTime.now().UnixTimestampMillis- self.StartTime
   self.Items[index] = not self.Items[index] and timea or self.Items[index] + timea
   self.StartTime = DateTime.now().UnixTimestampMillis
   if self.Global then
    global[index] = not global[index] and timea or global[index] + timea
   end
end
function  debug:printglobal()
    for i,v in pairs(global)do
        print(i.."|"..v.."ms")
    end
end
function  debug:clearglobal()
   global = {}
end

return debug