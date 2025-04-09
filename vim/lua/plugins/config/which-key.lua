---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  optional = true,
  event = "VeryLazy",
  config = function()
    require("which-key").setup({
      win = {
        -- don't allow the popup to overlap with the cursor
        no_overlap = false,
      },
    })
    local maps = {}

    local function convert(prefix, mode, map)
      for k, v in pairs(map) do
        if k == "name" then
          maps[#maps + 1] = { prefix, mode = mode, group = v }
        else
          if type(v) == "string" then
            maps[#maps + 1] = { prefix .. k, mode = mode, desc = v }
          elseif type(v) == "table" then
            if v[1] ~= nil then
              if string.match(v[1], "^:.*") then
                maps[#maps + 1] = { prefix .. k, v[1] .. "<cr>", mode = mode, desc = v[2] }
              else
                maps[#maps + 1] = { prefix .. k, v[1], mode = mode, desc = v[2] }
              end
            else
              convert(prefix .. k, mode, v)
            end
          else
          end
        end
      end
    end

    convert("<leader>", "n", vim.g.which_key_map)
    convert("<leader>", "v", vim.g.which_key_map_visual)

    maps[#maps + 1] = {
      {
        "<leader>b",
        group = "buffers",
        expand = function()
          return require("which-key.extras").expand.buf()
        end,
      },
    }

    require("which-key").add(maps)
  end,
}
