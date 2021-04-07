require 'nvim-treesitter.configs'.setup {
  ensure_installed = {
    'comment',
    'html',
    'lua',
    'julia'
  },
  highlight = {
    enable = true
  }
}
