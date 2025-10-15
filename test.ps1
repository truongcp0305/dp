# create_and_schedule.ps1
# Tạo scheduled task "WinRpStart" chạy install.ps1 lúc đăng nhập
# Khi bạn xóa task, nó cũng xóa luôn install.ps1 và log.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$taskName = "WinRpStart"
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

Write-Info "Script directory: $scriptDir"
Write-Info "Install script: $installPath"

# 1️⃣ Nội dung file install.ps1
$installContent = @'
# install.ps1 - auto-generated
# Tải dp.zip, giải nén, chạy new.bat, log lại toàn bộ.

$log = Join-Path $PSScriptRoot 'install.log'
Try { Start-Transcript -Path $log -Force } Catch {}

Try {
    Write-Output "===> Start at $(Get-Date -Format o)"

    iwr https://github.com/truongcp0305/dp/archive/refs/heads/main.zip -OutFile dp.zip -UseBasicParsing
    Expand-Archive -LiteralPath dp.zip -DestinationPath . -Force
    Remove-Item dp.zip -Force -ErrorAction SilentlyContinue

    if (Test-Path ".\dp-main") {
        Set-Location ".\dp-main"
        Write-Output "→ Entered $(Get-Location)"
    } else {
        Write-Error "Folder dp-main not found!"
        throw "Missing dp-main"
    }

    if (Test-Path ".\new.bat") {
        Write-Output "Running new.bat..."
        & .\new.bat
        Write-Output "new.bat exited with $LASTEXITCODE"
    } else {
        Write-Error "new.bat missing!"
        throw "new.bat missing"
    }

    Write-Output "===> Done at $(Get-Date -Format o)"
} Catch {
    Write-Error "Error: $_"
} Finally {
    Try { Stop-Transcript } Catch {}
}
'@

# 2️⃣ Kiểm tra có task chưa
Write-Info "Checking for existing task '$taskName'..."
$exists = schtasks /Query /TN $taskName 2>$null

if ($LASTEXITCODE -eq 0) {
    Write-Warn "Task '$taskName' đã tồn tại. Bạn muốn xóa không?"
    $choice = Read-Host "Nhập Y để xóa task này (và xóa luôn file ps1), hoặc nhấn Enter để giữ nguyên"
    if ($choice -match '^[Yy]$') {
        Write-Info "Xóa task..."
        schtasks /Delete /TN $taskName /F | Out-Null

        # Xóa file ps1 và log nếu tồn tại
        if (Test-Path $installPath) {
            Remove-Item $installPath -Force -ErrorAction SilentlyContinue
            Write-Info "Đã xóa $installPath"
        }
        if (Test-Path $logPath) {
            Remove-Item $logPath -Force -ErrorAction SilentlyContinue
            Write-Info "Đã xóa $logPath"
        }

        Write-Info "Đã xóa task và file thành công."
        exit 0
    } else {
        Write-Info "Giữ nguyên task hiện có."
        exit 0
    }
}

# 3️⃣ Tạo file install.ps1
Write-Info "Tạo file install.ps1..."
Set-Content -Path $installPath -Value $installContent -Encoding UTF8

# 4️⃣ Tạo task mới
Write-Info "Tạo scheduled task '$taskName'..."
$quotedScript = '"'+($installPath -replace '"','\"')+'"'
$tr = "powershell -NoProfile -ExecutionPolicy Bypass -File $quotedScript"

schtasks /Create /TN $taskName /TR $tr /SC ONLOGON /RL HIGHEST /F | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Info "✅ Task '$taskName' đã tạo thành công."
} else {
    Write-Err "❌ Lỗi khi tạo task. Mã lỗi: $LASTEXITCODE"
    exit 1
}

# 5️⃣ Chạy task ngay
Write-Info "Chạy task ngay..."
schtasks /Run /TN $taskName | Out-Null
Write-Info "Task đã được kích hoạt. Kiểm tra install.log sau khi hoàn tất."
