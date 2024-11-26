local builtin = require("telescope.builtin")

vim.g.mapleader = " "
vim.keymap.set('n', '<C-f>f', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<C-f>g', builtin.git_files, { desc = 'Telescope find files in git repo' })
vim.keymap.set('n', '<C-f>s', builtin.live_grep, { desc = 'Telescope live grep working dir' })
vim.keymap.set('n', '<C-f>', function()
	builtin.live_grep({ grep_open_files = true })
end, { desc = 'Telescope string in file' })
vim.keymap.set('n', '<C-f>c', builtin.commands, { desc = 'Telescope vim commands' })
