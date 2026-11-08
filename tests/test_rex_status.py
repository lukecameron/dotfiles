import copy
import importlib.machinery
import importlib.util
from pathlib import Path
import time
import unittest


loader = importlib.machinery.SourceFileLoader(
    "rex_status", str(Path(__file__).resolve().parents[1] / "experiments/rex-status/rex-status")
)
spec = importlib.util.spec_from_loader(loader.name, loader)
status = importlib.util.module_from_spec(spec)
loader.exec_module(status)


class StatusDisplayTests(unittest.TestCase):
    def setUp(self):
        self.snapshot = {
            "updated_at": time.time(),
            "quota_at": time.time(),
            "quota": {
                "state": {"status": "fresh", "stale": False},
                "windows": [{"id": "weekly", "percentRemaining": 65}],
            },
            "agents": {"total": 3, "working": 1, "blocked": 1, "idle": 1},
            "sessions": 2,
        }

    def test_shows_used_percentage_and_server_agent_counts(self):
        usage, activity = status.status_lines(self.snapshot)
        self.assertIn("35% used", usage)
        self.assertIn("Agents 3", activity)
        self.assertIn("1 working", activity)
        self.assertIn("1 waiting", activity)
        self.assertIn("1 idle", activity)
        self.assertIn("2 sessions", activity)

    def test_zero_remaining_means_fully_used(self):
        self.snapshot["quota"]["windows"][0]["percentRemaining"] = 0
        self.assertIn("100% used", status.status_lines(self.snapshot)[0])

    def test_missing_or_failed_usage_does_not_look_unused(self):
        for quota in (None, {}, {"state": {"status": "error"}}):
            with self.subTest(quota=quota):
                self.snapshot["quota"] = quota
                self.assertIn("unavailable", status.status_lines(self.snapshot)[0])

    def test_stale_usage_is_not_presented_as_current(self):
        for field, value in (("status", "stale"), ("stale", True)):
            with self.subTest(field=field):
                snapshot = copy.deepcopy(self.snapshot)
                snapshot["quota"]["state"][field] = value
                self.assertIn("unavailable", status.status_lines(snapshot)[0])
        self.snapshot["quota_at"] -= 121
        self.assertIn("unavailable", status.status_lines(self.snapshot)[0])

    def test_disconnected_watcher_does_not_show_old_agent_counts(self):
        self.snapshot["updated_at"] -= 31
        lines = status.status_lines(self.snapshot)
        self.assertIn("reconnecting", lines[0])
        self.assertNotIn("Agents 3", " ".join(lines))

    def test_invalid_reset_is_omitted(self):
        self.assertEqual(status.countdown(None), "")
        self.assertEqual(status.countdown("not a timestamp"), "")


if __name__ == "__main__":
    unittest.main()
