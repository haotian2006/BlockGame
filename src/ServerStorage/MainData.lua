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
			["position"] = {},
			["IsChild"] = false,
		}]]
		["clone"]= { -- a uuid
			["Name"] = "Mar",
			["Age"] = "0",
			["Position"] = {-68,84,-120},
			["IsChild"] = false,
            Rotation = {0,0,0},
            Events = {}
		},
	
	},
	["LoadedEntitys"] ={}
}
