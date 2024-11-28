local builtin = require("telescope.builtin")

vim.g.mapleader = " "

-- Telescope find files
vim.keymap.set('n', '<C-f>f', builtin.find_files )

-- Telescope find files in current git repo
vim.keymap.set('n', '<C-f>g', builtin.git_files )

-- Telescope live grep working dir
vim.keymap.set('n', '<C-f>s', builtin.live_grep )

-- Telescope string in file
vim.keymap.set('n', '<C-f>', function()
	builtin.live_grep({ grep_open_files = true })
end )

-- Telescope vim commands
vim.keymap.set('n', '<C-f>c', builtin.commands, { desc = 'Telescope vim commands' })

-- Create export object to hold LSP keybinds
local export = {}

function export.lsp_keybinds(opts)
	vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
	vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
	vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
	vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
	vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
	vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
	vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
	vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
	vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
	vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

-- Return export so the LSP file has access to this function
return export
