---@type LazySpec[]
local plugins = {}

local is_map = function(v)
  return string.match(v, "^<Plug>.*")
end

local as_array = function(v)
  if type(v) == "string" then
    return { v }
  elseif type(v) == "table" then
    return v
  else
    return {}
  end
end

if vim.g.plugs_order ~= nil then
  vim.tbl_map(function(plug)
    local config = vim.g.plugs[plug]

    if config ~= nil then
      local cmd = vim.tbl_filter(function(v)
        return not is_map(v)
      end, as_array(config["on"]))
      local keys = vim.tbl_filter(function(v)
        return is_map(v)
      end, as_array(config["on"]))

      local path = vim.g.config_home .. "/config/plugin/" .. plug .. ".vim"
      ---@type LazySpec
      local conf = {
        config["uri"],
        lazy = (not vim.tbl_isempty(as_array(config["on"])))
          or (not vim.tbl_isempty(as_array(config["for"]))),
        cmd = cmd,
        keys = keys,
        dir = vim.fn.isdirectory(config["dir"]) == 1 and config["dir"] or nil,
      }

      local mappings = {
        event = "event",
        ft = "for",
        branch = "branch",
        tag = "tag",
        commit = "commit",
        name = "as",
        pin = "forzen",
        build = "do",
      }

      for k, v in pairs(mappings) do
        if config[v] ~= nil and config[v] ~= "" then
          conf[k] = config[v]
        end
      end

      conf["init"] = function()
        pcall(vim.cmd.source, path)
      end

      table.insert(plugins, conf)
    end
  end, vim.g.plugs_order)
end

return plugins
