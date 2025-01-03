-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins toogleterm.nvim.
--
-- -----------------------------------------------------------------------------------------

return {
  {
     "voldikss/vim-floaterm",
    cmd = { "FloatermNew", "FloatermToggle", "FloatermNext", "FloatermPrev" },
    version = false,

    keys = {
      { "<Leader>ot", ":FloattermToggle<CR>", desc = "Open Terminal", silent = true },
      { "<F2>", "<Esc><Cmd>FloatermNew<CR>", desc = "New Floatterm", mode = {"i", "n", "v"} },
      { "<F5>", "<Esc><Cmd>FloatermToggle<CR>", desc = "Toggle Floatterm", mode = {"i", "n", "v"} },
      { "<F2>", "<C-\\><C-n><Cmd>FloatermNew<CR>", desc = "New Floatterm", mode = "t" },
      { "<F3>", "<C-\\><C-n><Cmd>FloatermPrev<CR>", desc = "Previous Floatterm", mode = "t" },
      { "<F4>", "<C-\\><C-n><Cmd>FloatermNext<CR>", desc = "Next Floatterm", mode = "t" },
      { "<F5>", "<C-\\><C-n><Cmd>FloatermToggle<CR>", desc = "Toggle Floatterm", mode = "t" },
    },

    config = function ()
      vim.g.floaterm_autoclose = 1
      vim.g.floaterm_autoinsert = 1
      vim.g.floaterm_gitcommit = 'floaterm'
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_title = ''
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_wintitle = 0
      vim.g.floaterm_borderchars = '─│─│╭╮╯╰'

      -- Set the float term border.
      vim.cmd [[hi FloatermBorder ctermbg=none ctermfg=none guibg=none guifg=none]]
    end,
  }
}

-- vim:ts=2:sts=2:sw=2:et
