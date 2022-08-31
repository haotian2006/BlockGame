local AABB = {}
function AABB.new(min:Vector3,max:Vector3,center:Vector3,size:Vector3)
    return {min = min,max=max,center = center,size=size}
end
function AABB.moreThanOne()
     
end
function AABB.createMinMax(min:Vector3,max:Vector3)
     local center = (max - min)*0.5
     local size = max-center
     return AABB.new(min.max,center,size)
end
function AABB.createCenterSize(center,xs,ys,zs)
    local size = Vector3.new(xs,ys,zs)
    local max = center+size
    local min = center-size
    return AABB.new(min,max,center,size)
end
return AABB