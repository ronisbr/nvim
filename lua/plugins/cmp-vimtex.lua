-- Plugin configuration: cmp-vimtex --------------------------------------------------------

return {
  {
    "micangl/cmp-vimtex",
    dependencies = {
      {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
          table.insert(opts.sources, { name = "vimtex" })
        end
      }
    }
  }
}
