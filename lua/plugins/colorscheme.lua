-- Description -----------------------------------------------------------------------------
--
-- Configuration of the color schemes.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    -- MiniDeps.add({ source = "sainnhe/gruvbox-material", })

    -- vim.g.gruvbox_material_background           = "medium"
    -- vim.g.gruvbox_material_better_performance   = true
    -- vim.g.gruvbox_material_dim_inactive_windows = true
    -- vim.g.gruvbox_material_enable_bold          = true
    -- vim.g.gruvbox_material_enable_italic        = true
    -- vim.g.gruvbox_material_float_style          = "dim"

    -- vim.cmd.colorscheme("gruvbox-material")

    -- MiniDeps.add({ source = "ronisbr/nano-theme.nvim" })
    --
    -- vim.cmd.colorscheme("nano-theme")
    -- vim.o.background = "light"

    -- Customize Highlight Groups ----------------------------------------------------------

    -- vim.api.nvim_set_hl(0, "WinBar", { bold = false })
    -- vim.api.nvim_set_hl(0, "WinBarNC", { bold = false })

    MiniDeps.add({ source = "rebelot/kanagawa.nvim" })
    require("kanagawa").setup({})
    vim.cmd.colorscheme("kanagawa-dragon")
  end
)

