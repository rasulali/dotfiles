return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "*",
		---@diagnostic disable-next-line: missing-fields
		opts = {
			appearance = {
				use_nvim_cmp_as_default = false,
			},
			completion = {
				menu = {
					auto_show = false,
					border = nil,
					scrolloff = 1,
					scrollbar = false,
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},
					},
				},
				documentation = {
					window = {
						border = nil,
						scrollbar = false,
						winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc",
					},
					auto_show = true,
					auto_show_delay_ms = 500,
				},
			},
			sources = {
				default = { "lsp", "buffer", "snippets", "path" },
				---@diagnostic disable-next-line: missing-fields
				providers = {},
			},
			cmdline = {
				enabled = false,
			},
			keymap = {
				["<C-n>"] = { "show", "select_next", "fallback" },
				["<C-p>"] = { "select_prev", "fallback" },
				["<C-c>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
		},
		---@param opts table
		config = function(_, opts)
			local enabled = opts.sources.default
			for _, source in ipairs(opts.sources.compat or {}) do
				opts.sources.providers[source] = vim.tbl_deep_extend(
					"force",
					{ name = source, module = "blink.compat.source" },
					opts.sources.providers[source] or {}
				)
				if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
					table.insert(enabled, source)
				end
			end
			opts.sources.compat = nil
			require("blink.cmp").setup(opts)
		end,
	},
}
