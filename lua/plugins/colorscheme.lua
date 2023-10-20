-- Color scheme configuration --------------------------------------------------------------

return {
	{
		"ronisbr/nano-theme.nvim",
    init = function()
      vim.o.background = "light"
    end
	},
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nano-theme",
    },
  },
}
