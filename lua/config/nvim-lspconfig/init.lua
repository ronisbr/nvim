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

-- To use Julia LSP, execute the following command:
--     julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")

nvim_lsp['julials'].setup({ })

-- =============================================================================
--                                    C++
-- =============================================================================

-- To use C++ LSP, the software `ccls` must be installed.
nvim_lsp['ccls'].setup({ })
