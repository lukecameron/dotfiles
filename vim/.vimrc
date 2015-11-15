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

call neobundle#end()
NeoBundleCheck



set background=dark
set t_Co=256
colo hybrid
syntax enable
set number

inoremap jk <ESC>

let mapleader = "\<Space>"

filetype plugin indent on
syntax on
set encoding=utf-8
set laststatus=2
set mouse=a

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

nnoremap ∆ <C-d> " alt-j on os x
nnoremap ˚ <C-u> " alt-k on os x


" vim-airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

