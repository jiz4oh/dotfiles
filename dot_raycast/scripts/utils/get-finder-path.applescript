#!/usr/bin/osascript

on run
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

  return filename
end run
