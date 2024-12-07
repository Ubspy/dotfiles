local cmp = require('cmp')
local knap = require('knap')
local gitsigns = require('gitsigns')
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

-- Create an item to help with \item in tex files
-- Autocmd to make it only apply to "tex" files
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        -- Do a noremap keybind with a callback for the enter key
        vim.api.nvim_set_keymap('i', '<CR>', '',
            { noremap = true, callback = function()
                -- Look at line when <CR> is pressed
                local line = vim.fn.getline('.')

                -- Insert newline
                vim.cmd('normal! i\r')

                -- If the line matches the regex, start line, whitespace, \item
                if line:match('^\\s+\\item') then
                    -- Inset "\item "
                    vim.cmd('normal! i\\item  ')
                end
            end })
    end
})

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

-- Array for cmp plugin keybinds
export.cmp_keybinds = { ['<CR>'] = cmp.mapping.confirm({ select = true }) }

function export.git_keybinds(opts)
	-- Navigation next
	-- TODO:
	-- ]c and [c are nvim default diff keybinds
	-- if you find somehting better, change it
	vim.keymap.set('n', ']c', function()
		if vim.wo.diff then
			vim.cmd.normal({']c', bang = true})
		else
			gitsigns.nav_hunk('next')
		end
	end, opts)

	-- Navigation next
	vim.keymap.set('n', '[c', function()
		if vim.wo.diff then
			vim.cmd.normal({'[c', bang = true})
		else
			gitsigns.nav_hunk('prev')
		end
	end, opts)

	-- Actions
	vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk)
	vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk)
	vim.keymap.set('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
	vim.keymap.set('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
	vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer)
	vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk)
	vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer)
	vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk)
	vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
	vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame)
	vim.keymap.set('n', '<leader>hd', gitsigns.diffthis)
	vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~1') end)
	vim.keymap.set('n', '<leader>td', gitsigns.toggle_deleted)
end

-- Knap bindings
vim.keymap.set('n', '<F5>', knap.process_once)
vim.keymap.set('v', '<F5>', knap.process_once)
vim.keymap.set('i', '<F5>', knap.process_once)

vim.keymap.set('n', '<F6>', knap.close_viewer)
vim.keymap.set('v', '<F6>', knap.close_viewer)
vim.keymap.set('i', '<F6>', knap.close_viewer)

vim.keymap.set('n', '<F7>', knap.toggle_autopreviewing)
vim.keymap.set('v', '<F7>', knap.toggle_autopreviewing)
vim.keymap.set('i', '<F7>', knap.toggle_autopreviewing)

vim.keymap.set('n', '<F8>', knap.forward_jump)
vim.keymap.set('v', '<F8>', knap.forward_jump)
vim.keymap.set('i', '<F8>', knap.forward_jump)

-- Return export so the LSP file has access to this function
return export
