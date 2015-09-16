@echo
for /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

cls
color 0f
set SCRIPT_VERSION=1.0.3
set SCRIPT_DATE=2015-09-16
title bloatwaredl v%SCRIPT_VERSION% (%SCRIPT_DATE%)

set REPO_URL=
set REPO_SCRIPT_DATE=0
set REPO_SCRIPT_VERSION=0

:: PREP: Update check
:: Use wget to fetch sha256sums.txt from the repo and parse through it. Extract latest version number and release date from last line (which is always the latest release)
wget.exe --no-check-certificate https://raw.githubusercontent.com/gslight/bloatwaredl/master/sha256sums.txt -O %TEMP%\sha256sums.txt 2>NUL
:: Assuming there was no error, go ahead and extract version number into REPO_SCRIPT_VERSION, and release date into REPO_SCRIPT_DATE
if /i %ERRORLEVEL%==0 (
	for /f "tokens=1,2,3 delims= " %%a in (%TEMP%\sha256sums.txt) do set WORKING=%%b
	for /f "tokens=4 delims=,()" %%a in (%TEMP%\sha256sums.txt) do set WORKING2=%%a
	)
if /i %ERRORLEVEL%==0 (
	set REPO_SCRIPT_VERSION=%WORKING:~1,6%
	set REPO_SCRIPT_DATE=%WORKING2%
	)


:: Notify if an update was found
SETLOCAL ENABLEDELAYEDEXPANSION
if /i %SCRIPT_VERSION% LSS %REPO_SCRIPT_VERSION% (
	set CHOICE=y
	color 8a
	cls
	echo.
	echo  ^^! A newer version of bloatwaredl is available on the official repo.
	echo.
	echo    Your version:   %SCRIPT_VERSION% ^(%SCRIPT_DATE%^)
	echo    Latest version: %REPO_SCRIPT_VERSION% ^(%REPO_SCRIPT_DATE%^)
	echo.
	set /p CHOICE= Auto-download latest version now? [Y/n]:
	if !CHOICE!==y (
		color 8B
		cls
		echo.
		echo %TIME%   Downloading new version to the %Temp%, please wait...
		echo.
		wget.exe --no-check-certificate "https://raw.githubusercontent.com/gslight/bloatwaredl/master/bloatwaredl%%20v%REPO_SCRIPT_VERSION%%%20(%REPO_SCRIPT_DATE%).bat" -O "%Temp%\bloatwaredl v%REPO_SCRIPT_VERSION% (%REPO_SCRIPT_DATE%).bat"
		echo.
		echo %TIME%   Download finished.
		echo.
		echo %TIME%   Verifying SHA256 pack integrity, please wait...
		echo.
		hashdeep.exe -s -e -b -v -a -k %TEMP%\sha256sums.txt "%Temp%\bloatwaredl*.bat" | find /i "Files matched: 1"
		if !ERRORLEVEL!==0 (
			echo %TIME%   SHA256 pack integrity verified. The new version is on your desktop.
			echo.
			popd
			pause
			echo. && ENDLOCAL DISABLEDELAYEDEXPANSION
		) else (
			color 0c
			echo %TIME% ^^! ERROR: Download FAILED the integrity check. Recommend manually
			echo                      downloading latest version.
			echo.
			pause
			REM Clean up after ourselves
			del /f /q %TEMP%\sha256sums.txt
			exit
		)
	)
	color 0f
)