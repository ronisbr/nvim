-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin fzf-lua.
--
-- -----------------------------------------------------------------------------------------

return {
  "ibhagwan/fzf-lua",
  cmd = { "FzfLua" },
  dependencies = { "nvim-tree/nvim-web-devicons" },

  keys = {
    {
      "<Leader>/",
      function()
        require("fzf-lua").blines()
      end,
      desc = "Fuzzily Search in Current Buffer",
      silent = true,
    },
    {
      "<Leader>.",
      function()
        require("fzf-lua").files()
      end,
      desc = "Find Files in ./",
      silent = true
    },
    {
      "<Leader>fb",
      function()
        require("fzf-lua").lines()
      end,
      desc = "Find Opened Buffers",
      silent = true
    },
    {
      "<Leader>fh",
      function()
        require("fzf-lua").helptags()
      end,
      desc = "Find Help",
      silent = true
    },
    {
      "<Leader>fi",
      function()
        require("fzf-lua").live_grep_native()
      end,
      desc = "Find with Grep",
      silent = true
    },
    {
      "<Leader>fr",
      function()
        require("fzf-lua").oldfiles()
      end,
      desc = "Find Recent Files",
      silent = true
    },
    {
      "<Leader>fz",
      function()
        require("fzf-lua").builtin()
      end,
      desc = "FzfLua builtin commands",
      silent = true
    }
  },

  config = function()
    require("fzf-lua").setup({
      fzf_colors = {
        true,
        ["hl"] = { "fg", "Comment", "bold" },
        ["hl+"] = { "fg", "Statement", "bold" },
      }
    })

    -- Use fzf-lua as the default UI for selections.
    require("fzf-lua").register_ui_select()
  end
}

-- vim:ts=2:sts=2:sw=2:et
