" NeoBundle
let g:neobundle#types#git#default_protocol='git'
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shougo/neobundle.vim'

" Bundles
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'bling/vim-airline'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'vim-scripts/Color-Scheme-Explorer'
NeoBundle 'jscappini/material.vim'
NeoBundle 'modess/vim-phpcolors'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'tpope/vim-fireplace'
NeoBundle 'scrooloose/nerdtree'

call neobundle#end()
NeoBundleCheck

set background=dark
set t_Co=256
colo hybrid
syntax enable
set number

inoremap jk <ESC>

let mapleader = "\<Space>"

" code formatting
filetype plugin indent on
set encoding=utf-8
"set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

syntax on
set laststatus=2
set mouse=a

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
nnoremap <Leader>b :bp<CR>
nnoremap <Leader>n :bn<CR>
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

" nicer scrolling using alt and jk/fd
" not sure which I like better yet
nnoremap ∆ <C-d> " alt-j on os x
nnoremap ˚ <C-u> " alt-k on os x
nnoremap ƒ <C-d> " alt-f on os x
nnoremap ∂ <C-u> " alt-d on os x

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

