-- https://github.com/kovidgoyal/kitty/issues/45#issuecomment-573196169
-- https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "HammerspoonWindow"
obj.version = "0.1"
obj.author = "jiz4oh"
obj.license = "MIT"

obj.defaultHotkeys = {
	terminal = { { "cmd" }, "F12" },
}

local function toggle_terminal()
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
end

function obj:bindHotkeys(mapping)
	local def = {
		terminal = toggle_terminal,
	}

	hs.spoons.bindHotkeysToSpec(def, mapping)
end

return obj
