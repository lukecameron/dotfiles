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


" vim-airline
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '¦'
let g:airline#extensions#tabline#buffer_idx_mode = 1

" Training wheels (show open buffers across top)
let g:airline#extensions#tabline#enabled = 1
