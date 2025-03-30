local default_sources = {
  -- Copilot Source
  { name = "copilot" },
  { name = "vim_lsp" },
  { name = "nvim_lsp" },
  { name = "nvim_lsp_signature_help" },
  -- { name = 'vsnip' }, -- For vsnip users.
  { name = "luasnip" }, -- For luasnip users.
  -- { name = 'ultisnips' }, -- For ultisnips users.
  -- { name = 'snippy' }, -- For snippy users.
  { name = "cmp_tabnine" },
  {
    name = "kitty",
    option = {
      -- this is where any configuration should be inserted
    },
  },
  { name = "buffer" },
}

return {
  "hrsh7th/nvim-cmp",
  version = false, -- last release is way too old
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "lukas-reineke/cmp-under-comparator",
    "roobert/tailwindcss-colorizer-cmp.nvim",
    "onsails/lspkind.nvim",
  },
  opts = function()
    local cmp = require("cmp")

    local comparators = {
      function(entry1, entry2)
        local ok, plugin = pcall(require, "copilot_cmp.comparators")
        if ok then
          plugin.prioritize(entry1, entry2)
        end
      end,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      function(entry1, entry2)
        local ok, plugin = pcall(require, "cmp-under-comparator")
        if ok then
          plugin.under(entry1, entry2)
        end
      end,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    }

    local ok3, tailwindcss_colorizer_cmp = pcall(require, "tailwindcss-colorizer-cmp")

    local lspkind_ops = {
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
      symbol_map = { Copilot = "" },
    }

    if ok3 then
      lspkind_ops.before = function(entry, vim_item)
        vim_item = tailwindcss_colorizer_cmp.formatter(entry, vim_item)
        return vim_item
      end
    end

    local formatter = require("lspkind").cmp_format(lspkind_ops)

    function load_luasnip()
      local ok, luasnip = pcall(require, "luasnip")
      return ok, luasnip
    end

    return {
      sorting = {
        comparators = comparators,
      },
      mapping = cmp.mapping.preset.insert({
        ["<M-n>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<M-p>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
        ["<CR>"] = cmp.mapping({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end,
          s = cmp.mapping.confirm({ select = true }),
          c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
        }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#confirm-candidate-on-tab-immediately-when-theres-only-one-completion-entry
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            if #cmp.get_entries() == 1 then
              cmp.confirm({ select = true })
            else
              cmp.select_next_item()
            end
          else
            local ok, luasnip = load_luasnip()
            if ok and luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif vim.F.has_words_before() then
              cmp.complete()
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                fallback()
              end
            else
              fallback()
            end
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            local ok, luasnip = load_luasnip()
            if ok and luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end
        end, { "i", "s", "c" }),
      }),
      sources = cmp.config.sources(default_sources),
      formatting = {
        format = formatter,
      },
    }
  end,
  config = function(_, opts)
    local cmp = require("cmp")

    -- https://github.com/zbirenbaum/copilot.lua?tab=readme-ov-file#suggestion
    cmp.event:on("menu_opened", function()
      vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on("menu_closed", function()
      vim.b.copilot_suggestion_hidden = false
    end)

    -- default config
    -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua
    cmp.setup(opts)

    for _, filetypee in ipairs({ "vim", "go", "ruby" }) do
      local sources = vim.tbl_deep_extend("force", {}, default_sources)
      table.insert(sources, { name = "tags", group_index = 2 })
      cmp.setup.filetype(filetypee, {
        sources = sources,
      })
    end

    for _, cmd_type in ipairs({ "/", "?", "@" }) do
      cmp.setup.cmdline(cmd_type, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
          { name = "cmdline_history" },
        },
      })
    end

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = "cmdline_history" },
        { name = "cmdline" },
        { name = "path" },
      }),
    })
  end,
}
