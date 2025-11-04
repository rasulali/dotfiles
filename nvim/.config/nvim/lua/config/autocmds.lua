-- Variables
local autocmd = vim.api.nvim_create_autocmd

-- Clean default format on BufEnter
autocmd("BufEnter", {
	pattern = "*",
	command = "set fo-=c fo-=r fo-=o",
})

-- Better text edit
autocmd("OptionSet", {
	pattern = "wrap",
	callback = function(event)
		local bufnr = event.buf or vim.api.nvim_get_current_buf()
		local winid = event.win or vim.api.nvim_get_current_win()

		local ok_wrap, wrap_enabled = pcall(vim.api.nvim_win_get_option, winid, "wrap")
		if not ok_wrap then
			wrap_enabled = false
		end

		local ok_ft, buf_ft = pcall(vim.api.nvim_buf_get_option, bufnr, "filetype")
		if not ok_ft then
			buf_ft = ""
		end

		if wrap_enabled then
			if buf_ft == "markdown" or buf_ft == "text" or buf_ft == "gitcommit" then
				vim.api.nvim_buf_set_option(bufnr, "spell", true)
			else
				vim.api.nvim_buf_set_option(bufnr, "spell", false)
			end

			vim.keymap.set({ "n", "v", "x" }, "j", "gj", { buffer = bufnr, silent = true })
			vim.keymap.set({ "n", "v", "x" }, "k", "gk", { buffer = bufnr, silent = true })
		else
			for _, mode in ipairs({ "n", "v", "x" }) do
				pcall(vim.keymap.del, mode, "j", { buffer = bufnr })
				pcall(vim.keymap.del, mode, "k", { buffer = bufnr })
			end

			vim.api.nvim_buf_set_option(bufnr, "spell", false)
		end
	end,
})

-- Highlight yanked text
autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40,
		})
	end,
})

-- Remove whitespace before saving on BufWritePre
autocmd("BufWritePre", {
	pattern = "*",
	command = [[%s/\s\+$//e]],
})
