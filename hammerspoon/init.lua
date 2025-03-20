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
