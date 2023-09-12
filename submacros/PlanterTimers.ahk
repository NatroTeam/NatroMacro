/*
Natro Macro, https://bit.ly/NatroMacro
Copyright © 2022-2023 Natro Dev Team (natromacroserver@gmail.com)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro. 

You should have received a copy of the GNU General Public License along with Natro Macro. If not, see https://www.gnu.org/licenses/. 
*/

;Enhancement Version 0.2.0
#SingleInstance force
#NoTrayIcon
;Menu, Tray, Icon, nm_image_assets\ptimers\bonk.ico
global TimerGuiTransparency:=0
global TimerX:=150
global TimerY:=150

if (TimerX && TimerY)
{
	SysGet, MonitorCount, MonitorCount
	loop %MonitorCount%
	{
		SysGet, Mon, MonitorWorkArea, %A_Index%
		if(TimerX>MonLeft && TimerX<MonRight && GuiY>MonTop && GuiY<MonBottom)
			break
		if(A_Index=MonitorCount)
			TimerX:=TimerY:=0
	}
}
else
	TimerX:=TimerY:=0
	
SetWorkingDir %A_ScriptDir%\..
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
IniRead, ThemeSelect, settings\nm_config.ini, Settings, GuiTheme
SkinForm(Apply, A_WorkingDir . "\nm_image_assets\Styles\USkin.dll", A_WorkingDir . "\nm_image_assets\Styles\" . ThemeSelect . ".msstyles")
OnExit("ba_timersExit")

if(fileexist("settings\nm_config.ini")){
	IniRead, TimerX, settings\nm_config.ini, gui, TimerX
	IniRead, TimerY, settings\nm_config.ini, gui, TimerY
	IniRead, TimerGuiTransparency, settings\nm_config.ini, gui, TimerGuiTransparency
}

gui ptimers:+AlwaysOnTop +border +minsize50x30 +E0x08040000 +hwndhGUI +lastfound
setTimerGuiTransparency()
gui ptimers:font, s8 cDefault Norm, Tahoma
gui ptimers:font, w1000
gui ptimers:add, picture,x2 y35 h40 w40 vvplanterfield1 +BackgroundTrans,
gui ptimers:add, picture,x88 y35 h40 w40 vvplanterfield2 +BackgroundTrans,
gui ptimers:add, picture,x174 y35 h40 w40 vvplanterfield3 +BackgroundTrans,
gui ptimers:add, picture,x44 y35 h40 w40 vvplantername1 +BackgroundTrans,
gui ptimers:add, picture,x130 y35 h40 w40 vvplantername2 +BackgroundTrans,
gui ptimers:add, picture,x216 y35 h40 w40 vvplantername3 +BackgroundTrans,
gui ptimers:add, picture,x34 y16 h18 w18 vvplanternectar1 +BackgroundTrans,
gui ptimers:add, picture,x120 y16 h18 w18 vvplanternectar2 +BackgroundTrans,
gui ptimers:add, picture,x206 y16 h18 w18 vvplanternectar3 +BackgroundTrans,
gui ptimers:add, text,x2 y2 w82 vp1timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x88 y2 w82 vp2timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x174 y2 w82 vp3timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x258 y4 w66 +center +BackgroundTrans,Next King
gui ptimers:add, text,x258 y40 w66 +center +BackgroundTrans,Next Bear
gui ptimers:add, text,x258 y76 w66 +center +BackgroundTrans,Next Wolf
gui ptimers:add, text,x262 y20 w58 vpkingTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x262 y56 w58 vptunnelTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x262 y92 w58 vpwolfTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x322 y4 w66 +center +BackgroundTrans,Per Hour
gui ptimers:add, text,x322 y40 w66 +center +BackgroundTrans,Session
gui ptimers:add, text,x322 y76 w66 +center +BackgroundTrans,Reset
gui ptimers:add, text,x326 y20 w58 vphoneyaverage +center +BackgroundTrans,0
gui ptimers:add, text,x326 y56 w58 vpsessiontotalhoney +center +BackgroundTrans,0
gui ptimers:add, text,x326 y92 w58 vpserverTimer +center +BackgroundTrans,N/A
gui ptimers:add, Text, x0 y0 w500 h2 0x7
gui ptimers:add, Text, x258 y0 w2 h108 0x7
gui ptimers:add, Text, x322 y0 w2 h108 0x7
gui ptimers:add, Text, x386 y0 w2 h108 0x7
gui ptimers:add, Text, x259 y36 w128 h2 0x7
gui ptimers:add, Text, x259 y72 w241 h2 0x7
gui ptimers:add, Text, x387 y86 w113 h2 0x7
gui ptimers:add, Text,x390 y90 +left +BackgroundTrans,Transparency
Gui ptimers:Add, Text, x469 y90 w29 h14 +Center
Gui ptimers:Add, updown, Range0-70 vtimerGuiTransparency gsetTimerGuiTransparency, %TimerGuiTransparency%
Gui, ptimers:Add, Button, x2 y76 w40 h15 hwndhReady1 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, x88 y76 w40 h15 hwndhReady2 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, x174 y76 w40 h15 hwndhReady3 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, x44 y76 w40 h15 hwndhClear1 gba_setPlanterData, Add
Gui, ptimers:Add, Button, x130 y76 w40 h15 hwndhClear2 gba_setPlanterData, Add
Gui, ptimers:Add, Button, x216 y76 w40 h15 hwndhClear3 gba_setPlanterData, Add
Gui, ptimers:Add, Button, x2 y92 w40 h15 hwndhSubHour1 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, x88 y92 w40 h15 hwndhSubHour2 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, x174 y92 w40 h15 hwndhSubHour3 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, x44 y92 w40 h15 hwndhAddHour1 gba_setPlanterTimer, +1HR
Gui, ptimers:Add, Button, x130 y92 w40 h15 hwndhAddHour2 gba_setPlanterTimer, +1HR
Gui, ptimers:Add, Button, x216 y92 w40 h15 hwndhAddHour3 gba_setPlanterTimer, +1HR
gui ptimers:add, text,x388 y73 w112 +center +BackgroundTrans vdayOrNight,Day Detected
gui, ptimers:add, text,x391 y2 w110 h60 vstatus +center +BackgroundTrans,Status:
gui, ptimers:add, text,x392 y13 w104 h56 vpstatus +left +BackgroundTrans,unknown
	
;msgbox x=%TimerX% y=%TimerY%
gui ptimers:show, x%TimerX% y%TimerY% w500 h108 NoActivate,Timers Revision 3.0
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
		
		GuiControl, -Redraw, % hClear%i%
		GuiControl,, % hClear%i%, % ((PlanterName%i% = "None") ? "Add" : "Clear")
		GuiControl, +Redraw, % hClear%i%
		
		p%i%timer := PlanterHarvestTime%i%-nowUnix(), VarSetCapacity(p%i%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",p%i%timer*10000000,"wstr",(p%i%timer > 360000) ? "'No Planter'" : (p%i%timer > 0) ? (((p%i%timer >= 3600) ? "h'h' m" : "") . ((p%i%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Ready'","str",p%i%timerstring,"int",256)
		GuiControl,ptimers:-Redraw, p%i%timer
		GuiControl,ptimers:,p%i%timer,% p%i%timerstring
		GuiControl,ptimers:+Redraw, p%i%timer
	}
	
	IniRead, MonsterRespawnTime, settings\nm_config.ini, Collect, MonsterRespawnTime
	for k,v in ["king","tunnel","wolf"]
	{
		IniRead, Last%v%, settings\nm_config.ini, Collect, % "Last" . ((v = "king") ? "KingBeetle" : (v = "tunnel") ? "TunnelBear" : "BugrunWerewolf")
		
		p%v%timer:=Last%v%-(nowUnix()-((v = "king") ? 86400 : (v = "tunnel") ? 172800 : 3600)*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)), VarSetCapacity(p%v%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",p%v%timer*10000000,"wstr",(p%v%timer > 360000) ? "'N/A'" : (p%v%timer > 0) ? (((p%v%timer >= 3600) ? "h'h' m" : "") . ((p%v%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Now'","str",p%v%timerstring,"int",256)
		GuiControl,ptimers:, p%v%timer, % p%v%timerstring
	}

	IniRead, ReconnectHour, settings\nm_config.ini, Settings, ReconnectHour
	IniRead, ReconnectMin, settings\nm_config.ini, Settings, ReconnectMin
	IniRead, ReconnectInterval, settings\nm_config.ini, Settings, ReconnectInterval
	if (ReconnectHour != "" && ReconnectMin != "")
	{
		FormatTime, UTCHour, %A_NowUTC%, HH
		FormatTime, UTCMin, %A_NowUTC%, mm
		pservertimers := []
		Loop % 24//ReconnectInterval
		{
			hour := Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24)
			pservertimers.Push(Mod(24-((UTCMin < ReconnectMin) ? 0 : 1)+hour-UTCHour, 24)*3600 + Mod(59+ReconnectMin-UTCMin, 60)*60 + (60 - Mod(A_Sec, 60)))
		}
		pservertimer := Min(pservertimers*)
		VarSetCapacity(pservertimerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",pservertimer*10000000,"wstr",(pservertimer > 86400) ? "'N/A'" : ((pservertimer >= 3600) ? "h'h' m" : "") . ((pservertimer >= 60) ? "m'm' s" : "") . "s's'","str",pservertimerstring,"int",256)
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
	GuiControl,ptimers:,dayOrNight,%dayOrNight% Detected
	
	ControlGetText, val, , % "ahk_id " A_Args[1]
	GuiControl,ptimers:,pstatus,%val%
	
	Sleep, (1100 - A_MSec)
}

nowUnix(){
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
ba_resetPlanterTimer(hCtrl){
	global hReady1, hReady2, hReady3
	Loop, 3 {
		if (hCtrl = hReady%A_Index%) {
			IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
			if (PlanterName%A_Index% != "None") {
				PlanterHarvestTime%A_Index% := nowUnix()-1
				IniWrite, % PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
			}
			break
		}
	}
}
ba_setPlanterTimer(hCtrl){
	global hSubHour1, hSubHour2, hSubHour3, hAddHour1, hAddHour2, hAddHour3
	Loop, 3 {
		i := A_Index
		for k,v in ["Sub","Add"] {
			if (hCtrl = h%v%Hour%i%) {
				IniRead, PlanterName%i%, settings\nm_config.ini, Planters, PlanterName%i%
				if (PlanterName%i% != "None") {
					IniRead, PlanterHarvestTime%i%, settings\nm_config.ini, Planters, PlanterHarvestTime%i%
					IniWrite, % (PlanterHarvestTime%i% := (k = 1) ? Max(nowUnix(), PlanterHarvestTime%i%-3600) : Max(nowUnix(), PlanterHarvestTime%i%)+3600), settings\nm_config.ini, Planters, PlanterHarvestTime%i%
					IniWrite, % Min(Max((PlanterHarvestTime%i% - nowUnix())//864, 0), 100), settings\nm_config.ini, Planters, PlanterEstPercent%i%
				}
				break
			}
		}
	}
}
ba_setPlanterData(hCtrl){
	global hClear1, hClear2, hClear3
	Loop, 3 {
		if (hCtrl = hClear%A_Index%) {
			IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
			if (PlanterName%A_Index% = "None") {
				ba_addPlanterData(A_Index)
			} else {
				IniWrite, None, settings\nm_config.ini, Planters, PlanterName%A_Index%
				IniWrite, None, settings\nm_config.ini, Planters, PlanterField%A_Index%
				IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
				IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
				IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent%A_Index%
				IniWrite, % "", settings\nm_config.ini, Planters, PlanterHarvestFull%A_Index%
				IniWrite, 0, settings\nm_config.ini, Planters, PlanterGlitter%A_Index%
				IniWrite, 0, settings\nm_config.ini, Planters, PlanterGlitterC%A_Index%
			}
			break
		}
	}
}
ba_addPlanterData(PlanterIndex){
	global
	addIndex := PlanterIndex, addField := "Bamboo", addPlanter := "BlueClayPlanter"
	Gui addp:Destroy
	Gui addp:+AlwaysOnTop +Border -Resize +hwndhAdd
	Gui addp:Font, s8 cDefault Norm, Tahoma
	Gui addp:Add, Picture, x20 y4 w50 h50 hwndhAddField, nm_image_assets\ptimers\fields\Bamboo.png
	Gui addp:Add, Picture, x90 y4 w50 h50 hwndhAddPlanter, nm_image_assets\ptimers\planters\Blueclayplanter.png
	Gui addp:Add, Button, x22 y58 w18 h18 hwndhfleft gba_AddFieldButton, <
	Gui addp:Add, Button, x50 y58 w18 h18 hwndhfright gba_AddFieldButton, >
	Gui addp:Add, Button, x92 y58 w18 h18 hwndhpleft gba_AddPlanterButton, <
	Gui addp:Add, Button, x120 y58 w18 h18 hwndhpright gba_AddPlanterButton, >
	Gui addp:Add, Text, x6 y80, Harvest in:
	Gui addp:Add, Text, x64 y80 w28 h16 +Center, 0
	Gui addp:Add, UpDown, vAddHours Range0-23
	Gui addp:Add, Text, x96 y80 w28 h16 +Center, 0
	Gui addp:Add, UpDown, vAddMins Range0-59
	Gui addp:Add, Text, x128 y80 w28 h16 +Center, 0
	Gui addp:Add, UpDown, vAddSecs Range0-59
	Gui addp:Add, Text, x65 y96 w32 +Center, Hours
	Gui addp:Add, Text, x98 y96 w32 +Center, Mins
	Gui addp:Add, Text, x128 y96 w32 +Center, Secs
	Gui addp:Font, w1000
	Gui addp:Add, Button, x40 y114 w80 h16 +Center gba_AddPlanter, Add to Slot %PlanterIndex%
	VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	Gui addp:Show, % "x" (x - 124 + PlanterIndex * 86) " y" (y + 136) " w160", Add Planter
}
ba_AddFieldButton(hCtrl){
	global hAdd, hfleft, hfright, hAddField, addfield
	static fields := ["Bamboo","Blue Flower","Cactus","Clover","Coconut","Dandelion","Mountain Top","Mushroom","Pepper","Pine Tree","Pineapple","Pumpkin","Rose","Spider","Strawberry","Stump","Sunflower"], i := 0, h := 0
	if (h != hAdd)
		i := 0, h := hAdd
	i := Mod(fields.Length() + i + ((hCtrl = hfleft) ? -1 : 1), fields.Length()), addField := fields[i+1]
	GuiControl,, % hAddField, % "*w50 *h50 nm_image_assets\ptimers\fields\" addField ".png"
}
ba_AddPlanterButton(hCtrl){
	global hAdd, hpleft, hpright, hAddPlanter, addplanter
	static planters := ["BlueClayPlanter","CandyPlanter","HeatTreatedPlanter","HydroponicPlanter","PaperPlanter","PesticidePlanter","PetalPlanter","PlanterOfPlenty","PlasticPlanter","RedClayPlanter","TackyPlanter","TicketPlanter"], i := 0, h := 0
	if (h != hAdd)
		i := 0, h := hAdd
	i := Mod(planters.Length() + i + ((hCtrl = hpleft) ? -1 : 1), planters.Length()), addPlanter := planters[i+1]
	GuiControl,, % hAddPlanter, % "*w50 *h50 nm_image_assets\ptimers\planters\" addPlanter ".png"
}
ba_AddPlanter(){
	global addIndex, addField, addPlanter, AddHours, AddMins, AddSecs
	Loop, 3
	{
		IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
		IniRead, PlanterField%A_Index%, settings\nm_config.ini, Planters, PlanterField%A_Index%
		Gui addp:+OwnDialogs
		if (PlanterField%A_Index% = addField)
		{
			msgbox, 0x40000, Error!, This field is already used in Slot %A_Index%. You must clear that slot before adding this entry!
			return
		}
		else if (PlanterName%A_Index% = addPlanter)
		{
			msgbox, 0x40000, Error!, This planter is already used in Slot %A_Index%. You must clear that slot before adding this entry!
			return
		}
	}
	switch addfield
	{
		case "Dandelion", "Bamboo", "Pine Tree":
		addnectar := "Comforting"
		
		case "Coconut", "Strawberry", "Blue Flower":
		addnectar := "Refreshing"
		
		case "Pineapple", "Sunflower", "Pumpkin":
		addnectar := "Satisfying"
		
		case "Stump", "Spider", "Mushroom", "Rose":
		addnectar := "Motivating"
		
		case "Pepper", "Mountain Top", "Clover", "Cactus":
		addnectar := "Invigorating"
	}
	Gui addp:Submit
	Gui addp:Destroy
	IniWrite, %addplanter%, settings\nm_config.ini, Planters, PlanterName%addindex%
	IniWrite, %addfield%, settings\nm_config.ini, Planters, PlanterField%addindex%
	IniWrite, %addnectar%, settings\nm_config.ini, Planters, PlanterNectar%addindex%
	IniWrite, % nowUnix() + (addharvesttime := AddHours*3600+AddMins*60+AddSecs), settings\nm_config.ini, Planters, PlanterHarvestTime%addindex%
	IniWrite, % Min(addharvesttime//864, 100), settings\nm_config.ini, Planters, PlanterEstPercent%addindex%
	IniWrite, % "", settings\nm_config.ini, Planters, PlanterHarvestFull%addindex%
	IniWrite, 0, settings\nm_config.ini, Planters, PlanterGlitter%addindex%
	IniWrite, 0, settings\nm_config.ini, Planters, PlanterGlitterC%addindex%
}
ba_saveTimerGui(){
	global hGUI, TimerGuiTransparency
	VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	if(fileexist("settings\nm_config.ini")){
		if (x > 0)
			IniWrite, %x%, settings\nm_config.ini, gui, TimerX
		if (y > 0)
			IniWrite, %y%, settings\nm_config.ini, gui, TimerY
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