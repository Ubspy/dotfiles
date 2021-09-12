" Auto install the vim-plug package manager
if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	"autocmd VimEnter * PlugInstall
	"autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

" Start the package manager
call plug#begin('~/.config/nvim/autoload/plugged')
	" Tree based file explorer
	Plug 'scrooloose/nerdTree'                  |
        \ Plug 'Xuyuanp/nerdtree-git-plugin'    | " Git integration
        \ Plug 'ryanoasis/vim-devicons'         | " NERDTree icons
        \ Plug 'scrooloose/nerdtree-project-plugin'

	" Language server package 
	Plug 'sheerun/vim-polyglot'
	Plug 'neovim/nvim-lspconfig'

    " Auto complete plugins
    Plug 'hrsh7th/nvim-cmp' 
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'

    " Snipper engine
    Plug 'hrsh7th/vim-vsnip'

    " Warning lightbulb
	Plug 'kosayoda/nvim-lightbulb'

	" Tree-sitter syntax highlighting
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

	" Emmet for HTML
	Plug 'mattn/emmet-vim'
	
	" Quote and parenthesis support
	Plug 'tpope/vim-surround'
	Plug 'jiangmiao/auto-pairs'

	" Easy alignment
	Plug 'junegunn/vim-easy-align'

	" Git integration
	Plug 'airblade/vim-gitgutter'

    " Color schemes
    Plug 'joshdick/onedark.vim'
    Plug 'tomasr/molokai'
    Plug 'rakr/vim-one'
    Plug 'ayu-theme/ayu-vim'
    Plug 'ghifarit53/tokyonight-vim'
    Plug 'jaredgorski/SpaceCamp'

    " Icons
    Plug 'ryanoasis/vim-devicons'

call plug#end()

" Start NERDTree and keep it on the side
autocmd VimEnter * NERDTree

" Start the light-bulb plugin
autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
