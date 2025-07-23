-- Getting HOME variable for relative path
local HOME = os.getenv("HOME")

-- List of options
local options = {

	tabstop = 2,
	softtabstop = 2,
	shiftwidth = 2,
	expandtab = true,
	smartindent = true,

	bg = "dark",
	colorcolumn = "80",
	title = true,

	number = true,
	relativenumber = true,

	signcolumn = "yes",
	laststatus = 3,
	wrap = false,
	scrolloff = 8,
	splitright = true,
	splitbelow = true,
	syntax = "ON",
	foldmethod = "expr",
	foldexpr = "nvim_treesitter#foldexpr()",
	foldlevel = 99,

	swapfile = false,
	backup = false,
	undodir = HOME .. "/.local/share/nvim/undo",
	undofile = true,

	hlsearch = false,
	showmode = false,
	ignorecase = true,
	smartcase = true,
	filetype = "on",

	updatetime = 40,

	termguicolors = true,

	completeopt = { "menu", "menuone", "noselect" },
	inccommand = "split",

	errorbells = false,
	cmdheight = 0,
}

-- Function to set from table above
for k, v in pairs(options) do
	vim.opt[k] = v
end
