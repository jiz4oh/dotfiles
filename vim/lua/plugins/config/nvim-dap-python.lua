---@type LazyPluginSpec
return {
  "mfussenegger/nvim-dap-python",
  optional = true,
  opts = {},
  ft = { "python" },
  config = function()
    require("dap-python").setup("python3")
    -- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#python-dependencies-and-virtualenv
    -- require('dap-python').resolve_python = function()
    --   return '/absolute/path/to/python'
    -- end
  end,
  dependencies = {
    "mfussenegger/nvim-dap",
  },
}
