/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © 2022-2023 Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#NoEnv
#NoTrayIcon
#SingleInstance Force
#MaxThreads 255

SetBatchLines -1
SetWorkingDir %A_ScriptDir%
OnMessage(0x5552, "nm_SetGlobalInt")
OnMessage(0x5556, "nm_SetHeartbeat")

LastRobloxWindow := LastStatusHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
MacroState := 0
SplitPath, A_AhkPath, exe
path := (exe = "natro_macro.exe") ? ("""" A_AhkPath """") :  ("""" A_AhkPath """ """ A_ScriptDir "\..\natro_macro.ahk" """")

Loop
{
	DetectHiddenWindows, Off
	SetTitleMatchMode, 1
	time := nowUnix()
	if (WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
		LastRobloxWindow := time
	; request heartbeat
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	if WinExist("natro_macro ahk_class AutoHotkey")
		PostMessage, 0x5556
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5556
	if WinExist("background.ahk ahk_class AutoHotkey")
		PostMessage, 0x5556
	; check for timeouts
	if (((MacroState = 2) && (((time - LastMainHeartbeat > 120) && (reason := "Macro Unresponsive Timeout!"))
		|| ((time - LastBackgroundHeartbeat > 120) && (reason := "Background Script Timeout!"))
		|| ((time - LastStatusHeartbeat > 120) && (reason := "Status Script Timeout!"))
		|| ((time - LastRobloxWindow > 600) && (reason := "No Roblox Window Timeout!"))))
		
		|| ((MacroState = 1) && (((time - LastMainHeartbeat > 120) && (reason := "Macro Unresponsive Timeout!"))
		|| ((time - LastBackgroundHeartbeat > 120) && (reason := "Background Script Timeout!"))
		|| ((time - LastStatusHeartbeat > 120) && (reason := "Status Script Timeout!"))))) {
		Prev_MacroState := MacroState, MacroState := 0
		Loop
		{
			while WinExist("natro_macro ahk_class AutoHotkey")
			{
				WinGet, natroPID, PID
				Process, Close, % natroPID
			}
			for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
				Process, Close, % p.ProcessID
			
			ForceStart := (Prev_MacroState = 2)
			
			run, %path% "%ForceStart%" "%A_ScriptHwnd%"
			WinWait, Natro ahk_class AutoHotkeyGUI, , 300
			if (success := !ErrorLevel)
			{
				Sleep, 2000
				Send_WM_COPYDATA("Error: " reason "`nSuccessfully restarted macro!", "natro_macro ahk_class AutoHotkey")
				Sleep, 1000
				LastRobloxWindow := LastStatusHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
				break
			}
		}
	}
	else
	{
		switch % MacroState
		{
			case 1:
			LastRobloxWindow += 5
			
			case 0:
			LastBackgroundHeartbeat += 5
			LastRobloxWindow += 5
		}
	}
	Sleep, 5000
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle, wParam:=0)
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
    SendMessage, 0x004A, wParam, &CopyDataStruct,, %TargetScriptTitle%
    return ErrorLevel
}

nm_SetHeartbeat(wParam)
{
	global
	Critical
	static arr := ["Main", "Background", "Status"]
	script := arr[wParam], Last%script%Heartbeat := nowUnix()
}

nm_SetGlobalInt(wParam, lParam)
{
	global
	Critical
	local var
	; enumeration
	static arr := {23: "MacroState"}
	
	var := arr[wParam], %var% := lParam
	return 0
}

nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}