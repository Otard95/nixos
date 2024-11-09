local move = require "utils.move"
local fn = require "utils.fn"
vim.g.mapleader = ' '
vim.g.maplocalleader = ';'

vim.keymap.set('n', '<leader>ve', ':edit ~/.config/nvim/init.lua<cr>', {})
vim.keymap.set('n', '<leader>vr', ':so ~/.config/nvim/init.lua<cr>', {})

-- Move selected text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep the caret where it is
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set('n', 'zm', 'zmzz')
vim.keymap.set('n', 'zM', 'zMzz')
vim.keymap.set('n', 'zr', 'zrzz')
vim.keymap.set('n', 'zR', 'zRzz')
vim.keymap.set('n', 'zo', 'zozz')
vim.keymap.set('n', 'zO', 'zOzz')
vim.keymap.set('n', 'zc', 'zczz')
vim.keymap.set('n', 'zC', 'zCzz')

-- Goto file
vim.keymap.set('n', 'gf', ':edit <cfile><cr>', {})

-- Just no
vim.keymap.set("n", "Q", "<nop>")

-- Substitute word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- Make this file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Reselect visual selection after indenting
vim.keymap.set('v', '<', '<gv', { noremap = true })
vim.keymap.set('v', '>', '>gv', { noremap = true })

-- When text is wrapped or folded, move by terminal rows not lines
vim.keymap.set('n', 'j', 'gj', { noremap = true })
vim.keymap.set('n', 'k', 'gk', { noremap = true })
vim.keymap.set('v', 'j', 'gj', { noremap = true })
vim.keymap.set('v', 'k', 'gk', { noremap = true })
vim.keymap.set('n', '{', fn.partial(move.skipping_folds, '{'), { noremap = true })
vim.keymap.set('n', '}', fn.partial(move.skipping_folds, '}'), { noremap = true })

-- Paste replace visual selection without copy
vim.keymap.set('v', '<leader>p', '"_dP', { noremap = true })

-- Stop highlight
vim.keymap.set('n', '<tab>', ':noh<CR>', { noremap = true })

-- Buffer cleaning
vim.keymap.set('n', '<leader>bo', ':BufOnly<CR>', {})

-- Copy reference
vim.keymap.set('n', '<leader>cr', 'Reference<CR>', {})
vim.keymap.set('v', '<leader>cr', 'Reference<CR>', {})

--" Resizing
vim.keymap.set('n', '<leader>>', ':vertical resize +4<CR>', {})
vim.keymap.set('n', '<leader><', ':vertical resize -4<CR>', {})
