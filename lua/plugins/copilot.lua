-- Description -----------------------------------------------------------------------------
--
-- Configuraiton of Github copilot.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "github/copilot.vim",
    event = "BufEnter",
    config = function()
      vim.g.copilot_no_tab_map = true

      vim.keymap.set(
        "i",
        "<C-g>",
        "copilot#Accept(\"\")",
        {expr = true, replace_keycodes = false, silent = true,}
      )

      vim.keymap.set(
        "i",
        "<C-k>",
        "<Plug>(copilot-accept-word)",
        {silent = true,}
      )

      vim.keymap.set(
        "i",
        "<C-l>",
        "<Plug>(copilot-accept-line)",
        {silent = true,}
      )

      vim.keymap.set(
        "i",
        "<C-.>",
        "<Plug>(copilot-next)",
        {silent = true,}
      )

      vim.keymap.set(
        "i",
        "<C-,>",
        "<Plug>(copilot-previous)",
        {silent = true,}
      )

      vim.keymap.set(
        "i",
        "<C-/>",
        "<Plug>(copilot-dismiss)",
        {silent = true,}
      )
    end
  }
}
