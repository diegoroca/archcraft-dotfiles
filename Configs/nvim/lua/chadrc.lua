-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
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
}

-- M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
