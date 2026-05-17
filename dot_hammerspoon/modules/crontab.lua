-- 类定义
local Crontab = {}
Crontab.__index = Crontab

-- --- 默认配置 ---
-- 这些可以在创建实例时覆盖
local defaultConfig = {
  notifyOnTaskSuccess = false, -- 是否在任务成功时显示通知
  notifyOnTaskError = true, -- 是否在任务失败时显示通知
}
-- --- 结束配置 ---

-- 用于跟踪所有活动的 Crontab 实例
local activeInstances = {}

-- 构造函数: 创建一个新的 Crontab 实例
-- @param path string: 要执行的脚本的绝对路径
-- @param interval number: 执行间隔（秒）
-- @param options table|nil: 可选配置，覆盖 defaultConfig (例如 { notifyOnSuccess = true })
-- @return table: 新的 Crontab 实例
function Crontab:new(path, interval)
  local instance = setmetatable({}, Crontab) -- 创建实例并设置元表

  -- 检查参数
  if type(path) ~= "string" or path == "" then
    error("Crontab:new() requires a non-empty string for path.", 2)
  end
  if type(interval) ~= "number" or interval <= 0 then
    error("Crontab:new() requires a positive number for interval.", 2)
  end

  instance.path = path
  instance.interval = interval
  instance.options = defaultConfig -- 使用默认配置

  instance.timer = nil
  instance.isRunning = false -- 用于防止重复执行

  -- 将实例添加到活动列表
  table.insert(activeInstances, instance)

  print(
    string.format(
      "Crontab instance created for path: %s, Interval: %d seconds.",
      instance.path,
      instance.interval
    )
  )

  return instance
end

-- 启动定时器
-- @return boolean: 定时器是否成功启动
function Crontab:start()
  if self.timer then
    print("Crontab: Timer already started for " .. self.path)
    return true -- 认为已经启动是成功的
  end

  -- 检查脚本文件是否存在 (启动时检查一次)
  if not hs.fs.attributes(self.path) then
    local errorMsg = "Script not found at: " .. self.path .. ". Timer not started."
    print("Error: " .. errorMsg)
    if self.options.notifyOnError then
      hs.notify.new({ title = "Hammerspoon Crontab Error", informativeText = errorMsg }):send()
    end
    return false -- 启动失败
  end

  -- 创建并启动定时器
  -- doEvery 会立即执行一次，然后按间隔重复
  self.timer = hs.timer.doEvery(self.interval, function()
    self:runScript() -- 使用 self 调用实例方法
  end)

  if self.timer then
    print(
      string.format(
        "Crontab timer started for path: %s, Interval: %d seconds.",
        self.path,
        self.interval
      )
    )
    return true
  else
    -- hs.timer.doEvery 理论上总是返回 timer 对象，但以防万一
    print("Error: Failed to create timer for " .. self.path)
    return false
  end
end

-- 停止定时器
function Crontab:stop()
  if self.timer then
    self.timer:stop()
    self.timer = nil
    print("Crontab timer stopped for path: " .. self.path)

    -- 从活动列表中移除实例
    for i, inst in ipairs(activeInstances) do
      if inst == self then
        table.remove(activeInstances, i)
        break
      end
    end
  else
    print("Crontab timer was not running for path: " .. self.path)
  end
end

-- 执行同步脚本 (内部方法)
function Crontab:runScript()
  if self.isRunning then
    print("Task already running for " .. self.path .. ", skipping interval.")
    return
  end

  -- 再次检查脚本文件是否存在 (运行时检查)
  if not hs.fs.attributes(self.path) then
    local errorMsg = "Script not found at: " .. self.path
    print("Error: " .. errorMsg)
    if self.options.notifyOnError then
      hs.notify.new({ title = "Hammerspoon Crontab Error", informativeText = errorMsg }):send()
    end
    -- 如果脚本找不到，停止这个实例的定时器以避免重复报错
    self:stop()
    return
  end

  self.isRunning = true
  print("Starting script: " .. self.path)

  -- 使用 hs.task 运行脚本
  local task = hs.task.new(self.path, function(exitCode, stdOut, stdErr)
    self.isRunning = false -- 标记为完成
    if exitCode == 0 then
      print("Script finished successfully for " .. self.path)
      if self.options.notifyOnSuccess then
        hs.notify
          .new({
            title = "Hammerspoon Crontab",
            informativeText = "Completed successfully for " .. self.path,
          })
          :send()
      end
    else
      local errorMsg =
        string.format("Script failed for %s with exit code %d.", self.path, exitCode)
      print("Error: " .. errorMsg)
      if stdErr and stdErr ~= "" then
        print("Stderr:\n" .. stdErr)
        errorMsg = errorMsg .. "\nError Output:\n" .. stdErr -- 将部分 stderr 加入通知
      else
        print("Stderr: (empty)")
      end
      if stdOut and stdOut ~= "" then
        print("Stdout:\n" .. stdOut)
      else
        print("Stdout: (empty)")
      end

      if self.options.notifyOnError then
        -- 限制通知中错误信息的长度
        local maxErrLength = 200
        if string.len(errorMsg) > maxErrLength then
          errorMsg = string.sub(errorMsg, 1, maxErrLength) .. "..."
        end
        hs.notify
          .new({
            title = "Hammerspoon Crontab Error",
            informativeText = errorMsg,
          })
          :send()
      end
    end
  end)

  if task then
    -- 启动任务
    local started = task:start()
    if not started then
      self.isRunning = false
      local errorMsg = "Failed to start task for: " .. self.path
      print("Error: " .. errorMsg)
      if self.options.notifyOnError then
        hs.notify
          .new({
            title = "Hammerspoon Crontab Error",
            informativeText = errorMsg,
          })
          :send()
      end
    end
  else
    self.isRunning = false
    local errorMsg = "Failed to create hs.task for: " .. self.path
    print("Error: " .. errorMsg)
    if self.options.notifyOnError then
      hs.notify.new({ title = "Hammerspoon Crontab Error", informativeText = errorMsg }):send()
    end
  end
end

-- 在 Hammerspoon 重新加载配置或退出时停止所有活动的定时器
local oldShutdownCallback = hs.shutdownCallback
hs.shutdownCallback = function()
  if oldShutdownCallback then
    pcall(oldShutdownCallback) -- 安全地调用旧的回调
  end

  -- 停止所有由此模块创建的活动定时器
  -- 从后往前遍历，因为 stop() 会修改 activeInstances 表
  for i = #activeInstances, 1, -1 do
    local instance = activeInstances[i]
    -- 使用 pcall 以防某个实例的 stop 方法出错影响其他实例
    pcall(function()
      instance:stop()
    end)
  end
  print("All active Crontab timers stopped during shutdown/reload.")
end

-- 返回 Crontab 类
return Crontab
