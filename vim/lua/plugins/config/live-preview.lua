---@type LazyPluginSpec
return {
  "brianhuster/live-preview.nvim",
  optional = true,
  ft = {
    "markdown",
  },
  cmd = {
    "LivePreview",
  },
  init = function()
    local aug = vim.api.nvim_create_augroup("markdown-preview-autocmd", { clear = true })

    vim.api.nvim_create_user_command("MarkdownPreview", function()
      vim.cmd("LivePreview start")
    end, { desc = "Open markdown preview" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      group = aug,
      callback = function(args)
        local bufnr = args.buf
        vim.b[bufnr].dispatch = ":LivePreview start"
      end,
    })

    -- cannot call vim.fn["rails#buffer"]().relative()
    vim.cmd([[
      autocmd User Rails if rails#buffer().relative() == 'README.md'|let b:dispatch = ':LivePreview start'|endif
    ]])
  end,
  config = function()
    require("livepreview.config").set()
  end,
  specs = {
    {
      "iamcco/markdown-preview.nvim",
      enabled = false,
    },
  },
}
