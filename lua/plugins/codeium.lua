-- Description -----------------------------------------------------------------------------
--
-- Configurations related to Julia files (*.jl).
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    config = function ()
      vim.g.codeium_disable_bindings = 1

      vim.keymap.set(
        "i",
        "<C-g>",
        function ()
          return vim.fn["codeium#Accept"]()
        end,
        { expr = true, silent = true }
      )

      vim.keymap.set(
        "i",
        "<C-k>",
        function ()
          return vim.fn["codeium#AcceptNextWord"]()
        end,
        { expr = true, silent = true }
      )

      vim.keymap.set(
        "i",
        "<C-l>",
        function ()
          return vim.fn["codeium#AcceptNextLine"]()
        end,
        { expr = true, silent = true }
      )

      vim.keymap.set(
        "i",
        "<C-.>",
        function()
          return vim.fn["codeium#CycleCompletions"](1)
        end,
        { expr = true, silent = true }
      )

      vim.keymap.set(
        "i",
        "<C-,>",
        function()
          return vim.fn["codeium#CycleCompletions"](-1)
        end,
        { expr = true, silent = true }
      )

      vim.keymap.set(
        "i",
        "<C-/>",
        function()
          return vim.fn["codeium#Clear"]()
        end,
        { expr = true, silent = true }
      )
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
