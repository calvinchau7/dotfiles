return {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" }, -- use SchemaStore.nvim's catalog instead
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}
