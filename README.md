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

Chezmoi asks whether the machine is `personal` or `work` and which short name (`m1-air`, `mitti-air`, or `slate-pro`) to show in the prompt. The short name defaults to `m1-air` for personal machines and `mitti-air` for work machines. Packages are shared by default, with additive role-specific sections in `Brewfile.tmpl`.

Authentication and secrets remain machine-local. Sign in to 1Password, the coding harnesses, and any other services after setup.

## Everyday use

```sh
chezmoi edit ~/.zshrc
chezmoi diff
chezmoi apply
chezmoi update
```

Homebrew setup installs missing packages but deliberately does not remove anything else. Run `brew upgrade` when you want to update Homebrew-managed tools.

Node's latest LTS release, Pi, Treehouse, Cloudflare Wrangler, and the AXI command-line tools are installed by mise. They track release channels rather than fixed versions, so any change to `dot_config/mise/config.toml` upgrades all of them to the newest release mise considers eligible; bump its Pi marker to trigger that. No Mistakes uses its official user-local layout so its self-updater and launchd daemon share a stable executable path. Python runtimes and environments are installed on demand by uv.

The Herdr Auto Title plugin names tabs and panes after the Claude Code session title in each one. It is pinned to a known commit, built from source with the Go toolchain mise installs, and installed automatically after Herdr and mise tools are available, together with Herdr's Claude Code integration hook. Herdr only starts plugins when its server starts, so run `herdr server stop` and reopen Herdr after a fresh install.

Herdr's mobile view keeps split panes side by side, which leaves two unreadable half-width panes on a phone. The `herdr-narrow-tabs` launchd agent watches the width of the client in front. While it is 80 columns or narrower, the agent moves the right-hand pane of every two-pane tab into a tab of its own, which the mobile switcher lists under tabs. At 100 columns or wider it moves each pane back at its original split ratio. It logs to `~/Library/Logs/herdr-narrow-tabs.log`.

The Rex status bar is a disabled-by-default experiment, retained in `experiments/rex-status` and excluded from chezmoi deployment. It used a Lua watcher and terminal panes to show Codex weekly usage and agent activity across tabs and sessions. The pane layout and lifecycle overhead made it awkward to use, so it stays disabled pending a native Rex status bar. Applying these dotfiles stops the previously installed watcher, removes its status panes, and removes its installed files. The archived display checks still run with `python3 -m unittest discover -s tests`.

Coding agents on macOS share a headed Chrome Canary with its own profile in `~/Library/Application Support/agent-chrome` and remote debugging on `127.0.0.1:9223`. The zsh functions for `chrome-devtools-axi` and `agent-browser` run `agent-chrome` before browser operations to start it if needed. Help and stop commands leave it closed. Tools invoked by absolute path bypass these functions; run `agent-chrome` first in that case. Sign-ins persist across restarts. You can quit Canary normally. It stays closed until the next browser command, which reconnects to a new browser. Quitting interrupts any browser operation in progress. Claude in Chrome stays off because it drives the stable Chrome profile.

Pi's global settings are merged into its existing file so authentication, sessions, trust decisions, and caches stay machine-local. Existing provider and model selections are preserved; defaults are supplied only when missing. The managed settings keep startup quiet, deliver queued steering and follow-ups together, and pin `pi-web-access` for web research. Pi invokes npm through mise, and its terminal title shows the machine short name plus the current session or directory while it works.

Shared agent guidance is rendered for each supported harness. Reusable cross-agent workflows live in `~/.agents/skills`; this setup includes evidence-backed change review and preregistered evaluation skills.

LazyVim installs its plugins the first time `nvim` starts. Commit `~/.config/nvim/lazy-lock.json` through chezmoi whenever plugin versions change.

## pstack

[pstack](https://github.com/cursor/plugins/tree/main/pstack), Cursor's rigorous-engineering agent skills (`/poteto-mode`, `/how`, `/why`, `/unslop` and the `principle-*` skills), is installed at user level for Claude Code, Codex, Pi and OpenCode from the [backnotprop/pstack](https://github.com/backnotprop/pstack) mirror, which rewrites its Cursor-only instructions for other harnesses. Run `/setup-pstack` once per machine to pick its models. `npx skills update -g -y` takes the mirror's latest; bumping the refresh marker in `run_onchange_after_40-install-pstack.sh.tmpl` reinstalls everywhere.

## Matt Pocock's skills

[mattpocock/skills](https://github.com/mattpocock/skills) (`/ask-matt` lists them) is installed at user level for Claude Code, Codex and Pi by `run_onchange_after_40-install-mattpocock-skills.sh.tmpl`. Run `/setup-matt-pocock-skills` once per repo before using its issue-tracker flows, such as `/to-spec`, `/to-tickets`, `/triage` and `/wayfinder`.

The script names each skill, so a new upstream skill stays out until it is read and added. It leaves out `tdd` and `teach` (pstack has skills with those names), `code-review` (Claude Code has `/code-review`) and `pr` (it fires on every PR body). `software-factory` is also absent, because the skills CLI cannot parse its frontmatter. As a result, `/implement` and `/implement-spec` run without Matt's `tdd`, and in Claude Code they use its `/code-review` for the review step.

Bumping the refresh marker in the script reinstalls from upstream's main branch. `npx skills update -g -y` also updates these skills, along with pstack.

## Claude Code plugins

Work machines get the Datadog plugin from the official marketplace, set to Slate's Datadog site (AU, `ap2`). Sign in once per machine: `/mcp`, select `plugin:datadog:mcp`, then Authenticate.

## Remote shell

Mosh is installed on every machine and runs over Tailscale. On each destination Mac, enable **System Settings → General → Sharing → Remote Login**, then connect using its Tailscale MagicDNS name:

```sh
mosh luke@machine-name
```

The tailnet policy must allow TCP port 22 and UDP ports 60000–61000 from the client to the destination.

## Local configuration

Use `~/.zprofile.local` and `~/.zshrc.local` for machine-only shell configuration. These files are intentionally unmanaged.

Codex's `config.toml` is a create-only seed. Chezmoi supplies initial defaults on a new machine, then leaves the file untouched so Codex can persist session settings locally without creating dotfile drift.
