#!/usr/bin/env python3
"""Metadata-only preflight for first apply; refuses all existing targets."""
import argparse
from pathlib import Path
import stat
import sys

TARGETS = ('.zshenv', '.zprofile', '.zshrc', '.config/starship.toml')


def require_absent(home, uid, gid, parent_uid, parent_gid):
    for path, owner, group, mode in (
        (home.parent, parent_uid, parent_gid, None),
        (home, uid, gid, 0o750),
        (home / '.config', uid, gid, 0o700),
    ):
        metadata = path.lstat()
        if not stat.S_ISDIR(metadata.st_mode):
            raise ValueError('Parent is not a real directory: ' + str(path))
        if metadata.st_uid != owner or metadata.st_gid != group:
            raise ValueError('Unexpected parent ownership: ' + str(path))
        permissions = stat.S_IMODE(metadata.st_mode)
        if (mode is not None and permissions != mode) or permissions & 0o022:
            raise ValueError('Unexpected parent permissions: ' + str(path))
    for name in TARGETS:
        path = home / name
        try:
            path.lstat()
        except FileNotFoundError:
            continue
        raise ValueError('Refusing existing target (including symlink): ' + str(path))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('home', type=Path)
    parser.add_argument('--uid', type=int, default=3000)
    parser.add_argument('--gid', type=int, default=3000)
    parser.add_argument('--parent-uid', type=int, default=0)
    parser.add_argument('--parent-gid', type=int, default=0)
    args = parser.parse_args()
    try:
        require_absent(args.home, args.uid, args.gid, args.parent_uid, args.parent_gid)
    except (OSError, ValueError) as error:
        sys.exit(str(error))
