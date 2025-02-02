#!/usr/bin/env pwsh

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Error "Install a newer version of PowerShell from the Windows Store and run this script with that version. Current version: $($PSVersionTable.PSVersion)"
    exit 1
}

if ($args.Count -lt 1) {
    Write-Host "Usage: .\install.ps1 THEATER"
    Write-Host "Example: .\install.ps1 calamity"
    exit
}

$theaterName = $args[0]

$savedGamesFolder = "$env:USERPROFILE\Saved Games\DCS"

$entryFileSrc = "dct/entry.lua"
if (-Not (Test-Path -Path $entryFileSrc)) {
    Write-Host "entry.lua not found: $entryFileSrc"
    exit
}
$entryFileDest = "$savedGamesFolder\Mods\Tech\DCT\entry.lua"

$luaFolderSource = "dct/lua"
if (-Not (Test-Path -Path $luaFolderSource)) {
    Write-Host "lua folder not found: $luaFolderSource"
    exit
}
$luaFolderDest = "$savedGamesFolder\Mods\Tech\DCT\lua"

$hookFileSource = "dct/dct-hook.lua"
if (-Not (Test-Path -Path $hookFileSource)) {
    Write-Host "dct-hook.lua not found: $hookFileSource"
    exit
}
$hookFileDest = "$savedGamesFolder\Scripts\Hooks\dct-hook.lua"

$cfgFileSource = "dct/dct.cfg"
if (-Not (Test-Path -Path $cfgFileSource)) {
    Write-Host "dct.cfg not found: $cfgFileSource"
    exit
}
$cfgFileDest = "$savedGamesFolder\Config\dct.cfg"

$theaterFolderSource = "theaters/$theaterName/theater"
if (-Not (Test-Path -Path $theaterFolderSource)) {
    Write-Host "theater not found: $theaterFolderSource"
    exit
}
$theaterFolderDest = "$savedGamesFolder\theater"

$missionFolderSource = "theaters/$theaterName/mission"
if (-Not (Test-Path -Path $missionFolderSource)) {
    Write-Host "mission folder not found: $missionFolderSource"
    exit
}
$missionFileTemp = "$env:TEMP\mission.zip"
$missionFileDest = "$savedGamesFolder\Missions\dct-$theaterName.miz"

try {
    Write-Host "Removing any exising DCT files from $env:USERPROFILE\Saved Games\DCS"
    if (Test-Path -Path $theaterFolderDest) {
        Remove-Item -Path $theaterFolderDest -Recurse -Force        
    }
    $dctDataFolder = "$savedGamesFolder\DCT"
    if (Test-Path -Path $dctDataFolder) {
        Remove-Item -Path $dctDataFolder -Recurse -Force
    }
    $dctTechFolder = "$savedGamesFolder\Mods\Tech\DCT"
    if (Test-Path -Path $dctTechFolder) {
        Remove-Item -Path $dctTechFolder -Recurse -Force
    }
    if (Test-Path -Path $missionFileTemp) {
        Remove-Item -Path $missionFileTemp -Force        
    }
    if (Test-Path -Path $missionFileDest) {
        Remove-Item -Path $missionFileDest -Force        
    }

    Write-Host "Installing DCT"
    if (!(Test-Path -Path $dctDataFolder)) {
        New-Item -ItemType Directory -Path $dctDataFolder | Out-Null
    }
    if (!(Test-Path -Path $dctTechFolder)) {
        New-Item -ItemType Directory -Path $dctTechFolder | Out-Null
    }
    $hooksFolder = "$savedGamesFolder\Scripts\Hooks"
    if (!(Test-Path -Path $hooksFolder)) {
        New-Item -ItemType Directory -Path $hooksFolder | Out-Null
    }
    $cfgFolder = "$savedGamesFolder\Config"
    if (!(Test-Path -Path $cfgFolder)) {
        New-Item -ItemType Directory -Path $cfgFolder | Out-Null
    }

    Copy-Item -Path $entryFileSrc -Destination $entryFileDest -Force
    Copy-Item -Path $luaFolderSource -Destination $luaFolderDest -Recurse -Force
    Copy-Item -Path $hookFileSource -Destination $hookFileDest -Force
    Copy-Item -Path $cfgFileSource -Destination $cfgFileDest -Force

    Write-Host "Configuring DCT"
    (Get-Content $cfgFileDest).Replace("USERPROFILE_HERE", $env:USERPROFILE) | Set-Content $cfgFileDest

    Write-Host "Installing $theaterName theater"
    Copy-Item -Path $theaterFolderSource -Destination $theaterFolderDest -Recurse -Force

    # Add all of the files and folders in the mission folder to a zip file
    Write-Host "Creating $missionFileDest"
    Compress-Archive -Path "$missionFolderSource\*" -DestinationPath $missionFileTemp -Force
    Copy-Item -Path $missionFileTemp -Destination $missionFileDest -Force
}
catch {
    Write-Host "An error occurred: $_"
}
finally {
    if (Test-Path -Path $missionFileTemp) {
        Remove-Item -Path $missionFileTemp -Force
    }
}