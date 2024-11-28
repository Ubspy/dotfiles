return{
	{
		-- LSP Installer
		"williamboman/mason.nvim",
		lazy = false,
		url = "https://github.com/williamboman/mason.nvim"
	},
	{
		-- LSP Official Quickstart Configs
		"neovim/nvim-lspconfig",
		lazy = false,
		url = "https://github.com/neovim/nvim-lspconfig"
	},
	{
		-- Autocomplete
		"hrsh7th/nvim-cmp",
		lazy = false,
		url = "https://github.com/hrsh7th/nvim-cmp",
		dependencies = { "hrsh7th/cmp-nvim-lsp" }
	},
	{
		-- LSP Autocomplete Integration
		"hrsh7th/cmp-nvim-lsp",
		lazy = true,
		url = "https://github.com/hrsh7th/cmp-nvim-lsp"
	}
}
