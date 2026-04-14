local logfile = vim.fn.stdpath("state") .. "/errors.log"
local orig_schedule = vim.schedule
local orig_schedule_wrap = vim.schedule_wrap
local unpack_fn = table.unpack or unpack

vim.g.async_error_logfile = logfile

local function append_log(message)
  local sanitized = tostring(message):gsub("%z", "\\0")
  vim.fn.writefile({
    ("[%s] %s"):format(os.date("%Y-%m-%d %H:%M:%S"), sanitized),
    "",
  }, logfile, "a")
end

local function format_trace(context, err)
  return ("%s\n%s"):format(context, debug.traceback(err, 2))
end

local function handle_async_error(context, err)
  local trace = format_trace(context, err)
  append_log(trace)
  orig_schedule(function()
    vim.notify(trace, vim.log.levels.ERROR)
  end)
  return trace
end

vim.schedule = function(callback)
  return orig_schedule(function()
    local ok, trace = xpcall(callback, function(err)
      return handle_async_error("vim.schedule callback failed", err)
    end)
    if ok then
      return
    end
    return trace
  end)
end

vim.schedule_wrap = function(callback)
  return orig_schedule_wrap(function(...)
    local argc = select("#", ...)
    local args = { ... }
    local ok, trace = xpcall(function()
      callback(unpack_fn(args, 1, argc))
    end, function(err)
      return handle_async_error("vim.schedule_wrap callback failed", err)
    end)
    if ok then
      return
    end
    return trace
  end)
end

vim.api.nvim_create_user_command("ErrorLog", function()
  vim.cmd.edit(vim.g.async_error_logfile)
end, { desc = "Open async error log" })
