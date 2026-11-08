#!/usr/bin/env python3
"""Dry-run only; pass a reviewed official chezmoi executable. Never uses real HOME."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

source = Path(__file__).resolve().parents[1]
# Source-level regression: residual Homebrew paths must stay Darwin-only.
zshenv = (source / "dot_zshenv").read_text()
brew_block = zshenv[zshenv.index('if [[ $OSTYPE == darwin* ]]; then'):zshenv.index('export NO_MISTAKES_TELEMETRY')]
assert 'unset libpq_bin\nfi' in brew_block
assert not any(path in zshenv.replace(brew_block, "") for path in
               ("/opt/homebrew", "/usr/local/Homebrew", "/usr/local/opt"))
for line in (source / "dot_zshrc").read_text().splitlines():
    if "[[" in line and any(path in line for path in
                             ("/opt/homebrew", "/usr/local/opt", "/usr/local/share/zsh-autosuggestions")):
        assert "$OSTYPE == darwin*" in line, line
assert "brew" not in (source / "dot_zprofile").read_text()
binary = str(Path(sys.argv[1]).resolve())
with tempfile.TemporaryDirectory(prefix="dotfiles-linux-preview-") as tmp:
    root = Path(tmp)
    home = root / "home"
    home.mkdir()
    sentinels = {".codex/config.toml": b"# synthetic private state\n",
                 ".config/nvim/local.lua": b"-- synthetic personal edit\n"}
    for name, content in sentinels.items():
        target = home / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(content)
    config = root / "config.toml"
    config.write_text('[data]\nrole="personal"\nmachineName="marcus"\n')
    env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(root / "config"),
               XDG_DATA_HOME=str(root / "data"), XDG_CACHE_HOME=str(root / "cache"))
    cmd = [binary, "--source", str(source), "--destination", str(home),
           "--config", str(config), "--persistent-state", str(root / "state.boltdb")]
    def run(*args):
        return subprocess.check_output(cmd + list(args), env=env, text=True)
    targets = set(run("managed").splitlines())
    assert targets == {".config", ".config/starship.toml", ".zprofile", ".zshenv", ".zshrc"}, targets
    preview = run("apply", "--dry-run", "--verbose")
    assert "marcus" in preview
    assert "brew bundle" not in preview
    for name, content in sentinels.items():
        assert (home / name).read_bytes() == content
    assert not (home / ".zshrc").exists(), "Dry run wrote a target"
    # Exercise the exact nonverbose administrator flags with preexisting data.
    personal = b"# synthetic selected-file private state\n"
    (home / ".zshrc").write_bytes(personal)
    candidate = subprocess.run(cmd + ["--no-tty", "--error-on-conflict",
                               "--refresh-externals=never", "apply", "--dry-run",
                               "--exclude", "scripts"] +
                              [str(home / name) for name in
                               (".zshenv", ".zprofile", ".zshrc", ".config/starship.toml")],
                              env=env, capture_output=True, text=True)
    assert candidate.returncode in (0, 1), candidate.stderr
    assert personal.decode().strip() not in candidate.stdout + candidate.stderr
    assert (home / ".zshrc").read_bytes() == personal
    print("PASS: Linux targets are shell/prompt only; dry run leaves HOME unchanged")
