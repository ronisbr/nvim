-- Plugin configuration: alpha-nvim
-- ============================================================================

local alpha = require('alpha')

local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
  [[███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗]],
  [[████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║]],
  [[██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║]],
  [[██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║]],
  [[██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║]],
  [[╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝]],
}

dashboard.section.buttons.val = {
  dashboard.button("SPC f f", "  Find File",           ":Telescope find_files<CR>"),
  dashboard.button("SPC f h", "  Recently Used Files", ":Telescope oldfiles<CR>"),
  dashboard.button("SPC s l", "  Load Last Session",   ":SessionLoad<CR>"),
  dashboard.button("SPC f a", "  Find Word",           ":Telescope live_grep<CR>"),
  dashboard.button("SPC f b", "  Marks",               ":Telescope marks<CR>"),
}

alpha.setup(dashboard.opts)
