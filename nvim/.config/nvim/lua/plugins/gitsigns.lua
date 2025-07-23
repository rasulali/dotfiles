return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local gitsigns = require("gitsigns")
		gitsigns.setup({
			current_line_blame = false,
			vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { noremap = true, silent = true }),
		})
	end,
}
