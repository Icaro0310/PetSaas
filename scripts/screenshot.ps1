# Script de screenshot para o ritual de módulos do PetCare
# Requer Android SDK + emulador/dispositivo conectado
# Uso: powershell -File tool\screenshot.ps1

param(
    [string]$Prefix = "modulo",
    [string]$OutDir = "$PSScriptRoot\..\screenshots"
)

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Verifica dispositivo ADB
$devices = adb devices 2>&1 | Select-String "device$" | ForEach-Object { ($_ -split "\t")[0] }
if (-not $devices) {
    Write-Host "Nenhum dispositivo/emulador ADB encontrado. Inicie o emulador primeiro." -ForegroundColor Red
    exit 1
}

Write-Host "Dispositivos ADB: $($devices -join ', ')"
$device = $devices | Select-Object -First 1

function Take-Shot($name) {
    $date = Get-Date -Format "yyyyMMdd_HHmmss"
    $out = Join-Path $OutDir "$name`_$date.png"
    adb -s $device shell screencap -p /sdcard/screen.png | Out-Null
    adb -s $device pull /sdcard/screen.png "$out" | Out-Null
    Write-Host "Salvo: $out" -ForegroundColor Green
    return $out
}

Write-Host ""
Write-Host "============================="
Write-Host "Ritual de Screenshot PetCare"
Write-Host "============================="
Write-Host "Navegue manualmente na app. A cada tela, pressione ENTER para capturar."
Write-Host "Digite 'q' e ENTER para sair."
Write-Host ""

$i = 1
while ($true) {
    $label = Read-Host "Nome do screenshot (ou 'q' para sair) [ex: $($Prefix)_02_pets_list]"
    if ($label -eq 'q') { break }
    if (-not $label) { $label = "$Prefix`_$i"; $i++ }
    Take-Shot $label
}

Write-Host "Screenshots guardados em: $OutDir"
