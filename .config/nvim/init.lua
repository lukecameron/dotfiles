-- based on:
--   https://oroques.dev/notes/neovim-init/
--   https://github.com/ojroques/dotfiles/blob/master/nvim/init.lua
--   my old .vimrc file

-- helpers
local opt = vim.opt

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- BOOTSTRAP PACKER (new installations only)
local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

-- DEFINE PACKER PACKAGES
require('packer').startup(function() 
  -- allow packer upgrades using packer itself
  use 'wbthomason/packer.nvim' -- allows packer upgrades

  -- colours: this is a lua neovim specific port of nord
  use 'shaunsingh/nord.nvim' -- nvim specific fork of nord (colours)

  -- unix-style commands like :Rename
  use 'tpope/vim-eunuch'

  -- better parsing and highlighting: needs neovim >= 0.5
  use 'nvim-treesitter/nvim-treesitter'

  -- LSP support: needs neovim >= 0.5
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-compe'

  -- status line
  use 'Avimitin/nerd-galaxyline'
  use {
    'glepnir/galaxyline.nvim',
    branch = 'main',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- bufferline
  use {
    'akinsho/nvim-bufferline.lua',
    requires = 'kyazdani42/nvim-web-devicons'
  }

  -- fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }

  -- I use this for project grep
  use '/opt/homebrew/opt/fzf'
  use 'junegunn/fzf.vim'

end)
-- :PackerUpdate updates/installs new plugins. :PackerSync does same and removes unused

-- COMPLETION
vim.o.completeopt = "menuone,noselect"

-- TREE-SITTER CONFIG
local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}}

-- LSP SERVER CONFIG
require('lspconfig').ccls.setup {
  init_options = {
    compilationDatabaseDirectory = "build";
    index = {
      threads = 0;
    };
    clang = {
      excludeArgs = { "-frounding-math"} ;
    };
  }
}

-- telescope setup (fuzzy finder / grepper on C-p C-o)
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      },
      n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous
      }
    }
  }
}

-- fzf/ripgrep setup
vim.api.nvim_command('source ~/.config/nvim/fzf-ripgrep.nvim')

-- INDENTING
local indent = 2;
opt.expandtab = true
opt.shiftwidth = indent
opt.tabstop = indent
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.shiftround = true

-- DISPLAY (many taken from tpope/vim-sensible)
opt.number = true
opt.relativenumber = true
opt.list = true
opt.mouse = 'a'
opt.scrolloff = 4
opt.termguicolors = true
opt.laststatus = 2 -- always show status line
require('nord').set()
require('bufferline').setup{}

-- FILE HANDLING
opt.encoding = 'utf-8'

-- BUFFER HANDLING
opt.hidden = true

-- CLIPBOARD
opt.clipboard = 'unnamed'

-- MAPPINGS
vim.g.mapleader = " "

-- reselect lines when changing indentation
map('v', '<', '<gv')
map('v', '>', '>gv')

-- navigate left/right through buffers
map('n', '<C-h>', ':bp<CR>') -- previous buffer
map('n', '<C-l>', ':bn<CR>') -- next buffer

-- close current buffer with leader-w
map('n', '<leader>w', ':bd<CR>')

-- directional window movements with leader-hjkl
map('n', '<leader>h', ':wincmd h<CR>')
map('n', '<leader>j', ':wincmd j<CR>')
map('n', '<leader>k', ':wincmd k<CR>')
map('n', '<leader>l', ':wincmd l<CR>')

-- fuzzy find, grep etc
map('n', '<C-p>', ':Telescope find_files<CR>')
map('n', '<C-o>', ':Telescope live_grep<CR>')









