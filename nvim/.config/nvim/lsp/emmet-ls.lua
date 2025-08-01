return {
	cmd = { "emmet-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"scss",
		"sass",
		"less",
		"javascriptreact",
		"typescriptreact",
		"svelte",
		"vue",
	},
	root_markers = { ".git", "package.json" },
	single_file_support = true,
	init_options = {
		--- @type table<string, any> https://docs.emmet.io/customization/preferences/
		preferences = {},
		--- @type "always" | "never" default: "always"
		showExpandedAbbreviation = "always",
		--- @type boolean default: true
		showAbbreviationSuggestions = true,
		--- @type boolean default: false
		showSuggestionsAsSnippets = false,
		--- @type table<string, any> https://docs.emmet.io/customization/syntax-profiles/
		syntaxProfiles = {},
		--- @type table<string, string> https://docs.emmet.io/customization/snippets/#variables
		variables = {},
		--- @type string[]
		excludeLanguages = {},
	},
	capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		require("blink.cmp").get_lsp_capabilities()
	),
}
