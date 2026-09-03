#!/usr/bin/env python3

import json
import subprocess
import tempfile
import unittest
from pathlib import Path

import install_agent_memory_hooks as installer


ROOT = Path(__file__).resolve().parent.parent
HOOK = ROOT / "chezmoi/dot_agents/hooks/executable_agents-memory"


class InstallerTest(unittest.TestCase):
    def test_preserves_existing_hooks_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            codex = home / ".codex/hooks.json"
            claude = home / ".claude/settings.json"
            gemini = home / ".gemini/settings.json"
            for path in (codex, claude, gemini):
                path.parent.mkdir(parents=True)

            existing = {
                "hooks": {
                    "SessionStart": [
                        {"hooks": [{"type": "command", "command": "existing-hook"}]}
                    ],
                    "Stop": [
                        {
                            "hooks": [
                                {
                                    "type": "command",
                                    "command": "python3 ~/.agents/hooks/agents-memory",
                                }
                            ]
                        }
                    ],
                }
            }
            codex.write_text(json.dumps(existing))
            claude.write_text(json.dumps(existing))

            self.assertEqual(installer.install(home), ["codex", "claude", "gemini"])
            first = {path: path.read_text() for path in (codex, claude, gemini)}
            self.assertEqual(installer.install(home), [])
            self.assertEqual(first, {path: path.read_text() for path in first})

            for path in (codex, claude):
                hooks = json.loads(path.read_text())["hooks"]
                commands = [
                    item["command"]
                    for group in hooks["SessionStart"]
                    for item in group["hooks"]
                ]
                self.assertIn("existing-hook", commands)
                managed = sum(installer.HOOK_MARKER in item for item in commands)
                self.assertEqual(managed, 1)
                self.assertEqual(len(hooks["PostCompact"]), 1)
                self.assertNotIn("Stop", hooks)

            gemini_hooks = json.loads(gemini.read_text())["hooks"]
            self.assertEqual(
                gemini_hooks["BeforeAgent"][0]["hooks"][0]["name"],
                "agents-memory",
            )

    def test_skips_clients_without_a_config_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertEqual(installer.install(Path(directory)), [])


class HookTest(unittest.TestCase):
    def test_emits_shared_additional_context(self):
        result = subprocess.run(
            ["python3", str(HOOK)],
            input=json.dumps({"hook_event_name": "SessionStart"}),
            text=True,
            capture_output=True,
            check=True,
        )
        output = json.loads(result.stdout)
        specific = output["hookSpecificOutput"]
        self.assertEqual(specific["hookEventName"], "SessionStart")
        self.assertIn("$agents-memory", specific["additionalContext"])


if __name__ == "__main__":
    unittest.main()
