;Enhancement Version 0.2.0
#SingleInstance force
;Menu, Tray, Icon, nm_image_assets\ptimers\bonk.ico
global TimerGuiTransparency:=0
global TimerX:=150
global TimerY:=150
global TimerW:=500
global TimerH:=100
SetWorkingDir %A_ScriptDir%\..
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
IniRead, ThemeSelect, settings\nm_config.ini, Settings, GuiTheme
SkinForm(Apply, A_WorkingDir . "\Styles\USkin.dll", A_WorkingDir . "\styles\" . ThemeSelect . ".msstyles")
OnExit("ba_timersExit")

gui ptimers:+AlwaysOnTop +border +minsize50x30 +E0x08040000 +hwndhGUI
gui ptimers:font, s8 cDefault Norm, Tahoma
gui ptimers:font, w1000
gui ptimers:+lastfound
gui ptimers:add, picture,x5 y35 h40 w40 vvplanterfield1 +BackgroundTrans,
gui ptimers:add, picture,x90 y35 h40 w40 vvplanterfield2 +BackgroundTrans,
gui ptimers:add, picture,x175 y35 h40 w40 vvplanterfield3 +BackgroundTrans,
gui ptimers:add, picture,x45 y35 h40 w40 vvplantername1 +BackgroundTrans,
gui ptimers:add, picture,x130 y35 h40 w40 vvplantername2 +BackgroundTrans,
gui ptimers:add, picture,x215 y35 h40 w40 vvplantername3 +BackgroundTrans,
gui ptimers:add, picture,x32 y16 h18 w18 vvplanternectar1 +BackgroundTrans,
gui ptimers:add, picture,x120 y16 h18 w18 vvplanternectar2 +BackgroundTrans,
gui ptimers:add, picture,x208 y16 h18 w18 vvplanternectar3 +BackgroundTrans,
gui ptimers:add, text,x2 y2 w80 vp1timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x90 y2 w80 vp2timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x177 y2 w80 vp3timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x262 y2 w60 +center +BackgroundTrans,Next King
gui ptimers:add, text,x262 y35 w60 +center +BackgroundTrans,Next Bear
gui ptimers:add, text,x262 y70 w60 +center +BackgroundTrans,Next Wolf
gui ptimers:add, text,x262 y17 w60 vpkingTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x262 y50 w60 vptunnelTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x262 y85 w60 vpwolfTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x327 y2 w60 +center +BackgroundTrans,Per Hour
gui ptimers:add, text,x325 y35 w60 +center +BackgroundTrans,Session
gui ptimers:add, text,x325 y70 w60 +center +BackgroundTrans,Reset
gui ptimers:add, text,x325 y17 w60 vphoneyaverage +center +BackgroundTrans,0
gui ptimers:add, text,x325 y50 w60 vpsessiontotalhoney +center +BackgroundTrans,0
gui ptimers:add, text,x325 y85 w60 vpserverTimer +center +BackgroundTrans,N/A
gui ptimers:add, Text, x0 y0 w500 h2 0x7
gui ptimers:add, Text, x257 y0 w2 h100 0x7
gui ptimers:add, Text, x322 y0 w2 h100 0x7
gui ptimers:add, Text, x389 y0 w2 h100 0x7
gui ptimers:add, Text, x259 y32 w130 h2 0x7
gui ptimers:add, Text, x259 y65 w241 h2 0x7
gui ptimers:add, Text, x389 y79 w111 h2 0x7
gui ptimers:font, w800
gui ptimers:add, text,x407 y84 w40  +left +BackgroundTrans,Opacity:
gui ptimers:font, w1000
Gui ptimers:Add, edit, x454 y83 w40 h16 Limit2 Number ReadOnly -border
if(fileexist("settings\nm_config.ini"))
	IniRead, TimerGuiTransparency, settings\nm_config.ini, gui, TimerGuiTransparency
Gui ptimers:Add, updown, Range0-50 vtimerGuiTransparency gsetTimerGuiTransparency, %TimerGuiTransparency%
setTimerGuiTransparency()
Gui, ptimers:Add, Button, x2 y84 w43 h15 gba_resetPlanterTimer1, Ready
Gui, ptimers:Add, Button, x89 y84 w43 h15 gba_resetPlanterTimer2, Ready
Gui, ptimers:Add, Button, x174 y84 w43 h15 gba_resetPlanterTimer3, Ready
Gui, ptimers:Add, Button, x45 y84 w40 h15 gba_resetPlanterData1, Clear
Gui, ptimers:Add, Button, x130 y84 w40 h15 gba_resetPlanterData2, Clear
Gui, ptimers:Add, Button, x217 y84 w40 h15 gba_resetPlanterData3, Clear
gui ptimers:add, text,x378 y66 w55 +right +BackgroundTrans vdayOrNight,Day
gui ptimers:add, text,x436 y66 w35 +left +BackgroundTrans, Detected
gui, ptimers:add, text,x391 y2 w110 h60 vstatus +center +BackgroundTrans,Status:
gui, ptimers:add, text,x395 y13 w84 h55 vpstatus +left +BackgroundTrans,unknown

if(fileexist("settings\nm_config.ini")){
	IniRead, TimerX, settings\nm_config.ini, gui, TimerX
	IniRead, TimerY, settings\nm_config.ini, gui, TimerY
	IniRead, TimerW, settings\nm_config.ini, gui, TimerW
	IniRead, TimerH, settings\nm_config.ini, gui, TimerH
}
;msgbox x=%TimerX% y=%TimerY%
gui ptimers:show, x%TimerX% y%TimerY% w%TimerW% h%TimerH% NoActivate,Timers Revision 2.0

Gui, -Resize

Loop {
	Loop, 3
	{
		i := A_Index
		
		for k,v in ["name","field","nectar","harvesttime","estpercent"]
			IniRead, Planter%v%%i%, settings\nm_config.ini, Planters, Planter%v%%i%
		
		for k,v in ["field","name","nectar"]
		{
			if (Planter%v%%i% != LastPlanter%v%%i%)
			{
				GuiControl,ptimers:, vplanter%v%%i%, % "nm_image_assets\ptimers\" . ((v = "name") ? "planter" : v) . "s\" Planter%v%%i% ".png"
				LastPlanter%v%%i% := Planter%v%%i%
			}
		}
		
		p%i%timer := PlanterHarvestTime%i%-toUnix_(), VarSetCapacity(p%i%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",p%i%timer*10000000,"wstr",(p%i%timer > 360000) ? "'No Planter'" : (p%i%timer > 0) ? (((p%i%timer >= 3600) ? "h'h' " : "") . ((p%i%timer >= 60) ? "mm'm' " : "") . "ss's'") : "'Ready'","str",p%i%timerstring,"int",256)
		GuiControl,ptimers:,p%i%timer,% p%i%timerstring
	}
	
	IniRead, GiftedViciousCheck, settings\nm_config.ini, Collect, GiftedViciousCheck
	for k,v in ["king","tunnel","wolf"]
	{
		IniRead, Last%v%, settings\nm_config.ini, Collect, % "Last" . ((v = "king") ? "KingBeetle" : (v = "tunnel") ? "TunnelBear" : "BugrunWerewolf")
		
		p%v%timer:=Last%v%-(toUnix_()-((v = "king") ? 86400 : (v = "tunnel") ? 172800 : 3600)*(1-GiftedViciousCheck*.15)), VarSetCapacity(p%v%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",p%v%timer*10000000,"wstr",(p%v%timer > 360000) ? "'N/A'" : (p%v%timer > 0) ? (((p%v%timer >= 3600) ? "h'h' " : "") . ((p%v%timer >= 60) ? "mm'm' " : "") . "ss's'") : "'Now'","str",p%v%timerstring,"int",256)
		GuiControl,ptimers:, p%v%timer, % p%v%timerstring
	}
	
	;IniRead, DailyReconnect, settings\nm_config.ini, Settings, DailyReconnect
	;if DailyReconnect
	;{

	IniRead, ReconnectHour, settings\nm_config.ini, Settings, ReconnectHour
	IniRead, ReconnectMin, settings\nm_config.ini, Settings, ReconnectMin
	if (ReconnectHour > 0 || ReconnectMin > 0)
	{
		IniRead, ReconnectHour, settings\nm_config.ini, Settings, ReconnectHour
		IniRead, ReconnectMin, settings\nm_config.ini, Settings, ReconnectMin
		FormatTime, UTCHour, %A_NowUTC%, HH
		FormatTime, UTCMin, %A_NowUTC%, mm
		pservertimer := Mod(24-((UTCMin < ReconnectMin) ? 0 : 1)+ReconnectHour-UTCHour, 24)*3600 + Mod(59+ReconnectMin-UTCMin, 60)*60 + (60 - Mod(A_Sec, 60)), VarSetCapacity(pservertimerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",pservertimer*10000000,"wstr",(pservertimer > 86400) ? "'N/A'" : ((pservertimer >= 3600) ? "h'h' " : "") . ((pservertimer >= 60) ? "mm'm' " : "") . "ss's'","str",pservertimerstring,"int",256)
		GuiControl,ptimers:,pservertimer, % pservertimerstring
	}
	
	if (Mod(A_Index, 60) = 1)
	{
		IniRead, HoneyAverage, settings\nm_config.ini, Status, HoneyAverage, 0
		IniRead, SessionTotalHoney, settings\nm_config.ini, Status, SessionTotalHoney, 0
		GuiControl,ptimers:,phoneyAverage, % HoneyAverage
		GuiControl,ptimers:,psessionTotalHoney, % SessionTotalHoney
	}
	
	IniRead, dayOrNight, settings\nm_config.ini, gui, dayOrNight
	GuiControl,ptimers:,dayOrNight,%dayOrNight%
	
	ControlGetText, val, static4, Natro Macro
	GuiControl,ptimers:,pstatus,%val%
	
	Sleep, 1000
}

toUnix_(){
	Time := A_NowUTC
	EnvSub, Time, 19700101000000, Seconds
	return Time
}

SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}
	else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
	}
}

setTimerGuiTransparency(){
	global TimerGuiTransparency
	setVal:=255-floor(timerGuiTransparency*2.55)
	winset, transparent, %setVal%
	if(fileexist("settings\nm_config.ini"))
		IniWrite, %TimerGuiTransparency%, settings\nm_config.ini, Gui, TimerGuiTransparency
}
ba_resetPlanterTimer1(){
	PlanterHarvestTime1 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime1
	IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime1
	IniRead, PlanterHarvestTime1, settings\nm_config.ini, Planters, PlanterHarvestTime1
}
ba_resetPlanterTimer2(){
	PlanterHarvestTime2 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime2
	IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime2
	IniRead, PlanterHarvestTime2, settings\nm_config.ini, Planters, PlanterHarvestTime2
}
ba_resetPlanterTimer3(){
	PlanterHarvestTime3 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime3
	IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime3
	IniRead, PlanterHarvestTime3, settings\nm_config.ini, Planters, PlanterHarvestTime3
}
ba_resetPlanterData1(){
	;save changes
	IniWrite, None, settings\nm_config.ini, Planters, PlanterName1
	IniWrite, None, settings\nm_config.ini, Planters, PlanterField1
	IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar1
	IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime1
	IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent1
	;readback ini values
	IniRead, PlanterName1, settings\nm_config.ini, Planters, PlanterName1
	IniRead, PlanterField1, settings\nm_config.ini, Planters, PlanterField1
	IniRead, PlanterNectar1, settings\nm_config.ini, Planters, PlanterNectar1
	IniRead, PlanterHarvestTime1, settings\nm_config.ini, Planters, PlanterHarvestTime1
	IniRead, PlanterEstPercent1, settings\nm_config.ini, Planters, PlanterEstPercent1
}
ba_resetPlanterData2(){
	;save changes
	IniWrite, None, settings\nm_config.ini, Planters, PlanterName2
	IniWrite, None, settings\nm_config.ini, Planters, PlanterField2
	IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar2
	IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime2
	IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent2
	;readback ini values
	IniRead, PlanterName2, settings\nm_config.ini, Planters, PlanterName2
	IniRead, PlanterField2, settings\nm_config.ini, Planters, PlanterField2
	IniRead, PlanterNectar2, settings\nm_config.ini, Planters, PlanterNectar2
	IniRead, PlanterHarvestTime2, settings\nm_config.ini, Planters, PlanterHarvestTime2
	IniRead, PlanterEstPercent2, settings\nm_config.ini, Planters, PlanterEstPercent2
}
ba_resetPlanterData3(){
	;save changes
	IniWrite, None, settings\nm_config.ini, Planters, PlanterName3
	IniWrite, None, settings\nm_config.ini, Planters, PlanterField3
	IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar3
	IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime3
	IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent3
	;readback ini values
	IniRead, PlanterName3, settings\nm_config.ini, Planters, PlanterName3
	IniRead, PlanterField3, settings\nm_config.ini, Planters, PlanterField3
	IniRead, PlanterNectar3, settings\nm_config.ini, Planters, PlanterNectar3
	IniRead, PlanterHarvestTime3, settings\nm_config.ini, Planters, PlanterHarvestTime3
	IniRead, PlanterEstPercent3, settings\nm_config.ini, Planters, PlanterEstPercent3
}
ba_saveTimerGui(){
	global hGUI, TimerGuiTransparency
	VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	;msgbox X=%TimerX% y=%TimerY% W=%TimerW% H=%TimerH%`nX=%windowX% y=%windowY% W=%windowWidth% H=%windowHeight%
	if(fileexist("settings\nm_config.ini")){
		if (x > 0)
			IniWrite, %x%, settings\nm_config.ini, gui, TimerX
		if (y > 0)
			IniWrite, %y%, settings\nm_config.ini, gui, TimerY
		;if (windowWidth > 0)
		;    IniWrite, %windowWidth%, settings\nm_config.ini, gui, TimerW
		;if (windowHeight > 0)
		;    IniWrite, %windowHeight%, settings\nm_config.ini, gui, TimerH
		IniWrite, %TimerGuiTransparency%, settings\nm_config.ini, gui, TimerGuiTransparency
	}
}
ba_timersExit(){
	ba_saveTimerGui()
	SkinForm(0)
	ExitApp
}

PtimersGuiClose:
ba_timersExit()
return
PtimersGuiSize:
ba_saveTimerGui()
return