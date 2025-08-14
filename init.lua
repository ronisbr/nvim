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

MiniDeps.later(
  function()
    local num_plugins = #MiniDeps.get_session()
    _G.__nvim_num_loaded_plugins = num_plugins

    vim.cmd("doautocmd User MiniDepsFinished")
  end
)

-- vim:ts=2:sts=2:sw=2:et
