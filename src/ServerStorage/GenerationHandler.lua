local Generation = {}
Generation.Noise = function(x, y, octaves, lacunarity, persistence, scale, seed)
	local value = 0 
	local x1 = x 
	local y1 = y
	local amplitude = 1
	for i = 1, octaves, 1 do
		value += math.noise(x1 / scale, y1 / scale, seed) * amplitude
		y1 *= lacunarity
		x1 *= lacunarity
		amplitude *= persistence
	end
	return math.clamp(value, -1, 1)
end
--local Surface = 7
PART_SCALE = 4
NOISE_SCALE = 100
HEIGHT_SCALE = 40

OCTAVES = 4
LACUNARITY = 0
PERSISTENCE = 2
SEED = 123
local function pack(pos:Vector3)
	local statement = pos.X..","..pos.Y..","..pos.Z
	return statement
end
function Generation.GetBlock(position:Vector3)
	local Surface = (2+ Generation.Noise(position.X,position.Z,OCTAVES,LACUNARITY,PERSISTENCE,NOISE_SCALE,SEED))*HEIGHT_SCALE
	return (position.Y<Surface) and "Stone" or nil
end
function Generation.GetChunks(chuncks)
	local new = {}
	for i,v in pairs(chuncks)do
		for index,coord in ipairs(v) do
			for y = 0,80,4 do
				--task.spawn(function()
					local coords = string.split(coord,"x")
					local position = Vector3.new(coords[1],y,coords[2])
					local block,id = Generation.GetBlock(position)
					id = 0
					if  block ~= nil and block ~="Air" then
						new[i] = new[i] or {}
						local packpos = pack(position)
						new[i][packpos] = {block,id,{0,0,0},packpos,i,true}
					end
			end
		end
	end
	return new
end
return Generation
