local values = {
     events = {}
}
local MainData = require(game.ServerStorage.MainData)
local function getentityfromuuid(uuid)
	return MainData.LoadedEntitys[uuid] or  MainData.Entitys[uuid]
end
function values.DcAll(uuid)
    for i,v in pairs(values.events[uuid])do
        v:destroy()
    end
    uuid = nil
end
function values.Connect(uuid,valuename,valuepath)
    if not  values.events[uuid] then  values.events[uuid] = {} end
    if  not values.events[uuid][valuepath] then values.events[uuid][valuepath] = Instance.new("BindableEvent") end
    return values.events[uuid][valuepath]
end
function  values.Change(uuid,valuepath:string,value)
    local entity
    if typeof(uuid) == "table" then
        entity = uuid
    else
     entity = getentityfromuuid(uuid) 
    end
   
    
    local paths = string.split(valuepath,".")
    local parentvalue,valuename = entity,valuepath
    for i,v in ipairs(paths)do
        if i == #paths then
            valuename = v
        else
            parentvalue = parentvalue[v]
        end
        if parentvalue == nil then
            warn("Path Does Not Exsist | Path:",valuepath,"uuid:",uuid)
        end
    end
    if not  values.events[uuid] then  values.events[uuid] = {} end
    if  values.events[uuid][valuepath] then
        values.events[uuid][valuepath]:Fire(value)
    end
    parentvalue[valuename] = value
end
return values
--[[
    <input>
    3213123 ={
    b ={
        c = 1
        }
    }
    <output>
    3213123.b.c

]]

