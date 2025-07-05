-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to LSP.
--
-- -----------------------------------------------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "echasnovski/mini.completion" },
    event = { "BufReadPre", "BufNewFile" },
    version = false,

    config = function()

      -- Configuration of the LSP Clients --------------------------------------------------

      vim.lsp.config(
        "*",
        {
          capabilities = MiniCompletion.get_lsp_capabilities()
        }
      )

      -- Julia --
      vim.lsp.config("julials", {})

      -- Lua --
      vim.lsp.config('lua_ls', {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath('config')
              and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
            then
              return
            end
          end

          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT',
              path = {
                'lua/?.lua',
                'lua/?/init.lua',
              },
            },

            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              }
            }
          })
        end,
        settings = {
          Lua = {}
        }
      })

      -- Create an autocmd to configure the buffer when the LSP attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("ronisbr-lsp-attach", { clear = true }),

        callback = function(event)
          local function map(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          -- Keymaps -------------------------------------------------------------------------

          local function lsp_hover()
            vim.lsp.buf.hover({
                border = "rounded"
            })
          end

          local function lsp_signature()
            vim.lsp.buf.signature_help({
                border    = "rounded",
                title_pos = "left",
            })
          end

          -- Change the mappings of default Neovim keybindings.
          map("n", "gO", Snacks.picker.lsp_symbols, "Document Symbols")
          map("n", "grD", Snacks.picker.lsp_declarations, "Goto Declaration")
          map("n", "gra", vim.lsp.buf.code_action, "Code Action")
          map("n", "grd", Snacks.picker.lsp_definitions, "Goto Definition")
          map("n", "gri", Snacks.picker.lsp_implementations, "Goto Implementation")
          map("n", "grn", vim.lsp.buf.rename, "Rename")
          map("n", "grr", Snacks.picker.lsp_references, "Goto References")
          map("n", "grt", Snacks.picker.lsp_type_definitions, "Type Definition")
          map("n", "grw", Snacks.picker.lsp_workspace_symbols, "Workspace Symbols")
          map("i", "<C-s>", lsp_signature, "Signature Help")

          -- Other mappings.
          map("n", "K", lsp_hover, "Hover Documentation")
        end
      })

      -- Enable LSP Clients ----------------------------------------------------------------

      vim.lsp.enable("julials")
      vim.lsp.enable("lua_ls")
    end
  },
}

-- vim:ts=2:sts=2:sw=2:et
