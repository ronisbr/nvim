-- Plugin configuration: nvim-lspconfig
-- ============================================================================

local nvim_lsp = require('lspconfig')

-- Do not show virtual text since we are using lspsaga.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false
    }
)

-- Go-to definition in a split window.
local function goto_definition(split_cmd)
  local util = vim.lsp.util
  local log  = require("vim.lsp.log")
  local api  = vim.api

  -- NOTE: This handler is for Neovim 0.5.
  -- For Neovim >= 0.5.1, use `function(_, result, {method = method})`.
  local handler = function(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(method, "No location found")
      return nil
    end

    if split_cmd then
      vim.cmd(split_cmd)
    end

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])

      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command("copen")
        api.nvim_command("wincmd p")
      end
    else
      util.jump_to_location(result)
    end
  end

  return handler
end

vim.lsp.handlers["textDocument/definition"] = goto_definition('split')

-- =============================================================================
--                              UI customization
-- =============================================================================

-- Borders
-- -----------------------------------------------------------------------------

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded"
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "rounded"
  }
)

-- Presentation of the diagnostics
-- -----------------------------------------------------------------------------

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text     = false,
    signs            = true,
    underline        = true,
    update_in_insert = true,
  }
)

-- Gutter
-- -----------------------------------------------------------------------------

local signs = {
  Error = " ",
  Warn  = " ",
  Hint  = " ",
  Info  = " "
}

for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  vim.fn.sign_define(hl, {
    text   = icon,
    texthl = hl,
    numhl  = ""
  })
end

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

nvim_lsp['ccls'].setup({ })

