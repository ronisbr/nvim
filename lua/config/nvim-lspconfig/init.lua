-- Plugin configuration: nvim-lspconfig
-- ============================================================================

local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')

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
--     julia --project=~/.julia/environments/nvim-lspconfig
--     ]
--     add CSTParser#master LanguageServer#master StaticLint#master SymbolServer#master
--
-- NOTE: The new configuration of root_dir is not compatible with single file
-- If we use the default configuration of `root_dir`, then we have problems when
-- running Julia LSP using single file mode (without a project).

nvim_lsp.julials.setup({
  root_dir = function(fname)
    return util.find_git_ancestor(fname) or util.path.dirname(fname)
  end,
})

-- =============================================================================
--                                    C++
-- =============================================================================

-- To use C++ LSP, the software `ccls` must be installed.
nvim_lsp.ccls.setup({ })
