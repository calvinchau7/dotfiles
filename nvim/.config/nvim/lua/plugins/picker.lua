-- Fuzzy finder: fzf-lua. Needs `fzf`; uses `rg` and `fd` when available.
--   macOS:   brew install fzf ripgrep fd
--   Linux:   install fzf, ripgrep, fd (fd-find) from your package manager
--   Windows: winget install junegunn.fzf BurntSushi.ripgrep.MSVC sharkdp.fd
return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "FzfLua",
	event = "VeryLazy", -- load early so vim.ui.select (code actions) uses fzf-lua
	keys = {
		{ "<leader><space>", "<cmd>FzfLua files<cr>", desc = "Find files" },
		{ "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Grep project" },
		{ "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		-- find
		{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
		{ "<leader>fr", "<cmd>FzfLua oldfiles cwd_only=true<cr>", desc = "Recent files (cwd)" },
		{ "<leader>fR", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files (all)" },
		{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
		{
			"<leader>fc",
			function()
				require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Config files",
		},
		-- search
		{ "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
		{ "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep word under cursor" },
		{ "<leader>sw", "<cmd>FzfLua grep_visual<cr>", mode = "x", desc = "Grep selection" },
		{ "<leader>sb", "<cmd>FzfLua blines<cr>", desc = "Search buffer lines" },
		{ "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics (buffer)" },
		{ "<leader>sD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics (workspace)" },
		{ "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "Help" },
		{ "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
		{ "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "Commands" },
		{ "<leader>s:", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
		{ "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },
		{ "<leader>sq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix list" },
		{ "<leader>su", "<cmd>FzfLua undotree<cr>", desc = "Undo history" },
		-- git
		{ "<leader>gf", "<cmd>FzfLua git_files<cr>", desc = "Git files" },
		{ "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git status" },
		{ "<leader>gl", "<cmd>FzfLua git_commits<cr>", desc = "Git log" },
		{ "<leader>gL", "<cmd>FzfLua git_bcommits<cr>", desc = "Git log (file)" },
		{ "<leader>gB", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
	},
	opts = {
		"default-title",
		ui_select = {}, -- use fzf-lua for vim.ui.select
		winopts = { height = 0.85, width = 0.85 },
	},
}
