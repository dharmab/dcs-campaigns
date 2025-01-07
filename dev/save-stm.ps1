param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

$fileName = Split-Path -Leaf $FilePath
$targetFile = Join-Path -Path (Get-Location) -ChildPath $FilePath
$targetDirectory = Split-Path -Path $targetFile -Parent
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory -Force
}

$staticTemplateDirectory = "$env:USERPROFILE\Saved Games\DCS\StaticTemplate"
$sourceFile = Join-Path -Path $staticTemplateDirectory -ChildPath $fileName
if (-not (Test-Path -Path $sourceFile)) {
    Write-Host "Error: static template file '$fileName' does not exist in the DCS StaticTemplate directory." -ForegroundColor Red
    exit 1
}

Copy-Item -Path $sourceFile -Destination $targetFile -Force
Write-Host "copied '$fileName' from the DCS StaticTemplate directory and overwritten at '$targetFile'"

