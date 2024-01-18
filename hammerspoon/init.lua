-- https://github.com/kovidgoyal/kitty/issues/45#issuecomment-573196169
hs.hotkey.bind({"cmd"}, "F12", function()
  -- osascript -e 'id of app "kitty"'
  local app_bundle_id = "net.kovidgoyal.kitty"
  local app_bundle_id = "com.github.wez.wezterm"
  local app = hs.application.get(app_bundle_id)

  if app then
      if not app:mainWindow() then
          app:selectMenuItem({"kitty", "New OS window"})
      elseif app:isFrontmost() then
          app:hide()
      else
          app:activate()
      end
  else
      hs.application.launchOrFocusByBundleID(app_bundle_id)
      app = hs.application.get(app_bundle_id)
  end

  app:mainWindow():moveToUnit'[100,100,0,0]'
end)
