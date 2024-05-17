-- Plugin configuration: emojify.nvim ------------------------------------------------------

return {
  "ronisbr/emojify.nvim",
  config = function ()
    require("emojify").setup({
      inlay = true
    })
    vim.cmd("Emojify")
  end,
  lazy = false,
}
