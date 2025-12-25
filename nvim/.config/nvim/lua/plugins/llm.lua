local presets = {
	deepseek_coder_1_3b = {
		backend = "ollama",
		model = "deepseek-coder:1.3b",
		url = "http://localhost:11434",
		request_body = {
			options = {
				temperature = 0.02,
				top_p = 0.85,
				num_predict = 12,
			},
		},
		context_window = 512,
		debounce_ms = 40,
		fim = {
			enabled = true,
			prefix = "<fim_prefix>",
			middle = "<fim_middle>",
			suffix = "<fim_suffix>",
		},
		tokens_to_clear = { "<|endoftext|>", "<fim_pad>", "<|file_separator|>" },
	},
	deepseek_coder_6_7b = {
		backend = "ollama",
		model = "deepseek-coder:6.7b",
		url = "http://localhost:11434",
		request_body = {
			options = {
				temperature = 0.05,
				top_p = 0.9,
				num_predict = 24,
			},
		},
		context_window = 1024,
		debounce_ms = 80,
		fim = {
			enabled = true,
			prefix = "<fim_prefix>",
			middle = "<fim_middle>",
			suffix = "<fim_suffix>",
		},
		tokens_to_clear = { "<|endoftext|>", "<fim_pad>", "<|file_separator|>" },
	},
	deepseek_coder_33b = {
		backend = "ollama",
		model = "deepseek-coder:33b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 60,
			options = {
				temperature = 0.15,
				top_p = 0.95,
				num_predict = 64,
			},
		},
		context_window = 2048,
		debounce_ms = 150,
		fim = {
			enabled = true,
			prefix = "<fim_prefix>",
			middle = "<fim_middle>",
			suffix = "<fim_suffix>",
		},
		tokens_to_clear = { "<|endoftext|>", "<fim_pad>", "<|file_separator|>" },
	},
	qwen25_coder_3b = {
		backend = "ollama",
		model = "qwen2.5-coder:3b",
		url = "http://localhost:11434",
		request_body = {
			options = {
				temperature = 0.02,
				top_p = 0.85,
				num_predict = 12,
			},
		},
		context_window = 512,
		debounce_ms = 50,
	},
	qwen25_coder_7b = {
		backend = "ollama",
		model = "qwen2.5-coder:7b",
		url = "http://localhost:11434",
		request_body = {
			options = {
				temperature = 0.05,
				top_p = 0.9,
				num_predict = 16,
			},
		},
		context_window = 1024,
		debounce_ms = 80,
	},
	devstral_24b = {
		backend = "ollama",
		model = "devstral-small-2:24b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 60,
			options = {
				temperature = 0.15,
				top_p = 0.95,
				num_predict = 64,
			},
		},
		context_window = 2048,
		debounce_ms = 150,
	},
	qwen3_coder_30b = {
		backend = "ollama",
		model = "qwen3-coder:30b",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 60,
			options = {
				temperature = 0.15,
				top_p = 0.95,
				num_predict = 64,
			},
		},
		context_window = 2048,
		debounce_ms = 150,
	},
	qwen3_coder_480b_cloud = {
		backend = "ollama",
		model = "qwen3-coder:480b-cloud",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 120,
			raw = false,
			options = {
				temperature = 0.2,
				top_p = 0.95,
				num_predict = 128,
			},
		},
		context_window = 4096,
		debounce_ms = 100,
		tokens_to_clear = {
			"<|endoftext|>",
			"<|fim_pad|>",
			"```typescript",
			"```javascript",
			"```python",
			"```lua",
			"```rust",
			"```go",
			"```java",
			"```cpp",
			"```c",
			"```html",
			"```css",
			"```json",
			"```",
		},
	},
	cogito_671b_cloud = {
		backend = "ollama",
		model = "cogito-2.1:671b-cloud",
		url = "http://localhost:11434",
		request_body = {
			keep_alive = 120,
			raw = false,
			options = {
				temperature = 0.2,
				top_p = 0.95,
				num_predict = 128,
			},
		},
		context_window = 4096,
		debounce_ms = 100,
		tokens_to_clear = {
			"<|endoftext|>",
			"<|fim_pad|>",
			"```typescript",
			"```javascript",
			"```python",
			"```lua",
			"```rust",
			"```go",
			"```java",
			"```cpp",
			"```c",
			"```html",
			"```css",
			"```json",
			"```",
		},
	},
}

local default_preset = "qwen25_coder_7b"

local defaults = {
	keep_alive = 30,
	raw = true,
	options = {
		num_thread = 8,
		num_gpu = 38,
	},
}

local Switcher = {}
Switcher.__index = Switcher

function Switcher.new(opts)
	local self = setmetatable({}, Switcher)
	self.presets = vim.deepcopy(opts.presets or {})
	self.current = opts.default or next(self.presets)
	return self
end

function Switcher:merge_config(preset)
	local config = require("llm.config")
	local merged = vim.tbl_deep_extend("force", {}, config.get(), preset)
	config.config = merged
	return merged
end

function Switcher:switch(name)
	local preset = self.presets[name]
	if not preset then
		vim.notify(string.format("[LLM] Unknown preset '%s'", name or "nil"), vim.log.levels.WARN)
		return
	end

	local completion = require("llm.completion")
	completion.cancel()
	self:merge_config(preset)
	self.current = name

	local label = preset.model or preset.backend or name
	vim.notify(string.format("[LLM] Switched to %s (%s)", name, label), vim.log.levels.INFO)
end

function Switcher:names()
	local keys = {}
	for name, _ in pairs(self.presets) do
		table.insert(keys, name)
	end
	table.sort(keys)
	return keys
end

function Switcher:pick()
	if vim.tbl_isempty(self.presets) then
		vim.notify("[LLM] No presets configured", vim.log.levels.WARN)
		return
	end

	local fzf = require("fzf-lua")
	local entries = {}

	local max_name_len = 0
	local max_label_len = 0

	for _, name in ipairs(self:names()) do
		local preset = self.presets[name] or {}
		local label = preset.model or preset.backend or name
		max_name_len = math.max(max_name_len, #name)
		max_label_len = math.max(max_label_len, #label)
	end

	local function get_speed_icon(model_name)
		local is_cloud = model_name:match("cloud") ~= nil

		if is_cloud then
			return "󰓅 󰅟"
		end

		local params = model_name:match(":(%d+%.?%d*)b") or model_name:match("(%d+%.?%d*)b")
		if not params then
			return "󰾅"
		end

		params = tonumber(params)

		if params < 10 then
			return "󰓅"
		elseif params < 30 then
			return "󰾅"
		else
			return "󰾆"
		end
	end

	for _, name in ipairs(self:names()) do
		local preset = self.presets[name] or {}
		local label = preset.model or preset.backend or name

		local indicator = name == self.current and "● " or "  "
		local padded_name = name .. string.rep(" ", max_name_len - #name)
		local padded_label = label .. string.rep(" ", max_label_len - #label)
		local speed_icon = get_speed_icon(label)
		local entry = string.format("%s%s  %s  %s", indicator, padded_name, padded_label, speed_icon)
		table.insert(entries, entry)
	end

	fzf.fzf_exec(entries, {
		prompt = "LLM > ",
		fzf_opts = {
			["--no-separator"] = "",
			["--info"] = "inline-right",
			["--layout"] = "reverse",
			["--border"] = "rounded",
			["--pointer"] = ">",
			["--marker"] = "+",
		},
		winopts = {
			width = 0.7,
			height = 0.6,
			row = 0.5,
			col = 0.5,
			border = "rounded",
			preview = { hidden = "hidden" },
		},
		actions = {
			["default"] = function(selected)
				if not selected or #selected == 0 then
					return
				end
				local line = selected[1]
				local name = line:match("^[● ]+ ([^%s]+)")
				if name then
					self:switch(name)
				end
			end,
		},
	})
end

return {
	"huggingface/llm.nvim",
	dependencies = { "ibhagwan/fzf-lua" },
	lazy = false,
	opts = function()
		local merged_presets = {}
		for name, preset in pairs(presets) do
			local merged_request_body = vim.tbl_deep_extend("force", defaults, preset.request_body or {})
			merged_presets[name] = {
				backend = preset.backend,
				model = preset.model,
				url = preset.url,
				request_body = merged_request_body,
				context_window = preset.context_window,
				debounce_ms = preset.debounce_ms,
				tokens_to_clear = preset.tokens_to_clear,
			}
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
			accept_keymap = "<Tab>",
			dismiss_keymap = "<S-Tab>",
			presets = merged_presets,
			default_preset = default_preset,
		}

		return vim.tbl_deep_extend("force", base_opts, merged_presets[default_preset] or {})
	end,
	config = function(_, opts)
		require("llm").setup(opts)

		local switcher = Switcher.new({
			presets = opts.presets or {},
			default = opts.default_preset or default_preset,
		})

		_G.llm_switcher = switcher

		vim.api.nvim_create_user_command("LLMSwitch", function(cmd_opts)
			if cmd_opts.args and cmd_opts.args ~= "" then
				switcher:switch(cmd_opts.args)
			else
				switcher:pick()
			end
		end, {
			nargs = "?",
			complete = function()
				return switcher:names()
			end,
		})

		vim.keymap.set("n", "<leader>ll", function()
			switcher:pick()
		end, { desc = "Switch LLM preset" })
	end,
}
