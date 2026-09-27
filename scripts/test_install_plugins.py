#!/usr/bin/env python3

import subprocess
import json
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
INSTALLER = ROOT / "scripts/install_plugins"


class InstallPluginsTest(unittest.TestCase):
    def test_opencode_sync_preserves_existing_config_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as directory:
            config = Path(directory) / "opencode.json"
            original = {
                "$schema": "https://opencode.ai/config.json",
                "plugin": ["existing-plugin", "@openviking/opencode-plugin"],
                "mcp": {"existing": {"type": "remote", "url": "https://example.com/mcp"}},
            }
            config.write_text(json.dumps(original))
            command = ["python3", str(INSTALLER), "--opencode-only", "--opencode-config", str(config)]

            subprocess.run(command, check=True, capture_output=True, text=True)
            first = json.loads(config.read_text())
            self.assertEqual(first["plugin"], original["plugin"])
            self.assertEqual(first["plugins"], [str(ROOT / "scripts/opencode_ponytail")])
            self.assertEqual(first["mcp"], original["mcp"])

            subprocess.run(command, check=True, capture_output=True, text=True)
            self.assertEqual(json.loads(config.read_text()), first)

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
        self.assertIn("OpenCode plugins", result.stdout)
        self.assertIn(str(ROOT / "scripts/opencode_ponytail"), result.stdout)
        self.assertIn("plugins sync complete", result.stdout)

    def test_registry_uses_separate_agent_entries(self):
        result = subprocess.run(
            ["chezmoi", "--source", str(ROOT), "execute-template", "{{ .plugins | toJson }}"],
            check=True, capture_output=True, text=True,
        )
        entries = json.loads(result.stdout)
        self.assertEqual([entry["agent"] for entry in entries], ["codex", "codex", "opencode", "opencode"])
        self.assertTrue(all("opencode" not in entry for entry in entries))
        self.assertTrue(all("marketplace" not in entry for entry in entries if entry["agent"] == "opencode"))


if __name__ == "__main__":
    unittest.main()
