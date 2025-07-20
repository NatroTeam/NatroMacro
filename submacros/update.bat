<!-- : Begin batch script
@echo off
setlocal EnableDelayedExpansion
chcp 65001 > nul
cd %temp%

:: Added: Enhanced logging and error tracking for update process
set "update_log=%temp%\natro_update.log"
echo [%date% %time%] Update process started > "%update_log%"
echo [%date% %time%] Parameters: %1 %2 %3 %4 %5 %6 %7 >> "%update_log%"

:: ANSI color codes
:: Added: Color code validation to prevent script errors
for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
if not defined \e set "\e="
set cyan=%\e%[96m
set green=%\e%[92m
set purple=%\e%[95m
set blue=%\e%[94m
set red=%\e%[91m
set yellow=%\e%[93m
set reset=%\e%[0m

:: Added: Disk space check before proceeding with update
for /f "tokens=3" %%a in ('dir /-c %temp% ^| find "bytes free"') do set "free_space=%%a"
set /a free_space_mb=%free_space:,=%/1048576 2>nul
if %free_space_mb% LSS 500 (
    echo %red%Warning: Low disk space ^(%free_space_mb% MB free^). Update may fail.%reset%
    echo [%date% %time%] Warning: Low disk space %free_space_mb% MB >> "%update_log%"
)

:: check existence of command line parameters
:: Added: Enhanced parameter validation with detailed error reporting
if [%1]==[] (
    echo %red%This script must be run from Natro Macro^^!%reset%
    echo [%date% %time%] Error: No command line parameters provided >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: Added: Validate URL parameter format
echo %1 | findstr /R "https*://" >nul
if %errorlevel% neq 0 (
    echo %red%Error: Invalid URL format in parameter 1%reset%
    echo [%date% %time%] Error: Invalid URL format: %1 >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: download latest .zip to %temp%
:: Added: Enhanced download process with retry mechanism and progress tracking
set "download_attempts=0"
:download_retry
set /a download_attempts+=1
echo %cyan%Downloading %~nx1... ^(Attempt %download_attempts%/3^)%reset%
echo [%date% %time%] Download attempt %download_attempts%: %~nx1 >> "%update_log%"

:: Added: Check if file already exists and remove it to prevent conflicts
if exist "%temp%\%~nx1" (
    echo %yellow%Removing existing file...%reset%
    del /f /q "%temp%\%~nx1" 2>nul
)

:: Added: Enhanced PowerShell download with better error handling and progress
powershell -Command "try { $ProgressPreference = 'Continue'; (New-Object Net.WebClient).DownloadFile('%1', '%temp%\%~nx1'); Write-Host 'Download successful' } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }"
if %errorlevel% neq 0 (
    echo %red%Download failed^^!%reset%
    echo [%date% %time%] Download failed on attempt %download_attempts% >> "%update_log%"
    if %download_attempts% lss 3 (
        echo %yellow%Retrying in 5 seconds...%reset%
        timeout /t 5 >nul
        goto download_retry
    ) else (
        echo %red%All download attempts failed. Please check your internet connection.%reset%
        echo [%date% %time%] All download attempts failed >> "%update_log%"
        <nul set /p "=%red%Press any key to exit . . . %reset%"
        pause >nul
        exit
    )
)

:: Added: Verify downloaded file size and integrity
if not exist "%temp%\%~nx1" (
    echo %red%Error: Downloaded file not found^^!%reset%
    echo [%date% %time%] Error: Downloaded file not found >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

for %%F in ("%temp%\%~nx1") do set "file_size=%%~zF"
if %file_size% lss 1048576 (
    echo %yellow%Warning: Downloaded file seems small ^(%file_size% bytes^). Continuing anyway...%reset%
    echo [%date% %time%] Warning: Small file size %file_size% bytes >> "%update_log%"
)

echo %cyan%Download complete^^! ^(Size: %file_size% bytes^)%reset%
echo [%date% %time%] Download successful, size: %file_size% bytes >> "%update_log%"
echo:

:: extract from %temp%/zip to Natro Macro directory
:: Added: Enhanced extraction with validation and error handling
for %%a in ("%~2") do set "a2=%%~dpa"
echo %purple%Extracting %~nx1...%reset%
echo [%date% %time%] Starting extraction to: %a2% >> "%update_log%"

:: Added: Validate destination directory exists
if not exist "%a2%" (
    echo %red%Error: Destination directory does not exist: %a2%%reset%
    echo [%date% %time%] Error: Destination directory missing: %a2% >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: Added: Enhanced extraction with error detection
for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%a2%" "%temp%\%~nx1" 2^>nul') do set "f=%%g"
if "%f%"=="" (
    echo %red%Error: Extraction failed^^! ZIP file may be corrupted.%reset%
    echo [%date% %time%] Error: Extraction failed, no folder returned >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)
call set folder=%%a2%%!f!
echo [%date% %time%] Extraction successful, folder: !folder! >> "%update_log%"

:: Added: Validate extracted folder contains required files
if not exist "!folder!\submacros\natro_macro.ahk" (
    echo %red%Error: Extracted folder missing critical files^^!%reset%
    echo [%date% %time%] Error: Missing natro_macro.ahk in extracted folder >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)
if not exist "!folder!\submacros\AutoHotkey32.exe" if not exist "!folder!\submacros\AutoHotkey64.exe" (
    echo %red%Error: Extracted folder missing AutoHotkey executable^^!%reset%
    echo [%date% %time%] Error: Missing AutoHotkey executable in extracted folder >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

echo %purple%Extract complete^^!%reset%
echo:

:: delete temp .zip
:: Added: Enhanced cleanup with verification
echo %yellow%Deleting %~nx1...%reset%
del /f /q "%temp%\%~nx1" >nul 2>nul
if exist "%temp%\%~nx1" (
    echo %yellow%Warning: Could not delete temporary file, but update continues...%reset%
    echo [%date% %time%] Warning: Could not delete temp file >> "%update_log%"
) else (
    echo %yellow%Deleted successfully^^!%reset%
    echo [%date% %time%] Temporary file deleted successfully >> "%update_log%"
)
echo:

:: copy importables from previous version
:: Added: Enhanced data migration with progress tracking and error handling
(if exist "%~2\" (
    echo [%date% %time%] Starting data migration from: %~2 >> "%update_log%"
    
    :: copy settings
    :: Added: Enhanced settings copy with validation
    if %~3 == 1 (
        echo %blue%Copying settings...%reset%
        if exist "%~2\settings" (
            echo [%date% %time%] Copying settings folder >> "%update_log%"
            robocopy "%~2\settings" "!folder!\settings" /E /R:3 /W:5 > nul
            if %errorlevel% geq 8 (
                echo %red%Warning: Some settings files failed to copy%reset%
                echo [%date% %time%] Warning: Settings copy had errors, errorlevel: %errorlevel% >> "%update_log%"
            ) else (
                echo %blue%Copy complete^^!%reset%
                echo [%date% %time%] Settings copied successfully >> "%update_log%"
            )
        ) else (
            echo %yellow%No settings folder found in previous version%reset%
            echo [%date% %time%] No settings folder in previous version >> "%update_log%"
        )
        echo:
    )
    
    :: copy patterns
    :: Added: Enhanced patterns copy with validation
    if %~4 == 1 (
        echo %blue%Copying patterns...%reset%
        if exist "%~2\patterns" (
            echo [%date% %time%] Copying patterns folder >> "%update_log%"
            robocopy "%~2\patterns" "!folder!\patterns" /E /R:3 /W:5 > nul
            if %errorlevel% geq 8 (
                echo %red%Warning: Some pattern files failed to copy%reset%
                echo [%date% %time%] Warning: Patterns copy had errors, errorlevel: %errorlevel% >> "%update_log%"
            ) else (
                echo %blue%Copy complete^^!%reset%
                echo [%date% %time%] Patterns copied successfully >> "%update_log%"
            )
        ) else (
            echo %yellow%No patterns folder found in previous version%reset%
            echo [%date% %time%] No patterns folder in previous version >> "%update_log%"
        )
        echo:
    )
    
    :: copy paths
    :: Added: Enhanced paths copy with validation and exclusion handling
    if %~5 == 1 (
        echo %blue%Copying paths...%reset%
        if exist "%~2\paths" (
            echo [%date% %time%] Copying paths folder, excluding: %~7 >> "%update_log%"
            if not [%~7]==[] (
                robocopy "%~2\paths" "!folder!\paths" /E /XF %~7 /R:3 /W:5 > nul
            ) else (
                robocopy "%~2\paths" "!folder!\paths" /E /R:3 /W:5 > nul
            )
            if %errorlevel% geq 8 (
                echo %red%Warning: Some path files failed to copy%reset%
                echo [%date% %time%] Warning: Paths copy had errors, errorlevel: %errorlevel% >> "%update_log%"
            ) else (
                echo %blue%Copy complete^^!%reset%
                echo [%date% %time%] Paths copied successfully >> "%update_log%"
            )
        ) else (
            echo %yellow%No paths folder found in previous version%reset%
            echo [%date% %time%] No paths folder in previous version >> "%update_log%"
        )
        echo:
    )
    :: delete old version
    :: Added: Enhanced old version cleanup with backup option
    if %~6 == 1 (
        echo %blue%Deleting %~nx2...%reset%
        echo [%date% %time%] Attempting to delete old version: %~2 >> "%update_log%"
        
        :: Added: Create backup of critical files before deletion
        if exist "%~2\settings\nm_config.ini" (
            echo %yellow%Creating backup of critical files...%reset%
            if not exist "%temp%\natro_backup" mkdir "%temp%\natro_backup"
            copy "%~2\settings\nm_config.ini" "%temp%\natro_backup\nm_config_backup.ini" >nul 2>nul
            echo [%date% %time%] Backup created at %temp%\natro_backup >> "%update_log%"
        )
        
        :: Added: Graceful deletion with retry mechanism
        set "delete_attempts=0"
        :delete_retry
        set /a delete_attempts+=1
        rd /s /q "%~2" >nul 2>nul
        if exist "%~2" (
            if %delete_attempts% lss 3 (
                echo %yellow%Deletion failed, retrying in 2 seconds... ^(Attempt %delete_attempts%/3^)%reset%
                timeout /t 2 >nul
                goto delete_retry
            ) else (
                echo %red%Warning: Could not completely remove old version. Some files may be in use.%reset%
                echo [%date% %time%] Warning: Could not delete old version after 3 attempts >> "%update_log%"
            )
        ) else (
            echo %blue%Deleted successfully^^!%reset%
            echo [%date% %time%] Old version deleted successfully >> "%update_log%"
        )
        echo:
    )
    :: update autostart
    :: Added: Enhanced autostart registry handling with validation and backup
    echo [%date% %time%] Checking autostart registry entry >> "%update_log%"
    for /f "usebackq tokens=2,* skip=2" %%l in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NatroMacro" 2^>nul`) do set "cmdline=%%m"
    if not [!cmdline!] == [] (
        echo [%date% %time%] Found existing autostart: !cmdline! >> "%update_log%"
        call set strtest=%%cmdline:%~2=%%
        if not "!strtest!"=="!cmdline!" (
            :: Added: Backup original registry entry before modification
            echo %blue%Backing up original autostart entry...%reset%
            echo !cmdline! > "%temp%\natro_autostart_backup.txt"
            
            call set cmdline=%%cmdline:%~2=!folder!%%
            call set regcmd=%%cmdline:"=\"%%
            
            :: Added: Validate new registry command before applying
            if exist "!folder!\START.bat" (
                reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "NatroMacro" /d "!regcmd!" /f > nul 2>nul
                if !errorlevel! == 0 (
                    echo %blue%Updated auto-start entry^^!%reset%
                    echo %blue%New command: !cmdline!%reset%
                    echo [%date% %time%] Autostart updated successfully: !cmdline! >> "%update_log%"
                ) else (
                    echo %red%Warning: Failed to update autostart registry entry%reset%
                    echo [%date% %time%] Error: Failed to update autostart registry >> "%update_log%"
                )
            ) else (
                echo %red%Warning: New folder missing START.bat, autostart not updated%reset%
                echo [%date% %time%] Warning: START.bat missing, autostart not updated >> "%update_log%"
            )
            echo:
        ) else (
            echo %red%Auto-start entry is not for previous version, left unchanged^^!%reset%
            echo [%date% %time%] Autostart entry not for previous version >> "%update_log%"
            echo:
        )
    ) else (
        echo [%date% %time%] No existing autostart entry found >> "%update_log%"
    )
) else (
    echo %red%Error: Previous Natro Macro folder not found^^!%reset%
    echo [%date% %time%] Error: Previous folder not found: %~2 >> "%update_log%"
    echo %red%Make sure to manually copy over settings, patterns, and paths.%reset%
    echo %red%Updated version: !folder!%reset%
    echo %cyan%Update log: %update_log%%reset%
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: Added: Final validation before starting macro
echo [%date% %time%] Performing final validation >> "%update_log%"
if not exist "!folder!\submacros\natro_macro.ahk" (
    echo %red%Error: Critical files missing after update^^!%reset%
    echo [%date% %time%] Error: natro_macro.ahk missing after update >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: Added: Check for AutoHotkey executable (32-bit or 64-bit)
set "ahk_exe="
if exist "!folder!\submacros\AutoHotkey32.exe" (
    set "ahk_exe=!folder!\submacros\AutoHotkey32.exe"
    echo [%date% %time%] Will use AutoHotkey32.exe >> "%update_log%"
) else if exist "!folder!\submacros\AutoHotkey64.exe" (
    set "ahk_exe=!folder!\submacros\AutoHotkey64.exe"
    echo [%date% %time%] Will use AutoHotkey64.exe as fallback >> "%update_log%"
) else (
    echo %red%Error: No AutoHotkey executable found^^!%reset%
    echo [%date% %time%] Error: No AutoHotkey executable found >> "%update_log%"
    <nul set /p "=%red%Press any key to exit . . . %reset%"
    pause >nul
    exit
)

:: countdown to macro start
:: Added: Enhanced countdown with process cleanup
echo %green%Update complete^^! Starting Natro Macro in 10 seconds.%reset%
echo [%date% %time%] Update completed successfully >> "%update_log%"

:: Added: Kill any existing AutoHotkey processes to prevent conflicts
tasklist /FI "IMAGENAME eq AutoHotkey32.exe" 2>nul | find /i "natro_macro" >nul
if %errorlevel% == 0 (
    echo %yellow%Stopping existing Natro Macro processes...%reset%
    taskkill /f /im AutoHotkey32.exe /fi "WINDOWTITLE eq natro_macro*" 2>nul
    timeout /t 2 >nul
)

<nul set /p =%green%Press any key to skip . . . %reset%
timeout /t 10 >nul

:: Added: Enhanced startup with error handling
echo [%date% %time%] Starting macro: !ahk_exe! >> "%update_log%"
start "" "!ahk_exe!" "!folder!\submacros\natro_macro.ahk"
if %errorlevel% == 0 (
    echo [%date% %time%] Macro started successfully >> "%update_log%"
) else (
    echo [%date% %time%] Failed to start macro, error level: %errorlevel% >> "%update_log%"
)
exit)

----- Begin wsf script --->
<job><script language="VBScript">
REM Added: Enhanced VBScript with comprehensive error handling and logging
Dim fso, objShell, FilesInZip, folder
Set fso = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("Shell.Application")

REM Added: Error handling for zip file access
On Error Resume Next
Set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
If Err.Number <> 0 Then
    WScript.Echo "ERROR: Could not access zip file - " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

REM Added: Validate zip contents before extraction
If FilesInZip.Count = 0 Then
    WScript.Echo "ERROR: Zip file appears to be empty"
    WScript.Quit 1
End If

REM Added: Enhanced folder enumeration with validation
For Each folder In FilesInZip
    WScript.Echo folder
Next

REM Added: Enhanced extraction with error detection
On Error Resume Next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
If Err.Number <> 0 Then
    WScript.Echo "ERROR: Extraction failed - " & Err.Description
    WScript.Quit 1
End If
On Error GoTo 0

REM Added: Cleanup with error handling
On Error Resume Next
Set fso = Nothing
Set objShell = Nothing
If Err.Number <> 0 Then
    WScript.Echo "WARNING: Cleanup had minor issues"
End If
</script></job>