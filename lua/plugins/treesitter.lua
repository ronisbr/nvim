-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to treesitter.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.add({
  source = "nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout =
      function()
        vim.cmd("TSUpdate")
      end
    }
})

--------------------------------------------------------------------------------------------
--                                         Setup                                          --
--------------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    require("nvim-treesitter.install").prefer_git = true
    require("nvim-treesitter.configs").setup({
      additional_vim_regex_highlighting = false,

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

      highlight = { enable = true, },

      ignore_install = { "gitcommit" },

      indent = {
        enable = true,
        disable = { "markdown" },
      }
    })
  end
)

-- vim: ts=2 sts=2 sw=2 et
