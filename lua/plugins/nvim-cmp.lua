-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin nvim-cmp.
--
-- -----------------------------------------------------------------------------------------

return {
  "hrsh7th/nvim-cmp",
  event = { "BufReadPre", "BufNewFile" },
  version = false,

  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "garymjr/nvim-snippets",
  },

  config = function()
    local cmp = require("cmp")

    cmp.setup({
      completion = {
        completopt = "menu,menuone,noinsert"
      },

      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = function(fallback)
          -- Don't block <CR> if signature help is active.
          -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/13
          if not cmp.visible() or
             not cmp.get_selected_entry() or
             cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help' then
            fallback()
          else
            cmp.confirm({
              -- Replace word if completing in the middle of a word.
              -- https://github.com/hrsh7th/nvim-cmp/issues/664
              behavior = cmp.ConfirmBehavior.Replace,
              -- Don't select first item on CR if nothing was selected.
              select = false,
            })
          end
        end,
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          -- If a snippet is active, we need to move to the next its placeholder.
          if vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          -- Otherwise, check if `cmp` window is visible. In this case, we must move to the
          -- next item.
          elseif cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          -- If a snippet is active, we need to move to the next its placeholder.
          if vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          -- Otherwise, check if `cmp` window is visible. In this case, we must move to the
          -- next item.
          elseif cmp.visible() then
            cmp.select_next_item()
          else
            fallback()
          end
        end, { "i", "s" }),

      }),

      performance = {
        debounce = 400
      },

      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "path" },
        { name = "snippets" },
      }, {
        { name = "buffer" }
      })
    })
  end

}

-- vim:ts=2:sts=2:sw=2:et
