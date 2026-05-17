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

local _DOTFILES_PATH = os.getenv("_DOTFILES_PATH")
if _DOTFILES_PATH == nil then
  local file = io.open(os.getenv("HOME") .. "/.mydotfile", "r")
  if file ~= nil then
    local _DOTFILES_PATH = file:read()
    file:close()
  end
end

if _DOTFILES_PATH ~= nil then
  hs.timer.doAt("5:21", function()
    local path = hs.fs.pathToAbsolute(_DOTFILES_PATH .. "/rime/squirrel_sync")
    hs.task.new(path, nil):start()
  end)

  -- random for each different machines
  require("modules.crontab")
    :new(
      hs.fs.pathToAbsolute(_DOTFILES_PATH .. "/rime/sync_icloud"),
      -- 基础间隔 6 小时，加上 0 到 3600 秒 (0-60分钟) 的随机偏移
      hs.timer.hours(6) + math.random(0, 3600)
    )
    :start()
end

require("modules.mute")
