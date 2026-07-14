_G.__nvim_start_time = (_G.__nvim_start_time or vim.uv.hrtime())

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("plugins")

require("config.autocmds")
require("config.keymaps")
require("config.options")

require("misc.bufdelete").setup()
require("misc.lazygit").setup()
require("misc.statusline").setup()
require("misc.terminal").setup()

require("misc.julia").setup()

MiniMisc.now(
  function()
    _G.__nvim_num_loaded_plugins = #vim.pack.get(nil, { info = false })

    vim.cmd("doautocmd User StartupFinished")
  end
)

