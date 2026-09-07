return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "lua_ls", "rust_analyzer" },
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				rust = { "rustfmt", lsp_format = "fallback" },
				qml = { "qmlformat" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim", "hl" } },
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
						},
					},
				},
				qmlls = {
					cmd = { "qmlls6" },
					filetypes = { "qml" },
					root_markers = { "qmldir", ".git" },
				},
				rust_analyzer = {},
				pyright = {},
				ts_ls = {},
			}

			for name, opts in pairs(servers) do
				vim.lsp.config(name, opts)
				vim.lsp.enable(name)
			end
		end,
	},
}
