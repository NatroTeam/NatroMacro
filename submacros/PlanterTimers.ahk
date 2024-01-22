/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

;Enhancement Version 0.2.0
#SingleInstance force
#NoTrayIcon
#Include %A_ScriptDir%\..\lib\Gdip_All.ahk
global TimerGuiTransparency:=0
global TimerX:=150
global TimerY:=150
DetectHiddenWindows, On
SetTitleMatchMode, 2
	
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

	if (TimerX && TimerY)
	{
		SysGet, MonitorCount, MonitorCount
		loop %MonitorCount%
		{
			SysGet, Mon, MonitorWorkArea, %A_Index%
			if(TimerX>MonLeft && TimerX<MonRight && TimerY>MonTop && TimerY<MonBottom)
				break
			if(A_Index=MonitorCount)
				TimerX:=TimerY:=0
		}
	}
	else
		TimerX:=TimerY:=0
}

pToken := Gdip_Startup() ;not ure if this should go somewhere else

;Blender/shrine GUI
hBitmapsSBT := {}
#Include %A_ScriptDir%\..\nm_image_assets\gui\blendershrine_bitmaps.ahk

hBitmapsSB := {}
for x,y in hBitmapsSBT
	hBitmapsSB[x] := Gdip_CreateHBITMAPFromBitmap(y), Gdip_DisposeImage(y)
hBitmapsSB["None"] := 0

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
gui ptimers:add, Text, x0 y216 w500 h2 0x7
gui ptimers:add, Text, x258 y0 w2 h215 0x7
gui ptimers:add, Text, x322 y0 w2 h108 0x7
gui ptimers:add, Text, x386 y0 w2 h108 0x7
gui ptimers:add, Text, x259 y36 w128 h2 0x7
gui ptimers:add, Text, x259 y72 w241 h2 0x7
gui ptimers:add, Text, x0 y108 w499 h2 0x7
gui ptimers:add, Text, x387 y86 w113 h2 0x7
gui ptimers:add, Text,x390 y90 +left +BackgroundTrans,Transparency
Gui ptimers:Add, Text, x469 y90 w29 h14 +Center
Gui ptimers:Add, updown, Range0-70 vtimerGuiTransparency gsetTimerGuiTransparency, %TimerGuiTransparency%
Gui, ptimers:Add, Button, x1 y76 w42 h15 hwndhReady1 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, xp+86 y76 wp h15 hwndhReady2 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, xp+86 y76 wp h15 hwndhReady3 gba_resetPlanterTimer, Ready
Gui, ptimers:Add, Button, x43 y76 wp h15 hwndhClear1 gba_setPlanterData, Add
Gui, ptimers:Add, Button, xp+86 y76 wp h15 hwndhClear2 gba_setPlanterData, Add
Gui, ptimers:Add, Button, xp+86 y76 wp h15 hwndhClear3 gba_setPlanterData, Add
Gui, ptimers:Add, Button, x1 y92 wp h15 hwndhSubHour1 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, xp+86 y92 wp h15 hwndhSubHour2 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, xp+86 y92 wp h15 hwndhSubHour3 gba_setPlanterTimer, -1HR
Gui, ptimers:Add, Button, x43 y92 wp h15 hwndhAddHour1 gba_setPlanterTimer, +1HR
Gui, ptimers:Add, Button, xp+86 y92 wp h15 hwndhAddHour2 gba_setPlanterTimer, +1HR
Gui, ptimers:Add, Button, xp+86 y92 wp h15 hwndhAddHour3 gba_setPlanterTimer, +1HR

;BlenderStuff
Gui, ptimers:Add, Button, x1 y184 w42 h15 hwndhBlenderReady1 gba_resetBlenderTimer, Ready
Gui, ptimers:Add, Button, x87 y184 w42 h15 hwndhBlenderReady2 gba_resetBlenderTimer, Ready
Gui, ptimers:Add, Button, x173 y184 w42 h15 hwndhBlenderReady3 gba_resetBlenderTimer, Ready
gui ptimers:add, picture,x24 y140 h40 w40 vvBlenderItem1 hwndhBlenderItem1Picture +BackgroundTrans +0xE
gui ptimers:add, picture,x110 y140 h40 w40 vvBlenderItem2 hwndhBlenderItem2Picture +BackgroundTrans +0xE
gui ptimers:add, picture,x195 y140 h40 w40 vvBlenderItem3 hwndhBlenderItem3Picture +BackgroundTrans +0xE
gui ptimers:add, text,x2 y110 w82 vb1timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x88 y110 w82 vb2timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x174 y110 w82 vb3timer +center +BackgroundTrans,h m s
gui ptimers:font, s7
gui ptimers:add, text, x4 y123 w80 vBlenderTextAmount1 +center +BackgroundTrans,
gui ptimers:add, text, x89 y123 w80 vBlenderTextAmount2 +center +BackgroundTrans,
gui ptimers:add, text, x175 y123 w80 vBlenderTextAmount3 +center +BackgroundTrans,
gui ptimers:font, s8
Gui, ptimers:Add, Button, x43 y184 w42 h15 hwndhBlenderClear1 gba_setBlenderData, Add
Gui, ptimers:Add, Button, x129 y184 w42 h15 hwndhBlenderClear2 gba_setBlenderData, Add
Gui, ptimers:Add, Button, x215 y184 w42 h15 hwndhBlenderClear3 gba_setBlenderData, Add
Gui, ptimers:Add, Button, x17 y200 w25 h15 hwndhSubBlenderAmount1 gba_setBlenderAmount, -1
Gui, ptimers:Add, Button, x103 y200 w25 h15 hwndhSubBlenderAmount2 gba_setBlenderAmount, -1
Gui, ptimers:Add, Button, x189 y200 w25 h15 hwndhSubBlenderAmount3 gba_setBlenderAmount, -1
Gui, ptimers:Add, Button, x44 y200 w25 h15 hwndhAddBlenderAmount1 gba_setBlenderAmount, +1
Gui, ptimers:Add, Button, x130 y200 w25 h15 hwndhAddBlenderAmount2 gba_setBlenderAmount, +1
Gui, ptimers:Add, Button, x216 y200 w25 h15 hwndhAddBlenderAmount3 gba_setBlenderAmount, +1
;Blender Over and Shrine Start
Gui, ptimers:Add, Button, x279 y184 w42 h15 hwndhShrineReady1 gba_resetShrineTimer, Ready
Gui, ptimers:Add, Button, x394 y184 w42 h15 hwndhShrineReady2 gba_resetShrineTimer, Ready
gui ptimers:add, picture,x302 y140 h40 w40 vvShrineitem1 hwndhShrineItem1Picture +BackgroundTrans +0xE
gui ptimers:add, picture,x416 y140 h40 w40 vvShrineitem2 hwndhShrineItem2Picture +BackgroundTrans +0xE
gui ptimers:add, text,x280 y110 w82 vs1timer +center +BackgroundTrans,h m s
gui ptimers:add, text,x395 y110 w82 vs2timer +center +BackgroundTrans,h m s
gui ptimers:font, s7
gui ptimers:add, text, x282 y123 w80 vShrineTextAmount1 +center +BackgroundTrans,
gui ptimers:add, text, x396 y123 w80 vShrineTextAmount2 +center +BackgroundTrans,
gui ptimers:font, s8
Gui, ptimers:Add, Button, x321 y184 w42 h15 hwndhShrineClear1 gba_setShrineData, Add
Gui, ptimers:Add, Button, x435 y184 w42 h15 hwndhShrineClear2 gba_setShrineData, Add
Gui, ptimers:Add, Button, x295 y200 w25 h15 hwndhSubShrineAmount1 gba_setShrineAmount, -1
Gui, ptimers:Add, Button, x409 y200 w25 h15 hwndhSubShrineAmount2 gba_setShrineAmount, -1
Gui, ptimers:Add, Button, x322 y200 w25 h15 hwndhAddShrineAmount1 gba_setShrineAmount, +1
Gui, ptimers:Add, Button, x436 y200 w25 h15 hwndhAddShrineAmount2 gba_setShrineAmount, +1


gui ptimers:add, text,x388 y73 w112 +center +BackgroundTrans vdayOrNight,Day Detected
gui, ptimers:add, text,x391 y2 w110 h60 vstatus +center +BackgroundTrans,Status:
gui, ptimers:add, text,x392 y13 w104 h56 vpstatus +left +BackgroundTrans,unknown
	
;msgbox x=%TimerX% y=%TimerY%
gui ptimers:show, x%TimerX% y%TimerY% w500 h218 NoActivate,Timers Revision 4.0
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

        IniRead, MPlanterHold%i%, Settings/nm_config.ini, Planters, MPlanterHold%i%
        IniRead, MPlanterSmoking%i%, Settings/nm_config.ini, Planters, MPlanterSmoking%i%
        IniRead, PlanterMode, Settings/nm_config.ini, Gui, PlanterMode
        p%i%timer := PlanterHarvestTime%i%-nowUnix(), VarSetCapacity(p%i%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",p%i%timer*10000000,"wstr",(p%i%timer > 360000) ? "'No Planter'" : (p%i%timer > 0) ? (((p%i%timer >= 3600) ? "h'h' m" : "") . ((p%i%timer >= 60) ? "m'm' s" : "") . "s's'") : ((MPlanterSmoking%i%) && (PlanterMode = 1)) ? "'Smoking'" : ((MPlanterHold%i%) && (PlanterMode = 1)) ? "'Holding'" : "'Ready'","str",p%i%timerstring,"int",256)
        GuiControl,ptimers:-Redraw, p%i%timer
        GuiControl,ptimers:,p%i%timer,% p%i%timerstring
        GuiControl,ptimers:+Redraw, p%i%timer
    }
    Loop, 3 {
        i := A_Index

        for k,v in ["Item","Index","Amount","Time","Count"]
            IniRead, Blender%v%%i%, settings\nm_config.ini, Blender, Blender%v%%i%

        if (BlenderItem%i% != LastBlenderItem%i%)
        {
            SetImage(hBlenderItem%i%Picture, hBitmapsSB[BlenderItem%i%])
            LastBlenderItem%i% := BlenderItem%i%
        }

        GuiControl, -Redraw, % hBlenderClear%i%
        GuiControl,, % hBlenderClear%i%, % ((BlenderItem%i% = "None" || BlenderItem%i% = "") ? "Add" : "Clear")
        GuiControl, +Redraw, % hBlenderClear%i%
        
        b%i%timer := BlenderTime%i%-nowUnix(), VarSetCapacity(b%i%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",b%i%timer*10000000,"wstr",(BlenderItem%i% = "None") ? "'No Item'" : (b%i%timer > 0) ? (((b%i%timer >= 3600) ? "h'h' m" : "") . ((b%i%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Ready'","str",b%i%timerstring,"int",256)

        GuiControl,ptimers:-Redraw, b%i%timer
        GuiControl,ptimers:,b%i%timer,% b%i%timerstring
        GuiControl,ptimers:+Redraw, b%i%timer
    }

    IniRead, BlenderRot, settings\nm_config.ini, blender, BlenderRot
    IniRead, LastBlenderRot, settings\nm_config.ini, Blender, LastBlenderRot
    IniRead, TimerInterval, settings\nm_config.ini, blender, TimerInterval

    Test := BlenderAmount%LastBlenderRot% - Ceil((BlenderTime%LastBlenderRot% - NowUnix()) / 300)

    if (Test <= BlenderAmount%LastBlenderRot% && Test >= 0) {
        BlenderCount%LastBlenderRot% := Test
        IniWrite, %Test%, settings\nm_config.ini, blender, BlenderCount%LastBlenderRot%
    }

    if (BlenderItem%LastBlenderRot% != "None" && CheckForItem > 1 && LastBlenderRot = BlenderRot)
        IniWrite, 0, settings\nm_config.ini, blender, BlenderCount%LastBlenderRot%
    else if (BlenderItem%LastBlenderRot% = "None" || BlenderItem%LastBlenderRot% = "")
        IniWrite, 0, settings\nm_config.ini, blender, BlenderCount%LastBlenderRot%

    loop, 3 { 
        GuiControl,ptimers:-Redraw, BlenderTextAmount%A_Index% 
        GuiControl, pTimers:, BlenderTextAmount%A_Index%, % "(" BlenderCount%A_index% "/" BlenderAmount%A_Index% ") [" ((BlenderIndex%A_Index% = "Infinite") ? "∞" : BlenderIndex%A_Index%) "]" ; Update BlenderCount
        GuiControl,ptimers:+Redraw, BlenderTextAmount%A_Index%
    }
    Loop, 2 {
        i := A_Index

        for k,v in ["Item","Index","Amount"]
            IniRead, Shrine%v%%i%, settings\nm_config.ini, Shrine, Shrine%v%%i%
        Iniread, LastShrine, settings\nm_config.ini, Shrine, LastShrine

        if (ShrineItem%i% != LastShrineItem%i%)
        {
            SetImage(hShrineItem%i%Picture, hBitmapsSB[ShrineItem%i%])
            LastShrineItem%i% := ShrineItem%i%
        }

        GuiControl, -Redraw, % hShrineClear%i%
        GuiControl,, % hShrineClear%i%, % ((ShrineItem%i% = "None") ? "Add" : "Clear")
        GuiControl, +Redraw, % hShrineClear%i%

        LastShrine1 := LastShrine + 3600, LastShrine2 := LastShrine1 + 3600, s%i%timer := LastShrine%i%-nowUnix(), VarSetCapacity(s%i%timerstring,256), DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",s%i%timer*10000000,"wstr",(ShrineItem%i% = "None") ? "'No Item'" : (s%i%timer > 0) ? (((s%i%timer >= 3600) ? "h'h' m" : "") . ((s%i%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Ready'","str",s%i%timerstring,"int",256)

        GuiControl,ptimers:-Redraw, s%i%timer
        GuiControl,ptimers:,s%i%timer,% s%i%timerstring
        GuiControl,ptimers:+Redraw, s%i%timer

        GuiControl,ptimers:-Redraw, ShrineTextAmount%A_Index%
        GuiControl, pTimers:, ShrineTextAmount%A_Index%, % "(" ShrineAmount%A_Index% ") [" ((ShrineIndex%A_Index% = "Infinite") ? "∞" : ShrineIndex%A_Index%) "]" ; Update Shrine amount to inf symbol
        GuiControl,ptimers:+Redraw, ShrineTextAmount%A_Index%
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
				IniWrite, 0, settings\nm_config.ini, Planters, MPlanterHold%A_Index%
				IniWrite, 0, settings\nm_config.ini, Planters, MPlanterRelease%A_Index%
				IniWrite, 0, settings\nm_config.ini, Planters, MPlanterSmoking%A_Index%
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
	IniWrite, 0, settings\nm_config.ini, Planters, MPlanterHold%addindex%
	IniWrite, 0, settings\nm_config.ini, Planters, MPlanterRelease%addindex%
	IniWrite, 0, settings\nm_config.ini, Planters, MPlanterSmoking%addindex%
}

ba_setBlenderAmount(hCtrl){
    global hSubBlenderAmount1, hSubBlenderAmount2, hSubBlenderAmount3, hAddBlenderAmount1, hAddBlenderAmount2, hAddBlenderAmount3, BlenderAmount1, BlenderAmount2, BlenderAmount3, BlenderItem1, BlenderItem2, BlenderItem3, LastBlenderRot
    Loop, 3 {
        i := A_Index
        for k,v in ["Sub","Add"] {
            if (hCtrl = h%v%BlenderAmount%i%) {
                if (BlenderItem%i% != "None") {
                    (k = 1 && BlenderAmount%i% > 1) ? BlenderAmount%i%-- : (k = 2) ? BlenderAmount%i%++ : BlenderAmount%i%
                    GuiControl, pTimers:, BlenderTextAmount%i%, % "(" BlenderCount%i% "/" BlenderAmount%i% ") [" ((BlenderIndex%i% = "Infinite") ? "∞" : BlenderIndex%i%) "]"
                    IniWrite, % BlenderAmount%i%, settings\nm_config.ini, Blender, BlenderAmount%i%
                    if WinExist("natro_macro ahk_class AutoHotkey")
                        PostMessage, 0x5552, 232+i, % BlenderAmount%i% ; BlenderAmount
                    If (LastBlenderRot = i) {
                        TimerInterval := BlenderAmount%LastBlenderRot% * 300
                        IniWrite, %TimerInterval%, settings\nm_config.ini, Blender, TimerInterval
                        if WinExist("natro_macro ahk_class AutoHotkey")
                            PostMessage, 0x5552, 237, %TimerInterval% ; TimerInterval
                    }
                }
                break
            }
        }
    }
}
ba_resetBlenderTimer(hCtrl){
    global hBlenderReady1, hBlenderReady2, hBlenderReady3, BlenderItem1, BlenderItem2, BlenderItem3
    Loop, 3 {
        if (hCtrl = hBlenderReady%A_Index%) {
            if (BlenderItem%A_Index% != "None") {
                IniWrite, 0, settings\nm_config.ini, Blender, BlenderCount%A_Index%
                Iniwrite, 0, settings\nm_config.ini, Blender, BlenderTime%A_Index%
                IniWrite, %A_Index%, settings\nm_config.ini, Blender, BlenderRot
                IniWrite, 1, settings\nm_config.ini, Blender, BlenderEnd
            }
            break
        }
    }
}
ba_setBlenderData(hCtrl){
    global hBlenderClear1, hBlenderClear2, hBlenderClear3
    Loop, 3 {
        if (hCtrl = hBlenderClear%A_Index%) {
            IniRead, BlenderItem%A_Index%, settings\nm_config.ini, Blender, BlenderItem%A_Index%
            if (BlenderItem%A_Index% = "None") 
                ba_addBlenderData(A_Index)
            else {
                SetImage(hBlenderItem%A_Index%Picture, hBitmapsSB["None"])
                IniWrite, None, settings\nm_config.ini, Blender, BlenderItem%A_Index%
                IniWrite, 0, settings\nm_config.ini, Blender, BlenderAmount%A_Index%
                IniWrite, 0, settings\nm_config.ini, Blender, BlenderCount%A_Index%
                Iniwrite, 1, settings\nm_config.ini, Blender, BlenderIndex%A_Index%
                Iniwrite, 0, settings\nm_config.ini, Blender, BlenderTime%A_Index%
                IniWrite, %A_index%, settings\nm_config.ini, Blender, BlenderRot
                if WinExist("natro_macro ahk_class AutoHotkey") {
                    PostMessage, 0x5552, 232+A_Index, 0 ; BlenderAmount
                    PostMessage, 0x5552, 238+A_Index, 0 ; BlenderTime
                    PostMessage, 0x5553, 58+A_Index, 9 ; BlenderIndex
                    PostMessage, 0x5553, 61+A_Index, 9 ; BlenderItem
                }
            }
            break
        }
    }
}
ba_addBlenderData(GBlenderIndex){
    global
    BlenderaddIndex := GBlenderIndex, AddBlenderItem := "RedExtract"
    Iniread, BlenderIndex%A_Index%, settings\nm_config.ini, Blender, BlenderIndex%BlenderaddIndex%
    Gui addp:Destroy
    Gui addp:+AlwaysOnTop +Border -Resize +hwndhAdd
    Gui addp:Font, s8 cDefault Norm, Tahoma
    Gui addp:Add, Picture, x15 y10 w40 h40 hwndhAddBlenderItem +0xE
    SetImage(hAddBlenderItem, hBitmapsSB["RedExtract"])
    Gui addp:Add, Button, x15 y56 w16 h16 hwndhfleft gba_AddBlenderItemButton, <
    Gui addp:Add, Button, x39 y56 w16 h16 hwndhfright gba_AddBlenderItemButton, >
    Gui addp:Add, Text, x94 y4, Repeat:
    Gui addp:Add, checkbox, x85 yp+16 vBAddindexOption gba_BlenderIndexOption, Infinite
    Gui addp:Add, Text, x87 yp+16 w41 h16 +Center +0x200
    Gui addp:Add, UpDown, vBAddindex Range1-999, 1
    Gui addp:Add, Text, x72 y60, Amount:
    Gui addp:Add, Text, x+0 yp-1 w41 h16 +Center +0x200
    Gui addp:Add, UpDown, vBAddamount Range1-999, 1
    Gui addp:Font, w1000
    Gui addp:Add, Button, x40 y80 w80 h16 +Center gba_AddBlenderItem, Add to Slot %BlenderaddIndex%
    VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
    x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
    Gui addp:Show, % "x" (x - 124 + BlenderaddIndex * 86) " y" (y + 244) " w160", Add Item
}
ba_BlenderIndexOption(){
    GuiControlGet, BAddindexOption, addp:
    if (BAddindexOption)
		GuiControl, addp:disable, BAddindex
	else
		GuiControl, addp:enable, BAddindex
}
ba_AddBlenderItemButton(hCtrl){
    global hAdd, hfleft, hfright, hAddBlenderItem, AddBlenderItem, hBitmapsSB
    static items :=["RedExtract", "BlueExtract", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms", "Glitter", "StarJelly", "PurplePotion", "SoftWax", "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "SuperSmoothie", "Turpentine"], i := 0, h := 0
    if (h != hAdd)
        i := 0, h := hAdd
    i := Mod(items.Length() + i + ((hCtrl = hfleft) ? -1 : 1), items.Length()), AddBlenderItem := items[i+1]
    SetImage(hAddBlenderItem, hBitmapsSB[AddBlenderItem])
}
ba_AddBlenderItem(){
    global BlenderaddIndex, AddBlenderItem, BAddIndex, BAddindexOption, BAddamount
    Gui addp:Submit
    Gui addp:Destroy
    IniWrite, %BAddamount%, settings\nm_config.ini, Blender, BlenderAmount%BlenderaddIndex%
    IniWrite, %AddBlenderItem%, settings\nm_config.ini, Blender, BlenderItem%BlenderaddIndex%
    IniWrite, % (BAddindexOption = 1) ? "Infinite" : BAddindex, settings\nm_config.ini, Blender, BlenderIndex%BlenderaddIndex%
    if WinExist("natro_macro ahk_class AutoHotkey") {
        PostMessage, 0x5552, 232+BlenderaddIndex, BAddamount ; BlenderAmount
        PostMessage, 0x5553, 58+BlenderaddIndex, 9 ; BlenderIndex
        PostMessage, 0x5553, 61+BlenderaddIndex, 9 ; BlenderItem
    }
}

ba_setShrineAmount(hCtrl){
    global hSubShrineAmount1, hSubShrineAmount2, hAddShrineAmount1, hAddshrineAmount2, ShrineAmount1, ShrineAmount2, ShrineItem1, ShrineItem2
    Loop, 2 {
        i := A_Index
        for k,v in ["Sub","Add"] {
            if (hCtrl = h%v%ShrineAmount%i%) {
                if (ShrineItem%i% != "None") {
                    (k = 1 && ShrineAmount%i% > 1) ? ShrineAmount%i%-- : (k = 2) ? ShrineAmount%i%++ : ShrineAmount%i%
                    GuiControl, pTimers:, ShrineTextAmount%i%, % "(" ShrineAmount%i% ") [" ((ShrineIndex%i% = "Infinite") ? "∞" : ShrineIndex%i%) "]"
                    IniWrite, % ShrineAmount%i%, settings\nm_config.ini, Shrine, ShrineAmount%i%
                    if WinExist("natro_macro ahk_class AutoHotkey")
                        PostMessage, 0x5552, 230+i, % ShrineAmount%i% ; ShrineAmount
                }
                break
            }
        }
    }
}
ba_resetShrineTimer(hCtrl){
    global hShrineReady1, hShrineReady2, ShrineItem1, ShrineItem2
    Loop, 2 {
        if (hCtrl = hShrineReady%A_Index%) {
            if (ShrineItem%A_Index% != "None") {
                Iniwrite, 0, settings\nm_config.ini, Shrine, LastShrine
                IniWrite, %A_Index%, settings\nm_config.ini, Shrine, ShrineRot
            }
            break
        }
    }
}
ba_setShrineData(hCtrl){
    global hShrineClear1, hShrineClear2
    Loop, 2 {
        if (hCtrl = hShrineClear%A_Index%) {
            IniRead, ShrineItem%A_Index%, settings\nm_config.ini, Shrine, ShrineItem%A_Index%
            if (ShrineItem%A_Index% = "None") 
                ba_addShrineData(A_Index)
            else {
                SetImage(hShrineItem%A_Index%Picture, hBitmapsSB["None"])
                IniWrite, None, settings\nm_config.ini, Shrine, ShrineItem%A_Index%
                IniWrite, 0, settings\nm_config.ini, Shrine, ShrineAmount%A_Index%
                Iniwrite, 1, settings\nm_config.ini, Shrine, ShrineIndex%A_Index%
                Iniwrite, 0, settings\nm_config.ini, Shrine, LastShrine
                if WinExist("natro_macro ahk_class AutoHotkey") {
                    PostMessage, 0x5552, 230+A_Index, 0 ; ShrineAmount
                    PostMessage, 0x5553, 56+A_Index, 10 ; ShrineIndex
                    PostMessage, 0x5553, 54+A_Index, 10 ; ShrineItem
                }
            }
            break
        }
    }
}
ba_addShrineData(GShrineIndex){
    global
    ShrineaddIndex := GShrineIndex, AddShrineItem := "RedExtract"
    Iniread, ShrineIndex%A_Index%, settings\nm_config.ini, Shrine, ShrineIndex%ShrineaddIndex%
    Gui addp:Destroy
    Gui addp:+AlwaysOnTop +Border -Resize +hwndhAdd
    Gui addp:Font, s8 cDefault Norm, Tahoma
    Gui addp:Add, Picture, x15 y10 w40 h40 hwndhAddShrineItem +0xE
    SetImage(hAddShrineItem, hBitmapsSB["RedExtract"])
    Gui addp:Add, Button, x15 y56 w16 h16 hwndhfleft gba_AddShrineItemButton, <
    Gui addp:Add, Button, x39 y56 w16 h16 hwndhfright gba_AddShrineItemButton, >
    Gui addp:Add, Text, x94 y4, Repeat:
    Gui addp:Add, checkbox, x85 yp+16 vSAddindexOption gba_ShrineIndexOption, Infinite
    Gui addp:Add, Text, x87 yp+16 w41 h16 +Center +0x200
    Gui addp:Add, UpDown, vSAddindex Range1-999, 1
    Gui addp:Add, Text, x72 y60, Amount:
    Gui addp:Add, Text, x+0 yp-1 w41 h16 +Center +0x200
    Gui addp:Add, UpDown, vSAddamount Range1-999, 1
    Gui addp:Font, w1000
    Gui addp:Add, Button, x40 y80 w80 h16 +Center gba_AddShrineItem, Add to Slot %ShrineaddIndex%
    VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
    x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
    Gui addp:Show, % "x" (x + 175 + ShrineaddIndex * 86) " y" (y + 244) " w160", Add Item
}
ba_ShrineIndexOption(){
    GuiControlGet, SAddindexOption, addp:
    if (SAddindexOption)
		GuiControl, addp:disable, SAddindex
	else
		GuiControl, addp:enable, SAddindex
}
ba_AddShrineItemButton(hCtrl){
    global hAdd, hfleft, hfright, hAddShrineItem, AddShrineItem, hBitmapsSB
    static items :=  ["RedExtract", "BlueExtract", "BlueBerry", "Pineapple", "StrawBerry", "Sunflower", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms", "Glitter", "StarJelly", "PurplePotion", "AntPass", "CloudVial", "SoftWax", "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "Turpentine"], i := 0, h := 0
    if (h != hAdd)
        i := 0, h := hAdd
    i := Mod(items.Length() + i + ((hCtrl = hfleft) ? -1 : 1), items.Length()), AddShrineItem := items[i+1]
    SetImage(hAddShrineItem, hBitmapsSB[AddShrineItem])
}
ba_AddShrineItem(){
    global ShrineaddIndex, AddShrineItem, SAddindex, SAddindexOption, SAddamount
    Gui addp:Submit
    Gui addp:Destroy
    IniWrite, %SAddamount%, settings\nm_config.ini, Shrine, ShrineAmount%ShrineaddIndex%
    IniWrite, %AddShrineItem%, settings\nm_config.ini, Shrine, ShrineItem%ShrineaddIndex%
    IniWrite, % (SAddindexOption = 1) ? "Infinite" : SAddindex, settings\nm_config.ini, Shrine, ShrineIndex%ShrineaddIndex%
    if WinExist("natro_macro ahk_class AutoHotkey") {
        PostMessage, 0x5552, 230+ShrineaddIndex, SAddamount ; ShrineAmount
        PostMessage, 0x5553, 56+ShrineaddIndex, 10 ; ShrineIndex
        PostMessage, 0x5553, 54+ShrineaddIndex, 10 ; ShrineItem
    }
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
    Gdip_Shutdown(pToken)
    ExitApp
}

PtimersGuiClose:
ba_timersExit()
return
PtimersGuiSize:
ba_saveTimerGui()
return
