-- Plugin configuration: nvim-compe
-- ============================================================================

local cmp = require'cmp'
local lspkind = require'lspkind'

cmp.setup({
  completion = {
    autocomplete = false,
  },

  formatting = {
    format = lspkind.cmp_format({
      with_text = false,
      maxwidth = 50,
    })
  },

  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },

  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body)
    end,
  },

  sources = cmp.config.sources({
    { name = 'buffer' },
    { name = 'calc' },
    { name = 'latex_symbols' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'ultisnips' },
  }, {
    { name = 'buffer' }
  })
})
