#!/usr/bin/env pwsh

if ($args.Count -lt 1) {
    Write-Host "Usage: .\uninstall.ps1 THEATER"
    Write-Host "Example: .\uninstall.ps1 calamity"
    exit
}

$theaterName = $args[0]
$savedGamesFolder = "$env:USERPROFILE\Saved Games\DCS"
$dctTechFolder = "$savedGamesFolder\Mods\Tech\DCT"
$theaterFolder = "$savedGamesFolder\theater"
$hookFile = "$savedGamesFolder\Scripts\Hooks\dct-hook.lua"
$cfgFile = "$savedGamesFolder\Config\dct.cfg"
$missionFile = "$savedGamesFolder\Missions\dct-$theaterName.miz"
$stateFile = "$savedGamesFolder\Caucasus_.state"


try {
    Write-Host "Removing theater"
    if (Test-Path -Path $stateFile) {
        Remove-Item -Path $stateFile -Force
    }
    if (Test-Path -Path $missionFile) {
        Remove-Item -Path $missionFile -Force
    }
    if (Test-Path -Path $theaterFolder) {
        Remove-Item -Path $theaterFolder -Recurse -Force
    }
    Write-Host "Removing DCT"
    if (Test-Path -Path $dctTechFolder) {
        Remove-Item -Path $dctTechFolder -Recurse -Force
    }
    if (Test-Path -Path $hookFile) {
        Remove-Item -Path $hookFile -Force
    }
    if (Test-Path -Path $cfgFile) {
        Remove-Item -Path $cfgFile -Force
    }
}
catch {
    Write-Host "An error occurred: $_"
}
