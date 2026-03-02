/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

#SingleInstance Force
#Requires AutoHotkey v2.0

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"

#Warn VarUnset, Off

SetWorkingDir A_ScriptDir "\.."

; set version number
version := "2.3"

; ▰▰▰▰▰▰▰▰
; INITIAL SETUP
; ▰▰▰▰▰▰▰▰

; set image width and height, in pixels
w := 6000, h := 5800

; prepare graphics and template bitmap
pToken := Gdip_Startup()
pBM := Gdip_CreateBitmap(w, h)
G := Gdip_GraphicsFromImage(pBM)
Gdip_SetSmoothingMode(G, 4)
Gdip_SetInterpolationMode(G, 7)

; IMAGE ASSETS
; store buff icons for drawing
(buff_bitmaps := Map()).CaseSense := 0
(bitmaps := Map()).CaseSense := 0
buff_characters := Map()

#Include "%A_ScriptDir%\..\nm_image_assets\offset\bitmaps.ahk"
#Include "%A_ScriptDir%\..\nm_image_assets\statmonitor\bitmaps.ahk"

; ▰▰▰▰▰▰▰▰▰▰▰▰
; INITIALISE VARIABLES
; ▰▰▰▰▰▰▰▰▰▰▰▰

; OCR TEST
; check that classes needed for OCR function exist and can be created
ocr_enabled := 1
ocr_language := ""
for k,v in Map("Windows.Globalization.Language","{9B0252AC-0C27-44F8-B792-9793FB66C63E}", "Windows.Graphics.Imaging.BitmapDecoder","{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", "Windows.Media.Ocr.OcrEngine","{5BFFA85A-3384-3540-9940-699120D428A8}")
{
	CreateHString(k, &hString)
	GUID := Buffer(16), DllCall("ole32\CLSIDFromString", "WStr", v, "Ptr", GUID)
	result := DllCall("Combase.dll\RoGetActivationFactory", "Ptr", hString, "Ptr", GUID, "PtrP", &pClass:=0)
	DeleteHString(hString)
	if (result != 0)
	{
		ocr_enabled := 0
		break
	}
}
if (ocr_enabled = 1)
{
	list := ocr("ShowAvailableLanguages")
	for lang in ["ko","en-"] ; priority list
	{
		Loop Parse list, "`n", "`r"
		{
			if (InStr(A_LoopField, lang) = 1)
			{
				ocr_language := A_LoopField
				break 2
			}
		}
	}
	if (ocr_language = "")
		if ((ocr_language := SubStr(list, 1, InStr(list, "`n")-1)) = "")
			msgbox "No OCR supporting languages are installed on your system! Please follow the Knowledge Base guide to install a supported language as a secondary language on Windows.", "WARNING!!", 0x1030
}


; HONEY MONITORING
; honey_values format: (A_Min):value
honey_values := Map()

; obtain start honey
start_honey := ocr_enabled ? DetectHoney() : 0

; honey_12h format: (minutes DIV 4):value
honey_12h := Map()
honey_12h[180] := start_honey


; BUFF MONITORING
; buff_values format: buff:{time_coefficient:value}
(buff_values := Map()).CaseSense := 0
for v in ["haste","melody","redboost","blueboost","whiteboost","focus","bombcombo","balloonaura","clock","jbshare","babylove","inspire","bear","pollenmark","honeymark","festivemark","popstar","comforting","motivating","satisfying","refreshing","invigorating","blessing","bloat","guiding","mondo","reindeerfetch","tideblessing"]
	buff_values[v] := Map()

; INFO FROM MAIN SCRIPT
; status_changes format: (A_Min*60+A_Sec+1):status_number (0 = other, 1 = gathering, 2 = converting)
status_changes := Map()

; stats format: number:[string, value]
stats := [["Total Boss Kills",0],["Total Vic Kills",0],["Total Bug Kills",0],["Total Planters",0],["Quests Done",0],["Disconnects",0]]

; backpack_values format: A_Min*60+A_Sec:percent
backpack_values := Map()

; enable receiving of messages
OnMessage(0x5554, SetStatus, 255)
OnMessage(0x5555, IncrementStat, 255)
OnMessage(0x5556, SetAbility, 255)
OnMessage(0x5557, SetBackpack, 255)



; ▰▰▰▰▰▰▰▰
; STARTUP REPORT
; ▰▰▰▰▰▰▰▰


; OBTAIN DATA
; detect OS version
os_version := "cant detect os"
for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_OperatingSystem")
	os_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))

; obtain natro version and other options (if exist)
if ((A_Args.Length > 0) && (natro_version := A_Args[1]))
{
	; read information from settings\nm_config.ini
	Loop 3
		FieldName%A_Index% := IniRead("settings\nm_config.ini", "Gather", "FieldName" A_Index, "N/A")
	HiveSlot := IniRead("settings\nm_config.ini", "Settings", "HiveSlot", "N/A")

	global HotkeyWhile2, HotkeyWhile3, HotkeyWhile4, HotkeyWhile5, HotkeyWhile6, HotkeyWhile7
	Loop 6
	{
		i := A_Index+1
		HotkeyWhile%i% := IniRead("settings\nm_config.ini", "Boost", "HotkeyWhile" i, "Never")
		consumables .= (HotkeyWhile%i% != "Never") ? (((StrLen(consumables) = 0) ? "" : ", " ) . "#" . i) : ""
	}

	PlanterMode := IniRead("settings\nm_config.ini", "Planters", "PlanterMode", 0)
	MaxAllowedPlanters := IniRead("settings\nm_config.ini", "Planters", "MaxAllowedPlanters", 0)
}

; FORM MESSAGE
message := "Hourly Reports will start sending in **" DurationFromSeconds(60*(59-A_Min)+(60-A_Sec), "m'm 's's'") "**\n"
	. "Version: **StatMonitor v" version "**\n"
	. "Detected OS: **" os_version "**\n"
	. (ocr_enabled ? "OCR Status: **Enabled (" ocr_language ")**\nCurrent Honey: **" (start_honey ? FormatNumber(start_honey) : "N/A") "**"
		: "OCR Status: **Disabled**\n**Honey Graphs will be empty.**")

message .= (IsSet(natro_version) ? "\n\nMacro: **Natro v" natro_version "**\n"
	. "Gather Fields: **" FieldName1 ", " FieldName2 ", " FieldName3 "**\n"
	. "Consumables: **" ((StrLen(consumables) = 0) ? "None" : consumables) "**\n"
	. "Planters: **" ((PlanterMode = 2) ? ("ON (" MaxAllowedPlanters " Planters)") : (PlanterMode = 1) ? ("ON (MANUAL)") : "OFF") "**\n"
	. "Hive Slot: **" HiveSlot "**"
	: "")


; SEND STARTUP REPORT
; create postdata
postdata :=
(
'
{
	"embeds": [{
		"title": "[' A_Hour ':' A_Min ':' A_Sec '] Startup Report",
		"description": "' message '",
		"color": "14052794"
	}]
}
'
)

; post to status
Send_WM_COPYDATA(postdata, "Status.ahk ahk_class AutoHotkey")



; ▰▰▰▰▰▰▰▰▰
; CREATE TEMPLATE
; ▰▰▰▰▰▰▰▰▰


; DRAW REGIONS
; draw background (fill with rounded dark grey rectangle)
pBrush := Gdip_BrushCreateSolid(0xff121212), Gdip_FillRoundedRectangle(G, pBrush, -1, -1, w+1, h+1, 60), Gdip_DeleteBrush(pBrush)

; regions format: region_name:[x,y,w,h]
regions := Map("honey/sec", [120,120,4080,1080]
	, "stats", [w-1560-120,120,1560,h-240]
	, "backpack", [120,240+1080,4080,678]
	, "buffs", [120,360+1758,4080,h-480-1758])

stat_regions := Map("lasthour", [regions["stats"][1]+100,regions["stats"][2]+100,regions["stats"][3]-200,1206]
	, "session", [regions["stats"][1]+100,regions["stats"][2]+1406,regions["stats"][3]-200,1289]
	, "buffs", [regions["stats"][1]+100,regions["stats"][2]+2795,regions["stats"][3]-200,720]
	, "planters", [regions["stats"][1]+100,regions["stats"][2]+3615,regions["stats"][3]-200,495]
	, "stats", [regions["stats"][1]+100,regions["stats"][2]+4220,regions["stats"][3]-200,620]
	, "info", [regions["stats"][1]+100,regions["stats"][2]+4940,regions["stats"][3]-200,regions["stats"][4]-4940-100])

; draw region backgrounds (dark grey background for each region)
for k,v in regions
{
	pPen := Gdip_CreatePen(0xff282628, 10), Gdip_DrawRoundedRectangle(G, pPen, v[1], v[2], v[3], v[4], 20), Gdip_DeletePen(pPen)
	pBrush := Gdip_BrushCreateSolid(0xff201e20), Gdip_FillRoundedRectangle(G, pBrush, v[1], v[2], v[3], v[4], 20), Gdip_DeleteBrush(pBrush)
}
for k,v in stat_regions
{
	pPen := Gdip_CreatePen(0xff353335, 10), Gdip_DrawRoundedRectangle(G, pPen, v[1], v[2], v[3], v[4], 20), Gdip_DeletePen(pPen)
	pBrush := Gdip_BrushCreateSolid(0xff2c2a2c), Gdip_FillRoundedRectangle(G, pBrush, v[1], v[2], v[3], v[4], 20), Gdip_DeleteBrush(pBrush)
}

; draw region titles
Gdip_TextToGraphics(G, "HONEY/SEC", "s64 Center Bold cffffffff x" regions["honey/sec"][1] " y" regions["honey/sec"][2]+16, "Segoe UI", regions["honey/sec"][3])
Gdip_TextToGraphics(G, "BUFF UPTIME", "s64 Center Bold cffffffff x" regions["buffs"][1] " y" regions["buffs"][2]+16, "Segoe UI", regions["buffs"][3])
Gdip_TextToGraphics(G, "BACKPACK", "s64 Center Bold cffffffff x" regions["backpack"][1] " y" regions["backpack"][2]+16, "Segoe UI", regions["backpack"][3])


; DRAW GRAPHS AND OTHER ASSETS
; declare coordinate bounds for each graph
graph_regions := Map("honey/sec", [regions["honey/sec"][1]+320,regions["honey/sec"][2]+130,3600,800]
	, "backpack", [regions["backpack"][1]+320,regions["backpack"][2]+130,3600,400]
	, "boost", [regions["buffs"][1]+320,regions["buffs"][2]+135,3600,280]
	, "haste", [regions["buffs"][1]+320,regions["buffs"][2]+435,3600,280]
	, "focus", [regions["buffs"][1]+320,regions["buffs"][2]+735,3600,280]
	, "bombcombo", [regions["buffs"][1]+320,regions["buffs"][2]+1035,3600,280]
	, "balloonaura", [regions["buffs"][1]+320,regions["buffs"][2]+1335,3600,280]
	, "inspire", [regions["buffs"][1]+320,regions["buffs"][2]+1635,3600,280]
	, "reindeerfetch", [regions["buffs"][1]+320,regions["buffs"][2]+1935,3600,280]
	, "honeymark", [regions["buffs"][1]+320,regions["buffs"][2]+2235,3600,120]
	, "pollenmark", [regions["buffs"][1]+320,regions["buffs"][2]+2375,3600,120]
	, "festivemark", [regions["buffs"][1]+320,regions["buffs"][2]+2515,3600,120]
	, "popstar", [regions["buffs"][1]+320,regions["buffs"][2]+2655,3600,110]
	, "melody", [regions["buffs"][1]+320,regions["buffs"][2]+2785,3600,110]
	, "bear", [regions["buffs"][1]+320,regions["buffs"][2]+2915,3600,110]
	, "babylove", [regions["buffs"][1]+320,regions["buffs"][2]+3045,3600,110]
	, "jbshare", [regions["buffs"][1]+320,regions["buffs"][2]+3175,3600,110]
	, "guiding", [regions["buffs"][1]+320,regions["buffs"][2]+3305,3600,110]
	, "honey", [stat_regions["lasthour"][1]+200,stat_regions["lasthour"][2]+650,1080,480]
	, "honey12h", [stat_regions["session"][1]+200,stat_regions["session"][2]+734,1080,480])

; draw graph grids and axes
pPen := Gdip_CreatePen(0x40c0c0f0, 4)
Loop 61
{
	n := (Mod(A_Index, 10) = 1) ? 45 : 25
	Gdip_DrawLine(G, pPen, graph_regions["honey/sec"][1]+graph_regions["honey/sec"][3]*(A_Index-1)//60, graph_regions["honey/sec"][2]+graph_regions["honey/sec"][4]+20, graph_regions["honey/sec"][1]+graph_regions["honey/sec"][3]*(A_Index-1)//60, graph_regions["honey/sec"][2]+graph_regions["honey/sec"][4]+20+n)
	Gdip_DrawLine(G, pPen, graph_regions["backpack"][1]+graph_regions["backpack"][3]*(A_Index-1)//60, graph_regions["backpack"][2]+graph_regions["backpack"][4]+20, graph_regions["backpack"][1]+graph_regions["backpack"][3]*(A_Index-1)//60, graph_regions["backpack"][2]+graph_regions["backpack"][4]+20+n)
	Gdip_DrawLine(G, pPen, graph_regions["boost"][1]+graph_regions["boost"][3]*(A_Index-1)//60, regions["buffs"][2]+regions["buffs"][4]-125, graph_regions["boost"][1]+graph_regions["boost"][3]*(A_Index-1)//60, regions["buffs"][2]+regions["buffs"][4]-125+n)

	if (Mod(A_Index, 10) = 1)
	{
		i := A_Index
		for k,v in graph_regions
			Gdip_DrawLine(G, pPen, v[1]+v[3]*(i-1)//60, v[2], v[1]+v[3]*(i-1)//60, v[2]+v[4])
	}

	if (A_Index < 5 && A_Index > 1)
		y := regions["honey/sec"][2]+130+(regions["honey/sec"][4]-280)*(A_Index-1)//4, Gdip_DrawLine(G, pPen, regions["honey/sec"][1]+260, y, regions["honey/sec"][1]+regions["honey/sec"][3]-100, y)
}
for k,v in graph_regions
{
	if ((v[4] = 280) || (v[4] = 400))
		Gdip_DrawLine(G, pPen, v[1]-60, v[2]+v[4]//2, v[1]+v[3]+60, v[2]+v[4]//2)
	else if (v[4] = 480)
		Loop 3
			Gdip_DrawLine(G, pPen, v[1]-60, v[2]+v[4]*A_Index//4, v[1]+v[3]+60, v[2]+v[4]*A_Index//4)
}

; draw buff images and graph backgrounds
pBrush := Gdip_BrushCreateSolid(0x80141414)
for k,v in graph_regions
{
	Gdip_FillRectangle(G, pBrush, v[1]-60, v[2], v[3]+120, v[4])

	if bitmaps.Has("pBM" k)
	{
		Gdip_DrawImage(G, bitmaps["pBM" k], regions["buffs"][1]+75, v[2]+v[4]//2-55, 110, 110), Gdip_DisposeImage(bitmaps["pBM" k])
		Gdip_DrawLine(G, pPen, v[1]-60, v[2]+v[4]+10, v[1]+v[3]+60, v[2]+v[4]+10)
	}
}
Gdip_DeleteBrush(pBrush), Gdip_DeletePen(pPen)
if (ocr_enabled = 0)
{
	pBrush := Gdip_BrushCreateSolid(0x40cc0000)
	for k,v in ["honey/sec","honey","honey12h"]
		Gdip_FillRectangle(G, pBrush, graph_regions[v][1], graph_regions[v][2], graph_regions[v][3], graph_regions[v][4])
	Gdip_DeleteBrush(pBrush)
}

; draw static buff images
for k,v in ["clock","blessing","bloat","tideblessing","mondo"]
	Gdip_DrawImage(G, bitmaps["pBM" v], stat_regions["buffs"][1]+48+(A_Index-1)*(stat_regions["buffs"][3]-96-220)/4, stat_regions["buffs"][2]+124, 220, 220), Gdip_DisposeImage(bitmaps["pBM" v])

; leave pBM as final graph template
Gdip_DeleteGraphics(G)

; ▰▰▰▰
; TESTING
; ▰▰▰▰
/*
start_time := A_Now
status_changes[A_Min*60+A_Sec] := 0

honey_values[0] := 170000000000000
honey_12h[180] := 170000000000000

Loop 60
	honey_values[A_Index] := honey_values[A_Index-1] + ((Mod(A_Index, 15) < 4) ? 100000000000 : 10000000000)

Loop 3601
{
	if (Mod(A_Index, 5) = 1)
		x := Random(0, 6)
	backpack_values[A_Index-1] := ((Mod(A_Index, 900) < 240) ? 100 : 10) - x
}

status_changes := Map(0,2, 180,1 ,780,2, 1080,1, 1680,2, 1784,3 ,1832,2, 1980,1, 2100,3, 2120,1, 2580,2, 2880,1, 3480,2)

stats[1][2] := 1000
stats[6][2] := 100

for k,v in buff_values
{
	v[0] := 2
	Loop 600
	{
		x := Random(0, (k = "redboost" || k = "whiteboost" || k = "precision") ? 2 : 10)
		x := (x > 6) ? 10 : x
		v[A_Index] := Abs(x-v[A_Index-1]) > 4 ? 10 : x
	}
}

Loop 601
{
	buff_values["tideblessing"][A_Index-1] := "1.10"
	buff_values["bloat"][A_Index-1] := "6.00"
}
buff_values["comforting"][600] := 100

start_honey := 170000000000000
start_time := DateAdd(start_time, -1, "Hours")

SendHourlyReport()
KeyWait "F4", "D"
Reload
ExitApp
*/

; ▰▰▰▰▰
; MAIN LOOP
; ▰▰▰▰▰

; startup finished, set start time
start_time := A_Now
status_changes[A_Min*60+A_Sec] := 0

; set emergency switches in case of time error
last_honey := last_report := time := 0

; indefinite loop of detection and reporting
Loop
{
	; obtain current time and wait until next 6-second interval
	DllCall("GetSystemTimeAsFileTime", "int64p", &time)
	Sleep (60000000-Mod(time, 60000000))//10000 + 100
	time_value := (60*A_Min+A_Sec)//6

	; detect buffs every 6 seconds
	DetectBuffs()

	; detect honey every minute if ocr is enabled
	if ((ocr_enabled = 1) && ((Mod(time_value, 10) = 0) || (last_honey && time > last_honey + 580000000)))
	{
		DetectHoney()
		DllCall("GetSystemTimeAsFileTime", "int64p", &time)
		last_honey := time
	}

	; send report every hour
	if ((time_value = 0) || (last_report && time > last_report + 35980000000))
	{
		SendHourlyReport()
		DllCall("GetSystemTimeAsFileTime", "int64p", &time)
		last_report := time
	}
}



; ▰▰▰▰▰
; FUNCTIONS
; ▰▰▰▰▰

/********************************************************************************************
* @description: detects buffs in BSS and updates the relevant arrays with current buff values
* @returns: (string) list of buffs and their values (buff:value) delimited by new lines
* @author SP
********************************************************************************************/
DetectBuffs()
{
	global buff_values, buff_characters, buff_bitmaps

	; set time value
	time_value := (60*A_Min+A_Sec)//6
	i := (time_value = 0) ? 600 : time_value

	; check roblox window exists
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd), offsetY := GetYOffset(hwnd)
	if !(windowHeight >= 500)
	{
		for k,v in buff_values
		{
			v[i] := 0
			str .= k ":" 0 "`n"
		}
		return str
	}

	; create bitmap for buffs
	pBMArea := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+30 "|" windowWidth "|50")

	; basic on/off
	for v in ["jbshare","babylove","festivemark","guiding"]
		buff_values[v][i] := (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], , , 30, , , InStr(v, "mark") ? 6 : (v = "guiding") ? 10 : 0, , 7) = 1)

	; bear morphs
	buff_values["bear"][i] := 0
	for v in ["Brown","Black","Panda","Polar","Gummy","Science","Mother"]
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBMBear" v], , , 43, , 45, 8, , 2) = 1)
		{
			buff_values["bear"][i] := 1
			break
		}
	}

	; basic x1-x10
	for v in ["focus","bombcombo","balloonaura","clock","honeymark","pollenmark","reindeerfetch"]
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, , InStr(v, "mark") ? 20 : 30, , 50, InStr(v, "mark") ? 6 : 0, , 7) != 1)
		{
			buff_values[v][i] := 0
			continue
		}

		x := SubStr(list, 1, InStr(list, ",")-1)

		Loop 9
		{
			if (Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x-20, 15, x, 50) = 1)
			{
				buff_values[v][i] := (A_Index = 9) ? 10 : 10 - A_Index
				break
			}
			if (A_Index = 9)
				buff_values[v][i] := 1
		}
	}

	; mondo
	for v in ["mondo"]
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, , 20, , 46, 21, , 7) != 1)
		{
			buff_values[v][i] := 0
			continue
		}

		x := SubStr(list, 1, InStr(list, ",")-1)

		Loop 9
		{
			if (Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x+16, 20, x+36, 46) = 1)
			{
				buff_values[v][i] := (A_Index = 9) ? 10 : 10 - A_Index
				break
			}
			if (A_Index = 9)
				buff_values[v][i] := 1
		}
	}

	; melody / haste
	x := 0
	Loop 3 ; melody, haste, coconut haste
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBMHaste"], &list, x, 30, , , , , 6) != 1)
			break

		x := SubStr(list, 1, InStr(list, ",")-1)

		if ((s := Gdip_ImageSearch(pBMArea, buff_bitmaps["pBMMelody"], , x+2, 15, x+34, 40, 12)) != 1)
		{
			if !buff_values["haste"].Has(i)
			{
				Loop 9
				{
					if (Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x+6, 15, x+44, 50) = 1)
					{
						buff_values["haste"][i] := (A_Index = 9) ? 10 : 10 - A_Index
						break
					}
					if (A_Index = 9)
						buff_values["haste"][i] := 1
				}
			}
		}
		else if (s = 1)
			buff_values["melody"][i] := 1

		x += 44
	}
	for v in ["melody","haste"]
		if !buff_values[v].Has(i)
			buff_values[v][i] := 0

	; colour boost x1-x10
	x := windowWidth
	Loop 3
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBMBoost"], &list, , 30, x, , , , 7) != 1)
			break

		x := SubStr(list, 1, InStr(list, ",")-1)
		y := SubStr(list, InStr(list, ",")+1)

		; obtain colour of boost buff
		pBMPxRed := Gdip_CreateBitmap(1,2), pBMPxBlue := Gdip_CreateBitmap(1,2)
		pGRed := Gdip_GraphicsFromImage(pBMPxRed), pGBlue := Gdip_GraphicsFromImage(pBMPxBlue)
		Gdip_GraphicsClear(pGRed, 0xffe46156), Gdip_GraphicsClear(pGBlue, 0xff56a4e4)
		Gdip_DeleteGraphics(pGRed), Gdip_DeleteGraphics(pGBlue)
		v := (Gdip_ImageSearch(pBMArea, pBMPxRed, , x-30, 15, x-4, 34, 20, , , 2) = 2) ? "redboost"
			: (Gdip_ImageSearch(pBMArea, pBMPxBlue, , x-30, 15, x-4, 34, 20, , , 2) = 2) ? "blueboost"
			: "whiteboost"
		Gdip_DisposeImage(pBMPxRed), Gdip_DisposeImage(pBMPxBlue)

		; find stack number
		Loop 9
		{
			if Gdip_ImageSearch(pBMArea, buff_characters[10-A_Index], , x-20, 15, x, 50)
			{
				buff_values[v][i] := (A_Index = 9) ? 10 : 10 - A_Index
				break
			}
			if (A_Index = 9)
				buff_values[v][i] := 1
		}

		x -= 2*y-53 ; take away width of buff square to prevent duplication
	}
	for v in ["redboost","blueboost","whiteboost"]
		if !buff_values[v].Has(i)
			buff_values[v][i] := 0

	; 2 digit
	for v in ["blessing","inspire"]
	{
		if (v = "blessing") && (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBMBlessingx100"], , , 20, , , 21, , 6)=1)
		{
			buff_values["blessing"][i] := "100"
			continue
		}
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, , 20, , , (v = "blessing") ? 21 : 0, , (v = "blessing") ? 6 : 7) != 1)
		{
			buff_values[v][i] := 0
			continue
		}

		x := SubStr(list, 1, InStr(list, ",")-1)

		(digits := Map()).Default := ""

		Loop 10
		{
			n := 10-A_Index
			if ((n = 1) || (n = 3))
				continue
			Gdip_ImageSearch(pBMArea, buff_characters[n], &list:="", ((v = "blessing") ? x+8 : x-20), 15, ((v = "blessing") ? x+36 : x), 50, 1, , 5, 5, , "`n")
			Loop Parse list, "`n"
				if (A_Index & 1)
					digits[Integer(A_LoopField)] := n
		}

		for m,n in [1,3]
		{
			Gdip_ImageSearch(pBMArea, buff_characters[n], &list:="", ((v = "blessing") ? x+8 : x-20), 15, ((v = "blessing") ? x+36 : x), 50, 1, , 5, 5, , "`n")
			Loop Parse list, "`n"
			{
				if (A_Index & 1)
				{
					if (((n = 1) && (digits[A_LoopField - 5] = 4)) || ((n = 3) && (digits[A_LoopField - 1] = 8)))
						continue
					digits[Integer(A_LoopField)] := n
				}
			}
		}

		num := ""
		for x,y in digits
			num .= y

		buff_values[v][i] := num ? Min(num, (v = "inspire" ? 50 : 100)) : 1
	}

	; scaled
	for v in ["bloat","comforting","motivating","satisfying","refreshing","invigorating"]
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, , 30, , , , , 6) != 1)
		{
			buff_values[v][i] := 0
			continue
		}

		x := SubStr(list, 1, InStr(list, ",")-1)

		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, x, 6, x+38, 44) != 1)
		{
			buff_values[v][i] := 0
			continue
		}

		y := SubStr(list, InStr(list, ",")+1)

		buff_values[v][i] := String(Round(Min((44 - y) / 38, 1) * ((v = "bloat") ? 5 : 100) + ((v = "bloat") ? 1 : 0), (v = "bloat") ? 2 : 0))
	}

	; tide
	for v in ["tideblessing"]
	{
		if (Gdip_ImageSearch(pBMArea, buff_bitmaps["pBM" v], &list, , 30, , , , , 6) != 1)
			continue

		x := SubStr(list, 1, InStr(list, ",")-1)

		pBM := Gdip_CreateBitmap(36, 1), Gdip_SetPixel(pBM, 0, 0, 0xff91c2fd), Gdip_SetPixel(pBM, 35, 0, 0xff91c2fd)

		s := Gdip_ImageSearch(pBMArea, pBM, &list, x-16, 6, x+36, 44)
		Gdip_DisposeImage(pBM)
		if (s != 1)
			continue

		y := SubStr(list, InStr(list, ",")+1)
		buff_values[v][i] := String(Round(1.01 + 0.19 * (44.3 - y) / 38, 2))
	}

	; form string
	str := ""
	for k,v in buff_values
		str .= k ":" (v.Has(i) ? v[i] : 0) "`n"

	; clean up and return
	Gdip_DisposeImage(pBMArea)
	return str
}

/********************************************************************
* @description: uses OCR to detect the current honey value in BSS
* @returns: (string) current honey value or (integer) 0 on failure
* @note function is a WIP, and OCR readings are not 100% reliable!
* @author SP
********************************************************************/
DetectHoney()
{
	global honey_values, start_honey, start_time, ocr_language

	; check roblox window exists
	hwnd := GetRobloxHWND()
	GetRobloxClientPos(hwnd), offsetY := GetYOffset(hwnd)
	if !(windowHeight >= 500)
		return 0

	; initialise array to store detected values and get bitmap and effect ready
	detected := Map()
	pBM := Gdip_BitmapFromScreen(windowX+windowWidth//2-241 "|" windowY+offsetY "|140|36")
	pEffect := Gdip_CreateEffect(5,-80,30)

	; detect honey, enlarge image if necessary
	Loop 25
	{
		i := A_Index
		Loop 2
		{
			pBMNew := Gdip_ResizeBitmap(pBM, ((A_Index = 1) ? (250 + i * 20) : (750 - i * 20)), 36 + i * 4, 2)
			Gdip_BitmapApplyEffect(pBMNew, pEffect)
			hBM := Gdip_CreateHBITMAPFromBitmap(pBMNew)
			;Gdip_SaveBitmapToFile(pBMNew, i A_Index ".png")
			Gdip_DisposeImage(pBMNew)
			pIRandomAccessStream := HBitmapToRandomAccessStream(hBM)
			DllCall("DeleteObject", "Ptr", hBM)
			try detected[v := ((StrLen((n := RegExReplace(StrReplace(StrReplace(StrReplace(StrReplace(ocr(pIRandomAccessStream, ocr_language), "o", "0"), "i", "1"), "l", "1"), "a", "4"), "\D"))) > 0) ? n : 0)] := detected.Has(v) ? [detected[v][1]+1, detected[v][2] " " i . A_Index] : [1, i . A_Index]
		}
	}

	; clean up
	Gdip_DisposeImage(pBM), Gdip_DisposeEffect(pEffect)
	DllCall("psapi.dll\EmptyWorkingSet", "UInt", -1)

	; evaluate current honey
	current_honey := 0
	for k,v in detected
		if ((v[1] > 2) && (k > current_honey))
			current_honey := k

	; update honey values array and write values to ini
	index := (A_Min = "00") ? 60 : Integer(A_Min)
	if current_honey
	{
		honey_values[index] := current_honey
		if (FileExist("settings\nm_config.ini") && IsSet(start_time))
		{
			session_time := DateDiff(A_Now, start_time, "S")
			session_total := current_honey - start_honey
			try IniWrite FormatNumber(session_total), "settings\nm_config.ini", "Status", "SessionTotalHoney"
			try IniWrite FormatNumber(session_total*3600/session_time), "settings\nm_config.ini", "Status", "HoneyAverage"
		}
		return current_honey
	}
	else
		return 0
}

/********************************************************************************************************
* @description: creates an hourly report (image) from the honey and buff arrays, then sends it to Discord
* @author SP
********************************************************************************************************/
SendHourlyReport()
{
	global pBM, regions, stat_regions, honey_values, honey_12h, backpack_values, buff_values, buff_colors, status_changes, start_time, start_honey, stats, latest_boost, latest_winds, graph_regions, version, natro_version, os_version, bitmaps, ocr_enabled, ocr_language
	static honey_average := 0, honey_earned := 0, convert_time := 0, gather_time := 0, other_time := 0, stats_old := [["Total Boss Kills",0],["Total Vic Kills",0],["Total Bug Kills",0],["Total Planters",0],["Quests Done",0],["Disconnects",0]]

	if (honey_values.Count > 0)
	{
		; identify and exterminate misread values
		max_value := maxX(honey_values)

		str := ""
		for k,v in honey_values
			if (v < max_value//8) ; any value smaller than this is regarded as a misread
				str .= (StrLen(str) ? " " : "") k

		Loop Parse str, A_Space
			honey_values.Delete(Integer(A_LoopField))

		min_value := minX(honey_values), max_value := Max(maxX(honey_values), min_value+1000), range_value := max_value - min_value
	}
	else
		min_value := 0, max_value := 1000, range_value := 1000

	; populate honey_values array, fill missing values
	enum := honey_values.__Enum()
	enum.Call(&x2,&y2)
	for x1,y1 in honey_values
	{
		if (enum.Call(&x2,&y2) = 0)
		{
			if (x1 < 60)
				Loop (60 - x1)
					honey_values[x1+A_Index] := y1
			break
		}
		delta_x := x2 - x1
		if (delta_x > 1)
		{
			delta_y := y2 - y1
			Loop (delta_x - 1)
				honey_values[x1+A_Index] := y1 + A_Index * (delta_y/delta_x)
		}
	}
	Loop 61
		if !honey_values.Has(A_Index-1)
			honey_values[A_Index-1] := min_value

	; update honey gradients and 12h data
	honey_gradients := Map()
	for k,v in honey_values
		if (k < 60)
			honey_gradients[k+1] := (honey_values[k+1]-honey_values[k])/60
	honey_gradients[0] := honey_gradients[1], honey_gradients[61] := honey_gradients[60]

	Loop 166
		try honey_12h[A_Index - 1] := honey_12h[A_Index + 14]
	Loop 15
		honey_12h[A_Index + 165] := honey_values[4*A_Index]

	; set time arrays (10 min interval and 2 hour for 12h graph)
	times := [], times_12h := []
	time := A_Now
	Loop 7
		times.InsertAt(1, FormatTime(time, "HH:mm")), time := DateAdd(time, -10, "m")
	time := DateAdd(time, 70, "m")
	Loop 7
		times_12h.InsertAt(1, FormatTime(time, "HH:mm")), time := DateAdd(time, -2, "h")

	; create report bitmap and graphics
	pBMReport := Gdip_CloneBitmap(pBM)
	G := Gdip_GraphicsFromImage(pBMReport)
	Gdip_SetSmoothingMode(G, 4)
	Gdip_SetInterpolationMode(G, 7)

	; set variable graph bounds
	min_gradient := 0, max_gradient := Max(maxX(honey_gradients), min_gradient+1000), range_gradient := Floor(max_gradient - min_gradient)
	min_12h := minX(honey_12h), max_12h := Max(maxX(honey_12h), min_12h+1000), range_12h := max_12h - min_12h

	; draw times
	for v in ["honey/sec","backpack","buffs"]
		Loop 7
			Gdip_TextToGraphics(G, times[A_Index], "s44 Center Bold cffffffff x" regions[v][1]+320+(regions[v][3]-480)*(A_Index-1)//6 " y" regions[v][2]+regions[v][4]-85, "Segoe UI")
	for k,v in Map("honey","times", "honey12h","times_12h")
		Loop 7
			Gdip_TextToGraphics(G, %v%[A_Index], "s30 Center Bold cffffffff x" graph_regions[k][1]+graph_regions[k][3]*(A_Index-1)//6 " y" graph_regions[k][2]+graph_regions[k][4]+14, "Segoe UI")

	; draw graphs
	for k,v in graph_regions
	{
		pBMGraph := Gdip_CreateBitmap(v[3]+8, v[4]+8)
		G_Graph := Gdip_GraphicsFromImage(pBMGraph)
		Gdip_SetSmoothingMode(G_Graph, 4)
		Gdip_SetInterpolationMode(G_Graph, 7)

		switch k
		{
			case "honey/sec":
			Loop 5
				Gdip_TextToGraphics(G, FormatNumber(max_gradient-(range_gradient*(A_Index-1))//4), "s40 Right Bold cffffffff x" v[1]-320 " y" v[2]+v[4]*(A_Index-1)//4-28, "Segoe UI", 240)

			enum := status_changes.__Enum()
			enum.Call(&m)
			for i,j in status_changes
			{
				if (enum.Call(&m) = 0)
					m := 3599
				points := []
				points.Push([4+i*v[3]/3600, 4+v[4]])
				points.Push([4+i*v[3]/3600, 4+v[4]-(honey_gradients[(i+30)//60]+((i+30)/60-(i+30)//60)*(honey_gradients[(i+30)//60+1]-honey_gradients[(i+30)//60])-min_gradient)/range_gradient*v[4]])
				for x,y in honey_gradients
					((y != "") && (x >= (i+30)/60 && x <= (m+30)/60)) && points.Push([4+(x-0.5)*v[3]/60, 4+v[4]-((y > 0) ? (((y-min_gradient)/range_gradient)*v[4]) : 0)])
				points.Push([4+m*v[3]/3600, 4+v[4]-(honey_gradients[(m+30)//60]+((m+30)/60-(m+30)//60)*(honey_gradients[(m+30)//60+1]-honey_gradients[(m+30)//60])-min_gradient)/range_gradient*v[4]])
				points.Push([4+m*v[3]/3600, 4+v[4]])

				color := (j = 1) ? 0xffa6ff7c
						: (j = 2) ? 0xfffeca40
						: 0xff859aad

				pBrush := Gdip_BrushCreateSolid(color - 0x80000000)
				Gdip_FillPolygon(G_Graph, pBrush, points)
				Gdip_DeleteBrush(pBrush)

				points.RemoveAt(1), points.Pop()
				pPen := Gdip_CreatePen(color, 6)
				Gdip_DrawLines(G_Graph, pPen, points)
				Gdip_DeletePen(pPen)
			}


			case "honey":
			Loop 5
				Gdip_TextToGraphics(G, FormatNumber(max_value-(range_value*(A_Index-1))//4), "s28 Right Bold cffffffff x" v[1] - 310 " y" v[2]+v[4]*(A_Index-1)//4 - 20, "Segoe UI", 240)

			enum := status_changes.__Enum()
			enum.Call(&m)
			for i,j in status_changes
			{
				if (enum.Call(&m) = 0)
					m := 3599
				points := []
				points.Push([4+i*v[3]/3600, 4+v[4]])
				points.Push([4+i*v[3]/3600, 4+v[4]-(honey_values[i//60]+(i/60-i//60)*(honey_values[i//60+1]-honey_values[i//60])-min_value)/range_value*v[4]])
				for x,y in honey_values
					((y != "") && (x >= i/60 && x <= m/60)) && points.Push([4+x*v[3]/60, 4+v[4]-((y > 0) ? (((y-min_value)/range_value)*v[4]) : 0)])
				points.Push([4+m*v[3]/3600, 4+v[4]-(honey_values[m//60]+(m/60-m//60)*(honey_values[m//60+1]-honey_values[m//60])-min_value)/range_value*v[4]])
				points.Push([4+m*v[3]/3600, 4+v[4]])

				color := (j = 1) ? 0xffa6ff7c
						: (j = 2) ? 0xfffeca40
						: 0xff859aad

				pBrush := Gdip_BrushCreateSolid(color - 0x80000000)
				Gdip_FillPolygon(G_Graph, pBrush, points)
				Gdip_DeleteBrush(pBrush)

				points.RemoveAt(1), points.Pop()
				pPen := Gdip_CreatePen(color, 6)
				Gdip_DrawLines(G_Graph, pPen, points)
				Gdip_DeletePen(pPen)
			}


			case "honey12h":
			Loop 5
				Gdip_TextToGraphics(G, FormatNumber(max_12h-Floor((range_12h*(A_Index-1))/4)), "s28 Right Bold cffffffff x" v[1]-310 " y" v[2]+v[4]*(A_Index-1)//4-20, "Segoe UI", 240)

			points := []
			honey_12h.__Enum().Call(&x), points.Push([4+v[3]*x/180, 4+v[4]])
			for x,y in honey_12h
				(y != "") && points.Push([4+v[3]*(max_x := x)/180, 4+v[4]-((y-min_12h)/range_12h)*v[4]])
			points.Push([4+v[3]*max_x/180, 4+v[4]])
			color := 0xff0e8bf0

			pBrush := Gdip_BrushCreateSolid(color - 0x80000000)
			Gdip_FillPolygon(G_Graph, pBrush, points)
			Gdip_DeleteBrush(pBrush)

			points.RemoveAt(1), points.Pop()
			pPen := Gdip_CreatePen(color, 6)
			Gdip_DrawLines(G_Graph, pPen, points)
			Gdip_DeletePen(pPen)


			case "backpack":
			Loop 3
				Gdip_TextToGraphics(G, 150-50*A_Index "%", "s40 Right Bold cffffffff x" v[1]-320 " y" v[2]+v[4]*(A_Index-1)//2-28, "Segoe UI", 240)

			points := []
			backpack_values.__Enum().Call(&x), points.Push([4+x*v[3]/3600, 4+v[4]])
			for x,y in backpack_values
				(y != "") && points.Push([4+(max_x := x)*v[3]/3600, 4+v[4]-(y/100)*v[4]])
			points.Push([4+max_x*v[3]/3600, 4+v[4]])

			pBrush := Gdip_CreateLinearGrBrushFromRect(4, 4, v[3], v[4], 0x00000000, 0x00000000)
			Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.2, 0.8], [0xffff0000, 0xffff8000, 0xff41ff80])
			pPen := Gdip_CreatePenFromBrush(pBrush, 6)
			Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.2, 0.8], [0x80ff0000, 0x80ff8000, 0x8041ff80])
			Gdip_FillPolygon(G_Graph, pBrush, points)
			points.RemoveAt(1), points.Pop()
			Gdip_DrawLines(G_Graph, pPen, points)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)


			case "boost":
			Gdip_TextToGraphics(G, "x0-10", "s44 Center Bold cffffffff x" v[1]-190 " y" v[2]+190, "Segoe UI")

			Loop 3
			{
				i := (A_Index = 1) ? "whiteboost"
					: (A_Index = 2) ? "redboost"
					: "blueboost"

				total := 0
				count := 0
				enum := status_changes.__Enum()
				enum.Call(&m)
				for a,b in status_changes
				{
					if (enum.Call(&m) = 0)
						m := 3600
					if (b != 1)
						continue
					for x,y in buff_values[i]
					{
						if (x >= a//6 && x <= m//6)
						{
							total += y
							count++
						}
					}
				}

				color := (i = "whiteboost") ? 0xffffffff
					: (i = "redboost") ? 0xffe46156
					: 0xff56a4e4

				pBrush := Gdip_BrushCreateSolid(color), Gdip_TextToGraphics(G, "x" . (count ? Round(total/count, 3) : "0.000"), "s32 Center Bold c" pBrush " x" v[1]-190 " y" v[2]+(72-36*A_Index), "Segoe UI"), Gdip_DeleteBrush(pBrush)

				points := []

				buff_values[i].__Enum().Call(&x), points.Push([4+v[3]*x/600, 4+v[4]])
				for x,y in buff_values[i]
					points.Push([4+v[3]*(max_x := x)/600, 4+v[4]-((y <= 10) ? (y/10)*(v[4]) : 10)])
				points.Push([4+v[3]*max_x/600, 4+v[4]])

				if (points.Length > 2)
				{
					pBrush := Gdip_CreateLinearGrBrushFromRect(4, 4, v[3], v[4], 0x00000000, color - 0x40000000)
					Gdip_SetLinearGrBrushSigmaBlend(pBrush, 0, 0.3)
					Gdip_FillPolygon(G_Graph, pBrush, points)
					Gdip_DeleteBrush(pBrush)

					points.RemoveAt(1), points.Pop()
					pPen := Gdip_CreatePen(color, 4)
					Gdip_DrawCurve(G_Graph, pPen, points, 0)
					Gdip_DeletePen(pPen)
				}
			}


			case "honeymark","pollenmark","precisemark":
			color := (k = "honeymark") ? 0xffffd119
				: (k = "pollenmark") ? 0xffffe994
				: 0xff8f4eb4

			pBrush := Gdip_BrushCreateSolid(color-0x60000000)
			for x,y in buff_values[k]
				(y && y < 4 && y > 0) && Gdip_FillRectangle(G_Graph, pBrush, 4+v[3]*x//600, 4+v[4]*(3-y)//3, 6, v[4]*y//3)
			Gdip_DeleteBrush(pBrush)


			case "festivemark","popstar","melody","bear","babylove","jbshare","guiding":
			color := (k = "festivemark") ? 0xffc84335
				: (k = "popstar") ? 0xff0096ff
				: (k = "melody") ? 0xfff0f0f0
				: (k = "bear") ? 0xffb26f3e
				: (k = "babylove") ? 0xff8de4f3
				: (k = "jbshare") ? 0xfff9ccff
				: 0xffffef8e

			pBrush := Gdip_BrushCreateSolid(color-0x60000000)
			enum := buff_values[k].__Enum()
			enum.Call(&x2)
			for x,y in buff_values[k]
			{
				if (enum.Call(&x2) = 0)
					x2 := 600
				(y) && Gdip_FillRectangle(G_Graph, pBrush, 4+v[3]*x//600, 4, (x2-x)*6, v[4])
			}
			Gdip_DeleteBrush(pBrush)


			default:
			max_buff := (k = "inspire") ? Max(ceil(maxX(buff_values[k])/5)*5, 5) : 10
			Gdip_TextToGraphics(G, "x0-" max_buff, "s44 Center Bold cffffffff x" v[1]-190 " y" v[2]+190, "Segoe UI")

			total := 0
			count := 0
			enum := status_changes.__Enum()
			enum.Call(&m)
			for a,b in status_changes
			{
				if (enum.Call(&m) = 0)
					m := 3600
				if (b != 1)
					continue
				for x,y in buff_values[k]
				{
					if (x >= a//6 && x <= m//6)
					{
						total += y
						count++
					}
				}
			}

			color := (k = "focus") ? 0xff22ff06
				: (k = "haste") ? 0xfff0f0f0
				: (k = "bombcombo") ? 0xffa0a0a0
				: (k = "balloonaura") ? 0xff3350c3
				: (k = "inspire") ? 0xfff4ef14
				: (k = "precision") ? 0xff8f4eb4
				: (k = "reindeerfetch") ? 0xffcc2c2c : 0

			pBrush := Gdip_BrushCreateSolid(color), Gdip_TextToGraphics(G, "x" . (count ? Round(total/count, 3) : "0.000"), "s32 Center Bold c" pBrush " x" v[1]-190 " y" v[2]+36, "Segoe UI"), Gdip_DeleteBrush(pBrush)

			points := []

			buff_values[k].__Enum().Call(&x), points.Push([4+v[3]*x/600, 4+v[4]])
			for x,y in buff_values[k]
				points.Push([4+v[3]*(max_x := x)/600, 4+v[4]-(y/max_buff)*(v[4])])
			points.Push([4+v[3]*max_x/600, 4+v[4]])

			if (points.Length > 2)
			{
				pBrush := Gdip_CreateLinearGrBrushFromRect(4, 4, v[3], v[4], 0x00000000, color - 0x40000000)
				Gdip_SetLinearGrBrushSigmaBlend(pBrush, 0, 0.3)
				Gdip_FillPolygon(G_Graph, pBrush, points)
				Gdip_DeleteBrush(pBrush)

				points.RemoveAt(1), points.Pop()
				pPen := Gdip_CreatePen(color, 4)
				Gdip_DrawLines(G_Graph, pPen, points)
				Gdip_DeletePen(pPen)
			}
		}

		Gdip_DeleteGraphics(G_Graph)
		Gdip_DrawImage(G, pBMGraph, v[1]-4, v[2]-4)
		Gdip_DisposeImage(pBMGraph)
	}

	; calculate times
	time := DateAdd(DateAdd(A_Now, -A_Min, "Minutes"), -A_Sec, "Seconds")
	session_time := DateDiff(time, start_time, "Seconds")

	local hour_gather_time, hour_convert_time, hour_other_time
		, hour_gather_percent, hour_convert_percent, hour_other_percent
		, gather_percent, convert_percent, other_percent

	status_list := ["Gather","Convert","Other"]
	for i,j in status_list
		hour_%j%_time := 0
	enum := status_changes.__Enum()
	enum.Call(&m)
	for i,j in status_changes
	{
		if (enum.Call(&m) = 0)
			m := 3600
		status := (j = 1) ? "Gather"
			: (j = 2) ? "Convert"
			: "Other"
		hour_%status%_time += m-i
	}
	for i,j in status_list
		%j%_time += hour_%j%_time

	unix_now := DateDiff(SubStr(A_NowUTC, 1, 10), "19700101000000", "Seconds")

	; calculate percentages
	cumul_hour := 0, cumul_hour_rounded := 0
	cumul_total := 0, cumul_total_rounded := 0
	for i,j in status_list
	{
		cumul_hour += hour_%j%_time*100/3600
		hour_%j%_percent := Round(cumul_hour) - cumul_hour_rounded . "%"
		cumul_hour_rounded := Round(cumul_hour)

		cumul_total += %j%_time*100/session_time
		%j%_percent := Round(cumul_total) - cumul_total_rounded . "%"
		cumul_total_rounded := Round(cumul_total)
	}

	; session stats
	current_honey := honey_values[60]
	session_total := current_honey - start_honey

	; last hour stats
	hour_increase := (honey_values[60] - honey_values[0] < honey_earned) ? "0" : "1"
	honey_earned := honey_values[60] - honey_values[0]
	average_difference := honey_average ? ((session_total * 3600 / session_time) - honey_average) : 0
	honey_change := (average_difference = 0) ? "(+0%)" : (average_difference > 0) ? "(+" . Ceil(average_difference * 100 / Abs(honey_average)) . "%)" : "(" . Floor(average_difference * 100 / Abs(honey_average)) . "%)"
	honey_average := session_total * 3600 / session_time


	; WRITE STATS
	; section 1: last hour
	Gdip_TextToGraphics(G, "LAST HOUR", "s64 Center Bold cffffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2 " y" stat_regions["lasthour"][2]+4, "Segoe UI")

	Gdip_TextToGraphics(G, "Honey Earned", "s60 Right Bold ccfffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2-40 " y" stat_regions["lasthour"][2]+96, "Segoe UI")
	pos := Gdip_TextToGraphics(G, FormatNumber(honey_earned), "s60 Left Bold cffffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+40 " y" stat_regions["lasthour"][2]+96, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
	pBrush := Gdip_BrushCreateSolid(hour_increase ? 0xff00ff00 : 0xffff0000), (x) && Gdip_FillPolygon(G, pBrush, hour_increase ? [[x+45, stat_regions["lasthour"][2]+119], [x+20, stat_regions["lasthour"][2]+161], [x+70, stat_regions["lasthour"][2]+161]] : [[x+20, stat_regions["lasthour"][2]+119], [x+70, stat_regions["lasthour"][2]+119], [x+45, stat_regions["lasthour"][2]+161]]), Gdip_DeleteBrush(pBrush)

	Gdip_TextToGraphics(G, "Hourly Average", "s60 Right Bold ccfffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2-40 " y" stat_regions["lasthour"][2]+180, "Segoe UI")
	pos := Gdip_TextToGraphics(G, FormatNumber(honey_average), "s60 Left Bold cffffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+40 " y" stat_regions["lasthour"][2]+180, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
	Gdip_TextToGraphics(G, honey_change, "s60 Left Bold c" . (InStr(honey_change, "-") ? "ffff0000" : InStr(honey_change, "+0") ? "ff888888" : "ff00ff00") . " x" x " y" stat_regions["lasthour"][2]+180, "Segoe UI")

	angle := -90
	for i,j in status_list
	{
		color := (j = "Gather") ? 0xffa6ff7c
				: (j = "Convert") ? 0xfffeca40
				: 0xff859aad
		pBrush := Gdip_BrushCreateSolid(color)
		Gdip_FillPie(G, pBrush, stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2-464, stat_regions["lasthour"][2]+318, 280, 280, angle, hour_%j%_time/10)
		angle += hour_%j%_time/10

		Gdip_FillRoundedRectangle(G, pBrush, stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+74, stat_regions["lasthour"][2]+348+(A_Index-1)*88, 44, 44, 4)
		Gdip_DeleteBrush(pBrush)

		Gdip_TextToGraphics(G, j, "s48 Right Bold ccfffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+56 " y" stat_regions["lasthour"][2]+335+(A_Index-1)*88, "Segoe UI")
		Gdip_TextToGraphics(G, DurationFromSeconds(hour_%j%_time), "s48 Left Bold cefffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+135 " y" stat_regions["lasthour"][2]+335+(A_Index-1)*88, "Segoe UI")
		Gdip_TextToGraphics(G, hour_%j%_percent, "s48 Right Bold cefffffff x" stat_regions["lasthour"][1]+stat_regions["lasthour"][3]//2+476 " y" stat_regions["lasthour"][2]+335+(A_Index-1)*88, "Segoe UI")
	}

	; section 2: session
	Gdip_TextToGraphics(G, "SESSION", "s64 Center Bold cffffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2 " y" stat_regions["session"][2]+4, "Segoe UI")

	Gdip_TextToGraphics(G, "Current Honey", "s60 Right Bold ccfffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2-40 " y" stat_regions["session"][2]+96, "Segoe UI")
	Gdip_TextToGraphics(G, FormatNumber(current_honey), "s60 Left Bold cffffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+40 " y" stat_regions["session"][2]+96, "Segoe UI")

	Gdip_TextToGraphics(G, "Session Honey", "s60 Right Bold ccfffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2-40 " y" stat_regions["session"][2]+180, "Segoe UI")
	Gdip_TextToGraphics(G, FormatNumber(session_total), "s60 Left Bold cffffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+40 " y" stat_regions["session"][2]+180, "Segoe UI")

	Gdip_TextToGraphics(G, "Session Time", "s60 Right Bold ccfffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2-40 " y" stat_regions["session"][2]+264, "Segoe UI")
	session_time_F := DurationFromSeconds(session_time)
	Gdip_TextToGraphics(G, session_time_F, "s60 Left Bold cffffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+40 " y" stat_regions["session"][2]+264, "Segoe UI")

	angle := -90
	for i,j in status_list
	{
		color := (j = "Gather") ? 0xffa6ff7c
				: (j = "Convert") ? 0xfffeca40
				: 0xff859aad
		pBrush := Gdip_BrushCreateSolid(color)
		Gdip_FillPie(G, pBrush, stat_regions["session"][1]+stat_regions["session"][3]//2-464, stat_regions["session"][2]+402, 280, 280, angle, %j%_time/session_time*360)
		angle += %j%_time/session_time*360

		Gdip_FillRoundedRectangle(G, pBrush, stat_regions["session"][1]+stat_regions["session"][3]//2+74, stat_regions["session"][2]+432+(A_Index-1)*88, 44, 44, 4)
		Gdip_DeleteBrush(pBrush)

		Gdip_TextToGraphics(G, j, "s48 Right Bold ccfffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+56 " y" stat_regions["session"][2]+419+(A_Index-1)*88, "Segoe UI")
		Gdip_TextToGraphics(G, DurationFromSeconds(%j%_time), "s48 Left Bold cefffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+135 " y" stat_regions["session"][2]+419+(A_Index-1)*88, "Segoe UI")
		Gdip_TextToGraphics(G, %j%_percent, "s48 Right Bold cefffffff x" stat_regions["session"][1]+stat_regions["session"][3]//2+476 " y" stat_regions["session"][2]+419+(A_Index-1)*88, "Segoe UI")
	}

	; section 3: buffs
	Gdip_TextToGraphics(G, "BUFFS", "s64 Center Bold cffffffff x" stat_regions["buffs"][1]+stat_regions["buffs"][3]//2 " y" stat_regions["buffs"][2]+4, "Segoe UI")

	for k,v in ["clock","blessing","bloat","tideblessing","mondo"]
	{
		i := A_Index
		Loop 601
		{
			if (buff_values[v].Has(601-A_Index) && (buff_values[v][601-A_Index] > 0))
			{
				if (i = 3 || i = 4)
					pBrush := Gdip_BrushCreateSolid(0x70000000), Gdip_FillRectangle(G, pBrush, stat_regions["buffs"][1]+47+(i-1)*(stat_regions["buffs"][3]-96-220)/4, stat_regions["buffs"][2]+123, 221, 1+Min((1-((buff_values[v][601-A_Index]-1)/((i = 3) ? 5.00 : 0.20))) * 220, 220)), Gdip_DeleteBrush(pBrush)

				pBrush := Gdip_BrushCreateSolid(0xffffffff), pPen := Gdip_CreatePen(0xff000000, 10)
				Gdip_DrawOrientedString(G, "x" buff_values[v][601-A_Index], "Segoe UI", 72, 1, stat_regions["buffs"][1]+48+(i-1)*(stat_regions["buffs"][3]-96-220)/4, stat_regions["buffs"][2]+254, 220, 90, , pBrush, pPen, 2)
				Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
				break
			}
			if (A_Index = 601)
			{
				pBrush := Gdip_BrushCreateSolid(0x70000000), Gdip_FillRectangle(G, pBrush, stat_regions["buffs"][1]+47+(i-1)*(stat_regions["buffs"][3]-96-220)/4, stat_regions["buffs"][2]+123, 221, 221), Gdip_DeleteBrush(pBrush)
				pBrush := Gdip_BrushCreateSolid(0xffffffff), pPen := Gdip_CreatePen(0xff000000, 10)
				Gdip_DrawOrientedString(G, "x0", "Segoe UI", 72, 1, stat_regions["buffs"][1]+48+(i-1)*(stat_regions["buffs"][3]-96-220)/4, stat_regions["buffs"][2]+254, 220, 90, , pBrush, pPen, 2)
				Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
			}
		}
	}

	planters := 0

	local PlanterName1, PlanterName2, PlanterName3
		, PlanterField1, PlanterField2, PlanterField3
		, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, PlanterNectar1, PlanterNectar2, PlanterNectar3
		, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
		, MPlanterHold1, MPlanterHold2, MPlanterHold3
		, MPlanterSmoking1, MPlanterSmoking2, MPlanterSmoking3

	Loop 3
	{
		PlanterName%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterName" A_Index, "None")
		PlanterField%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterField" A_Index, "None")
		PlanterHarvestTime%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index, "20211106000000")
		PlanterNectar%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterNectar" A_Index, "None")
		PlanterEstPercent%A_Index% := IniRead("settings\nm_config.ini", "Planters", "PlanterEstPercent" A_Index, 0)
		if (PlanterName%A_Index% && (PlanterName%A_Index% != "None"))
			planters++
	}

	for i,j in ["comforting","motivating","satisfying","refreshing","invigorating"]
	{
		color := (j = "comforting") ? 0xff7e9eb3
			: (j = "motivating") ? 0xff937db3
			: (j = "satisfying") ? 0xffb398a7
			: (j = "refreshing") ? 0xff78b375
			: 0xffb35951 ; invigorating

		nectar_value := 0
		Loop 601
		{
			if (buff_values[j].Has(601-A_Index) && (buff_values[j][601-A_Index] > 0))
			{
				nectar_value := buff_values[j][601-A_Index]
				break
			}
		}

		projected_value := 0
		Loop 3
			projected_value += (PlanterNectar%A_Index% = j) ? (PlanterEstPercent%A_Index% - Max(PlanterHarvestTime%A_Index% - unix_now, 0)/864) : 0
		projected_value := Max(Min(projected_value, 100-nectar_value), 0)

		pPen := Gdip_CreatePen(color, 32), Gdip_DrawArc(G, pPen, stat_regions["buffs"][1]+50+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4, stat_regions["buffs"][2]+410, 200, 200, -90, nectar_value/100*360), Gdip_DeletePen(pPen)

		pBrush := Gdip_BrushCreateHatch(color, color-0xa0000000, 34), pPen := Gdip_CreatePenFromBrush(pBrush, 32), Gdip_DeleteBrush(pBrush), Gdip_DrawArc(G, pPen, stat_regions["buffs"][1]+50+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4, stat_regions["buffs"][2]+410, 200, 200, -90-1+nectar_value/100*360, projected_value/100*360+1), Gdip_DeletePen(pPen)

		pPen := Gdip_CreatePen(color-0xd0000000, 32), Gdip_DrawArc(G, pPen, stat_regions["buffs"][1]+50+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4, stat_regions["buffs"][2]+410, 200, 200, -90-1+(nectar_value+projected_value)/100*360, 360+2-(nectar_value+projected_value)/100*360), Gdip_DeletePen(pPen)

		pBrush := Gdip_BrushCreateSolid(color)
		Gdip_TextToGraphics(G, nectar_value "%", "s54 Center Bold c" pBrush " x" stat_regions["buffs"][1]+150+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4 " y" stat_regions["buffs"][2]+(projected_value ? 456 : 472), "Segoe UI")
		Gdip_TextToGraphics(G, Format("{1:Us}", SubStr(j, 1, 3)), "s48 Center Bold c" pBrush " x" stat_regions["buffs"][1]+150+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4 " y" stat_regions["buffs"][2]+630, "Segoe UI")
		Gdip_DeleteBrush(pBrush)

		if projected_value
		{
			pBrush := Gdip_BrushCreateSolid(color-0x40000000)
			Gdip_TextToGraphics(G, "(+" Round(projected_value) "%)", "s28 Center Bold c" pBrush " x" stat_regions["buffs"][1]+150+(A_Index-1)*(stat_regions["buffs"][3]-100-200)/4 " y" stat_regions["buffs"][2]+516, "Segoe UI")
			Gdip_DeleteBrush(pBrush)
		}
	}

	; section 4: planters
	Gdip_TextToGraphics(G, "PLANTERS", "s64 Center Bold cffffffff x" stat_regions["planters"][1]+stat_regions["planters"][3]//2 " y" stat_regions["planters"][2]+4, "Segoe UI")

	if planters
	{
		i := 0
		Loop 3
		{
			if (PlanterName%A_Index% = "None")
				continue

			i++
			Gdip_DrawImage(G, bitmaps["pBM" PlanterName%A_Index%], stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i-1)*440, stat_regions["planters"][2]+110, 220, 220)

			pos := Gdip_TextToGraphics(G, PlanterField%A_Index%, "s52 Center Bold cffffffff x" stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i-1)*440+74 " y" stat_regions["planters"][2]+340, "Segoe UI")
			x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
			Gdip_DrawImage(G, bitmaps["pBM" ((PlanterNectar%A_Index% = "None") ? "Unknown" : PlanterNectar%A_Index%)], x+6, stat_regions["planters"][2]+348, 60, 60)

			MPlanterHold%i% := IniRead("settings\nm_config.ini", "Planters", "MPlanterHold" i)
			MPlanterSmoking%i% := IniRead("settings\nm_config.ini", "Planters", "MPlanterSmoking" i)
			PlanterMode := IniRead("settings\nm_config.ini", "Planters", "PlanterMode")
			duration := ((time := PlanterHarvestTime%A_Index% - unix_now) > 360000) ? "N/A" : (time > 0) ? hmsFromSeconds(PlanterHarvestTime%A_Index% - unix_now) : (((MPlanterSmoking%i%) && (PlanterMode = 1)) ? "Smoking" : ((MPlanterHold%i%) && (PlanterMode = 1)) ? "Holding" :  "Ready")
			pos := Gdip_TextToGraphics(G, duration, "s46 Center Bold ccfffffff x" stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i-1)*440+130 " y" stat_regions["planters"][2]+406, "Segoe UI")
			x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)
			Gdip_DrawImage(G, bitmaps["pBMTimer"], x-60, stat_regions["planters"][2]+410, 56, 56, , , , , 0.811765)

			if (i >= planters)
				break
		}
		Loop (planters - i)
		{
			Gdip_DrawImage(G, bitmaps["pBMUnknown"], stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i+A_Index-1)*440, stat_regions["planters"][2]+110, 220, 220)

			pos := Gdip_TextToGraphics(G, "None", "s52 Center Bold cffffffff x" stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i+A_Index-1)*440+74 " y" stat_regions["planters"][2]+340, "Segoe UI")
			x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
			Gdip_DrawImage(G, bitmaps["pBMUnknown"], x+6, stat_regions["planters"][2]+348, 60, 60)

			pos := Gdip_TextToGraphics(G, "N/A", "s46 Center Bold ccfffffff x" stat_regions["planters"][1]+stat_regions["planters"][3]//2-(110+220*(planters-1))+(i+A_Index-1)*440+130 " y" stat_regions["planters"][2]+406, "Segoe UI")
			x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)
			Gdip_DrawImage(G, bitmaps["pBMTimer"], x-60, stat_regions["planters"][2]+410, 56, 56, , , , , 0.811765)
		}
	}

	; section 5: stats
	pos := Gdip_TextToGraphics(G, "STATS", "s64 Center Bold cffffffff x" stat_regions["stats"][1]+stat_regions["stats"][3]//2 " y" stat_regions["stats"][2]+4, "Segoe UI")
	y := SubStr(pos, InStr(pos, "|", , , 1)+1, InStr(pos, "|", , , 2)-InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 3)+1, InStr(pos, "|", , , 4)-InStr(pos, "|", , , 3)-1)+4

	for i,j in stats
	{
		Gdip_TextToGraphics(G, j[1], "s60 Right Bold ccfffffff x" stat_regions["stats"][1]+stat_regions["stats"][3]//2-40 " y" y, "Segoe UI")
		pos := Gdip_TextToGraphics(G, j[2], "s60 Left Bold cffffffff x" stat_regions["stats"][1]+stat_regions["stats"][3]//2+40 " y" y, "Segoe UI")
		if (j[2] > stats_old[i][2])
		{
			x := stat_regions["stats"][1]+stat_regions["stats"][3]//2+240
			pBrush := Gdip_BrushCreateSolid((j[1] = "Disconnects") ? 0xffff0000 : 0xff00ff00), Gdip_FillPolygon(G, pBrush, [[x+45, y+23], [x+20, y+65], [x+70, y+65]]), Gdip_DeleteBrush(pBrush)
			x := stat_regions["stats"][1]+stat_regions["stats"][3]//2+312
			Gdip_TextToGraphics(G, j[2]-stats_old[i][2], "s40 Left Bold cafffffff x" x " y" y+16, "Segoe UI")
		}
		else
		{
			pBrush := Gdip_BrushCreateSolid(0xff666666)
			Gdip_FillRoundedRectangle(G, pBrush, stat_regions["stats"][1]+stat_regions["stats"][3]//2+260, y+36, 50, 12, 6)
			Gdip_DeleteBrush(pBrush)
		}
		y := SubStr(pos, InStr(pos, "|", , , 1)+1, InStr(pos, "|", , , 2)-InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 3)+1, InStr(pos, "|", , , 4)-InStr(pos, "|", , , 3)-1)-4
	}

	; section 6: info
	; row 1: statmonitor and natro version
	y := stat_regions["info"][2]+60
	pos := Gdip_TextToGraphics(G, "StatMonitor v" version " by SP", "s56 Center Bold c00ffffff x" stat_regions["info"][1]+stat_regions["info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)

	pos := Gdip_TextToGraphics(G, "StatMonitor v" version " by ", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)

	pos := Gdip_TextToGraphics(G, "SP", "s56 Left Bold cffff5f1f x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)

	; row 2: report timestamp
	y := stat_regions["info"][2]+140
	FormatStr := Buffer(256), DllCall("GetLocaleInfoEx", "Ptr",0, "UInt",0x20, "Ptr",FormatStr.Ptr, "Int",256)
	DateStr := Buffer(512), DllCall("GetDateFormatEx", "Ptr",0, "UInt",0, "Ptr",0, "Str",StrReplace(StrReplace(StrReplace(StrReplace(StrGet(FormatStr), ", dddd"), "dddd, "), " dddd"), "dddd "), "Ptr",DateStr.Ptr, "Int",512, "Ptr",0)
	pos := Gdip_TextToGraphics(G, times[1] " - " times[7] " • " StrGet(DateStr), "s56 Center Bold c00ffffff x" stat_regions["info"][1]+stat_regions["info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)

	pos := Gdip_TextToGraphics(G, times[1] " - " times[7] " ", "s56 Left Bold cffffda3d x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)

	pos := Gdip_TextToGraphics(G, "•", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)

	Gdip_TextToGraphics(G, StrGet(DateStr), "s56 Left Bold cffffda3d x" x " y" y, "Segoe UI")

	; row 3: OCR status
	y := stat_regions["info"][2]+220
	pos := Gdip_TextToGraphics(G, "OCR: " (ocr_enabled ? ("Enabled (" ocr_language ")") : ("Disabled")), "s56 Center Bold c00ffffff x" stat_regions["info"][1]+stat_regions["info"][3]//2 " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)

	pos := Gdip_TextToGraphics(G, "OCR: ", "s56 Left Bold cafffffff x" x " y" y, "Segoe UI")
	x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)

	Gdip_TextToGraphics(G, (ocr_enabled ? ("Enabled (" ocr_language ")") : ("Disabled")), "s56 Left Bold c" (ocr_enabled ? "ff4fdf26" : "ffcc0000") " x" x " y" y, "Segoe UI")

	; row 4: windows version
	y := stat_regions["info"][2]+300
	Gdip_TextToGraphics(G, os_version, "s56 Center Bold cff04b4e4 x" stat_regions["info"][1]+stat_regions["info"][3]//2 " y" y, "Segoe UI")

	; row 5: natro information
	if IsSet(natro_version)
	{
		y := stat_regions["info"][2]+380
		x := stat_regions["info"][1]+stat_regions["info"][3]//2-50

		pos := Gdip_TextToGraphics(G, "Natro v" natro_version, "s56 Left Bold c00ffffff x" x " y" y, "Segoe UI")
		x -= SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)/2
		pos := Gdip_TextToGraphics(G, "discord.gg/natromacro", "s56 Left Bold c00ffffff x" x " y" y, "Segoe UI")
		x -= SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)/2

		pos := Gdip_TextToGraphics(G, "discord.gg/natromacro", "s56 Left Bold Underline cff3366cc x" x " y" y, "Segoe UI")
		x := SubStr(pos, 1, InStr(pos, "|", , , 1)-1)+SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)
		Gdip_DrawImage(G, bitmaps["pBMNatroLogo"], x+10, y, 80, 80)
		Gdip_TextToGraphics(G, "Natro v" natro_version, "s56 Left Bold cffb47bd1 x" x+100 " y" y, "Segoe UI")
	}

	Gdip_DeleteGraphics(G)

	webhook := IniRead("settings\nm_config.ini", "Status", "webhook")
	bottoken := IniRead("settings\nm_config.ini", "Status", "bottoken")
	discordMode := IniRead("settings\nm_config.ini", "Status", "discordMode")
	ReportChannelID := IniRead("settings\nm_config.ini", "Status", "ReportChannelID")
	if (StrLen(ReportChannelID) < 17)
		ReportChannelID := IniRead("settings\nm_config.ini", "Status", "MainChannelID")

	try
	{
		chars := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		chars := Sort(chars, "D| Random")
		boundary := SubStr(StrReplace(chars, "|"), 1, 12)
		hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
		DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream:=0, "UInt")

		str :=
		(
		'
		------------------------------' boundary '
		Content-Disposition: form-data; name="payload_json"
		Content-Type: application/json

		{
			"embeds": [{
				"title": "**[' A_Hour ':' A_Min ':00] Hourly Report**",
				"color": "14052794",
				"image": {"url": "attachment://file.png"}
			}]
		}
		------------------------------' boundary '
		Content-Disposition: form-data; name="files[0]"; filename="file.png"
		Content-Type: image/png

		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")

		pFileStream := Gdip_SaveBitmapToStream(pBMReport)
		DllCall("shlwapi\IStream_Size", "Ptr", pFileStream, "UInt64P", &size:=0, "UInt")
		DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
		DllCall("shlwapi\IStream_Copy", "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
		ObjRelease(pFileStream)

		str :=
		(
		'

		------------------------------' boundary '--
		'
		)

		utf8 := Buffer(length := StrPut(str, "UTF-8") - 1), StrPut(str, utf8, length, "UTF-8")
		DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8.Ptr, "UInt", length, "UInt")
		ObjRelease(pStream)

		pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
		size := DllCall("GlobalSize", "Ptr", pData, "UPtr")

		retData := ComObjArray(0x11, size)
		pvData := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
		DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)

		DllCall("GlobalUnlock", "Ptr", hData)
		DllCall("GlobalFree", "Ptr", hData, "Ptr")
		contentType := "multipart/form-data; boundary=----------------------------" boundary

		wr := ComObject("WinHttp.WinHttpRequest.5.1")
		wr.Option[9] := 2720
		wr.Open("POST", (discordMode = 0) ? webhook : ("https://discord.com/api/v10/channels/" ReportChannelID "/messages"), 0)
		if (discordMode = 1)
		{
			wr.SetRequestHeader("User-Agent", "DiscordBot (AHK, " A_AhkVersion ")")
			wr.SetRequestHeader("Authorization", "Bot " bottoken)
		}
		wr.SetRequestHeader("Content-Type", contentType)
		wr.SetTimeouts(0, 60000, 120000, 30000)
		wr.Send(retData)
	}
	catch as e
	{
		message := "**[" A_Hour ":" A_Min ":" A_Sec "]**`n"
		. "**Failed to send Hourly Report!**`n"
		. "Gdip SaveBitmap Error: " result "`n`n"
		. "Exception Properties:`n"
		. ">>> What: " e.what "`n"
		. "File: " e.file "`n"
		. "Line: " e.line "`n"
		. "Message: " e.message "`n"
		. "Extra: " e.extra
		message := StrReplace(StrReplace(message, "\", "\\"), "`n", "\n")

		postdata :=
		(
		'
		{
			"embeds": [{
				"description": "' message '",
				"color": "15085139"
			}]
		}
		'
		)

		Send_WM_COPYDATA(postdata, "Status.ahk ahk_class AutoHotkey")
	}

	Gdip_DisposeImage(pBMReport)

	; save old stats for comparison
	for k,v in stats_old
		v[2] := stats[k][2]
	; reset honey values map
	honey_values.Clear()
	honey_values[0] := current_honey
	; reset backpack values map
	for k,v in backpack_values
		if (A_Index = backpack_values.Count)
			current_backpack := v
	backpack_values.Clear()
	backpack_values[0] := current_backpack
	; reset status changes array
	for k,v in status_changes
		if (A_Index = status_changes.Count)
			current_status := v
	status_changes.Clear()
	status_changes[0] := current_status
	; reset buff values array
	for k,v in buff_values
		v.Clear()
}

/*************************************************************************************************************
* @description: rounds a number (integer/float) to 4 s.f. and abbreviates it with common large number prefixes
* @returns: (string) result
* @author SP
*************************************************************************************************************/
FormatNumber(n)
{
	static numnames := ["M","B","T","Qa","Qi"]
	digit := floor(log(abs(n)))+1
	if (digit > 6)
	{
		numname := (digit-4)//3
		numstring := SubStr((round(n,4-digit)) / 10**(3*numname+3), 1, 5)
		numformat := (SubStr(numstring, 0) = ".") ? 1.000 : numstring, numname += (SubStr(numstring, 0) = ".") ? 1 : 0
		num := SubStr((round(n,4-digit)) / 10**(3*numname+3), 1, 5) " " numnames[numname]
	}
	else
	{
		num := Buffer(32), DllCall("GetNumberFormatEx","str","!x-sys-default-locale","uint",0,"str",n,"ptr",0,"Ptr",num.Ptr,"int",32)
		num := SubStr(StrGet(num), 1, -3)
	}
	return num
}

/**************************************************************************************************
* @description: responsible for receiving messages from the main macro script to set current status
* @param: wParam is the status number, lParam is the second of the hour when status started
* @author SP
**************************************************************************************************/
SetStatus(wParam, lParam, *){
	for k,v in status_changes
		if (lParam < k)
			return 0
	status_changes[lParam] := wParam
	return 0
}

/***********************************************************************************************
* @description: responsible for receiving messages from the main macro script to increment stats
* @param: wParam is the stat to be incrememted, lParam is the amount
* @author SP
***********************************************************************************************/
IncrementStat(wParam, lParam, *){
	stats[wParam][2] += lParam
	return 0
}

/************************************************************************************************************
* @description: receives messages from the background script to update ability values (pop/scorch star, etc.)
* @param: wParam is the ability (buff) to be changed, lParam is the value
* @author SP
************************************************************************************************************/
SetAbility(wParam, lParam, *){
	static arr := ["popstar"]
	time_value := (60*A_Min+A_Sec)//6, i := (time_value = 0) ? 600 : time_value
	buff_values[arr[wParam]][i] := lParam
	return 0
}

/**********************************************************************************************************
* @description: receives messages from the background script to set the current (filtered) backpack percent
* @param: wParam is the backpack percent, lParam is the second of the hour
* @author SP
**********************************************************************************************************/
SetBackpack(wParam, lParam, *){
	for k,v in backpack_values
		if (lParam < k)
			return 0
	backpack_values[lParam] := wParam
	return 0
}

/***************************************************************************************
* @description: these functions return the minimum and maximum values in maps and arrays
* @author modified versions of functions by FanaticGuru
* @url https://www.autohotkey.com/boards/viewtopic.php?t=40898
***************************************************************************************/
minX(List)
{
	List.__Enum().Call(, &X)
	for key, element in List
		if (IsNumber(element) && (element < X))
			X := element
	return X
}
maxX(List)
{
	List.__Enum().Call(, &X)
	for key, element in List
		if (IsNumber(element) && (element > X))
			X := element
	return X
}

/*************************************************************
* @description: OCR with UWP API
* @author malcev, teadrinker
* @url https://www.autohotkey.com/boards/viewtopic.php?t=72674
*************************************************************/
HBitmapToRandomAccessStream(hBitmap) {
	static IID_IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
			, IID_IPicture            := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"
			, PICTYPE_BITMAP := 1
			, BSOS_DEFAULT   := 0
			, sz := 8 + A_PtrSize * 2

	DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", &pIStream:=0, "UInt")

	PICTDESC := Buffer(sz, 0)
	NumPut("uint", sz
		, "uint", PICTYPE_BITMAP
		, "ptr", hBitmap, PICTDESC)

	riid := CLSIDFromString(IID_IPicture)
	DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", PICTDESC, "Ptr", riid, "UInt", false, "PtrP", &pIPicture:=0, "UInt")
	; IPicture::SaveAsFile
	ComCall(15, pIPicture, "Ptr", pIStream, "UInt", true, "UIntP", &size:=0, "UInt")
	riid := CLSIDFromString(IID_IRandomAccessStream)
	DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", pIStream, "UInt", BSOS_DEFAULT, "Ptr", riid, "PtrP", &pIRandomAccessStream:=0, "UInt")
	ObjRelease(pIPicture)
	ObjRelease(pIStream)
	Return pIRandomAccessStream
}

CLSIDFromString(IID, &CLSID?) {
	CLSID := Buffer(16)
	if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", CLSID, "UInt")
	throw Error("CLSIDFromString failed. Error: " . Format("{:#x}", res))
	Return CLSID
}

ocr(file, lang := "FirstFromAvailableLanguages")
{
	static OcrEngineStatics, OcrEngine, MaxDimension, LanguageFactory, Language, CurrentLanguage:="", BitmapDecoderStatics, GlobalizationPreferencesStatics
	if !IsSet(OcrEngineStatics)
	{
		CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", &LanguageFactory)
		CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", &BitmapDecoderStatics)
		CreateClass("Windows.Media.Ocr.OcrEngine", IOcrEngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}", &OcrEngineStatics)
		ComCall(6, OcrEngineStatics, "uint*", &MaxDimension:=0)
	}
	text := ""
	if (file = "ShowAvailableLanguages")
	{
		if !IsSet(GlobalizationPreferencesStatics)
			CreateClass("Windows.System.UserProfile.GlobalizationPreferences", IGlobalizationPreferencesStatics := "{01BF4326-ED37-4E96-B0E9-C1340D1EA158}", &GlobalizationPreferencesStatics)
		ComCall(9, GlobalizationPreferencesStatics, "ptr*", &LanguageList:=0)   ; get_Languages
		ComCall(7, LanguageList, "int*", &count:=0)   ; count
		loop count
		{
			ComCall(6, LanguageList, "int", A_Index-1, "ptr*", &hString:=0)   ; get_Item
			ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &LanguageTest:=0)   ; CreateLanguage
			ComCall(8, OcrEngineStatics, "ptr", LanguageTest, "int*", &bool:=0)   ; IsLanguageSupported
			if (bool = 1)
			{
				ComCall(6, LanguageTest, "ptr*", &hText:=0)
				b := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
				text .= StrGet(b, "UTF-16") "`n"
			}
			ObjRelease(LanguageTest)
		}
		ObjRelease(LanguageList)
		return text
	}
	if (lang != CurrentLanguage) or (lang = "FirstFromAvailableLanguages")
	{
		if IsSet(OcrEngine)
		{
			ObjRelease(OcrEngine)
			if (CurrentLanguage != "FirstFromAvailableLanguages")
				ObjRelease(Language)
		}
		if (lang = "FirstFromAvailableLanguages")
			ComCall(10, OcrEngineStatics, "ptr*", OcrEngine)   ; TryCreateFromUserProfileLanguages
		else
		{
			CreateHString(lang, &hString)
			ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &Language:=0)   ; CreateLanguage
			DeleteHString(hString)
			ComCall(9, OcrEngineStatics, "ptr", Language, "ptr*", &OcrEngine:=0)   ; TryCreateFromLanguage
		}
		if (OcrEngine = 0)
		{
			msgbox 'Can not use language "' lang '" for OCR, please install language pack.'
			ExitApp
		}
		CurrentLanguage := lang
	}
	IRandomAccessStream := file
	ComCall(14, BitmapDecoderStatics, "ptr", IRandomAccessStream, "ptr*", &BitmapDecoder:=0)   ; CreateAsync
	WaitForAsync(&BitmapDecoder)
	BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
	ComCall(12, BitmapFrame, "uint*", &width:=0)   ; get_PixelWidth
	ComCall(13, BitmapFrame, "uint*", &height:=0)   ; get_PixelHeight
	if (width > MaxDimension) or (height > MaxDimension)
	{
		msgbox 'Image is to big - ' width 'x' height '.`nIt should be maximum - ' MaxDimension ' pixels'
		ExitApp
	}
	BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
	ComCall(6, BitmapFrameWithSoftwareBitmap, "ptr*", &SoftwareBitmap:=0)   ; GetSoftwareBitmapAsync
	WaitForAsync(&SoftwareBitmap)
	ComCall(6, OcrEngine, "ptr", SoftwareBitmap, "ptr*", &OcrResult:=0)   ; RecognizeAsync
	WaitForAsync(&OcrResult)
	ComCall(6, OcrResult, "ptr*", &LinesList:=0)   ; get_Lines
	ComCall(7, LinesList, "int*", &count:=0)   ; count
	loop count
	{
		ComCall(6, LinesList, "int", A_Index-1, "ptr*", &OcrLine:=0)
		ComCall(7, OcrLine, "ptr*", &hText:=0)
		buf := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", &length:=0, "ptr")
		text .= StrGet(buf, "UTF-16") "`n"
		ObjRelease(OcrLine)
	}
	Close := ComObjQuery(IRandomAccessStream, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
	ComCall(6, Close)   ; Close
	Close := ComObjQuery(SoftwareBitmap, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
	ComCall(6, Close)   ; Close
	ObjRelease(IRandomAccessStream)
	ObjRelease(BitmapDecoder)
	ObjRelease(SoftwareBitmap)
	ObjRelease(OcrResult)
	ObjRelease(LinesList)
	return text
}

CreateClass(str, interface, &Class)
{
	CreateHString(str, &hString)
	GUID := CLSIDFromString(interface)
	result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", GUID, "ptr*", &Class:=0)
	if (result != 0)
	{
		if (result = 0x80004002)
			msgbox "No such interface supported"
		else if (result = 0x80040154)
			msgbox "Class not registered"
		else
			msgbox "error: " result
	}
	DeleteHString(hString)
}

CreateHString(str, &hString)
{
	DllCall("Combase.dll\WindowsCreateString", "wstr", str, "uint", StrLen(str), "ptr*", &hString:=0)
}

DeleteHString(hString)
{
	DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}

WaitForAsync(&Object)
{
	AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
	loop
	{
		ComCall(7, AsyncInfo, "uint*", &status:=0)   ; IAsyncInfo.Status
		if (status != 0)
		{
			if (status != 1)
			{
				ComCall(8, AsyncInfo, "uint*", &ErrorCode:=0)   ; IAsyncInfo.ErrorCode
				msgbox "AsyncInfo status error: " ErrorCode
				ExitApp
			}
			break
		}
		sleep 10
	}
	ComCall(8, Object, "ptr*", &ObjectResult:=0)   ; GetResults
	ObjRelease(Object)
	Object := ObjectResult
}

Send_WM_COPYDATA(StringToSend, TargetScriptTitle, wParam:=0)
{
	CopyDataStruct := Buffer(3*A_PtrSize)
	SizeInBytes := (StrLen(StringToSend) + 1) * 2
	NumPut("Ptr", SizeInBytes
		, "Ptr", StrPtr(StringToSend)
		, CopyDataStruct, A_PtrSize)
	DetectHiddenWindows 1
	try ret := SendMessage(0x004A, wParam, CopyDataStruct,, TargetScriptTitle)
	DetectHiddenWindows 0
	return IsSet(ret) ? ret : 0
}
