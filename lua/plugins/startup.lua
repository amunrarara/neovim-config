return {
  'startup-nvim/startup.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
  opts = function()
    local theme = require 'startup.themes.aceaspades_theme'
    return vim.tbl_deep_extend('force', theme, {
      options = {
        disable_statuslines = true,
        after = function()
          vim.cmd 'stopinsert' -- Start in Normal mode
        end,
      },
    })
  end,
}
