-- Description -----------------------------------------------------------------------------
--
-- Configuration of plugins related to Markdown files.
--
-- -----------------------------------------------------------------------------------------

MiniMisc.on_filetype(
  "markdown",
  function()
    vim.pack.add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })
  end
)
