return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		-- Variables
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")
		local opts = { noremap = true, silent = true }
		local map = vim.keymap.set

		map("n", "<leader>ff", builtin.find_files, opts)
		map("n", "<leader>fb", function()
			builtin.buffers({
				attach_mappings = function(_, localMap)
					localMap("n", "x", actions.delete_buffer)
					return true
				end,
			})
		end, opts)
		map("n", "<leader>fh", builtin.oldfiles, opts)
		map("n", "<leader>gg", builtin.live_grep, opts)
		map("n", "<leader>gf", builtin.diagnostics, opts)
		map("n", "<leader>qf", builtin.quickfix, opts)
		map("n", "<C-g>", function()
			vim.fn.system("git rev-parse --is-inside-work-tree")
			if vim.v.shell_error == 0 then
				require("telescope.builtin").git_files(opts)
			else
				print("Not a Git directory")
			end
		end, opts)
	end,
}
