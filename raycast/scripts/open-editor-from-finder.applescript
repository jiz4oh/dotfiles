#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open with $EDITOR
# @raycast.mode compact
# @raycast.packageName Navigation
#
# Optional parameters:
# @raycast.icon images/iterm-logo.png
# @raycast.argument1 { "type": "text", "placeholder": "File or current finder path", "optional": true }
#
# Documentation:
# @raycast.description Open the input path or current Finder path in $EDITOR
# @raycast.author jiz4oh
# @raycast.authorURL https://github.com/jiz4oh

on run {input}
  set terminal to "kitty"
  set scriptPath to POSIX path of (path to me)
  set scriptDir to do shell script "dirname " & quoted form of scriptPath

	-- If run without input, open random file at $HOME
	try
		if (length of input is not 0) then
			set filename to input
		else
      set filename to run script scriptDir & "/utils/get-finder-path.applescript"
		end if
	on error
		set filename to "vim-" & (do shell script "date +%F") & "__" & (random number from 1000 to 9999) & ".txt"
	end try
	
  if terminal is equal to "wezterm" then
    tell application "System Events"
      tell application "WezTerm"
        do shell script "sh -c 'ruby \"" & scriptDir & "/utils/open-wezterm.rb\" \"" & filename & "\"'"
      end tell
    end tell
  else if terminal is equal to "kitty" then
    tell application "System Events"
      tell application "Kitty"
        do shell script "sh -c 'ruby \"" & scriptDir & "/utils/open-kitty.rb\" \"" & filename & "\"'"
      end tell
    end tell
  else if terminal is equal to "iterm2" then
    -- Set your editor here
    set myEditor to "${EDITOR:-vim}"
    -- Open the file and auto exit after done
    set command to myEditor & " " & quoted form of filename & " && exit"

    tell application "iTerm"
      activate
      set hasNoWindows to ((count of windows) is 0)
      if hasNoWindows then
        create window with default profile
      end if
      select first window
      
      tell the first window
        if hasNoWindows is false then
          create tab with default profile
        end if
        tell current session to write text command
      end tell
    end tell
  end if
end run
