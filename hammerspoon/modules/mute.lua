local muteOnSSIDs = {
  ["下埔购书中心_guest"] = true,
  -- ["公司WiFi"] = true,
  -- ["会议室WiFi"] = true,
}

local mutedBuiltInByWifiAutomation = false
local hasShownLocationPermissionWarning = false

local function notify(text)
  hs.notify
    .new({
      title = "Hammerspoon",
      informativeText = text,
    })
    :send()
end

local function hasLocationAccess()
  if not hs.location.servicesEnabled() then
    return false, "系统定位服务未开启"
  end

  local status = hs.location.authorizationStatus()
  if status == "authorized" then
    return true, nil
  end

  return false, "Hammerspoon 缺少定位权限"
end

local function ensureLocationAccess()
  local ok, reason = hasLocationAccess()
  if ok then
    hasShownLocationPermissionWarning = false
    return true
  end

  if not hasShownLocationPermissionWarning then
    hasShownLocationPermissionWarning = true
    hs.location.get()
    notify(reason .. "，请到 Privacy & Security > Location Services 为 Hammerspoon 开启权限")
  end

  return false
end

local function shouldMuteForSSID(ssid)
  return ssid ~= nil and muteOnSSIDs[ssid] == true
end

local function getBuiltInOutput()
  local current = hs.audiodevice.defaultOutputDevice()
  if current and current:transportType() == "Built-in" then
    return current
  end

  for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
    if dev:transportType() == "Built-in" then
      return dev
    end
  end

  return nil
end

local function updateMuteForWifi()
  if not ensureLocationAccess() then
    return
  end

  local ssid = hs.wifi.currentNetwork()
  local builtIn = getBuiltInOutput()

  if not builtIn then
    return
  end

  if shouldMuteForSSID(ssid) then
    if not builtIn:muted() then
      builtIn:setMuted(true)
      mutedBuiltInByWifiAutomation = true
      notify("已连接到 “" .. ssid .. "”，内建扬声器已静音")
    end
  else
    if mutedBuiltInByWifiAutomation then
      builtIn:setMuted(false)
      mutedBuiltInByWifiAutomation = false
      notify("已离开静音 Wi‑Fi，内建扬声器已解除静音")
    end
  end
end

wifiWatcher = hs.wifi.watcher.new(updateMuteForWifi)
wifiWatcher:start()

hs.audiodevice.watcher.setCallback(function(event)
  if event == "dOut" then
    updateMuteForWifi()
  end
end)
hs.audiodevice.watcher.start()
