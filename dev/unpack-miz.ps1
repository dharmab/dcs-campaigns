#!/usr/bin/env pwsh

if ($args.Count -lt 1) {
    Write-Host "Usage: .\unpack-miz.ps1 THEATER"
    Write-Host "Example: .\unpack-miz.ps1 calamity"
    exit
}

$theaterName = $args[0]

$mizFile = "$env:USERPROFILE\Saved Games\DCS\Missions\dct-$theaterName.miz"
$zipFile = "$env:TEMP\mission.zip"
$destinationFolder = "theaters/$theaterName/mission"

if (-Not (Test-Path -Path $mizFile)) {
    Write-Host "MIZ file not found: $mizFile"
    exit
}

try {
    Write-Host "unpacking $mizFile into $destinationFolder"
    Copy-Item -Path $mizFile -Destination $zipFile
    Expand-Archive -Path $zipFile -DestinationPath $destinationFolder -Force
}
catch {
    Write-Host "an error occurred: $_"
}
finally {
    Remove-Item -Path $zipFile -Force
}

