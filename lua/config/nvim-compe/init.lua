-- Plugin configuration: nvim-compe
-- ============================================================================

require'compe'.setup {
  enabled = true;
  autocomplete = false;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = true;

  source = {
    path = {kind = "  "},
    buffer = {kind = "  "},
    calc = {kind = "  "},
    nvim_lsp = {kind = "  "},
    nvim_lua = {kind = "  "},
    spell = {kind = "  "},
    tags = false,
    -- snippets_nvim = {kind = "  "},
    ultisnips = {kind = "  "},
    -- treesitter = {kind = "  "},
    emoji = {kind = " ﲃ ", filetypes={"markdown"}},
    -- for emoji press : (idk if that in compe tho)
    latex_symbols = true
  };
}
