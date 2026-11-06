-- LSP
--   mason.nvim             installs servers/tools (cross-platform)
--   nvim-lspconfig         ships default server configs (lsp/*.lua)
--   mason-lspconfig.nvim   installs the servers below and vim.lsp.enable()s them
--   mason-tool-installer   installs formatters/linters
-- Per-server overrides live in after/lsp/<server>.lua.
--
-- Built-in LSP keymaps (Neovim 0.11+):
--   K hover   grn rename   gra code action   grr references   gri implementation
--   grt type definition   gO document symbols   <C-s> (insert) signature help
--   [d / ]d prev/next diagnostic   <C-w>d diagnostic float

return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
			"b0o/SchemaStore.nvim", -- JSON/YAML schemas, used in after/lsp/{jsonls,yamlls}.lua
		},
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			ensure_installed = {
				-- systems
				"clangd", -- C / C++
				"rust_analyzer", -- Rust
				-- zls: prefers zvm's (see config below)
				"ols", -- Odin
				"gopls", -- Go
				-- work stack
				"basedpyright", -- Python types
				"ruff", -- Python lint/format/imports
				"ts_ls", -- JavaScript / TypeScript
				"html", -- HTML + Django templates
				"cssls", -- CSS
				"jsonls", -- JSON
				"yamlls", -- YAML
				"taplo", -- TOML
				"bashls", -- shell
				"marksman", -- Markdown
				"lua_ls", -- Lua
			},
			-- stylua ships an LSP mode; formatting already goes through conform
			automatic_enable = { exclude = { "stylua" } },
		},
		config = function(_, opts)
			-- zls must match the zig version, so use zvm's when it's on PATH and
			-- only let mason install one on machines without it
			local has_zls = vim.fn.executable("zls") == 1
			if not has_zls then
				table.insert(opts.ensure_installed, "zls")
			end

			require("mason-lspconfig").setup(opts)

			if has_zls then
				vim.lsp.enable("zls")
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
				callback = function(ev)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
					end
					map("gd", vim.lsp.buf.definition, "Goto definition")
					map("gD", vim.lsp.buf.declaration, "Goto declaration")
					map("<leader>cs", "<cmd>FzfLua lsp_document_symbols<cr>", "Document symbols")
					map("<leader>cS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", "Workspace symbols")
					map("<leader>uh", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
							{ bufnr = ev.buf }
						)
					end, "Toggle inlay hints")
				end,
			})
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"stylua", -- Lua
				"clang-format", -- C / C++
				"goimports", -- Go
				"prettierd", -- JS/TS/HTML/CSS/JSON/YAML/Markdown
				"djlint", -- Django templates
				"shfmt", -- shell
				"shellcheck", -- shell lint (used by bashls)
			},
		},
	},

	-- Lua LSP understands the Neovim API and plugins when editing this config
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
		},
	},
}
