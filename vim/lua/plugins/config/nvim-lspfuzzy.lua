---@type LazyPluginSpec
return {
  "ojroques/nvim-lspfuzzy",
  optional = true,
  event = "LspAttach",
  opts = {
    methods = {
      "callHierarchy/incomingCalls",
      "callHierarchy/outgoingCalls",
    }, -- either 'all' or a list of LSP methods (see below)
    jump_one = true, -- jump immediately if there is only one location
    callback = nil, -- callback called after jumping to a location
    save_last = false, -- save last location results for the :LspFuzzyLast command
    fzf_modifier = ":~:.", -- format FZF entries, see |filename-modifiers|
    fzf_trim = true, -- trim FZF entries
  },
  dependencies = {
    { "junegunn/fzf" },
    { "junegunn/fzf.vim" }, -- to enable preview (optional)
  },
}
