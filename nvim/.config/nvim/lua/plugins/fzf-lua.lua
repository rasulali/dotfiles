return {
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		config = function()
			local fzf = require("fzf-lua")

			fzf.setup({
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
				},
				files = {
					fd_opts = "--color=never --type f --hidden --exclude .git",
				},
			})
		end,
		keys = {
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{
				"<leader>fb",
				function()
					require("fzf-lua").buffers({
						actions = {
							["default"] = require("fzf-lua").actions.buf_edit,
							["x"] = require("fzf-lua").actions.buf_del,
						},
					})
				end,
				desc = "Buffers",
			},
			{ "<leader>fh", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
			{ "<leader>gg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
			{ "<leader>gf", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Diagnostics" },
			{ "<leader>qf", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
			{
				"<C-g>",
				function()
					vim.fn.system("git rev-parse --is-inside-work-tree")
					if vim.v.shell_error == 0 then
						require("fzf-lua").git_files()
					else
						print("Not a Git directory")
					end
				end,
				desc = "Git Files",
			},
		},
	},
}
