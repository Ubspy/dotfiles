-- This one has to go first
require("config.lazy")

-- Rest of the configs
require("config.colors")
require("config.comments")
require("config.git")
require("config.lsp")
require("config.lualine")
require("config.remap")
require("config.telescope")
require("config.treesitter")

-- Add extra space to align tabs
vim.bo.expandtab = true

-- Highlight the line number the cursor is currently on
vim.wo.cursorline = true
vim.wo.cursorlineopt = "number"

-- Add <> as a pair for HTML/XML
vim.bo.matchpairs = "(:),{:},[:],<:>"

-- Add line numbers
vim.wo.number = true

-- Set scroll start at 8 lines above or below edge of window
vim.wo.scrolloff = 8

-- Always show tabs at the top
vim.go.showtabline = 2

-- Search case sensitive only if capital letters are introduced
vim.go.smartcase = true

-- No text wrapping to the next line
vim.wo.wrap = false

-- Set tab size to 4 spaces
vim.bo.shiftwidth = 4       -- When using > or < in normal mode, only shift by 4
vim.bo.smartindent = true   -- Auto indenting based off brackets and other stuff
vim.bo.tabstop = 4          -- Set tab to 4 spaces
vim.bo.softtabstop = 4      -- Smart tabs, so you can turn the tabs into spaces as needed


-- More options that might be interesting later:
-- Automatically change working dir when using different buffers
-- vim.wo.autochdir = true (default false)

-- Automatically save files
-- vim.wo.autowrite = true (default false)

-- When :cd is run, change working DIR to $HOME
-- vim.wo.cdhome = true (default false)

-- Automatic indenting when programming C (idk how good it works)
-- vim.wo.cindent = on

-- Manage clipboard (planning on using a plugin for this)
-- vim.wo.clipboard = 

-- Options for code completion
-- vim.go.completeopt = "menu,preview"

-- Checkout fold options, might be interesting to have keybinds for closing folds
-- vim.wo.foldmatch = "indent"
-- zc and zv open and close folds
-- Set the text of a cloased fold
-- vim.wo.foldtext = 

-- Ignore case when searching
-- vim.wo.ignorecase = true

-- Set height of preview window
-- vim.go.previewheight = 12
