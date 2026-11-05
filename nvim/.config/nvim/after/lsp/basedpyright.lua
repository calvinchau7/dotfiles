-- Point basedpyright at the project's virtualenv (.venv / venv) so imports resolve.
-- An activated venv ($VIRTUAL_ENV) or venvPath/venv in pyproject.toml also work.
local function venv_python(root)
	local bin = vim.fn.has("win32") == 1 and "Scripts/python.exe" or "bin/python"
	for _, dir in ipairs({ ".venv", "venv" }) do
		local py = vim.fs.joinpath(root, dir, bin)
		if vim.uv.fs_stat(py) then
			return py
		end
	end
end

return {
	before_init = function(_, config)
		local py = config.root_dir and venv_python(config.root_dir)
		if py then
			config.settings.python = vim.tbl_extend("force", config.settings.python or {}, { pythonPath = py })
		end
	end,
	settings = {
		basedpyright = {
			disableOrganizeImports = true, -- ruff handles imports
			analysis = {
				-- basedpyright's default ("recommended") is very strict; [tool.basedpyright]
				-- in a project's pyproject.toml overrides this.
				typeCheckingMode = "standard",
			},
		},
	},
}
