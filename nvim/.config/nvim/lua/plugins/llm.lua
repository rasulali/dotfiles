--- Dynamic LLM presets from local Ollama and LM Studio (OpenAI-compatible) servers.
--- Model lists are fetched at runtime; no model names are hardcoded in this file.

local function ensure_scheme(url)
	url = vim.trim(url or "")
	if url == "" then
		return nil
	end
	if not url:match("^https?://") then
		return "http://" .. url
	end
	return url
end

local function normalize_base(env_val, fallback)
	local u = env_val and vim.trim(env_val):gsub("/+$", "") or nil
	if not u or u == "" then
		return fallback
	end
	return ensure_scheme(u) or fallback
end

local OLLAMA_BASE = normalize_base(vim.env.OLLAMA_HOST, "http://127.0.0.1:11434")
local LMSTUDIO_BASE = normalize_base(vim.env.LMSTUDIO_URL, "http://127.0.0.1:1234")

local ollama_defaults = {
	keep_alive = 30,
	raw = true,
	options = {
		num_thread = 8,
		num_gpu = 38,
	},
}

local function curl_json(url, timeout_s)
	local out = vim.fn.system({
		"curl",
		"-sS",
		"--connect-timeout",
		"1",
		"--max-time",
		tostring(timeout_s or 3),
		url,
	})
	if vim.v.shell_error ~= 0 or out == "" then
		return nil
	end
	local ok, decoded = pcall(vim.json.decode, out)
	if not ok or type(decoded) ~= "table" then
		return nil
	end
	return decoded
end

local function fetch_ollama_presets(base)
	base = ensure_scheme(base)
	if not base then
		return {}
	end
	local data = curl_json(base .. "/api/tags", 3)
	if not data or type(data.models) ~= "table" then
		return {}
	end
	local out = {}
	for _, m in ipairs(data.models) do
		local name = m.name
		if type(name) == "string" and name ~= "" then
			local key = "ollama@" .. name
			out[key] = {
				backend = "ollama",
				model = name,
				url = base,
				request_body = vim.tbl_deep_extend("force", vim.deepcopy(ollama_defaults), {
					options = {
						temperature = 0.05,
						top_p = 0.9,
						num_predict = 16,
					},
				}),
				context_window = 1024,
				debounce_ms = 80,
				fim = {
					enabled = true,
					prefix = "<fim_prefix>",
					middle = "<fim_middle>",
					suffix = "<fim_suffix>",
				},
				tokens_to_clear = { "<|endoftext|>", "<fim_pad>", "<|file_separator|>" },
				_llm_label = "Ollama",
			}
		end
	end
	return out
end

local function fetch_lmstudio_presets(base)
	base = ensure_scheme(base)
	if not base then
		return {}
	end
	local data = curl_json(base .. "/v1/models", 3)
	if not data or type(data.data) ~= "table" then
		return {}
	end
	local out = {}
	for _, entry in ipairs(data.data) do
		local id = entry.id
		if type(id) == "string" and id ~= "" then
			local key = "lmstudio@" .. id
			out[key] = {
				backend = "openai",
				model = id,
				url = base,
				request_body = {
					temperature = 0.2,
					top_p = 0.95,
				},
				context_window = 1024,
				debounce_ms = 150,
				fim = {
					enabled = true,
					prefix = "<|fim_prefix|>",
					middle = "<|fim_middle|>",
					suffix = "<|fim_suffix|>",
				},
				tokens_to_clear = { "<|endoftext|>", "<|fim_pad|>" },
				_llm_label = "LM Studio",
			}
		end
	end
	return out
end

local function fetch_all_presets()
	local merged = {}
	for k, v in pairs(fetch_ollama_presets(OLLAMA_BASE)) do
		merged[k] = v
	end
	for k, v in pairs(fetch_lmstudio_presets(LMSTUDIO_BASE)) do
		merged[k] = v
	end
	return merged
end

local function preset_to_setup_fields(preset)
	return {
		backend = preset.backend,
		model = preset.model,
		url = preset.url,
		request_body = preset.request_body,
		context_window = preset.context_window,
		debounce_ms = preset.debounce_ms,
		tokens_to_clear = preset.tokens_to_clear,
		fim = preset.fim,
	}
end

--- llm.nvim: debounced `schedule()` can call `reject()` between Tab and the scheduled `complete()`,
--- clearing `shown_suggestion` while `suggestion` remains. `accept_completion(nil)` then crashes.
--- No-op accept when there is nothing to report; `complete()` still applies the ghost text.
local function patch_llm_ls_accept_nil_safe()
	local ok, llm_ls = pcall(require, "llm.language_server")
	if not ok or llm_ls._llm_accept_nil_safe then
		return
	end
	llm_ls._llm_accept_nil_safe = true
	local orig = llm_ls.accept_completion
	llm_ls.accept_completion = function(completion_result)
		if completion_result == nil or completion_result.request_id == nil then
			return
		end
		return orig(completion_result)
	end
end

local Switcher = {}
Switcher.__index = Switcher

function Switcher.new()
	local self = setmetatable({}, Switcher)
	self.presets = {}
	self.current = nil
	self.enabled = true
	self._llm_setup_done = false
	return self
end

function Switcher:merge_config(preset)
	local llm_config = require("llm.config")
	local merged = vim.tbl_deep_extend("force", {}, llm_config.get(), preset_to_setup_fields(preset))
	llm_config.config = merged
	return merged
end

function Switcher:refresh_presets()
	self.presets = fetch_all_presets()
	return not vim.tbl_isempty(self.presets)
end

function Switcher:ensure_llm_setup_with(preset)
	if not preset then
		return false
	end
	if self._llm_setup_done then
		self:merge_config(preset)
		return true
	end
	local base = self._base_opts or {}
	local setup_opts = vim.tbl_deep_extend("force", {}, base, preset_to_setup_fields(preset))
	require("llm").setup(setup_opts)
	self._llm_setup_done = true
	return true
end

function Switcher:switch(name)
	local preset = self.presets[name]
	if not preset then
		vim.notify(string.format("[LLM] Unknown preset '%s'", name or "nil"), vim.log.levels.WARN)
		return
	end

	if not self:ensure_llm_setup_with(preset) then
		return
	end

	local completion = require("llm.completion")
	completion.cancel()
	self:merge_config(preset)
	self.current = name

	local label = preset.model or preset.backend or name
	vim.notify(string.format("[LLM] Switched to %s (%s)", name, label), vim.log.levels.INFO)
end

function Switcher:toggle()
	if not self._llm_setup_done then
		vim.notify("[LLM] Pick a model first (:LLMSwitch or <leader>ll).", vim.log.levels.WARN)
		return
	end
	self.enabled = not self.enabled
	vim.cmd("LLMToggleAutoSuggest")
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
	self:refresh_presets()
	if vim.tbl_isempty(self.presets) then
		vim.notify(
			string.format(
				"[LLM] No models from Ollama (%s) or LM Studio (%s). Check servers and OLLAMA_HOST / LMSTUDIO_URL.",
				OLLAMA_BASE,
				LMSTUDIO_BASE
			),
			vim.log.levels.WARN
		)
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
		local prov = preset._llm_label or preset.backend or ""

		local indicator = name == self.current and "● " or "  "
		local padded_name = name .. string.rep(" ", max_name_len - #name)
		local padded_label = label .. string.rep(" ", max_label_len - #label)
		local speed_icon = get_speed_icon(label)
		local entry = string.format("%s%s  %s  %s  %s", indicator, padded_name, prov, padded_label, speed_icon)
		table.insert(entries, entry)
	end

	local status_icon = self.enabled and "󰄵" or "󰄱"
	local status_text = self.enabled and "ON" or "OFF"

	local fzf_colors = self.enabled and {} or {
		["fg"] = "8",
		["fg+"] = "7",
		["hl"] = "8",
		["hl+"] = "7",
	}

	fzf.fzf_exec(entries, {
		prompt = string.format("LLM [%s %s] > ", status_icon, status_text),
		fzf_opts = {
			["--no-separator"] = "",
			["--info"] = "inline-right",
			["--layout"] = "reverse",
			["--border"] = "rounded",
			["--pointer"] = ">",
			["--marker"] = "+",
			["--header"] = "ctrl-l: toggle autocompletion",
			["--color"] = vim.tbl_isempty(fzf_colors) and nil or table.concat(
				vim.tbl_map(function(k)
					return k .. ":" .. fzf_colors[k]
				end, vim.tbl_keys(fzf_colors)),
				","
			),
		},
		winopts = {
			width = 0.75,
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
				local name = vim.trim((line:gsub("^●", ""):gsub("^%s+", "")))
				name = name:match("^(%S+)")
				if name and self.presets[name] then
					self:switch(name)
				end
			end,
			["ctrl-l"] = function()
				self:toggle()
				vim.schedule(function()
					self:pick()
				end)
			end,
		},
	})
end

return {
	"huggingface/llm.nvim",
	dependencies = { "ibhagwan/fzf-lua" },
	lazy = false,
	opts = function()
		return {
			-- Applied on first :LLMSwitch / <leader>ll after a model is chosen.
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
		}
	end,
	config = function(_, opts)
		patch_llm_ls_accept_nil_safe()

		local switcher = Switcher.new()
		switcher._base_opts = vim.deepcopy(opts)
		_G.llm_switcher = switcher

		vim.api.nvim_create_user_command("LLMSwitch", function(cmd_opts)
			if cmd_opts.args and cmd_opts.args ~= "" then
				switcher:refresh_presets()
				switcher:switch(cmd_opts.args)
			else
				switcher:pick()
			end
		end, {
			nargs = "?",
			complete = function()
				switcher:refresh_presets()
				return switcher:names()
			end,
		})

		vim.api.nvim_create_user_command("LLMToggle", function()
			switcher:toggle()
		end, {})

		vim.api.nvim_create_user_command("LLMRefreshModels", function()
			if switcher:refresh_presets() then
				vim.notify("[LLM] Model list refreshed.", vim.log.levels.INFO)
			else
				vim.notify("[LLM] No models found.", vim.log.levels.WARN)
			end
		end, {})

		vim.keymap.set("n", "<leader>ll", function()
			switcher:pick()
		end, { desc = "Switch LLM model" })

		vim.defer_fn(function()
			switcher:refresh_presets()
			local n = 0
			for _ in pairs(switcher.presets) do
				n = n + 1
			end
			if n == 0 then
				vim.notify(
					string.format(
						"[LLM] No local models. Start Ollama (%s) and/or LM Studio (%s), then :LLMSwitch or <leader>ll.",
						OLLAMA_BASE,
						LMSTUDIO_BASE
					),
					vim.log.levels.WARN
				)
				return
			end
			vim.notify(
				string.format("[LLM] %d local model(s) found. Use :LLMSwitch or <leader>ll to pick one.", n),
				vim.log.levels.INFO
			)
		end, 0)
	end,
}
