-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to treesitter.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    vim.api.nvim_create_autocmd(
      "PackChanged",
      {
        callback = function(ev)
          local name, kind = ev.data.spec.name, ev.data.kind
          if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
            vim.cmd("TSUpdate")
          end
        end
      }
    )

    require("nvim-treesitter").install({
      "bash",
      "c",
      "diff",
      "julia",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "yaml"
    })

    vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = {
          "bash",
          "c",
          "diff",
          "julia",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "vim",
          "vimdoc",
          "yaml"
        },
        callback = function()
          vim.treesitter.start()
        end,
        group = ronisbr_autocmd_groups
      }
    )

    vim.api.nvim_create_autocmd(
      "FileType",
      {
        pattern = {
          "bash",
          "c",
          "diff",
          "julia",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "vim",
          "vimdoc",
          "yaml"
        },
        callback = function()
          vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
        end,
        group = ronisbr_autocmd_groups
      }
    )
  end
)

