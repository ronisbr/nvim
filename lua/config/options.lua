-- Description -----------------------------------------------------------------------------
--
-- General options for Neovim.
--
-- -----------------------------------------------------------------------------------------

vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "93"
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.lazyredraw = false
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = 'a'
vim.opt.ruler = false
vim.opt.scrolloff = 10
vim.opt.shiftwidth = 4
vim.opt.shortmess = vim.opt.shortmess + { c = true, q = true }
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.spelllang = "en_us,pt_br"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.textwidth = 92
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.virtualedit = "block"

vim.opt.number = true
vim.opt.relativenumber = true

-- Neovide ---------------------------------------------------------------------------------

if vim.g.neovide then
  -- vim.o.guifont = "JetBrains Mono,Symbols Nerd Font Mono:h15"
  vim.o.guifont = "Monaco Nerd Font:h15"
  vim.o.linespace = -1

  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_floating_blur_amount_x = 6.0
  vim.g.neovide_floating_blur_amount_y = 6.0
  vim.g.neovide_floating_corner_radius = 0.4
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_top = 10
  vim.g.neovide_scroll_animation_length = 0.1

  -- We must disable shadows until this bug is fixed:
  --
  --     https://github.com/neovide/neovide/issues/2931
  --
  vim.g.neovide_floating_shadow = false
  -- vim.g.neovide_floating_z_height = 10
  -- vim.g.neovide_light_angle_degrees = 0
  -- vim.g.neovide_light_radius = 5

  -- Fix pasting using `CMD+v` on macOS. Otherwise, we will not be able to paste to the
  -- terminal using `CMD+v` on Neovide. For more information, see:
  --
  --    https://github.com/neovide/neovide/issues/1263
  vim.keymap.set(
    {'n', 'v', 's', 'x', 'o', 'i', 'l', 'c', 't'},
    '<D-v>',
    function()
      vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
    end,
    {
      noremap = true,
      silent = true
    }
  )
end

-- vim: ts=2 sts=2 sw=2 et
