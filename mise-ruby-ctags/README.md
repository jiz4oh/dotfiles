# mise-ruby-ctags

Generate Ruby stdlib `tags` for Rubies installed by `mise`.

This is the `mise` equivalent of
[tpope/rbenv-ctags](https://github.com/tpope/rbenv-ctags), but it is
designed to be used as a companion tool via `mise` install hooks instead
of being embedded inside a Vim plugin.

`gem` tags are intentionally out of scope. Use
[tpope/gem-ctags](https://github.com/tpope/gem-ctags) for installed gems.

## Usage

Generate tags for the current active Ruby:

```sh
mise-ruby-ctags
```

Generate tags for a specific installed Ruby version:

```sh
mise-ruby-ctags 3.1.2
```

Generate tags for a specific install path:

```sh
mise-ruby-ctags ~/.local/share/mise/installs/ruby/3.1.2
```

Generate tags for every installed Ruby under `mise`:

```sh
mise-ruby-ctags --all
```

## Hook Integration

Recommended: use a tool-level `postinstall` hook so tags are generated
immediately after each Ruby install.

```toml
[tools]
ruby = { version = "3.1.2", postinstall = "mise-ruby-ctags \"$MISE_TOOL_INSTALL_PATH\"" }
```

You can also use a global `postinstall` hook and filter
`MISE_INSTALLED_TOOLS` yourself, but the tool-level hook is simpler.

## Requirements

- `mise`
- `ctags`

For Ruby tags, many setups use a wrapper `ctags` that dispatches Ruby
input to `ripper-tags`. This tool intentionally shells out to:

```sh
ctags --languages=Ruby -R --tag-relative=yes .
```

so it stays compatible with existing `ctags` wrappers and workflows.

## Output

Tags are written into the Ruby stdlib directories themselves, for example:

```text
~/.local/share/mise/installs/ruby/3.1.2/lib/ruby/3.1.0/tags
~/.local/share/mise/installs/ruby/3.1.2/lib/ruby/site_ruby/3.1.0/tags
~/.local/share/mise/installs/ruby/3.1.2/lib/ruby/vendor_ruby/3.1.0/tags
```
