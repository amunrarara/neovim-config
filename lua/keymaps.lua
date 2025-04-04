-- [[ Basic Keymaps ]]ke
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Swap G and gg, and $ and 0 in all relevant modes
for _, mode in ipairs { 'n', 'v', 'o' } do
  -- Swap G and gg
  vim.keymap.set(mode, 'G', 'gg', { noremap = true })
  vim.keymap.set(mode, 'gg', 'G', { noremap = true })

  -- Swap $ and 0
  vim.keymap.set(mode, '0', '$', { noremap = true })
  vim.keymap.set(mode, '$', '0', { noremap = true })
end

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
vim.api.nvim_set_keymap('n', '<leader>th', ':sp | term<CR>', { noremap = true, silent = true, desc = 'Open Terminal - Horizontal [S]plit' })
vim.api.nvim_set_keymap('n', '<leader>t2', ':sp | term<CR>:vsp | term<CR>', { noremap = true, silent = true, desc = 'Open [2] Terminals (Horizontally)' })

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

-- Update floating terminal cwd when Neovim's cwd changes

vim.api.nvim_create_autocmd('DirChanged', {
  callback = function()
    if floating_term.buf and vim.api.nvim_buf_is_valid(floating_term.buf) then
      local chan_id = vim.b[floating_term.buf].terminal_job_id
      if chan_id and chan_id > 0 then
        local new_cwd = vim.fn.getcwd()
        vim.api.nvim_chan_send(chan_id, 'cd ' .. new_cwd .. '\n')
      end
    end
  end,
})

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
vim.keymap.set('n', '<leader>wh', ':split<CR>', { desc = 'Split Window Horizontally' })
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
vim.keymap.set('n', '<leader>bk', ':bwipeout!<CR>', { desc = 'Kill (Wipeout) Buffer' })

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

-- Start-up Screen
--
vim.keymap.set('n', '<leader>aa', '<cmd>Startup display<CR>', { desc = 'Display the Startup screen' })

-- Git Copy Remote URL

local function get_git_remote_url()
  local handle = io.popen 'git remote get-url origin 2>/dev/null'
  if handle then
    local result = handle:read('*a'):gsub('\n', '')
    handle:close()
    if result:find 'git@' then
      result = result:gsub('git@', 'https://')
      result = result:gsub(':', '/')
    end
    return result:gsub('%.git$', '')
  end
  return nil
end

local function get_git_relative_path()
  local handle = io.popen 'git rev-parse --show-prefix'
  if handle then
    local result = handle:read('*a'):gsub('\n', '')
    handle:close()
    return result .. vim.fn.expand '%'
  end
  return vim.fn.expand '%'
end

local function get_commit_hash()
  local handle = io.popen('git log -n 1 --pretty=format:%H -- ' .. vim.fn.shellescape(vim.fn.expand '%'))
  if handle then
    local result = handle:read('*a'):gsub('\n', '')
    handle:close()
    return result
  end
  return nil
end

_G.copy_commit_git_url = function()
  local remote_url = get_git_remote_url()
  if not remote_url then
    print 'Not a git repository or no remote set'
    return
  end

  local file_path = get_git_relative_path()
  local commit_hash = get_commit_hash()
  local line = vim.fn.line '.'

  if not commit_hash then
    print 'Could not determine commit hash'
    return
  end

  local full_url = remote_url .. '/blob/' .. commit_hash .. '/' .. file_path .. '#L' .. line

  -- Copy to system clipboard
  vim.fn.setreg('+', full_url)
  print('Copied to clipboard: ' .. full_url)
end

-- Create a command for convenience
vim.api.nvim_create_user_command('CopyCommitGitUrl', function()
  _G.copy_commit_git_url()
end, {})

-- Bind it to a key (e.g., <leader>gy for "Git Yank")
vim.api.nvim_set_keymap('n', '<leader>gy', ':CopyCommitGitUrl<CR>', { noremap = true, silent = true })

-- Switch to hex editor mode and back
-- Function to toggle hex mode
local function toggle_hex_mode()
  local ft = vim.bo.filetype

  if vim.b.hex_mode then
    -- Restore from hex mode
    vim.cmd ':%!xxd -r'
    vim.bo.filetype = vim.b.orig_ft
    vim.b.hex_mode = false
    print 'Hex mode: OFF'
  else
    -- Save original filetype and switch to hex mode
    vim.b.orig_ft = ft
    vim.cmd ':%!xxd'
    vim.bo.filetype = 'xxd'
    vim.b.hex_mode = true
    print 'Hex mode: ON'
  end

  -- Ensure buffer is marked as modified to prevent accidental data loss
  vim.bo.modified = true
end

-- Set the keybinding using nvim_set_keymap
vim.api.nvim_set_keymap(
  'n', -- Normal mode
  '<leader>hm', -- Keybinding with <leader>hm
  ':lua toggle_hex_mode()<CR>', -- Command to execute
  { noremap = true, silent = true, desc = 'Toggle hex mode' } -- Options
)
-- Right-click context menu
-- vim.api.nvim_set_keymap('n', '<RightMouse>', ':CopyCommitGitUrl<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<RightMouse>', ':CopyGitUrl<CR>', { noremap = true, silent = true })

-- vim: ts=2 sts=2 sw=2 et
