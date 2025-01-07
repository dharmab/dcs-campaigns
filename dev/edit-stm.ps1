param (
    [Parameter(Mandatory = $true)]
    [string]$SourceFile
)

$resolvedSourceFile = Join-Path -Path (Get-Location) -ChildPath $SourceFile
if (-not (Test-Path -Path $resolvedSourceFile)) {
    Write-Host "Error: File '$resolvedSourceFile' not found" -ForegroundColor Red
    exit 1
}

$targetDirectory = "$env:USERPROFILE\Saved Games\DCS\StaticTemplate"
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory -Force
}
$targetFile = Join-Path -Path $targetDirectory -ChildPath (Split-Path -Leaf $resolvedSourceFile)

Copy-Item -Path $resolvedSourceFile -Destination $targetFile -Force
Write-Host "copied $resolvedSourceFile to $targetFile"
