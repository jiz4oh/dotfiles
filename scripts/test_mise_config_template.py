#!/usr/bin/env python3

import json
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = ROOT / "chezmoi/dot_config/mise/config.toml.tmpl"


def render(os_name: str, os_id: str) -> str:
    data = {"chezmoi": {"os": os_name, "osRelease": {"id": os_id}}}
    return subprocess.run(
        [
            "chezmoi",
            "--source",
            str(ROOT),
            "execute-template",
            "--override-data",
            json.dumps(data),
        ],
        check=True,
        input=TEMPLATE.read_text(),
        capture_output=True,
        text=True,
    ).stdout


class MiseConfigTemplateTest(unittest.TestCase):
    def test_macos_keeps_mise_managed_tools(self) -> None:
        config = render("darwin", "darwin")

        for declaration in (
            'bat = "latest"',
            '"github:sharkdp/fd" = "latest"',
            'neovim = "latest"',
            'rg = "latest"',
            'usage = "latest"',
        ):
            self.assertIn(declaration, config)

        self.assertNotIn('codex = "latest"', config)

    def test_omarchy_uses_pacman_tools_and_keeps_codex(self) -> None:
        config = render("linux", "omarchy")

        for declaration in (
            'bat = "latest"',
            '"github:sharkdp/fd" = "latest"',
            'neovim = "latest"',
            'rg = "latest"',
            'usage = "latest"',
        ):
            self.assertNotIn(declaration, config)

        self.assertIn('codex = "latest"', config)


if __name__ == "__main__":
    unittest.main()
