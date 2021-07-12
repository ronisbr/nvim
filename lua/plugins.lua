local execute = vim.api.nvim_command
local fn = vim.fn

-- Check if `packer` exists. If not, install it as a start plugin.
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

-- Auto compile when there are changes in `plugins.lua`.
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile'

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'GoldsteinE/compe-latex-symbols'
  use 'JuliaEditorSupport/julia-vim'
  use 'SirVer/ultisnips'
  use 'Th3Whit3Wolf/one-nvim'
  use 'dstein64/nvim-scrollview'
  use 'folke/todo-comments.nvim'
  use 'glepnir/dashboard-nvim'
  use 'glepnir/galaxyline.nvim'
  use 'honza/vim-snippets'
  use 'hrsh7th/nvim-compe'
  use 'junegunn/vim-easy-align'
  use 'kyazdani42/nvim-tree.lua'
  use 'kyazdani42/nvim-web-devicons'
  use 'lervag/vimtex'
  use 'lewis6991/gitsigns.nvim'
  use 'liuchengxu/vim-which-key'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'mbbill/undotree'
  use 'ntpeters/vim-better-whitespace'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'phaazon/hop.nvim'
  use 'romgrk/barbar.nvim'
  use 'terrortylor/nvim-comment'
  use 'tpope/vim-fugitive'
  use 'voldikss/vim-floaterm'

end)
