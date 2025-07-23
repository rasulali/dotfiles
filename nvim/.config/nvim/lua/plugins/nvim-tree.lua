return {
	"nvim-tree/nvim-tree.lua",
	config = function()
		local tree = require("nvim-tree")
		vim.api.nvim_set_keymap("n", "<A-n>", ":NvimTreeToggle<cr>", { noremap = true, silent = true })
		tree.setup({
			sort_by = "case_sensitive",
			git = {
				ignore = false,
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			view = {
				adaptive_size = true,
				side = "right",
			},
			renderer = {
				group_empty = true,
			},
			filters = {
				dotfiles = false,
			},
		})
	end,
}
