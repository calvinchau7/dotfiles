-- Viewing non-text files: images, PDFs, rendered markdown.
-- Images use the kitty graphics protocol (Ghostty, kitty, WezTerm).
-- Needs: imagemagick (non-png formats), ghostscript (pdf). Both in the Brewfile.

return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		init = function()
			-- snacks detects the terminal by asking its name; inside tuios the answer
			-- is "tuios", so it would disable images. tuios forwards kitty graphics
			-- (incl. unicode placeholders) to Ghostty/kitty, so treat it as ghostty.
			if vim.env.TUIOS_ENV and not vim.env.SNACKS_GHOSTTY then
				vim.env.SNACKS_GHOSTTY = "1"
			end
		end,
		opts = {
			image = {
				enabled = true,
				-- render images inline in markdown/html/etc; hover for the rest
				doc = { enabled = true, inline = true, float = true, max_width = 80, max_height = 40 },
			},
			-- Sidebar file tree. Oil still handles `nvim .` and `-`.
			explorer = { replace_netrw = false },
			picker = {
				sources = {
					explorer = { hidden = true }, -- show dotfiles
				},
			},
		},
		keys = {
			{
				"<leader>e",
				function()
					Snacks.explorer()
				end,
				desc = "File explorer",
			},
			{
				"<leader>ui",
				function()
					Snacks.image.hover()
				end,
				desc = "Show image under cursor",
			},
		},
	},

	-- Pretty markdown in the buffer: headings, tables, code blocks, checkboxes.
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		opts = {
			completions = { blink = { enabled = true } },
		},
		keys = {
			{ "<leader>um", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
		},
	},
}
