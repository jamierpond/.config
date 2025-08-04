#!/bin/bash

OUTFILE="./clipimage.png"

osascript <<EOF
try
  set pngData to the clipboard as «class PNGf»
  set outFile to POSIX file "$(pwd)/clipimage.png"
  set fileRef to open for access outFile with write permission
  set eof fileRef to 0
  write pngData to fileRef
  close access fileRef
on error
  try
    close access outFile
  end try
  error "no image"
end try
EOF

