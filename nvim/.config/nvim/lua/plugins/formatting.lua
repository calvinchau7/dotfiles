-- Formatting with conform.nvim. Formats on save; toggle with <leader>uf (buffer) / <leader>uF (global).
-- Languages not listed fall back to their LSP's formatter (rust-analyzer -> rustfmt,
-- zls -> zig fmt, gopls, taplo, etc.).
--
-- Every file is formatted on save. Each formatter follows the project's own config when
-- one exists (.prettierrc, pyproject.toml [tool.ruff], .clang-format, stylua.toml,
-- rustfmt.toml, .djlintrc, .editorconfig, ...) and its default style otherwise.

return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ async = true })
			end,
			mode = { "n", "x" },
			desc = "Format",
		},
		{
			"<leader>uf",
			function()
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify("Format on save (buffer): " .. (vim.b.disable_autoformat and "off" or "on"))
			end,
			desc = "Toggle format on save (buffer)",
		},
		{
			"<leader>uF",
			function()
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Format on save (global): " .. (vim.g.disable_autoformat and "off" or "on"))
			end,
			desc = "Toggle format on save (global)",
		},
	},
	---@module 'conform'
	---@type conform.setupOpts
	opts = {
		formatters_by_ft = {
			python = { "ruff_organize_imports", "ruff_format" },
			go = { "goimports", "gofmt" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			odin = { "odinfmt" },
			lua = { "stylua" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			html = { "prettierd" },
			css = { "prettierd" },
			json = { "prettierd" },
			jsonc = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			htmldjango = { "djlint" },
			sh = { "shfmt" },
			bash = { "shfmt" },
		},
		default_format_opts = { lsp_format = "fallback" },
		format_on_save = function(buf)
			if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
				return
			end
			return { timeout_ms = 1000 }
		end,
	},
}
