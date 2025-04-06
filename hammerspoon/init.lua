hs.ipc.cliInstall()

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

hs.spoons.use("ime", {
  hotkeys = "default",
})
hs.spoons.use("window", {
  hotkeys = "default",
})

local file = io.open(os.getenv("HOME") .. "/.mydotfile", "r")
if file ~= nil then
  local dir = file:read()
  file:close()

  require("modules.crontab")
    :new(hs.fs.pathToAbsolute(dir .. "/rime/squirrel_sync"), 15 * 60)
    :start()
  require("modules.crontab"):new(hs.fs.pathToAbsolute(dir .. "/rime/sync_icloud"), 15 * 60):start()
end
