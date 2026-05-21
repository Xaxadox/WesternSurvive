$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProgressPath = Join-Path $Root "cache\progress.json"

$defaultSettings = [ordered]@{
    fullscreen = $false
    master_volume = 0.85
    music_volume = 0.55
    resolution = "1280x720"
}

if (Test-Path -LiteralPath $ProgressPath) {
    $progress = Get-Content -LiteralPath $ProgressPath -Raw | ConvertFrom-Json
} else {
    New-Item -ItemType Directory -Force -Path (Join-Path $Root "cache") | Out-Null
    $progress = [ordered]@{
        unlocked_stages = @("ghost_town", "broken_fort", "canyon", "mine")
        unlocked_weapons = @()
    }
}

$progress | Add-Member -NotePropertyName settings -NotePropertyValue $defaultSettings -Force
$progress | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ProgressPath -Encoding UTF8

Write-Host "Configuracoes resetadas para 1280x720 em modo janela."
