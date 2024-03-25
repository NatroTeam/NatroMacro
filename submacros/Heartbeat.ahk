/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#NoTrayIcon
#SingleInstance Force
#MaxThreads 255

#Include "%A_ScriptDir%\..\lib\nowUnix.ahk"

SetWorkingDir A_ScriptDir
OnMessage(0x5552, nm_SetGlobalInt)
OnMessage(0x5556, nm_SetHeartbeat)

LastRobloxWindow := LastStatusHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
MacroState := 0
path := '"' A_AhkPath '" "' A_ScriptDir '\natro_macro.ahk"'

Loop
{
	time := nowUnix()
	DetectHiddenWindows 0
	if (WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") || WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
		LastRobloxWindow := time
	DetectHiddenWindows 1
	; request heartbeat
	if WinExist("natro_macro ahk_class AutoHotkey")
		PostMessage 0x5556
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage 0x5556
	if WinExist("background.ahk ahk_class AutoHotkey")
		PostMessage 0x5556
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
				ProcessClose WinGetPID()
			for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
				ProcessClose p.ProcessID

			ForceStart := (Prev_MacroState = 2)

			run path ' "' ForceStart '" "' A_ScriptHwnd '"'

			if (WinWait("Natro ahk_class AutoHotkeyGUI", , 300) != 0)
			{
				Sleep 2000
				Send_WM_COPYDATA("Error: " reason "`nSuccessfully restarted macro!", "natro_macro ahk_class AutoHotkey")
				Sleep 1000
				LastRobloxWindow := LastStatusHeartbeat := LastMainHeartbeat := LastBackgroundHeartbeat := nowUnix()
				break
			}
		}
	}
	else
	{
		switch MacroState
		{
			case 1:
			LastRobloxWindow += 5

			case 0:
			LastBackgroundHeartbeat += 5
			LastRobloxWindow += 5
		}
	}
	Sleep 5000
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam:=0)
{
    CopyDataStruct := Buffer(3*A_PtrSize)
    SizeInBytes := (StrLen(StringToSend) + 1) * 2
    NumPut("Ptr", SizeInBytes
		, "Ptr", StrPtr(StringToSend)
		, CopyDataStruct, A_PtrSize)

	try
		s := SendMessage(0x004A, wParam, CopyDataStruct,, TargetScriptTitle)
	catch
		return -1
	else
		return s
}

nm_SetHeartbeat(wParam, *)
{
	global
	Critical
	static arr := ["Main", "Background", "Status"]
	script := arr[wParam], Last%script%Heartbeat := nowUnix()
}

nm_SetGlobalInt(wParam, lParam, *)
{
	global
	Critical
	local var
	; enumeration
	static arr := Map(23, "MacroState")

	var := arr[wParam], %var% := lParam
	return 0
}
