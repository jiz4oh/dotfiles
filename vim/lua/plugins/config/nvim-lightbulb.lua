---@type LazyPluginSpec
return {
  "kosayoda/nvim-lightbulb",
  optional = true,
  event = {
    "CursorHold",
    "CursorHoldI",
  },
  opts = {
    autocmd = { enabled = true },
    -- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeActionKind
    -- exclude source kinds
    action_kinds = { "quickfix", "refactor" },
    code_lenses = false,
    sign = { enabled = true }, -- conflict with git signs
    virtual_text = { enabled = true },
  },
}
