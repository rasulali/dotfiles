local blink = require("blink.cmp")

return {
	cmd = { "zls" },
	filetypes = { "zig", "zir" },
	root_markers = {
		"build.zig",
		"zls.json",
		"build.zig.zon",
		".git",
	},
	settings = {
		zls = {
			enable_snippets = true,
			enable_autofix = true,
			warn_style = true,
			enable_inlay_hints = true,
			inlay_hints_show_variable_type_hints = true,
			inlay_hints_show_parameter_name_hints = true,
			inlay_hints_show_builtin_format_strings = true,
			enable_semantic_tokens = true,
		},
	},
	capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		blink.get_lsp_capabilities(),
		{
			workspace = {
				fileOperations = {
					didRename = true,
					willRename = true,
				},
			},
		}
	),
}
