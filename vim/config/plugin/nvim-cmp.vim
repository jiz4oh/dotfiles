lua<<EOF
local cmp = require('cmp')

local default_sources = {
  -- Copilot Source
  { name = 'copilot' },
  { name = 'vim_lsp' },
  { name = 'nvim_lsp' },
  -- { name = 'vsnip' }, -- For vsnip users.
  -- { name = 'luasnip' }, -- For luasnip users.
  -- { name = 'ultisnips' }, -- For ultisnips users.
  -- { name = 'snippy' }, -- For snippy users.
  { name = 'cmp_tabnine' },
  { name = 'kitty',
      option = {
          -- this is where any configuration should be inserted
      }
  },
  {
      name = 'spell',
      option = {
          keep_all_entries = false,
          enable_in_context = function()
              return true
          end,
      },
  },
  { name = 'buffer' },
}

local comparators
local ok1, under_comparator = pcall(require, 'cmp-under-comparator')
if ok1 then
  comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    cmp.config.compare.score,
    cmp.config.compare.recently_used,
    cmp.config.compare.locality,
    under_comparator.under,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
  }
else
  comparators = {
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    cmp.config.compare.score,
    cmp.config.compare.recently_used,
    cmp.config.compare.locality,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
  }
end

-- default config
-- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
cmp.setup({
  sorting = {
    comparators = comparators,
  },
  mapping = cmp.mapping.preset.insert({
    ['<M-n>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<M-p>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          if vim.fn.pumvisible() == 1 then
            cmp.complete()
          else
            cmp.select_next_item()
          end
        else
          fallback()
        end
      end, {"i","s","c",}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          if vim.fn.pumvisible() == 1 then
            cmp.complete()
          else
            cmp.select_prev_item()
          end
        else
          fallback()
        end
      end, {"i","s","c",}),
  }),
  sources = cmp.config.sources(default_sources),
  snippet = {
    -- We recommend using *actual* snippet engine.
    -- It's a simple implementation so it might not work in some of the cases.
    expand = function(args)
      local line_num, col = unpack(vim.api.nvim_win_get_cursor(0))
      local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, true)[1]
      local indent = string.match(line_text, '^%s*')
      local replace = vim.split(args.body, '\n', true)
      local surround = string.match(line_text, '%S.*') or ''
      local surround_end = surround:sub(col)

      replace[1] = surround:sub(0, col - 1)..replace[1]
      replace[#replace] = replace[#replace]..(#surround_end > 1 and ' ' or '')..surround_end
      if indent ~= '' then
        for i, line in ipairs(replace) do
         replace[i] = indent..line
        end
      end

      vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, true, replace)
    end,
  },
  formatting = {
    format = require("tailwindcss-colorizer-cmp").formatter
  }
})

for _, filetypee in ipairs({'vim', 'go', 'ruby'}) do
  local sources = vim.tbl_deep_extend('force', {}, default_sources)
  table.insert(sources, { name = 'tags', group_index = 2 })
  cmp.setup.filetype(filetypee, {
    sources = sources
  })
end

for _, cmd_type in ipairs({'/', '?', '@'}) do
  cmp.setup.cmdline(cmd_type, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
      { name = 'cmdline_history' },
    },
  })
end

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'cmdline_history' },
    { name = 'cmdline' },
    { name = 'path' },
  })
})

for _, file_type in ipairs({ 'sql', 'mysql', 'plsql'}) do
  cmp.setup.filetype(file_type, {
    sources = cmp.config.sources({
      { name = 'vim-dadbod-completion' },
    })
  })
end
EOF
