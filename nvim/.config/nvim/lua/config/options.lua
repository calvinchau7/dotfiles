local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false -- lualine shows it
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitright = true
opt.splitbelow = true
opt.winborder = "rounded"
opt.list = false -- set to true to show tabs/trailing spaces
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.pumheight = 12

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 400
opt.confirm = true
opt.mouse = "a"
opt.inccommand = "split" -- live preview of :s

-- Folding (treesitter sets foldexpr per buffer); start fully unfolded
opt.foldlevel = 99
opt.foldlevelstart = 99

-- System clipboard (scheduled: clipboard provider detection is slow on startup)
vim.schedule(function()
	opt.clipboard = "unnamedplus"
end)

-- Windows: prefer PowerShell 7, fall back to Windows PowerShell
if vim.fn.has("win32") == 1 then
	local shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
	opt.shell = shell
	opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
		.. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
	opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
	opt.shellpipe = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
	opt.shellquote = ""
	opt.shellxquote = ""
end

-- Diagnostics
vim.diagnostic.config({
	severity_sort = true,
	underline = true,
	update_in_insert = true, -- show errors while typing, not only after leaving insert
	virtual_text = { spacing = 2, source = "if_many", prefix = "●" },
	float = { source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.INFO] = "I",
			[vim.diagnostic.severity.HINT] = "H",
		},
	},
})
