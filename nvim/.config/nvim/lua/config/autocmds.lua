-- Indentation per language comes from Neovim's built-in ftplugins (Go/Make use tabs),
-- .editorconfig files (built-in support), and the formatters in plugins/formatting.lua.
local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Flash yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Reopen files at the last cursor position (:h restore-cursor)
vim.api.nvim_create_autocmd("BufReadPost", {
	group = group,
	callback = function(ev)
		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		if
			mark[1] > 0
			and mark[1] <= vim.api.nvim_buf_line_count(ev.buf)
			and not vim.bo[ev.buf].filetype:match("^git")
		then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Reload files changed outside nvim (e.g. git checkout)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = group,
	command = "checktime",
})
