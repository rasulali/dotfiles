local blink = require("blink.cmp")

return {
	cmd = { "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp" },
	filetypes = { "swift", "objc", "objcpp" },
	root_markers = { "Package.swift", ".git", "compile_commands.json" },
	single_file_support = true,
	capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		blink.get_lsp_capabilities()
	),
}
