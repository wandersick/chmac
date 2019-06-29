:: This file is part of ChMac
:: Copyright (C)2010 wanderSick ( http://wandersick.blogspot.com/ | wandersick@gmail.com )
::
:: ChMac is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: ChMac is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with ChMac.  If not, see <http://www.gnu.org/licenses/>.

:: ------------------------------------------------------------
:: See main script -- fy.cmd -- for more details.
:: ------------------------------------------------------------

@echo off

setlocal ENABLEDELAYEDEXPANSION

:: @if /i "%1"=="/ud" is used cos there're 3 ways to check for update (ud = update), one is thru
:: /ud (<- for interactive checking by entering 'ud') and
:: /ud2 (<- both with msg display, except that /ud2 exit cmd at the end, so its used for startup check),
:: another is thru setting udStart=true in _config.bat and
:: "call _update" with the script (<- this way is totally silent, was used for startup check but now unused).
:: When user specifies auto check at start up, it is better to show no msg when there's no update

:: [translation]                              .. Please wait ..
if /i "%1"=="/ud" echo.&echo.&echo !uWaitMsg1%lang%!
pushd %temp%

:: REMINDER: keep "Enhanced Command Prompt Portable 2.0 Final" on server
:: REMINDER: if it has space, replace with +
for %%i in ("ws.chmac.10a" "ws.chmac.11" "ws.chmac.15" "ws.chmac.20" "ws.chmac.20b") do (
	del cmdDictUpdate.tmp /F /Q >nul 2>&1
	REM "%ChMacDir%\Data\3rdparty\wget.exe" --output-document=cmdDictUpdate.tmp --include-directories=www.google.com --accept=html -t2 -E -e robots=off -T 8 -U "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7) Gecko/20040613 Firefox/0.8.0+" "http://www.google.com/search?as_q=&hl=en-US&num=10&as_epq=%%~i&as_oq=&as_eq=&lr=&cr=&as_ft=i&as_filetype=&as_qdr=all&as_occt=any&as_dt=i&as_sitesearch=wandersick.blogspot.com" >nul 2>&1
	"%ChMacDir%\Data\3rdparty\curl.exe" "http://www.google.com/search?as_q=&hl=en-US&num=10&as_epq=%%~i&as_oq=&as_eq=&lr=&cr=&as_ft=i&as_filetype=&as_qdr=all&as_occt=any&as_dt=i&as_sitesearch=wandersick.blogspot.com" -A "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7) Gecko/20040613 Firefox/0.8.0+" --retry 1 -m 8 -o cmdDictUpdate.tmp >nul 2>&1
	@if !errorlevel! NEQ 0 (
		REM [translation] An error occured during update check
		REM [translation] Verify Internet connectivity.
		REM [translation] Going back in a few seconds
		@if /i "%1"=="/ud" echo &echo :: !uErr1a%lang%!^^^! !uErr1b%lang%!&echo.&echo :: !uErr1c%lang%!...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
		goto :end
	)
	REM check if the downloaded page is empty (i.e. actually not downloaded)
	@for /f "usebackq tokens=* delims=" %%a in (`type cmdDictUpdate.tmp 2^>nul`) do set udContent=%%a >nul 2>&1
	find /i "did not match any documents" "cmdDictUpdate.tmp" >nul 2>&1
	@if !errorlevel! EQU 0 (
		set updateFound=false
	) else (
		@if "!udContent!"=="" (
			set updateFound=error
		) else (
			set updateFound=true&goto updateFound
		)
	)
)
:updateFound
if defined debug echo updateFound: %updateFound%
if /i "%updateFound%"=="false" (
	REM [translation]                         **  No update was found  **
	REM [translation] You may check manually at
	REM [translation] Going back in a few seconds
	@if /i "%1"=="/ud" echo.&echo !uMsg2a%lang%!&echo.&echo.&echo :: !uMsg2b%lang%! wandersick.blogspot.com&echo.&echo :: !uErr1c%lang%!...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
) else if /i "%updateFound%"=="error" (
	REM [translation] An error occured during update check
	REM [translation] Verify Internet connectivity.
	REM [translation] Going back in a few seconds
	echo.&echo :: !uErr1a%lang%!^^^! !uErr1b%lang%!&echo.&echo :: !uErr1c%lang%!...&((timeout /T 6 >nul 2>&1) || (ping -n 6 -l 2 127.0.0.1 >nul 2>&1))
) else if /i "%updateFound%"=="true" (
	REM beep
	echo 
	REM flashes taskbar
	start "" "%ChMacDir%\Data\_winflash_wget.exe"
	REM [translation] A new version seems available. Visit
	call "%ChMacDir%\Data\_choiceYn.bat" ":: !uFoundMsg3%lang%! wandersick.blogspot.com? [Y,N] " N 20
	@if !errorlevel! EQU 0 start http://wandersick.blogspot.com
)
:end
popd
endlocal
if /i "%~2"=="/udstart" exit
goto :EOF