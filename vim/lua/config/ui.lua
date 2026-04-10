vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("custom_highlight", { clear = true }),
  pattern = "*",
  desc = "Define or override some highlight groups",
  callback = function()
    -- For floating windows border highlight
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "Grey", bg = "None", bold = true })

    local hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
    -- change the background color of floating window to None, so it blenders better
    vim.api.nvim_set_hl(0, "NormalFloat", { fg = hl.fg, bg = "None" })
  end,
})

local builtin_ui_open = vim.ui.open

local function normalize_open_target(path)
  if path:match("%w+:") then
    return path
  end

  return vim.fs.normalize(vim.fn.expand(path))
end

local function copy_text_via_osc52(text)
  local osc52 = require("vim.ui.clipboard.osc52")
  osc52.copy("+")({ text })
  osc52.copy("*")({ text })
end

local function open_via_lemonade(target)
  if vim.fn.executable("lemonade") ~= 1 then
    return nil, "vim.ui.open: lemonade is not available"
  end

  vim.fn.jobstart({ "lemonade", target }, { detach = true })
  return true, nil
end

vim.ui.open = function(path, opt)
  vim.validate("path", path, "string")

  if not vim.F.is_ssh_session() then
    return builtin_ui_open(path, opt)
  end

  local ok, err = open_via_lemonade(target)
  if ok then
    vim.notify(("Remote session: opened by lemonade: %s"):format(target), vim.log.levels.INFO)
    return nil, nil
  end

  local target = normalize_open_target(path)
  local ok = pcall(copy_text_via_osc52, target)
  if ok then
    vim.notify(("Remote session: copied to clipboard: %s"):format(target), vim.log.levels.INFO)
    return nil, nil
  end

  vim.notify(
    ("Remote session detected, but clipboard copy failed: %s"):format(target),
    vim.log.levels.WARN
  )
  return nil, "vim.ui.open: remote session detected but clipboard bridge is unavailable"
end
