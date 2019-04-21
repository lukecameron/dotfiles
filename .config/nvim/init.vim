call plug#begin('~/.nvim/plugged')

Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'

call plug#end()

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
