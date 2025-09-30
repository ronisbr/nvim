-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to LSP.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.now(
  function()
    MiniDeps.add({
      source = "neovim/nvim-lspconfig",
      dependencies = {
        "nvim-mini/mini.completion",
        "nvim-mini/mini.extra",
      }
    })

    -- Configuration of the LSP Clients ----------------------------------------------------

    vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })

    -- Copilot .............................................................................

    vim.lsp.config("copilot", {})

    -- C++ ..............................................................................

    vim.lsp.config("clangd", {})

    -- Julia ...............................................................................

    vim.lsp.config("julials", {})

    -- Lua .................................................................................

    vim.lsp.config('lua_ls', {
      on_init = function(client)
        -- Early return if workspace has existing config
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath('config') and
             (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
            return
          end
        end

        -- Optimized settings merge
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } }
        })
      end,
      settings = { Lua = {} }
    })

    -- Create an autocmd to configure the buffer when the LSP attaches.
    vim.api.nvim_create_autocmd(
      "LspAttach",
      {
        group = vim.api.nvim_create_augroup("ronisbr-lsp-attach", { clear = true }),
        callback = function(event)
          local function nmap(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end

          nmap("K",   vim.lsp.buf.hover, "Hover Documentation")
          nmap("gra", vim.lsp.buf.code_action, "Code Actions")
          nmap("grd", vim.lsp.buf.definition, "Definition")
          nmap("grD", vim.lsp.buf.declaration, "Declaration")
          nmap("gri", vim.lsp.buf.implementation, "Implementation")
          nmap("grn", vim.lsp.buf.rename, "Rename")
          nmap("grr", function() MiniExtra.pickers.lsp({ scope = "references" }) end, "References")
        end
      }
    )

    -- Enable LSP Clients ----------------------------------------------------------------

    vim.lsp.enable("clangd")
    vim.lsp.enable("copilot")
    vim.lsp.enable("julials")
    vim.lsp.enable("lua_ls")
  end
)

-- vim:ts=2:sts=2:sw=2:et
