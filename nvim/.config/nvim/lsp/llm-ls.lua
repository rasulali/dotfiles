local blink = require("blink.cmp")

return {
	cmd = { "llm-ls" },
	filetypes = { "*" },
	root_markers = { ".git" },
	single_file_support = true,
	capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		blink.get_lsp_capabilities()
	),
}
