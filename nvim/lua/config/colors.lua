-- Configure the onedark colorscheme
require('onedark').setup({
	-- Main options
	style = 'darker',
	transparent = true,

	-- Redefine cyan to be less abrassive
	colors = {
		new_cyan = "#69c9c9"
	},
	-- Tell everything that uses cyan in this colorscheme to use the
	-- more friendly version
	highlights = {
		["@attribute"] = {fg = '$new_cyan'},
		["@function.builtin"] = {fg ='$new_cyan' , fmt = 'none'},
		["@function.macro"] = {fg ='$new_cyan' , fmt = 'none'},
		["@markup.link.url"] = {fg = '$new_cyan', fmt = 'underline'},
		["@property"] = {fg = '$new_cyan'},
		["@string.special.symbol"] = {fg = '$new_cyan'},
	 	["@variable.member"] = {fg = "$new_cyan"},
	}
})

-- Set colorscheme
vim.cmd.colorscheme("onedark")

-- Set default nvim background to transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Set column at 80 characters
vim.g.virtcolumn_char = '▕'
vim.g.virtcolumn_priority = 10
vim.wo.colorcolumn = '81'
