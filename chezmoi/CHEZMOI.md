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
- former git submodules are now managed by `chezmoi/.chezmoiexternal.toml`:
  `~/.config/kitty/kitty_search`, `~/.tmux/plugins/tpm`, and
  `~/.agents/skill-sources/{git-commit-helper,notebooklm-skill,ordinary-claude-skills,superpowers}`

Mutating setup steps are now executed through chezmoi run scripts:

- `run_once_*`: one-time bootstrap steps
- `run_onchange_*`: rerun when script content changes

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
