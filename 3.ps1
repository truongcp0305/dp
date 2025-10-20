<#
system_report.ps1
Generates system information report (HTML + CSV) and saves to an output folder.
Usage:
  - Save this file and run in an elevated PowerShell session if you want driver/installed-program info.
  - Example: powershell -ExecutionPolicy Bypass -File .\system_report.ps1
  - Or provide an output directory: .\system_report.ps1 -OutputDir "C:\temp\myreport"
#>
param(
    [string]$OutputDir = "C:\Temp\system_report_$(Get-Date -Format yyyyMMdd_HHmmss)",
    [switch]$OpenHtml
)

# Create output folder
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Host "Writing reports to: $OutputDir"

# Helper: safe-get - run command and return null on error
function Safe-Get([scriptblock]$sb) {
    try {
        & $sb
    } catch {
        Write-Warning "Command failed: $($_.Exception.Message)"
        return $null
    }
}

# Collect data
Write-Host "Collecting basic computer info..."
$computer = Safe-Get { Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsVersion, OsArchitecture, OsName, OsBuildNumber }

Write-Host "Collecting CPU info..."
$cpu = Safe-Get { Get-CimInstance Win32_Processor | Select-Object Name, DeviceID, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed }

Write-Host "Collecting memory modules..."
$memory = Safe-Get { Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, BankLabel, Capacity, Speed, DeviceLocator }

Write-Host "Collecting baseboard and BIOS..."
$baseboard = Safe-Get { Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber }
$bios = Safe-Get { Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate }

Write-Host "Collecting GPU info..."
$gpus = Safe-Get { Get-CimInstance Win32_VideoController | Select-Object Name, AdapterRAM, DriverVersion }

Write-Host "Collecting physical disks and volumes..."
$physdisks = Safe-Get { Get-PhysicalDisk | Select-Object FriendlyName, MediaType, Size, OperationalStatus }
$volumes = Safe-Get { Get-Volume | Select-Object DriveLetter, FileSystemLabel, FileSystem, SizeRemaining, Size }
$logicaldisks = Safe-Get { Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, FreeSpace, Size }

Write-Host "Collecting network adapters and IP addresses..."
$netadapters = Safe-Get { Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed }
$ipaddresses = Safe-Get { Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' } | Select-Object InterfaceAlias, IPAddress, PrefixLength }
$dns = Safe-Get { Get-DnsClientServerAddress | Select-Object InterfaceAlias, ServerAddresses }

Write-Host "Collecting installed programs (may require admin)..."
# Registry-based program list (both 64-bit and 32-bit locations)
$uninstallPaths = @("HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
$programs = @()
foreach ($p in $uninstallPaths) {
    try {
        $items = Get-ItemProperty -Path $p -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
        if ($items) { $programs += $items }
    } catch {}
}
$programs = $programs | Sort-Object DisplayName -Unique

Write-Host "Collecting signed PnP drivers (may take a while)..."
$drivers = Safe-Get { Get-CimInstance Win32_PnPSignedDriver | Select-Object DeviceName, Manufacturer, DriverVersion, DriverDate }

# Build HTML report
Write-Host "Building HTML report..."
# Initialize $htmlSections as an empty array explicitly
$htmlSections = [System.Collections.ArrayList]@()

function Add-Section($title, $object) {
    Write-Host "Adding section: $title"
    if (-not $object -or $object.Count -eq 0) { 
        Write-Warning "Skipping section '$title' as it has no data."
        return 
    }
    # Ensure pipeline input (handles single object or arrays) and wrap in a <section>
    $table = $object | ForEach-Object { $_ } | ConvertTo-Html -Fragment -PreContent "<h2>$title</h2>"
    $sectionHtml = "<section>`n$table`n</section>"
    # Explicitly add to the array using +=
    $htmlSections.Add("<section>`n$table`n</section>") | Out-Null  # Ensure $sectionHtml is treated as an array element
}

Add-Section -title 'Computer' -object $computer
Add-Section -title 'CPU' -object $cpu
Add-Section -title 'Memory Modules' -object $memory
Add-Section -title 'Baseboard' -object $baseboard
Add-Section -title 'BIOS' -object $bios
Add-Section -title 'GPUs' -object $gpus
Add-Section -title 'Physical Disks' -object $physdisks
Add-Section -title 'Volumes' -object $volumes
Add-Section -title 'Logical Disks' -object $logicaldisks
Add-Section -title 'Network Adapters' -object $netadapters
Add-Section -title 'IP Addresses' -object $ipaddresses
Add-Section -title 'DNS Servers' -object $dns
Add-Section -title 'Installed Programs' -object $programs
Add-Section -title 'Drivers' -object $drivers

$fullHtml = @"
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
<title>System Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
<style>
body{font-family:Segoe UI, Tahoma, Arial; margin:20px}
h1{font-size:22px}
section{margin-bottom:20px}
table{border-collapse:collapse; width:100%; margin-top:6px}
th,td{border:1px solid #ddd; padding:6px; text-align:left}
th{background:#f2f2f2}
</style>
</head>
<body>
<h1>System Report</h1>
<p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
"@

# Ensure $htmlSections is not empty before joining
if ($htmlSections.Count -gt 0) {
    Write-Host "DEBUG: htmlSections.Count = $($htmlSections.Count)"
    $fullHtml += ($htmlSections -join "`n<hr/>`n")
} else {
    Write-Warning "No sections were added to the HTML report."
}

$fullHtml += "`n</body>`n</html>"

$HtmlPath = Join-Path $OutputDir 'system_report.html'
$fullHtml | Out-File -FilePath $HtmlPath -Encoding UTF8

Write-Host "Reports written. HTML: $HtmlPath"

# Open the HTML file in the default browser
Start-Process "cmd.exe" "/c start $HtmlPath"

Write-Host "Done."