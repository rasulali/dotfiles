return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local function dir()
			local path = vim.fn.expand("%:p")
			local current_folder = vim.fn.fnamemodify(path, ":h:t")
			local parent_folder = vim.fn.fnamemodify(path, ":h:h:t")
			return parent_folder .. "/" .. current_folder
		end

		require("lualine").setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "TelescopePrompt", "NvimTree" },
				},
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { dir, "filename", "diagnostics" },
				lualine_x = { "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "selectioncount" },
			},
		})
	end,
}
