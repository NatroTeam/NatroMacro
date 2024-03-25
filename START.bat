<!-- : Begin batch script
@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %~dp0

:: IF script and executable exist, run the macro
if exist "submacros\natro_macro.ahk" (
	if exist "submacros\AutoHotkey32.exe" (
		if not [%~3]==[] (
			set /a "delay=%~3" 2>nul
			echo Starting Natro Macro in !delay! seconds.
			<nul set /p =Press any key to skip . . . 
			timeout /t !delay! >nul
		)
		start "" "%~dp0submacros\AutoHotkey32.exe" "%~dp0submacros\natro_macro.ahk" %*
		exit
	) else (set "exe_missing=1")
)

:: ELSE try to find .zip in common directories, extract, and run the macro
for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
set cyan=%\e%[96m
set green=%\e%[92m
set purple=%\e%[95m
set red=%\e%[91m
set yellow=%\e%[93m
set reset=%\e%[0m

if "%exe_missing%" == "1" (
	echo %red%Could not find submacros\AutoHotkey32.exe^^!%reset%
	echo %red%This is most likely due to a third-party antivirus deleting the file:%reset%
	echo %red% 1. Disable any third-party antivirus software ^(or add the Natro Macro folder as an exception^)%reset%
	echo %red% 2. Re-extract the macro and check that AutoHotkey32.exe exists in 'submacros' folder%reset%
	echo %red% 3. Run START.bat%reset%
	echo:
	echo %red%Note: Both Natro Macro and AutoHotkey are safe and work fine with Microsoft Defender^^!%reset%
	echo %red%Join our Discord server for support: discord.gg/natromacro%reset%
	echo:
	<nul set /p "=%red%Press any key to exit . . . %reset%"
	pause >nul
	exit
)

for %%a in (".\..") do set "grandparent=%%~nxa"
if not [!grandparent!] == [] (
	for /f "tokens=1,* delims=_" %%a in ("%grandparent%") do set "zip=%%b"
	if not [!zip!] == [] (
		call set str=%%zip:*.zip=%%
		call set zip=%%zip:!str!=%%
		if not [!zip!] == [] (
			echo %cyan%Looking for !zip!...%reset%
			cd %USERPROFILE%
			for %%a in ("Downloads","Downloads\Natro Macro","Desktop","Documents","OneDrive\Downloads","OneDrive\Downloads\Natro Macro","OneDrive\Desktop","OneDrive\Documents") do (
				if exist "%%~a\!zip!" (
					echo %cyan%Found in %%~a^^!%reset%
					echo:
					
					echo %purple%Extracting %USERPROFILE%\%%~a\!zip!...%reset%
					for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%USERPROFILE%\%%~a" "%USERPROFILE%\%%~a\!zip!"') do set "folder=%%g"
					echo %purple%Extract complete^^!%reset%
					echo:
					
					echo %yellow%Deleting !zip!...%reset%
					del /f /q "%USERPROFILE%\%%~a\!zip!" >nul
					echo %yellow%Deleted successfully^^!%reset%
					echo:
					
					echo %green%Unzip complete^^! Starting Natro Macro in 10 seconds.%reset%
					<nul set /p =%green%Press any key to skip . . . %reset%
					timeout /t 10 >nul
					start "" "%USERPROFILE%\%%~a\!folder!\submacros\AutoHotkey32.exe" "%USERPROFILE%\%%~a\!folder!\submacros\natro_macro.ahk"
					exit
				)
			)
		) else (echo %red%Error: No .zip detected, but essential files are missing^^!%reset%)
	) else (echo %red%Error: Could not determine name of unextracted .zip^^!%reset%)
) else (echo %red%Error: Could not find Temp folder of unextracted .zip^^! ^(.bat has no grandparent^)%reset%)

echo %red%Unable to automatically extract Natro Macro^^!%reset%
echo %red% - If you have already extracted, you are missing important files, please re-extract.%reset%
echo %red% - If you have not extracted, you may have to manually extract the zipped folder.%reset%
echo %red%Join our Discord server for support: discord.gg/natromacro%reset%
echo:
<nul set /p "=%red%Press any key to exit . . . %reset%"
pause >nul
exit

----- Begin wsf script --->
<job><script language="VBScript">
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
for each folder in FilesInZip
	WScript.Echo folder
next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
set fso = Nothing
set objShell = Nothing
</script></job>