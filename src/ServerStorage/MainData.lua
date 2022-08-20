return {
    ["Chunck"] ={
		--[["0x0"] ={t
			["Stone"]={
				["Position"] = {{0,0,0},{4,0,4},{4,-4,8},{8,-4,8},{4,-4,16},{4,-4,12},{4,-4,24},{-32,-4,-32},{28,-4,28},{-32, -4, 28}},
				["Id"] ={0,0,0,0}
			} --Old Saving Method
		};]]
	--[["0x0"] ={
		["0,0,0"] = {"Stone",1,1,{0,90,0}}--(name,Direaction,State,rotation)
	};]]-- New quicker method
	},
	["LoadedBlocks"] ={

	}, 
	["BlockNbt"] ={

	},
	["Entitys"] ={
	--[[	["190-099-3210"] { -- a uuid
			["Name"] = "Example",
			["Age"] = "0",
			["Position"] = {},
			["IsChild"] = false,
		}]]
		["haotian2006"]= { -- a uuid
			["Name"] = "aar",
			["Age"] = "0",
			["Position"] = {-68,86,-120},
			HitBoxSize = {x =1.5,y=4,z=1.5},
			behaviors = {
			},
            Rotation = {0,0,0},
            Events = {},
			["NotSaved"] = {Velocity={}},
			FallTicks = 0,
			maxfallvelocity = 3.92,
			FallDistance = 0,
		},
	},
	["LoadedEntitys"] ={}
}
