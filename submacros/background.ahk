#NoEnv
#SingleInstance force
;SetBatchLines -1
#MaxThreads 255

RunWith(32)
runWith(version){	
	if (A_PtrSize=(version=32?4:8))
		Return
	SplitPath,A_AhkPath,,ahkDir
	if (!FileExist(correct := ahkDir "\AutoHotkeyU" version ".exe")){
		MsgBox,0x10,"Error",% "Couldn't find the " version " bit Unicode version of Autohotkey in:`n" correct
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
	ExitApp
}

global windowX, windowY, windowWidth, windowHeight
global resetTime:=nowUnix()
global NightLastDetected
global VBState:=0
global confirm:=0
global PackFilterArray:=[]
global imgfolder:="..\nm_image_assets"
IniRead, NightLastDetected, ..\settings\nm_config.ini, Collect, NightLastDetected
IniRead, VBLastKilled, ..\settings\nm_config.ini, Collect, VBLastKilled
IniRead, StingerCheck, ..\settings\nm_config.ini, Collect, StingerCheck
IniRead, AnnounceGuidingStar, ..\settings\nm_config.ini, Settings, AnnounceGuidingStar

CoordMode, Pixel, Client
DetectHiddenWindows On
SetTitleMatchMode 2

;OnMessages
OnMessage(0x5554, "nm_setGlobalNum", 255)

loop {
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox")
	nm_deathCheck()
	nm_dayOrNight()
	nm_backpackPercentFilter()
	nm_guidCheck()
	nm_popStarCheck()
	nm_guidingStarDetect()
	sleep, 1000
}

nm_setGlobalNum(wParam, lParam){
	global
	static arr := ["resetTime", "NightLastDetected", "VBState", "StingerCheck", "VBLastKilled"]
	
	var := arr[wParam], %var% := lParam
	
	return 0
}

nm_deathCheck(){
	global windowX, windowY, windowWidth, windowHeight
	static lastDetected:=0
	if (((nowUnix()-resetTime)>20) && ((nowUnix()-lastDetected)>10)) {
		ImageSearch, FoundX, FoundY, windowWidth/2, windowHeight/2, windowWidth, windowHeight, *50 %imgfolder%\died.png	
		if(ErrorLevel=0){
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 1, 1
			}
			lastDetected := nowUnix()
		}
	}
}

nm_guidCheck(){
	global windowX, windowY, windowWidth, windowHeight, LastFieldGuidDetected
	ImageSearch, FoundX, FoundY, 0, 0, windowWidth, 100, *50 %imgfolder%\boostguidingstar.png	
	if(ErrorLevel=0){ ;Guid Detected
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 8, 1
		}
	}
}
nm_popStarCheck(){
	global windowX, windowY, windowWidth, windowHeight, HasPopStar, PopStarActive
	ImageSearch, FoundX, FoundY, windowWidth/4, (windowHeight/4)*3, (windowWidth/4)*3, windowHeight, *30 %imgfolder%\popstar_counter.png
	if(ErrorLevel=0){
		HasPopStar:=1
		PopStarActive:=0
	} else if(ErrorLevel=1 && HasPopStar){
		PopStarActive:=1
	}
}
nm_dayOrNight(){
	disableDayorNight:=0
	;0=no VB, 1=searching for VB, 2=VB found
	global windowX, windowY, windowWidth, windowHeight
	global VBState, NightLastDetected, StingerCheck, VBLastKilled, confirm
	if (disableDayorNight || StingerCheck=0)
		return
	if(((VBState=1) && ((nowUnix()-NightLastDetected)>(400) || (nowUnix()-NightLastDetected)<0)) || ((VBState=2) && ((nowUnix()-VBLastKilled)>(400) || (nowUnix()-VBLastKilled)<0))) {
;temp:=nowUnix()-NightLastDetected
;temp2:=nowUnix()-VBLastKilled
;temp3:=nowUnix()
;temp4:=VBLastKilled
;send {F2}
;msgbox reset VBState=%VBState% (nowUnix()-NightLastDetected)=%temp% (nowUnix()-VBLastKilled)=%temp2%`nnow=%temp3% VBLastKilled=%VBLastKilled%
		VBState:=0
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 3, %VBState%
		}
	}
	ImageSearch, FoundX, FoundY, 0, windowHeight/2, windowWidth, windowHeight, *5 %imgfolder%\grassD.png
	if(ErrorLevel=0){
		dayOrNight:="Day"
	} else {
		ImageSearch, FoundX, FoundY, 0, windowHeight/2, windowWidth, windowHeight, *5 %imgfolder%\grassN.png	
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
		if((nowUnix()-NightLastDetected)>(300) || (nowUnix()-NightLastDetected)<0) {
			NightLastDetected:=nowUnix()
			IniWrite, %NightLastDetected%, ..\settings\nm_config.ini, Collect, NightLastDetected
;temp:=nowUnix()-NightLastDetected
;temp2:=nowUnix()-VBLastKilled
;temp3:=nowUnix()
;temp4:=NightLastDetected
;send {F2}
;msgbox reset VBState=%VBState% (nowUnix()-NightLastDetected)=%temp%`nnow=%temp3% NightLastDetected=%NightLastDetected%
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 2, %NightLastDetected%
			}
			sleep, 250
			if(StingerCheck && VBState=0) {
				VBState:=1 ;0=no VB, 1=searching for VB, 2=VB found
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, %VBState%
				}
			}
		}
	}
	;GuiControl,Text, timeOfDay, %dayOrNight%
	if(winexist("PlanterTimers.ahk ahk_class AutoHotkey")) {
		IniWrite, %dayOrNight%, ..\settings\nm_config.ini, gui, DayOrNight
	}
}

nm_backpackPercent(){
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
	if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
		PostMessage, 0x5555, 6, %BackpackPercent%
	}
	Return BackpackPercent
}
nm_backpackPercentFilter(){
	global PackFilterArray
	global BackpackPercentFiltered
	samplesize:=6 ;6 seconds (6 samples @ 1 sec intervals)
	
	;make room for new sample
	if(PackFilterArray.Length()=samplesize){
		PackFilterArray.Pop()
	}
	;get new sample
	PackFilterArray.InsertAt(1, nm_backpackPercent())
	;calculate rolling average
	sum:=0
	for key, val in PackFilterArray {
		sum:=sum+PackFilterArray[key]
	}
	BackpackPercentFiltered:=sum/PackFilterArray.length()
	if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
		PostMessage, 0x5555, 7, %BackpackPercentFiltered%
	}
	return BackpackPercentFiltered
}
nm_guidingStarDetect(){
	global AnnounceGuidingStar, windowX, windowY, windowWidth, windowHeight
	static lastDetected:=0, fieldnames := ["PineTree", "Stump", "Bamboo", "BlueFlower", "MountainTop", "Cactus", "Coconut", "Pineapple", "Spider", "Pumpkin", "Dandelion", "Sunflower", "Clover", "Pepper", "Rose", "Strawberry", "Mushroom"]
	
	if (!AnnounceGuidingStar || (nowUnix()-lastDetected<10))
		return
	
	xi:=windowWidth/2
	yi:=windowHeight/2
	
	GSfound:=0
	ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_icon1.png
	if(ErrorLevel=0){
		GSfound:=1
	} else {
		ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_icon2.png
		if(ErrorLevel=0){
			GSfound:=1
		}
	}
	if(GSfound){
		for key, value in fieldnames {
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_%value%.png
			if(ErrorLevel=0){
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					StringToSend:=value
					;set up string send
					VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
					SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
					NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
					NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
					;send the address to the string
					;SendMessage, 0x4242, 1, &CopyDataStruct
					SendMessage, 0x004A, 1, &CopyDataStruct
					lastDetected := nowUnix()
					break
				}
			}
		}
	}
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
    DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
    X := NumGet(&RECT, 0, "Int"), Y := NumGet(&RECT, 4, "Int")
    Width := NumGet(&RECT, 8, "Int"), Height := NumGet(&RECT, 12, "Int")
}
