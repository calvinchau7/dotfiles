require("config.lazy")
require("config.options")

vim.opt.clipboard:append("unnamedplus")

vim.opt.number = true
vim.opt.relativenumber = true

vim.diagnostic.config({
	-- virtual_text = {
	-- 	spacing = 4,
	-- 	source = "if_many",
	-- },
	underline = true,
	signs = true,
	float = {
		border = "rounded",
		source = "always",
	},
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic message" })

vim.keymap.set("n", "K", function()
	local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diagnostics > 0 then
		vim.diagnostic.open_float(nil, { focus = false })
	else
		vim.lsp.buf.hover()
	end
end, { desc = "Hover or Diagnostics" })
