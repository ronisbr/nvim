-- Description -----------------------------------------------------------------------------
--
-- Configuration of the plugin undotree.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.on_event(
  "BufEnter",
  function()
    vim.pack.add({ "https://github.com/mbbill/undotree" })
  end
)

