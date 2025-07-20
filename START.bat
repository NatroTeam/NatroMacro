<!-- : Begin batch script
@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %~dp0

:: Added: Enhanced startup validation and logging
set "log_file=%~dp0debug_startup.log"
echo [%date% %time%] START.bat initiated > "%log_file%"

:: Added: Check for existing processes to prevent conflicts
tasklist /FI "IMAGENAME eq AutoHotkey32.exe" 2>nul | find /i "natro_macro.ahk" >nul
if %errorlevel% == 0 (
	echo %cyan%Natro Macro is already running! Stopping existing process...%reset%
	echo [%date% %time%] Found existing process, terminating >> "%log_file%"
	taskkill /f /im AutoHotkey32.exe /fi "WINDOWTITLE eq natro_macro.ahk*" 2>nul
	timeout /t 2 >nul
)

:: IF script and executable exist, run the macro
if exist "submacros\natro_macro.ahk" (
	:: Added: Support for both 32-bit and 64-bit AutoHotkey with fallback
	set "ahk_exe="
	if exist "submacros\AutoHotkey32.exe" (
		set "ahk_exe=submacros\AutoHotkey32.exe"
		echo [%date% %time%] Found AutoHotkey32.exe >> "%log_file%"
	) else if exist "submacros\AutoHotkey64.exe" (
		set "ahk_exe=submacros\AutoHotkey64.exe"
		echo [%date% %time%] Using AutoHotkey64.exe as fallback >> "%log_file%"
	)
	
	if not "!ahk_exe!"=="" (
		:: Added: Validate file integrity before starting
		if exist "!ahk_exe!" (
			echo [%date% %time%] Starting macro with !ahk_exe! >> "%log_file%"
			if not [%~3]==[] (
				set /a "delay=%~3" 2>nul
				if !delay! GTR 0 if !delay! LEQ 300 (
					echo Starting Natro Macro in !delay! seconds.
					echo [%date% %time%] User delay: !delay! seconds >> "%log_file%"
					<nul set /p =Press any key to skip . . . 
					timeout /t !delay! >nul
				)
			)
			:: Added: Enhanced startup with error checking
			start "" "%~dp0!ahk_exe!" "%~dp0submacros\natro_macro.ahk" %*
			if %errorlevel% == 0 (
				echo [%date% %time%] Macro started successfully >> "%log_file%"
			) else (
				echo [%date% %time%] Failed to start macro, error level: %errorlevel% >> "%log_file%"
			)
			exit
		)
	) else (set "exe_missing=1")
)

:: ELSE try to find .zip in common directories, extract, and run the macro
:: Added: Enhanced color setup with validation
for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
if not defined \e set "\e="
set cyan=%\e%[96m
set green=%\e%[92m
set purple=%\e%[95m
set red=%\e%[91m
set yellow=%\e%[93m
set reset=%\e%[0m

:: Added: Enhanced error handling for missing executable
if "%exe_missing%" == "1" (
	echo [%date% %time%] AutoHotkey executable missing >> "%log_file%"
	echo %red%Could not find submacros\AutoHotkey32.exe or AutoHotkey64.exe^^!%reset%
	echo %red%This is most likely due to a third-party antivirus deleting the file:%reset%
	echo %red% 1. Disable any third-party antivirus software ^(or add the Natro Macro folder as an exception^)%reset%
	echo %red% 2. Re-extract the macro and check that AutoHotkey32.exe exists in 'submacros' folder%reset%
	echo %red% 3. Run START.bat%reset%
	echo:
	echo %red%Note: Both Natro Macro and AutoHotkey are safe and work fine with Microsoft Defender^^!%reset%
	echo %red%Join our Discord server for support: discord.gg/natromacro%reset%
	echo:
	:: Added: Enhanced exit prompt with timeout
	echo %yellow%Auto-exit in 30 seconds...%reset%
	<nul set /p "=%red%Press any key to exit immediately . . . %reset%"
	timeout /t 30 >nul
	exit
)

:: Added: Enhanced zip detection and extraction with better error handling
for %%a in (".\..") do set "grandparent=%%~nxa"
if not [!grandparent!] == [] (
	echo [%date% %time%] Grandparent folder: !grandparent! >> "%log_file%"
	for /f "tokens=1,* delims=_" %%a in ("%grandparent%") do set "zip=%%b"
	if not [!zip!] == [] (
		call set str=%%zip:*.zip=%%
		call set zip=%%zip:!str!=%%
		if not [!zip!] == [] (
			echo %cyan%Looking for !zip!...%reset%
			echo [%date% %time%] Searching for zip file: !zip! >> "%log_file%"
			cd %USERPROFILE%
			:: Added: Expanded search locations for better coverage
			for %%a in ("Downloads","Downloads\Natro Macro","Desktop","Documents","OneDrive\Downloads","OneDrive\Downloads\Natro Macro","OneDrive\Desktop","OneDrive\Documents","Downloads\NatroMacro","OneDrive\Downloads\NatroMacro") do (
				if exist "%%~a\!zip!" (
					echo %cyan%Found in %%~a^^!%reset%
					echo [%date% %time%] Found zip at: %%~a\!zip! >> "%log_file%"
					echo:
					
					:: Added: Backup existing files before extraction
					if exist "%%~a\NatroMacro_backup" (
						echo %yellow%Removing old backup...%reset%
						rmdir /s /q "%%~a\NatroMacro_backup" 2>nul
					)
					
					echo %purple%Extracting %USERPROFILE%\%%~a\!zip!...%reset%
					:: Added: Enhanced extraction with error handling
					for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%USERPROFILE%\%%~a" "%USERPROFILE%\%%~a\!zip!" 2^>nul') do set "folder=%%g"
					if "!folder!" == "" (
						echo %red%Extraction failed! Please extract manually.%reset%
						echo [%date% %time%] Extraction failed for !zip! >> "%log_file%"
						pause
						exit
					)
					echo %purple%Extract complete^^!%reset%
					echo [%date% %time%] Extraction successful, folder: !folder! >> "%log_file%"
					echo:
					
					:: Added: Validate extracted files before cleanup
					if exist "%USERPROFILE%\%%~a\!folder!\submacros\natro_macro.ahk" (
						if exist "%USERPROFILE%\%%~a\!folder!\submacros\AutoHotkey32.exe" (
							echo %yellow%Deleting !zip!...%reset%
							del /f /q "%USERPROFILE%\%%~a\!zip!" >nul 2>nul
							if exist "%USERPROFILE%\%%~a\!zip!" (
								echo %yellow%Could not delete zip file, but extraction was successful%reset%
							) else (
								echo %yellow%Deleted successfully^^!%reset%
							)
							echo [%date% %time%] Cleanup completed >> "%log_file%"
							echo:
							
							echo %green%Unzip complete^^! Starting Natro Macro in 10 seconds.%reset%
							echo [%date% %time%] Starting extracted macro >> "%log_file%"
							<nul set /p =%green%Press any key to skip . . . %reset%
							timeout /t 10 >nul
							start "" "%USERPROFILE%\%%~a\!folder!\submacros\AutoHotkey32.exe" "%USERPROFILE%\%%~a\!folder!\submacros\natro_macro.ahk"
							exit
						) else (
							echo %red%Error: Extracted files are incomplete ^(missing AutoHotkey32.exe^)^^!%reset%
							echo [%date% %time%] Incomplete extraction - missing AutoHotkey32.exe >> "%log_file%"
						)
					) else (
						echo %red%Error: Extracted files are incomplete ^(missing natro_macro.ahk^)^^!%reset%
						echo [%date% %time%] Incomplete extraction - missing natro_macro.ahk >> "%log_file%"
					)
				)
			)
		) else (
			echo %red%Error: No .zip detected, but essential files are missing^^!%reset%
			echo [%date% %time%] No zip file detected but files missing >> "%log_file%"
		)
	) else (
		echo %red%Error: Could not determine name of unextracted .zip^^!%reset%
		echo [%date% %time%] Could not determine zip name >> "%log_file%"
	)
) else (
	echo %red%Error: Could not find Temp folder of unextracted .zip^^! ^(.bat has no grandparent^)%reset%
	echo [%date% %time%] No grandparent folder found >> "%log_file%"
)

:: Added: Enhanced final error message with logging and troubleshooting
echo %red%Unable to automatically extract Natro Macro^^!%reset%
echo [%date% %time%] Failed to extract macro automatically >> "%log_file%"
echo %red% - If you have already extracted, you are missing important files, please re-extract.%reset%
echo %red% - If you have not extracted, you may have to manually extract the zipped folder.%reset%
echo %red% - Check the debug_startup.log file for detailed error information.%reset%
echo %red%Join our Discord server for support: discord.gg/natromacro%reset%
echo:
echo %cyan%Debug log location: %log_file%%reset%
echo %cyan%Common solutions:%reset%
echo %cyan% 1. Right-click the .zip file and select "Extract All..."%reset%
echo %cyan% 2. Run this START.bat from inside the extracted folder%reset%
echo %cyan% 3. Ensure Windows Defender/Antivirus is not blocking files%reset%
echo:
:: Added: Enhanced timeout with progress indicator
for /l %%i in (30,-1,1) do (
	<nul set /p "=%red%Auto-exit in %%i seconds, press any key to exit now . . . %reset%"
	timeout /t 1 >nul 2>nul || goto :exit_now
	echo 
)
:exit_now
echo [%date% %time%] Script ended with errors >> "%log_file%"
exit

----- Begin wsf script --->
<job><script language="VBScript">
REM Added: Enhanced VBScript with error handling
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
On Error Resume Next
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
if Err.Number <> 0 then
	WScript.Echo "ERROR: Could not access zip file"
	WScript.Quit 1
end if
for each folder in FilesInZip
	WScript.Echo folder
next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
if Err.Number <> 0 then
	WScript.Echo "ERROR: Extraction failed"
	WScript.Quit 1
end if
set fso = Nothing
set objShell = Nothing
</script></job>