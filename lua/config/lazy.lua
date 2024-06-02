-- Description -----------------------------------------------------------------------------
--
-- Configuration for the pacakge manager lazy.nvim.
--
-- -----------------------------------------------------------------------------------------

-- Bootstrap lazy.nvim.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- We need to set the leader and localleader **before** setup lazy.nvim.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require("config.options")

require("lazy").setup(
  "plugins",
  {
    change_detection = {
      enabled = false,
      notify = false,
    },

    checker = {
      enabled = true
    },

    defaults = {
      -- By default, we will lazy-load plugins.
      lazy = true,
    },

    install = {
      colorscheme = { "nano-theme" }
    }
  }
)

require("config.autocmds")
require("config.keymaps")

-- vim:ts=2:sts=2:sw=2:et
