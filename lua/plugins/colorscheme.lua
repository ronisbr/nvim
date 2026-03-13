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
    require("kanagawa").setup({
      terminalColors = false,

      overrides = function(colors)
        local theme = colors.theme
        return {
          Pmenu         = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuExtra    = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuExtraSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuKind     = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },
          PmenuKindSel  = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar     = { bg = theme.ui.bg_m1 },
          PmenuSel      = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuThumb    = { bg = theme.syn.identifier },
        }
      end
    })

    vim.cmd.colorscheme("kanagawa-dragon")
  end
)
