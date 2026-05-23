#!/usr/bin/env python3

import argparse
import glob
import json
import os
from collections import Counter


IGNORE_DIRS = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    ".next",
    ".turbo",
    ".yarn",
    ".pnpm-store",
    "dist",
    "build",
    "coverage",
    ".venv",
    "venv",
    "__pycache__",
    "target",
    "vendor",
}

LANGUAGE_EXTENSIONS = {
    ".js": "JavaScript",
    ".cjs": "JavaScript",
    ".mjs": "JavaScript",
    ".ts": "TypeScript",
    ".tsx": "TypeScript",
    ".jsx": "JavaScript",
    ".py": "Python",
    ".rb": "Ruby",
    ".go": "Go",
    ".rs": "Rust",
    ".java": "Java",
    ".kt": "Kotlin",
    ".swift": "Swift",
    ".php": "PHP",
    ".cs": "C#",
    ".scala": "Scala",
    ".sh": "Shell",
}

LANGUAGE_MARKERS = {
    "TypeScript": ["tsconfig.json"],
    "Python": ["pyproject.toml", "requirements.txt", "setup.py", "uv.lock", "poetry.lock"],
    "Ruby": ["Gemfile"],
    "Go": ["go.mod"],
    "Rust": ["Cargo.toml"],
    "Java": ["pom.xml", "build.gradle", "build.gradle.kts"],
    "Swift": ["Package.swift"],
    "PHP": ["composer.json"],
    "C#": [".sln"],
}

PACKAGE_MANAGER_MARKERS = {
    "pnpm": ["pnpm-lock.yaml", "pnpm-workspace.yaml"],
    "npm": ["package-lock.json"],
    "yarn": ["yarn.lock"],
    "bun": ["bun.lockb", "bun.lock"],
    "pip": ["requirements.txt"],
    "poetry": ["poetry.lock"],
    "uv": ["uv.lock"],
    "bundler": ["Gemfile.lock"],
    "cargo": ["Cargo.lock"],
    "go": ["go.sum"],
}

TEST_MARKERS = {
    "pytest": ["pytest.ini", "conftest.py", "tox.ini"],
    "vitest": ["vitest.config.ts", "vitest.config.js", "vite.config.ts", "vite.config.js"],
    "jest": ["jest.config.js", "jest.config.ts"],
    "playwright": ["playwright.config.ts", "playwright.config.js"],
    "cypress": ["cypress.config.ts", "cypress.config.js"],
    "rspec": [".rspec"],
    "go test": ["go.mod"],
    "cargo test": ["Cargo.toml"],
}

TOOLING_CONFIG_MARKERS = {
    "eslint": [
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
    ],
    "biome": ["biome.json", "biome.jsonc"],
    "prettier": [
        ".prettierrc",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.json",
        "prettier.config.js",
        "prettier.config.cjs",
    ],
    "ruff": ["ruff.toml", ".ruff.toml", "pyproject.toml"],
    "mypy": ["mypy.ini", ".mypy.ini", "pyproject.toml"],
    "pyright": ["pyrightconfig.json"],
    "rubocop": [".rubocop.yml"],
    "commitlint": [
        "commitlint.config.js",
        "commitlint.config.cjs",
        ".commitlintrc",
        ".commitlintrc.json",
    ],
}

MIGRATION_DIR_NAMES = [
    "migrations",
    "db/migrate",
    "db/migrations",
    "prisma/migrations",
    "alembic",
    "flyway",
    "goose",
]

PUBLIC_API_MARKERS = [
    "src/index.ts",
    "src/index.tsx",
    "src/index.js",
    "src/index.jsx",
    "src/lib.rs",
    "lib.rs",
    "__init__.py",
]

INTERVIEW_TOPIC_LABELS = {
    "migration_policy": "迁移策略",
    "commit_style": "提交风格",
    "testing_policy": "测试策略",
    "public_api_policy": "公共 API 策略",
    "monorepo_policy": "Monorepo 归属策略",
    "agents_update_policy": "AGENTS 更新策略",
}

TASK_LABELS = {
    "lint": "Lint",
    "test": "测试",
    "typecheck": "类型检查",
}

PROJECT_TYPE_LABELS = {
    "application": "应用",
    "library": "类库",
    "monorepo": "Monorepo",
}


def rel(root, path):
    return os.path.relpath(path, root)


def read_text(path):
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return handle.read()
    except (OSError, UnicodeDecodeError):
        return ""


def read_json(path):
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except (OSError, UnicodeDecodeError, json.JSONDecodeError):
        return None


def collect_files(root, max_files):
    collected = []
    for current_root, dirnames, filenames in os.walk(root):
        dirnames[:] = [name for name in dirnames if name not in IGNORE_DIRS]
        for filename in filenames:
            collected.append(os.path.join(current_root, filename))
            if len(collected) >= max_files:
                return collected
    return collected


def add_signal(signals, name, evidence):
    if evidence:
        signals.append({"name": name, "evidence": sorted(set(evidence))})


def detect_package_managers(root):
    signals = []
    for manager, markers in PACKAGE_MANAGER_MARKERS.items():
        evidence = []
        for marker in markers:
            if os.path.exists(os.path.join(root, marker)):
                evidence.append(marker)
        add_signal(signals, manager, evidence)
    return signals


def signal_names(signals):
    return [signal["name"] for signal in signals]


def select_js_runner(package_managers):
    names = signal_names(package_managers)
    if "pnpm" in names:
        return "pnpm exec"
    if "yarn" in names:
        return "yarn"
    if "bun" in names:
        return "bunx"
    if "npm" in names:
        return "npx"
    return None


def select_python_runner(package_managers):
    names = signal_names(package_managers)
    if "uv" in names:
        return "uv run"
    if "poetry" in names:
        return "poetry run"
    return "python -m"


def detect_languages(root, files):
    evidence = {}
    counts = Counter()

    for language, markers in LANGUAGE_MARKERS.items():
        for marker in markers:
            if marker.startswith("."):
                matches = glob.glob(os.path.join(root, "*" + marker))
                if matches:
                    evidence.setdefault(language, []).append(rel(root, matches[0]))
            elif os.path.exists(os.path.join(root, marker)):
                evidence.setdefault(language, []).append(marker)

    for path in files:
        _, extension = os.path.splitext(path)
        language = LANGUAGE_EXTENSIONS.get(extension.lower())
        if language:
            counts[language] += 1

    signals = []
    for language in sorted(set(list(evidence.keys()) + list(counts.keys()))):
        marker_evidence = evidence.get(language, [])
        count = counts.get(language, 0)
        entry = {"name": language}
        if marker_evidence:
            entry["evidence"] = sorted(set(marker_evidence))
        if count:
            entry["file_count"] = count
        signals.append(entry)
    return signals


def parse_workspace_globs(root):
    globs_found = []

    package_json = read_json(os.path.join(root, "package.json"))
    if isinstance(package_json, dict):
        workspaces = package_json.get("workspaces")
        if isinstance(workspaces, list):
            globs_found.extend([item for item in workspaces if isinstance(item, str)])
        elif isinstance(workspaces, dict):
            packages = workspaces.get("packages")
            if isinstance(packages, list):
                globs_found.extend([item for item in packages if isinstance(item, str)])

    pnpm_workspace = read_text(os.path.join(root, "pnpm-workspace.yaml"))
    in_packages_block = False
    for raw_line in pnpm_workspace.splitlines():
        line = raw_line.strip()
        if line == "packages:":
            in_packages_block = True
            continue
        if in_packages_block and line.startswith("- "):
            globs_found.append(line[2:].strip().strip("'\""))
            continue
        if in_packages_block and line and not line.startswith("#"):
            in_packages_block = False

    return sorted(set([item for item in globs_found if item]))


def expand_workspace_members(root, workspace_globs):
    members = []
    for pattern in workspace_globs:
        absolute_pattern = os.path.join(root, pattern)
        for match in glob.glob(absolute_pattern):
            if os.path.isdir(match):
                members.append(rel(root, match))
    return sorted(set(members))


def detect_monorepo(root):
    evidence = []
    for marker in [
        "pnpm-workspace.yaml",
        "turbo.json",
        "nx.json",
        "lerna.json",
        "rush.json",
        "Cargo.toml",
    ]:
        if os.path.exists(os.path.join(root, marker)):
            evidence.append(marker)

    workspace_globs = parse_workspace_globs(root)
    members = expand_workspace_members(root, workspace_globs)

    for fallback_dir in ["packages", "apps", "services"]:
        full_path = os.path.join(root, fallback_dir)
        if os.path.isdir(full_path):
            child_dirs = []
            for child in sorted(os.listdir(full_path)):
                candidate = os.path.join(full_path, child)
                if os.path.isdir(candidate):
                    markers = [
                        os.path.join(candidate, "package.json"),
                        os.path.join(candidate, "pyproject.toml"),
                        os.path.join(candidate, "Cargo.toml"),
                    ]
                    if any(os.path.exists(marker) for marker in markers):
                        child_dirs.append(rel(root, candidate))
            if child_dirs:
                evidence.append(fallback_dir + "/")
                members.extend(child_dirs)

    members = sorted(set(members))
    is_monorepo = bool(workspace_globs or len(members) > 1 or any(marker in evidence for marker in ["turbo.json", "nx.json", "lerna.json", "rush.json"]))

    return {
        "is_monorepo": is_monorepo,
        "evidence": sorted(set(evidence)),
        "workspace_globs": workspace_globs,
        "workspace_members": members,
    }


def detect_root_scripts(root):
    package_json = read_json(os.path.join(root, "package.json"))
    if not isinstance(package_json, dict):
        return {}
    scripts = package_json.get("scripts")
    if not isinstance(scripts, dict):
        return {}

    ordered_keys = [
        "dev",
        "build",
        "test",
        "test:unit",
        "test:e2e",
        "lint",
        "typecheck",
        "check",
        "migrate",
        "db:migrate",
    ]
    result = {}
    for key in ordered_keys:
        if key in scripts and isinstance(scripts[key], str):
            result[key] = scripts[key]
    return result


def detect_tooling_configs(root):
    signals = []
    package_json = read_json(os.path.join(root, "package.json"))

    for tool, markers in TOOLING_CONFIG_MARKERS.items():
        evidence = []
        for marker in markers:
            if os.path.exists(os.path.join(root, marker)):
                evidence.append(marker)

        if isinstance(package_json, dict):
            if tool == "eslint" and "eslintConfig" in package_json:
                evidence.append("package.json:eslintConfig")
            if tool == "prettier" and "prettier" in package_json:
                evidence.append("package.json:prettier")

        add_signal(signals, tool, evidence)

    return sorted(signals, key=lambda item: item["name"])


def detect_test_signals(root, root_scripts):
    signals = []
    for name, markers in TEST_MARKERS.items():
        evidence = []
        for marker in markers:
            if os.path.exists(os.path.join(root, marker)):
                evidence.append(marker)
        add_signal(signals, name, evidence)

    for script_name, command in sorted(root_scripts.items()):
        if script_name.startswith("test") or "vitest" in command or "jest" in command or "pytest" in command:
            signals.append(
                {
                    "name": "package.json script",
                    "evidence": [f"package.json:scripts.{script_name}"],
                }
            )

    return sorted(signals, key=lambda item: item["name"])


def detect_migration_signals(root):
    signals = []
    for marker in MIGRATION_DIR_NAMES:
        full_path = os.path.join(root, marker)
        if os.path.exists(full_path):
            signals.append({"name": marker, "evidence": [marker]})
    for marker in ["prisma/schema.prisma", "alembic.ini"]:
        if os.path.exists(os.path.join(root, marker)):
            signals.append({"name": marker, "evidence": [marker]})
    return signals


def detect_public_api_signals(root):
    signals = []
    for marker in PUBLIC_API_MARKERS:
        if os.path.exists(os.path.join(root, marker)):
            signals.append({"name": marker, "evidence": [marker]})

    package_json = read_json(os.path.join(root, "package.json"))
    if isinstance(package_json, dict) and "exports" in package_json:
        signals.append({"name": "package.json exports", "evidence": ["package.json:exports"]})

    for marker in ["api", "public", "openapi", "proto"]:
        if os.path.isdir(os.path.join(root, marker)):
            signals.append({"name": marker + "/", "evidence": [marker + "/"]})

    return signals


def detect_ci_files(root):
    files = []
    github_dir = os.path.join(root, ".github", "workflows")
    if os.path.isdir(github_dir):
        for entry in sorted(os.listdir(github_dir)):
            if entry.endswith((".yml", ".yaml")):
                files.append(rel(root, os.path.join(github_dir, entry)))
    for marker in [".gitlab-ci.yml", ".circleci/config.yml", "azure-pipelines.yml"]:
        if os.path.exists(os.path.join(root, marker)):
            files.append(marker)
    return files


def detect_guidance_files(root):
    guidance = []
    for marker in [
        "AGENTS.md",
        "CLAUDE.md",
        "README.md",
        "README",
        "CONTRIBUTING.md",
        "CONTRIBUTING",
        "docs",
    ]:
        if os.path.exists(os.path.join(root, marker)):
            guidance.append(marker)
    return guidance


def command_entry(task, command, evidence):
    return {"task": task, "command": command, "evidence": sorted(set(evidence))}


def detect_file_scoped_commands(root, package_managers, languages, root_scripts, test_signals, tooling_configs):
    commands = []
    language_names = [item["name"] for item in languages]
    tooling_names = signal_names(tooling_configs)
    test_names = signal_names(test_signals)
    js_runner = select_js_runner(package_managers)
    python_runner = select_python_runner(package_managers)
    root_script_values = " ".join(root_scripts.values())

    if js_runner:
        if "eslint" in tooling_names or "eslint" in root_script_values:
            commands.append(
                command_entry(
                    "lint",
                    f"{js_runner} eslint path/to/file.ts",
                    ["eslint"],
                )
            )
        if "biome" in tooling_names or "biome" in root_script_values:
            commands.append(
                command_entry(
                    "lint",
                    f"{js_runner} biome check path/to/file.ts",
                    ["biome"],
                )
            )
        if "vitest" in test_names or "vitest" in root_script_values:
            commands.append(
                command_entry(
                    "test",
                    f"{js_runner} vitest path/to/spec.ts",
                    ["vitest"],
                )
            )
        if "jest" in test_names or "jest" in root_script_values:
            commands.append(
                command_entry(
                    "test",
                    f"{js_runner} jest path/to/test.ts",
                    ["jest"],
                )
            )
        if "tsc-files" in root_script_values:
            commands.append(
                command_entry(
                    "typecheck",
                    f"{js_runner} tsc-files --noEmit path/to/file.ts",
                    ["package.json scripts"],
                )
            )

    if "Python" in language_names:
        if "ruff" in tooling_names or "ruff" in root_script_values:
            commands.append(
                command_entry(
                    "lint",
                    f"{python_runner} ruff check path/to/file.py",
                    ["ruff"],
                )
            )
        if "pytest" in test_names or "pytest" in root_script_values:
            commands.append(
                command_entry(
                    "test",
                    f"{python_runner} pytest path/to/test_file.py",
                    ["pytest"],
                )
            )
        if "mypy" in tooling_names or "mypy" in root_script_values:
            commands.append(
                command_entry(
                    "typecheck",
                    f"{python_runner} mypy path/to/file.py",
                    ["mypy"],
                )
            )
        if "pyright" in tooling_names or "pyright" in root_script_values:
            commands.append(
                command_entry(
                    "typecheck",
                    f"{python_runner} pyright path/to/file.py",
                    ["pyright"],
                )
            )

    if "Ruby" in language_names:
        if "rubocop" in tooling_names or "rubocop" in root_script_values:
            commands.append(
                command_entry(
                    "lint",
                    "bundle exec rubocop path/to/file.rb",
                    ["rubocop"],
                )
            )
        if "rspec" in test_names or "rspec" in root_script_values:
            commands.append(
                command_entry(
                    "test",
                    "bundle exec rspec spec/path/to_spec.rb",
                    ["rspec"],
                )
            )

    if "Go" in language_names:
        commands.append(
            command_entry(
                "test",
                "go test ./path/to/package",
                ["go.mod"],
            )
        )

    if "Rust" in language_names:
        commands.append(
            command_entry(
                "test",
                "cargo test test_name",
                ["Cargo.toml"],
            )
        )

    unique = {}
    for item in commands:
        key = (item["task"], item["command"])
        unique[key] = item
    return list(unique.values())


def detect_interview_topics(monorepo, migrations, public_api_signals):
    topics = ["commit_style", "testing_policy", "agents_update_policy"]
    if migrations:
        topics.insert(0, "migration_policy")
    if public_api_signals:
        topics.append("public_api_policy")
    if monorepo.get("is_monorepo"):
        topics.append("monorepo_policy")
    return topics


def guess_project_type(monorepo, public_api_signals):
    if monorepo.get("is_monorepo"):
        return "monorepo"
    for signal in public_api_signals:
        if signal["name"] in ("package.json exports", "src/lib.rs", "lib.rs", "__init__.py"):
            return "library"
    return "application"


def render_markdown(data):
    lines = []
    lines.append("# 仓库事实")
    lines.append("")
    lines.append("- 根目录：`{}`".format(data["root"]))
    lines.append("- 项目类型：`{}`".format(PROJECT_TYPE_LABELS.get(data["project_type"], data["project_type"])))
    lines.append("")
    lines.append("## 使用提示")
    lines.append("- 这里的扫描结果是候选证据，不是自动落盘结论")
    lines.append("- 只有能帮助未来 agent 决策的内容，才值得写进 `AGENTS.md`")
    lines.append("- 未确认的偏好先留在待确认，不要伪装成仓库事实")
    lines.append("")

    for title, key in [
        ("指导文件", "guidance_files"),
        ("包管理器", "package_managers"),
        ("语言", "languages"),
        ("工具配置", "tooling_configs"),
        ("CI 文件", "ci_files"),
        ("测试信号", "test_signals"),
        ("迁移信号", "migration_signals"),
        ("公共 API 信号", "public_api_signals"),
    ]:
        lines.append("## " + title)
        value = data[key]
        if not value:
            lines.append("- 未发现")
            lines.append("")
            continue
        if key in ("package_managers", "languages", "tooling_configs", "test_signals", "migration_signals", "public_api_signals"):
            for item in value:
                parts = [item["name"]]
                if item.get("evidence"):
                    parts.append("证据: " + ", ".join(item["evidence"]))
                if item.get("file_count"):
                    parts.append("文件数: {}".format(item["file_count"]))
                lines.append("- " + " | ".join(parts))
        else:
            for item in value:
                lines.append("- " + item)
        lines.append("")

    lines.append("## Monorepo")
    lines.append("- 检测结果：{}".format("是" if data["monorepo"]["is_monorepo"] else "否"))
    if data["monorepo"]["evidence"]:
        lines.append("- 证据：" + ", ".join(data["monorepo"]["evidence"]))
    if data["monorepo"]["workspace_globs"]:
        lines.append("- workspace 模式：" + ", ".join(data["monorepo"]["workspace_globs"]))
    if data["monorepo"]["workspace_members"]:
        lines.append("- workspace 成员：" + ", ".join(data["monorepo"]["workspace_members"]))
    lines.append("")

    lines.append("## 根脚本")
    if data["root_scripts"]:
        for name, command in data["root_scripts"].items():
            lines.append("- `{}`: `{}`".format(name, command))
    else:
        lines.append("- 未发现")
    lines.append("")

    lines.append("## 文件级命令")
    if data["file_scoped_commands"]:
        for item in data["file_scoped_commands"]:
            label = TASK_LABELS.get(item["task"], item["task"])
            lines.append("- {}：`{}`".format(label, item["command"]))
    else:
        lines.append("- 未发现")
    lines.append("")

    lines.append("## 建议采访主题")
    for topic in data["suggested_interview_topics"]:
        lines.append("- `{}`".format(INTERVIEW_TOPIC_LABELS.get(topic, topic)))
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="扫描仓库事实，用于初始化或收敛 AGENTS.md。")
    parser.add_argument("root", nargs="?", default=".", help="要扫描的仓库根目录")
    parser.add_argument("--markdown", action="store_true", help="输出中文 markdown 摘要")
    parser.add_argument("--max-files", type=int, default=2500, help="最多扫描的文件数量")
    args = parser.parse_args()

    root = os.path.abspath(args.root)
    files = collect_files(root, args.max_files)
    monorepo = detect_monorepo(root)
    package_managers = detect_package_managers(root)
    root_scripts = detect_root_scripts(root)
    tooling_configs = detect_tooling_configs(root)
    languages = detect_languages(root, files)
    test_signals = detect_test_signals(root, root_scripts)
    migrations = detect_migration_signals(root)
    public_api_signals = detect_public_api_signals(root)

    data = {
        "root": root,
        "project_type": guess_project_type(monorepo, public_api_signals),
        "guidance_files": detect_guidance_files(root),
        "package_managers": package_managers,
        "languages": languages,
        "monorepo": monorepo,
        "root_scripts": root_scripts,
        "tooling_configs": tooling_configs,
        "ci_files": detect_ci_files(root),
        "test_signals": test_signals,
        "migration_signals": migrations,
        "public_api_signals": public_api_signals,
        "file_scoped_commands": detect_file_scoped_commands(
            root,
            package_managers,
            languages,
            root_scripts,
            test_signals,
            tooling_configs,
        ),
        "suggested_interview_topics": detect_interview_topics(monorepo, migrations, public_api_signals),
    }

    if args.markdown:
        print(render_markdown(data))
    else:
        print(json.dumps(data, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
