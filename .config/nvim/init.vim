syntax on                   " Enable syntax highlighting
set number                  " Enable line numbers
set tabstop=4               " Displayed tab char (\t) width is 4
set shiftwidth=4            " Indent (when pressing tab key) width is 4
set expandtab               " Use spaces, not tabs
set undodir=~/.nvim/undodir " Undofile directory
set undofile                " Enable undofiles
set updatetime=300          " Update every 300ms (default is 4s)
set cursorline              " Highlight the line the cursor is on
set relativenumber          " Show relative rather than absolute line numbers
set splitbelow              " Open new splits below, not above
set splitright              " OPen new v-splits to the right, not left

let mapleader = ';' " <leader> key definition

" Change Ctrl-W + HJKL to just Ctrl + HJKL for split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Install VimPlug if it isnt already
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins (courtsey of VimPlug)
call plug#begin()
    Plug 'preservim/nerdtree'                           " NERDTree
    Plug 'sheerun/vim-polyglot'                         " Polyglot (Syntax highlighting for pretty much any lang)
    Plug 'tpope/vim-surround'                           " surround.vim (plugin for parenthesis, quotes, html/xml tags, etc)
    Plug 'neoclide/coc.nvim', {'branch': 'release'}     " CoC code completion
    Plug 'vim-airline/vim-airline'                      " Airline statusline
    Plug 'puremourning/vimspector'                      " Vimspector debugging
    Plug 'wdhg/coc-omnisharp'                           " Apple Silicon-compatible coc-omnisharp fork
    Plug 'morhetz/gruvbox'                              " gruvbox theme
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }      " catppuccin theme
    Plug 'nvim-lua/plenary.nvim'                        " Telescope prereq
    Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' } " Fuzzy finder
    Plug 'nvim-tree/nvim-web-devicons'                  " Filetype icons
call plug#end()

" Activate theme
colorscheme catppuccin-mocha

" Import CoC config
source $HOME/.config/nvim/coc.vim 

" Set keybinds for Vimspector
let g:vimspector_enable_mappings = 'HUMAN'

" Shortcut for Telescope
nnoremap <leader>p :Telescope fd<CR>
