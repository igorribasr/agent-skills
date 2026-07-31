# sync-skills.ps1
# Sincroniza todas as skills do repositório para o diretório global do Antigravity.
# Chamado automaticamente pelo git hook post-merge (após git pull).

$SkillsRepo    = "D:\Documents\GitHub\agent-skills"
$GlobalSkills  = "$env:USERPROFILE\.gemini\antigravity-cli\skills"

Write-Host ""
Write-Host "Sincronizando skills com o diretorio global..." -ForegroundColor Cyan

$synced = 0
Get-ChildItem -Path $SkillsRepo -Directory | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
    $dest = Join-Path $GlobalSkills $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
    Write-Host "  OK $($_.Name)" -ForegroundColor Green
    $synced++
}

Write-Host ""
Write-Host "$synced skills sincronizadas em: $GlobalSkills" -ForegroundColor Cyan
Write-Host ""
