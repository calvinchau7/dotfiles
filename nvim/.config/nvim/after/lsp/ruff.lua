-- Hover comes from basedpyright (per ruff's editor-setup docs)
return {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
}
