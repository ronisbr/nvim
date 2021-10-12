-- Plugin configuration: nvim-tree.lua
-- ============================================================================

require('nvim-tree').setup({
  disable_netrw = false,
  hijack_netrw  = false,
  auto_close    = true,
  update_cwd    = false,
  diagnostics = {
    enable = false,
    icons = {
      hint    = "",
      info    = "",
      warning = "",
      error   = "",
    },
  },
  view = {
    auto_resize = true,
  },
})
