-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to the lensline.nvim plugin.
--
-- -----------------------------------------------------------------------------------------

MiniDeps.later(
  function()
    MiniDeps.add({ source = 'oribarilan/lensline.nvim' })

    require('lensline').setup({
      profiles = {
        {
          name = "default",
          providers = {
            {
              name = "usages",
              enabled = true
            },
            {
              name = "last_author",
              enabled = true
            },
            {
              name = "diagnostics",
              enabled = true,
            },
            {
              name = "complexity",
              enabled = true,
              min_level = "L"
            },
          },
        }
      }
    })
  end
)

-- vim:ts=2:sts=2:sw=2:et
