local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

vim.o.background = "light"

-- We must set this autocmd here to ensure it is created before the theme definition.
vim.api.nvim_create_autocmd(
  "ColorScheme", {
    pattern = "nano-theme",
    callback = function ()
      local c = require("nano-theme.colors").get()

      -- Set additional highlight groups.
      vim.api.nvim_set_hl(
        0,
        "WinBar",
        { fg = c.fg, bg = c.nano_subtle_color }
      )

      vim.api.nvim_set_hl(
        0,
        "@assignment",
        { fg = c.nano_salient_color, bold = true }
      )

      vim.api.nvim_set_hl(
        0,
        "@function.macro.call",
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
  }
)


-- LazyVim --------------------------------------------------------------------------------

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.coding.luasnip" },
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "nano-theme", "material", "tokyonight", "habamax", "catppuccin" } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
