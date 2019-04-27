
" currently using pathogen for vim and vim-plug for neovim
if !has('nvim')
  execute pathogen#infect()
endif

if has("termguicolors")
  set termguicolors
endif
"let g:hybrid_reduced_contrast = 1
"set t_Co=256
"set background=dark

if !has('nvim')
  colo sol
endif
set number
set relativenumber
set incsearch

let mapleader = "\<Space>"

" code formatting
syntax enable
filetype plugin indent on
set encoding=utf-8
set softtabstop=2
set expandtab
set shiftwidth=2

" fuzzy find
let g:ctrlp_working_path_mode = 0
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" show invisibles
set list!
set listchars=tab:▸\ ,eol:¬
set clipboard=unnamed
set laststatus=2
set mouse=a
set timeoutlen=200 ttimeoutlen=0

" reselect text when changing indentation
vnoremap < <gv
vnoremap > >gv

" clojure
let g:clojure_fuzzy_indent = 1

" reasonml
let g:LanguageClient_serverCommands = {
    \ 'reason': ['/Users/luke/bin/reason-language-server.exe']
    \ }

" kill all bells
" unfortunately there is no way to get iterm2 to use alt key
" the way vim wants to, the only way I found was with
" an esc prefix. This causes a bell sound in normal mode.
"set noerrorbells visualbell t_vb=
"autocmd GUIEnter * set visualbell t_vb=

" allow switching buffers without saving
set hidden

" key mapping
inoremap jk <ESC>
onoremap jk <ESC>
vnoremap jk <ESC>
cnoremap jk <ESC>
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

" for aligning text
nnoremap <Leader>a= :Tabularize /=<CR>
nnoremap <Leader>a: :Tabularize /:<CR>
nnoremap <Leader>a:: :Tabularize /:\zs<CR>
nnoremap <Leader>a, :Tabularize /,<CR>
nnoremap <Leader>a<Bar> :Tabularize /<Bar><CR>

" toggle nerdtree
nnoremap <C-n> :NERDTreeToggle<CR>

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
"let g:airline_powerline_fonts = 1

