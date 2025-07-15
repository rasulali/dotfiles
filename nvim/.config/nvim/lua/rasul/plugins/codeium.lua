return {
	"Exafunction/windsurf.vim",
	event = "BufEnter",
	config = function()
		-- Disable Default Keybindings
		vim.g.codeium_disable_bindings = 1

		-- Global Variables
		local opts_expr = { silent = true, expr = true }
		local map = vim.keymap.set

		-- Functions
		local accept = function()
			return vim.fn["codeium#Accept"]()
		end
		local next = function()
			return vim.fn["codeium#CycleCompletions"](1)
		end
		local prev = function()
			return vim.fn["codeium#CycleCompletions"](-1)
		end
		local clear = function()
			return vim.fn["codeium#Clear"]()
		end
		local manual = function()
			return vim.fn["codeium#Complete"]()
		end

		-- Keybindings
		map("i", "<Tab>", accept, opts_expr) --Tab for completion
		map("i", "<M-]>", next, opts_expr) --Alt+] for next
		map("i", "<M-[>", prev, opts_expr) --Alt+[ for prev
		map("i", "<M-\\>", manual, opts_expr) --Alt+\ for manual
		map("i", "<M-BS>", clear, opts_expr) --Alt+Backspace for clear
	end,
}
