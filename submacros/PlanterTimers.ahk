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

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"

OnError (e, mode) => (mode = "Return") ? -1 : 0
DetectHiddenWindows 1
SetWorkingDir A_ScriptDir "\.."

; check for the correct AHK version before starting
if (A_PtrSize != 4)
{
    SplitPath(A_AhkPath, , &ahkDirectory)

    if (!FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe"))
        MsgBox "Couldn't find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
    else
        ReloadScript(ahkpath)

    ExitApp
}
ReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run '"' ahkpath '" /restart ' params
}

; GUI skinning: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
GuiTheme := IniRead("settings\nm_config.ini", "Settings", "GuiTheme", "MacLion3")
DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str",A_WorkingDir "\nm_image_assets\Styles\USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr",A_WorkingDir "\nm_image_assets\styles\" GuiTheme ".msstyles")

; GUI position
TimerX := IniRead("settings\nm_config.ini", "Planters", "TimerX", 0)
TimerY := IniRead("settings\nm_config.ini", "Planters", "TimerY", 0)
TimerGuiTransparency := IniRead("settings\nm_config.ini", "Planters", "TimerGuiTransparency", 0)
if (TimerX && TimerY)
{
	Loop (MonitorCount := MonitorGetCount())
	{
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(TimerX>MonLeft && TimerX<MonRight && TimerY>MonTop && TimerY<MonBottom)
			break
		if(A_Index=MonitorCount)
			TimerX:=TimerY:=0
	}
}
else
	TimerX:=TimerY:=0

pToken := Gdip_Startup()
OnExit(ba_timersExit)

;Blender/shrine images
hBitmapsSBT := Map()
#Include "%A_ScriptDir%\..\nm_image_assets\gui\blendershrine_bitmaps.ahk"

(hBitmapsSB := Map()).CaseSense := false
for x,y in hBitmapsSBT
	hBitmapsSB[x] := Gdip_CreateHBITMAPFromBitmap(y), Gdip_DisposeImage(y)
hBitmapsSB["None"] := 0

;GUI
TimersGui := Gui("+AlwaysOnTop +border +minsize50x30 +E0x08040000 +lastfound", "Timers Revision 4.0")
setTimerGuiTransparency()
TimersGui.OnEvent("Close", (*) => ExitApp())
TimersGui.SetFont("s8 cDefault w1000", "Tahoma")
TimersGui.Add("picture", "x2 y35 h40 w40 vvplanterfield1 +BackgroundTrans")
TimersGui.Add("picture", "x88 y35 h40 w40 vvplanterfield2 +BackgroundTrans")
TimersGui.Add("picture", "x174 y35 h40 w40 vvplanterfield3 +BackgroundTrans")
TimersGui.Add("picture", "x44 y35 h40 w40 vvplantername1 +BackgroundTrans")
TimersGui.Add("picture", "x130 y35 h40 w40 vvplantername2 +BackgroundTrans")
TimersGui.Add("picture", "x216 y35 h40 w40 vvplantername3 +BackgroundTrans")
TimersGui.Add("picture", "x34 y16 h18 w18 vvplanternectar1 +BackgroundTrans")
TimersGui.Add("picture", "x120 y16 h18 w18 vvplanternectar2 +BackgroundTrans")
TimersGui.Add("picture", "x206 y16 h18 w18 vvplanternectar3 +BackgroundTrans")
TimersGui.Add("text", "x2 y2 w82 vp1timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x88 y2 w82 vp2timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x174 y2 w82 vp3timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x258 y4 w66 +center +BackgroundTrans", "Next King")
TimersGui.Add("text", "x258 y40 w66 +center +BackgroundTrans", "Next Bear")
TimersGui.Add("text", "x258 y76 w66 +center +BackgroundTrans", "Next Wolf")
TimersGui.Add("text", "x262 y20 w58 vpkingTimer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x262 y56 w58 vptunnelTimer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x262 y92 w58 vpwolfTimer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x322 y4 w66 +center +BackgroundTrans", "Per Hour")
TimersGui.Add("text", "x322 y40 w66 +center +BackgroundTrans", "Session")
TimersGui.Add("text", "x322 y76 w66 +center +BackgroundTrans", "Reset")
TimersGui.Add("text", "x326 y20 w58 vphoneyaverage +center +BackgroundTrans", 0)
TimersGui.Add("text", "x326 y56 w58 vpsessiontotalhoney +center +BackgroundTrans", 0)
TimersGui.Add("text", "x326 y92 w58 vpserverTimer +center +BackgroundTrans", "N/A")
TimersGui.Add("Text", "x0 y0 w500 h2 0x7")
TimersGui.Add("Text", "x0 y216 w500 h2 0x7")
TimersGui.Add("Text", "x258 y0 w2 h215 0x7")
TimersGui.Add("Text", "x322 y0 w2 h108 0x7")
TimersGui.Add("Text", "x386 y0 w2 h108 0x7")
TimersGui.Add("Text", "x259 y36 w128 h2 0x7")
TimersGui.Add("Text", "x259 y72 w241 h2 0x7")
TimersGui.Add("Text", "x0 y108 w499 h2 0x7")
TimersGui.Add("Text", "x387 y86 w113 h2 0x7")
TimersGui.Add("Text", "x390 y90 +left +BackgroundTrans", "Transparency")
TimersGui.Add("Text", "x469 y90 w29 h14 +Center")
TimersGui.Add("updown", "Range0-70 vtimerGuiTransparency", TimerGuiTransparency).OnEvent("Change", setTimerGuiTransparency)
TimersGui.Add("Button", "x1 y76 w42 h15 vReady1", "Ready").OnEvent("Click", ba_resetPlanterTimer)
TimersGui.Add("Button", "xp+86 y76 wp h15 vReady2", "Ready").OnEvent("Click", ba_resetPlanterTimer)
TimersGui.Add("Button", "xp+86 y76 wp h15 vReady3", "Ready").OnEvent("Click", ba_resetPlanterTimer)
TimersGui.Add("Button", "x43 y76 wp h15 vClear1", "Add").OnEvent("Click", ba_setPlanterData)
TimersGui.Add("Button", "xp+86 y76 wp h15 vClear2", "Add").OnEvent("Click", ba_setPlanterData)
TimersGui.Add("Button", "xp+86 y76 wp h15 vClear3", "Add").OnEvent("Click", ba_setPlanterData)
TimersGui.Add("Button", "x1 y92 wp h15 vSubHour1", "-1HR").OnEvent("Click", ba_setPlanterTimer)
TimersGui.Add("Button", "xp+86 y92 wp h15 vSubHour2", "-1HR").OnEvent("Click", ba_setPlanterTimer)
TimersGui.Add("Button", "xp+86 y92 wp h15 vSubHour3", "-1HR").OnEvent("Click", ba_setPlanterTimer)
TimersGui.Add("Button", "x43 y92 wp h15 vAddHour1", "+1HR").OnEvent("Click", ba_setPlanterTimer)
TimersGui.Add("Button", "xp+86 y92 wp h15 vAddHour2", "+1HR").OnEvent("Click", ba_setPlanterTimer)
TimersGui.Add("Button", "xp+86 y92 wp h15 vAddHour3", "+1HR").OnEvent("Click", ba_setPlanterTimer)

;Blender
TimersGui.Add("Button", "x1 y184 w42 h15 vBlenderReady1", "Ready").OnEvent("Click", ba_resetBlenderTimer)
TimersGui.Add("Button", "x87 y184 w42 h15 vBlenderReady2", "Ready").OnEvent("Click", ba_resetBlenderTimer)
TimersGui.Add("Button", "x173 y184 w42 h15 vBlenderReady3", "Ready").OnEvent("Click", ba_resetBlenderTimer)
TimersGui.Add("picture", "x24 y140 h40 w40 vBlenderItem1Picture +BackgroundTrans +0xE")
TimersGui.Add("picture", "x110 y140 h40 w40 vBlenderItem2Picture +BackgroundTrans +0xE")
TimersGui.Add("picture", "x195 y140 h40 w40 vBlenderItem3Picture +BackgroundTrans +0xE")
TimersGui.Add("text", "x2 y110 w82 vb1timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x88 y110 w82 vb2timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x174 y110 w82 vb3timer +center +BackgroundTrans", "h m s")
TimersGui.SetFont("s7")
TimersGui.Add("text", "x4 y123 w80 vBlenderTextAmount1 +center +BackgroundTrans")
TimersGui.Add("text", "x89 y123 w80 vBlenderTextAmount2 +center +BackgroundTrans")
TimersGui.Add("text", "x175 y123 w80 vBlenderTextAmount3 +center +BackgroundTrans")
TimersGui.SetFont("s8")
TimersGui.Add("Button", "x43 y184 w42 h15 vBlenderClear1", "Add").OnEvent("Click", ba_setBlenderData)
TimersGui.Add("Button", "x129 y184 w42 h15 vBlenderClear2", "Add").OnEvent("Click", ba_setBlenderData)
TimersGui.Add("Button", "x215 y184 w42 h15 vBlenderClear3", "Add").OnEvent("Click", ba_setBlenderData)
TimersGui.Add("Button", "x17 y200 w25 h15 vSubBlenderAmount1", "-1").OnEvent("Click", ba_setBlenderAmount)
TimersGui.Add("Button", "x103 y200 w25 h15 vSubBlenderAmount2", "-1").OnEvent("Click", ba_setBlenderAmount)
TimersGui.Add("Button", "x189 y200 w25 h15 vSubBlenderAmount3", "-1").OnEvent("Click", ba_setBlenderAmount)
TimersGui.Add("Button", "x44 y200 w25 h15 vAddBlenderAmount1", "+1").OnEvent("Click", ba_setBlenderAmount)
TimersGui.Add("Button", "x130 y200 w25 h15 vAddBlenderAmount2", "+1").OnEvent("Click", ba_setBlenderAmount)
TimersGui.Add("Button", "x216 y200 w25 h15 vAddBlenderAmount3", "+1").OnEvent("Click", ba_setBlenderAmount)

;Shrine
TimersGui.Add("Button", "x279 y184 w42 h15 vShrineReady1", "Ready").OnEvent("Click", ba_resetShrineTimer)
TimersGui.Add("Button", "x394 y184 w42 h15 vShrineReady2", "Ready").OnEvent("Click", ba_resetShrineTimer)
TimersGui.Add("picture", "x302 y140 h40 w40 vShrineitem1Picture +BackgroundTrans +0xE")
TimersGui.Add("picture", "x416 y140 h40 w40 vShrineitem2Picture +BackgroundTrans +0xE")
TimersGui.Add("text", "x280 y110 w82 vs1timer +center +BackgroundTrans", "h m s")
TimersGui.Add("text", "x395 y110 w82 vs2timer +center +BackgroundTrans", "h m s")
TimersGui.SetFont("s7")
TimersGui.Add("text", "x282 y123 w80 vShrineTextAmount1 +center +BackgroundTrans")
TimersGui.Add("text", "x396 y123 w80 vShrineTextAmount2 +center +BackgroundTrans")
TimersGui.SetFont("s8")
TimersGui.Add("Button", "x321 y184 w42 h15 vShrineClear1", "Add").OnEvent("Click", ba_setShrineData)
TimersGui.Add("Button", "x435 y184 w42 h15 vShrineClear2", "Add").OnEvent("Click", ba_setShrineData)
TimersGui.Add("Button", "x295 y200 w25 h15 vSubShrineAmount1", "-1").OnEvent("Click", ba_setShrineAmount)
TimersGui.Add("Button", "x409 y200 w25 h15 vSubShrineAmount2", "-1").OnEvent("Click", ba_setShrineAmount)
TimersGui.Add("Button", "x322 y200 w25 h15 vAddShrineAmount1", "+1").OnEvent("Click", ba_setShrineAmount)
TimersGui.Add("Button", "x436 y200 w25 h15 vAddShrineAmount2", "+1").OnEvent("Click", ba_setShrineAmount)


TimersGui.Add("text", "x388 y73 w112 +center +BackgroundTrans vdayOrNight", "Day Detected")
TimersGui.Add("text", "x391 y2 w110 h60 vstatus +center +BackgroundTrans", "Status:")
TimersGui.Add("text", "x392 y13 w104 h56 vpstatus +left +BackgroundTrans", "unknown")

TimersGui.Show("x" TimerX " y" TimerY "w490 h208 NoActivate")

global PlanterField1, PlanterField2, PlanterField3
    , PlanterNectar1, PlanterNectar2, PlanterNectar3
    , PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
    , LastPlanterField1, LastPlanterField2, LastPlanterField3
    , LastPlanterName1, LastPlanterName2, LastPlanterName3
    , LastPlanterNectar1, LastPlanterNectar2, LastPlanterNectar3
    , MPlanterHold1, MPlanterHold2, MPlanterHold3
    , MPlanterSmoking1, MPlanterSmoking2, MPlanterSmoking3
    , p1timer, p2timer, p3timer

    , BlenderIndex1, BlenderIndex2, BlenderIndex3
    , BlenderTime1, BlenderTime2, BlenderTime3
    , BlenderCount1, BlenderCount2, BlenderCount3
    , LastBlenderItem1, LastBlenderItem2, LastBlenderItem3
    , b1timer, b2timer, b3timer

    , ShrineIndex1, ShrineIndex2
    , LastShrineItem1, LastShrineItem2
    , s1timer, s2timer

    , LastKing, LastTunnel, LastWolf
    , pkingtimer, ptunneltimer, pwolftimer


Loop {
    Loop 3
    {
        i := A_Index

        for k,v in ["name","field","nectar","harvesttime","estpercent"]
            Planter%v%%i% := IniRead("settings\nm_config.ini", "Planters", "Planter" v i)

        for k,v in ["field","name","nectar"]
        {
            if (!IsSet(LastPlanter%v%%i%) || (Planter%v%%i% != LastPlanter%v%%i%))
            {
                TimersGui["vplanter" v i].Value := (Planter%v%%i% = "None") ? "" : "nm_image_assets\ptimers\" . ((v = "name") ? "planter" : v) . "s\" Planter%v%%i% ".png"
                LastPlanter%v%%i% := Planter%v%%i%
            }
        }

        if (TimersGui["Clear" i].Text != (text := ((PlanterName%i% = "None") ? "Add" : "Clear")))
            TimersGui["Clear" i].Text := text

        MPlanterHold%i% := IniRead("settings/nm_config.ini", "Planters", "MPlanterHold" i)
        MPlanterSmoking%i% := IniRead("settings/nm_config.ini", "Planters", "MPlanterSmoking" i)
        PlanterMode := IniRead("settings/nm_config.ini", "Planters", "PlanterMode")

        TimersGui["p" i "timer"].Text := DurationFromSeconds(p%i%timer := PlanterHarvestTime%i% - nowUnix(), (p%i%timer > 360000) ? "'No Planter'" : (p%i%timer > 0) ? (((p%i%timer >= 3600) ? "h'h' m" : "") . ((p%i%timer >= 60) ? "m'm' s" : "") . "s's'") : ((MPlanterSmoking%i%) && (PlanterMode = 1)) ? "'Smoking'" : ((MPlanterHold%i%) && (PlanterMode = 1)) ? "'Holding'" : "'Ready'")
    }
    Loop 3 {
        i := A_Index

        for k,v in ["Item","Index","Amount","Time","Count"]
            Blender%v%%i% := IniRead("settings\nm_config.ini", "Blender", "Blender" v i)

        if (!IsSet(LastBlenderItem%i%) || (BlenderItem%i% != LastBlenderItem%i%))
        {
            SetImage(TimersGui["BlenderItem" i "Picture"].Hwnd, hBitmapsSB[BlenderItem%i%])
            LastBlenderItem%i% := BlenderItem%i%
        }

        if (TimersGui["BlenderClear" i].Text != (text := ((BlenderItem%i% = "None" || BlenderItem%i% = "") ? "Add" : "Clear")))
            TimersGui["BlenderClear" i].Text := text
        TimersGui["b" i "timer"].Text := DurationFromSeconds(b%i%timer := BlenderTime%i% - nowUnix(), (BlenderItem%i% = "None") ? "'No Item'" : (b%i%timer > 0) ? (((b%i%timer >= 3600) ? "h'h' m" : "") . ((b%i%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Ready'")
    }

    BlenderRot := IniRead("settings\nm_config.ini", "Blender", "BlenderRot")
    LastBlenderRot := IniRead("settings\nm_config.ini", "Blender", "LastBlenderRot")
    TimerInterval := IniRead("settings\nm_config.ini", "Blender", "TimerInterval")

    Test := BlenderAmount%LastBlenderRot% - Ceil((BlenderTime%LastBlenderRot% - NowUnix()) / 300)

    if (Test <= BlenderAmount%LastBlenderRot% && Test >= 0) {
        BlenderCount%LastBlenderRot% := Test
        IniWrite Test, "settings\nm_config.ini", "Blender", "BlenderCount" LastBlenderRot
    }

    if (BlenderItem%LastBlenderRot% != "None" && LastBlenderRot = BlenderRot)
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderCount" LastBlenderRot
    else if (BlenderItem%LastBlenderRot% = "None" || BlenderItem%LastBlenderRot% = "")
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderCount" LastBlenderRot

    Loop 3
        TimersGui["BlenderTextAmount" A_Index].Text := "(" BlenderCount%A_index% "/" BlenderAmount%A_Index% ") [" ((BlenderIndex%A_Index% = "Infinite") ? "∞" : BlenderIndex%A_Index%) "]" ; Update BlenderCount
    Loop 2 {
        i := A_Index

        for k,v in ["Item","Index","Amount"]
            Shrine%v%%i% := IniRead("settings\nm_config.ini", "Shrine", "Shrine" v i)
        LastShrine := IniRead("settings\nm_config.ini", "Shrine", "LastShrine")

        if (!IsSet(LastShrineItem%i%) || (ShrineItem%i% != LastShrineItem%i%))
        {
            SetImage(TimersGui["ShrineItem" i "Picture"].Hwnd, hBitmapsSB[ShrineItem%i%])
            LastShrineItem%i% := ShrineItem%i%
        }

        if (TimersGui["ShrineClear" i].Text != (text := ((ShrineItem%i% = "None") ? "Add" : "Clear")))
            TimersGui["ShrineClear" i].Text := text

        LastShrine1 := LastShrine + 3600, LastShrine2 := LastShrine1 + 3600

        TimersGui["s" i "timer"].Text := DurationFromSeconds(s%i%timer := LastShrine%i% - nowUnix(), (ShrineItem%i% = "None") ? "'No Item'" : (s%i%timer > 0) ? (((s%i%timer >= 3600) ? "h'h' m" : "") . ((s%i%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Ready'")
        TimersGui["ShrineTextAmount" A_Index].Text := "(" ShrineAmount%A_Index% ") [" ((ShrineIndex%A_Index% = "Infinite") ? "∞" : ShrineIndex%A_Index%) "]" ; Update Shrine amount to inf symbol
    }

    MonsterRespawnTime := IniRead("settings\nm_config.ini", "Collect", "MonsterRespawnTime")
    for k,v in ["king","tunnel","wolf"]
    {
        Last%v% := IniRead("settings\nm_config.ini", "Collect", "Last" . ((v = "king") ? "KingBeetle" : (v = "tunnel") ? "TunnelBear" : "BugrunWerewolf"))
        TimersGui["p" v "timer"].Text := DurationFromSeconds(p%v%timer:=Last%v%-(nowUnix()-((v = "king") ? 86400 : (v = "tunnel") ? 172800 : 3600)*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)), (p%v%timer > 360000) ? "'N/A'" : (p%v%timer > 0) ? (((p%v%timer >= 3600) ? "h'h' m" : "") . ((p%v%timer >= 60) ? "m'm' s" : "") . "s's'") : "'Now'")
    }

	ReconnectHour := IniRead("settings\nm_config.ini", "Settings", "ReconnectHour")
	ReconnectMin := IniRead("settings\nm_config.ini", "Settings", "ReconnectMin")
	ReconnectInterval := IniRead("settings\nm_config.ini", "Settings", "ReconnectInterval")
	if (ReconnectHour != "" && ReconnectMin != "" && ReconnectInterval != "")
	{
        UTCHour := Number(FormatTime(A_NowUTC, "hh"))
        UTCMin := Number(FormatTime(A_NowUTC, "mm"))
		pservertimers := []
		Loop 24//ReconnectInterval
		{
			hour := Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24)
			pservertimers.Push(Mod(24-((UTCMin < ReconnectMin) ? 0 : 1)+hour-UTCHour, 24)*3600 + Mod(59+ReconnectMin-UTCMin, 60)*60 + (60 - Mod(A_Sec, 60)))
		}
        TimersGui["pservertimer"].Text := DurationFromSeconds(pservertimer := Min(pservertimers*), (pservertimer > 86400) ? "'N/A'" : ((pservertimer >= 3600) ? "h'h' m" : "") . ((pservertimer >= 60) ? "m'm' s" : "") . "s's'")
	}

	if (Mod(A_Index, 60) = 1)
	{
		TimersGui["phoneyAverage"].Text := IniRead("settings\nm_config.ini", "Status", "HoneyAverage", 0)
		TimersGui["psessionTotalHoney"].Text := IniRead("settings\nm_config.ini", "Status", "SessionTotalHoney", 0)
	}

    TimersGui["dayOrNight"].Text := IniRead("settings\nm_config.ini", "Planters", "dayOrNight") " Detected"
    try TimersGui["pstatus"].Text := ControlGetText("Static4", "Natro ahk_class AutoHotkeyGUI")

	Sleep (1100 - A_MSec)
}

setTimerGuiTransparency(GuiCtrl?, *){
	global TimerGuiTransparency
    if IsSet(GuiCtrl)
        IniWrite TimerGuiTransparency := GuiCtrl.Value, "settings\nm_config.ini", "Planters", "TimerGuiTransparency"
	WinSetTransparent 255-floor(TimerGuiTransparency*2.55), TimersGui
}
ba_resetPlanterTimer(GuiCtrl, *){
    global PlanterName1, PlanterName2, PlanterName3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
    i := SubStr(GuiCtrl.Name, -1)
	PlanterName%i% := IniRead("settings\nm_config.ini", "Planters", "PlanterName" i)
	if (PlanterName%i% != "None") {
		UpdateInt("PlanterHarvestTime" i, nowUnix()-1)
	}
}
ba_setPlanterTimer(GuiCtrl, *){
    global PlanterName1, PlanterName2, PlanterName3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
    i := SubStr(GuiCtrl.Name, -1), c := SubStr(GuiCtrl.Name, 1, 3)
	PlanterName%i% := IniRead("settings\nm_config.ini", "Planters", "PlanterName" i)
	if (PlanterName%i% != "None") {
        PlanterHarvestTime%i% := IniRead("settings\nm_config.ini", "Planters", "PlanterHarvestTime" i)
        UpdateInt("PlanterHarvestTime" i, PlanterHarvestTime%i% := (c = "Sub") ? Max(nowUnix(), Integer(PlanterHarvestTime%i%-3600)) : Max(nowUnix(), Integer(PlanterHarvestTime%i%))+3600)
        UpdateInt("PlanterEstPercent" i, Min(Max((Integer(PlanterHarvestTime%i%) - nowUnix())//864, 0), 100))
	}
}
ba_setPlanterData(GuiCtrl, *){
	global PlanterName1, PlanterName2, PlanterName3
    i := SubStr(GuiCtrl.Name, -1)
    PlanterName%i% := IniRead("settings\nm_config.ini", "Planters", "PlanterName" i)
    if (PlanterName%i% = "None") {
        ba_addPlanterData(i)
    } else {
        UpdateStr("PlanterName" i, "None")
        UpdateStr("PlanterField" i, "None")
        UpdateStr("PlanterNectar" i, "None")
        UpdateStr("PlanterHarvestFull" i, "")
        UpdateInt("PlanterHarvestTime" i, 2147483647)
        UpdateInt("PlanterEstPercent" i, 0)
        UpdateInt("PlanterGlitter" i, 0)
        UpdateInt("PlanterGlitterC" i, 0)
        UpdateInt("MPlanterHold" i, 0)
        UpdateInt("PlanterHarvestNow" i, 0)
        UpdateInt("MPlanterSmoking" i, 0)
    }
}
ba_addPlanterData(PlanterIndex){
	global
	addIndex := PlanterIndex, addField := "Bamboo", addPlanter := "BlueClayPlanter"

    GuiClose(*){
		if (IsSet(AddGui) && IsObject(AddGui))
			AddGui.Destroy(), AddGui := ""
	}
	GuiClose()
    AddGui := Gui("+AlwaysOnTop +Border -Resize", "Add Planter")
    AddGui.OnEvent("Close", GuiClose)
    AddGui.SetFont("s8 cDefault Norm", "Tahoma")
	AddGui.Add("Picture", "x20 y4 w50 h50 vAddField", "nm_image_assets\ptimers\fields\Bamboo.png")
	AddGui.Add("Picture", "x90 y4 w50 h50 vAddPlanter", "nm_image_assets\ptimers\planters\Blueclayplanter.png")
	AddGui.Add("Button", "x22 y58 w18 h18 vfleft", "<").OnEvent("Click", ba_AddFieldButton)
	AddGui.Add("Button", "x50 y58 w18 h18 vfright", ">").OnEvent("Click", ba_AddFieldButton)
	AddGui.Add("Button", "x92 y58 w18 h18 vpleft", "<").OnEvent("Click", ba_AddPlanterButton)
	AddGui.Add("Button", "x120 y58 w18 h18 vpright", ">").OnEvent("Click", ba_AddPlanterButton)
	AddGui.Add("Text", "x6 y80", "Harvest in:")
	AddGui.Add("Text", "x64 y80 w28 h16 +Center", 0)
	AddGui.Add("UpDown", "vAddHours Range0-23")
	AddGui.Add("Text", "x96 y80 w28 h16 +Center", 0)
	AddGui.Add("UpDown", "vAddMins Range0-59")
	AddGui.Add("Text", "x128 y80 w28 h16 +Center", 0)
	AddGui.Add("UpDown", "vAddSecs Range0-59")
	AddGui.Add("Text", "x65 y96 w32 +Center", "Hours")
	AddGui.Add("Text", "x98 y96 w32 +Center", "Mins")
	AddGui.Add("Text", "x128 y96 w32 +Center", "Secs")
	AddGui.SetFont("w1000")
	AddGui.Add("Button", "x40 y114 w80 h16 +Center", "Add to Slot " PlanterIndex).OnEvent("Click", ba_AddPlanter)

	wp := Buffer(44), DllCall("GetWindowPlacement", "UInt", TimersGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
	AddGui.Show("x" (x - 124 + PlanterIndex * 86) " y" (y + 136) " w160")
}
ba_AddFieldButton(GuiCtrl, *){
	static fields := ["Bamboo","Blue Flower","Cactus","Clover","Coconut","Dandelion","Mountain Top","Mushroom","Pepper","Pine Tree","Pineapple","Pumpkin","Rose","Spider","Strawberry","Stump","Sunflower"], i := 0, h := 0
	if (h != AddGui.Hwnd)
		i := 0, h := AddGui.Hwnd
	i := Mod(fields.Length + i + ((GuiCtrl.Name = "fleft") ? -1 : 1), fields.Length)
    global addField := fields[i+1]
    AddGui["AddField"].Value := "*w50 *h50 nm_image_assets\ptimers\fields\" addField ".png"
}
ba_AddPlanterButton(GuiCtrl, *){
	static planters := ["BlueClayPlanter","CandyPlanter","HeatTreatedPlanter","HydroponicPlanter","PaperPlanter","PesticidePlanter","PetalPlanter","PlanterOfPlenty","PlasticPlanter","RedClayPlanter","TackyPlanter","TicketPlanter"], i := 0, h := 0
	if (h != AddGui.Hwnd)
		i := 0, h := AddGui.Hwnd
	i := Mod(planters.Length + i + ((GuiCtrl.Name = "pleft") ? -1 : 1), planters.Length)
    global addPlanter := planters[i+1]
	AddGui["AddPlanter"].Value := "*w50 *h50 nm_image_assets\ptimers\planters\" addPlanter ".png"
}
ba_AddPlanter(GuiCtrl?, *){
    global
	Loop 3
	{
		PlanterName%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterName" A_Index)
		PlanterField%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterField" A_Index)
		if (PlanterField%A_Index% = addField)
		{
			msgbox "This field is already used in Slot " A_Index ". You must clear that slot before adding this entry!", "Error!", 0x40000
			return
		}
		else if (PlanterName%A_Index% = addPlanter)
		{
			msgbox "This planter is already used in Slot " A_Index ". You must clear that slot before adding this entry!", "Error!", 0x40000
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
	local values := AddGui.Submit()
    AddGui.Destroy()
    UpdateStr("PlanterName" addindex, addplanter)
    UpdateStr("PlanterField" addindex, addfield)
    UpdateStr("PlanterNectar" addindex, addnectar)
    UpdateStr("PlanterHarvestFull" addindex, "")
    UpdateInt("PlanterHarvestTime" addindex, nowUnix() + (addharvesttime := values.AddHours*3600+values.AddMins*60+values.AddSecs))
    UpdateInt("PlanterEstPercent" addindex, Min(addharvesttime//864, 100))
    UpdateInt("PlanterGlitter" addindex, 0)
    UpdateInt("PlanterGlitterC" addindex, 0)
    UpdateInt("MPlanterHold" addindex, 0)
    UpdateInt("PlanterHarvestNow" addindex, 0)
    UpdateInt("MPlanterSmoking" addindex, 0)
}

ba_setBlenderAmount(GuiCtrl, *){
    global BlenderAmount1, BlenderAmount2, BlenderAmount3, BlenderItem1, BlenderItem2, BlenderItem3
    i := SubStr(GuiCtrl.Name, -1), c := SubStr(GuiCtrl.Name, 1, 3)
    if (BlenderItem%i% != "None") {
        BlenderAmount%i% += (c = "Sub" && BlenderAmount%i% > 1) ? -1 : (c = "Add") ? 1 : 0
        TimersGui["BlenderTextAmount" i].Text := "(" BlenderCount%i% "/" BlenderAmount%i% ") [" ((BlenderIndex%i% = "Infinite") ? "∞" : BlenderIndex%i%) "]"
        IniWrite BlenderAmount%i%, "settings\nm_config.ini", "Blender", "BlenderAmount" i
        if WinExist("natro_macro ahk_class AutoHotkey")
            PostMessage 0x5552, 232+i, BlenderAmount%i% ; BlenderAmount
        If (LastBlenderRot = i) {
            TimerInterval := BlenderAmount%LastBlenderRot% * 300
            IniWrite TimerInterval, "settings\nm_config.ini", "Blender", "TimerInterval"
            if WinExist("natro_macro ahk_class AutoHotkey")
                PostMessage 0x5552, 237, TimerInterval ; TimerInterval
        }
    }
}
ba_resetBlenderTimer(GuiCtrl, *){
    global BlenderItem1, BlenderItem2, BlenderItem3
    i := SubStr(GuiCtrl.Name, -1)
    if (BlenderItem%i% != "None") {
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderCount" i
        Iniwrite 0, "settings\nm_config.ini", "Blender", "BlenderTime" i
        IniWrite i, "settings\nm_config.ini", "Blender", "BlenderRot"
        IniWrite 1, "settings\nm_config.ini", "Blender", "BlenderEnd"
    }
}
ba_setBlenderData(GuiCtrl, *){
    global BlenderItem1, BlenderItem2, BlenderItem3
    i := SubStr(GuiCtrl.Name, -1)
    BlenderItem%i% := IniRead("settings\nm_config.ini", "Blender", "BlenderItem" i)
    if (BlenderItem%i% = "None")
        ba_addBlenderData(i)
    else {
        SetImage(TimersGui["BlenderItem" i "Picture"].Hwnd, hBitmapsSB["None"])
        IniWrite "None", "settings\nm_config.ini", "Blender", "BlenderItem" i
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderAmount" i
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderCount" i
        IniWrite 1, "settings\nm_config.ini", "Blender", "BlenderIndex" i
        IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderTime" i
        IniWrite i, "settings\nm_config.ini", "Blender", "BlenderRot"
        if WinExist("natro_macro ahk_class AutoHotkey") {
            PostMessage 0x5552, 232+i, 0 ; BlenderAmount
            PostMessage 0x5552, 238+i, 0 ; BlenderTime
            PostMessage 0x5553, 58+i, 8 ; BlenderIndex
            PostMessage 0x5553, 61+i, 8 ; BlenderItem
        }
    }
}
ba_addBlenderData(GBlenderIndex){
    global
    BlenderaddIndex := GBlenderIndex, AddBlenderItem := "RedExtract"

    GuiClose(*){
		if (IsSet(AddGui) && IsObject(AddGui))
			AddGui.Destroy(), AddGui := ""
	}
	GuiClose()
    AddGui := Gui("+AlwaysOnTop +Border -Resize", "Add Item")
    AddGui.OnEvent("Close", GuiClose)
    AddGui.SetFont("s8 cDefault Norm", "Tahoma")
    AddGui.Add("Picture", "x15 y10 w40 h40 vAddBlenderItem +0xE")
    SetImage(AddGui["AddBlenderItem"].Hwnd, hBitmapsSB["RedExtract"])
    AddGui.Add("Button", "x15 y56 w16 h16 vfleft", "<").OnEvent("Click", ba_AddBlenderItemButton)
    AddGui.Add("Button", "x39 y56 w16 h16 vfright", ">").OnEvent("Click", ba_AddBlenderItemButton)
    AddGui.Add("Text", "x94 y4", "Repeat:")
    AddGui.Add("checkbox", "x85 yp+16 vBAddindexOption", "Infinite").OnEvent("Click", ba_BlenderIndexOption)
    AddGui.Add("Text", "x87 yp+16 w41 h16 +Center +0x200")
    AddGui.Add("UpDown", "vBAddindex Range1-999", 1)
    AddGui.Add("Text", "x72 y60", "Amount:")
    AddGui.Add("Text", "x+0 yp-1 w41 h16 +Center +0x200")
    AddGui.Add("UpDown", "vBAddamount Range1-999", 1)
    AddGui.SetFont("w1000")
    AddGui.Add("Button", "x40 y80 w80 h16 +Center", "Add to Slot " BlenderaddIndex).OnEvent("Click", ba_AddBlenderItem)

    wp := Buffer(44), DllCall("GetWindowPlacement", "UInt", TimersGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
    AddGui.Show("x" (x - 124 + BlenderaddIndex * 86) " y" (y + 244) " w160")
}
ba_BlenderIndexOption(GuiCtrl, *){
    AddGui["BAddindex"].Enabled := !(AddGui["BAddindexOption"].Value)
}
ba_AddBlenderItemButton(GuiCtrl, *){
    static items :=["RedExtract", "BlueExtract", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms", "Glitter", "StarJelly", "PurplePotion", "SoftWax", "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "Turpentine"], i := 0, h := 0
    if (h != AddGui.Hwnd)
        i := 0, h := AddGui.Hwnd
    i := Mod(items.Length + i + ((GuiCtrl.Name = "fleft") ? -1 : 1), items.Length)
    global AddBlenderItem := items[i+1]
    SetImage(AddGui["AddBlenderItem"].Hwnd, hBitmapsSB[AddBlenderItem])
}
ba_AddBlenderItem(GuiCtrl?, *){
    local values := AddGui.Submit()
    AddGui.Destroy()
    IniWrite values.BAddamount, "settings\nm_config.ini", "Blender", "BlenderAmount" BlenderaddIndex
    IniWrite AddBlenderItem, "settings\nm_config.ini", "Blender", "BlenderItem" BlenderaddIndex
    IniWrite values.BAddindexOption ? "Infinite" : values.BAddindex, "settings\nm_config.ini", "Blender", "BlenderIndex" BlenderaddIndex
    if WinExist("natro_macro ahk_class AutoHotkey") {
        PostMessage 0x5552, 232+BlenderaddIndex, values.BAddamount ; BlenderAmount
        PostMessage 0x5553, 58+BlenderaddIndex, 8 ; BlenderIndex
        PostMessage 0x5553, 61+BlenderaddIndex, 8 ; BlenderItem
    }
}

ba_setShrineAmount(GuiCtrl, *){
    global ShrineAmount1, ShrineAmount2, ShrineItem1, ShrineItem2
    i := SubStr(GuiCtrl.Name, -1), c := SubStr(GuiCtrl.Name, 1, 3)
    if (ShrineItem%i% != "None") {
        ShrineAmount%i% += (c = "Sub" && ShrineAmount%i% > 1) ? -1 : (c = "Add") ? 1 : 0
        TimersGui["ShrineTextAmount" i].Text := "(" ShrineAmount%i% ") [" ((ShrineIndex%i% = "Infinite") ? "∞" : ShrineIndex%i%) "]"
        IniWrite ShrineAmount%i%, "settings\nm_config.ini", "Shrine", "ShrineAmount" i
        if WinExist("natro_macro ahk_class AutoHotkey")
            PostMessage 0x5552, 230+i, ShrineAmount%i% ; ShrineAmount
    }
}
ba_resetShrineTimer(GuiCtrl, *){
    global ShrineItem1, ShrineItem2
    i := SubStr(GuiCtrl.Name, -1)
    if (ShrineItem%i% != "None") {
        IniWrite 0, "settings\nm_config.ini", "Shrine", "LastShrine"
        IniWrite i, "settings\nm_config.ini", "Shrine", "ShrineRot"
    }
}
ba_setShrineData(GuiCtrl, *){
    global ShrineItem1, ShrineItem2, ShrineItem3
    i := SubStr(GuiCtrl.Name, -1)
    ShrineItem%i% := IniRead("settings\nm_config.ini", "Shrine", "ShrineItem" i)
    if (ShrineItem%i% = "None")
        ba_addShrineData(i)
    else {
        SetImage(TimersGui["ShrineItem" i "Picture"].Hwnd, hBitmapsSB["None"])
        IniWrite "None", "settings\nm_config.ini", "Shrine", "ShrineItem" i
        IniWrite 0, "settings\nm_config.ini", "Shrine", "ShrineAmount" i
        IniWrite 1, "settings\nm_config.ini", "Shrine", "ShrineIndex" i
        IniWrite 0, "settings\nm_config.ini", "Shrine", "LastShrine"
        if WinExist("natro_macro ahk_class AutoHotkey") {
            PostMessage 0x5552, 230+i, 0 ; ShrineAmount
            PostMessage 0x5553, 56+i, 9 ; ShrineIndex
            PostMessage 0x5553, 54+i, 9 ; ShrineItem
        }
    }
}
ba_addShrineData(GShrineIndex){
    global
    ShrineaddIndex := GShrineIndex, AddShrineItem := "RedExtract"

    GuiClose(*){
		if (IsSet(AddGui) && IsObject(AddGui))
			AddGui.Destroy(), AddGui := ""
	}
	GuiClose()
    AddGui := Gui("+AlwaysOnTop +Border -Resize", "Add Item")
    AddGui.OnEvent("Close", GuiClose)
    AddGui.SetFont("s8 cDefault Norm", "Tahoma")
    AddGui.Add("Picture", "x15 y10 w40 h40 vAddShrineItem +0xE")
    SetImage(AddGui["AddShrineItem"].Hwnd, hBitmapsSB["RedExtract"])
    AddGui.Add("Button", "x15 y56 w16 h16 vfleft", "<").OnEvent("Click", ba_AddShrineItemButton)
    AddGui.Add("Button", "x39 y56 w16 h16 vfright", ">").OnEvent("Click", ba_AddShrineItemButton)
    AddGui.Add("Text", "x94 y4", "Repeat:")
    AddGui.Add("checkbox", "x85 yp+16 vSAddindexOption", "Infinite").OnEvent("Click", ba_ShrineIndexOption)
    AddGui.Add("Text", "x87 yp+16 w41 h16 +Center +0x200")
    AddGui.Add("UpDown", "vSAddindex Range1-999", 1)
    AddGui.Add("Text", "x72 y60", "Amount:")
    AddGui.Add("Text", "x+0 yp-1 w41 h16 +Center +0x200")
    AddGui.Add("UpDown", "vSAddamount Range1-999", 1)
    AddGui.SetFont("w1000")
    AddGui.Add("Button", "x40 y80 w80 h16 +Center", "Add to Slot " ShrineaddIndex).OnEvent("Click", ba_AddShrineItem)

    wp := Buffer(44), DllCall("GetWindowPlacement", "UInt", TimersGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
    AddGui.Show("x" (x + 175 + ShrineaddIndex * 86) " y" (y + 244) " w160")
}
ba_ShrineIndexOption(GuiCtrl, *){
    AddGui["SAddindex"].Enabled := !(AddGui["SAddindexOption"].Value)
}
ba_AddShrineItemButton(GuiCtrl, *){
    static items := ["RedExtract", "BlueExtract", "BlueBerry", "Pineapple", "StrawBerry", "Sunflower", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms", "Glitter", "StarJelly", "PurplePotion", "AntPass", "CloudVial", "SoftWax", "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "Turpentine"], i := 0, h := 0
    if (h != AddGui.Hwnd)
        i := 0, h := AddGui.Hwnd
    i := Mod(items.Length + i + ((GuiCtrl.Name = "fleft") ? -1 : 1), items.Length)
    global AddShrineItem := items[i+1]
    SetImage(AddGui["AddShrineItem"].Hwnd, hBitmapsSB[AddShrineItem])
}
ba_AddShrineItem(GuiCtrl?, *){
    local values := AddGui.Submit()
    AddGui.Destroy()
    IniWrite values.SAddamount, "settings\nm_config.ini", "Shrine", "ShrineAmount" ShrineaddIndex
    IniWrite AddShrineItem, "settings\nm_config.ini", "Shrine", "ShrineItem" ShrineaddIndex
    IniWrite values.SAddindexOption ? "Infinite" : values.SAddindex, "settings\nm_config.ini", "Shrine", "ShrineIndex" ShrineaddIndex
    if WinExist("natro_macro ahk_class AutoHotkey") {
        PostMessage 0x5552, 230+ShrineaddIndex, values.SAddamount ; ShrineAmount
        PostMessage 0x5553, 56+ShrineaddIndex, 9 ; ShrineIndex
        PostMessage 0x5553, 54+ShrineaddIndex, 9 ; ShrineItem
    }
}

UpdateStr(var, value)
{
	global
	static enum := Map("PlanterName1", 68
		, "PlanterName2", 69
		, "PlanterName3", 70
		, "PlanterField1", 71
		, "PlanterField2", 72
		, "PlanterField3", 73
		, "PlanterNectar1", 74
		, "PlanterNectar2", 75
		, "PlanterNectar3", 76
		, "PlanterHarvestFull1", 77
		, "PlanterHarvestFull2", 78
		, "PlanterHarvestFull3", 79)

	try %var% := value
	IniWrite value, "settings\nm_config.ini", "Planters", var
	DetectHiddenWindows 1
	if WinExist("natro_macro ahk_class AutoHotkey")
		PostMessage 0x5553, enum[var], 4
}

UpdateInt(var, value)
{
	global
	static enum := Map("MPlanterHold1", 264
		, "MPlanterHold2", 265
		, "MPlanterHold3", 266
		, "MPlanterGatherA", 280
		, "MPlanterGather1", 281
		, "MPlanterGather2", 282
		, "MPlanterGather3", 283
		, "MPlanterSmoking1", 284
		, "MPlanterSmoking2", 285
		, "MPlanterSmoking3", 286
		, "MPuffModeA", 287
		, "MPuffMode1", 288
		, "MPuffMode2", 289
		, "MPuffMode3", 290
		, "PlanterHarvestNow1", 291
		, "PlanterHarvestNow2", 292
		, "PlanterHarvestNow3", 293
		, "PlanterSS1", 294
		, "PlanterSS2", 295
		, "PlanterSS3", 296
		, "PlanterHarvestTime1", 297
		, "PlanterHarvestTime2", 298
		, "PlanterHarvestTime3", 299
		, "PlanterEstPercent1", 300
		, "PlanterEstPercent2", 301
		, "PlanterEstPercent3", 302
		, "PlanterGlitter1", 303
		, "PlanterGlitter2", 304
		, "PlanterGlitter3", 305
		, "PlanterGlitterC1", 306
		, "PlanterGlitterC2", 307
		, "PlanterGlitterC3", 308
		, "PlanterManualCycle1", 309
		, "PlanterManualCycle2", 310
		, "PlanterManualCycle3", 311)

	try %var% := value
	IniWrite value, "settings\nm_config.ini", "Planters", var
	DetectHiddenWindows 1
	if WinExist("natro_macro ahk_class AutoHotkey")
		PostMessage 0x5552, enum[var], value
}

ba_saveTimerGui(){
	global TimerX, TimerY
	wp := Buffer(44)
    DllCall("GetWindowPlacement", "UInt", TimersGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
	if (x > 0)
		IniWrite x, "settings\nm_config.ini", "Planters", "TimerX"
	if (y > 0)
		IniWrite y, "settings\nm_config.ini", "Planters", "TimerY"
}

ba_timersExit(*){
    ba_saveTimerGui()
    DllCall(A_WorkingDir "\nm_image_assets\Styles\USkin.dll\USkinExit")
    try Gdip_Shutdown(pToken)
}
