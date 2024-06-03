--escription -----------------------------------------------------------------------------
--
-- Configuration of plugins related to treesitter.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate",

    opts = {
      auto_install = true,

      ensure_installed = {
        "bash",
        "c",
        "diff",
        "julia",
        "lua",
        "luadoc",
        "markdown",
        "vim",
        "vimdoc"
      },

      highlight = {
        enable = true,
      },

      indent = {
        enable = true,
        disable = {
          "markdown"
        },
      }
    },

    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = true
      require("nvim-treesitter.configs").setup(opts)
    end
  }
}

-- vim: ts=2 sts=2 sw=2 et
