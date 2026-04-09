local function in_ssh()
  return vim.env.SSH_TTY ~= nil
    or vim.env.SSH_CONNECTION ~= nil
    or vim.env.SSH_CLIENT ~= nil
end

local function tailscale_ip()
  if vim.fn.executable("tailscale") ~= 1 then
    return nil
  end

  local lines = vim.fn.systemlist({ "tailscale", "ip", "-4" })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  for _, line in ipairs(lines) do
    local ip = vim.trim(line)
    if ip ~= "" then
      return ip
    end
  end
end

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
  config = function(_, opts)
    if is_ssh_session() then
      opts.address = tailscale_ip() or "0.0.0.0"
    else
      opts.address = "127.0.0.1"
    end

    require("livepreview.config").set(opts)
  end,
  specs = {
    {
      "iamcco/markdown-preview.nvim",
      enabled = false,
    },
  },
}
