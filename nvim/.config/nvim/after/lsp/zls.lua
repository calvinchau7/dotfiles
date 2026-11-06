-- ZLS reports syntax errors as you type, but type errors come from the zig
-- compiler, which it only runs on save (build-on-save). That's ZLS, not nvim.
return {
	settings = {
		zls = {
			enable_build_on_save = true,
		},
	},
}
