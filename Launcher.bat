@echo off
setlocal enabledelayedexpansion

:: detect if system doesn't support "devcon"
devcon >nul 2>&1
if "%errorlevel%"=="9009" set noDevcon=1

:: if devcon.exe is not in current directory, copy it from current path. this is for 'restart as administrator' feature in the main script to work. because when it restarts, it runs without ECPP's paths.
:: if not exist "devcon.exe" @for /f "usebackq delims=" %%i in (`which devcon.exe`) do copy "%%i" >nul 2>&1
:: (cancelled. just ask user to RA first)

if not defined noDevcon start "" "ChMac.bat"&exit
if exist skipInit start "" "ChMac.bat"&exit

:notFound
cls
Title ChMac Reminder
echo.
echo :: ChMac can be enhanced with DevCon.exe. Without DevCon.exe
echo    it still works but you'd have to manually re-enable the network
echo    adapter for the changes to take effect. DevCon.exe can be put
echo    in %ecppDir%\Exe\*
echo.
echo :: These choices are available:
echo.
echo    1. Download it manually ^(Open DevCon web page^)
echo.
echo    2. Continue and remind me again
echo.
echo    3. Continue and never remind me again
echo.
call "%ecppDir%\Data\Batch\_choiceMulti.bat" /msg ":: Please choose [1,2,3] " /errorlevel 3
echo.
if %errorlevel% EQU 3 (echo skipInit > skipInit)&start "" "ChMac.bat"&exit
if %errorlevel% EQU 2 start "" "ChMac.bat"&exit
if %errorlevel% EQU 1 (start http://support.microsoft.com/kb/311272) & exit
goto :notFound