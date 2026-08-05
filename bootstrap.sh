#!/bin/sh
set -eu

if [ "$(uname -s)" != "Darwin" ]; then
	echo "This bootstrap currently supports macOS only." >&2
	exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

brew install chezmoi
exec chezmoi init --apply "${DOTFILES_REPO:-lukecameron}"
