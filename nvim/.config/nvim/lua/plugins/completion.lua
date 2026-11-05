return {
	-- Completion + snippets
	{
		"saghen/blink.cmp",
		version = "1.*", -- release tags ship prebuilt fuzzy-matcher binaries for mac/linux/windows
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = { "rafamadriz/friendly-snippets" },
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- Tab accepts / jumps to next snippet placeholder, S-Tab jumps back.
			-- C-space: open menu/docs   C-e: close   C-n/C-p or Up/Down: select   C-k: signature
			keymap = { preset = "super-tab" },

			appearance = { nerd_font_variant = "mono" },

			completion = {
				accept = { auto_brackets = { enabled = true } }, -- add () after functions
				list = {
					selection = {
						-- don't hijack Tab while jumping through a snippet
						preselect = function()
							return not require("blink.cmp").snippet_active({ direction = 1 })
						end,
					},
				},
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
			},

			signature = { enabled = true },

			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			cmdline = {
				keymap = { preset = "inherit" },
				completion = { menu = { auto_show = true } },
			},

			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},

	-- Auto-close brackets/quotes while typing
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = { check_ts = true },
	},
}
