:: ChMac by wanderSick for ECPP
:: requires devcon.exe, reg.exe and getmac.exe, supports XP or higher

:: devcon.exe has to separately downloaded from Microsoft: http://support.microsoft.com/kb/311272.

:: When there's more than 8 adapters, ChoiceMulti will fall back to Set /P

@echo off

if not "%OS%"=="Windows_NT" echo #  ERROR: Windows version not supported.&goto :end9x

setlocal enabledelayedexpansion

:: ======================================================== debugging options
:: set debug=1
:: set debug2=1
if defined debug echo :: Debugging mode 1 is ON.
if defined debug2 echo on&set debug=1&echo :: Debugging mode 2 is ON.

:: set whether to check for ChMac update silently
set mUpdateChMac=Y
set mErrCode=0
set mAutoChangeInterval=None
set ChMacVersion=1.1

:: if elevated itself
:: if /i "%1" EQU "/2ndtime" set secondRun=1


:: ======================================================== language (auto / manual)

:: auto detect current user language. (so far English/Chinese T/Chinese S)
:: separate between CHS, CHT and EN. For CHT (1), use "¥Ø¿ý"; for CHS (2), use "Ä¿Â¼".

:: check if lang is defined in ECPP
if /i "%lang%"=="En" goto :skipLangChk
if /i "%lang%"=="Cht" goto :skipLangChk
if /i "%lang%"=="Chs" goto :skipLangChk
set lang=En
dir %systemdrive% | find /i "¥Ø¿ý" >nul 2>&1
if %errorlevel% EQU 0 set lang=Cht
dir %systemdrive% | find /i "Ä¿Â¼" >nul 2>&1
if %errorlevel% EQU 0 set lang=Chs
:skipLangChk

:: OS ver check

set OSver=0
for /f "usebackq tokens=1* delims=Z" %%a in (`reg query "hklm\software\microsoft\windows nt\currentversion" /v CurrentVersion`) do set OSver=%%b

:: delete used per-session MAC track list

del "%temp%\exclMac.tmp" /f /q >nul 2>&1

:: ======================================================== pre parameter check

:: ======================================================== set work directory (see /d) 

:: detect if user ChMac is run by Run As Administrator (ie %CD% would be windir\system32)
:: correct the working directory to be %~d0%~p0 (i.e. x:\...\Chmac\
:: so that Run As Administrator would not fail
:: (cancelled) if /i "%CD%" EQU "%windir%\system32" cd /d %~d0%~p0

:: (cancelled) always cd into the directory of the bat (ie as working directory)
:: cd /d %~d0%~p0

:: fall back if ECPP is not present
:: (cancelled) if not defined ChMacDir @if defined ecppDir (set ChMacDir=%ecppDir%\Data\Batch) else (set ChMacDir=%CD%)
set ChMacDir=%~d0%~p0

:: to manually specify work directory
if /i "%~1"=="/d" (
	REM check if ChMacDir is correct
	@if not exist "%~2\Data\_choiceMulti.bat" (
		set mErrType=Syntax Error: Working directory. ^(/D^)
		set mErrCode=4
		goto :error
	)
	set ChMacDir=%~2
	shift
	shift
)

:: ======================================================== set PATH for some sub-components with no absolute path

:: check if path of subscript folder already set
echo %path% | find /i "%chmacdir%Data\3rdparty" >nul 2>&1

if %errorlevel% NEQ 0 (
	REM set path for sub-elements
	set PATH=%chmacdir%Data;%chmacdir%Data\3rdparty;%chmacdir%Data\3rdparty\i386;%PATH%;%chmacdir%Data\3rdparty\LP
)

:: ======================================================== TRANSLATION

:: load translations
call "%chmacdir%Data\_translation.bat"&set mTranslation=1

:: ======================================================== check for executables / rights

:: detect if system doesn't support "more"
more nul >nul 2>&1
if "%errorlevel%"=="9009" set noMore=1

:: detect if system doesn't support "reg"
reg >nul 2>&1
if "%errorlevel%"=="9009" (
	set mErrType=Error: No reg.exe. Place one from XP in "%chmacdir%Data\3rdparty\LP"
	set mErrCode=5
	goto :error
)

:: detect if system doesn't support "devcon"
which devcon >nul 2>&1
if %errorlevel% NEQ 0 set noDevcon=1

:: detect if system doesn't support "attrib"
:: attrib >nul 2>&1
:: if "%errorlevel%"=="9009" (
:: 	set mErrType=Error: No attrib.exe. Place one from XP in "%chmacdir%Data\3rdparty\LP"
:: 	set mErrCode=5
:: 	goto :error
:: )

:: getmac takes a long time to load, cannot check that way
if not exist "%windir%\system32\getmac.exe" (
	@if not exist "%chmacdir%Data\3rdparty\getmac.exe" (
		@if not exist "%chmacdir%Data\3rdparty\LP\getmac.exe" (
			set mErrType=Error: No getmac.exe. Place one from XP in "%chmacdir%Data\3rdparty\LP"
			set mErrCode=5
			goto :error
		)
	)
)

:: help parameter check

if /i "%~1"=="/?" (
	set mHelp=1
	set mShortHelp=1
	goto :Help
)

if /i "%~1"=="/help" (
	set mHelp=1
	goto :Help
)


:: detect for admin rights (it's fine without admin rights with UAC as devcon can elevate itself -- unless UAC is disabled)
attrib -h "%windir%\system32" | find /i "system32" >nul 2>&1
if %errorlevel% EQU 0 (
	set noAdmin=1
)

if defined ECPP set noAdminEcppMsg= Run RA from ECPP first.
if defined noAdmin (
	set mErrType=Error: No admin right. Please run as admin.%noAdminEcppMsg%
	set mErrCode=7
	goto :error
)

:: elevate as admin or output error, unless its already been elevated 1 time
:: if defined noAdmin @if not defined secondRun ("%ecppDir%\Data\Batch\3rdparty\HP\elevate.cmd" "%comspec%" /c start "" /D "%ecppDir%\data\batch\tasks\ChMac\" "ChMac.bat" /2ndtime) else (echo.&echo :: Sorry. Admin rights are required.&echo.&pause&exit)
:: (cancelled because devcon.exe wouldn't be in path)

:: ======================================================== parameter and input check

:parameterCheck

if /i "%~1"=="/m" (
	REM strip input of unnecessary things + convert to caps
	@for /f "usebackq tokens=* delims=" %%i in (`echo "%~2"^| tr.exe -s "[:punct:][:cntrl:][:space:]" " " ^| tr.exe "a-z" "A-Z" ^| sed.exe -e "s/^.//g" -e "s/.$//g"`) do set mCmdNewMac=%%i
	REM to correct format
	set mCmdNewMac=!mCmdNewMac:-=!
	set mCmdNewMac=!mCmdNewMac::=!
	set mCmdNewMac=!mCmdNewMac: =!
	set mCmdNewMac=!mCmdNewMac:.=!
	REM check for wrong length
	@for /f "usebackq" %%i in (`echo !mCmdNewMac!^| wc.exe -m`) do (
		@if /i "%%i" NEQ "14" (
			@if /i "%%i" NEQ "12" (
				set mErrType=Syntax Error: Wrong address length (^/M^)
				set mErrCode=4
				goto :error
			)
		)
	)
	REM check for non hex
	echo !mCmdNewMac!| "%chmacdir%Data\3rdparty\grep.exe" "[^[:xdigit:]]" >nul 2>&1
	@if !errorlevel! EQU 0 (
		set mErrType=Syntax Error: Not hexadecimal ^(/M^)
		set mErrCode=4
		goto :error
	)
	set mCmd=1
	shift
	shift
	goto :parameterCheck
)

if /i "%~1"=="/n" (
	REM check for non digit
	echo "%~2"|"%chmacdir%Data\3rdparty\tr.exe" -d "\042"|"%chmacdir%Data\3rdparty\grep.exe" "[^[:digit:]]" >nul 2>&1
	@if !errorlevel! EQU 0 (
		set mErrType=Syntax Error: Not digit ^(/N^)
		set mErrCode=4
		goto :error
	)
	set mCmdAdapterNum=%~2
	set mCmd=1
	shift
	shift
	goto :parameterCheck
)

if /i "%~1"=="/r" (
	set mCmd=1
	set mRestoreOriginalMac=1
	shift
	goto :parameterCheck
)

if /i "%~1"=="/a" (
	REM check for non digit
	echo "%~2"|"%chmacdir%Data\3rdparty\tr.exe" -d "\042"|"%chmacdir%Data\3rdparty\grep.exe" -i  "^[0-9]*[smhd]$" >nul 2>&1
	@if !errorlevel! NEQ 0 (
		set mErrType=Syntax Error: Not digit or smhd ^(/A^)
		set mErrCode=4
		goto :error
	)
	set mAutoChangeInterval=%~2
	REM convert to lowercase since sleep.exe doesn't accept uppercase
	@for /f "usebackq tokens=* delims=" %%i in (`echo !mAutoChangeInterval!^|"%chmacdir%Data\3rdparty\tr.exe" "[:upper:]" "[:lower:]"`) do set mAutoChangeInterval=%%i
	set mCmd=1
	shift
	shift
	goto :parameterCheck
)

if /i "%~1"=="/l" (
	set mCmdList=1
	set mCmd=1
	goto :ChMac
)

if /i "%~1"=="/u" (
	call "%chmacdir%Data\_update2.bat" /ud
	goto :end
)

if /i "%~1"=="/d" (
	set mErrType=Syntax Error: Working directory ^(/D^)
	set mErrCode=4
	goto :error
)

if defined mCmdNewMac @if not defined mCmdAdapterNum (
	set mErrType=Syntax Error: Missing parameter /N ^(/M^)
	set mErrCode=4
	goto :error
)

REM check for -
echo "%~1"|"%chmacdir%Data\3rdparty\tr.exe" -d "\042"|"%chmacdir%Data\3rdparty\grep.exe" -i  "^-" >nul 2>&1
@if %errorlevel% EQU 0 (
	set mErrType=Syntax Error: Please use "/" instead of '-'
	set mErrCode=4
	goto :error
)

REM check for any left wrong parameter
:: echo "%~1"|"%chmacdir%Data\3rdparty\tr.exe" -d "\042"|"%chmacdir%Data\3rdparty\grep.exe" -i  "^/" >nul 2>&1
:: @if %errorlevel% EQU 0 (
:: 	set mErrType=Syntax Error: Unknown parameter
:: 	set mErrCode=4
:: 	goto :error
:: )

REM check for any left wrong parameter
if "%~1" NEQ "" (
	set mErrType=Syntax Error: Unknown parameter: "%~1"
	set mErrCode=4
	goto :error
)

REM in command line mode title is not shown
if not defined mCmd title ChMac v1.1 - Download DevCon.exe

if not defined noDevcon goto :MainMenu
if exist "%chmacdir%Data\skipInit" goto :MainMenu
:Reminder
cls
echo.
echo :: ChMac can be enhanced with DevCon.exe. Without it ChMac works too,
echo    but at the end the Network Connections folder will be presented so as
echo    to manually disable and enable the adapter for changes to take effect.
echo.
echo :: Available choices:
echo.
echo    1. Download it automatically
echo.
echo    2. Download it manually ^(Open DevCon web page^)
echo.
echo    3. Continue and remind me next time
echo.
echo    4. Continue and never remind me again
echo.
call "%chmacdir%Data\_choiceMulti.bat" /msg ":: Please choose [1,2,3,4] " /errorlevel 4
set cmReminderChoice=%errorlevel%
echo.
if %cmReminderChoice% EQU 4 (echo skipInit>"%chmacdir%Data\skipInit")&goto :MainMenu
if %cmReminderChoice% EQU 3 (del "%chmacdir%Data\skipInit" /f /q >nul 2>&1)&goto :MainMenu
:ReminderOption2
if %cmReminderChoice% EQU 2 (
	cls
	echo.
	echo :: A web page will be opened in 5 seconds. Please wait.
	echo.
	echo    After the download, run the exe which is a self-extracting
	echo    archive. Then just click "Unzip". Do NOT modify the path.
	echo.
	echo :: Press any key here after the above has been performed.
	"%chmacdir%Data\3rdparty\sleep.exe" 5
	start http://support.microsoft.com/kb/311272
	pause >nul 2>&1
	@if not exist "%temp%\i386\devcon.exe" (
		cls
		echo 
		echo #   Error: devcon.exe not found in "%temp%\i386"
		echo.
		echo #   Please try again.
		echo.
		pause
		goto :ReminderOption2
	)
	goto :MainMenu
)
:ReminderOption1
if %cmReminderChoice% EQU 1 (
	cls
	wget http://download.microsoft.com/download/1/1/f/11f7dd10-272d-4cd2-896f-9ce67f3e0240/devcon.exe --output-document=devcon_package.exe >nul 2>&1
	@if !errorlevel! NEQ 0 (
		cls
		echo 
		echo #   Error: Cannot download DevCon.exe
		echo.
		echo #   Please try again or choose another option.
		echo.
		del devcon_package.exe /f /q >nul 2>&1
		pause
		goto :Reminder
	)
	echo 
	echo :: Just click "Unzip" and close. Do NOT change the path.
	echo.
	devcon_package.exe
	del devcon_package.exe /f /q >nul 2>&1
	@if not exist "%temp%\i386\devcon.exe" (
		cls
		echo 
		echo #   Error: devcon.exe not found in "%temp%\i386"
		echo.
		echo #   Please try again.
		echo.
		pause
		goto :ReminderOption1
	)
	copy "%temp%\i386\devcon.exe" "%chmacdir%Data\3rdparty\devcon.exe" /y >nul 2>&1
	copy "%temp%\EULA.txt" "%chmacdir%Data\3rdparty\devcon-EULA.txt" /y >nul 2>&1
	goto :MainMenu
)
goto :Reminder

:MainMenu
:: mTitleConsoleMsg is for title below; mOperationTypeMsg is used for summary
if defined mCmd (set mOperationTypeMsg=Command-line) else (set mTitleConsoleMsg=Interactive Console&set mOperationTypeMsg=Interactive)
:: menu not implemented

:ChMac
title ChMac v1.1 %mTitleConsoleMsg%
:: less is displayed in command line mode than in interactive
if not defined mCmd (
	cls
	set mNumOfAdapters=0
	@if not defined mRerun set mNumofAdapterChoice=1
	echo.
	echo :: Please wait a bit while ChMac initializes...
	echo.
) else (
	echo.
	echo :: Enumerating available network interface cards...
	echo.
)
:: Getmac in csv output is the best to grab the 4 columns completely without the header
for /f "usebackq tokens=1-4 delims=," %%i in (`getmac /v /nh /fo csv`) do set /a mNumOfAdapters+=1&set mName!mNumOfAdapters!=%%~i&set mAdapter!mNumOfAdapters!=%%~j&set mMac!mNumOfAdapters!=%%~k&set mID!mNumOfAdapters!=%%~l

if %mNumOfAdapters% EQU 0 (
	set mErrType=Error: No network adapter found.
	set mErrCode=4
	goto :error
)

:ChMacLoaded
set mIsVirtualAdapter=
set mErrorLevel=
if not defined mCmd (
	set mRestoreOriginalMac=
	cls
	echo.
	echo :: Number of network adapters detected: %mNumOfAdapters%
	echo.
	echo :: Please choose an adapter
	echo.
)
for /l %%i in (1,1,%mNumOfAdapters%) do (
  echo    %%i. !mAdapter%%i:~0,73!
  echo       + [!mName%%i!]
  echo.
  REM to make the Choice line show 1,2,3,4 
  @if not defined mRerun @if %%i NEQ 1 set mNumofAdapterChoice=!mNumofAdapterChoice!,%%i
)
if defined mCmdList (
	echo :: For example, to change the Mac address of [1]:
	echo.
	echo     . chmac /n 1 /m 1A2B3C4D5E6F ^(/m is optional; randomized if without^)
	REM if run by /L, quit at this stage
	goto :EOF
) else if defined mCmdAdapterNum (
	echo :: Chosen Nic: %mCmdAdapterNum%
)
REM if command line mode, skip to mCmdAdapterNum
if defined mCmd goto :CmdAdapterNum
REM if not command line mode but mCmdAdapterNum still defined, i.e. returned from sub menu unplugged error, skip directly to the screen after choosing that adapter ID.
if defined mCmdAdapterNum goto :CmdAdapterNum
REM add a few more options, e.g. Quit
set /a mNumPlusOne=%mNumOfAdapters%+1
set /a mNumPlusTwo=%mNumOfAdapters%+2
@if not defined mRerun set mNumofAdapterChoice=!mNumofAdapterChoice!,%mNumPlusOne%,%mNumPlusTwo%
if /i "%mAutoChangeInterval%" NEQ "None" (set mAutoChangeIntervalMsg=^(%mAutoChangeInterval%^)) else (set mAutoChangeIntervalMsg=)
echo    %mNumPlusOne%. Configure auto-changing %mAutoChangeIntervalMsg%
echo.
echo    %mNumPlusTwo%. Exit
echo.
:: check if there are more than 8 adapters (including the Quit, then 9)
if not %mNumOfAdapters% GEQ 9 (
  call "%chmacdir%Data\_choiceMulti.bat" /msg ":: Please make a choice [%mNumofAdapterChoice%] " /errorlevel %mNumPlusTwo%
) else (
  set /p mErrorLevel=:: Please make a choice [%mNumofAdapterChoice%] 
)
:: if mErrorLevel is defined, means that there're more than 9 adapters which is more than ChoiceMulti can take.
:: then set /p is used and user can input anything.

:: if not defined mErrorLevel, i.e. not using set /p, so mErrorLevel becomes the errorlevel of choiceMulti
if not defined mErrorLevel set mErrorLevel=%errorlevel%
:DefineInterval
if %mErrorLevel% EQU %mNumPlusOne% (
	cls
	echo.
	echo :: Specify an interval to automatically change random MAC address.
	echo.
	echo    Suffix may be s for seconds, m for minutes, h for hours or d for days,
	echo.   e.g. enter '20m' for a 20-minute schedule. [X] to reset and exit.
	echo.
	echo    ^(This is useful for free Wi-Fi hotspots with time limits.^)
	echo.
	set /p mAutoChangeInterval=:: Input [0-9smhd,X]: 
	REM check if interval is reset
	if /i "!mAutoChangeInterval!"=="x" set mAutoChangeInterval=None&set mRerun=1&goto :ChMacLoaded
	REM check if not only digit
	echo !mAutoChangeInterval!|"%chmacdir%Data\3rdparty\grep.exe" -i  "^[0-9]*[smhd]$" >nul 2>&1
	@if !errorlevel! NEQ 0 goto :DefineInterval
	REM convert to lowercase since sleep.exe doesn't accept uppercase
	@for /f "usebackq tokens=* delims=" %%i in (`echo !mAutoChangeInterval!^|"%chmacdir%Data\3rdparty\tr.exe" "[:upper:]" "[:lower:]"`) do set mAutoChangeInterval=%%i
	set mRerun=1
	goto :ChMacLoaded
)
if %mErrorLevel% EQU %mNumPlusTwo% (
  cls
  echo.
  echo    Thanks for using ChMac v1.1
  echo.
  sleep 1s >nul 2>&1
  cls
  REM echo    To check for updates, perform "chmac /u".
  REM echo.
  REM echo.  
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo.
  REM echo    2
  REM sleep 1s >nul 2>&1
  REM echo.
  REM echo    1
  REM sleep 1s >nul 2>&1
  goto :end
)
:CmdAdapterNum
:: start point for command line /N (manually set network adapter ID). it then becomes mChosenAdapterNum just as in interactive mode
if defined mCmdAdapterNum set mErrorLevel=%mCmdAdapterNum%

for /l %%i in (%mNumOfAdapters%,-1,1) do (
  if "%mErrorLevel%" EQU "%%i" set mChosenAdapterNum=%%i&set mChosenCorrectly=1
)

:: ======================================================== CHECK SELECTED ADAPTER for operability

:: this is for set /p (not choiceMulti) which lets users enter anything, so that when user enters a wrong choice, script will stop.
if not defined mChosenCorrectly (
	@if defined mCmd (
		echo ___________________________________________________________________
		set mErrType=Error: Adapter ID not available ^(/N^)
		set mErrCode=4
		goto :error
	) else (
		echo ___________________________________________________________________
		echo 
		echo :: Wrong choice. Please try again.
		echo.
		pause
		set mRerun=1
		goto :ChMacLoaded
	)
)


:: detect if chosen adapter is non-operational -- check MAC address field for non hex/-
echo !mMac%mChosenAdapterNum%!| "%chmacdir%Data\3rdparty\grep.exe" "[^[:xdigit:]-]" >nul 2>&1
if %errorlevel% EQU 0 (
	@if defined mCmd (
		echo ___________________________________________________________________
		set mErrType=Error: Adapter in a nonoperational state.
		set mErrCode=3
		goto :error	
	) else (
		echo ___________________________________________________________________
		echo 
		echo :: Error: Adapter in a nonoperational state.
		echo.
		call "%chmacdir%Data\_choiceYN.bat" ":: Start Device Manager for debugging? [Y,N] " N 60
		@if %errorlevel% EQU 0 devmgmt.msc
		set mRerun=1
		goto :ChMac
	)
)


:: detect if chosen adapter is unplugged, e.g. un unconnected wireless adapter -- check transport field for keyword "Tcpip_"
echo "!mID%mChosenAdapterNum%!"| find /i "Tcpip_" >nul 2>&1
if %errorlevel% NEQ 0 (
	@if defined mCmd (
		echo ___________________________________________________________________
		set mErrType=Error: Adapter unplugged. Please connect first
		set mErrCode=3
		goto :error	
	) else (
		echo ___________________________________________________________________
		echo 
		echo :: Error: Adapter unplugged.
		echo.
		echo Connect first, then press any key ^(or CTRL+C to exit^)
		pause >nul
		set mCmdAdapterNum=%mChosenAdapterNum%
		set mRerun=1
		goto :ChMac
	)
)

:: detect if chosen adapter is virtual, for an error shown after summary if operation failed.
echo !mAdapter%mChosenAdapterNum%! | find /i "Virtual" >nul 2>&1
if %errorlevel% EQU 0 set mIsVirtualAdapter=1

:randomize

:: for display in summary
set mRandomizedMsg=No

:: current mac address for both cmd and interactive
set mOldMac=!mMac%mChosenAdapterNum%!

:: correct format of current mac address grabbed by getmac
set mOldMac=%mOldMac:-=%
set mOldMac=%mOldMac::=%
set mOldMac=%mOldMac: =%
set mOldMac=%mOldMac:.=%

:: in cmd mode, randomization is performed only when /M (mac address) is unspecified
if defined mCmd @if defined mCmdNewMac (
	set mNewMac=%mCmdNewMac%
	goto :apply
)

:: if auto-change interval was specified, the randomize function will begin at :apply instead
if /i "%mAutoChangeInterval%" NEQ "None" goto :apply

call :RandomizeFunction

:: if cmd mode and randomization is specified
if defined mCmd set mNewMac=%mNewRanMac%&goto :apply

:: Convert MAC address into user-friendly form

for /f "usebackq tokens=* delims=" %%i in (`ECHO %mOldMac%^|sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3-\4-\5-\6/g"`) do set mOldMacFriendly=%%i
for /f "usebackq tokens=* delims=" %%i in (`ECHO %mNewRanMac%^|sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3-\4-\5-\6/g"`) do set mNewRanMacFriendly=%%i


:InputMac
:: set mNewMac=
set mMacInputted=
set mRestoreOriginalMac=
echo ___________________________________________________________________
echo.
echo :: You've chosen: [%mChosenAdapterNum%] !mName%mChosenAdapterNum%!
echo.
echo    Current MAC address:  	%mOldMacFriendly%
echo    New randomized address: 	%mNewRanMacFriendly% [OUI: %mOuiVendor%]
echo.
set /p mNewMac=:: [A] Accept  [G] Gen  [O] OUI  [R] Reset  [X] Exit  or type MAC: 

if "%mNewMac%"=="" goto :InputMac
if /i "%mNewMac%" EQU "X" set mRerun=1&goto :ChMacLoaded
if /i "%mNewMac%" EQU "G" goto :randomize
if /i "%mNewMac%" EQU "O" start "" notepad "%chmacdir%Data\OUI_NT6.txt"&start "" notepad "%chmacdir%Data\OUI_NT5.txt"&goto :InputMac
if /i "%mNewMac%" EQU "A" set mNewMac=%mNewRanMac%
if /i "%mNewMac%" EQU "R" (
	set mRestoreOriginalMac=1
	echo ___________________________________________________________________
	echo.
	echo :: Restoring original MAC address
	echo ___________________________________________________________________
	goto :apply
)

set mMacInputted=1

:: strip input of unnecessary things (+ convert to caps)
for /f "usebackq tokens=* delims=" %%i in (`echo "%mNewMac%"^| tr.exe -s "[:punct:][:cntrl:][:space:]" " " ^| tr.exe "a-z" "A-Z" ^| sed.exe -e "s/^.//g" -e "s/.$//g"`) do set mNewMac=%%i

:: correct MAC address input
set mNewMac=%mNewMac:-=%
set mNewMac=%mNewMac::=%
set mNewMac=%mNewMac: =%
set mNewMac=%mNewMac:.=%

:: check for wrong length
for /f "usebackq" %%i in (`echo %mNewMac%^| wc.exe -m`) do (
	@if /i "%%i" NEQ "14" (
		@if /i "%%i" NEQ "12" (
			echo ___________________________________________________________________
			echo.
			echo :: Wrong length. Try either 12 chars or 17 with hyphen [-] or colon [:]
			set mNewMac=%mNewRanMac%
			goto :InputMac
		)
	)
)

:: check for non hex
echo %mNewMac%| "%chmacdir%Data\3rdparty\grep.exe" "[^[:xdigit:]]" >nul 2>&1
if %errorlevel% EQU 0 (
	echo ___________________________________________________________________
	echo.
	echo :: Not hexadecimal [0-9/A-F]. Please try again.
	set mNewMac=%mNewRanMac%
	goto :InputMac
)

echo ___________________________________________________________________

:: Convert MAC address into user-friendly form

for /f "usebackq tokens=* delims=" %%i in (`ECHO %mNewMac%^|sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3-\4-\5-\6/g"`) do set mNewMacFriendly=%%i

echo.
echo :: Please confirm, your new MAC address is %mNewMacFriendly%
echo.
call "%chmacdir%Data\_choiceYN.bat" ":: Are you sure to apply it? [Y,N] " N 60
echo ___________________________________________________________________
if %errorlevel% NEQ 0 (
  REM reset the mNewMac variable
  set mNewMac=
  echo.
  echo :: Returning to main menu
  set mRerun=1
  goto ChMacLoaded
)

:apply

:: debug mode 1
if defined debug @echo on

:: if auto-change specified, script will loop back to :apply and randomize a new MAC address non-stop 
if /i "%mAutoChangeInterval%" NEQ "None" (
	echo ___________________________________________________________________
	call :RandomizeFunction
)

for /f "usebackq delims={ tokens=2" %%i in (`echo !mID%mChosenAdapterNum%!`) do set mChosenAdapterID={%%i

:: debug mode 1
if defined debug echo.&echo mChosenAdapterID: !mID%mChosenAdapterNum%!&echo %mChosenAdapterID%&echo.

for /l %%i in (1,1,9) do (
    (reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\000%%i" 2^>nul) | find /i "%mChosenAdapterID%" | find /i "NetCfgInstanceId" >nul
    @if !errorlevel! EQU 0 set mAdapterRegNum=000%%i&goto mFound
)

for /l %%i in (10,1,99) do (
    (reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\00%%i" 2^>nul) | find /i "%mChosenAdapterID%" | find /i "NetCfgInstanceId" >nul
    @if !errorlevel! EQU 0 set mAdapterRegNum=00%%i&goto mFound
)

:mFound
echo.
echo :: Found adapter at {4D36E972-E325-11CE-BFC1-08002BE10318}\%mAdapterRegNum%

if defined mRestoreOriginalMac (
	reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\%mAdapterRegNum%" /v "NetworkAddress" /f >nul 2>&1
) else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\%mAdapterRegNum%" /t REG_SZ /v "NetworkAddress" /d "%mNewMac%" /f 
)

:: grab Device Instance ID for use with Devcon
for /f "usebackq tokens=3" %%i in (`reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\%mAdapterRegNum%" /v "MatchingDeviceId"`) do (
  REM wrap it with quotes here for devcon to process it properly (due to reserved characters)
  set mDeviceId="*%%i*"
)
:: convert lowercase to uppercase
:: %mDeviceId% is quoted (no need to add quotes here)
@for /f "usebackq tokens=* delims=" %%i in (`echo %mDeviceId%^| tr.exe "a-z" "A-Z"`) do set mDeviceId=%%i

echo.
echo :: Restarting device with the Device ID:
echo    %mDeviceId%
devcon restart %mDeviceId% >nul 2>&1
if %errorlevel% NEQ 0 (
  echo ___________________________________________________________________
  echo 
  echo :: No DevCon.exe. Opening Network Connections folder instead.
  echo.
  echo :: Please disable and enable the adapter to take effect.
  echo.
  ncpa.cpl
  pause
) else (
	REM wait 2 seconds
	ping -l 2 -n 2 127.0.0.1 >nul 2>&1
)

ipconfig /all > "%temp%\ipConfigAll.tmp"
"%chmacdir%Data\3rdparty\sed.exe" "s/[^[:xdigit:]]//g" < "%temp%\ipConfigAll.tmp" | find /i "%mNewMac%" >nul 2>&1
if %errorlevel% EQU 0 (
	set mSuccessOrFailure=Success&set mErrCode=0
) else if defined mRestoreOriginalMac (
	set mSuccessOrFailure=See 'ipconfig /all'
) else (
	set mSuccessOrFailure=Failure&set mErrCode=1&echo 
)

:: For "Device restarted" msg in summary
if defined noDevcon (set mDevconMsg=Manual) else (set mDevconMsg=Auto)

:: Convert MAC address into user-friendly form (2)

for /f "usebackq tokens=* delims=" %%i in (`ECHO %mOldMac%^|sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3-\4-\5-\6/g"`) do set mOldMacFriendly=%%i
for /f "usebackq tokens=* delims=" %%i in (`ECHO %mNewMac%^|sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1-\2-\3-\4-\5-\6/g"`) do set mNewMacFriendly=%%i
if defined mRestoreOriginalMac set mNewMacFriendly=Restored to original

:: check for update
if /i "%mAutoChangeInterval%" EQU "None" (
	@if /i "%mUpdateChMac%"=="Y" (
		REM without /ud
		call "%chmacdir%Data\_update2.bat"
		@if !errorlevel! EQU 222 (
			echo.
			echo :: New version has been found - http://wandersick.blogspot.com
		)
	)
)

echo ___________________________________________________________________
echo.
echo :: Summary
echo.
echo :: Operation Mode    :   %mOperationTypeMsg%
if defined mCmd (
echo :: Arguments         :   %*
)
echo.
echo :: Connection Name   :   !mName%mChosenAdapterNum%!
echo :: Nic Name          :   !mAdapter%mChosenAdapterNum%:~0,53!
echo :: Nic ID            :   %mChosenAdapterNum%
echo :: Enum ID           :   "{4D36E972-E325-11CE-BFC1-08002BE10318}\%mAdapterRegNum%"
echo :: Plug 'n Play ID   :   %mDeviceId:~0,52%
:: will figout why old mac addr dont display correctly when auto change is defined
if /i "%mAutoChangeInterval%" EQU "None" echo :: Old Mac address   :   %mOldMacFriendly%
echo :: New Mac address   :   %mNewMacFriendly%
echo :: Randomized        :   %mRandomizedMsg%
echo :: Device restarted  :   %mDevconMsg%
echo.
echo :: Result            :   %mSuccessOrFailure%
echo :: Completed time    :   %Date% %time:~0,-6%
echo ___________________________________________________________________
echo.

:: blacklist current MAC not to be used again for randomization in the current session (can be specified manually tho)

echo %mNewMac% >> "%temp%\exclMac.tmp"

set mOldMac=
set mOldMacFriendly=
set mNewMac=
set mNewMacFriendly=
set mNewRanMac=
set mNewRanMacFriendly=

if /i "%mAutoChangeInterval%" NEQ "None" (
	goto :AutoChangeInterval
)


:: extra msg for virtual adapter
if defined mIsVirtualAdapter (set mIsVirtualAdapterMsg=Unsupported virtual adapter.) else (set mIsVirtualAdapterMsg=Try another OUI or restart the adapter.)

title ChMac v1.1 - Please send feedback to http://wandersick.blogspot.com
if "%mSuccessOrFailure%" EQU "Failure" (
	echo :: Error: MAC change failed. %mIsVirtualAdapterMsg%
	echo.
) else (
	echo :: Finished.
	echo.
)

if defined mCmd goto :end
set mNewMac=
call "%chmacdir%Data\_choiceYN.bat" ":: Run 'ipconfig /all' to verify new address? [Y,N] " N 60
if %errorlevel% EQU 0 (
	echo ___________________________________________________________________
	echo.
	@if defined noMore (
		type "%temp%\ipConfigAll.tmp"
	) else (
		more "%temp%\ipConfigAll.tmp"
	)
	echo.
	pause
)
if defined noDevcon (
	REM check again to ensure it has just been downloaded.
	devcon >nul 2>&1
	if "!errorlevel!"=="9009" (
		echo ___________________________________________________________________
		echo.
		call "%chmacdir%Data\_choiceYN.bat" ":: DevCon was not available. Download it? [Y,N] " N 60
		@if !errorlevel! EQU 0 (goto :Reminder)
	)
)
set mRerun=1
goto :ChMac
:end
endlocal&exit /b %mErrCode%

:error
echo.
echo #  %mErrType%
echo.
pause
goto :end

:AutoChangeInterval

set /a mAutoChangeTries+=1

echo :: Auto-change interval set. Waiting: %mAutoChangeInterval% ^(Try: %mAutoChangeTries%^)
echo.
echo :: To stop, press [CTRL+C] or close this.
"%chmacdir%Data\3rdparty\sleep.exe" %mAutoChangeInterval%
:: update old mac value for display at next summary
set mOldMac=%mNewMac%
goto :apply

:RandomizeFunction
set mOuiAlt=
:: don't randomize a new MAC address, keep current OUT part if OUI.txt doesn't exist in 'Data' folder
set mOuiVendor=Original
set mOui=%mOldMac:~0,6%
set mNic=%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%%random:~0,1%
set mNewRanMac=%mOui%%mNic%

:: randomize a new MAC address using OUI.txt
set mRandomSkipNum= skip=%random:~0,1%

:: if it is 0, it returns weird stuff, so the whole 'skip=0' must be removed or start from 1 or re-generate
:: it very rarely returns 0, for unknown reasons, hence the whole process would be very slow... for retrying and retrying... until it returns 0.
:: so 0 became VENDOR=OUI and not used instead. regenerate if 0.
if /i "%mRandomSkipNum%"==" skip=000" (
	goto :RandomizeFunction
) else if /i "%mRandomSkipNum%"==" skip=00" (
	goto :RandomizeFunction
) else if /i "%mRandomSkipNum%"==" skip=0" (
	goto :RandomizeFunction
)

if OSver GTR 5.2 (
	if exist "%chmacdir%Data\OUI_NT6.txt" (
		@for /f "delims== tokens=1,2 usebackq%mRandomSkipNum%" %%i in ("%chmacdir%Data\OUI_NT6.txt") do set mOuiVendor=%%i&set mOuiAlt=%%j&set mNewRanMac=!mOuiAlt!%mNic%&goto :exitRanOuiLoop
	)
)

if OSver LSS 6.0 (
	if exist "%chmacdir%Data\OUI_NT5.txt" (
		@for /f "delims== tokens=1,2 usebackq%mRandomSkipNum%" %%i in ("%chmacdir%Data\OUI_NT5.txt") do set mOuiVendor=%%i&set mOuiAlt=%%j&set mNewRanMac=!mOuiAlt!%mNic%&goto :exitRanOuiLoop
	)
)

:exitRanOuiLoop
:: check if the skip number points to a valid point in the file. if not, go back and re-generate
if "%mOuiAlt%"=="" goto :RandomizeFunction

:: prevent the randomized MAC address from being used twice in the same session
if exist "%temp%\exclMac.tmp" (
	for /f "usebackq tokens=* delims=" %%i in (`type "%temp%\exclMac.tmp"`) do @if /i "%mNewRanMac%" EQU "%%i" goto :RandomizeFunction
)

if /i "%mAutoChangeInterval%" NEQ "None" set mNewMac=%mNewRanMac%

if /i "%mAutoChangeInterval%" NEQ "None" (
	set mRandomizedMsg=Yes ^(auto-changing^)
) else (
	REM if MAC is not manually inputted but randomly generated
	@if "%mMacInputted%" NEQ "1" (
		set mRandomizedMsg=Yes
	)
)
goto :EOF

:: ======================================================== HELP DOC

:ChineseHelpNotice

if /i "%lang%" EQU "cht" (
	goto :HelpCHT
) else if /i "%lang%" EQU "chs" (
	goto :HelpCHS
) else (
	goto :EOF
)

:HelpCHT
echo.
echo                  ( ¦p±ý¾\Åª¤¤¤å¤¶²Ð¡A½Ð¨ì³Ì³»Åã¥Üªººô­¶ )
echo.
goto :EOF

:HelpCHS
echo.
echo                  ( ÈçÓûÔÄ¶ÁÖÐÎÄ½éÉÜ£¬Çëµ½×î¶¥ÏÔÊ¾µÄÍøÒ³ )
echo.

goto :EOF

:help
echo.
echo                               [ ChMac v%ChMacVersion% ]
echo.
echo             http://wandersick.blogspot.com ^| wandersick@gmail.com
echo.
if defined mShortHelp goto :helpSkip1
echo     [ What? ]
echo.
echo  #  ChMac is a portable command-line tool that changes MAC addresses of 
echo     specified network adapters. As a CLI tool, it can be used in misc ways
echo     such as using it with Schtasks for scheduling.
echo.
echo     [ Features ]
echo.
echo  #  Includes an interactive console.
echo.
echo  #  Automatically change MAC addresses on set intervals. This may be useful
echo     in some free public Wi-Fi Hotspot where trial connections get terminated
echo     every 20 minutes or so, until the MAC address is renewed.
echo.
echo  #  Uses DevCon.exe to automate the whole process. ChMac still works without
echo     it, but will show the Network Connections folder when finished, so that
echo     users can manually disable and re-enable the adapter for new settings to
echo     take effect. On 1st run users are asked to download DevCon to avoid that.
echo.
echo  #  New MAC addresses can be randomized from a list of 13476 OUIs.
echo.
echo  #  Multilingual interface. ^(See tip 5^)
echo.
echo  #  Free software. Written in poorly commented Batch. Any codes of anything
echo     by me are GPL-licensed. However the 3rdparty component DevCon.exe is not.
echo     You may freely adopt it to your free projects.
echo.
echo  #  Windows XP or later are fully supported. If you use this in Windows PE
echo     or 2000, you may place from a XP machine: msvcp60.dll, getmac.exe,
echo     reg.exe in "ChMac\Dict\conf\3rdparty\LP". Admins rights are required.
echo.
echo  #  The interactive console is easier to use. Just follow instructions on
echo     screen. For command line mode, see the following:
echo.
:helpSkip1
echo     [ Parameters ]
echo.
echo  #  ChMac [/d dir][/l][/m address][/n id][/r][/u][/help][/?]
echo.
echo     /d       dir  :: working directory -- maybe required
echo                      ^(MUST be specified before other parameters^)
echo     /l            :: list network adapters and their IDs
echo     /m            :: new mac address to be applied.
echo     /n            :: adapter to be applied new mac address
echo                      if /m is unspecified. New mac address will be
echo                      randomized ^(OUI kept^) and automatically filled.
echo     /r            :: restore to original MAC address
echo     /a            :: auto-change interval
echo     /u            :: check for program update ^(by default program checks
echo                      for update silently - can be turned off in conf^)
echo.
echo  #  The mac address format can be any of the following:
echo.
echo     AB-CD-EF-12-34-56
echo     AB:CD:EF:12:34:56
echo     AB.CD.EF.12.34.56
echo     AB CD EF 12 34 56 ... or without any separation in between at all.
echo.
echo  #  When no parameter is specified, interactive mode is entered.
echo.
echo     [ Examples ]
echo.
echo  #  . chmac /l                     :: list available adapter IDs
echo     . chmac /n 1                   :: update network adapter #1 with
echo                                       randomized mac address numbers.
echo     . chmac /m 00301812AB01 /n 2   :: update network adapter #2 with the
echo                                       new mac address: 00-30-18-12-AB-01
echo     . chmac /n 3 /r                :: restore adapter 3 to its original MAC
echo     . chmac /n 4 /a 20m            :: auto-change MAC per 20 minute
echo     . chmac /?                     :: shows short help. [/help] for long.
echo.
echo     [ Return codes ]
echo.
echo  #  ^(0^) Success  ^(1^) Failure  ^(3^) NIC error  ^(4^) Bad syntax  ^(5^) No exe
echo.
if defined mShortHelp (
	echo  #  For full documentation, try "chmac /help"
	set mShortHelp=
	set mHelp=
	call :ChineseHelpNotice
	goto :end
)
echo     [ Limitations ]
echo.
echo  #  1. While it may seem this program is multi-lingual, only English has been
echo        implemented for this version.
echo.
echo     2. Some virtual adapters are unsupported.
echo.
echo     [ Suggestion? ]
echo.
echo  #  Please drop me a line by email or the web site atop.
call :ChineseHelpNotice
set mHelp=
goto :end

:end9x	