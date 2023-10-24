-- Plugin configuration: whitespace.nvim ---------------------------------------------------

return {
  {
    "johnfrankmorgan/whitespace.nvim",
    config = function ()
      require("whitespace-nvim").setup({
        highlight = "WarningMsg",
        ignored_filetype = { "TelescopePrompt", "Trouble", "help" },
        ignore_terminal = true
      })
    end,
    lazy = false,
  }
}
