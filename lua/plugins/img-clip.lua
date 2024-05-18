-- Plugin: img-clip.nvim -------------------------------------------------------------------

return {
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = function()
          return vim.fn.expand("%:p:h") .. "/assets"
        end,
      }
    }
  }
}
