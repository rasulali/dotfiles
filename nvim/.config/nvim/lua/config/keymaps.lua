-- Options for mappings
local opts = { noremap = true, silent = true }
local opts_expr = { noremap = true, silent = true, expr = true }

-- Shorten the functions' name
local map = vim.keymap.set

-- Remap space as leader key
map("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Move the line
map("n", "<A-j>", ":m .+1<CR>", opts)
map("n", "<A-k>", ":m .-2<CR>", opts)

-- Duplicate the line
map("n", "<A-y>", ":t .<CR>", opts)

-- Insert empty line(s)
map("n", "<leader>o", "'m`' . v:count1 . 'o<Esc>``'", opts_expr)
map("n", "<leader>O", "'m`' . v:count1 . 'O<Esc>``'", opts_expr)

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Better split navigation
map("n", "<C-A-v>", "<C-w>v", opts)
map("n", "<C-A-s>", "<C-w>s", opts)
map("n", "<C-A-c>", "<C-w>c", opts)

map("n", "<C-A-h>", "<C-w>H", opts)
map("n", "<C-A-j>", "<C-w>J", opts)
map("n", "<C-A-k>", "<C-w>K", opts)
map("n", "<C-A-l>", "<C-w>L", opts)

-- Resize with arrows
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Easily copy, cut, paste from system clipboard
map({ "n", "v" }, "<C-y>", [["+y]], opts)
map({ "n", "v" }, "<C-x>", [["+x]], opts)
map("", "<C-p>", [["+p]], opts)

-- Toggle Light/Dark mode
map("", "<F9>", [[':set bg='.(&bg=='dark' ? "light" : "dark")."<CR>"]], opts_expr)

-- Navigate between buffers
map("n", "<leader><Tab>", ":bnext<CR>", opts)
map("n", "<leader><S-Tab>", ":bprev<CR>", opts)

-- Close buffers easily
map("n", "<leader>x", ":bd<CR>", opts)

-- Save the current buffer
map("n", "<leader>w", ":w<CR>", opts)

-- Execute the current buffer if possible
map("n", "<leader>!", ":!./%<CR>", opts)

-- Shell like navigation in command mode
map("c", "<C-a>", "<Home>", opts)
map("c", "<C-e>", "<End>", opts)

-- Toggle text wrap
map("n", "<leader>s", ":set wrap!<CR>", opts)

-- Better escape key for terminal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)

-- Stay in indent mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Unset increment number shortcut
map("n", "<C-a>", "<Nop>", opts)
