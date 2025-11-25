local config = require("llm.config")
local completion = require("llm.completion")

local M = {
	presets = {},
	current = nil,
}

local function merge_config(preset)
	local merged = vim.tbl_deep_extend("force", {}, config.get(), preset)
	config.config = merged
	return merged
end

function M.setup(opts)
	M.presets = vim.deepcopy(opts.presets or {})
	M.current = opts.default or opts.current or next(M.presets)
	if not M.current or not M.presets[M.current] then
		return
	end

	merge_config(M.presets[M.current])
end

function M.switch(name)
	local preset = M.presets[name]
	if not preset then
		vim.notify(string.format("[LLM] Unknown preset '%s'", name or "nil"), vim.log.levels.WARN)
		return
	end

	completion.cancel()
	merge_config(preset)
	M.current = name

	local label = preset.model or preset.backend or name
	vim.notify(string.format("[LLM] Switched to %s (%s)", name, label), vim.log.levels.INFO)
end

function M.names()
	local keys = {}
	for name, _ in pairs(M.presets) do
		table.insert(keys, name)
	end
	table.sort(keys)
	return keys
end

function M.pick()
	if vim.tbl_isempty(M.presets) then
		vim.notify("[LLM] No presets configured", vim.log.levels.WARN)
		return
	end

	local fzf = require("fzf-lua")
	local entries = {}
	for _, name in ipairs(M.names()) do
		local preset = M.presets[name] or {}
		local label = preset.model or preset.backend or name
		table.insert(entries, string.format("%s\t%s", name, label))
	end

	fzf.fzf_exec(entries, {
		prompt = "LLM> ",
		fzf_opts = {
			["--delimiter"] = "\t",
			["--with-nth"] = "2",
			["--no-separator"] = "",
			["--info"] = "inline",
		},
		winopts = {
			width = 0.5,
			height = 0.35,
			row = 0.35,
			col = 0.5,
			preview = { hidden = "hidden" },
		},
		actions = {
			["default"] = function(selected)
				local entry = selected[1]
				if not entry then
					return
				end
				local name = vim.split(entry, "\t")[1]
				if name then
					M.switch(name)
				end
			end,
		},
	})
end

return M
