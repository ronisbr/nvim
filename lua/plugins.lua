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
  use 'JuliaEditorSupport/julia-vim'
  use 'NTBBloodbath/galaxyline.nvim'
  use 'SirVer/ultisnips'
  use 'Th3Whit3Wolf/one-nvim'
  use 'dstein64/nvim-scrollview'
  use 'folke/todo-comments.nvim'
  use 'folke/which-key.nvim'
  use 'glepnir/dashboard-nvim'
  use 'kdheepak/cmp-latex-symbols'
  use 'honza/vim-snippets'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-calc'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/nvim-cmp'
  use 'junegunn/vim-easy-align'
  use 'kyazdani42/nvim-tree.lua'
  use 'kyazdani42/nvim-web-devicons'
  use 'lervag/vimtex'
  use 'lewis6991/gitsigns.nvim'
  use 'lukas-reineke/indent-blankline.nvim'
  use 'mbbill/undotree'
  use 'neovim/nvim-lspconfig'
  use 'ntpeters/vim-better-whitespace'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-lua/popup.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'onsails/lspkind-nvim'
  use 'phaazon/hop.nvim'
  use 'quangnguyen30192/cmp-nvim-ultisnips'
  use 'romgrk/barbar.nvim'
  use 'tami5/lspsaga.nvim'
  use 'terrortylor/nvim-comment'
  use 'tpope/vim-fugitive'
  use 'voldikss/vim-floaterm'
end)
