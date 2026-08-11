# Dotfiles

Personal macOS development environment, managed with [chezmoi](https://www.chezmoi.io/).

The configuration currently targets Apple Silicon Macs. Linux support can be added when it is needed. The pre-Chezmoi configuration is retained in Git under the `legacy-2026-08-05` tag.

## New machine

Run:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install chezmoi
chezmoi init --apply lukecameron
```

Chezmoi asks whether the machine is `personal` or `work` and which short name (`m1-air` or `mitti-air`) to show in the prompt. The short name defaults to `m1-air` for personal machines and `mitti-air` for work machines. Packages are shared by default, with additive role-specific sections in `Brewfile.tmpl`.

Authentication and secrets remain machine-local. Sign in to 1Password, the coding harnesses, and any other services after setup.

## Everyday use

```sh
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
chezmoi update
```

Homebrew setup installs missing packages but deliberately does not remove anything else. Run `brew upgrade` when you want to update Homebrew-managed tools.

Node's latest LTS release and Pi are installed by mise. Python runtimes and environments are installed on demand by uv.

LazyVim installs its plugins the first time `nvim` starts. Commit `~/.config/nvim/lazy-lock.json` through chezmoi whenever plugin versions change.

## Local configuration

Use `~/.zprofile.local` and `~/.zshrc.local` for machine-only shell configuration. These files are intentionally unmanaged.

Codex's `config.toml` is a create-only seed. Chezmoi supplies initial defaults on a new machine, then leaves the file untouched so Codex can persist session settings locally without creating dotfile drift.
