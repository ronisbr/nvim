-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin blink.cmp.
--
-- -----------------------------------------------------------------------------------------

return {
  'saghen/blink.cmp',
  lazy = false,
  version = 'v0.*',

  opts = {
    keymap = { preset = "super-tab" },

    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono"
    },

    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer"
      },
    },

    signature = { enabled = true }
  },
}

-- vim:ts=2:sts=2:sw=2:et