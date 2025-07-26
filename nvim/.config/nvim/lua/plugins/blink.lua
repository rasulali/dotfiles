return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = { "rafamadriz/friendly-snippets" },
		event = "InsertEnter",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
		end,
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		event = "InsertEnter",
		version = "*",
		---@diagnostic disable-next-line: missing-fields
		opts = {
			snippets = {
				preset = "luasnip",
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet.body)
				end,
			},
			appearance = {
				use_nvim_cmp_as_default = false,
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				menu = {
					draw = {
						treesitter = { "lsp" },
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				ghost_text = {
					enabled = false,
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
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
