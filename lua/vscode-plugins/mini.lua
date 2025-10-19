-- Description -----------------------------------------------------------------------------
--
-- Configuration of mini.nvim and its modules.
--
-- -----------------------------------------------------------------------------------------

-- mini.align ------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "nvim-mini/mini.align" })

    require("mini.align").setup({})
  end
)

-- mini.move -------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "nvim-mini/mini.move" })

    require("mini.move").setup({})
  end
)

-- mini.splitjoin --------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "nvim-mini/mini.splitjoin" })

    require("mini.splitjoin").setup({
      detect = { separator = "[,;]" }
    })
  end
)

-- mini.trailspace -------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = "nvim-mini/mini.trailspace" })

    require("mini.trailspace").setup({})

    -- Keymaps -----------------------------------------------------------------------------

    local function mini_trailspace_map(lhs, rhs, desc)
      return vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
    end

    mini_trailspace_map("<Leader>tw", MiniTrailspace.trim, "Trim Whitespaces")
    mini_trailspace_map("<Leader>tl", MiniTrailspace.trim_last_lines, "Trim Lastlines")
  end
)

-- vim:ts=2:sts=2:sw=2:et
