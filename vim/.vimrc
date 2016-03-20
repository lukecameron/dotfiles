execute pathogen#infect()

"let g:hybrid_reduced_contrast = 1
set t_Co=256
set background=dark
colo hybrid
set number
set relativenumber

let mapleader = "\<Space>"

" code formatting
syntax enable
filetype plugin indent on
set encoding=utf-8
set softtabstop=2
set expandtab
set shiftwidth=2

set clipboard=unnamed
set laststatus=2
set mouse=a
set timeoutlen=1000 ttimeoutlen=0

" reselect text when changing indentation
vnoremap < <gv
vnoremap > >gv

" clojure
let g:clojure_fuzzy_indent = 1

" kill all bells
" unfortunately there is no way to get iterm2 to use alt key
" the way vim wants to, the only way I found was with
" an esc prefix. This causes a bell sound in normal mode.
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" allow switching buffers without saving
set hidden

" key mapping
inoremap jk <ESC>
nnoremap <Leader>b :bp<CR>
nnoremap <Leader>n :bn<CR>
nnoremap <C-h>     :bp<CR>
nnoremap <C-l>     :bn<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>

" I think I also like scrolling with C-[jk] now I'm using capslock for ctrl
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>

" nicer window movements using leader-hjkl
nnoremap <Leader>j :wincmd j<CR>
nnoremap <Leader>k :wincmd k<CR>
nnoremap <Leader>h :wincmd h<CR>
nnoremap <Leader>l :wincmd l<CR>
 
" close current buffer/window with leader-w/c
nnoremap <Leader>w :bd<CR>
nnoremap <Leader>c :wincmd c<CR>

" use command window for ex mode 
"noremap : q:I

" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

