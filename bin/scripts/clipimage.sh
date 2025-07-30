#!/bin/bash

OUTFILE="./clipimage.png"

# Use AppleScript to write PNG clipboard data to file
osascript -e '
try
  set theImage to the clipboard as «class PNGf»
  set outFile to POSIX file "'$OUTFILE'" as string
  set fileRef to open for access outFile with write permission
  set eof fileRef to 0
  write theImage to fileRef
  close access fileRef
on error
  try
    close access fileRef
  end try
  error "No image data in clipboard"
end try'

