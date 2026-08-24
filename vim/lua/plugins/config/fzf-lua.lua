local picker = require("config.picker")

local function visual_query()
  if vim.fn.mode():match("^[vV\022]") then
    return vim.fn["personal#functions#selected"]()
  end
end

local function tags_query()
  return visual_query() or vim.fn.expand("<cword>")
end

---@type LazyPluginSpec
return {
  "ibhagwan/fzf-lua",
  commit = "05e44d38de0a79c11fba5f7bf8138791b1dbdd1e",
  lazy = false,
  priority = 900,
  dependencies = {
    "junegunn/fzf",
  },
  opts = {
    "fzf-vim",
    defaults = {
      no_hide = true,
    },
    winopts = {
      height = 0.8,
      width = 0.9,
      row = 0.5,
      col = 0.5,
      preview = {
        hidden = false,
        layout = "vertical",
        vertical = "down:60%",
      },
    },
  },
  config = function(_, opts)
    vim.g.fzf_history_dir = vim.g.fzf_history_dir or "~/.local/share/fzf-history"
    vim.g.go_decls_mode = vim.g.go_decls_mode or "fzf"

    if vim.fn.executable("rg") == 1 then
      vim.env.FZF_DEFAULT_COMMAND = 'rg --files --hidden -g "!{.git}/*" 2>/dev/null'
    end
    vim.env.FZF_DEFAULT_OPTS = "--reverse --bind 'change:first,alt-n:page-down,alt-p:page-up,alt-j:preview-down,alt-k:preview-up'"

    local fzf = require("fzf-lua")

    opts.actions = vim.tbl_deep_extend("force", opts.actions or {}, {
      buffers = {
        ["enter"] = fzf.actions.buf_switch_or_edit,
        ["ctrl-x"] = fzf.actions.buf_split,
        ["ctrl-v"] = fzf.actions.buf_vsplit,
        ["ctrl-t"] = fzf.actions.buf_tabedit,
        ["alt-q"] = fzf.actions.buf_sel_to_qf,
        ["alt-l"] = fzf.actions.buf_sel_to_ll,
      },
    })

    fzf.setup(opts)
    picker.setup_commands()

    local function map(modes, lhs, rhs, desc)
      vim.keymap.set(modes, lhs, rhs, { silent = true, desc = desc })
    end

    map("n", "<leader>sP", picker.global, "Open FzfLua Pickers")
    map("n", "<leader>sd", function()
      picker.diagnostics(false)
    end, "Open Buffer Diagnostics Picker")
    map("n", "<leader>sD", function()
      picker.diagnostics(true)
    end, "Open Workspace Diagnostics Picker")
    map({ "n", "x" }, "<leader>s<Space>", function()
      picker.rg(visual_query())
    end, "Search with ripgrep")
    map("n", "<leader>ss", picker.bookmarks, "Search bookmarks")
    map({ "n", "x" }, "<leader>si", function()
      picker.paths(visual_query())
    end, "Search configured paths")
    map({ "n", "x" }, "<leader>sq", function()
      picker.quickfix(visual_query())
    end, "Search quickfix list")
    map({ "n", "x" }, "<leader>sp", function()
      picker.project_grep(visual_query())
    end, "Search current project")
    map({ "n", "x" }, "<leader>sg", function()
      picker.packages({ args = visual_query() or "", fargs = {} })
    end, "Search packages")
    map("n", "<leader>pp", picker.projects, "Search projects")
    map("n", "<leader>s]", picker.tags, "Search tags")
    map("n", "<leader>sb", picker.lines, "Search buffer lines")
    map("n", "<leader>s'", picker.marks, "Search marks")
    map("n", "<leader>sr", picker.recent, "Search recent files")
    map("n", "<leader>sF", picker.lsp_symbols, "Search document symbols")
    map("n", "<leader>s:", picker.command_history, "Search command history")
    map("n", "<leader>s/", picker.search_history, "Search search history")
    map({ "n", "x" }, "<C-]>", function()
      picker.tags(tags_query())
    end, "Search tags")
    map("n", "<leader>ld", picker.lsp_definitions, "Find definitions")
    map("n", "<leader>lD", picker.lsp_declarations, "Find declarations")
    map("n", "<leader>li", picker.lsp_implementations, "Find implementations")
    map("n", "<leader>lr", picker.lsp_references, "Find references")
    map("n", "<leader>lt", picker.lsp_type_definitions, "Find type definitions")

    local function keymaps(modes)
      fzf.keymaps({ modes = modes })
    end

    vim.keymap.set("n", "<M-Tab>", function() keymaps({ "n" }) end, {
      silent = true,
      desc = "Search normal-mode mappings",
    })
    vim.keymap.set("i", "<M-Tab>", function() keymaps({ "i" }) end, {
      silent = true,
      desc = "Search insert-mode mappings",
    })
    vim.keymap.set("x", "<M-Tab>", function() keymaps({ "x" }) end, {
      silent = true,
      desc = "Search visual-mode mappings",
    })
    vim.keymap.set("o", "<M-Tab>", function() keymaps({ "o" }) end, {
      silent = true,
      desc = "Search operator-pending mappings",
    })

    vim.keymap.set("i", "<C-x><C-k>", function()
      local dictionaries = vim.split(vim.o.dictionary, ",", { trimempty = true })
      if #dictionaries == 0 then
        dictionaries = { "/usr/share/dict/words" }
      end

      local existing = vim.tbl_filter(function(path)
        return vim.fn.filereadable(vim.fn.expand(path)) == 1
      end, dictionaries)
      if #existing == 0 then
        vim.notify("No dictionary file is available", vim.log.levels.WARN, { title = "FzfLua" })
        return
      end

      local command = "cat " .. table.concat(vim.tbl_map(vim.fn.shellescape, existing), " ")
      fzf.fzf_exec(command, {
        prompt = "Word> ",
        complete = true,
        fzf_opts = { ["--no-multi"] = true },
      })
    end, { silent = true, desc = "Fuzzy complete dictionary word" })

    vim.keymap.set("i", "<C-x><C-f>", function()
      fzf.complete_path()
    end, { silent = true, desc = "Fuzzy complete path" })

    vim.keymap.set("i", "<C-x><C-l>", function()
      fzf.complete_line()
    end, { silent = true, desc = "Fuzzy complete line" })
  end,
}
