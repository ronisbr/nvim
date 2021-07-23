-- Plugin configuration: nvim-lspconfig
-- ============================================================================

local nvim_lsp = require('lspconfig')

-- Do not show virtual text since we are using lspsaga.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

-- =============================================================================
--                                   Julia
-- =============================================================================

local julia_cmd = {
  "julia",
  "--startup-file=no",
  "--history-file=no",
  vim.fn.expand("~/.nvim/lua/config/julia/lsp/run.jl")
}

nvim_lsp['julials'].setup({
  cmd = julia_cmd,
  flags = {
    debounce_text_changes = 150,
  },
  filetypes = {'julia'},
  on_new_config = function(new_config, _)
    new_config.cmd = julia_cmd
  end,
})
