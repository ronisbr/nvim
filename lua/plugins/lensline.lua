-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the lensline.nvim plugin.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = 'oribarilan/lensline.nvim' })

    require('lensline').setup({
      providers = {
        {
          name = "references",
          enabled = false,
        },
        {
          name = "last_author",
          enabled = true,
          cache_max_files = 50,
        },
        {
          name = "diagnostics",
          enabled = true,
          min_level = "WARN",
        },
        {
          name = "complexity",
          enabled = true,
          min_level = "L",
        },
      }
    })
  end
)

-- vim:ts=2:sts=2:sw=2:et
