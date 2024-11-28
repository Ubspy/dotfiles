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

-- Configure Autocomplete
local cmp = require('cmp')

cmp.setup({
	sources = {
		-- cmp-nvim-lsp
		{ name = 'nvim_lsp' },
	},
	snippet = {
		expand = function(args)
			-- I'm assuming this is a snippet completion
			-- From docs it looks like specifying a snipper engine is required
			vim.snippet.expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({}),
})

-- Configure LSPs
local lspconfig = require('lspconfig')
lspconfig.clangd.setup{}
