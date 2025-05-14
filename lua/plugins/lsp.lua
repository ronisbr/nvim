-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to LSP.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    event = { "BufReadPre", "BufNewFile" },
    version = false,

    config = function()
      vim.lsp.config(
        "*",
        {
          capabilities = require('blink.cmp').get_lsp_capabilities()
        }
      )

      vim.lsp.config("julials", {})
      vim.lsp.config("lua_ls", {})

      vim.lsp.enable("julials")
      vim.lsp.enable("lua_ls")

      -- Create an autocmd to configure the buffer when the LSP attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ronisbr-lsp-attach", { clear = true }),

        callback = function(event)
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          -- Keymaps -------------------------------------------------------------------------

          map("gd", Snacks.picker.lsp_definitions, "Goto Definition")
          map("gr", Snacks.picker.lsp_references, "Goto References")
          map("gI", Snacks.picker.lsp_implementations, "Goto Implementation")
          map("gD", Snacks.picker.lsp_declarations, "Goto Declaration")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          map("<Leader>cD",  Snacks.picker.lsp_type_definitions, "Type Definition")
          map("<Leader>cd", Snacks.picker.lsp_symbols, "Document Symbols")
          map("<Leader>cw", Snacks.picker.lsp_workspace_symbols, "Workspace Symbols")
          map("<Leader>cr", vim.lsp.buf.rename, "Rename")
          map("<Leader>ca", vim.lsp.buf.code_action, "Action")
        end
      })
    end
  },
}

-- vim:ts=2:sts=2:sw=2:et
