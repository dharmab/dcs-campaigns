#!/usr/bin/env pwsh

if ($args.Count -lt 2) {
    Write-Host "Usage: .\unpack-miz.ps1 MIZ THEATER"
    Write-Host "Example: .\unpack-miz.ps1 mission.miz calamity"
    exit
}

$mizFile = $args[0]
$theaterName = $args[1]

$destinationFolder = "theaters/$theaterName/mission"

if (-Not (Test-Path -Path $mizFile)) {
    Write-Host "MIZ file not found: $mizFile"
    exit
}

if (-Not (Test-Path -Path $destinationFolder)) {
    Write-Host "creating folder: $destinationFolder"
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

try {
    Expand-Archive -Path $mizFile -DestinationPath $destinationFolder -Force
    Write-Host "unpacked $mizFile into $destinationFolder"
} catch {
    Write-Host "an error occurred: $_"
}

