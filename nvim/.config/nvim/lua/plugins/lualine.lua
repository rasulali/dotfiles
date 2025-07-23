return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local function folder()
			local path = vim.fn.expand("%:p")
			local current_folder = vim.fn.fnamemodify(path, ":h:t")
			local parent_folder = vim.fn.fnamemodify(path, ":h:h:t")
			return parent_folder .. "/" .. current_folder
		end

		-- display codeium status with codeium icon
		local function codeium()
			return "󰁨 " .. vim.fn["codeium#GetStatusString"]()
		end
		require("lualine").setup({
			options = {
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = { "TelescopePrompt", "NvimTree" },
				},
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff" },
				lualine_c = { folder, "filename", "diagnostics" },
				lualine_x = { codeium, "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "selectioncount" },
			},
		})
	end,
}
