local presets = {
	qwen3_coder_30b = {
		backend = "ollama",
		model = "qwen3-coder:30b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 10,
			raw = true,
			options = {
				temperature = 0.15,
				top_p = 0.9,
				num_predict = 32,
				num_gpu = 38,
				num_thread = 8,
				stop = { "\n\n", "```", "##" },
			},
		},
	},
	qwen25_coder_7b = {
		backend = "ollama",
		model = "qwen2.5-coder:7b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 10,
			raw = true,
			options = {
				temperature = 0.15,
				top_p = 0.9,
				num_predict = 32,
				num_gpu = 16,
				num_thread = 8,
				stop = { "\n\n", "```", "##" },
			},
		},
	},
	qwen25_coder_3b = {
		backend = "ollama",
		model = "qwen2.5-coder:3b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 10,
			raw = true,
			options = {
				temperature = 0.15,
				top_p = 0.9,
				num_predict = 24,
				num_gpu = 8,
				num_thread = 6,
				stop = { "\n\n", "```", "##" },
			},
		},
	},
}

local default_preset = "qwen3_coder_30b"

return {
	"huggingface/llm.nvim",
	lazy = false,
	opts = function()
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
			debounce_ms = 80,
			accept_keymap = "<Tab>",
			dismiss_keymap = "<S-Tab>",
			presets = presets,
			default_preset = default_preset,
		}

		local active = presets[default_preset] or {}
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
