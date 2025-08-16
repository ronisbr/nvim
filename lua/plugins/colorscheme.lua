-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({ source = "sainnhe/gruvbox-material", })

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
)

-- vim:ts=2:sts=2:sw=2:et
