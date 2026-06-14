---@module "lazy"
---@type LazyPluginSpec
return {
  "afonsofrancof/worktrees.nvim",
  optional = true,
  event = "VeryLazy",
  cmd = {
    "WorktreeCreate",
    "WorktreeDelete",
    "WorktreeSwitch",
  },
  keys = {
    "<leader>gwc",
    "<leader>gwd",
    "<leader>gws",
  },
  opts = {
    -- Specify where to create worktrees relative to git common dir
    -- The common dir is the .git dir in a normal repo or the root dir of a bare repo
    base_path = "..", -- Parent directory of common dir

    -- Template for worktree folder names (string or function(branch) -> path)
    -- This is only used if you don't specify the folder name when creating the worktree
    path_template = "{branch}", -- Default: use branch name

    -- Command names (optional)
    commands = {
      create = "WorktreeCreate",
      delete = "WorktreeDelete",
      switch = "WorktreeSwitch",
    },

    -- Key mappings for interactive UI (optional)
    mappings = {
      create = "<leader>gwc",
      delete = "<leader>gwd",
      switch = "<leader>gws",
    },

    -- Lifecycle hooks (optional)
    on_create = function(path) end,
    on_delete = function(path) end,
    on_switch = function(from_path, to_path) end,
  },
}
