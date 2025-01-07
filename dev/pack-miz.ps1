#!/usr/bin/env pwsh

if ($args.Count -lt 1) {
    Write-Host "Usage: .\pack-miz.ps1 THEATER"
    Write-Host "Example: .\pack-miz.ps1 calamity"
    exit
}

$theaterName = $args[0]
$sourceFolder = "theaters/$theaterName/mission"
$destinationFile = "mission.miz"

if (-Not (Test-Path -Path $sourceFolder)) {
    Write-Host "theater not found: $sourceFolder"
    exit
}

try {
    Compress-Archive -Path "$sourceFolder\*" -DestinationPath $destinationFile -Force
    Write-Host "created $destinationFile"
} catch {
    Write-Host "An error occurred: $_"
}
