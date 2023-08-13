#NoEnv
#SingleInstance force
;SetBatchLines -1

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

global ResetTime:=nowUnix()
global windowX, windowY, windowWidth, windowHeight, NightLastDetected
global confirm:=0
global PackFilterArray:=[]
global imgfolder:="..\nm_image_assets"
IniRead, NightLastDetected, ..\nm_config.ini, Collect, NightLastDetected
IniRead, VBLastKilled, ..\nm_config.ini, Collect, VBLastKilled
IniRead, StingerCheck, ..\nm_config.ini, Collect, StingerCheck
IniRead, WindowedScreen, ..\nm_config.ini, Settings, WindowedScreen


CoordMode, Pixel, Relative
WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
DetectHiddenWindows On
SetTitleMatchMode 2

;OnMessages
OnMessage(0x4200, "nm_setGlobalNum")

while 1 {
	nm_deathCheck()
	nm_dayOrNight()
	nm_backpackPercentFilter()
	nm_guidCheck()
	nm_popStarCheck()
	sleep, 1000
}

nm_setGlobalNum(wParam, lParam){
	global resetTime, NightLastDetected, VBState, StingerCheck, VBLastKilled
	
	;set resetTime
	if(wParam=1){
		resetTime:=lParam
	}
	;set NightLastDetected
	else if(wParam=2){
		NightLastDetected:=lParam
	}
	;set VBState
	else if(wParam=3){
		VBState:=lParam
	}
	;set StingerCheck
	else if(wParam=4){
		StingerCheck:=lParam
	}
	;set VBLastKilled
	else if(wParam=5){
		VBLastKilled:=lParam
	}
}

nm_deathCheck(){
	global windowX, windowY, windowWidth, windowHeight
	if ((nowUnix()-ResetTime)>20) {
		ImageSearch, FoundX, FoundY, windowWidth/2, windowHeight/2, windowWidth, windowHeight, *50 %imgfolder%\died.png	
		if(ErrorLevel=0){
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				SendMessage, 0x4201, 1, 0
			}
		}
	}
}

nm_guidCheck(){
	global windowX, windowY, windowWidth, windowHeight, LastFieldGuidDetected, GuidStrike
	ImageSearch, FoundX, FoundY, 0, 0, windowWidth, 100, *50 %imgfolder%\boostguidingstar.png	
	if(ErrorLevel=0){ ;Guid Detected
		if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
			SendMessage, 0x4201, 8, 0
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
			SendMessage, 0x4201, 3, %VBState%
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
		if((nowUnix()-NightLastDetected)>(300) || (nowUnix()-NightLastDetected)<0) { ;at least 5 minutes since last time it was night
			NightLastDetected:=nowUnix()
			IniWrite, %NightLastDetected%, ..\nm_config.ini, Collect, NightLastDetected
;temp:=nowUnix()-NightLastDetected
;temp2:=nowUnix()-VBLastKilled
;temp3:=nowUnix()
;temp4:=NightLastDetected
;send {F2}
;msgbox reset VBState=%VBState% (nowUnix()-NightLastDetected)=%temp%`nnow=%temp3% NightLastDetected=%NightLastDetected%
			if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
				SendMessage, 0x4201, 2, %NightLastDetected%
			}
			sleep, 250
			if(StingerCheck && VBState=0) {
				VBState:=1 ;0=no VB, 1=searching for VB, 2=VB found
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					SendMessage, 0x4201, 3, %VBState%
				}
			}
		}
	}
	;GuiControl,Text, timeOfDay, %dayOrNight%
	if(winexist("Timers")) {
		IniWrite, %dayOrNight%, ..\nm_config.ini, gui, DayOrNight
	}
}

nm_backpackPercent(){
	global WindowedScreen
	;WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	;UpperLeft X1 = windowWidth/2+59
	;UpperLeft Y1 = 3+WindowedScreen*31
	;LowerRight X2 = windowWidth/2+59+220
	;LowerRight Y2 = 3+WindowedScreen*31+5
	;Bar = 220 pixels wide = 11 pixels per 5%
	X1:=round((windowWidth/2+59+3), 0)
	Y1:=round((3+WindowedScreen*31+3), 0)
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
		SendMessage, 0x4201, 6, %BackpackPercent%
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
		SendMessage, 0x4201, 7, %BackpackPercentFiltered%
	}
	return BackpackPercentFiltered
}


nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}
