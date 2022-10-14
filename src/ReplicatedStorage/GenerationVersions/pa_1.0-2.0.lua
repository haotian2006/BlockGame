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
PART_SCALE = 4
NOISE_SCALE = 100
HEIGHT_SCALE = 40*2

OCTAVES = 1
LACUNARITY = 0
PERSISTENCE = 2
SEED = 12345

amplitude = 100
noiseScale =0.99--40*2
local maxheight = 40*4
local function pack(pos:Vector3)
	local statement = pos.X..","..pos.Y..","..pos.Z
	return statement
end
local function pack2(x,y,z)
	local statement = x..","..y..","..z
	return statement
end												
function Generation.GetBlockName(position:Vector3,generated)
	generated = generated or {}
	local noneeffect = Generation.Noise(position.X,position.Z,OCTAVES,LACUNARITY,PERSISTENCE,NOISE_SCALE,SEED)
	local Surface = (2+ noneeffect)*HEIGHT_SCALE
	local blocktogen = "Stone"
	local x,y,z = position.X,position.Y,position.Z
	if generated and not generated[pack2(x,y+4,z)] then
		blocktogen = "Grass"
	elseif generated and generated[pack2(x,y+4,z)]  and generated[pack2(x,y+4,z)][1] and generated[pack2(x,y+4,z)][1] == "Grass" then
		blocktogen = "Dirt"
	end
	return (position.Y<Surface and position.Y <=maxheight and Generation.CheckForCave(position)or position.Y == 0) and blocktogen or nil
end
function Generation.CheckForCave(Position)
	-- local x,y,z = Position.X,Position.Y,Position.Z
	-- local xNoise = math.noise(y/noiseScale,z/noiseScale,SEED) * amplitude
	-- local yNoise = math.noise(x/noiseScale,z/noiseScale,SEED) * amplitude
	-- local zNoise = math.noise(x/noiseScale,y/noiseScale,SEED) * amplitude	

	-- local density = xNoise + yNoise + zNoise
	-- return density < 20
		local x,y,z = Position.X,Position.Y,Position.Z
		x /= noiseScale
		y /= noiseScale
		z /= noiseScale
		local n0 = PerlinNoiseAPI.new({x,y,z},amplitude)
	--x *= 0.9
	--y *= 0.9
	--z *= 0.9
	--local xNoise = math.noise(y/noiseScale,z/noiseScale,SEED) * amplitude
	--local yNoise = math.noise(x/noiseScale,z/noiseScale,SEED) * amplitude
	--local zNoise = math.noise(x/noiseScale,y/noiseScale,SEED) * amplitude	
	local n0 = PerlinNoiseAPI.new({x,y,z,SEED},amplitude)

	--x +=noiseScale*0.5
	--y +=noiseScale*0.5
	--z +=noiseScale*0.5
	--local n1 = noise.new({x,y,z},amplitude)
	local density = n0--math.min(n0,n1)
	return density >0
end

function Generation.GetBlock(pos:Vector3)
	local c =Generation.GetBlockName(pos)
	return c and {c,0,{0,0,0},{pos.X,pos.Y,pos.Z},0,true}
end
function Generation.GetChunks(chuncks,getall)
	local versiontouse
	local new = {}
	for i,v in pairs(chuncks)do
		for index,coord in ipairs(v) do
			for y = maxheight,0,-4 do
				--task.spawn(function()
				local coords = string.split(coord,"x")
				local position = Vector3.new(coords[1],y,coords[2])
				local block,id = Generation.GetBlockName(position,new[i])
				id = 0
				if  (block ~= nil and block ~="Air")or getall then
					new[i] = new[i] or {}
					local packpos = pack(position)
					new[i][packpos] = {block,id,{0,0,0},packpos,i,true}
				end
			end
		end
	end
	return new
end
PerlinNoiseAPI = {}

function PerlinNoiseAPI.new(coords,amplitude,octaves,persistence)
	coords = coords or {}
	octaves = octaves or 1
	persistence = persistence or 0.5
	if #coords > 4 then
		error("The Perlin Noise API doesn't support more than 4 dimensions!")
	else
		if octaves < 1 then
			error("Octaves have to be 1 or higher!")
		else
			local X = coords[1] or 0
			local Y = coords[2] or 0
			local Z = coords[3] or 0
			local W = coords[4] or 0

			amplitude = amplitude or 10
			octaves = octaves-1
			if W == 0 then
				local perlinvalue = (math.noise(X/amplitude,Y/amplitude,Z/amplitude))
				if octaves ~= 0 then
					for i = 1,octaves do
						perlinvalue = perlinvalue+(math.noise(X/(amplitude*(persistence^i)),Y/(amplitude*(persistence^i)),Z/(amplitude*(persistence^i)))/(2^i))
					end
				end
				return perlinvalue
			else
				local AB = math.noise(X/amplitude,Y/amplitude)
				local AC = math.noise(X/amplitude,Z/amplitude)
				local AD = math.noise(X/amplitude,W/amplitude)
				local BC = math.noise(Y/amplitude,Z/amplitude)
				local BD = math.noise(Y/amplitude,W/amplitude)
				local CD = math.noise(Z/amplitude,W/amplitude)

				local BA = math.noise(Y/amplitude,X/amplitude)
				local CA = math.noise(Z/amplitude,X/amplitude)
				local DA = math.noise(W/amplitude,X/amplitude)
				local CB = math.noise(Z/amplitude,Y/amplitude)
				local DB = math.noise(W/amplitude,Y/amplitude)
				local DC = math.noise(W/amplitude,Z/amplitude)

				local ABCD = AB+AC+AD+BC+BD+CD+BA+CA+DA+CB+DB+DC

				local perlinvalue = ABCD/12

				if octaves ~= 0 then
					for i = 1,octaves do
						local AB = math.noise(X/(amplitude*(persistence^i)),Y/(amplitude*(persistence^i)))
						local AC = math.noise(X/(amplitude*(persistence^i)),Z/(amplitude*(persistence^i)))
						local AD = math.noise(X/(amplitude*(persistence^i)),W/(amplitude*(persistence^i)))
						local BC = math.noise(Y/(amplitude*(persistence^i)),Z/(amplitude*(persistence^i)))
						local BD = math.noise(Y/(amplitude*(persistence^i)),W/(amplitude*(persistence^i)))
						local CD = math.noise(Z/(amplitude*(persistence^i)),W/(amplitude*(persistence^i)))

						local BA = math.noise(Y/(amplitude*(persistence^i)),X/(amplitude*(persistence^i)))
						local CA = math.noise(Z/(amplitude*(persistence^i)),X/(amplitude*(persistence^i)))
						local DA = math.noise(W/(amplitude*(persistence^i)),X/(amplitude*(persistence^i)))
						local CB = math.noise(Z/(amplitude*(persistence^i)),Y/(amplitude*(persistence^i)))
						local DB = math.noise(W/(amplitude*(persistence^i)),Y/(amplitude*(persistence^i)))
						local DC = math.noise(W/(amplitude*(persistence^i)),Z/(amplitude*(persistence^i)))

						local ABCD = AB+AC+AD+BC+BD+CD+BA+CA+DA+CB+DB+DC

						perlinvalue = perlinvalue+((ABCD/12)/(2^i))
					end
				end
				return perlinvalue
			end
		end
	end
end

return Generation
