# Chezmoi migration

This repository root is the chezmoi source directory. Simple files use native
chezmoi `dot_*` source-state names. Large mutable trees use explicit symlink or
external entries.

## Daily flow

```sh
chezmoi --source "$PWD" managed
chezmoi --source "$PWD" apply --dry-run --force --no-tty
chezmoi --source "$PWD" apply --force --no-tty
```

Equivalent raw commands:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

Direct source path:

```sh
chezmoi --source "$PWD" diff
chezmoi --source "$PWD" apply
```

## Scope

The migration currently covers the files and directories from the legacy
`install` script:

- simple shell, git, tmux, editor, formatter, and tool dotfiles as native
  `dot_*` entries
- simple nested files such as `~/.config/direnv/direnv.toml`,
  `~/.config/lemonade.toml`, `~/.codex/AGENTS.md`,
  `~/.rbenv/default-gems`, `~/.snipaste/config.ini`, and
  `~/.hammerspoon/init.lua`
- larger directories as symlinks, including `~/.agents`, `~/.vim`,
  `~/.raycast`, `~/.terminfo`, `~/.config/{kitty,mise,rubocop,solargraph,wezterm}`,
  and `~/.hammerspoon/{Spoons,modules}`
- former git submodules are now managed by files under
  `chezmoi/.chezmoiexternals/`:
  `~/.config/kitty/kitty_search`, `~/.tmux/plugins/tpm`, and
  `~/.agents/skill-sources/{git-commit-helper,notebooklm-skill,ordinary-claude-skills,superpowers}`
- the Rime upstream repo is managed as an external checkout under
  `~/.local/share/rime-frost`, while local overlays remain in `rime/custom` and
  `rime/opencc`

Mutating setup steps are now executed through files under
`chezmoi/.chezmoiscripts/`:

- `run_once_*`: one-time bootstrap steps
- `run_onchange_*`: rerun when script content changes
- `run_after_*`: run after `chezmoi apply` finishes

Declarative package lists live under `chezmoi/.chezmoidata/`. The current
package source of truth is `chezmoi/.chezmoidata/packages.yaml`, consumed by
OS-specific `run_onchange_*install_packages*` scripts.

Manual helper scripts that should not run during `chezmoi apply` should stay
outside `chezmoi/.chezmoiscripts/`. For Rime, the user-facing entrypoints stay
under `rime/`, while only the automatic apply hook remains in
`chezmoi/.chezmoiscripts/`.

## Notes

- `.chezmoiignore` ignores raw repository files so only native `dot_*`
  entries and explicit `symlink_*` entries are applied.
- The remaining symlink targets use `{{ .chezmoi.sourceDir }}` so the source
  checkout can move without editing the mappings.
- The legacy `install` script now skips missing legacy file paths. Use chezmoi
  for dotfile placement, then run the legacy scripts only for software,
  plugins, and system setup.
- `oh-my-zsh/custom` is not mapped in this pass because an existing Oh My Zsh
  install commonly owns that directory. Keep using `install` or migrate it after
  deciding whether the whole directory should be replaced by a symlink.
