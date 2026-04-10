local muteOnSSIDs = {
  ["下埔购书中心_guest"] = true,
  -- ["公司WiFi"] = true,
  -- ["会议室WiFi"] = true,
}

local mutedBuiltInByWifiAutomation = false

local function notify(text)
  hs.notify
    .new({
      title = "Hammerspoon",
      informativeText = text,
    })
    :send()
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
