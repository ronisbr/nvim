-- Plugin configuration: nvim-lspconfig ----------------------------------------------------

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
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
        lua_ls = {
          settings = {
            Lua = {
              hint = {
                enable = true,
                paramName = "Enable"
              }
            }
          }
        }
      }
    }
  }
}
