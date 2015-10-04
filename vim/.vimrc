execute pathogen#infect()

syntax enable
let g:solarized_termcolors=16
let g:solarized_termtrans = 1
set background=dark
set number
colorscheme solarized

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
