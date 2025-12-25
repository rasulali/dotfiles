return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
	config = function()
		vim.keymap.set("n", "<leader>m", "<cmd>RenderMarkdown toggle<cr>", { noremap = true, silent = true })
	end,
}
