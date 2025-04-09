hs.ipc.cliInstall()

-- 为随机数生成器设置基于主机名的种子，以减少跨机器冲突
local hostname = hs.host.localizedName()
local seed = 0
for i = 1, #hostname do
  seed = seed + string.byte(hostname, i)
end
math.randomseed(seed)

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
    :new(hs.fs.pathToAbsolute(dir .. "/rime/squirrel_sync"), hs.timer.hours(7))
    :start()

  -- random for each different machines
  require("modules.crontab")
    :new(
      hs.fs.pathToAbsolute(dir .. "/rime/sync_icloud"),
      -- 基础间隔 6 小时，加上 0 到 3600 秒 (0-60分钟) 的随机偏移
      hs.timer.hours(6) + math.random(0, 3600)
    )
    :start()
end
