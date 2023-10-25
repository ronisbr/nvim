-- Plugin configuration: emojify.nvim ------------------------------------------------------

return {
  "ronisbr/emojify.nvim",
  config = function ()
    require("emojify").setup()
    vim.cmd("Emojify")
  end,
  lazy = false,
}
