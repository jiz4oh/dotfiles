local M = {}

local default_bookmarks = {
  function()
    return vim.env.MYVIMRC
  end,
  function()
    return vim.env.HOME .. "/.local/share/chezmoi/"
  end,
  function()
    return vim.env.HOME .. "/.Trash"
  end,
  function()
    return vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs"
  end,
}

local legacy_bookmark_file = vim.fn.expand("~/.cache/startify_bookmarks")
local bookmark_file = vim.fn.stdpath("state") .. "/bookmarks"
local custom_commands_ready = false

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Picker" })
end

local function fzf_lua()
  local ok, picker = pcall(require, "fzf-lua")
  if ok then
    return picker
  end

  notify("fzf-lua is not available", vim.log.levels.ERROR)
end

local function trim(value)
  if value == nil then
    return nil
  end
  value = vim.trim(tostring(value))
  return value ~= "" and value or nil
end

local function copy_options(options)
  return vim.deepcopy(options or {})
end

local function set_search_register(query)
  query = trim(query)
  if query and query ~= "" then
    vim.fn.setreg("/", query)
  end
  return query
end

local function with_fullscreen(options, fullscreen)
  options = copy_options(options)
  if fullscreen then
    options.winopts = vim.tbl_deep_extend("force", options.winopts or {}, { fullscreen = true })
  end
  return options
end

local function repo_root()
  local ok, root = pcall(vim.fn["personal#git#Repo"])
  if ok and root ~= "" then
    return root
  end
end

local function paths_from_option()
  local paths = {}
  local seen = {}

  for _, value in ipairs(vim.opt.path:get()) do
    local path = vim.fn.expand(value)
    if path ~= "" and not path:find("[*?]", 1) and vim.fn.isdirectory(path) == 1 then
      path = vim.fn.fnamemodify(path, ":p")
      if not seen[path] then
        seen[path] = true
        table.insert(paths, path)
      end
    end
  end

  if #paths == 0 then
    table.insert(paths, vim.fn.getcwd())
  end
  return paths
end

local function rg_options()
  local ignore_file = "/tmp/rgignore-for-vim"
  local wildignore = vim.split(vim.o.wildignore, ",", { trimempty = true })
  pcall(vim.fn.writefile, wildignore, ignore_file)
  local options = {
    "--hidden",
    "--no-ignore-vcs",
    "--column",
    "--line-number",
    "--no-heading",
    "--color=always",
    "--smart-case",
    "--follow",
    "-F",
    "-e",
  }

  if #wildignore > 0 then
    table.insert(options, 3, "--ignore-file " .. vim.fn.shellescape(ignore_file))
  end
  return table.concat(options, " ")
end

local function grep_options(query, dirs, options)
  local opts = vim.tbl_deep_extend("force", {
    rg_opts = rg_options(),
    no_esc = true,
    rg_glob = false,
  }, copy_options(options))
  opts.search = query or ""
  if dirs then
    opts.search_paths = dirs
  end
  return opts
end

function M.grep(query, dirs, options)
  local picker = fzf_lua()
  if picker then
    picker.grep(grep_options(set_search_register(query), dirs, options))
  end
end

function M.rg(query, options)
  local picker = fzf_lua()
  if picker then
    picker.live_grep(grep_options(set_search_register(query), nil, options))
  end
end

function M.project_grep(query, options)
  local cwd = vim.fn.getcwd()
  local opts = copy_options(options)
  opts.cwd = cwd
  opts.search_paths = { cwd }
  opts.prompt = cwd
  M.grep(query, nil, opts)
end

function M.git_grep(query, options)
  local root = repo_root()
  if not root then
    notify("Not inside a Git repository", vim.log.levels.WARN)
    return
  end

  local opts = copy_options(options)
  opts.cwd = root
  M.grep(query, { root }, opts)
end

function M.paths(query, options)
  M.grep(query, paths_from_option(), options)
end

function M.files(query, options)
  local picker = fzf_lua()
  if picker then
    picker.files(vim.tbl_deep_extend("force", {
      query = trim(query),
      hidden = true,
      follow = true,
    }, copy_options(options)))
  end
end

function M.projects(options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local projects = vim.g.projects or {}
  if #projects == 0 then
    notify("No projects found", vim.log.levels.WARN)
    return
  end

  picker.fzf_exec(projects, vim.tbl_deep_extend("force", {
    prompt = "Projects> ",
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["enter"] = function(selected)
        local project = selected and selected[1]
        if project and vim.fn.isdirectory(project) == 1 then
          vim.cmd("tcd " .. vim.fn.fnameescape(project))
          notify("cwd: " .. vim.fn.getcwd())
        end
      end,
    },
  }, copy_options(options)))
end

function M.lines(query, options)
  local picker = fzf_lua()
  if picker then
    picker.lines(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

function M.marks(query, options)
  local picker = fzf_lua()
  if picker then
    picker.marks(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

function M.tags(query, options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local opts = vim.tbl_deep_extend("force", {
    cwd = repo_root() or vim.fn.getcwd(),
    query = trim(query),
    fzf_opts = {
      ["--exact"] = true,
      ["--select-1"] = true,
      ["+i"] = true,
    },
  }, copy_options(options))
  picker.tags(opts)
end

function M.quickfix(query, options)
  local picker = fzf_lua()
  if picker then
    picker.quickfix(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

function M.recent(query, options)
  M.mru(query, options)
end

function M.command_history(query, options)
  local picker = fzf_lua()
  if picker then
    picker.command_history(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

function M.search_history(query, options)
  local picker = fzf_lua()
  if picker then
    picker.search_history(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

function M.history(kind, query, options)
  if kind == ":" then
    M.command_history(query, options)
  elseif kind == "/" then
    M.search_history(query, options)
  else
    M.recent(query, options)
  end
end

function M.global(options)
  local picker = fzf_lua()
  if picker then
    picker.global(copy_options(options))
  end
end

function M.diagnostics(workspace, options)
  local picker = fzf_lua()
  if not picker then
    return
  end
  local provider = workspace and picker.diagnostics_workspace or picker.diagnostics_document
  provider(copy_options(options))
end

function M.lsp_definitions()
  local picker = fzf_lua()
  if picker then
    picker.lsp_definitions()
  else
    vim.lsp.buf.definition({ on_list = vim.lsp.on_list })
  end
end

function M.lsp_declarations()
  local picker = fzf_lua()
  if picker then
    picker.lsp_declarations()
  else
    vim.lsp.buf.declaration({ on_list = vim.lsp.on_list })
  end
end

function M.lsp_type_definitions()
  local picker = fzf_lua()
  if picker then
    picker.lsp_typedefs()
  else
    vim.lsp.buf.type_definition({ on_list = vim.lsp.on_list })
  end
end

function M.lsp_implementations()
  local picker = fzf_lua()
  if picker then
    picker.lsp_implementations()
  else
    vim.lsp.buf.implementation({ on_list = vim.lsp.on_list })
  end
end

function M.lsp_references()
  local picker = fzf_lua()
  if picker then
    picker.lsp_references({ includeDeclaration = false })
  else
    vim.lsp.buf.references({ includeDeclaration = false }, { on_list = vim.lsp.on_list })
  end
end

function M.lsp_symbols()
  local picker = fzf_lua()
  if picker then
    picker.lsp_document_symbols()
  else
    vim.lsp.buf.document_symbol({ on_list = vim.lsp.on_list })
  end
end

function M.lsp_workspace_symbols(query)
  local picker = fzf_lua()
  if picker then
    picker.lsp_workspace_symbols({ lsp_query = trim(query) })
  else
    vim.lsp.buf.workspace_symbol(trim(query), { on_list = vim.lsp.on_list })
  end
end

function M.fzf_funky(query, options)
  local picker = fzf_lua()
  if picker then
    picker.treesitter(vim.tbl_deep_extend("force", { query = trim(query) }, copy_options(options)))
  end
end

local function mru_stat_file(path)
  local normalized = vim.fn.fnamemodify(path, ":p")
  local excluded = {
    "^/tmp/",
    "^/var/tmp/",
    "^/private/var/",
    "%.git/.+MSG$",
    "Session%.vim$",
  }
  for _, pattern in ipairs(excluded) do
    if normalized:match(pattern) then
      return false
    end
  end

  local session_dir = vim.g.session_dir and vim.fn.fnamemodify(vim.fn.expand(vim.g.session_dir), ":p")
  if session_dir and session_dir ~= "" and normalized:sub(1, #session_dir) == session_dir then
    return false
  end
  return vim.fn.filereadable(path) == 1
end

function M.mru(query, options)
  local picker = fzf_lua()
  if picker then
    picker.oldfiles(vim.tbl_deep_extend("force", {
      query = trim(query),
      include_current_session = true,
      ignore_current_buffer = false,
      stat_file = mru_stat_file,
      prompt = "MRU> ",
      fzf_opts = { ["--no-sort"] = true, ["--no-multi"] = true },
    }, copy_options(options)))
  end
end

function M.fresh_mru(query, options)
  vim.cmd("silent! wshada")
  M.mru(query, options)
end

local function file_actions(picker, extra)
  return vim.tbl_extend("force", {
    ["enter"] = picker.actions.file_edit_or_qf,
    ["ctrl-x"] = picker.actions.file_split,
    ["ctrl-v"] = picker.actions.file_vsplit,
    ["ctrl-t"] = picker.actions.file_tabedit,
    ["alt-q"] = picker.actions.file_sel_to_qf,
    ["alt-l"] = picker.actions.file_sel_to_ll,
  }, extra or {})
end

local function buffer_actions(picker, extra)
  return vim.tbl_extend("force", file_actions(picker, {
    ["enter"] = picker.actions.buf_switch_or_edit,
  }), extra or {})
end

function M.buffers(query, options)
  local picker = fzf_lua()
  if picker then
    picker.buffers(vim.tbl_deep_extend("force", {
      query = trim(query),
      actions = buffer_actions(picker),
    }, copy_options(options)))
  end
end

function M.bmarks(query, options)
  local picker = fzf_lua()
  if picker then
    picker.marks(vim.tbl_deep_extend("force", {
      marks = "^[a-z]$",
      query = trim(query),
    }, copy_options(options)))
  end
end

function M.locate(query, options)
  local picker = fzf_lua()
  if not picker then
    return
  end
  if vim.fn.executable("locate") == 0 then
    notify("locate is not installed", vim.log.levels.ERROR)
    return
  end

  query = set_search_register(query)
  if not query or query == "" then
    notify("Locate requires a pattern", vim.log.levels.WARN)
    return
  end

  local command = "locate " .. vim.fn.shellescape(query)
  picker.fzf_exec(command, vim.tbl_deep_extend("force", {
    prompt = "Locate> ",
    query = query,
    fzf_opts = { ["--multi"] = true },
    actions = file_actions(picker),
  }, copy_options(options)))
end

function M.ag(query, options)
  local picker = fzf_lua()
  if not picker then
    return
  end
  if vim.fn.executable("ag") == 0 then
    notify("ag is not installed", vim.log.levels.ERROR)
    return
  end

  query = set_search_register(query) or "^(?=.)"
  local grep_opts = vim.tbl_deep_extend("force", {
    cmd = "ag --nogroup --column --color always --",
    no_esc = true,
    rg_glob = false,
    fzf_opts = { ["--multi"] = true },
    actions = file_actions(picker),
  }, copy_options(options))
  if query ~= nil then
    grep_opts.search = query
  end
  picker.grep(grep_opts)
end

local function open_directory(path, command)
  if not path or vim.fn.isdirectory(path) ~= 1 then
    return
  end
  if command then
    vim.cmd(command)
  end
  local ok, oil = pcall(require, "oil")
  if ok then
    oil.open(path)
  else
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

function M.path(query, options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local paths = paths_from_option()
  local selected_query = set_search_register(query)
  picker.fzf_exec(paths, vim.tbl_deep_extend("force", {
    prompt = "Path> ",
    query = selected_query,
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["enter"] = function(selected)
        local path = selected and selected[1]
        if path then
          M.grep(selected_query, { path }, options)
        end
      end,
      ["ctrl-l"] = function()
        M.paths(selected_query, options)
      end,
      ["ctrl-t"] = function(selected)
        open_directory(selected and selected[1], "tabnew")
      end,
      ["ctrl-x"] = function(selected)
        open_directory(selected and selected[1], "split")
      end,
      ["ctrl-v"] = function(selected)
        open_directory(selected and selected[1], "vsplit")
      end,
    },
  }, copy_options(options)))
end

function M.windows(options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local entries = {}
  local windows = {}
  for tab, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for win, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      local buffer = vim.api.nvim_win_get_buf(winid)
      local name = vim.api.nvim_buf_get_name(buffer)
      name = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":~:.")
      local modified = vim.bo[buffer].modified and " [+]" or ""
      local current = winid == vim.api.nvim_get_current_win() and ">" or " "
      local entry = string.format("%s %3d %3d  %s%s", current, tab, win, name, modified)
      table.insert(entries, entry)
      windows[entry] = { tabpage = tabpage, winid = winid }
    end
  end

  picker.fzf_exec(entries, vim.tbl_deep_extend("force", {
    prompt = "Windows> ",
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["enter"] = function(selected)
        local target = selected and windows[selected[1]]
        if target then
          pcall(vim.api.nvim_set_current_tabpage, target.tabpage)
          pcall(vim.api.nvim_set_current_win, target.winid)
        end
      end,
    },
  }, copy_options(options)))
end

function M.snippets(options)
  local picker = fzf_lua()
  if not picker then
    return
  end
  if vim.fn.exists(":UltiSnipsEdit") == 0 then
    notify("UltiSnips not found", vim.log.levels.WARN)
    return
  end

  local ok, snippets = pcall(vim.fn["UltiSnips#SnippetsInCurrentScope"])
  if not ok or type(snippets) ~= "table" or vim.tbl_isempty(snippets) then
    notify("No snippets available here", vim.log.levels.WARN)
    return
  end

  local entries = {}
  for trigger, description in pairs(snippets) do
    table.insert(entries, trigger .. "\t" .. tostring(description))
  end
  table.sort(entries)

  picker.fzf_exec(entries, vim.tbl_deep_extend("force", {
    prompt = "Snippets> ",
    fzf_opts = {
      ["--no-multi"] = true,
      ["--delimiter"] = "\t",
      ["--with-nth"] = "1..",
    },
    actions = {
      ["enter"] = function(selected)
        local trigger = selected and selected[1] and selected[1]:match("^[^\t]+")
        if not trigger then
          return
        end
        local keys = vim.api.nvim_replace_termcodes(
          "a" .. trigger .. "<C-R>=UltiSnips#ExpandSnippet()<CR>",
          true,
          false,
          true
        )
        vim.api.nvim_feedkeys(keys, "n", false)
      end,
    },
  }, copy_options(options)))
end

local function normalize_path(path)
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

local function bookmark_path(path)
  path = trim(path) or vim.fn.expand("%:p")
  if path == "" then
    return ""
  end
  return normalize_path(path)
end

local function read_bookmarks(path)
  if vim.fn.filereadable(path) == 0 then
    return {}
  end

  local result = {}
  for _, value in ipairs(vim.fn.readfile(path)) do
    value = trim(value)
    if value and value ~= "" then
      table.insert(result, normalize_path(value))
    end
  end
  return result
end

local function unique(values)
  local result = {}
  local seen = {}
  for _, value in ipairs(values) do
    if value ~= "" and not seen[value] then
      seen[value] = true
      table.insert(result, value)
    end
  end
  return result
end

function M.bookmark_data()
  local defaults = {}
  for _, value in ipairs(default_bookmarks) do
    local path = value()
    if path and path ~= "" then
      table.insert(defaults, normalize_path(path))
    end
  end
  defaults = unique(defaults)

  local default_set = {}
  for _, path in ipairs(defaults) do
    default_set[path] = true
  end

  local stored = read_bookmarks(bookmark_file)
  -- Read the Startify file only until the new state file is written. This makes
  -- deletion persistent while still importing existing bookmarks lazily.
  if vim.fn.filereadable(bookmark_file) == 0 then
    vim.list_extend(stored, read_bookmarks(legacy_bookmark_file))
  end
  local user = unique(stored)
  user = vim.tbl_filter(function(path)
    return not default_set[path]
  end, user)
  return defaults, user
end

local function save_bookmarks(bookmarks)
  vim.fn.mkdir(vim.fn.fnamemodify(bookmark_file, ":h"), "p")
  vim.fn.writefile(bookmarks, bookmark_file)
end

function M.add_bookmark(path)
  local bookmark = bookmark_path(path)
  if bookmark == "" then
    notify("Current buffer has no file path", vim.log.levels.WARN)
    return
  end

  local defaults, user = M.bookmark_data()
  if vim.tbl_contains(defaults, bookmark) or vim.tbl_contains(user, bookmark) then
    notify("Bookmark already exists: " .. vim.fn.fnamemodify(bookmark, ":~:."), vim.log.levels.WARN)
    return
  end

  table.insert(user, bookmark)
  save_bookmarks(user)
  notify("Bookmark added: " .. vim.fn.fnamemodify(bookmark, ":~:."))
end

local function bookmark_entries(delete_mode)
  local defaults, user = bookmark_data()
  local entries = {}
  local lookup = {}

  local function add(path, removable)
    local display = vim.fn.fnamemodify(path, ":~:.")
    if not removable then
      display = display .. " [default]"
    end
    local entry = display .. "\t" .. path
    table.insert(entries, entry)
    lookup[entry] = { path = path, removable = removable }
  end

  for _, path in ipairs(defaults) do
    add(path, false)
  end
  for _, path in ipairs(user) do
    add(path, true)
  end
  return entries, lookup, delete_mode and "Delete Bookmark" or "Bookmarks"
end

function M.open_bookmark(path)
  if vim.fn.isdirectory(path) == 1 then
    open_directory(path)
  else
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end
end

local function bookmark_input()
  vim.schedule(function()
    vim.ui.input({ prompt = "Bookmark path: ", default = vim.fn.expand("%:p") }, function(value)
      if value and value ~= "" then
        M.add_bookmark(value)
      end
    end)
  end)
end

local function bookmark_picker(delete_mode)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local entries, lookup, title = bookmark_entries(delete_mode)
  picker.fzf_exec(entries, {
    prompt = title .. "> ",
    fzf_opts = {
      ["--no-multi"] = true,
      ["--delimiter"] = "\t",
      ["--with-nth"] = "1",
    },
    actions = {
      ["enter"] = function(selected)
        local item = selected and lookup[selected[1]]
        if not item then
          return
        end
        if delete_mode then
          if item.removable then
            M.delete_bookmark(item.path)
          else
            notify("Default bookmarks cannot be deleted", vim.log.levels.WARN)
          end
        else
          M.open_bookmark(item.path)
        end
      end,
      ["ctrl-a"] = not delete_mode and bookmark_input or nil,
      ["ctrl-x"] = function(selected)
        local item = selected and lookup[selected[1]]
        if not item then
          return
        end
        if item.removable then
          M.delete_bookmark(item.path)
        else
          notify("Default bookmarks cannot be deleted", vim.log.levels.WARN)
        end
      end,
    },
  })
end

function M.delete_bookmark(path)
  path = path and bookmark_path(path) or nil
  if not path then
    bookmark_picker(true)
    return
  end

  local _, user = bookmark_data()
  if not vim.tbl_contains(user, path) then
    notify("User bookmark not found: " .. vim.fn.fnamemodify(path, ":~:."), vim.log.levels.WARN)
    return
  end

  user = vim.tbl_filter(function(value)
    return value ~= path
  end, user)
  save_bookmarks(user)
  notify("Bookmark deleted: " .. vim.fn.fnamemodify(path, ":~:."))
end

function M.bookmarks()
  bookmark_picker(false)
end

local function package_filetypes()
  return { "ruby", "go", "vim", "javascript" }
end

local function package_prompt(filetype)
  return ({ ruby = "Gem", go = "Pkg", vim = "Plugin", javascript = "Module" })[filetype] or "Package"
end

local function add_package(result, name, path)
  if type(name) == "string" and name ~= "" and type(path) == "string" and path ~= "" then
    result[name] = path
  end
end

local function package_from_vimscript(filetype)
  local function_name = "select#packages#" .. filetype .. "#packages"
  if vim.fn.exists("*" .. function_name) == 0 then
    return {}
  end

  local ok, packages = pcall(vim.fn[function_name])
  if not ok or type(packages) ~= "table" then
    return {}
  end

  local result = {}
  for name, value in pairs(packages) do
    local path = type(value) == "table" and (value.dir or value.path) or value
    add_package(result, name, path)
  end
  return result
end

local function package_ruby()
  local result = package_from_vimscript("ruby")
  if next(result) then
    return result
  end

  if vim.fn.executable("bundle") == 1
      and (vim.fn.filereadable("Gemfile") == 1 or vim.fn.filereadable("Gemfile.lock") == 1)
  then
    local output = vim.fn.systemlist("bundle show --paths")
    if vim.v.shell_error == 0 then
      for _, path in ipairs(output) do
        path = vim.trim(path)
        if path ~= "" and vim.fn.isdirectory(path) == 1 then
          add_package(result, vim.fn.fnamemodify(path, ":t"), path)
        end
      end
    end
  end

  if next(result) then
    return result
  end

  local delimiter = vim.fn.has("win32") == 1 and ";" or ":"
  local output = vim.fn.systemlist("gem env path")
  if vim.v.shell_error ~= 0 or not output[1] then
    return result
  end

  for _, gem_path in ipairs(vim.split(output[1], delimiter, { trimempty = true })) do
    local gems = vim.fn.fnamemodify(gem_path .. "/gems", ":p")
    if vim.fn.isdirectory(gems) == 1 then
      for _, name in ipairs(vim.fn.readdir(gems)) do
        local path = gems .. name
        if vim.fn.isdirectory(path) == 1 then
          add_package(result, name, path)
        end
      end
    end
  end
  return result
end

local function walk_directories(root, callback)
  if vim.fn.isdirectory(root) ~= 1 then
    return
  end
  local ok, entries = pcall(vim.fs.dir, root)
  if not ok then
    return
  end
  for name, kind in entries do
    if kind == "directory" and name ~= "cache" then
      local path = vim.fs.joinpath(root, name)
      local descend = callback(path, name)
      if descend ~= false then
        walk_directories(path, callback)
      end
    end
  end
end

local function package_go()
  local result = package_from_vimscript("go")
  if next(result) then
    return result
  end

  local gopath = vim.env.GOPATH
  if not gopath or gopath == "" then
    local output = vim.fn.systemlist("go env GOPATH")
    gopath = output[1]
  end
  if not gopath or gopath == "" then
    return result
  end

  local delimiter = vim.fn.has("win32") == 1 and ";" or ":"
  local roots = {}
  for _, root in ipairs(vim.split(gopath, delimiter, { trimempty = true })) do
    table.insert(roots, vim.fs.joinpath(root, "pkg", "mod"))
    table.insert(roots, vim.fs.joinpath(root, "src"))
  end
  for _, root in ipairs(roots) do
    walk_directories(root, function(path)
      local relative = path:sub(#root + 2)
      if relative ~= "" then
        add_package(result, relative, path)
      end
      return not vim.fn.fnamemodify(path, ":t"):match("@v%d+%.%d+%.%d+$")
    end)
  end
  return result
end

local function project_root()
  local ok, root = pcall(vim.fn["personal#project#find_home"])
  if ok and root and root ~= "" then
    return root
  end

  local ok_find, matches = pcall(vim.fs.find, { "package.json" }, { upward = true, path = vim.fn.getcwd() })
  if ok_find and matches[1] then
    return vim.fn.fnamemodify(matches[1], ":h")
  end
  return vim.fn.getcwd()
end

local function json_file(path)
  if vim.fn.filereadable(path) == 0 then
    return {}
  end
  local ok, value = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
  return ok and type(value) == "table" and value or {}
end

local function package_javascript()
  local result = package_from_vimscript("javascript")
  if next(result) then
    return result
  end

  local root = project_root()
  local package_json = json_file(vim.fs.joinpath(root, "package.json"))
  local dependencies = {}
  for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies", "optionalDependencies" }) do
    for name, _ in pairs(package_json[field] or {}) do
      dependencies[name] = true
    end
  end

  local node_modules = vim.fs.joinpath(root, "node_modules")
  if vim.fn.isdirectory(node_modules) == 1 then
    for name in vim.fn.readdir(node_modules) do
      local path = vim.fs.joinpath(node_modules, name)
      if name:sub(1, 1) == "@" and vim.fn.isdirectory(path) == 1 then
        for scoped_name in vim.fn.readdir(path) do
          local scoped_path = vim.fs.joinpath(path, scoped_name)
          local data = json_file(vim.fs.joinpath(scoped_path, "package.json"))
          add_package(result, data.name or (name .. "/" .. scoped_name), scoped_path)
        end
      else
        local data = json_file(vim.fs.joinpath(path, "package.json"))
        add_package(result, data.name or name, path)
      end
    end
  end
  return result
end

local function package_vim()
  local result = package_from_vimscript("vim")
  if next(result) then
    return result
  end

  add_package(result, "$VIMRUNTIME", vim.env.VIMRUNTIME)
  for _, path in ipairs(vim.split(vim.o.runtimepath, ",", { trimempty = true })) do
    if not path:match("/after$") and vim.fn.isdirectory(path) == 1 then
      add_package(result, vim.fn.fnamemodify(path, ":t"), path)
    end
  end

  local ok, lazy_config = pcall(require, "lazy.core.config")
  if ok and lazy_config.plugins then
    for name, plugin in pairs(lazy_config.plugins) do
      if plugin.dir then
        add_package(result, name, plugin.dir)
      end
    end
  end
  return result
end

local package_loaders = {
  ruby = package_ruby,
  go = package_go,
  vim = package_vim,
  javascript = package_javascript,
}

local function package_data(filetype)
  local loader = package_loaders[filetype]
  return loader and loader() or {}
end

local function package_items(filetype)
  local packages = package_data(filetype)
  local items = {}
  for name, path in pairs(packages) do
    table.insert(items, { name = name, path = path })
  end
  table.sort(items, function(a, b)
    return a.name < b.name
  end)
  return items
end

local function package_content_picker(filetype, query)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local items = package_items(filetype)
  local paths = vim.tbl_map(function(item)
    return item.path
  end, items)
  if #paths == 0 then
    notify("No packages found for " .. filetype, vim.log.levels.WARN)
    return
  end

  M.grep(query or "", paths, { prompt = package_prompt(filetype) .. "> " })
end

local function package_picker(filetype, query)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local items = package_items(filetype)
  if #items == 0 then
    notify("No packages found for " .. filetype, vim.log.levels.WARN)
    return
  end

  local entries = {}
  local lookup = {}
  for _, item in ipairs(items) do
    local entry = item.name .. "\t" .. item.path
    table.insert(entries, entry)
    lookup[entry] = item
  end

  picker.fzf_exec(entries, {
    prompt = package_prompt(filetype) .. "> ",
    query = trim(query),
    fzf_opts = {
      ["--delimiter"] = "\t",
      ["--with-nth"] = "1",
      ["--no-multi"] = true,
    },
    actions = {
      ["enter"] = function(selected)
        local item = selected and lookup[selected[1]]
        if item then
          M.grep(query or "", { item.path }, { prompt = item.name .. "> " })
        end
      end,
      ["ctrl-l"] = function()
        package_content_picker(filetype, query)
      end,
    },
  })
end

function M.packages(args)
  args = args or {}
  local filetypes = package_filetypes()
  local filetype = vim.bo.filetype
  local query
  local first = args.fargs and args.fargs[1]

  if first and vim.tbl_contains(filetypes, first) then
    filetype = first
    local query_parts = {}
    for index = 2, #args.fargs do
      table.insert(query_parts, args.fargs[index])
    end
    query = table.concat(query_parts, " ")
  else
    query = args.args or ""
  end

  if vim.tbl_contains(filetypes, filetype) then
    package_picker(filetype, query)
    return
  end

  local picker = fzf_lua()
  if not picker then
    return
  end
  picker.fzf_exec(filetypes, {
    prompt = "Select package type> ",
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["enter"] = function(selected)
        if selected and selected[1] then
          package_picker(selected[1], query)
        end
      end,
    },
  })
end

function M.compilers(options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local compilers = vim.fn.globpath(vim.o.runtimepath, "compiler/*.vim", false, true)
  if vim.fn.has("packages") == 1 then
    vim.list_extend(compilers, vim.fn.globpath(vim.o.packpath, "pack/*/opt/*/compiler/*.vim", false, true))
  end
  local names = {}
  for _, path in ipairs(compilers) do
    names[vim.fn.fnamemodify(path, ":t:r")] = true
  end
  compilers = vim.tbl_keys(names)
  table.sort(compilers)

  picker.fzf_exec(compilers, vim.tbl_deep_extend("force", {
    prompt = "Compilers> ",
    fzf_opts = { ["--no-multi"] = true },
    actions = {
      ["enter"] = function(selected)
        if selected and selected[1] then
          vim.cmd("compiler " .. selected[1])
        end
      end,
    },
  }, copy_options(options)))
end

function M.async_tasks(rows, options)
  local picker = fzf_lua()
  if not picker then
    return
  end

  local entries = {}
  local names = {}
  for _, row in ipairs(rows or {}) do
    local name = row[1]
    if name and name ~= "" then
      local entry = string.format("%-24s  %s  : %s", name, row[2] or "", row[3] or "")
      table.insert(entries, entry)
      names[entry] = name
    end
  end

  picker.fzf_exec(entries, vim.tbl_deep_extend("force", {
    prompt = "Tasks> ",
    fzf_opts = {
      ["--multi"] = true,
      ["--nth"] = "1",
      ["--tac"] = true,
    },
    actions = {
      ["enter"] = function(selected)
        for _, entry in ipairs(selected or {}) do
          local name = names[entry]
          if name then
            vim.cmd("AsyncTask " .. vim.fn.fnameescape(name))
          end
        end
      end,
    },
  }, copy_options(options)))
end

local function command_options(opts)
  return with_fullscreen({}, opts.bang)
end

local function create_command(name, callback, opts, replace)
  if replace then
    pcall(vim.api.nvim_del_user_command, name)
  elseif vim.fn.exists(":" .. name) == 2 then
    return
  end
  vim.api.nvim_create_user_command(name, callback, opts or {})
end

function M.setup_commands()
  if custom_commands_ready then
    return
  end
  custom_commands_ready = true

  create_command("GitFiles", function(opts)
    local picker = fzf_lua()
    if not picker then
      return
    end

    local picker_opts = command_options(opts)
    local cwd = trim(opts.args)
    if cwd == "?" then
      picker.git_status(picker_opts)
    else
      picker_opts.cwd = cwd
      picker.git_files(picker_opts)
    end
  end, { desc = "Search Git files", nargs = "?", bang = true, complete = "dir" }, true)
  create_command("Buffers", function(opts)
    M.buffers(opts.args, command_options(opts))
  end, { desc = "Search open buffers", nargs = "?", bang = true, complete = "buffer" }, true)
  create_command("Rg", function(opts)
    M.grep(opts.args, nil, command_options(opts))
  end, { desc = "Search with ripgrep", nargs = "?", bang = true }, true)
  create_command("RG", function(opts)
    M.rg(opts.args, command_options(opts))
  end, { desc = "Live grep", nargs = "?", bang = true }, true)
  create_command("Tags", function(opts)
    M.tags(opts.args, command_options(opts))
  end, { desc = "Search tags", nargs = "*", bang = true }, true)

  create_command("Cfilter", function(opts)
    M.quickfix(opts.args, command_options(opts))
  end, { desc = "Filter the quickfix list", nargs = "?", bang = true })
  create_command("Pg", function(opts)
    M.project_grep(opts.args, command_options(opts))
  end, { desc = "Search the current project", nargs = "?", bang = true })
  create_command("GitGrep", function(opts)
    M.git_grep(opts.args, command_options(opts))
  end, { desc = "Search the current Git repository", nargs = "?", bang = true })
  create_command("GGrep", function(opts)
    M.git_grep(opts.args, command_options(opts))
  end, { desc = "Search the current Git repository", nargs = "?", bang = true })
  create_command("Paths", function(opts)
    M.paths(opts.args, command_options(opts))
  end, { desc = "Search all configured paths", nargs = "?", bang = true })
  create_command("Locate", function(opts)
    M.locate(opts.args, command_options(opts))
  end, { desc = "Search locate database", nargs = "+", bang = true, complete = "dir" })
  create_command("Ag", function(opts)
    M.ag(opts.args, command_options(opts))
  end, { desc = "Search with The Silver Searcher", nargs = "*", bang = true })
  create_command("BMarks", function(opts)
    M.bmarks(opts.args, command_options(opts))
  end, { desc = "Search lowercase marks", nargs = "?", bang = true })
  create_command("Snippets", function(opts)
    M.snippets(command_options(opts))
  end, { desc = "Search UltiSnips snippets", nargs = 0, bang = true })
  create_command("Windows", function(opts)
    M.windows(command_options(opts))
  end, { desc = "Search windows", nargs = 0, bang = true })
  create_command("Path", function(opts)
    M.path(opts.args, command_options(opts))
  end, { desc = "Select a configured path to search", nargs = "?", bang = true })
  create_command("Projects", function(opts)
    M.projects(command_options(opts))
  end, { desc = "Select a project", nargs = 0, bang = true })
  create_command("Packages", function(opts)
    M.packages(opts)
  end, { desc = "Search packages", nargs = "*", bang = true })
  create_command("Compilers", function(opts)
    M.compilers(command_options(opts))
  end, { desc = "Select a compiler", nargs = 0, bang = true })
  create_command("FzfFunky", function(opts)
    M.fzf_funky(opts.args, command_options(opts))
  end, { desc = "Search document symbols", nargs = "?", bang = true })
  create_command("FZFMru", function(opts)
    M.mru(opts.args, command_options(opts))
  end, { desc = "Search MRU files", nargs = "?", bang = true })
  create_command("FZFFreshMru", function(opts)
    M.fresh_mru(opts.args, command_options(opts))
  end, { desc = "Refresh and search MRU files", nargs = "?", bang = true })
  create_command("Bookmarks", M.bookmarks, { desc = "Open bookmarks", nargs = 0 })
  create_command("BookmarkAdd", function(opts)
    M.add_bookmark(opts.args)
  end, { desc = "Add a bookmark", nargs = "?", complete = "file" })
  create_command("BookmarkDelete", function(opts)
    M.delete_bookmark(trim(opts.args))
  end, { desc = "Delete a bookmark", nargs = "?", complete = "file" })
  create_command("Imaps", function(opts)
    local picker = fzf_lua()
    if picker then
      picker.keymaps(vim.tbl_deep_extend("force", {
        modes = { "i" },
        query = trim(opts.args),
      }, command_options(opts)))
    end
  end, { desc = "Search insert-mode mappings", nargs = "?", bang = true })
  create_command("Xmaps", function(opts)
    local picker = fzf_lua()
    if picker then
      picker.keymaps(vim.tbl_deep_extend("force", {
        modes = { "x" },
        query = trim(opts.args),
      }, command_options(opts)))
    end
  end, { desc = "Search visual-mode mappings", nargs = "?", bang = true })
  create_command("Omaps", function(opts)
    local picker = fzf_lua()
    if picker then
      picker.keymaps(vim.tbl_deep_extend("force", {
        modes = { "o" },
        query = trim(opts.args),
      }, command_options(opts)))
    end
  end, { desc = "Search operator-pending mappings", nargs = "?", bang = true })
  create_command("AsyncTaskFzf", function()
    if vim.fn.exists("*asynctasks#source") == 1 then
      M.async_tasks(vim.fn["asynctasks#source"](vim.o.columns * 48 / 100))
    end
  end, { desc = "Select an AsyncTask with fzf-lua", nargs = 0 })
end

return M
