#!/usr/bin/env python3
"""Disposable metadata fixtures only; never accesses the resident home."""
import importlib.util
import os
from pathlib import Path
import sys
import subprocess
import tempfile
import unittest

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('guard', Path(__file__).with_name('selected-targets-absent.py'))
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)


class AbsenceGuardTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='selected-target-guard-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / 'home'
        self.home.mkdir(mode=0o750)
        self.home.chmod(0o750)
        (self.home / '.config').mkdir(mode=0o700)
        self.uid, self.gid = os.getuid(), os.getgid()

    def check(self):
        guard.require_absent(self.home, self.uid, self.gid, self.uid, self.gid)

    def test_all_absent_allowed(self):
        self.check()

    def test_every_existing_target_refused(self):
        for name in guard.TARGETS:
            target = self.home / name
            for kind in ('file', 'directory', 'symlink', 'dangling'):
                with self.subTest(target=name, kind=kind):
                    if kind == 'file':
                        target.write_bytes(b'private sentinel')
                    elif kind == 'directory':
                        target.mkdir()
                    else:
                        target.symlink_to(self.home / '.config' if kind == 'symlink' else self.home / 'missing')
                    with self.assertRaisesRegex(ValueError, 'Refusing existing target'):
                        self.check()
                    # Refusal happens before any apply; existing data is untouched.
                    if kind == 'file':
                        self.assertEqual(target.read_bytes(), b'private sentinel')
                    if kind == 'directory':
                        target.rmdir()
                    else:
                        target.unlink()

    def test_cli_refuses_preexisting_unmanaged_file(self):
        target = self.home / '.zshrc'
        target.write_bytes(b'private sentinel')
        result = subprocess.run([sys.executable, str(Path(__file__).with_name('selected-targets-absent.py')),
                                 str(self.home), '--uid', str(self.uid), '--gid', str(self.gid),
                                 '--parent-uid', str(self.uid), '--parent-gid', str(self.gid)],
                                capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Refusing existing target', result.stderr)
        self.assertNotIn('private sentinel', result.stdout + result.stderr)
        self.assertEqual(target.read_bytes(), b'private sentinel')

    def test_parent_modes_refused(self):
        for target, unsafe, original in ((self.home, 0o755, 0o750),
                                         (self.home / '.config', 0o750, 0o700),
                                         (self.root, 0o777, 0o700)):
            target.chmod(unsafe)
            with self.assertRaisesRegex(ValueError, 'permissions'):
                self.check()
            target.chmod(original)

    def test_unexpected_ownership_refused(self):
        with self.assertRaisesRegex(ValueError, 'ownership'):
            guard.require_absent(self.home, self.uid + 1, self.gid, self.uid, self.gid)

    def test_symlink_config_refused(self):
        config = self.home / '.config'
        config.rmdir()
        config.symlink_to(self.root)
        with self.assertRaisesRegex(ValueError, 'not a real directory'):
            self.check()

    def test_symlink_home_refused(self):
        alias = self.root / 'alias'
        alias.symlink_to(self.home)
        with self.assertRaisesRegex(ValueError, 'not a real directory'):
            guard.require_absent(alias, self.uid, self.gid, self.uid, self.gid)


if __name__ == '__main__':
    unittest.main()
