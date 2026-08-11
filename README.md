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

Node's latest LTS release, Pi, Treehouse, and the AXI command-line tools are installed by mise. No Mistakes uses its official user-local layout so its self-updater and launchd daemon share a stable executable path. Python runtimes and environments are installed on demand by uv.

Bun is installed by Homebrew for Herdr plugins so long-lived Herdr servers have a stable runtime path. The managed `rjyo/herdr-window-title-sync` plugin publishes the focused Herdr workspace, tab, and agent session through the outer terminal title so Moshi can identify resumed sessions; its local-session fallback can include recent Codex or Claude prompt text in that title.

Pi's global settings are merged into its existing file so authentication, sessions, trust decisions, and caches stay machine-local. The managed settings keep startup quiet, deliver queued steering and follow-ups together, and pin `pi-web-access` for web research. Pi invokes npm through mise, and its terminal title shows the machine short name plus the current session or directory while it works.

LazyVim installs its plugins the first time `nvim` starts. Commit `~/.config/nvim/lazy-lock.json` through chezmoi whenever plugin versions change.

## Remote shell

Mosh is installed on every machine and runs over Tailscale. On each destination Mac, enable **System Settings → General → Sharing → Remote Login**, then connect using its Tailscale MagicDNS name:

```sh
mosh luke@machine-name
```

The tailnet policy must allow TCP port 22 and UDP ports 60000–61000 from the client to the destination.

`moshi-hook` is installed from the trusted `rjyo/moshi` tap and registered as a per-user service. Its pairing token and generated agent-hook configuration remain machine-local.

## Local configuration

Use `~/.zprofile.local` and `~/.zshrc.local` for machine-only shell configuration. These files are intentionally unmanaged.

Codex's `config.toml` is a create-only seed. Chezmoi supplies initial defaults on a new machine, then leaves the file untouched so Codex can persist session settings locally without creating dotfile drift.
