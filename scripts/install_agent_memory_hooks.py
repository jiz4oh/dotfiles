#!/usr/bin/env python3

import argparse
import json
import os
import shlex
import stat
import tempfile
from pathlib import Path


HOOK_MARKER = ".agents/hooks/agents-memory"


def handler(home, *, gemini=False):
    hook = shlex.quote(str(home / HOOK_MARKER))
    item = {
        "type": "command",
        "command": f"python3 {hook}",
        "timeout": 5_000 if gemini else 5,
    }
    if gemini:
        item.update(
            name="agents-memory",
            description="Load repository memory guidance",
        )
    else:
        item["statusMessage"] = "Loading project memory guidance"
    return item


def desired_hooks(client, home):
    if client == "codex":
        return {
            "SessionStart": [
                {
                    "matcher": "startup|resume|clear|compact",
                    "hooks": [handler(home)],
                }
            ],
            "PostCompact": [{"hooks": [handler(home)]}],
        }
    if client == "claude":
        return {
            "SessionStart": [
                {
                    "matcher": "startup|resume|clear|compact",
                    "hooks": [handler(home)],
                }
            ],
            "PostCompact": [{"hooks": [handler(home)]}],
        }
    if client == "gemini":
        return {"BeforeAgent": [{"hooks": [handler(home, gemini=True)]}]}
    raise ValueError(f"unsupported client: {client}")


def managed(item):
    return HOOK_MARKER in item.get("command", "")


def merge_hooks(document, additions):
    hooks = document.setdefault("hooks", {})
    for event, event_groups in list(hooks.items()):
        groups = []
        for group in event_groups:
            remaining = [item for item in group.get("hooks", []) if not managed(item)]
            if remaining:
                groups.append({**group, "hooks": remaining})
        if groups:
            hooks[event] = groups
        else:
            hooks.pop(event)
    for event, desired_groups in additions.items():
        hooks[event] = hooks.get(event, []) + desired_groups
    return document


def write_json(path, document):
    content = json.dumps(document, indent=2, ensure_ascii=False) + "\n"
    if path.exists() and path.read_text() == content:
        return False

    path.parent.mkdir(parents=True, exist_ok=True)
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o600
    with tempfile.NamedTemporaryFile(
        "w", dir=path.parent, prefix=f".{path.name}.", delete=False
    ) as stream:
        stream.write(content)
        temp_path = Path(stream.name)
    os.chmod(temp_path, mode)
    os.replace(temp_path, path)
    return True


def install(home):
    targets = {
        "codex": home / ".codex" / "hooks.json",
        "claude": home / ".claude" / "settings.json",
        "gemini": home / ".gemini" / "settings.json",
    }
    changed = []
    for client, path in targets.items():
        if not path.parent.is_dir():
            continue
        document = json.loads(path.read_text()) if path.exists() else {}
        if write_json(path, merge_hooks(document, desired_hooks(client, home))):
            changed.append(client)
    return changed


def main():
    parser = argparse.ArgumentParser(
        description="Merge agents-memory hooks into installed agent clients."
    )
    parser.add_argument("--home", type=Path, default=Path.home())
    args = parser.parse_args()

    changed = install(args.home.expanduser().resolve())
    if changed:
        print(f"agents-memory hooks updated: {', '.join(changed)}")


if __name__ == "__main__":
    main()
