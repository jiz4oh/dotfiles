-- https://github.com/kovidgoyal/kitty/issues/45#issuecomment-573196169
hs.hotkey.bind({ "cmd" }, "F12", function()
	-- osascript -e 'id of app "kitty"'
  local terminal = os.getenv("TERMINAL")
  local app_bundle_id

  if terminal == "kitty" then
    app_bundle_id = "net.kovidgoyal.kitty"
  elseif terminal == "wezterm" then
    app_bundle_id = "com.github.wez.wezterm"
  else
    app_bundle_id = "net.kovidgoyal.kitty"
  end

	local app = hs.application.get(app_bundle_id)

	if app then
		if app:isFrontmost() then
			app:hide()
		else
			app:activate()
			-- if not app:mainWindow() then
			-- 	app:selectMenuItem({ "kitty", "New OS window" })
			-- end
		end
	else
		hs.application.launchOrFocusByBundleID(app_bundle_id)
		app = hs.application.get(app_bundle_id)
	end

	app:mainWindow():moveToUnit("[100,100,0,0]")
end)

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

hs.spoons.use("ime", {
	hotkeys = "default",
})
