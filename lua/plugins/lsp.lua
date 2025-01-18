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
    julia_env_path = "~/.julia/environments/v1.10/",

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
    },

    on_new_config = function(config, workspace_dir)
      local _    = require("mason-core.functional")
      local fs   = require("mason-core.fs")
      local path = require("mason-core.path")

      -- The default configuration used by `mason-lspconfig`:
      --
      --   https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/server_configurations/julials/init.lua
      --
      -- has the following logic to obtain the current environment path:
      --
      --   1. Check if `env_path` is defined.
      --   2. Check if we are in a Julia project.
      --   3. Call julia to return the current env path.
      --
      -- However, the third step causes a significant slow down when Julia is called in a
      -- single file mode because it must wait loading Julia. Here, we will invert the
      -- logic:
      --
      --   1. Check if we are in a Julia project.
      --   2. Check if `env_path` is defined.
      --   3. Call julia to return the current env path.
      --
      -- Hence, if we define `env_path`, we can still use the project folder as root and
      -- avoid the slowdown in the single file case.
      local env_path = nil
      local file_exists = _.compose(fs.sync.file_exists, path.concat, _.concat { workspace_dir })
      if (file_exists { "Project.toml" } and file_exists { "Manifest.toml" }) or
        (file_exists { "JuliaProject.toml" } and file_exists { "JuliaManifest.toml" }) then
        env_path = workspace_dir
      end

      if not env_path then
        env_path = config.julia_env_path and vim.fn.expand(config.julia_env_path)
      end

      if not env_path then
        local ok, env = pcall(vim.fn.system, {
          "julia",
          "--startup-file=no",
          "--history-file=no",
          "-e",
          "using Pkg; print(dirname(Pkg.Types.Context().env.project_file))",
        })
        if ok then
          env_path = env
        end
      end

      config.cmd = {
        vim.fn.exepath "julia-lsp",
        env_path,
      }
      config.cmd_env = vim.tbl_extend("keep", config.cmd_env or {}, {
        SYMBOL_SERVER = config.symbol_server,
        SYMBOL_CACHE_DOWNLOAD = (config.symbol_cache_download == false) and "0" or "1",
      })
    end,
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
    dependencies = { "saghen/blink.cmp" },
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
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          local function maplsp(keys, scope, desc)
            map(
              keys,
              function()
                require("mini.extra").pickers.lsp({ scope = scope })
              end,
              desc
            )
          end

          -- Keymaps -------------------------------------------------------------------------

          maplsp("gd", "definition", "Goto Definition")
          maplsp("gr", "references", "Goto References")
          maplsp("gI", "implementation", "Goto Implementation")
          maplsp("gD", "declaration", "Goto Declaration")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          maplsp("<Leader>cD",  "type_definition", "Type Definition")
          maplsp("<Leader>cd", "document_symbol", "Document Symbols")
          maplsp("<Leader>cw", "workspace_symbol", "Workspace Symbols")
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
      require("mason").setup({
        ui = {
          border = "rounded",
        }
      })
      require("mason-lspconfig").setup()
      require("mason-lspconfig").setup_handlers({
        function (server_name)
          local server = servers[server_name] or {}
          server.capabilities = require("blink.cmp").get_lsp_capabilities(server.capabilities)
          require("lspconfig")[server_name].setup(server)
        end,
      })
    end
  }
}

-- vim:ts=2:sts=2:sw=2:et
