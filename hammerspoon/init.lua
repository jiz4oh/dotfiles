-- https://github.com/kovidgoyal/kitty/issues/45#issuecomment-573196169
hs.hotkey.bind({"cmd"}, "F12", function()
  local app = hs.application.get("net.kovidgoyal.kitty")

  if app then
      if not app:mainWindow() then
          app:selectMenuItem({"kitty", "New OS window"})
      elseif app:isFrontmost() then
          app:hide()
      else
          app:activate()
      end
  else
      hs.application.launchOrFocusByBundleID("net.kovidgoyal.kitty")
      app = hs.application.get("net.kovidgoyal.kitty")
  end

  app:mainWindow():moveToUnit'[100,50,0,0]'
end)
