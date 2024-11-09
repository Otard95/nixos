-- Indenting
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Line numbers
vim.opt.relativenumber = true
vim.opt.number = true

-- Colors
vim.opt.termguicolors = false

-- Folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 2

-- Search
-- vim.opt.smartcase = true
vim.opt.ignorecase = true

-- Line wrapping
vim.opt.wrap = true
vim.opt.showbreak = '↪ '
vim.opt.linebreak = true
vim.opt.colorcolumn = '80'
vim.opt.signcolumn = 'yes'

-- Undo, swap, backup
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undodir"
vim.opt.undofile = true

-- Misc
vim.opt.wildmode = 'longest:full,full'
vim.opt.list = true
vim.opt.listchars = 'tab:󰌒 ,trail:⋅'
vim.opt.scrolloff = 20
vim.opt.sidescrolloff = 10
vim.opt.clipboard = 'unnamedplus'
vim.opt.cmdheight = 2
vim.opt.mouse = 'a'
vim.opt.updatetime = 50
vim.opt.formatoptions:remove { 'o' }
