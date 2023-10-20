-- Plugin configuration: vim-floaterm ------------------------------------------------------

return {
  {
    "voldikss/vim-floaterm",
    cmd = { "FloatermNew", "FloatermToggle", "FloatermNext", "FloatermPrev" },
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
      vim.cmd [[hi FloatermBorder guibg=none guifg=none]]
    end,
    lazy = true,
  }
}
