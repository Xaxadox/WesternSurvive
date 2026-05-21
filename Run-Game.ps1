$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Game = Join-Path $Root "builds\WesternSurvive.exe"
$TempPath = Join-Path $Root "cache\tmp"

New-Item -ItemType Directory -Force -Path $TempPath | Out-Null
$env:TEMP = $TempPath
$env:TMP = $TempPath

if (-not (Test-Path -LiteralPath $Game)) {
    Write-Host "Executavel nao encontrado em $Game."
    Write-Host "Exporte o projeto pelo preset Windows Desktop."
    exit 1
}

Start-Process -FilePath $Game
