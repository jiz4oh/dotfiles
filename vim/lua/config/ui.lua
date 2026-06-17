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
  local on_exit = function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        vim.notify(string.format("lemonade occur error %d: %s", obj.code, obj.stderr))
        return
      end
    end)
  end

  vim.system({ "lemonade", "open", target }, { detach = true }, on_exit)
  return true, nil
end

local function get_remote_file_by_ssh(host, port, path, callback)
  if vim.endswith(path, "/") then
    vim.notify("current buffer is not a file", vim.log.levels.ERROR)
    return
  end

  local src = host .. ":" .. path

  local tmpdir = vim.fn.stdpath("cache") .. "/remote-open"
  vim.fn.mkdir(tmpdir, "p")

  -- 保留后缀，方便 Chrome Markdown 插件识别 .md/.markdown/.yaml
  local digest = vim.fn.sha256(host .. ":" .. path):sub(1, 12)
  local basename = vim.fn.fnamemodify(path, ":t")
  local tmpfile = vim.fs.joinpath(tmpdir, ("%s-%s"):format(digest, basename))

  local cmd = { "scp" }
  if port then
    vim.list_extend(cmd, { "-P", port })
  end
  vim.list_extend(cmd, { src, tmpfile })

  vim.notify("copying remote file: " .. path)

  require("oil.shell").run(cmd, function(err)
    if err then
      vim.notify(("copy remote file faield: %s"):format(err), vim.log.levels.ERROR)
    else
      callback(tmpfile)
    end
  end)
end

local function ui_open(path, opt)
  if not vim.F.is_ssh_session() then
    return builtin_ui_open(path, opt)
  end

  local target = normalize_open_target(path)
  local ok, err = open_via_lemonade(target)
  if ok then
    vim.notify(("Remote session: opened by lemonade: %s"):format(target), vim.log.levels.INFO)
    return nil, nil
  end

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

vim.ui.open = function(path, opt)
  vim.validate("path", path, "string")
  if path:match("^(oil-ssh://)(.*)$") then
    local ok1, oil_ssh = pcall(require, "oil.adapters.ssh")
    if ok1 then
      local res = oil_ssh.parse_url(vim.api.nvim_buf_get_name(0))
      path = get_remote_file_by_ssh(res.host, res.port, res.path, function(path)
        ui_open(path, opt)
      end)
      if path == nil then
        return nil, nil
      end
    end
  else
    ui_open(path, opt)
  end
end
