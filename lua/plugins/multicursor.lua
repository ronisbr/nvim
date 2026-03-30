-- Description -----------------------------------------------------------------------------
--
-- Configuration for multicursor.nvim.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.later(
  function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set(
      {"n", "x"},
      "<C-S-k>",
      function() mc.lineAddCursor(-1) end,
      { desc = "Add cursor above" }
    )

    set(
      {"n", "x"},
      "<C-S-j>",
      function() mc.lineAddCursor(1) end,
      { desc = "Add cursor below" }
    )

    set(
      {"n", "x"},
      "<leader><up>",
      function() mc.lineSkipCursor(-1) end,
      { desc = "Skip cursor above" }
    )

    set(
      {"n", "x"},
      "<leader><down>",
      function() mc.lineSkipCursor(1) end,
      { desc = "Skip cursor below" }
    )

    -- Add or skip adding a new cursor by matching word/selection.
    set(
      {"n", "x"},
      "<leader>mn",
      function() mc.matchAddCursor(1) end,
      { desc = "Add cursor on next match" }
    )

    set(
      {"n", "x"},
      "<leader>ms",
      function() mc.matchSkipCursor(1) end,
      { desc = "Skip cursor on next match" }
    )

    set(
      {"n", "x"},
      "<leader>mN",
      function() mc.matchAddCursor(-1) end,
      { desc = "Add cursor on previous match" }
    )

    set(
      {"n", "x"},
      "<leader>mS",
      function() mc.matchSkipCursor(-1) end,
      { desc = "Skip cursor on previous match" }
    )

    -- Toggle cursor under the main cursor.
    set(
      {"n", "x"},
      "<leader>ma",
      mc.toggleCursor,
      { desc = "Toggle cursor" }
    )

    -- Disable and enable cursors.
    set(
      {"n", "x"},
      "<leader>mt",
      function()
        if mc.cursorsEnabled() then
          mc.disableCursors()
        else
          mc.enableCursors()
        end
      end,
      { desc = "Toggle cursors enabled" }
    )

    -- Mappings defined in a keymap layer only apply when there are multiple cursors.
    mc.addKeymapLayer(
      function(layerSet)
        -- Select a different cursor as the main one.
        layerSet(
          {"n", "x"},
          "<C-S-h>",
          mc.prevCursor,
          { desc = "Select previous cursor" }
        )

        layerSet(
          {"n", "x"},
          "<C-S-l>",
          mc.nextCursor,
          { desc = "Select next cursor" }
        )

        -- Delete the main cursor.
        layerSet(
          {"n", "x"},
          "<leader>mx",
          mc.deleteCursor,
          { desc = "Delete cursor" }
        )

        -- Enable and clear cursors using escape.
        layerSet(
          "n",
          "<Esc>",
          function()
            if not mc.cursorsEnabled() then
              mc.enableCursors()
            else
              mc.clearCursors()
            end
          end,
          { desc = "Enable or clear cursors" }
        )
      end
    )
  end
)
