# fix_nuget.ps1
$nuget_url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$target_path = Join-Path $PSScriptRoot "windows\nuget.exe"

if (-not (Test-Path $target_path)) {
    Write-Host "Downloading nuget.exe..."
    Invoke-WebRequest -Uri $nuget_url -OutFile $target_path
}

$env:PATH = "$($PSScriptRoot)\windows;" + $env:PATH
Write-Host "Running flutter build windows..."
flutter build windows
