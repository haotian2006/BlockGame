local heap ={}
heap.__index = heap
local function compareto(value1,value2)
    if value1> value2 then
        return 1
    elseif value1 < value2 then
        return -1
    else
        return 0
    end
end
local function comparenode(node1,node2)
    local compared = compareto(node1.fcost,node2.fcost)
    if compared == 0 then
        compared = compareto(node1.hcost,node2.hcost)
    end
    return -compared
end
local function swap(self,ItemA,ItemB)
    self.Items[ItemA.HeapIndex] = ItemB 
    self.Items[ItemB.HeapIndex] = ItemA
    local placeholder =ItemA.HeapIndex
    ItemA.HeapIndex = ItemB.HeapIndex
    ItemB.HeapIndex = placeholder
end
local function sortup(self,item)
    local parentindex = (item.HeapIndex-1)/2
    while true do
        local parentitem = self.Items[parentindex]
        if comparenode(item,parentitem) > 0 then
            swap(item,parentitem)
        else
            break
        end
        parentindex = (item.HeapIndex-1)/2
    end
end
local function sortdown(self,item)
    while true do
        local indexofchildleft = item.HeapIndex*2 +1
        local indexofchildright = item.HeapIndex*2 +2
        local swapindex = 0
        if indexofchildleft < self.CurrentSize then
            swapindex = indexofchildleft
            if indexofchildright < self.CurrentSize then
                if comparenode(self.Items[indexofchildleft],self.Items[indexofchildright] <0) then
                    swapindex = indexofchildright
                end
            end
            if comparenode(item,self.Items[swapindex]<0) then
                swap(item,self.Items[swapindex])
            else
                return
            end
        else
            return
        end
    end
end
function heap.new(maxsize)
    local newheap = {}
    setmetatable(newheap,heap)
    newheap.Items ={}
    newheap.CurrentSize = 0
    newheap.max = maxsize
    return newheap
end
function heap:add(item)
    item.HeapIndex = self.CurrentSize
    self.Items[self.CurrentSize] = item
    sortup(self,item)
    self.CurrentSize += 1
end
function heap:RemoveFirst()
   local firstitme = self.Items[1]
   self.CurrentSize -= 1
   self.Items[1] = self.Items[self.CurrentSize]
   self.Items[1].HeapIndex = 0 
   sortdown(self.Items[1])
   return firstitme
end
return heap