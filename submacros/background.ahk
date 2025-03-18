/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#SingleInstance Force
#NoTrayIcon
#MaxThreads 255

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"

OnError (e, mode) => (mode = "Return") ? -1 : 0
SetWorkingDir A_ScriptDir "\.."

if (A_Args.Length = 0)
{
	msgbox "This script needs to be run by Natro Macro! You are not supposed to run it manually."
	ExitApp
}

;initialization
resetTime:=LastState:=LastConvertBalloon:=nowUnix()
VBState:=state:=0
MacroState:=2
NightLastDetected := A_Args[1]
VBLastKilled := A_Args[2]
StingerCheck := A_Args[3]
StingerDailyBonusCheck := A_Args[4]
AnnounceGuidingStar := A_Args[5]
ReconnectInterval := A_Args[6]
ReconnectHour := A_Args[7]
ReconnectMin := A_Args[8]
EmergencyBalloonPingCheck := A_Args[9]
ConvertBalloon := A_Args[10]
NightMemoryMatchCheck := A_Args[11]
LastNightMemoryMatch := A_Args[12]

pToken := Gdip_Startup()
bitmaps := Map(), bitmaps.CaseSense := 0
#Include "%A_ScriptDir%\..\nm_image_assets\offset\bitmaps.ahk"
#Include "%A_ScriptDir%\..\nm_image_assets\night\bitmaps.ahk"

CoordMode "Pixel", "Screen"
DetectHiddenWindows 1

;OnMessages
OnExit((*) => ProcessClose(DllCall("GetCurrentProcessId")))
OnMessage(0x5552, nm_setGlobalInt, 255)
OnMessage(0x5553, nm_setGlobalStr, 255)
OnMessage(0x5554, nm_setGlobalNum, 255)
OnMessage(0x5555, nm_setState, 255)
OnMessage(0x5556, nm_sendHeartbeat)

loop {
	hwnd := GetRobloxHWND(), GetRobloxClientPos(hwnd), offsetY := GetYOffset(hwnd)
	nm_deathCheck()
	nm_guidCheck()
	nm_popStarCheck()
	nm_dayOrNight()
	nm_backpackPercentFilter()
	nm_guidingStarDetect()
	nm_dailyReconnect()
	nm_EmergencyBalloon()
	sleep 1000
}

nm_setGlobalNum(wParam, lParam, *){
	Critical
	global resetTime, NightLastDetected, VBState, StingerCheck, VBLastKilled, LastConvertBalloon, NightMemoryMatchCheck, LastNightMemoryMatch
	static arr:=["resetTime", "NightLastDetected", "VBState", "StingerCheck", "VBLastKilled", "LastConvertBalloon", "NightMemoryMatchCheck", "LastNightMemoryMatch"]

	var := arr[wParam], %var% := lParam
	return 0
}

nm_setState(wParam, lParam, *){
	Critical
	global state, lastState
	state := wParam, LastState := lParam
	return 0
}

nm_deathCheck(){
	static LastDeathDetected:=0
	if (((nowUnix()-resetTime)>20) && ((nowUnix()-LastDeathDetected)>10)) {
		try
			result := ImageSearch(&FoundX, &FoundY, windowX+windowWidth//2, windowY+windowHeight//2, windowX+windowWidth, windowY+windowHeight, "*50 nm_image_assets\died.png")
		catch
			return
		if (result = 1) {
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 1, 1
				Send_WM_COPYDATA("You Died", "natro_macro ahk_class AutoHotkey")
			}
			LastDeathDetected := nowUnix()
		}
	}
}

nm_guidCheck(){
	global windowX, windowY, windowWidth, windowHeight, offsetY, state
	static LastFieldGuidDetected:=1, FieldGuidDetected:=0, confirm:=0
	try
		result := ImageSearch(&FoundX, &FoundY, windowX, windowY+offsetY+30, windowX+windowWidth, windowY+offsetY+90, "*50 nm_image_assets\boostguidingstar.png")
	catch
		return
	if (result = 1) { ;Guid Detected
		confirm:=0
		if ((FieldGuidDetected = 0) && (state = 1)) {
			FieldGuidDetected := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 6, 1
				Send_WM_COPYDATA("Detected: Guiding Star Active", "natro_macro ahk_class AutoHotkey")
			}
			LastFieldGuidDetected := nowUnix()
		}
	}
	else if ((nowUnix() - LastFieldGuidDetected > 5) && FieldGuidDetected){
		confirm++
		if (confirm >= 5) {
			confirm:=0
			FieldGuidDetected := 0
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 6, 0
			}
		}
	}
}

nm_popStarCheck(){
	static HasPopStar:=0, PopStarActive:=0
	try
		result := ImageSearch(&FoundX, &FoundY, windowX + windowWidth//2 - 275, windowY + 3*windowHeight//4, windowX + windowWidth//2 + 275, windowY + windowHeight, "*30 nm_image_assets\popstar_counter.png")
	catch
		return
	if (result = 1) { ;Has Pop
		if (HasPopStar = 0){
			HasPopStar := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 7, 1
			}
		}
		if (HasPopStar && (PopStarActive = 1)){
			PopStarActive := 0
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 8, 0
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage 0x5556, 1, 0
			}
		}
	} else {
		if (HasPopStar && (PopStarActive = 0) && (state = 1)){
			PopStarActive := 1
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 8, 1
				;Send_WM_COPYDATA("Detected: Pop Star Active", "natro_macro ahk_class AutoHotkey")
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage 0x5556, 1, 1
			}
		}
	}
}

nm_dayOrNight(){
	;VBState 0=no VB, 1=searching for VB, 2=VB found
	global NightLastDetected, StingerCheck, StingerDailyBonusCheck, VBLastKilled, VBState
	static confirm:=0
	if (StingerCheck=0 && NightMemoryMatchCheck=0)
		return
	if(((VBState=1) && ((nowUnix()-NightLastDetected)>400 || (nowUnix()-NightLastDetected)<0)) || ((VBState=2) && ((nowUnix()-VBLastKilled)>(600) || (nowUnix()-VBLastKilled)<0))) {
		VBState:=0
		if WinExist("natro_macro ahk_class AutoHotkey") {
			PostMessage 0x5555, 3, 0
		}
	}
	;return if pollen text is not visible (darkened background)
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
	if (Gdip_ImageSearch(pBMScreen, bitmaps["toppollen"], , , , , , 8) != 1) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	Gdip_DisposeImage(pBMScreen)

	try {
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 2*windowHeight//5 "|" windowWidth "|" 3*windowHeight//5)
		for k, v in bitmaps["day"] {
			if (Gdip_ImageSearch(pBMScreen, v, , , , , , 6) = 1) {
				result := 1
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		Gdip_DisposeImage(pBMScreen)
	} catch
		return
	if result {
		dayOrNight:="Day"
	} else {
		try {
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + windowHeight//2 "|" windowWidth "|" windowHeight//2)
			for k, v in bitmaps["night"] {
				if (Gdip_ImageSearch(pBMScreen, v, , , , , , 4) = 1)
				{
					result := 1
					Gdip_DisposeImage(pBMScreen)
					break
				}
			}		
			Gdip_DisposeImage(pBMScreen)
		} catch
			return
		if result  {
			dayOrNight:="Dusk"
		} else {
			dayOrNight:="Day"
		}
	}
	if (dayOrNight="Dusk" || dayOrNight="Night") {
		confirm:=confirm+1
	} else if (dayOrNight="Day") {
		confirm:=0
	}
	if(confirm>=5) {
		dayOrNight:="Night"
		if((nowUnix()-NightLastDetected)>300 || (nowUnix()-NightLastDetected)<0) {
			NightLastDetected:=nowUnix()
			try IniWrite NightLastDetected, "settings\nm_config.ini", "Collect", "NightLastDetected"
			if WinExist("natro_macro ahk_class AutoHotkey") {
				PostMessage 0x5555, 2, NightLastDetected
				Send_WM_COPYDATA("Detected: Night", "natro_macro ahk_class AutoHotkey")
			}
			if(((StingerCheck=1) && ((StingerDailyBonusCheck=0) || (nowUnix()-VBLastKilled)>79200) && VBState=0) || ((NightMemoryMatchCheck=1) && (nowUnix()-LastNightMemoryMatch)>28800)) {
				VBState:=1 ;0=no VB, 1=searching for VB, 2=VB found
				if WinExist("natro_macro ahk_class AutoHotkey") {
					PostMessage 0x5555, 3, 1
				}
			}
		}
	}
	;GuiControl,Text, timeOfDay, %dayOrNight%
	if(winexist("PlanterTimers.ahk ahk_class AutoHotkey")) {
		try IniWrite dayOrNight, "settings\nm_config.ini", "Planters", "DayOrNight" ;make this a PostMessage too, fewer disk reads/writes is better!
	}
}

nm_backpackPercent(){
	static LastBackpackPercent:=""
	;WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	;UpperLeft X1 = windowWidth/2+59
	;UpperLeft Y1 = 3
	;LowerRight X2 = windowWidth/2+59+220
	;LowerRight Y2 = 3+5
	;Bar = 220 pixels wide = 11 pixels per 5%
	backpackColor := PixelGetColor(windowX+windowWidth//2+59+3, windowY+offsetY+6)
	BackpackPercent:=0

	if((backpackColor & 0xFF0000 <= 0x690000)) { ;less or equal to 50%
		if(backpackColor & 0xFF0000 <= 0x4B0000) { ;less or equal to 25%
			if(backpackColor & 0xFF0000 <= 0x420000) { ;less or equal to 10%
				if((backpackColor & 0xFF0000 <= 0x410000) && (backpackColor & 0x00FFFF <= 0x00FF80) && (backpackColor & 0x00FFFF > 0x00FF86)) { ;less or equal to 5%
					BackpackPercent:=0
				} else if((backpackColor & 0xFF0000 > 0x410000) && (backpackColor & 0x00FFFF <= 0x00FF80) && (backpackColor & 0x00FFFF > 0x00FC85)) { ;greater than 5%
					BackpackPercent:=5
				} else {
					BackpackPercent:=0
				}
			} else { ;greater than 10%
				if((backpackColor & 0xFF0000 <= 0x470000)) { ;less or equal to 20%
					if((backpackColor & 0xFF0000 <= 0x440000) && (backpackColor & 0x00FFFF <= 0x00FE85) && (backpackColor & 0x00FFFF > 0x00F984)) { ;less or equal to 15%
						BackpackPercent:=10
					} else if((backpackColor & 0xFF0000 > 0x440000) && (backpackColor & 0x00FFFF <= 0x00FB84) && (backpackColor & 0x00FFFF > 0x00F582)) { ;greater than 15%
						BackpackPercent:=15
					} else {
						BackpackPercent:=0
					}
				} else if((backpackColor & 0xFF0000 > 0x470000) && (backpackColor & 0x00FFFF <= 0x00F782) && (backpackColor & 0x00FFFF > 0x00F080)) { ;greater than 20%
					BackpackPercent:=20
				} else {
					BackpackPercent:=0
				}
			}
		} else { ;greater than 25%
			if(backpackColor & 0xFF0000 <= 0x5B0000) { ;less or equal to 40%
				if((backpackColor & 0xFF0000 <= 0x4F0000) && (backpackColor & 0x00FFFF <= 0x00F280) && (backpackColor & 0x00FFFF > 0x00EA7D)) { ;less or equal to 30%
					BackpackPercent:=25
				} else { ;greater than 30%
					if((backpackColor & 0xFF0000 <= 0x550000) && (backpackColor & 0x00FFFF <= 0x00EC7D) && (backpackColor & 0x00FFFF > 0x00E37A)) { ;less or equal to 35%
						BackpackPercent:=30
					} else if((backpackColor & 0xFF0000 > 0x550000) && (backpackColor & 0x00FFFF <= 0x00E57A) && (backpackColor & 0x00FFFF > 0x00DA76)) { ;greater than 35%
						BackpackPercent:=35
					} else {
						BackpackPercent:=0
					}
				}
			} else { ;greater than 40%
				if((backpackColor & 0xFF0000 <= 0x620000) && (backpackColor & 0x00FFFF <= 0x00DC76) && (backpackColor & 0x00FFFF > 0x00D072)) { ;less or equal to 45%
					BackpackPercent:=40
				} else if((backpackColor & 0xFF0000 > 0x620000) && (backpackColor & 0x00FFFF <= 0x00D272) && (backpackColor & 0x00FFFF > 0x00C66D)) { ;greater than 45%
					BackpackPercent:=45
				} else {
					BackpackPercent:=0
				}
			}
		}
	} else { ;greater than 50%
		if(backpackColor & 0xFF0000 <= 0x9C0000) { ;less or equal to 75%
			if(backpackColor & 0xFF0000 <= 0x850000) { ;less or equal to 65%
				if(backpackColor & 0xFF0000 <= 0x7B0000) { ;less or equal to 60%
					if((backpackColor & 0xFF0000 <= 0x720000) && (backpackColor & 0x00FFFF <= 0x00C86D) && (backpackColor & 0x00FFFF > 0x00BA68)) { ;less or equal to 55%
						BackpackPercent:=50
					} else if((backpackColor & 0xFF0000 > 0x720000) && (backpackColor & 0x00FFFF <= 0x00BC68) && (backpackColor & 0x00FFFF > 0x00AD62)) { ;greater than 55%
						BackpackPercent:=55
					} else {
						BackpackPercent:=0
					}
				} else if((backpackColor & 0xFF0000 > 0x7B0000) && (backpackColor & 0x00FFFF <= 0x00AF62) && (backpackColor & 0x00FFFF > 0x009E5C)) { ;greater than 60%
					BackpackPercent:=60
				} else {
					BackpackPercent:=0
				}
			} else { ;greater than 65%
				if((backpackColor & 0xFF0000 <= 0x900000) && (backpackColor & 0x00FFFF <= 0x00A05C) && (backpackColor & 0x00FFFF > 0x008F55)) { ;less or equal to 70%
					BackpackPercent:=65
				} else if((backpackColor & 0xFF0000 > 0x900000) && (backpackColor & 0x00FFFF <= 0x009155) && (backpackColor & 0x00FFFF > 0x007E4E)) { ;greater than 70%
					BackpackPercent:=70
				} else {
					BackpackPercent:=0
				}
			}
		} else { ;greater than 75%
			if((backpackColor & 0xFF0000 <= 0xC40000)) { ;less or equal to 90%
				if((backpackColor & 0xFF0000 <= 0xA90000) && (backpackColor & 0x00FFFF <= 0x00804E) && (backpackColor & 0x00FFFF > 0x006C46)) { ;less or equal to 80%
					BackpackPercent:=75
				} else { ;greater than 80%
					if((backpackColor & 0xFF0000 <= 0xB60000) && (backpackColor & 0x00FFFF <= 0x006E46) && (backpackColor & 0x00FFFF > 0x005A3F)) { ;less or equal to 85%
						BackpackPercent:=80
					} else if((backpackColor & 0xFF0000 > 0xB60000) && (backpackColor & 0x00FFFF <= 0x005D3F) && (backpackColor & 0x00FFFF > 0x004637)){ ;greater than 85%
						BackpackPercent:=85
					} else {
						BackpackPercent:=0
					}
				}
			} else { ;greater than 90%
				if((backpackColor & 0xFF0000 <= 0xD30000) && (backpackColor & 0x00FFFF <= 0x004A37) && (backpackColor & 0x00FFFF > 0x00322E)) { ;less or equal to 95%
					BackpackPercent:=90
				} else { ;greater than 95%
					if((backpackColor = 0xF70017) || ((backpackColor & 0xFF0000 >= 0xE00000) && (backpackColor & 0x00FFFF <= 0x002427) && (backpackColor & 0x00FFFF > 0x001000))) { ;is equal to 100%
						BackpackPercent:=100
					} else if((backpackColor & 0x00FFFF <= 0x00342E)){
						BackpackPercent:=95
					} else {
						BackpackPercent:=0
					}
				}
			}
		}
	}
	if ((BackpackPercent != LastBackpackPercent) && WinExist("natro_macro ahk_class AutoHotkey")) {
		PostMessage 0x5555, 4, BackpackPercent
		LastBackpackPercent := BackpackPercent
	}
	Return BackpackPercent
}

nm_backpackPercentFilter(){
	static PackFilterArray:=[], LastBackpackPercentFiltered:="", i:=0, samplesize:=6 ;6 seconds (6 samples @ 1 sec intervals)

	;make room for new sample
	if(PackFilterArray.Length=samplesize){
		PackFilterArray.Pop()
	}
	;get new sample
	PackFilterArray.InsertAt(1, nm_backpackPercent())
	;calculate rolling average
	sum:=0
	for val in PackFilterArray {
		sum+=val
	}
	BackpackPercentFiltered:=Round(sum/PackFilterArray.Length)
	if ((i=0) && WinExist("StatMonitor.ahk ahk_class AutoHotkey")) {
		PostMessage 0x5557, BackpackPercentFiltered, 60 * A_Min + A_Sec
	}
	i:=Mod(i+1, 6)
	if (BackpackPercentFiltered != LastBackpackPercentFiltered) {
		if WinExist("natro_macro ahk_class AutoHotkey") {
			PostMessage 0x5555, 5, BackpackPercentFiltered
		}
		LastBackpackPercentFiltered := BackpackPercentFiltered
	}
}

nm_guidingStarDetect(){
	static LastGuidDetected:=0, fieldnames := ["PineTree", "Stump", "Bamboo", "BlueFlower", "MountainTop", "Cactus", "Coconut", "Pineapple", "Spider", "Pumpkin", "Dandelion", "Sunflower", "Clover", "Pepper", "Rose", "Strawberry", "Mushroom"]

	if ((AnnounceGuidingStar=0) || (nowUnix()-LastGuidDetected<10))
		return

	xi:=windowX+windowWidth//2
	yi:=windowY+windowHeight//2
	ww:=windowX+windowWidth
	wh:=windowY+windowHeight

	GSfound:=0
	Loop 2 {
		try
			result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*50 nm_image_assets\guiding_star_icon" A_Index ".png")
		catch
			return
		if (result = 1) {
			GSfound:=1
			break
		}
	}

	if(GSfound){
		for value in fieldnames {
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*50 nm_image_assets\guiding_star_" value ".png")
			catch
				return
			if (result = 1) {
				if WinExist("natro_macro ahk_class AutoHotkey") {
					Send_WM_COPYDATA(value, "natro_macro ahk_class AutoHotkey", 1)
					LastGuidDetected := nowUnix()
					break
				}
			}
		}
	}
}

nm_dailyReconnect(){
	static LastDailyReconnect := 0
	if ((ReconnectHour = "") || (ReconnectMin = "") || (ReconnectInterval = "") || (nowUnix() - LastDailyReconnect < 60))
		return
	RChourUTC := Number(FormatTime(A_NowUTC, "HH"))
	RCminUTC := Number(FormatTime(A_NowUTC, "mm"))
	HourReady:=0
	Loop 24//ReconnectInterval
	{
		if (Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24)=RChourUTC)
		{
			HourReady:=1
			break
		}
	}
	if((Number(ReconnectMin)=RCminUTC) && HourReady && (MacroState = 2)) {
		LastDailyReconnect := nowUnix()
		if WinExist("natro_macro ahk_class AutoHotkey") {
			Send_WM_COPYDATA("Closing: Roblox, Daily Reconnect", "natro_macro ahk_class AutoHotkey")
			PostMessage 0x5557, 60
		}
	}
}

nm_EmergencyBalloon(){
	static LastEmergency:=0
	if ((EmergencyBalloonPingCheck = 1) && (ConvertBalloon != "Never") && (nowUnix() - LastEmergency > 60) && ((time := nowUnix() - LastConvertBalloon) > 2700) && (time < 3600))
	{
		if WinExist("natro_macro ahk_class AutoHotkey") {
			duration := DurationFromSeconds(time, "m'm' ss's'")
			Send_WM_COPYDATA("Detected: No Balloon Convert in " duration, "natro_macro ahk_class AutoHotkey")
			LastEmergency := nowUnix()
		}
	}
}

nm_sendHeartbeat(*){
	Critical
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
		PostMessage 0x5556, 2
	}
	return 0
}

nm_setGlobalInt(wParam, lParam, *)
{
	global
	Critical
	; enumeration
	#Include "%A_ScriptDir%\..\lib\enum\EnumInt.ahk"

	local var := arr[wParam]
	try %var% := lParam
	return 0
}

nm_setGlobalStr(wParam, lParam, *)
{
	global
	Critical
	; enumeration
	#Include "%A_ScriptDir%\..\lib\enum\EnumStr.ahk"
	static sections := ["Boost","Collect","Gather","Planters","Quests","Settings","Status","Blender","Shrine"]

	local var := arr[wParam], section := sections[lParam]
	try %var% := IniRead("settings\nm_config.ini", section, var)
	return 0
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
