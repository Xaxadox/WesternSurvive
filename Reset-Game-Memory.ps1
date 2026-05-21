$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProgressPath = Join-Path $Root "cache\progress.json"

if (Test-Path -LiteralPath $ProgressPath) {
    Remove-Item -LiteralPath $ProgressPath
    Write-Host "Memoria do jogo apagada: $ProgressPath"
} else {
    Write-Host "Nenhuma memoria do jogo encontrada."
}
