-- startup.nvim - https://github.com/max397574/startup.nvim
return {
  'startup-nvim/startup.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-file-browser.nvim' },
  config = function()
    require('startup').setup(require 'startup.themes.aceaspades_theme')
  end,
}
