_G.__nvim_start_time = (_G.__nvim_start_time or vim.uv.hrtime())

require("config.minideps")

require("config.autocmds")
require("config.keymaps")
require("config.options")

require("misc.bufdelete").setup()
require("misc.julia").setup()
require("misc.lazygit").setup()
require("misc.statusline").setup()
require("misc.terminal").setup()

-- vim:ts=2:sts=2:sw=2:et
