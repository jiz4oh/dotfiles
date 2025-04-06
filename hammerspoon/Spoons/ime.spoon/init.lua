-- inspired by https://gist.github.com/hongqn/7fae6ddefb929ed5f1ab59d9148a2250
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HammerspoonSwitchIME"
obj.version = "0.2"
obj.author = "Qiangning Hong, jiz4oh"
obj.license = "MIT"

obj.defaultHotkeys = {
  cn = { { "cmd", "alt" }, "c" },
  en = { { "cmd", "alt" }, "e" },
}

local sources = {
  cn = "im.rime.inputmethod.Squirrel.Hans",
  en = "com.apple.keylayout.ABC",
}
local current = "im.rime.inputmethod.Squirrel.Hans"

local function switch(id)
  current = id
  hs.keycodes.currentSourceID(id)
end

-- 有时候 macos 莫名其妙会切换到 ABC 输入法，锁定输入法，强制只能通过这种方式切换输入法
local function forceIME()
  if hs.keycodes.currentSourceID() ~= current then
    switch(current)
  end
end

function obj:bindHotkeys(mapping)
  local def = {}
  for k, value in pairs(sources) do
    def[k] = function()
      switch(value)
    end
  end

  hs.spoons.bindHotkeysToSpec(def, mapping)
end

function obj:bindEvent()
  hs.keycodes.inputSourceChanged(forceIME)
  hs.application.watcher
    .new(function(app_name, event, application)
      forceIME()
    end)
    :start()

  hs.urlevent.bind("switch_ime", function(_, params)
    switch(sources[params["lang"]] or sources.cn)
  end)
end

function obj:init()
  self:bindEvent()
end

return obj
