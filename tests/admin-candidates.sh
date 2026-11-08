#!/usr/bin/env bash
# REVIEW CANDIDATE: run locally as Luke using an immutable reviewed source.
# Usage: bash --noprofile --norc tests/admin-candidates.sh preview|apply
# Set review_dir (Luke-owned, outside home), reviewed_source and chezmoi_binary.
# review_dir/config.toml must contain only [data], role="personal", machineName="marcus".
set -euo pipefail
: "${review_dir:?Set the Luke-owned disposable review directory}"
: "${reviewed_source:?Set the immutable reviewed source snapshot}"
: "${chezmoi_binary:?Set the checksum-verified official executable}"
[[ $(id -u) = 3000 && $(id -g) = 3000 && $HOME = /home/luke ]] || exit 1
case ${1:-} in preview|apply) mode=$1 ;; *) exit 2 ;; esac
cm=("$chezmoi_binary" --source "$reviewed_source" --destination /home/luke
    --config "$review_dir/config.toml" --cache "$review_dir/cache"
    --persistent-state "$review_dir/state.boltdb" --no-tty
    --error-on-conflict --refresh-externals=never)
targets=(/home/luke/.zshenv /home/luke/.zprofile /home/luke/.zshrc
         /home/luke/.config/starship.toml)
# Only print target names. The exact list is independently tested in linux-preview.py.
"${cm[@]}" managed
# Recheck immediately before EACH preview/apply, not only during earlier inspection.
# lstat refuses files, directories, live/dangling symlinks and unreadable metadata.
# Existing targets require a separate backed-up/reviewed merge procedure; no override.
python3 "$reviewed_source/tests/selected-targets-absent.py" /home/luke
if [[ $mode = preview ]]; then
    "${cm[@]}" apply --dry-run --exclude scripts "${targets[@]}"
else
    "${cm[@]}" apply --exclude scripts "${targets[@]}"
fi
