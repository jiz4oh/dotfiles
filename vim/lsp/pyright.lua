return {
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    "libpython*.dylib", -- add this one to search in built-in libs
    ".git",
  },
}
