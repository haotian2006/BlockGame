local Blocks_Folder = game:GetService("ReplicatedStorage").Block_Models
local texture_folder = game:GetService("ReplicatedStorage").Block_Texture
local Blocks = {
	["Stone"] = {
		["Model"] = Blocks_Folder.Block;
		["Override"] = true;
		["IsTransparent"] = false;
		["Id"] = 0;
	}
}
return Blocks
