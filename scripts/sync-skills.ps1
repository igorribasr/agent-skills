param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Detecta automaticamente a raiz do repositorio relativo a este script
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $RepoRoot -or -not (Test-Path $RepoRoot)) {
    $RepoRoot = (Get-Location).Path
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Sincronizando Skills Globais do repositorio agent-skills " -ForegroundColor Cyan
Write-Host " Origem: $RepoRoot" -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Puxar as atualizacoes mais recentes do GitHub
Write-Host "`n[1/4] Verificando atualizacoes no GitHub..." -ForegroundColor Yellow
try {
    if (Test-Path (Join-Path $RepoRoot ".git")) {
        $gitStatus = git -C $RepoRoot pull --ff-only
        Write-Host "  $gitStatus" -ForegroundColor Green
    }
} catch {
    Write-Host "  Aviso: Nao foi possivel rodar git pull automaticamente: $_" -ForegroundColor DarkYellow
}

# 2. Identificar todas as skills no repositorio
$skills = Get-ChildItem -Path $RepoRoot -Directory | Where-Object { 
    $_.Name -ne ".git" -and $_.Name -ne "scripts" -and (Test-Path (Join-Path $_.FullName "SKILL.md"))
}

Write-Host "`n[2/4] Total de skills encontradas no repositorio: $($skills.Count)" -ForegroundColor Green

# 3. Definir os diretorios globais de cada CLI
$TargetDirs = @(
    @{ Name = "Antigravity (Global Config)"; Path = "$env:USERPROFILE\.gemini\config\skills" },
    @{ Name = "Antigravity (CLI legacy)";   Path = "$env:USERPROFILE\.gemini\antigravity-cli\skills" },
    @{ Name = "Claude Code";                Path = "$env:USERPROFILE\.claude\skills" },
    @{ Name = "Codex CLI";                  Path = "$env:USERPROFILE\.codex\skills" },
    @{ Name = "Agents Standard";            Path = "$env:USERPROFILE\.agents\skills" }
)

# 4. Sincronizar para cada destino
Write-Host "`n[3/4] Instalando skills nos diretorios globais de cada CLI..." -ForegroundColor Yellow

foreach ($target in $TargetDirs) {
    $destPath = $target.Path
    Write-Host "`n-> Destino: $($target.Name)" -ForegroundColor Cyan
    Write-Host "   Caminho: $destPath" -ForegroundColor Gray
    
    if (-not (Test-Path $destPath)) {
        New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        Write-Host "   [Criado diretorio destino]" -ForegroundColor DarkGray
    }
    
    $copiedCount = 0
    foreach ($skill in $skills) {
        $skillDest = Join-Path $destPath $skill.Name
        Copy-Item -Path $skill.FullName -Destination $skillDest -Recurse -Force
        $copiedCount++
    }
    Write-Host "   OK: $copiedCount skills instaladas/atualizadas com sucesso." -ForegroundColor Green
}

Write-Host "`n[4/4] Validacao de integridade..." -ForegroundColor Yellow
foreach ($target in $TargetDirs) {
    if (Test-Path $target.Path) {
        $installed = (Get-ChildItem -Path $target.Path -Directory).Count
        Write-Host "  - $($target.Name): $installed skills totais disponiveis" -ForegroundColor Green
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Sincronizacao concluida com sucesso para todos os CLIs!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
