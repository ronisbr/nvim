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
vim.opt.lazyredraw = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.mouse = 'a'
vim.opt.ruler = false
vim.opt.scrolloff = 10
vim.opt.shiftwidth = 4
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.signcolumn = 'yes'
vim.opt.smartcase = true
vim.opt.spelllang = "en_us,pt_br"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.textwidth = 92
vim.opt.undofile = true
vim.opt.updatetime = 250

vim.opt.number = true
vim.opt.relativenumber = true

-- Neovide ---------------------------------------------------------------------------------

if vim.g.neovide then
  vim.o.guifont = "JetBrains Mono,Symbols Nerd Font Mono:h15"

  vim.g.neovide_cursor_animation_length = 0.02
  vim.g.neovide_floating_blur_amount_x = 6.0
  vim.g.neovide_floating_blur_amount_y = 6.0
  vim.g.neovide_floating_corner_radius = 0.4
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 0
  vim.g.neovide_light_radius = 5
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_top = 10
end

-- vim: ts=2 sts=2 sw=2 et
