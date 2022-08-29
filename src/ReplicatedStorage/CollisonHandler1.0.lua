local Collison = {}
local refunction = require(game.ReplicatedStorage.Functions)
local rotationstuffaaaa = {
	["0,0,0"] = function(datao) return datao end,
	["0,1,0"] = function(datao) return {datao[3],datao[2],datao[1]} end,
	["0,1,1"] = function(datao) return {datao[3],datao[1],datao[2]} end,
	["1,1,0"] = function(datao) return {datao[2],datao[3],datao[1]} end,
	["1,0,0"] = function(datao) return {datao[1],datao[3],datao[2]} end,
	["0,0,1"] = function(datao) return {datao[2],datao[1],datao[3]} end,
}
function Collison.lineToPlane(px,py,pz, ux,uy,uz,  vx,vy,vz, nx,ny,nz)
    local NdotU = nx*ux + ny*uy + nz*uz
    if NdotU == 0 then return math.huge end
    return (nx*(vx-px) + ny*(vy-py) + nz*(vz-pz)) / NdotU
end
function Collison.between(x,a,b)
    return x >= a and x <= b
end
function Collison.SweapAABB(ax,ay,az,ahx,ahy,ahz,  bx,by,bz,bhx,bhy,bhz, dx,dy,dz)
    --p1 = {p1[1]-s1[1]/2,p1[2]-s1[2]/2,p1[3]-s1[3]/2}
   -- p2 = {p2[1]-s2[1]/2,p2[2]-s2[2]/2,p2[3]-s2[3]/2}
   -- local ax,ay,az,ahx,ahy,ahz,  bx,by,bz,bhx,bhy,bhz, dx,dy,dz = p1[1],p1[2],p1[3],s1[1],s1[2],s1[3],p2[1],p2[2],p2[3],s2[1],s2[2],s2[3],velocity[1],velocity[2],velocity[3]
    local mx,my,mz,mhx,mhy,mhz

    mx = bx - (ax+ahx)
    my = by - (ay+ahy)
    mz = bz - (az+ahz)
    mhx = ahx + bhx
    mhy = ahy + bhy
    mhz = ahz + bhz

    local h,s,nx,ny,nx,nz = 1, nil,0,0,0

    s = Collison.lineToPlane(0,0,0, dx,dy,dz,mx,my,mz,-1,0,0)
    -- x min
    if s >= 0 and dx >0 and s<h and Collison.between(s*dy,my,my+mhy) and Collison.between(s*dz,mz,mz+mhz) then
        h = s nx = -1  ny = 0 nz = 0
    end
    -- x max
    s = Collison.lineToPlane(0,0,0,dx,dy,dz,mx+mhx,my,mz,1,0,0)
    if s>= 0 and dx < 0 and s < h and Collison.between(s*dy,my,my+mhy) and Collison.between(s*dz,mz,mz+mhz) then
        h = s nx = 1 ny = 0 nz = 0
    end
    --Y min
    s = Collison.lineToPlane(0,0,0,dx,dy,dz,mx,my,mz,0,-1,0)
    if s >= 0 and dy > 0 and s < h and Collison.between(s*dx,mx,mx+mhx) and Collison.between(s*dz,mz,mhz) then
        h = s nx = 0 ny = -1 nz = 0
    end
    -- Y max
    s = Collison.lineToPlane(0,0,0,dx,dy,dz,mx,my+mhy,mz,0,1,0)

    if s>=0 and dy < 0 and s <h and Collison.between(s*dx,mx,mx+mhx) and Collison.between(s*dz,mz,mz+mhz) then
        h = s nx = 0 ny = 1 nz = 0
    end
    --Z min
    s = Collison.lineToPlane(0,0,0,dx,dy,dz,mx,my,mz,0,0,-1)
    if s >= 0 and dz > 0 and s <h and Collison.between(s*dx,mx,mx+mhx) and Collison.between(s*dy,my,my+mhy) then
        h =s nx =0 ny = 0 nz = -1
    end
    --Z Max
    s = Collison.lineToPlane(0,0,0,dx,dy,dz,mx,my,mz+mhz,0,0,1)
    
    if s>=0 and dz <0 and s<h and Collison.between(s*dx,mx,mx+mhx) and Collison.between(s*dy,my,my+mhy) then
        h =s nx = 0 ny = 0 nz = 1
    end
    return {h =h,nx = nx , ny =ny,nz = nz}
end
function Collison.Handle(entity,velocity,p)
    local apos = entity.Position
    local hx,hy,hz = entity.HitBoxSize.x,entity.HitBoxSize.y,entity.HitBoxSize.z
    local x,y,z = entity.Position[1],entity.Position[2],entity.Position[3]
    local px ,py,pz = p[1],p[2],p[3]
    local dx = x-px
    local dy = y-py
    local dz = z-pz
    local minXi = math.floor(math.min(x,px)-hx/2)
    local maxXi = math.floor(math.max(x,px)+hx/2)
    local minYi = math.floor(math.min(y,py)-hy/2)
    local maxYi = math.floor(math.max(y,py)+hy/2)
    local minZi = math.floor(math.min(z,pz)-hz/2)
    local maxZi = math.floor(math.max(z,pz)+hz/2)

    local r = {h = 1,nx = 0,ny = 0,nz = 0}

    for yi = minYi, maxYi,1 do
        for zi = minZi, maxZi,1 do
            for xi = minXi, maxXi,1 do
                local block,pos = refunction.GetBlock({xi,yi,zi})

                if block then
                    pos = refunction.convertPositionto(pos,"table")
                    local c = Collison.SweapAABB(
                        px - hx/2, py - hy/2,pz-hz/2,
                        hx,hy,hz,
                        pos[1],pos[2],pos[3],
                        4,4,4,
                        dx,dy,dz
                    )
                    if c.h < r.h then
                        r = c
                    end
                end
            end
        end
    end

    local ep = 0.001
    x = px + r.h*dx+ep*r.nx 
    y = py + r.h*dy+ep*r.ny 
    z = pz + r.h*dz+ep*r.nz 
    print( r.h)
    if r.h == 1 then return end 

    local  BdotB = r.nx*r.nx+r.ny*r.ny+r.nz*r.nz
    if BdotB ~= 0 then
        px = x
        py = x
        pz = x
        local AdotB = (1-r.h)*(dx*r.nx + dy*r.ny + dz*r.nz)
       -- x +=(1-r.h)*dx  - (AdotB/BdotB)*r.nx
      --  y +=(1-r.h)*dy  - (AdotB/BdotB)*r.ny
      --  z +=(1-r.h)*dz  - (AdotB/BdotB)*r.nz
    end
    return {x,y,z}
end
return Collison