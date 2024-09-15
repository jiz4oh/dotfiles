lua<<EOF
local maps = {}

local function convert(prefix, mode, map)
  for k, v in pairs(map) do
    if k == 'name' then
      maps[#maps + 1] = { prefix, mode = mode, group = v }
    else
      if type(v) == 'string' then
        maps[#maps + 1] = { prefix..k, mode = mode, desc = v }
      elseif type(v) == 'table' then
        if v[1] ~= nil then
          maps[#maps + 1] = { prefix..k, v[1], mode = mode, desc = v[2] }
        else
          convert(prefix .. k, mode, v)
        end
      else
      end
    end
  end
end

convert("<leader>", 'n', vim.g.which_key_map)
convert("<leader>", 'v', vim.g.which_key_map_visual)

maps[#maps + 1] = {
  { "<leader>b", group = "buffers", expand = function()
      return require("which-key.extras").expand.buf()
    end
  },
}

require("which-key").add(maps)
EOF
