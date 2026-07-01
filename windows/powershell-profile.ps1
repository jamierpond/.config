# PowerShell profile - Windows. Dot-sourced by $PROFILE (stub written by
# windows/setup.ps1).

# Unix-style Ctrl+D: delete char under cursor, or exit when the line is empty
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

# Unix-isms
Set-Alias which Get-Command
