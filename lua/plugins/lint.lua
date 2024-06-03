-- Description -----------------------------------------------------------------------------
--
-- Configuration of linters.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        markdown = { "markdownlint" },
      }
    },

    config = function(_, opts)
      require("lint").linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd(opts.events, {
        callback = function()
          require("lint").try_lint()
        end
      })
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
