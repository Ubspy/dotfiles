source $HOME/.config/nvim/vim-plug/plugins.vim

" Set tab indentation to 4 spaces
set tabstop=4 softtabstop=4 " Soft tab makes them act like spaces so you can navigate through the indent
set shiftwidth=4
set expandtab
set smartindent

" Add line numbers
set number

" Keeps buffers loaded in RAM
set hidden

" No text wrapping to the next line
set nowrap

" Set incremental search
set incsearch

" Set scroll start at 8 lines above or below edge of window
set scrolloff=8

" Add extra column for linting (errors and warnings)
set signcolumn=yes

" Give more space for typing commands
set cmdheight=2

" Set color scheme for vim
colorscheme tokyonight

" Set transparent background for vim
autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE
autocmd vimenter * hi EndOfBuffer guibg=NONE ctermbg=NONE

" Rebind auto complete to ctrl+space
inoremap <C-Space> <C-n>
