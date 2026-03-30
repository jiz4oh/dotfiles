local opts = {
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
    disable = { "git", "gitcommit", "json" },
    additional_vim_regex_highlighting = { "embedded_template", "ruby" },
  },
}

if vim.g.with_treesitter == 1 then
  opts = vim.tbl_deep_extend("force", opts, {
    auto_install = true,
  })
end

if vim.fn.has("nvim-0.12") == 1 then
  build = function()
    local ok, m = pcall(require, "nvim-treesitter.install")
    if ok then
      m.update({ with_sync = true })
    end
  end
else
  build = ":TSUpdate"
  branch = "master"
end

local set_treesitter = function(event)
  if vim.fn.has("nvim-0.12") ~= 1 then
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
      if parsers.has_parser(filetype) then
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.cmd("normal! zvzz")
      end
    end
  else
    local function start_treesitter(buf, lang)
      if not vim.treesitter.language.add(lang) then
        return
      end
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.treesitter.start(buf, lang)
    end

    local function ensure_parser(buf, lang)
      if vim.tbl_contains(require("nvim-treesitter").get_installed("parsers"), lang) then
        start_treesitter(buf, lang)
      else
        require("nvim-treesitter").install(lang):await(function()
          start_treesitter(buf, lang)
        end)
      end
    end

    local buf = event.buf
    local ft = event.match
    local lang = vim.treesitter.language.get_lang(ft)
    if not lang then
      return
    end

    if not vim.tbl_contains(require("nvim-treesitter").get_available(), lang) then
      return
    end
    ensure_parser(buf, lang)
  end
end

---@type LazyPluginSpec
return {
  "nvim-treesitter/nvim-treesitter",
  optional = true,
  build = build,
  branch = branch,
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  enabled = vim.fn.has("nvim-0.10") == 1,
  lazy = false,
  opts = opts,
  init = function(plugin)
    -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
    -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
    -- no longer trigger the **nvim-treesitter** module to be loaded in time.
    -- Luckily, the only things that those plugins need are the custom queries, which we make available
    -- during startup.
    require("lazy.core.loader").add_to_rtp(plugin)
    pcall(require, "nvim-treesitter.query_predicates")
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      group = vim.api.nvim_create_augroup("ts_setup", {}),
      callback = set_treesitter,
    })
  end,
  config = function(_, opts)
    if vim.fn.has("nvim-0.12") ~= 1 then
      require("nvim-treesitter.configs").setup(opts)
    end
  end,
  specs = {
    {
      "hedyhli/outline.nvim",
      optional = true,
      dependencies = {
        "epheien/outline-treesitter-provider.nvim",
      },
      opts = function(_, opts)
        if opts.providers == nil then
          return opts
        end

        if opts.providers.priority == nil then
          opts.providers.priority = { "lsp", "treesitter" }
          return opts
        end

        local i = #opts.providers.priority + 1
        for index, v in ipairs(opts.providers.priority) do
          if v == "ctags" then
            i = index
            break
          end
        end

        table.insert(opts.providers.priority, i, "treesitter")
      end,
    },
  },
}
