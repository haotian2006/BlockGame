local Blocks_Folder = game:GetService("ReplicatedStorage").Block_Models
local texture_folder = game:GetService("ReplicatedStorage").Block_Texture
local Blocks = {
	["Stone"] = {
		["Model"] = Blocks_Folder.Block;
		["Override"] = true;
		["IsTransparent"] = false;
	},
	["Grass"] = {
		["Model"] = Blocks_Folder.Block;
		["Override"] = true;
		["IsTransparent"] = false;
	},
	["Dirt"] = {
		["Model"] = Blocks_Folder.Block;
		["Override"] = true;
		["IsTransparent"] = false;
	},
	["Slab"] = {
		["Model"] = Blocks_Folder.Slab;
		["Override"] = true;
		["IsTransparent"] = false;
	},
	["air"] = {
		["IsTransparent"] = true;
	}
}
return Blocks
