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

-- Command Line
vim.keymap.set('n', ';', ':', { desc = 'Open Command Bar' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Terminal Session
vim.api.nvim_set_keymap('n', '<leader>tt', ':term<CR>', { noremap = true, silent = true, desc = 'Open [T]erminal' })
vim.api.nvim_set_keymap('n', '<leader>tv', ':vsp | term<CR>', { noremap = true, silent = true, desc = 'Open Terminal [V]ertical Split' })
vim.api.nvim_set_keymap('n', '<leader>ts', ':sp | term<CR>', { noremap = true, silent = true, desc = 'Open Terminal - Horizontal [S]plit' })

-- Open floating terminal window

local floating_term = {
  buf = nil,
  win = nil,
}

-- Start terminal session on Neovim startup
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Ensure terminal buffer is created on startup
    if not floating_term.buf or not vim.api.nvim_buf_is_valid(floating_term.buf) then
      floating_term.buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(floating_term.buf, 'bufhidden', 'hide')
      vim.api.nvim_buf_set_option(floating_term.buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(floating_term.buf, 'modifiable', false)

      -- Start terminal in buffer
      vim.api.nvim_buf_call(floating_term.buf, function()
        vim.fn.termopen(vim.o.shell, {
          on_exit = function()
            -- Reopen terminal if it exits
            vim.fn.termopen(vim.o.shell)
          end,
        })
      end)

      -- Ensure terminal starts in Terminal mode
      vim.api.nvim_buf_call(floating_term.buf, function()
        vim.cmd 'startinsert' -- Enter Terminal mode
      end)
    end
  end,
})

local function toggle_floating_terminal()
  -- If window exists, close it
  if floating_term.win and vim.api.nvim_win_is_valid(floating_term.win) then
    vim.api.nvim_win_close(floating_term.win, true)
    floating_term.win = nil
    return
  end

  -- Create buffer if it doesn't exist
  if not floating_term.buf or not vim.api.nvim_buf_is_valid(floating_term.buf) then
    floating_term.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(floating_term.buf, 'bufhidden', 'hide') -- Keep buffer when closed
    vim.api.nvim_buf_set_option(floating_term.buf, 'buftype', 'nofile') -- Prevent modification issues
    vim.api.nvim_buf_set_option(floating_term.buf, 'modifiable', false)

    -- Start terminal in buffer
    vim.api.nvim_buf_call(floating_term.buf, function()
      vim.fn.termopen(vim.o.shell)
    end)

    -- Ensure terminal starts in Terminal mode
    vim.api.nvim_buf_call(floating_term.buf, function()
      vim.cmd 'startinsert'
    end)

    -- Map <Esc> to close window but keep buffer
    vim.keymap.set('t', '<C-\\>', ':hide<CR>', { buffer = floating_term.buf, silent = true })
  end

  -- Floating window options
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.6)
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  }

  -- Open floating window with the existing buffer
  floating_term.win = vim.api.nvim_open_win(floating_term.buf, true, opts)
end

-- Map the function to a keybinding
vim.keymap.set('n', '<leader>tf', toggle_floating_terminal, { noremap = true, silent = true, desc = 'Open [F]loating Terminal Window' })
vim.keymap.set('n', '<C-\\>', toggle_floating_terminal, { noremap = true, silent = true, desc = 'Open Floating Terminal Window' })

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

-- Function to toggle comment in normal mode
vim.keymap.set('n', '<C-/>', function()
  vim.cmd 'normal! gcc'
end, { noremap = true, silent = true, desc = 'Toggle Comment' })

-- Function to toggle comment in visual mode
vim.keymap.set('v', '<C-/>', function()
  vim.cmd 'normal! gc'
end, { noremap = true, silent = true, desc = 'Toggle Comment' })

vim.api.nvim_set_keymap('n', '<D-/>', 'gcc', { noremap = false, silent = true })
vim.api.nvim_set_keymap('v', '<D-/>', 'gb', { noremap = false, silent = true })

-- Window Management
vim.keymap.set('n', '<leader>ws', ':split<CR>', { desc = 'Split Window Horizontally' })
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>', { desc = 'Split Window Vertically' })
vim.keymap.set('n', '<leader>wk', ':close<CR>', { desc = 'Close Current Window' })
vim.keymap.set('n', '<leader>wo', ':only<CR>', { desc = 'Close All Other Windows' })

-- Resize windows
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize Window Sizes' })
vim.keymap.set('n', '<leader>w]', ':resize +20<CR>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<leader>w[', ':resize +20<CR>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<leader>w>', ':vertical resize +20<CR>', { desc = 'Increase Window Width' })
vim.keymap.set('n', '<leader>w<', ':vertical resize -20<CR>', { desc = 'Decrease Window Width' })

-- Swap windows
vim.keymap.set('n', '<leader>wH', '<C-w>H', { desc = 'Move Window to Left' })
vim.keymap.set('n', '<leader>wJ', '<C-w>J', { desc = 'Move Window to Bottom' })
vim.keymap.set('n', '<leader>wK', '<C-w>K', { desc = 'Move Window to Top' })
vim.keymap.set('n', '<leader>wL', '<C-w>L', { desc = 'Move Window to Right' })

-- Save Buffer
vim.keymap.set('n', '<D-s>', ':w<CR>', { silent = false, desc = '[S]ave Buffer' })
vim.keymap.set('i', '<D-s>', '<Esc>:w<CR>a', { silent = false, desc = '[S]ave Buffer' })
vim.keymap.set('v', '<D-s>', '<Esc>:w<CR>gv', { silent = false, desc = '[S]ave Buffer' })

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
