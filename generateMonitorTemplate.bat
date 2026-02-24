@echo off

if exist "submacros\StatMonitor.ahk" (
	if exist "submacros\AutoHotkey32.exe" (
		if not [%~3]==[] (
			set /a "delay=%~3" 2>nul
			echo Starting Natro Macro in !delay! seconds.
			<nul set /p =Press any key to skip . . . 
			timeout /t !delay! >nul
		)
		start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\StatMonitor.ahk" %* "1.1.0-B3" "ForceTemplate" 
		exit
	) else (set "exe_missing=1")
)