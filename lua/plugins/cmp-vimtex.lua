-- Plugin configuration: cmp-vimtex --------------------------------------------------------

return {
  {
    "micangl/cmp-vimtex"
  },

  {
    "hrsh7th/nvim-cmp",
    dependency = { "micangl/cmp-vimtex" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "vimtex" })
    end
  }
}
