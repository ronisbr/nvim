-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to LSP.
--
-- -----------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
--                           Configuration of Language Servers                            --
--------------------------------------------------------------------------------------------

local servers = {
  -- Julia Language Server -----------------------------------------------------------------

  julials = {
    settings = {
      julia = {
        inlayHints = {
          static = {
            enabled = true,
            variableTypes = {
              enabled = false
            },
            parameterNames = "all"
          }
        }
      }
    }
  },

  -- Lua Language Server -------------------------------------------------------------------

  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = {
            "vim",
            "use",
            "s",
            "sn",
            "i",
            "rep",
            "c",
            "d",
            "f",
            "t",
            "fmta",
            "fmt"
          },
        },
        hint = {
          enable = true,
          paramName = "Enable"
        },
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          library = {
            vim.fn.expand("$VIMRUNTIME/lua"),
            vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
          }
        }
      }
    }
  },

  -- LaTeX Language Server -----------------------------------------------------------------

  tabtex = {
  }
}

--------------------------------------------------------------------------------------------
--                                  Plugin Configuration                                  --
--------------------------------------------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    version = false,

    dependencies = {
      "williamboman/mason.nvim",
    },

    config = function()
      -- Create an autocmd to configure the buffer when the LSP attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ronisbr-lsp-attach", { clear = true }),

        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          -- Keymaps -------------------------------------------------------------------------

          map("gd", ":Telescope lsp_definitions<CR>", "Goto Definition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("gr", ":Telescope lsp_references<CR>", "Goto References")
          map("gI", ":Telescope lsp_implementations<CR>", "Goto Implementation")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          map("<Leader>cD",  ":Telescope lsp_type_definitions<CR>", "Type Definition")
          map("<Leader>cd", ":Telescope lsp_document_symbols<CR>", "Document Symbols")
          map("<Leader>cw", ":Telescope lsp_dynamic_workspace_symbols<CR>", "Workspace Symbols")
          map("<Leader>cr", vim.lsp.buf.rename, "Rename")
          map("<Leader>ca", vim.lsp.buf.code_action, "Action")

          -- Highlighting ------------------------------------------------------------------

          -- Highlight references of the word under the cursor.
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup =
              vim.api.nvim_create_augroup("ronisbr-lsp-highlight", { clear = false })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("ronisbr-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = "ronisbr-lsp-highlight",
                  buffer = event2.buf
                })
              end,
            })
          end

          -- Inlay Hints -------------------------------------------------------------------

          if client and
            client.server_capabilities.inlayHintProvider and
            vim.lsp.inlay_hint then
            map(
              "<Leader>ci",
              function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ }))
              end,
              "Toggle Inlay Hints"
            )
          end
        end,
      })
    end
  },

  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    version = false,

    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()
      require("mason").setup()
      require('mason-lspconfig').setup()
      require("mason-lspconfig").setup_handlers({
        function (server_name)
          local server = servers[server_name] or {}
          require("lspconfig")[server_name].setup(server)
        end,
      })
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
