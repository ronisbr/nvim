-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to treesitter.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.now(
  function()
    local augroup = vim.api.nvim_create_augroup("ronisbr_treesitter", { clear = true })

    -- Languages with treesitter highlighting and indentation.
    local filetypes = {
      "bash",
      "c",
      "cpp",
      "diff",
      "julia",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "vim",
      "vimdoc",
      "yaml",
    }

    vim.api.nvim_create_autocmd(
      "PackChanged",
      {
        group    = augroup,
        callback = function(ev)
          local name, kind = ev.data.spec.name, ev.data.kind

          if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then
              vim.cmd.packadd("nvim-treesitter")
            end

            vim.cmd("TSUpdate")
          end
        end,
      }
    )

    require("nvim-treesitter").install(filetypes)

    vim.api.nvim_create_autocmd(
      "FileType",
      {
        group    = augroup,
        pattern  = filetypes,
        callback = function()
          vim.treesitter.start()
        end,
      }
    )

    -- Julia buffers wrap the treesitter indentation in `after/ftplugin/julia.lua`.
    vim.api.nvim_create_autocmd(
      "FileType",
      {
        group    = augroup,
        pattern  = vim.tbl_filter(function(ft) return ft ~= "julia" end, filetypes),
        callback = function()
          vim.bo.indentexpr = require("nvim-treesitter").indentexpr
        end,
      }
    )
  end
)
