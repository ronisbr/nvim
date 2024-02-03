-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

opt.conceallevel = 1
opt.formatexpr = ""
opt.guifont = "JetBrains Mono,Symbols Nerd Font Mono,Apple Color Emoji:h13"
opt.pumblend = 0
opt.shiftwidth = 4
opt.showtabline = 0
opt.spelllang = "en_us,pt_br"
opt.spellsuggest = "best,7"
opt.tabstop = 4
opt.textwidth = 92
opt.winblend = 0

vim.g.autoformat = false

-- Set neovim language to English.
vim.cmd("language en_US.UTF-8")

-- Neovide Configuration -------------------------------------------------------------------

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_floating_blur_amount_x = 10.0
  vim.g.neovide_floating_blur_amount_y = 10.0
  vim.g.neovide_floating_shadow = false
  vim.g.neovide_floating_z_height = 2.0
  vim.g.neovide_padding_bottom = 20
  vim.g.neovide_padding_left = 20
  vim.g.neovide_padding_right = 20
  vim.g.neovide_padding_top = 20
  vim.g.neovide_scale_factor = 1.1
  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_transparency = 1.0

  opt.pumblend = 30
  opt.winblend = 30
end

