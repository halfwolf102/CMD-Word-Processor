@echo off
:-------------------------------------------------------------------------------
:Created by Halfwolf102 (Ezekiel Kovar) as a proof of concept
:-------------------------------------------------------------------------------
set version=0
set revision=2
set minor=0
Setlocal EnableDelayedExpansion
title Word Processor v%version%.%revision%

:fullreset
:Pre-Op Variables
set linenum=0
set linetot=0
:-----------------

:initial
set start=
set lastloc=initial
cls
echo Command Line Word Processor v%version%.%revision%
echo by Ezekiel "Zeek" Kovar
echo -------------------------------------------------------------------------------
echo N - Create new file
echo L - Load existing file
echo V - Version Information
echo Q - Quit
set /p start=Select an option: 
if /i "%start%"=="n" goto new
if /i "%start%"=="l" goto load
if /i "%start%"=="v" goto version
if /i "%start%"=="q" exit
cls
echo ERROR^^! Invalid choice^^!
pause
goto initial

:load
set loadfile=
cls
echo Load file ^| enter B to go back
echo -------------------------------------------------------------------------------
echo (NOTE: File extensions are currently limited to CMD, BAT, TXT, VBS, INF, JSON)
set /p loadfile=Enter FULL file path for file to load (with extension): 
if /i "%loadfile%"=="b" goto %lastloc%
for %%i in (%loadfile%) do set extension=%%~xi
if /i not "%extension%"==".cmd" (if /i not "%extension%"==".bat" (if /i not "%extension%"==".vbs" (if /i not "%extension%"==".txt" (if /i not "%extension%"==".inf" (if /i not "%extension%"==".json" (echo ERROR^^! Invalid file extension^^! & pause & goto load))))))
if not exist "%loadfile%" (cls & echo ERROR^^! File does not exist^^! & pause & goto load)
echo Loading...
echo -------------------------------------------------------------------------------
for /f "usebackq tokens=*" %%a in ("%loadfile%") do (
	set /a "linenum=!linenum!+1,linetot=!linetot!+1"
	set "line!linenum!=%%a"
)
set linenum=0
goto return

:version
cls
echo Version Information
echo -------------------------------------------------------------------------------
echo Full version info: v%version%.%revision%.%minor%
echo Version: %version%  Revision: %revision%  Patch: %minor%
echo:
if exist Changelog.txt (type Changelog.txt) else (echo Changelog missing^^! & echo Please Download Changelog.txt and place it in the current directory.)
pause
goto initial

:new
set extension=
cls
echo Create a file ^| Enter B to go back
echo -------------------------------------------------------------------------------
echo (NOTE: File extensions are currently limited to CMD, BAT, TXT, VBS, INF, JSON)
echo:
set /p extension=Enter file extension (with period): 
if /i "%extension%"=="B" goto initial
if /i not "%extension%"==".cmd" (if /i not "%extension%"==".bat" (if /i not "%extension%"==".vbs" (if /i not "%extension%"==".txt" (if /i not "%extension%"==".inf" (if /i not "%extension%"==".json" (echo ERROR^^! Invalid file extension^^! & pause & goto new))))))
cls

:bufferloop
set /a "commandbuffer=commandbuffer+225"
:set /a "pagetot=pagetot+1"
:set /a "curpage=curpage+1"
echo Enter -O to access options
echo Filetype: %extension%
:echo Page %curpage% / %pagetot%
echo -------------------------------------------------------------------------------

:normloop
set /a "linenum=linenum+1"
set /a "linetot=linetot+1"
set /p line%linenum%=Line %linenum%: 
if /i '!line%linenum%!'=='-O' goto options
if "%linenum%"=="%commandbuffer%" echo: & echo -- BUFFER LIMIT REACHED^^! -- & echo ALL PREVIOUS COMMANDS WILL BE CLEARED ON THE NEXT LINE& pause & goto bufferloop
goto normloop

:options
set line%linenum%=
set /a "linetot=linetot-1"

:optreturn
set linenum=0
set option=
set lastloc=optreturn
cls
echo Option Commands
echo -------------------------------------------------------------------------------
echo E [Line Number] - Edit line number
echo R - Return to current progress
echo S - Save current work
echo D - Display current progress
echo Q - Quit to main menu
echo X - Exit without saving
set /p option=Select an option: 
for /f "tokens=1" %%a in ("%option%") do (
	if /i "%%a"=="E" goto editor
	if /i "%%a"=="R" goto returnbuffer
	if /i "%%a"=="s" goto save
	if /i "%%a"=="D" goto display
	if /i "%%a"=="Q" goto exitconfirm
	if /i "%%a"=="X" goto exitconfirm
	cls
	echo Error^^! Invalid choice^^!
	pause
	goto optreturn
)

:editor
cls
for /f "tokens=2" %%a in ("%option%") do set editline=%%a
if not defined line%editline% (echo Error^^! Line does not exist^^! & pause & goto optreturn)
echo Editing Line %editline%
echo -------------------------------------------------------------------------------
echo OLD Line %editline%: !line%editline%!
set /p line%editline%=NEW Line %editline%: 
set editline=
goto return

:returnbuffer
set /a "commandbuffer=commandbuffer+225"

:return
set linenum=0
cls
set /a "curpage=curpage+1"
echo Enter -O to access options
echo Filetype: %extension%
:echo Page %curpage% / %pagetot%
echo -------------------------------------------------------------------------------

:returnloop
if "%linetot%"=="0" goto normloop
set /a "linenum=linenum+1"
echo Line %linenum%: !line%linenum%!
if "%linenum%"=="%commandbuffer%" echo: & echo -- BUFFER LIMIT REACHED^^! -- & echo ALL PREVIOUS COMMANDS WILL BE CLEARED ON THE NEXT LINE& pause & goto returnbuffer
if not "%linenum%"=="%linetot%" goto returnloop
goto normloop

:save
cls
echo Save Options
echo -------------------------------------------------------------------------------
echo C - Save and continue
echo Q - Save and exit
echo O - Return to options
echo R - Return to editing
set /p saveop=Select an option: 
if /i "%saveop%"=="o" goto optreturn
if /i "%saveop%"=="o" goto return
if /i "%saveop%"=="C" goto savecont
if /i "%saveop%"=="q" goto savecont
cls
echo Error^^! Invalid choice^^!
goto save

:savecont
set linenum=0
cls
echo -------------------------------------------------------------------------------
set /p savefile=Enter file name (without extension): 
set /p savedir=Enter save path (Default: Current Directory): 
if not defined savedir set savedir=%cd%
if not defined savefile (cls & echo Error^^! File name cannot be blank^^! & pause & goto savecont)
if exist "%savedir%\%savefile%%extension%" set /p owconfirm=WARNING^^! This file aleready exists. Overwrite (Y/N)?: 
if defined owconfirm (
	if /i "%owconfirm%"=="n" (
		set owconfirm=
		goto savecont
	)
	if /i "%owconfirm%"=="y" (
	del /q "%savedir%\%savefile%%extension%"
	)
	if /i not "%owconfirm%"=="y" (
		set owconfirm=
		echo ERROR^^! Invalid choice^^!
		pause
		goto savecont
	
	)
)
cls
echo Saving file to %savedir%\%savefile%%extension%
echo -------------------------------------------------------------------------------

:saveloop
set /a "linenum=linenum+1"
echo Line %linenum% / %linetot% Lines
if defined line%linenum% (
	if "!line%linenum%!"==" " (
		echo: >> "%savedir%\%savefile%%extension%"
	) else (
		echo !line%linenum%! >> "%savedir%\%savefile%%extension%"
	)
)else (
	echo: >> "%savedir%\%savefile%%extension%"
)
if not "%linenum%"=="%linetot%" goto saveloop
echo -- DONE^^! --
pause
set linenum=0
if /i "%saveop%"=="c" goto return
exit

:display
set linenum=0
cls
set linegroup=50
echo Displaying progress (Press enter to show next 50 lines)
echo -------------------------------------------------------------------------------

:displayloop
set /a "linenum=linenum+1"
echo Line %linenum%: !line%linenum%!
if "%linenum%"=="%linegroup%" set /a "linegroup=linegroup+50" & pause > nul
if not "%linenum%"=="%linetot%" goto displayloop
echo:
echo -- END OF CURRENT PROGRESS^^! --
pause
goto optreturn

:exitconfirm
set confirm=
cls
echo Unsaved progress will be lost on exiting^^!
if /i "%option%"=="Q" set /p confirm=Are you sure you want to quit (Y/N): 
if /i "%option%"=="X" set /p confirm=Are you sure you want to exit (Y/N): 
if /i "%confirm%"=="y" (if /i "%option%"=="Q" (goto fullreset) else (exit))
if /i "%confirm%"=="n" goto optreturn
cls
echo ERROR^^! Invalid choice^^!
goto exitconfirm