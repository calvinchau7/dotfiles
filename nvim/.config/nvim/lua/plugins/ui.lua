return {
	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "gruvbox",
				globalstatus = true,
				component_separators = "",
				section_separators = "",
			},
			sections = {
				lualine_c = { { "filename", path = 1 } }, -- path relative to cwd
				lualine_x = { "lsp_status", "filetype" },
			},
		},
	},

	-- Pin the enclosing function/class header at the top while scrolling
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		opts = { max_lines = 3 },
		keys = {
			{ "<leader>ut", "<cmd>TSContext toggle<cr>", desc = "Toggle sticky context" },
		},
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = { char = "│" },
			scope = { show_start = false, show_end = false },
		},
	},
}
