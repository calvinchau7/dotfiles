return {
	"ellisonleao/gruvbox.nvim",
	lazy = false,
	priority = 1000, -- load before other plugins
	opts = {
		contrast = "hard", -- darker gruvbox
	},
	config = function(_, opts)
		vim.o.background = "dark"
		require("gruvbox").setup(opts)
		vim.cmd.colorscheme("gruvbox")
	end,
}
