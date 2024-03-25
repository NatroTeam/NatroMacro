<!-- : Begin batch script
@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %temp%

:: ANSI color codes
for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
set cyan=%\e%[96m
set green=%\e%[92m
set purple=%\e%[95m
set blue=%\e%[94m
set red=%\e%[91m
set yellow=%\e%[93m
set reset=%\e%[0m

:: check existence of command line parameters
if [%1]==[] (
    echo %red%This script must be run from Natro Macro^^!%reset%
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: download latest .zip to %temp%
echo %cyan%Downloading %~nx1...%reset%
powershell -Command ""(New-Object Net.WebClient).DownloadFile('%1', '%temp%\%~nx1')""
echo %cyan%Download complete^^!%reset%
echo:

:: extract from %temp%/zip to Natro Macro directory
for %%a in ("%~2") do set "a2=%%~dpa"
echo %purple%Extracting %~nx1...%reset%
for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%a2%" "%temp%\%~nx1"') do set "f=%%g"
call set folder=%%a2%%!f!
echo %purple%Extract complete^^!%reset%
echo:

:: delete temp .zip
echo %yellow%Deleting %~nx1...%reset%
del /f /q "%temp%\%~nx1" >nul
echo %yellow%Deleted successfully^^!%reset%
echo:

:: copy importables from previous version
(if exist "%~2\" (
    :: copy settings
    if %~3 == 1 (
        echo %blue%Copying settings...%reset%
        robocopy "%~2\settings" "!folder!\settings" /E > nul
        echo %blue%Copy complete^^!%reset%
        echo:
    )
    :: copy patterns
    if %~4 == 1 (
        echo %blue%Copying patterns...%reset%
        robocopy "%~2\patterns" "!folder!\patterns" /E > nul
        echo %blue%Copy complete^^!%reset%
        echo:
    )
    :: copy paths
    if %~5 == 1 (
        echo %blue%Copying paths...%reset%
        robocopy "%~2\paths" "!folder!\paths" /E /XF %~7 > nul
        echo %blue%Copy complete^^!%reset%
        echo:
    )
    :: delete old version
    if %~6 == 1 (
        echo %blue%Deleting %~nx2...%reset%
        rd /s /q "%~2" >nul
        echo %blue%Deleted successfully^^!%reset%
        echo:
    )
    :: update autostart
    for /f "usebackq tokens=2,* skip=2" %%l in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NatroMacro" 2^>nul`) do set "cmdline=%%m"
    if not [!cmdline!] == [] (
        call set strtest=%%cmdline:%~2=%%
        if not "!strtest!"=="!cmdline!" (
            call set cmdline=%%cmdline:%~2=!folder!%%
            call set regcmd=%%cmdline:"=\"%%
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NatroMacro" /d "!regcmd!" /f > nul
            echo %blue%Updated auto-start entry^^!%reset%
            echo %blue%New command: !cmdline!%reset%
            echo:
        ) else (
            echo %red%Auto-start entry is not for previous version, left unchanged^^!%reset%
            echo:
        )
    )
) else (
    echo %red%Error: Previous Natro Macro folder not found^^!%reset%
    echo %red%Make sure to manually copy over settings, patterns, and paths.%reset%
    echo %red%Updated version: !folder!%reset%
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: countdown to macro start
echo %green%Update complete^^! Starting Natro Macro in 10 seconds.%reset%
<nul set /p =%green%Press any key to skip . . . %reset%
timeout /t 10 >nul

start "" "!folder!\submacros\AutoHotkey32.exe" "!folder!\submacros\natro_macro.ahk"
exit)

----- Begin wsf script --->
<job><script language="VBScript">
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
for each folder in FilesInZip
	WScript.Echo folder
next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
set fso = nothing
set objShell = nothing
</script></job>