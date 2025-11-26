---@type LazyPluginSpec
return {
  "fang2hou/blink-copilot",
  optional = true,
  opts = {},
  specs = {
    {
      "saghen/blink.cmp",
      opts = {
        sources = {
          default = { "copilot" },
          providers = {
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              score_offset = 100,
              async = true,
            },
          },
        },
      },
    },
  },
}
