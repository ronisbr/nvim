-- Plugin configuration: zen-mode.nvim -----------------------------------------------------

return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    lazy = true,
    keys = {
      { "<leader>uz", "<cmd>lua require('misc.zen_mode').toogle_zen_mode()<cr>", desc = "Zen Mode" }
    },
    opts = {
      window = {
        backdrop = 1,
        options = {
          number = false,
          relativenumber = false,
        },
      },
      on_close = function ()
        if vim.g.neovide then
          vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / 1.2
        end
      end,
      on_open = function ()
        if vim.g.neovide then
          vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.2
        end
      end,
    }
  }
}
