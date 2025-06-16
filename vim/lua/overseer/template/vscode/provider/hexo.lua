local M = {}

M.get_task_opts = function(defn)
  local cmd = defn.args or {}
  table.insert(cmd, 1, "hexo")
  return {
    cmd = cmd,
  }
end

M.problem_patterns = {
  -- This will provide the problem matcher pattern '$my-pat'
  ["$hexo"] = {
    {
      vim_regexp = "^\\(INFO\\|FATAL\\|Error\\)\\(\\:\\s\\+\\|\\s\\+\\)\\(.\\+\\)$",
      severity = 1,
      message = 3,
    },
    {
      vim_regexp = "^\\s\\+at\\([^(]\\+(\\)\\=\\s\\=\\(.\\{-1,}\\)\\:\\(\\d\\+\\)\\:\\(\\d\\+\\))\\=$",
      file = 2,
      line = 3,
      column = 4,
      loop = true,
    },
  },
}

M.problem_matchers = {
  ["$hexo"] = {
    name = "hexo",
    owner = "hexo",
    severity = "error",
    fileLocation = "absolute",
    pattern = "$hexo",
  },
}

return M
