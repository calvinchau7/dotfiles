-- nvim-treesitter `main` branch (the supported branch for Neovim 0.12).
-- Requirements (see the plugin README):
--   * tree-sitter CLI >= 0.26.1 from your package manager (not npm):
--       macOS: brew install tree-sitter-cli   Windows: winget install tree-sitter.tree-sitter-cli
--       Linux: distro package, or `cargo install --locked tree-sitter-cli`
--   * a C compiler on PATH
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- the plugin does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install({
			-- systems
			"c",
			"cpp",
			"rust",
			"zig",
			"odin",
			"go",
			"gomod",
			"gosum",
			"gowork",
			-- work stack
			"python",
			"htmldjango",
			"html",
			"css",
			"javascript",
			"typescript",
			"tsx",
			"json",
			"yaml",
			"toml",
			"sql",
			"bash",
			"powershell",
			"dockerfile",
			-- editor / misc
			"lua",
			"luadoc",
			"vim",
			"vimdoc",
			"query",
			"regex",
			"markdown",
			"markdown_inline",
			"diff",
			"gitcommit",
			"git_rebase",
			"gitignore",
			"git_config",
			"make",
			"cmake",
			"comment",
		})

		-- Highlighting, folds and indent are opt-in per filetype (see README "Supported features")
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
			callback = function(ev)
				-- skip filetypes without a parser
				if not pcall(vim.treesitter.start, ev.buf) then
					return
				end
				vim.wo[0][0].foldmethod = "expr"
				vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
