local presets = {
	qwen25_coder_7b = {
		backend = "ollama",
		model = "qwen2.5-coder:7b",
		url = "http://localhost:11434",
	},
	qwen25_coder_3b = {
		backend = "ollama",
		model = "qwen2.5-coder:3b",
		url = "http://localhost:11434",
	},
	qwen3_coder_30b = {
		backend = "ollama",
		model = "qwen3-coder:30b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 60,
		},
	},
}

local default_preset = "qwen25_coder_7b"

local defaults = {
	keep_alive = 30,
	raw = true,
	options = {
		temperature = 0.05,
		top_p = 0.9,
		num_predict = 16,
		num_thread = 8,
		num_gpu = 38,
	},
}

return {
	"huggingface/llm.nvim",
	lazy = false,
	opts = function()
		local merged_presets = {}
		for name, preset in pairs(presets) do
			merged_presets[name] = vim.tbl_deep_extend("force", {
				backend = preset.backend,
				model = preset.model,
				url = preset.url,
				request_body = vim.tbl_deep_extend("force", defaults, preset.request_body or {}),
			}, {})
		end

		local base_opts = {
			enable_suggestions_on_startup = true,
			enable_suggestions_on_files = "*",
			fim = {
				enabled = true,
				prefix = "<|fim_prefix|>",
				middle = "<|fim_middle|>",
				suffix = "<|fim_suffix|>",
			},
			tokens_to_clear = { "<|endoftext|>", "<|fim_pad|>" },
			debounce_ms = 10,
			accept_keymap = "<Tab>",
			dismiss_keymap = "<S-Tab>",
			context_window = 1024,
			presets = merged_presets,
			default_preset = default_preset,
		}

		local active = merged_presets[default_preset] or {}
		return vim.tbl_deep_extend("force", base_opts, active)
	end,
	config = function(_, opts)
		require("llm").setup(opts)
		require("config.llm_switcher").setup({
			presets = opts.presets or {},
			default = opts.default_preset or default_preset,
		})
	end,
}
