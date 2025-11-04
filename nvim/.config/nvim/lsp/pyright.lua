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
		-- If using blink.cmp
		require("blink.cmp").get_lsp_capabilities()
		-- If using nvim-cmp instead, use:
		-- require("cmp_nvim_lsp").default_capabilities()
	),
	-- Optional: custom on_attach function
	on_attach = function(client, bufnr)
		-- Custom keymaps or settings specific to Pyright
		-- This will run in addition to your global LspAttach autocmd

		-- Example: disable hover in favor of another provider
		-- client.server_capabilities.hoverProvider = false

		-- Example: Python-specific keymaps
		local opts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.kind and string.match(action.kind, "source%.organizeImports")
				end,
				apply = true,
			})
		end, opts)
	end,
	-- Optional: custom initialization options
	init_options = {
		-- Custom initialization options if needed
	},
}
