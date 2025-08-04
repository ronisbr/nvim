-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

return {
  -- {
  --   "catppuccin/nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "auto",
  --     })
  --
  --     vim.cmd.colorscheme("catppuccin")
  --   end
  -- },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_background           = "medium"
      vim.g.gruvbox_material_better_performance   = true
      vim.g.gruvbox_material_dim_inactive_windows = true
      vim.g.gruvbox_material_enable_bold          = true
      vim.g.gruvbox_material_enable_italic        = true
      vim.g.gruvbox_material_float_style          = "dim"

      vim.cmd.colorscheme("gruvbox-material")

      -- Customize Highlight Groups --------------------------------------------------------

      vim.api.nvim_set_hl(0, "WinBar", { bold = false })
      vim.api.nvim_set_hl(0, "WinBarNC", { bold = false })
    end
  },
  -- {
  --   "ronisbr/nano-theme.nvim",
  --   lazy = false,
  --   priority = 1000,
  -- }
}

-- vim:ts=2:sts=2:sw=2:et
