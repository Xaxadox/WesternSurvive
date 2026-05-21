$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$ProjectPath = Join-Path $Root "project"
$EnginePath = Join-Path $Root "engine"
$CachePath = Join-Path $Root "cache"
$TempPath = Join-Path $CachePath "tmp"

New-Item -ItemType Directory -Force -Path $CachePath,$TempPath | Out-Null

$env:GODOT_USER_HOME = Join-Path $CachePath "godot_user_home"
$env:TEMP = $TempPath
$env:TMP = $TempPath
New-Item -ItemType Directory -Force -Path $env:GODOT_USER_HOME | Out-Null

$Godot = Get-ChildItem -LiteralPath $EnginePath -Filter "Godot*.exe" -File |
    Where-Object { $_.Name -notlike "*console*" } |
    Select-Object -First 1

if (-not $Godot) {
    Write-Host "Nenhum Godot encontrado em $EnginePath."
    Write-Host "Baixe o Godot 4 para Windows e extraia o executavel nessa pasta."
    exit 1
}

Start-Process -FilePath $Godot.FullName -ArgumentList @("--path", $ProjectPath)
