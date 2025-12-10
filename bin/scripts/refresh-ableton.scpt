tell application "Ableton Live 12 Beta" to activate
delay 0.2
tell application "System Events"
    keystroke "r" using {command down, option down, shift down}
end tell
delay 2
tell application "iTerm" to activate
return "SUCCESS: Ableton MIDI Remote Scripts reloaded"
