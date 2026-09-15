# Merge repo-managed Claude Code env into ~/.claude/settings.json.
# Unix equivalent: `just claude-settings`.
$f = "$env:USERPROFILE\.claude\settings.json"
if (!(Test-Path $f)) { New-Item -ItemType Directory -Force (Split-Path $f) | Out-Null; Set-Content $f "{}" }
$j = Get-Content $f -Raw | ConvertFrom-Json
if (-not $j.PSObject.Properties['env']) { $j | Add-Member -NotePropertyName env -NotePropertyValue ([pscustomobject]@{}) }
$j.env | Add-Member -NotePropertyName CLAUDE_CODE_SUBAGENT_MODEL -NotePropertyValue "opus" -Force
$j | ConvertTo-Json -Depth 10 | Set-Content $f -Encoding UTF8
Write-Output ("env: " + ($j.env | ConvertTo-Json -Compress))
