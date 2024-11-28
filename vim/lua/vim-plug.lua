local plugins = {}

local is_map = function (v)
  return string.match(v, "^<Plug>.*")
end

local as_array = function (v)
  if type(v) == "string" then
    return {v}
  elseif type(v) == "table" then
    return v
  else
    return {}
  end
end

if vim.g.plugs_order ~= nil then
  vim.tbl_map(function(plug)
    local config = vim.g.plugs[plug]
    if type(config['on']) == "string" then
      local on = {config['on']}
    else
      local on = config['on']
    end

    if config ~= nil then
      local cmd = vim.tbl_filter(function(v)
        return not is_map(v)
      end, as_array(config['on']))
      local keys = vim.tbl_filter(function(v)
        return is_map(v)
      end, as_array(config['on']))

      local path = vim.g.config_home .. '/config/plugin/' .. plug .. '.vim'
      local conf = { 
        config['uri'],
        lazy = (not vim.tbl_isempty(as_array(config['on']))) or (not vim.tbl_isempty(as_array(config['for']))),
        cmd = cmd,
        keys = keys,
        event = config['event'],
        ft = config['for'],
        branch = config['branch'],
        tag = config['tag'],
        commit = config['commit'],
        dir = config['dir'],
        name = config['as'],
        pin = config['forzen'],
        build = config['do'],
      }

      conf['init'] = function()
        pcall(vim.cmd.source, path)
      end

      table.insert(plugins, conf)
    end
  end, vim.g.plugs_order)
end

return plugins
