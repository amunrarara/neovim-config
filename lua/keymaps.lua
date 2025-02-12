-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Window Management
vim.keymap.set('n', '<leader>ws', ':split<CR>', { desc = 'Split Window Horizontally' })
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Split Window Vertically' })
vim.keymap.set('n', '<leader>wk', ':close<CR>', { desc = 'Close Current Window' })
vim.keymap.set('n', '<leader>wo', ':only<CR>', { desc = 'Close All Other Windows' })

-- Resize windows
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize Window Sizes' })
vim.keymap.set('n', '<leader>w]', ':resize +5<CR>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<leader>w[', ':resize -5<CR>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<leader>w>', ':resize +20<CR>', { desc = 'Increase Window Width' })
vim.keymap.set('n', '<leader>w<', ':resize -20<CR>', { desc = 'Decrease Window Width' })

-- Swap windows
vim.keymap.set('n', '<leader>wH', '<C-w>H', { desc = 'Move Window to Left' })
vim.keymap.set('n', '<leader>wJ', '<C-w>J', { desc = 'Move Window to Bottom' })
vim.keymap.set('n', '<leader>wK', '<C-w>K', { desc = 'Move Window to Top' })
vim.keymap.set('n', '<leader>wL', '<C-w>L', { desc = 'Move Window to Right' })

-- Save Buffer
vim.keymap.set('n', '<D-s>', ':w<CR>', { silent = false })
vim.keymap.set('i', '<D-s>', '<Esc>:w<CR>a', { silent = false })
vim.keymap.set('v', '<D-s>', '<Esc>:w<CR>gv', { silent = false })

-- Delete Buffer (Preserves window)
vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete Current Buffer' })
vim.keymap.set('n', '<leader>bk', ':bwipeout<CR>', { desc = 'Kill (Wipeout) Buffer' })

-- Create a Scratch Buffer
vim.keymap.set('n', '<leader>bs', function()
  local bufname = vim.fn.input 'Scratch Buffer Name: '
  vim.api.nvim_command 'enew'
  if bufname and bufname ~= '' then
    vim.api.nvim_buf_set_name(0, bufname)
  end
end, { desc = 'New Scratch Buffer' })

-- Navigate Buffers
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', { desc = 'Next Buffer' })
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous Buffer' })

-- Open Buffer in Split
vim.keymap.set('n', '<leader>bv', function()
  vim.cmd 'vsplit' -- Open a vertical split
  vim.cmd 'enew' -- Create a new buffer (scratch buffer)
end, { desc = 'Open New Scratch Buffer in Vertical Split' })

vim.keymap.set('n', '<leader>bh', function()
  vim.cmd 'split' -- Open a horizontal split
  vim.cmd 'enew' -- Create a new buffer (scratch buffer)
end, { desc = 'Open New Scratch Buffer in Horizontal Split' })

-- Close All Other Buffers
vim.keymap.set('n', '<leader>bo', ':%bd|e#|bd#<CR>', { desc = 'Close All Buffers Except Current' })

-- Reveal Startup screen
vim.keymap.set('n', '<leader>S', ':Startup display<CR>', { desc = 'Display [S]tartup screen' })

--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.keymap.set('n', '<leader>aa', '<cmd>Startup display<CR>', { desc = 'Display the Startup screen' })

-- vim: ts=2 sts=2 sw=2 et
