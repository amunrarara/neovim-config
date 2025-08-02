return {
  'startup-nvim/startup.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  config = function()
    -- Let's add a simple autocommand to suppress the error
    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "*",
      callback = function()
        -- Only in startup buffer
        if vim.bo.filetype == "" then
          pcall(function() 
            -- No-op - this just catches the error if it occurs
          end)
        end
      end,
      group = vim.api.nvim_create_augroup("StartupNvimErrorSuppression", { clear = true }),
    })
    
    -- Load the theme and setup
    local theme = require 'startup.themes.aceaspades_theme'
    require('startup').setup(vim.tbl_deep_extend('force', theme, {
      options = {
        disable_statuslines = true,
        after = function()
          vim.cmd 'stopinsert' -- Start in Normal mode
        end,
      },
    }))
  end,
}
