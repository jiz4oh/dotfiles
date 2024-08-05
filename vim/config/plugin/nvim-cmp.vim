lua<<EOF
local cmp = require('cmp')

local default_sources = {
  -- Copilot Source
  { name = 'copilot' },
  { name = 'vim_lsp' },
  { name = 'nvim_lsp' },
  -- { name = 'vsnip' }, -- For vsnip users.
  { name = 'luasnip' }, -- For luasnip users.
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

local ok2, copilot_cmp = pcall(require, 'copilot_cmp.comparators')
if ok2 then
  table.insert(comparators, 1, copilot_cmp.prioritize)
end

local ok3, tailwindcss_colorizer_cmp = pcall(require, 'tailwindcss-colorizer-cmp')

local ok4, lspkind = pcall(require, 'lspkind')
if ok4 then
  local lspkind_ops = {
    mode = 'symbol_text',
    maxwidth = 50,
    ellipsis_char = '...',
    symbol_map = { Copilot = "" },
  }

  if ok3 then
    lspkind_ops.before = function (entry, vim_item)
      vim_item = tailwindcss_colorizer_cmp.formatter(entry, vim_item)
      return vim_item
    end
  end

  formatter = lspkind.cmp_format(lspkind_ops)
elseif ok3 then
  formatter = tailwindcss_colorizer_cmp.formatter
else
  formatter = function(entry, vim_item)
    return vim_item
  end
end

local ok5, luasnip = pcall(require, 'luasnip')
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
        elseif ok5 and luasnip.locally_jumpable(1) then
          luasnip.jump(1)
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
        elseif ok5 and luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, {"i","s","c",}),
  }),
  sources = cmp.config.sources(default_sources),
  snippet = {
    expand = function(args)
      if ok5 then
        luasnip.lsp_expand(args.body) -- For `luasnip` users.
      end
    end,
  },
  formatting = {
    format = formatter
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
