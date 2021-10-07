### dotfiles

#### setup
To configure these dotfiles, look at [this article](https://www.atlassian.com/git/tutorials/dotfiles). My alias is `dotfiles` instead of `config` however.

See `.config/fish/aliases.fish` for the `dotfiles` alias. This can be used anywhere in the home directory normally as the `git` command would. For example to add a new file to the repo:

```
dotfiles add .config/some-application/new-file.config
dotfiles status
dotfiles commit -a
dotfiles push
```

#### neovim
- install neovim >= 0.5 (as of writing this was HEAD)
- open it and do :PackerSync


#### homebrew stuff that's needed
```
ccls
cmake
neovim
fd
rg
fish
fzf
```
In particular, `fd` is needed as telescope (fuzzy finder) won't work well in nvim without it. `rg` is same for live grepping.
