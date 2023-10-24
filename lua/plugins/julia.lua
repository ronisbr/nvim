-- Plugin configuration: julia-vim ---------------------------------------------------------

return {
  {
    "JuliaEditorSupport/julia-vim",
    lazy = false,
    config = function()
      vim.g.latex_to_unicode_auto = true
    end
  }
}
