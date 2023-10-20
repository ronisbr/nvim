-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.laststatus = 0
opt.pumblend = 0
opt.shiftwidth = 4
opt.showtabline = 0
opt.statusline = " "
opt.tabstop = 4
opt.textwidth = 92
opt.winblend = 0

vim.g.autoformat = false
vim.o.guifont = "JetBrains Mono NL,Apple Color Emoji,Symbols Nerd Font Mono:h13"

-- Neovide Configuration -------------------------------------------------------------------

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_scroll_animation_length = 0
  vim.g.neovide_scale_factor = 1.1
  vim.g.neovide_padding_top = 20
  vim.g.neovide_padding_bottom = 20
  vim.g.neovide_padding_right = 20
  vim.g.neovide_padding_left = 20
  vim.g.neovide_background_color = "#ffffff"
  vim.g.neovide_floating_blur_amount_x = 10.0
  vim.g.neovide_floating_blur_amount_y = 10.0

  opt.pumblend = 30
  opt.winblend = 30
end

