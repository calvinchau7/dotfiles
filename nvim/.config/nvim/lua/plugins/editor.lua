return {
	-- Show pending keybinds (press <leader> and wait)
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>x", group = "diagnostics/quickfix" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>h", group = "hunks" },
				{ "<leader>q", group = "quit" },
				{ "<leader>s", group = "search" },
				{ "<leader>u", group = "toggle" },
				{ "gr", group = "lsp" },
			},
		},
	},

	-- File explorer that edits the filesystem like a buffer. `-` opens the parent dir.
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false, -- recommended so `nvim .` opens oil
		keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
		opts = {
			view_options = { show_hidden = true },
		},
	},

	-- Add/change/delete surrounding pairs: ys{motion}{char}, cs{old}{new}, ds{char}
	{
		"kylechui/nvim-surround",
		version = "^4.0.0",
		event = "VeryLazy",
		opts = {},
	},

	-- Detect indentation (tabs vs spaces, width) from the file being edited
	{ "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } },

	-- Save/restore sessions per directory
	{
		"folke/persistence.nvim",
		event = "BufReadPre", -- only start saving once a real file is opened
		opts = {},
		keys = {
			{
				"<leader>qs",
				function()
					require("persistence").load()
				end,
				desc = "Restore session (cwd)",
			},
			{
				"<leader>qS",
				function()
					require("persistence").select()
				end,
				desc = "Select session",
			},
			{
				"<leader>ql",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore last session",
			},
			{
				"<leader>qd",
				function()
					require("persistence").stop()
				end,
				desc = "Don't save this session",
			},
		},
	},

	-- Diagnostics / references / quickfix in a list panel
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
			{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols outline" },
			{ "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs/defs" },
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
		},
	},

	-- Highlight and search TODO/FIXME/HACK/NOTE comments
	{
		"folke/todo-comments.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next TODO",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Prev TODO",
			},
			{ "<leader>st", "<cmd>TodoFzfLua<cr>", desc = "TODOs" },
		},
	},
}
