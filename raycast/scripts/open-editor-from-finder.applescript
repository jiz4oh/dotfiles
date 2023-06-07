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
	-- If run without input, open random file at $HOME
	try
		if (length of input is not 0) then
			set filename to input
		else
			tell application "Finder"
				-- Check if there's a selection; works if there's a window open or not.
				if selection is not {} then
					set i to item 1 of (get selection)
					
					-- If it's an alias, set the item to the original item.
					if class of i is alias file then
						set i to original item of i
					end if
					
          set p to i
				else if (exists window 1) and (exists folder of window 1) then
					-- If a window exists, use its folder property as the path.
					set p to folder of window 1
				else
					-- Fallback to the error logic
					error "No valid Finder window or input provided."
				end if
				
				set filename to POSIX path of (p as alias)
			end tell
		end if
	on error
		set filename to "vim-" & (do shell script "date +%F") & "__" & (random number from 1000 to 9999) & ".txt"
	end try
	
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
end run
