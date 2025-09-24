-- I got most of this config from https://github.com/VonHeikemen/lsp-zero.nvim
-- It sets up the autocomplete and LSP related plugins

-- Start LSP Installer
require('mason').setup()

-- Expand LSP capabilities to include the cmp_nvim_lsp autocomplete functionality
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
	'force',
	lspconfig_defaults.capabilities,
	require('cmp_nvim_lsp').default_capabilities()
)

-- Enable LSP features, mostly keybinds
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP Actions',
	callback = function(event)
		local opts = { buffer = event.buf }

		-- Create LSP bindings when LSP is availible
		require('config.remap').lsp_keybinds(opts)
	end,
})

-- Make it so LSP error diagnostics are shown when the error is hovered over
-- There's bug where if you're hovering over an error, then open a new file in the
-- same buffer, the hover stays
vim.api.nvim_create_autocmd('CursorHold', {
    desc = 'LSP Error Hover',
    callback = function(event)
        vim.diagnostic.open_float()
    end,
})

-- Configure Autocomplete
local cmp = require('cmp')

cmp.setup({
    snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end
	},
    sources = {
        -- cmp-nvim-lsp
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' }
    },
    -- Set keybinds according to what we have in our remap for cmp
    mapping = cmp.mapping.preset.insert(require('config.remap').cmp_keybinds),
})

-- Configure LSPs
vim.lsp.enable('clangd')
vim.lsp.enable('texlab')

-- Github pages for plugins:
-- https://github.com/hrsh7th/nvim-cmp
-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/hrsh7th/cmp-nvim-lsp
-- https://github.com/williamboman/mason.nvim
