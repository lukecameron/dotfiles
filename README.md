### dotfiles

#### setup

- install GNU Stow (`brew install stow` / `apt-get install stow`)
- clone into a directory in home (I use `~/dotfiles`)
- `cd dotfiles`
- `stow <app name>` for any apps you want to configure

`stow` creates symlinks in the parent directory of the working directory by default. it won't overwrite existing files with symlinks, so you'll have to `rm` them or use `--adopt`


#### vim
- for the plugins to work, you'll need to do `git submodule update --init --recursive` to pull the latest of all plugins
