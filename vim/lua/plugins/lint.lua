---@type LazySpec[]
return {
  {
    "dense-analysis/ale",
    event = "VeryLazy",
    lazy = true,
    dependencies = {
      "jiz4oh/ale-autocorrect.vim",
    },
  },
}
