return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
	single_file_support = true,
	settings = {
		python = {
			analysis = {
				-- Enable/disable type checking
				typeCheckingMode = "basic", -- "off", "basic", "strict"
				-- Auto-import completions
				autoImportCompletions = true,
				-- Search paths for import resolution
				autoSearchPaths = true,
				-- Use library code for types when stubs are not available
				useLibraryCodeForTypes = true,
				-- Diagnostics mode
				diagnosticMode = "workspace", -- "openFilesOnly" or "workspace"
				-- Additional stub paths
				stubPath = "typings",
				-- Type shed paths
				typeshedPaths = {},
				-- Extra paths for analysis
				extraPaths = {},
				-- Diagnostic severity overrides
				diagnosticSeverityOverrides = {
					-- reportUnusedImport = "information",
					-- reportUnusedVariable = "information",
					-- reportGeneralTypeIssues = "error",
					-- reportOptionalMemberAccess = "error",
					-- reportOptionalSubscript = "error",
					-- reportPrivateImportUsage = "error",
				},
			},
		},
	},
	capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		require("blink.cmp").get_lsp_capabilities()
	),
}
