-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.ui = {
	theme = "gruvbox",
	
	changed_themes = {
		gruvbox = {
			base_16 = {
				base00 = "#121212",
			},
			base_30 = {
				black = "#121212",
				darker_black = "#0E0E0E",
				black2 = "#1E1E1E",
				statusline_bg = "#1C1C1C",
				lightbg = "#282828",
			},
				
		},

	},
	
	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

return M
