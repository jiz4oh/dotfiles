local state = require("ai_commit.state")
local config = require("ai_commit.config")
local cli = require("ai_commit.cli")

local UI = {}

function UI.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "AICommit" })
end

function UI.buf_is_valid(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

function UI.win_is_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

function UI.stop_spinner()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
  state.spinner_index = 1
end

function UI.stop_timeout()
  if state.timeout_timer then
    state.timeout_timer:stop()
    state.timeout_timer:close()
    state.timeout_timer = nil
  end
end

function UI.destroy_popup()
  UI.stop_spinner()
  UI.stop_timeout()

  if state.job and state.job.is_closing ~= nil and not state.job:is_closing() then
    state.job:kill(15)
  end

  state.job = nil

  if UI.win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  if UI.buf_is_valid(state.popup_buf) then
    vim.api.nvim_buf_delete(state.popup_buf, { force = true })
  end

  state.cleanup_tempfile()

  state.popup_buf = nil
  state.popup_win = nil
  state.backend = nil
end

function UI.hide_popup()
  UI.stop_spinner()
  UI.stop_timeout()

  if UI.win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  state.popup_win = nil
end

function UI.set_popup_lines(lines)
  if not UI.buf_is_valid(state.popup_buf) then
    return
  end

  vim.bo[state.popup_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.popup_buf, 0, -1, false, lines)
  vim.bo[state.popup_buf].modifiable = false
end

function UI.update_spinner_line()
  if not UI.buf_is_valid(state.popup_buf) then
    UI.stop_spinner()
    return
  end

  local frame = config.spinner_frames[state.spinner_index]
  state.spinner_index = (state.spinner_index % #config.spinner_frames) + 1

  local backend = state.backend or "ai"
  local current_model = cli.get_current_model()
  local model_info = ""
  if current_model then
    model_info = string.format(" [%s]", current_model)
  end
  vim.bo[state.popup_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.popup_buf, 0, 1, false, {
    string.format("Generating %s commit message%s... %s", backend, model_info, frame),
  })
  vim.bo[state.popup_buf].modifiable = false
end

function UI.start_spinner()
  UI.stop_spinner()
  UI.update_spinner_line()

  state.spinner_timer = vim.uv.new_timer()
  state.spinner_timer:start(config.spinner_interval, config.spinner_interval, function()
    vim.schedule(UI.update_spinner_line)
  end)
end

function UI.render_timeout()
  UI.stop_spinner()
  UI.stop_timeout()

  if not UI.buf_is_valid(state.popup_buf) then
    return
  end

  UI.set_popup_lines({
    string.format("Timed out after %.1fs. Total retries: %d.", config.timeout_ms / 1000, state.total_retries),
    "",
    "Commit message generation was cancelled.",
    "Try again or reduce the staged diff size.",
    "",
    "Keys:",
    "  q hide popup",
  })
  vim.bo[state.popup_buf].modifiable = false
end

function UI.create_popup_window()
  local width = math.min(math.max(math.floor(vim.o.columns * 0.6), 60), 100)
  local height = math.min(math.max(math.floor(vim.o.lines * 0.4), 10), 18)
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  state.popup_win = vim.api.nvim_open_win(state.popup_buf, true, {
    relative = "editor",
    style = "minimal",
    border = "rounded",
    title = " AI Commit ",
    title_pos = "center",
    width = width,
    height = height,
    row = math.max(row, 1),
    col = col,
  })

  vim.wo[state.popup_win].wrap = true
  vim.wo[state.popup_win].linebreak = true
  vim.wo[state.popup_win].winfixbuf = true

  vim.keymap.set("n", "q", UI.hide_popup, { buffer = state.popup_buf, silent = true })
end

function UI.open_popup(target_buf, target_win, backend)
  UI.destroy_popup()

  state.target_buf = target_buf
  state.target_win = target_win
  state.backend = backend
  state.popup_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.popup_buf].buftype = "nofile"
  vim.bo[state.popup_buf].bufhidden = "hide"
  vim.bo[state.popup_buf].swapfile = false
  vim.bo[state.popup_buf].filetype = "gitcommit"

  UI.create_popup_window()

  UI.set_popup_lines({
    string.format("Generating %s commit message...", state.backend or "ai"),
    "",
    "Keys:",
    "  <C-y> apply to current gitcommit buffer",
    "  q hide popup",
  })
  UI.start_spinner()
end

function UI.normalize_message(raw)
  local lines = vim.split(raw or "", "\n", { plain = true, trimempty = false })
  local cleaned = {}
  local in_codeblock = false

  for _, line in ipairs(lines) do
    if line:match("^```") then
      in_codeblock = not in_codeblock
    elseif in_codeblock or line ~= "" or #cleaned > 0 then
      table.insert(cleaned, (line:gsub("%s+$", "")))
    end
  end

  while #cleaned > 0 and cleaned[#cleaned] == "" do
    table.remove(cleaned)
  end

  return cleaned
end

function UI.apply_message()
  if not UI.buf_is_valid(state.popup_buf) or not UI.buf_is_valid(state.target_buf) then
    UI.destroy_popup()
    UI.notify("Target gitcommit buffer is gone", vim.log.levels.WARN)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(state.popup_buf, 0, -1, false)
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end

  vim.bo[state.target_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.target_buf, 0, -1, false, lines)
  vim.bo[state.target_buf].modified = true

  if UI.win_is_valid(state.target_win) then
    vim.api.nvim_set_current_win(state.target_win)
  end

  UI.hide_popup()
end

function UI.set_confirm_maps()
  vim.keymap.set("n", "<C-y>", UI.apply_message, { buffer = state.popup_buf, silent = true })
end

function UI.render_result(raw)
  UI.stop_spinner()
  UI.stop_timeout()
  local lines = UI.normalize_message(raw)

  if #lines == 0 then
    lines = { "" }
  end

  UI.set_popup_lines(lines)
  UI.set_confirm_maps()

  if UI.win_is_valid(state.popup_win) then
    vim.api.nvim_set_current_win(state.popup_win)
  end
end

return UI
