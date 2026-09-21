#!/usr/bin/env python3

import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
INSTALLER = ROOT / "scripts/install_plugins"


class InstallPluginsTest(unittest.TestCase):
    def test_dry_run_reads_repo_registry_and_builds_native_commands(self):
        result = subprocess.run(
            ["python3", str(INSTALLER), "--dry-run"],
            check=True,
            capture_output=True,
            text=True,
        )

        self.assertIn(
            "would run: codex plugin marketplace add "
            "https://github.com/volcengine/OpenViking.git --ref main "
            "--sparse examples/codex-memory-plugin --sparse .agents",
            result.stdout,
        )
        self.assertIn("would run: codex plugin marketplace upgrade openviking", result.stdout)
        self.assertIn("would run: codex plugin add openviking-memory@openviking", result.stdout)
        self.assertIn(
            "would run: codex plugin marketplace add "
            "https://github.com/DietrichGebert/ponytail.git",
            result.stdout,
        )
        self.assertIn("would run: codex plugin add ponytail@ponytail", result.stdout)
        self.assertIn("plugins sync complete", result.stdout)


if __name__ == "__main__":
    unittest.main()
