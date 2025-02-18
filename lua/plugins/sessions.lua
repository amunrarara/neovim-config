return {
  'natecraddock/sessions.nvim',
  opts = { events = { 'WinEnter' }, session_filepath = vim.fn.stdpath 'data' .. '/sessions', absolute = true },
}
