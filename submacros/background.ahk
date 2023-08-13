#NoEnv
#NoTrayIcon
#SingleInstance force
SetBatchLines -1
#InputLevel 1
#MaxThreads 255
SetWorkingDir %A_ScriptDir%

RunWith(32)
RunWith(bits) {
	If (A_IsUnicode && (A_PtrSize = (bits = 32 ? 4 : 8)))
		Return
	
	SplitPath, A_AhkPath,, ahkDirectory

	If (!FileExist(ahkPath := ahkDirectory "\AutoHotkeyU" bits ".exe"))
		MsgBox, 0x10, "Error", % "Couldn't find the " bits "-bit Unicode version of Autohotkey in:`n" ahkPath
	Else 
		Run, "%ahkPath%" "%A_ScriptName%", %A_ScriptDir%

	ExitApp
}

;initialization
global imgfolder:="..\nm_image_assets"
resetTime:=LastRobloxWindow:=LastState:=LastHeartbeat:=nowUnix()
VBState:=state:=0
DailyReconnect:=0
IniRead, NightLastDetected, ..\settings\nm_config.ini, Collect, NightLastDetected
IniRead, VBLastKilled, ..\settings\nm_config.ini, Collect, VBLastKilled
IniRead, StingerCheck, ..\settings\nm_config.ini, Collect, StingerCheck
IniRead, AnnounceGuidingStar, ..\settings\nm_config.ini, Settings, AnnounceGuidingStar
IniRead, ReconnectInterval, ..\settings\nm_config.ini, Settings, ReconnectInterval
IniRead, ReconnectHour, ..\settings\nm_config.ini, Settings, ReconnectHour
IniRead, ReconnectMin, ..\settings\nm_config.ini, Settings, ReconnectMin

CoordMode, Pixel, Client
DetectHiddenWindows On
SetTitleMatchMode 2

;OnMessages
OnExit("ExitFunc")
OnMessage(0x5554, "nm_setGlobalNum", 255)
OnMessage(0x5555, "nm_setState", 255)

loop {
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	nm_deathCheck()
	nm_guidCheck()
	nm_popStarCheck()
	nm_dayOrNight()
	nm_backpackPercentFilter()
	nm_guidingStarDetect()
	nm_dailyReconnect()
	(Mod(A_Index, 10) = 0) ? nm_sendHeartbeat()
	sleep, 1000
}

nm_setGlobalNum(wParam, lParam){
	Critical
	global resetTime, NightLastDetected, VBState, StingerCheck, VBLastKilled, DailyReconnect, LastHeartbeat
	static arr:=["resetTime", "NightLastDetected", "VBState", "StingerCheck", "VBLastKilled", "DailyReconnect", "LastHeartbeat"]
	
	var := arr[wParam], %var% := lParam
	return 0
}

nm_setState(wParam, lParam){
	Critical
	global state, lastState
	state := wParam, LastState := lParam
	return 0
}

nm_deathCheck(){
	global windowX, windowY, windowWidth, windowHeight, resetTime
	static LastDeathDetected:=0
	if (((nowUnix()-resetTime)>20) && ((nowUnix()-LastDeathDetected)>10)) {
		ImageSearch, , , windowWidth/2, windowHeight/2, windowWidth, windowHeight, *50 %imgfolder%\died.png	
		if(ErrorLevel=0){
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 1, 1
				Send_WM_COPYDATA("You Died", "natro_macro.ahk ahk_class AutoHotkey")
			}
			LastDeathDetected := nowUnix()
		}
	}
}

nm_guidCheck(){
	global windowX, windowY, windowWidth, windowHeight, state
	static LastFieldGuidDetected:=1, FieldGuidDetected:=0, confirm:=0
	ImageSearch, , , 0, 30, windowWidth, 90, *50 %imgfolder%\boostguidingstar.png
	if(ErrorLevel=0){ ;Guid Detected
		confirm:=0
		if ((FieldGuidDetected = 0) && (state = 1)) {
			FieldGuidDetected := 1
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 6, 1
				Send_WM_COPYDATA("Detected: Guiding Star Active", "natro_macro.ahk ahk_class AutoHotkey")
			}
			LastFieldGuidDetected := nowUnix()
		}
	}
	else if ((nowUnix() - LastFieldGuidDetected > 5) && FieldGuidDetected){
		confirm++
		if (comfirm >= 5) {
			confirm:=0
			FieldGuidDetected := 0
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 6, 0
			}
		}
	}
}

nm_popStarCheck(){
	global windowX, windowY, windowWidth, windowHeight, state
	static HasPopStar:=0, PopStarActive:=0
	ImageSearch, , , windowWidth//2 - 275, 3*windowHeight//4, windowWidth//2 + 275, windowHeight, *30 %imgfolder%\popstar_counter.png
	if(ErrorLevel=0){ ;Has Pop
		if (HasPopStar = 0){
			HasPopStar := 1
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 7, 1
			}
		}
		if (HasPopStar && (PopStarActive = 1)){
			PopStarActive := 0
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 8, 0
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5556, 1, 0
			}
		}
	}
	else if(ErrorLevel=1){
		if (HasPopStar && (PopStarActive = 0) && (state = 1)){
			PopStarActive := 1
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 8, 1
				;Send_WM_COPYDATA("Detected: Pop Star Active", "natro_macro.ahk ahk_class AutoHotkey")
			}
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5556, 1, 1
			}
		}
	}
}

nm_dayOrNight(){
	disableDayorNight:=0
	;VBState 0=no VB, 1=searching for VB, 2=VB found
	global windowX, windowY, windowWidth, windowHeight, NightLastDetected, StingerCheck, VBLastKilled, VBState
	static confirm:=0
	if (disableDayorNight || StingerCheck=0)
		return
	if(((VBState=1) && ((nowUnix()-NightLastDetected)>400 || (nowUnix()-NightLastDetected)<0)) || ((VBState=2) && ((nowUnix()-VBLastKilled)>(600) || (nowUnix()-VBLastKilled)<0))) {
		VBState:=0
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 3, 0
		}
	}
	ImageSearch, , , 0, windowHeight/2, windowWidth, windowHeight, *5 %imgfolder%\grassD.png
	if(ErrorLevel=0){
		dayOrNight:="Day"
	} else {
		ImageSearch, , , 0, windowHeight/2, windowWidth, windowHeight, *5 %imgfolder%\grassN.png	
		if(ErrorLevel=0){
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
			IniWrite, %NightLastDetected%, ..\settings\nm_config.ini, Collect, NightLastDetected
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 2, %NightLastDetected%
				Send_WM_COPYDATA("Detected: Night", "natro_macro.ahk ahk_class AutoHotkey")
			}
			if(StingerCheck && VBState=0) {
				VBState:=1 ;0=no VB, 1=searching for VB, 2=VB found
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 1
				}
			}
		}
	}
	;GuiControl,Text, timeOfDay, %dayOrNight%
	if(winexist("PlanterTimers.ahk ahk_class AutoHotkey")) {
		IniWrite, %dayOrNight%, ..\settings\nm_config.ini, gui, DayOrNight ;make this a PostMessage too, fewer disk reads/writes is better!
	}
}

nm_backpackPercent(){
	global windowX, windowY, windowWidth, windowHeight
	static LastBackpackPercent:=""
	;WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	;UpperLeft X1 = windowWidth/2+59
	;UpperLeft Y1 = 3
	;LowerRight X2 = windowWidth/2+59+220
	;LowerRight Y2 = 3+5
	;Bar = 220 pixels wide = 11 pixels per 5%
	X1:=windowWidth//2+59+3
	Y1:=6
	PixelGetColor, backpackColor, %X1%, %Y1%, RGB fast
	BackpackPercent:=0

	if((backpackColor & 0xFF0000 <= Format("{:d}",0x690000))) { ;less or equal to 50%
		if(backpackColor & 0xFF0000 <= Format("{:d}",0x4B0000)) { ;less or equal to 25%
			if(backpackColor & 0xFF0000 <= Format("{:d}",0x420000)) { ;less or equal to 10%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0x410000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00FF80)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00FF86))) { ;less or equal to 5%
					BackpackPercent:=0
				} else if((backpackColor & 0xFF0000 > Format("{:d}",0x410000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00FF80)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00FC85))) { ;greater than 5%
					BackpackPercent:=5
				} else {
					BackpackPercent:=0
				}
			} else { ;greater than 10%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0x470000))) { ;less or equal to 20%
					if((backpackColor & 0xFF0000 <= Format("{:d}",0x440000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00FE85)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00F984))) { ;less or equal to 15%
						BackpackPercent:=10
					} else if((backpackColor & 0xFF0000 > Format("{:d}",0x440000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00FB84)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00F582))) { ;greater than 15%
						BackpackPercent:=15
					} else {
						BackpackPercent:=0
					}
				} else if((backpackColor & 0xFF0000 > Format("{:d}",0x470000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00F782)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00F080))) { ;greater than 20%
					BackpackPercent:=20
				} else {
					BackpackPercent:=0
				}
			}
		} else { ;greater than 25%
			if(backpackColor & 0xFF0000 <= Format("{:d}",0x5B0000)) { ;less or equal to 40%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0x4F0000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00F280)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00EA7D))) { ;less or equal to 30%
					BackpackPercent:=25
				} else { ;greater than 30%
					if((backpackColor & 0xFF0000 <= Format("{:d}",0x550000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00EC7D)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00E37A))) { ;less or equal to 35%
						BackpackPercent:=30
					} else if((backpackColor & 0xFF0000 > Format("{:d}",0x550000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00E57A)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00DA76))) { ;greater than 35%
						BackpackPercent:=35
					} else {
						BackpackPercent:=0
					}
				}
			} else { ;greater than 40%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0x620000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00DC76)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00D072))) { ;less or equal to 45%
					BackpackPercent:=40
				} else if((backpackColor & 0xFF0000 > Format("{:d}",0x620000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00D272)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00C66D))) { ;greater than 45%
					BackpackPercent:=45
				} else {
					BackpackPercent:=0
				}
			}
		}
	} else { ;greater than 50%
		if(backpackColor & 0xFF0000 <= Format("{:d}",0x9C0000)) { ;less or equal to 75%
			if(backpackColor & 0xFF0000 <= Format("{:d}",0x850000)) { ;less or equal to 65%
				if(backpackColor & 0xFF0000 <= Format("{:d}",0x7B0000)) { ;less or equal to 60%
					if((backpackColor & 0xFF0000 <= Format("{:d}",0x720000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00C86D)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00BA68))) { ;less or equal to 55%
						BackpackPercent:=50
					} else if((backpackColor & 0xFF0000 > Format("{:d}",0x720000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00BC68)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00AD62))) { ;greater than 55%
						BackpackPercent:=55
					} else {
						BackpackPercent:=0
					}
				} else if((backpackColor & 0xFF0000 > Format("{:d}",0x7B0000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00AF62)) && (backpackColor & 0x00FFFF > Format("{:d}",0x009E5C))) { ;greater than 60%
					BackpackPercent:=60
				} else {
					BackpackPercent:=0
				}
			} else { ;greater than 65%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0x900000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00A05C)) && (backpackColor & 0x00FFFF > Format("{:d}",0x008F55))) { ;less or equal to 70%
					BackpackPercent:=65
				} else if((backpackColor & 0xFF0000 > Format("{:d}",0x900000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x009155)) && (backpackColor & 0x00FFFF > Format("{:d}",0x007E4E))) { ;greater than 70%
					BackpackPercent:=70
				} else {
					BackpackPercent:=0
				}
			}
		} else { ;greater than 75%
			if((backpackColor & 0xFF0000 <= Format("{:d}",0xC40000))) { ;less or equal to 90%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0xA90000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x00804E)) && (backpackColor & 0x00FFFF > Format("{:d}",0x006C46))) { ;less or equal to 80%
					BackpackPercent:=75
				} else { ;greater than 80%
					if((backpackColor & 0xFF0000 <= Format("{:d}",0xB60000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x006E46)) && (backpackColor & 0x00FFFF > Format("{:d}",0x005A3F))) { ;less or equal to 85%
						BackpackPercent:=80
					} else if((backpackColor & 0xFF0000 > Format("{:d}",0xB60000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x005D3F)) && (backpackColor & 0x00FFFF > Format("{:d}",0x004637))){ ;greater than 85%
						BackpackPercent:=85
					} else {
						BackpackPercent:=0
					}
				}
			} else { ;greater than 90%
				if((backpackColor & 0xFF0000 <= Format("{:d}",0xD30000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x004A37)) && (backpackColor & 0x00FFFF > Format("{:d}",0x00322E))) { ;less or equal to 95%
					BackpackPercent:=90
				} else { ;greater than 95%
					if((backpackColor = Format("{:d}",0xF70017)) || ((backpackColor & 0xFF0000 >= Format("{:d}",0xE00000)) && (backpackColor & 0x00FFFF <= Format("{:d}",0x002427)) && (backpackColor & 0x00FFFF > Format("{:d}",0x001000)))) { ;is equal to 100%
						BackpackPercent:=100
					} else if((backpackColor & 0x00FFFF <= Format("{:d}",0x00342E))){
						BackpackPercent:=95
					} else {
						BackpackPercent:=0
					}
				}
			}
		}
	}
	if ((BackpackPercent != LastBackpackPercent) && WinExist("natro_macro.ahk ahk_class AutoHotkey")) {
		PostMessage, 0x5555, 4, %BackpackPercent%
		LastBackpackPercent := BackpackPercent
	}
	Return BackpackPercent
}
nm_backpackPercentFilter(){
	static PackFilterArray:=[], LastBackpackPercentFiltered:="", i:=0, samplesize:=6 ;6 seconds (6 samples @ 1 sec intervals)
	
	;make room for new sample
	if(PackFilterArray.Length()=samplesize){
		PackFilterArray.Pop()
	}
	;get new sample
	PackFilterArray.InsertAt(1, nm_backpackPercent())
	;calculate rolling average
	sum:=0
	for key, val in PackFilterArray {
		sum+=val
	}
	BackpackPercentFiltered:=Round(sum/PackFilterArray.length())
	if ((i=0) && WinExist("StatMonitor.ahk ahk_class AutoHotkey")) {
		PostMessage, 0x5557, BackpackPercentFiltered, 60 * A_Min + A_Sec
	}
	i:=Mod(i+1, 6)
	if (BackpackPercentFiltered != LastBackpackPercentFiltered) {
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 5, BackpackPercentFiltered
		}
		LastBackpackPercentFiltered := BackpackPercentFiltered
	}
}

nm_guidingStarDetect(){
	global AnnounceGuidingStar, windowX, windowY, windowWidth, windowHeight
	static LastGuidDetected:=0, fieldnames := ["PineTree", "Stump", "Bamboo", "BlueFlower", "MountainTop", "Cactus", "Coconut", "Pineapple", "Spider", "Pumpkin", "Dandelion", "Sunflower", "Clover", "Pepper", "Rose", "Strawberry", "Mushroom"]
	
	if (!AnnounceGuidingStar || (nowUnix()-LastGuidDetected<10))
		return
	
	xi:=windowWidth/2
	yi:=windowHeight/2
	
	GSfound:=0
	Loop, 2 {
		ImageSearch, , , xi, yi, windowWidth, windowHeight, *50 %imgfolder%\guiding_star_icon%A_Index%.png
		if(ErrorLevel=0) {
			GSfound:=1
			break
		}
	}
	
	if(GSfound){
		for key, value in fieldnames {
			ImageSearch, , , xi, yi, windowWidth, windowHeight, *50 %imgfolder%\guiding_star_%value%.png
			if(ErrorLevel=0){
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					Send_WM_COPYDATA(value, "natro_macro.ahk ahk_class AutoHotkey", 1)
					LastGuidDetected := nowUnix()
					break
				}
			}
		}
	}
}

nm_dailyReconnect(){
	global ReconnectHour, ReconnectMin, ReconnectInterval, DailyReconnect
	if ((ReconnectHour = "") || (ReconnectMin = "") || (ReconnectInterval = ""))
		return
	FormatTime, RChourUTC, %A_NowUTC%, HH
	FormatTime, RCminUTC, %A_NowUTC%, mm
	HourReady:=0
	Loop % 24//ReconnectInterval
	{
		if (Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24)=RChourUTC)
		{
			HourReady:=1
			break
		}
	}
	if((ReconnectMin=RCminUTC) && HourReady && (DailyReconnect=0)) {
		DailyReconnect:=1
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 9, 1
			Send_WM_COPYDATA("Closing: Roblox, Daily Reconnect", "natro_macro.ahk ahk_class AutoHotkey")
		}
		while(winexist("Roblox ahk_exe RobloxPlayerBeta.exe")){
			WinKill
			sleep, 1000
		}
	}
}

nm_sendHeartbeat(){
	global LastHeartbeat, LastState, LastRobloxWindow
	time := nowUnix()
	if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")
		LastRobloxWindow:=time
	if (((time - LastHeartbeat > 120) && (reason := 1)) || ((time - LastRobloxWindow > 600) && (reason := 2))) {
		Loop, 10 {
			while WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				WinGet, natroPID, PID
				Process, Close, % natroPID
			}
			while WinExist("Roblox") {
				WinKill
				sleep, 1000
			}
			
			run, "%A_AhkPath%" "..\natro_macro.ahk"
			WinWait, Natro ahk_class AutoHotkeyGUI, , 300
			if (success := !ErrorLevel) {
				Sleep, 5000
				Send_WM_COPYDATA("Error: " ((reason = 1) ? "Macro Unresponsive Timeout!" : "No Roblox Window Timeout!") "`nSuccessfully restarted macro!", "natro_macro.ahk ahk_class AutoHotkey")
				Sleep, 1000
				if WinExist("natro_macro.ahk ahk_class AutoHotkey")
					PostMessage, 0x5550
				Sleep, 1000
				ExitApp
			}
		}
	}
	if WinExist("natro_macro.ahk ahk_class AutoHotkey")
		PostMessage, 0x5556
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
nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}
WinGetClientPos(ByRef X:="", ByRef Y:="", ByRef Width:="", ByRef Height:="", WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="")
{
    local hWnd, RECT
    hWnd := WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText)
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "UPtr",hWnd, "Ptr",&RECT)
    DllCall("ClientToScreen", "UPtr",hWnd, "Ptr",&RECT)
    X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
    Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}

ExitFunc()
{
	Process, Close, % DllCall("GetCurrentProcessId")
}
