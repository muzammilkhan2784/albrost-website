# Sends any changes in this folder to GitHub, and brings down changes made there.
param([switch]$FromClaude)

Set-Location (Split-Path -Parent $PSScriptRoot)

git add -A
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    $message = "Update website ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
    if ($FromClaude) {
        git commit -q -m $message -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
    } else {
        git commit -q -m $message
    }
    if ($LASTEXITCODE -ne 0) { Write-Output "Sync failed: could not save the changes."; exit 1 }
}

git pull -q --rebase origin main
if ($LASTEXITCODE -ne 0) {
    git rebase --abort
    Write-Output "Sync failed: the same part was changed here and on GitHub. Nothing was lost, but it needs sorting out."
    exit 1
}

git push -q origin main
if ($LASTEXITCODE -ne 0) { Write-Output "Sync failed: could not reach GitHub. Check the internet and try again."; exit 1 }

Write-Output "GitHub is up to date."
