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

-- We must set this autocmd here to ensure it is created before the theme definition.
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "nano-theme",
  callback = function ()
    local c = require("nano-theme.colors").get()

    -- Set additional highlight groups.
    vim.api.nvim_set_hl(
      0,
      "@assignment",
      { fg = c.nano_salient_color, bold = true }
    )

    vim.api.nvim_set_hl(
      0,
      "@function.macro.julia",
      { fg = c.nano_salient_color, bold = true }
    )

    vim.api.nvim_set_hl(
      0,
      "@function.macro.call.julia",
      { fg = c.nano_salient_color, bold = true }
    )

    vim.api.nvim_set_hl(
      0,
      "@markup.strong.markdown_inline",
      {
        bold = true,
        fg = c.fg
      }
    )

    vim.api.nvim_set_hl(
      0,
      "@string.interpolation",
      { fg = c.nano_salient_color, bold = true }
    )

    vim.api.nvim_set_hl(
      0,
      "@text.literal.block.markdown",
      { bg = c.nano_highlight_color }
    )

    vim.api.nvim_set_hl(
      0,
      "@text.literal.heading.markdown",
      {
        bg = c.nano_subtle_color,
        fg = c.nano_strong_color,
        bold = true,
      }
    )
  end
})

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
      colorscheme = { "catppuccin" }
    },

    ui = {
      border = "rounded",
    }
  }
)

require("config.autocmds")
require("config.keymaps")

require("misc.julia").setup()
require("misc.statusline").setup()

-- vim:ts=2:sts=2:sw=2:et
