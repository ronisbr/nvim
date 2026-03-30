_G.__nvim_start_time = (_G.__nvim_start_time or vim.uv.hrtime())

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("plugins")

require("config.autocmds")
require("config.keymaps")
require("config.options")

require("misc.bufdelete").setup()
require("misc.input").setup()
require("misc.lazygit").setup()
require("misc.statusline").setup()
require("misc.terminal").setup()

require("misc.julia").setup()

MiniMisc.now(
  function()
    local plugins = vim.pack.get()
    local num_plugins = 0

    for _ in pairs(plugins) do
      num_plugins = num_plugins + 1
    end

    _G.__nvim_num_loaded_plugins = num_plugins

    vim.cmd("doautocmd User StartupFinished")
  end
)

