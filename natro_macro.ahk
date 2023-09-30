/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © 2022-2023 Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

;Compiler directives:
;@Ahk2Exe-SetName Natro Macro
;@Ahk2Exe-SetDescription Natro Macro
;@Ahk2Exe-SetCompanyName Natro Team
;@Ahk2Exe-SetCopyright Copyright © 2022-2023 Natro Team
;@Ahk2Exe-SetOrigFilename natro_macro.exe

#NoEnv
#MaxThreads 255
#SingleInstance Force
#Requires AutoHotkey v1.1.36.01+

#Include %A_ScriptDir%\lib\Gdip_All.ahk
#Include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk

SetBatchLines -1
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

; checks for the correct AHK version before starting
RunWith(32)
RunWith(bits) {
	If (A_IsCompiled || (A_IsUnicode && (A_PtrSize = (bits = 32 ? 4 : 8))))
		Return

	SplitPath, A_AhkPath,, ahkDirectory

	If (!FileExist(ahkPath := ahkDirectory "\AutoHotkeyU" bits ".exe"))
		MsgBox, 0x10, "Error", % "Couldn't find the " bits "-bit Unicode version of Autohotkey in:`n" ahkPath
	Else
		Reload(ahkpath)

	ExitApp
}
Reload(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run % """" ahkpath """ /r " params
}

; elevate script if required (check write permissions in ScriptDir)
h := DllCall("CreateFile", "Str", A_ScriptFullPath, "UInt", 0x40000000, "UInt", 0, "UInt", 0, "UInt", 4, "UInt", 0, "UInt", 0), DllCall("CloseHandle", "UInt", h)
if (h = -1)
{
	if (!A_IsAdmin || !(DllCall("GetCommandLine","Str") ~= " /restart(?!\S)"))
		Try RunWait, *RunAs "%A_AhkPath%" /script /restart "%A_ScriptFullPath%"
	if !A_IsAdmin {
		MsgBox, 0x40010, Error, You must run Natro Macro as administrator in this folder!`nIf you don't want to do this, move the macro to a different folder (e.g. Downloads, Desktop)
		ExitApp
	}
	; elevated but still can't write, read-only directory?
	MsgBox, 0x40010, Error, You cannot run Natro Macro in this folder!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)
}

; declare executable paths
global exe_path32 := A_AhkPath
global exe_path64 := (A_Is64bitOS && FileExist("submacros\AutoHotkeyU64.exe")) ? (A_ScriptDir "\submacros\AutoHotkeyU64.exe") : A_AhkPath

; close any remnant running natro scripts and start heartbeat
DetectHiddenWindows, On
SetTitleMatchMode, 2
WinGet, script_list, List, % A_ScriptDir " ahk_class AutoHotkey"
	Loop %script_list%
		if (((script_hwnd := script_list%A_Index%) != A_ScriptHwnd) && (script_hwnd != A_Args[2]))
			WinClose, ahk_id %script_hwnd%
if !WinExist("Heartbeat.ahk ahk_class AutoHotkey")
	run, "%exe_path32%" /script "submacros\Heartbeat.ahk"
DetectHiddenWindows, Off
SetTitleMatchMode, 1

OnMessage(0x004A, "nm_WM_COPYDATA")
OnMessage(0x5550, "nm_ForceLabel", 255)
OnMessage(0x5551, "nm_setShiftLock", 255)
OnMessage(0x5552, "nm_setGlobalInt", 255)
OnMessage(0x5553, "nm_setGlobalStr", 255)
OnMessage(0x5555, "nm_backgroundEvent", 255)
OnMessage(0x5556, "nm_sendHeartbeat")
OnMessage(0x5557, "nm_ForceReconnect")
OnMessage(0x5558, "nm_AmuletPrompt")

;run, test.ahk
pToken := Gdip_Startup()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE CONFIG FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If (!FileExist("settings")) ; make sure the settings folder exists
{
	FileCreateDir, settings
	If (ErrorLevel)
	{
		MsgBox, 0x40010, Error, Could not create the settings directory!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)
		ExitApp
	}
}

VersionID := "0.9.6"
currentWalk := {"pid":"", "name":""} ; stores "pid" (script process ID) and "name" (pattern/movement name)

;initial load warnings
if (A_ScreenDPI*100//96 != 100)
	msgbox, 0x1030, WARNING!!, % "Your Display Scale seems to be a value other than 100`%. This means the macro will NOT work correctly!`n`nTo change this, right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100`% -> Close and Restart Roblox before starting the macro.", 60

DetectHiddenWindows, On
lp_PID := nm_LoadingProgress()
PostMessage, 0x5555, 0, 0, , ahk_pid %lp_PID%

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IMPORT PATTERNS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; assign keys
FwdKey:="sc011" ; w
LeftKey:="sc01e" ; a
BackKey:="sc01f" ; s
RightKey:="sc020" ; d
RotLeft:="sc033" ; ,
RotRight:="sc034" ; .
RotUp:="sc149" ; PgUp
RotDown:="sc151" ; PgDn
ZoomIn:="sc017" ; i
ZoomOut:="sc018" ; o
SC_E:="sc012" ; e
SC_R:="sc013" ; r
SC_L:="sc026" ; l
SC_Esc:="sc001" ; Esc
SC_Enter:="sc01c" ; Enter
SC_LShift:="sc02a" ; LShift
SC_Space:="sc039" ; Space
SC_1:="sc002" ; 1
TCFBKey:=FwdKey
AFCFBKey:=BackKey
TCLRKey:=LeftKey
AFCLRKey:=RightKey
; other default values
HiveSlot:=6
MoveMethod:="Cannon"
HiveBees:=50
KeyDelay:=20
nm_import() ; at every start of macro, import patterns
{
	global
	local import, script, stdout, file, pattern, exec, init, oldimport, new_patterns, _args

	If !FileExist("settings\imported") ; make sure the import folder exists
	{
		FileCreateDir, settings\imported
		If ErrorLevel
		{
			msgbox, 0x40010, Error, Could not create the directory for imported patterns!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)
			ExitApp
		}
	}

	import := ""
	patternlist := "|"

	Loop, Files, %A_ScriptDir%\patterns\*.ahk
	{
		file := FileOpen(A_LoopFilePath, "r"), pattern := file.Read(), file.Close()
		script := "
		(Join`r`n
		#NoEnv
		#NoTrayIcon
		#SingleInstance Off
		#Requires AutoHotkey v1.1.36.01+
		SetBatchLines -1

		TCFBKey:=FwdKey:=""" FwdKey """
		AFCFBKey:=LeftKey:=""" LeftKey """
		TCLRKey:=BackKey:=""" BackKey """
		AFCLRKey:=RightKey:=""" RightKey """
		RotLeft:=""" RotLeft """
		RotRight:=""" RotRight """
		RotUp:=""" RotUp """
		RotDown:=""" RotDown """
		ZoomIn:=""" ZoomIn """
		ZoomOut:=""" ZoomOut """
		SC_E:=""" SC_E """
		SC_R:=""" SC_R """
		SC_L:=""" SC_L """
		SC_Esc:=""" SC_Esc """
		SC_Enter:=""" SC_Enter """
		SC_LShift:=""" SC_LShift """
		SC_Space:=""" SC_Space """
		SC_1:=""" SC_1 """
		HiveSlot:=""" HiveSlot """
		MoveMethod:=""" MoveMethod """
		HiveBees:=""" HiveBees """
		KeyDelay:=""" KeyDelay """

		size:=1, reps:=1, facingcorner:=0

		patterns := {}
		pattern := " pattern "

		script := ""
		(Join``r``n
		#SingleInstance Off
		#Requires AutoHotkey v1.1.36.01+
		"" pattern ""

		Walk(param1, param2:=0)
		{
		}

		HyperSleep(param1)
		{
		}
		`)""

		exec := ComObjCreate(""WScript.Shell"").Exec(A_AhkPath "" /script /iLib nul /ErrorStdOut *""), exec.StdIn.Write(script), exec.StdIn.Close()
		if (stdout := exec.StdErr.ReadAll())
			FileAppend, % stdout, **

		nm_Walk(tiles, MoveKey1, MoveKey2:=0)
		{
			return ""
			(LTrim Join``r``n
			Send {"" MoveKey1 "" down}"" (MoveKey2 ? ""{"" MoveKey2 "" down}"" : """") ""
			Walk("" tiles "")
			Send {"" MoveKey1 "" up}"" (MoveKey2 ? ""{"" MoveKey2 "" up}"" : """") ""
			`)""
		}
		)"

		exec := ComObjCreate("WScript.Shell").Exec(exe_path64 " /script /ErrorStdOut *"), exec.StdIn.Write(script), exec.StdIn.Close()
		if (stdout := exec.StdErr.ReadAll())
			msgbox, 0x40010, Unable to Import Pattern!, % "Unable to import '" StrReplace(A_LoopFileName, ".ahk") "' pattern! Click 'OK' to continue loading the macro without this pattern installed, otherwise fix the error and reload the macro.`r`n`r`nThe error found on loading is stated below:`r`n" stdout, 60
		else
		{
			import .= pattern "`r`n`r`n"
			patternlist .= StrReplace(A_LoopFileName, ".ahk") "|"
		}
	}

	init := (!FileExist(A_ScriptDir "\settings\imported\patterns.ahk") && import) ? 1 : 0
	file := FileOpen(A_ScriptDir "\settings\imported\patterns.ahk", "r-d"), oldimport := file.Read(), file.Close()
	if (import != oldimport)
	{
		file := FileOpen(A_ScriptDir "\settings\imported\patterns.ahk", "w-d"), file.Write(import), file.Close()
		new_patterns := import ? 1 : 0
	}

	if init
	{
		WinClose, ahk_pid %lp_PID% ahk_class AutoHotkey
		Reload(A_AhkPath)
		Sleep, 10000
	}

	if new_patterns
	{
		msgbox, 0x1034, , % "Change in patterns detected! Reload to update?", 30
		IfMsgBox No
			ExitApp
		else
		{
			WinClose, ahk_pid %lp_PID% ahk_class AutoHotkey
			Reload(A_AhkPath)
			Sleep, 10000
		}
	}
}
nm_import() ; import patterns
PostMessage, 0x5555, 7, 0, , ahk_pid %lp_PID%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SET CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
config := {} ; store default values, these are loaded initially

config["Gui"] := {"dayOrNight":"Day"
	, "PlanterMode":0
	, "nPreset":"Blue"
	, "MaxAllowedPlanters":3
	, "n1priority":"Comforting"
	, "n2priority":"Motivating"
	, "n3priority":"Satisfying"
	, "n4priority":"Refreshing"
	, "n5priority":"Invigorating"
	, "n1string":"||None|Comforting|Refreshing|Satisfying|Motivating|Invigorating"
	, "n2string":"||None|Refreshing|Satisfying|Motivating|Invigorating"
	, "n3string":"||None|Refreshing|Satisfying|Invigorating"
	, "n4string":"||None|Refreshing|Invigorating"
	, "n5string":"||None|Invigorating"
	, "n1minPercent":70
	, "n2minPercent":80
	, "n3minPercent":80
	, "n4minPercent":80
	, "n5minPercent":40
	, "HarvestInterval":2
	, "AutomaticHarvestInterval":0
	, "HarvestFullGrown":0
	, "GotoPlanterField":0
	, "GatherFieldSipping":0
	, "ConvertFullBagHarvest":0
	, "GatherPlanterLoot":1
	, "PlasticPlanterCheck":1
	, "CandyPlanterCheck":1
	, "BlueClayPlanterCheck":1
	, "RedClayPlanterCheck":1
	, "TackyPlanterCheck":1
	, "PesticidePlanterCheck":1
	, "HeatTreatedPlanterCheck":0
	, "HydroponicPlanterCheck":0
	, "PetalPlanterCheck":0
	, "PaperPlanterCheck":0
	, "TicketPlanterCheck":0
	, "PlanterOfPlentyCheck":0
	, "BambooFieldCheck":0
	, "BlueFlowerFieldCheck":1
	, "CactusFieldCheck":1
	, "CloverFieldCheck":1
	, "CoconutFieldCheck":0
	, "DandelionFieldCheck":1
	, "MountainTopFieldCheck":0
	, "MushroomFieldCheck":0
	, "PepperFieldCheck":1
	, "PineTreeFieldCheck":1
	, "PineappleFieldCheck":1
	, "PumpkinFieldCheck":0
	, "RoseFieldCheck":1
	, "SpiderFieldCheck":1
	, "StrawberryFieldCheck":1
	, "StumpFieldCheck":0
	, "SunflowerFieldCheck":1
	, "TimerGuiTransparency":0
	, "TimerX":150
	, "TimerY":150
	, "TimersOpen":0}

config["Settings"] := {"GuiTheme":"MacLion3"
	, "AlwaysOnTop":0
	, "MoveSpeedNum":28
	, "MoveMethod":"Cannon"
	, "SprinklerType":"Supreme"
	, "MultiReset":0
	, "ConvertBalloon":"Always"
	, "ConvertMins":30
	, "LastConvertBalloon":1
	, "GatherDoubleReset":1
	, "DisableToolUse":0
	, "AnnounceGuidingStar":0
	, "NewWalk":1
	, "HiveSlot":6
	, "HiveBees":50
	, "ConvertDelay":0
	, "PrivServer":""
	, "FallbackServer1":""
	, "FallbackServer2":""
	, "FallbackServer3":""
	, "ReconnectInterval":""
	, "ReconnectHour":""
	, "ReconnectMin":""
	, "ReconnectMessage":0
	, "PublicFallback":1
	, "GuiX":""
	, "GuiY":""
	, "GuiTransparency":0
	, "BuffDetectReset":0
	, "ClickCount":1000
	, "ClickDelay":10
	, "ClickMode":0
	, "KeyDelay":20
	, "StartHotkey":"F1"
	, "PauseHotkey":"F2"
	, "StopHotkey":"F3"
	, "AutoClickerHotkey":"F4"
	, "TimersHotkey":"F5"
	, "ShowOnPause":0}

config["Status"] := {"StatusLogReverse":0
	, "TotalRuntime":0
	, "SessionRuntime":0
	, "TotalGatherTime":0
	, "SessionGatherTime":0
	, "TotalConvertTime":0
	, "SessionConvertTime":0
	, "TotalViciousKills":0
	, "SessionViciousKills":0
	, "TotalBossKills":0
	, "SessionBossKills":0
	, "TotalBugKills":0
	, "SessionBugKills":0
	, "TotalPlantersCollected":0
	, "SessionPlantersCollected":0
	, "TotalQuestsComplete":0
	, "SessionQuestsComplete":0
	, "TotalDisconnects":0
	, "SessionDisconnects":0
	, "DiscordMode":0
	, "DiscordCheck":0
	, "Webhook":""
	, "BotToken":""
	, "MainChannelCheck":1
	, "MainChannelID":""
	, "ReportChannelCheck":1
	, "ReportChannelID":""
	, "WebhookEasterEgg":0
	, "ssCheck":0
	, "ssDebugging":0
	, "CriticalSSCheck":1
	, "AmuletSSCheck":1
	, "MachineSSCheck":1
	, "BalloonSSCheck":1
	, "ViciousSSCheck":1
	, "DeathSSCheck":1
	, "PlanterSSCheck":1
	, "HoneySSCheck":0
	, "criticalCheck":0
	, "discordUID":""
	, "CriticalErrorPingCheck":1
	, "DisconnectPingCheck":1
	, "GameFrozenPingCheck":1
	, "PhantomPingCheck":1
	, "UnexpectedDeathPingCheck":0
	, "EmergencyBalloonPingCheck":0
	, "commandPrefix":"?"
	, "NightAnnouncementCheck":0
	, "NightAnnouncementName":""
	, "NightAnnouncementPingID":""
	, "NightAnnouncementWebhook":""
	, "DebugLogEnabled":1}

config["Gather"] := {"FieldName1":"Sunflower"
	, "FieldName2":"None"
	, "FieldName3":"None"
	, "FieldPattern1":"Squares"
	, "FieldPattern2":"Lines"
	, "FieldPattern3":"Lines"
	, "FieldPatternSize1":"M"
	, "FieldPatternSize2":"M"
	, "FieldPatternSize3":"M"
	, "FieldPatternReps1":3
	, "FieldPatternReps2":3
	, "FieldPatternReps3":3
	, "FieldPatternShift1":0
	, "FieldPatternShift2":0
	, "FieldPatternShift3":0
	, "FieldPatternInvertFB1":0
	, "FieldPatternInvertFB2":0
	, "FieldPatternInvertFB3":0
	, "FieldPatternInvertLR1":0
	, "FieldPatternInvertLR2":0
	, "FieldPatternInvertLR3":0
	, "FieldUntilMins1":20
	, "FieldUntilMins2":15
	, "FieldUntilMins3":15
	, "FieldUntilPack1":95
	, "FieldUntilPack2":95
	, "FieldUntilPack3":95
	, "FieldReturnType1":"Walk"
	, "FieldReturnType2":"Walk"
	, "FieldReturnType3":"Walk"
	, "FieldSprinklerLoc1":"Center"
	, "FieldSprinklerLoc2":"Center"
	, "FieldSprinklerLoc3":"Center"
	, "FieldSprinklerDist1":10
	, "FieldSprinklerDist2":10
	, "FieldSprinklerDist3":10
	, "FieldRotateDirection1":"None"
	, "FieldRotateDirection2":"None"
	, "FieldRotateDirection3":"None"
	, "FieldRotateTimes1":1
	, "FieldRotateTimes2":1
	, "FieldRotateTimes3":1
	, "FieldDriftCheck1":1
	, "FieldDriftCheck2":1
	, "FieldDriftCheck3":1
	, "CurrentFieldNum":1}

config["Collect"] := {"ClockCheck":1
	, "LastClock":1
	, "MondoBuffCheck":0
	, "MondoAction":"Buff"
	, "LastMondoBuff":1
	, "AntPassCheck":0
	, "AntPassAction":"Pass"
	, "LastAntPass":1
	, "RoboPassCheck":0
	, "LastRoboPass":1
	, "HoneystormCheck":0
	, "LastHoneystorm":1
	, "HoneyDisCheck":0
	, "LastHoneyDis":1
	, "TreatDisCheck":0
	, "LastTreatDis":1
	, "BlueberryDisCheck":0
	, "LastBlueberryDis":1
	, "StrawberryDisCheck":0
	, "LastStrawberryDis":1
	, "CoconutDisCheck":0
	, "LastCoconutDis":1
	, "RoyalJellyDisCheck":0
	, "LastRoyalJellyDis":1
	, "GlueDisCheck":0
	, "LastGlueDis":1
	, "BlueBoostCheck":1
	, "LastBlueBoost":1
	, "RedBoostCheck":0
	, "LastRedBoost":1
	, "MountainBoostCheck":0
	, "LastMountainBoost":1
	, "BeesmasGatherInterruptCheck":0
	, "StockingsCheck":0
	, "LastStockings":1
	, "WreathCheck":0
	, "LastWreath":1
	, "FeastCheck":0
	, "LastFeast":1
	, "RBPDelevelCheck" :0
	, "LastRBPDelevel" :1
	, "GingerbreadCheck":0
	, "LastGingerbread":1
	, "SnowMachineCheck":0
	, "LastSnowMachine":1
	, "CandlesCheck":0
	, "LastCandles":1
	, "SamovarCheck":0
	, "LastSamovar":1
	, "LidArtCheck":0
	, "LastLidArt":1
	, "GummyBeaconCheck":0
	, "LastGummyBeacon":1
	, "MonsterRespawnTime":0
	, "BugRunCheck":0
	, "BugrunInterruptCheck":0
	, "BugrunLadybugsCheck":0
	, "BugrunLadybugsLoot":0
	, "LastBugrunLadybugs":1
	, "BugrunRhinoBeetlesCheck":0
	, "BugrunRhinoBeetlesLoot":0
	, "LastBugrunRhinoBeetles":1
	, "BugrunSpiderCheck":0
	, "BugrunSpiderLoot":0
	, "LastBugrunSpider":1
	, "BugrunMantisCheck":0
	, "BugrunMantisLoot":0
	, "LastBugrunMantis":1
	, "BugrunScorpionsCheck":0
	, "BugrunScorpionsLoot":0
	, "LastBugrunScorpions":1
	, "BugrunWerewolfCheck":0
	, "BugrunWerewolfLoot":0
	, "LastBugrunWerewolf":1
	, "TunnelBearCheck":0
	, "TunnelBearBabyCheck":0
	, "LastTunnelBear":1
	, "KingBeetleCheck":0
	, "KingBeetleBabyCheck":0
	, "KingBeetleAmuletMode":1
	, "LastKingBeetle":1
	, "InputSnailHealth":100.00
	, "SnailTime":15
	, "InputChickHealth":100.00
	, "ChickTime":15
	, "StumpSnailCheck":0
	, "ShellAmuletMode":1
	, "LastStumpSnail":1
	, "CommandoCheck":0
	, "LastCommando":1
	, "CocoCrabCheck":0
	, "LastCocoCrab":1
	, "StingerCheck":0
	, "StingerPepperCheck":1
	, "StingerMountainTopCheck":1
	, "StingerRoseCheck":1
	, "StingerCactusCheck":1
	, "StingerSpiderCheck":1
	, "StingerCloverCheck":1
	, "StingerDailyBonusCheck":0
	, "NightLastDetected":1
	, "VBLastKilled":1}

config["Boost"] := {"FieldBoostStacks":0
	, "FieldBooster1":"None"
	, "FieldBooster2":"None"
	, "FieldBooster3":"None"
	, "BoostChaserCheck":0
	, "HotbarWhile2":"Never"
	, "HotbarWhile3":"Never"
	, "HotbarWhile4":"Never"
	, "HotbarWhile5":"Never"
	, "HotbarWhile6":"Never"
	, "HotbarWhile7":"Never"
	, "FieldBoosterMins":15
	, "HotbarTime2":900
	, "HotbarTime3":900
	, "HotbarTime4":900
	, "HotbarTime5":900
	, "HotbarTime6":900
	, "HotbarTime7":900
	, "HotkeyMax2":0
	, "HotkeyMax3":0
	, "HotkeyMax4":0
	, "HotkeyMax5":0
	, "HotkeyMax6":0
	, "HotkeyMax7":0
	, "LastHotkey2":1
	, "LastHotkey3":1
	, "LastHotkey4":1
	, "LastHotkey5":1
	, "LastHotkey6":1
	, "LastHotkey7":1
	, "LastWhirligig":1
	, "LastEnzymes":1
	, "LastGlitter":1
	, "LastSnowflake":1
	, "LastWindShrine":1
	, "LastMicroConverter":1
	, "LastGuid":1
	, "AutoFieldBoostActive":0
	, "AutoFieldBoostRefresh":12.5
	, "AFBDiceEnable":0
	, "AFBGlitterEnable":0
	, "AFBFieldEnable":0
	, "AFBDiceHotbar":"None"
	, "AFBGlitterHotbar":"None"
	, "AFBDiceLimitEnable":1
	, "AFBGlitterLimitEnable":1
	, "AFBHoursLimitEnable":0
	, "AFBDiceLimit":1
	, "AFBGlitterLimit":1
	, "AFBHoursLimit":.01
	, "FieldLastBoosted":1
	, "FieldLastBoostedBy":"None"
	, "FieldNextBoostedBy":"None"
	, "AFBdiceUsed":0
	, "AFBglitterUsed":0}

config["Quests"] := {"QuestGatherMins":5
	, "QuestGatherReturnBy":"Walk"
	, "PolarQuestCheck":0
	, "PolarQuestGatherInterruptCheck":1
	, "PolarQuestName":"None"
	, "PolarQuestProgress":"Unknown"
	, "HoneyQuestCheck":0
	, "HoneyQuestProgress":"Unknown"
	, "BlackQuestCheck":0
	, "BlackQuestName":"None"
	, "BlackQuestProgress":"Unknown"
	, "LastBlackQuest":1
	, "BuckoQuestCheck":0
	, "BuckoQuestGatherInterruptCheck":1
	, "BuckoQuestName":"None"
	, "BuckoQuestProgress":"Unknown"
	, "RileyQuestCheck":0
	, "RileyQuestGatherInterruptCheck":1
	, "RileyQuestName":"None"
	, "RileyQuestProgress":"Unknown"}

config["Planters"] := {"LastComfortingField":"None"
	, "LastRefreshingField":"None"
	, "LastSatisfyingField":"None"
	, "LastMotivatingField":"None"
	, "LastInvigoratingField":"None"
	, "PlanterName1":"None"
	, "PlanterName2":"None"
	, "PlanterName3":"None"
	, "PlanterField1":"None"
	, "PlanterField2":"None"
	, "PlanterField3":"None"
	, "PlanterHarvestTime1":20211106000000
	, "PlanterHarvestTime2":20211106000000
	, "PlanterHarvestTime3":20211106000000
	, "PlanterNectar1":"None"
	, "PlanterNectar2":"None"
	, "PlanterNectar3":"None"
	, "PlanterEstPercent1":0
	, "PlanterEstPercent2":0
	, "PlanterEstPercent3":0
	, "PlanterGlitter1":0
	, "PlanterGlitter2":0
	, "PlanterGlitter3":0
	, "PlanterGlitterC1":0
	, "PlanterGlitterC2":0
	, "PlanterGlitterC3":0
	, "PlanterHarvestFull1":""
	, "PlanterHarvestFull2":""
	, "PlanterHarvestFull3":""
	, "PlanterManualCycle1":1
	, "PlanterManualCycle2":1
	, "PlanterManualCycle3":1}

for k,v in config ; load the default values as globals, will be overwritten if a new value exists when reading
	for i,j in v
		%i% := j

if FileExist(A_ScriptDir "\settings\nm_config.ini") ; update default values with new ones read from any existing .ini
	nm_ReadIni(A_ScriptDir "\settings\nm_config.ini")

ini := ""
for k,v in config ; overwrite any existing .ini with updated one with all new keys and old values
{
	ini .= "[" k "]`r`n"
	for i in v
		ini .= i "=" %i% "`r`n"
	ini .= "`r`n"
}
FileDelete, %A_ScriptDir%\settings\nm_config.ini
FileAppend, %ini%, %A_ScriptDir%\settings\nm_config.ini
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NATRO ENHANCEMENT STUFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global VBState:=0
global LostPlanters:=""
global QuestFields:=""
global nectarnames:=["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
global planternames:=["PlasticPlanter", "CandyPlanter", "BlueClayPlanter", "RedClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "PlanterOfPlenty", "PaperPlanter", "TicketPlanter"]
global fieldnames:=["dandelion", "sunflower", "mushroom", "blueflower", "clover", "strawberry", "spider", "bamboo", "pineapple", "stump", "cactus", "pumpkin", "pinetree", "rose", "mountaintop", "pepper", "coconut"]

ComfortingFields:=["Dandelion", "Bamboo", "Pine Tree"]
RefreshingFields:=["Coconut", "Strawberry", "Blue Flower"]
SatisfyingFields:=["Pineapple", "Sunflower", "Pumpkin"]
MotivatingFields:=["Stump", "Spider", "Mushroom", "Rose"]
InvigoratingFields:=["Pepper", "Mountain Top", "Clover", "Cactus"]

;field planters ordered from best to worst (will always try to pick the best planter for the field)
;planters that provide no bonuses at all are ordered by worst to best so it can preserve the "better" planters for other nectar types
;planters array: [1] planter name, [2] nectar bonus, [3] speed bonus, [4] hours to complete growth (no field degradation is assumed) (rounded up 2 d.p.)
;assumed: hydroponic 40% faster near blue flowers, heat-treated 40% faster near red flowers
BambooPlanters:=[["HydroponicPlanter", 1.4, 1.375, 8.73] ; 1.925
	, ["PetalPlanter", 1.5, 1.125, 12.45] ; 1.6875
	, ["PesticidePlanter", 1, 1.6, 6.25] ; 1.6
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.1875, 5.06] ; 1.425
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

BlueFlowerPlanters:=[["HydroponicPlanter", 1.4, 1.345, 8.93] ; 1.883
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.1725, 5.12] ; 1.407
	, ["PetalPlanter", 1, 1.155, 12.13] ; 1.155
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 1

CactusPlanters:=[["HeatTreatedPlanter", 1.4, 1.215, 9.88] ; 1.701
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["RedClayPlanter", 1.2, 1.1075, 5.42] ; 1.29
	, ["HydroponicPlanter", 1, 1.25, 9.6] ; 1.25
	, ["BlueClayPlanter", 1, 1.125, 5.34] ; 1.125
	, ["PetalPlanter", 1, 1.035, 13.53] ; 1.035
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

CloverPlanters:=[["HeatTreatedPlanter", 1.4, 1.17, 10.26] ; 1.638
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["RedClayPlanter", 1.2, 1.085, 5.53] ; 1.302
	, ["HydroponicPlanter", 1, 1.17, 10.57] ; 1.17
	, ["PetalPlanter", 1, 1.16, 12.07] ; 1.16
	, ["BlueClayPlanter", 1, 1.085, 5.53] ; 1.085
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

CoconutPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PetalPlanter", 1, 1.447, 9.68] ; 1.447
	, ["HydroponicPlanter", 1.4, 1.023, 11.74] ; 1.4322
	, ["BlueClayPlanter", 1.2, 1.0115, 5.94] ; 1.2138
	, ["HeatTreatedPlanter", 1, 1.03, 11.66] ; 1.03
	, ["RedClayPlanter", 1, 1.015, 5.92] ; 1.015
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

DandelionPlanters:=[["PetalPlanter", 1.5, 1.4235, 9.84] ; 2.13525
	, ["TackyPlanter", 1.25, 1.5, 5.33] ; 1.875
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HydroponicPlanter", 1.4, 1.0485, 11.45] ; 1.4679
	, ["BlueClayPlanter", 1.2, 1.02425, 5.86] ; 1.2291
	, ["HeatTreatedPlanter", 1, 1.028, 11.68] ; 1.028
	, ["RedClayPlanter", 1, 1.014, 5.92] ; 1.014
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

MountainTopPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.25, 9.6] ; 1.75
	, ["RedClayPlanter", 1.2, 1.125, 5.34] ; 1.35
	, ["HydroponicPlanter", 1, 1.25, 9.6] ; 1.25
	, ["BlueClayPlanter", 1, 1.125, 5.34] ; 1.125
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PetalPlanter", 1, 1, 14] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

MushroomPlanters:=[["HeatTreatedPlanter", 1.4, 1.3425, 8.94] ; 1.8795
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["RedClayPlanter", 1, 1.17125, 5.12] ; 1.17125
	, ["PetalPlanter", 1, 1.1575, 12.1] ; 1.1575
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 1

PepperPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.46, 8.22] ; 2.044
	, ["RedClayPlanter", 1.2, 1.23, 4.88] ; 1.476
	, ["PetalPlanter", 1, 1.04, 13.47] ; 1.04
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

PineTreePlanters:=[["HydroponicPlanter", 1.4, 1.42, 8.46] ; 1.988
	, ["PetalPlanter", 1.5, 1.08, 12.97] ; 1.62
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.21, 4.96] ; 1.452
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2 

PineapplePlanters:=[["PetalPlanter", 1.5, 1.445, 9.69] ; 2.1675
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["RedClayPlanter", 1.2, 1.015, 5.92] ; 1.218
	, ["HeatTreatedPlanter", 1, 1.03, 11.66] ; 1.03
	, ["HydroponicPlanter", 1, 1.025, 11.71] ; 1.025
	, ["BlueClayPlanter", 1, 1.0125, 5.93] ; 1.0125
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

PumpkinPlanters:=[["PetalPlanter", 1.5, 1.285, 10.9] ; 1.9275
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1.2, 1.055, 5.69] ; 1.266
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["HeatTreatedPlanter", 1, 1.11, 10.82] ; 1.11
	, ["HydroponicPlanter", 1, 1.105, 10.86] ; 1.105
	, ["BlueClayPlanter", 1, 1.0525, 5.71] ; 1.0525
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

RosePlanters:=[["HeatTreatedPlanter", 1.4, 1.41, 8.52] ; 1.974
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1, 1.205, 4.98] ; 1.205
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["PetalPlanter", 1, 1.09, 12.85] ; 1.09
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

SpiderPlanters:=[["PesticidePlanter", 1.3, 1.6, 6.25] ; 2.08
	, ["PetalPlanter", 1, 1.5, 9.33] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HeatTreatedPlanter", 1.4, 1, 12] ; 1.4
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

StrawberryPlanters:=[["PesticidePlanter", 1, 1.6, 6.25] ; 1.6
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HydroponicPlanter", 1.4, 1, 12] ; 1.3
	, ["HeatTreatedPlanter", 1, 1.345, 8.93] ; 1.345
	, ["BlueClayPlanter", 1.2, 1, 6] ; 1.2
	, ["RedClayPlanter", 1, 1.1725, 5.12] ; 1.1725
	, ["PetalPlanter", 1, 1.155, 12.13] ; 1.155
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

StumpPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.03, 11.65] ; 1.442
	, ["HydroponicPlanter", 1, 1.375, 8.73] ; 1.375
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["BlueClayPlanter", 1, 1.1875, 5.06] ; 1.1875
	, ["PetalPlanter", 1, 1.095, 12.79] ; 1.095
	, ["RedClayPlanter", 1, 1.015, 5.92] ; 1.015
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

SunflowerPlanters:=[["PetalPlanter", 1.5, 1.3415, 10.44] ; 2.01225
	, ["TackyPlanter", 1.25, 1.5, 5.34] ; 1.875
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1.2, 1.04175, 5.76] ; 1.2501
	, ["HeatTreatedPlanter", 1, 1.0835, 11.08] ; 1.0835
	, ["HydroponicPlanter", 1, 1.075, 11.17] ; 1.075
	, ["BlueClayPlanter", 1, 1.0375, 5.79] ; 1.0375
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END NATRO ENHANCEMENT STUFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READ INI VALUES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global PolarBear:={"Aromatic Pie":[[3,"Kill","Mantis"]
	,[4,"Kill","Ladybugs"]
	,[1,"Collect","Rose"]
	,[2,"Collect","Pine Tree"]]

	, "Beetle Brew":[[3,"Kill", "Ladybugs"]
	,[4,"Kill","RhinoBeetles"]
	,[1,"Collect","Pineapple"]
	,[2,"Collect","Dandelion"]]

	, "Candied Beetles":[[3,"Kill","RhinoBeetles"]
	,[1,"Collect","Strawberry"]
	,[2,"Collect","Blue Flower"]]

	, "Exotic Salad":[[1,"Collect", "Cactus"]
	,[2, "Collect","Rose"]
	,[3,"Collect","Blue Flower"]
	,[4,"Collect","Clover"]]

	, "Extreme Stir-Fry":[[6,"Kill","Werewolf"]
	,[5,"Kill","Scorpions"]
	,[4,"Kill","Spider"]
	,[1,"Collect","Cactus"]
	,[2,"Collect","Bamboo"]
	,[3,"Collect","Dandelion"]]

	, "High Protein":[[4,"Kill","Spider"]
	,[3,"Kill","Scorpions"]
	,[2,"Kill","Mantis"]
	,[1,"Collect","Sunflower"]]

	, "Ladybug Poppers":[[2,"Kill","Ladybugs"]
	,[1,"Collect","Blue Flower"]]

	, "Mantis Meatballs":[[2,"Kill","Mantis"]
	,[1,"Collect","Pine Tree"]]

	, "Prickly Pears":[[1,"Collect","Cactus"]]

	, "Pumpkin Pie":[[3,"Kill","Mantis"]
	,[1,"Collect","Pumpkin"]
	,[2,"Collect","Sunflower"]]

	, "Scorpion Salad":[[2,"Kill","Scorpions"]
	,[1,"Collect","Rose"]]

	, "Spiced Kebab":[[3,"Kill","Werewolf"]
	,[1,"Collect","Clover"]
	,[2,"Collect","Bamboo"]]

	, "Spider Pot-Pie":[[2,"Kill","Spider"]
	,[1,"Collect","Mushroom"]]

	, "Spooky Stew":[[4,"Kill","Werewolf"]
	,[3,"Kill","Spider"]
	,[1,"Collect","Spider"]
	,[2,"Collect","Mushroom"]]

	, "Strawberry Skewers":[[3,"Kill","Scorpions"]
	,[1,"Collect","Strawberry"]
	,[2,"Collect","Bamboo"]]

	, "Teriyaki Jerky":[[3,"Kill","Werewolf"]
	,[1,"Collect","Pineapple"]
	,[2,"Collect","Spider"]]

	, "Thick Smoothie":[[1,"Collect","Strawberry"]
	,[2,"Collect","Pumpkin"]]

	, "Trail Mix":[[1,"Collect","Sunflower"]
	,[2,"Collect","Pineapple"]]}


global BlackBear:={"Just White":[[1,"Collect","White"]]

	, "Just Red":[[1,"Collect","Red"]]

	, "Just Blue":[[1,"Collect","Blue"]]

	, "A Bit Of Both":[[1,"Collect","Red"]
	,[2,"Collect","Blue"]]

	, "Any Pollen":[[1,"Collect","Any"]]

	, "The Whole Lot":[[1,"Collect","Red"]
	,[2,"Collect","Blue"]
	,[3,"Collect","White"]]

	, "Between The Bamboo":[[2,"Collect","Bamboo"]
	,[1,"Collect","Blue"]]

	, "Play In The Pumpkins":[[2,"Collect","Pumpkin"]
	,[1,"Collect","White"]]

	, "Plundering Pineapples":[[2,"Collect","Pineapple"]
	,[1,"Collect","Any"]]

	, "Stroll In The Strawberries":[[2,"Collect","Strawberry"]
	,[1,"Collect","Red"]]

	, "Mid-Level Mission":[[1,"Collect","Spider"]
	,[2, "Collect","Strawberry"]
	,[3,"Collect","Bamboo"]]

	, "Blue Flower Bliss":[[1,"Collect","Blue Flower"]]

	, "Delve Into Dandelions":[[1,"Collect","Dandelion"]]

	, "Fun In The Sunflowers":[[1,"Collect","Sunflower"]]

	, "Mission For Mushrooms":[[1,"Collect","Mushroom"]]

	, "Leisurely Lowlands":[[1,"Collect","Sunflower"]
	,[2,"Collect","Dandelion"]
	,[3,"Collect","Mushroom"]
	,[4,"Collect","Blue Flower"]]

	, "Triple Trek":[[1,"Collect","Mountain Top"]
	,[2,"Collect","Pepper"]
	,[3,"Collect","Coconut"]]

	, "Pepper Patrol":[[1,"Collect","Pepper"]]}


global BuckoBee:={"Abilities":[[1,"Collect","Any"]]

	, "Bamboo":[[1,"Collect","Bamboo"]]

	, "Bombard":[[4,"Get","Ant"]
	,[3,"Get","Ant"]
	,[2,"Kill","RhinoBeetles"]
	,[1,"Collect","Any"]]

	, "Booster":[[2,"Get","BlueBoost"]
	,[1,"Collect","Any"]]

	, "Clean-Up":[[1,"Collect","Blue Flower"]
	,[2,"Collect","Bamboo"]
	,[3,"Collect","Pine Tree"]]

	, "Extraction":[[1,"Collect","Clover"]
	,[2,"Collect","Cactus"]
	,[3,"Collect","Pumpkin"]]

	, "Flowers":[[1,"Collect","Blue Flower"]]

	, "Goo":[[1,"Collect","Blue"]]

	, "Medley":[[2,"Collect","Bamboo"]
	,[3,"Collect","Pine Tree"]
	,[1,"Collect","Any"]]

	, "Picnic":[[5,"Get","Ant"]
	,[4,"Get","Ant"]
	,[3,"Feed","Blueberry"]
	,[1,"Collect","Blue Flower"]
	,[2,"Collect","Blue"]]

	, "Pine Trees":[[1, "Collect", "Pine Tree"]]

	, "Pollen":[[1,"Collect","Blue"]]

	, "Scavenge":[[1,"Collect","Blue"]
	,[3,"Collect","Blue"]
	,[2,"Collect","Any"]]

	, "Skirmish":[[2,"Kill","RhinoBeetles"]
	,[1,"Collect","Blue Flower"]]

	, "Tango":[[3,"Kill","Mantis"]
	,[1,"Collect","Blue"]
	,[2,"Collect","Any"]]

	, "Tour":[[5,"Kill","Mantis"]
	,[4,"Kill","RhinoBeetles"]
	,[1,"Collect","Blue Flower"]
	,[2,"Collect","Bamboo"]
	,[3,"Collect","Pine Tree"]]}


global RileyBee:={"Abilities":[[1,"Collect","Any"]]

	, "Booster":[[2,"Get","RedBoost"]
	,[1,"Collect","Any"]]

	, "Clean-Up":[[1,"Collect","Mushroom"]
	,[2,"Collect","Strawberry"]
	,[3,"Collect","Rose"]]

	, "Extraction":[[1,"Collect","Clover"]
	,[2,"Collect","Cactus"]
	,[3,"Collect","Pumpkin"]]

	, "Goo":[[1,"Collect","Red"]]

	, "Medley":[[2,"Collect","Strawberry"]
	,[3,"Collect","Rose"]
	,[1,"Collect","Any"]]

	, "Mushrooms":[[1,"Collect","Mushroom"]]

	, "Picnic":[[4,"Get","Ant"]
	,[3,"Feed","Strawberry"]
	,[1,"Collect","Mushroom"]
	,[2,"Collect","Red"]]

	, "Pollen":[[1,"Collect","Red"]]

	, "Rampage":[[3,"Get","Ant"]
	,[2,"Kill","Ladybugs"]
	,[1,"Kill","All"]]

	, "Roses":[[1,"Collect","Rose"]]

	, "Scavenge":[[1,"Collect","Red"]
	,[3,"Collect","Red"]
	,[2,"Collect","Any"]]

	, "Skirmish":[[2,"Kill","Ladybugs"]
	,[1,"Collect","Mushroom"]]

	, "Strawberries":[[1,"Collect","Strawberry"]]

	, "Tango":[[3,"Kill","Scorpions"]
	,[1,"Collect","Red"]
	,[2,"Collect","Any"]]

	, "Tour":[[5,"Kill","Scorpions"]
	,[4,"Kill","Ladybugs"]
	,[1,"Collect","Mushroom"]
	,[2,"Collect","Strawberry"]
	,[3,"Collect","Rose"]]}


global FieldBooster:={"pine tree":{booster:"blue", stacks:1}
	, "bamboo":{booster:"blue", stacks:1}
	, "blue flower":{booster:"blue", stacks:3}
	, "rose":{booster:"red", stacks:1}
	, "strawberry":{booster:"red", stacks:1}
	, "mushroom":{booster:"red", stacks:3}
	, "sunflower":{booster:"mountain", stacks:3}
	, "dandelion":{booster:"mountain", stacks:3}
	, "spider":{booster:"mountain", stacks:2}
	, "clover":{booster:"mountain", stacks:2}
	, "pineapple":{booster:"mountain", stacks:2}
	, "pumpkin":{booster:"mountain", stacks:1}
	, "cactus":{booster:"mountain", stacks:1}
	, "stump":{booster:"none", stacks:0}
	, "mountain top":{booster:"none", stacks:0}
	, "coconut":{booster:"none", stacks:0}
	, "pepper":{booster:"none", stacks:0}}


global FieldDefault:={}

FieldDefault["Sunflower"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":4
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Left"
	, "distance":8
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Dandelion"] := {"pattern":"Lines"
	, "size":"M"
	, "width":2
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Right"
	, "distance":9
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":1
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Mushroom"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":2
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Left"
	, "distance":8
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Blue Flower"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":7
	, "camera":"Right"
	, "turns":2
	, "sprinkler":"Center"
	, "distance":1
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Clover"] := {"pattern":"Lines"
	, "size":"M"
	, "width":2
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Left"
	, "distance":4
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Spider"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":1
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Left"
	, "distance":6
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Strawberry"] := {"pattern":"CornerXSnake"
	, "size":"S"
	, "width":1
	, "camera":"Right"
	, "turns":2
	, "sprinkler":"Upper Right"
	, "distance":6
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Bamboo"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":3
	, "camera":"Left"
	, "turns":2
	, "sprinkler":"Upper Left"
	, "distance":4
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Pineapple"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":1
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Left"
	, "distance":8
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Stump"] := {"pattern":"Stationary"
	, "size":"S"
	, "width":1
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Center"
	, "distance":1
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Cactus"] := {"pattern":"Squares"
	, "size":"S"
	, "width":1
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Lower"
	, "distance":5
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":1
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Pumpkin"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":5
	, "camera":"Right"
	, "turns":2
	, "sprinkler":"Right"
	, "distance":8
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Pine Tree"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":3
	, "camera":"Left"
	, "turns":2
	, "sprinkler":"Upper Left"
	, "distance":7
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Rose"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":1
	, "camera":"Left"
	, "turns":4
	, "sprinkler":"Lower Right"
	, "distance":10
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":1}

FieldDefault["Mountain Top"] := {"pattern":"Snake"
	, "size":"S"
	, "width":2
	, "camera":"Right"
	, "turns":2
	, "sprinkler":"Right"
	, "distance":5
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":1
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Coconut"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":3
	, "camera":"Right"
	, "turns":2
	, "sprinkler":"Right"
	, "distance":6
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

FieldDefault["Pepper"] := {"pattern":"CornerXSnake"
	, "size":"M"
	, "width":5
	, "camera":"None"
	, "turns":1
	, "sprinkler":"Upper Right"
	, "distance":7
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

StandardFieldDefault := ObjFullyClone(FieldDefault)

ObjFullyClone(obj)
{
	nobj := ObjClone(obj)
	for k,v in nobj
		if IsObject(v)
			nobj[k] := ObjFullyClone(v)
	return nobj
}

if FileExist(A_ScriptDir "\settings\field_config.ini") ; update default values with new ones read from any existing .ini
	nm_LoadFieldDefaults()

loop 3 {
	if (!InStr(patternlist "Stationary|", FieldPattern%A_Index%))
		nm_FieldDefaults(A_Index)
}

ini := ""
for k,v in FieldDefault ; overwrite any existing .ini with updated one with all new keys and old values
{
	ini .= "[" k "]`r`n"
	for i,j in v
		ini .= i "=" j "`r`n"
	ini .= "`r`n"
}
FileDelete, %A_ScriptDir%\settings\field_config.ini
FileAppend, %ini%, %A_ScriptDir%\settings\field_config.ini

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MANUAL PLANTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ManualPlanters := {}

ManualPlanters["General"] := {"MHarvestInterval":"Every 2 Hours"}

ManualPlanters["Slot 1"] := {"MSlot1Cycle1Planter":""
	, "MSlot1Cycle2Planter":""
	, "MSlot1Cycle3Planter":""
	, "MSlot1Cycle4Planter":""
	, "MSlot1Cycle5Planter":""
	, "MSlot1Cycle6Planter":""
	, "MSlot1Cycle7Planter":""
	, "MSlot1Cycle8Planter":""
	, "MSlot1Cycle9Planter":""
	, "MSlot1Cycle1Field":""
	, "MSlot1Cycle2Field":""
	, "MSlot1Cycle3Field":""
	, "MSlot1Cycle4Field":""
	, "MSlot1Cycle5Field":""
	, "MSlot1Cycle6Field":""
	, "MSlot1Cycle7Field":""
	, "MSlot1Cycle8Field":""
	, "MSlot1Cycle9Field":""
	, "MSlot1Cycle1Glitter":0
	, "MSlot1Cycle2Glitter":0
	, "MSlot1Cycle3Glitter":0
	, "MSlot1Cycle4Glitter":0
	, "MSlot1Cycle5Glitter":0
	, "MSlot1Cycle6Glitter":0
	, "MSlot1Cycle7Glitter":0
	, "MSlot1Cycle8Glitter":0
	, "MSlot1Cycle9Glitter":0
	, "MSlot1Cycle1AutoFull":"Timed"
	, "MSlot1Cycle2AutoFull":"Timed"
	, "MSlot1Cycle3AutoFull":"Timed"
	, "MSlot1Cycle4AutoFull":"Timed"
	, "MSlot1Cycle5AutoFull":"Timed"
	, "MSlot1Cycle6AutoFull":"Timed"
	, "MSlot1Cycle7AutoFull":"Timed"
	, "MSlot1Cycle8AutoFull":"Timed"
	, "MSlot1Cycle9AutoFull":"Timed"}

ManualPlanters["Slot 2"] := {"MSlot2Cycle1Planter":""
	, "MSlot2Cycle2Planter":""
	, "MSlot2Cycle3Planter":""
	, "MSlot2Cycle4Planter":""
	, "MSlot2Cycle5Planter":""
	, "MSlot2Cycle6Planter":""
	, "MSlot2Cycle7Planter":""
	, "MSlot2Cycle8Planter":""
	, "MSlot2Cycle9Planter":""
	, "MSlot2Cycle1Field":""
	, "MSlot2Cycle2Field":""
	, "MSlot2Cycle3Field":""
	, "MSlot2Cycle4Field":""
	, "MSlot2Cycle5Field":""
	, "MSlot2Cycle6Field":""
	, "MSlot2Cycle7Field":""
	, "MSlot2Cycle8Field":""
	, "MSlot2Cycle9Field":""
	, "MSlot2Cycle1Glitter":0
	, "MSlot2Cycle2Glitter":0
	, "MSlot2Cycle3Glitter":0
	, "MSlot2Cycle4Glitter":0
	, "MSlot2Cycle5Glitter":0
	, "MSlot2Cycle6Glitter":0
	, "MSlot2Cycle7Glitter":0
	, "MSlot2Cycle8Glitter":0
	, "MSlot2Cycle9Glitter":0
	, "MSlot2Cycle1AutoFull":"Timed"
	, "MSlot2Cycle2AutoFull":"Timed"
	, "MSlot2Cycle3AutoFull":"Timed"
	, "MSlot2Cycle4AutoFull":"Timed"
	, "MSlot2Cycle5AutoFull":"Timed"
	, "MSlot2Cycle6AutoFull":"Timed"
	, "MSlot2Cycle7AutoFull":"Timed"
	, "MSlot2Cycle8AutoFull":"Timed"
	, "MSlot2Cycle9AutoFull":"Timed"}

ManualPlanters["Slot 3"] := {"MSlot3Cycle1Planter":""
	, "MSlot3Cycle2Planter":""
	, "MSlot3Cycle3Planter":""
	, "MSlot3Cycle4Planter":""
	, "MSlot3Cycle5Planter":""
	, "MSlot3Cycle6Planter":""
	, "MSlot3Cycle7Planter":""
	, "MSlot3Cycle8Planter":""
	, "MSlot3Cycle9Planter":""
	, "MSlot3Cycle1Field":""
	, "MSlot3Cycle2Field":""
	, "MSlot3Cycle3Field":""
	, "MSlot3Cycle4Field":""
	, "MSlot3Cycle5Field":""
	, "MSlot3Cycle6Field":""
	, "MSlot3Cycle7Field":""
	, "MSlot3Cycle8Field":""
	, "MSlot3Cycle9Field":""
	, "MSlot3Cycle1Glitter":0
	, "MSlot3Cycle2Glitter":0
	, "MSlot3Cycle3Glitter":0
	, "MSlot3Cycle4Glitter":0
	, "MSlot3Cycle5Glitter":0
	, "MSlot3Cycle6Glitter":0
	, "MSlot3Cycle7Glitter":0
	, "MSlot3Cycle8Glitter":0
	, "MSlot3Cycle9Glitter":0
	, "MSlot3Cycle1AutoFull":"Timed"
	, "MSlot3Cycle2AutoFull":"Timed"
	, "MSlot3Cycle3AutoFull":"Timed"
	, "MSlot3Cycle4AutoFull":"Timed"
	, "MSlot3Cycle5AutoFull":"Timed"
	, "MSlot3Cycle6AutoFull":"Timed"
	, "MSlot3Cycle7AutoFull":"Timed"
	, "MSlot3Cycle8AutoFull":"Timed"
	, "MSlot3Cycle9AutoFull":"Timed"}

for k,v in ManualPlanters ; load the default values as globals, will be overwritten if a new value exists when reading
	for i,j in v
		%i% := j

if FileExist(A_ScriptDir "\settings\manual_planters.ini") ; update default values with new ones read from any existing .ini
	nm_ReadIni(A_ScriptDir "\settings\manual_planters.ini")

ini := ""
for k,v in ManualPlanters ; overwrite any existing .ini with updated one with all new keys and old values
{
	ini .= "[" k "]`r`n"
	for i in v
		ini .= i "=" %i% "`r`n"
	ini .= "`r`n"
}
FileDelete, %A_ScriptDir%\settings\manual_planters.ini
FileAppend, %ini%, %A_ScriptDir%\settings\manual_planters.ini

Hotkey, %StopHotkey%, stop, UseErrorLevel On
global resetTime:=nowUnix()
global youDied:=0
global GameFrozenCounter:=0
global state, objective
global AFBrollingDice:=0
global AFBuseGlitter:=0
global AFBuseBooster:=0
global MacroState:=0 ; 0=stopped, 1=paused, 2=running
global MacroStartTime:=nowUnix()
global MacroReloadTime:=nowUnix()
;global delta:=0
global PausedRuntime:=0
global FieldGuidDetected:=0
global HasPopStar:=0
global PopStarActive:=0
global PreviousAction:="None"
global CurrentAction:="Startup"
state:="Startup"
objective:="UI"
DailyReconnect:=0
for k,v in ["PWindShrine","PWindShrineDonate","PWindShrineDonateNum","PWindShrineBooster","PWindShineBoostedField","PMondoGuid","PFieldDriftSteps","PFieldBoosted","PFieldGuidExtend","PFieldGuidExtendMins","PFieldBoostExtend","PFieldBoostBypass","PPopStarExtend"]
	%v%:=0
#include *i %A_ScriptDir%\settings\personal.ahk

;ensure Gui will be visible
if (GuiX && GuiY)
{
	SysGet, MonitorCount, MonitorCount
	loop %MonitorCount%
	{
		SysGet, Mon, MonitorWorkArea, %A_Index%
		if(GuiX>MonLeft && GuiX<MonRight && GuiY>MonTop && GuiY<MonBottom)
			break
		if(A_Index=MonitorCount)
			guiX:=guiY:=0
	}
}
else
	guiX:=guiY:=0
global PackFilterArray:=[]
global BackpackPercent, BackpackPercentFiltered
global ActiveHotkeys:=[]

PostMessage, 0x5555, 10, 0, , ahk_pid %lp_PID%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STATUS HANDLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
run, "%exe_path64%" /script "submacros\Status.ahk" "%discordMode%" "%discordCheck%" "%webhook%" "%bottoken%" "%MainChannelCheck%" "%MainChannelID%" "%ReportChannelCheck%" "%ReportChannelID%" "%WebhookEasterEgg%" "%ssCheck%" "%ssDebugging%" "%CriticalSSCheck%" "%AmuletSSCheck%" "%MachineSSCheck%" "%BalloonSSCheck%" "%ViciousSSCheck%" "%DeathSSCheck%" "%PlanterSSCheck%" "%HoneySSCheck%" "%criticalCheck%" "%discordUID%" "%CriticalErrorPingCheck%" "%DisconnectPingCheck%" "%GameFrozenPingCheck%" "%PhantomPingCheck%" "%UnexpectedDeathPingCheck%" "%EmergencyBalloonPingCheck%" "%commandPrefix%" "%NightAnnouncementCheck%" "%NightAnnouncementName%" "%NightAnnouncementPingID%" "%NightAnnouncementWebhook%" "%PrivServer%" "%DebugLogEnabled%"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDIP BITMAPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bitmaps := {}

;general
bitmaps["e_button"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAADIAAAAEAQMAAAD20v5CAAAAA1BMVEXu7vKXSI0iAAAAK0lEQVR4AQEgAN//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAABaSL1yAAAAABJRU5ErkJggg==")
bitmaps["redcannon"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABsAAAAMAQMAAACpyVQ1AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEdJREFUeAEBPADD/wDAAGBgAMAAYGAA/gBgYAD+AGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYDdgEn1l8cC/AAAAAElFTkSuQmCC")
bitmaps["tokenlink"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAFAAAAAOCAMAAACPS2sYAAABelBMVEUiV6gjWKgkWakmWqonW6ooXKspXasqXasrXqwrX6wsX6wxY642Z7E3aLE6arM9bbQ/brVAb7VBcLZDcbZEcrdIdrlLeLpMeLpMebpNertOertPe7tRfbxSfb1Tfr1Uf75VgL5Xgr9Zg8BchcFdhsJeh8JfiMNkjMVljMVljcVmjsZnjsZoj8Zpj8dpkMdqkcdrkchskshtk8ltk8hulMlvlMlwlcpwlspyl8tzmMt0mMt0mcx1msx3m817ns97n89+oNB/otGCpNKNrNaNrdeQr9iTsdmYtduZttybuN2cuN2cud2eut6fu96hvd+lwOGpw+OsxeSux+WvyOW0zOe5z+q50Oq60eq+1Oy/1OzA1u3C1+7E2O7E2e/F2u/G2u/H2/DI3PDK3fHL3/LM3/LN4PLO4PPP4fPP4vPQ4vTS5PTU5fXV5vbX6Pfa6vjb6/nc7Pnf7vrh7/vh8Pvi8fzj8fzk8vzl8/3m9P3n9P7o9f7o9v7p9v/q9/8MEYKwAAAEeUlEQVR4AQFuBJH7AAAAAAAAAAAAASdPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAABAbhIAAAAAAAAAAAAAASdPAAAAAAAAAAVnVgAAAAAAAAAAAAAAGX1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAABBcBMAAAAAAAAAAAAAGX1hAAAAAAAAAAAkfS4AAAAAAAAAAAAAGn1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAAAAAAAAAAAAAAAAAAAAGn1hAAAAAAAAAAAAX1sAAAA2YXZiOgAAGn1hAAAgJyEAAAAAJV53Yy0AABZ9ZE9vcU0HAAAAAAAACX13AAAAAAAAAAAXJQ0AFn1kT29xTQcAGn1hAAAgJyEAAAAAQn0RADx9fX19fT8AGn1hADt9chsAAAAfen19fXwmABZ9fX19fX1GAAAAAAAACX13AAAAAAAAAABTfS8AFn19fX19fUYAGn1hADt9chsAAAAAHn01AGx9OAY0fW4DGn1hMHx1IAAAAABafUAKMn1cABZ9fS8IOX10BAAAAAAACX13AAAAAAAAAABTfS8AFn19Lwg5fXQEGn1hMHx1IAAAAAAADH1EAH1eAAAAWX0bGn1zen1RAAAAAAx9agAAAF59CxZ9aQAAAGB9EQAAAAAACX13AAAAAAAAAABTfS8AFn1pAAAAYH0RGn1zen1RAAAAAAAACH1KAH1MAAAASH0pGn19dnp7FAAAABx9fX19fX19GRZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn19dnp7FAAAAAAAB31JAH1MAAAAR30oGn14JE59UAAAAB19fX19fX19IhZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn14JE59UAAAAAAADn1DAH1dAAAAWH0YGn1hAA95fBUAAA59bQAAAAAAABZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn1hAA95fBUAAAAAI30zAGh9PQU3fWsCGn1hAABLfVIAAABlfT4JJ1gzABZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn1hAABLfVIAAAAARX0QADB9fX19fTcAGn1hAAAOd30ZAAApfX19fX1FABZ9XgAAAFV9FgAAAAAACX19fX19fX1nAABTfS8AFn1eAAAAVX0WGn1hAAAOd30ZAAACa1oAAAAsXnVgMQAAGn1hAAAAR31UAAAAK2F3ZkEBABZ9XgAAAFV9FgAAAAAACX19fX19fX1nAABTfS8AFn1eAAAAVX0WGn1hAAAAR31UAAAqfS4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVpVwAAqhit0/6UWu4AAAAASUVORK5CYII=")
bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
bitmaps["beemenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC")
bitmaps["dialog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAAUAQMAAAC3R49OAAAABlBMVEUiV6gyg//3rCo4AAAAEElEQVR42mMgFvz//4EYDABK9B1Nh2RNtgAAAABJRU5ErkJggg==")
bitmaps["shiftlock"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABkAAAAZAgMAAAC5h23wAAAADFBMVEUAAAAFov4Fov0Gov5PyD1RAAAAAXRSTlMAQObYZgAAAG1JREFUeNp1zrENwlAMhOEvOOmQQsEgGSBSVkjB24dRMgIjeBRGyAZBLhBpKOz/ijvdEcfyhpEZXkQST+yMMHNFvUm3CjZ9L1K6dZzYtbYWh9YekoE7sij/cit/pKny8e379Udiryt92ns5lp0PKyEgGjSX+tcAAAAASUVORK5CYII=")
bitmaps["yes"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAAPAQMAAAAiQ1bcAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFZJREFUeAEBSwC0/wDDAAfAAEIACGAAfgAQMAA8ABAQABgAIAgAGAAgCAAYACAYABgAP/gAGAAgAAAYAAAAABgAIAAAGAAwAAAYADAAABgAGDAAGAAP4FGfB+0KKAbEAAAAAElFTkSuQmCC")
bitmaps["no"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB4AAAAQAQMAAAA79F2RAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFtJREFUeAEBUACv/wD4CAHAANwIB/AAjAgMGACGCAgIAIYIEAwAgwgQBACBiBAEAIGIEAQAgMgQBACAeBAEAIA4EAQAgDgQBACAOBAEAIAYCAgAgAgMGACACAfwttYQFVcrYb0AAAAASUVORK5CYII=")
bitmaps["keep"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAEIAAAAcAQMAAADvHvssAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAIBJREFUeNqVzjEOwjAQRNGxLHmbyLmAJa6RY6WkQitxMR9lIwpKWgrLy8pgkyJNfvW6GUjCL1mGrkPrkHRtuevBsOgGPNm/XSE1gYqvpIwX4kSB7gzFFIInl6GcQmzavoIpX+qsJogcaE2I2MmZlr/6hqS5kO3C1B5UU2yv0DuhDxaLPafi+H0cAAAAAElFTkSuQmCC")
bitmaps["emptyhealth"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAABCAAAAAD7+dH5AAAADElEQVR42mNczoAJAA02AKmWDxinAAAAAElFTkSuQmCC")

;gui
bitmaps["beesmas"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAC1lBMVEUAAABkuTNitTJfqTPSdVGQakFhqjJkpDRgpjP+5l3211ZdqjBgpzNcnzJhrjNdqi5jpTVhtC5epDM9wCNenzNhojf84mBayjForTVbrzL30RmZb07z4F/+XV/y0k9fuzH91y9dnTRkrDRkojNXnyZeuTCeclKBsz1SwC6SaUOYi0FjtTJWqTD+4m3y3mTsYVhiqDT+42NWuy6gdFSrviRitzPcaVRiqDT01FKVa0RPviz72EVfsjH7WVljtzGWdU9gtTJ+ljpYlTObblBkuDJ/pDhGrC5fpTT1zyWOnD1nrzf311b63l6wf0mQYkVTqy9hsC/Uvw7+Om2LakH+4mcr0iEajBpitTJitjJhpjNfpDBjsjJnvzT/V19gpjJWqzBesy1boyv/T2L/U2D4XVxpqz1jozRjrDNhpTNgtS9YsSTP5cH/UWH+W13oZVhpuTtmrjdqxDZntDVnvDRjsDNhuDFhsTFcujBUrDBTqDBYvC9cpC9UvS3////7/v2y1Jyn1Yz/72j/aWKGxWHlaFfhalTBe02Zeky9eku4ekqbikGNcUGGpT6MnD18njtqszp8pDlqmDZrsTVvqzVkoDRcmjRfqDJVtDFdrzFaqTFPoDFXmTFatjBatDBYozBXuS5bsyhbqyZXoSZNqCVUoCPc7dG/2q2936mw2Zms0JSazYOWxHiPwG+NyWv/6WiJvmaLw2X/YmL7312rhln/UVl7tVXv11Scm1Oef1PW1VLWclLXcVLQcFF3s1DJbVD42E/TzU9tuU/Jc0+tjkuReEtyrkm1fkmvgEite0hwvEWbs0Scq0SjmUSfiUOciUP+1kKyyEL/5kGOh0GKsz6Qnj6Kkz6Kkj7/4D2AujyFlTx4lDptujm30TdrwjdqozdynjdkuTZftzVvrjVnojRgqDNXnTNXvTFYrzFTrTFMojBmwy9eoS9Uui5ivi1RtC1jsSxaridTpCZajVxKAAAAV3RSTlMA/s8a/vLizsmpmpN+em5DOy8iDwv9/Pv6+Pj29fXs7Ojn5ubg393b0MvBu7i1tLGvrq2soZ+ckpCQjYSEf395eGhnXlpZVlJQSklAPTMrKikjIh4aFggjtvGzAAACC0lEQVQ4y2JAA1zeDPiBmAU+WWtO3XVyXJw+OBV4KFzcv6nRMAS3EYFS5xv18Nlhcv3ANhkB3PJudy48n7xTPQyXfKh88dyy6nnvuXEp0L88PyI6KnV9Pz92edemvPDy6EWrazeoiGBVYHUqaXf5nKjUNanpQlgVMGucSdoVHR+1KJ0Hhxs4pp9Lyrv18qmoE3Z57rsz3vWmJJ+Y8kLSH5s8f0wEY0TN5EM5Kcd62LHIC6vGJCzNXjA3/uae2OQmW0wFAJndmJ+womFBWUZ8/P2uNhZfdHnPjS1FVVlZEdEZkZEfF1eEs6MHhdHpnJZHNeFABXGJ9fWJcUXoUcYnfiU2pbemHKQgOzsxnY0Z3Q62ZxPyktomvZkZGRcVFVXAiy7PW5BWmdaZk3t84qxZs2dPnaqIZoIgY0RZyYzpfSzJsfsuTZxXWflQB1UB09usCCCoqprQkZKc29px9mqPI7I8YDavmhvCQSBiTkXatc7W3NgtsbJBCPmA4qzldfkJIAUfqqfFV8x83Le967AWkgUxmfknM8FGNB+NioyMW7Kq7uDiB+5wBcWM4ZkJIOmE/NplSyIjIxO3rkyNuo1IFg4xhYWFMTGlpZmla/dWP5mWXlCysKhfSQjJly52ptpMEpNKohe+TptyT5nDwJzPSxgjQu0372g/0t3dzhqMK907G6tJs2pa+iGLAQCiD78p46afzQAAAABJRU5ErkJggg==")
bitmaps["weary"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAMAAAC6V+0/AAAB9VBMVEUAAADulgrxlwj3pBj2tCf2tyj0qh71ribypxnypBf1rCX2qSPwmg32sifulwf1ryb1pR/znhH2pRz2qSTtlQjvlQj1pCL5rSL1ryDzphPwpBP1ribwoBH1qSX1rCX1qyTyohbvmhH2pR33txrwjgT0oxL0piP0nybxphLylAf1oyH2pyL1qRP5zC3/1TD6zi34xCz3wiv60S75yi3/7jP/6TL+3y/91S79zS35xi33wCr/4yn3vin2tikzHQo1HAH/6zD/4zD/3jD73S//3C/+2y/+0S/8zy/70y34yCz7xCv/6yn2tSjBpyW6nSOoix/0sh50WRU8JQw1HwstGAn56+CCeHJxZFZoWkj7xzr/8zP/5TH/2DD51S75xyzzxSvxwyvgvynWvCnovSjgriSVehywhBqKcBqCaRlIMg5XOQw4IwtHKgkpFQQxGgD76NX759D/4Kv/3Zybg2umhl7/2VX/2UX/+TX/8DP8yzLz3TD13C//yy3wxyz1xCz1siv/3Sr+1irZwSntuSnctyn1ryj/xifQsyfLsif3ySbftCbRrSbIrSbQqyb2uyXrvSPquCP1tyP/2iKwliL/3SCkhx/Uoh7Hlx2dfx2RcRuObxrxqRmleRmkehiCZxiAZhiAYhhtUhOUZxF1TQ5ONA1BLA00IAznqphmAAAALXRSTlMAfCME+O/p39/QrKejoJKIamljX1k4KRv08+vk4+DNza+tl5OOjYWCb2RDQBkslC9PAAABbklEQVQY00XN03ZDUQBF0ZPUtm1ex2psJzVjp7Zt2+53Nhoj822vlw2iigtysrJyCopBXEd6klKJoagyKb09lhJaEjHG6BiCjI4xsMTmhEhsWEdh6PFYKLY82YaY3PpwzdsdQXY+HCKaSKAznCIj6lwASiowCNHpqBQajbqgfVhloMlkkKtWQPTBeY12kHpyPUClQwpuK8jgEPjwstVo4A84zJqlYZxg1YJqDBJqPTyfhsK3esy/t0KEmQZSUEhicbkP+Gy2asvl3pcgzNRwlAsoqhtGf//ilYoikEOhWIMRuIQ9NzXR3T0+OcsW4RCaFjminc/09Pb19fZM2zdwglMH8rkK2eZXINgVEgx8H9IJfR7orGLBF94/o4nHMxl9/rshrLIEgHy11O43/3y+vxm8PNM9/NwGQpq4a87XI7lYTLc5X7b1jSCCVLoCw1KZTArDe2UkEFOUmXzJYbHO9OWZRSCOXEjKziYVkqPrH2zQXTfcpxWAAAAAAElFTkSuQmCC")
bitmaps["aurynico"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAC9FBMVEUAAABbWlZaWFVDPzp9f3uoqqFpY1pZVU1IQjt5enVmZ2NkWEc6MiloYVpIQTiztauWgFqjpJ50X0CXmJORk46PkYx1d3J5enZZVEtdXFZHQj6jhVVqYlGQkYpsVDSHclBoUjSdnJaVf1uqq6RYQyl4eHNxcWtWQSlvcG1qWUBeSzJmY2BlZWNbWFJEPTJNRz1NQTNgXVWBg31LRDeukWGfn5l+f3l2Xz2Jb0uPelZhSSp5enSipZ+DaEWehmBwWTqqq6WNjoZ5enSUlpCPkIleUD9vWjtfXVZbVk2bnJaLdVSMjYd+a0tgTTRjY11XQyiGcVRiY194enVNPyx3Z01AMBxHR0NUQyp3ZUxjVkFjUThdXVpzdHKNfmZSSj40LSNWTUJra2twcG51bGmHdVaIbEOYmZKMjYfIy8N5enSfi2R2XTuwsqy7vLRkY11tcG5lXlKQfFmVfFWGh4Fxcm5JNBuHcWySlJB5YD17fHdeXlpyc21XRzKRe1dLRDyam5ORe1ZgSS18f3qQfFigo5s7Lx56a1RIOyl8fXdTS0CZmpR1c2h4Z0xvXUNOSUJhUDmKioRNTkp2Xj1bTTyOj4o9LhpmUzlxb2lFRD03KRlVQy1qYlGDhIGnqaGMjodkY12qq6OanJWChYClpp+Ulo+JbERyWDWvsaqsraWfoJqbglqUelKKb0hdVERxXUC5u7Ozta6nqaKho5ucnpWRkouNj4iJi4WFiYSlj2aNc02NcUmGbEeAZkF5YT9bSTK2t6+ur6ijpJydn5iYmZKRlI6Cgntwb2ebhl+ahFxbWlWOd1KRd1CCbk51Xjy8vbasmG+ok2xpa2afhl5kYlt6bVVwZVGYeUtfWEt7YDxZTTt3XTlnUjRRPyeGiICLiX50cmmljWJxbF5hYl6SfFedfU5vYUmGakSFaEF/ZD5qVztsVDLAwbuflY6gi4Z8e3OGdnCgimSqilhXV1SJc1OBcFGff093aE+TdEd+ZkRJRT5QRDJdQyIeBmTrAAAAoHRSTlMADwUi/v1ALhr+gkIzGhP+/ffMxaGGfGNKOAr+/fPv4ODe287Ewr+1oo+PcVdPTjwv/Pj49vDv7u3s6ujk49/e3dnUzczKxrSyr6+uqKShn52Yl5aNgnp0c3FqYF1YSD46Mish/Pr29vX19PPy8fHu7evq5eXl5ODg3dzb2tfW1dXVxsbBwLe3taahnJyZmJWUiX98e3VxaGJiXFpRLyol1PIVCwAAAzBJREFUOMt1U1N4o1EQvX+DNqhtu9uubdtGubZt22bspLGT2rbtrq2XzZ/ddpt+7XmbOefOnbn3DDCEEXrdOhPQL6CwpeOH7pkZbtQnO3Dl7NPOH52d2RZDLwaEOPWmHWZv/WChKP3a3Fz6mVqSLLBea8gvlec1abYdHsf5Xqo+eXO/mCKInWXSo7WF+WkjFjw1NjPFPby7GgEQ2DESZu4U427+el6T/0CDioj5gym5E7sUK+WZQTqZUc9xjWekSuhTzfSB6fj0aWjb897es+yhvzR6odfekT9a6oRYfbhanrMbFRdPIPDNp4bC5W9YsJVUjpLaXjwGAQvmpmkxCRQpiSRJiENhQcQJlqrSzWpCZSuHmv0YFpxTVJCQRWVcbhGSQiBccy8sH33PFDiF+1eqlPN0vLEXh9vI5WVnKnLKkMkiUTHNBwGgGF3LS9ScDY4A8lvP1lZYyAtZLFYbFylOqr2Et7ceNsxzjsNynrItEDxP/JZFq3IPXLHATZ3Da5CJJy225scLiQkE4i5uVut0YEsv0yjcwuDufb7kZQ86a21Op/ja2WMnSyip2VQrYBNboFVx5qJNY5555Wf+HnKInoQ5Ck8H+YplLu3TdYLkn9UaKnXcSHZW+YEhRIa0IAPjuybaEXt5UnJq5zxgF8dPvbDMg0ajdZ55stySQMr4JBUJCJaWgsHHkpDaASBqYyxjPoAcVq3CQSFjySkZ1R0pxESmUJiELCBKr+imXcTM3W4HwZfaxotIO6tVbF5DikxGwgzKYLrC/xlRR+S/nmhjazOWLK6ZgV+izC9U8VpKSoo7XAT7YNOYHS+SJZLJZCGlZssdJ2C0bERmejqLlc6uesfw01vgQVVFI4ZEShkeEAZg4G955Gg0E4JmMonB+oSZlVr7a1rw2ijQBRMcLtLp1RTGkX+2jBxVXz56BTAE2pO+aUBXgHOvV9B8QmF3vXipHwi92DLeNeS/HG8lT1PT/EODPTfv8L56e84pMp08vPu8vo/AUWlZvNq3b2LNzRm6dxJJ/Rx7b16Qhws/DoUiMFAS5ORFDn3spwne7uB7VIJrwBpHCPQDxKP79tGGqT+cP0KtxCX6BwAAAABJRU5ErkJggg==")
bitmaps["babylovegui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAMAAABhEH5lAAACqVBMVEXpUY9pUl56U23fU5DtVpR1WGnsXJ5EX11YYmdfYmllYmmCZHuMZX1YZ2yVZ4NeaW1Vam5qa3ZVbXGObX6RbYmVbY2HboCab42qb5NRcHJ7cHulcJGacZCwc5yWdIWidZhUdnldd3xpd4F6d4aBd4hdeX5feX9heX92eYiiepl4e4uCe4adfJG/fqi5gKXDg67NhbRnh41eiY7BibRui5Sgi5yjjJ9ZjpHGjrnMjr5gj5VxkJlikZffkceekpvck8XLlL7hlMrJlb7WlcdclprNl7vhl83VmMFjmZ7hmdHpmdL0mdXCm7DInL/bnMbwndndns/ontbvntnon9fSoMfpoNjqodrrodrrodvmpNjspN7vpN7xpN/ypODupd/rpt/vptX0puLrp9vmqNj3qOb4qOZnqbDTqcLzqd/1qeTkqtj0quP4qufsq+D7rOtrrbXtreH7rezrrt74run5ruv8ru39ru5nr7Xzr+T4sOXxseH2seLlstP0s+f1s+fyteNwt8BvuMF0uMPquNn9uO9zusTyuub0uun8uu14u8fxvOX1vOj0veftvt35v+/ywuf0w+r6w+7/w/b0xOn3xOx1xdHxxej5xe11xtL4x+//x/L4yO74y+7/y/N6zdj/z/3/0PZ80d9/0d990uD/1Pd+1eGD1+R/2eeF3OqC3ev/3f+G3+2K3/CI4O+K4PCL4fKM4fGM4fKL4vOL4vKM4vOE4/GF4/KM4/SM4/ON4/WJ5fOL5fSO5faO5veP5viQ5/mJ6PaK6PiP6PqQ6PqQ6PmR6PqP6fmQ6fqR6fuR6fqQ6vqS6v2O6/yP6/2Q6/2R6/2N7P2O7PyP7P6R7P+R7P6R7P2S7P6S7P+S7PyP7fyR7f+P7v6T7v6S7/+V7/+T8P+U8P+V8P+W9f+dEdofAAABQ0lEQVR42kXLY1M0UBgA0PvaRrZt27Zt27Zt2+6229aTbdv+JW1NU1/PzEEARMLC+vo0BkyYmiBgAAR4brOpsqxln3S80dG1d4QB4eVmNh4xcWrpyyQmVhb2xG2MJjt/eLQ21lXzfvivH+Wp8C7tBF3L6naXF1QU5ahlxgX6hcpx7KId0bzaklI90wxvl390OubGnMNoRyalpjD3NW2xoqHVm/fWBtxD6Fwotir7LYpRFmFQ8XKw12aeRRcB9A3pjtHxf+W/aNkYBVFq3iDSmvCfhPzgSEkuKSeTMMGf46MI4Mz9s0aqs4+drYU/38f2hUEy4du2b/whZhaWbt8Z++YxkAn6V8aoBHzNXL+qXk5geCTAiz2f1MNpJO4GiPBE0HsVQaH0+5QwAs8EpJlfr+pXyeuFBpeykg8f5IWAuHXwJHAPd7iooDZ9upoAAAAASUVORK5CYII=")
bitmaps["discordgui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABUAAAAQCAYAAAD52jQlAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMi0yMlQyMDozMzowNFoiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAyLTIyVDIyOjU0OjM0WiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMi0yMlQyMjo1NDozNFoiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmY5NzJlODZjLTIzM2QtYTY0Yi05YjM2LTU5ZmY0M2ZlNjQ2MCIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpmOTcyZTg2Yy0yMzNkLWE2NGItOWIzNi01OWZmNDNmZTY0NjAiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmOTcyZTg2Yy0yMzNkLWE2NGItOWIzNi01OWZmNDNmZTY0NjAiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmY5NzJlODZjLTIzM2QtYTY0Yi05YjM2LTU5ZmY0M2ZlNjQ2MCIgc3RFdnQ6d2hlbj0iMjAyMy0wMi0yMlQyMDozMzowNFoiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4kuCcAAAAB00lEQVQ4ja1UPUvEQBAdUUS5wsLC3rP0TrGzsrESLKzycWfOuyT3AwQFQaxORBQULP0PVgqCX/iBgmAlCAoqNoL4kexeK+ibJMq5rnCoxWOTebsvs/MmQ8VCQMWxgEpOQLYnyPRlj+XLKaxHlie3k1iL6VXbsLZaeLd8sY7nE+ybxtqXQ6wEjbEE5BRDKiTApjWjLN+wsRY3wCNQBZ6Aa4V/w7kNxw3IKQU0ClDODSnvsqCYNPxvgnXBiIUreS+kHICr8fVECuTrbwS/ZOzJdi4PZ8g1m/mrYIJFTpJysREP/yQqbC9sguNy4IcN+8DOD9wesKvjoDfEjle+uylWEQdXZX5O4VbMctRW3ILLmk5Y4qtvakQ7+FAsLBuUQ6kkTjAmpcn2gEUv1fZABv1x00cZpZUPZqMfwIuEMxrRGxZ91LTGFdBnlmUGImdfOXGBWC/4LETPNaIvLCr+yfkPVEkXBG7rFLjTJcV1WVCCXI4JYDZpHbU8z8AhMI+z41jvFX6F7MhJMYiX41qzLD/M2H4yoXzZCXQDXeBSbCJmRlqZFaeID6FPKRK1I5cxVDwxjCm1BeIQU6s57woyylGJPmHwfog6btgIs3aS24yYcd/yz0TvJMcgxVE+atQAAAAASUVORK5CYII=")
bitmaps["robloxgui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMi0yMlQyMDozMjo0MloiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAyLTIyVDIyOjU0OjE5WiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMi0yMlQyMjo1NDoxOVoiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmY5NzZmODFmLTE3MDQtYzk0Yy05NjE1LThkYjczYjk0ZDVmNiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpmOTc2ZjgxZi0xNzA0LWM5NGMtOTYxNS04ZGI3M2I5NGQ1ZjYiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpmOTc2ZjgxZi0xNzA0LWM5NGMtOTYxNS04ZGI3M2I5NGQ1ZjYiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmY5NzZmODFmLTE3MDQtYzk0Yy05NjE1LThkYjczYjk0ZDVmNiIgc3RFdnQ6d2hlbj0iMjAyMy0wMi0yMlQyMDozMjo0MloiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7vrBMcAAACIUlEQVQ4EXXBwWpdVRiG4ff719p7h5OmpRMpHShiwIDoQMEOmgbSgDOvoQjiNQnOHHgRKlFD68BhS8GKRKhgR0VMT+o5Z+/1f7amPSqtz6Pj1y9hnhK1xHfR8o8lfJlDHJVVu31eE7/3HSe5Qe8l/WLFZgw8ZEIU6qz/Ewe46bVpmu25BBv4Q48mFT+P1Ftl4miIvNngJ9vYkIIA6qJtkSmK80Ay2CRnArZHynbffGPIkRF+dO1uSj6qyS3guE4SlgizHzaWeM6AMBZ/62CHUnaMP75AEBFf1c3+BBnG5ex6EgjzMgbMEzZP9SFO0hfq6XSR6rZdmC5L5jkJbLBB4gWJaG38PPKxyRUHSKwJWssV+LOtTj8UM0/+qwGDytexEXM6rfaNWLMpLt+j8slxyyuPMr7o+YcBp3/dzLgX4yQyYl82a4Yy6Pacyv1TMzG9HWLNCrpsh3VcUGdF74zolQTEMxKrafpocL575Vy5Y+f7S4N4xgnUb9vQUd1zkATh5N+C2Kpil/SuEeKMgQJ0w3SoCOo01RtRzcskLwpDE788hPt2UluN095JcyAMggTE/yiC1Xg4zkcw1KG2q4+XejNq7hbYo+mqxBsCLDAgs5YY3H1zPgaE0W87l5gvgzJMTC50i+Bcl2/NVa7VKa9J7KZ4tUPYkCSLXF1ewYPAVJ4QIAsMwoR0d1Lc7cf8tEdabrT35s49onwwI0pfZg8GzvwFnngUHu4H9AoAAAAASUVORK5CYII=")
bitmaps["paypalgui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAAQCAYAAAAmlE46AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMi0yM1QwMDowMjozM1oiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAyLTIzVDAwOjAzOjExWiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMi0yM1QwMDowMzoxMVoiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjVlNTE5Y2EyLWU1MjQtYTM0OS05Y2FhLTExZWQwZmYwZTc1OCIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDo1ZTUxOWNhMi1lNTI0LWEzNDktOWNhYS0xMWVkMGZmMGU3NTgiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo1ZTUxOWNhMi1lNTI0LWEzNDktOWNhYS0xMWVkMGZmMGU3NTgiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjVlNTE5Y2EyLWU1MjQtYTM0OS05Y2FhLTExZWQwZmYwZTc1OCIgc3RFdnQ6d2hlbj0iMjAyMy0wMi0yM1QwMDowMjozM1oiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4BkaF1AAABKklEQVQoFWNggAG9fn4G3c56rFinM51Bs0ucASvQ6e5j1O36jwsz6HZ9Y9DtyMeisXMbPo1wAzBs1u18hqqg8RwSvsWo3QYR1+62Z0D2H4ompeIjDPLZ/zGwXNYHhtJt6Ui2dZijaJTPvYxVo3z2e4bpd78xzL4PtVW7IxxFo1zWe6wao2buY5z14D/DzPv1MP+1wTXptL3Aqsms4hzINrDGWffjoRq71sE1atSfQtHg0HicoWjzIZAGGAZq1IfZeA2uMX39HpjJ2DDDrAf7kAKn6xtcY+e5/Xg0LWOYf58dGvE96igBM+nGcbjCmQ++ARW3gQMDHpKIFOOPonHm/UdwjbMf9DHgBMAEDNdkO/E9WiCkMxAFgKGFohHDeXg0gkMNgtchAgITAACfKCNu3pc7egAAAABJRU5ErkJggg==")
bitmaps["githubgui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAAgQAAAIEBHRF40wAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAFJSURBVDiNjdOxSlxREAbg794sLizZZgvFLmxjIYGA+wA2BoutY2Fp4VOE1DYLPoFFyrCorY0W1oKFlSAphKiNRBCWNCfFnStnr2s2B4Y755/55575z5wipSRfRVEs4AvW0Q/4Bqf4kVL6M0VIKb0YtvGA9IbdYWuKk5FH/yA2bTRVALsRuMV3PM8gPeMAv2K/W7e/iEmAZwEu4XNo0A9/OWLnkTvBYgs7aIckT6HLPU4yqW4y/zG+beyUGGbBY/PXUeYPqZStj9TNFZ5l6GYt35XoRLV3IdS8NUEr/E6J69i08Ok/CqzFz+C6xFUWHBVF8f4tZsT2MugKBqp+9gP4ia9YyfpexbeI5bMxqBPG+B3Huwz/Y1Zgw+vBGueT2MOF6u4/YKGhfNkgX6DXfAs91YtLSDOuryaf1uSpAlnipmpYygZ+iM1m/l+r2AEqRmEVzAAAAABJRU5ErkJggg==")
bitmaps["updategui"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAAyVBMVEVHcEz/IUf/Ikf/IUf/IUf/IUf/IUf/IUf/IUf/Ikn/IUj/IUb/JEL/IEf/IUf/Ikf/Ikf/IUj/IUf/IUf/Ikf/IUf/IUf/Ikj/I0f/Ik3/IUf/IUf/JkL/JEv/JEj/Ikf/IUf/H0f/IUf/IUj/IEf/IUf/IUf/IUf/IEf/IEb/NFb/vcj/KU7/laf/L1L/K0//5ur/0Nj/S2r/7O//Kk7/JEn/Kk//fZP/fJL/JEr/QWH/5uv/QGH/SGf/nq7/M1b/na7/SGj/5+sudTdoAAAAJ3RSTlMA8dDU8s7V/v0FXlwFMIIxMIPohYTW8zEFCF7nBwgIX10F0DHQ6V/g0khgAAAACXBIWXMAAAB2AAAAdgFOeyYIAAAAnElEQVQIHQXBBQKCQABFwa8Cu5jY3fEAuzvvfyhnJA3H5UmtNqoUfEnqzarWRJGxXropNfpTCFerEEppX/UqEL8+b8ALVLYQ7vb7XQi2qKQBvr/7EzCuHIDbZvMASMgBiLfbGCChpAGu58sRMK4qFjjN5wfA5lXwgMVyuQBSOfmtErBeA+1MVuoOPGuiyNhUpiNJflB0HcfN57LSH2+WFhZkM2KAAAAAAElFTkSuQmCC")
bitmaps["kingbeetleamu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMy0xOFQyMjo0ODowMVoiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAzLTE4VDIyOjUyOjUzWiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMy0xOFQyMjo1Mjo1M1oiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjc5NzIyNzI3LTQ5ZWYtYTg0Ny1hNzA2LWI4NjE5ZThkMWI3YyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDo3OTcyMjcyNy00OWVmLWE4NDctYTcwNi1iODYxOWU4ZDFiN2MiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo3OTcyMjcyNy00OWVmLWE4NDctYTcwNi1iODYxOWU4ZDFiN2MiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjc5NzIyNzI3LTQ5ZWYtYTg0Ny1hNzA2LWI4NjE5ZThkMWI3YyIgc3RFdnQ6d2hlbj0iMjAyMy0wMy0xOFQyMjo0ODowMVoiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4pvtxCAAAFTUlEQVQ4y1WVC0xTZxTHP2wrEWa0BcqzBQYitBQUZQFBRVoYkCyLmcsUCb6GYBEfc74HlIcoU3mooCIVVsVQQMuog2j6EI2AcSpPxQkRFbC6KUKhhWn23+01ZPMk5z7P+d3zne+ccwkAYtGAgABSWlpKMjIyiI+PD4vJYkld3dwa/UX+fRGRkWORYvGEv0g0wLHjNFIq9fPzYyUmJpLCwkKSnZ1NJiYmaA6ZBgYFBRGZTEYEAkEK351vSEpORlW1Eg86u/DsxRAGng/iQUcXlHV1SJFK4eLqapjv65uSnp5OioqKiNFo/BQYsXw5oeRc+LJl0OpvwCLPhoegrv4N8vxKnC47i/oGNZ5TcIto9c0IDQuDja1tuQU6zSH3798nOp2O8Hi8cklUFEbGJjAyaoQsJwtRIRL4hcyDRxwPIh8RFgQGQiwWI1Mmw8g7I95Rtiuoe0cnR7leryetra1kWjZIosUYNU7hVvNTLFsag895fAT5LoZ3owiOms8Q6ClAsH8QgoOD4e7OR2zcl+h5NEBBpxApjoCFwWKxiCV3TCdnJ/O1azfxdnQUJYoozPf1hoOVECu+i0Hs8FbYa2cjfncSIpd8Bb6LC8KWhMDVxZuKVkIFMYbrmmZ4z/M2U/lnkoULF25JSEzE2zeA4td9aOpkoe+vBdi6Zz0U9a/R/coEO80sKP++jjejU9ifnw9XR08IfEIQv5mgRr0F4+PA95uTwOFwpMTJ2Vl3vqIWr0eGUdXogZx8gqs6Wyq/MTC8b8C9Ox+g6ryN7pEeTEuh4jpWJdigoGIGissd8PLVIC5UqahcOmmI0F84+Pu9XtSrL+OHvVaovEiQe4TgVBkDvUMcGCb3ob97En2P/4Hp/UegtvsoZMVWKD7HwVkFwe07Vbjd8gSiANFbQhWseejlSxw+cgIzCBu70iWoUrmg4BTBkeNMaNqsMfRhFdr776LjEVCrycCuHELD6hrZ+GYNE4cPF+PZcwPEEglo4OCwAQWFBZadQvLBCqhuaHCybDHOnKegxwgqa63wdDIW2s4fsSNjBo6WzMYl1Syk7XKnfByQl1eEYYOBLiFqyf5DXQ8foVpZQwOlsjw03XuBM/Kr1LJTqTMbP1PRllyyQVWrHXJruajUzEXO0UXg2vvD1sYOyholenofQyAUGsjcuWxd3RUV1V6DcLZnY3FENNQdfbhU34ByhQYl8vMoORmO4tMMnD1ujbpUAv2Jr/HttkOwItbw9fXBANU9yto6OHC5OkI1vzR+7Vo62WlpaXSUB4vL0fx4EBdVV1Cm1qP0pzOo9uJCZcOAzi0IxzbmwHXBF7Tttu3bad818fEIWrRIStavW8dkc9hm7Y1mjI2b4eXpQRtmnixH492HaOjogbJYDkVEIiqkOdi9JxfuIaG0jUgkottP33wLbA7HnJCQwCJMBoMwGIwN0TExmDBP4Un/U3jwebRDyIoo7MjMw96MQ0g7kImYpBTMdLCn3wkFAvT+0Qfz1HtIoqMszzbSTdzW1kY0Gg2ZaT1THkltu8VgbNyE5OQUzGIxaOf/qyMFTKVSM2o0wWiaRExcHNx4bnKdVvtxOFhGjslkImtWryZ8Pr88JDQU+pu36LxYZuAvigvIys5Bdk4uFBeq6GfT4ytSIrZ8RB4QGPjf+LIc2tvbSVZWFlGr1WTOnDkpHp6ehg2bNlHlUEcv69Wfb2Cg1HJdc/kykpI3w8vby0BN+S2xsbGEy+V+Cuzq6iI7d+4kLS0tZGl4OP0LcOPxUqmp3CQUCvstBWtRqmb7nV1cmphMZmp4WBjrwP79ZOXKlZ8A/wU2S30rPX5tBQAAAABJRU5ErkJggg==")
bitmaps["supremeshellamu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMy0xOFQyMjo0ODowN1oiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAzLTE4VDIyOjUyOjM3WiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMy0xOFQyMjo1MjozN1oiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ5M2U4NGFiLTMwNzUtYzQ0Ni05ZTNhLTIwZjBjMDI1ZDg1NyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpkOTNlODRhYi0zMDc1LWM0NDYtOWUzYS0yMGYwYzAyNWQ4NTciIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpkOTNlODRhYi0zMDc1LWM0NDYtOWUzYS0yMGYwYzAyNWQ4NTciPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmQ5M2U4NGFiLTMwNzUtYzQ0Ni05ZTNhLTIwZjBjMDI1ZDg1NyIgc3RFdnQ6d2hlbj0iMjAyMy0wMy0xOFQyMjo0ODowN1oiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz6lFK7pAAAFW0lEQVQ4jW1UC0yTVxi9G6KiDKS8BKFFoNiW8m4pDwFbiqgoig/UTGHihEJAdIIDCoiyLUYimCnyWkFwUBV0m4BzWhUECSNL5kRe8qYFJywqAjJ1cvb3T+aWzJuc5Obee06+77vfdwgAokVbWxvp7u4mw8PDJDU1VYfFYsns7O3rOFxO7yqx+IVYIpmh9gMsG5s6J2fnuPz8fF2VSkWUSiX5R0OLdxu1Wk1aWlqIWCzet4RhNLY1PByKsnP49bd2DI5oMDisxv0HD1FWcR5hW7aAevPY1dVVVl1d/X7Bjo4Ooq+vX8havhzXb6igXRrNGGprrqG4QIGikhJcra2DmjrTLu0bOzYbZubmisGBgX8Fp6eniUajIUwms8hdKMTzqRlMUsg++gWk66Xg+thjhcgeTjw+XF1cIA2UIuvoMTydnMbUzCxEXl5YYmRU2t/fT5eLrp2vr+/uZdZWeDH9En2DwwhZHwKmoTFc+I6IPr4Fkq2+8Hfwgv8KITx4LrBYuhzr1q5BT18/pl++ggNnBTwEbnurqq4QUlhQ8KHe4kUz2hQmp2cRHLwaTIMlCAiQQpScAPHF41h5IRHeBbvg+/k2SEJXYkcIFzxbK0ikq/Fscgo3VLehu8DgVW1tqS5h29tHb9q8ma5L5pEMMOYthPfOXRAocmBbcQwOlRlwv5UFp5ZYiB7EIaBpP2Lz/BAiZMPQ0AJp8nSau2HjdohEdvGEzWarSsvKMfJ4FHyuHbyCQ7Gu8iycz6RCdisfYVdPgFuZDrf6Q/Cuj4RXy6cI7TyIsBgprPWs4OklwrBaA+VFJUzNrG4TDoejvv+wHVcu/ABPlgCy05mIKcjAhpwUHLhXiJ03T8EhPwl+N7PBrYsBpzYcfm0xiPvlMNasXgn9+eaoqP4OXV3d4Ds5PSNUw872jg2hRF6CfcEROPB9AuLzIxFfLMeqM2lwU8jhVpYJfk06EobkCGncDUH9DkS1J+JQawakLiZQZGehf3QC0qAg0ILDY2M4nnICkvAAJF2NQ1zxDiSXp2BjcRZE31BiJRlwrklFbL8coY0xCLwejsg7EdjfI8ehXZa4kpmMLs1TBAZJoU1Z87CzB4Wni+ATHoivVNmIPS1DVHEa/L9OA+9UGjxK0yFWZUCoOgx+VRSkqmgc7JXhsx+j4MAwxqWz5Wjv7YOjk9M4sbGxuXXu/Lfo7eqBu48/9l4+hfhLX2JdESVEiQoU6fC9kAW/lpPwb0mBa30Egq5FILJoE7g8JqxNWBgeUaOm5jLMzMwaiYfAI3ZTWBj99bKPP4GeqwBrb1fCtzoPQkU2PJU58GkugiAnGtxVfHDWuoAn4sLWlEXNGUFC4n6au5nSEAoFiSQn58S8RYsXz6ruNOL55CTYFtYgLFs4ZyTD7eQRuOemgr8nFNYMUyzTZYBlYAGWKZMW4/K41AhOoaGpGR/o6LyuUirnk59bW4lEIt7DZNlg9s1bdD/qBdvMnCYYGZvAytQcFrr6sFpqCWsmk2pmQ/rOwcEBHVSZXv81B1s7Oyo6YUxDQwMhubm5JC8vj1hYWihE3t748/VbyhxeIlYWC0tTU5r8X1haWiJGJqMje/N2DgJPXzCMzSq09jc3N0fIxMQEbTujo6PE2MRYYWNnizuNTXRdtB5YTvnf0WPZNM6VV2BgaIS+u9t8j7IvHhgMnfInv/f93w+1aKXSF4lEcQv19Ma1BnuJ+jmto4z/8ZTGo74B+mzb9u3Q/8hgwtHRNWH8STPFnX2/YGdnJ2lqaiJyuXyBQCBIMDYx+YnvxB8MlErppqVGa4gy1BtcHi8xKenwwqa7TRRPQ+HRO42/AcCTid7dtvPaAAAAAElFTkSuQmCC")
bitmaps["savefield"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAACXBIWXMAAAsTAAALEwEAmpwYAAAE2mlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMy0yNVQwMjo1NDo1NVoiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAzLTI1VDAzOjE1OjI5WiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMy0yNVQwMzoxNToyOVoiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmU1Yjk5ZGVmLTE4ZWQtOGQ0YS1hZTM0LTg5OGJkYjgxZDdkMyIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDplNWI5OWRlZi0xOGVkLThkNGEtYWUzNC04OThiZGI4MWQ3ZDMiIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDplNWI5OWRlZi0xOGVkLThkNGEtYWUzNC04OThiZGI4MWQ3ZDMiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJjcmVhdGVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOmU1Yjk5ZGVmLTE4ZWQtOGQ0YS1hZTM0LTg5OGJkYjgxZDdkMyIgc3RFdnQ6d2hlbj0iMjAyMy0wMy0yNVQwMjo1NDo1NVoiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyMy4zIChXaW5kb3dzKSIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5yEIOIAAADIUlEQVQ4Ea3BW2hbdRzA8e/vf04uzWrSpk2btinSlmCF2s12RbopOvYwHwqdsjEQNkcnuCkMFdEpKqIg4osIPlR3AS1T5+YF8W0PZWD7NN3UOefoqL3Y0kvSNGmTdsk5P3fKFME8+ODnI6c/+Wz/F2eG+qdu3NDquhqtjMRYyaa4o6qOuelrOCUXY9igCMYINfE2E483LAwODh7hL5vvaR8B9M5771OIKKAQVECDtZ0aSXRrKNallQ1btb33MY217VRAAd23d/dpVUVV4YHu5Fm7plu/zKv2Hf1Ya2sb9cCzH6pl2Tr0ner5CdVvrqp+dUV14IVT+ubJ65po6dBYa68C+vZbbzyjqtiBYFBLhVUufQ+zs38gOOSzi6gqywtpAv4oqpBJFTj1zgC7Hj0KpTU2979KLn2AYy8feXdLV89Vo9xiBL8NthFU+ZsLqIICqmxwEdR1WJ4bY8+xw+Br5LmnD75m+AfXcbAsi03hGjyx+ih1TRCugkRLBU+8eIKH+p4km01TWFnCUZDaJAFL8ja3WTbYtmFufoavTzyP6zq8fmgrwYog6+sOlmVItN7FpQtnyeWWCfgDqAOUCgSCFUWb21YzkOzpJzV5hdzSLPHqOLNTv+EsrWAswTOxeBkxSvv9+2nftpd8BhTFY+NxXdZWIBxPsuupj3DVQRD+RUABEYOgFHKAKh4bBQmFUVU+f6WX+fGL/BfRpg4ef+8ygU3VKIvY3CKBEPlskfnxi/Rs76Nnx04yqRIggIICIngiUYsfR0cYHT7HamYNn78Cj43HdRBx8Wx/+BADL+1maoyymlvh0/e3MDp8DmNcXNfBYyMgCgbBs7Q4w+QYzE6UKEddm/TCNBtE8AiC4X9is0EQMXhEBBEQMZQjAiKCR8QAgsd2iutgB6mK+/CEq+tJtIC6hnISLRCJNuCJ1IcwvhBOaR3p6rx75Iefft3mT+zg5vQwJhinraOTfM6hnFClxe/Xr1HMTeJrfJDizAWSrU0/ywfHTx4+M3R8T3puXGsSHbqUmmE5lcLnF8op3lTC1VVEY82kp3+RSKxZHtl38Ns/Ae1wSi179ePEAAAAAElFTkSuQmCC")
bitmaps["savefielddisabled"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABIAAAASCAYAAABWzo5XAAAACXBIWXMAAAsTAAALEwEAmpwYAAAFsGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNy4xLWMwMDAgNzkuOWNjYzRkZSwgMjAyMi8wMy8xNC0xMToyNjoxOSAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0RXZ0PSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VFdmVudCMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIiB4bXA6Q3JlYXRlRGF0ZT0iMjAyMy0wMy0yNVQwMjo1NDo1NVoiIHhtcDpNb2RpZnlEYXRlPSIyMDIzLTAzLTI1VDAzOjE2OjM3WiIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyMy0wMy0yNVQwMzoxNjozN1oiIGRjOmZvcm1hdD0iaW1hZ2UvcG5nIiBwaG90b3Nob3A6Q29sb3JNb2RlPSIzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjI4ZmJkNzlmLWJlMDEtNjE0Ni04MjUxLTY1N2FkMDgwY2UyNSIgeG1wTU06RG9jdW1lbnRJRD0iYWRvYmU6ZG9jaWQ6cGhvdG9zaG9wOjc2NDdiNGE5LTVjMWItZWE0My1hNjQzLTU4Yjg3MmRiZDRhZiIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOmRmZjg4YzUzLTJjMzYtYzI0MC1iZWMzLWJkY2U1ODg5ZTVmOSI+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249ImNyZWF0ZWQiIHN0RXZ0Omluc3RhbmNlSUQ9InhtcC5paWQ6ZGZmODhjNTMtMmMzNi1jMjQwLWJlYzMtYmRjZTU4ODllNWY5IiBzdEV2dDp3aGVuPSIyMDIzLTAzLTI1VDAyOjU0OjU1WiIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDIzLjMgKFdpbmRvd3MpIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDoyOGZiZDc5Zi1iZTAxLTYxNDYtODI1MS02NTdhZDA4MGNlMjUiIHN0RXZ0OndoZW49IjIwMjMtMDMtMjVUMDM6MTY6MzdaIiBzdEV2dDpzb2Z0d2FyZUFnZW50PSJBZG9iZSBQaG90b3Nob3AgMjMuMyAoV2luZG93cykiIHN0RXZ0OmNoYW5nZWQ9Ii8iLz4gPC9yZGY6U2VxPiA8L3htcE1NOkhpc3Rvcnk+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+em1joQAAAp5JREFUOMutVM1LYlEcPU+fGJJ9SFhmUVjQwiLEheDGIIJ2grqIYPbjziBwUQwUtR5oFUSbYEQYcOVG3LTpL5BGJLLa5HffWGB25/5+8N44kzO0mAOP93Hv79xzzu/epyQSiU/JZDJ4dnYmRkZGxMDAAO7u7mCz2XB1dYVWqwWj0QiCEAIGgwFOp9PgcDhq+/v7UWiYnZ09oTk+n0/IAkHP2iULxPT0tBgfHxeTk5NiaWlJyPn6eCQS+UbkdMHj8XyX7IIQj8eF3W4Xm5ubTFooFMTLy4uo1+uiUqmInZ0dkUqlmHxmZobJdnd3Y0Skms1m8fz8jHw+j+vra1Z5f3/Pq5RKJaiqys+1Wg1yAayuruL19RWhUAiNRgMbGxtfvV7vDwMVkm/Kge4sswOKouj5aHh7e+NFt7a20NPTg2g0+kXtLGq320zY39/P76OjoxgbG8PT0xN/297ehtvtRjqdxuPjI8+RDaKapk5EFugql8vY29vjVcPhMCwWC2ROPCazQTabxcPDAyuhhamrvb29LZ3o5uYGfr8fl5eX7H1oaAgXFxe4vb1lywTKibC4uIhAIMA1uhDNM0klK+vr6/yuZdMN2hgpo7k6EcmnMNfW1iA3Jj6CiYkJHB4ewmq1/iKSW4DZiWRhYQHLy8u6Da1jmgqyfHx8jEwmw9aolveRZk2bGAwGEYvFfvPfCTo6REZE1GGtVv3TNymhsCnobqDCarX6Tq0B/wnvFDG7bPffutY51jlHpQ1Fm02edD2DwcFB7sq/MiJQDYXdbDahzM3NneRyOf/U1BTOz8+5nfPz89zFbujr68Pp6SlvVJfLhWKxCPmLySkHBwefj46OIvKkC6lCUNjytwGTydSViByQquHhYfrxKfKurKyspH8CQbJRXIJ6BNUAAAAASUVORK5CYII=")
bitmaps["allfields"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGQAAAAUCAMAAABMHminAAAAYFBMVEUNDQ1HR0ff398AAAAeHh5cXFxjY2PT09Pr6+sWFhYnJyf/vwAAAADRnADprgCqfgBCLwC4iQAmGgDdpQCccwBrTgD0twB9XACNaABXPwDtsQDFkgDcpABHNQDhqAA8LABpXx7aAAAAC3RSTlPyuCAA4aOcLBTp2IexPKcAAAEESURBVDjLtdLXboQwEIXhoWxJfDw2rrAlef+3zHhRpBRfRM76F1wgJD6YgabTQOgYDeNEJ0LnaKQB20V17HLHgQhi9OwNMwGqc8AfEI1y1IJWEoP/hQQsXxGD0gJ+KuJc/obYDl/i3eLSL2SBnHa1viDawYF5A3IjEnLCtYZom9QSBWFn5CbnrPzWiNiriuvPnURBQihTStDGPca1btw6Lo+kjKt9SUSJBYkPJK1AaEMMSrqCrPsTBbGfi/fwTchmyshCbSdOKx8F8bKzAM5GEG5B9jcMtoLIFLH/XQaIYLmEaRhXY3WEwKprN7zSgLtXHbu940gjoXMvZ5rGw4yOzcfz9AHU/FucFIbdDgAAAABJRU5ErkJggg==")

;beemenu
bitmaps["gifted"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAsAAAALAQMAAACTYuVlAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAACRJREFUeNoVwjERACAMBLBIr7RKqQRGJp5rLoqiGQ6XjLTUfj6prwwjH5l0JAAAAABJRU5ErkJggg==")
bitmaps["beedigit0"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAALAQAAAACFIpq2AAAAAnRSTlMAAHaTzTgAAAAoSURBVHjaY7BjYFJlYLrHwOhoz7zwARMDAxAxP1RgcGRgUmJgus0AAFunBZXlZXSIAAAAAElFTkSuQmCC")
bitmaps["beedigit1"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAcAAAANAQAAAABNskkYAAAAAnRSTlMAAHaTzTgAAAAZSURBVHjaY+BgMmD4wcTAIMHEgIAM/5gYAB78AllVws+EAAAAAElFTkSuQmCC")
bitmaps["beedigit2"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAAMAQAAAACYJ6oOAAAAAnRSTlMAAHaTzTgAAAAhSURBVHjaY6hjYGBmYGKAIQibjYGJh4FJgoGxkJ+pjwEAGGMB0AVJCscAAAAASUVORK5CYII=")
bitmaps["beedigit3"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAcAAAALAQAAAACb66oFAAAAAnRSTlMAAHaTzTgAAAAbSURBVHjaY/jDwMbEwMzIZMLEwMDGxACCDH8AGcUCSaxCWr0AAAAASUVORK5CYII=")
bitmaps["beedigit4"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAANAQAAAABTe3mrAAAAAnRSTlMAAHaTzTgAAAAqSURBVHjaBcAhFYAwAADRz02AIARRSEoZCk1O7jl16dbSo6mX3/iOMERsVRoD3hvuAP4AAAAASUVORK5CYII=")
bitmaps["beedigit5"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAMAQAAAAB35cEwAAAAAnRSTlMAAHaTzTgAAAAeSURBVHjaY/jHxMB0iIkBBBn+MLAxMTL9Z2Jg+AMANzAEz+96xZQAAAAASUVORK5CYII=")
bitmaps["beedigit6"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAALAQAAAACFIpq2AAAAAnRSTlMAAHaTzTgAAAApSURBVHjaY5BnYGJkYHJgYHrAwHCAgYmfgfHhfOaLCkwMDAyJDEx3GQBSCQXP8S0kmQAAAABJRU5ErkJggg==")
bitmaps["beedigit7"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAANAQAAAABTe3mrAAAAAnRSTlMAAHaTzTgAAAAiSURBVHjaY/7PyPCfgYGJgYmBgQlCcjAw/QEzBBiYGKAIAF1CAy/lPwiRAAAAAElFTkSuQmCC")
bitmaps["beedigit8"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAALAQAAAACFIpq2AAAAAnRSTlMAAHaTzTgAAAAnSURBVHjaY7BjYFJmYGIAIWam58zMn5jYGZjkGJgXKjA4MjD9YwAAOLsEet1G4MkAAAAASUVORK5CYII=")
bitmaps["beedigit9"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAkAAAALAQAAAACFIpq2AAAAAnRSTlMAAHaTzTgAAAAoSURBVHjaBcBBEQAQAATAdUYpD1X08FZMFkEYQxpHqHemy6ZI5MnyAUcCBJI1ZIEgAAAAAElFTkSuQmCC")

;buffs
bitmaps["snowflake_identifier"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAUAAAABCAAAAAAzlTsvAAAAEUlEQVR42gEGAPn/Ae0AAAAABK0A71vtvPwAAAAASUVORK5CYII=")
bitmaps["buffdigit0"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAAAAAAAA8wAAAAIAAAAAAgAAAAACAAAAAAAAAAAAAADzAAABAADzAIAxBMg7bpCUAAAAAElFTkSuQmCC")
bitmaps["buffdigit1"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAIAAAAMCAAAAABt1zOIAAAAAnRSTlMAAHaTzTgAAAACYktHRAD/h4/MvwAAABZJREFUeAFjYPjM+JmBgeEzEwMDLgQAWo0C7U3u8hAAAAAASUVORK5CYII=")
bitmaps["buffdigit2"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8BAPMAAADzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPMAAADzAAAA8wAAAPMAAAAB8wAAAAIAAAAAtc8GqohTl5oAAAAASUVORK5CYII=")
bitmaps["buffdigit3"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAPMAAAAAAAAAAAAAAAAAAAAAAAAAAADzAAAAAAAAAAAAAAAAAAAAAPMAAAABAPMAAFILA8/B68+8AAAAAElFTkSuQmCC")
bitmaps["buffdigit4"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAGCAAAAADBUmCpAAAAAnRSTlMAAHaTzTgAAAApSURBVHgBAR4A4f8AAAAA8wAAAAAAAAAA8wAAAPMAAALzAAAAAfMAAABBtgTDARckPAAAAABJRU5ErkJggg==")
bitmaps["buffdigit5"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAALCAAAAAB9zHN3AAAAAnRSTlMAAHaTzTgAAABCSURBVHgBATcAyP8B8wAAAAIAAAAAAPMAAAACAAAAAAHzAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHzAAAAgmID1KbRt+YAAAAASUVORK5CYII=")
bitmaps["buffdigit6"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAJCAAAAAAwBNJ8AAAAAnRSTlMAAHaTzTgAAAA4SURBVHgBAS0A0v8AAAAA8wAAAPMAAADzAAACAAAAAAEA8wAAAPPzAAAA8wAAAAAA8wAAAQAA8wC5oAiQ09KYngAAAABJRU5ErkJggg==")
bitmaps["buffdigit7"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAMCAAAAABgyUPPAAAAAnRSTlMAAHaTzTgAAABHSURBVHgBATwAw/8B8wAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8wIAAAAAAgAAAABDdgHu70cIeQAAAABJRU5ErkJggg==")
bitmaps["buffdigit8"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAgAAAAABAPMAAAEAAPMAAADzAAAAAAAAAADzAAAAAADzAAABAADzALv5B59oKTe0AAAAAElFTkSuQmCC")
bitmaps["buffdigit9"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAQAAAAKCAAAAAC2kKDSAAAAAnRSTlMAAHaTzTgAAAA9SURBVHgBATIAzf8BAADzAAAA8wAAAPMAAAAAAPMAAAEAAPMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA87TcBbXcfy3eAAAAAElFTkSuQmCC")

;conversion
bitmaps["makehoney"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABkAAAAOAQMAAADg9CUDAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFFJREFUeAEBRgC5/wDgAAOAAOAAA4AA4AADgADh/4OAAOB/g4AA4H4DgADgPgOAAOAYA4AA4BgDgADgGAOAAOAYA4AA4AgDgADgAAOAAOAAA4BWYxcOMd0SeAAAAABJRU5ErkJggg==")
bitmaps["collectpollen"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABcAAAALAQMAAACu8IQDAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAADdJREFUeAEBLADT/wDBgAAAwYAAAMGAAADBgAAAwYMGAMGDBgDBg/4AwYP+AMGDAADBgwAAwYMAV/YP6c5DNZYAAAAASUVORK5CYII=")

;collect
bitmaps["passfull"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAANAQMAAABvi/fXAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAExJREFUeAEBQQC+/wAGAMAAAA8AwAAACYDB+AAYgMH4ABCAwYAAEMDBgAAwwMGAACBAwYAAP+DBgABgIMGAAEAgwYAAQBDBgADAEMGAw1sXQS/tL+4AAAAASUVORK5CYII=")
bitmaps["passnone"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACMAAAAHAQMAAAC4KmY6AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAADVJREFUeAEBKgDV/wB/A/gfwADBgggQQADBhgwwYADBhgwwYADBhgwwYADBh/w/4ADBh/w/4DR2EGRmE1R+AAAAAElFTkSuQmCC")
bitmaps["passcooldown"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACAAAAALAQMAAAAk3x1CAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEJJREFUeAEBNwDI/wDAA/B8AMADAIIA/gMAAADAAwEBAMADAQEAwAMB/wDAAwD+AMADAAAAwAMAgADAAwDGAMADADiYVQ4O+iTe6QAAAABJRU5ErkJggg==")

;inventory
bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
bitmaps["blueberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAFkAAAASBAMAAADCum8zAAAAD1BMVEUAAAAbKjUcKzYdLDceLDe8hzzeAAAAAXRSTlMAQObYZgAAAJlJREFUeNq10oEJAjEMheEXXSD/TaCb6P5LSfo42sAhRTAkIYGvB1cqSO0Hg0c7Et80+zqL/lsz1arznVVhV11TB4yWkkaHUfc0AhadlaGZyJXeIK+0e20unO3bN+DUT2BqH+x/GRSxrjGnfslai6711DVOnbHqGGrR0bQyPMWij6Gdj6ahvRMPuB2+76kHEaTHy+h6M37Qkj4y8wuCNNqdxAAAAABJRU5ErkJggg==")
bitmaps["strawberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGUAAAARBAMAAAA24X8rAAAAD1BMVEUAAAAbKjUcKzYdLDceLDe8hzzeAAAAAXRSTlMAQObYZgAAALlJREFUeNqd0tFNQzEUg+HftAPYwADtBowA+y+FsJKGqO3DrZUTXTn3e4gUaMR9xLMouRw1VzhsDLxklKBzOCdGdG3GP/4bGWRyMylPSxOUNt2Tzqlm/Kp+lw9jxFqBjkHAKR4nw2A8zZSGTiiFLJMELHIz1yTLDA76ombSTyFNkyRe5nsa7yZBYRqAZazHRv+NNoO1LrMZ87bqy2aSbgkoNSSpoV3eW5llZHqyPZ/Rf7BlM0fysgF+AYk1CtE5QOD0AAAAAElFTkSuQmCC")
bitmaps["glitter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAADcAAAAPAQMAAAB6PMXFAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAFFJREFUeNotyLEJgEAQRcEXyNZw4Y+MDQ1EPWzIEoy0Le3I8AQRWfaigQFDMzBVc/WsbpaemzYsg6vcdBy7q/ANl09sLuLyR2QLR0v9WgSWAP1wyRghiUY/cgAAAABJRU5ErkJggg==")
bitmaps["gumdrops"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAFwAAAAUAQMAAAA6KsgaAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAHpJREFUeNqdzrENgCAQheGnXtTCwg1kBCZQ2cRJDAkmNg6FsIgjMICFECJS+zeXr7jkITbHMyGkI0QOnUN2/e1gFswRth3s6dbqClDEbdkKAvbDgxmPLaHuhMohNeQHhnN7fySHIA8eAIaxcooGU7i1ueBThDIMT/3GA3+GKqkj9c29AAAAAElFTkSuQmCC")
bitmaps["blueclayplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAJ8AAAAWAQMAAADkatyzAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAdlJREFUeAEBzgEx/gD4AAAAAAAAAAAAAAAAAAAAAAAAAAD+BgAAAAAADAAAAAHgDAAAAEAAAAD/BgAAAAB+DAAAAAH+DAAAAEAAAACBhgAAAACCDAAAAAECDAAAAEAAAACBhgAAAAGADAAAAAEDDAAAAEAAAACBhjBAAAGADB8MDAEDDB8MAfAAJgCBBjBB8AEADAGEDAEDDAGP4fD4PAD/BjBCCAEADACECAH+DACMEEEEMAD+BjBCCAEADACGGAHgDACMEEEEIAD/BjBD+AEADB+CEAEADB+MEEH8IACBhjBH/AEADCCCEAEADCCMEEP+IACAhjBGAAGADCCDMAEADCCMEEMAIACAhhBCAAGADCCBIAEADCCMEEEAIACBhhBCAACCDCCB4AEADCCMEEEAIAD/Bg/B8AB+DB+AwAEADB+MEHD4IAD4BgAAAAAADAAAwAEADAAMEAAAIAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAFzEPdK0OEUMAAAAAElFTkSuQmCC")
bitmaps["candyplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAIEAAAAVAQMAAABbmR9GAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAYVJREFUeAEBegGF/gAAAAAAACAAAHgDAAAAEAAAAAA/AAAAAGAAAH+DAAAAEAAAAABBAAAAAGAAAECDAAAAEAAAAADAAAAAAGAAAEDDAAAAEAAAAADAA+GAAGMDAEDDB8MAfAAJgACAADH8D+EDAEDDAGP4fD4PAACAABGCGGECAH+DACMEEEEMAACAABGCEGGGAHgDACMEEEEIAACAA/GCEGCEAEADB+MEEH8IAACABBGCEGCEAEADCCMEEP+IAADABBGCEGDMAEADCCMEEMAIAADABBGCEGBIAEADCCMEEEAIAABBBBGCGGB4AEADCCMEEEAIAAA/A/GCD+AwAEADB+MEHD4IAAAAAAGCAAAwAEADAAMEAAAIAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAADAAAAAAAAAAAAAAIA3MKqb/Uz+AAAAAElFTkSuQmCC")
bitmaps["festiveplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAIsAAAAPAQMAAADu9q5yAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAShJREFUeAEBHQHi/gD/AAAAIAAAAAAeAMAAAAQAAAAA/wAAACAAAAAAH+DAAAAEAAAAAIAAAAAgAAAAABAgwAAABAAAAACAAAAAIAAAAAAQMMAAAAQAAAAAgAAAAPjGBAAAEDDB8MAfAAJgAIAHwPj4wgQfABAwwBj+Hw+DwAD8CCEAIMIMIIAf4MAIwQQQQwAA/AghACDDCCCAHgDACMEEEEIAAIAP4MAgwRg/gBAAwfjBBB/CAACAH/AwIMEQf8AQAMIIwQQ/4gAAgBgACCDAkGAAEADCCMEEMAIAAIAIAAwgwLAgABAAwgjBBBACAACACAAIIMDgIAAQAMIIwQQQAgAAgAfB+DjAYB8AEADB+MEHD4IAAIAAAAAAwEAAABAAwADBAAACAD/FQ7p8ZfErAAAAAElFTkSuQmCC")
bitmaps["heattreatedplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAL8AAAAPAQMAAACP7owwAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAYJJREFUeAEBdwGI/gCAgAAACAB/gAAAAAgAAAgB4AwAAABAAAAAgIAAAAgAf4AAAAAIAAAYAf4MAAAAQAAAAICAAAAIAAwAAAAACAAAGAECDAAAAEAAAACAgAAACAAMAAAAAAgAABgBAwwAAABAAAAAgIAAfD4ADATAAHw+AAAYAQMMHwwB8AAmAICD4AY+AAwHg+AGPh8D+AEDDAGP4fD4PAD/hBACCHgMBgQQAggghhgB/gwAjBBBBDAA/4QQAgh4DAQEEAIIIIQYAeAMAIwQQQQgAICH8H4IAAwEB/B+CD+EGAEADB+MEEH8IACAj/iCCAAMBA/4ggh/xBgBAAwgjBBD/iAAgIwAgggADAQMAIIIYAQYAQAMIIwQQwAgAICEAIIIAAwEBACCCCAEGAEADCCMEEEAIACAhACCCAAMBAQAggggBhgBAAwgjBBBACAAgIPgfg4ADAQD4H4OHwP4AQAMH4wQcPggAICAAAAAAAwEAAAAAAAAAAEADAAMEAAAIFF2Q5RnzOirAAAAAElFTkSuQmCC")
bitmaps["hydroponicplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAALEAAAAVAQMAAAAzap1+AAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAgNJREFUeAEB+AEH/gCAgAAAgAAAAAAAAAAAAHgDAAAAEAAAAACAgAABgAAAAAAAAAAAAH+DAAAAEAAAAACAgAABgAAAAAAAAAAAAECDAAAAEAAAAACAgAABgAAAAAAAAAAAAEDDAAAAEAAAAACAjAwBhMAAgAADADAAAEDDB8MAfAAJgACAhAw/h4Pg/AfD+DB8AEDDAGP4fD4PAAD/hAhhhgQQgggjBDCAAH+DACMEEEEMAAD/hhhBhAQQgwgjBDCAAHgDACMEEEEIAACAghBBhAwYgxgzBDGAAEADB+MEEH8IAACAghBBhAwYgxgzBDGAAEADCCMEEP+IAACAgzBBhAwYgxgzBDGAAEADCCMEEMAIAACAgSBBhAQQgwgjBDCAAEADCCMEEEAIAACAgeBhhAQQgggjBDCAAEADCCMEEEAIAACAgMA/hAPg/AfDBDB8AEADB+MEHD4IAACAgMAABAAAgAADBDAAAEADAAMEAAAIAAAAAMAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAYAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAMerStYWLR4mAAAAAElFTkSuQmCC")
bitmaps["paperplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAH0AAAAUAQMAAACataD0AAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAV9JREFUeAEBVAGr/gDwAAAAAAAAB4AwAAABAAAAAP8AAAAAAAAH+DAAAAEAAAAAgQAAAAAAAAQIMAAAAQAAAACBgAAAAAAABAwwAAABAAAAAIGD4IAAATAEDDB8MAfAAJgAgYAw/AfB4AQMMAY/h8Pg8AD/ABCCCCGAB/gwAjBBBBDAAPAAEIMIIQAHgDACMEEEEIAAgAPwgw/hAAQAMH4wQQfwgACABBCDH/EABAAwgjBBD/iAAIAEEIMYAQAEADCCMEEMAIAAgAQQgwgBAAQAMIIwQQQAgACABBCCCAEABAAwgjBBBACAAIAD8PwHwQAEADB+MEHD4IAAgAAAgAABAAQAMAAwQAAAgAAAAACAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAADLtjg13P4DpwAAAABJRU5ErkJggg==")
bitmaps["pesticideplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAJ0AAAAPAQMAAADERl/dAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAUZJREFUeAEBOwHE/gDwAAAAEAAAAAEAAAeAMAAAAQAAAAD/AAAAEAAAAAMAAAf4MAAAAQAAAACBAAAAEAAAAAMAAAQIMAAAAQAAAACBgAAAEAAAAAMAAAQMMAAAAQAAAACBgAAAfGAAMAMAAAQMMHwwB8AAmACBg+B8fGD4MH8HwAQMMAY/h8Pg8AD/BBCAEGEAMMMIIAf4MAIwQQQQwADwBBCAEGEAMIMIIAeAMAIwQQQQgACAB/BgEGMAMIMP4AQAMH4wQQfwgACAD/gYEGMAMIMf8AQAMIIwQQ/4gACADAAEEGMAMIMYAAQAMIIwQQwAgACABAAGEGEAMIMIAAQAMIIwQQQAgACABAAEEGEAMMMIAAQAMIIwQQQAgACAA+D8HGD4MH8HwAQAMH4wQcPggACAAAAAAGAAMAAAAAQAMAAwQAAAgP5rQDXjJsGFAAAAAElFTkSuQmCC")
bitmaps["petalplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAHYAAAAPAQMAAAALRKlbAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAPtJREFUeAEB8AAP/wDwAABAADADwBgAAACAAAAA/wAAQAAwA/wYAAAAgAAAAIEAAEAAMAIEGAAAAIAAAACBgABAADACBhgAAACAAAAAgYAB8PgwAgYYPhgD4ABMAIGD4fAMMAIGGAMfw+HweAD/BBBABDAD/BgBGCCCCGAA8AQQQAQwA8AYARgggghAAIAH8ED8MAIAGD8YIIP4QACAD/hBBDACABhBGCCH/EAAgAwAQQQwAgAYQRgghgBAAIAEAEEEMAIAGEEYIIIAQACABABBBDACABhBGCCCAEAAgAPgcPwwAgAYPxgg4fBAAIAAAAAAMAIAGAAYIAAAQPxqMvFduh0GAAAAAElFTkSuQmCC")
bitmaps["planterofplenty"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAJkAAAAMAQMAAABLOY0JAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAQdJREFUeAEB/AAD/wD+AAAAcAAAAAAAAAAAA4AAAAAAAAD+QAAAfhAAAEAAAB4IA/CAAAIAAAAQQAAAAhAAAEAAACEIABCAAAIAAAAQQAAAABABAPAAAACcAACACAegAAAQfh4AAhEh+PPBwECcABCPD8eggAAQQgEAfhARCEAhAECIA/CAiEIQgAAQQiEAcBARCEQgAECIA4CQiEIRAAAQQj8AABHxCEfgAECIAACfiEIBAAAQQj8AABARCEfgAACIAACfiEIIAAAQQgAAABARCEAAACEIAACACEIKAAAQQh4AABHxCEPAAB4IAACPCEIGAAAQQgAAABABCAAAAAAIAACACEAEACcfKiwo59aBAAAAAElFTkSuQmCC")
bitmaps["plasticplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAIYAAAAPAQMAAAAbCCXCAAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAARlJREFUeAEBDgHx/gDwBgAAAEAAAAPAGAAAAIAAAAD/BgAAAEAAAAP8GAAAAIAAAACBBgAAAEAAAAIEGAAAAIAAAACBhgAAAEAAAAIGGAAAAIAAAACBhg+AAfGAAAIGGD4YA+AATACBhgDB8fGD4AIGGAMfw+HweAD/BgBCAEGEAAP8GAEYIIIIYADwBgBCAEGEAAPAGAEYIIIIQACABg/BgEGMAAIAGD8YIIP4QACABhBAYEGMAAIAGEEYIIf8QACABhBAEEGMAAIAGEEYIIYAQACABhBAGEGEAAIAGEEYIIIAQACABhBAEEGEAAIAGEEYIIIAQACABg/D8HGD4AIAGD8YIOHwQACABgAAAAGAAAIAGAAYIAAAQMPiOJbfYHAOAAAAAElFTkSuQmCC")
bitmaps["redclayplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAJoAAAAWAQMAAAACQxf3AAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAdlJREFUeAEBzgEx/gD4AAAAAAAAAAAAAAAAAAAAAAAAAAD+AAABAAABgAAAADwBgAAACAAAAAD/AAADAA/BgAAAAD/BgAAACAAAAACBgAADABBBgAAAACBBgAAACAAAAACBgAADADABgAAAACBhgAAACAAAAACBgAADADABg+GBgCBhg+GAPgAEwACBA+B/ACABgDCBgCBhgDH8Ph8HgAD+BBDDACABgBCBAD/BgBGCCCCGAAD8BBCDACABgBDDADwBgBGCCCCEAACGB/CDACABg/BCACABg/GCCD+EAACCD/iDACABhBBCACABhBGCCH/EAACCDACDADABhBBmACABhBGCCGAEAACDBACDADABhBAkACABhBGCCCAEAACBBADDABBBhBA8ACABhBGCCCAEAACBA+B/AA/Bg/AYACABg/GCDh8EAACBgAAAAAABgAAYACABgAGCAAAEAAAAAAAAAAAAAAAYAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAAAFMRqnrn9fvAAAAAElFTkSuQmCC")
bitmaps["tackyplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAIAAAAAVAQMAAAC0W3R4AAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAAXBJREFUeAEBZQGa/gD/AAAAIAAAAPAGAAAAIAAAAP8AAABgAAAA/wYAAAAgAAAAGAAAAGAAAACBBgAAACAAAAAYAAAAYAAAAIGGAAAAIAAAABgHwABjBgYAgYYPhgD4ABMAGABg+GICBgCBhgDH8Ph8HgAYACEAZAIEAP8GAEYIIIIYABgAIQB8AwwA8AYARgggghAAGAfjAHYBCACABg/GCCD+EAAYCCMAYgEIAIAGEEYIIf8QABgIIwBhAZgAgAYQRgghgBAAGAghAGEAkACABhBGCCCAEAAYCCEAYIDwAIAGEEYIIIAQABgH4PhggGAAgAYPxgg4fBAAGAAAAGBAYACABgAGCAAAEAAAAAAAAABgAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAwAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAABgAAAAAAAAAAAAHKgMQ3R/o1WAAAAAElFTkSuQmCC")
bitmaps["ticketplanter"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAIEAAAAPAQMAAAD51D67AAAABlBMVEUAAAAbKjWMzP1VAAAAAXRSTlMAQObYZgAAARlJREFUeAEBDgHx/gD/AAAEAAAEAHgDAAAAEAAAAAD/AAAMAAAEAH+DAAAAEAAAAAAYAAAMAAAEAECDAAAAEAAAAAAYAAAMAAAEAEDDAAAAEAAAAAAYDAAMYAAfAEDDB8MAfAAJgAAYDB8MQD4fAEDDAGP4fD4PAAAYDCAMgEEEAH+DACMEEEEMAAAYDCAPgEEEAHgDACMEEEEIAAAYDGAOwH8EAEADB+MEEH8IAAAYDGAMQP+EAEADCCMEEP+IAAAYDGAMIMAEAEADCCMEEMAIAAAYDCAMIEAEAEADCCMEEEAIAAAYDCAMEEAEAEADCCMEEEAIAAAYDB8MED4HAEADB+MEHD4IAAAYDAAMCAAAAEADAAMEAAAIAI1KIpDOlz4qAAAAAElFTkSuQmCC")

;reconnect
bitmaps["loading"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAAA1BMVEUiV6ixRE8dAAAAE0lEQVR42mMYBaNgFIyCUUBXAAAFeAABSanTpAAAAABJRU5ErkJggg==")
bitmaps["science"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKAQMAAAC3/F3+AAAAA1BMVEX0qQ0Uw53LAAAACklEQVR42mPACwAAHgAB3XenRQAAAABJRU5ErkJggg==")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SYSTEM TRAY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["aurynico"])
Menu, Tray, Icon, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["aurynico"])
Menu, Tray, NoStandard
Menu, Tray, Add
Menu, Tray, Add, Open Logs, TrayMenuOpen
TrayMenuOpen() {
	ListLines
}
Menu, Tray, Add
Menu, Tray, Add, Edit This Script, TrayMenuEdit
TrayMenuEdit() {
	Edit
}
Menu, Tray, Add, Suspend Hotkeys, TrayMenuSuspend
TrayMenuSuspend() {
	Menu, Tray, ToggleCheck, Suspend Hotkeys
	Suspend
}
Menu, Tray, Add
Menu, Tray, Add, Start Macro, start
Menu, Tray, Add, Pause Macro, pause
Menu, Tray, Add, Stop Macro, stop
Menu, Tray, Add
Menu, Tray, Add, Show Timers, timers
Menu, Tray, Add

Menu, Tray, Default, Start Macro
Menu, Tray, Click, 1

PostMessage, 0x5555, 12, 0, , ahk_pid %lp_PID%
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
SkinForm(Apply, A_ScriptDir . "\nm_image_assets\Styles\USkin.dll", A_ScriptDir . "\nm_image_assets\styles\" . GuiTheme . ".msstyles")
OnExit("GetOut")
if (AlwaysOnTop)
	gui +AlwaysOnTop
gui +border +hwndhGUI +OwnDialogs
Gui, Font, s8 cDefault Norm, Tahoma
CurrentField:=FieldName%CurrentFieldNum%
Gui, Font, w700
Gui, Add, Text, x5 y241 w80 +left -Wrap +BackgroundTrans,Current Field:
Gui, Add, Text, x177 y241 w30 +left +BackgroundTrans,Status:
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Button, x82 y240 w10 h15 gnm_currentFieldUp, <
Gui, Add, Button, x165 y240 w10 h15 gnm_currentFieldDown, >
Gui, Add, Text, x92 y240 w73 +center +BackgroundTrans +border vCurrentField,%CurrentField%
Gui, Add, Text, x220 y240 w275 +left +BackgroundTrans vstate hwndhwndstate +border, %state%
Gui, Add, Text, x435 y263 gnm_showAdvancedSettings vVersionText, v%versionID%
GuiControlGet, pos, Pos, VersionText
; get latest release tag from GitHub
try
{
	wr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	wr.Open("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/releases/latest", 1)
	wr.SetRequestHeader("accept", "application/vnd.github+json")
	wr.Send()
	wr.WaitForResponse()
	if !RegExMatch(wr.ResponseText, "i)""tag_name"":\s?""v?(.+?)""", LatestVer)
		throw
}
catch
	LatestVer1 := 0
; shift elements to left if macro version is not latest
if (VerCompare(VersionID, LatestVer1) < 0)
{
	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["updategui"])
	Gui, Add, Picture, % "+BackgroundTrans x484 y263 w14 h14 gGitHubReleaseLink vImageUpdateLink", HBITMAP:*%hBM%
	DllCall("DeleteObject", "ptr", hBM)
	Gdip_DisposeImage(bitmaps["updategui"])
	posW += 15
}
GuiControl, Move, VersionText, % "x" 495-posW
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["githubgui"])
Gui, Add, Picture, % "+BackgroundTrans x" 495-posW-20 " y262 w16 h16 gGitHubRepoLink vImageGitHubLink", HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["githubgui"])
Gui, Font, s8 w700 c0046ee
w := 255-posW-12
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["discordgui"])
Gui, Add, Picture, % "+BackgroundTrans x" 215 " y262 w21 h16 gDiscordLink vImageDiscordLink", HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["discordgui"])
Gui, Add, Text, % "x" 215+27 " y256 +Center gDiscordLink vTextDiscordLink", Join`nDiscord
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["robloxgui"])
Gui, Add, Picture, % "+BackgroundTrans x" 205+w//3+w//8.4 " y262 w16 h16 gRobloxLink vImageRobloxLink", HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["robloxgui"])
Gui, Add, Text, % "x" 205+w//3+w//8.4+22 " y256 +Center gRobloxLink vTextRobloxLink", Join`nGroup
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["paypalgui"])
Gui, Add, Picture, % "+BackgroundTrans x" 195+2*w//3+w//5.4 " y262 w14 h16 gDonateLink vImageDonateLink", HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["paypalgui"])
Gui, Add, Text, % "x" 195+2*w//3+w//5.4+20 " y263 gDonateLink vTextDonateLink", Donate
Gui, Font, s8 cDefault Norm, Tahoma
;control buttons
Gui, Add, Button, x5 y260 w65 h20 -Wrap vStartButton gstart, % " Start (" StartHotkey ")"
Gui, Add, Button, x75 y260 w65 h20 -Wrap vPauseButton gpause, % " Pause (" PauseHotkey ")"
Gui, Add, Button, x145 y260 w65 h20 -Wrap vStopButton gstop, % " Stop (" StopHotkey ")"

PostMessage, 0x5555, 15, 0, , ahk_pid %lp_PID%
;ADD TABS
Gui, Add, Tab, x0 y-1 w502 h240 -Wrap hwndhTab vTab gnm_TabSelect, Gather|Collect/Kill|Boost|Quest|Planters|Status|Settings|Misc|Contributors
SendMessage, 0x1331, 0, 20, , ahk_id %hTab% ; set minimum tab width
Gui, Font, w700 Underline
Gui, Add, Text, x0 y25 w117 +center +BackgroundTrans,Gathering
Gui, Add, Text, x117 y25 w212 +center +BackgroundTrans,Pattern
Gui, Add, Text, x323 y25 w87 +center +BackgroundTrans,Until
Gui, Add, Text, x410 y25 w90 +center +BackgroundTrans,Sprinkler
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x2 y39 w115 +center +BackgroundTrans,Field Rotation
Gui, Add, Text, x117 y25 w1 h206 0x7 ; 0x7 = SS_BLACKFRAME - faster drawing of lines since no text rendered
Gui, Add, Text, x122 y39 w112 +center +BackgroundTrans,Pattern Shape
Gui, Add, Text, x243 y39 w100 +left +BackgroundTrans,Length
Gui, Add, Text, x288 y39 w100 +left +BackgroundTrans,Width
Gui, Add, Text, x323 y25 w1 h206 0x7
Gui, Add, Text, x335 y39 w100 +left +BackgroundTrans,Mins
Gui, Add, Text, x370 y39 w100 +left +BackgroundTrans,Pack`%
Gui, Add, Text, x410 y25 w1 h206 0x7
Gui, Add, Text, x420 y39 w100 +left +BackgroundTrans,Start Location
Gui, Add, Text, x5 y53 w492 h2 0x7
Gui, Add, Text, xp y115 wp h1 0x7
Gui, Add, Text, xp yp+60 wp h1 0x7
Gui, Add, Text, xp yp+60 wp h1 0x7
Gui, Font, w700
Gui, Add, Text, x4 y61 w10 +left +BackgroundTrans,1:
Gui, Add, Text, xp yp+60 wp +left +BackgroundTrans,2:
Gui, Add, Text, xp yp+60 wp +left +BackgroundTrans,3:
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, DropDownList, x18 y57 w96 vFieldName1 gnm_FieldSelect1 Disabled, % LTrim(StrReplace("|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName1 "|", "|" FieldName1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldName2 gnm_FieldSelect2 Disabled, % LTrim(StrReplace("|None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName2 "|", "|" FieldName2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldName3 gnm_FieldSelect3 Disabled, % LTrim(StrReplace("|None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName3 "|", "|" FieldName3 "||"), "|")
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
Gui, Add, Picture, x5 y86 w18 h18 gnm_SaveFieldDefault hwndhSaveFieldDefault1, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps[(FieldName2 = "None") ? "savefielddisabled" : "savefield"])
Gui, Add, Picture, xp yp+60 wp hp gnm_SaveFieldDefault hwndhSaveFieldDefault2, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps[(FieldName3 = "None") ? "savefielddisabled" : "savefield"])
Gui, Add, Picture, xp yp+60 wp hp gnm_SaveFieldDefault hwndhSaveFieldDefault3, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gui, Add, Checkbox, x28 y83 w86 +BackgroundTrans +Center vFieldDriftCheck1 gnm_SaveGather Checked%FieldDriftCheck1% Disabled,Field Drift`nCompensation
Gui, Add, Checkbox, xp yp+60 wp +BackgroundTrans +Center vFieldDriftCheck2 gnm_SaveGather Checked%FieldDriftCheck2% Disabled,Field Drift`nCompensation
Gui, Add, Checkbox, xp yp+60 wp +BackgroundTrans +Center vFieldDriftCheck3 gnm_SaveGather Checked%FieldDriftCheck3% Disabled,Field Drift`nCompensation
Gui, Add, DropDownList, x121 y57 w112 vFieldPattern1 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern1 "|", "|" FieldPattern1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPattern2 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern2 "|", "|" FieldPattern2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPattern3 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern3 "|", "|" FieldPattern3 "||"), "|")
Gui, Add, DropDownList, x236 y57 w46 vFieldPatternSize1 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize1 "|", "|" FieldPatternSize1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPatternSize2 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize2 "|", "|" FieldPatternSize2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPatternSize3 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize3 "|", "|" FieldPatternSize3 "||"), "|")
Gui, Add, DropDownList, x284 y57 w36 vFieldPatternReps1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps1 "|", "|" FieldPatternReps1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPatternReps2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps2 "|", "|" FieldPatternReps2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldPatternReps3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps3 "|", "|" FieldPatternReps3 "||"), "|")
Gui, Add, Checkbox, x121 y82 +BackgroundTrans vFieldPatternShift1 gnm_SaveGather Checked%FieldPatternShift1% Disabled, Gather w/Shift-Lock
Gui, Add, Checkbox, xp yp+60 +BackgroundTrans vFieldPatternShift2 gnm_SaveGather Checked%FieldPatternShift2% Disabled, Gather w/Shift-Lock
Gui, Add, Checkbox, xp yp+60 +BackgroundTrans vFieldPatternShift3 gnm_SaveGather Checked%FieldPatternShift3% Disabled, Gather w/Shift-Lock
Gui, Add, Text, x123 y97, Invert:
Gui, Add, Text, xp yp+60, Invert:
Gui, Add, Text, xp yp+60, Invert:
Gui, Add, Checkbox, x160 y97 vFieldPatternInvertFB1 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB1% Disabled, F/B
Gui, Add, Checkbox, xp yp+60 vFieldPatternInvertFB2 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB2% Disabled, F/B
Gui, Add, Checkbox, xp yp+60 vFieldPatternInvertFB3 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB3% Disabled, F/B
Gui, Add, Checkbox, x198 y97 vFieldPatternInvertLR1 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR1% Disabled, L/R
Gui, Add, Checkbox, xp yp+60 vFieldPatternInvertLR2 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR2% Disabled, L/R
Gui, Add, Checkbox, xp yp+60 vFieldPatternInvertLR3 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR3% Disabled, L/R
Gui, Add, Text, x240 y78 +BackgroundTrans +Center, Rotate Camera:
Gui, Add, Text, xp yp+60 +BackgroundTrans +Center, Rotate Camera:
Gui, Add, Text, xp yp+60 +BackgroundTrans +Center, Rotate Camera:
Gui, Add, DropDownList, x236 y92 w50 vFieldRotateDirection1 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection1 "|", "|" FieldRotateDirection1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldRotateDirection2 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection2 "|", "|" FieldRotateDirection2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldRotateDirection3 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection3 "|", "|" FieldRotateDirection3 "||"), "|")
Gui, Add, DropDownList, x288 y92 w32 vFieldRotateTimes1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes1 "|", "|" FieldRotateTimes1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldRotateTimes2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes2 "|", "|" FieldRotateTimes2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldRotateTimes3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes3 "|", "|" FieldRotateTimes3 "||"), "|")
Gui, Add, Edit, x327 y58 w36 h19 limit4 number vFieldUntilMins1 gnm_SaveGather Disabled, %FieldUntilMins1%
Gui, Add, Edit, xp yp+60 wp h19 limit4 number vFieldUntilMins2 gnm_SaveGather Disabled, %FieldUntilMins2%
Gui, Add, Edit, xp yp+60 wp h19 limit4 number vFieldUntilMins3 gnm_SaveGather Disabled, %FieldUntilMins3%
Gui, Add, DropDownList, x365 y57 w42 vFieldUntilPack1 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack1 "|", "|" FieldUntilPack1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 w45 vFieldUntilPack2 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack2 "|", "|" FieldUntilPack2 "||"), "|")
Gui, Add, DropDownList, xp yP+60 w45 vFieldUntilPack3 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack3 "|", "|" FieldUntilPack3 "||"), "|")
Gui, Add, Text, x322 y78 w93 +BackgroundTrans +Center, To Hive By:
Gui, Add, Text, xp yp+60 wp +BackgroundTrans +Center, To Hive By:
Gui, Add, Text, xp yp+60 wp +BackgroundTrans +Center, To Hive By:
Gui, Add, DropDownList, x339 y92 w58 vFieldReturnType1 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|", "|" FieldReturnType1 "|", "|" FieldReturnType1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldReturnType2 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|", "|" FieldReturnType2 "|", "|" FieldReturnType2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldReturnType3 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|", "|" FieldReturnType3 "|", "|" FieldReturnType3 "||"), "|")
Gui, Add, DropDownList, x414 y57 w82 vFieldSprinklerLoc1 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc1 "|", "|" FieldSprinklerLoc1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldSprinklerLoc2 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc2 "|", "|" FieldSprinklerLoc2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldSprinklerLoc3 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc3 "|", "|" FieldSprinklerLoc3 "||"), "|")
Gui, Add, Text, x412 y79 w86 +BackgroundTrans +Center, Distance:
Gui, Add, Text, xp yp+60 wp +BackgroundTrans +Center, Distance:
Gui, Add, Text, xp yp+60 wp +BackgroundTrans +Center, Distance:
Gui, Add, DropDownList, x433 y93 w40 vFieldSprinklerDist1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist1 "|", "|" FieldSprinklerDist1 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldSprinklerDist2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist2 "|", "|" FieldSprinklerDist2 "||"), "|")
Gui, Add, DropDownList, xp yp+60 wp vFieldSprinklerDist3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist3 "|", "|" FieldSprinklerDist3 "||"), "|")
PostMessage, 0x5555, 25, 0, , ahk_pid %lp_PID%

;Contributors TAB
;------------------------
Gui, Tab, Contributors
;GuiControl,focus, Tab
page_end := nm_ContributorsImage()
Gui, Font, w700
Gui, Add, Text, x15 y28 w225 +wrap +backgroundtrans cWhite, Development
Gui, Add, Text, x261 y28 w225 +wrap +backgroundtrans cWhite, Contributors
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x18 y43 w225 +wrap +backgroundtrans cWhite, Special Thanks to the developers and testers!
Gui, Add, Text, x264 y43 w180 +wrap +backgroundtrans cWhite, Thank you for your donations and contributions to this project!
Gui, Add, Button, x440 y46 w18 h18 hwndhcleft gnm_ContributorsPageButton Disabled, <
Gui, Add, Button, % "x464 y46 w18 h18 hwndhcright gnm_ContributorsPageButton Disabled" page_end, >
PostMessage, 0x5555, 28, 0, , ahk_pid %lp_PID%

;MISC TAB
;------------------------
Gui, Tab, Misc
Gui, Font, w700
Gui, Add, GroupBox, x5 y24 w160 h144, Hive Tools
Gui, Add, GroupBox, x5 y168 w160 h62, Other Tools
Gui, Add, GroupBox, x170 y24 w160 h144, Calculators
Gui, Add, GroupBox, x335 y24 w160 h84, Macro Tools
Gui, Add, GroupBox, x335 y108 w160 h60, Discord Tools
Gui, Add, GroupBox, x335 y168 w160 h62, Reporting
Gui, Font, s9 cDefault Norm, Tahoma
;hive tools
Gui, Add, Button, x10 y40 w150 h40 gnm_BasicEggHatcher, Gifted Basic Bee`nAuto-Hatcher
Gui, Add, Button, x10 y82 w150 h40 gnm_BitterberryFeeder, Bitterberry`nAuto-Feeder
Gui, Add, Button, x10 y124 w150 h40 Disabled, Auto-Mutator`n(coming soon!)
;other tools
Gui, Add, Button, x10 y184 w150 h42 gnm_GenerateBeeList, Export Hive Bee List`n(for Hive Builder)
;calculators
Gui, Add, Button, x175 y40 w150 h40 gnm_TicketShopCalculatorButton, Ticket Shop Calculator`n(Google Sheets)
Gui, Add, Button, x175 y82 w150 h40 gnm_SSACalculatorButton, SSA Calculator`n(Google Sheets)
Gui, Add, Button, x175 y124 w150 h40 gnm_BondCalculatorButton, Bond Calculator`n(Google Sheets)
;macro tools
Gui, Add, Button, x340 y40 w150 h20 gnm_HotkeyGUI, Change Hotkeys
Gui, Add, Button, x340 y62 w150 h20 gnm_DebugLogGUI, Debug Log Options
Gui, Add, Button, x340 y84 w150 h20 gnm_testReconnect, Test Reconnect
;discord tools
Gui, Add, Button, x340 y124 w150 h40 gnm_NightAnnouncementGUI, Night Detection`nAnnouncement
;reporting
Gui, Add, Button, x340 y184 w150 h20 gnm_ReportBugButton, Report Bugs
Gui, Add, Button, x340 y206 w150 h20 gnm_MakeSuggestionButton, Make Suggestions
Gui, Font, s8 cDefault Norm, Tahoma

;STATUS TAB
;------------------------
Gui, Tab, Status
;GuiControl,focus, Tab
Gui, Font, w700
Gui, Add, GroupBox, x5 y23 w240 h210, Status Log
Gui, Add, GroupBox, x250 y23 w245 h160, Stats
Gui, Add, GroupBox, x250 y185 w245 h48, Discord Integration
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x85 y23 vStatusLogReverse gnm_StatusLogReverseCheck Checked%StatusLogReverse%, Reverse Order
Gui, Add, Text, x10 y37 w230 r15 +BackgroundTrans -Wrap vstatuslog, Status Log:
Gui, font, w700
Gui, Add, Text, x255 y40, Total
Gui, Add, Text, x375 y40, Session
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x255 y55 w119 h120 -Wrap vTotalStats
Gui, Add, Text, x375 y55 w119 h120 -Wrap vSessionStats
Gui, Add, Button, x290 y39 w50 h15 vResetTotalStats gnm_ResetTotalStats, Reset
Gui, Add, Button, x265 y202 w215 h24 gnm_WebhookGUI, Change Discord Settings
nm_setStats()
PostMessage, 0x5555, 35, 0, , ahk_pid %lp_PID%

;SETTINGS TAB
;------------------------
Gui, Tab, Settings
;gui settings
Gui, Add, GroupBox, x5 y25 w160 h65, GUI SETTINGS
Gui, Add, Checkbox, x10 y73 vAlwaysOnTop gnm_AlwaysOnTop Checked%AlwaysOnTop%, Always On Top
Gui, Add, Text, x10 y40 w70 +left +BackgroundTrans,GUI Theme:
nm_importStyles()
Gui, Add, DropDownList, x85 y34 w72 h100 vGuiTheme gnm_guiThemeSelect Disabled, % LTrim(StrReplace(StylesList, "|" GuiTheme "|", "|" GuiTheme "||"), "|")
Gui, Add, Text, x10 y57 w100 +left +BackgroundTrans,GUI Transparency:
Gui, Add, DropDownList, x105 y55 w52 h100 vGuiTransparency gnm_guiTransparencySet Disabled, % LTrim(StrReplace("|0|5|10|15|20|25|30|35|40|45|50|55|60|65|70|", "|" GuiTransparency "|", "|" GuiTransparency "||"), "|")

;hive settings
Gui, Add, GroupBox, x5 y95 w160 h65, HIVE SETTINGS
Gui, Add, Text, x10 y110 w60 +left +BackgroundTrans,Hive Slot:
Gui, Font, s6
Gui, Add, Text, x61 y112 w60 +left +BackgroundTrans,(6-5-4-3-2-1)
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, DropDownList, x110 y105 w30 vHiveSlot gnm_saveConfig Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|", "|" HiveSlot "|", "|" HiveSlot "||"), "|")
Gui, Add, Text, x10 y125 w110 +left +BackgroundTrans,My Hive Has:
Gui, Add, Edit, x75 y124 w18 h16 Limit2 number +BackgroundTrans vHiveBees gnm_HiveBees Disabled, %HiveBees%
Gui, Add, Text, x98 y125 w110 +left +BackgroundTrans,Bees
Gui, Add, Button, x150 y124 w10 h15 gnm_HiveBeesHelp, ?
Gui, Add, Text, x9 y142 w110 +left +BackgroundTrans,Wait
Gui, Add, Edit, x33 y141 w18 h16 Limit2 number +BackgroundTrans vConvertDelay gnm_saveConfig Disabled, %ConvertDelay%
Gui, Add, Text, x54 y142 w110 +left +BackgroundTrans,seconds after convert

;reset settings
Gui, Add, GroupBox, x5 y165 w160 h70, RESET SETTINGS
Gui, Add, Button, x20 y183 w130 h22 gnm_ResetFieldDefaultGUI, Reset Field Defaults
Gui, Add, Button, x20 y207 w130 h22 gnm_ResetConfig, Reset All Settings

;input settings
Gui, Add, GroupBox, x170 y25 w160 h93, INPUT SETTINGS
Gui, Add, Text, x180 y40 w100 +left +BackgroundTrans,Add Key Delay (ms):
Gui, Add, Edit, x280 y38 w47 h18 limit4 number vKeyDelayEdit gnm_saveKeyDelay
Gui, Add, UpDown, Range0-9999 vKeyDelay gnm_saveKeyDelay Disabled, % KeyDelay
Gui, Font, Underline
Gui, Add, Text, x182 y58 w85 -Wrap c0x0046ee vAutoClickerButton, AutoClicker (%AutoClickerHotkey%)
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x267 y59 +BackgroundTrans vClickMode gnm_saveAutoClicker Checked%ClickMode%, Infinite
Gui, Add, Text, x182 y77, Repeat
Gui, Add, Edit, % "x221 y75 w64 h18 vClickCountEdit +BackgroundTrans gnm_saveAutoClicker Number Disabled" ClickMode
Gui, Add, UpDown, % "vClickCount gnm_saveAutoClicker Range0-99999 Disabled" ClickMode, %ClickCount%
Gui, Add, Text, x290 y77, times
Gui, Add, Text, x182 y96, Click Interval (ms):
Gui, Add, Edit, x277 y94 w40 h18 +BackgroundTrans Number vClickDelay gnm_saveAutoClicker, %ClickDelay%

;reconnect settings
Gui, Add, GroupBox, x170 y123 w160 h112, RECONNECT SETTINGS
Gui, Add, Text, x180 y140 w80 +Left +BackgroundTrans,Server Link:
Gui, Add, Edit, x240 y139 w82 h16 +BackgroundTrans vPrivServer gnm_ServerLink Disabled, %PrivServer%
Gui, Add, Text, x180 y159 +BackgroundTrans, Reconnect every
Gui, Add, Edit, x265 y158 w18 h16 Number Limit2 vReconnectInterval gnm_setReconnectInterval, %ReconnectInterval%
Gui, Add, Text, x287 y159 +BackgroundTrans, hours
Gui, Add, Text, x196 y177 +BackgroundTrans, starting at
Gui, Add, Edit, x250 y176 w18 h16 Number Limit2 vReconnectHour gnm_setReconnectHour, %ReconnectHour%
Gui, font, w1000 s11
Gui, Add, Text, x269 y173 +BackgroundTrans, :
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Edit, x275 y176 w18 h16 Number Limit2 vReconnectMin gnm_setReconnectMin, %ReconnectMin%
Gui, font, s6 w700
Gui, Add, Text, x295 y179 +BackgroundTrans, UTC
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Button, x315 y176 w10 h15 gnm_ReconnectTimeHelp, ?
Gui, Add, CheckBox, x180 y195 w88 h15 vReconnectMessage gnm_saveConfig +BackgroundTrans Checked%ReconnectMessage%, Natro so broke
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["weary"])
Gui, Add, Picture, +BackgroundTrans x269 y193 w20 h20, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["weary"])
Gui, Add, Button, x315 y194 w10 h15 gnm_NatroSoBrokeHelp, ?
Gui, Add, CheckBox, x180 y212 w132 h15 vPublicFallback gnm_saveConfig +BackgroundTrans Checked%PublicFallback%, Fallback to Public Server
Gui, Add, Button, x315 y212 w10 h15 gnm_PublicFallbackHelp, ?

;character settings
Gui, Add, GroupBox, x335 y25 w160 h210, CHARACTER SETTINGS
Gui, Add, Text, x345 y40 w110 +left +BackgroundTrans,Movement Speed:
Gui, Font, s6
Gui, Add, Text, x345 y55 w80 +right +BackgroundTrans,(WITHOUT HASTE)
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Edit, x438 y43 w43 r1 limit5 vMoveSpeedNum gnm_moveSpeed Disabled, %MoveSpeedNum%
Gui, Add, CheckBox, x345 y68 w125 h15 vNewWalk gnm_saveConfig +BackgroundTrans Checked%NewWalk%, MoveSpeed Correction
Gui, Add, Button, x475 y68 w10 h15 gnm_NewWalkHelp, ?
Gui, Add, Text, x345 y90 w110 +left +BackgroundTrans,Move Method:
Gui, Add, DropDownList, x416 y87 w68 vMoveMethod gnm_saveConfig Disabled, % LTrim(StrReplace("|Walk|Cannon|", "|" MoveMethod "|", "|" MoveMethod "||"), "|")
Gui, Add, Text, x345 y111 w110 +left +BackgroundTrans,Sprinkler Type:
Gui, Add, DropDownList, x419 y108 w65 vSprinklerType gnm_saveConfig Disabled, % LTrim(StrReplace("|None|Basic|Silver|Golden|Diamond|Supreme|", "|" SprinklerType "|", "|" SprinklerType "||"), "|")
Gui, Add, Text, x345 y132 w110 +left +BackgroundTrans,Convert Balloon:
Gui, Add, Text, x370 y147 w110 +left +BackgroundTrans,\____\___
Gui, Add, DropDownList, x427 y129 w57 vConvertBalloon gnm_convertBalloon Disabled, % LTrim(StrReplace("|Always|Never|Every|", "|" ConvertBalloon "|", "|" ConvertBalloon "||"), "|")
Gui, Add, Edit, % "x422 y150 w30 h18 number Limit3 +BackgroundTrans vConvertMins gnm_saveConfig" ((ConvertBalloon = "Every") ? "" : " Disabled") , %ConvertMins%
Gui, Add, Text, x456 y152, Mins
Gui, Add, Text, x345 y170 w110 +left +BackgroundTrans,Multiple Reset:
Gui, Add, Slider, x415 y168 w78 h16 vMultiReset gnm_saveConfig Thick16 Disabled ToolTipTop Range0-3 Page1 TickInterval1, %MultiReset%
Gui, Add, CheckBox, x345 y186 vGatherDoubleReset gnm_saveConfig +BackgroundTrans Checked%GatherDoubleReset%, Gather Double Reset
Gui, Add, CheckBox, x345 y201 vDisableToolUse gnm_saveConfig +BackgroundTrans Checked%DisableToolUse%, Disable Tool Use
Gui, Add, CheckBox, x345 y216 vAnnounceGuidingStar gnm_saveConfig +BackgroundTrans Checked%AnnounceGuidingStar%, Announce Guiding Star

PostMessage, 0x5555, 45, 0, , ahk_pid %lp_PID%

;COLLECT/Kill TAB
;------------------------
Gui, Tab, Collect/Kill
;sub-tabs
Gui, Add, Button, x4 y21 w246 h18 hwndhcollect gnm_CollectKillButton Disabled, Collect
Gui, Add, Button, x250 y21 w246 h18 hwndhkill gnm_CollectKillButton, Kill
;collect
Gui, Font, w700
Gui, Add, GroupBox, x10 y42 w115 h109 vCollectGroupBox, Collect
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x15 y57 +BackgroundTrans vClockCheck gnm_saveCollect Checked%ClockCheck% Disabled, Clock (tickets)
Gui, Add, Checkbox, x15 y76 +BackgroundTrans vMondoBuffCheck gnm_saveCollect Checked%MondoBuffCheck% Disabled, Mondo
Gui, Add, DropDownList, x77 y72 w45 vMondoAction hwndhDDLMondo gnm_saveCollect Disabled, % LTrim(StrReplace(mondoactionlist := ("|Buff|Kill" (PMondoGuid ? "|Tag|Guid" : "") "|"), "|" MondoAction "|", "|" MondoAction "||"), "|")
PostMessage, 0x153, -1, 14,, ahk_id %hDDLMondo%
Gui, Add, Checkbox, x15 y95 w35 +BackgroundTrans vAntPassCheck gnm_saveCollect Checked%AntPassCheck% Disabled, Ant
Gui, Add, DropDownList, x52 y92 w70 vAntPassAction hwndhDDLAntPass gnm_saveCollect Disabled, % LTrim(StrReplace("|Pass|Challenge|", "|" AntPassAction "|", "|" AntPassAction "||"), "|")
PostMessage, 0x153, -1, 14,, ahk_id %hDDLAntPass%
Gui, Add, Checkbox, x15 y114 +BackgroundTrans vRoboPassCheck gnm_saveCollect Checked%RoboPassCheck% Disabled, Robo Pass
Gui, Add, Checkbox, x15 y133 +BackgroundTrans vHoneystormCheck gnm_saveCollect Checked%HoneystormCheck% Disabled, Honeystorm
;dispensers
Gui, Font, w700
Gui, Add, GroupBox, x130 y42 w170 h109 vDispensersGroupBox, Dispensers
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x135 y57 +BackgroundTrans vHoneyDisCheck gnm_saveCollect Checked%HoneyDisCheck% Disabled, Honey
Gui, Add, Checkbox, x135 yp+19 +BackgroundTrans vTreatDisCheck gnm_saveCollect Checked%TreatDisCheck% Disabled, Treat
Gui, Add, Checkbox, x135 yp+19 +BackgroundTrans vBlueberryDisCheck gnm_saveCollect Checked%BlueberryDisCheck% Disabled, Blueberry
Gui, Add, Checkbox, x135 yp+19 +BackgroundTrans vStrawberryDisCheck gnm_saveCollect Checked%StrawberryDisCheck% Disabled, Strawberry
Gui, Add, Checkbox, x135 yp+19 +BackgroundTrans vCoconutDisCheck gnm_saveCollect Checked%CoconutDisCheck% Disabled, Coconut
Gui, Add, Checkbox, x225 y57 +BackgroundTrans vRoyalJellyDisCheck gnm_saveCollect Checked%RoyalJellyDisCheck% Disabled, Royal Jelly
Gui, Add, Checkbox, x225 yp+19 +BackgroundTrans vGlueDisCheck gnm_saveCollect Checked%GlueDisCheck% Disabled, Glue
;beesmas
beesmasActive:=0
if (beesmasActive = 0)
	BeesmasGatherInterruptCheck := StockingsCheck := WreathCheck := FeastCheck := RBPDeLevelChck := GingerbreadCheck := SnowMachineCheck := CandlesCheck := SamovarCheck := LidArtCheck := GummyBeaconCheck := 0

Gui, Font, w700
Gui, Add, GroupBox, x10 y153 w290 h84 vBeesmasGroupBox, % "Beesmas" (beesmasActive ? "" : " (Reserved)")
Gui, Font, s8 cDefault Norm, Tahoma
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["beesmas"]) 
Gui, Add, Picture, +BackgroundTrans x77 y150 w20 h20 vBeesmasImage, % (beesmasActive ? "HBITMAP:*" . hBM : "")
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["beesmas"])
Gui, Add, Checkbox, % "x142 y154 +BackgroundTrans vBeesmasGatherInterruptCheck gnm_saveCollect Checked" (BeesmasGatherInterruptCheck && beesmasActive) " Disabled" !beesmasActive, Allow Gather Interrupt
Gui, Add, Checkbox, % "x15 y170 w62 +BackgroundTrans vStockingsCheck gnm_saveCollect Checked" (StockingsCheck && beesmasActive) " Disabled" !beesmasActive, Stockings
Gui, Add, Checkbox, % "x15 yp+17 +BackgroundTrans vWreathCheck gnm_saveCollect Checked" (WreathCheck && beesmasActive) " Disabled" !beesmasActive, Honey Wreath
Gui, Add, Checkbox, % "x15 yp+17 +BackgroundTrans vFeastCheck gnm_saveCollect Checked" (FeastCheck && beesmasActive) " Disabled" !beesmasActive, Feast
Gui, Add, Checkbox, % "x15 yp+17 +BackgroundTrans vRBPDelevelCheck gnm_saveCollect Checked" (RBPDelevelCheck && beesmasActive) " Disabled" !beesmasActive, Robo Party De-level
Gui, Add, Checkbox, % "x108 y170 +BackgroundTrans vGingerbreadCheck gnm_saveCollect Checked" (GingerbreadCheck && beesmasActive) " Disabled" !beesmasActive, Gingerbread
Gui, Add, Checkbox, % "x108 yp+17 +BackgroundTrans vSnowMachineCheck gnm_saveCollect Checked" (SnowMachineCheck && beesmasActive) " Disabled" !beesmasActive, Snow Machine
Gui, Add, Checkbox, % "x108 yp+17 +BackgroundTrans vCandlesCheck gnm_saveCollect Checked" (CandlesCheck && beesmasActive) " Disabled" !beesmasActive, Candles
Gui, Add, Checkbox, % "x201 y170 +BackgroundTrans vSamovarCheck gnm_saveCollect Checked" (SamovarCheck && beesmasActive) " Disabled" !beesmasActive, Samovar
Gui, Add, Checkbox, % "x201 yp+17 +BackgroundTrans vLidArtCheck gnm_saveCollect Checked" (LidArtCheck && beesmasActive) " Disabled" !beesmasActive, Lid Art
Gui, Add, Checkbox, % "x201 yp+17 +BackgroundTrans vGummyBeaconCheck gnm_saveCollect Checked" (GummyBeaconCheck && beesmasActive) " Disabled" !beesmasActive, Gummy Beacon

;KILL
;bugrun
Gui, Font, w700
Gui, Add, GroupBox, x10 y42 w134 h188 vBugRunGroupBox Hidden, Bug Run
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x76 y43 vBugRunCheck gnm_BugRunCheck Checked%BugRunCheck% Hidden, Select All
Gui, Add, Text, x16 y62 +BackgroundTrans Hidden vTextMonsterRespawnPercent, % "–       %"
Gui, Add, Text, x52 y55 w80 +BackgroundTrans +Center Hidden vTextMonsterRespawn, Monster Respawn Time
Gui, Add, Edit, x24 y61 w18 h16 Limit2 number +BackgroundTrans vMonsterRespawnTime gnm_MonsterRespawnTime Hidden, %MonsterRespawnTime%
Gui, Add, Button, x128 y63 w12 h14 gnm_MonsterRespawnTimeHelp vMonsterRespawnTimeHelp Hidden, ?
Gui, Add, Checkbox, x16 y82 w125 h15 +BackgroundTrans vBugrunInterruptCheck gnm_saveCollect Checked%BugrunInterruptCheck% Hidden, Allow Gather Interrupt
Gui, Add, text, x16 y100 +BackgroundTrans Hidden vTextLoot, Loot
Gui, Add, text, x49 y100 +BackgroundTrans Hidden vTextKill, Kill
Gui, Add, Text, x15 y114 w114 h1 0x7 Hidden vTextLineBugRun1
Gui, Add, Text, x40 y100 w1 h124 0x7 Hidden vTextLineBugRun2
Gui, Add, Checkbox, x20 y120 w13 h13 +BackgroundTrans vBugrunLadybugsLoot gnm_saveCollect Checked%BugrunLadybugsLoot% Disabled Hidden
Gui, Add, Checkbox, xp yp+18 w13 h13 +BackgroundTrans vBugrunRhinoBeetlesLoot gnm_saveCollect Checked%BugrunRhinoBeetlesLoot% Disabled Hidden
Gui, Add, Checkbox, xp yp+18 w13 h13 +BackgroundTrans vBugrunSpiderLoot gnm_saveCollect Checked%BugrunSpiderLoot% Disabled Hidden
Gui, Add, Checkbox, xp yp+18 w13 h13 +BackgroundTrans vBugrunMantisLoot gnm_saveCollect Checked%BugrunMantisLoot% Disabled Hidden
Gui, Add, Checkbox, xp yp+18 w13 h13 +BackgroundTrans vBugrunScorpionsLoot gnm_saveCollect Checked%BugrunScorpionsLoot% Disabled Hidden
Gui, Add, Checkbox, xp yp+18 w13 h13 +BackgroundTrans vBugrunWerewolfLoot gnm_saveCollect Checked%BugrunWerewolfLoot% Disabled Hidden
Gui, Add, Checkbox, x48 y120 +BackgroundTrans vBugrunLadybugsCheck gnm_saveCollect Checked%BugrunLadybugsCheck% Disabled Hidden, Ladybugs
Gui, Add, Checkbox, xp yp+18 +BackgroundTrans vBugrunRhinoBeetlesCheck gnm_saveCollect Checked%BugrunRhinoBeetlesCheck% Disabled Hidden, Rhino Beetles
Gui, Add, Checkbox, xp yp+18 +BackgroundTrans vBugrunSpiderCheck gnm_saveCollect Checked%BugrunSpiderCheck% Disabled Hidden, Spider
Gui, Add, Checkbox, xp yp+18 +BackgroundTrans vBugrunMantisCheck gnm_saveCollect Checked%BugrunMantisCheck% Disabled Hidden, Mantis
Gui, Add, Checkbox, xp yp+18 +BackgroundTrans vBugrunScorpionsCheck gnm_saveCollect Checked%BugrunScorpionsCheck% Disabled Hidden, Scorpions
Gui, Add, Checkbox, xp yp+18 +BackgroundTrans vBugrunWerewolfCheck gnm_saveCollect Checked%BugrunWerewolfCheck% Disabled Hidden, Werewolf
;stingers
Gui, Font, w700
Gui, Add, GroupBox, x149 y42 w341 h60 vStingersGroupBox Hidden, Stingers
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x217 y43 +BackgroundTrans vStingerCheck gnm_saveStingers Checked%StingerCheck% Disabled Hidden, Kill Vicious Bee
Gui, Add, Checkbox, % "x315 y43 vStingerDailyBonusCheck gnm_saveStingers Checked" StingerDailyBonusCheck " Hidden Disabled" !StingerCheck, Only Daily Bonus
Gui, Add, Text, x168 y69 +BackgroundTrans Hidden vTextFields, Fields:
Gui, Add, Checkbox, % "x220 y62 vStingerCloverCheck gnm_saveStingers Checked" StingerCloverCheck " Hidden Disabled" !StingerCheck, Clover
Gui, Add, Checkbox, % "x220 y80 vStingerSpiderCheck gnm_saveStingers Checked" StingerSpiderCheck " Hidden Disabled" !StingerCheck, Spider
Gui, Add, Checkbox, % "x305 y62 vStingerCactusCheck gnm_saveStingers Checked" StingerCactusCheck " Hidden Disabled" !StingerCheck, Cactus
Gui, Add, Checkbox, % "x305 y80 vStingerRoseCheck gnm_saveStingers Checked" StingerRoseCheck " Hidden Disabled" !StingerCheck, Rose
Gui, Add, Checkbox, % "x390 y62 vStingerMountainTopCheck gnm_saveStingers Checked" StingerMountainTopCheck " Hidden Disabled" !StingerCheck, Mountain Top
Gui, Add, Checkbox, % "x390 y80 vStingerPepperCheck gnm_saveStingers Checked" StingerPepperCheck " Hidden Disabled" !StingerCheck, Pepper
;bosses
Gui, Font, w700
Gui, Add, GroupBox, x149 y104 w341 h126 vBossesGroupBox Hidden, Bosses
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Button, x209 y104 w12 h14 gnm_BossConfigHelp vBossConfigHelp Hidden, ?
Gui, Add, Checkbox, x152 y123 +BackgroundTrans vKingBeetleCheck gnm_saveCollect Checked%KingBeetleCheck% Disabled Hidden, King Beetle
Gui, Add, Checkbox, xp yp+21 +BackgroundTrans vTunnelBearCheck gnm_saveCollect Checked%TunnelBearCheck% Disabled Hidden, Tunnel Bear
Gui, Add, Checkbox, xp yp+21 +BackgroundTrans vCocoCrabCheck gnm_CocoCrabCheck Checked%CocoCrabCheck% Disabled Hidden, Coco Crab
Gui, Add, Checkbox, xp yp+21 +BackgroundTrans vStumpSnailCheck gnm_saveCollect Checked%StumpSnailCheck% Disabled Hidden, Stump Snail
Gui, Add, Checkbox, xp yp+21 +BackgroundTrans vCommandoCheck gnm_saveCollect Checked%CommandoCheck% Disabled Hidden, Commando
Gui, Add, Checkbox, x270 y123 w13 h13 +BackgroundTrans vTunnelBearBabyCheck gnm_saveCollect Checked%TunnelBearBabyCheck% Disabled Hidden
Gui, Add, Checkbox, xp yp+21 w13 h13 +BackgroundTrans vKingBeetleBabyCheck gnm_saveCollect Checked%KingBeetleBabyCheck% Disabled Hidden
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["babylovegui"])
Gui, Add, Picture, +BackgroundTrans vBabyLovePicture1 x286 y120 w18 h18 Hidden, HBITMAP:*%hBM%
Gui, Add, Picture, +BackgroundTrans vBabyLovePicture2 xp yp+21 w18 h18 Hidden, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["babylovegui"])
Gui, Add, Checkbox, x370 y123 w13 h13 +BackgroundTrans vKingBeetleAmuletMode gnm_saveAmulet Checked%KingBeetleAmuletMode% Disabled Hidden
Gui, Add, Checkbox, x229 y186 w13 h13 +BackgroundTrans vShellAmuletMode gnm_saveAmulet Checked%ShellAmuletMode% Disabled Hidden
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["kingbeetleamu"])
Gui, Add, Picture, +BackgroundTrans vKingBeetleAmuPicture x386 y119 w20 h20 Hidden, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["kingbeetleamu"])
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["supremeshellamu"])
Gui, Add, Picture, +BackgroundTrans vShellAmuPicture x245 y182 w20 h20 Hidden, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["supremeshellamu"])
Gui, Add, Text, x410 y123 w56 vKingBeetleAmuletModeText Hidden, % (KingBeetleAmuletMode = 1) ? " Keep Old" : "Do Nothing"
Gui, Add, Text, x269 y186 w56 vShellAmuletModeText Hidden, % (ShellAmuletMode = 1) ? " Keep Old" : "Do Nothing"
Gui, Add, Text, x246 y207 vChickLevelTextLabel Hidden, Level:
Gui, Add, Text, x276 y207 w30 vChickLevelText +Center Hidden, ?
Gui, Add, UpDown, w10 h16 vChickLevel gnm_setChickHealth Range3-25 Hidden, 10
GuiControl, , ChickLevelText, ? ; no point in storing this value, have it undefined on start
Gui, Add, Text, x325 y186 vSnailHPText Hidden, HP:
Gui, Add, Text, xp yp+21 vChickHPText Hidden, HP:
Gui, Add, Edit, x343 y184 w60 h18 +BackgroundTrans Number Limit8 gnm_setSnailHealth vSnailHealthEdit Hidden, % Round(30000000*InputSnailHealth/100)
Gui, Add, Edit, xp yp+21 w60 h18 +BackgroundTrans Number Limit8 gnm_setChickHealth vChickHealthEdit Hidden
Gui, Font, s7
Gui, Add, Text, % "x405 y188 w40 vSnailHealthText Hidden c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0), % InputSnailHealth "%"
Gui, Add, Text, % "xp yp+21 w40 vChickHealthText Hidden c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0), % InputChickHealth "%"
Gui, Font, s8
Gui, Add, Text, x448 y186 w22 vSnailTimeText +Center Hidden, % (SnailTime = "Kill") ? SnailTime : SnailTime "m"
Gui, Add, UpDown, xp+22 yp-1 w10 h16 -16 Range1-4 vSnailTimeUpDown gnm_SnailTime Hidden, % (SnailTime = "Kill") ? 4 : SnailTime//5
Gui, Add, Text, x448 y207 w22 vChickTimeText +Center Hidden, % (ChickTime = "Kill") ? ChickTime : ChickTime "m"
Gui, Add, UpDown, xp+22 yp-1 w10 h16 -16 Range1-4 vChickTimeUpDown gnm_ChickTime Hidden, % (ChickTime = "Kill") ? 4 : ChickTime//5


nm_saveCollect()
PostMessage, 0x5555, 55, 0, , ahk_pid %lp_PID%

;BOOST TAB
;------------------------
Gui, Tab, Boost
;GuiControl,focus, Tab
;boosters
Gui, Font, W700
Gui, Add, GroupBox, x5 y25 w120 h135, HQ Field Boosters
Gui, Add, GroupBox, x130 y25 w260 h155, Hotbar Slots
Gui, Font, s8 cDefault Norm, Tahoma
;field booster
Gui, Add, Text, x25 y40 w100 left +BackgroundTrans, Order
Gui, Add, Text, x95 y35 w100 left cGREEN +BackgroundTrans, (free)
Gui, Add, Text, x9 y54 w112 h1 0x7
Gui, Add, Text, x10 y62 w10 left +BackgroundTrans, 1:
Gui, Add, Text, x10 y82 w10 left +BackgroundTrans, 2:
Gui, Add, Text, x10 y102 w10 left +BackgroundTrans, 3:
Gui, Add, DropDownList, x20 y58 w55 vFieldBooster1 gnm_FieldBooster1 Disabled, % LTrim(StrReplace("|None|Blue|Red|Mountain|", "|" FieldBooster1 "|", "|" FieldBooster1 "||"), "|")
Gui, Add, DropDownList, x20 y78 w55 vFieldBooster2 gnm_FieldBooster2 Disabled, % LTrim(StrReplace("|None|Blue|Red|Mountain|", "|" FieldBooster2 "|", "|" FieldBooster2 "||"), "|")
Gui, Add, DropDownList, x20 y98 w55 vFieldBooster3 gnm_FieldBooster3 Disabled, % LTrim(StrReplace("|None|Blue|Red|Mountain|", "|" FieldBooster3 "|", "|" FieldBooster3 "||"), "|")
Gui, Add, Text, x77 y62 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x77 y82 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x77 y102 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x15 y120 w120 left +BackgroundTrans, Separate Each Boost
Gui, Add, Text, x35 y137 w100 left +BackgroundTrans,By:
Gui, Add, DropDownList, x55 y135 w37 vFieldBoosterMins gnm_saveBoost Disabled, % LTrim(StrReplace("|0|5|10|15|20|30|", "|" FieldBoosterMins "|", "|" FieldBoosterMins "||"), "|")
Gui, Add, Text, x95 y137 w100 left +BackgroundTrans, Mins
Gui, Add, CheckBox, x20 y165 +border +center vBoostChaserCheck gnm_BoostChaserCheck Checked%BoostChaserCheck%, Gather in`nBoosted Field
;hotbar
Gui, Add, Text, x165 y40 w140 left +BackgroundTrans, Use
Gui, Add, Text, x286 y40 w140 left +BackgroundTrans, Options
Gui, Add, Text, x134 y54 w252 h1 0x7
hotbarwhilelist := "|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (beesmasActive ? "|Snowflake" : "") (PMondoGuid ? "|Glitter" : "") "|"
Loop, 6
{
	i := A_Index + 1
	Gui, Add, Text, % "x135 y" (41 + 20 * A_Index) " w10 +BackgroundTrans", %i%:
	Gui, Add, DropDownList, % "x145 y" 37 + 20 * A_Index " w80 hwndhHB" i " vHotbarWhile" i " gnm_HotbarWhile Disabled", % LTrim(StrReplace(hotbarwhilelist, "|" HotbarWhile%i% "|", "|" HotbarWhile%i% "||"), "|")
	Gui, Add, Text, % "x233 y" 41 + 20 * A_Index " cRed vHBOffText" i, <-- OFF
	Gui, Add, Text, % "x226 y" 41 + 20 * A_Index " w120 vHBText" i " Hidden"
	Gui, Add, Text, % "x228 y" 41 + 20 * A_Index " w62 vHBTimeText" i " gnm_HotkeyEditTime +Center Hidden"
	Gui, Add, UpDown, % "x290 y" 40 + 20 * A_Index " w10 h16 -16 Range1-99999 vHotbarTime" i " gnm_saveBoost Hidden", % HotbarTime%i%
	Gui, Add, Text, % "x308 y" 41 + 20 * A_Index " w62 vHBConditionText" i " +Center Hidden"
	Gui, Add, UpDown, % "x370 y" 40 + 20 * A_Index " w10 h16 -16 Range1-100 vHotkeyMax" i " gnm_saveBoost Hidden", % HotkeyMax%i%
}
nm_HotbarWhile()
Gui, Add, Button, x20 y200 w90 h30 vAutoFieldBoostButton gnm_autoFieldBoostButton, % (AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]")
Gui, Font, w700
Gui, Font, s8 cDefault Norm, Tahoma
PostMessage, 0x5555, 65, 0, , ahk_pid %lp_PID%

;QUEST TAB
;------------------------
Gui, Tab, Quest
;GuiControl,focus, Tab
Gui, Font, w700
Gui, Add, GroupBox, x5 y23 w150 h108, Polar Bear
Gui, Add, GroupBox, x5 y131 w150 h38, Honey Bee
Gui, Add, GroupBox, x5 y170 w150 h68, QUEST SETTINGS
Gui, Add, GroupBox, x160 y23 w165 h108, Black Bear
Gui, Add, GroupBox, x160 y131 w165 h108, Brown Bear
Gui, Add, Text, x165 y145 cRED, Not Yet Implemented
Gui, Add, GroupBox, x330 y23 w165 h108, Bucko Bee
Gui, Add, GroupBox, x330 y131 w165 h108, Riley Bee
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x80 y23 vPolarQuestCheck gnm_savequest Checked%PolarQuestCheck%, Enable
Gui, Add, Checkbox, x15 y37 vPolarQuestGatherInterruptCheck gnm_savequest Checked%PolarQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x8 y51 w145 h78 vPolarQuestProgress, % StrReplace(PolarQuestProgress, "|", "`n")
Gui, Add, Checkbox, x80 y131 vHoneyQuestCheck gnm_savequest Checked%HoneyQuestCheck%, Enable
Gui, Add, Text, x8 y145 w143 h20 vHoneyQuestProgress, % StrReplace(HoneyQuestProgress, "|", "`n")
Gui, Add, Text, x8 y188 +BackgroundTrans, Quest Gather Limit:
Gui, Add, Edit, x100 y185 w25 h17 limit3 number vQuestGatherMins gnm_savequest, %QuestGatherMins%
Gui, Add, Text, x8 y205 +BackgroundTrans, Return to hive by:
Gui, Add, DropDownList, x92 y203 w55 vQuestGatherReturnBy gnm_savequest, % LTrim(StrReplace("|Walk|Reset|", "|" QuestGatherReturnBy "|", "|" QuestGatherReturnBy "||"), "|")
Gui, Add, Text, x126 y188 +BackgroundTrans, Mins
Gui, Add, Checkbox, x235 y23 vBlackQuestCheck gnm_BlackQuestCheck Checked%BlackQuestCheck%, Enable
Gui, Add, Text, x163 y38 w158 h92 vBlackQuestProgress, % StrReplace(BlackQuestProgress, "|", "`n")
Gui, Add, Checkbox, x410 y23 vBuckoQuestCheck gnm_BuckoQuestCheck Checked%BuckoQuestCheck%, Enable
Gui, Add, Checkbox, x340 y37 vBuckoQuestGatherInterruptCheck gnm_BuckoQuestCheck Checked%BuckoQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x333 y51 w158 h78 vBuckoQuestProgress, % StrReplace(BuckoQuestProgress, "|", "`n")
Gui, Add, Checkbox, x410 y131 vRileyQuestCheck gnm_RileyQuestCheck Checked%RileyQuestCheck%, Enable
Gui, Add, Checkbox, x340 y145 vRileyQuestGatherInterruptCheck gnm_RileyQuestCheck Checked%RileyQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x333 y159 w158 h78 vRileyQuestProgress, % StrReplace(RileyQuestProgress, "|", "`n")
Gui, Font, w700
Gui, Font, s8 cDefault Norm, Tahoma
PostMessage, 0x5555, 70, 0, , ahk_pid %lp_PID%

;PLANTERS TAB
;------------------------
Gui, Tab, Planters
;GuiControl,focus, Tab
Gui, Add, Slider, x364 y24 w130 h19 vPlanterMode gba_PlanterSwitch Range0-2 Thick16 TickInterval1 Page1 +BackgroundTrans, %PlanterMode%
Gui, Add, Text, x366 y43 h20 cRed +Center +BackgroundTrans, OFF
Gui, Add, Text, x410 y43 h20 c0xFF9200 +Center +BackgroundTrans, MANUAL
Gui, Add, Text, x478 y43 h20 cGreen +Center +BackgroundTrans, +
;Planters+ Start
Gui, Add, Text, % "x17 y27 w40 h20 +left +BackgroundTrans vTextPresets" ((PlanterMode = 2) ? "" : " Hidden"), Presets
Gui, Add, DropDownList, % "x57 y24 w60 h100 vNPreset gba_nPresetSwitch_" ((PlanterMode = 2) ? "" : " Hidden"), %nPreset%||Custom|Blue|Red|White
Gui, Add, Text, % "x10 y47 w80 h20 +center +BackgroundTrans vTextNP" ((PlanterMode = 2) ? "" : " Hidden"), Nectar Priority
Gui, Add, Text, % "x100 y47 w47 h30 +center +BackgroundTrans vTextMin" ((PlanterMode = 2) ? "" : " Hidden"), Min `%
Gui, Add, Text, % "x10 y62 w137 h1 0x7 vTextLine1" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Text, % "x10 y69 w10 h20 +Left +BackgroundTrans vText1" ((PlanterMode = 2) ? "" : " Hidden"), 1
Gui, Add, Text, % "x10 y89 w10 h20 +Left +BackgroundTrans vText2" ((PlanterMode = 2) ? "" : " Hidden"), 2
Gui, Add, Text, % "x10 y109 w10 h20 +Left +BackgroundTrans vText3" ((PlanterMode = 2) ? "" : " Hidden"), 3
Gui, Add, Text, % "x10 y129 w10 h20 +Left +BackgroundTrans vText4" ((PlanterMode = 2) ? "" : " Hidden"), 4
Gui, Add, Text, % "x10 y149 w10 h20 +Left +BackgroundTrans vText5" ((PlanterMode = 2) ? "" : " Hidden"), 5
Gui, Add, DropDownList, % "x20 y66 w80 h120 vN1priority gba_N1unswitch_" ((PlanterMode = 2) ? "" : " Hidden"), % LTrim(StrReplace("|" LTrim(n1string, "|") "|", "|" n1priority "|", "|" n1priority "||"), "|")
Gui, Add, DropDownList, % "x20 y86 w80 h120 vN2priority gba_N2unswitch_" (((PlanterMode = 2) && (N1Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|" LTrim(n2string, "|") "|", "|" n2priority "|", "|" n2priority "||"), "|")
Gui, Add, DropDownList, % "x20 y106 w80 h120 vN3priority gba_N3unswitch_" (((PlanterMode = 2) && (N2Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|" LTrim(n3string, "|") "|", "|" n3priority "|", "|" n3priority "||"), "|")
Gui, Add, DropDownList, % "x20 y126 w80 h120 vN4priority gba_N4unswitch_" (((PlanterMode = 2) && (N3Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|" LTrim(n4string, "|") "|", "|" n4priority "|", "|" n4priority "||"), "|")
Gui, Add, DropDownList, % "x20 y146 w80 h120 vN5priority gba_N5unswitch_" (((PlanterMode = 2) && (N4Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|" LTrim(n5string, "|") "|", "|" n5priority "|", "|" n5priority "||"), "|")
Gui, Add, DropDownList, % "x105 y66 w40 h100 vN1minPercent gba_N1Punswitch_" ((PlanterMode = 2) ? "" : " Hidden"), % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n1minPercent "|", "|" n1minPercent "||"), "|")
Gui, Add, DropDownList, % "x105 y86 w40 h100 vN2minPercent gba_N2Punswitch_" (((PlanterMode = 2) && (N1Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n2minPercent "|", "|" n2minPercent "||"), "|")
Gui, Add, DropDownList, % "x105 y106 w40 h100 vN3minPercent gba_N3Punswitch_" (((PlanterMode = 2) && (N2Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n3minPercent "|", "|" n3minPercent "||"), "|")
Gui, Add, DropDownList, % "x105 y126 w40 h100 vN4minPercent gba_N4Punswitch_" (((PlanterMode = 2) && (N3Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n4minPercent "|", "|" n4minPercent "||"), "|")
Gui, Add, DropDownList, % "x105 y146 w40 h100 vN5minPercent gba_N5Punswitch_" (((PlanterMode = 2) && (N4Priority != "none")) ? "" : " Hidden"), % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n5minPercent "|", "|" n5minPercent "||"), "|")
Gui, Add, Text, % "x10 y171 w137 h1 0x7 vTextLine2" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Text, % "x5 y178 w70 h20 +right +BackgroundTrans vTextHarvest" ((PlanterMode = 2) ? "" : " Hidden"), Harvest Every
Gui, Add, Checkbox, % "x103 y194 w40 +BackgroundTrans vAutomaticHarvestInterval gba_AutoHarvestSwitch_ Checked" AutomaticHarvestInterval ((PlanterMode = 2) ? "" : " Hidden"), Auto
Gui, Add, Checkbox, % "x28 y194 +BackgroundTrans vHarvestFullGrown gba_HarvestFullGrownSwitch_ Checked" HarvestFullGrown ((PlanterMode = 2) ? "" : " Hidden"), Full Grown
Gui, Add, Checkbox, % "x2 y211 +BackgroundTrans vgotoPlanterField gba_gotoPlanterFieldSwitch_ Checked" gotoPlanterField ((PlanterMode = 2) ? "" : " Hidden"), Only Gather in Planter Field
Gui, Add, Checkbox, % "x2 y224 w150 h14 +BackgroundTrans vgatherFieldSipping gba_gatherFieldSippingSwitch_ Checked" gatherFieldSipping ((PlanterMode = 2) ? "" : " Hidden"), Gather Field Nectar Sipping
Gui, Add, Text, % "x80 y178 w32 h20 cRed +left vAutoText +BackgroundTrans" (((PlanterMode = 2) && AutomaticHarvestInterval) ? "" : " Hidden"), [Auto]
Gui, Add, Text, % "x80 y178 w32 h20 cRed +left vFullText +BackgroundTrans" (((PlanterMode = 2) && HarvestFullGrown) ? "" : " Hidden"), [Full]
Gui, Add, Edit, % "x80 y174 w32 h20 limit2 Number vHarvestInterval gba_harvestInterval" (((PlanterMode = 2) && !HarvestFullGrown && !AutomaticHarvestInterval) ? "" : " Hidden"), %HarvestInterval%
Gui, Add, Text, % "x115 y178 w70 h20 +left +BackgroundTrans vTextHours" ((PlanterMode = 2) ? "" : " Hidden"), Hours
Gui, Add, Text, % "x10 y209 w137 h1 0x7 vTextLine3" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Button, % "x261 y24 w96 h18 -Wrap vTimersButton gba_showPlanterTimers" ((PlanterMode = 2) ? "" : " Hidden"), % " Show Timers (" TimersHotkey ")"
Gui, Add, Text, % "x147 y28 w1 h182 0x7 vTextLine4" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Text, % "x147 y27 w108 h20 +Center +BackgroundTrans vTextAllowedPlanters" ((PlanterMode = 2) ? "" : " Hidden"), Allowed Planters
Gui, Add, Text, % "x255 y43 w100 h20 +Center +BackgroundTrans vTextAllowedFields" ((PlanterMode = 2) ? "" : " Hidden"), Allowed Fields
Gui, Add, Text, % "x147 y42 w108 h1 0x7 vTextLine5" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Checkbox, % "x155 y47 vPlasticPlanterCheck gba_saveConfig_ Checked" PlasticPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Plastic
Gui, Add, Checkbox, % "x155 y61 vCandyPlanterCheck gba_saveConfig_ Checked" CandyPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Candy
Gui, Add, Checkbox, % "x155 y75 vBlueClayPlanterCheck gba_saveConfig_ Checked" BlueClayPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Blue Clay
Gui, Add, Checkbox, % "x155 y89 vRedClayPlanterCheck gba_saveConfig_ Checked" RedClayPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Red Clay
Gui, Add, Checkbox, % "x155 y103 vTackyPlanterCheck gba_saveConfig_ Checked" TackyPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Tacky
Gui, Add, Checkbox, % "x155 y117 vPesticidePlanterCheck gba_saveConfig_ Checked" PesticidePlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Pesticide
Gui, Add, Checkbox, % "x155 y131 vHeatTreatedPlanterCheck gba_saveConfig_ Checked" HeatTreatedPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Heat-Treated
Gui, Add, Checkbox, % "x155 y145 vHydroponicPlanterCheck gba_saveConfig_ Checked" HydroponicPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Hydroponic
Gui, Add, Checkbox, % "x155 y159 vPetalPlanterCheck gba_saveConfig_ Checked" PetalPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Petal
Gui, Add, Checkbox, % "x155 y173 w100 h13 vPlanterOfPlentyCheck gba_saveConfig_ Checked" PlanterOfPlentyCheck ((PlanterMode = 2) ? "" : " Hidden"), Planter of Plenty
Gui, Add, Checkbox, % "x155 y187 vPaperPlanterCheck gba_saveConfig_ Checked" PaperPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Paper
Gui, Add, Checkbox, % "x155 y201 vTicketPlanterCheck gba_saveConfig_ Checked" TicketPlanterCheck ((PlanterMode = 2) ? "" : " Hidden"), Ticket
Gui, Add, Text, % "x155 y217 w80 h20 +left +BackgroundTrans vTextMax" ((PlanterMode = 2) ? "" : " Hidden"), Max Planters
Gui, Add, Edit, % "x219 y215 w34 h18 vMaxAllowedPlantersEdit +BackgroundTrans gnm_saveAutoClicker Number" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, UpDown, % "vMaxAllowedPlanters gba_maxAllowedPlantersSwitch Range0-3" ((PlanterMode = 2) ? "" : " Hidden"), %MaxAllowedPlanters%
Gui, Add, Text, % "x255 y28 w1 h204 0x7 vTextLine6" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Add, Text, % "x255 y58 w240 h1 0x7 vTextLine7" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Font, s7
Gui, Add, Text, % "x250 y61 w100 h20 +Center +BackgroundTrans vTextZone1" ((PlanterMode = 2) ? "" : " Hidden"), -- starting zone --
Gui, Add, Text, % "x250 y142 w100 h20 +Center +BackgroundTrans vTextZone2" ((PlanterMode = 2) ? "" : " Hidden"), -- 5 bee zone --
Gui, Add, Text, % "x250 y195 w100 h20 +Center +BackgroundTrans vTextZone3" ((PlanterMode = 2) ? "" : " Hidden"), -- 10 bee zone --
Gui, Add, Text, % "x375 y61 w100 h20 +Center +BackgroundTrans vTextZone4" ((PlanterMode = 2) ? "" : " Hidden"), -- 15 bee zone --
Gui, Add, Text, % "x375 y128 w100 h20 +Center +BackgroundTrans vTextZone5" ((PlanterMode = 2) ? "" : " Hidden"), -- 25 bee zone --
Gui, Add, Text, % "x375 y153 w100 h20 +Center +BackgroundTrans vTextZone6" ((PlanterMode = 2) ? "" : " Hidden"), -- 35 bee zone --
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, % "x260 y72 vDandelionFieldCheck gba_saveConfig_ Checked" DandelionFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Dandelion (COM)
Gui, Add, Checkbox, % "x260 y86 vSunflowerFieldCheck gba_saveConfig_ Checked" SunflowerFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Sunflower (SAT)
Gui, Add, Checkbox, % "x260 y100 vMushroomFieldCheck gba_saveConfig_ Checked" MushroomFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Mushroom (MOT)
Gui, Add, Checkbox, % "x260 y114 vBlueFlowerFieldCheck gba_saveConfig_ Checked" BlueFlowerFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Blue Flower (REF)
Gui, Add, Checkbox, % "x260 y128 vCloverFieldCheck gba_saveConfig_ Checked" CloverFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Clover (INV)
Gui, Add, Checkbox, % "x260 y153 vSpiderFieldCheck gba_saveConfig_ Checked" SpiderFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Spider (MOT)
Gui, Add, Checkbox, % "x260 y167 vStrawberryFieldCheck gba_saveConfig_ Checked" StrawberryFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Strawberry (REF)
Gui, Add, Checkbox, % "x260 y181 vBambooFieldCheck gba_saveConfig_ Checked" BambooFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Bamboo (COM)
Gui, Add, Checkbox, % "x260 y206 vPineappleFieldCheck gba_saveConfig_ Checked" PineappleFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Pineapple (SAT)
Gui, Add, Checkbox, % "x260 y220 vStumpFieldCheck gba_saveConfig_ Checked" StumpFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Stump (MOT)
Gui, Add, Checkbox, % "x380 y72 vCactusFieldCheck gba_saveConfig_ Checked" CactusFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Cactus (INV)
Gui, Add, Checkbox, % "x380 y86 vPumpkinFieldCheck gba_saveConfig_ Checked" PumpkinFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Pumpkin (SAT)
Gui, Add, Checkbox, % "x380 y100 vPineTreeFieldCheck gba_saveConfig_ Checked" PineTreeFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Pine Tree (COM)
Gui, Add, Checkbox, % "x380 y114 vRoseFieldCheck gba_saveConfig_ Checked" RoseFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Rose (MOT)
Gui, Add, Checkbox, % "x380 y139 vMountainTopFieldCheck gba_saveConfig_ Checked" MountainTopFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Mountain Top (INV)
Gui, Add, Checkbox, % "x380 y164 vCoconutFieldCheck gba_saveConfig_ Checked" CoconutFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Coconut (REF)
Gui, Add, Checkbox, % "x380 y178 vPepperFieldCheck gba_saveConfig_ Checked" PepperFieldCheck ((PlanterMode = 2) ? "" : " Hidden"), Pepper (INV)
Gui, Add, Text, % "x360 y196 w136 h36 0x7 vTextBox1" ((PlanterMode = 2) ? "" : " Hidden")
Gui, Font, s7
Gui, Add, Checkbox, % "x364 y200 w126 h13 vConvertFullBagHarvest gba_saveConfig_ Checked" ConvertFullBagHarvest ((PlanterMode = 2) ? "" : " Hidden"), Convert Full Bag Harvest
Gui, Add, Checkbox, % "x364 y216 w126 h13 vGatherPlanterLoot gba_saveConfig_ Checked" GatherPlanterLoot ((PlanterMode = 2) ? "" : " Hidden"), Gather Planter Loot

Gui, Font, s8 cDefault Norm, Tahoma
PostMessage, 0x5555, 80, 0, , ahk_pid %lp_PID%
;Manual Planters Start

MPlanterListText := "|Plastic|Candy|Blue Clay|Red Clay|Tacky|Pesticide|Heat Treated|Hydroponic|Petal|Planter of Plenty|Paper|Ticket|"
MFieldListText := "|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|"

; Headers
Gui, Add, Text, % "x67 y23 w92 +BackgroundTrans +Center vMHeader1Text" (PlanterMode == 1 ? "" : " Hidden"), Cycle #1
Gui, Add, Text, % "xp+96 yp wp +BackgroundTrans +Center vMHeader2Text" (PlanterMode == 1 ? "" : " Hidden"), Cycle #2
Gui, Add, Text, % "xp+96 yp wp +BackgroundTrans +Center vMHeader3Text" (PlanterMode == 1 ? "" : " Hidden"), Cycle #3

Loop, 3 {
    i := A_Index
    Gui, Add, Text, % ((i = 1) ? "x5 y40" : "xs ys+29") " +Center Section vMSlot" i "PlanterText" (PlanterMode == 1 ? "" : " Hidden"), S%i% Planters:
    Loop, 9 {
        Gui, Add, DropDownList, % "x" ((Mod(A_Index, 3) = 1) ? "s+62" : "p+50") " ys-3 w92 vMSlot" i "Cycle" A_Index "Planter gmp_SaveConfig" (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden"), % (MSlot%i%Cycle%A_Index%Planter ? StrReplace(MPlanterListText, MSlot%i%Cycle%A_Index%Planter, MSlot%i%Cycle%A_Index%Planter "|") : "|" MPlanterListText)
		Gui, Add, DropDownList, % "x" ((Mod(A_Index, 3) = 1) ? "s+62" : "p") " ys+17 w92 vMSlot" i "Cycle" A_Index "Field gmp_SaveConfig" (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden"), % (MSlot%i%Cycle%A_Index%Field ? StrReplace(MFieldListText, MSlot%i%Cycle%A_Index%Field, MSlot%i%Cycle%A_Index%Field "|") : "|" MFieldListText)
		Gui, Add, CheckBox, % "x" ((Mod(A_Index, 3) = 1) ? "s+62" : "p") " ys+41 w46 vMSlot" i "Cycle" A_Index "Glitter gmp_SaveConfig" (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden") " Checked" MSlot%i%Cycle%A_Index%Glitter, Glitter
		Gui, Add, DropDownList, % "x" ((Mod(A_Index, 3) = 1) ? "s+108" : "p+46") " ys+38 w46 vMSlot" i "Cycle" A_Index "AutoFull gmp_SaveConfig" (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden"), % StrReplace("Full|Timed|", MSlot%i%Cycle%A_Index%AutoFull, MSlot%i%Cycle%A_Index%AutoFull "|")
	}
    Gui, Add, Text, % "xs ys+20 +Center Section vMSlot" i "FieldText" (PlanterMode == 1 ? "" : " Hidden"), S%i% Fields:
    Gui, Add, Text, % "xs ys+20 +Center Section vMSlot" i "SettingsText" (PlanterMode == 1 ? "" : " Hidden"), S%i% Settings:
    if (i < 3)
        Gui, Add, Text, % "xs ys+22 w" ((i = 1) ? "350" : "500") " h1 0x7 vMSlot" i "SeparatorLine" (PlanterMode == 1 ? "" : " Hidden")
}

Loop, 3 {
	Gui, Add, Text, % ((A_Index = 1) ? "x360 y63" : "xs ys+35") "w200 +BackgroundTrans Section vMSlot" A_Index "CycleText" (PlanterMode == 1 ? "" : " Hidden"), % "Slot " A_Index " currently at cycle #" PlanterManualCycle%A_Index%
	Gui, Add, Button, % "xs+25 ys+17 w20 h16 vMSlot" A_Index "Left gmp_Slot" A_Index "ChangeLeft" (PlanterMode == 1 ? "" : " Hidden"), <
	Gui, Add, Text, % "x+4 yp+1 h16 vMSlot" A_Index "ChangeText" (PlanterMode == 1 ? "" : " Hidden"), Change
	Gui, Add, Button, % "x+4 yp-1 w20 h16 vMSlot" A_Index "Right gmp_Slot" A_Index "ChangeRight" (PlanterMode == 1 ? "" : " Hidden"), >
}

Gui, Add, Text, % "x355 y23 h215 w1 0x7 vMSectionSeparatorLine" (PlanterMode == 1 ? "" : " Hidden")
Gui, Add, Text, % "x355 y58 h1 w150 0x7 vMSliderSeparatorLine" (PlanterMode == 1 ? "" : " Hidden")

;; check plants button
Gui, Add, Text, % "xs ys+50 +Center vMHarvestText Section" (PlanterMode == 1 ? "" : " Hidden"), Harvest
Gui, Add, DropdownList, % "xp+41 yp-3 w94 vMHarvestInterval gmp_SaveConfig" (PlanterMode == 1 ? "" : " Hidden"), % StrReplace("Every 30 Minutes|Every Hour|Every 2 Hours|Every 3 Hours|Every 4 Hours|Every 5 Hours|Every 6 Hours|", MHarvestInterval, MHarvestInterval "|")

; page movement
Gui, Add, Button, % "xs+25 ys+24 w20 h20 hwndMPageLeftHWND vMPageLeft gmp_UpdatePage Disabled" (PlanterMode == 1 ? "" : " Hidden"), <
Gui, Add, Text, % "x+4 yp+3 +Center vMPageNumberText" (PlanterMode == 1 ? "" : " Hidden"), % "Page: " (MPageIndex := 1)
Gui, Add, Button, % "x+4 yp-3 w20 h20 hwndMPageRightHWND vMPageRight gmp_UpdatePage " (PlanterMode == 1 ? "" : " Hidden"), >

mp_UpdatePage(hwnd)
{
	Global MPageIndex, MPageLeftHWND, MPageRightHWND
	Static ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"], LastPageIndex := 1

	MPageIndex += ((hwnd == MPageLeftHWND) ? -1 : 1)

	GuiControl, % ((MPageIndex == 1) ? "Disable" : "Enable"), % MPageLeftHWND
	GuiControl, % ((MPageIndex == 3) ? "Disable" : "Enable"), % MPageRightHWND
	GuiControl, Text, MPageNumberText, Page: %MPageIndex%

	Loop, 3 {
		GuiControl, Text, MHeader%A_Index%Text, % "Cycle #" ((MPageIndex - 1) * 3 + A_Index)
		i := A_Index
		for k,v in ManualPlantersOptions {
			Loop, 3 {
				GuiControl, Hide, % "MSlot" A_Index "Cycle" (3 * (LastPageIndex - 1) + i) v
				GuiControl, Show, % "MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v
			}
		}
	}

	LastPageIndex := MPageIndex
}

mp_UpdateControls()
mp_UpdateControls() {
	global
	local i, j

	Loop, 3 {
		i := A_Index
		Loop, 9 {
			GuiControl, Choose, MSlot%i%Cycle%A_Index%Planter, % (MSlot%i%Cycle%A_Index%Planter ? MSlot%i%Cycle%A_Index%Planter : 1)
			GuiControl, Choose, MSlot%i%Cycle%A_Index%Field, % (MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%Field : 1)
			GuiControl,, MSlot%i%Cycle%A_Index%Glitter, % MSlot%i%Cycle%A_Index%Glitter
			GuiControl, Choose, MSlot%i%Cycle%A_Index%AutoFull, % MSlot%i%Cycle%A_Index%AutoFull
		}
	}

	Loop, 3 {
		i := A_Index
		Loop, 9 {
			j := A_Index - 1
			If (A_Index != 1)
				GuiControl, % (MSlot%i%Cycle%j%Field ? "Enable" : "Disable"), MSlot%i%Cycle%A_Index%Planter
			GuiControl, % (MSlot%i%Cycle%A_Index%Planter ? "Enable" : "Disable"), MSlot%i%Cycle%A_Index%Field
			GuiControl, % (MSlot%i%Cycle%A_Index%Field ? "Enable" : "Disable"), MSlot%i%Cycle%A_Index%Glitter
			GuiControl, % (MSlot%i%Cycle%A_Index%Field ? "Enable" : "Disable"), MSlot%i%Cycle%A_Index%AutoFull
		}
		j := A_Index - 1
		If (i > 1)
			GuiControl, % (MSlot%j%Cycle1Field ? "Enable" : "Disable"), MSlot%i%Cycle1Planter
	}

	mp_UpdateCycles()
}

mp_SaveConfig() {
	global
	local i, j

	Loop, 3 {
		i := A_Index
		Loop, 9 {
			GuiControlGet, MSlot%i%Cycle%A_Index%Planter
			GuiControlGet, MSlot%i%Cycle%A_Index%Field
			GuiControlGet, MSlot%i%Cycle%A_Index%Glitter
			GuiControlGet, MSlot%i%Cycle%A_Index%AutoFull
		}
	}

	GuiControlGet, MHarvestInterval

	Loop, 3 {
		i := A_Index
		Loop, 9 {
			j := A_Index - 1
			If (A_Index != 1)
				MSlot%i%Cycle%A_Index%Planter := MSlot%i%Cycle%j%Field ? MSlot%i%Cycle%A_Index%Planter : ""
			MSlot%i%Cycle%A_Index%Field := MSlot%i%Cycle%A_Index%Planter ? MSlot%i%Cycle%A_Index%Field : ""
			MSlot%i%Cycle%A_Index%Glitter := MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%Glitter : 0
			MSlot%i%Cycle%A_Index%AutoFull := MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%AutoFull : "Timed"
		}
		j := A_Index + 1
		If (i < 3)
			MSlot%j%Cycle1Planter := MSlot%i%Cycle1Field ? MSlot%j%Cycle1Planter : ""
	}

	Loop, 3 {
		i := A_Index
		Loop, 9 {
			IniWrite, % MSlot%i%Cycle%A_Index%Planter, Settings\manual_planters.ini, % "Slot " i, MSlot%i%Cycle%A_Index%Planter
			IniWrite, % MSlot%i%Cycle%A_Index%Field, Settings\manual_planters.ini, % "Slot " i, MSlot%i%Cycle%A_Index%Field
			IniWrite, % MSlot%i%Cycle%A_Index%Glitter, Settings\manual_planters.ini, % "Slot " i, MSlot%i%Cycle%A_Index%Glitter
			IniWrite, % MSlot%i%Cycle%A_Index%AutoFull, Settings\manual_planters.ini, % "Slot " i, MSlot%i%Cycle%A_Index%AutoFull
		}
	}

	IniWrite, % MHarvestInterval, Settings\manual_planters.ini, General, MHarvestInterval

	mp_UpdateControls()
}

mp_UpdateCycles() {
	global
	local i

	Loop, 3 {
		i := A_Index, MSlot%A_Index%MaxCycle := 9
		Loop, 9 {
			If (!MSlot%i%Cycle%A_Index%Field) {
				MSlot%i%MaxCycle := Max(A_Index - 1, 1)
				break
			}
		}

		PlanterManualCycle%i% := Min(MSlot%i%MaxCycle, PlanterManualCycle%i%)
		IniWrite, % PlanterManualCycle%i%, Settings\nm_config.ini, Planters, PlanterManualCycle%i%

		GuiControl, % (PlanterManualCycle%i% != 1 ? "Enable" : "Disable"), MSlot%i%Left
		GuiControl, % (PlanterManualCycle%i% < MSlot%i%MaxCycle ? "Enable" : "Disable"), MSlot%i%Right
		GuiControl,, MSlot%i%CycleText, % "Slot " i " currently at cycle #" PlanterManualCycle%i%
	}
}

mp_Slot1ChangeLeft() {
	Global PlanterManualCycle1
	PlanterManualCycle1--

	mp_UpdateCycles()
}

mp_Slot1ChangeRight() {
	Global PlanterManualCycle1
	PlanterManualCycle1++

	mp_UpdateCycles()
}

mp_Slot2ChangeLeft() {
	Global PlanterManualCycle2
	PlanterManualCycle2--

	mp_UpdateCycles()
}

mp_Slot2ChangeRight() {
	Global PlanterManualCycle2
	PlanterManualCycle2++

	mp_UpdateCycles()
}

mp_Slot3ChangeLeft() {
	Global PlanterManualCycle3
	PlanterManualCycle3--

	mp_UpdateCycles()
}

mp_Slot3ChangeRight() {
	Global PlanterManualCycle3
	PlanterManualCycle3++

	mp_UpdateCycles()
}

mp_Planter() {
	Global
	Local utc_min, TimeElapsed, GlitterPos, field, i, k, v

	if (PlanterMode != 1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	If (VBState == 1 || ((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")) || ((nowUnix()-GatherFieldBoostedStart)<900 || (nowUnix()-LastGlitter)<900 || nm_boostBypassCheck()))
		Return

	Loop, 2 {
		Loop, 3 {
			If (!MSlot%A_Index%Cycle1Field)
				Continue
			If (PlanterHarvestTime%A_Index% > 2**31) {
				mp_PlantPlanter(A_Index)
			} Else {
				If (nowUnix() >= PlanterHarvestTime%A_Index%)
					mp_HarvestPlanter(A_Index)
				If (PlanterHarvestFull%A_Index% == "Full" && (nowUnix() - LastGlitter >= 900) && PlanterGlitterC%A_Index% && !PlanterGlitter%A_Index%) {
					i := A_Index, field := StrReplace(PlanterField%A_Index%, " ")
					for k,v in %field%Planters {
						if (v[1] = PlanterName%i%) {
							PlanterGrowTime := v[4]
							break
						}
					}
					If ((PlanterHarvestTime%A_Index% - nowUnix()) >= Round(3600 * PlanterGrowTime * 0.5)) {
						mp_UseGlitter(A_Index)
					}
				}
			}
		}
	}
}

mp_PlantPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MFieldName, MPlanterName, planterPos, pBMScreen, imgPos, field, k, v
	Static MHarvestIntervalValue := {"Every 30 Minutes":0.5
		, "Every Hour":1
		, "Every 2 Hours":2
		, "Every 3 Hours":3
		, "Every 4 Hours":4
		, "Every 5 Hours":5
		, "Every 6 Hours":6}
	, MFieldNectars := {"Dandelion":"Comforting"
		, "Bamboo":"Comforting"
		, "Pine Tree":"Comforting"
		, "Coconut":"Refreshing"
		, "Strawberry":"Refreshing"
		, "Blue Flower":"Refreshing"
		, "Pineapple":"Satisfying"
		, "Sunflower":"Satisfying"
		, "Pumpkin":"Satisfying"
		, "Stump":"Motivating"
		, "Spider":"Motivating"
		, "Mushroom":"Motivating"
		, "Rose":"Motivating"
		, "Pepper":"Invigorating"
		, "Mountain Top":"Invigorating"
		, "Clover":"Invigorating"
		, "Cactus":"Invigorating"}

	If (CurrentAction != "Planters") {
		PreviousAction := CurrentAction
		CurrentAction := "Planters"
	}

	Loop % MSlot%PlanterIndex%MaxCycle {
		CycleIndex := PlanterManualCycle%PlanterIndex%
		MFieldName := MSlot%PlanterIndex%Cycle%CycleIndex%Field
		MPlanterName := (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))
		If (PlanterField1 = MFieldName || PlanterField2 = MFieldName || PlanterField3 = MFieldName || PlanterName1 = MPlanterName || PlanterName2 = MPlanterName || PlanterName3 = MPlanterName) {
			PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
			mp_UpdateCycles()
		} Else
			Break
		If (A_Index = MSlot%PlanterIndex%MaxCycle)
			Return
	}

	nm_setShiftLock(0)
	nm_OpenMenu("itemmenu")

	nm_Reset()
	nm_setStatus("Traveling", MPlanterName " (" MFieldName ")")
	nm_gotoPlanter(MFieldName, 0)

	WinActivate, Roblox
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())

	planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

	if (planterPos = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", MPlanterName)
		return 0
	}
	else
		MouseMove, windowX+planterPos[1], windowY+planterPos[2]

	KeyWait, F14, T120 L ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", MPlanterName)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|" windowWidth//2 "|" Max(480, windowHeight-120))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop, 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Missing", MPlanterName)
						return 0
					}
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Max(480, windowHeight-120))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[MPlanterName], planterPos, 0, 0, 306, Max(480, windowHeight-120), 10, , 5) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag, Left, windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		sleep, 200
	}
	Loop, 50
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 2, , 2) = 1) {
				MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
				sleep, 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+350, windowY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", MPlanterName)
			return 0
		}

		Sleep, 100
	}

	Loop, 10
	{
		Sleep, 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			nm_setStatus("Error", "3 Planters already placed!")
			Sleep, 500
			return 3
		}
		imgPos := nm_imgSearch("planteralready.png",30,"lowright")
		If (imgPos[1] = 0){
			return 2
		}
		imgPos := nm_imgSearch("standing.png",30,"lowright")
		If (imgPos[1] = 0){
			return 4
		}
	}

	PlanterName%PlanterIndex% := MPlanterName
	PlanterField%PlanterIndex% := MFieldName
	PlanterNectar%PlanterIndex% := MFieldNectars[MFieldName]
	PlanterGlitterC%PlanterIndex% := MSlot%PlanterIndex%Cycle%CycleIndex%Glitter
	PlanterGlitter%PlanterIndex% := 0
	if ((PlanterHarvestFull%PlanterIndex% := MSlot%PlanterIndex%Cycle%CycleIndex%AutoFull) = "Full") {
		field := StrReplace(PlanterField%PlanterIndex%, " ")
		for k,v in %field%Planters {
			if (v[1] = PlanterName%PlanterIndex%) {
				PlanterHarvestTime%PlanterIndex% := nowUnix() + Round(v[4] * 3600)
				break
			}
		}
	} else {
		PlanterHarvestTime%PlanterIndex% := nowUnix() + 3600 * MHarvestIntervalValue[MHarvestInterval]
		Loop, 3
			If (PlanterHarvestTime%A_Index% < PlanterHarvestTime%PlanterIndex% && PlanterHarvestTime%A_Index% > PlanterHarvestTime%PlanterIndex% - 300)
				PlanterHarvestTime%PlanterIndex% := PlanterHarvestTime%A_Index%
	}

	IniWrite, % PlanterName%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterName%PlanterIndex%
	IniWrite, % PlanterField%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterField%PlanterIndex%
	IniWrite, % PlanterNectar%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterNectar%PlanterIndex%
	IniWrite, % PlanterGlitter%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitter%PlanterIndex%
	IniWrite, % PlanterGlitterC%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitterC%PlanterIndex%
	IniWrite, % PlanterHarvestFull%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestFull%PlanterIndex%
	IniWrite, % PlanterHarvestTime%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestTime%PlanterIndex%

	If (nowUnix() - LastGlitter >= 900 && PlanterGlitterC%PlanterIndex% && !PlanterGlitter%PlanterIndex%)
		mp_UseGlitter(PlanterIndex, 1)

	return 1
}

mp_UseGlitter(PlanterIndex, atField:=0) {
	Global
	Local pBMScreen, windowX, windowY, windowWidth, windowHeight, glitterPos

	nm_setShiftLock(0)
	nm_OpenMenu("itemmenu")

	if (atField = 0) {
		nm_Reset()
		nm_setStatus("Traveling", "Glitter: " PlanterName%PlanterIndex% " (" PlanterField%PlanterIndex% ")")
		nm_gotoPlanter(PlanterField%PlanterIndex%, 0)
	}

	glitterPos := nm_InventorySearch("glitter")

	if (glitterPos = 0) ; glitter not in inventory
	{
		nm_setStatus("Missing", "Glitter")
		return 0
	}
	else
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+glitterPos[1], windowY+glitterPos[2]
	}

	KeyWait, F14, T120 L ; wait for gotoPlanter finish
	nm_endWalk()

	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|" windowWidth//2 "|" Max(480, windowHeight-120))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop, 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Missing", "Glitter")
						return 0
					}
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Max(480, windowHeight-120))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps["glitter"], glitterPos, 0, 0, 306, Max(480, windowHeight-120), 10, , 5) = 0)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag, Left, windowX+30, windowY+SubStr(glitterPos, InStr(glitterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		sleep, 200
	}

	nm_setStatus("Boosted", "Glitter: " PlanterName%PlanterIndex%)
	LastGlitter:=nowUnix()
	IniWrite, %LastGlitter%, settings\nm_config.ini, Boost, LastGlitter
	PlanterGlitter%PlanterIndex% := LastGlitter
	PlanterHarvestTime%PlanterIndex% := nowUnix() + (PlanterHarvestTime%PlanterIndex% - nowUnix()) * 0.75
	IniWrite, % PlanterGlitter%PlanterIndex%, settings\nm_config.ini, Planters, PlanterGlitter%PlanterIndex%
	IniWrite, % PlanterHarvestTime%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestTime%PlanterIndex%
}

mp_HarvestPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MPlanterName, MFieldName, findPlanter, planterPos, pBMScreen, Prev_DetectHiddenWindows, Prev_TitleMatchMode

	If (CurrentAction != "Planters") {
		PreviousAction := CurrentAction
		CurrentAction := "Planters"
	}

	MPlanterName := PlanterName%PlanterIndex%
	MFieldName := PlanterField%PlanterIndex%

	nm_setShiftLock(0)
	nm_Reset(nm_Reset(1, ((MFieldName = "Rose") || (MFieldName = "Pine Tree") || (MFieldName = "Pumpkin") || (MFieldName = "Cactus") || (MFieldName = "Spider")) ? min(20000, (60-HiveBees)*1000) : 0))

	nm_setStatus("Traveling", MPlanterName . " (" . MFieldName . ")")
	nm_gotoPlanter(MFieldName)
	nm_setStatus("Collecting", (MPlanterName . " (" . MFieldName . ")"))

	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep, 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (MPlanterName . " (" . MFieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . MPlanterName)

		nm_OpenMenu("itemmenu")
		planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", MPlanterName . ". Clearing Data.")

			;reset values
			CycleIndex := PlanterManualCycle%PlanterIndex%
			if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
				PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
				mp_UpdateCycles()
			}

			PlanterName%PlanterIndex% := ""
			PlanterField%PlanterIndex% := ""
			PlanterNectar%PlanterIndex% := ""
			PlanterGlitterC%PlanterIndex% := 0
			PlanterGlitter%PlanterIndex% := 0
			PlanterHarvestFull%PlanterIndex% := ""
			PlanterHarvestTime%PlanterIndex% := 20211106000000

			IniWrite, % PlanterName%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterName%PlanterIndex%
			IniWrite, % PlanterField%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterField%PlanterIndex%
			IniWrite, % PlanterNectar%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterNectar%PlanterIndex%
			IniWrite, % PlanterGlitter%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitter%PlanterIndex%
			IniWrite, % PlanterGlitterC%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitterC%PlanterIndex%
			IniWrite, % PlanterHarvestFull%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestFull%PlanterIndex%
			IniWrite, % PlanterHarvestTime%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestTime%PlanterIndex%
		}

		return 1
	}
	else {
		sendinput {e down}
		Sleep, 100
		sendinput {e up}

		Loop, 50
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep, 100

			if (A_Index = 50)
				return 0
		}

		Sleep, 50 ; wait for game to update frame
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		if (PlanterHarvestFull%PlanterIndex% == "Full") {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], pos, , , , , 2, , 3) = 1) {
					MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
					sleep, 150
					Click
					sleep 100
					MouseMove, windowX+350, windowY+100
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(FieldName)
					return 2
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 2, , 2) = 1) {
					MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
					sleep, 150
					Click
					sleep 100
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowX+350, windowY+100
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}

		;reset values
		CycleIndex := PlanterManualCycle%PlanterIndex%
		if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
			PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
			mp_UpdateCycles()
		}

		PlanterName%PlanterIndex% := ""
		PlanterField%PlanterIndex% := ""
		PlanterNectar%PlanterIndex% := ""
		PlanterGlitterC%PlanterIndex% := 0
		PlanterGlitter%PlanterIndex% := 0
		PlanterHarvestFull%PlanterIndex% := ""
		PlanterHarvestTime%PlanterIndex% := 20211106000000

		IniWrite, % PlanterName%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterName%PlanterIndex%
		IniWrite, % PlanterField%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterField%PlanterIndex%
		IniWrite, % PlanterNectar%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterNectar%PlanterIndex%
		IniWrite, % PlanterGlitter%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitter%PlanterIndex%
		IniWrite, % PlanterGlitterC%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterGlitterC%PlanterIndex%
		IniWrite, % PlanterHarvestFull%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestFull%PlanterIndex%
		IniWrite, % PlanterHarvestTime%PlanterIndex%, Settings/nm_config.ini, Planters, PlanterHarvestTime%PlanterIndex%

		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 4, 1
		}
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
		IniWrite, %TotalPlantersCollected%, settings\nm_config.ini, Status, TotalPlantersCollected
		IniWrite, %SessionPlantersCollected%, settings\nm_config.ini, Status, SessionPlantersCollected
		;gather loot
		nm_setStatus("Looting", MPlanterName . " Loot")
		sleep, 1000
		nm_Move(1500*round(18/MoveSpeedNum, 2), BackKey, RightKey)
		nm_loot(9, 5, "left")
		return 1
	}
}
;;Manual planters end

PostMessage, 0x5555, 95, 0, , ahk_pid %lp_PID%
if (BuffDetectReset = 1)
	nm_AdvancedGUI()
PostMessage, 0x5555, 100, 0, , ahk_pid %lp_PID%

WinClose, ahk_pid %lp_PID% ahk_class AutoHotkey
DetectHiddenWindows, Off
Gui, Show, x%GuiX% y%GuiY% w500 h285, Natro Macro
GuiControl,focus, Tab
nm_guiTransparencySet()
;enable hotkeys
Hotkey, %StartHotkey%, start, UseErrorLevel On
Hotkey, %PauseHotkey%, pause, UseErrorLevel On
Hotkey, %AutoClickerHotkey%, autoclicker, UseErrorLevel On T2
Hotkey, %TimersHotkey%, timers, UseErrorLevel On

;unlock tabs
nm_FieldUnlock()
nm_TabCollectUnLock()
nm_TabBoostUnLock()
nm_TabPlantersUnLock()
nm_TabSettingsUnLock()
nm_setStatus()

if(TimersOpen && (PlanterMode != 0))
    run, "%exe_path32%" /script "submacros\PlanterTimers.ahk" "%hwndstate%"

settimer, Background, 2000
if (A_Args[1] = 1)
	settimer, start, -1000

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_Start(){
	WinActivate, Roblox
	global serverStart
	global QuestGatherField
	serverStart:=nowUnix()
	run:=1
	while(run){
		DisconnectCheck()
		;vicious/stingers
		nm_locateVB()
		;mondo
		nm_Mondo()
		;planters
		mp_planter()
		ba_planter()
		;kill things
		nm_Bugrun()
		;collect things
		nm_Collect()
		;quests
		nm_QuestRotate()
		;booster
		nm_ToAnyBooster()
		;gather
		nm_GoGather()
		continue
		mainend:
		run:=0
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_TabSelect(){
	GuiControlGet, Tab
	GuiControl,focus, Tab
}
nm_LoadingProgress(){
	script := "
	(LTrim Join`r`n
	#NoEnv
	#NoTrayIcon
	#Requires AutoHotkey v1.1.36.01+
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	CoordMode, Mouse, Screen

	pToken := Gdip_Startup()
	w := 64, h := 64
	Gui, New, -Caption +E0x80000 +E0x8000000 +E0x20 +hwndhMain +LastFound +ToolWindow -DPIScale
	Gui, Show, NA
	hbm := CreateDIBSection(w, h)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 2)
	Gdip_SetInterpolationMode(G, 2)
	pPen := Gdip_CreatePen(0x80000000, 10), Gdip_DrawArc(G, pPen, 10, 10, 44, 44, -90, 360), Gdip_DeletePen(pPen)
	OnMessage(0x5555, ""UpdateProgress"")
	WinSet, AlwaysOnTop, On, % ""ahk_id "" hMain
	Loop
	{
		MouseGetPos, x, y
		UpdateLayeredWindow(hMain, hdc, x-32, y-32, w, h)
		Sleep, 10
	}
	return

	GuiClose:
	ExitApp

	UpdateProgress(wParam, lParam)
	{
		global G
		Gdip_GraphicsClear(G)
		percent := wParam*3.6
		pPen := Gdip_CreatePen(0xff551a8b, 10), Gdip_DrawArc(G, pPen, 10, 10, 44, 44, -91, percent+1), Gdip_DeletePen(pPen)
		pPen := Gdip_CreatePen(0x80000000, 10), Gdip_DrawArc(G, pPen, 10, 10, 44, 44, -91 + percent, 361 - percent), Gdip_DeletePen(pPen)
	}
	)"

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path32 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()

	return exec.ProcessID
}
nm_WebhookEasterEgg(){
	global WebhookEasterEgg
	Gui +OwnDialogs
	GuiControlGet, FieldName1
	GuiControlGet, FieldName2
	GuiControlGet, FieldName3
	if ((FieldName1 = FieldName2) && (FieldName2 = FieldName3))
	{
		msgbox, 0x1024, , You found an easter egg!`nEnable Rainbow Webhook?
		IfMsgBox, Yes
			WebhookEasterEgg := 1
		else
			WebhookEasterEgg := 0
		IniWrite, %WebhookEasterEgg%, settings\nm_config.ini, Status, WebhookEasterEgg
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage, 0x5552, 5, WebhookEasterEgg
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
	}
}
nm_showAdvancedSettings(){
	global BuffDetectReset
	static i := 0, t1, init := DllCall("GetSystemTimeAsFileTime", "int64p", t1)
	if (BuffDetectReset = 1)
		return
	DllCall("GetSystemTimeAsFileTime", "int64p", t2)
	if (t2 - t1 < 50000000)
	{
		if (++i >= 7)
			nm_AdvancedGUI(1), i := 0
	}
	else
		i := 1, t1 := t2
}
nm_AdvancedGUI(init:=0){
	global
	local hBM
	GuiControl, , Tab, Advanced
	Gui, Tab, Advanced
	Gui, Font, s8 cDefault Norm, Tahoma
	Gui, Font, w700
	Gui, Add, GroupBox, x5 y24 w240 h90, Fallback Private Servers
	Gui, Add, GroupBox, x5 y114 w240 h46, Advanced Tools
	Gui, Add, GroupBox, x255 y24 w240 h38, Debugging
	Gui, Add, GroupBox, x255 y62 w240 h168, Test Paths/Patterns
	Gui, Font, s8 cDefault Norm, Tahoma
	;reconnect
	Gui, Add, Text, x15 y44, 3 Fails:
	Gui, Add, Edit, x55 y42 w180 h18 +BackgroundTrans vFallbackServer1 gnm_ServerLink, %FallbackServer1%
	Gui, Add, Text, x15 y66, 6 Fails:
	Gui, Add, Edit, x55 y64 w180 h18 +BackgroundTrans vFallbackServer2 gnm_ServerLink, %FallbackServer2%
	Gui, Add, Text, x15 y88, 9 Fails:
	Gui, Add, Edit, x55 y86 w180 h18 +BackgroundTrans vFallbackServer3 gnm_ServerLink, %FallbackServer3%
	;debugging
	Gui, Add, Checkbox, x265 y42 +BackgroundTrans vssDebugging gnm_saveAdvanced Checked%ssDebugging%, Enable Discord Debugging Screenshots
	;advanced tools
	Gui, Add, Button, x20 y130 w210 h24 gnm_AutoStartManager, Auto-Start Manager
	;test
	Gui, Add, Checkbox, x265 y89 w14 h14 Checked vTest1Check
	Gui, Add, Checkbox, x265 y121 w14 h14 vTest2Check
	Gui, Add, Text, x285 y88 w174 hwndhTest1Text -Wrap, <none>
	Gui, Add, Text, x285 y120 w174 hwndhTest2Text -Wrap, <none>
	hBM := LoadPicture("shell32.dll", "w20 h-1 Icon046")
	Gui, Add, Picture, x465 y86 w20 h20 hwndhBrowse1 gnm_selectTestPath, HBITMAP:*%hBM%
	Gui, Add, Picture, x465 y118 w20 h20 hwndhBrowse2 gnm_selectTestPath, HBITMAP:*%hBM%
	DllCall("DeleteObject", "ptr", hBM)
	Gui, Add, Text, x292 y149, Repeat:
	Gui, Add, Edit, x336 y147 w64 h18 vTestCountEdit Number
	Gui, Add, UpDown, vTestCount Range1-99999, 1
	Gui, Add, Checkbox, x410 y149 +BackgroundTrans gnm_TestInfinite vTestInfinite, Infinite
	Gui, Add, Text, x283 y174, On Cycle Start:
	Gui, Add, Checkbox, x362 y174 +BackgroundTrans vTestReset Checked, Reset
	Gui, Add, Checkbox, x413 y174 +BackgroundTrans vTestMsgBox, MsgBox
	Gui, Add, Button, x325 y197 w100 h24 gnm_testButton, Start Test
	if (init = 1)
	{
		GuiControl, ChooseString, Tab, Advanced
		IniWrite, % (BuffDetectReset := 1), settings\nm_config.ini, Settings, BuffDetectReset
		msgbox, 0x40040, Advanced Settings, You have enabled Advanced Settings!`nHere you can find options that are not recommended to change.`nRemember that most of these settings are experimental and mainly intended for debugging and testing purposes!, 20
	}
}
nm_TestInfinite(){
	global
	GuiControlGet, TestInfinite
	local p := (TestInfinite ? "Disable" : "Enable")
	GuiControl, %p%, TestCountEdit
	GuiControl, %p%, TestCount
}
nm_selectTestPath(hCtrl){
	global hBrowse1, hBrowse2, Test1Path, Test2Path
	Loop, 2
	{
		if (hCtrl = hBrowse%A_Index%)
		{
			Gui, +OwnDialogs
			FileSelectFile, path, , %A_ScriptDir%\paths, Select Path/Pattern, AHK Files (*.ahk)
			if (SubStr(path, -3) = ".ahk")
			{
				Test%A_Index%Path := path
				hFont := DllCall("SendMessage", "Ptr", hTest%A_Index%Text, "UInt", 0x31, "Ptr", 0, "Ptr", 0, "Ptr")
				Loop, Parse, % (str := StrReplace(path, A_ScriptDir "\")), "\"
				{
					hDC := DllCall("GetDC", "UInt", hTest%A_Index%Text)
					hFold := DllCall("SelectObject", "UInt", hDC, "UInt", hFont)
					DllCall("GetTextExtentPoint32", "UInt", hDC, "Str", line := ((p := InStr(str, "\", , , A_Index)-1) > 0) ? SubStr(str, 1, p) : str, "Int", StrLen(line), "Int64P", nSize)
					DllCall("SelectObject", "UInt", hDC, "UInt", hFold)
					DllCall("ReleaseDC", "UInt", hTest%A_Index%Text, "UInt", hDC)

					if ((nSize & 0xffffffff) > 174)
					{
						str := SubStr(str, 1, InStr(str, "\", , , A_Index-1)-1) "`n" SubStr(str, InStr(str, "\", , , A_Index-1)), nl := 1
						break
					}
				}
				GuiControl, , % hTest%A_Index%Text, % str
				GuiControl, MoveDraw, % hTest%A_Index%Text, % "y" (((nl = 1) ? 50 : 56) + 32 * A_Index) " h" ((nl = 1) ? 28 : 14)
			}
			else if path
				msgbox, 0x40030, Select Path/Pattern, You must select an .ahk file!, 20
		}
	}
}
nm_saveAdvanced(){
	global
	for k,v in {"ssDebugging":"Status"}
	{
		GuiControlGet, temp, , %k%
		if (temp != "")
		{
			GuiControlGet, %k%
			IniWrite, % %k%, settings\nm_config.ini, %v%, %k%
		}
	}
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 7, ssDebugging
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
}
nm_testButton(){ ;~~ lines 3464 and 3465 have the same change as 14156
	global
	local Test1:="", Test2:="", file
	GuiControlGet, Test1Check
	GuiControlGet, Test2Check
	GuiControlGet, TestCount
	GuiControlGet, TestInfinite
	GuiControlGet, TestReset
	GuiControlGet, TestMsgBox
	Gui, +OwnDialogs

	if !GetRobloxHWND()
	{
		msgbox, 0x40030, Test Paths/Patterns, You must have Bee Swarm Simulator open to use this!, 20
		return 0
	}

	if ((Test1Check = 1) || (Test2Check = 1))
	{
		Loop, 2
		{
			if (Test%A_Index%Check = 1)
			{
				if (SubStr(Test%A_Index%Path, -3) = ".ahk")
					file := FileOpen(Test%A_Index%Path, "r"), Test%A_Index% := file.Read(), file.Close()
				else
				{
					msgbox, 0x40030, Test Paths/Patterns, Test Path %A_Index% is enabled but not valid!, 20
					return 0
				}
			}
		}
	}
	else
	{
		msgbox, 0x40030, Test Paths/Patterns, No paths were selected for testing!, 20
		return 0
	}

	script := "
	(Join`r`n
	#NoEnv
	#NoTrayIcon
	#SingleInstance Force
	#Requires AutoHotkey v1.1.36.01+
	SetBatchLines -1

	TCFBKey:=FwdKey:=""" FwdKey """
	AFCFBKey:=LeftKey:=""" LeftKey """
	TCLRKey:=BackKey:=""" BackKey """
	AFCLRKey:=RightKey:=""" RightKey """
	RotLeft:=""" RotLeft """
	RotRight:=""" RotRight """
	RotUp:=""" RotUp """
	RotDown:=""" RotDown """
	ZoomIn:=""" ZoomIn """
	ZoomOut:=""" ZoomOut """
	SC_E:=""" SC_E """
	SC_R:=""" SC_R """
	SC_L:=""" SC_L """
	SC_Esc:=""" SC_Esc """
	SC_Enter:=""" SC_Enter """
	SC_LShift:=""" SC_LShift """
	SC_Space:=""" SC_Space """
	SC_1:=""" SC_1 """
	HiveSlot:=""" HiveSlot """
	MoveMethod:=""" MoveMethod """
	HiveBees:=""" HiveBees """
	KeyDelay:=""" KeyDelay """

	paths := {}, patterns := {}

	" (Test1 ? (StrReplace(StrReplace(Test1,";gotoramp","nm_gotoramp()"),";gotocannon","nm_gotocannon()") "`r`nTest1 := nm_ImportPath()") : "") "
	" (Test2 ? (StrReplace(StrReplace(Test2,";gotoramp","nm_gotoramp()"),";gotocannon","nm_gotocannon()") "`r`nTest2 := nm_ImportPath()") : "") "

	nm_ImportPath()
	{
		global paths, patterns
		for k,v in paths
			return v, paths.Delete(k)
		for k,v in patterns
			return v, patterns.Delete(k)
	}

	script := ""
	(LTrim Join``r``n
	#NoEnv
	#SingleInstance, Off
	SendMode Input
	SetBatchLines -1
	Process, Priority, , AboveNormal
	#KeyHistory 0
	ListLines, Off
	OnExit(""""ExitFunc"""")
	CoordMode, Mouse, Screen

	#Include %A_ScriptDir%\lib
	#Include Gdip_All.ahk
	#Include Gdip_ImageSearch.ahk
	#Include HyperSleep.ahk
	#Include Walk.ahk

	movespeed := " MoveSpeedNum "
	hasty_guard := (Mod(movespeed*10, 11) = 0) ? 1 : 0
	base_movespeed := movespeed / (hasty_guard ? 1.1 : 1)
	gifted_hasty := ((Mod(base_movespeed*10, 12) = 0) && base_movespeed != 18 && base_movespeed != 24 && base_movespeed != 30) ? 1 : 0
	base_movespeed /= (gifted_hasty ? 1.2 : 1)

	Loop" ((TestInfinite = 0) ? (", " TestCount) : "") "
	{
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, """"ahk_id """" GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		" ((TestMsgBox = 1) ? "msgbox, 0x40044, Test Paths/Patterns, % """"Start Cycle: """" A_Index """"````r````nContinue?""""`r`n`t`tIfMsgBox, No`r`n`t`tExitApp" : "tooltip % """"Testing````nCycle: """" A_Index") "
		" ((TestReset = 1) ? "nm_reset()" : "") "
		" ((NewWalk = 1) ? """ Test1 """ : (""" RegExReplace(Test1, ""im)Walk\((?<param>.+?)(?:\,|\)(?=[^()]*(?:\(|$)))(?:.*\))?"", ""HyperSleep(2000/9*"" round(18/" MoveSpeedNum ", 2) ""*(${param}))"") """)) "
		" ((NewWalk = 1) ? """ Test2 """ : (""" RegExReplace(Test2, ""im)Walk\((?<param>.+?)(?:\,|\)(?=[^()]*(?:\(|$)))(?:.*\))?"", ""HyperSleep(2000/9*"" round(18/" MoveSpeedNum ", 2) ""*(${param}))"") """)) "
	}
	msgbox, 0x40040, Test Paths/Patterns, Test Complete!
	ExitApp

	F16::
	if A_IsPaused
	{
		for k,v in ["""""" LeftKey """""", """""" RightKey """""", """""" FwdKey """""", """""" BackKey """""", """""" SC_Space """""", """"LButton"""", """"RButton"""", """""" SC_E """"""]
			if %v%state
				Send % """"{"""" v """" down}""""
	}
	else
	{
		for k,v in ["""""" LeftKey """""", """""" RightKey """""", """""" FwdKey """""", """""" BackKey """""", """""" SC_Space """""", """"LButton"""", """"RButton"""", """""" SC_E """"""]
		{
			%v%state := GetKeyState(v)
			Send % """"{"""" v """" up}""""
		}
	}
	Pause, Toggle, 1
	return

	nm_gotoramp()
	{
		"" nm_Walk(6, FwdKey) ""
		"" nm_Walk(8.35*HiveSlot+1, RightKey) ""
	}
	nm_gotocannon()
	{
		pBMCannon := Gdip_BitmapFromBase64(""""iVBORw0KGgoAAAANSUhEUgAAABsAAAAMAQMAAACpyVQ1AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEdJREFUeAEBPADD/wDAAGBgAMAAYGAA/gBgYAD+AGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYDdgEn1l8cC/AAAAAElFTkSuQmCC"""")
		Loop, 10
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, """"ahk_id """" GetRobloxHWND())
			MouseMove, windowX+350, windowY+100
			Send {"" SC_Space "" down}
			Sleep, 100
			Send {"" SC_Space "" up}{"" RightKey "" down}

			DllCall(""""GetSystemTimeAsFileTime"""",""""int64p"""",s)
			n := s, f := s+100000000, success := 0
			while (n < f)
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 """"|"""" windowY """"|400|125"""")
				if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
				{
					success := 1, Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				DllCall(""""GetSystemTimeAsFileTime"""",""""int64p"""",n)
			}
			Send {"" RightKey "" up}

			if (success = 1)
			{
				Loop, 10
				{
					if (A_Index = 10)
					{
						success := 0
						break
					}
					Sleep, 500
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 """"|"""" windowY """"|400|125"""")
					if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
					{
						Gdip_DisposeImage(pBMScreen)
						break 2
					}
					else
					{
						"" nm_Walk(1.5, LeftKey) ""
					}
					Gdip_DisposeImage(pBMScreen)
				}
			}

			if (success = 0)
			{
				nm_reset()
				nm_gotoramp()
			}
		}
		Gdip_DisposeImage(pBMCannon)
	}
	nm_reset()
	{
		pBMH1 := Gdip_CreateBitmap(240,3), G := Gdip_GraphicsFromImage(pBMH1), Gdip_GraphicsClear(G,0xff867018), Gdip_DeleteGraphics(G)
		pBMH2 := Gdip_CreateBitmap(240,3), G := Gdip_GraphicsFromImage(pBMH2), Gdip_GraphicsClear(G,0xff937d2d), Gdip_DeleteGraphics(G)
		pBMH3 := Gdip_CreateBitmap(240,3), G := Gdip_GraphicsFromImage(pBMH3), Gdip_GraphicsClear(G,0xff8e7d4d), Gdip_DeleteGraphics(G)
		pBMR := Gdip_CreateBitmap(20,1), G := Gdip_GraphicsFromImage(pBMR), Gdip_GraphicsClear(G,0xffa7a7a7), Gdip_DeleteGraphics(G)
		success := 0
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, """"ahk_id """" GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		Loop, 10
		{
			WinActivate, Roblox
			SetKeyDelay, 250+"" KeyDelay ""
			SendEvent {"" SC_Esc ""}{"" SC_R ""}{"" SC_Enter ""}
			SetKeyDelay, 100+"" KeyDelay ""
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep, 250
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, """"ahk_id """" GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-100 """"|"""" windowY """"|100|32"""")
				n += (Gdip_ImageSearch(pBMScreen, pBMR, , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep, 1000
			Send {"" RotUp "" 4}
			SendEvent {"" ZoomOut "" 8}
			SetKeyDelay, 10
			Sleep, 500
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, """"ahk_id """" GetRobloxHWND())
			Loop, 4
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//4 """"|"""" windowY+3*windowHeight//4 """"|"""" windowWidth//2 """"|"""" windowHeight//4)
				if ((Gdip_ImageSearch(pBMScreen, pBMH1, , , , , , 20) = 1) || (Gdip_ImageSearch(pBMScreen, pBMH2, , , , , , 20) = 1) || (Gdip_ImageSearch(pBMScreen, pBMH3, , , , , , 20) = 1))
				{
					Send {"" RotRight "" 4}{"" RotDown "" 4}
					success := 1
					break 2
				}
				Send {"" RotRight "" 4}
				Sleep, 250
			}
		}
		Gdip_DisposeImage(pBMH1), Gdip_DisposeImage(pBMH2), Gdip_DisposeImage(pBMH3)
		if (success = 0)
		{
			msgbox, 0x40034, Test Paths/Patterns, Reset Failed!````r````nTest has been aborted.
			ExitApp
		}
	}
	GetRobloxHWND()
	{
		if (hwnd := WinExist(""""Roblox ahk_exe RobloxPlayerBeta.exe""""))
			return hwnd
		else if (WinExist(""""Roblox ahk_exe ApplicationFrameHost.exe""""))
		{
			ControlGet, hwnd, Hwnd, , ApplicationFrameInputSinkWindow1
			return hwnd
		}
		else
			return 0
	}
	ExitFunc()
	{
		global pToken
		Send {"" LeftKey "" up}{"" RightKey "" up}{"" FwdKey "" up}{"" BackKey "" up}{"" SC_Space "" up}{F14 up}{"" SC_E "" up}
		Gdip_Shutdown(pToken)
	}
	`)""

	shell := ComObjCreate(""WScript.Shell"")
    exec := shell.Exec(""" exe_path64 " /script /f *"")
    exec.StdIn.Write(script), exec.StdIn.Close()
	ExitApp

	nm_Walk(tiles, MoveKey1, MoveKey2:=0)
	{
		return ""
		(LTrim Join``r``n
		Send {"" MoveKey1 "" down}"" (MoveKey2 ? ""{"" MoveKey2 "" down}"" : """") ""
		Walk("" tiles "")
		Send {"" MoveKey1 "" up}"" (MoveKey2 ? ""{"" MoveKey2 "" up}"" : """") ""
		`)""
	}
	)"

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path64 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_setState(newState){
	global state
	/*
	global disableDayOrNight
	if (newState="Traveling") {
		disableDayOrNight:=1
		GuiControl, Text, TimeofDay, Travel
	}
	else
		disableDayOrNight:=0
	*/
	state:=newState
	GuiControl, text, state, %state%
}
nm_setObjective(newObjective){
	global objective
	objective:=newObjective
	GuiControl, text, objective, %objective%
}
nm_setStats(){
	global
	static newline:="`n"
	local rundelta:=0, gatherdelta:=0, convertdelta:=0, TotalStatsString, SessionStatsString

	if (MacroState=2) {
		rundelta:=(nowUnix()-MacroStartTime)
		if(GatherStartTime)
			gatherdelta:=(nowUnix()-GatherStartTime)
		if(ConvertStartTime)
			convertdelta:=(nowUnix()-ConvertStartTime)
	}

	TotalStatsString:="Runtime: " nm_TimeFromSeconds(TotalRuntime+rundelta)
		. newline "Gather: " nm_TimeFromSeconds(TotalGatherTime+gatherdelta)
		. newline "Convert: " nm_TimeFromSeconds(TotalConvertTime+convertdelta)
		. newline "ViciousKills=" TotalViciousKills
		. newline "BossKills=" TotalBossKills
		. newline "BugKills=" TotalBugKills
		. newline "PlantersCollected=" TotalPlantersCollected
		. newline "QuestsComplete=" TotalQuestsComplete
		. newline "Disconnects=" TotalDisconnects

	SessionStatsString:="Runtime: " nm_TimeFromSeconds(SessionRuntime+rundelta)
		. newline "Gather: " nm_TimeFromSeconds(SessionGatherTime+gatherdelta)
		. newline "Convert: " nm_TimeFromSeconds(SessionConvertTime+convertdelta)
		. newline "ViciousKills=" SessionViciousKills
		. newline "BossKills=" SessionBossKills
		. newline "BugKills=" SessionBugKills
		. newline "PlantersCollected=" SessionPlantersCollected
		. newline "QuestsComplete=" SessionQuestsComplete
		. newline "Disconnects=" SessionDisconnects

	GuiControl, , TotalStats, %TotalStatsString%
	GuiControl, , SessionStats, %SessionStatsString%
}
nm_TimeFromSeconds(secs)
{
	VarSetCapacity(dur,128), DllCall("GetDurationFormatEx","Ptr",0,"UInt",0,"Ptr",0,"Int64",secs*10000000,"WStr","hh:mm:ss","WStr",dur,"Int",128)
    return dur
}
nm_DurationFromSeconds(secs)
{
	VarSetCapacity(dur,128), DllCall("GetDurationFormatEx","Ptr",0,"UInt",0,"Ptr",0,"Int64",secs*10000000,"WStr",((secs >= 3600) ? "h'h' m" : "") ((secs >= 60) ? "m'm' s" : "") "s's'","WStr",dur,"Int",128)
    return dur
}
nm_setStatus(newState:=0, newObjective:=0){
	global state, objective, StatusLogReverse, DebugLogEnabled
	static statuslog:=[], status_number:=0

	if ((DebugLogEnabled = 1) && (statuslog.Length() = 0)) {
		txt := FileOpen("settings\debug_log.txt", "r")
		while ((c < 15) && !f && (A_Index < 100))
			txt.Seek(- (((p := (A_Index * 128)) > txt.Length) ? (f := txt.Length) : p), 2), log := txt.Read(), StrReplace(log, "`n", , c)
		txt.Close()
		Loop, Parse, % SubStr(RTrim(log, "`r`n"), f ? 1 : InStr(log, "`n", , , Max(c - 15, 1)) + 1), `n, `r
			statuslog.Push(SubStr(A_LoopField, 8))
	}

	if (newState != "Detected") {
		if(newState)
			state:=newState
		if(newObjective)
			objective:=newObjective
	}
	stateString := ((newState ? newState : state) . ": " . (newObjective ? newObjective : objective))

	statuslog.Push("[" A_Hour ":" A_Min ":" A_Sec "] " (InStr(stateString, "`n") ? SubStr(stateString, 1, InStr(stateString, "`n")-1) : stateString))
	statuslog.RemoveAt(1,(statuslog.MaxIndex()>15) ? statuslog.MaxIndex()-15 : 0), len:=statuslog.MaxIndex()
	statuslogtext:=""
	for k,v in statuslog
		i := ((StatusLogReverse) ? len+1-k : k), statuslogtext .= (((A_Index>1) ? "`r`n" : "") statuslog[i])

	GuiControl, , state, %stateString%
	GuiControl, , statuslog, %statuslogtext%

	; update status
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
	if (newState != "Detected") {
		num := ((state = "Gathering") && !InStr(objective, "Ended")) ? 1 : ((state = "Converting") && !InStr(objective, "Refreshed") && !InStr(objective, "Emptied")) ? 2 : 0
		if (num != status_number) {
			status_number := num
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey")
				PostMessage, 0x5554, status_number, 60 * A_Min + A_Sec
			if WinExist("background.ahk ahk_class AutoHotkey")
				PostMessage, 0x5555, status_number, nowUnix()
		}
	}
	if WinExist("Status.ahk ahk_class AutoHotkey")
		SendMessage, 0xC2, 0, "[" A_MM "/" A_DD "][" A_Hour ":" A_Min ":" A_Sec "] " stateString, , , , , , 2000
	DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
}
nm_StatusLogReverseCheck(){
	global StatusLogReverse
	GuiControlGet, StatusLogReverse
	GuiControl, Disable, StatusLogReverse
	IniWrite, %StatusLogReverse%, settings\nm_config.ini, Status, StatusLogReverse
	if (StatusLogReverse) {
		nm_setStatus("GUI", "Status Log Reversed")
	} else {
		nm_setStatus("GUI", "Status Log NOT Reversed")
	}
	GuiControl, Enable, StatusLogReverse
}
nm_FieldSelect1(){
	global FieldName1, CurrentFieldNum
	global CurrentField
	GuiControlGet, FieldName1
	IniWrite, %FieldName1%, settings\nm_config.ini, Gather, FieldName1
	CurrentFieldNum:=1
	IniWrite, %CurrentFieldNum%, settings\nm_config.ini, Gather, CurrentFieldNum
	GuiControl,,CurrentField, %FieldName1%
	CurrentField:=FieldName1
	nm_FieldDefaults(1)
	nm_WebhookEasterEgg()
}
nm_TabGatherLock(){
	GuiControl, Disable, FieldName1
	GuiControl, Disable, FieldPattern1
	GuiControl, Disable, FieldPatternSize1
	GuiControl, Disable, FieldPatternReps1
	GuiControl, Disable, FieldPatternShift1
	GuiControl, Disable, FieldPatternInvertFB1
	GuiControl, Disable, FieldPatternInvertLR1
	GuiControl, Disable, FieldUntilMins1
	GuiControl, Disable, FieldUntilPack1
	GuiControl, Disable, FieldReturnType1
	GuiControl, Disable, FieldSprinklerLoc1
	GuiControl, Disable, FieldSprinklerDist1
	GuiControl, Disable, FieldRotateDirection1
	GuiControl, Disable, FieldRotateTimes1
	GuiControl, Disable, FieldDriftCheck1
	GuiControl, Disable, FieldName2
	GuiControl, Disable, FieldPattern2
	GuiControl, Disable, FieldPatternSize2
	GuiControl, Disable, FieldPatternReps2
	GuiControl, Disable, FieldPatternShift2
	GuiControl, Disable, FieldPatternInvertFB2
	GuiControl, Disable, FieldPatternInvertLR2
	GuiControl, Disable, FieldUntilMins2
	GuiControl, Disable, FieldUntilPack2
	GuiControl, Disable, FieldReturnType2
	GuiControl, Disable, FieldSprinklerLoc2
	GuiControl, Disable, FieldSprinklerDist2
	GuiControl, Disable, FieldRotateDirection2
	GuiControl, Disable, FieldRotateTimes2
	GuiControl, Disable, FieldDriftCheck2
	GuiControl, Disable, FieldName3
	GuiControl, Disable, FieldPattern3
	GuiControl, Disable, FieldPatternSize3
	GuiControl, Disable, FieldPatternReps3
	GuiControl, Disable, FieldPatternShift3
	GuiControl, Disable, FieldPatternInvertFB3
	GuiControl, Disable, FieldPatternInvertLR3
	GuiControl, Disable, FieldUntilMins3
	GuiControl, Disable, FieldUntilPack3
	GuiControl, Disable, FieldReturnType3
	GuiControl, Disable, FieldSprinklerLoc3
	GuiControl, Disable, FieldSprinklerDist3
	GuiControl, Disable, FieldRotateDirection3
	GuiControl, Disable, FieldRotateTimes3
	GuiControl, Disable, FieldDriftCheck3
}
nm_FieldUnlock(){
	global FieldName2, FieldName3
	GuiControl, Enable, FieldName1
	GuiControl, Enable, FieldName2
	GuiControl, Enable, FieldPattern1
	GuiControl, Enable, FieldPatternSize1
	GuiControl, Enable, FieldPatternReps1
	GuiControl, Enable, FieldPatternShift1
	GuiControl, Enable, FieldPatternInvertFB1
	GuiControl, Enable, FieldPatternInvertLR1
	GuiControl, Enable, FieldUntilMins1
	GuiControl, Enable, FieldUntilPack1
	GuiControl, Enable, FieldReturnType1
	GuiControl, Enable, FieldSprinklerLoc1
	GuiControl, Enable, FieldSprinklerDist1
	GuiControl, Enable, FieldRotateDirection1
	GuiControl, Enable, FieldRotateTimes1
	GuiControl, Enable, FieldDriftCheck1
	if(FieldName2!="none"){
		GuiControl, Enable, FieldName3
		GuiControl, Enable, FieldPattern2
		GuiControl, Enable, FieldPatternSize2
		GuiControl, Enable, FieldPatternReps2
		GuiControl, Enable, FieldPatternShift2
		GuiControl, Enable, FieldPatternInvertFB2
		GuiControl, Enable, FieldPatternInvertLR2
		GuiControl, Enable, FieldUntilMins2
		GuiControl, Enable, FieldUntilPack2
		GuiControl, Enable, FieldReturnType2
		GuiControl, Enable, FieldSprinklerLoc2
		GuiControl, Enable, FieldSprinklerDist2
		GuiControl, Enable, FieldRotateDirection2
		GuiControl, Enable, FieldRotateTimes2
		GuiControl, Enable, FieldDriftCheck2
	}
	if(FieldName3!="none"){
		GuiControl, Enable, FieldPattern3
		GuiControl, Enable, FieldPatternSize3
		GuiControl, Enable, FieldPatternReps3
		GuiControl, Enable, FieldPatternShift3
		GuiControl, Enable, FieldPatternInvertFB3
		GuiControl, Enable, FieldPatternInvertLR3
		GuiControl, Enable, FieldUntilMins3
		GuiControl, Enable, FieldUntilPack3
		GuiControl, Enable, FieldReturnType3
		GuiControl, Enable, FieldSprinklerLoc3
		GuiControl, Enable, FieldSprinklerDist3
		GuiControl, Enable, FieldRotateDirection3
		GuiControl, Enable, FieldRotateTimes3
		GuiControl, Enable, FieldDriftCheck3
	}
}
nm_FieldSelect2(){
	global FieldName2, CurrentField, CurrentFieldNum, bitmaps, hSaveFieldDefault2
	GuiControlGet, FieldName2
	if(FieldName2!="none"){
		GuiControl, Enable, FieldName3
		GuiControl, Enable, FieldPattern2
		GuiControl, Enable, FieldPatternSize2
		GuiControl, Enable, FieldPatternReps2
		GuiControl, Enable, FieldPatternShift2
		GuiControl, Enable, FieldPatternInvertFB2
		GuiControl, Enable, FieldPatternInvertLR2
		GuiControl, Enable, FieldUntilMins2
		GuiControl, Enable, FieldUntilPack2
		GuiControl, Enable, FieldReturnType2
		GuiControl, Enable, FieldSprinklerLoc2
		GuiControl, Enable, FieldSprinklerDist2
		GuiControl, Enable, FieldRotateDirection2
		GuiControl, Enable, FieldRotateTimes2
		GuiControl, Enable, FieldDriftCheck2
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		GuiControl, , % hSaveFieldDefault2, HBITMAP:*%hBM%
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		GuiControlGet, FieldName1
		CurrentFieldNum:=1
		IniWrite, %CurrentFieldNum%, settings\nm_config.ini, Gather, CurrentFieldNum
		GuiControl,,CurrentField, %FieldName1%
		CurrentField:=FieldName1
		GuiControl, Disable, FieldPattern2
		GuiControl, Disable, FieldPatternSize2
		GuiControl, Disable, FieldPatternReps2
		GuiControl, Disable, FieldPatternShift2
		GuiControl, Disable, FieldPatternInvertFB2
		GuiControl, Disable, FieldPatternInvertLR2
		GuiControl, Disable, FieldUntilMins2
		GuiControl, Disable, FieldUntilPack2
		GuiControl, Disable, FieldReturnType2
		GuiControl, Disable, FieldSprinklerLoc2
		GuiControl, Disable, FieldSprinklerDist2
		GuiControl, Disable, FieldRotateDirection2
		GuiControl, Disable, FieldRotateTimes2
		GuiControl, Disable, FieldDriftCheck2
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		GuiControl, , % hSaveFieldDefault2, HBITMAP:*%hBM%
		DllCall("DeleteObject", "ptr", hBM)
		GuiControl, ChooseString, FieldName3, None
		GuiControl, Disable, FieldName3
		nm_fieldSelect3()
	}
	nm_FieldDefaults(2)
	IniWrite, %FieldName2%, settings\nm_config.ini, Gather, FieldName2
	nm_WebhookEasterEgg()
}
nm_FieldSelect3(){
	global FieldName3, CurrentField, CurrentFieldNum, bitmaps, hSaveFieldDefault3
	GuiControlGet, FieldName3
	if(FieldName3!="none"){
		GuiControl, Enable, FieldPattern3
		GuiControl, Enable, FieldPatternSize3
		GuiControl, Enable, FieldPatternReps3
		GuiControl, Enable, FieldPatternShift3
		GuiControl, Enable, FieldPatternInvertFB3
		GuiControl, Enable, FieldPatternInvertLR3
		GuiControl, Enable, FieldUntilMins3
		GuiControl, Enable, FieldUntilPack3
		GuiControl, Enable, FieldReturnType3
		GuiControl, Enable, FieldSprinklerLoc3
		GuiControl, Enable, FieldSprinklerDist3
		GuiControl, Enable, FieldRotateDirection3
		GuiControl, Enable, FieldRotateTimes3
		GuiControl, Enable, FieldDriftCheck3
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		GuiControl, , % hSaveFieldDefault3, HBITMAP:*%hBM%
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		GuiControlGet, FieldName1
		CurrentFieldNum:=1
		IniWrite, %CurrentFieldNum%, settings\nm_config.ini, Gather, CurrentFieldNum
		GuiControl,,CurrentField, %FieldName1%
		CurrentField:=FieldName1
		GuiControl, Disable, FieldPattern3
		GuiControl, Disable, FieldPatternSize3
		GuiControl, Disable, FieldPatternReps3
		GuiControl, Disable, FieldPatternShift3
		GuiControl, Disable, FieldPatternInvertFB3
		GuiControl, Disable, FieldPatternInvertLR3
		GuiControl, Disable, FieldUntilMins3
		GuiControl, Disable, FieldUntilPack3
		GuiControl, Disable, FieldReturnType3
		GuiControl, Disable, FieldSprinklerLoc3
		GuiControl, Disable, FieldSprinklerDist3
		GuiControl, Disable, FieldRotateDirection3
		GuiControl, Disable, FieldRotateTimes3
		GuiControl, Disable, FieldDriftCheck3
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		GuiControl, , % hSaveFieldDefault3, HBITMAP:*%hBM%
		DllCall("DeleteObject", "ptr", hBM)
	}
	nm_FieldDefaults(3)
	IniWrite, %FieldName3%, settings\nm_config.ini, Gather, FieldName3
	nm_WebhookEasterEgg()
}
nm_FieldDefaults(num){
	global FieldDefault, FieldPattern1, FieldPattern2, FieldPattern3, FieldPatternSize1, FieldPatternSize2, FieldPatternSize3, FieldPatternReps1, FieldPatternReps2, FieldPatternReps3, FieldPatternShift1, FieldPatternShift2, FieldPatternShift3, FieldPatternInvertFB1, FieldPatternInvertFB2, FieldPatternInvertFB3, FieldPatternInvertLR1, FieldPatternInvertLR2, FieldPatternInvertLR3, FieldUntilMins1, FieldUntilMins2, FieldUntilMins3, FieldUntilPack1, FieldUntilPack2, FieldUntilPack3, FieldReturnType1, FieldReturnType2, FieldReturnType3, FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3, FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3, FieldRotateDirection1, FieldRotateDirection2, FieldRotateDirection3, FieldRotateTimes1, FieldRotateTimes2, FieldRotateTimes3, FieldDriftCheck1, FieldDriftCheck2, FieldDriftCheck3, patternlist, disableSave:=1

	static patternsizelist:="|XS|S|M|L|XL|"
		, patternrepslist:="|1|2|3|4|5|6|7|8|9|"
		, untilpacklist:="|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|"
		, returntypelist:="|Walk|Reset|"
		, sprinklerloclist:="|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|"
		, sprinklerdistlist:="|1|2|3|4|5|6|7|8|9|10|"
		, rotatedirectionlist:="|None|Left|Right|"
		, rotatetimeslist:="|1|2|3|4|"

	GuiControlGet, FieldName%num%
	if(FieldName%num%="none") {
		FieldPattern%num%:="Lines"
		FieldPatternSize%num%:="M"
		FieldPatternReps%num%:=3
		FieldPatternShift%num%:=0
		FieldPatternInvertFB%num%:=0
		FieldPatternInvertLR%num%:=0
		FieldUntilMins%num%:=15
		FieldUntilPack%num%:=95
		FieldReturnType%num%:="Walk"
		FieldSprinklerLoc%num%:="Center"
		FieldSprinklerDist%num%:=10
		FieldRotateDirection%num%:="None"
		FieldRotateTimes%num%:=1
		FieldDriftCheck%num%:=1
	} else {
		FieldPattern%num%:=FieldDefault[FieldName%num%]["pattern"]
		FieldPatternSize%num%:=FieldDefault[FieldName%num%]["size"]
		FieldPatternReps%num%:=FieldDefault[FieldName%num%]["width"]
		FieldPatternShift%num%:=FieldDefault[FieldName%num%]["shiftlock"]
		FieldPatternInvertFB%num%:=FieldDefault[FieldName%num%]["invertFB"]
		FieldPatternInvertLR%num%:=FieldDefault[FieldName%num%]["invertLR"]
		FieldUntilMins%num%:=FieldDefault[FieldName%num%]["gathertime"]
		FieldUntilPack%num%:=FieldDefault[FieldName%num%]["percent"]
		FieldReturnType%num%:=FieldDefault[FieldName%num%]["convert"]
		FieldSprinklerLoc%num%:=FieldDefault[FieldName%num%]["sprinkler"]
		FieldSprinklerDist%num%:=FieldDefault[FieldName%num%]["distance"]
		FieldRotateDirection%num%:=FieldDefault[FieldName%num%]["camera"]
		FieldRotateTimes%num%:=FieldDefault[FieldName%num%]["turns"]
		FieldDriftCheck%num%:=FieldDefault[FieldName%num%]["drift"]
	}
	GuiControl, , FieldPattern%num%, % StrReplace(patternlist "Stationary|", "|" FieldPattern%num% "|", "|" FieldPattern%num% "||")
	GuiControl, , FieldPatternSize%num%, % StrReplace(patternsizelist, "|" FieldPatternSize%num% "|", "|" FieldPatternSize%num% "||")
	GuiControl, , FieldPatternReps%num%, % StrReplace(patternrepslist, "|" FieldPatternReps%num% "|", "|" FieldPatternReps%num% "||")
	GuiControl, , FieldPatternShift%num%, % FieldPatternShift%num%
	GuiControl, , FieldPatternInvertFB%num%, % FieldPatternInvertFB%num%
	GuiControl, , FieldPatternInvertLR%num%, % FieldPatternInvertLR%num%
	GuiControl, , FieldUntilMins%num%, % FieldUntilMins%num%
	GuiControl, , FieldUntilPack%num%, % StrReplace(untilpacklist, "|" FieldUntilPack%num% "|", "|" FieldUntilPack%num% "||")
	GuiControl, , FieldReturnType%num%, % StrReplace(returntypelist, "|" FieldReturnType%num% "|", "|" FieldReturnType%num% "||")
	GuiControl, , FieldSprinklerLoc%num%, % StrReplace(sprinklerloclist, "|" FieldSprinklerLoc%num% "|", "|" FieldSprinklerLoc%num% "||")
	GuiControl, , FieldSprinklerDist%num%, % StrReplace(sprinklerdistlist, "|" FieldSprinklerDist%num% "|", "|" FieldSprinklerDist%num% "||")
	GuiControl, , FieldRotateDirection%num%, % StrReplace(rotatedirectionlist, "|" FieldRotateDirection%num% "|", "|" FieldRotateDirection%num% "||")
	GuiControl, , FieldRotateTimes%num%, % StrReplace(rotatetimeslist, "|" FieldRotateTimes%num% "|", "|" FieldRotateTimes%num% "||")
	GuiControl, , FieldDriftCheck%num%, % FieldDriftCheck%num%
	IniWrite, % FieldPattern%num%, settings\nm_config.ini, Gather, FieldPattern%num%
	IniWrite, % FieldPatternSize%num%, settings\nm_config.ini, Gather, FieldPatternSize%num%
	IniWrite, % FieldPatternReps%num%, settings\nm_config.ini, Gather, FieldPatternReps%num%
	IniWrite, % FieldPatternShift%num%, settings\nm_config.ini, Gather, FieldPatternShift%num%
	IniWrite, % FieldPatternInvertFB%num%, settings\nm_config.ini, Gather, FieldPatternInvertFB%num%
	IniWrite, % FieldPatternInvertLR%num%, settings\nm_config.ini, Gather, FieldPatternInvertLR%num%
	IniWrite, % FieldUntilMins%num%, settings\nm_config.ini, Gather, FieldUntilMins%num%
	IniWrite, % FieldUntilPack%num%, settings\nm_config.ini, Gather, FieldUntilPack%num%
	IniWrite, % FieldReturnType%num%, settings\nm_config.ini, Gather, FieldReturnType%num%
	IniWrite, % FieldSprinklerLoc%num%, settings\nm_config.ini, Gather, FieldSprinklerLoc%num%
	IniWrite, % FieldSprinklerDist%num%, settings\nm_config.ini, Gather, FieldSprinklerDist%num%
	IniWrite, % FieldRotateDirection%num%, settings\nm_config.ini, Gather, FieldRotateDirection%num%
	IniWrite, % FieldRotateTimes%num%, settings\nm_config.ini, Gather, FieldRotateTimes%num%
	IniWrite, % FieldDriftCheck%num%, settings\nm_config.ini, Gather, FieldDriftCheck%num%
	disableSave:=0
}
nm_SaveFieldDefault(hCtrl){
	global
	local i,k,v
	Gui, +OwnDialogs
	Loop, 3
	{
		if ((hCtrl = hSaveFieldDefault%A_Index%) && (FieldName%A_Index% != "None"))
		{
			i := A_Index
			msgbox, 0x40044, Change Field Defaults, % "Update " FieldName%i% " default settings with the currently selected settings? These will become the default settings when you change to this field.`n`nThe macro will use the updated settings when gathering for Quests/Planters."
			IfMsgBox, Yes
			{
				FieldDefault[FieldName%i%]["pattern"]:=FieldPattern%i%
				FieldDefault[FieldName%i%]["size"]:=FieldPatternSize%i%
				FieldDefault[FieldName%i%]["width"]:=FieldPatternReps%i%
				FieldDefault[FieldName%i%]["shiftlock"]:=FieldPatternShift%i%
				FieldDefault[FieldName%i%]["invertFB"]:=FieldPatternInvertFB%i%
				FieldDefault[FieldName%i%]["invertLR"]:=FieldPatternInvertLR%i%
				FieldDefault[FieldName%i%]["gathertime"]:=FieldUntilMins%i%
				FieldDefault[FieldName%i%]["percent"]:=FieldUntilPack%i%
				FieldDefault[FieldName%i%]["convert"]:=FieldReturnType%i%
				FieldDefault[FieldName%i%]["sprinkler"]:=FieldSprinklerLoc%i%
				FieldDefault[FieldName%i%]["distance"]:=FieldSprinklerDist%i%
				FieldDefault[FieldName%i%]["camera"]:=FieldRotateDirection%i%
				FieldDefault[FieldName%i%]["turns"]:=FieldRotateTimes%i%
				FieldDefault[FieldName%i%]["drift"]:=FieldDriftCheck%i%
				for k,v in FieldDefault[FieldName%i%]
					IniWrite, %v%, settings\field_config.ini, % FieldName%i%, %k%
			}
		}
	}
}
nm_currentFieldUp(){
	global CurrentField
	global CurrentFieldNum
	GuiControlGet FieldName1
	GuiControlGet FieldName2
	GuiControlGet FieldName3
	if(CurrentFieldNum=1) { ;wrap around to bottom
		if(FieldName3!="None") {
			CurrentFieldNum:=3
			CurrentField:=FieldName3
		} else if (FieldName2!="None") {
			CurrentFieldNum:=2
			CurrentField:=FieldName2
		} else {
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=2) {
		CurrentFieldNum:=1
		CurrentField:=FieldName1
	} else if(CurrentFieldNum=3) {
		CurrentFieldNum:=2
		CurrentField:=FieldName2
	}
	GuiControl,,CurrentField, %CurrentField%
	IniWrite, %CurrentFieldNum%, settings\nm_config.ini, Gather, CurrentFieldNum
}
nm_currentFieldDown(){
	global CurrentField
	global CurrentFieldNum
	GuiControlGet FieldName1
	GuiControlGet FieldName2
	GuiControlGet FieldName3
	if(CurrentFieldNum=1) {
		if(FieldName2!="None") {
			CurrentFieldNum:=2
			CurrentField:=FieldName2
		} else { ;default to 1
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=2) {
		if(FieldName3!="None") {
			CurrentFieldNum:=3
			CurrentField:=FieldName3
		} else { ;default to 1
			CurrentFieldNum:=1
			CurrentField:=FieldName1
		}
	} else if(CurrentFieldNum=3) {
		CurrentFieldNum:=1
		CurrentField:=FieldName1
	}
	GuiControl,,CurrentField, %CurrentField%
	IniWrite, %CurrentFieldNum%, settings\nm_config.ini, Gather, CurrentFieldNum
}
nm_savePlanters(){
	GuiControlGet PlanterHotkeySlot1
	GuiControlGet PlanterHotkeySlot2
	GuiControlGet PlanterHotkeySlot3
	;GuiControlGet PlanterSelectedName1
	;GuiControlGet PlanterSelectedName2
	;GuiControlGet PlanterSelectedName3
	IniWrite, %PlanterHotkeySlot1%, settings\nm_config.ini, Planters, PlanterHotkeySlot1
	IniWrite, %PlanterHotkeySlot2%, settings\nm_config.ini, Planters, PlanterHotkeySlot2
	IniWrite, %PlanterHotkeySlot3%, settings\nm_config.ini, Planters, PlanterHotkeySlot3
	;IniWrite, %PlanterSelectedName1%, settings\nm_config.ini, Planters, PlanterSelectedName1
	;IniWrite, %PlanterSelectedName2%, settings\nm_config.ini, Planters, PlanterSelectedName2
	;IniWrite, %PlanterSelectedName3%, settings\nm_config.ini, Planters, PlanterSelectedName3
}
nm_plantersPlacedBy1(){
	GuiControlGet, PlanterPlacedBy1
	GuiControlGet PlanterSelectedName1
	if(PlanterPlacedBy1="Inventory") {
		GuiControl, enable, PlanterSelectedName1
		GuiControl, disable, PlanterHotkeySlot1

	} else {
		GuiControl,ChooseString, PlanterSelectedName1, None
		GuiControl, disable, PlanterSelectedName1
		GuiControl, enable, PlanterHotkeySlot1
	}
	if(PlanterSelectedName1="none"){
		GuiControl, ChooseString, PlanterSelectedName1, Automatic
	}
	GuiControlGet PlanterSelectedName1
	if(PlanterSelectedName1="automatic"){
		GuiControl, ChooseString, Planter1Field1, None
		GuiControl, disable, Planter1Field1
		GuiControl, disable, Planter1Until1
		nm_Planter1Field1()
	} else {
		GuiControlGet Planter1Field1
		GuiControl, enable, Planter1Field1
		if(Planter1Field1="none") {
			GuiControl, ChooseString, Planter1Field1, Dandelion
			nm_Planter1Field1()
		}
		GuiControl, enable, Planter1Until1
	}
	IniWrite, %PlanterPlacedBy1%, settings\nm_config.ini, Planters, PlanterPlacedBy1
	IniWrite, %PlanterSelectedName1%, settings\nm_config.ini, Planters, PlanterSelectedName1
}
nm_plantersPlacedBy2(){
	GuiControlGet, PlanterPlacedBy2
	GuiControlGet PlanterSelectedName2
	if(PlanterPlacedBy2="Inventory") {
		GuiControl, enable, PlanterSelectedName2
		GuiControl, disable, PlanterHotkeySlot2

	} else {
		GuiControl,ChooseString, PlanterSelectedName2, None
		GuiControl, disable, PlanterSelectedName2
		GuiControl, enable, PlanterHotkeySlot2
	}
	if(PlanterSelectedName2="none"){
		GuiControl, ChooseString, PlanterSelectedName2, Automatic
	}
	GuiControlGet PlanterSelectedName2
	if(PlanterSelectedName2="automatic"){
		GuiControl, ChooseString, Planter2Field1, None
		GuiControl, disable, Planter2Field1
		GuiControl, disable, Planter2Until1
		nm_Planter2Field1()
	} else {
		GuiControlGet Planter2Field1
		GuiControl, enable, Planter2Field1
		if(Planter2Field1="none") {
			GuiControl, ChooseString, Planter2Field1, Blue Flower
			nm_Planter2Field1()
		}
		GuiControl, enable, Planter2Until1
	}
	IniWrite, %PlanterPlacedBy2%, settings\nm_config.ini, Planters, PlanterPlacedBy2
	IniWrite, %PlanterSelectedName2%, settings\nm_config.ini, Planters, PlanterSelectedName2
}
nm_plantersPlacedBy3(){
	GuiControlGet, PlanterPlacedBy3
	GuiControlGet PlanterSelectedName3
	if(PlanterPlacedBy3="Inventory") {
		GuiControl, enable, PlanterSelectedName3
		GuiControl, disable, PlanterHotkeySlot3

	} else {
		GuiControl,ChooseString, PlanterSelectedName3, None
		GuiControl, disable, PlanterSelectedName3
		GuiControl, enable, PlanterHotkeySlot3
	}
	if(PlanterSelectedName3="none"){
		GuiControl, ChooseString, PlanterSelectedName3, Automatic
	}
	GuiControlGet PlanterSelectedName3
	if(PlanterSelectedName3="automatic"){
		GuiControl, ChooseString, Planter3Field1, None
		GuiControl, disable, Planter3Field1
		GuiControl, disable, Planter3Until1
		nm_Planter3Field1()
	} else {
		GuiControlGet Planter3Field1
		GuiControl, enable, Planter3Field1
		if(Planter3Field1="none") {
			GuiControl, ChooseString, Planter3Field1, Mushroom
			nm_Planter3Field1()
		}
		GuiControl, enable, Planter3Until1
	}
	IniWrite, %PlanterPlacedBy3%, settings\nm_config.ini, Planters, PlanterPlacedBy3
	IniWrite, %PlanterSelectedName3%, settings\nm_config.ini, Planters, PlanterSelectedName3
}
nm_Planter1Field1(){
	GuiControlGet Planter1Field1
	GuiControlGet Planter1Until1
	GuiControlGet PlanterSelectedName1
	if(Planter1Field1="none"){
		if(PlanterSelectedName1!="automatic") {
			GuiControl,ChooseString, Planter1Field1, Dandelion
			GuiControl,enable, Planter1Field2
			GuiControl,enable, Planter1Until2
		} else {
			GuiControl,ChooseString, Planter1Field2, None
			GuiControl,disable, Planter1Field2
			GuiControl,disable, Planter1Until2
		}
	} else {
		GuiControl,enable, Planter1Field2
		GuiControl,enable, Planter1Until2
	}
	nm_Planter1Field2()
	IniWrite, %Planter1Field1%, settings\nm_config.ini, Planters, Planter1Field1
	IniWrite, %Planter1Until1%, settings\nm_config.ini, Planters, Planter1Until1
}
nm_Planter1Field2(){
	GuiControlGet Planter1Field2
	GuiControlGet Planter1Until2
	if(Planter1Field2="none"){
		GuiControl,ChooseString, Planter1Field3, None
		GuiControl,disable, Planter1Field3
		GuiControl,disable, Planter1Until3
		nm_Planter1Field3()
	} else {
		GuiControl,enable, Planter1Field3
		GuiControl,enable, Planter1Until3
	}
	IniWrite, %Planter1Field2%, settings\nm_config.ini, Planters, Planter1Field2
	IniWrite, %Planter1Until2%, settings\nm_config.ini, Planters, Planter1Until2
}
nm_Planter1Field3(){
	GuiControlGet Planter1Field3
	GuiControlGet Planter1Until3
	if(Planter1Field3="none"){
		GuiControl,ChooseString, Planter1Field4, None
		GuiControl,disable, Planter1Field4
		GuiControl,disable, Planter1Until4
		nm_Planter1Field4()
	} else {
		GuiControl,enable, Planter1Field4
		GuiControl,enable, Planter1Until4
	}
	IniWrite, %Planter1Field3%, settings\nm_config.ini, Planters, Planter1Field3
	IniWrite, %Planter1Until3%, settings\nm_config.ini, Planters, Planter1Until3
}
nm_Planter1Field4(){
	GuiControlGet Planter1Field4
	GuiControlGet Planter1Until4
	IniWrite, %Planter1Field4%, settings\nm_config.ini, Planters, Planter1Field4
	IniWrite, %Planter1Until4%, settings\nm_config.ini, Planters, Planter1Until4

}
nm_Planter2Field1(){
	GuiControlGet Planter2Field1
	GuiControlGet Planter2Until1
	GuiControlGet PlanterSelectedName2
	if(Planter2Field1="none"){
		if(PlanterSelectedName2!="automatic") {
			GuiControl,ChooseString, Planter2Field1, BlueFlower
			GuiControl,enable, Planter2Field2
			GuiControl,enable, Planter2Until2
		} else {
			GuiControl,ChooseString, Planter2Field2, None
			GuiControl,disable, Planter2Field2
			GuiControl,disable, Planter2Until2
		}
	} else {
		GuiControl,enable, Planter2Field2
		GuiControl,enable, Planter2Until2
	}
	nm_Planter2Field2()
	IniWrite, %Planter2Field1%, settings\nm_config.ini, Planters, Planter2Field1
	IniWrite, %Planter2Until1%, settings\nm_config.ini, Planters, Planter2Until1
}
nm_Planter2Field2(){
	GuiControlGet Planter2Field2
	GuiControlGet Planter2Until2
	if(Planter2Field2="none"){
		GuiControl,ChooseString, Planter2Field3, None
		GuiControl,disable, Planter2Field3
		GuiControl,disable, Planter2Until3
		nm_Planter2Field3()
	} else {
		GuiControl,enable, Planter1Field3
		GuiControl,enable, Planter1Until3
	}
	IniWrite, %Planter2Field2%, settings\nm_config.ini, Planters, Planter2Field2
	IniWrite, %Planter2Until2%, settings\nm_config.ini, Planters, Planter2Until2
}
nm_Planter2Field3(){
	GuiControlGet Planter2Field3
	GuiControlGet Planter2Until3
	if(Planter2Field3="none"){
		GuiControl,ChooseString, Planter2Field4, None
		GuiControl,disable, Planter2Field4
		GuiControl,disable, Planter2Until4
		nm_Planter2Field4()
	} else {
		GuiControl,enable, Planter2Field4
		GuiControl,enable, Planter2Until4
	}
	IniWrite, %Planter2Field3%, settings\nm_config.ini, Planters, Planter2Field3
	IniWrite, %Planter2Until3%, settings\nm_config.ini, Planters, Planter2Until3
}
nm_Planter2Field4(){
	GuiControlGet Planter2Field4
	GuiControlGet Planter2Until4
	IniWrite, %Planter2Field4%, settings\nm_config.ini, Planters, Planter2Field4
	IniWrite, %Planter2Until4%, settings\nm_config.ini, Planters, Planter2Until4
}
nm_Planter3Field1(){
	GuiControlGet Planter3Field1
	GuiControlGet Planter3Until1
	GuiControlGet PlanterSelectedName3
	if(Planter3Field1="none"){
		if(PlanterSelectedName3!="automatic") {
			GuiControl,ChooseString, Planter3Field1, Mushroom
			GuiControl,enable, Planter3Field2
			GuiControl,enable, Planter3Until2
		} else {
			GuiControl,ChooseString, Planter3Field2, None
			GuiControl,disable, Planter3Field2
			GuiControl,disable, Planter3Until2
		}
	} else {
		GuiControl,enable, Planter3Field2
		GuiControl,enable, Planter3Until2
	}
	nm_Planter3Field2()
	IniWrite, %Planter3Field1%, settings\nm_config.ini, Planters, Planter3Field1
	IniWrite, %Planter3Until1%, settings\nm_config.ini, Planters, Planter3Until1
}
nm_Planter3Field2(){
	GuiControlGet Planter3Field2
	GuiControlGet Planter3Until2
	if(Planter3Field2="none"){
		GuiControl,ChooseString, Planter3Field3, None
		GuiControl,disable, Planter3Field3
		GuiControl,disable, Planter3Until3
		nm_Planter3Field3()
	} else {
		GuiControl,enable, Planter3Field3
		GuiControl,enable, Planter3Until3
	}
	IniWrite, %Planter3Field2%, settings\nm_config.ini, Planters, Planter3Field2
	IniWrite, %Planter3Until2%, settings\nm_config.ini, Planters, Planter3Until2
}
nm_Planter3Field3(){
	GuiControlGet Planter3Field3
	GuiControlGet Planter3Until3
	if(Planter3Field3="none"){
		GuiControl,ChooseString, Planter3Field4, None
		GuiControl,disable, Planter3Field4
		GuiControl,disable, Planter3Until4
		nm_Planter3Field4()
	} else {
		GuiControl,enable, Planter3Field4
		GuiControl,enable, Planter3Until4
	}
	IniWrite, %Planter3Field3%, settings\nm_config.ini, Planters, Planter3Field3
	IniWrite, %Planter3Until3%, settings\nm_config.ini, Planters, Planter3Until3
}
nm_Planter3Field4(){
	GuiControlGet Planter3Field4
	GuiControlGet Planter3Until4
	IniWrite, %Planter3Field4%, settings\nm_config.ini, Planters, Planter3Field4
	IniWrite, %Planter3Until4%, settings\nm_config.ini, Planters, Planter3Until4
}
nm_SaveGather(){
	global
	local k, temp
	if (disableSave = 1)
		return
	for k in config["Gather"]
	{
		GuiControlGet, temp, , %k%
		if (temp != "")
		{
			GuiControlGet, %k%
			IniWrite, % %k%, settings\nm_config.ini, Gather, %k%
		}
	}
}
nm_saveCollect(){
	global
	local k, temp
	for k in config["Collect"]
	{
		GuiControlGet, temp, , %k%
		if (temp != "")
		{
			GuiControlGet, %k%
			IniWrite, % %k%, settings\nm_config.ini, Collect, %k%
		}
	}
}
nm_saveStingers(hCtrl){
	global
	static fields := ["Pepper","MountainTop","Rose","Cactus","Spider","Clover"]
	local k,c,i,v
	GuiControlGet, k, Name, %hCtrl%
	GuiControlGet, %k%
	IniWrite, % %k%, settings\nm_config.ini, Collect, %k%

	if (k = "StingerCheck")
	{
		c := StingerCheck ? "Enable" : "Disable"
		for i,v in fields
			GuiControl, %c%, Stinger%v%Check
		GuiControl, %c%, StingerDailyBonusCheck
	}
}
nm_saveAmulet(hCtrl){
	global
	local k
	GuiControlGet, k, Name, %hCtrl%
	GuiControlGet, %k%
	GuiControl, , %k%Text, % (%k% = 1) ? " Keep Old" : "Do Nothing"
	IniWrite, % %k%, settings\nm_config.ini, Collect, %k%
}
nm_setSnailHealth(hEdit)
{
	global InputSnailHealth
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, inputHP, , SnailHealthEdit

	if (inputHP ~= "[^\d]" || (inputHP > 30000000)) ; invalid HP
	{
		GuiControl, , %hEdit%, % Round(30000000*InputSnailHealth/100)
		SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "You cannot enter a number above 30M!")
	}
	else
	{
		InputSnailHealth := Round((inputHP / 30000000) * 100, 2)
		GuiControl, % "+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0) " +Redraw", SnailHealthText
		GuiControl, , SnailHealthText, % InputSnailHealth "%"
		IniWrite, %InputSnailHealth%, settings\nm_config.ini, Collect, InputSnailHealth
	}
}
nm_setChickHealth(hCtrl)
{
    global InputChickHealth
	;Gumdrops carried me, they so pro
	static chickArray := {3: 150
	, 4: 2000
	, 5: 10000
	, 6: 15000
	, 7: 25000
	, 8: 50000
	, 9: 100000
	, 10: 150000
	, 11: 200000
	, 12: 300000
	, 13: 400000
	, 14: 500000
	, 15: 750000
	, 16: 1000000
	, 17: 2500000
	, 18: 5000000
	, 19: 7500000}

	GuiControlGet, k, Name, %hCtrl%
	GuiControlGet, inputHP, , ChickHealthEdit
	GuiControlGet, ChickLevel
	MaxHealth := chickArray.HasKey(ChickLevel) ? chickArray[ChickLevel] : 10000000

	if (k = "ChickHealthEdit")
	{
		if (inputHP ~= "[^\d]" || (inputHP > MaxHealth))
		{
			ControlGet, p, CurrentCol, , , ahk_id %hCtrl%
			GuiControl, , %hCtrl%, % Round(MaxHealth*InputChickHealth/100)
			SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hCtrl%
			nm_ShowErrorBalloonTip(hCtrl, "Unacceptable Number", "You cannot enter a number above " MaxHealth " for this level!")
			return
		}
	}
	else if (inputHP > MaxHealth)
		GuiControl, , ChickHealthEdit, % (inputHP := MaxHealth)
	GuiControl, , ChickLevelText, % ChickLevel

	InputChickHealth := Round(Min(100, (inputHP / (chickArray.HasKey(ChickLevel) ? chickArray[ChickLevel] : 10000000)) * 100), 2)
	GuiControl, % "+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0) " +Redraw", ChickHealthText
	GuiControl, , ChickHealthText, % InputChickHealth "%"
	IniWrite, %InputChickHealth%, settings\nm_config.ini, Collect, InputChickHealth
}
nm_SnailTime(){
	global SnailTime
	static arr := [5,10,15,"Kill"]
	GuiControlGet, SnailTimeUpDown
	GuiControl, , SnailTimeText, % ((SnailTime := arr[SnailTimeUpDown]) = "Kill") ? SnailTime : SnailTime "m"
	IniWrite, %SnailTime%, settings\nm_config.ini, Collect, SnailTime
}
nm_ChickTime(){
	global ChickTime
	static arr := [5,10,15,"Kill"]
	GuiControlGet, ChickTimeUpDown
	GuiControl, , ChickTimeText, % ((ChickTime := arr[ChickTimeUpDown]) = "Kill") ? ChickTime : ChickTime "m"
	IniWrite, %ChickTime%, settings\nm_config.ini, Collect, ChickTime
}
nm_BugrunCheck(){
	GuiControlGet, BugrunCheck
	if(BugrunCheck){
		GuiControl,,BugrunInterruptCheck, 1
		GuiControl,,BugrunLadybugsCheck, 1
		GuiControl,,BugrunRhinoBeetlesCheck, 1
		GuiControl,,BugrunSpiderCheck, 1
		GuiControl,,BugrunMantisCheck, 1
		GuiControl,,BugrunScorpionsCheck, 1
		GuiControl,,BugrunWerewolfCheck, 1
		GuiControl,,BugrunLadybugsLoot, 1
		GuiControl,,BugrunRhinoBeetlesLoot, 1
		GuiControl,,BugrunSpiderLoot, 1
		GuiControl,,BugrunMantisLoot, 1
		GuiControl,,BugrunScorpionsLoot, 1
		GuiControl,,BugrunWerewolfLoot, 1
	} else {
		GuiControl,,BugrunInterruptCheck, 0
		GuiControl,,BugrunLadybugsCheck, 0
		GuiControl,,BugrunRhinoBeetlesCheck, 0
		GuiControl,,BugrunSpiderCheck, 0
		GuiControl,,BugrunMantisCheck, 0
		GuiControl,,BugrunScorpionsCheck, 0
		GuiControl,,BugrunWerewolfCheck, 0
		GuiControl,,BugrunLadybugsLoot, 0
		GuiControl,,BugrunRhinoBeetlesLoot, 0
		GuiControl,,BugrunSpiderLoot, 0
		GuiControl,,BugrunMantisLoot, 0
		GuiControl,,BugrunScorpionsLoot, 0
		GuiControl,,BugrunWerewolfLoot, 0
	}
	nm_saveCollect()
}
nm_TabCollectLock(){
	GuiControl, disable, ClockCheck
	GuiControl, disable, MondoBuffCheck
	GuiControl, disable, MondoAction
	GuiControl, disable, RoboPassCheck
	GuiControl, disable, HoneystormCheck
	GuiControl, disable, AntPassCheck
	GuiControl, disable, AntPassAction
	GuiControl, disable, HoneyDisCheck
	GuiControl, disable, TreatDisCheck
	GuiControl, disable, BlueberryDisCheck
	GuiControl, disable, StrawberryDisCheck
	GuiControl, disable, CoconutDisCheck
	GuiControl, disable, RoyalJellyDisCheck
	GuiControl, disable, GlueDisCheck
	GuiControl, disable, BeesmasGatherInterruptCheck
	GuiControl, disable, StockingsCheck
	GuiControl, disable, WreathCheck
	GuiControl, disable, FeastCheck
	GuiControl, disable, RBPDelevelCheck
	GuiControl, disable, GingerbreadCheck
	GuiControl, disable, SnowMachineCheck
	GuiControl, disable, CandlesCheck
	GuiControl, disable, SamovarCheck
	GuiControl, disable, LidArtCheck
	GuiControl, disable, GummyBeaconCheck
	GuiControl, disable, MonsterRespawnTime
	GuiControl, disable, BugrunLadybugsCheck
	GuiControl, disable, BugrunRhinoBeetlesCheck
	GuiControl, disable, BugrunSpiderCheck
	GuiControl, disable, BugrunMantisCheck
	GuiControl, disable, BugrunScorpionsCheck
	GuiControl, disable, BugrunWerewolfCheck
	GuiControl, disable, BugrunLadybugsLoot
	GuiControl, disable, BugrunRhinoBeetlesLoot
	GuiControl, disable, BugrunSpiderLoot
	GuiControl, disable, BugrunMantisLoot
	GuiControl, disable, BugrunScorpionsLoot
	GuiControl, disable, BugrunWerewolfLoot
	GuiControl, disable, StingerCheck
	GuiControl, disable, TunnelBearCheck
	GuiControl, disable, TunnelBearBabyCheck
	GuiControl, disable, KingBeetleCheck
	GuiControl, disable, KingBeetleBabyCheck
	GuiControl, disable, KingBeetleAmuletMode
	GuiControl, disable, CocoCrabCheck
	GuiControl, disable, StumpSnailCheck
	GuiControl, disable, ShellAmuletMode
	GuiControl, disable, CommandoCheck
	GuiControl, disable, InputSnailHealthButton
	GuiControl, disable, SnailTimeUpDown
	GuiControl, disable, InputChickHealthButton
	GuiControl, disable, ChickTimeUpDown
}
nm_TabCollectUnLock(){
	global beesmasActive
	GuiControl, enable, ClockCheck
	GuiControl, enable, MondoBuffCheck
	GuiControl, enable, MondoAction
	GuiControl, enable, RoboPassCheck
	GuiControl, enable, HoneystormCheck
	GuiControl, enable, AntPassCheck
	GuiControl, enable, AntPassAction
	GuiControl, enable, HoneyDisCheck
	GuiControl, enable, TreatDisCheck
	GuiControl, enable, BlueberryDisCheck
	GuiControl, enable, StrawberryDisCheck
	GuiControl, enable, CoconutDisCheck
	GuiControl, enable, RoyalJellyDisCheck
	GuiControl, enable, GlueDisCheck
	if beesmasActive
	{
		GuiControl, enable, BeesmasGatherInterruptCheck
		GuiControl, enable, StockingsCheck
		GuiControl, enable, WreathCheck
		GuiControl, enable, FeastCheck
		GuiControl, enable, RBPDelevelCheck
		GuiControl, enable, GingerbreadCheck
		GuiControl, enable, SnowMachineCheck
		GuiControl, enable, CandlesCheck
		GuiControl, enable, SamovarCheck
		GuiControl, enable, LidArtCheck
		GuiControl, enable, GummyBeaconCheck
	}
	GuiControl, enable, MonsterRespawnTime
	GuiControl, enable, BugrunLadybugsCheck
	GuiControl, enable, BugrunRhinoBeetlesCheck
	GuiControl, enable, BugrunSpiderCheck
	GuiControl, enable, BugrunMantisCheck
	GuiControl, enable, BugrunScorpionsCheck
	GuiControl, enable, BugrunWerewolfCheck
	GuiControl, enable, BugrunLadybugsLoot
	GuiControl, enable, BugrunRhinoBeetlesLoot
	GuiControl, enable, BugrunSpiderLoot
	GuiControl, enable, BugrunMantisLoot
	GuiControl, enable, BugrunScorpionsLoot
	GuiControl, enable, BugrunWerewolfLoot
	GuiControl, enable, StingerCheck
	GuiControl, enable, TunnelBearCheck
	GuiControl, enable, TunnelBearBabyCheck
	GuiControl, enable, KingBeetleCheck
	GuiControl, enable, KingBeetleBabyCheck
	GuiControl, enable, KingBeetleAmuletMode
	GuiControl, enable, CocoCrabCheck
	GuiControl, enable, StumpSnailCheck
	GuiControl, enable, ShellAmuletMode
	GuiControl, enable, CommandoCheck
	GuiControl, enable, InputSnailHealthButton
	GuiControl, enable, SnailTimeUpDown
	GuiControl, enable, InputChickHealthButton
	GuiControl, enable,	ChickTimeUpDown
}
nm_saveBoost(){
	global
	for k in config["Boost"]
	{
		GuiControlGet, temp, , %k%
		if (temp != "")
		{
			GuiControlGet, %k%
			IniWrite, % %k%, settings\nm_config.ini, Boost, %k%
		}
	}
	nm_HotbarWhile()
}
nm_BoostChaserCheck(){
	global BoostChaserCheck
	global AutoFieldBoostActive
	GuiControlGet BoostChaserCheck
	IniWrite, %BoostChaserCheck%, settings\nm_config.ini, Boost, BoostChaserCheck
	;disable AutoFieldBoost (mutually exclusive features)
	if(BoostChaserCheck) {
		AutoFieldBoostActive:=0
		GuiControl,afb:, AutoFieldBoostActive, %AutoFieldBoostActive%
		GuiControl,, AutoFieldBoostActive, %AutoFieldBoostActive%
		IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
		if(AutoFieldBoostActive)
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[ON]
		else if(not AutoFieldBoostActive)
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
	}
}
nm_TabBoostLock(){
	GuiControl, disable, FieldBooster1
	GuiControl, disable, FieldBooster2
	GuiControl, disable, FieldBooster3
	GuiControl, disable, FieldBoosterMins
	GuiControl, disable, HotbarWhile2
	GuiControl, disable, HotbarWhile3
	GuiControl, disable, HotbarWhile4
	GuiControl, disable, HotbarWhile5
	GuiControl, disable, HotbarWhile6
	GuiControl, disable, HotbarWhile7
	GuiControl, disable, HotbarTime2
	GuiControl, disable, HotbarTime3
	GuiControl, disable, HotbarTime4
	GuiControl, disable, HotbarTime5
	GuiControl, disable, HotbarTime6
	GuiControl, disable, HotbarTime7
}
nm_TabBoostUnLock(){
	GuiControl, enable, FieldBooster1
	nm_FieldBooster1()
	GuiControl, enable, FieldBoosterMins
	GuiControl, enable, HotbarWhile2
	GuiControl, enable, HotbarWhile3
	GuiControl, enable, HotbarWhile4
	GuiControl, enable, HotbarWhile5
	GuiControl, enable, HotbarWhile6
	GuiControl, enable, HotbarWhile7
	GuiControl, enable, HotbarTime2
	GuiControl, enable, HotbarTime3
	GuiControl, enable, HotbarTime4
	GuiControl, enable, HotbarTime5
	GuiControl, enable, HotbarTime6
	GuiControl, enable, HotbarTime7
}
nm_FieldBooster1(){
	global FieldBooster1
	GuiControlGet FieldBooster1
	if(FieldBooster1="none") {
		GuiControl, ChooseString, FieldBooster2, None
		GuiControl, disable, FieldBooster2
	} else {
		GuiControl, enable, FieldBooster2
	}
	nm_FieldBooster2()
	IniWrite, %FieldBooster1%, settings\nm_config.ini, Boost, FieldBooster1
}
nm_FieldBooster2(){
	global FieldBooster2
	GuiControlGet FieldBooster2
	if(FieldBooster2=FieldBooster1) {
		FieldBooster2=None
		GuiControl, ChooseString, FieldBooster2, None
	}
	if(FieldBooster2="none") {
		GuiControl, ChooseString, FieldBooster3, None
		GuiControl, disable, FieldBooster3
	} else {
		GuiControl, enable, FieldBooster3
	}
	nm_FieldBooster3()
	IniWrite, %FieldBooster2%, settings\nm_config.ini, Boost, FieldBooster2
}
nm_FieldBooster3(){
	global FieldBooster3
	GuiControlGet FieldBooster3
	if(FieldBooster3=FieldBooster1 || FieldBooster3=FieldBooster2) {
		FieldBooster3=None
		GuiControl, ChooseString, FieldBooster3, None
	}
	IniWrite, %FieldBooster3%, settings\nm_config.ini, Boost, FieldBooster3
}
nm_HotbarWhile(hCtrl:=0){
	global HotbarWhile2, HotbarWhile3, HotbarWhile4, HotbarWhile5, HotbarWhile6, HotbarWhile7
		, hHB2, hHB3, hHB4, hHB5, hHB6, hHB7
		, PFieldBoosted

	Loop, 6 {
		i := A_Index + 1
		if ((hCtrl = 0) || (hCtrl = hHB%i%)) {
			GuiControlGet HotbarWhile%i%
			switch HotbarWhile%i%
			{
				case "microconverter":
				GuiControl,,HBText%i%, % (PFieldBoosted ? "@ Boosted" : "@ Full Pack")
				GuiControl, hide, HotbarTime%i%
				GuiControl, hide, HBTimeText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%
				GuiControl, show, HBText%i%

				case "whirligig":
				GuiControl,,HBText%i%, % (PFieldBoosted ? "@ Boosted" : "@ Hive Return")
				GuiControl, hide, HotbarTime%i%
				GuiControl, hide, HBTimeText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%
				GuiControl, show, HBText%i%

				case "enzymes":
				GuiControl,,HBText%i%, % (PFieldBoosted ? "@ Boosted" : "@ Converting Balloon")
				GuiControl, hide, HotbarTime%i%
				GuiControl, hide, HBTimeText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%
				GuiControl, show, HBText%i%

				case "glitter":
				GuiControl,,HBText%i%, @ Boosted
				GuiControl, hide, HotbarTime%i%
				GuiControl, hide, HBTimeText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%
				GuiControl, show, HBText%i%

				case "snowflake":
				GuiControlGet, HotkeyMax%i%
				GuiControlGet, HotbarTime%i%
				GuiControl,,HBConditionText%i%, % "Until: " HotkeyMax%i% "%"
				GuiControl,,HBTimeText%i%, % nm_DurationFromSeconds(HotbarTime%i%)
				GuiControl, hide, HBText%i%
				GuiControl, show, HotbarTime%i%
				GuiControl, show, HBTimeText%i%
				GuiControl, show, HBConditionText%i%
				GuiControl, show, HotkeyMax%i%

				case "never":
				GuiControl, hide, HBText%i%
				GuiControl, hide, HotbarTime%i%
				GuiControl, hide, HBTimeText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%

				default:
				GuiControlGet, HotbarTime%i%
				GuiControl,,HBTimeText%i%, % nm_DurationFromSeconds(HotbarTime%i%)
				GuiControl, hide, HBText%i%
				GuiControl, hide, HBConditionText%i%
				GuiControl, hide, HotkeyMax%i%
				GuiControl, show, HotbarTime%i%
				GuiControl, show, HBTimeText%i%
			}
			IniWrite, % HotbarWhile%i%, settings\nm_config.ini, Boost, HotbarWhile%i%
		}
	}
}
nm_importStyles() {
	global StylesList, GuiTheme
	StylesList := ""
	Loop, Files, %A_ScriptDir%\nm_image_assets\Styles\*.msstyles
		StylesList .= "|" A_LoopFileName

	StylesList .= "|", StylesList := StrReplace(StylesList, ".msstyles")

	if !(Instr(StylesList, GuiTheme))
		StylesList .= GuiTheme "|"
}
nm_HotkeyEditTime(hCtrl){
	global
	local k,i,time
	GuiControlGet, k, Name, %hCtrl%
	i := SubStr(k, 0)
	Gui, +OwnDialogs
	InputBox, time, Hotbar Slot Time, Enter the number of seconds (1-99999) to wait between each use of Hotbar %i%:
	if (time ~= "i)^\d{1,5}$")
	{
		HotbarTime%i% := time
		GuiControl,,HotbarTime%i%, % HotbarTime%i%
		GuiControl,,HBTimeText%i%, % nm_DurationFromSeconds(HotbarTime%i%)
		IniWrite, % HotbarTime%i%, settings\nm_config.ini, Boost, HotbarTime%i%
	}
	else if (time != "")
		msgbox, 0x40030, Hotbar Slot Time, You must enter a valid number of seconds between 1 and 99999!, 20
}
nm_savequest(){
	global
	GuiControlGet, PolarQuestCheck
	GuiControlGet, PolarQuestGatherInterruptCheck
	GuiControlGet, HoneyQuestCheck
	GuiControlGet, QuestGatherMins
	GuiControlGet, QuestGatherReturnBy
	IniWrite, %PolarQuestCheck%, settings\nm_config.ini, Quests, PolarQuestCheck
	IniWrite, %PolarQuestGatherInterruptCheck%, settings\nm_config.ini, Quests, PolarQuestGatherInterruptCheck
	IniWrite, %HoneyQuestCheck%, settings\nm_config.ini, Quests, HoneyQuestCheck
	IniWrite, %QuestGatherMins%, settings\nm_config.ini, Quests, QuestGatherMins
	IniWrite, %QuestGatherReturnBy%, settings\nm_config.ini, Quests, QuestGatherReturnBy
}
nm_BlackQuestCheck(){
	global
	Gui +OwnDialogs
	GuiControlGet, BlackQuestCheck
	IniWrite, %BlackQuestCheck%, settings\nm_config.ini, Quests, BlackQuestCheck
	if BlackQuestCheck
		msgbox,0,Black Bear Quest, This option only works for the repeatable quests.  You must first complete the main questline before this option will work properly.
}
nm_BuckoQuestCheck(){
	global
	Gui +OwnDialogs
	GuiControlGet, BuckoQuestCheck
	GuiControlGet, BuckoQuestGatherInterruptCheck
	IniWrite, %BuckoQuestCheck%, settings\nm_config.ini, Quests, BuckoQuestCheck
	IniWrite, %BuckoQuestGatherInterruptCheck%, settings\nm_config.ini, Quests, BuckoQuestGatherInterruptCheck
	if(BuckoQuestCheck && (AntPassCheck = 0)) {
		GuiControl,,AntPassCheck, 1
		GuiControl,ChooseString, AntPassAction, Pass
		nm_saveCollect()
		msgbox,0,Bucko Bee Quest, Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.
	}
}
nm_RileyQuestCheck(){
	global
	Gui +OwnDialogs
	GuiControlGet, RileyQuestCheck
	GuiControlGet, RileyQuestGatherInterruptCheck
	IniWrite, %RileyQuestCheck%, settings\nm_config.ini, Quests, RileyQuestCheck
	IniWrite, %RileyQuestGatherInterruptCheck%, settings\nm_config.ini, Quests, RileyQuestGatherInterruptCheck
	if(RileyQuestCheck && (AntPassCheck = 0)) {
		GuiControl,,AntPassCheck, 1
		GuiControl,ChooseString, AntPassAction, Pass
		nm_saveCollect()
		msgbox,0,Riley Bee Quest, Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.
	}
}
nm_CocoCrabCheck(){
	global
	Gui +OwnDialogs
	GuiControlGet, CocoCrabCheck
	IniWrite, %CocoCrabCheck%, settings\nm_config.ini, Collect, CocoCrabCheck
	if CocoCrabCheck
		msgbox,0x1030,Coconut Crab, Being able to kill Coco Crab with the macro depends heavily on your hive level, attack, number of bees, and server lag!
}
nm_ResetTotalStats(){
	global TotalRuntime:=0
	global TotalGatherTime:=0
	global TotalConvertTime:=0
	global TotalViciousKills:=0
	global TotalBossKills:=0
	global TotalBugKills:=0
	global TotalPlantersCollected:=0
	global TotalQuestsComplete:=0
	global TotalDisconnects:=0
	IniWrite, %TotalRuntime%, settings\nm_config.ini, Status, TotalRuntime
	IniWrite, %TotalGatherTime%, settings\nm_config.ini, Status, TotalGatherTime
	IniWrite, %TotalConvertTime%, settings\nm_config.ini, Status, TotalConvertTime
	IniWrite, %TotalViciousKills%, settings\nm_config.ini, Status, TotalViciousKills
	IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
	IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
	IniWrite, %TotalPlantersCollected%, settings\nm_config.ini, Status, TotalPlantersCollected
	IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
	IniWrite, %TotalDisconnects%, settings\nm_config.ini, Status, TotalDisconnects
	nm_setStats()
}
nm_ResetSessionStats(){
	global SessionRuntime:=0
	global SessionGatherTime:=0
	global SessionConvertTime:=0
	global SessionViciousKills:=0
	global SessionBossKills:=0
	global SessionBugKills:=0
	global SessionPlantersCollected:=0
	global SessionQuestsComplete:=0
	global SessionDisconnects:=0
	IniWrite, %SessionRuntime%, settings\nm_config.ini, Status, SessionRuntime
	IniWrite, %SessionGatherTime%, settings\nm_config.ini, Status, SessionGatherTime
	IniWrite, %SessionConvertTime%, settings\nm_config.ini, Status, SessionConvertTime
	IniWrite, %SessionViciousKills%, settings\nm_config.ini, Status, SessionViciousKills
	IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
	IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
	IniWrite, %SessionPlantersCollected%, settings\nm_config.ini, Status, SessionPlantersCollected
	IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
	IniWrite, %SessionDisconnects%, settings\nm_config.ini, Status, SessionDisconnects
	nm_setStats()
}
nm_NightAnnouncementGUI(){
	global
	Gui, night:Destroy
	Gui, night:+AlwaysOnTop +Border
	Gui, night:Font, s8 cDefault Bold, Tahoma
	Gui, night:Add, GroupBox, x5 y2 w290 h65, Settings
	Gui, night:Add, Checkbox, x73 y2 vNightAnnouncementCheck gnm_NightAnnouncementCheck Checked%NightAnnouncementCheck%, Enabled
	Gui, night:Font, Norm
	Gui, night:Add, Button, x150 y1 w135 h16 gnm_NightAnnouncementHelp, What does this do?
	Gui, night:Add, Text, x15 y23, Name:
	Gui, night:Add, Edit, % "x48 y21 w75 h18 gnm_saveNightAnnouncementName vNightAnnouncementName Disabled" !NightAnnouncementCheck, %NightAnnouncementName%
	Gui, night:Add, Text, x130 y23, Ping ID:
	Gui, night:Add, Edit, % "x170 y21 w115 h18 gnm_saveNightAnnouncementPingID vNightAnnouncementPingID Disabled" !NightAnnouncementCheck, %NightAnnouncementPingID%
	Gui, night:Add, Text, x15 y45, Webhook:
	Gui, night:Add, Edit, % "x67 y43 w218 h18 gnm_saveNightAnnouncementWebhook vNightAnnouncementWebhook Disabled" !NightAnnouncementCheck, %NightAnnouncementWebhook%
	Gui, night:Show, w300 h72, Announce Night Detection
}
nm_NightAnnouncementCheck(){
	global NightAnnouncementCheck
	GuiControlGet, NightAnnouncementCheck
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 220, NightAnnouncementCheck
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	SetTitleMatchMode, %Prev_TitleMatchMode%
	IniWrite, %NightAnnouncementCheck%, settings\nm_config.ini, Status, NightAnnouncementCheck

	p := (NightAnnouncementCheck ? "Enable" : "Disable")
	GuiControl, %p%, NightAnnouncementName
	GuiControl, %p%, NightAnnouncementPingID
	GuiControl, %p%, NightAnnouncementWebhook
}
nm_saveNightAnnouncementName(hEdit){
	global NightAnnouncementName
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewNightAnnouncementName, , %hEdit%

	if InStr(NewNightAnnouncementName, "\")
	{
		GuiControl, , %hEdit%, %NightAnnouncementName%
		SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Character", "The name cannot include the following characters:`n'\'")
	}
	else
	{
		NightAnnouncementName := NewNightAnnouncementName
		IniWrite, %NightAnnouncementName%, settings\nm_config.ini, Status, NightAnnouncementName
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage, 0x5553, 48, 8
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
		SetTitleMatchMode, %Prev_TitleMatchMode%
	}

	;enum
	IniWrite, %NightAnnouncementName%, settings\nm_config.ini, Status, NightAnnouncementName
}
nm_saveNightAnnouncementPingID(hEdit){
	global NightAnnouncementPingID
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewNightAnnouncementPingID, , %hEdit%

	if (NewNightAnnouncementPingID ~= "i)^&?[0-9]*$")
	{
		NightAnnouncementPingID := NewNightAnnouncementPingID
		IniWrite, %NightAnnouncementPingID%, settings\nm_config.ini, Status, NightAnnouncementPingID
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage, 0x5553, 49, 8
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
		SetTitleMatchMode, %Prev_TitleMatchMode%
	}
	else
	{
		GuiControl, , %hEdit%, %NightAnnouncementPingID%
		SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Invalid Discord Ping ID!", "Make sure it is a valid User ID or Role ID (starting with &).")
	}
}
nm_saveNightAnnouncementWebhook(hEdit){
	global NightAnnouncementWebhook
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, str, , %hEdit%
	RegexMatch(str, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)", NewNightAnnouncementWebhook)

	if ((StrLen(str) = 0) || (StrLen(NewNightAnnouncementWebhook) > 0))
	{
		NightAnnouncementWebhook := NewNightAnnouncementWebhook
		IniWrite, %NightAnnouncementWebhook%, settings\nm_config.ini, Status, NightAnnouncementWebhook
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage, 0x5553, 50, 8
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
		SetTitleMatchMode, %Prev_TitleMatchMode%
	}
	else
	{
		GuiControl, , %hEdit%, %NightAnnouncementWebhook%
		SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Invalid Discord Webhook Link!", "Make sure your link is copied directly from Discord.")
	}
}
nm_NightAnnouncementHelp(){
	msgbox, 0x40000, Announce Night Detection, DESCRIPTION:`nWhen this option is enabled, the macro will send a message to the specified webhook alerting others that night has been detected in your server, allowing them to join and help fight Vicious Bee.`nNOTE: 'Kill Vicious Bee' must be enabled in Collect/Kill tab for night detection to run!`n`nName:`nThis is just what your name will show as, i.e. ___'s Server.`n`nPing ID:`nYou can enter either a User ID or Role ID here. Make sure to start a Role ID with '&'. If this option is not empty, the macro will ping this user/role when it sends the Night Detection message.`n`nWebhook:`nHere, you must enter the destination webhook for Night Detection Announcements. This is the channel where messages will be sent and people with access to the channel will be informed that it is nighttime in your server.
}
nm_ShowErrorBalloonTip(hEdit, Title, Text){
	NumPut(VarSetCapacity(EBT, 4 * A_PtrSize, 0), EBT, 0, "UInt")
	If !(A_IsUnicode) {
		VarSetCapacity(WTitle, StrLen(Title) * 4, 0)
		VarSetCapacity(WText, StrLen(Text) * 4, 0)
		StrPut(Title, &WTitle, "UTF-16")
		StrPut(Text, &WText, "UTF-16")
	}
	NumPut(A_IsUnicode ? &Title : &WTitle, EBT, A_PtrSize, "Ptr")
	NumPut(A_IsUnicode ? &Text : &WText, EBT, A_PtrSize * 2, "Ptr")
	NumPut(3, EBT, A_PtrSize * 3, "UInt")
	DllCall("SendMessage", "UPtr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
}
;;;;;;;;; START AFB
nm_autoFieldBoostButton(){
	nm_autoFieldBoostGui()
}
nm_autoFieldBoostGui(){
	gui, afb:destroy
	global AutoFieldBoostActive
	global AutoFieldBoostRefresh ;minutes
	global AFBDiceLimitEnableSel
	global AFBGlitterLimitEnableSel
	global AFBHoursLimitEnableSel
	global AFBDiceEnable
	global AFBGlitterEnable
	global AFBFieldEnable
	global AFBDiceLimit
	global AFBGlitterLimit
	global AFBHoursLimit
	global AFBHoursLimitNum
	global AFBDiceHotbar
	global AFBGlitterHotbar
	global currentField
	global AFBcurrentField
	gui afb:+border
	gui afb:font, s8 cDefault Norm, Tahoma
	IniRead, AutoFieldBoostActive, settings\nm_config.ini, Boost, AutoFieldBoostActive
	IniRead, AutoFieldBoostRefresh, settings\nm_config.ini, Boost, AutoFieldBoostRefresh
	Gui, afb:Add, Checkbox, x5 y5 vAutoFieldBoostActive gnm_autoFieldBoostCheck checked%AutoFieldBoostActive%, Activate Automatic Field Boost for Gathering Field:
	gui afb:font, w800 cBlue
	Gui, afb:Add, text, x270 y5 left vAFBcurrentField, %currentField%
	gui afb:font, s8 cDefault Norm, Tahoma
	Gui, afb:Add, button, x20 y22 w120 h15 gnm_AFBHelpButton, What does this do?
	gui afb:add, text, x5 y42 w355 h1 0x7
	Gui, afb:Add, text, x20 y48, Re-Buff Field Boost Every:
	Gui, afb:Add, DropDownList, x147 y46 w45 h150 vAutoFieldBoostRefresh gnm_saveAFBConfig, % LTrim(StrReplace("|8|8.5|9|9.5|10|10.5|11|11.5|12|12.5|13|13.5|14|14.5|15|", "|" AutoFieldBoostRefresh "|", "|" AutoFieldBoostRefresh "||"), "|")
	Gui, afb:Add, text, x195 y48, Minutes
	Gui, afb:Add, button, x5 y48 w10 h15 gnm_AFBRebuffHelpButton, ?
	gui afb:add, text,x20 y70 +left +BackgroundTrans,Use
	gui afb:add, text, x5 y86 w355 h1 0x7
	gui afb:font, s10
	IniRead, AFBDiceEnable, settings\nm_config.ini, Boost, AFBDiceEnable
	IniRead, AFBGlitterEnable, settings\nm_config.ini, Boost, AFBGlitterEnable
	IniRead, AFBFieldEnable, settings\nm_config.ini, Boost, AFBFieldEnable
	Gui, afb:Add, button, x5 y90 w10 h15 gnm_AFBDiceEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y90 vAFBDiceEnable gnm_AFBDiceEnableCheck checked%AFBDiceEnable%, Dice:
	Gui, afb:Add, button, x5 y113 w10 h15 gnm_AFBGlitterEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y113 vAFBGlitterEnable gnm_AFBGlitterEnableCheck checked%AFBGlitterEnable%, Glitter:
	Gui, afb:Add, button, x5 y136 w10 h15 gnm_AFBFieldEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y136 vAFBFieldEnable gnm_saveAFBConfig checked%AFBFieldEnable%, Free Field Boosters
	gui afb:font, s8 cDefault Norm, Tahoma
	gui afb:add, text,x80 y70 +left +BackgroundTrans,Hotbar Slot
	IniRead, AFBDiceHotbar, settings\nm_config.ini, Boost, AFBDiceHotbar
	IniRead, AFBGlitterHotbar, settings\nm_config.ini, Boost, AFBGlitterHotbar
	Gui, afb:Add, DropDownList, x80 y88 w50 h120 vAFBDiceHotbar gnm_saveAFBConfig, % LTrim(StrReplace("|None|2|3|4|5|6|7|", "|" AFBDiceHotbar "|", "|" AFBDiceHotbar "||"), "|")
	Gui, afb:Add, DropDownList, x80 y110 w50 h120 vAFBGlitterHotbar gnm_saveAFBConfig, % LTrim(StrReplace("|None|2|3|4|5|6|7|", "|" AFBGlitterHotbar "|", "|" AFBGlitterHotbar "||"), "|")
	gui afb:add, text,x160 y73 +left +BackgroundTrans,|
	gui afb:add, text,x160 y83 +left +BackgroundTrans,|
	gui afb:add, text,x160 y93 +left +BackgroundTrans,|
	gui afb:add, text,x160 y103 +left +BackgroundTrans,|
	gui afb:add, text,x160 y113 +left +BackgroundTrans,|
	gui afb:add, text,x160 y123 +left +BackgroundTrans,|
	gui afb:add, text,x160 y133 +left +BackgroundTrans,|
	gui afb:add, text,x160 y143 +left +BackgroundTrans,|
	gui afb:add, text,x160 y153 +left +BackgroundTrans,|
	gui afb:add, text,x160 y163 +left +BackgroundTrans,|
	Gui, afb:Add, button, x170 y70 w10 h15 gnm_AFBDeactivationLimitsHelpButton, ?
	gui afb:add, text,x185 y70 cRED +left +BackgroundTrans,DEACTIVATION LIMITS:
	gui afb:add, text,x298 y42 +left +BackgroundTrans,Reset Used:
	Gui, afb:Add, button, x318 y55 w40 h15 gnm_resetUsedDice, Dice
	Gui, afb:Add, button, x318 y70 w40 h15 gnm_resetUsedGlitter, Glitter
	;gui afb:add, text,x155 y40 +left +BackgroundTrans,Set Limits
	IniRead, AFBDiceLimitEnable, settings\nm_config.ini, Boost, AFBDiceLimitEnable
	if(not AFBDiceLimitEnable)
		DiceSel:="None"
	else
		DiceSel:="Limit"
	IniRead, AFBGlitterLimitEnable, settings\nm_config.ini, Boost, AFBGlitterLimitEnable
	if(not AFBGlitterLimitEnable)
		GlitterSel:="None"
	else
		GlitterSel:="Limit"
	IniRead, AFBHoursLimitEnable, settings\nm_config.ini, Boost, AFBHoursLimitEnable
	if(not AFBHoursLimitEnable)
		HoursSel:="None"
	else
		HoursSel:="Limit"
	Gui, afb:Add, button, x170 y90 w10 h15 gnm_AFBDiceLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y88 w50 h120 vAFBDiceLimitEnableSel gnm_AFBDiceLimitEnable, % LTrim(StrReplace("|Limit|None|", "|" DiceSel "|", "|" DiceSel "||"), "|")
	Gui, afb:Add, button, x170 y113 w10 h15 gnm_AFBGlitterLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y110 w50 h120 vAFBGlitterLimitEnableSel gnm_AFBGlitterLimitEnable, % LTrim(StrReplace("|Limit|None|", "|" GlitterSel "|", "|" GlitterSel "||"), "|")
	Gui, afb:Add, button, x170 y156 w10 h15 gnm_AFBHoursLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y152 w50 h120 vAFBHoursLimitEnableSel gnm_AFBHoursLimitEnable, % LTrim(StrReplace("|Limit|None|", "|" HoursSel "|", "|" HoursSel "||"), "|")
	gui afb:add, text,x240 y90 +left +BackgroundTrans,to
	gui afb:add, text,x305 y90 +left +BackgroundTrans,Dice Used
	gui afb:add, text,x240 y113 +left +BackgroundTrans,to
	gui afb:add, text,x305 y113 +left +BackgroundTrans,Glitter Used
	gui afb:add, text,x240 y156 +left +BackgroundTrans,to
	gui afb:add, text,x305 y156 +left +BackgroundTrans,Hours
	IniRead, AFBDiceLimit, settings\nm_config.ini, Boost, AFBDiceLimit
	IniRead, AFBGlitterLimit, settings\nm_config.ini, Boost, AFBGlitterLimit
	IniRead, AFBHoursLimitNum, settings\nm_config.ini, Boost, AFBHoursLimit
	Gui, afb:Add, Edit, x255 y88 w45 h20 limit6 number vAFBDiceLimit gnm_saveAFBConfig, %AFBDiceLimit%
	Gui, afb:Add, Edit, x255 y110 w45 h20 limit6 number vAFBGlitterLimit gnm_saveAFBConfig, %AFBGlitterLimit%
	gui afb:add, text,x185 y136 +left +BackgroundTrans,Deactivate Field Boosting After:
	Gui, afb:Add, Edit, x255 y152 w45 h20 limit6 vAFBHoursLimit gnm_AFBHoursLimit, %AFBHoursLimitNum%
	;gui afb:add, text,x5 y123 +left +BackgroundTrans,________________________________________________________
	if(not AFBDiceEnable){
		GuiControl afb:disable, AFBDiceHotbar
		GuiControl afb:disable, AFBDiceLimitEnableSel
		GuiControl afb:disable, AFBDiceLimit
	}
	if(not AFBGlitterEnable){
		GuiControl afb:disable, AFBGlitterHotbar
		GuiControl afb:disable, AFBGlitterLimitEnableSel
		GuiControl afb:disable, AFBGlitterLimit
	}
	if(not AFBDiceLimitEnable)
		GuiControl afb:disable, AFBDiceLimit
	if(not AFBGlitterLimitEnable)
		GuiControl afb:disable, AFBGlitterLimit
	if(not AFBHoursLimitEnable)
		GuiControl afb:disable, AFBHoursLimit


	Gui afb:show,,Auto Field Boost Settings
}
nm_AFBHelpButton(){
	msgbox, 0, Auto Field Boost Description,PURPOSE:`nThis option will use the selected Dice, Glitter, and Field Boosters automatically to build and maintain a field boost for your current gathering field (as defined in the Main tab).`n`nTHIS DOES NOT:`n* quickly build your boost multiplier up to x4.  If this is what you want then it is best to manually do this before using this feature.`n* use items from your inventory.  You must include the Dice and Glitter on your hotbar and make sure the slots match the settings.`n`nHOW IT WORKS:`nThis field boost will be Re-buffed at the interval defined in the settings.  It will use the items that are selected in the following priority: 1) Free Field Booster, 2) Dice, 3) Glitter.  The Dice and Glitter item uses will be alternated so it can stack field boosts.  If there are any deactivation limits set, this option will disable itself once both the Dice and Glitter or the Hours limits have been reached.`n`nRECOMMENDATIONS:`nIt is highly recommended to disable all other macro options except your gathering field.  This will ensure you are actually benefiting from the use of your materials!`n`nPlease reference the various "?" buttons for additional information.
}
nm_AFBRebuffHelpButton(){
	msgbox, 0, Re-Buff Field Boost, This setting defines the time interval between each Field Boost buff.
}
nm_AFBDiceEnableHelpButton(){
	msgbox, 0, Enable Dice Use, This setting indicates if you would like to use Field Dice (NOT Smooth or Loaded) to boost your current gathering field.  The Hotbar Slot indicates which slot on your hotbar contains these dice.`n`nThese Dice will be re-rolled until your your gathering field is boosted.  If Glitter is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.`n`nCAUTION!!`nThis can use up a lot of dice quickly!  If you would like to limit the number of dice used for this, then make sure to set a limit for them in the DEACTIVATION LIMITS.
}
nm_AFBGlitterEnableHelpButton(){
	msgbox, 0, Enable Glitter Use, This setting indicates if you would like to use Glitter to boost your current gathering field. The Hotbar Slot indicates which slot on your hotbar contains these dice.`n`nThe macro will only attempt to use Glitter if you are currently in the field.  If Dice is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.
}
nm_AFBFieldEnableHelpButton(){
	msgbox, 0, Enable Free Field Booster Use, This setting indicates if you would like to use the Free Field Boosters (Blue, Red, or Mountain Top) to boost your current gathering field.`n`nThe macro will determine which Field Booster applies for your current gathering field and will use the Free Field Booster first if it available.  If this does not boost your gathering field, the macro will use Dice or Glitter instead (if enabled in settings).
}
nm_AFBDeactivationLimitsHelpButton(){
	msgbox, 0, Deactivation Limits, This settings are limits that you can set to deactivate (turn off) Auto Field Boost.`n`nIf any of the limits defined are met, then Auto Field Boost will be deactivated.
}
nm_AFBDiceLimitEnableHelpButton(){
	msgbox, 0, Dice Limit Deactivation, The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of dice are used.`n`nThe setting of "None" indicates that there is no Dice use limit.  The macro will continue to use Dice for as long as Auto Field Boost is enabled.`n`nNOTE:`nThe counter for the used Dice is reset each time you activate Auto Field Boost, enable Dice, or press the Reset Used: 'Dice' button.
}
nm_AFBGlitterLimitEnableHelpButton(){
	msgbox, 0, Glitter Limit Deactivation, The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Glitter are used.`n`nThe setting of "None" indicates that there is no Glitter use limit.  The macro will continue to use Glitter for as long as Auto Field Boost is enabled.`n`nNOTE:`nThe counter for the used Glitter is reset each time you activate Auto Field Boost, enable Glitter, or press the Reset Used: 'Glitter' button.
}
nm_AFBHoursLimitEnableHelpButton(){
	msgbox, 0, Hours Limit Deactivation, The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Hours have elapsed since starting the macro.`n`nThe setting of "None" indicates that there is no Hours limit.  The macro will continue use Dice and/or Glitter (if enabled in settings) for as long as Auto Field Boost is enabled.`n`nNOTE:`nThe counter for the elapsed Hours is reset each time you stop the macro (F3).
}
nm_resetUsedDice(){
	global AFBdiceUsed
	AFBdiceUsed:=0
	IniWrite, %AFBdiceUsed%, settings\nm_config.ini, Boost, AFBdiceUsed
}
nm_resetUsedGlitter(){
	IniWrite, 0, settings\nm_config.ini, Boost, AFBglitterUsed
}
nm_autoFieldBoostCheck(){
	global BoostChaserCheck
	GuiControlGet, AutoFieldBoostActive
	if(AutoFieldBoostActive){
		AutoFieldBoostActive:=0
		Guicontrol,,AutoFieldBoostActive,0
		msgbox, 1, WARNING!!,You have selected to "Activate Automatic Field Boost".`n`nIf no DEACTIVATION LIMITS are set then this option will continue to use the selected items until they are completely gone.`n`nPlease make ABSOLUTELY SURE that the settings you have selected are correct!
		IfMsgBox Ok
		{
			AutoFieldBoostActive:=1
			Guicontrol,,AutoFieldBoostActive,1
			IniWrite, 0, settings\nm_config.ini, Boost, AFBdiceUsed
			IniWrite, 0, settings\nm_config.ini, Boost, AFBglitterUsed
			BoostChaserCheck:=0
			GuiControl,1:,BoostChaserCheck, %BoostChaserCheck%
			IniWrite, %BoostChaserCheck%, settings\nm_config.ini, Boost, BoostChaserCheck
		} else {
			AutoFieldBoostActive:=0
			Guicontrol,,AutoFieldBoostActive,0
		}
	}
	IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
	if(AutoFieldBoostActive)
		GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[ON]
	else if(not AutoFieldBoostActive)
		GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
}
nm_AFBDiceEnableCheck(){
	GuiControlGet, AFBDiceEnable
	GuiControlGet, AFBDiceLimitEnableSel
	if(not AFBDiceEnable){
		GuiControl afb:disable, AFBDiceHotbar
		GuiControl afb:disable, AFBDiceLimitEnableSel
		GuiControl afb:disable, AFBDiceLimit
	} else if(AFBDiceEnable){
		GuiControl afb:enable, AFBDiceHotbar
		GuiControl afb:enable, AFBDiceLimitEnableSel
		AFBdiceUsed:=0
		IniWrite, %AFBdiceUsed%, settings\nm_config.ini, Boost, AFBdiceUsed
		if(AFBDiceLimitEnableSel="None"){
			GuiControl afb:disable, AFBDiceLimit
		} else if(AFBDiceLimitEnableSel="Limit"){
			GuiControl afb:enable, AFBDiceLimit
		}
	}
	IniWrite, %AFBDiceEnable%, settings\nm_config.ini, Boost, AFBDiceEnable
}
nm_AFBGlitterEnableCheck(){
	GuiControlGet, AFBGlitterEnable
	GuiControlGet, AFBGlitterLimitEnableSel
	if(not AFBGlitterEnable){
		GuiControl afb:disable, AFBGlitterHotbar
		GuiControl afb:disable, AFBGlitterLimitEnableSel
		GuiControl afb:disable, AFBGlitterLimit
	} else if(AFBGlitterEnable){
		GuiControl afb:enable, AFBGlitterHotbar
		GuiControl afb:enable, AFBGlitterLimitEnableSel
		AFBglitterUsed:=0
		IniWrite, %AFBglitterUsed%, settings\nm_config.ini, Boost, AFBglitterUsed
		if(AFBGlitterLimitEnableSel="None"){
			GuiControl afb:disable, AFBGlitterLimit
		} else if(AFBGlitterLimitEnableSel="Limit"){
			GuiControl afb:enable, AFBGlitterLimit
		}
	}
	IniWrite, %AFBGlitterEnable%, settings\nm_config.ini, Boost, AFBGlitterEnable
}
nm_AFBDiceLimitEnable(){
	GuiControlGet, AFBDiceLimitEnableSel
	if(AFBDiceLimitEnableSel="None"){
		GuiControl afb:disable, AFBDiceLimit
		val:=0
	} else if(AFBDiceLimitEnableSel="Limit"){
		GuiControl afb:enable, AFBDiceLimit
		val:=1
	}
	IniWrite, %val%, settings\nm_config.ini, Boost, AFBDiceLimitEnable
}
nm_AFBGlitterLimitEnable(){
	GuiControlGet, AFBGlitterLimitEnableSel
	if(AFBGlitterLimitEnableSel="None"){
		GuiControl afb:disable, AFBGlitterLimit
		val:=0
	} else if(AFBGlitterLimitEnableSel="Limit"){
		GuiControl afb:enable, AFBGlitterLimit
		val:=1
	}
	IniWrite, %val%, settings\nm_config.ini, Boost, AFBGlitterLimitEnable
}
nm_AFBHoursLimitEnable(){
	global AFBHoursLimitEnable
	GuiControlGet, AFBHoursLimitEnableSel
	if(AFBHoursLimitEnableSel="None"){
		GuiControl afb:disable, AFBHoursLimit
		val:=0
	} else if(AFBHoursLimitEnableSel="Limit"){
		GuiControl afb:enable, AFBHoursLimit
		val:=1
	}
	AFBHoursLimitEnable:=val
	IniWrite, %val%, settings\nm_config.ini, Boost, AFBHoursLimitEnable
}
nm_AFBHoursLimit(){
	global AFBHoursLimitNum
	GuiControlGet, AFBHoursLimit
	if AFBHoursLimit is number
	{
		if AFBHoursLimit>0
		{
			AFBHoursLimitNum:=AFBHoursLimit
			nm_saveAFBConfig()
		} else {
			GuiControl, Text, AFBHoursLimit, %AFBHoursLimitNum%
		}
	} else {
		GuiControl, Text, AFBHoursLimit, %AFBHoursLimitNum%
	}
}
nm_saveAFBConfig(){
	global
	GuiControlGet, AutoFieldBoostRefresh
	GuiControlGet, AFBFieldEnable
	GuiControlGet, AFBDiceLimit
	GuiControlGet, AFBGlitterLimit
	GuiControlGet, AFBHoursLimit
	GuiControlGet, AFBDiceHotbar
	GuiControlGet, AFBGlitterHotbar
	IniWrite, %AutoFieldBoostRefresh%, settings\nm_config.ini, Boost, AutoFieldBoostRefresh
	IniWrite, %AFBFieldEnable%, settings\nm_config.ini, Boost, AFBFieldEnable
	IniWrite, %AFBDiceLimit%, settings\nm_config.ini, Boost, AFBDiceLimit
	IniWrite, %AFBGlitterLimit%, settings\nm_config.ini, Boost, AFBGlitterLimit
	IniWrite, %AFBHoursLimit%, settings\nm_config.ini, Boost, AFBHoursLimit
	IniWrite, %AFBDiceHotbar%, settings\nm_config.ini, Boost, AFBDiceHotbar
	IniWrite, %AFBGlitterHotbar%, settings\nm_config.ini, Boost, AFBGlitterHotbar
}
nm_AutoFieldBoost(fieldName){
	global FieldBooster
	global AFBrollingDice
	global AFBuseGlitter
	global AFBuseBooster
	global serverStart
	global AutoFieldBoostActive
	global FieldLastBoosted
	global FieldLastBoostedBy
	global FieldBoostStacks
	global AutoFieldBoostRefresh
	global AFBHoursLimitEnable
	global AFBHoursLimit
	global AFBFieldEnable
	global AFBDiceEnable
	global AFBGlitterEnable
	if(not AutoFieldBoostActive)
		return
	if(AFBHoursLimitEnable && (nowUnix()-serverStart)>(AFBHoursLimit*60*60)){
		AutoFieldBoostActive:=0
		Guicontrol,afb:,AutoFieldBoostActive,%AutoFieldBoostActive%
		GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
		IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
		return
	}

	if(not AFBrollingDice && ((nowUnix()-FieldLastBoosted)>(AutoFieldBoostRefresh*60) || (nowUnix()-FieldLastBoosted)<0)){ ;refresh period exceeded
		;check for field boost stack reset
		if((nowUnix()-FieldLastBoosted)>=(15*60)){ ;longer than 15 mins since last boost buff
			FieldBoostStacks:=0
			FieldLastBoostedBy:="None"
			IniWrite, %FieldBoostStacks%, settings\nm_config.ini, Boost, FieldBoostStacks
			IniWrite, %FieldLastBoostedBy%, settings\nm_config.ini, Boost, FieldLastBoostedBy
		}
		;free booster first
		if(AFBFieldEnable){
			;determine which booster applies
			if(FieldBooster[fieldName].booster!="none") {
				booster:=FieldBooster[fieldName].booster
				boosterTimer:=("Last" . booster . "Boost")
				IniRead, boosterTimer, settings\nm_config.ini, Boost, %boosterTimer%
				if (nowUnix() - boosterTimer > 3600){
					AFBuseBooster:=1
				}
			}
		}
		;dice next
		if(AFBDiceEnable && not AFBrollingDice && (FieldLastBoostedBy="none" || FieldLastBoostedBy="glitter" || FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster" || (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
			AFBrollingDice:=1
			nm_setStatus(0, "Boosting Field: Dice")
		}
		;glitter next
		if(AFBGlitterEnable && not AFBrollingDice && (FieldLastBoostedBy="none" || FieldLastBoostedBy="dice" || FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")) {
			nm_setStatus(0, "Boosting Field: Glitter")
			AFBuseGlitter:=1
		}

	} else { ;refresh period NOT exceeded
		return
	}
}
nm_fieldBoostCheck(fieldName, variant:=0){
	/*
	;uncomment & edit to only allow certain fields
	if(fieldName != "Pine Tree" &&  fieldName != "Blue Flower" && fieldName != "Bamboo")
		return 0
	*/
	if(variant=0) {
		if(fieldName="Bamboo"){
			imgName:="boostbamboo0.png"
		}
		else if (fieldName="Blue Flower"){
			imgName:="boostblueflower0.png"
		}
		else if (fieldName="Cactus"){
			imgName:="boostcactus0.png"
		}
		else if (fieldName="Clover"){
			imgName:="boostclover0.png"
		}
		else if (fieldName="Coconut"){
			imgName:="boostcoconut0.png"
		}
		else if (fieldName="Dandelion"){
			imgName:="boostdandelion0.png"
		}
		else if (fieldName="Mountain Top"){
			imgName:="boostmountaintop0.png"
		}
		else if (fieldName="Mushroom"){
			imgName:="boostmushroom0.png"
		}
		else if (fieldName="Pepper"){
			imgName:="boostpepper0.png"
		}
		else if (fieldName="Pine Tree"){
			imgName:="boostpinetree0.png"
		}
		else if (fieldName="Pineapple"){
			imgName:="boostpineapple0.png"
		}
		else if (fieldName="Pumpkin"){
			imgName:="boostpumpkin0.png"
		}
		else if (fieldName="Rose"){
			imgName:="boostrose0.png"
		}
		else if (fieldName="Spider"){
			imgName:="boostspider0.png"
		}
		else if (fieldName="Strawberry"){
			imgName:="booststrawberry0.png"
		}
		else if (fieldName="Stump"){
			imgName:="booststump0.png"
		}
		else if (fieldName="Sunflower"){
			imgName:="boostsunflower0.png"
		}
		imgFound:=nm_imgSearch(imgName,50,"buff")
	} else if (variant=1) {
		if(fieldName="Bamboo"){
			imgName:="boostbamboo1.png"
		}
		else if (fieldName="Blue Flower"){
			imgName:="boostblueflower1.png"
		}
		else if (fieldName="Cactus"){
			imgName:="boostcactus1.png"
		}
		else if (fieldName="Clover"){
			imgName:="boostclover1.png"
		}
		else if (fieldName="Coconut"){
			imgName:="boostcoconut1.png"
		}
		else if (fieldName="Dandelion"){
			imgName:="boostdandelion1.png"
		}
		else if (fieldName="Mountain Top"){
			imgName:="boostmountaintop1.png"
		}
		else if (fieldName="Mushroom"){
			imgName:="boostmushroom1.png"
		}
		else if (fieldName="Pepper"){
			imgName:="boostpepper1.png"
		}
		else if (fieldName="Pine Tree"){
			imgName:="boostpinetree1.png"
		}
		else if (fieldName="Pineapple"){
			imgName:="boostpineapple1.png"
		}
		else if (fieldName="Pumpkin"){
			imgName:="boostpumpkin1.png"
		}
		else if (fieldName="Rose"){
			imgName:="boostrose1.png"
		}
		else if (fieldName="Spider"){
			imgName:="boostspider1.png"
		}
		else if (fieldName="Strawberry"){
			imgName:="booststrawberry1.png"
		}
		else if (fieldName="Stump"){
			imgName:="booststump1.png"
		}
		else if (fieldName="Sunflower"){
			imgName:="boostsunflower1.png"
		}
		imgFound:=nm_imgSearch(imgName,30,"buff")
	} else if (variant=3) {
		if(fieldName="Bamboo"){
			imgName:="boostbamboo3.png"
		}
		else if (fieldName="Blue Flower"){
			imgName:="boostblueflower3.png"
		}
		else if (fieldName="Cactus"){
			imgName:="boostcactus3.png"
		}
		else if (fieldName="Clover"){
			imgName:="boostclover3.png"
		}
		else if (fieldName="Coconut"){
			imgName:="boostcoconut3.png"
		}
		else if (fieldName="Dandelion"){
			imgName:="boostdandelion3.png"
		}
		else if (fieldName="Mountain Top"){
			imgName:="boostmountaintop3.png"
		}
		else if (fieldName="Mushroom"){
			imgName:="boostmushroom3.png"
		}
		else if (fieldName="Pepper"){
			imgName:="boostpepper3.png"
		}
		else if (fieldName="Pine Tree"){
			imgName:="boostpinetree3.png"
		}
		else if (fieldName="Pineapple"){
			imgName:="boostpineapple3.png"
		}
		else if (fieldName="Pumpkin"){
			imgName:="boostpumpkin3.png"
		}
		else if (fieldName="Rose"){
			imgName:="boostrose3.png"
		}
		else if (fieldName="Spider"){
			imgName:="boostspider3.png"
		}
		else if (fieldName="Strawberry"){
			imgName:="booststrawberry3.png"
		}
		else if (fieldName="Stump"){
			imgName:="booststump3.png"
		}
		else if (fieldName="Sunflower"){
			imgName:="boostsunflower3.png"
		}
		imgFound:=nm_imgSearch(imgName,50,"buff")
	}
	if(imgFound[1]=0){
		return 1
	} else {
		return 0
	}
}
nm_fieldBoostBooster(){
	global CurrentField
	global FieldBooster
	global AFBuseBooster
	global FieldLastBoosted
	global FieldBoostStacks
	global FieldLastBoostedBy
	global FieldNextBoostedBy
	global AFBFieldEnable
	global AFBDiceEnable
	global AFBGlitterEnable
	global FieldBoostStacks
	if (!AFBuseBooster)
		return
	nm_setStatus(0, "Boosting Field: Booster")
	if(FieldBooster[CurrentField].booster="blue") {
		boosterName:="bbooster"
		nm_toBooster("blue")
	}
	else if(FieldBooster[CurrentField].booster="red") {
		boosterName:="rbooster"
		nm_toBooster("red")
	}
	else if(FieldBooster[CurrentField].booster="mountain") {
		boosterName:="mbooster"
		nm_toBooster("mountain")
	}
	AFBuseBooster:=0
	sleep, 5000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Booster")
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:=boosterName
		IniWrite, %FieldLastBoosted%, settings\nm_config.ini, Boost, FieldLastBoosted
		IniWrite, %FieldLastBoosted%, settings\nm_config.ini, Boost, %boosterTimer%
		IniWrite, %FieldLastBoostedBy%, settings\nm_config.ini, Boost, FieldLastBoostedBy
		FieldBoostStacks:=FieldBoostStacks+FieldBooster[CurrentField].stacks
		IniWrite, %FieldBoostStacks%, settings\nm_config.ini, Boost, FieldBoostStacks
		if(FieldBoostStacks>4)
			return
	}
	;determine next boost item
	;is it dice?
	if(AFBDiceEnable && (FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"|| FieldLastBoostedBy="glitter" || (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
		FieldNextBoostedBy:="dice"
		IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
	}
	;is it glitter?
	else if(AFBGlitterEnable && (FieldLastBoostedBy="dice" || ((FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")|| not AFBDiceEnable) || (FieldLastBoostedBy="glitter" && not AFBDiceEnable))) {
		FieldNextBoostedBy:="glitter"
		IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
	}
	;is it booster?
	else if(AFBFieldEnable && not AFBDiceEnable && not AFBGlitterEnable) {
		FieldNextBoostedBy:=boosterName
		IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
	}
}
nm_fieldBoostDice(){
	global AFBrollingDice
	global AFBdiceUsed
	global AFBDiceLimit
	global AFBDiceLimitEnable
	global CurrentField
	global FieldBooster
	global boostTimer
	global FieldLastBoosted
	global FieldLastBoostedBy
	global FieldNextBoostedBy
	global FieldBoostStacks
	global AutoFieldBoostRefresh
	global AFBFieldEnable
	global AFBDiceEnable
	global AFBGlitterEnable
	global AFBDiceHotbar
	if(not nm_fieldBoostCheck(CurrentField)) {
		send % "{sc00" AFBDiceHotbar+1 "}"
		AFBdiceUsed:=AFBdiceUsed+1
		IniWrite, %AFBdiceUsed%, settings\nm_config.ini, Boost, AFBdiceUsed
		if(AFBDiceLimitEnable && AFBdiceUsed >= AFBDiceLimit) {
			AFBrollingDice:=0
			AFBDiceEnable:=0
			Guicontrol,afb:,AFBDiceEnable,%AFBDiceEnable%
			IniWrite, %AFBDiceEnable%, settings\nm_config.ini, Boost, AFBDiceEnable
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			AutoFieldBoostActive:=0
			Guicontrol,afb:,AutoFieldBoostActive,%AutoFieldBoostActive%
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
			IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
		}
	} else {
		AFBrollingDice:=0
		nm_setStatus(0, "Field was Boosted: Dice")
		if(FieldLastBoostedBy!="dice" || FieldBoostStacks=0) {
			FieldBoostStacks:=FieldBoostStacks+1
			FieldLastBoostedBy:="dice"
			IniWrite, %FieldLastBoostedBy%, settings\nm_config.ini, Boost, FieldLastBoostedBy
			IniWrite, %FieldBoostStacks%, settings\nm_config.ini, Boost, FieldBoostStacks
		}
		FieldLastBoosted:=nowUnix()
		IniWrite, %FieldLastBoosted%, settings\nm_config.ini, Boost, FieldLastBoosted
		;determine next boost item
		;is it booster?
		if(FieldBooster[currentField].booster="blue") {
			boosterName:="bbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastBlueBoost
		}
		else if(FieldBooster[currentField].booster="red") {
			boosterName:="rbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastRedBoost
		}
		else if(FieldBooster[currentField].booster="mountain") {
			boosterName:="mbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it glitter?
		else if(AFBGlitterEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it dice?
		else if(not AFBGlitterEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}
	}
}
nm_fieldBoostGlitter(){
	global AFBuseGlitter
	global AFBglitterUsed
	global CurrentField
	global FieldBooster
	global boostTimer
	global FieldLastBoosted
	global FieldLastBoostedBy
	global FieldNextBoostedBy
	global FieldBoostStacks
	global AutoFieldBoostRefresh
	global AFBFieldEnable
	global AFBDiceEnable
	global AFBGlitterEnable
	global AFBdiceHotbar
	global AFBGlitterHotbar
	global AFBGlitterLimit
	global AFBGlitterLimitEnable
	if(not AFBuseGlitter)
		return
	send % "{sc00" AFBGlitterHotbar+1 "}"
	sleep, 2000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Glitter")
		AFBglitterUsed:=AFBglitterUsed+1
		IniWrite, %AFBglitterUsed%, settings\nm_config.ini, Boost, AFBglitterUsed
		if(AFBGlitterLimitEnable && AFBglitterUsed >= AFBglitterLimit) {
			AFBGlitterEnable:=0
			Guicontrol,afb:,AFBGlitterEnable,%AFBGlitterEnable%
			IniWrite, %AFBGlitterEnable%, settings\nm_config.ini, Boost, AFBGlitterEnable
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			AutoFieldBoostActive:=0
			Guicontrol,afb:,AutoFieldBoostActive,%AutoFieldBoostActive%
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
			IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
		}
		AFBuseGlitter:=0
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:="glitter"
		IniWrite, %FieldLastBoosted%, settings\nm_config.ini, Boost, FieldLastBoosted
		IniWrite, %FieldLastBoostedBy%, settings\nm_config.ini, Boost, FieldLastBoostedBy
		FieldBoostStacks:=FieldBoostStacks+1
		IniWrite, %FieldBoostStacks%, settings\nm_config.ini, Boost, FieldBoostStacks
		;determine next boost item
		;is it booster?
		if(FieldBooster[currentField].booster="blue") {
			boosterName:="bbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastBlueBoost
		}
		else if(FieldBooster[currentField].booster="red") {
			boosterName:="rbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastRedBoost
		}
		else if(FieldBooster[currentField].booster="mountain") {
			boosterName:="mbooster"
			IniRead, boostTimer, settings\nm_config.ini, Collect, LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it dice?
		else if(AFBDiceEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it glitter?
		else if(not AFBDiceEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite, %FieldNextBoostedBy%, settings\nm_config.ini, Boost, FieldNextBoostedBy
		}

	}
}
;;;;; END AFB

nm_SaveGui(){
	global hGUI, GuiX, GuiY
	VarSetCapacity(wp, 44), NumPut(44, wp)
    DllCall("GetWindowPlacement", "uint", hGUI, "uint", &wp)
	x := NumGet(wp, 28, "int"), y := NumGet(wp, 32, "int")
	if (x > 0)
		IniWrite, %x%, settings\nm_config.ini, Settings, GuiX
	if (y > 0)
		IniWrite, %y%, settings\nm_config.ini, Settings, GuiY
}
nm_moveSpeed(hMS){
	global MoveSpeedNum
	ControlGet, p, CurrentCol, , , ahk_id %hMS%
	GuiControlGet, NewMoveSpeed, , %hMS%
	StrReplace(NewMoveSpeed, ".", , n)

    if (NewMoveSpeed ~= "[^\d\.]" || (n > 1)) ; contains char other than digit or dpt, or more than 1 dpt
	{
        GuiControl, , %hMS%, %MoveSpeedNum%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hMS%
    }
    else
	{
		MoveSpeedNum := NewMoveSpeed
		IniWrite, %MoveSpeedNum%, settings\nm_config.ini, Settings, MoveSpeedNum
	}
}
nm_HiveBees(hEdit){
	global HiveBees
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewHiveBees, , %hEdit%

    if (NewHiveBees ~= "[^\d]" || (NewHiveBees > 50)) ; contains char other than digit, or more than 50
	{
        GuiControl, , %hEdit%, %HiveBees%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "You cannot enter a number above 50!")
    }
    else
	{
		HiveBees := NewHiveBees
		IniWrite, %HiveBees%, settings\nm_config.ini, Settings, HiveBees
	}
}
nm_MonsterRespawnTime(hEdit){
	global MonsterRespawnTime
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewMonsterRespawnTime, , %hEdit%

    if (NewMonsterRespawnTime ~= "[^\d]" || (NewMonsterRespawnTime > 40)) ; contains char other than digit, or more than 40
	{
        GuiControl, , %hEdit%, %MonsterRespawnTime%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "You cannot enter a number above 40!")
    }
    else
	{
		MonsterRespawnTime := NewMonsterRespawnTime
		IniWrite, %MonsterRespawnTime%, settings\nm_config.ini, Collect, MonsterRespawnTime
	}
}
nm_ResetConfig(){
	Gui, +OwnDialogs
	msgbox, 0x40034, Reset Settings, Are you sure you want to reset ALL Natro settings? This will set all settings (Gather, Planters, Boost, Quests, etc.) to the default AND reset all timers (Collect/Kill, Planters, etc.), as if you freshly started the macro.`n`nIf you want to proceed, click 'Yes'. Backup your 'settings' folder if you're unsure.
	IfMsgBox, Yes
	{
		FileRemoveDir, %A_ScriptDir%\settings, 1
		GoSub, stop
	}
}
nm_ResetFieldDefaultGUI(){
	global
	local x,y,i,k,v,hBM
	Gui, fielddefault:Destroy
	Gui, fielddefault:+AlwaysOnTop +Owner
	Gui, fielddefault:Font, s9 cDefault Norm, Tahoma
	i := 0
	for k,v in StandardFieldDefault
	{
		i++
		x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
		Gui, fielddefault:Add, Button, % "x" x " y" y " w100 h20 vResetFieldDefault" i " gnm_ResetFieldDefault", %k%
	}
	i++
	x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["allfields"])
	Gui, fielddefault:Add, Picture, % "x" x " y" y " w100 h20 gnm_ResetAllFieldDefaults", HBITMAP:*%hBM%
	DllCall("DeleteObject", "ptr", hBM)
	Gui, fielddefault:Show, , Reset Field Defaults
}
nm_ResetFieldDefault(hCtrl){
	global FieldDefault, StandardFieldDefault
	Gui, +OwnDialogs
	GuiControlGet, name, Name, %hCtrl%
	n := SubStr(name, 18) ; ResetFieldDefault
	for k,v in StandardFieldDefault
	{
		if (A_Index = n)
		{
			msgbox, 0x40034, Reset Field Defaults, % "Reset " k " default settings to these standard settings?`n`n"
				. "Pattern Shape: " v["pattern"] "`n"
				. "Pattern Length: " v["size"] "`n"
				. "Pattern Width: " v["width"] "`n"
				. "Pattern Invert F/B: " (v["invertFB"] ? "Enabled" : "Disabled") "`n"
				. "Pattern Invert L/R: " (v["invertLR"] ? "Enabled" : "Disabled") "`n"
				. "Shift-Lock: " (v["shiftlock"] ? "Enabled" : "Disabled") "`n`n"
				. "Until Mins: " v["gathertime"] "`n"
				. "Until Pack: " v["percent"] "%`n"
				. "To Hive By: " v["convert"] "`n`n"
				. "Rotate Camera Direction: " v["camera"] "`n"
				. "Rotate Camera Turns: " v["turns"] "`n`n"
				. "Sprinkler Location: " v["sprinkler"] "`n"
				. "Sprinkler Distance: " v["distance"]

			IfMsgBox, Yes
			{
				FieldDefault[k]["pattern"]:=v["pattern"]
				FieldDefault[k]["size"]:=v["size"]
				FieldDefault[k]["width"]:=v["width"]
				FieldDefault[k]["shiftlock"]:=v["shiftlock"]
				FieldDefault[k]["invertFB"]:=v["invertFB"]
				FieldDefault[k]["invertLR"]:=v["invertLR"]
				FieldDefault[k]["gathertime"]:=v["gathertime"]
				FieldDefault[k]["percent"]:=v["percent"]
				FieldDefault[k]["convert"]:=v["convert"]
				FieldDefault[k]["sprinkler"]:=v["sprinkler"]
				FieldDefault[k]["distance"]:=v["distance"]
				FieldDefault[k]["camera"]:=v["camera"]
				FieldDefault[k]["turns"]:=v["turns"]
				FieldDefault[k]["drift"]:=v["drift"]
				for i,j in FieldDefault[k]
					IniWrite, %j%, settings\field_config.ini, %k%, %i%
				msgbox, 0x40040, Reset Field Defaults, Changed %k% field defaults back to their standard settings!
			}

			break
		}
	}
}
nm_ResetAllFieldDefaults(hCtrl){
	global FieldDefault, StandardFieldDefault
	Gui, +OwnDialogs
	msgbox, 0x40034, Reset Field Defaults, Are you sure you want to reset all field default settings to their standard settings?
	IfMsgBox, Yes
	{
		msgbox, 0x40034, Reset Field Defaults, ARE YOU SUPER DUPER SURE?
		IfMsgBox, Yes
		{
			ini := ""
			for k,v in StandardFieldDefault
			{
				ini .= "[" k "]`r`n"
				for i,j in v
				{
					FieldDefault[k][i] := j
					ini .= i "=" j "`r`n"
				}
				ini .= "`r`n"
			}

			file := FileOpen(A_ScriptDir "\settings\field_config.ini", "w-d"), file.Write(ini), file.Close()

			msgbox, 0x40040, Reset Field Defaults, Changed all field defaults back to their standard settings!
		}
	}
}
nm_DebugLogGUI(){
	global
	Gui, debuglog:Destroy
	Gui, debuglog:+AlwaysOnTop +Owner
	Gui, debuglog:Font, s8 cDefault Norm, Tahoma
	Gui, debuglog:Add, Checkbox, x10 y6 vDebugLogEnabled Checked%DebugLogEnabled% gnm_DebugLogCheck, Enable Debug Logging
	Gui, debuglog:Add, Button, xp+140 y5 h16 gnm_GotoDebugLogButton, Go To File
	Gui, debuglog:Show, , Debug Log Options
}
nm_DebugLogCheck(){
	global DebugLogEnabled
	GuiControlGet, DebugLogEnabled
	IniWrite, %DebugLogEnabled%, settings\nm_config.ini, Status, DebugLogEnabled
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 222, DebugLogEnabled
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
}
nm_testReconnect(){
	CloseRoblox()
	if (DisconnectCheck(1) = 1)
		msgbox success
}
nm_GotoDebugLogButton(){
	Run, % "explorer.exe /e`, /n`, /select`," A_ScriptDir "\settings\debug_log.txt"
}
nm_HotkeyGUI(){
	global
	Gui, hotkeys:Destroy
	Gui, hotkeys:+AlwaysOnTop +Owner%hGUI% -MinimizeBox
	Gui, hotkeys:Font, s8 cDefault Bold, Tahoma
	Gui, hotkeys:Add, GroupBox, x5 y2 w190 h144, Change Hotkeys
	Gui, hotkeys:Add, GroupBox, x5 y146 w190 h34, Settings
	Gui, hotkeys:Font, Norm
	Gui, hotkeys:Add, Text, x10 y23 w60 +left +BackgroundTrans,Start:
	Gui, hotkeys:Add, Text, x10 yp+19 w60 +left +BackgroundTrans,Pause:
	Gui, hotkeys:Add, Text, x10 yp+19 w60 +left +BackgroundTrans,Stop:
	Gui, hotkeys:Add, Text, x10 yp+19 w60 +left +BackgroundTrans,AutoClicker:
	Gui, hotkeys:Add, Text, x10 yp+19 w60 +left +BackgroundTrans,Timers:
	Gui, hotkeys:Add, Hotkey, x70 y20 w120 h18 vStartHotkeyEdit gnm_saveHotkey, %StartHotkey%
	Gui, hotkeys:Add, Hotkey, x70 yp+19 w120 h18 vPauseHotkeyEdit gnm_saveHotkey, %PauseHotkey%
	Gui, hotkeys:Add, Hotkey, x70 yp+19 w120 h18 vStopHotkeyEdit gnm_saveHotkey, %StopHotkey%
	Gui, hotkeys:Add, Hotkey, x70 yp+19 w120 h18 vAutoClickerHotkeyEdit gnm_saveHotkey, %AutoClickerHotkey%
	Gui, hotkeys:Add, Hotkey, x70 yp+19 w120 h18 vTimersHotkeyEdit gnm_saveHotkey, %TimersHotkey%
	Gui, hotkeys:Add, Button, x30 yp+24 w140 h20 gnm_ResetHotkeys, Restore Defaults
	Gui, hotkeys:Add, CheckBox, x10 y162 gnm_saveHotkeyConfig vShowOnPause Checked%ShowOnPause%, Show Natro on Pause
	Gui, hotkeys:Show, w200, Hotkeys
}
nm_ResetHotkeys(){
	global
	Hotkey, %StartHotkey%, start, UseErrorLevel Off
	Hotkey, %PauseHotkey%, pause, UseErrorLevel Off
	Hotkey, %StopHotkey%, stop, UseErrorLevel Off
	Hotkey, %AutoClickerHotkey%, autoclicker, UseErrorLevel Off
	Hotkey, %TimersHotkey%, timers, UseErrorLevel Off
	IniWrite, % (StartHotkey := "F1"), settings\nm_config.ini, Settings, StartHotkey
	IniWrite, % (PauseHotkey := "F2"), settings\nm_config.ini, Settings, PauseHotkey
	IniWrite, % (StopHotkey := "F3"), settings\nm_config.ini, Settings, StopHotkey
	IniWrite, % (AutoClickerHotkey := "F4"), settings\nm_config.ini, Settings, AutoClickerHotkey
	IniWrite, % (TimersHotkey := "F5"), settings\nm_config.ini, Settings, TimersHotkey
	GuiControl, hotkeys:, StartHotkeyEdit, F1
	GuiControl, hotkeys:, PauseHotkeyEdit, F2
	GuiControl, hotkeys:, StopHotkeyEdit, F3
	GuiControl, hotkeys:, AutoClickerHotkeyEdit, F4
	GuiControl, hotkeys:, TimersHotkeyEdit, F5
	GuiControl, %hGUI%:, StartButton, % " Start (F1)"
	GuiControl, %hGUI%:, PauseButton, % " Pause (F2)"
	GuiControl, %hGUI%:, StopButton, % " Stop (F3)"
	GuiControl, %hGUI%:, AutoClickerButton, % "AutoClicker (F4)"
	GuiControl, %hGUI%:, TimersButton, % " Show Timers (F5)"
	Hotkey, %StartHotkey%, start, UseErrorLevel On
	Hotkey, %PauseHotkey%, pause, UseErrorLevel On
	Hotkey, %StopHotkey%, stop, UseErrorLevel On
	Hotkey, %AutoClickerHotkey%, autoclicker, UseErrorLevel On T2
	Hotkey, %TimersHotkey%, timers, UseErrorLevel On
}
nm_saveHotkey(hCtrl){
	global
	local k, v, l, NewHotkey
	Gui +OwnDialogs
	GuiControlGet, k, Name, %hCtrl%

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$")
	{
		; do not allow necessary keys
		switch % Format("sc{:03X}", GetKeySC(%k%))
		{
			case FwdKey,LeftKey,BackKey,RightKey,RotLeft,RotRight,RotUp,RotDown,ZoomIn,ZoomOut,SC_E,SC_R,SC_L,SC_Esc,SC_Enter,SC_LShift,SC_Space:
			GuiControl, , %hCtrl%, % %v%
			msgbox, 0x1030, Unacceptable Hotkey!, % "That hotkey cannot be used!`nThe key is already used elsewhere in the macro."
			return

			case SC_1,"sc003","sc004","sc005","sc006","sc007","sc008":
			GuiControl, , %hCtrl%, % %v%
			msgbox, 0x1030, Unacceptable Hotkey!, % "That hotkey cannot be used!`nIt will be required to use your hotbar slots."
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = AutoClickerHotkey) || (%k% = TimersHotkey)) ; do not allow empty or already used hotkey (not necessary in most cases)
			GuiControl, , %hCtrl%, % %v%
		else ; update the hotkey
		{
			l := StrReplace(v, "Hotkey")
			Hotkey, % %v%, %l%, UseErrorLevel Off
			IniWrite, % (%v% := %k%), settings\nm_config.ini, Settings, %v%
			GuiControl, %hGUI%:, %l%Button, % ((l = "Timers") ? " Show " : (l = "AutoClicker") ? "" : " ") l " (" %v% ")"
			Hotkey, % %v%, %l%, % ("UseErrorLevel On" (v = "AutoClickerHotkey" ? " T2" : ""))
		}
	}
}
nm_saveHotkeyConfig(){
	global
	GuiControlGet, ShowOnPause
	IniWrite, %ShowOnPause%, settings\nm_config.ini, Settings, ShowOnPause
}
nm_saveConfig(){
	global
	GuiControlGet, HiveSlot
	GuiControlGet, MoveMethod
	GuiControlGet, SprinklerType
	GuiControlGet, MultiReset
	GuiControlGet, ConvertMins
	GuiControlGet, GatherDoubleReset
	GuiControlGet, DisableToolUse
	GuiControlGet, AnnounceGuidingStar
	GuiControlGet, NewWalk
	GuiControlGet, ConvertDelay
	GuiControlGet, ReconnectMessage
	GuiControlGet, PublicFallback
	IniWrite, %HiveSlot%, settings\nm_config.ini, Settings, HiveSlot
	IniWrite, %MoveMethod%, settings\nm_config.ini, Settings, MoveMethod
	IniWrite, %SprinklerType%, settings\nm_config.ini, Settings, SprinklerType
	IniWrite, %MultiReset%, settings\nm_config.ini, Settings, MultiReset
	IniWrite, %ConvertMins%, settings\nm_config.ini, Settings, ConvertMins
	IniWrite, %GatherDoubleReset%, settings\nm_config.ini, Settings, GatherDoubleReset
	IniWrite, %DisableToolUse%, settings\nm_config.ini, Settings, DisableToolUse
	IniWrite, %AnnounceGuidingStar%, settings\nm_config.ini, Settings, AnnounceGuidingStar
	IniWrite, %NewWalk%, settings\nm_config.ini, Settings, NewWalk
	IniWrite, %ConvertDelay%, settings\nm_config.ini, Settings, ConvertDelay
	IniWrite, %ReconnectMessage%, settings\nm_config.ini, Settings, ReconnectMessage
	IniWrite, %PublicFallback%, settings\nm_config.ini, Settings, PublicFallback
}
nm_convertBalloon(){
	global ConvertBalloon, ConvertMins
	GuiControlGet, ConvertBalloon
	if(ConvertBalloon="Every") {
		GuiControl, enable, ConvertMins
	} else {
		GuiControl, disable, ConvertMins
	}
	IniWrite, %ConvertBalloon%, settings\nm_config.ini, Settings, ConvertBalloon
}
nm_guiThemeSelect(){
	GuiControlGet, GuiTheme
	IniWrite, %GuiTheme%, settings\nm_config.ini, Settings, GuiTheme
	reload
	Sleep, 10000
}
nm_guiTransparencySet(){
	GuiControlGet, GuiTransparency
	IniWrite, %GuiTransparency%, settings\nm_config.ini, Settings, GuiTransparency
	setVal:=255-floor(GuiTransparency*2.55)
	winset, transparent, %setval%, Natro Macro
}
nm_AlwaysOnTop(){
	GuiControlGet, AlwaysOnTop
	IniWrite, %AlwaysOnTop%, settings\nm_config.ini, Settings, AlwaysOnTop
	if(AlwaysOnTop)
		Gui +AlwaysOnTop
	else
		Gui -AlwaysOnTop
}
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
SkinForm(Param1 = "Apply", DLL = "", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLL)
		DllCall(DLL . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}
    else if(Param1 = 0){
		DllCall(DLL . "\USkinExit")
	}
}
nm_ServerLink(hEdit){
	global PrivServer, FallbackServer1, FallbackServer2, FallbackServer3
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, k, Name, %hEdit%
	GuiControlGet, str, , %hEdit%

	RegExMatch(str, "i)((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*", NewPrivServer)
    if ((StrLen(str) > 0) && (StrLen(NewPrivServer) = 0))
	{
        GuiControl, , %hEdit%, % %k%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Invalid Private Server Link", "Make sure your link is:`r`n- copied correctly and completely`r`n- for Bee Swarm Simulator by Onett")
    }
    else
	{
		%k% := NewPrivServer
		GuiControl, , %hEdit%, % %k%
		IniWrite, % %k%, settings\nm_config.ini, Settings, %k%

		if (k = "PrivServer")
		{
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("Status.ahk ahk_class AutoHotkey")
				PostMessage, 0x5553, 10, 7
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
		}
	}
}
nm_setReconnectInterval(hEdit){
	global ReconnectInterval
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewReconnectInterval, , %hEdit%

    if (((Mod(24, NewReconnectInterval) != 0) && NewReconnectInterval) || (NewReconnectInterval = 0)) ; not a factor of 24 or 0
	{
        GuiControl, , %hEdit%, %ReconnectInterval%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "Reconnect Interval must be a factor of 24!`r`nThese are: 1, 2, 3, 4, 6, 8, 12, 24.")
    }
    else
	{
		ReconnectInterval := NewReconnectInterval
		IniWrite, %ReconnectInterval%, settings\nm_config.ini, Settings, ReconnectInterval
	}
}
nm_setReconnectHour(hEdit){
	global ReconnectHour
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewReconnectHour, , %hEdit%

    if ((NewReconnectHour > 23) && (NewReconnectHour != "")) ; not between 00 and 24
	{
        GuiControl, , %hEdit%, %ReconnectHour%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "Reconnect Hour must be between 00 and 23!")
    }
    else
	{
		ReconnectHour := NewReconnectHour
		IniWrite, %ReconnectHour%, settings\nm_config.ini, Settings, ReconnectHour
	}
}
nm_setReconnectMin(hEdit){
	global ReconnectMin
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewReconnectMin, , %hEdit%

    if ((NewReconnectMin > 59) && (NewReconnectMin != "")) ; not between 00 and 59
	{
        GuiControl, , %hEdit%, %ReconnectMin%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		nm_ShowErrorBalloonTip(hEdit, "Unacceptable Number", "Reconnect Minute must be between 00 and 59!")
    }
    else
	{
		ReconnectMin := NewReconnectMin
		IniWrite, %ReconnectMin%, settings\nm_config.ini, Settings, ReconnectMin
	}
}
nm_WebhookGUI(){
	global
	local script, exec, shell

	Process, Close, %WGUIPID%

	script := "
	(Join`r`n
	#NoEnv
	#NoTrayIcon
	#SingleInstance Force
	#Requires AutoHotkey v1.1.36.01+
	#MaxThreads 255
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	#Include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk

	SetWorkingDir %A_ScriptDir%
	SetBatchLines -1
	DetectHiddenWindows, On
	SetTitleMatchMode, 2

	pToken := Gdip_Startup()

	bitmaps := {}

	#Include %A_ScriptDir%\nm_image_assets\webhook_gui\bitmaps.ahk

	; config
	discordMode := """ discordMode """
	discordCheck := """ discordCheck """

	webhook := """ webhook """
	bottoken := """ bottoken """

	MainChannelCheck := """ MainChannelCheck """
	MainChannelID := """ MainChannelID """
	ReportChannelCheck := """ ReportChannelCheck """
	ReportChannelID := """ ReportChannelID """

	ssCheck := """ ssCheck """
	CriticalSSCheck := """ CriticalSSCheck """
	AmuletSSCheck := """ AmuletSSCheck """
	MachineSSCheck := """ MachineSSCheck """
	BalloonSSCheck := """ BalloonSSCheck """
	ViciousSSCheck := """ ViciousSSCheck """
	DeathSSCheck := """ DeathSSCheck """
	PlanterSSCheck := """ PlanterSSCheck """
	HoneySSCheck := """ HoneySSCheck """

	criticalCheck := """ criticalCheck """
	discordUID := """ discordUID """
	CriticalErrorPingCheck := """ CriticalErrorPingCheck """
	DisconnectPingCheck := """ DisconnectPingCheck """
	GameFrozenPingCheck := """ GameFrozenPingCheck """
	PhantomPingCheck := """ PhantomPingCheck """
	UnexpectedDeathPingCheck := """ UnexpectedDeathPingCheck """
	EmergencyBalloonPingCheck := """ EmergencyBalloonPingCheck """

	enum := {""discordMode"":1
		, ""discordCheck"":2
		, ""MainChannelCheck"":3
		, ""ReportChannelCheck"":4
		, ""ssCheck"":6
		, ""CriticalSSCheck"":8
		, ""AmuletSSCheck"":9
		, ""MachineSSCheck"":10
		, ""BalloonSSCheck"":11
		, ""ViciousSSCheck"":12
		, ""DeathSSCheck"":13
		, ""PlanterSSCheck"":14
		, ""HoneySSCheck"":15
		, ""criticalCheck"":16
		, ""CriticalErrorPingCheck"":17
		, ""DisconnectPingCheck"":18
		, ""GameFrozenPingCheck"":19
		, ""PhantomPingCheck"":20
		, ""UnexpectedDeathPingCheck"":21
		, ""EmergencyBalloonPingCheck"":22}

	str_enum := {""webhook"":1
		, ""bottoken"":2
		, ""MainChannelID"":3
		, ""ReportChannelID"":4
		, ""discordUID"":5}

	w := 500, h := 480
	Gui, New, -Caption +E0x80000 +E0x8000000 +hwndhMain +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale
	Gui, Show, NA
	Gui, % hMain "":Add"", Text, % ""x8 y0 w"" w-16 "" h32 hwndhTitle""
	Gui, % hMain "":Add"", Text, % ""x18 y5 w32 h24 hwndhChangeMode""
	Gui, % hMain "":Add"", Text, % ""x"" w-42 "" y4 w26 h26 hwndhClose""

	for k,v in enum
		if (v != 1)
			Gui, % hMain "":Add"", Text, % ""Hidden v"" k "" hwndh"" k
	Gui, % hMain "":Add"", Text, % ""Hidden hwndhCopyDiscord""
	Gui, % hMain "":Add"", Text, % ""Hidden hwndhPasteDiscord""
	Gui, % hMain "":Add"", Text, % ""Hidden hwndhPasteMainID""
	Gui, % hMain "":Add"", Text, % ""Hidden hwndhPasteReportID""
	Gui, % hMain "":Add"", Text, % ""Hidden hwndhPasteUserID""

	; setup
	hbm := CreateDIBSection(w, h)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 2)
	Gdip_SetInterpolationMode(G, 2)
	UpdateLayeredWindow(hMain, hdc, (A_ScreenWidth-w)//2, (A_ScreenHeight-h+80*(!discordMode))//2, w, h-80*(!discordMode))
	nm_WebhookGUI()
	return

	GuiEscape:
	GuiClose:
	ExitApp

	nm_WebhookGUI()
	{
		global
		local k,v,x,y,w,h,str
		static ss_list := [""critical"",""amulet"",""machine"",""balloon"",""vicious"",""death"",""planter"",""honey""]
		static ping_list := [""criticalerror"",""disconnect"",""gamefrozen"",""phantom"",""unexpecteddeath"",""emergencyballoon""]

		Gdip_GraphicsClear(G)
		w := 500, h := 400 + discordMode * 80

		; edge shadow
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h, 0x00000000, 0x78000000), 14, 6, w-16, h-16, 12), Gdip_DeleteBrush(pBrush)

		; title bar and control
		pBrush := Gdip_BrushCreateSolid(0xff5865f2), Gdip_FillRoundedRectanglePath(G, pBrush, 8, 0, w-16, 30, 12), Gdip_FillRectangle(G, pBrush, 8, 13, w-16, 20), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps[""logo_mode"" discordMode], 18, 5)
		Gdip_DrawImage(G, bitmaps[""text_mode"" discordMode], w//2 - Gdip_GetImageWidth(bitmaps[""text_mode"" discordMode])//2, 9)
		Gdip_DrawImage(G, bitmaps[""close""], w-42, 4)

		; main background
		pBrush := Gdip_BrushCreateSolid(0xff131416)
		Gdip_FillRectangle(G, pBrush, 8, 32, w-16, h-80), Gdip_FillRoundedRectanglePath(G, pBrush, 8, h-100, w-16, 84, 12)
		Gdip_DeleteBrush(pBrush)

		; webhook url / bot token
		Gdip_DrawImage(G, bitmaps[(discordMode = 0) ? ""text_webhookurl"" : ""text_bottoken""], 22, 47)
		x := 30 + Gdip_GetImageWidth(bitmaps[(discordMode = 0) ? ""text_webhookurl"" : ""text_bottoken""])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(discordCheck ? 0xff4bb543 : 0xffff3333), x, 42, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (discordCheck ? 19 : 3), 45, 18), Gdip_DeleteBrush(pBrush)
		GuiControl, Move, % hDiscordCheck, % ""x"" x "" y42 w40 h24""
		GuiControl, Show, % hDiscordCheck
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), 20, 72, w-40, 50, 20), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(0xff222932)
		Gdip_FillRoundedRectanglePath(G, pBrush, 20, 72, w-136, 50, 20), Gdip_FillRectangle(G, pBrush, w-148, 72, 32, 50)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawOrientedString(G, str := (discordMode = 0) ? webhook : bottoken, ""Calibri"", (StrLen(str) < 56) ? 19 : (StrLen(str) < 84) ? 17 : 13, 1, 32, 72 + 3 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), w-160, 50 - 6 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps[""copy""], w-110, 72)
		GuiControl, Move, % hCopyDiscord, % ""x"" w-106 "" y72 w32 h50""
		GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hCopyDiscord
		Gdip_DrawImage(G, bitmaps[""paste""], w-65, 72)
		GuiControl, Move, % hPasteDiscord, % ""x"" w-61 "" y72 w32 h50""
		GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hPasteDiscord


		; channel ids
		if (discordMode = 1)
		{
			if MainChannelCheck
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), 24, 130, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], 25, 131)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), 25, 131, 18, 18, 4), Gdip_DeletePen(pPen)
			GuiControl, Move, % hMainChannelCheck, % ""x"" 25 "" y"" 131 "" w18 h18""
			GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hMainChannelCheck
			Gdip_DrawImage(G, bitmaps[""text_mainchannelid""], 52, 134)
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), 22, 158, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
			pBrush := Gdip_BrushCreateSolid(0xff222932)
			Gdip_FillRoundedRectanglePath(G, pBrush, 22, 158, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w//2-86, 158, 32, 40)
			Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, MainChannelID, ""Calibri"", 16, 1, 22, 168, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
			Gdip_DrawImage(G, bitmaps[""paste""], w//2-50, 158, 32, 40)
			GuiControl, Move, % hPasteMainID, % ""x"" w//2-47 "" y158 w26 h40""
			GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hPasteMainID

			if ReportChannelCheck
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), w//2+16, 130, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], w//2+17, 131)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), w//2+17, 131, 18, 18, 4), Gdip_DeletePen(pPen)
			GuiControl, Move, % hReportChannelCheck, % ""x"" w//2+17 "" y"" 131 "" w18 h18""
			GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hReportChannelCheck
			Gdip_DrawImage(G, bitmaps[""text_reportchannelid""], w//2+44, 134)
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), w//2+14, 158, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
			pBrush := Gdip_BrushCreateSolid(0xff222932)
			Gdip_FillRoundedRectanglePath(G, pBrush, w//2+14, 158, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w-94, 158, 32, 40)
			Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ReportChannelID, ""Calibri"", 16, 1, w//2+14, 168, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
			Gdip_DrawImage(G, bitmaps[""paste""], w-58, 158, 32, 40)
			GuiControl, Move, % hPasteReportID, % ""x"" w-55 "" y158 w26 h40""
			GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hPasteReportID
		}
		else
		{
			GuiControl, Move, % hMainChannelCheck, x0 y0 w0 h0
			GuiControl, Move, % hReportChannelCheck, x0 y0 w0 h0
			GuiControl, Move, % hPasteMainID, x0 y0 w0 h0
			GuiControl, Move, % hPasteReportID, x0 y0 w0 h0
			GuiControl, Hide, % hMainChannelCheck
			GuiControl, Hide, % hReportChannelCheck
			GuiControl, Hide, % hPasteMainID
			GuiControl, Hide, % hPasteReportID
		}

		; screenshots
		Gdip_DrawImage(G, bitmaps[""text_screenshots""], 22, h-262)
		x := 30 + Gdip_GetImageWidth(bitmaps[""text_screenshots""])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(ssCheck ? 0xff4bb543 : 0xffff3333), x, h-266, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (ssCheck ? 19 : 3), h-263, 18), Gdip_DeleteBrush(pBrush)
		GuiControl, Move, % hSSCheck, % ""x"" x "" y"" h-266 "" w40 h24""
		GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hSSCheck
		for k,v in ss_list
		{
			if (%v%SSCheck = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), 24, h-263 + k * 26, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], 25, h-262 + k * 26)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), 25, h-262 + k * 26, 18, 18, 4), Gdip_DeletePen(pPen)
			GuiControl, Move, % h%v%SSCheck, % ""x25 y"" h-262 + k * 26 "" w18 h18""
			GuiControl, % ((discordCheck && ssCheck) ? ""Show"" : ""Hide""), % h%v%SSCheck
			Gdip_DrawImage(G, bitmaps[""text_"" v], 52, h-258 + k * 26)
		}

		; pings
		Gdip_DrawImage(G, bitmaps[""text_userid""], w//2+16, h-263)
		x := w//2+24 + Gdip_GetImageWidth(bitmaps[""text_userid""])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(criticalCheck ? 0xff4bb543 : 0xffff3333), x, h-266, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (criticalCheck ? 19 : 3), h-263, 18), Gdip_DeleteBrush(pBrush)
		GuiControl, Move, % hCriticalCheck, % ""x"" x "" y"" h-266 "" w40 h24""
		GuiControl, % (discordCheck ? ""Show"" : ""Hide""), % hCriticalCheck
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), w//2+14, h-236, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(0xff222932)
		Gdip_FillRoundedRectanglePath(G, pBrush, w//2+14, h-236, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w-94, h-236, 32, 40)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawOrientedString(G, discordUID, ""Calibri"", 16, 1, w//2+14, h-226, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps[""paste""], w-58, h-236, 32, 40)
		GuiControl, Move, % hPasteUserID, % ""x"" w-55 "" y"" h-236 "" w26 h40""
		GuiControl, % ((discordCheck && criticalCheck) ? ""Show"" : ""Hide""), % hPasteUserID
		for k,v in ping_list
		{
			if (%v%PingCheck = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), w//2+18, h-211 + k * 26, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], w//2+19, h-210 + k * 26)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), w//2+19, h-210 + k * 26, 18, 18, 4), Gdip_DeletePen(pPen)
			GuiControl, Move, % h%v%PingCheck, % ""x"" w//2+19 "" y"" h-210 + k * 26 "" w18 h18""
			GuiControl, % ((discordCheck && criticalCheck) ? ""Show"" : ""Hide""), % h%v%PingCheck
			Gdip_DrawImage(G, bitmaps[""text_"" v], w//2+46, h-206 + k * 26)
		}

		; grey out disabled options
		if (discordCheck = 0)
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), 16, 70, w-32, h-90), Gdip_DeleteBrush(pBrush)
		else
		{
			if (ssCheck = 0)
				Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), 16, h-240, w//2-24, 210), Gdip_DeleteBrush(pBrush)
			if (criticalCheck = 0)
				Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), w//2+8, h-240, w//2-24, 210), Gdip_DeleteBrush(pBrush)
		}

		UpdateLayeredWindow(hMain, hdc, , , w, h)
		OnMessage(0x201, ""WM_LBUTTONDOWN"")
		OnMessage(0x200, ""WM_MOUSEMOVE"")
		OnExit(""ExitFunc"")
	}


	)"

	script .= "
	(Join`r`n
	WM_LBUTTONDOWN()
	{
		global
		local hCtrl, k, pBrush, pPen, ctrl_x, ctrl_y, ctrl_w, ctrl_h, s, str
		MouseGetPos, , , , hCtrl, 2
		if !hCtrl
			return

		switch hCtrl
		{
			case hTitle:
			PostMessage, 0xA1, 2

			case hChangeMode:
			discordMode := !discordMode
			nm_WebhookGUI()
			UpdateInt(""discordMode"")

			case hClose:
			ReplaceSystemCursors()
			ExitApp

			case hDiscordCheck:
			discordCheck := !discordCheck
			nm_WebhookGUI()
			UpdateInt(""discordCheck"")

			case hSSCheck:
			ssCheck := !ssCheck
			nm_WebhookGUI()
			UpdateInt(""ssCheck"")

			case hCriticalCheck:
			criticalCheck := !criticalCheck
			nm_WebhookGUI()
			UpdateInt(""criticalCheck"")

			case hMainChannelCheck, hReportChannelCheck, hCriticalSSCheck, hAmuletSSCheck, hMachineSSCheck, hBalloonSSCheck, hViciousSSCheck, hDeathSSCheck, hPlanterSSCheck, hHoneySSCheck, hCriticalErrorPingCheck, hDisconnectPingCheck, hGameFrozenPingCheck, hPhantomPingCheck, hUnexpectedDeathPingCheck, hEmergencyBalloonPingCheck:
			GuiControlGet, k, Name, %hCtrl%
			ControlGetPos, ctrl_x, ctrl_y, ctrl_w, ctrl_h, , ahk_id %hCtrl%
			%k% := !%k%
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xff131416), ctrl_x-3, ctrl_y-3, ctrl_w+6, ctrl_h+6), Gdip_DeleteBrush(pBrush)
			if (%k% = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), ctrl_x-1, ctrl_y-1, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], ctrl_x, ctrl_y)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), ctrl_x, ctrl_y, 18, 18, 4), Gdip_DeletePen(pPen)
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x40131416), ctrl_x-2, ctrl_y-2, ctrl_w+4, ctrl_h+4), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			UpdateInt(k)

			case hCopyDiscord:
			ControlGetPos, , ctrl_y, , ctrl_h, , ahk_id %hCtrl%
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 21, ctrl_y+1, w-138, ctrl_h-2, 20), Gdip_FillRectangle(G, pBrush, w-148, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ""Copied to Clipboard!"", ""Calibri"", 22, 1, 32, ctrl_y+11, w-160, ctrl_h-11, 0, pBrush := Gdip_BrushCreateSolid(0xff00a000), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			clipboard := (discordMode = 0) ? webhook : bottoken
			SetTimer, nm_WebhookGUI, -1000, 1

			case hPasteDiscord:
			ControlGetPos, , ctrl_y, , ctrl_h, , ahk_id %hCtrl%
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 21, ctrl_y+1, w-138, ctrl_h-2, 20), Gdip_FillRectangle(G, pBrush, w-148, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, (s := (((discordMode = 0) && RegExMatch(clipboard, ""i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)"", str)) || ((discordMode = 1) && RegExMatch(clipboard, ""i)^[\w-.]{50,83}$"", str)))) ? (((discordMode = 0) ? webhook : bottoken) := str) : (""No valid "" ((discordMode = 0) ? ""Webhook URL"" : ""Bot Token"") "" found``nin Clipboard!""), ""Calibri"", (s = 0) ? 20 : ((StrLen(str) < 56) ? 19 : (StrLen(str) < 84) ? 17 : 13), 1, 32, ctrl_y + 3 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), w-160, ctrl_h - 6 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer, nm_WebhookGUI, -1000, 1
			(s != 0) ? UpdateStr((discordMode = 0) ? ""webhook"" : ""bottoken"")

			case hPasteMainID:
			ControlGetPos, , ctrl_y, , ctrl_h, , ahk_id %hCtrl%
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 23, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w//2-86, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, (s := RegExMatch(clipboard, ""i)^\d{17,20}$"", str)) ? (MainChannelID := str) : ""Invalid Channel ID!"", ""Calibri"", 16, 1, 22, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer, nm_WebhookGUI, -1000, 1
			(s != 0) ? UpdateStr(""MainChannelID"")

			case hPasteReportID:
			ControlGetPos, , ctrl_y, , ctrl_h, , ahk_id %hCtrl%
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), w//2+15, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w-94, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, (s := RegExMatch(clipboard, ""i)^\d{17,20}$"", str)) ? (ReportChannelID := str) : ""Invalid Channel ID!"", ""Calibri"", 16, 1, w//2+14, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer, nm_WebhookGUI, -1000, 1
			(s != 0) ? UpdateStr(""ReportChannelID"")

			case hPasteUserID:
			ControlGetPos, , ctrl_y, , ctrl_h, , ahk_id %hCtrl%
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), w//2+15, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w-94, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, (s := RegExMatch(clipboard, ""i)^&?\d{17,20}$"", str)) ? (discordUID := str) : ""Invalid User ID!"", ""Calibri"", 16, 1, w//2+14, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer, nm_WebhookGUI, -1000, 1
			(s != 0) ? UpdateStr(""discordUID"")
		}
	}

	WM_MOUSEMOVE()
	{
		global
		local hCtrl, pBrush, pPen, k, hover_x, hover_y, hover_w, hover_h
		MouseGetPos, , , , hCtrl, 2

		if (!hCtrl || (hCtrl = hTitle))
			return 0

		switch hCtrl
		{
			case hChangeMode, hClose, hDiscordCheck, hSSCheck, hCriticalCheck, hCopyDiscord, hPasteDiscord, hPasteMainID, hPasteReportID, hPasteUserID:
			hover_ctrl := hCtrl
			ReplaceSystemCursors(""IDC_HAND"")
			while (hCtrl = hover_ctrl)
			{
				Sleep, 20
				MouseGetPos, , , , hCtrl, 2
			}
			ReplaceSystemCursors()

			case hMainChannelCheck, hReportChannelCheck, hCriticalSSCheck, hAmuletSSCheck, hMachineSSCheck, hBalloonSSCheck, hViciousSSCheck, hDeathSSCheck, hPlanterSSCheck, hHoneySSCheck, hCriticalErrorPingCheck, hDisconnectPingCheck, hGameFrozenPingCheck, hPhantomPingCheck, hUnexpectedDeathPingCheck, hEmergencyBalloonPingCheck:
			hover_ctrl := hCtrl
			GuiControlGet, k, Name, %hCtrl%
			ControlGetPos, hover_x, hover_y, hover_w, hover_h, , ahk_id %hCtrl%
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x40131416), hover_x-2, hover_y-2, hover_w+4, hover_h+4), Gdip_DeleteBrush(pBrush)

			ReplaceSystemCursors(""IDC_HAND"")
			UpdateLayeredWindow(hMain, hdc)

			while (hCtrl = hover_ctrl)
			{
				Sleep, 20
				MouseGetPos, , , , hCtrl, 2
			}

			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xff131416), hover_x-3, hover_y-3, hover_w+6, hover_h+6), Gdip_DeleteBrush(pBrush)
			if (%k% = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), hover_x-1, hover_y-1, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps[""check""], hover_x, hover_y)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), hover_x, hover_y, 18, 18, 4), Gdip_DeletePen(pPen)

			ReplaceSystemCursors()
			UpdateLayeredWindow(hMain, hdc)
		}
	}

	UpdateInt(var)
	{
		global
		local v := %var%
		IniWrite, %v%, settings\nm_config.ini, Status, %var%
		if WinExist(""natro_macro.ahk ahk_class AutoHotkey"")
			PostMessage, 0x5552, enum[var], v
		if WinExist(""Status.ahk ahk_class AutoHotkey"")
			PostMessage, 0x5552, enum[var], v
	}

	UpdateStr(var)
	{
		global
		IniWrite, % %var%, settings\nm_config.ini, Status, %var%
		if WinExist(""natro_macro.ahk ahk_class AutoHotkey"")
			PostMessage, 0x5553, str_enum[var], 8
		if WinExist(""Status.ahk ahk_class AutoHotkey"")
			PostMessage, 0x5553, str_enum[var], 8
	}

	ReplaceSystemCursors(IDC = """")
	{
		static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := { IDC_APPSTARTING: 32650
							, IDC_ARROW      : 32512
							, IDC_CROSS      : 32515
							, IDC_HAND       : 32649
							, IDC_HELP       : 32651
							, IDC_IBEAM      : 32513
							, IDC_NO         : 32648
							, IDC_SIZEALL    : 32646
							, IDC_SIZENESW   : 32643
							, IDC_SIZENWSE   : 32642
							, IDC_SIZEWE     : 32644
							, IDC_SIZENS     : 32645
							, IDC_UPARROW    : 32516
							, IDC_WAIT       : 32514 }
		if !IDC
			DllCall(""SystemParametersInfo"", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
		else
		{
			hCursor := DllCall(""LoadCursor"", Ptr, 0, UInt, SysCursors[IDC], Ptr)
			for k, v in SysCursors
			{
				hCopy := DllCall(""CopyImage"", Ptr, hCursor, UInt, IMAGE_CURSOR, Int, 0, Int, 0, UInt, 0, Ptr)
				DllCall(""SetSystemCursor"", Ptr, hCopy, UInt, v)
			}
		}
	}

	ExitFunc()
	{
		global
		Gui, % hMain "":Destroy""
		Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
	}
	)"

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path64 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()

	return (WGUIPID := exec.ProcessID)
}
nm_AutoStartManager(){
	global
	local script, file, path, Prev_DetectHiddenWindows, Prev_TitleMatchMode

	Gui, +OwnDialogs
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	WinGet, ASMGUIPID, PID, AutoStartManager.ahk ahk_class AutoHotkey
	if ASMGUIPID
	{
		Process, Close, %ASMGUIPID%
		if (ErrorLevel = 0)
		{
			Process, Exist, %ASMGUIPID%
			if (ErrorLevel != 0)
			{
				msgbox, 0x40030, Auto-Start Manager, There is already an Auto-Start Manager window!
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				return
			}
		}
	}
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
	FileDelete, %A_ScriptDir%\submacros\AutoStartManager.ahk

	script := "
	(Join`r`n C

	#NoEnv
	#NoTrayIcon
	#SingleInstance Force
	#Requires AutoHotkey v1.1.36.01+

	if (!A_IsAdmin || !(DllCall(""GetCommandLine"",""Str"") ~= "" /restart(?!\S)""))
		Try RunWait, *RunAs ""%A_AhkPath%"" /script /restart ""%A_ScriptFullPath%""
	if !A_IsAdmin {
		msgbox You must allow Auto-Start Manager to run as admin, otherwise it will not be able to get and create tasks!
		ExitApp
	}

	ts := ComObjCreate(""Schedule.Service""), ts.Connect(), tasks := GetNatroTasks(), count := tasks.Count()
	taskName := ""None"", validAhk := 0, validScript := 0, autostart := 0, delay := ""None"", level := 0

	if (count = 0)
		status := 1
	else if (count > 1)
		status := 2
	else
	{
		for k,v in tasks
		{
			taskName := k
			SplitPath, % v.args[1], ahkExe, ahkDir
			SplitPath, A_AhkPath, , validAhkDir
			validAhk := (ahkdir = validAhkDir)
			validScript := ((v.args[2] = """ A_ScriptFullPath """) || (" (A_IsCompiled ? 1 : 0) " && (v.args[1] = """ A_ScriptFullPath """)))
			autostart := ((v.args[3] = 1) || (" (A_IsCompiled ? 1 : 0) " && (v.args[2] = 1)))
			delay := v.delay ? v.delay : ""None""
			level := v.level
			status := (validAhk && validScript) ? 0 : 3
		}
	}

	DllCall(""LoadLibrary"", ""Str"", """ A_ScriptDir "\nm_image_assets\Styles\USkin.dll"")
	DllCall(""" A_ScriptDir "\nm_image_assets\Styles\USkin.dll\USkinInit"", ""Int"", 0, ""Int"", 0, ""AStr"", """ A_ScriptDir "\nm_image_assets\Styles\" GuiTheme ".msstyles"")

	w := 250, h := 250
	hGUI := A_Args[1]
	Gui, +AlwaysOnTop -MinimizeBox +Owner%hGUI%
	Gui, Font, s11 cDefault Bold, Tahoma
	Gui, Add, Text, x0 y4 hwndhStatusLabel, Current Status:%A_Space%
	Gui, Add, Text, % ""x0 y4 hwndhStatusVal c"" ((status > 0) ? ""Red"" : ""Green""), % (status > 0) ? ""Inactive"" : ""Active""
	CenterText(hStatusLabel, hStatusVal, hStatusLabel)
	Gui, Font, s9 cDefault Bold, Tahoma
	Gui, Add, Text, % ""x0 y24 w"" w "" h36 vStatusText +Center c"" ((status > 0) ? ""Red"" : ""Green"")
		, % ((status = 0) ? ""Natro Macro will automatically start with Windows using the settings below:""
		: (status = 1) ? ""No Natro Macro startup tasks found! Use the 'Add' button below.""
		: (status = 2) ? ""Multiple Natro Macro startup tasks set!``nUse 'Remove' to clear them.""
		: ""Your startup task needs updating!``nUse 'Add' to create a new startup task."")

	Gui, Add, Text, x0 y58 w%w% +Center hwndhTaskName, % ""Task Name: "" (taskName ? taskName : ""No Task"")
	Gui, Add, Text, x0 y74 hwndhAHKLabel, AutoHotkey Path:%A_Space%
	Gui, Add, Text, % ""x0 y74  hwndhAHKVal c"" ((validAhk) ? ""Green"" : ""Red""), % (status = 1) ? ""No Task"" : (validAhk) ? ""Valid"" : ""Invalid""
	CenterText(hAHKLabel, hAHKVal, hTaskName)
	Gui, Add, Text, x0 y90 hwndhNTLabel, Natro File Path:%A_Space%
	Gui, Add, Text, % ""x0 y90 hwndhNTVal c"" ((validScript) ? ""Green"" : ""Red""), % (status = 1) ? ""No Task"" : (validScript) ? ""Valid"" : ""Invalid""
	CenterText(hNTLabel, hNTVal, hTaskName)
	Gui, Add, Text, x0 y106 hwndhASLabel, Start Macro On Run:%A_Space%
	Gui, Add, Text, % ""x0 y106 hwndhASVal c"" ((autostart) ? ""Green"" : ""Red""), % (status = 1) ? ""No Task"" : (autostart) ? ""Enabled"" : ""Disabled""
	CenterText(hASLabel, hASVal, hTaskName)
	Gui, Add, Text, x0 y122 hwndhRLLabel, Run With Privileges:%A_Space%
	Gui, Add, Text, % ""x0 y122 hwndhRLVal c"" ((status = 1) ? ""Red"" : (level) ? ""Green"" : ""Yellow""), % (status = 1) ? ""No Task"" : (level) ? ""Highest"" : ""Least""
	CenterText(hRLLabel, hRLVal, hTaskName)
	Gui, Add, Text, x0 y138 w%w% hwndhDelay +Center, % ""Delay Duration: "" delay

	Gui, Add, Button, x10 y160 w110 h24 gRemoveButton, Remove
	Gui, Add, Button, x130 y160 w110 h24 gAddButton, Add

	Gui, Add, GroupBox, x5 y190 w240 h54, New Task Settings
	Gui, Font, s8 cDefault Norm, Tahoma
	Gui, Add, CheckBox, x15 y208 Checked vAutoStartCheck, Start Macro On Run
	Gui, Add, CheckBox, x15 y224 Checked vAdminCheck, Run Macro As Admin
	Gui, Add, Text, x140 y205 w100 +Center, Delay Before Start:
	Gui, Add, Text, x146 y222 w68 vDelayText +Center, 0s
	Gui, Add, UpDown, x216 y221 w10 h16 -16 Range0-86400 vDelayDuration gChangeDelay, 0

	GuiControl, Focus, % """"
	Gui, Show, w%w% h%h%, Auto-Start Manager
	return

	GuiClose:
	FileDelete, %A_ScriptFullPath%
	ExitApp

	ChangeDelay()
	{
		GuiControlGet, secs, , DelayDuration
		VarSetCapacity(dur,128), DllCall(""GetDurationFormatEx"",""Ptr"",0,""UInt"",0,""Ptr"",0,""Int64"",secs*10000000,""WStr"",((secs >= 3600) ? ""h'h' m"" : """") ((secs >= 60) ? ""m'm' s"" : """") ""s's'"",""WStr"",dur,""Int"",128)
		GuiControl, , DelayText, % dur
	}

	AddButton()
	{
		global
		local def, tr, action, name, delay, secs
		if (GetNatroTasks().Count() > 0)
		{
			Gui, +OwnDialogs
			MsgBox, 0x40024, Overwrite Existing Task, Are you sure?``nThis will overwrite your existing Natro Macro Auto-Start tasks!, 30
			IfMsgBox Yes
				RemoveButton()
			else
				return
		}

		GuiControlGet, autostart, , AutoStartCheck
		GuiControlGet, runlevel, , AdminCheck
		GuiControlGet, secs, , DelayDuration
		VarSetCapacity(delay,128), DllCall(""GetDurationFormatEx"",""Ptr"",0,""UInt"",0,""Ptr"",0,""Int64"",secs*10000000,""WStr"",""'PT'"" ((secs >= 3600) ? ""h'H'"" : """") ((secs >= 60) ? ""m'M'"" : """") ""s'S'"",""WStr"",delay,""Int"",128)

		def := ts.NewTask(0)

		def.RegistrationInfo.Author := ""Natro Macro""
		def.RegistrationInfo.Description := ""Automatically starts Natro Macro v" VersionID " on logon.""

		def.Principal.RunLevel := runlevel

		tr := def.Triggers.Create(8)
		tr.Delay := delay

		action := def.Actions.Create(0)
		action.ID := ""Run Natro Macro""
		action.Path := """"""" A_AhkPath """""""
		action.Arguments := " (A_IsCompiled ? "" : ("""""""" A_ScriptFullPath """"" """)) " ((autostart = 1) ?  """"""1"""""" : """")

		def.Settings.Enabled := 1
		def.Settings.Hidden := 0
		def.Settings.StartWhenAvailable := 1
		def.Settings.IdleSettings.StopOnIdleEnd := 0
		def.Settings.DisallowStartIfOnBatteries := 0
		def.Settings.StopIfGoingOnBatteries := 0
		def.Settings.ExecutionTimeLimit := ""PT0S""

		ts.GetFolder(""\"").RegisterTaskDefinition(name := ""Natro v" VersionID """, def, 0x6, """", """", 0)


		GuiControl, , % hTaskName, Task Name: %name%
		GuiControl, , % hDelay, % ""Delay Duration: "" ((delay = ""PT0S"") ? ""None"" : delay)
		Gui, Font, s11 cGreen Bold, Tahoma
		GuiControl, Font, % hStatusVal
		GuiControl, , % hStatusVal, Active
		CenterText(hStatusLabel, hStatusVal, hStatusLabel)
		Gui, Font, s9
		GuiControl, Font, StatusText
		GuiControl, , StatusText, Natro Macro will automatically start with Windows using the settings below:
		GuiControl, Font, % hAHKVal
		GuiControl, , % hAHKVal, Valid
		CenterText(hAHKLabel, hAHKVal, hTaskName)
		GuiControl, Font, % hNTVal
		GuiControl, , % hNTVal, Valid
		CenterText(hNTLabel, hNTVal, hTaskName)
		Gui, Font, % (autostart = 1) ? ""cGreen"" : ""cRed""
		GuiControl, Font, % hASVal
		GuiControl, , % hASVal, % (autostart = 1) ? ""Enabled"" : ""Disabled""
		CenterText(hASLabel, hASVal, hTaskName)
		Gui, Font, % (runlevel = 1) ? ""cGreen"" : ""cYellow""
		GuiControl, Font, % hRLVal
		GuiControl, , % hRLVal, % (runlevel = 1) ? ""Highest"" : ""Least""
		CenterText(hRLLabel, hRLVal, hTaskName)
	}

	RemoveButton(hButton:=0)
	{
		global
		local root, k
		root := ts.GetFolder(""\"")
			for k in GetNatroTasks()
				root.DeleteTask(k, 0)

		if hButton
		{
			GuiControl, , % hTaskName, Task Name: None
			GuiControl, , % hDelay, Delay Duration: None
			Gui, Font, s11 cRed Bold, Tahoma
			GuiControl, Font, % hStatusVal
			GuiControl, , % hStatusVal, Inactive
			CenterText(hStatusLabel, hStatusVal, hStatusLabel)
			Gui, Font, s9
			GuiControl, Font, StatusText
			GuiControl, , StatusText, No Natro Macro startup tasks found! Use the 'Add' button below.
			GuiControl, Font, % hAHKVal
			GuiControl, , % hAHKVal, No Task
			CenterText(hAHKLabel, hAHKVal, hTaskName)
			GuiControl, Font, % hNTVal
			GuiControl, , % hNTVal, No Task
			CenterText(hNTLabel, hNTVal, hTaskName)
			GuiControl, Font, % hASVal
			GuiControl, , % hASVal, No Task
			CenterText(hASLabel, hASVal, hTaskName)
			GuiControl, Font, % hRLVal
			GuiControl, , % hRLVal, No Task
			CenterText(hRLLabel, hRLVal, hTaskName)
		}
	}

	GetNatroTasks()
	{
		global ts
		tasks := {}
		for t in ts.GetFolder(""\"").GetTasks(1)
			for tr in t.Definition.Triggers
				if ((tr.Type = 8) || (tr.Type = 9)) ; boot/logon
					for a in t.Definition.Actions
						if (a.Type = 0) ; exec
							for i,arg in (args := Args(a.Path "" "" a.Arguments))
								if ((SubStr(arg, -14, 11) = ""natro_macro"") && (tasks[t.Name] := {""args"":args,""delay"":tr.Delay,""level"":t.Definition.Principal.RunLevel}))
									continue 4
		return tasks
	}

	CenterText(hText1, hText2, hFont)
	{
		global w
		GuiControlGet, t1, , % hText1
		GuiControlGet, t2, , % hText2
		w1 := TextExtent(t1, hFont), w2 := TextExtent(t2, hFont)
		GuiControl, MoveDraw, % hText1, % ""x"" (x1 := (w - w1 - w2)//2) "" w"" w1
		GuiControl, MoveDraw, % hText2, % ""x"" x1 + w1 "" w"" w2
	}

	TextExtent(text, hCtrl)
	{
		hFont := DllCall(""SendMessage"", ""Ptr"", hCtrl, ""UInt"", 0x31, ""Ptr"", 0, ""Ptr"", 0, ""Ptr"")
		hDC := DllCall(""GetDC"", ""UInt"", hCtrl)
		hFold := DllCall(""SelectObject"", ""UInt"", hDC, ""UInt"", hFont)
		DllCall(""GetTextExtentPoint32"", ""UInt"", hDC, ""Str"", text, ""Int"", StrLen(text), ""Int64P"", nSize)
		DllCall(""SelectObject"", ""UInt"", hDC, ""UInt"", hFold)
		DllCall(""ReleaseDC"", ""UInt"", hCtrl, ""UInt"", hDC)
		return nSize & 0xffffffff
	}

	Args(CmdLine := """") { ; modified from Args() By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
		Local pArgs := 0, nArgs := 0, A := []

		pArgs := DllCall(""Shell32\CommandLineToArgvW"", ""WStr"",CmdLine, ""PtrP"",nArgs, ""Ptr"")

		Loop % nArgs
			A[A_Index] := StrGet(NumGet((A_Index - 1) * A_PtrSize + pArgs), ""UTF-16"")

		Return A, A[0] := nArgs, DllCall(""LocalFree"", ""Ptr"", pArgs)
	}
	)"

	file := FileOpen(path := A_ScriptDir "\submacros\AutoStartManager.ahk", "w-d", "UTF-8"), file.Write(script), file.Close()
	Run, "%A_AhkPath%" /script "%path%" "%hGUI%"

	return
}
nm_NewWalkHelp(){ ; movespeed correction information
	msgbox, 0x40000, MoveSpeed Correction, DESCRIPTION:`nWhen this option is enabled, the macro will detect your Haste, Bear Morph, Coconut Haste, Haste+, Oil and Super Smoothie values real-time. Using this information, it will calculate the distance you have moved and use that for more accurate movements. If working as intended, this option will dramatically reduce drift and make Traveling anywhere in game much more accurate.`n`nIMPORTANT:`nIf you have this option enabled, make sure your 'Movement Speed' value is EXACTLY as shown in BSS Settings menu without haste or other temporary buffs (e.g. write 33.6 as 33.6 without any rounding). Also, it is ESSENTIAL that your Display Scale is 100`%, otherwise the buffs will not be detected properly.
}
nm_PublicFallbackHelp(){ ; public fallback information
	msgbox, 0x40000, Public Server Fallback, DESCRIPTION:`nWhen this option is enabled, the macro will revert to attempting to join a Public Server if your Server Link failed three times. Otherwise, it will keep trying the Server Link you entered above until it succeeds.
}
nm_NatroSoBrokeHelp(){ ; so broke information
	msgbox, 0x40000, Natro so broke :weary:, DESCRIPTION:`nEnable this to have the macro say 'Natro so broke :weary:' in chat after it reconnects! This is a reference to e_lol's macros which type 'e_lol so pro :weary:' in chat.
}
nm_MonsterRespawnTimeHelp(){ ; monster respawn time information
	msgbox, 0x40000, Monster Respawn Time, DESCRIPTION:`nEnter the sum of all of your Monster Respawn Time buffs here. These can come from:`n- Gifted Vicious Bee (-15`%)`n- Stick Bug Amulet (up to -10`%)`n- Icicles Beequip (-1`% to -5`%)`n`nEXAMPLE:`nI have a Gifted Vicious Bee (-15`%), a Stick Bug Amulet with -8`% Monster Respawn Time, and 2 Icicles Beequips with -2`% Monster Respawn Time each. I will enter '27' in the input box.
}
nm_BossConfigHelp(){ ; monster respawn time information
	msgbox, 0x40000, Boss configuration, DESCRIPTION:`nThe Bosses menu allows for you to customize whether to wait for baby love, to keep your old amulet or keep it on the screen for manual input and to configure the health and time interval for Snail and chick.`n`nBaby Love`n- The baby love option will allow for the macro to wait a certain amount of time to try to get a baby love token to increase loot luck. This option is only for king beetle and tunnel bear.`n`nBoss Amulet options`n- Enabling the checkbox will allow for the macro to automatically keep your old amulet so that you don't lose your perfect amulet. Unchecking this box will allow for the amulet prompt to stay on screen for manual input whether to keep or replace. The only bosses with this feature are Stump Snail and King beetle`n`nBoss health/time settings`n- Enter the boss's health in the text box. The health needs to be written in wihtout commas seperating the health and it will automatically be converted into a percentage. As for the time, the time options are in 5,10,15 minutes with another option being the kill option. The Kill option will basically attack the boss until the boss dies or if you die. The only bosses with this feature are Stump Snail and Commando Chick.
}
nm_ReconnectTimeHelp(){
	global ReconnectHour, ReconnectMin, ReconnectInterval
	Gui +OwnDialogs
	timeUTC := A_NowUTC, timeLOC := A_Now
	FormatTime, hhmmUTC, %A_NowUTC%, HH:mm
	FormatTime, hhmmLOC, %A_Now%, HH:mm
	s := timeLOC
	s -= timeUTC, S
	VarSetCapacity(o,256),DllCall("GetDurationFormatEx","ptr",0,"uint",0,"ptr",0,"int64",Abs(s)*10000000,"wstr",((s>=0)?"+":"-") "hh:mm","str",o,"int",256)

	if((!ReconnectHour && ReconnectHour!=0) || (!ReconnectMin && ReconnectMin!=0) || (Mod(24, ReconnectInterval) != 0)) {
		ReconnectTimeString:="`n<Invalid Time>"
	} else {
		ReconnectTimeString:=""
		Loop % 24//ReconnectInterval {
			time := "19700101" SubStr("0" Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24), -1) SubStr("0" Mod(ReconnectMin, 60), -1) "00"
			FormatTime, hhmmReconnectUTC, %time%, HH:mm
			time += s, S
			FormatTime, hhmmReconnectLOC, %time%, HH:mm
			ReconnectTimeString.="`n" hhmmReconnectUTC " UTC = Local Time: " hhmmReconnectLOC
		}
	}

	msgbox, 0x40000, Coordinated Universal Time (UTC),% "DEFINITION:`nUTC is the time standard commonly used across the world. The world's timing centers have agreed to keep their time scales closely synchronized - or coordinated - therefore the name Coordinated Universal Time.`n`nWhy use UTC?`nThis allows all players on the same server to enter the same time value into the GUI regardless of the local timezone.`n`nTIME NOW:`nLocal Time: " hhmmLOC " (UTC" o " hours) = UTC Time: " hhmmUTC "`n`nRECONNECT TIMES:" ReconnectTimeString
}
nm_HiveBeesHelp(){
	msgbox, 0x40000, Hive Bees, DESCRIPTION:`nEnter the number of Bees you have in your Hive. This doesn't have to be exactly the same as your in-game amount, but the macro will use this value to determine whether it can travel to the 35 Bee Zone, use the Red Cannon, etc.`n`nNOTE:`nLowering this number will increase the time your character waits at hive after converting or before going to battle. If you notice that your bees don't finish converting or haven't recovered to fight mobs, reduce this value but keep it above 35 to enable access to all areas in the map.
}
nm_ContributorsImage(page:=1){
	static hCtrl, hBM1, hBM2, hBM3, hBM4, hBM5, hBM6, hBM7, hBM8, hBM9 ; 9 pages max
		, colorArr := {"blue": [0xff83c6e2, 0xff2779d8, 0xff83c6e2]
			, "gold": [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f]
			, "error-red": [0xffa82428, 0xffa82428, 0xffa82428]
			, "pink": [0xffad32c3, 0xfff47fff, 0xffad32c3]}

	if (hBM1 = "")
	{
		devs := [["bastianauryn",0xffa202c0]
			, ["zez_",0xff7df9ff]
			, ["ScriptingNoob",0xfffa01c5]
			, ["zaappiix",0xffa2a4a3]
			, ["xspx",0xfffc6600]
			, ["BlackBeard6#2691",0xff8780ff]
			, ["baguetto",0xff3d85c6]
			, ["raychal71",0xffb7c9e2]]

		testers := [["fhl09",0xffff00ff]
			, ["ziz_jake",0xffa45ee9]
			, ["nick9",0xffdfdfdf]
			, ["heatsky",0xff3f8d4d]
			, ["valibreaz",0xff7aa22c]
			, ["randomuserhere",0xff2bc016]
			, ["crazyrocketman_",0xffffdc64]
			, ["chaxe",0xff794044]
			, ["phucduc#9444",0xffffde48]
			, ["anniespony",0xff0096ff]
			, ["idote",0xfff47fff]
			, ["axetar",0xffec8fd0]
			, ["mahirishere",0xffa3bded]]

		try
		{
			wr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://raw.githubusercontent.com/NatroTeam/.github/main/profile/data/contributors.txt", 1)
			wr.SetRequestHeader("accept", "application/vnd.github.v3.raw")
			wr.Send()
			wr.WaitForResponse()
			contributors := StrSplit(wr.ResponseText, "`n", " `t")
		}
		catch
			contributors := ["Error while loading,error-red", "contributors!,error-red", "", "Make sure you have,error-red", "a working internet,error-red", "connection and then,error-red", "reload the macro.,error-red"]

		pBM := Gdip_CreateBitmap(244,212)
		G := Gdip_GraphicsFromImage(pBM)
		Gdip_SetSmoothingMode(G, 2)
		Gdip_SetInterpolationMode(G, 7)

		pBrush := Gdip_BrushCreateSolid(0xff202020)
		Gdip_FillRoundedRectangle(G, pBrush, 0, 0, 242, 210, 5)
		Gdip_DeleteBrush(pBrush)

		pos := Gdip_TextToGraphics(G, "Dev Team", "s12 x6 y35 Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(6, 35, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+2, 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, 6, 35, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Dev Team", "s12 x7 y35 r4 Bold cff000000", "Tahoma")

		pos := Gdip_TextToGraphics(G, "Testers", "s12 x126 y35 Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(126, 35, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, 126, 35, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+1, 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Testers", "s12 x127 y35 r4 Bold cff000000", "Tahoma")

		for k,v in devs
		{
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, 52+(k-1)*12, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1,2), 255), 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, 5, 51+(k-1)*12, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		for k,v in testers
		{
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, 52+(k-1)*12, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1.2), 255), 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, 125, 51+(k-1)*12, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}

		Gdip_DeleteGraphics(G)

		hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		Gdip_DisposeImage(pBM)
		Gui, Add, Picture, +BackgroundTrans gnm_ContributorsDiscordLink x5 y24, HBITMAP:*%hBM%
		DllCall("DeleteObject", "ptr", hBM)

		i := 0
		for k,v in contributors
		{
			if (Mod(k, 24) = 1)
			{
				if (k > 1)
				{
					Gdip_DeleteGraphics(G)
					hBM%i% := Gdip_CreateHBITMAPFromBitmap(pBM%i%)
					Gdip_DisposeImage(pBM%i%)
				}

				i++
				pBM%i% := Gdip_CreateBitmap(244,212)
				G := Gdip_GraphicsFromImage(pBM%i%)
				Gdip_SetSmoothingMode(G, 2)
				Gdip_SetInterpolationMode(G, 7)

				pBrush := Gdip_BrushCreateSolid(0xff202020)
				Gdip_FillRoundedRectangle(G, pBrush, 0, 0, 242, 210, 5)
				Gdip_DeleteBrush(pBrush)
			}

			name := Trim(SubStr(v, 1, (pos := InStr(v, ",", , 0))-1)), color := Trim(SubStr(v, pos+1))
			x := (Mod(k-1, 24) > 11) ? 124 : 4, y := 48+Mod(k-1, 12)*13
			pos := Gdip_TextToGraphics(G, name, "s11 x" x " y0 cff000000", "Tahoma", , , 1)
			pBrush := Gdip_CreateLinearGrBrushFromRect(x, y+1, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 12, 0x00000000, 0x00000000, 2)
			Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], colorArr[colorArr.HasKey(color) ? color : "gold"].Clone())
			pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, name, "Tahoma", 11, 0, x, y, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		Gdip_DeleteGraphics(G)
		hBM%i% := Gdip_CreateHBITMAPFromBitmap(pBM%i%)
		Gdip_DisposeImage(pBM%i%)

		Gui, Add, Picture, +BackgroundTrans hwndhCtrl x253 y24 AltSubmit, % "HBITMAP:*" hBM1
	}
	else
	{
		;GDI_SetImageX() by SKAN
		hdcSrc  := DllCall( "CreateCompatibleDC", UInt,0 )
		hdcDst  := DllCall( "GetDC", UInt,hCtrl )
		VarSetCapacity( bm,24,0 ) ; BITMAP Structure
		DllCall( "GetObject", UInt,hBM%page%, UInt,24, UInt,&bm )
		w := Numget( bm,4 ), h := Numget( bm,8 )
		hbmOld  := DllCall( "SelectObject", UInt,hdcSrc, UInt,hBM%page% )
		hbmNew  := DllCall( "CreateBitmap", Int,w-6, Int,h-50, UInt,NumGet( bm,16,"UShort" )
						, UInt,NumGet( bm,18,"UShort" ), Int,0 )
		hbmOld2 := DllCall( "SelectObject", UInt,hdcDst, UInt,hbmNew )
		DllCall( "BitBlt", UInt,hdcDst, Int,3, Int,48, Int,w-6, Int,h-50
						, UInt,hdcSrc, Int,3, Int,48, UInt,0x00CC0020 )
		DllCall( "SelectObject", UInt,hdcSrc, UInt,hbmOld )
		DllCall( "DeleteDC",  UInt,hdcSrc ),   DllCall( "ReleaseDC", UInt,hCtrl, UInt,hdcDst )
		DllCall( "SendMessage", UInt,hCtrl, UInt,0x0B, UInt,0, UInt,0 )        ; WM_SETREDRAW OFF
		oBM := DllCall( "SendMessage", UInt,hCtrl, UInt,0x172, UInt,0, UInt,hBM%page% ) ; STM_SETIMAGE
		DllCall( "SendMessage", UInt,hCtrl, UInt,0x0B, UInt,1, UInt,0 )        ; WM_SETREDRAW ON
		DllCall( "DeleteObject", UInt,oBM )
	}

	i := page + 1
	return ((hBM%i% = "") ? 1 : 0)
}
nm_ContributorsDiscordLink(){
	static id_list := {"779430642043191307": [4,39,68,49] ;DEV TEAM
		, "253742141124116481": [4,51,27,61]
		, "245481556355973121": [4,63,72,73]
		, "747945550888042537": [4,75,44,85]
		, "240431161191432193": [4,87,27,97]
		, "278608676296589313": [4,99,98,109]
		, "323507959957028874": [4,111,48,121]
		, "259441167068954624": [4,123,51,133]
		, "334634052361650177": [113,39,137,49] ;TESTERS || 134 HERE <====================================
		, "227604929806729217": [113,51,152,61] ;x, y, w, h
		, "700353887512690759": [113,63,139,73]
		, "725444258835726407": [113,75,151,85]
		, "244504077579452417": [113,87,157,97]
		, "744072472890179665": [113,99,195,109]
		, "720088699475591180": [113,111,197,121]
		, "529089693749608468": [113,123,142,133]
		, "710486399744475136": [113,135,188,145]
		, "217700684835979265": [113,147,170,157]
		, "350433227380621322": [113,159,138,169]
		, "487989990937198602": [113,171,144,181]}
	WinGetClientPos(window_x, window_y, , , "Natro ahk_class AutoHotkeyGUI") ;gets the location of the natro window
	MouseGetPos, mouse_x, mouse_y, , hCtrl, 2
	ControlGetPos, ctrl_x, ctrl_y, , , , ahk_id %hCtrl%
	x := mouse_x - window_x - ctrl_x, y := mouse_y - window_y - ctrl_y
	for k,v in id_list
	{
		if ((x >= v[1]) && (x <= v[3]) && (y >= v[2]) && (y <= v[4]))
		{
			nm_RunDiscord("users/" k)
			break
		}
	}
}
nm_ContributorsPageButton(hwnd){
	global
	static p := 1

	p += (hwnd = hcleft) ? -1 : 1

	GuiControl, % ((p=1) ? "Disable" : "Enable"), % hcleft
	GuiControl, % ((nm_ContributorsImage(p)=1) ? "Disable" : "Enable"), % hcright
}
nm_CollectKillButton(hCtrl){
	global
	static CollectControls := ["CollectGroupBox","DispensersGroupBox","BeesmasGroupBox","BeesmasImage","ClockCheck","MondoBuffCheck","MondoAction","AntPassCheck","AntPassAction","RoboPassCheck","HoneystormCheck","HoneyDisCheck","TreatDisCheck","BlueberryDisCheck","StrawberryDisCheck","CoconutDisCheck","RoyalJellyDisCheck","GlueDisCheck","BeesmasGatherInterruptCheck","StockingsCheck","WreathCheck","FeastCheck","RBPDelevelCheck","GingerbreadCheck","SnowMachineCheck","CandlesCheck","SamovarCheck","LidArtCheck","GummyBeaconCheck"]
	, KillControls := ["BugRunGroupBox","BugRunCheck","MonsterRespawnTime","TextMonsterRespawnPercent","TextMonsterRespawn","MonsterRespawnTimeHelp","BugrunInterruptCheck","TextLoot","TextKill","TextLineBugRun1","TextLineBugRun2","BugrunLadybugsLoot","BugrunRhinoBeetlesLoot","BugrunSpiderLoot","BugrunMantisLoot","BugrunScorpionsLoot","BugrunWerewolfLoot","BugrunLadybugsCheck","BugrunRhinoBeetlesCheck","BugrunSpiderCheck","BugrunMantisCheck","BugrunScorpionsCheck","BugrunWerewolfCheck","StingersGroupBox","StingerCheck","StingerDailyBonusCheck","TextFields","StingerCloverCheck","StingerSpiderCheck","StingerCactusCheck","StingerRoseCheck","StingerMountainTopCheck","StingerPepperCheck","BossesGroupBox","TunnelBearCheck","KingBeetleCheck","CocoCrabCheck","StumpSnailCheck","CommandoCheck","TunnelBearBabyCheck","KingBeetleBabyCheck","BabyLovePicture1","BabyLovePicture2","KingBeetleAmuletMode","ShellAmuletMode","KingBeetleAmuPicture","ShellAmuPicture","KingBeetleAmuletModeText","ShellAmuletModeText","ChickLevelTextLabel","ChickLevelText","ChickLevel","SnailHPText","SnailHealthEdit","SnailHealthText","ChickHPText","ChickHealthEdit","ChickHealthText","SnailTimeText","SnailTimeUpDown","ChickTimeText","ChickTimeUpDown","BossConfigHelp"]

	p := (hCtrl = hKill)
	GuiControl, % (p ? "Enable" : "Disable"), % hCollect
	GuiControl, % (p ? "Disable" : "Enable"), % hKill
	GuiControl, Focus, 0

	for i,c in ["Hide","Show"] ; hide first, then show
	{
		if (((i = 1) && (p = 1)) || ((i = 2) && (p = 0))) ; hide/show all collect controls
		{
			for k,v in CollectControls
				GuiControl, %c%, %v%
		}

		if (((i = 1) && (p = 0)) || ((i = 2) && (p = 1))) ; hide/show all kill controls
		{
			for k,v in KillControls
				GuiControl, %c%, %v%
		}
	}
}
nm_saveAutoClicker(){
	global
	GuiControlGet, ClickDelay
	GuiControlGet, ClickCount
	GuiControlGet, ClickMode
	IniWrite, %ClickDelay%, settings\nm_config.ini, Settings, ClickDelay
	IniWrite, %ClickCount%, settings\nm_config.ini, Settings, ClickCount
	IniWrite, %ClickMode%, settings\nm_config.ini, Settings, ClickMode
	GuiControl, % (ClickMode ? "Disable" : "Enable"), ClickCount
	GuiControl, % (ClickMode ? "Disable" : "Enable"), ClickCountEdit
}
nm_saveKeyDelay(){
    global 
	GuiControlGet, KeyDelay
    IniWrite, %KeyDelay%, settings\nm_config.ini, Settings, KeyDelay
}
nm_TicketShopCalculatorButton(){
	Run, https://docs.google.com/spreadsheets/d/1_5JP_9uZUv7PUqjL76T5orEA3MIHe4R8gLu27L8KJ-A/
}
nm_SSACalculatorButton()
{
	Run, https://docs.google.com/spreadsheets/d/1nupF_6g1TLJk1W5MpLBsfe1yk6C99-ooMMffuxdn580/edit?usp=sharing
}
nm_BondCalculatorButton()
{
	Run, https://docs.google.com/spreadsheets/d/1TFTAahwsB4WRmRkX4YiM8mPQyk53CDmfAKOSOYv-Bow/edit?usp=sharing
}

nm_RunDiscord(path){
	static init := VarSetCapacity(cmd, 512) + DllCall("shlwapi\AssocQueryString","Int",0,"Int",1,"Str","discord","Str","open","Str",cmd, "IntP",512) + DllCall("Shell32\SHEvaluateSystemCommandTemplate","WStr",cmd,"PtrP",pEXE,"Ptr",0,"PtrP",pPARAMS)
	, exe := StrGet(pEXE)
	, params := StrGet(pPARAMS)
	, appenabled := (StrLen(exe) > 0)

	Run, % appenabled ? ("""" exe """ " StrReplace(params, "%1", "discord://-/" path)) : ("""https://discord.com/" path """")
}
nm_ReportBugButton(){
	nm_RunDiscord("channels/1012610056921038868/1012767324656390215")
}
nm_MakeSuggestionButton(){
	nm_RunDiscord("channels/1012610056921038868/1057798330056462436")
}
DiscordLink(){
    nm_RunDiscord("invite/xbkXjwWh8U")
}
DonateLink(){
    run, https://www.paypal.com/donate/?hosted_button_id=9KN7JHBCTAU8U&no_recurring=0&currency_code=USD
}
RobloxLink(){
    run, https://www.roblox.com/groups/16490149/Natro-Macro
}
GitHubRepoLink(){
	run, https://github.com/NatroTeam/NatroMacro
}
GitHubReleaseLink(){
	global LatestVer1
	Gui, +OwnDialogs
	MsgBox, 0x1044, Update, % "A newer version of Natro Macro was found!`r`nDo you want to update to v" LatestVer1 "?"
	IfMsgBox, Yes
		run, https://github.com/NatroTeam/NatroMacro/releases/latest
}
nm_TabPlantersLock(){
	GuiControl, disable, PlanterMode
	;planters+
	GuiControl, disable, NPreset
	GuiControl, disable, N1Priority
	GuiControl, disable, N2Priority
	GuiControl, disable, N3Priority
	GuiControl, disable, N4Priority
	GuiControl, disable, N5Priority
	GuiControl, disable, N1MinPercent
	GuiControl, disable, N2MinPercent
	GuiControl, disable, N3MinPercent
	GuiControl, disable, N4MinPercent
	GuiControl, disable, N5MinPercent
	GuiControl, disable, MaxAllowedPlanters
	GuiControl, disable, MaxAllowedPlantersEdit
	GuiControl, disable, AutomaticHarvestInterval
	GuiControl, disable, HarvestFullGrown
	GuiControl, disable, gotoPlanterField
	GuiControl, disable, gatherFieldSipping
	GuiControl, disable, ConvertFullBagHarvest
	GuiControl, disable, GatherPlanterLoot
	GuiControl, disable, HarvestInterval
	GuiControl, disable, PlasticPlanterCheck
	GuiControl, disable, CandyPlanterCheck
	GuiControl, disable, BlueClayPlanterCheck
	GuiControl, disable, RedClayPlanterCheck
	GuiControl, disable, TackyPlanterCheck
	GuiControl, disable, PesticidePlanterCheck
	GuiControl, disable, HeatTreatedPlanterCheck
	GuiControl, disable, HydroponicPlanterCheck
	GuiControl, disable, PetalPlanterCheck
	GuiControl, disable, PlanterOfPlentyCheck
	GuiControl, disable, PaperPlanterCheck
	GuiControl, disable, TicketPlanterCheck
	GuiControl, disable, DandelionFieldCheck
	GuiControl, disable, SunflowerFieldCheck
	GuiControl, disable, MushroomFieldCheck
	GuiControl, disable, BlueFlowerFieldCheck
	GuiControl, disable, CloverFieldCheck
	GuiControl, disable, SpiderFieldCheck
	GuiControl, disable, StrawberryFieldCheck
	GuiControl, disable, BambooFieldCheck
	GuiControl, disable, PineappleFieldCheck
	GuiControl, disable, StumpFieldCheck
	GuiControl, disable, CactusFieldCheck
	GuiControl, disable, PumpkinFieldCheck
	GuiControl, disable, PineTreeFieldCheck
	GuiControl, disable, RoseFieldCheck
	GuiControl, disable, MountainTopFieldCheck
	GuiControl, disable, CoconutFieldCheck
	GuiControl, disable, PepperFieldCheck
	;manual
	Static ManualPlantersControls := ["MHarvestInterval", "MSlot1Cycle1Planter", "MSlot1Cycle2Planter", "MSlot1Cycle3Planter", "MSlot1Cycle4Planter", "MSlot1Cycle5Planter", "MSlot1Cycle6Planter", "MSlot1Cycle7Planter", "MSlot1Cycle8Planter", "MSlot1Cycle9Planter", "MSlot1Cycle1Field", "MSlot1Cycle2Field", "MSlot1Cycle3Field", "MSlot1Cycle4Field", "MSlot1Cycle5Field", "MSlot1Cycle6Field", "MSlot1Cycle7Field", "MSlot1Cycle8Field", "MSlot1Cycle9Field", "MSlot1Cycle1Glitter", "MSlot1Cycle2Glitter", "MSlot1Cycle3Glitter", "MSlot1Cycle4Glitter", "MSlot1Cycle5Glitter", "MSlot1Cycle6Glitter", "MSlot1Cycle7Glitter", "MSlot1Cycle8Glitter", "MSlot1Cycle9Glitter", "MSlot1Cycle1AutoFull", "MSlot1Cycle2AutoFull", "MSlot1Cycle3AutoFull", "MSlot1Cycle4AutoFull", "MSlot1Cycle5AutoFull", "MSlot1Cycle6AutoFull", "MSlot1Cycle7AutoFull", "MSlot1Cycle8AutoFull", "MSlot1Cycle9AutoFull", "MSlot2Cycle1Planter", "MSlot2Cycle2Planter", "MSlot2Cycle3Planter", "MSlot2Cycle4Planter", "MSlot2Cycle5Planter", "MSlot2Cycle6Planter", "MSlot2Cycle7Planter", "MSlot2Cycle8Planter", "MSlot2Cycle9Planter", "MSlot2Cycle1Field", "MSlot2Cycle2Field", "MSlot2Cycle3Field", "MSlot2Cycle4Field", "MSlot2Cycle5Field", "MSlot2Cycle6Field", "MSlot2Cycle7Field", "MSlot2Cycle8Field", "MSlot2Cycle9Field", "MSlot2Cycle1Glitter", "MSlot2Cycle2Glitter", "MSlot2Cycle3Glitter", "MSlot2Cycle4Glitter", "MSlot2Cycle5Glitter", "MSlot2Cycle6Glitter", "MSlot2Cycle7Glitter", "MSlot2Cycle8Glitter", "MSlot2Cycle9Glitter", "MSlot2Cycle1AutoFull", "MSlot2Cycle2AutoFull", "MSlot2Cycle3AutoFull", "MSlot2Cycle4AutoFull", "MSlot2Cycle5AutoFull", "MSlot2Cycle6AutoFull", "MSlot2Cycle7AutoFull", "MSlot2Cycle8AutoFull", "MSlot2Cycle9AutoFull", "MSlot3Cycle1Planter", "MSlot3Cycle2Planter", "MSlot3Cycle3Planter", "MSlot3Cycle4Planter", "MSlot3Cycle5Planter", "MSlot3Cycle6Planter", "MSlot3Cycle7Planter", "MSlot3Cycle8Planter", "MSlot3Cycle9Planter", "MSlot3Cycle1Field", "MSlot3Cycle2Field", "MSlot3Cycle3Field", "MSlot3Cycle4Field", "MSlot3Cycle5Field", "MSlot3Cycle6Field", "MSlot3Cycle7Field", "MSlot3Cycle8Field", "MSlot3Cycle9Field", "MSlot3Cycle1Glitter", "MSlot3Cycle2Glitter", "MSlot3Cycle3Glitter", "MSlot3Cycle4Glitter", "MSlot3Cycle5Glitter", "MSlot3Cycle6Glitter", "MSlot3Cycle7Glitter", "MSlot3Cycle8Glitter", "MSlot3Cycle9Glitter", "MSlot3Cycle1AutoFull", "MSlot3Cycle2AutoFull", "MSlot3Cycle3AutoFull", "MSlot3Cycle4AutoFull", "MSlot3Cycle5AutoFull", "MSlot3Cycle6AutoFull", "MSlot3Cycle7AutoFull", "MSlot3Cycle8AutoFull", "MSlot3Cycle9AutoFull", "MHeader1Text", "MHeader2Text", "MHeader3Text", "MSlot1PlanterText", "MSlot2PlanterText", "MSlot3PlanterText", "MSlot1FieldText", "MSlot2FieldText", "MSlot3FieldText", "MSlot1SettingsText", "MSlot2SettingsText", "MSlot3SettingsText", "MSlot1SeparatorLine", "MSlot2SeparatorLine", "MSlot1CycleText", "MSlot2CycleText", "MSlot3CycleText", "MSlot1Left", "MSlot2Left", "MSlot3Left", "MSlot1Right", "MSlot2Right", "MSlot3Right", "MSlot1ChangeText", "MSlot2ChangeText", "MSlot3ChangeText", "MSectionSeparatorLine", "MSliderSeparatorLine", "MHarvestText", "MHarvestInterval", "MPageLeft", "MPageRight", "MPageNumberText"]
	For k, v in ManualPlantersControls
		GuiControl, disable, %v%
}
nm_TabPlantersUnLock(){
	global
	GuiControl, enable, PlanterMode
	;planters+
	GuiControl, enable, NPreset
	GuiControl, enable, N1Priority
	GuiControl, enable, N2Priority
	GuiControl, enable, N3Priority
	GuiControl, enable, N4Priority
	GuiControl, enable, N5Priority
	GuiControl, enable, N1MinPercent
	GuiControl, enable, N2MinPercent
	GuiControl, enable, N3MinPercent
	GuiControl, enable, N4MinPercent
	GuiControl, enable, N5MinPercent
	GuiControl, enable, MaxAllowedPlanters
	GuiControl, enable, MaxAllowedPlantersEdit
	GuiControl, enable, AutomaticHarvestInterval
	GuiControl, enable, HarvestFullGrown
	GuiControl, enable, gotoPlanterField
	GuiControl, enable, gatherFieldSipping
	GuiControl, enable, ConvertFullBagHarvest
	GuiControl, enable, GatherPlanterLoot
	GuiControl, enable, HarvestInterval
	GuiControl, enable, PlasticPlanterCheck
	GuiControl, enable, CandyPlanterCheck
	GuiControl, enable, BlueClayPlanterCheck
	GuiControl, enable, RedClayPlanterCheck
	GuiControl, enable, TackyPlanterCheck
	GuiControl, enable, PesticidePlanterCheck
	GuiControl, enable, HeatTreatedPlanterCheck
	GuiControl, enable, HydroponicPlanterCheck
	GuiControl, enable, PetalPlanterCheck
	GuiControl, enable, PlanterOfPlentyCheck
	GuiControl, enable, PaperPlanterCheck
	GuiControl, enable, TicketPlanterCheck
	GuiControl, enable, DandelionFieldCheck
	GuiControl, enable, SunflowerFieldCheck
	GuiControl, enable, MushroomFieldCheck
	GuiControl, enable, BlueFlowerFieldCheck
	GuiControl, enable, CloverFieldCheck
	GuiControl, enable, SpiderFieldCheck
	GuiControl, enable, StrawberryFieldCheck
	GuiControl, enable, BambooFieldCheck
	GuiControl, enable, PineappleFieldCheck
	GuiControl, enable, StumpFieldCheck
	GuiControl, enable, CactusFieldCheck
	GuiControl, enable, PumpkinFieldCheck
	GuiControl, enable, PineTreeFieldCheck
	GuiControl, enable, RoseFieldCheck
	GuiControl, enable, MountainTopFieldCheck
	GuiControl, enable, CoconutFieldCheck
	GuiControl, enable, PepperFieldCheck
	;manual
	mp_UpdateControls()
}
nm_TabSettingsLock(){
	GuiControl, disable, GuiTheme
	GuiControl, disable, GuiTransparency
	GuiControl, disable, FwdKey
	GuiControl, disable, LeftKey
	GuiControl, disable, BackKey
	GuiControl, disable, RightKey
	GuiControl, disable, RotLeft
	GuiControl, disable, RotRight
	GuiControl, disable, ZoomIn
	GuiControl, disable, ZoomOut
	GuiControl, disable, KeyDelay
	GuiControl, disable, KeyDelayEdit
	GuiControl, disable, MoveSpeedNum
	GuiControl, disable, MoveMethod
	GuiControl, disable, SprinklerType
	GuiControl, disable, MultiReset
	GuiControl, disable, ConvertBalloon
	GuiControl, disable, ConvertMins
	GuiControl, disable, GatherDoubleReset
	GuiControl, disable, DisableToolUse
	GuiControl, disable, AnnounceGuidingStar
	GuiControl, disable, NewWalk
	GuiControl, disable, HiveSlot
	GuiControl, disable, HiveBees
	GuiControl, disable, ConvertDelay
	GuiControl, disable, PrivServer
	GuiControl, disable, ReconnectMessage
	GuiControl, disable, PublicFallback
}
nm_TabSettingsUnLock(){
	GuiControlGet, ConvertBalloon
	GuiControl, enable, GuiTheme
	GuiControl, enable, GuiTransparency
	GuiControl, enable, KeyDelay
	GuiControl, enable, KeyDelayEdit
	GuiControl, enable, MoveSpeedNum
	GuiControl, enable, MoveMethod
	GuiControl, enable, SprinklerType
	GuiControl, enable, MultiReset
	GuiControl, enable, ConvertBalloon
	if(ConvertBalloon="every")
		GuiControl, enable, ConvertMins
	GuiControl, enable, GatherDoubleReset
	GuiControl, enable, DisableToolUse
	GuiControl, enable, AnnounceGuidingStar
	GuiControl, enable, NewWalk
	GuiControl, enable, HiveSlot
	GuiControl, enable, HiveBees
	GuiControl, enable, ConvertDelay
	GuiControl, enable, PrivServer
	GuiControl, enable, ReconnectMessage
	GuiControl, enable, PublicFallback
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Optical Character Recognition (OCR) functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HBitmapFromScreen(X, Y, W, H) {
   HDC := DllCall("GetDC", "Ptr", 0, "UPtr")
   HBM := DllCall("CreateCompatibleBitmap", "Ptr", HDC, "Int", W, "Int", H, "UPtr")
   PDC := DllCall("CreateCompatibleDC", "Ptr", HDC, "UPtr")
   DllCall("SelectObject", "Ptr", PDC, "Ptr", HBM)
   DllCall("BitBlt", "Ptr", PDC, "Int", 0, "Int", 0, "Int", W, "Int", H
                   , "Ptr", HDC, "Int", X, "Int", Y, "UInt", 0x00CC0020)
   DllCall("DeleteDC", "Ptr", PDC)
   DllCall("ReleaseDC", "Ptr", 0, "Ptr", HDC)
   Return HBM
}
HBitmapToRandomAccessStream(hBitmap) {
   static IID_IRandomAccessStream := "{905A0FE1-BC53-11DF-8C49-001E4FC686DA}"
        , IID_IPicture            := "{7BF80980-BF32-101A-8BBB-00AA00300CAB}"
        , PICTYPE_BITMAP := 1
        , BSOS_DEFAULT   := 0

   DllCall("Ole32\CreateStreamOnHGlobal", "Ptr", 0, "UInt", true, "PtrP", pIStream, "UInt")

   VarSetCapacity(PICTDESC, sz := 8 + A_PtrSize*2, 0)
   NumPut(sz, PICTDESC)
   NumPut(PICTYPE_BITMAP, PICTDESC, 4)
   NumPut(hBitmap, PICTDESC, 8)
   riid := CLSIDFromString(IID_IPicture, GUID1)
   DllCall("OleAut32\OleCreatePictureIndirect", "Ptr", &PICTDESC, "Ptr", riid, "UInt", false, "PtrP", pIPicture, "UInt")
   ; IPicture::SaveAsFile
   DllCall(NumGet(NumGet(pIPicture+0) + A_PtrSize*15), "Ptr", pIPicture, "Ptr", pIStream, "UInt", true, "UIntP", size, "UInt")
   riid := CLSIDFromString(IID_IRandomAccessStream, GUID2)
   DllCall("ShCore\CreateRandomAccessStreamOverStream", "Ptr", pIStream, "UInt", BSOS_DEFAULT, "Ptr", riid, "PtrP", pIRandomAccessStream, "UInt")
   ObjRelease(pIPicture)
   ObjRelease(pIStream)
   Return pIRandomAccessStream
}
ocr(file, lang := "FirstFromAvailableLanguages")
{
   static OcrEngineStatics, OcrEngine, MaxDimension, LanguageFactory, Language, CurrentLanguage, BitmapDecoderStatics, GlobalizationPreferencesStatics
   if (OcrEngineStatics = "")
   {
      CreateClass("Windows.Globalization.Language", ILanguageFactory := "{9B0252AC-0C27-44F8-B792-9793FB66C63E}", LanguageFactory)
      CreateClass("Windows.Graphics.Imaging.BitmapDecoder", IBitmapDecoderStatics := "{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", BitmapDecoderStatics)
      CreateClass("Windows.Media.Ocr.OcrEngine", IOcrEngineStatics := "{5BFFA85A-3384-3540-9940-699120D428A8}", OcrEngineStatics)
      DllCall(NumGet(NumGet(OcrEngineStatics+0)+6*A_PtrSize), "ptr", OcrEngineStatics, "uint*", MaxDimension)   ; MaxImageDimension
   }
   if (file = "ShowAvailableLanguages")
   {
      if (GlobalizationPreferencesStatics = "")
         CreateClass("Windows.System.UserProfile.GlobalizationPreferences", IGlobalizationPreferencesStatics := "{01BF4326-ED37-4E96-B0E9-C1340D1EA158}", GlobalizationPreferencesStatics)
      DllCall(NumGet(NumGet(GlobalizationPreferencesStatics+0)+9*A_PtrSize), "ptr", GlobalizationPreferencesStatics, "ptr*", LanguageList)   ; get_Languages
      DllCall(NumGet(NumGet(LanguageList+0)+7*A_PtrSize), "ptr", LanguageList, "int*", count)   ; count
      loop % count
      {
         DllCall(NumGet(NumGet(LanguageList+0)+6*A_PtrSize), "ptr", LanguageList, "int", A_Index-1, "ptr*", hString)   ; get_Item
         DllCall(NumGet(NumGet(LanguageFactory+0)+6*A_PtrSize), "ptr", LanguageFactory, "ptr", hString, "ptr*", LanguageTest)   ; CreateLanguage
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+8*A_PtrSize), "ptr", OcrEngineStatics, "ptr", LanguageTest, "int*", bool)   ; IsLanguageSupported
         if (bool = 1)
         {
            DllCall(NumGet(NumGet(LanguageTest+0)+6*A_PtrSize), "ptr", LanguageTest, "ptr*", hText)
            buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
            text .= StrGet(buffer, "UTF-16") "`n"
         }
         ObjRelease(LanguageTest)
      }
      ObjRelease(LanguageList)
      return text
   }
   if (lang != CurrentLanguage) or (lang = "FirstFromAvailableLanguages")
   {
      if (OcrEngine != "")
      {
         ObjRelease(OcrEngine)
         if (CurrentLanguage != "FirstFromAvailableLanguages")
            ObjRelease(Language)
      }
      if (lang = "FirstFromAvailableLanguages")
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+10*A_PtrSize), "ptr", OcrEngineStatics, "ptr*", OcrEngine)   ; TryCreateFromUserProfileLanguages
      else
      {
         CreateHString(lang, hString)
         DllCall(NumGet(NumGet(LanguageFactory+0)+6*A_PtrSize), "ptr", LanguageFactory, "ptr", hString, "ptr*", Language)   ; CreateLanguage
         DeleteHString(hString)
         DllCall(NumGet(NumGet(OcrEngineStatics+0)+9*A_PtrSize), "ptr", OcrEngineStatics, ptr, Language, "ptr*", OcrEngine)   ; TryCreateFromLanguage
      }
      if (OcrEngine = 0)
      {
         msgbox Can not use language "%lang%" for OCR, please install language pack.
         ExitApp
      }
      CurrentLanguage := lang
   }
   IRandomAccessStream := file
   DllCall(NumGet(NumGet(BitmapDecoderStatics+0)+14*A_PtrSize), "ptr", BitmapDecoderStatics, "ptr", IRandomAccessStream, "ptr*", BitmapDecoder)   ; CreateAsync
   WaitForAsync(BitmapDecoder)
   BitmapFrame := ComObjQuery(BitmapDecoder, IBitmapFrame := "{72A49A1C-8081-438D-91BC-94ECFC8185C6}")
   DllCall(NumGet(NumGet(BitmapFrame+0)+12*A_PtrSize), "ptr", BitmapFrame, "uint*", width)   ; get_PixelWidth
   DllCall(NumGet(NumGet(BitmapFrame+0)+13*A_PtrSize), "ptr", BitmapFrame, "uint*", height)   ; get_PixelHeight
   if (width > MaxDimension) or (height > MaxDimension)
   {
      msgbox Image is to big - %width%x%height%.`nIt should be maximum - %MaxDimension% pixels
      ExitApp
   }
   BitmapFrameWithSoftwareBitmap := ComObjQuery(BitmapDecoder, IBitmapFrameWithSoftwareBitmap := "{FE287C9A-420C-4963-87AD-691436E08383}")
   DllCall(NumGet(NumGet(BitmapFrameWithSoftwareBitmap+0)+6*A_PtrSize), "ptr", BitmapFrameWithSoftwareBitmap, "ptr*", SoftwareBitmap)   ; GetSoftwareBitmapAsync
   WaitForAsync(SoftwareBitmap)
   DllCall(NumGet(NumGet(OcrEngine+0)+6*A_PtrSize), "ptr", OcrEngine, ptr, SoftwareBitmap, "ptr*", OcrResult)   ; RecognizeAsync
   WaitForAsync(OcrResult)
   DllCall(NumGet(NumGet(OcrResult+0)+6*A_PtrSize), "ptr", OcrResult, "ptr*", LinesList)   ; get_Lines
   DllCall(NumGet(NumGet(LinesList+0)+7*A_PtrSize), "ptr", LinesList, "int*", count)   ; count
   loop % count
   {
      DllCall(NumGet(NumGet(LinesList+0)+6*A_PtrSize), "ptr", LinesList, "int", A_Index-1, "ptr*", OcrLine)
      DllCall(NumGet(NumGet(OcrLine+0)+7*A_PtrSize), "ptr", OcrLine, "ptr*", hText)
      buffer := DllCall("Combase.dll\WindowsGetStringRawBuffer", "ptr", hText, "uint*", length, "ptr")
      text .= StrGet(buffer, "UTF-16") "`n"
      ObjRelease(OcrLine)
   }
   Close := ComObjQuery(IRandomAccessStream, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
   DllCall(NumGet(NumGet(Close+0)+6*A_PtrSize), "ptr", Close)   ; Close
   ObjRelease(Close)
   Close := ComObjQuery(SoftwareBitmap, IClosable := "{30D5A829-7FA4-4026-83BB-D75BAE4EA99E}")
   DllCall(NumGet(NumGet(Close+0)+6*A_PtrSize), "ptr", Close)   ; Close
   ObjRelease(Close)
   ObjRelease(IRandomAccessStream)
   ObjRelease(BitmapDecoder)
   ObjRelease(BitmapFrame)
   ObjRelease(BitmapFrameWithSoftwareBitmap)
   ObjRelease(SoftwareBitmap)
   ObjRelease(OcrResult)
   ObjRelease(LinesList)
   return text
}
CLSIDFromString(IID, ByRef CLSID) {
   VarSetCapacity(CLSID, 16, 0)
   if res := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", &CLSID, "UInt")
      throw Exception("CLSIDFromString failed. Error: " . Format("{:#x}", res))
   Return &CLSID
}
CreateClass(string, interface, ByRef Class)
{
   CreateHString(string, hString)
   VarSetCapacity(GUID, 16)
   DllCall("ole32\CLSIDFromString", "wstr", interface, "ptr", &GUID)
   result := DllCall("Combase.dll\RoGetActivationFactory", "ptr", hString, "ptr", &GUID, "ptr*", Class)
   if (result != 0)
   {
      if (result = 0x80004002)
         msgbox No such interface supported
      else if (result = 0x80040154)
         msgbox Class not registered
      else
         msgbox error: %result%
      ExitApp
   }
   DeleteHString(hString)
}
CreateHString(string, ByRef hString)
{
    DllCall("Combase.dll\WindowsCreateString", "wstr", string, "uint", StrLen(string), "ptr*", hString)
}
DeleteHString(hString)
{
   DllCall("Combase.dll\WindowsDeleteString", "ptr", hString)
}
WaitForAsync(ByRef Object)
{
   AsyncInfo := ComObjQuery(Object, IAsyncInfo := "{00000036-0000-0000-C000-000000000046}")
   loop
   {
      DllCall(NumGet(NumGet(AsyncInfo+0)+7*A_PtrSize), "ptr", AsyncInfo, "uint*", status)   ; IAsyncInfo.Status
      if (status != 0)
      {
         if (status != 1)
         {
            DllCall(NumGet(NumGet(AsyncInfo+0)+8*A_PtrSize), "ptr", AsyncInfo, "uint*", ErrorCode)   ; IAsyncInfo.ErrorCode
            msgbox AsyncInfo status error: %ErrorCode%
            ExitApp
         }
         ObjRelease(AsyncInfo)
         break
      }
      sleep 10
   }
   DllCall(NumGet(NumGet(Object+0)+8*A_PtrSize), "ptr", Object, "ptr*", ObjectResult)   ; GetResults
   ObjRelease(Object)
   Object := ObjectResult
}
;OCRMutation(ByRef amount, ByRef stat, x1, y1, w1, h1)
ba_OCRStringExists(findString, aim:="full")
{
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
    xi := 0
    yi := 0
	ww := windowWidth
	wh := windowHeight
    if (aim!="full"){
        if (aim = "low")
			yi := windowHeight / 2
        if (aim = "high")
            wh := windowHeight / 2
		if (aim = "buff")
            wh := 150
		if (aim = "left")
			ww := windowWidth / 2
		if (aim = "right")
			xi := windowWidth / 2
		if (aim = "center") {
			xi := windowWidth / 4
			yi := windowHeight / 4
			ww := xi*3
			wh := yi*3
		}
        if (aim = "lowright") {
            yi := windowHeight / 2
            xi := windowWidth / 2
        }
		if (aim = "highright") {
            xi := windowWidth / 2
			wh := windowHeight / 2
        }
    }
	hBitmap := HBitmapFromScreen(xi, yi, ww, wh)
	pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
	DllCall("DeleteObject", "Ptr", hBitmap)
	ocrtext := StrReplace(StrReplace(ocr(pIRandomAccessStream, "en"), "`n"), " ")
	;msgbox %ocrtext%
	if(InStr(ocrtext, findString)) {
		return 1
	} else {
		return 0
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_PlanterDetection()
{
	static pBMProgressStart, pBMProgressEnd, pBMRemain

	;defines the bitmaps via hex color
	if ((pBMProgressStart = "") || (pBMProgressEnd = "") || (pBMRemain = ""))
	{
		pBMProgressStart := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressStart), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMProgressEnd := Gdip_CreateBitmap(1,2)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressEnd), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMRemain := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMRemain), Gdip_GraphicsClear(pGraphics, 0xff567848), Gdip_DeleteGraphics(pGraphics)
	}

	WinActivate, Roblox
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)

	sPlanterStart := Gdip_ImageSearch(pBMScreen, pBMProgressStart, PStart, , , , , , , 5)
	x := SubStr(PStart, 1, InStr(PStart, ",")-1), y := SubStr(PStart, InStr(PStart, ",")+1)
	sPlanterEnd := Gdip_ImageSearch(pBMScreen, pBMProgressEnd, PEnd, x, y, , y+2, , , 8)
	sPBarEnd := Gdip_ImageSearch(pBMScreen, pBMRemain, PBarEnd, x, y, , y+8, , , 8)

	Gdip_DisposeImage(pBMScreen)

	if !((sPlanterStart = 0) || (sPlanterEnd = 0) || (sPBarEnd = 0))
	{
		cx2 := SubStr(PEnd, 1, InStr(PEnd, ",")-1)+1, dx2 := SubStr(PBarEnd, 1, InStr(PBarEnd, ",")-1)+1
		PlanterBarRemain := Round((dx2-cx2)/(dx2-x)*100, 2)
		PlanterBarProgress := (cx2-x)/(dx2-x)
		return PlanterBarProgress
	}
	else
		return 0
}
nm_PlanterTimeUpdate(FieldName)
{
	global
	local i, field, k, v, r, PlanterGrowTime, PlanterBarProgress

	Loop, 3
	{
		i := A_Index
		if ((((PlanterMode = 2) && HarvestFullGrown) || ((PlanterMode = 1) && (PlanterHarvestFull%i% = "Full"))) && (PlanterField%i% = FieldName))
		{
			field := StrReplace(FieldName, " ")
			for k,v in %field%Planters
			{
				if (v[1] = PlanterName%i%)
				{
					PlanterGrowTime := v[4]
					break
				}
			}

			sendinput {%RotUp% 4}
			Sleep, 200
			Loop, 20
			{
				if ((PlanterBarProgress := nm_PlanterDetection()) > 0)
				{
					PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
					IniWrite, % PlanterHarvestTime%i%, settings\nm_config.ini, Planters, PlanterHarvestTime%i%
					nm_setStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress*100) "%")
					break
				}
				Sleep, 100
				sendinput {%ZoomOut%}
				if (A_Index = 10)
				{
					sendinput {%RotLeft% 2}
					r := 1
				}
			}
			sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
			Sleep, 500
		}
	}
}
;syspalk if you're reading this hi
;(+) Keep this in for the final
nm_HealthDetection() 
{
	static pBMHealth, pBMDamage
    HealthBars := []
    if (pBMHealth= "" || pBMDamage= "")
	{
		pBMHealth := Gdip_CreateBitmap(1,4)
		pGraphics := Gdip_GraphicsFromImage(pBMHealth), Gdip_GraphicsClear(pGraphics, 0xff1fe744), Gdip_DeleteGraphics(pGraphics)
        pBMDamage := Gdip_CreateBitmap(1,4)
        pGraphics := Gdip_GraphicsFromImage(pBMDamage), Gdip_GraphicsClear(pGraphics, 0xff6b131a), Gdip_DeleteGraphics(pGraphics)
	}
	WinActivate, Roblox
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
    G := Gdip_GraphicsFromImage(pBMScreen)
    pBrush := Gdip_BrushCreateSolid(0xff000000)
    while ((Gdip_ImageSearch(pBMScreen, pBMHealth, HPStart, , , , , , , 5) > 0) || (Gdip_ImageSearch(pBMScreen, pBMDamage, HPStart, , , , , , , 5) > 0))
    {
        x := SubStr(HPStart, 1, InStr(HPStart, ",")-1), y := SubStr(HPStart, InStr(HPStart, ",")+1)
        x1 := x, y1 := y
        loop % (windowWidth - x)
        {
            i := x + A_Index - 1 
            switch % Gdip_GetPixel(pBMScreen, i, y)
            { 
                case 4280280900:
                x1++

                case 4285207322:
                x2 := i 

                default:
                Break
            }
        }
        loop % (windowHeight - y)
        {
            switch % Gdip_GetPixel(pBMScreen, x, y1)
            {
                case 4280280900, 4285207322: 
                y1++

                default: 
                Break
            }
        } 
		HealthBarPercent := (x1 > x) ? ((x2 > x) ? Round((x1-x)/(x2-x)*100, 2) : 100.00) : 0.00
        Gdip_FillRectangle(G, pBrush, x, y, i-x, y1-y)
        HealthBars.Push(HealthBarPercent) 
		if (A_Index > 100)
		{
			Break
		}
    }
    Gdip_DeleteBrush(pBrush), Gdip_DisposeImage(pBMScreen), Gdip_DeleteGraphics(G)
    Return HealthBars  
} 
;;Time interval in minutes 
nm_KillTimeEstimation(bossName, bossTimer)
{
	global InputSnailHealth, SnailTime, InputChickHealth, ChickTime, intialHealthCheck
    static bosses := {}
	confidenceArray := []
	confidenceTotal := 0
	if (!intialHealthCheck)
	{
	    bosses[bossName "Health"] := (Input%bossName%Health > 0) ? Input%bossName%Health : 100
	    intialHealthCheck := 1
	}
	bosses[bossName "TimeInterval"] := bossTimer 
	loop 5
	{
	    HealthBars := nm_HealthDetection()
	    for i, v in HealthBars
	    {
	        if (v = 100.00) ;Not enough damage was dealt or there is a planter detected
	        {
	            continue
	        }
	        else if (!healthDiff || (Abs(bosses[bossName "Health"] - v) < healthDiff))
	        {
	            healthDiff := Abs(bosses[bossName "Health"] - v)
	            lastHealth := v
	            confidenceArray.Push(v)
	        }
	    }
	}
	for index, value in confidenceArray
	{
	    confidenceTotal += value
	}
	confidenceMean := confidenceTotal / confidenceArray.Length()
	if ((confidenceMean >= lastHealth - 1) && (confidenceMean <= lastHealth + 1))
	{
		dmgDealt := round((bosses[bossName "Health"]-lastHealth)/(bosses[bossName "TimeInterval"]/60000), 4)
    	timeEstimation := round(lastHealth/abs(dmgDealt), 2)
		elapsedMins := floor(bossTimer/60000)
		elapsedSecs := Mod(bossTimer, 60)
		if ((dmgDealt >= 0) && ((abs(bosses[bossName "Health"]-lastHealth) >= 2.5) && lastHealth > 0))
		{
    		if (timeEstimation > 60) 
			{
				sHours := Floor(timeEstimation/60)
				sMinutes := Mod(timeEstimation, 60)
    			nm_setStatus("Detected", "Health`nBoss: " bossName "`n Est Previous Health: " round(bosses[bossName "Health"], 2) "%`n Est Current Health: " lastHealth "%`n Est Change of health: " round(abs(dmgDealt), 2) "% Per minute`nEst Time until dead: " round(sHours) " Hours " round(sMinutes) " Minutes`nTime Elasped: " elapsedMins " Minutes " elapsedSecs " Seconds")
			}
			else 
			{
				sMinutes := Floor(timeEstimation)
				Sseconds := Round((timeEstimation - sMinutes) * 60)
   				nm_setStatus("Detected", "Health`nBoss: " bossName "`n Est Previous Health: " round(bosses[bossName "Health"], 2) "%`n Est Current Health: " lastHealth "%`n EstChange of health: " round(abs(dmgDealt), 2) "% Per minute`nEst Time until dead: " round(sMinutes) " Minutes " round(sSeconds) " Seconds `nTime Elasped: " elapsedMins " Minutes  " elapsedSecs " Seconds")
			}
			IniWrite, %lastHealth%, settings\nm_config.ini, Collect, Input%bossName%Health
			bosses[bossName "Health"] := lastHealth
		}
		else
		{
			Return 0
		}
	}
}


nm_imgSearch(fileName,v,aim := "full", trans:="none"){
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
    ;xi := 0
    ;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi:=(aim="actionbar") ? windowWidth/4 : (aim="highright") ? windowWidth/2 : (aim="right") ? windowWidth/2 : (aim="center") ? windowWidth/4 : (aim="lowright") ? windowWidth/2 : 0
	yi:=(aim="low") ? windowHeight/2 : (aim="actionbar") ? (windowHeight/4)*3 : (aim="center") ? yi:=windowHeight/4 : (aim="lowright") ? windowHeight/2 : (aim="quest") ? 150 : 0
	ww:=(aim="actionbar") ? xi*3 : (aim="highleft") ? windowWidth/2 : (aim="left") ? windowWidth/2 : (aim="center") ? xi*3 : (aim="quest") ? 310 : windowWidth
	wh:=(aim="high") ? windowHeight/2 : (aim="highright") ? windowHeight/2 : (aim="highleft") ? windowHeight/2 : (aim="buff") ? 150 : (aim="abovebuff") ? 30 : (aim="center") ? yi*3 : (aim="quest") ? Max(560, windowHeight-100) : windowHeight
	IfExist, %A_ScriptDir%\nm_image_assets\
	{
		if(trans!="none")
			ImageSearch, FoundX, FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, *%v% *Trans%trans% %A_ScriptDir%\nm_image_assets\%fileName%
		else
			ImageSearch, FoundX, FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, *%v% %A_ScriptDir%\nm_image_assets\%fileName%
		if (ErrorLevel = 2) {
			nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
			Sleep, 5000
			Process, Close, % DllCall("GetCurrentProcessId")
		}
		return [ErrorLevel,FoundX-windowX,FoundY-windowY]
	} else {
		MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		return 3, 0, 0
	}
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
nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}
nm_Reset(checkAll:=1, wait:=2000, convert:=1, force:=0){
	global resetTime
	global youDied
	global VBState
	global KeyDelay
	global SC_E, SC_Esc, SC_R, SC_Enter, RotRight, RotUp, RotDown, ZoomOut
	global objective
	global AFBrollingDice
	global AFBuseGlitter
	global AFBuseBooster
	global currentField
	global HiveConfirmed, GameFrozenCounter, MultiReset, bitmaps
	nm_setShiftLock(0)
	;check for game frozen conditions
	if (GameFrozenCounter>=3) { ;3 strikes
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		CloseRoblox()
		GameFrozenCounter:=0
	}
	DisconnectCheck()
	if(youDied && not instr(objective, "mondo") && VBState=0){
		wait:=max(wait, 20000)
	}
	;mondo or coconut crab likely killed you here! skip over this field if possible
	if(youDied && (currentField="mountain top" || currentField="coconut"))
		nm_currentFieldDown()
	youDied:=0
	nm_AutoFieldBoost(currentField)
	;checkAll bypass to avoid infinite recursion here
	if(checkAll=1) {
		nm_fieldBoostBooster()
		nm_locateVB()
	}
	if(force=1) {
		HiveConfirmed:=0
	}
	while (!HiveConfirmed) {
		;failsafe game frozen
		if(Mod(A_Index, 10) = 0) {
			nm_setStatus("Closing", "and Re-Open Roblox")
			CloseRoblox()
			DisconnectCheck()
			continue
		}
		DisconnectCheck()
		WinActivate, Roblox
		;check to make sure you are not in dialog before reset
		Loop, 500
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], pos, , , , , 10, , 3) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
			Click
			sleep, 150
		}
		MouseMove, windowX+350, windowY+100
		;check to make sure you are not in a yes/no prompt
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], pos, , , , , 2, , 3) = 1) {
			MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
			Click
			MouseMove, windowX+350, windowY+100
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in feed window on accident
		imgPos := nm_imgSearch("cancel.png",30)
		If (imgPos[1] = 0){
			MouseMove, windowX+(imgPos[2]), windowY+(imgPos[3])
			Click
			MouseMove, windowX+350, windowY+100
		}
		;check to make sure you are not in shop before reset
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0) {
			loop 2 {
				shopG := nm_imgSearch("shop_corner_G.png",30,"right")
				shopR := nm_imgSearch("shop_corner_R.png",30,"right")
				If (shopG[1] = 0 || shopR[1] = 0) {
					sendinput {%SC_E% down}
					Sleep, 100
					sendinput {%SC_E% up}
					sleep, 1000
				}
			}
		}
		;check to make sure there is not a window open
		searchRet := nm_imgSearch("close.png",30,"full")
		If (searchRet[1] = 0) {
			MouseMove, windowX+searchRet[2],windowY+searchRet[3]
			click
			MouseMove, windowX+350, windowY+100
			sleep, 1000
		}
		nm_setStatus("Resetting", "Character " . Mod(A_Index, 10))
		MouseMove, windowX+350, windowY+100
		PrevKeyDelay:=A_KeyDelay
		SetKeyDelay, 250+KeyDelay
		Loop % (VBState = 0) ? (1 + MultiReset + (GatherDoubleReset && (CheckAll=2))) : 1
		{
			resetTime:=nowUnix()
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("background.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5554, 1, resetTime
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			;reset
			WinActivate, Roblox
			send {%SC_Esc%}{%SC_R%}{%SC_Enter%}
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep, 250
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-100 "|" windowY "|100|32")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep, 1000
		}
		SetKeyDelay, PrevKeyDelay
		sendinput {%RotUp% 4}
		send {%ZoomOut% 8}
		sleep,500
		loop, 4 { ;16
			If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0)){
				sendinput {%RotRight% 4}{%RotDown% 4}
				HiveConfirmed:=1
				break
			}
			sendinput {%RotRight% 4}
			sleep (250+KeyDelay)
		}
	}
	;convert
	(convert=1) ? nm_convert()
	;ensure minimum delay has been met
	if((nowUnix()-resetTime)<wait) {
		remaining:=floor((wait-(nowUnix()-resetTime))/1000) ;seconds
		if(remaining>5){
			Sleep, 1000
			nm_setStatus("Waiting", remaining . " Seconds")
			Sleep, (remaining-1)*1000
		}
		else {
			sleep, (remaining*1000) ;miliseconds
		}
	}
}
nm_setShiftLock(state){
	global bitmaps, SC_LShift, ShiftLockEnabled
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe") ; Shift Lock is not supported on UWP app at the moment
	if (windowWidth = 0)
		return 2
	else
		WinActivate, Roblox

	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50")

	switch (v := Gdip_ImageSearch(pBMScreen, bitmaps["shiftlock"], , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
		if (state = 0)
		{
			send {%SC_LShift%}
			result := 0
		}
		else
			result := 1

		; shift lock disabled - enable if needed
		case 0:
		if (state = 1)
		{
			send {%SC_LShift%}
			result := 1
		}
		else
			result := 0
	}

	Gdip_DisposeImage(pBMScreen)
	return (ShiftLockEnabled := result)
}
; decision: "keep", 1; "replace", 2 // returns 0 - no prompt, 1 - prompt exists, 2 - no roblox window
nm_AmuletPrompt(decision:=0){
	global bitmaps, ShiftLockEnabled

	Prev_ShiftLock := ShiftLockEnabled
	nm_setShiftLock(0)

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	if (windowWidth = 0)
		return 2
	else
		WinActivate, Roblox

	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)

	if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], pos, , , , , 2, , 2) = 1)
	{
		switch % decision
		{
			case "keep",1:
			MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+10, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
			Click
			Gdip_DisposeImage(pBMScreen)
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			case "replace",2:
			MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+190, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
			Click
			Gdip_DisposeImage(pBMScreen)
			Loop, 25
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 2, , 2) = 1)
				{
					MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+SubStr(pos, InStr(pos, ",")+1), 5
					Click
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep, 100
			}
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			default:
			Gdip_DisposeImage(pBMScreen)
			nm_setShiftLock(Prev_ShiftLock)
			return 1
		}
	}
	else
	{
		Gdip_DisposeImage(pBMScreen)
		nm_setShiftLock(Prev_ShiftLock)
		return 0
	}
}
nm_gotoRamp(){
	global FwdKey, RightKey, HiveSlot, state, objective, HiveConfirmed
	HiveConfirmed := 0

	movement := "
	(LTrim Join`r`n
	" nm_Walk(6, FwdKey) "
	" nm_Walk(8.35*HiveSlot+1, RightKey) "
	)"

	nm_createWalk(movement)
	KeyWait, F14, D T5 L
    KeyWait, F14, T60 L
    nm_endWalk()
}
nm_gotoCannon(){
	global LeftKey, RightKey, currentWalk, objective, SC_Space, bitmaps

	nm_setShiftLock(0)

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	MouseMove, windowX+350, windowY+100

	success := 0
	Loop, 10
	{
		SendInput {%SC_Space% down}
		Sleep, 100
		SendInput {%SC_Space% up}{%RightKey% down}
		DllCall("GetSystemTimeAsFileTime","int64p",s)
		n := s, f := s+100000000
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
			{
				success := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime","int64p",n)
		}
		SendInput {%RightKey% up}

		if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
		{
			Loop, 10
			{
				if (A_Index = 10)
				{
					success := 0
					break
				}
				Sleep, 500
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					break 2
				}
				else
				{
					movement := "
					(LTrim Join`r`n
					" nm_Walk(1.5, LeftKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T5 L
					nm_endWalk()
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}

		if (success = 0)
		{
			obj := objective
			nm_Reset()
			nm_setStatus("Traveling", obj)
			nm_gotoRamp()
		}
	}
	if (success = 0) { ;game frozen close roblox
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		CloseRoblox()
	}
}
nm_findHiveSlot(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, HiveConfirmed, bitmaps

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	MouseMove, windowX+350, windowY+100

	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
	if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
		HiveConfirmed := 1
	else
	{
		; find hive slot
		movement := "
		(LTrim Join`r`n
		" nm_Walk(4, FwdKey) "
		" nm_Walk(5.25, BackKey) "
		)"
		nm_createWalk(movement)
		KeyWait, F14, D T5 L
		KeyWait, F14, T20 L
		nm_endWalk()

		DllCall("GetSystemTimeAsFileTime","int64p",s)
		n := s, f := s+150000000
		SendInput {%LeftKey% down}
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				HiveConfirmed := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime","int64p",n)
		}
		SendInput {%LeftKey% up}
	}

	if (HiveConfirmed = 1) ; check that hive slot was not overrun, at the expense of a small delay
	{
		Loop, 10
		{
			if (A_Index = 10)
			{
				HiveConfirmed := 0
				break
			}
			Sleep, 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				nm_convert()
				break
			}
			else
			{
				movement := "
				(LTrim Join`r`n
				" nm_Walk(1.5, RightKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T5 L
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}

	return HiveConfirmed
}
nm_walkTo(location){
	global
	static paths := {}, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\wt-bamboo.ahk
		#Include %A_ScriptDir%\paths\wt-blueflower.ahk
		#Include %A_ScriptDir%\paths\wt-cactus.ahk
		#Include %A_ScriptDir%\paths\wt-clover.ahk
		#Include %A_ScriptDir%\paths\wt-coconut.ahk
		#Include %A_ScriptDir%\paths\wt-dandelion.ahk
		#Include %A_ScriptDir%\paths\wt-mountaintop.ahk
		#Include %A_ScriptDir%\paths\wt-mushroom.ahk
		#Include %A_ScriptDir%\paths\wt-pepper.ahk
		#Include %A_ScriptDir%\paths\wt-pinetree.ahk
		#Include %A_ScriptDir%\paths\wt-pineapple.ahk
		#Include %A_ScriptDir%\paths\wt-pumpkin.ahk
		#Include %A_ScriptDir%\paths\wt-rose.ahk
		#Include %A_ScriptDir%\paths\wt-spider.ahk
		#Include %A_ScriptDir%\paths\wt-strawberry.ahk
		#Include %A_ScriptDir%\paths\wt-stump.ahk
		#Include %A_ScriptDir%\paths\wt-sunflower.ahk
		SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	HiveConfirmed:=0

	InStr(paths[location], "gotoramp") ? nm_gotoRamp()
	InStr(paths[location], "gotocannon") ? nm_gotoCannon()

	nm_createWalk(paths[location])
	KeyWait, F14, D T5 L
	KeyWait, F14, T120 L
	nm_endWalk()
}
nm_gotoBooster(booster){
	global
	static paths := {}, SetMoveMethod, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\gtb-red.ahk
		#Include %A_ScriptDir%\paths\gtb-blue.ahk
		#Include %A_ScriptDir%\paths\gtb-mountain.ahk
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	HiveConfirmed:=0

	InStr(paths[booster], "gotoramp") ? nm_gotoRamp()
	InStr(paths[booster], "gotocannon") ? nm_gotoCannon()

	nm_createWalk(paths[booster])
	KeyWait, F14, D T5 L
	KeyWait, F14, T120 L
	nm_endWalk()
}
nm_toBooster(location){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, KeyDelay, MoveSpeedNum, MoveMethod, SC_E
	global LastBlueBoost, LastRedBoost, LastMountainBoost, RecentFBoost, objective
	static blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower"], redBoosterFields:=["Rose", "Strawberry", "Mushroom"], mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]

	success:=0
	Loop, 2 {
		nm_Reset(0)
		nm_setStatus("Traveling", (location="red") ? "Red Field Booster" : (location="blue") ? "Blue Field Booster" : "Mountain Top Field Booster")
		nm_gotoBooster(location)
		searchRet := nm_imgSearch("e_button.png",30,"high")
		if (searchRet[1] = 0) {
			sendinput {%SC_E% down}
			Sleep, 100
			sendinput {%SC_E% up}
			Sleep, 1000
			success:=1
			break
		}
	}

	if (success = 1)
	{
		Last%location%Boost:=nowUnix()
		IniWrite, % Last%location%Boost, settings\nm_config.ini, Collect, Last%location%Boost
		nm_Move(2000*round(18/MoveSpeedNum, 2), (location = "blue") ? RightKey : BackKey)

		Loop, 10
		{
			for k,v in %location%BoosterFields
			{
				if nm_fieldBoostCheck(v, 1)
				{
					nm_setStatus("Boosted", v), RecentFBoost := v
					break 2
				}
			}
			Sleep, 200
		}
	}
	else
	{
		Last%location%Boost:=nowUnix()-3000
		IniWrite, % Last%location%Boost, settings\nm_config.ini, Collect, Last%location%Boost
	}
}
nm_toAnyBooster(){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveMethod
	global LastBlueBoost, QuestBlueBoost
	global LastRedBoost
	global LastMountainBoost, QuestRedBoost, QuestGatherField, LastWindShrine
	global FieldBooster1
	global FieldBooster2
	global FieldBooster3
	global FieldBoosterMins
	global VBState
	global objective, CurrentAction, PreviousAction
	global MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff
	static blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower"], redBoosterFields:=["Rose", "Strawberry", "Mushroom"], mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
	if(VBState=1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if (QuestGatherField!="None" && QuestGatherField)
		return
	MyFunc := "nm_WindShrine"
	%MyFunc%()
	loop 3 {
		if(FieldBooster%A_Index%="none" && QuestBlueBoost=0 && QuestRedBoost=0)
			break
		LastBooster:=max(LastBlueBoost, LastRedBoost, LastMountainBoost)
		;Blue Field Booster
		if((FieldBooster%A_Index%="blue" && (nowUnix()-LastBlueBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)) || (QuestBlueBoost && (nowUnix()-LastBlueBoost)>3600)){
			if(CurrentAction!="Booster"){
				PreviousAction:=CurrentAction
				CurrentAction:="Booster"
			}
			nm_toBooster("blue")
		}
		;Red Field Booster
		else if((FieldBooster%A_Index%="red" && (nowUnix()-LastRedBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)) || (QuestRedBoost && (nowUnix()-LastRedBoost)>3600)){
			if(CurrentAction!="Booster"){
				PreviousAction:=CurrentAction
				CurrentAction:="Booster"
			}
			nm_toBooster("red")
		}
		;Mountain Top Field Booster
		else if(FieldBooster%A_Index%="mountain"  && (nowUnix()-LastMountainBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)){ ;1 hour
			if(CurrentAction!="Booster"){
				PreviousAction:=CurrentAction
				CurrentAction:="Booster"
			}
			nm_toBooster("mountain")
		}
	}
}
nm_Collect(){
	global FwdKey, BackKey, LeftKey, RightKey, RotLeft, RotRight, KeyDelay, objective, CurrentAction, PreviousAction, MoveSpeedNum, GatherFieldBoostedStart, LastGlitter, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, VBState, ClockCheck, LastClock, AntPassCheck, AntPassAction, QuestAnt, LastAntPass, HoneyDisCheck, LastHoneyDis, TreatDisCheck, LastTreatDis, BlueberryDisCheck, LastBlueberryDis, StrawberryDisCheck, LastStrawberryDis, CoconutDisCheck, LastCoconutDis, GlueDisCheck, LastGlueDis, RoboPassCheck, LastRoboPass, HoneystormCheck, LastHoneystorm, RoyalJellyDisCheck, LastRoyalJellyDis, StockingsCheck, LastStockings, FeastCheck, RBPDelevelCheck, LastRBPDelevel, LastFeast, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon, HoneySSCheck, resetTime, bitmaps, SC_E, SC_Space, SC_1
	static AntPassNum:=2, RoboPassNum:=1, LastHoneyLB:=1

	if(VBState=1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
		return

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())

	if(CurrentAction!="Collect") {
		PreviousAction:=CurrentAction
		CurrentAction:="Collect"
	}

	;clock
	if (ClockCheck && (nowUnix()-LastClock)>3600) { ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Wealth Clock" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("clock")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500
				nm_setStatus("Collected", "Wealth Clock")
				break
			}
		}
		LastClock:=nowUnix()
		IniWrite, %LastClock%, settings\nm_config.ini, Collect, LastClock
		if (StockingsCheck && (nowUnix()-LastStockings)>3580) { ;stockings from clock
			Sleep, 500
			nm_setStatus("Traveling", "Stockings (Clock)")

			movement := "
			(LTrim Join`r`n
			Send {" FwdKey " down}
			Walk(6.5)
			Send {" SC_Space " down}
			Sleep 100
			Send {" SC_Space " up}
			Walk(6.5)
			Send {" FwdKey " up}
			" nm_Walk(24.5, RightKey) "
			" nm_Walk(3, FwdKey) "
			)"
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T60 L
			nm_endWalk()

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500

				movement := "
				(LTrim Join`r`n
				" nm_Walk(8, FwdKey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(3, RightKey) "
				Send {" SC_Space " down}
				HyperSleep(500)
				Send {" SC_Space " up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, RightKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(9, LeftKey) "
				Send {" SC_Space " down}
				HyperSleep(500)
				Send {" SC_Space " up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, LeftKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(6, RightKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Stockings")

				LastStockings:=nowUnix()
				IniWrite, %LastStockings%, settings\nm_config.ini, Collect, LastStockings
			}
		}
	}
	;ant pass
	if(((AntPassCheck && ((AntPassNum<10) || (AntPassAction="challenge"))) && (nowUnix()-LastAntPass>7200)) || (QuestAnt && (AntPassNum>0))){ ;2 hours OR ant quest
		Loop, 2 {
			nm_Reset(1, (QuestAnt || (AntPassAction = "challenge")) ? 20000 : 2000)
			nm_setStatus("Traveling", (QuestAnt ? "Ant Challenge" : ("Ant " . AntPassAction)) ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("antpass")

			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}

				LastAntPass:=nowUnix()
				IniWrite, %LastAntPass%, settings\nm_config.ini, Collect, LastAntPass

				Sleep, 500
				nm_setStatus("Collected", "Ant Pass")
				++AntPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(AntPassNum < 10) ? nm_setStatus("Confirmed", "10/10 Ant Passes")
					AntPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					LastAntPass:=nowUnix()
					IniWrite, %LastAntPass%, settings\nm_config.ini, Collect, LastAntPass
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}

		;do ant challenge
		if(QuestAnt || AntPassAction="challenge"){
			QuestAnt:=0
			movement := "
			(LTrim Join`r`n
			" nm_Walk(13, FwdKey, RightKey) "
			" nm_Walk(5, FwdKey) "
			)"
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T30 L
			nm_endWalk()
			Sleep, 500
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				--AntPassNum
				nm_setStatus("Attacking", "Ant Challenge")
				Sleep, 500
				send {%SC_1%}
				MoveSpeedFactor := round(18/MoveSpeedNum, 2)
				nm_Move(2000*MoveSpeedFactor, BackKey)
				nm_Move(500*MoveSpeedFactor, RightKey)
				nm_Move(100*MoveSpeedFactor, FwdKey)
				loop 300 {
					if (Mod(A_Index, 10) = 1) {
						resetTime:=nowUnix()
						Prev_DetectHiddenWindows := A_DetectHiddenWindows
						Prev_TitleMatchMode := A_TitleMatchMode
						DetectHiddenWindows On
						SetTitleMatchMode 2
						if WinExist("background.ahk ahk_class AutoHotkey") {
							PostMessage, 0x5554, 1, resetTime
						}
						DetectHiddenWindows %Prev_DetectHiddenWindows%
						SetTitleMatchMode %Prev_TitleMatchMode%
					}
					searchRet := nm_imgSearch("keep.png",30,"center")
					searchRet2 := nm_imgSearch("d_ant_amulet.png",30,"center")
					searchRet3 := nm_imgSearch("g_ant_amulet.png",30,"center")
					If (searchRet[1]=0 && (searchRet2[1]=0 || searchRet3[1]=0)) {
						nm_setStatus("Keeping", "Ant Amulet")
						WinGetClientPos(windowX, windowY, , , "ahk_id " GetRobloxHWND())
						MouseMove, windowX+searchRet[2], windowY+searchRet[3], 5
						click
						MouseMove, windowX+350, windowY+100
						break
					}
					sleep, 1000
					click
				}
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passnone"], , , , , , 2, , 2) = 1) {
					nm_setStatus("Aborting", "No Ant Pass in Inventory")
					AntPassNum:=0
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
	}
	;robo pass
	if (RoboPassCheck && (RoboPassNum < 10) && (nowUnix()-LastRoboPass)>79200) { ;22 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Robo Pass" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("robopass")

			if (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}

				LastRoboPass:=nowUnix()
				IniWrite, %LastRoboPass%, settings\nm_config.ini, Collect, LastRoboPass

				Sleep, 500
				nm_setStatus("Collected", "Robo Pass")
				++RoboPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(RoboPassNum < 10) ? nm_setStatus("Confirmed", "10/10 Robo Passes")
					RoboPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					LastRoboPass:=nowUnix()
					IniWrite, %LastRoboPass%, settings\nm_config.ini, Collect, LastRoboPass
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
	}

	;DISPENSERS
	;Honey
	if (HoneyDisCheck && (nowUnix()-LastHoneyDis)>3600) { ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Honey Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("honeydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep, 500
				nm_setStatus("Collected", "Honey Dispenser")
				break
			}
		}
		LastHoneyDis:=nowUnix()
		IniWrite, %LastHoneyDis%, settings\nm_config.ini, Collect, LastHoneyDis
	}
	;Treat
	if (TreatDisCheck && (nowUnix()-LastTreatDis)>3600) { ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Treat Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("treatdis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep, 500
				nm_setStatus("Collected", "Treat Dispenser")
				break
			}
		}
		LastTreatDis:=nowUnix()
		IniWrite, %LastTreatDis%, settings\nm_config.ini, Collect, LastTreatDis
	}
	;Blueberry
	if (BlueberryDisCheck && (nowUnix()-LastBlueberryDis)>14400) { ;4 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Blueberry Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("blueberrydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep 500
				nm_setStatus("Collected", "Blueberry Dispenser")
				break
			}
		}
		LastBlueberryDis:=nowUnix()
		IniWrite, %LastBlueberryDis%, settings\nm_config.ini, Collect, LastBlueberryDis
	}
	;Strawberry
	if (StrawberryDisCheck && (nowUnix()-LastStrawberryDis)>14400) { ;4 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Strawberry Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("strawberrydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep 500
				nm_setStatus("Collected", "Strawberry Dispenser")
				break
			}
		}
		LastStrawberryDis:=nowUnix()
		IniWrite, %LastStrawberryDis%, settings\nm_config.ini, Collect, LastStrawberryDis
	}
	;Coconut
	if (CoconutDisCheck && (nowUnix()-LastCoconutDis)>14400) { ;4 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Coconut Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("coconutdis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep 500
				nm_setStatus("Collected", "Coconut Dispenser")
				break
			}
		}
		LastCoconutDis:=nowUnix()
		IniWrite, %LastCoconutDis%, settings\nm_config.ini, Collect, LastCoconutDis
	}
	;Glue
	if (GlueDisCheck && (nowUnix()-LastGlueDis)>(79200)) { ;22 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Glue Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_OpenMenu("itemmenu")
			nm_gotoCollect("gluedis", 0) ; do not wait for end

			;locate gumdrops
			if ((gumdropPos := nm_InventorySearch("gumdrops")) = 0) { ;~ new function
				nm_OpenMenu()
				continue
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+gumdropPos[1], windowY+gumdropPos[2]
			KeyWait, F14, T120 L
			nm_endWalk()

			MouseClickDrag, Left, windowX+gumdropPos[1], windowY+gumdropPos[2], windowX+(windowWidth/2), windowY+(windowHeight/2), 5
			;close inventory
			nm_OpenMenu()
			Sleep, 500
			;inside gummy lair
			movement := nm_Walk(6, FwdKey)
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T20 L
			nm_endWalk()
			Sleep, 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 1000
				nm_setStatus("Collected", "Glue Dispenser")
				break
			}
		}
		LastGlueDis:=nowUnix()
		IniWrite, %LastGlueDis%, settings\nm_config.ini, Collect, LastGlueDis
	}
	;Royal Jelly
	if (RoyalJellyDisCheck && (nowUnix()-LastRoyalJellyDis)>(79200) && (MoveMethod != "Walk")) { ;22 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Royal Jelly Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("royaljellydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500
				nm_setStatus("Collected", "Royal Jelly Dispenser")
				sleep 10000
				break
			}
		}
		LastRoyalJellyDis:=nowUnix()
		IniWrite, %LastRoyalJellyDis%, settings\nm_config.ini, Collect, LastRoyalJellyDis
	}
	;BEESMAS
	;Stockings
	if (StockingsCheck && (nowUnix()-LastStockings)>3600) { ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Stockings" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("stockings")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500

				movement := "
				(LTrim Join`r`n
				" nm_Walk(8, FwdKey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(3, RightKey) "
				Send {" SC_Space " down}
				HyperSleep(500)
				Send {" SC_Space " up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, RightKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(9, LeftKey) "
				Send {" SC_Space " down}
				HyperSleep(500)
				Send {" SC_Space " up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, LeftKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(6, RightKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Stockings")
				break
			}
		}
		LastStockings:=nowUnix()
		IniWrite, %LastStockings%, settings\nm_config.ini, Collect, LastStockings
	}
	;Beesmas Feast
	if (FeastCheck && (nowUnix()-LastFeast)>5400) { ;1.5 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Beesmas Feast" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("feast")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 3000
				sendinput {%RotLeft%}

				movement := "
				(LTrim Join`r`n
				" nm_Walk(3, FwdKey, RightKey) "
				" nm_Walk(1, RightKey) "
				Loop, 2 {
					" nm_Walk(5, BackKey) "
					" nm_Walk(1.5, LeftKey) "
					" nm_Walk(5, FwdKey) "
					" nm_Walk(1.5, LeftKey) "
				}
				" nm_Walk(5, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Beesmas Feast")
				break
			}
		}
		LastFeast:=nowUnix()
		IniWrite, %LastFeast%, settings\nm_config.ini, Collect, LastFeast
	}
	;Gingerbread House
	if (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) { ;2 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Gingerbread House" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("gingerbread")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 3000
				nm_setStatus("Collected", "Gingerbread House")
				break
			}
		}
		LastGingerbread:=nowUnix()
		IniWrite, %LastGingerbread%, settings\nm_config.ini, Collect, LastGingerbread
	}
	;Snow Machine
	if (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) { ;2 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Snow Machine" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("snowmachine")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				nm_setStatus("Collected", "Snow Machine")

				movement := "
				(LTrim Join`r`n
				" nm_Walk(18, LeftKey) "
				" nm_Walk(7, RightKey) "
				" nm_Walk(11, FwdKey) "
				" nm_Walk(2, LeftKey) "
				Sleep, 1000
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T30 L
				nm_endWalk()

				if (HoneystormCheck && (nm_imgSearch("e_button.png",30,"high")[1] = 0)) {
					sendinput {%SC_E% down}
					Sleep, 100
					sendinput {%SC_E% up}
					nm_setStatus("Collected", "Honeystorm")
					LastHoneystorm:=nowUnix()
					IniWrite, %LastHoneystorm%, settings\nm_config.ini, Collect, LastHoneystorm
				}

				movement := "
				(LTrim Join`r`n
				" nm_Walk(11, FwdKey) "
				loop 2 {
					loop 3 {
					" nm_Walk(20, LeftKey) "
					" nm_Walk(3, FwdKey) "
					" nm_Walk(20, RightKey) "
					" nm_Walk(3, FwdKey) "
					}
					" nm_Walk(1.5, FwdKey) "
					loop 3 {
					" nm_Walk(20, LeftKey) "
					" nm_Walk(3, BackKey) "
					" nm_Walk(20, RightKey) "
					" nm_Walk(3, BackKey) "
					}
				}
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T35 L
				nm_endWalk()

				break
			}
		}
		LastSnowMachine:=nowUnix()
		IniWrite, %LastSnowMachine%, settings\nm_config.ini, Collect, LastSnowMachine
	}
	;Candles
	if (CandlesCheck && (nowUnix()-LastCandles)>14400) { ;4 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Candles" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("candles")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 4000

				movement := "
				(LTrim Join`r`n
				" nm_Walk(4, FwdKey) "
				" nm_Walk(6, RightKey) "
				" nm_Walk(10, LeftKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Candles")
				break
			}
		}
		LastCandles:=nowUnix()
		IniWrite, %LastCandles%, settings\nm_config.ini, Collect, LastCandles
	}
	;Samovar
	if (SamovarCheck && (nowUnix()-LastSamovar)>21600) { ;6 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Samovar" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("samovar")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 5000

				movement := "
				(LTrim Join`r`n
				" nm_Walk(4, FwdKey, RightKey) "
				" nm_Walk(1, RightKey) "
				Loop, 3 {
					" nm_Walk(6, BackKey) "
					" nm_Walk(1.25, LeftKey) "
					" nm_Walk(6, FwdKey) "
					" nm_Walk(1.25, LeftKey) "
				}
				" nm_Walk(6, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Samovar")
				break
			}
		}
		LastSamovar:=nowUnix()
		IniWrite, %LastSamovar%, settings\nm_config.ini, Collect, LastSamovar
	}
	;Lid Art
	if (LidArtCheck && (nowUnix()-LastLidArt)>28800) { ;8 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Lid Art" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("lidart")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 5000

				movement := "
				(LTrim Join`r`n
				" nm_Walk(3, FwdKey, RightKey) "
				Loop, 2 {
					" nm_Walk(4.5, BackKey) "
					" nm_Walk(1.25, LeftKey) "
					" nm_Walk(4.5, FwdKey) "
					" nm_Walk(1.25, LeftKey) "
				}
				" nm_Walk(4.5, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				nm_setStatus("Collected", "Lid Art")
				break
			}
		}
		LastLidArt:=nowUnix()
		IniWrite, %LastLidArt%, settings\nm_config.ini, Collect, LastLidArt
	}
	;Gummy Beacon
	if (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800 && (MoveMethod != "Walk")) { ;8 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Gummy Beacon" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("gummybeacon")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500
				nm_setStatus("Collected", "Gummy Beacon")
				break
			}
		}
		LastGummyBeacon:=nowUnix()
		IniWrite, %LastGummyBeacon%, settings\nm_config.ini, Collect, LastGummyBeacon
	}
	;Robo Bear Party De-level
	if (RBPDelevelCheck && (nowUnix()-LastRBPDelevel)>10800 && (MoveMethod != "Walk")) { ;3 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "RBP De-Level" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("rbpdelevel")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				Sleep, 500
				nm_setStatus("Collected", "RBP De-Level")
				break
			}
		}
		LastRBPDelevel:=nowUnix()
		IniWrite, %LastRBPDelevel%, settings\nm_config.ini, Collect, LastRBPDelevel
	}
	;OTHER
	;Honeystorm
	if (HoneystormCheck && (nowUnix()-LastHoneystorm)>14400) { ;4 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Honeystorm" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("honeystorm")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				nm_setStatus("Collected", "Honeystorm")

				movement := "
				(LTrim Join`r`n
				" nm_Walk(11, FwdKey) "
				loop 2 {
					loop 3 {
					" nm_Walk(20, LeftKey) "
					" nm_Walk(3, FwdKey) "
					" nm_Walk(20, RightKey) "
					" nm_Walk(3, FwdKey) "
					}
					" nm_Walk(1.5, FwdKey) "
					loop 3 {
					" nm_Walk(20, LeftKey) "
					" nm_Walk(3, BackKey) "
					" nm_Walk(20, RightKey) "
					" nm_Walk(3, BackKey) "
					}
				}
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T35 L
				nm_endWalk()

				break
			}
		}
		LastHoneystorm:=nowUnix()
		IniWrite, %LastHoneystorm%, settings\nm_config.ini, Collect, LastHoneystorm
	}
	;Daily Honey LB
	if (HoneySSCheck) {
		FormatTime, utc_hour, %A_NowUTC%, H
		if ((utc_hour = 4) && (nowUnix()-LastHoneyLB)>3600) {
			nm_Reset()
			nm_setStatus("Traveling", "Daily Honey LB")
			nm_gotoCollect("honeylb")
			VarSetCapacity(FormatStr, 256, 0), DllCall("GetLocaleInfoEx", "Ptr", 0, "UInt", 0x20, "WStr", FormatStr, "Int", 256)
			VarSetCapacity(DateStr, 512, 0), DllCall("GetDateFormatEx", "Ptr", 0, "UInt", 0, "Ptr", 0, "Str", FormatStr, "Str", DateStr, "Int", 512, "Ptr", 0)
			nm_setStatus("Reporting", "Daily Honey LB`nDate: " DateStr)
			LastHoneyLB:=nowUnix()
		}
	}
}
nm_gotoCollect(location, waitEnd := 1){
	global
	static paths := {}, SetMoveMethod, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\gtc-clock.ahk
		#Include %A_ScriptDir%\paths\gtc-antpass.ahk
		#Include %A_ScriptDir%\paths\gtc-robopass.ahk
		#Include %A_ScriptDir%\paths\gtc-honeydis.ahk
		#Include %A_ScriptDir%\paths\gtc-treatdis.ahk
		#Include %A_ScriptDir%\paths\gtc-blueberrydis.ahk
		#Include %A_ScriptDir%\paths\gtc-strawberrydis.ahk
		#Include %A_ScriptDir%\paths\gtc-coconutdis.ahk
		#Include %A_ScriptDir%\paths\gtc-gluedis.ahk
		#Include %A_ScriptDir%\paths\gtc-royaljellydis.ahk
		;beesmas
		#Include %A_ScriptDir%\paths\gtc-stockings.ahk
		#Include %A_ScriptDir%\paths\gtc-wreath.ahk
		#Include %A_ScriptDir%\paths\gtc-feast.ahk
		#Include %A_ScriptDir%\paths\gtc-gingerbread.ahk
		#Include %A_ScriptDir%\paths\gtc-snowmachine.ahk
		#Include %A_ScriptDir%\paths\gtc-candles.ahk
		#Include %A_ScriptDir%\paths\gtc-samovar.ahk
		#Include %A_ScriptDir%\paths\gtc-lidart.ahk
		#Include %A_ScriptDir%\paths\gtc-gummybeacon.ahk
		#Include %A_ScriptDir%\paths\gtc-rbpdelevel.ahk
		;other
		#Include %A_ScriptDir%\paths\gtc-honeystorm.ahk
		#Include %A_ScriptDir%\paths\gtc-honeylb.ahk
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	HiveConfirmed:=0

	InStr(paths[location], "gotoramp") ? nm_gotoRamp()
	InStr(paths[location], "gotocannon") ? nm_gotoCannon()

	nm_createWalk(paths[location])
	KeyWait, F14, D T5 L
	if waitEnd
	{
		KeyWait, F14, T120 L
		nm_endWalk()
	}
}
nm_Bugrun(){
	global youDied, VBState, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, RotUp, RotDown, ZoomIn, ZoomOut, SC_1, SC_E, SC_Space, KeyDelay, MoveMethod, MoveSpeedNum, currentWalk, objective, HiveBees, MonsterRespawnTime, DisableToolUse
	global QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
	global BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll
	global CurrentAction, PreviousAction
	global GatherFieldBoostedStart, LastGlitter
	global BeesmasGatherInterruptCheck, StockingsCheck, LastStockings, FeastCheck, LastFeast, RBPDelevelCheck, LastRBPDelevel, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon
	global MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff
	global BugrunSpiderCheck, BugrunSpiderLoot, LastBugrunSpider, BugrunLadybugsCheck, BugrunLadybugsLoot, LastBugrunLadybugs, BugrunRhinoBeetlesCheck, BugrunRhinoBeetlesLoot, LastBugrunRhinoBeetles, BugrunMantisCheck, BugrunMantisLoot, LastBugrunMantis, BugrunWerewolfCheck, BugrunWerewolfLoot, LastBugrunWerewolf, BugrunScorpionsCheck, BugrunScorpionsLoot, LastBugrunScorpions, intialHealthCheck
	global CocoCrabCheck, LastCocoCrab, StumpSnailCheck, LastStumpSnail, CommandoCheck, LastCommando, TunnelBearCheck, TunnelBearBabyCheck, KingBeetleCheck, KingBeetleBabyCheck, LastTunnelBear, LastKingBeetle, InputSnailHealth, SnailTime, InputChickHealth, ChickTime, SprinklerType
	global TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills
	global KingBeetleAmuletMode, ShellAmuletMode

	;interrupts
	if(VBState=1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck()){
		return
	}
	if ((BeesmasGatherInterruptCheck) && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (RBPDelevelCheck && (nowUnix()-LastRBPDelevel)>10800) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800)))
		return

	nm_setShiftLock(0)
	bypass:=0
	MoveSpeedFactor := round(18/MoveSpeedNum, 2)
	if(((BugrunSpiderCheck || QuestSpider || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) && HiveBees>=5){ ;30 minutes
		PreviousAction:=CurrentAction
		CurrentAction:="Bugrun"
		loop 1 {
			if(VBState=1)
				return
			;spider
			BugRunField:="Spider"
			success:=0
			while (not success){
				if(A_Index>=3)
					break
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "Spider")
				If (MoveMethod="walk")
					nm_walkTo(BugRunField)
				else {
					nm_cannonTo(BugRunField)
				}
				found:=0 
				loop, 20
				{
					spiderBug:=nm_HealthDetection()
					if(spiderBug.Length() > 0)
					{ 
						found:= 1
						break
					} 
					sleep, 150
				}
				if (found)
				{
					nm_setStatus("Attacking", "Spider")
					send {%SC_1%}
					sendinput {%RotUp% 4}
					if(!DisableToolUse)
						click, down
					loop, 30 
					{ ;wait to kill
						if(A_Index=30)
							success:=1
						loop, 20
						{
							spiderDead:=nm_HealthDetection()
							if(spiderDead.Length() > 0)
								Break
							if (A_Index=10)
							{
								sendinput {%RotLeft% 2}
								r := 1
							}
							sendinput {%ZoomOut%}
							Sleep, 100
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
						if(!DisableToolUse)
							click
					}
					sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					sleep, 500
					click, up
					if(VBState=1)
						return
				}
			}
			LastBugrunSpider:=nowUnix()
			IniWrite, %LastBugrunSpider%, settings\nm_config.ini, Collect, LastBugrunSpider
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
			if(BugrunSpiderLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting", "Spider")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(3, RightKey) "
				loop 3 {
					" nm_Walk(9, FwdKey) "
					" nm_Walk(1.5, LeftKey) "
					" nm_Walk(9, BackKey) "
					" nm_Walk(1.5, LeftKey) "
				}
				" nm_Walk(6, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()
				click, up
			}
			if(VBState=1)
				return
			;head to ladybugs?
			if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) {
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Strawberry)")
				movement := "
				(LTrim Join`r`n
				" ((BugrunSpiderLoot=0) ? (nm_Walk(4.5, BackKey) "`r`n" nm_Walk(4.5, LeftKey)) : "") "
				" nm_Walk(30, LeftKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()
				sendinput {%RotLeft% 2}
			} else {
				bypass:=0
			}
		}
	}
	;Ladybugs
	if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll)  && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				return
			if(HiveBees>=5) {
				;strawberry
				BugRunField:="strawberry"
				success:=0
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(5000, (50-HiveBees)*1000)
						nm_Reset(1,wait)
						nm_setStatus("Traveling", "Ladybugs (Strawberry)")
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else
							nm_cannonTo(BugRunField)
						Sleep, 1000
					}
					bypass:=0
					;(+) new detection
					found:=0 
					loop 20
					{
						strawBug:=nm_HealthDetection()
						if(strawBug.Length() > 0)
						{ 
							found:= 1
							break
						} 
						sleep, 150
					}
					if (found)
					{
						nm_setStatus("Attacking", "Ladybugs (Strawberry)")
						sendinput {%RotUp% 4}
						send {%SC_1%}
						if(!DisableToolUse)
							click, down
						loop 10 
						{ ;wait to kill
							if(A_Index=10)
								success:=1
							loop, 10
							{
								ladybugDead:=nm_HealthDetection()
								if(ladybugDead.Length() > 0)
									Break
								if (A_Index=5)
								{
									sendinput {%RotLeft% 2}
									r := 1
								}
								Sleep, 100
								sendinput {%ZoomOut%}
								if (A_Index=10)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
							if(!DisableToolUse)
								Click
						}
						sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						sleep, 500
						click, up
						if(VBState=1)
							return
					}
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 2
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
				if(BugrunLadybugsLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting", "Ladybugs (Strawberry)")
					movement := "
					(LTrim Join`r`n
					" nm_Walk(2, BackKey) "
					" nm_Walk(8, RightKey, BackKey) "
					loop 2 {
						" nm_Walk(14, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(14, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(14, FwdKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
					click, up
				}
				if(VBState=1)
					return
				;mushroom
				BugRunField:="mushroom"
				success:=0
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Mushroom)")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(12, LeftKey) "
				" nm_Walk(16, BackKey) "
				" nm_Walk(16, BackKey, LeftKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()
			} else { ;HiveBees<5
				success:=0
				bypass:=0
			}
			BugRunField:="mushroom"
			while (not success){
				if(A_Index>=3)
					break
				if(not bypass){
					wait:=min(5000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					nm_setStatus("Traveling", "Ladybugs (Mushroom)")
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_cannonTo(BugRunField)
					}
					sendinput {%RotLeft% 2}
				}
				bypass:=0
				found:=0 
				loop 20
				{
					mushBug:=nm_HealthDetection()
					if(mushBug.Length() > 0)
					{ 
						found:= 1
						break
					} 
					sleep, 150
				}
				if(found)
				{
					nm_setStatus("Attacking", "Ladybugs (Mushroom)")
					send {%SC_1%}
					sendinput {%RotUp% 4}
					if(!DisableToolUse)
						click, down
					loop 10 { ;wait to kill
						if(A_Index=10)
							success:=1
						loop, 20
						{
							ladybugDead:=nm_HealthDetection()
							if(ladybugDead.Length() > 0)
								Break
							if (A_Index=10)
							{
								sendinput {%RotLeft% 2}
								r := 1
							}
							Sleep, 100
							sendinput {%ZoomOut%}
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
						if(!DisableToolUse)
							click
					}
					sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					sleep, 500
					click, up
					if(VBState=1)
					{
						return
					}
				}
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
			if(BugrunLadybugsLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting", "Ladybugs (Mushroom)")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(5, RightKey, BackKey) "
				" nm_Walk(2, RightKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T20 L
				nm_endWalk()
				nm_loot(9, 4, "left", 1)
				click, up
			}
		}
	}
	if(VBState=1)
		return
	nm_Mondo()
	;Ladybugs and/or Rhino Beetles
	if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				return
			;clover
			success:=0
			bypass:=0
			BugRunField:="clover"
			while (not success){
				if(A_Index>=3)
					break
				if(not bypass){
					wait:=min(10000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && not (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles)){
						nm_setStatus("Traveling", "Ladybugs (Clover)")
					}
					else if(not (BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						nm_setStatus("Traveling", "Rhino Beetles (Clover)")
					}
					else if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						nm_setStatus("Traveling", "Ladybugs / Rhino Beetles (Clover)")
					}
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				found:=0 
				loop 20
				{
					cloverBug:=nm_HealthDetection()
					if(cloverBug.Length() > 0)
					{ 
						found:= 1
						break
					} 
					sleep, 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					send {%SC_1%}
					sendinput {%RotUp% 4}
					if(!DisableToolUse)
						click, down
					loop 10 { ;wait to kill
						if(A_Index=10)
							success:=1
						loop, 10
						{
							cloverDead:=nm_HealthDetection()
							if(cloverDead.Length() > 0)
								Break
							else if (A_Index=10)
							{
								success:=1
								break 2
							}
							Sleep, 250
						}
						if(youDied)
							break
						if(!DisableToolUse)
						{
							Click
						}
					}
					sendinput {%RotDown% 4}
					click up
					if(VBState=1)
						return
				}
				
			}
			;done with ladybugs
			LastBugrunLadybugs:=nowUnix()
			IniWrite, %LastBugrunLadybugs%, settings\nm_config.ini, Collect, LastBugrunLadybugs
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 2
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
			;loot
			if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && BugrunLadybugsLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && BugrunRhinoBeetlesLoot)){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(4, RightKey) "
				" nm_Walk(8, FwdKey) "
				" nm_Walk(1.5, LeftKey) "
				" nm_Walk(8, BackKey) "
				" nm_Walk(1.5, LeftKey) "
				" nm_Walk(8, FwdKey) "
				" nm_Walk(1.5, LeftKey) "
				" nm_Walk(16, BackKey) "
				loop 2 {
					" nm_Walk(1.5, LeftKey) "
					" nm_Walk(8, FwdKey) "
					" nm_Walk(1.5, LeftKey) "
					" nm_Walk(8, BackKey) "
				}
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()
				click, up
			}
		}
	}
	if(VBState=1)
		Return
	;Rhino Beetles
	if((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				return
			;blue flower
			success:=0
			if (BugRunField="clover") {
				Sleep, 5000
				BugRunField:="blue flower"
				nm_setStatus("Traveling", "Rhino Beetles (Blue Flower)")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(18, BackKey) "
				send {" RotLeft " 2}
				" nm_Walk(10, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T30 L
				nm_endWalk()
			}
			else {
				BugRunField:="blue flower"
				wait:=min(5000, (50-HiveBees)*1000)
				nm_Reset(1,wait)
				nm_setStatus("Traveling", "Rhino Beetles (Blue Flower)")
				If (MoveMethod="walk")
					nm_walkTo(BugRunField)
				else {
					nm_cannonTo(BugRunField)
				}
			}
			while (not success){
				if(A_Index>=3)
					break
				found:=0 
				loop 20
				{
					blufBug:=nm_HealthDetection()
					if(blufBug.Length() > 0)
					{ 
						found:= 1
						break
					} 
					sleep, 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					send {%SC_1%}
					sendinput {%RotUp% 4}
					if(!DisableToolUse)
						click, down
					loop 12 { ;wait to kill
						if(A_Index=12)
							success:=1
						loop, 20
						{
							blufDead:=nm_HealthDetection()
							if(blufDead.Length() > 0)
								Break
							if (A_Index=10)
							{
								sendinput {%RotLeft% 2}
								r := 1
							}
							Sleep, 100
							sendinput {%ZoomOut%}
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
						if(!DisableToolUse)
							Click
					}
					sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					sleep, 500
					click, up
					if(VBState=1)
						return
				}
			}
			;done with Rhino Beetles if Hive has less than 5 bees
			if(HiveBees<5){
				LastBugrunRhinoBeetles:=nowUnix()
				IniWrite, %LastBugrunRhinoBeetles%, settings\nm_config.ini, Collect, LastBugrunRhinoBeetles
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
			;loot
			if(BugrunRhinoBeetlesLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(2, BackKey) "
				" nm_Walk(5, RightKey, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T30 L
				nm_endWalk()
				nm_loot(8, 3, "left", 1)
				click, up
			}
			if(HiveBees>=5) {
				;bamboo
				BugRunField:="bamboo"
				success:=0
				bypass:=0
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(10000, (50-HiveBees)*1000)
						nm_Reset(1, wait)
						nm_setStatus("Traveling", "Rhino Beetles (Bamboo)")
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					found:=0 
					loop 20
					{
						bambBug:=nm_HealthDetection()
						if(bambBug.Length() > 0)
						{ 
							found:= 1
							break
						} 
						sleep, 150
					}
					if (found)
					{
						nm_setStatus("Attacking")
						send {%SC_1%}
						sendinput {%RotUp% 4}
						if(!DisableToolUse)
							click, down
						loop 15 { ;wait to kill
							if(A_Index=15)
								success:=1
							loop, 20
							{
								bambDead:=nm_HealthDetection()
								if(bambDead.Length() > 0)
									Break
								if (A_Index=10)
								{
									sendinput {%RotLeft% 2}
									r := 1
								}
								Sleep, 100
								sendinput {%ZoomOut%}
								if (A_Index=20)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
							if(!DisableToolUse)
								Click
						}
						sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						sleep, 500
						click, up
						if(VBState=1)
							return
					}
				}	
				;done with Rhino Beetles if Hive has less than 10 bees
				if(HiveBees<10){
					LastBugrunRhinoBeetles:=nowUnix()
					IniWrite, %LastBugrunRhinoBeetles%, settings\nm_config.ini, Collect, LastBugrunRhinoBeetles
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 2
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunRhinoBeetlesLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					movement := "
					(LTrim Join`r`n
					" nm_Walk(9, BackKey) "
					" nm_Walk(1.5, RightKey) "
					loop 2 {
						" nm_Walk(18, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(18, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(18, FwdKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
					click, up
				}
			}
		}
	}
	if(VBState=1)
		Return
	;Rhino Beetles and/or Mantis
	if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll)  && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){ ;5 min Rhino 20min Mantis
		if(HiveBees>=10) {
			;pineapple
			BugRunField:="pineapple"
			if((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && MoveMethod="walk") {
				success:=0
				bypass:=1
				;walk from bamboo to pineapple
				if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && not (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles)){
					nm_setStatus("Traveling", "Mantis (Pineapple)")
				}
				else if(not (BugrunMantisCheck || QuestMantis || BuckoMantis) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
					nm_setStatus("Traveling", "Rhino Beetles (Pineapple)")
				}
				else if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
					nm_setStatus("Traveling", "Rhino Beetles / Mantis (Pineapple)")
				}
				if(BugrunRhinoBeetlesLoot){
					nm_Move(1000*MoveSpeedFactor, FwdKey, RightKey)
					nm_Move(8500*MoveSpeedFactor, FwdKey)
					nm_Move(2500*MoveSpeedFactor, LeftKey)
					nm_Move(5500*MoveSpeedFactor, RightKey)
				} else {
					nm_Move(8000*MoveSpeedFactor, FwdKey)
					nm_Move(4000*MoveSpeedFactor, RightKey)
				}
				PrevKeyDelay := A_KeyDelay
				SetKeyDelay, 5
				send, {%FwdKey% down}
				DllCall("Sleep",UInt,200)
				send, {%SC_Space% down}
				DllCall("Sleep",UInt,100)
				send, {%SC_Space% up}
				DllCall("Sleep",UInt,800)
				send, {%FwdKey% up}
				sendinput {%RotLeft% 2}
				SetKeyDelay, PrevKeyDelay
				nm_Move(14000*MoveSpeedFactor, FwdKey)
			} else {
				success:=0
				bypass:=0
			}
			;start pineapple
			while (not success){
				if(A_Index>=3)
					break
				if(not bypass){
					wait:=min(20000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && not (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles)){
						nm_setStatus("Traveling", "Mantis (Pineapple)")
					}
					else if(not (BugrunMantisCheck || QuestMantis || BuckoMantis) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						nm_setStatus("Traveling", "Rhino Beetles (Pineapple)")
					}
					else if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						nm_setStatus("Traveling", "Rhino Beetles / Mantis (Pineapple)")
					}
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				found:=0 
				loop 20
				{
					pineappleBug:=nm_HealthDetection()
					if(pineappleBug.Length() > 0)
					{ 
						found:= 1
						break
					} 
					sleep, 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					send {%SC_1%}
					sendinput {%RotUp% 4}
					if(!DisableToolUse)
						click, down
					;disableDayOrNight:=1
					loop 20 { ;wait to kill
						if(A_Index=20)
							success:=1
						loop, 20
						{
							pineappleDead:=nm_HealthDetection()
							if(pineappleDead.Length() > 0)
								Break
							if (A_Index=10)
							{
								sendinput {%RotLeft% 2}
								r := 1
							}
							Sleep, 100
							sendinput {%ZoomOut%}
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						sleep, 250
					}
					sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					sleep, 500
					click, up
					;disableDayOrNight:=0
					if(VBState=1)
						return
				}
			}
			;done with Rhino Beetles
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, settings\nm_config.ini, Collect, LastBugrunRhinoBeetles
			;done with Mantis if Hive is smaller than 15 bees
			if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && HiveBees<15){
				LastBugrunMantis:=nowUnix()
				IniWrite, %LastBugrunMantis%, settings\nm_config.ini, Collect, LastBugrunMantis
			}
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 2
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
			;loot
			if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && BugrunMantisLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles) && BugrunRhinoBeetlesLoot || RileyAll)){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(13.5, 5, "left")
				click, up
			}
		}
	}
	if(VBState=1)
		Return
	if(HiveBees>=15) {
		nm_Mondo()
		;werewolf
		if((BugrunWerewolfCheck || QuestWerewolf || RileyAll)  && (nowUnix()-LastBugrunWerewolf)>floor(3630*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;60 minutes
			loop 1 {
				if(VBState=1)
					return
				;pumpkin
				BugRunField:="pumpkin"
				success:=0
				bypass:=0
				while (not success){
					if(A_Index>=3)
						break
					wait:=min(20000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					nm_setStatus("Traveling", "Werewolf (Pumpkin)")
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_cannonTo(BugRunField)
					}
					found:=0 
					loop 20
					{
						wereBug:=nm_HealthDetection()
						if(wereBug.Length() > 0)
						{ 
							found:= 1
							break
						} 
						sleep, 150
					}
					if (found)
					{
						nm_setStatus("Attacking", "Werewolf (Pumpkin)")
						send {%SC_1%}
						sendinput {%RotUp% 4}
						if(!DisableToolUse)
							click, down
						loop 25 { ;wait to kill
							i:=A_Index
							if(mod(A_Index,4)=1){
								nm_Move(1500*MoveSpeedFactor, FwdKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length() > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									sendinput {%ZoomOut%}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=2){
								nm_Move(1500*MoveSpeedFactor, LeftKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length() > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									sendinput {%ZoomOut%}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=3){
								nm_Move(1500*MoveSpeedFactor, BackKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length() > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									sendinput {%ZoomOut%}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=0){
								nm_Move(1500*MoveSpeedFactor, RightKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length() > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									sendinput {%ZoomOut%}
									Sleep, 250
								}
							}
							if(A_Index=25)
								success:=1
							if(youDied)
								break
							if(!DisableToolUse)
								Click
						}
						sendinput {%RotDown% 4}
						sleep, 500
						click, up
						if(VBState=1)
							return
					}
				}
				LastBugrunWerewolf:=nowUnix()
				IniWrite, %LastBugrunWerewolf%, settings\nm_config.ini, Collect, LastBugrunWerewolf
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
				if(BugrunWerewolfLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting", "Werewolf (Pumpkin)")
					movement := "
					(LTrim Join`r`n
					" (((Mod(i, 4) = 1) || (Mod(i, 4) = 2)) ? nm_Walk(4.5, BackKey) : nm_Walk(4.5, FwdKey)) "
					" (((Mod(i, 4) = 0) || (Mod(i, 4) = 1)) ? nm_Walk(4.5, LeftKey) : nm_Walk(4.5, RightKey)) "
					" nm_Walk(4, BackKey) "
					" nm_Walk(6, BackKey, LeftKey) "
					loop 4 {
						" nm_Walk(14, FwdKey) "
						" nm_Walk(1.5, RightKey) "
						" nm_Walk(14, BackKey) "
						" nm_Walk(1.5, RightKey) "
					}
					" nm_Walk(14, FwdKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
					click, up
				}
			}
		}
		if(VBState=1)
			Return
		;mantis
		if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;20 minutes
			loop 1 {
				if(VBState=1)
					return
				;pine tree
				BugRunField:="pine tree"
				;walk to pine tree from pumpkin if just killed werewolf
				if((BugrunWerewolfCheck || QuestWerewolf || RileyAll) && (nowUnix()-LastBugrunWerewolf)>floor(3630*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){
					success:=0
					bypass:=1
					nm_setStatus("Traveling", "Mantis (Pine Tree)")
					nm_Move(1500*MoveSpeedFactor, FwdKey, LeftKey)
					nm_Move(6000*MoveSpeedFactor, LeftKey)
				} else {
					success:=0
					bypass:=0
				}
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(20000, (60-HiveBees)*1000)
						nm_Reset(1, wait)
						nm_setStatus("Traveling", "Mantis (Pine Tree)")
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					found:=0 
					loop 20
					{
						pineBug:=nm_HealthDetection()
						if(pineBug.Length() > 0)
						{ 
							found:= 1
							break
						} 
						sleep, 200
					}
					if (found)
					{
						nm_setStatus("Attacking")
						send {%SC_1%}
						sendinput {%RotUp% 4}
						if(!DisableToolUse)
							click, down
						loop 20 { ;wait to kill
							if(A_Index=20)
								success:=1
							loop, 10
							{
								pineDead:=nm_HealthDetection()
								if(pineDead.Length() > 0)
									Break
								if (A_Index=5)
								{
									sendinput {%RotLeft% 2}
									r := 1
								}
								Sleep, 100
								sendinput {%ZoomOut%}
								if (A_Index=10)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
							if(!DisableToolUse)
								Click
						}
						sendinput % "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						sleep, 500
						click, up
						if(VBState=1)
							return
					}
				}
				;done with Mantis
				LastBugrunMantis:=nowUnix()
				IniWrite, %LastBugrunMantis%, settings\nm_config.ini, Collect, LastBugrunMantis
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 2
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunMantisLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					movement := "
					(LTrim Join`r`n
					" nm_Walk(10, BackKey) "
					" nm_Walk(1.5, LeftKey) "
					loop 3 {
						" nm_Walk(10, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(10, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(20, FwdKey) "
					" nm_Walk(1.5, RightKey) "
					" nm_Walk(10, BackKey) "
					loop 3 {
						" nm_Walk(1.5, RightKey) "
						" nm_Walk(10, FwdKey) "
						" nm_Walk(1.5, RightKey) "
						" nm_Walk(10, BackKey) "
					}
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T90 L
					nm_endWalk()
					click, up
				}
			}
		}
		if(VBState=1)
			return
		;scorpions
		if((BugrunScorpionsCheck || QuestScorpions || RileyScorpions || RileyAll)  && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;20 minutes
			loop 1 {
				if(VBState=1)
					return
				;rose
				BugRunField:="rose"
				;walk to rose from pine tree if just killed mantis
				if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)) && MoveMethod="walk"){
					success:=0
					bypass:=1
					nm_setStatus("Traveling", "Scorpions (Rose)")
					loop 4 {
						send {%RotLeft%}
					}
					nm_Move(4000*MoveSpeedFactor, RightKey)
					nm_Move(2000*MoveSpeedFactor, LeftKey)
					nm_Move(17500*MoveSpeedFactor, FwdKey)
					loop 2 {
						send, {%RotRight%}
					}
				} else {
					success:=0
					bypass:=0
				}
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(20000, (60-HiveBees)*1000)
						nm_Reset(1, wait)
						nm_setStatus("Traveling", "Scorpions (Rose)")
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_cannonTo(BugRunField)
							nm_Move(1000*MoveSpeedFactor, BackKey)
							nm_Move(1500*MoveSpeedFactor, RightKey)
						}
					}
					bypass:=0
					found:=0 
					loop 20
					{
						roseBug:=nm_HealthDetection()
						if(roseBug.Length() > 0)
						{ 
							found:= 1
							break
						} 
						sleep, 150
					}
					if (found)
					{
						nm_setStatus("Attacking")
						sendinput {%RotUp% 4}
						send {%SC_1%}
						if(!DisableToolUse)
							click, down
						loop 17 { ;wait to kill
							i:=A_Index
							if(mod(A_Index,4)=1){
								nm_Move(1500*MoveSpeedFactor, FwdKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length() > 0)
									{
										Break
									}
									sendinput {%ZoomOut%}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=2){
								nm_Move(1500*MoveSpeedFactor, LeftKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length() > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=3){
								nm_Move(1500*MoveSpeedFactor, BackKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length() > 0)
									{
										Break
									}
									sendinput {%ZoomOut%}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep, 250
								}
							} else if(mod(A_Index,4)=0){
								nm_Move(1500*MoveSpeedFactor, RightKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length() > 0)
									{
										Break
									}
									sendinput {%ZoomOut%}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep, 250
								}
							}
							if(A_Index=17)
								success:=1
							if(youDied)
								break
							if(!DisableToolUse)
								Click
						}
						sendinput {%RotDown% 4}
						sleep, 500
						click, up
						if(VBState=1)
							return
					}
				}
				;done with Scorpions
				LastBugrunScorpions:=nowUnix()
				IniWrite, %LastBugrunScorpions%, settings\nm_config.ini, Collect, LastBugrunScorpions
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 2
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunScorpionsLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					movement := "
					(LTrim Join`r`n
					" (((Mod(i, 4) = 1) || (Mod(i, 4) = 2)) ? nm_Walk(4.5, BackKey) : nm_Walk(4.5, FwdKey)) "
					" (((Mod(i, 4) = 0) || (Mod(i, 4) = 1)) ? nm_Walk(4.5, LeftKey) : nm_Walk(4.5, RightKey)) "
					" nm_Walk(2, BackKey) "
					" nm_Walk(8, BackKey, RightKey) "
					loop 4 {
						" nm_Walk(16, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(16, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(16, FwdKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T90 L
					nm_endWalk()
					click, up
				} else {
					sleep 4000
				}
			}
		}
		if(VBState=1)
			return
		;tunnel bear
		if((TunnelBearCheck)  && (nowUnix()-LastTunnelBear)>floor(172800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;48 hours
			loop 2 {
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "Tunnel Bear")
				nm_gotoRamp()
				If (MoveMethod="walk") {
					break
				} else {
					nm_gotoCannon()
					PrevKeyDelay := A_KeyDelay
					SetKeyDelay, 5
					sendinput {%SC_E% down}
					Sleep, 100
					sendinput {%SC_E% up}
					DllCall("Sleep",UInt,50)
					send {%LeftKey% down}
					DllCall("Sleep",UInt,1050)
					send {%SC_Space%}
					send {%SC_Space%}
					DllCall("Sleep",UInt,4500)
					send {%LeftKey% up}
					send {%SC_Space%}
					DllCall("Sleep",UInt,1000)
					nm_Move(1500*MoveSpeedFactor, RightKey, BackKey)
					loop 4 {
						send {%RotLeft%}
					}
					nm_Move(2500*MoveSpeedFactor, FwdKey)
					DllCall("Sleep",UInt,2000)
					SetKeyDelay, PrevKeyDelay
				}
				;confirm tunnel
				if ((nm_imgSearch("tunnel.png",25,"high")[1] = 1) && (nm_imgSearch("tunnel2.png",25,"high")[1] = 1)){
					continue
				}
				loop 2 {
					send {%RotLeft%}
				}
				;wait for baby love
				DllCall("Sleep",UInt,2000)
				if (TunnelBearBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					DllCall("Sleep",UInt,1500)
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						DllCall("Sleep",UInt,1000)
					}
				}
				;search for tunnel bear
				nm_setStatus("Searching", "Tunnel Bear")
				nm_Move(6000*MoveSpeedFactor, BackKey)
				nm_Move(550*MoveSpeedFactor, LeftKey)
				found:=0
				 ;(+) new detection here
				loop 20
				{
					tBear:= nm_HealthDetection()
					if(tBear.Length() > 0)
					{
						found:=1
						break
					}
					DllCall("Sleep",UInt,250) 
				}
				;attack tunnel bear
				TBdead:=0
				if(found) {
					sendinput {%RotUp% 3}
					nm_setStatus("Attacking", "Tunnel Bear")
					loop 120 {
						loop 15 {
							if (nm_imgSearch("tunnelbear.png",5,"high")[1] = 0)
								nm_Move(200*MoveSpeedFactor, BackKey)
							else
								break
						}
						if(nm_imgSearch("tunnelbeardead.png",25,"lowright")[1] = 0){
							TBdead:=1
							sendinput {%RotDown% 3}
							break
						}
						if(youDied)
							break
						sleep, 1000
					}
				} else { ;No TunnelBear here...try again in 2 hours
					LastTunnelBear:=nowUnix()-floor(172800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
					IniWrite %LastTunnelBear%, settings\nm_config.ini, Collect, LastTunnelBear
				}
				;loot
				if(TBdead) {
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					Prev_DetectHiddenWindows := A_DetectHiddenWindows
					Prev_TitleMatchMode := A_TitleMatchMode
					DetectHiddenWindows On
					SetTitleMatchMode 2
					if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
						PostMessage, 0x5555, 1, 1
					}
					DetectHiddenWindows %Prev_DetectHiddenWindows%
					SetTitleMatchMode %Prev_TitleMatchMode%
					IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
					nm_setStatus("Looting")
					nm_Move(12000*MoveSpeedFactor, FwdKey)
					nm_Move(18000*MoveSpeedFactor, BackKey)
					LastTunnelBear:=nowUnix()
					IniWrite %LastTunnelBear%, settings\nm_config.ini, Collect, LastTunnelBear
					break
				}
			}
		}
		if(VBState=1)
			return
		;king beetle
		if((KingBeetleCheck) && (nowUnix()-LastKingBeetle)>floor(86400*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;24 hours
			loop 2 {
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "King Beetle")
				If (MoveMethod="walk") {
					nm_walkTo("blue flower")
					nm_Move(5000*MoveSpeedFactor, RightKey, FwdKey)
					nm_Move(4000*MoveSpeedFactor, FwdKey)
					loop 2 {
						send {%RotRight%}
					}
				} else {
					nm_gotoRamp()
					nm_gotoCannon()
					PrevKeyDelay := A_KeyDelay
					SetKeyDelay, 5
					sendinput {%SC_E% down}
					Sleep, 100
					sendinput {%SC_E% up}
					DllCall("Sleep",UInt,50)
					send {%LeftKey% down}
					DllCall("Sleep",UInt,575)
					send {%SC_Space%}
					send {%SC_Space%}
					DllCall("Sleep",UInt,4600)
					send {%LeftKey% up}
					send {%SC_Space%}
					DllCall("Sleep",UInt,1000)
					nm_Move(4000*MoveSpeedFactor, LeftKey, FwdKey)
					SetKeyDelay, PrevKeyDelay
				}
				;wait for baby love
				DllCall("Sleep",UInt,1000)
				if (KingBeetleBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					nm_Move(2000*MoveSpeedFactor, BackKey)
					DllCall("Sleep",UInt,1500)
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						DllCall("Sleep",UInt,1000)
					}
					nm_Move(1500*MoveSpeedFactor, FwdKey)
					nm_Move(1500*MoveSpeedFactor, LeftKey)
				}
				lairConfirmed:=0
				;Go inside
				movement := "
				(LTrim Join`r`n
				" nm_Walk(5, RightKey) "
				Send {" SC_Space " down}
				Sleep, 200
				Send {" SC_Space " up}
				" nm_Walk(3, RightKey) "
				" nm_Walk(5, RightKey, FwdKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T30 L
				nm_endWalk()
				loop 2 {
					send {%RotLeft%}
				}
				loop 5 {
					if (nm_imgSearch("kingfloor.png",10,"low")[1] = 0){
						lairConfirmed:=1
						break
					}
					sleep 200
				}
				if(!lairConfirmed)
					continue
				;search for king beetle
				nm_setStatus("Searching", "King Beetle")
				found:=0
				;(+) new detection here
				;(+) Update health detection
				loop 20
				{
					kBeetle:= nm_HealthDetection()
					if(kBeetle.Length() > 0)
					{
						found:=1
						break
					}
					Sleep, 250
				}
				if(!found) { ;No King Beetle here...try again in 2 hours
					if(A_Index=2){
						LastKingBeetle:=nowUnix()-floor(79200*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
						IniWrite %LastKingBeetle%, settings\nm_config.ini, Collect, LastKingBeetle
					}
					continue
				}
				nm_setStatus("Attacking", "King Beetle")
				kingdead:=0
				sleep, 2000
				loop 1 {
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
						nm_Move(2500*MoveSpeedFactor, BackKey)
						nm_Move(500*MoveSpeedFactor, RightKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, BackKey)
					sleep, 1000
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
						nm_Move(1000*MoveSpeedFactor, BackKey)
						nm_Move(500*MoveSpeedFactor, RightKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, RightKey)
					sleep, 100
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1500*MoveSpeedFactor, BackKey)
						nm_Move(1000*MoveSpeedFactor, LeftKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, BackKey)
					sleep, 1000
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1250*MoveSpeedFactor, FwdKey)
						nm_Move(1000*MoveSpeedFactor, LeftKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, RightKey)
					sleep, 1000
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1250*MoveSpeedFactor, FwdKey)
						nm_Move(2000*MoveSpeedFactor, LeftKey)
						break
					}
					loop 2 {
						nm_Move(2000*MoveSpeedFactor, BackKey, RightKey)
						if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
							kingdead:=1
							nm_Move(2500*MoveSpeedFactor, FwdKey, LeftKey)
							nm_Move(2500*MoveSpeedFactor, LeftKey)
							break
						}
					}
					if(kingdead)
						break
					sleep, 500
					send {%RotLeft%}
					loop 300 {
						if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
							kingdead:=1
							send {%RotRight%}
							nm_Move(3500*MoveSpeedFactor, FwdKey, LeftKey)
							nm_Move(2500*MoveSpeedFactor, LeftKey)
							break
						}
						sleep 1000
					}
				}
				if(kingdead) {
					;check for amulet
					imgPos := nm_imgSearch("keep.png",25,"full")
					If (imgPos[1] = 0){
						if (KingBeetleAmuletMode = 1) {
							nm_setStatus("Keeping", "King Beetle Amulet")
							WinGetClientPos(windowX, windowY, , , "ahk_id " GetRobloxHWND())
							MouseMove, windowX+(imgPos[2] + 10), windowY+(imgPos[3] + 10)
							Click
							sleep, 1000
						} else {
							nm_setStatus("Obtained", "King Beetle Amulet")
						}
					} else { ;loot
						nm_setStatus("Looting", "King Beetle")
						nm_loot(13.5, 7, "right", 1)
					}
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					Prev_DetectHiddenWindows := A_DetectHiddenWindows
					Prev_TitleMatchMode := A_TitleMatchMode
					DetectHiddenWindows On
					SetTitleMatchMode 2
					if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
						PostMessage, 0x5555, 1, 1
					}
					DetectHiddenWindows %Prev_DetectHiddenWindows%
					SetTitleMatchMode %Prev_TitleMatchMode%
					IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
					LastKingBeetle:=nowUnix()
					IniWrite %LastKingBeetle%, settings\nm_config.ini, Collect, LastKingBeetle
					break
				}
			}
		}
		if(VBState=1)
			return
		;Snail
		if((StumpSnailCheck) && (nowUnix()-LastStumpSnail)>floor(345600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;4 days
			loop 2 {
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "Stump Snail")
				If (MoveMethod="walk") {
					nm_walkTo("stump")
				} else {
					nm_cannonTo("stump")
				}

				;search for Stump snail
				nm_setStatus("Searching", "Stump Snail")
				found:=0
				loop 20
				{
					sSnail:= nm_HealthDetection()
					if(sSnail.Length() > 0)
					{
						found:=1
						break
					}
					Sleep, 150
				}
				;attack Snail
				movement := "
				(LTrim Join`r`n
				" nm_Walk(1, FwdKey) "
				)"
				nm_createWalk(movement, "snailWalk")
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				movement := "
				(LTrim Join`r`n
				" nm_Walk(2.5, RightKey) "
				" nm_Walk(2.5, FwdKey) "
				" nm_Walk(2.5, Leftkey) "
				" nm_Walk(5, BackKey) "
				" nm_Walk(2.5, Leftkey) "
				" nm_Walk(2.5, FwdKey) "
				" nm_Walk(5, RightKey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(2.5, Leftkey) "
				" nm_Walk(5, FwdKey) "
				" nm_Walk(2.5, Leftkey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(2.5, Rightkey) "
				)"

				Ssdead:=0
				if(found) {
					nm_setStatus("Attacking", "Stump Snail")
					DllCall("GetSystemTimeAsFileTime", "int64p", SnailStartTime)
					KillCheck := SnailStartTime
					UpdateTimer := SnailStartTime
					Send {%SC_1%}
					loop 2
					{
						Send {%RotUp%}
					}
					inactiveHoney:=0
					loop ;Custom Stump timer to keep blessings, Will rehunt in an hour
					{ 
						if (SprinklerType = "Supreme")
						{
							if (currentWalk["name"] != "snail")
							{
								nm_createWalk(movement, "snail") ; create cycled walk script for this snail session
							}
							else
							{
								Send {F13} ; start new cycle
							}
							KeyWait, F14, D T5 L ; wait for pattern start
						}
						click, down
						Loop, 600
						{
							Sleep, 50
							imgPos := nm_imgSearch("keep.png",25,"full")
							If (imgPos[1] = 0){
								Ssdead := 1
								Send {%RotDown% 2}
								if (ShellAmuletMode = 1) {
									nm_setStatus("Keeping", "Shell Amulet")
									WinGetClientPos(windowX, windowY, , , "ahk_id " GetRobloxHWND())
									MouseMove, windowX+(imgPos[2] + 10), windowY+(imgPos[3] + 10)
									Click
									sleep, 1000
								} else {
									nm_setStatus("Obtained", "Shell Amulet")
								}
								break 2
							}
							if((Mod(A_Index, 10) = 0) && (not nm_activeHoney())){
								inactiveHoney++
								if (inactiveHoney>=10)
									break 2
							}
							if(Mod(A_Index, 20) = 0){
								if (disconnectCheck())
									break
								FormatTime, utc_min, %A_NowUTC%, m
								if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
									break
							}
							if(youDied)
								break 2
							if(VBState=1){
								nm_endWalk()
								click, up
								return
							}
							if (SprinklerType = "Supreme")
							{
								if (!GetKeyState("F14") || A_Index = 600)
								{
									nm_fieldDriftCompensation()
									Break
								}
							}
						}
						click, up
						;(+) New detection system for snail
						DllCall("GetSystemTimeAsFileTime", "int64p", currentTime)
						ElaspedSnailTime :=  (currentTime - SnailStartTime)//10000
						LastHealthCheck := (currentTime - KillCheck)//10000
						LastUpdate := (currentTime - UpdateTimer)//10000
						If(ElaspedSnailTime > SnailTime*60000 && SnailTime != "Kill")
						{
							nm_setStatus("Time Limit", "Stump Snail")
							LastStumpSnail:=nowUnix()-floor(345600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
							break
						}
						if (LastUpdate > 60000)
						{
							if (nm_KillTimeEstimation("Snail", LastHealthCheck) != 0)
							{
								KillCheck := currentTime
							}
							UpdateTimer := currentTime
						}
					}
					nm_endWalk()
				}
				else { ;No Stump Snail try again in 2 hours
					LastStumpSnail:=nowUnix()-floor(345600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
					IniWrite %LastStumpSnail%, settings\nm_config.ini, Collect, LastStumpSnail
					nm_setStatus("Missing", "Stump Snail")
				}

				;loot
				if(SSdead) {
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					Prev_DetectHiddenWindows := A_DetectHiddenWindows
					Prev_TitleMatchMode := A_TitleMatchMode
					DetectHiddenWindows On
					SetTitleMatchMode 2
					if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
						PostMessage, 0x5555, 1, 1
					}
					DetectHiddenWindows %Prev_DetectHiddenWindows%
					SetTitleMatchMode %Prev_TitleMatchMode%
					IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
					LastStumpSnail:=nowUnix()
					IniWrite, %LastStumpSnail%, settings\nm_config.ini, Collect, LastStumpSnail
					InputSnailHealth := 100.00
					IniWrite, %InputSnailHealth%, settings\nm_config.ini, Collect, InputSnailHealth
					intialHealthCheck:=0
					break
				}
				else if (A_Index = 2){ ;stump snail not dead, come again in 30 mins
					LastStumpSnail:=nowUnix()-floor(345600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
					IniWrite, %LastStumpSnail%, settings\nm_config.ini, Collect, LastStumpSnail
				}
			}
		}
		if(VBState=1)
			return

		;Commando
		if((CommandoCheck) && (nowUnix()-LastCommando)>floor(1800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;30 minutes
			loop, 2 {
				nm_Reset()
				;Go to Commando tunnel
				nm_setStatus("Traveling", "Commando")
				nm_gotoRamp()
				if (MoveMethod = "Walk")
				{
					movement := "
					(LTrim Join`r`n
					" nm_Walk(47.25, BackKey, LeftKey) "
					" nm_Walk(40.5, LeftKey) "
					" nm_Walk(8.1, BackKey) "
					" nm_Walk(22.5, LeftKey) "
					send {" RotLeft " 2}
					" nm_Walk(27, FwdKey) "
					" nm_Walk(12, LeftKey, FwdKey) "
					" nm_Walk(11, FwdKey) "
					)"
				}
				else
				{
					nm_gotoCannon()
					movement := "
					(LTrim Join`r`n
					send {" SC_E " down}
					HyperSleep(100)
					send {" SC_E " up}
					HyperSleep(400)
					send {" LeftKey " down}{" FwdKey " down}
					HyperSleep(1050)
					send {" SC_Space " 2}
					HyperSleep(5850)
					send {" FwdKey " up}
					HyperSleep(750)
					send {" SC_Space "}{" RotLeft " 2}
					HyperSleep(1500)
					send {" LeftKey " up}
					" nm_Walk(4, BackKey) "
					" nm_Walk(4.5, LeftKey) "
					)"
				}

				if (MoveSpeedNum < 34)
				{
					movement .= "
					(LTrim Join`r`n

					" nm_Walk(10, LeftKey) "
					HyperSleep(50)
					" nm_Walk(6, RightKey) "
					HyperSleep(50)
					" nm_Walk(2, LeftKey) "
					HyperSleep(50)
					" nm_Walk(7, FwdKey) "
					HyperSleep(750)
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(5.5, FwdKey) "
					HyperSleep(750)
					Loop, 3
					{
						send {" SC_Space " down}
						HyperSleep(50)
						send {" SC_Space " up}
						" nm_Walk(6, FwdKey) "
						HyperSleep(750)
					}
					" nm_Walk(1, FwdKey) "
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(6, FwdKey) "
					HyperSleep(750)
					" nm_Walk(5, FwdKey) "
					HyperSleep(50)
					" nm_Walk(9, BackKey) "
					Sleep 4000
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(0.5, BackKey) "
					HyperSleep(1500)
					)"
				}
				else
				{
					movement .= "
					(LTrim Join`r`n

					" nm_Walk(10, LeftKey) "
					HyperSleep(50)
					" nm_Walk(6, RightKey) "
					HyperSleep(50)
					" nm_Walk(2, LeftKey) "
					HyperSleep(50)
					" nm_Walk(7, FwdKey) "
					HyperSleep(750)
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(4.5, FwdKey) "
					HyperSleep(750)
					Loop, 3
					{
						send {" SC_Space " down}
						HyperSleep(50)
						send {" SC_Space " up}
						" nm_Walk(5, FwdKey) "
						HyperSleep(750)
					}
					" nm_Walk(1, FwdKey) "
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(6, FwdKey) "
					HyperSleep(750)
					" nm_Walk(5, FwdKey) "
					HyperSleep(50)
					" nm_Walk(9, BackKey) "
					Sleep 4000
					send {" SC_Space " down}
					HyperSleep(50)
					send {" SC_Space " up}
					" nm_Walk(0.5, BackKey) "
					HyperSleep(1500)
					)"
				}

				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T90 L
				nm_endWalk()

				if (youDied)
					continue

				while (nm_imgSearch("ChickFled.png",50,"lowright")[1] = 0)
				{
					if (A_Index = 5)
					{
						nm_endWalk()
						continue 2
					}
					if ((A_Index = 1) || (currentWalk["name"] != "commando"))
					{
						movement := "
						(LTrim Join`r`n
						" nm_Walk(5, FwdKey) "
						HyperSleep(50)
						" nm_Walk(9, BackKey) "
						Sleep 4000
						send {" SC_Space " down}
						HyperSleep(50)
						send {" SC_Space " up}
						" nm_Walk(0.5, BackKey) "
						HyperSleep(1500)
						)"
						nm_createWalk(movement, "commando")
					}
					else
						Send {F13}

					KeyWait, F14, D T5 L
					KeyWait, F14, T20 L
				}
				nm_endWalk()

				nm_setStatus("Searching", "Commando Chick")
				found:=0
				loop 4 {
					Send {%ZoomIn%}
				}
				;(+) Update health detection
				loop 20
				{
					cChick:= nm_HealthDetection()
					if(cChick.Length() > 0)
					{
						found:=1
						break
					}
					Sleep, 250
				}
				Global ChickStartTime
				Global ElaspedChickTime
				Ccdead:=0
				if(found) {
					nm_setStatus("Attacking", "Commando Chick")

					DllCall("GetSystemTimeAsFileTime", "int64p", ChickStartTime)
					KillCheck := ChickStartTime 
					UpdateTimer := ChickStartTime
					chickStrikes := 0
					loop { ;10 minute chick timer to keep blessings, Will rehunt in an hour
						click
						sleep 100
						;do later
						if(nm_imgSearch("ChickDead.png",50,"lowright")[1] = 0){
							CCdead:=1
							break
						}
						if(youDied)
							break
						if (Mod(A_Index, 20) = 0){
							if (disconnectCheck())
								break
							FormatTime, utc_min, %A_NowUTC%, m
							if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
								break
						}
						;(+) New detection system for Chick
						DllCall("GetSystemTimeAsFileTime", "int64p", currentTime)
						LastHealthCheck := (currentTime - KillCheck)//10000
						ElaspedChickTime := (currentTime-ChickStartTime)//10000
						LastUpdate := (currentTime - UpdateTimer)//10000
						If(ElaspedChickTime > ChickTime*60000 && ChickTime != "Kill")
						{
							nm_setStatus("Time Limit", "Commando Chick")
							LastCommando:=nowUnix()-floor(1800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
							Break
						}
						if (LastUpdate > 60000)
						{
							if (nm_KillTimeEstimation("Chick", LastHealthCheck) != 0)
							{
								KillCheck := currentTime
							}
							UpdateTimer := currentTime
						}
						loop 20
						{
							comChick:= nm_HealthDetection()
							if(comChick.Length() > 0)
								break
							if(A_Index=20)
							{
								if (chickStrikes <= 10)
								{
									chickStrikes += 1
								}
								else
								{
									CCdead:=1
									Break, 2
								}
							}
							if(nm_imgSearch("ChickDead.png",50,"lowright")[1] = 0){
								CCdead:=1
								break 2
							}
							sleep, 250
						}	
					}
				}
				else { ;No Commando chick try again in 30 mins
					LastCommando:=nowUnix()
					IniWrite, %LastCommando%, settings\nm_config.ini, Collect, LastCommando
					nm_setStatus("Missing", "Commando Chick")
				}

				;loot
				if(CCdead) {
					nm_setStatus("Looting", "Commando Chick")
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					Prev_DetectHiddenWindows := A_DetectHiddenWindows
					Prev_TitleMatchMode := A_TitleMatchMode
					DetectHiddenWindows On
					SetTitleMatchMode 2
					if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
						PostMessage, 0x5555, 1, 1
					}
					DetectHiddenWindows %Prev_DetectHiddenWindows%
					SetTitleMatchMode %Prev_TitleMatchMode%
					IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
					LastCommando:=nowUnix()
					IniWrite, %LastCommando%, settings\nm_config.ini, Collect, LastCommando
					InputChickHealth:=100.00
					IniWrite, %InputChickHealth%, settings\nm_config.ini, Collect, InputChickHealth
					intialHealthCheck:=0
					break
				}
			}
		}
		if(VBState=1)
			return
		;crab
		if((CocoCrabCheck) && (nowUnix()-LastCocoCrab)>floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;1.5 days
			loop 6 {
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "Coco Crab")
				If (MoveMethod="walk") {
					nm_walkTo("coconut")
				} else {
					nm_cannonTo("coconut")
				}
				Send {%SC_1%}
				nm_Move(1400, RightKey)
				nm_Move(1000, BackKey)

				;search for Crab
				nm_setStatus("Searching", "Coco Crab")
				found:=0

				 ;(+) new detection here
				loop 20
				{
					cCrab:= nm_HealthDetection()
					if(cCrab.Length() > 0)
					{
						found:=1
						break
					}
					Sleep, 250
				}
				;attack Crab

				Global CrabStartTime
				Global ElaspedCrabTime

				;CRAB TIMERS
				;timers in ms
				leftright_start := 500
				leftright_end := 19000
				cycle_end := 24000

				;left-right movement
				moves := 14
				move_delay := 310

				movement := "
					(LTrim Join`r`n
					DllCall(""GetSystemTimeAsFileTime"", ""int64p"", start_time)
					" nm_Walk(4, FwdKey) "
					DllCall(""GetSystemTimeAsFileTime"", ""int64p"", time)
					Sleep, " leftright_start " -(time-start_time)//10000
					loop 2 {
						i := A_Index
						" nm_Walk(1, FwdKey) "
						Loop, " moves " {
							" nm_Walk(2, LeftKey) "
							DllCall(""GetSystemTimeAsFileTime"", ""int64p"", time)
							Sleep, i*" 2*move_delay*moves "-" 2*move_delay*moves-leftright_start "+A_Index*" move_delay "-(time-start_time)//10000
						}
						" nm_Walk(1, BackKey) "
						Loop, " moves " {
							" nm_Walk(2, RightKey) "
							DllCall(""GetSystemTimeAsFileTime"", ""int64p"", time)
							Sleep, i*" 2*move_delay*moves "-" move_delay*moves-leftright_start "+A_Index*" move_delay "-(time-start_time)//10000
						}
					}
					DllCall(""GetSystemTimeAsFileTime"", ""int64p"", time)
					Sleep, " leftright_end "-(time-start_time)//10000
					" nm_Walk(6.5, BackKey) "
					DllCall(""GetSystemTimeAsFileTime"", ""int64p"", time)
					Sleep, " cycle_end "-(time-start_time)//10000
					)"

				Crdead:=0
				if(found) {

					nm_setStatus("Attacking", "Coco Crab")
					DllCall("GetSystemTimeAsFileTime", "int64p", CrabStartTime)
					inactiveHoney:=0
					loop { ;30 minute crab timer to keep blessings, Will rehunt in an hour
						DllCall("GetSystemTimeAsFileTime", "int64p", PatternStartTime)
						if (currentWalk["name"] != "crab")
							nm_createWalk(movement, "crab") ; create cycled walk script for this gather session
						else
							Send {F13} ; start new cycle

						KeyWait, F14, D T5 L ; wait for pattern start

						Loop, 600
						{
							if(!DisableToolUse)
								Click
							if(nm_imgSearch("crab.png",70,"lowright")[1] = 0){
								Crdead:=1
								send {%RotUp% 2}
								break 2
							}
							if((Mod(A_Index, 10) = 0) && (not nm_activeHoney())){
								inactiveHoney++
								if (inactiveHoney>=10)
									break 2
							}
							if(youDied)
								break 2
							if((A_Index = 600) || !GetKeyState("F14"))
								break
							Sleep, 50
						}
						DllCall("GetSystemTimeAsFileTime", "int64p", time)
						ElaspedCrabTime := (time-CrabStartTime)//10000
						If (ElaspedCrabTime > 900000){
							nm_setStatus("Time Limit", "Coco Crab")
							LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
							IniWrite, %LastCocoCrab%, settings\nm_config.ini, Collect, LastCocoCrab
							nm_endWalk()
							Return
						}
					}
					nm_endWalk()
				}
				else { ;No Crab try again in 2 hours
					LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
					IniWrite, %LastCocoCrab%, settings\nm_config.ini, Collect, LastCocoCrab
					nm_setStatus("Missing", "Coco Crab")
				}

				;loot
				if(Crdead) {
					DllCall("GetSystemTimeAsFileTime", "int64p", time)
					VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",time-CrabStartTime,"wstr","mm:ss","str",duration,"int",256)
					nm_setStatus("Defeated", "Coco Crab`nTime: " duration)
					ElapsedPatternTime := (time-PatternStartTime)//10000
					movement := "
					(LTrim Join`r`n
					" nm_Walk(((ElapsedPatternTime > leftright_start) && (ElapsedPatternTime < leftright_start+4*moves*move_delay)) ? Abs(Abs(Mod((ElapsedPatternTime-moves*move_delay-leftright_start)*2/move_delay, moves*4)-moves*2)-moves*3/2) : moves*3/2, (((ElapsedPatternTime > leftright_start+moves/2*move_delay) && (ElapsedPatternTime < leftright_start+3*moves/2*move_delay)) || ((ElapsedPatternTime > leftright_start+5*moves/2*move_delay) && (ElapsedPatternTime < leftright_start+7*moves/2*move_delay))) ? RightKey : LeftKey) "
					" (((ElapsedPatternTime < leftright_start) || (ElapsedPatternTime > leftright_end)) ? nm_Walk(4, FwdKey) : "") "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T20 L
					nm_endWalk()
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					Prev_DetectHiddenWindows := A_DetectHiddenWindows
					Prev_TitleMatchMode := A_TitleMatchMode
					DetectHiddenWindows On
					SetTitleMatchMode 2
					if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
						PostMessage, 0x5555, 1, 1
					}
					DetectHiddenWindows %Prev_DetectHiddenWindows%
					SetTitleMatchMode %Prev_TitleMatchMode%
					IniWrite, %TotalBossKills%, settings\nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, settings\nm_config.ini, Status, SessionBossKills
					nm_setStatus("Looting", "Coco Crab")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					LastCocoCrab:=nowUnix()
					IniWrite, %LastCocoCrab%, settings\nm_config.ini, Collect, LastCocoCrab
					break
				}
				else if (A_Index = 2) { ;crab kill failed, try again in 30 mins
					LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
					IniWrite, %LastCocoCrab%, settings\nm_config.ini, Collect, LastCocoCrab
					nm_setStatus("Failed", "Coco Crab")
				}
			}
		}
	}
}
nm_Mondo(){
	global youDied
	global VBState
	;mondo buff
	global MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, PMondoGuidComplete, GatherFieldBoostedStart, LastGlitter
	if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
		return
	if(VBState=1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")){
		mondobuff := nm_imgSearch("mondobuff.png",50,"buff")
		If (mondobuff[1] = 0) {
			LastMondoBuff:=nowUnix()
			IniWrite, %LastMondoBuff%, settings\nm_config.ini, Collect, LastMondoBuff
			return
		}
		repeat:=1
		global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E
		global KeyDelay
		global MoveMethod
		global MoveSpeedNum
		global AFBrollingDice
		global AFBuseGlitter
		global AFBuseBooster
		global CurrentField, CurrentAction, PreviousAction
		PreviousAction:=CurrentAction
		CurrentAction:="Mondo"
		MoveSpeedFactor:=round(18/MoveSpeedNum, 2)
		while(repeat){
			nm_Reset()
			nm_setStatus("Traveling", ("Mondo (" . MondoAction . ")"))
			if (MoveMethod="walk") {
				nm_walkTo("mountain top")
				nm_Move(2500*MoveSpeedFactor, RightKey)
            } else {
                nm_gotoRamp()
                nm_gotoCannon()

                movement := "
                (LTrim Join`r`n
                send {" SC_E " down}
				HyperSleep(100)
				send {" SC_E " up}
				HyperSleep(2500)
				" nm_Walk(29, FwdKey) "
				" nm_Walk(25, RightKey) "
				" nm_Walk(3, LeftKey) "
				" nm_Walk(19, BackKey) "
				HyperSleep(200)
				send {" RotLeft " 1}
                )"

                nm_createWalk(movement)
                KeyWait, F14, D T5 L
                KeyWait, F14, T90 L
                nm_endWalk()
            }
			;;; (+) new conditions probably
			found := 0 
			loop 20
			{
				mChick:= nm_HealthDetection()
				if(mChick.Length() > 0)
				{
					found:=1
					break
				}
				Sleep, 250
			}
			if (found)
			{
				nm_setStatus("Found")
			    for index, value in mChick ;Mondo is already dmging itself before we get there 
			    {
			        if (v = 100.00) ;Planter detected since mondo will already have taken dmg by the time you come up
			        { 
			            continue
			        }
			        else 
			        {
			            mondoChick:=1
			        }
			    } 
			    if (mondoChick)
			    {
					nm_setStatus("Attacking")
			        if(MondoAction="Buff"){
			            repeat:=0
			            loop 120 { ;2 mins
			                nm_autoFieldBoost(CurrentField)
			                if(youDied || AFBrollingDice || AFBuseGlitter || AFBuseBooster)
			                    break
			                sleep, 1000
			            }
			        }
			        else if(MondoAction="Tag"){
			            repeat:=0
			            ;zaappiix5
			            nm_Move(2000*MoveSpeedFactor, LeftKey)	
			            nm_Move(2000*MoveSpeedFactor, BackKey)	
			            nm_Move(1000*MoveSpeedFactor, LeftKey)	
			            nm_Move(3500*MoveSpeedFactor, FwdKey)	
			            loop 25 { ;25 sec
			                if(youDied)
			                    break
			                sleep, 1000
			            }
			        } 
			        else if(MondoAction="Guid" && PMondoGuid=1 && PMondoGuidComplete=0){
			            repeat:=0
			            PMondoGuidComplete:=1
			            while ((nowUnix()-LastGuid)<=210 && utc_min<15 && A_Index<210) { ;3.5 mins since guid
			                if(youDied)
			                    break
			                ;check for mondo death here
			                mondo := nm_imgSearch("mondo3.png",50,"lowright")
			                If (mondo[1] = 0) {
			                    break
			                }
			                sleep, 1000
			                FormatTime, utc_min, %A_NowUTC%, m
			            }
			        } else if(MondoAction="Kill"){
			            repeat:=1
			            loop 900 { ;15 mins
			                nm_autoFieldBoost(CurrentField)
			                if(youDied || VBState=1 || AFBrollingDice || AFBuseGlitter || AFBuseBooster)
			                    break
			                if(utc_min>14) {
			                    repeat:=0
			                    break
			                }
			                ;check for mondo death here
							loop 60 ; Changed from 5 seconds to 15 seconds for when mondo goes off screen
							{
								mondoDead:=nm_HealthDetection()
								if(mondoDead.Length() > 0)
									Break
								if (A_Index=60)
								{
									repeat:=0
									send {%RotRight%}
			            			;loot mondo after death
									nm_setStatus("Looting")
									nm_Move(1500*MoveSpeedFactor, FwdKey)
									nm_Move(500*MoveSpeedFactor, LeftKey)
									nm_Move(1400*MoveSpeedFactor, BackKey)
									nm_Move(100*MoveSpeedFactor, LeftKey)
									nm_loot(13.5, 6, "left")
                        			nm_loot(13.5, 6, "right")
                        			nm_loot(13.5, 6, "left")
									break 2
								}
								Sleep, 250
							}	
							if(A_Index=900)
							{
								repeat:=0
			                    break
							}
			                if(Mod(A_Index, 60)=0)
			                    click
			                sleep, 1000
			                FormatTime, utc_min, %A_NowUTC%, m
			            }
			        }
			    }
			}
			else
			{
				Break
			}

		}
		LastMondoBuff:=nowUnix()
		IniWrite, %LastMondoBuff%, settings\nm_config.ini, Collect, LastMondoBuff
	}
}
nm_cannonTo(location){
	global
	static paths := {}, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\ct-bamboo.ahk
		#Include %A_ScriptDir%\paths\ct-blueflower.ahk
		#Include %A_ScriptDir%\paths\ct-cactus.ahk
		#Include %A_ScriptDir%\paths\ct-clover.ahk
		#Include %A_ScriptDir%\paths\ct-coconut.ahk
		#Include %A_ScriptDir%\paths\ct-dandelion.ahk
		#Include %A_ScriptDir%\paths\ct-mountaintop.ahk
		#Include %A_ScriptDir%\paths\ct-mushroom.ahk
		#Include %A_ScriptDir%\paths\ct-pepper.ahk
		#Include %A_ScriptDir%\paths\ct-pinetree.ahk
		#Include %A_ScriptDir%\paths\ct-pineapple.ahk
		#Include %A_ScriptDir%\paths\ct-pumpkin.ahk
		#Include %A_ScriptDir%\paths\ct-rose.ahk
		#Include %A_ScriptDir%\paths\ct-spider.ahk
		#Include %A_ScriptDir%\paths\ct-strawberry.ahk
		#Include %A_ScriptDir%\paths\ct-stump.ahk
		#Include %A_ScriptDir%\paths\ct-sunflower.ahk
		SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	HiveConfirmed:=0

	InStr(paths[location], "gotoramp") ? nm_gotoRamp()
	InStr(paths[location], "gotocannon") ? nm_gotoCannon()

	nm_createWalk(paths[location])
	KeyWait, F14, D T5 L
	KeyWait, F14, T60 L
	nm_endWalk()
}
nm_gotoPlanter(location, waitEnd := 1){
	global
	static paths := {}, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\gtp-bamboo.ahk
		#Include %A_ScriptDir%\paths\gtp-blueflower.ahk
		#Include %A_ScriptDir%\paths\gtp-cactus.ahk
		#Include %A_ScriptDir%\paths\gtp-clover.ahk
		#Include %A_ScriptDir%\paths\gtp-coconut.ahk
		#Include %A_ScriptDir%\paths\gtp-dandelion.ahk
		#Include %A_ScriptDir%\paths\gtp-mountaintop.ahk
		#Include %A_ScriptDir%\paths\gtp-mushroom.ahk
		#Include %A_ScriptDir%\paths\gtp-pepper.ahk
		#Include %A_ScriptDir%\paths\gtp-pinetree.ahk
		#Include %A_ScriptDir%\paths\gtp-pineapple.ahk
		#Include %A_ScriptDir%\paths\gtp-pumpkin.ahk
		#Include %A_ScriptDir%\paths\gtp-rose.ahk
		#Include %A_ScriptDir%\paths\gtp-spider.ahk
		#Include %A_ScriptDir%\paths\gtp-strawberry.ahk
		#Include %A_ScriptDir%\paths\gtp-stump.ahk
		#Include %A_ScriptDir%\paths\gtp-sunflower.ahk
		SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	HiveConfirmed:=0

	InStr(paths[location], "gotoramp") ? nm_gotoRamp()
	InStr(paths[location], "gotocannon") ? nm_gotoCannon()

	nm_createWalk(paths[location])
    KeyWait, F14, D T5 L
	if WaitEnd
	{
		KeyWait, F14, T60 L
		nm_endWalk()
	}
}
nm_walkFrom(field:="none")
{
	global
	static paths := {}, SetHiveSlot, SetHiveBees

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\wf-bamboo.ahk
		#Include %A_ScriptDir%\paths\wf-blueflower.ahk
		#Include %A_ScriptDir%\paths\wf-cactus.ahk
		#Include %A_ScriptDir%\paths\wf-clover.ahk
		#Include %A_ScriptDir%\paths\wf-coconut.ahk
		#Include %A_ScriptDir%\paths\wf-dandelion.ahk
		#Include %A_ScriptDir%\paths\wf-mountaintop.ahk
		#Include %A_ScriptDir%\paths\wf-mushroom.ahk
		#Include %A_ScriptDir%\paths\wf-pepper.ahk
		#Include %A_ScriptDir%\paths\wf-pinetree.ahk
		#Include %A_ScriptDir%\paths\wf-pineapple.ahk
		#Include %A_ScriptDir%\paths\wf-pumpkin.ahk
		#Include %A_ScriptDir%\paths\wf-rose.ahk
		#Include %A_ScriptDir%\paths\wf-spider.ahk
		#Include %A_ScriptDir%\paths\wf-strawberry.ahk
		#Include %A_ScriptDir%\paths\wf-stump.ahk
		#Include %A_ScriptDir%\paths\wf-sunflower.ahk
		SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	if !paths.HasKey(field)
	{
		msgbox walkFrom(): Invalid fieldname= %field%
		return
	}

	nm_createWalk(paths[field])
	KeyWait, F14, D T5 L
	nm_setStatus("Traveling", "Hive")
	KeyWait, F14, T60 L
	nm_endWalk()
}
nm_GoGather(){
	global youDied, VBState
	global TCFBKey, AFCFBKey, TCLRKey, AFCLRKey, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, KeyDelay
	global MoveMethod
	global CurrentFieldNum
	global objective
	global BackpackPercentFiltered
	global MicroConverterKey
	global PackFilterArray
	global WhirligigKey, PFieldBoosted, GlitterKey, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, PMondoGuidComplete, LastGuid, PMondoGuid, PFieldGuidExtend, PFieldGuidExtendMins, PFieldBoostExtend, PPopStarExtend, HasPopStar, PopStarActive, FieldGuidDetected, CurrentAction, PreviousAction
	global LastWhirligig
	global BoostChaserCheck, LastBlueBoost, LastRedBoost, LastMountainBoost, FieldBooster3, FieldBooster2, FieldBooster1, FieldDefault, LastMicroConverter, HiveConfirmed, LastWreath, WreathCheck
	global FieldName1, FieldPattern1, FieldPatternSize1, FieldPatternReps1, FieldPatternShift1, FieldPatternInvertFB1, FieldPatternInvertLR1, FieldUntilMins1, FieldUntilPack1, FieldReturnType1, FieldSprinklerLoc1, FieldSprinklerDist1, FieldRotateDirection1, FieldRotateTimes1, FieldDriftCheck1
	global FieldName2, FieldPattern2, FieldPatternSize2, FieldPatternReps2, FieldPatternShift2, FieldPatternInvertFB2, FieldPatternInvertLR2, FieldUntilMins2, FieldUntilPack2, FieldReturnType2, FieldSprinklerLoc2, FieldSprinklerDist2, FieldRotateDirection2, FieldRotateTimes2, FieldDriftCheck2
	global FieldName3, FieldPattern3, FieldPatternSize3, FieldPatternReps3, FieldPatternShift3, FieldPatternInvertFB3, FieldPatternInvertLR3, FieldUntilMins3, FieldUntilPack3, FieldReturnType3, FieldSprinklerLoc3, FieldSprinklerDist3, FieldRotateDirection3, FieldRotateTimes3, FieldDriftCheck3
	global MondoBuffCheck, MondoAction, LastMondoBuff
	global PlanterMode, gotoPlanterField
	global QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
	global PolarQuestGatherInterruptCheck, BuckoQuestGatherInterruptCheck, RileyQuestGatherInterruptCheck, BugrunInterruptCheck, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, BlackQuestCheck, BlackQuestComplete, QuestGatherField, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete, PolarQuestCheck, PolarQuestComplete, RotateQuest, QuestGatherMins, QuestGatherReturnBy, BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll, GameFrozenCounter, HiveSlot, BugrunLadybugsCheck, BugrunRhinoBeetlesCheck, BugrunSpiderCheck, BugrunMantisCheck, BugrunScorpionsCheck, BugrunWerewolfCheck, MonsterRespawnTime
	global BeesmasGatherInterruptCheck, StockingsCheck, LastStockings, FeastCheck, LastFeast, RBPDelevelCheck, LastRBPDelevel, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon
	global GatherStartTime, TotalGatherTime, SessionGatherTime, ConvertStartTime, TotalConvertTime, SessionConvertTime
	global bitmaps
	FormatTime, utc_min, %A_NowUTC%, m
	if !((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck()){
		;BUGS GatherInterruptCheck
		if ((((BugrunInterruptCheck && BugrunLadybugsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll))) && ((nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles)) && ((nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunSpiderCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunMantisCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis)) && ((nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunScorpionsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll))) && ((nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunWerewolfCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-)>floor(3600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))))){
			return
		}
		;BEESMAS GatherInterruptCheck
		if (BeesmasGatherInterruptCheck && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (RBPDelevelCheck && (nowUnix()-LastRBPDelevel)>10800) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800)))
			return
		;MONDO
		if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
			return
		;VICIOUS BEE
		if (VBState = 1)
			return
	}
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
	;FIELD OVERRIDES
	global fieldOverrideReason:="None"
	loop 1 {
		;boosted field override
		if(BoostChaserCheck){
			BoostChaserField:="None"
			blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower"]
			redBoosterFields:=["Rose", "Strawberry", "Mushroom"]
			mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
			otherFields:=["Stump", "Coconut", "Mountain Top", "Pepper"]
			loop 1 {
				;blue
				for key, value in blueBoosterFields {
					if(nm_fieldBoostCheck(value, 1)) {
						BoostChaserField:=value
						break
					}
				}
				if(BoostChaserField!="none")
					break
				;mountain
				for key, value in mountainBoosterFields {
					if(nm_fieldBoostCheck(value, 1)) {
						BoostChaserField:=value
						break
					}
				}
				if(BoostChaserField!="none")
					break
				;red
				for key, value in redBoosterFields {
					if(nm_fieldBoostCheck(value, 1)) {
						BoostChaserField:=value
						break
					}
				}
				if(BoostChaserField!="none")
					break
				;other
				for key, value in otherFields {
					if(nm_fieldBoostCheck(value, 1)) {
						BoostChaserField:=value
						break
					}
				}
			}
			;set field override
			if(BoostChaserField!="none") {
				fieldOverrideReason:="Boost"
				FieldName:=BoostChaserField
				FieldPattern:=FieldDefault[BoostChaserField]["pattern"]
				FieldPatternSize:=FieldDefault[BoostChaserField]["size"]
				FieldPatternReps:=FieldDefault[BoostChaserField]["width"]
				FieldPatternShift:=FieldDefault[BoostChaserField]["shiftlock"]
				FieldPatternInvertFB:=FieldDefault[BoostChaserField]["invertFB"]
				FieldPatternInvertLR:=FieldDefault[BoostChaserField]["invertLR"]
				FieldUntilMins:=FieldDefault[BoostChaserField]["gathertime"]
				FieldUntilPack:=FieldDefault[BoostChaserField]["percent"]
				FieldReturnType:=FieldDefault[BoostChaserField]["convert"]
				FieldSprinklerLoc:=FieldDefault[BoostChaserField]["sprinkler"]
				FieldSprinklerDist:=FieldDefault[BoostChaserField]["distance"]
				FieldRotateDirection:=FieldDefault[BoostChaserField]["camera"]
				FieldRotateTimes:=FieldDefault[BoostChaserField]["turns"]
				FieldDriftCheck:=FieldDefault[BoostChaserField]["drift"]
				;start boosted timer here
				if ((nowUnix()-GatherFieldBoostedStart>900) && (nowUnix()-LastGlitter>900)) {
					GatherFieldBoostedStart:=nowUnix()
				}
				break
			}
		}
		;questing override
		if((BlackQuestCheck || BuckoQuestCheck || RileyQuestCheck || PolarQuestCheck) && (QuestGatherField && QuestGatherField!="None")){
			fieldOverrideReason:="Quest"
			thisfield:=QuestGatherField
			if(QuestGatherField=FieldName1) {
				FieldName:=QuestGatherField
				FieldPattern:=FieldPattern1
				FieldPatternSize:=FieldPatternSize1
				FieldPatternReps:=FieldPatternReps1
				FieldPatternShift:=FieldPatternShift1
				FieldPatternInvertFB:=FieldPatternInvertFB1
				FieldPatternInvertLR:=FieldPatternInvertLR1
				FieldUntilMins:=FieldUntilMins1
				FieldUntilPack:=FieldUntilPack1
				FieldReturnType:=QuestGatherReturnBy
				FieldRotateDirection:=FieldRotateDirection1
				FieldRotateTimes:=FieldRotateTimes1
				FieldSprinklerLoc:=FieldSprinklerLoc1
				FieldSprinklerDist:=FieldSprinklerDist1
			} else {
				FieldName:=QuestGatherField
				FieldPattern:=FieldDefault[QuestGatherField]["pattern"]
				FieldPatternSize:=FieldDefault[QuestGatherField]["size"]
				FieldPatternReps:=FieldDefault[QuestGatherField]["width"]
				FieldPatternShift:=FieldDefault[QuestGatherField]["shiftlock"]
				FieldPatternInvertFB:=FieldDefault[QuestGatherField]["invertFB"]
				FieldPatternInvertLR:=FieldDefault[QuestGatherField]["invertLR"]
				FieldUntilMins:=QuestGatherMins
				FieldUntilPack:=FieldDefault[QuestGatherField]["percent"]
				FieldReturnType:=QuestGatherReturnBy
				FieldSprinklerLoc:=FieldDefault[QuestGatherField]["sprinkler"]
				FieldSprinklerDist:=FieldDefault[QuestGatherField]["distance"]
				FieldRotateDirection:=FieldDefault[QuestGatherField]["camera"]
				FieldRotateTimes:=FieldDefault[QuestGatherField]["turns"]
				FieldDriftCheck:=FieldDefault[QuestGatherField]["drift"]
			}
			break
		}
		;Gather in planter field override
		if(gotoPlanterField && (PlanterMode = 2)){
			loop, 3{
				inverseIndex:=(4-A_Index)
				IniRead, PlanterField%inverseIndex%, settings\nm_config.ini, planters, PlanterField%inverseIndex%
				If(PlanterField%inverseIndex%="dandelion" || PlanterField%inverseIndex%="sunflower" || PlanterField%inverseIndex%="mushroom" || PlanterField%inverseIndex%="blue flower" || PlanterField%inverseIndex%="clover" || PlanterField%inverseIndex%="strawberry" || PlanterField%inverseIndex%="spider" || PlanterField%inverseIndex%="bamboo" || PlanterField%inverseIndex%="pineapple" || PlanterField%inverseIndex%="stump" || PlanterField%inverseIndex%="cactus" || PlanterField%inverseIndex%="pumpkin" || PlanterField%inverseIndex%="pine tree" || PlanterField%inverseIndex%="rose" || PlanterField%inverseIndex%="mountain top" || PlanterField%inverseIndex%="pepper" || PlanterField%inverseIndex%="coconut"){
					fieldOverrideReason:="Planter"
					FieldName:=PlanterField%inverseIndex%
					FieldPattern:=FieldDefault[FieldName]["pattern"]
					FieldPatternSize:=FieldDefault[FieldName]["size"]
					FieldPatternReps:=FieldDefault[FieldName]["width"]
					FieldPatternShift:=FieldDefault[FieldName]["shiftlock"]
					FieldPatternInvertFB:=FieldDefault[FieldName]["invertFB"]
					FieldPatternInvertLR:=FieldDefault[FieldName]["invertLR"]
					FieldUntilMins:=FieldDefault[FieldName]["gathertime"]
					FieldUntilPack:=FieldDefault[FieldName]["percent"]
					FieldReturnType:=FieldDefault[FieldName]["convert"]
					FieldSprinklerLoc:=FieldDefault[FieldName]["sprinkler"]
					FieldSprinklerDist:=FieldDefault[FieldName]["distance"]
					FieldRotateDirection:=FieldDefault[FieldName]["camera"]
					FieldRotateTimes:=FieldDefault[FieldName]["turns"]
					FieldDriftCheck:=FieldDefault[FieldName]["drift"]
					break 2
				}
			}
		}
		FieldName:=FieldName%CurrentFieldNum%
		FieldPattern:=FieldPattern%CurrentFieldNum%
		FieldPatternSize:=FieldPatternSize%CurrentFieldNum%
		FieldPatternReps:=FieldPatternReps%CurrentFieldNum%
		FieldPatternShift:=FieldPatternShift%CurrentFieldNum%
		FieldPatternInvertFB:=FieldPatternInvertFB%CurrentFieldNum%
		FieldPatternInvertLR:=FieldPatternInvertLR%CurrentFieldNum%
		FieldUntilMins:=FieldUntilMins%CurrentFieldNum%
		FieldUntilPack:=FieldUntilPack%CurrentFieldNum%
		FieldReturnType:=FieldReturnType%CurrentFieldNum%
		FieldSprinklerLoc:=FieldSprinklerLoc%CurrentFieldNum%
		FieldSprinklerDist:=FieldSprinklerDist%CurrentFieldNum%
		FieldRotateDirection:=FieldRotateDirection%CurrentFieldNum%
		FieldRotateTimes:=FieldRotateTimes%CurrentFieldNum%
		FieldDriftCheck:=FieldDriftCheck%CurrentFieldNum%
	}
	PreviousAction:=CurrentAction
	CurrentAction:="Gather"
	;close all menus
	nm_OpenMenu()
	;reset
	if(fieldOverrideReason="None" || fieldOverrideReason="Boost") {
		;if(CurrentAction!=PreviousAction){
			nm_Reset(2)
		;} ~ fix reset for gather end, thanks @zaap for finding
		;check if gathering field is boosted
		blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower"]
		redBoosterFields:=["Rose", "Strawberry", "Mushroom"]
		mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
		otherFields:=["Stump", "Coconut", "Mountain Top", "Pepper"]
		loop 1 {
			GatherFieldBoosted:=0
			;blue
			for key, value in blueBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700 && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;mountain
			for key, value in mountainBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700  && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;red
			for key, value in redBoosterFields {
				if(nm_fieldBoostCheck(value, 3) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700  && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
			if(GatherFieldBoosted)
				break
			;other
			for key, value in otherFields {
				if(nm_fieldBoostCheck(value, 1) && FieldName=value) {
					if((nowUnix()-GatherFieldBoostedStart)>2700 && nm_fieldBoostCheck(value, 0)) {
						GatherFieldBoostedStart:=nowUnix()
					}
					if((nowUnix()-GatherFieldBoostedStart)<1800) {
						GatherFieldBoosted:=1
						break
					}
				}
			}
		}
	} else {
		nm_Reset()
	}
	nm_setStatus("Traveling", FieldName)
	;go to field
	if(MoveMethod="Walk"){
		nm_walkTo(FieldName)
	} else if (MoveMethod="Cannon"){
		nm_cannonTo(FieldName)
	} else {
		msgbox GoGather: MoveMethod undefined!
	}
	nm_autoFieldBoost(FieldName)
	nm_fieldBoostGlitter()
	nm_PlanterTimeUpdate(FieldName)
	;set sprinkler
	VarSetCapacity(field_limit,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",FieldUntilMins*60*10000000,"wstr","mm:ss","str",field_limit,"int",256)
	if(fieldOverrideReason="None") {
		nm_setStatus("Gathering", FieldName (GatherFieldBoosted ? " - Boosted" : "") "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else if(fieldOverrideReason="Quest") {
		nm_setStatus("Gathering", RotateQuest . " " . fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else {
		nm_setStatus("Gathering", fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	}
	nm_setSprinkler(FieldName, FieldSprinklerLoc, FieldSprinklerDist)
	;rotate
	if (FieldRotateDirection != "None") {
		direction:=FieldRotateDirection
		sendinput % "{" Rot%direction% " " FieldRotateTimes "}"
	}
	;determine if facing corner
	FacingFieldCorner:=0
	if((FieldName="pine tree" && ((FieldSprinklerLoc="upper" || FieldSprinklerLoc="upper left") && FieldRotateDirection="left" && FieldRotateTimes=1)) || ((FieldName="pineapple" && (FieldSprinklerLoc="upper left" && FieldRotateDirection="left" && FieldRotateTimes=1))) || (FieldName="spider" && ((FieldSprinklerLoc="upper" || FieldSprinklerLoc="upper left") && FieldRotateDirection="left" && FieldRotateTimes=1))) {
		FacingFieldCorner:=1
	}
	;set direction keys
	;foward/back
	if(FieldPatternInvertFB){
		TCFBKey:=BackKey
		AFCFBKey:=FwdKey
	} else {
		TCFBKey:=FwdKey
		AFCFBKey:=BackKey
	}
	if(FieldPatternInvertLR){
		TCLRKey:=RightKey
		AFCLRKey:=LeftKey
	} else {
		TCLRKey:=LeftKey
		AFCLRKey:=RightKey
	}

	;gather loop
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	MouseMove, windowX+350, windowY+100
	bypass:=0
	inactiveHoney:=0
	interruptReason := ""
	GatherStartTime:=gatherStart:=nowUnix()
	if(FieldPatternShift) {
		nm_setShiftLock(1)
	}
	;while(((nowUnix()-gatherStart)<(FieldUntilMins%CurrentFieldNum%*60)) || (PFieldBoostExtend && (nowUnix()-GatherFieldBoostedStart)<1800 && (nowUnix()-LastGlitter)<900) || (PFieldGuidExtend && FieldGuidDetected && (nowUnix()-gatherStart)<(FieldUntilMins%CurrentFieldNum%*60+PFieldGuidExtend*60) && (nowUnix()-GatherFieldBoostedStart)>900 && (nowUnix()-LastGlitter)>900) || (PPopStarExtend && HasPopStar && PopStarActive)){
	while(((nowUnix()-gatherStart)<(FieldUntilMins*60)) || (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)<840) || (PFieldBoostExtend && (nowUnix()-GatherFieldBoostedStart)<1800 && (nowUnix()-LastGlitter)<900) || (PFieldGuidExtend && FieldGuidDetected && (nowUnix()-gatherStart)<(FieldUntilMins*60+PFieldGuidExtend*60) && (nowUnix()-GatherFieldBoostedStart)>900 && (nowUnix()-LastGlitter)>900) || (PPopStarExtend && HasPopStar && PopStarActive)){
		;if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>720 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && (fieldOverrideReason="None" || fieldOverrideReason="Boost")) { ;between 12 and 15 mins (-minus an extra 15 seconds)
		if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && fieldOverrideReason="None") { ;between 9 and 15 mins (-minus an extra 15 seconds)
			Send {%GlitterKey%}
			LastGlitter:=nowUnix()
			IniWrite, %LastGlitter%, settings\nm_config.ini, Boost, LastGlitter
		}
		nm_gather(FieldPattern, A_Index, FieldPatternSize, FieldPatternReps, FacingFieldCorner)
		nm_autoFieldBoost(FieldName)
		FieldDriftCheck ? nm_fieldDriftCompensation()
		nm_fieldBoostGlitter()
		;high priority interrupts
		if(VBState=1 || (dccheck := DisconnectCheck()) || youDied) {
			bypass:=1
			interruptReason := VBState ? "Vicious Bee" : dccheck ? "Disconnect" : "You Died!"
			break
		}
		;full backpack
		if (BackpackPercentFiltered>=(FieldUntilPack-2)) {
			if((BackpackPercentFiltered>=(FieldUntilPack < 90 ? 98 : FieldUntilPack-2)) && ((nowUnix()-LastMicroConverter)>30) && ((MicroConverterKey!="none" && !PFieldBoosted) || (MicroConverterKey!="none" && PFieldBoosted && GatherFieldBoosted))) { ;30 seconds cooldown
				send {%MicroConverterKey%}
				sleep, 500
				LastMicroConverter:=nowUnix()
				IniWrite, %LastMicroConverter%, settings\nm_config.ini, Boost, LastMicroConverter
				continue
			} else {
				interruptReason := "Backpack exceeds " .  FieldUntilPack . " percent"
				;use glitter early if boosted and close to glitter time
				if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>600 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && (fieldOverrideReason="None" || fieldOverrideReason="Boost")){ ;between 10 and 15 mins
					Send {%GlitterKey%}
					LastGlitter:=nowUnix()
					IniWrite, %LastGlitter%, settings\nm_config.ini, Boost, LastGlitter
				}
				break
			}
		}
		;inactive honey
		if(not nm_activeHoney() && (BackpackPercentFiltered<FieldUntilPack)){
			++inactiveHoney
			if (inactiveHoney=3) {
				bypass:=1
				interruptReason := "Inactive Honey"
				GameFrozenCounter:=GameFrozenCounter+1
				break
			}
		}
		else
			inactiveHoney:=0
		;boost is over
		if (fieldOverrideReason="Boost" && (nowUnix()-GatherFieldBoostedStart>900) && (nowUnix()-LastGlitter>900)) {
			interruptReason := "Boost Over"
			break
		}
		;end of high priority interrupts, continue if boosted
		if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
			continue
		;low priority interrupts
		FormatTime, utc_min, %A_NowUTC%, m
		if ((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")){
			interruptReason := "Mondo"
			if (PMondoGuidComplete)
				PMondoGuidComplete:=0
			break
		}
		;GatherInterruptCheck
		if ((((BugrunInterruptCheck && BugrunLadybugsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll))) && ((nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles)) && ((nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunSpiderCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunMantisCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis)) && ((nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunScorpionsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll))) && ((nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) || (((BugrunInterruptCheck && BugrunWerewolfCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-)>floor(3600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))))){
			interruptReason := "Kill Bugs"
			break
		}
		if (BeesmasGatherInterruptCheck) && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (RBPDelevelCheck && (nowUnix()-LastRBPDelevel)>10800) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800)){
			interruptReason := "Beesmas Machine"
			break
		}
		;quest interrupts
		;Black Bear quest
		if(RotateQuest="Black" && BlackQuestCheck && fieldOverrideReason="Quest"){
			nm_BlackQuestProg()
			if(FieldPatternShift) {
				nm_setShiftLock(1)
			}
			;interrupt if
			if (thisfield!=QuestGatherField || BlackQuestComplete){ ;change fields or this field is complete
				interruptReason := "Next Quest Step"
				break
			}
		}
		;Bucko Bee quest
		if(RotateQuest="Bucko" && BuckoQuestCheck && fieldOverrideReason="Quest"){
			nm_BuckoQuestProg()
			if(FieldPatternShift) {
				nm_setShiftLock(1)
			}
			;interrupt if
			if (thisfield!=QuestGatherField || BuckoQuestComplete){ ;change fields or this field is complete
				interruptReason := "Next Quest Step"
				break
			}
		}
		;Riley Bee quest
		if(RotateQuest="Riley" && RileyQuestCheck && fieldOverrideReason="Quest"){
			nm_RileyQuestProg()
			if(FieldPatternShift) {
				nm_setShiftLock(1)
			}
			;interrupt if
			if (thisfield!=QuestGatherField || RileyQuestComplete){ ;change fields or this field is complete
				interruptReason := "Next Quest Step"
				break
			}
		}
		;Polar Bear quest
		if(RotateQuest="Polar" && PolarQuestCheck && fieldOverrideReason="Quest"){
			nm_PolarQuestProg()
			if(FieldPatternShift) {
				nm_setShiftLock(1)
			}
			;interrupt if
			if (thisfield!=QuestGatherField || PolarQuestComplete){ ;change fields or this field is complete
				interruptReason := "Next Quest Step"
				break
			}
		}
	}
	nm_endWalk()

	; set gather ended status
	VarSetCapacity(gatherDuration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(nowUnix()-gatherStart)*10000000,"wstr","mm:ss","str",gatherDuration,"int",256)
	nm_setStatus("Gathering", "Ended`nTime " gatherDuration " - " (interruptReason ? (InStr(interruptReason, "Backpack exceeds") ? "Bag Limit" : interruptReason) : "Time Limit") " - Return: " FieldReturnType)

	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	GatherStartTime:=0
	nm_setShiftLock(0)
	if(bypass = 0){
		;rotate back
		if (FieldRotateDirection != "None") {
			direction:=(FieldRotateDirection = "left") ? "right" : "left"
			sendinput % "{" Rot%direction% " " FieldRotateTimes "}"
		}
		;close quest log if necessary
		nm_OpenMenu()
		;check any planter progress
		nm_PlanterTimeUpdate(FieldName)
		;whirligig
		if(FieldReturnType="walk") { ;walk back
			if((WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)){
				if(FieldName="sunflower"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="dandelion"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="mushroom"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="blue flower"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="spider"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="strawberry"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="bamboo"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="pineapple"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="stump"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="pumpkin"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="pine tree"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="rose"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="pepper"){
					loop 2 {
						send {%RotLeft%}
					}
				}
				send {%WhirligigKey%}
				sleep (2500+KeyDelay)
				;Confirm hive
				send {PgUp 4}
				loop 8 {
					Send {%ZoomOut%}
				}
				loop 4
				{
					If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0))
					{
						send {%RotRight% 4}{PgDn 4}
						HiveConfirmed:=1
						LastWhirligig:=nowUnix()
						IniWrite, %LastWhirligig%, settings\nm_config.ini, Boost, LastWhirligig
						sleep, 1000
						break
					}
					sendinput {%RotRight% 4}
					sleep (250+KeyDelay)
					If (A_Index=4)
					{
						nm_setStatus("Warning", "No Whirligigs")
						WhirligigKey:="None"
					}
				}
			} else { ;walk to hive
				nm_walkFrom(FieldName)
				DisconnectCheck()
				;Honey Wreath
				if (WreathCheck && ((interruptReason = "") || InStr(interruptReason, "Backpack exceeds")) && (nowUnix()-LastWreath)>1800) { ;0.5 hours
					nm_setStatus("Traveling", "Honey Wreath")
					nm_gotoCollect("wreath")

					searchRet := nm_imgSearch("e_button.png",30,"high")
					if (searchRet[1] = 0) {
						sendinput {%SC_E% down}
						Sleep, 100
						sendinput {%SC_E% up}

						LastWreath:=nowUnix()
						IniWrite, %LastWreath%, settings\nm_config.ini, Collect, LastWreath

						Sleep, 4000

						;loot
						movement := "
						(LTrim Join`r`n
						" nm_Walk(1, BackKey) "
						" nm_Walk(4.5, BackKey, LeftKey) "
						" nm_Walk(1, LeftKey) "
						Loop, 3 {
							" nm_Walk(6, FwdKey) "
							" nm_Walk(1.25, RightKey) "
							" nm_Walk(6, BackKey) "
							" nm_Walk(1.25, RightKey) "
						}
						" nm_Walk(6, FwdKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()

						nm_setStatus("Collected", "Honey Wreath")
					}

					;walk back
					movement := "
					(LTrim Join`r`n
					" nm_Walk(4, BackKey) "
					" nm_Walk(12, FwdKey, RightKey) "
					" nm_Walk(24, LeftKey) "
					" nm_Walk(6, BackKey, LeftKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
				}
				nm_findHiveSlot()
			}
		} else { ;reset back
			if ((WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)) {
				if(FieldName="sunflower"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="dandelion"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="mushroom"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="blue flower"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="spider"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="strawberry"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="bamboo"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="pineapple"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="stump"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName="pumpkin"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="pine tree"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="rose"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName="pepper"){
					loop 2 {
						send {%RotLeft%}
					}
				}
				send {%WhirligigKey%}
				sleep (2500+KeyDelay)
				;Confirm hive
				send {PgUp 4}
				loop 8 {
					Send {%ZoomOut%}
				}
				loop 4
				{
					If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0))
					{
						send {%RotRight% 4}{PgDn 4}
						HiveConfirmed:=1
						LastWhirligig:=nowUnix()
						IniWrite, %LastWhirligig%, settings\nm_config.ini, Boost, LastWhirligig
						sleep, 1000
						break
					}
					sendinput {%RotRight% 4}
					sleep (250+KeyDelay)
					If (A_Index=4)
					{
						nm_setStatus("Missing", "Whirligig")
						WhirligigKey:="None"
					}
				}
			}
		}
	}
	nm_currentFieldDown()
	FormatTime, utc_min, %A_NowUTC%, m
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
}
nm_loot(length, reps, direction, tokenlink:=0){ ; length in tiles instead of ms (old)
	global FwdKey, LeftKey, BackKey, RightKey, KeyDelay, bitmaps

	movement := "
	(LTrim Join`r`n
	loop " reps " {
		" nm_Walk(length, FwdKey) "
		" nm_Walk(1.5, %direction%Key) "
		" nm_Walk(length, BackKey) "
		" nm_Walk(1.5, %direction%Key) "
	}
	)"

	nm_createWalk(movement)
	KeyWait, F14, D T5 L

	if (tokenlink = 0) ; wait for pattern finish
		KeyWait, F14, % "T" length*reps " L"
	else ; wait for token link or pattern finish
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		Sleep, 1000 ; primary delay, only accept token links after this
		DllCall("GetSystemTimeAsFileTime","int64p",s)
		n := s, f := s+length*reps*10000000 ; timeout at length * reps
		while ((n < f) && GetKeyState("F14"))
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-400 "|" windowY+windowHeight-400 "|400|400")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["tokenlink"], , , , , , 50, , 7) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep, 50
			DllCall("GetSystemTimeAsFileTime","int64p",n)
		}
	}
	nm_endWalk()
}
nm_OpenMenu(menu:="", refresh:=0){
	global bitmaps
	static x := {"itemmenu":30, "questlog":85, "beemenu":140}, open:=""

	if GetRobloxHWND()
		WinActivate, Roblox
	else
		return 0

	if ((menu = "") || (refresh = 1)) ; close
	{
		if open ; close the open menu
		{
			Loop, 10
			{
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+120
				Click
				MouseMove, windowX+350, windowY+100
				sleep, 500
			}
		}
		else ; close any open menu
		{
			for k,v in x
			{
				Loop, 10
				{
					WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
					if (Gdip_ImageSearch(pBMScreen, bitmaps[k], , , , , , 2) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowX+v, windowY+120
					Click
					MouseMove, windowX+350, windowY+100
					sleep, 500
				}
			}
			open := ""
		}
	}
	else
	{
		if ((menu != open) && open) ; close the open menu
		{
			Loop, 10
			{
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+120
				Click
				MouseMove, windowX+350, windowY+100
				sleep, 500
			}
		}
		; open the desired menu
		Loop, 10
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[menu], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				open := menu
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, windowX+x[menu], windowY+120
			Click
			MouseMove, windowX+350, windowY+100
			sleep, 500
		}
	}
}
nm_InventorySearch(item, direction:="down", prescroll:=0, prescrolldir:="", scrolltoend:=1, max:=70){ ;~ item: string of item; direction: down or up; prescroll: number of scrolls before direction switch; prescrolldir: direction to prescroll, set blank for same as direction; scrolltoend: set 0 to omit scrolling to top/bottom after prescrolls; max: number of scrolls in total
	global bitmaps
	static hRoblox, l:=0

	nm_OpenMenu("itemmenu")

	; detect inventory end for current hwnd
	if (hwnd := WinExist("ahk_id " GetRobloxHWND()))
	{
		if (hwnd != hRoblox)
		{
			WinActivate, Roblox
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-150)

			Loop, 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], lpos, , , 6, , 2, , 2) = 1)
				{
					l := SubStr(lpos, InStr(lpos, ",")+1)-60 ; image 20px, item 80px => y+20-80 = y-60
					hRoblox := hwnd
					break
				}
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						return 0
					}
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-150)
					}
				}
			}
		}
	}
	else
		return 0 ; no roblox

	; search inventory
	Loop %max%
	{
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" l)

		; wait for red vignette effect to disappear
		Loop, 40
		{
			if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
				break
			else
			{
				if (A_Index = 40)
				{
					Gdip_DisposeImage(pBMScreen)
					return 0
				}
				else
				{
					Sleep, 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" l)
				}
			}
		}

		if (Gdip_ImageSearch(pBMScreen, bitmaps[item], pos, , , , , 10, , 5) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break ; item found
		}
		Gdip_DisposeImage(pBMScreen)

		switch A_Index
		{
			case (prescroll+1): ; scroll entire inventory on (prescroll+1)th search
			if (scrolltoend = 1)
			{
				Loop, 100
				{
					MouseMove, windowX+30, windowY+200, 5
					sendinput % "{Wheel" ((direction = "down") ? "Up" : "Down") "}"
					Sleep, 50
				}
			}
			default: ; scroll once
			MouseMove, windowX+30, windowY+200, 5
			sendinput % "{Wheel" ((A_Index <= prescroll) ? (prescrolldir ? ((prescrolldir = "Down") ? "Down" : "Up") : ((direction = "down") ? "Down" : "Up")) : ((direction = "down") ? "Down" : "Up")) "}"
			Sleep, 50
		}
		Sleep, 500 ; wait for scroll to finish
	}
	return (pos ? [30, SubStr(pos, InStr(pos, ",")+1)+190] : 0) ; return list of coordinates for dragging
}
nm_BitterberryFeeder()
{
	if !GetRobloxHWND()
	{
		msgbox, 0x40030, Bitterberry Auto-Feeder v0.2, You must have Bee Swarm Simulator open to use this!, 20
		return
	}

	script := "
	(Join`r`n C
	#NoEnv
	#NoTrayIcon
	#SingleInstance Force
	#Requires AutoHotkey v1.1.36.01+
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	#Include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
	#Include %A_ScriptDir%\submacros\shared\nm_misc.ahk

	CoordMode, Mouse, Screen
	SetBatchLines -1
	OnExit(""ExitFunc"")
	pToken := Gdip_Startup()

	bitmaps := {}
	bitmaps[""itemmenu""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII="")
	bitmaps[""questlog""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg=="")
	bitmaps[""beemenu""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC"")
	bitmaps[""item""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII="")
	bitmaps[""bitterberry""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAG8AAAAbCAMAAABFqCGFAAAB11BMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8oNkApN0EqOEMrOUMsOkQtO0UuPEYvPUcwPkgyQEkzQUo0QUs1Q0w3RU44RU85Rk86SFE8SVM9SlM+S1Q/TFVATVZCT1hDUFlEUVlFUVpGU1xHVFxJVV5KVl9LV19NWWJPW2NRXWVSXmZUYGhVYWhWYWlXYmpXY2tbZm5cZ29daG9eanFibXRibnVkb3ZlcHdoc3ptd35ueX9veoBweoFzfYN0foR1f4V2gIZ4god6hIp7hYt+h41/iY6Aio+FjpSGj5SHkJWKk5iLlJmMlZqNlpqOl5uQmJ2QmZ2Rmp6Sm5+UnKCVnaGZoaWbo6ecpKigp6uhqKyjq66mrbCnrrGnr7Kor7OrsrWss7avtrmwt7myuLu2vL+4v8G5wMK6wMO8wsS+xMa/xcfAxsjBx8nDyMrEyszGzM3HzM7Izc/Jzs/Jz9DK0NHN0tPP1NXQ1dbR1tfS19jV2drX3NzY3N3Z3d7b4ODc4OHe4uLf4+Pg5OTg5eXi5ubj5+fm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/ZX5XClAAACKElEQVR42u3W61NMYQDH8W9iu7uEhAhJURIphYRci0QiFXKJXAttQnIPXdVWK/3+WHvK6dnZfaY3O443fm9+L34zz2fmzDPnHORt+O/9BS8HJ6mlL2Xys6XJlCVTLbUxepDQJaln9b5ZSXs4J7dsKeZIzB45kvzpRY6XHYLcsiU/Ju+YpOHD8NEdPPDUD8+kL52dwcW9K2kF3cazzqYX8d5Ar9QMQ7qMk/o/JU3WZfnWnx2RVEpWPLSFvJ1FKekVvZIss9v10C9JfXAy0hsswTdu937tx0nepHMgkDCifHPFLLPbn5dQI0k18NpyX05r3ot8nq2sejz+dCVNcwfeDAwq5CW1TzzPZLttNl3CmqA0k0G+or3kd7J7uTRIqqNw7oFJcrwKSbfhvWU2fRfuSw+h1eKxdsjqBeKYT6pz0G4Z7yt0WGbTkys4IFWSPKpwr1rSjzPQbPW+4SYY4U1Dm3V2WyeIHxhOpEpRnoJJnLJ6E3BJ84nwQlS7bTaeHxquwwuLN5XIeRmvVgu1iTJJ09FeB7wys83TNjYXslXR3mg1+Be8XeTe8bt1gbgbga6Msu5wL+lWoG8L62ZkZpt3FeCa/f15VAteLfDJrYkdOFn+NtybS9w9ycw27/tS8A1ZvGXZjTPGGzuYvNfUaM0GX2bVB5mDqgoOFaWkFT+SrLPxVA6VXn5vG+GJl14eG2c99Hrgojz0jhM/4KE3lkK5PPRa4cG/+x/8DdlCsT+3EwaSAAAAAElFTkSuQmCC"")
	bitmaps[""feed""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAADwAAAAUAQMAAADrzcxqAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAE1JREFUeNqNzbENwCAMRNHfpYxLSo/ACB4pG8SjMkImIAiwRIe46lX3+QtzAcE5wQ1cHeKQHhw10EwFwISK6YAvvCVg7LBamuM5fRGFBk/MFx8u1mbtAAAAAElFTkSuQmCC"")
	bitmaps[""greensuccess""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzowMzowOCAxNToyMzo1N/c+ABwAAAAdSURBVChTY3T+H/6fgQzABKVJBqMa8YDhr5GBAQBwxAKu5PiUjAAAAA5lWElmTU0AKgAAAAgAAAAAAAAA0lOTAAAAAElFTkSuQmCC"")

	MsgBox, 0x40001, Bitterberry Auto-Feeder v0.2, BITTERBERRY AUTO FEEDER v0.2 by anniespony#8135``nMake sure BEE SLOT TO MUTATE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE BEE IS RADIOACTIVE AT ALL TIMES!
	IfMsgBox, Cancel
		ExitApp

	InputBox, bitterberrynos, How many bitterberry?, Enter the amount of bitterberry used each time, , 320, 180, , , Locale, 60
	if (ErrorLevel != 0) {
		MsgBox, 0x40000, Bitterberry Auto-Feeder v0.2, Something is wrong. Stopping Feeder!
		ExitApp
	}
	if bitterberrynos is integer
	{
		if (bitterberrynos > 30)
		{
			MsgBox, 0x40034, Bitterberry Auto-Feeder v0.2, You have entered %bitterberrynos% which is more than 30.``nAre you sure?
			IfMsgBox No
				ExitApp
		}
	}
	else
	{
		MsgBox, 0x40010, Bitterberry Auto-Feeder v0.2, You must enter a number for Bitterberries!!``nStopping Feeder!
		ExitApp
	}

	MsgBox, 0x40001, Bitterberry Auto-Feeder v0.2, After dismissing this message,``nleft click ONLY once on BEE SLOT
	IfMsgBox, Cancel
		ExitApp

	WinGetClientPos(x, y, w, h, ""ahk_id "" GetRobloxHWND())
	WinActivate, Roblox
	Gui, -Caption +E0x80000 +hwndhOverlay +AlwaysOnTop +ToolWindow -DPIScale
	Gui, Show, NA
	hbm := CreateDIBSection(w, h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 2)
	Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x60000000), -1, -1, w+1, h+1), Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(hOverlay, hdc, x, y, w, h)

	KeyWait, LButton, D ; Wait for the left mouse button to be pressed down.
	MouseGetPos, beeX, beeY
	Gdip_GraphicsClear(G), Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xd0000000), -1, -1, w+1, 38), Gdip_DeleteBrush(pBrush)
	Gdip_TextToGraphics(G, ""Mutating... Right Click or Shift to Stop!"", ""x0 y0 cffff5f1f Bold Center vCenter s24"", ""Tahoma"", w, 38)
	UpdateLayeredWindow(hOverlay, hdc, x, y, w, 38)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Hotkey, Shift, ExitFunc, UseErrorLevel On
	Hotkey, RButton, ExitFunc, UseErrorLevel On
	Hotkey, F11, ExitFunc, UseErrorLevel On
	Sleep, 250

	Loop
	{
		if ((pos := nm_InventorySearch(""bitterberry"", ""down"", , , 0, (A_Index = 1) ? 40 : 4)) = 0)
		{
			MsgBox, 0x40010, Bitterberry Auto-Feeder v0.2, You ran out of Bitterberries!
			break
		}
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, ""ahk_id "" GetRobloxHWND())
		MouseMove, windowX+pos[1], windowY+pos[2]
		SendInput {Click Down}
		Sleep, 100
		MouseMove, beeX, beeY
		Sleep, 100
		SendInput {Click Up}
		Loop, 10
		{
			Sleep, 100
			pBMScreen := Gdip_BitmapFromScreen(windowX+(51*windowWidth)//100-216 ""|"" windowY+(58*windowHeight)//100-59 ""|440|100"")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[""feed""], pos, , , , , 2, , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				Click, % windowX+(51*windowWidth)//100-216+SubStr(pos, 1, InStr(pos, "","")-1)+140 "" "" windowY+(58*windowHeight)//100-59+SubStr(pos, InStr(pos, "","")+1)+5 ; Click Number
				Sleep, 100
				Loop % StrLen(bitterberrynos)
				{
					SendEvent % ""{Text}"" SubStr(bitterberrynos, A_Index, 1)
					Sleep, 100
				}
				Click, % windowX+(51*windowWidth)//100-216+SubStr(pos, 1, InStr(pos, "","")-1) "" "" windowY+(58*windowHeight)//100-59+SubStr(pos, InStr(pos, "","")+1) ; Click Feed
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 10)
				continue 2
		}
		Sleep, 750

		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-295 ""|"" windowY+((4*windowHeight)//10 - 15) ""|150|50"")
		if (Gdip_ImageSearch(pBMScreen, bitmaps[""greensuccess""], , , , , , 20) = 1) {
			MsgBox, 0x40024, Bitterberry Auto-Feeder v0.2, SUCCESS!!!!``nKeep this?
			IfMsgBox Yes
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				WinActivate, Roblox
				Click, % windowX + (windowWidth//2 - 132) "" "" windowY + ((4*windowHeight)//10 - 150) ; Close Bee
			}
		}
		Gdip_DisposeImage(pBMScreen)
	}
	ExitApp

	ExitFunc()
	{
		global
		Gui, Destroy
		Gdip_Shutdown(pToken)
		ExitApp
	}
	)"

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path64 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_BasicEggHatcher()
{
	if !GetRobloxHWND()
	{
		msgbox, 0x40030, Basic Bee Replacement Program, You must have Bee Swarm Simulator open to use this!, 20
		return
	}

	script := "
	(Join`r`n C
	#NoEnv
	#NoTrayIcon
	#SingleInstance Force
	#Requires AutoHotkey v1.1.36.01+
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	#Include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
	#Include %A_ScriptDir%\submacros\shared\nm_misc.ahk

	CoordMode, Mouse, Screen
	SetBatchLines -1
	OnExit(""ExitFunc"")
	pToken := Gdip_Startup()

	bitmaps := {}
	bitmaps[""itemmenu""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII="")
	bitmaps[""questlog""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg=="")
	bitmaps[""beemenu""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC"")
	bitmaps[""item""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII="")
	bitmaps[""basicegg""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAGIAAAAaCAMAAAB7CnmQAAABuVBMVEUbKjUdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0lND4nNUAoNkApOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgxP0kyQEkzQUo0QUs1Qkw2RE03RU44RU85Rk86SFE7SVI8SVNATVZEUVlGUltGU1xKVl9LV19MWWFPW2NQXGRRXWVVYWhWYWlXYmpXY2tdaXBeanFga3JhbHNibXRibnVjbnVkb3ZmcXhncnhoc3ppdHtqdXtsdn1td35ueX9veoBweoFzfYN0foR1f4V2gIZ3gYd4god6hIp+h42Ci5GFjpSGj5SIkZaJkpePl5yQmJ2VnaGWnqKZoaWaoqabo6ecpKidpamfp6qjq66mrbCnr7Kor7Ots7avtrmwt7m1vL63vcC+xMa/xcfAxsjBx8nCyMnDyMrEyszFy8zGzM3HzM7Izc/Jzs/Jz9DN0tPQ1dbR1tfS19jT2NjU2NnV2drV2tvW29zY3N3Z3d7a39/c4OHe4uLg5OTg5eXi5ubj5+fl6ejm6enm6uro7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/Y9aLFlAAACKklEQVR42u3Ta1MSUQDG8cfiVmZBUoqmBhVkRtj9JkmoSRGmlbZadiG6mXnpSmG6QWlqCDyfuNlYTu3sMsNM6zufV/9X5zc7Zw+46cMWUTvhg7KdoenNJgDbU1bZa9fxEvXzQt2zWgn4WGVTzs7/JSIkc+eBNGubIKJq1UZwHkiRfHm5xdI8mOW/yySTeTOIWeANmd4GZQdzJJOd9Q1d4wVyBJBJyv0t1v3nZoyJwu1DDncEkDStIZaCsK6QHDgQH+sGhsgndVAWrhDf2qHM8cKQCKM8SbSGUDdIkqt5stiGIHkS/uzHIW+6QtxA3f21lNOaoPa6ZaWfA+GFhR5AEm1A7HhLkp/ONmxvqkeAjMDzuMgSK8Q+nCY5vUQjIgbnL/IrIIk2IOCWyczecvvJd7sAT2K5QqwAd6pf9wl0Uz1WbS0RJbkcA0bIa2ifXf/QoRD8fNEKtM6pRBp4UJ3wo1c9VrSOYN6BAfIwxkge+UOQi3EbAjV9RRdOqceK1hPrdsSVw28JYoPkKPBTcxevFg2JCJqK6rFq64nvUWCK7IcrlbtrU4gJz/gPuQeODe0fZUkYEY+A69nMBUASbXTdvSS/iOuWG8t1U7yLNt27UBciS0G1JdE6wuIdLlAxrrjtR6+GYqQc99ldxyb593X3NVvdZ2ZoRHA13mFtvARIogVh6uaBh5o2nxgG5jRtOvF+N1oLmjabmNwDjGradOIe0Kdp84m1wERJ378B3+p4iisaatgAAAAASUVORK5CYII="")
	bitmaps[""royaljelly""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAGwAAAAcCAMAAACzmqo+AAAB+FBMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8nNUAoNkApN0EpOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgyQEkzQUo0QUs1Qkw1Q0w3RU44RU85Rk86SFE7SVI8SVM+S1Q/TFVDUFlEUVlFUVpGUltGU1xIVV1KVl9LV19MWWFPW2NWYWlXYmpXY2tbZm5cZ29daG9daXBga3JibXRibnVlcHdpdHttd35weoFxe4FyfIJzfYN0foR1f4V2gIZ3gYd4god5goh6hIp7hYt8hot+h41/iI6Aio+BipCCi5GFjpSFjpOGj5SHkJWIkZaJkpeKk5iKk5eLlJmMlZqNlpqPl5yQmJ2QmZ2Rmp6Sm5+UnKCVnaGaoqabo6ecpKigp6ujq66kq6+lrLCor7Ots7avtrmwt7mxt7qyuLu1vL62vL+3vcC5wMK6wMO8wsS9w8W/xcfAxsjDyMrDycvEyszGzM3HzM7Jzs/K0NHL0NLN0tPO09TP1NXQ1dbR1tfS19jT2NjV2drV2tvW29zX3NzY3N3a39/b4ODc4OHd4eLe4uLf4+Pg5OTg5eXi5ubj5+fk6Ojm6enm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9fTy9fTz9vX09/a7z3nGAAACf0lEQVR42u3W+VOMcQDH8Y9KVkUUkXQqJEqH0OWokHLlzplyRSgJFZWjnEmOtqhWx77/TbNPzHeenbZtZk3GjPcPO7O73/m8dvZ5fnjEPKb/2L+IpcqTI+sBc6s9d2RuR8xBb0wKaWEuXZe+Y69Beul9ZPrVJ6Z1bvBf7eyYOVI7M7YHGMiROucLo0tqwmdtRfEL4/YN/insmfQC+FyW4EiqGIRT1nvr81LeBk//0c5ZMFd1UujaiiEbZlsx2NBOpQMD8fKU8pX3QaoEqJSeQlni0frt0knf2FSOPKW7bJhtReYGWfwEKFdks6txsY5AtmImYDJWGcDYBEwlKds3Vqfo5pGWKF2yYbYVgwV1A1NLdBo4qFVwU7oF96Q64HXB8pA1S5XpG9ugGqBamXbMrJhr1ig1Ax+kx1jfDeNapm1QqLBh6IuR1Raf2NgCTRdhx8yKwcajVAR0Sr1Ah/QK9iq43+lQMVCu5K4fvSm+sZ4B/W7ChpkVg7Fb4SPwUWoDmqxz7VJNvfQI2KR6IMMbw9kHcE3qH5XOznjrmxWDtUo3wB3965rFA6xXSqbSsJhzM2CTu8K2TgIlWuEmWXnAuB2zrRjMHa9s4LAi7rpuO6Z/5UVJugxQqpUPnVcWeWHsl3b0OOtCVAXHteDqWGtsXpsXZlYMxiEF9YMzTZ7SRwA+hUihXwDezXyDuApktXkURjfKU+Rzb8ysGKxbugAMVyU7Uo+NYpUvFYKlFa92ZJXkHrBjuBuyYxelnrCOD1cmhMYVv8EbMytits5L9wkks+IfS1eimwAyK/6xDukMgWRW/GMlCu4ngMyKf+xbuPIJJLPiH6uT7hBAZuVvPMr9BDBOM9MqS26gAAAAAElFTkSuQmCC"")
	bitmaps[""giftedstar""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAgMAAAC5YVYYAAAACVBMVEX9rDT+rDT/rDOj6H2ZAAAAFElEQVR42mNYtYoBgVYyrFoBYQMAf4AKnlh184sAAAAASUVORK5CYII="")
	bitmaps[""yes""] := Gdip_BitmapFromBase64(""iVBORw0KGgoAAAANSUhEUgAAAB0AAAAPAQMAAAAiQ1bcAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFZJREFUeAEBSwC0/wDDAAfAAEIACGAAfgAQMAA8ABAQABgAIAgAGAAgCAAYACAYABgAP/gAGAAgAAAYAAAAABgAIAAAGAAwAAAYADAAABgAGDAAGAAP4FGfB+0KKAbEAAAAAElFTkSuQmCC"")

	MsgBox, 0x40001, Basic Bee Replacement Program, WELCOME TO THE BASIC BEE REPLACEMENT PROGRAM!!!!!``nMade by anniespony#8135``n``nMake sure BEE SLOT TO CHANGE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE AUTO-JELLY IS DISABLED!!
	IfMsgBox, Cancel
		ExitApp

	MsgBox, 0x40001, Basic Bee Replacement Program, After dismissing this message,``nleft click ONLY once on BEE SLOT
	IfMsgBox, Cancel
		ExitApp

	WinActivate, Roblox
	WinGetClientPos(x, y, w, h, ""ahk_id "" GetRobloxHWND())
	Gui, -Caption +E0x80000 +hwndhOverlay +AlwaysOnTop +ToolWindow -DPIScale
	Gui, Show, NA
	hbm := CreateDIBSection(w, h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 2)
	Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x60000000), -1, -1, w+1, h+1), Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(hOverlay, hdc, x, y, w, h)

	KeyWait, LButton, D ; Wait for the left mouse button to be pressed down.
	MouseGetPos, beeX, beeY
	Gdip_GraphicsClear(G), Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xd0000000), -1, -1, w+1, 38), Gdip_DeleteBrush(pBrush)
	Gdip_TextToGraphics(G, ""Hatching... Right Click or Shift to Stop!"", ""x0 y0 cffff5f1f Bold Center vCenter s24"", ""Tahoma"", w, 38)
	UpdateLayeredWindow(hOverlay, hdc, x, y, w, 38)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Hotkey, Shift, ExitFunc, UseErrorLevel On
	Hotkey, RButton, ExitFunc, UseErrorLevel On
	Hotkey, F11, ExitFunc, UseErrorLevel On
	Sleep, 250

	pBMC := Gdip_CreateBitmap(2,2), G := Gdip_GraphicsFromImage(pBMC), Gdip_GraphicsClear(G,0xffae792f), Gdip_DeleteGraphics(G) ; Common
	pBMM := Gdip_CreateBitmap(2,2), G := Gdip_GraphicsFromImage(pBMM), Gdip_GraphicsClear(G,0xffbda4ff), Gdip_DeleteGraphics(G) ; Mythic

	rj := 0
	Loop
	{
		if ((pos := (A_Index = 1) ? nm_InventorySearch(""basicegg"", ""down"", , , 0, 70) : (rj = 1) ? nm_InventorySearch(""royaljelly"", ""down"", , , 0, 7) : nm_InventorySearch(""basicegg"", ""up"", , , 0, 7)) = 0)
		{
			MsgBox, 0x40010, Basic Bee Replacement Program, % ""You ran out of "" ((rj = 1) ? ""Royal Jellies!"" : ""Basic Eggs!"")
			break
		}
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, ""ahk_id "" GetRobloxHWND())
		MouseMove, windowX+pos[1], windowY+pos[2]
		SendInput {Click Down}
		Sleep, 100
		MouseMove, beeX, beeY
		Sleep, 100
		SendInput {Click Up}
		Loop, 10
		{
			Sleep, 100
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 ""|"" windowY+((6*windowHeight)//10-60) ""|500|150"")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[""yes""], pos, , , , , 2, , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				Click % windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, "","")-1) "" "" windowY+((6*windowHeight)//10-60)+SubStr(pos, InStr(pos, "","")+1)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 10)
			{
				rj := 1
				continue 2
			}
		}
		Sleep, 750

		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-155 ""|"" windowY+((4*windowHeight)//10 - 135) ""|310|205""), rj := 0
		if (Gdip_ImageSearch(pBMScreen, pBMM, , 50, 165, 260, 205, 2, , , 5) = 5) { ; Mythic Hatched
			MsgBox, 0x40024, Basic Bee Replacement Program, MYTHIC!!!!``nKeep this?
			IfMsgBox Yes
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, pBMC, , 50, 165, 260, 205, 2, , , 5) = 5) {
			rj := 1
			if (Gdip_ImageSearch(pBMScreen, bitmaps[""giftedstar""], , 0, 20, 130, 50, 5) = 1) { ; If gifted is hatched, stop
				MsgBox, 0x40020, Basic Bee Replacement Program, SUCCESS!!!!
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, bitmaps[""giftedstar""], , 0, 20, 130, 50, 5) = 1) { ; Non-Basic Gifted Hatched
			MsgBox, 0x40024, Basic Bee Replacement Program, GIFTED!!!!``nKeep this?
			IfMsgBox Yes
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		Gdip_DisposeImage(pBMScreen)
	}
	ExitApp

	ExitFunc()
	{
		global
		Gdip_DisposeImage(pBMC), Gdip_DisposeImage(pBMM)
		Gui, Destroy
		Gdip_Shutdown(pToken)
		ExitApp
	}
	)"

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path64 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_GenerateBeeList()
{
	global bitmaps
	static bees := ["basic","bomber","brave","bumble","cool","hasty","looker","rad","rascal","stubborn","bubble","bucko","commander","demo","exhausted","fire","frosty","honey","rage","riley","shocked","baby","carpenter","demon","diamond","lion","music","ninja","shy","buoyant","fuzzy","precise","spicy","tadpole","vector","bear","cobalt","crimson","digital","festive","gummy","photon","puppy","tabby","vicious","windy"]

	if !GetRobloxHWND()
	{
		msgbox, 0x40030, Export Bee List, You must have Bee Swarm Simulator open to use this!, 20
		return
	}

	; initialise object to fill
	bee_data := {}

	; open menu
	WinActivate, Roblox
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	nm_OpenMenu()
	nm_OpenMenu("beemenu")
	MouseMove, windowX+30, windowY+200, 5

	; obtain lower bound of search
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-150)
	lb := 450
	for k,v in {"white":0xffc4c8cb,"red":0xffc7403c,"blue":0xff4d87ca}
	{
		pBM%k% := Gdip_CreateBitmap(6, 2), G := Gdip_GraphicsFromImage(pBM%k%), Gdip_GraphicsClear(G, v), Gdip_DeleteGraphics(G)
		if (Gdip_ImageSearch(pBMScreen, pBM%k%, lpos, , , 10, , 2, , 2) = 1)
		{
			l := SubStr(lpos, InStr(lpos, ",")+1)
			lb := Max(l+2, lb)
		}
	}
	Gdip_DisposeImage(pBMScreen)

	; loop through bees and fill object
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" lb)
	ub := 0
	for k,v in bees
	{
		Loop, 3
		{
			; find upper coordinate of current bee
			uc := lb
			for i,j in ["white","red","blue"]
			{
				if (Gdip_ImageSearch(pBMScreen, pBM%j%, upos, , ub, 10, , 2) = 1)
				{
					u := SubStr(upos, InStr(upos, ",")+1)
					uc := Min(u, uc)
				}
			}

			; if bee is too low, scroll up, else, set upper bound for next
			if (lb-uc < 120)
			{
				Loop % (lb//150 - 2)
				{
					MouseMove, windowX+30, windowY+200, 5
					Sleep, 50
					SendInput {WheelDown}
				}

				; obtain reference image for scroll distance
				DllCall("GetSystemTimeAsFileTime","Int64P",s)
				pBM := Gdip_CloneBitmapArea(pBMScreen, 6, Gdip_GetImageHeight(pBMScreen)-206, 294, 200)
				Gdip_LockBits(pBM, 0, 0, 294, 200, stride, scan0, bmData)
				Loop, 294
				{
					x := A_Index - 1
					if ((x+6 < windowWidth//2 - 261) || ((x+6 > windowWidth//2 - 190) && (x+6 < windowWidth//2 - 186)) || ((x+6 > windowWidth//2 - 115) && (x+6 < windowWidth//2 - 111)))
					{
						Loop, 200
						{
							y := A_Index - 1
							switch % Gdip_GetLockBitPixel(scan0, x, y, stride)
							{
								case 0xff4d87ca, 0xffc4c8cb, 0xffc7403c, 0xff74a9e6, 0xffe1e4e7, 0xffe46764:
								default:
								Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
							}
						}
					}
					else
					{
						Loop, 200
						{
							y := A_Index - 1
							Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
						}
					}
				}
				Gdip_UnlockBits(pBM, bmData)
				DllCall("GetSystemTimeAsFileTime","Int64P",f)

				; wait for scroll end then measure distance
				Sleep, 500 - (f-s)//10000
				Gdip_DisposeImage(pBMScreen)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" lb)
				ub := Max(0, ub - (((Gdip_ImageSearch(pBMScreen, pBM, pos) = 1)) ? Min(lb - 206 - SubStr(pos, InStr(pos, ",")+1), 150 * (lb//150 - 2)) : (150 * (lb//150 - 2))))
				Gdip_DisposeImage(pBM)
			}
			else
			{
				ub := uc + 120
				break
			}
		}

		; detect number of current bee
		digits := {}
		Loop, 10
		{
			n := 10-A_Index
			Gdip_ImageSearch(pBMScreen, bitmaps["beedigit" n], pos, 0, uc+100, 100, uc+120, , , 5, 2, , "`n")
			Loop, Parse, pos, `n
				if (A_Index & 1)
					digits[A_LoopField] := n
		}
		num := (digits.Length() > 0) ? "" : 0
		for x,y in digits
			num .= y


		; detect if current bee has gifted status
		gifted := ((num > 0) && (Gdip_ImageSearch(pBMScreen, bitmaps["gifted"], , 260, uc, 306, uc+40, 2) = 1))

		bee_data[v] := {"amount":num, "gifted":gifted}
	}

	; stringify the object into JSON format for export
	str := "{""type"":""natro"","
	for k,v in bee_data
		str .= (v["amount"] > 0) ? ("""" k """:{""amount"":" v["amount"] ",""gifted"":" (v["gifted"] ? "true" : "false") "},") : ""
	str := RTrim(str, ",") "}"

	clipboard := str
	msgbox, 0x40040, Export Bee List, Copied Bee List to clipboard!`nPaste the output into the '/hive import' command of Hive Builder to view your hive!., 20
}
nm_gather(pattern, index, patternsize:="M", reps:=1, facingcorner:=0){
	global
	static patterns := {}
	local identifier, Prev_DetectHiddenWindows

	if(!DisableToolUse)
		click, down

	if(pattern="stationary"){
		sleep 10000
		click, up
		return
	}

	;set size ~ replaced if-else with ternary, slightly speeds up delay between cycles
	size := (patternsize="XS") ? 0.25
		: (patternsize="S") ? 0.5
		: (patternsize="L") ? 1.5
		: (patternsize="XL") ? 2
		: 1 ; medium (default)

	; obtain all patterns, which are stored as code in settings\imported\patterns.ahk
	; Walk(" n * size ")" / "Walk(n)" - new general form, can alter to include variables
	; HyperSleep(" 2000/9*MoveSpeedFactor*walkparam ") - old form derived from new form (see RegExMatch below)
	; ask me if you need any help with translating old form to new form or vice versa
	; almost all of this function has been revamped to improve gathering timing inaccuracies, feel free to ask about anything

	if (index = 1)
	{
		patterns["auryn"] := "
		(LTrim Join`r`n
		;Auryn Gathering Path
		AurynDelay:=175
		loop " reps " {
			;infinity
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*3*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" TCLRKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*3*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" AFCLRKey " up}
			;big circle
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCLRKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCLRKey " up}
			;FLIP!!
			;move to other side (half circle)
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCLRKey " up}
			send {" AFCFBKey " up}
			;pause here
			HyperSleep(50)
			;reverse infinity
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*3*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" AFCLRKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*1.4)
			send {" TCLRKey " up}
			;big circle
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCLRKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" TCLRKey " up}
			;FLIP!!
			;move to other side (half circle)
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" AFCLRKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCFBKey " up}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2)
			send {" TCFBKey " down}
			Walk(AurynDelay*9/2000*" size "*A_Index*1.1*2*1.4)
			send {" AFCLRKey " up}
			send {" TCFBKey " up}
		}
		)"

		patterns["CornerXsnake"] := "
		(LTrim Join`r`n
			send {" TCLRKey " down}
			Walk(" 4 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCLRKey " down}{" AFCFBKey " down}
			Walk(" Sqrt( ( ( 8 * size ) ** 2 ) + ( ( 8 * size ) ** 2 )) ")
			send {" AFCLRKey " up}{" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 6.7 * size + 10 ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 6 + reps ")
			send {" TCFBKey " down}
			Walk(3)
			send {" AFCLRKey " up}{" TCFBKey " up}{" TCLRKey " down}
			Walk(" 2 + reps ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(5)
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 3 * size ")
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}{" AFCLRKey " down}
			Walk(" Sqrt( ( ( 4 * size ) ** 2 ) + ( ( 4 * size ) ** 2 )) ")
			send {" TCFBKey " up}{" AFCLRKey " up}
		)"

		patterns["diamonds"] := "
		(LTrim Join`r`n
		loop " reps " {
			send {" TCFBKey " down}{" TCLRKey " down}
			Walk(" 5 * size " + A_Index)
			send {" TCLRKey " up}{" AFCLRKey " down}
			Walk(" 5 * size " + A_Index)
			send {" TCFBKey " up}{" AFCFBKey " down}
			Walk(" 5 * size " + A_Index)
			send {" AFCLRKey " up}{" TCLRKey " down}
			Walk(" 5 * size " + A_Index)
			send {" TCLRKey " up}{" AFCFBKey " up}
		}
		)"

		patterns["e_lol"] := "
		(LTrim Join`r`n
		spacingDelay:=274 ;183
		send {" TCLRKey " down}
		Walk(spacingDelay*9/2000*(" reps "*2+1))
		send {" TCLRKey " up}{" AFCFBKey " down}
		Walk(" 5 * size ")
		send {" AFCFBKey " up}
		loop " reps " {
			send {" AFCLRKey " down}
			Walk(spacingDelay*9/2000)
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 5 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(spacingDelay*9/2000)
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk((1094+25*" facingcorner ")*9/2000*" size ")
			send {" AFCFBKey " up}
		}
		send {" TCLRKey " down}
		Walk(spacingDelay*9/2000*(" reps "*2+0.5))
		send {" TCLRKey " up}{" TCFBKey " down}
		Walk(" 5 * size ")
		send {" TCFBKey " up}
		loop " reps " {
			send {" AFCLRKey " down}
			Walk(spacingDelay*9/2000)
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk((1094+25*" facingcorner ")*9/2000*" size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(spacingDelay*9/2000*1.5)
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 5 * size ")
			send {" TCFBKey " up}
		}
		)"

		patterns["lines"] := "
		(LTrim Join`r`n
		loop " reps " {
			send {" TCFBKey " down}
			Walk(" 11 * size ")
			send {" TCFBKey " up}{" TCLRKey " down}
			Walk(" 1 ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 11 * size ")
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 1 ")
			send {" TCLRKey " up}
		}
		;away from center
		loop " reps " {
			send {" TCFBKey " down}
			Walk(" 11 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 1 ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 11 * size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 1 ")
			send {" AFCLRKey " up}
		}
		)"

		patterns["Slimline"] := "
		(LTrim Join`r`n
			send {" TCLRKey " down}
			Walk(" ( 4 * size ) + ( reps * 0.1 ) - 0.1 ")
			send {" TCLRKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" TCLRKey " down}
			Walk(" 4 * size ")
			send {" TCLRKey " up}
		)"

		patterns["snake"] := "
		(LTrim Join`r`n
		loop " reps " {
			send {" TCLRKey " down}
			Walk(" 11 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}
			Walk(" 1 ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 11 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 1 ")
			send {" TCFBKey " up}
		}
		;away from center
		loop " reps " {
			send {" TCLRKey " down}
			Walk(" 11 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 1 ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 11 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 1 ")
			send {" AFCFBKey " up}
		}
		)"

		patterns["squares"] := "
		(LTrim Join`r`n
		loop " reps " {
			send {" TCFBKey " down}
			Walk(" 5 * size " + A_Index)
			send {" TCFBKey " up}{" TCLRKey " down}
			Walk(" 5 * size " + A_Index)
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 5 * size " + A_Index)
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 5 * size " + A_Index)
			send {" AFCLRKey " up}
		}
		)"

		patterns["SuperCat"] := " 
		(LTrim Join`r`n
		loop " reps " {
			send {" TCLRKey " down} ; Left 1.5
			Walk(" 1.25 * size ")
			send {" TCLRKey " up}{" TCFBKey " down} ;Left forward 78
			Walk(" 7 * size ", 10)
			send {" TCFBKey " up}{" TCLRKey " down} ; Forward Left 1.5
			Walk(" 1.25 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down} ;Left Back 6.66
			Walk(" 6.66 * size ", 10)
			send {" AFCFBKey " up}{" TCLRKey " down} ;Back Left 1.5
			Walk(" 1.25 * size ")
			send {" TCLRKey " up}{" TCFBKey " down} ;Left forward 78
			Walk(" 7 * size ", 10)
			send {" TCFBKey " up}{" TCLRKey " down} ; Forward Left 1.5
			Walk(" 2 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down} ;Left Back 6.66
			Walk(" 6.5 * size ", 10)
			send {" AFCFBKey " up}
			}
		loop " reps " {
			send {" AFCLRKey " down} ; Right 1.5
			Walk(" 1.25 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down} ; Right Forward 7
			Walk(" 7 * size ", 10)
			send {" TCFBKey " up}{" AFCLRKey " down} ; Forward Right 1.5
			Walk(" 1 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down} ;Right Back 6.66
			Walk(" 6.66 * size ", 10)
			send {" AFCFBKey " up}{" AFCLRKey " down} ;Back Right 1.5
			Walk(" 1.25 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down} ; Right Forward 6.66
			Walk(" 7 * size ", 10)
			send {" TCFBKey " up}{" AFCLRKey " down} ; Forward Right 1.5
			Walk(" 1.25 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down} ;Right Back 6.66
			Walk(" 6.5 * size ", 10)
			send {" AFCFBKey " up}
			}
		)"

		patterns["Xsnake"] := "
		(LTrim Join`r`n
		loop " reps " {
			send {" TCLRKey " down}
			Walk(" 4 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCLRKey " down}{" AFCFBKey " down}
			Walk(" Sqrt( ( ( 8 * size ) ** 2 ) + ( ( 8 * size ) ** 2 )) ")
			send {" AFCLRKey " up}{" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}
			Walk(" 2 * size ")
			send {" TCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" TCFBKey " down}
			Walk(" 6.7 * size ")
			send {" TCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" AFCFBKey " down}
			Walk(" 2 * size ")
			send {" AFCFBKey " up}{" AFCLRKey " down}
			Walk(" 8 * size ")
			send {" AFCLRKey " up}{" AFCFBKey " down}
			Walk(" 3 * size ")
			send {" AFCFBKey " up}{" TCLRKey " down}
			Walk(" 8 * size ")
			send {" TCLRKey " up}{" TCFBKey " down}{" AFCLRKey " down}
			Walk(" Sqrt( ( ( 4 * size ) ** 2 ) + ( ( 4 * size ) ** 2 )) ")
			send {" TCFBKey " up}{" AFCLRKey " up}
		}
		)"

		#Include *i %A_ScriptDir%\settings\imported\patterns.ahk ; override with any custom paths
	}

	identifier := pattern . patternsize . reps . TCFBKey . AFCFBKey . TCLRKey . AFCLRKey
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	if ((index = 1) || (currentWalk["name"] != identifier) || !WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"]))
		nm_createWalk(patterns[pattern], identifier) ; create / replace cycled walk script for this gather session
	else
		Send {F13} ; start new cycle
	DetectHiddenWindows, %Prev_DetectHiddenWindows%

	KeyWait, F14, D T5 L ; wait for pattern start
	if ErrorLevel
		nm_endWalk()
	KeyWait, F14, T180 L ; wait for pattern finish
	if ErrorLevel
		nm_endWalk()

	click, up
}
nm_Walk(tiles, MoveKey1, MoveKey2:=0){ ; this function returns a string of AHK code which holds MoveKey1 (and optionally MoveKey2) down for 'tiles' tiles. NOTE: this only helps creating a movement, put this through nm_createWalk() to execute
	return "
	(LTrim Join`r`n
	Send {" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "") "
	Walk(" tiles ")
	Send {" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "") "
	)"
}
nm_createWalk(movement, name:="") ; this function generates the 'walk' code and runs it for a given 'movement' (AHK code string), using movespeed correction if 'NewWalk' is enabled and legacy movement otherwise
{
	global newWalk, MoveSpeedNum, currentWalk, LeftKey, RightKey, FwdKey, BackKey, SC_Space, SC_E

	; F13 is used by 'natro_macro.ahk' to tell 'walk' to complete a cycle
	; F14 is held down by 'walk' to indicate that the cycle is in progress, then released when the cycle is finished
	; F16 can be used by any script to pause / unpause the walk script, when unpaused it will resume from where it left off

	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On ; allow communication with walk script

	if WinExist("ahk_pid " currentWalk["pid"] " ahk_class AutoHotkey")
		nm_endWalk()

	if NewWalk
	{
		; #Include Walk.ahk performs most of the initialisation, i.e. creating bitmaps and storing the necessary functions
		; MoveSpeedNum must contain the exact in-game movespeed without buffs so the script can calculate the true base movespeed

		script := "
		(LTrim Join`r`n
		#NoEnv
		#SingleInstance, Off
		SendMode Input
		SetBatchLines -1
		Process, Priority, , AboveNormal
		#KeyHistory 0
		ListLines, Off
		OnExit(""ExitFunc"")

		#Include %A_ScriptDir%\lib
		#Include Gdip_All.ahk
		#Include Gdip_ImageSearch.ahk
		#Include HyperSleep.ahk

		#Include Walk.ahk

		movespeed := " MoveSpeedNum "
		hasty_guard := (Mod(movespeed*10, 11) = 0) ? 1 : 0
		base_movespeed := movespeed / (hasty_guard ? 1.1 : 1)
		gifted_hasty := ((Mod(base_movespeed*10, 12) = 0) && base_movespeed != 18 && base_movespeed != 24 && base_movespeed != 30) ? 1 : 0
		base_movespeed /= (gifted_hasty ? 1.2 : 1)

		Gosub, F13
		return

		F13::
		Send {F14 down}
		" movement "
		Send {F14 up}
		return

		F16::
		if A_IsPaused
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, """ SC_Space """, ""LButton"", ""RButton"", """ SC_E """]
				if %v%state
					Send % ""{"" v "" down}""
		}
		else
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, """ SC_Space """, ""LButton"", ""RButton"", """ SC_E """]
			{
				%v%state := GetKeyState(v)
				Send % ""{"" v "" up}""
			}
		}
		Pause, Toggle, 1
		return

		ExitFunc()
		{
			global pToken
			Send {" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}{" SC_Space " up}{F14 up}{" SC_E " up}
			Gdip_Shutdown(pToken)
		}
		)" ; this is just ahk code, it will be executed as a new script
	}
	else
	{ ;~~ ;line 14156 regex change (https://discord.com/channels/1012610056921038868/1021295942965673995/1138315469158371410)
		script := "
		(LTrim Join`r`n
		#NoEnv
		#SingleInstance, Off
		SendMode Input
		SetBatchLines -1
		Process, Priority, , AboveNormal
		#KeyHistory 0
		ListLines, Off
		OnExit(""ExitFunc"")

		#Include %A_ScriptDir%\lib
		#Include Gdip_All.ahk
		#Include Gdip_ImageSearch.ahk
		#Include HyperSleep.ahk

		Gosub, F13
		return

		F13::
		Send {F14 down}
		" RegExReplace(movement, "im)Walk\((?<param>.+?)(?:\,|\)(?=[^()]*(?:\(|$)))(?:.*\))?", "HyperSleep(2000/9*" round(18/MoveSpeedNum, 2) "*(${param}))") "
		Send {F14 up}
		return

		F16::
		if A_IsPaused
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, """ SC_Space """, ""LButton"", ""RButton"", """ SC_E """]
				if %v%state
					Send % ""{"" v "" down}""
		}
		else
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, """ SC_Space """, ""LButton"", ""RButton"", """ SC_E """]
			{
				%v%state := GetKeyState(v)
				Send % ""{"" v "" up}""
			}
		}
		Pause, Toggle, 1
		return

		ExitFunc()
		{
			Send {" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}{" SC_Space " up}{F14 up}{" SC_E " up}
		}
		)"
	}

	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(exe_path64 " /script /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()

	WinWait, % "ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2
	currentWalk.Delete("pid"),  currentWalk.Delete("name"), currentWalk["pid"] := exec.ProcessID, currentWalk["name"] := name
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	return !ErrorLevel ; return 1 if successful, 0 otherwise
}
nm_endWalk() ; this function ends the walk script
{
	global currentWalk
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows On
	WinClose % "ahk_class AutoHotkey ahk_pid " currentWalk["pid"]
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	currentWalk.Delete("pid"),  currentWalk.Delete("name")
	; if issues, we can check if closed, else kill and force keys up
}
nm_convert(){
	global KeyDelay, RotRight, ZoomOut, SC_E, AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey, LastEnzymes, ConvertStartTime, TotalConvertTime, SessionConvertTime, BackpackPercent, BackpackPercentFiltered, PFieldBoosted, GatherFieldBoosted, GameFrozenCounter, CurrentAction, PreviousAction, PFieldBoosted, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, GlitterKey, LastConvertBalloon, ConvertBalloon, ConvertMins, HiveBees,state, ConvertDelay, bitmaps

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
	if ((HiveConfirmed = 0) || (state = "Converting") || (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
		sendinput {%SC_E% down}
		Sleep, 100
		sendinput {%SC_E% up}
	}
	Gdip_DisposeImage(pBMScreen)
	ConvertStartTime:=nowUnix()
	inactiveHoney:=0
	;empty pack
	if (BackpackPercentFiltered > 0) {
		nm_setStatus("Converting", "Backpack")
		while (((BackpackConvertTime := nowUnix()-ConvertStartTime)<300) && (BackpackPercentFiltered>0)) { ;5 mins
			sleep, 1000
			nm_AutoFieldBoost(currentField)
			if(AFBuseGlitter || AFBuseBooster) {
				nm_setStatus("Interupted", "AFB")
				return
			}
			if (disconnectcheck()) {
				return
			}
			if (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>780 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
				nm_setStatus("Interupted", "Field Boosted")
				return
			}
			inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
			if (BackpackConvertTime>60 && inactiveHoney>30) {
				nm_setStatus("Interupted", "Inactive Honey")
				GameFrozenCounter:=GameFrozenCounter+1
				return
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
		}
		VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",BackpackConvertTime*10000000,"wstr","mm:ss","str",duration,"int",256)
		nm_setStatus("Converting", "Backpack Emptied`nTime: " duration)
	}
	;empty balloon
	if((ConvertBalloon="always") || (ConvertBalloon="Every" && (nowUnix() - LastConvertBalloon)>(ConvertMins*60))) {
		;balloon check
		strikes:=0
		while ((strikes <= 5) && (A_Index <= 50)) {
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) != 1)
				strikes++
			Gdip_DisposeImage(pBMScreen)
			Sleep, 100
		}
		if (strikes <= 5) {
			BalloonStartTime:=nowUnix()
			inactiveHoney:=0
			ballooncomplete:=0
			nm_setStatus("Converting", "Balloon")
			while((BalloonConvertTime := nowUnix()-BalloonStartTime)<600) { ;10 mins
				nm_AutoFieldBoost(currentField)
				if(AFBuseGlitter || AFBuseBooster) {
					nm_setStatus("Interupted", "AFB")
					return
				}
				inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
				if(((EnzymesKey!="none") && (!PFieldBoosted || (PFieldBoosted && GatherFieldBoosted))) && (nowUnix()-LastEnzymes)>600 && (inactiveHoney = 0)) {
					send {%EnzymesKey%}
					LastEnzymes:=nowUnix()
					IniWrite, %LastEnzymes%, settings\nm_config.ini, Boost, LastEnzymes
				}
				if (BalloonConvertTime>60 && inactiveHoney>30) {
					nm_setStatus("Interupted", "Inactive Honey")
					GameFrozenCounter:=GameFrozenCounter+1
					return
				}
				if (disconnectcheck()) {
					return
				}
				if (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>780 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
					nm_setStatus("Interupted", "Field Boosted")
					return
				}
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				if (Mod(A_Index, 30) = 0) {
					MouseMove, windowX+windowWidth-30, windowY+16
					click
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
					sendinput {%SC_E% down}
					Sleep, 100
					sendinput {%SC_E% up}
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
					Gdip_DisposeImage(pBMScreen)
					ballooncomplete:=1
					break
				}
				Gdip_DisposeImage(pBMScreen)
				sleep, 1000
			}
			if(ballooncomplete){
				VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",BalloonConvertTime*10000000,"wstr","mm:ss","str",duration,"int",256)
				nm_setStatus("Converting", "Balloon Refreshed`nTime: " duration)
				LastConvertBalloon:=nowUnix()
				IniWrite, %LastConvertBalloon%, settings\nm_config.ini, Settings, LastConvertBalloon
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("background.ahk ahk_class AutoHotkey"){
					PostMessage, 0x5554, 7, nowUnix()
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
			}
		}
	}
	TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
	SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
	ConvertStartTime:=0

	;hive wait
	;Sleep, 500+((5-Min(HiveBees, 50)/10)**0.5)*10000
	Sleep, 500+(ConvertDelay ? ConvertDelay : 0)*1000
}
nm_setSprinkler(field, loc, dist){
	global FwdKey, LeftKey, BackKey, RightKey, SC_1, SC_Space, KeyDelay, SprinklerType, MoveSpeedNum

	if (SprinklerType = "None")
		return

	;field dimensions
	switch field
	{
		case "sunflower":
		flen:=1250*dist/10
		fwid:=2000*dist/10

		case "dandelion":
		flen:=2500*dist/10
		fwid:=1000*dist/10

		case "mushroom":
		flen:=1250*dist/10
		fwid:=1750*dist/10

		case "blue flower":
		flen:=2750*dist/10
		fwid:=750*dist/10

		case "clover":
		flen:=2000*dist/10
		fwid:=1500*dist/10

		case "spider":
		flen:=2000*dist/10
		fwid:=2000*dist/10

		case "strawberry":
		flen:=1500*dist/10
		fwid:=2000*dist/10

		case "bamboo":
		flen:=3000*dist/10
		fwid:=1250*dist/10

		case "pineapple":
		flen:=1750*dist/10
		fwid:=3000*dist/10

		case "stump":
		flen:=1500*dist/10
		fwid:=1500*dist/10

		case "cactus","pumpkin":
		flen:=1500*dist/10
		fwid:=2500*dist/10

		case "pine tree":
		flen:=2500*dist/10
		fwid:=1750*dist/10

		case "rose":
		flen:=2500*dist/10
		fwid:=1500*dist/10

		case "mountain top":
		flen:=2250*dist/10
		fwid:=1500*dist/10

		case "pepper","coconut":
		flen:=1500*dist/10
		fwid:=2250*dist/10
	}

	MoveSpeedFactor:=round(18/MoveSpeedNum, 2)

	;move to start position
	if(InStr(loc, "Upper")){
		nm_Move(flen*MoveSpeedFactor, FwdKey)
	} else if(InStr(loc, "Lower")){
		nm_Move(flen*MoveSpeedFactor, BackKey)
	}
	if(InStr(loc, "Left")){
		nm_Move(fwid*MoveSpeedFactor, LeftKey)
	} else if(InStr(loc, "Right")){
		nm_Move(fwid*MoveSpeedFactor, RightKey)
	}
	if(loc="center")
		sleep, 1000
	;set sprinkler(s)
	if(SprinklerType="Supreme" || SprinklerType="Basic") {
		Send {%SC_1%}
		return
	} else {
		send {%SC_Space% down}
		DllCall("Sleep",UInt,200)
		Send {%SC_1%}
		send {%SC_Space% up}
		DllCall("Sleep",UInt,900)
	}
	if(SprinklerType="Silver" || SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, BackKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		}
		DllCall("Sleep",UInt,500)
		send {%SC_Space% down}
		DllCall("Sleep",UInt,200)
		send {%SC_1%}
		send {%SC_Space% up}
		DllCall("Sleep",UInt,900)
	}
	if(SprinklerType="Silver") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
	}
	if(SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Left")){
			nm_Move(1000*MoveSpeedFactor, RightKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		}
		DllCall("Sleep",UInt,500)
		send {%SC_Space% down}
		DllCall("Sleep",UInt,200)
		Send {%SC_1%}
		send {%SC_Space% up}
		DllCall("Sleep",UInt,900)
	}
	if(SprinklerType="Golden") {
		if(InStr(loc, "Upper")){
			if(InStr(loc, "Left")){
				nm_Move(1400*MoveSpeedFactor, FwdKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, FwdKey, RightKey)
			}
		} else {
			if(InStr(loc, "Left")){
				nm_Move(1400*MoveSpeedFactor, BackKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, BackKey, RightKey)
			}
		}
	}
	if(SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
		DllCall("Sleep",UInt,500)
		send {%SC_Space% down}
		DllCall("Sleep",UInt,200)
		Send {%SC_1%}
		send {%SC_Space% up}
		DllCall("Sleep",UInt,900)
		if(InStr(loc, "Left")){
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, RightKey)
		}
	}
}
nm_fieldDriftCompensation(){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global KeyDelay
	global MoveSpeedNum
	global CurrentFieldNum
	global FieldSprinklerLoc1
	global FieldSprinklerLoc2
	global FieldSprinklerLoc3
	global DisableToolUse, PFieldDriftSteps
	if (!PFieldDriftSteps) {
		PFieldDriftSteps:=10
	}
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	winUp := windowHeight / 2.14
	winDown := windowHeight / 1.88
	winLeft := windowWidth / 2.14
	winRight := windowWidth / 1.88
	saturatorFinder := nm_imgSearch("saturator.png",50)
	;search for winterstorm saturator
	If (saturatorFinder[1] = 1){
		saturatorFinder := nm_imgSearch("saturatorWS.png",50)
	}
	If (saturatorFinder[1] = 0){
		while (saturatorFinder[1] = 0 && A_Index<=PFieldDriftSteps) {
			if(saturatorFinder[2] >= winleft && saturatorFinder[2] <= winRight && saturatorFinder[3] >= winUp && saturatorFinder[3] <= winDown) {
				click up
				break
			}
			if(!DisableToolUse)
				click down
			if (saturatorFinder[2] < winleft){
				sendinput {%LeftKey% down}
			} else if (saturatorFinder[2] > winRight){
				sendinput {%RightKey% down}
			}
			if (saturatorFinder[3] < winUp){
				sendinput {%FwdKey% down}
			} else if (saturatorFinder[3] > winDown){
				sendinput {%BackKey% down}
			}
			sleep, 200*round(18/MoveSpeedNum, 2)
			sendinput {%LeftKey% up}{%RightKey% up}{%FwdKey% up}{%BackKey% up}
			click up
			saturatorFinder := nm_imgSearch("saturator.png",50)
		}
	} ;else if(not (saturatorFinder[2] >= winleft && saturatorFinder[2] <= winRight && saturatorFinder[3] >= winUp && saturatorFinder[3] <= winDown)){
		;ba_fieldDriftCompensation()
	;}
}
;move function
nm_Move(MoveTime, MoveKey1, MoveKey2:="None"){
	PrevKeyDelay:=A_KeyDelay
	SetKeyDelay, 5
	send, {%MoveKey1% down}
	if(MoveKey2!="None")
		send, {%MoveKey2% down}
	DllCall("Sleep",UInt,MoveTime)
	;sleep, %MoveTime%
	send, {%MoveKey1% up}
	if(MoveKey2!="None")
		send, {%MoveKey2% up}
	SetKeyDelay, PrevKeyDelay
}
GetRobloxHWND()
{
	if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe"))
		return hwnd
	else if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe"))
	{
		ControlGet, hwnd, Hwnd, , ApplicationFrameInputSinkWindow1
		return hwnd
	}
	else
		return 0
}
CloseRoblox()
{
	local PrevKeyDelay, p
	; if roblox exists, activate it and send Esc+L+Enter
	if GetRobloxHWND()
	{
		WinActivate, Roblox
		PrevKeyDelay := A_KeyDelay
		SetKeyDelay, 250+KeyDelay
		send {%SC_Esc%}{%SC_L%}{%SC_Enter%}
		SetKeyDelay, PrevKeyDelay
		WinClose, Roblox
	}
	; kill any remnant processes
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
		Process, Close, % p.ProcessID
}
DisconnectCheck(testCheck := 0)
{
	global LastClock, LastGingerbread, KeyDelay, HiveSlot, CurrentAction, PreviousAction, PrivServer, TotalDisconnects, SessionDisconnects, DailyReconnect, PublicFallback, resetTime, SC_Esc, SC_R, SC_Enter, SC_E, bitmaps, PlanterName1, PlanterName2, PlanterName3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3, MacroState, ReconnectDelay, FallbackServer1, FallbackServer2, FallbackServer3, beesmasActive
	static ServerLabels := {0: "Public Server Link", 1: "Private Server Link", 2: "Fallback Server Link 1", 3: "Fallback Server Link 2", 4: "Fallback Server Link 3"}, LegacyOverride := 0
	
	; return if not disconnected or crashed
	if (nm_imgSearch("disconnected.png",25, "center")[1] = 1 && GetRobloxHWND() && !WinExist("Roblox Crash"))
		return 0

	; end any residual movement and set reconnect start time
	nm_endWalk()
	ReconnectStart := nowUnix()
	PreviousAction:=CurrentAction
	CurrentAction:="Reconnect"

	; wait for any requested delay time (e.g. from remote control or daily reconnect)
	if (ReconnectDelay)
	{
		nm_setStatus("Waiting", ReconnectDelay " seconds before Reconnect")
		Sleep, 1000*ReconnectDelay
		ReconnectDelay := 0
	}
	if (DailyReconnect)
	{
		staggerDelay:=30000*HiveSlot
		nm_setStatus("Waiting", round(2+(staggerDelay/60000), 1) " minutes before Reconnect")
		sleep, 120000+staggerDelay
		DailyReconnect := 0
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		if WinExist("background.ahk ahk_class AutoHotkey"){
			PostMessage, 0x5554, 6, 0
		}
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
	}
	else if (MacroState = 2)
	{
		TotalDisconnects:=TotalDisconnects+1
		SessionDisconnects:=SessionDisconnects+1
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 6, 1
		}
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
		IniWrite, %TotalDisconnects%, settings\nm_config.ini, Status, TotalDisconnects
		IniWrite, %SessionDisconnects%, settings\nm_config.ini, Status, SessionDisconnects
		nm_setStatus("Disconnected", "Reconnecting")
	}

	; obtain link codes from Private Server and Fallback Server links
	linkCodes := {}
	for k,v in ["PrivServer", "FallbackServer1", "FallbackServer2", "FallbackServer3"]
	{
		if (%v% && (StrLen(%v%) > 0))
		{
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", linkCode)
				linkCodes[k] := linkCode
			else
				nm_setStatus("Error", ServerLabels[k] " Invalid")
		}
	}
	
	; main reconnect loop
	Loop {	
		;Decide Server
		server := ((A_Index <= 12) && linkCodes.HasKey(n := (A_Index-1)//3 + 1)) ? n : ((PublicFallback = 0) && (n := linkCodes.MinIndex())) ? n : 0
		
		;Wait For Success
		i := A_Index, success := 0
		Loop, 1 {
			;START
			switch % LegacyOverride ? 0 : Mod(i, 3)
			{
				case 1:
				;Close Roblox
				CloseRoblox()
				Sleep 500 ;Delay to prevent error during UWP reconnect
				;Run Server Deeplink
				nm_setStatus("Attempting", ServerLabels[server])
				try Run % "roblox://placeID=1537690962" (server ? ("&linkCode=" linkCodes[server]) : "")
				
				case 2:
				;Run Server Deeplink (without closing)
				nm_setStatus("Attempting", ServerLabels[server])
				try Run % "roblox://placeID=1537690962" (server ? ("&linkCode=" linkCodes[server]) : "")
				
				default:
				if server
				{
					;Close Roblox
					CloseRoblox()
					;Run Server Link (legacy method w/ browser)
					nm_setStatus("Attempting", ServerLabels[server] " (Browser)")
					if (success := LegacyReconnect(linkCodes[server]) = 1)
					{
						LegacyOverride := 1
						nm_setStatus("Warning", "Deeplink reconnect failed, legacy reconnect enabled for this session!") 
						;Add ((state = "Interupted") || (state = "Reporting") || (state = "Warning")) ? 14408468 ; yellow - alert to update the Status.ahk file
						break
					}
					else
						continue 2
				}
				else 
				{
					;Close Roblox
					if (i = 1)
					{
						CloseRoblox()
						Sleep 500
					}
					;Run Server Link (spam deeplink method)
					try Run % "roblox://placeID=1537690962"
				}
			}
			;STAGE 1 - wait for Roblox window
			Loop, 240 {
				if GetRobloxHWND() {
					WinActivate, Roblox
					nm_setStatus("Detected", "Roblox Open")
					break
				}
				if (A_Index = 240) {
					nm_setStatus("Error", "No Roblox Found`nRetry: " i)
					Sleep, 1000
					break 2
				}
				sleep, 1000 ; timeout 4 mins, wait for any Roblox update to finish
			}
			;STAGE 2 - wait for loading screen (or loaded game)
			Loop, 180 {
				WinActivate, Roblox
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Open")
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
					nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
					Sleep, 1000
					break 2
				}
				if (A_Index = 180) {
					nm_setStatus("Error", "No BSS Found`nRetry: " i)
					Sleep, 1000
					break 2
				}
				sleep, 1000 ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop, 180 {
				WinActivate, Roblox
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1))
				{
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
					nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
					Sleep, 1000
					break 2
				}
				if (A_Index = 180) {
					nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
					Sleep, 1000
					break 2
				}
				sleep, 1000 ; timeout 4 mins, slow loading
			}
		}
		
		;Successful Reconnect
		if (success = 1)
		{
			WinActivate, Roblox
			VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(ReconnectDuration := (nowUnix() - ReconnectStart))*10000000,"wstr","mm:ss","str",duration,"int",256)
			nm_setStatus("Completed", "Reconnect`nTime: " duration " - Attempts: " i)
			Sleep, 500

			LastClock:=nowUnix()
			IniWrite, %LastClock%, settings\nm_config.ini, Collect, LastClock
			if (beesmasActive)
			{
				LastGingerbread += ReconnectDuration ? ReconnectDuration : 300
				IniWrite, %LastGingerbread%, settings\nm_config.ini, Collect, LastGingerbread
			}
			Loop, 3 {
				IniRead, PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
				PlanterHarvestTime%A_Index% += PlanterName%A_Index% ? (ReconnectDuration ? ReconnectDuration : 300) : 0
				IniWrite, % PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
			}

			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if (server > 1) ; swap PrivServer and FallbackServer - original PrivServer probably has an issue
			{
				n := server - 1
				temp := PrivServer, PrivServer := FallbackServer%n%, FallbackServer%n% := temp
				GuiControl, , PrivServer, %PrivServer%
				GuiControl, , FallbackServer%n%, % FallbackServer%n%
				IniWrite, %PrivServer%, settings\nm_config.ini, Settings, PrivServer
				IniWrite, % FallbackServer%n%, settings\nm_config.ini, Settings, FallbackServer%n%
				if WinExist("Status.ahk ahk_class AutoHotkey")
					PostMessage, 0x5553, 10, 7
			}
			if WinExist("Status.ahk ahk_class AutoHotkey")
				PostMessage, 0x5552, 221, (server = 0)
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%

			if (testCheck || (nm_claimHiveSlot() = 1))
				return 1 
		}
	}
}
LegacyReconnect(linkCode)
{ 
	static init := VarSetCapacity(cmd, 512) + DllCall("shlwapi\AssocQueryString","Int",0,"Int",1,"Str","http","Str","open","Str",cmd, "IntP",512) + DllCall("Shell32\SHEvaluateSystemCommandTemplate","WStr",cmd,"PtrP",pEXE,"Ptr",0,"PtrP",pPARAMS), exe := StrGet(pEXE), params := StrGet(pPARAMS)
	
	ShellRun(exe, StrReplace(params, "%1", "https://www.roblox.com/games/1537690962?privateServerLinkCode=" linkCode)), success := 0
	Loop, 1 {
		;STAGE 1 - wait for Roblox Launcher
		Loop, 120 {
			if WinExist("Roblox") {
				break
			}
			if (A_Index = 120) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep, 1000
				break 2
			}
			sleep, 1000 ; timeout 2 mins, slow internet / not logged in
		}
		;STAGE 2 - wait for RobloxPlayerBeta.exe
		Loop, 180 {
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate
				nm_setStatus("Detected", "Roblox Open")
				break
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep, 1000
				break 2
			}
			sleep, 1000 ; timeout 3 mins, wait for any Roblox update to finish
		}
		;STAGE 3 - wait for loading screen (or loaded game)
		Loop, 180 {
			WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Open")
				break
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep, 1000
				break 2
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No BSS Found`nRetry: " i)
				Sleep, 1000
				break 2
			}
			sleep, 1000 ; timeout 3 mins, slow loading
		}
		;STAGE 4 - wait for loaded game
		Loop, 240 {
			WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|150")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Loaded")
				success := 1
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			if (nm_imgSearch("disconnected.png",25, "center")[1] = 0){
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep, 1000
				break 2
			}
			if (A_Index = 240) {
				nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
				Sleep, 1000
				break 2
			}
			sleep, 1000 ; timeout 4 mins, slow loading
		}
	}
	;Close Browser Tab
	WinGet, list, List
	Loop, %list%
	{
		hwnd := list%A_Index%
		WinGet, p, ProcessName, ahk_id %hwnd%
		if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
			continue ; skip roblox and AHK windows
		WinGetTitle, title, ahk_id %hwnd%
		if (title = "")
			continue ; skip empty title windows
		WinGet, s, Style, ahk_id %hwnd%
		if ((s & 0x8000000) || !(s & 0x10000000))
			continue ; skip NoActivate and invisible windows
		WinGet, s, ExStyle, ahk_id %hwnd%
		if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
			continue ; skip ToolWindow and AlwaysOnTop windows
		WinActivate, ahk_id %hwnd%
		Sleep, 500
		Send ^{w}
		break
	}
	return success
}
/*
  ShellRun by Lexikos
    requires: AutoHotkey v1.1
    license: http://creativecommons.org/publicdomain/zero/1.0/
  Credit for explaining this method goes to BrandonLive:
  http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/

  Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
  http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
;Note might have to use for deeplinking if we have roblox admin issues
ShellRun(prms*)
{ 
    shellWindows := ComObjCreate("Shell.Application").Windows
    VarSetCapacity(_hwnd, 4, 0)
    desktop := shellWindows.FindWindowSW(0, "", 8, ComObj(0x4003, &_hwnd), 1)

    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetCapacity(IID_IDispatch, 16)
            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")

            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)

            ; Get Shell object.
            shell := ComObj(9,pdisp,1).Application

            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)

            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}
nm_claimHiveSlot(){
	global KeyDelay, FwdKey, RightKey, LeftKey, BackKey, ZoomOut, HiveSlot, HiveConfirmed, SC_E, SC_Esc, SC_R, SC_Enter, bitmaps, ReconnectMessage, LastNatroSoBroke

	Loop, 5
	{
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100

		;reset
		if (A_Index > 1)
		{
			resetTime:=nowUnix()
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("background.ahk ahk_class AutoHotkey")
				PostMessage, 0x5554, 1, resetTime
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			WinActivate, Roblox
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay, 250+KeyDelay
			send {%SC_Esc%}{%SC_R%}{%SC_Enter%}
			SetKeyDelay, PrevKeyDelay
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep, 250
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-100 "|" windowY "|100|32")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep, 1000
		}

		;go to slot 1
		Sleep, 500
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		send {%ZoomOut% 8}

		movement := "
		(LTrim Join`r`n
		" nm_Walk(35, FwdKey, RightKey) "
		" nm_Walk(5, BackKey) "
		" nm_Walk(3.5, LeftKey) "
		)"
		nm_createWalk(movement)
		KeyWait, F14, D T5 L
		KeyWait, F14, T20 L
		nm_endWalk()

		;check slots 1 to old HiveSlot
		slots := {}
		movement := "
		(LTrim Join`r`n
		" nm_Walk(8.35, LeftKey) "
		)"
		Loop % HiveSlot
		{
			if (A_Index > 1)
			{
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T20 L
				nm_endWalk()
			}

			Sleep, 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
				slots[A_Index] := 1
			Gdip_DisposeImage(pBMScreen)
		}

		if (slots[HiveSlot] = 1)
			break
		else
		{
			if (slots.MinIndex() > 0)
			{
				movement := "
				(LTrim Join`r`n
				" nm_Walk((HiveSlot - slots.MinIndex()) * 8.35, RightKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T20 L
				nm_endWalk()
				Sleep, 500
				HiveSlot := slots.MinIndex()
				break
			}
			else {
				Loop % (6 - HiveSlot)
				{
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T20 L
					nm_endWalk()

					Sleep, 500
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1) {
						Gdip_DisposeImage(pBMScreen)
						HiveSlot += A_Index
						break 2
					}
					Gdip_DisposeImage(pBMScreen)
				}
			}
		}

		nm_setStatus("Failed", "Claim Hive Slot" ((A_Index > 1) ? (" (Attempt " A_Index ")") : ""))
		if (A_Index = 5)
			return 0
	}

	;update hive slot
	GuiControl, Choose, HiveSlot, %HiveSlot%
	IniWrite, %HiveSlot%, settings\nm_config.ini, Settings, HiveSlot
	nm_setStatus("Claimed", "Hive Slot " . HiveSlot)
	;;;;; Natro so broke :weary:
	if(ReconnectMessage && ((nowUnix()-LastNatroSoBroke)>3600)) { ;limit to once per hour
		LastNatroSoBroke:=nowUnix()
		Send {Text} /[%A_Hour%:%A_Min%] Natro so broke :weary:`n
		sleep 250
	}
	sendinput {%SC_E% down}
	Sleep, 100
	sendinput {%SC_E% up}
	HiveConfirmed := 1
	MouseMove, windowX+350, windowY+100

	return 1
}
nm_activeHoney(){
	global HiveBees, GameFrozenCounter
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
    x1 := (windowWidth//2)-90
    x2 := (windowWidth//2)-20
    PixelSearch, bx2, by2, windowX + x1, windowY, windowX + x2, windowY + 36, 0xFFE280, 20, RGB Fast
    if (ErrorLevel = 0){
		GameFrozenCounter:=0
        return 1
	} else {
		if(HiveBees<25){
			x1 := (windowWidth//2)+210
			x2 := (windowWidth//2)+280
			PixelSearch, bx2, by2, windowX + x1, windowY, windowX + x2, windowY + 36, 0xFFFFFF, 20, RGB Fast
			if (ErrorLevel = 0){
				return 1
			} else {
				return 0
			}
		}else{
			return 0
		}
    }
}
nm_searchForE(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, bitmaps

	movement := "
	(LTrim Join`r`n
	Loop, 8
	{
		i := A_Index
		Loop, 2
		{
			Send {" FwdKey " down}
			Walk(3*i)
			Send {" FwdKey " up}{" RotRight " 2}
		}
	}
	)"
	nm_createWalk(movement)
	KeyWait, F14, D T5 L

	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
	MouseMove, windowX+350, windowY+100
	success := 0
	DllCall("GetSystemTimeAsFileTime","int64p",s)
	n := s, f := s+90*10000000 ; 90 second timeout
	while (n < f && GetKeyState("F14"))
	{
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
		{
			success := 1, Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		DllCall("GetSystemTimeAsFileTime","int64p",n)
	}
	nm_endWalk()

	if (success = 1) ; check that planter was not overrun, at the expense of a small delay
	{
		Loop, 10
		{
			if (A_Index = 10)
			{
				success := 0
				break
			}
			Sleep, 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				movement := "
				(LTrim Join`r`n
				" nm_Walk(1.5, BackKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T5 L
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}
	return success
}
nm_boostBypassCheck(){
	global PFieldBoostBypass, RecentFBoost, LastBlueBoost, LastRedBoost, LastMountainBoost
	static fieldBoosters := {"Pine Tree":"blue"
		, "Bamboo":"blue"
		, "Blue Flower":"blue"
		, "Rose":"red"
		, "Strawberry":"red"
		, "Mushroom":"red"
		, "Cactus":"mountain"
		, "Pumpkin":"mountain"
		, "Pineapple":"mountain"
		, "Spider":"mountain"
		, "Clover":"mountain"
		, "Dandelion":"mountain"
		, "Sunflower":"mountain"}

	if (!PFieldBoostBypass || !fieldBoosters.HasKey(RecentFBoost))
		return 0

	booster := fieldBoosters[RecentFBoost]
	for k,v in StrSplit(PFieldBoostBypass, ",")
	{
		if ((RecentFBoost = Trim(v)) && ((nowUnix() - Last%booster%Boost) < 900))
			return 1
	}
	return 0
}
nm_ViciousCheck(){
	global VBState ;0=no VB, 1=searching for VB, 2=VB found
	global VBLastKilled, TotalViciousKills, SessionViciousKills, KeyDelay
	Send {Text} /`n
	sleep, 250
	Prev_DetectHiddenWindows := A_DetectHiddenWindows ; to communicate with background.ahk
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	if(VBState=1){
		if(nm_imgSearch("VBfoundSymbol2.png", 50, "highright")[1]=0){
			VBState:=2
			VBLastKilled:=nowUnix()
			;send VBState to background.ahk
			if WinExist("background.ahk ahk_class AutoHotkey")
			{
				PostMessage, 0x5554, 3, VBState
				PostMessage, 0x5554, 5, VBLastKilled
			}
			;nm_setStatus("VBState " . VBState, " <1>")
			IniWrite, %VBLastKilled%, settings\nm_config.ini, Collect, VBLastKilled
		}
		;check if VB was already killed by someone else
		if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
			VBState:=0
			VBLastKilled:=nowUnix()
			;send VBState to background.ahk
			if WinExist("background.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5554, 3, VBState
				PostMessage, 0x5554, 5, VBLastKilled
			}
			IniWrite, %VBLastKilled%, settings\nm_config.ini, Collect, VBLastKilled
			;nm_setStatus("VBState " . VBState, " <2>")
			nm_setStatus("Defeated", "Vicious Bee - Other Player")
		}
	}
	if(VBState=2){
	;temp:=(nowUnix()-VBLastKilled)
	;msgbox VBLastKilled (300): %temp%
		if((nowUnix()-VBLastKilled)<(600)) { ;it has been less than 10 minutes since VB was found
			if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
				VBState:=0
				VBLastKilled:=nowUnix()
				;send VBState to background.ahk
				if WinExist("background.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5554, 5, VBLastKilled
					PostMessage, 0x5554, 3, VBState
				}
				IniWrite, %VBLastKilled%, settings\nm_config.ini, Collect, VBLastKilled
				;nm_setStatus("VBState " . VBState, " <3>")
				;nm_setStatus("Defeated", "VB")
				TotalViciousKills:=TotalViciousKills+1
				SessionViciousKills:=SessionViciousKills+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 2, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalViciousKills%, settings\nm_config.ini, Status, TotalViciousKills
				IniWrite, %SessionViciousKills%, settings\nm_config.ini, Status, SessionViciousKills
				killed := 1
			}
		} else { ;it has been greater than 10 minutes since VB was found
				VBState:=0
				;send VBState to background.ahk
				if WinExist("background.ahk ahk_class AutoHotkey")
					PostMessage, 0x5554, 3, VBState
				;nm_setStatus("VBState " . VBState, " <4>")
				nm_setStatus("Aborted", "Vicious Fight > 10 Mins")
		}
	}
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
	return killed
}
nm_locateVB(){
	global VBState, StingerCheck, StingerDailyBonusCheck, StingerPepperCheck, StingerMountainTopCheck, StingerRoseCheck, StingerCactusCheck, StingerSpiderCheck, StingerCloverCheck, NightLastDetected, VBLastKilled, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, RotDown, RotUp, ZoomOut, MoveMethod, objective, DisableToolUse, CurrentAction, PreviousAction

	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	; must set these back to prev before returning

	time := nowUnix()
	; don't run if stinger check disabled, VB last killed less than 5m ago, night last detected more than 5m ago
	if ((StingerCheck=0) || (time-VBLastKilled)<300 || ((time-NightLastDetected)>300 || (time-NightLastDetected)<0) || (VBState = 0)) {
		VBState:=0
		;send VBState to background.ahk
		if WinExist("background.ahk ahk_class AutoHotkey")
			PostMessage, 0x5554, 3, VBState
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
		return
	}

	; check if VB has already been activated / killed
	nm_ViciousCheck()

	if(VBState=2){
		nm_setStatus("Attacking", "Vicious Bee")
		startBattle := nowUnix()
		if(!DisableToolUse)
			click, down

		while (VBState=2) { ; generic battle pattern
			movement := "
			(LTrim Join`r`n
			" nm_Walk(13.5, LeftKey) "
			" nm_Walk(4.5, BackKey) "
			)"
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T60 L
			nm_endWalk()
			movement := "
			(LTrim Join`r`n
			" nm_Walk(13.5, RightKey) "
			" nm_Walk(4.5, FwdKey) "
			)"
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T60 L
			nm_endWalk()
			killed := nm_ViciousCheck()
		}
		if killed {
			VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(nowUnix() - startBattle)*10000000,"wstr","mm:ss","str",duration,"int",256)
			nm_setStatus("Defeated", "Vicious Bee`nTime: " duration)
		}
		VBState:=0 ;0=no VB, 1=searching for VB, 2=VB found
		if WinExist("background.ahk ahk_class AutoHotkey")
			PostMessage, 0x5554, 3, VBState
		DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
		SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
		return
	}

	; confirm night time
	if(VBState=1){
		nm_setStatus("Confirming", "Night")
		nm_Reset(0, 2000, 0)
		sendinput {%RotRight% 3}{%RotDown% 3}
		loop 10 {
			sendinput {%ZoomOut%}
			Sleep, 100
			if ((findImg := nm_imgSearch("nightsky.png", 50, "abovebuff"))[1] = 0)
				break
		}
		if(findImg[1]=0){
			;night confirmed, proceed!
			nm_setStatus("Starting", "Vicious Bee Cycle")
			sendinput {%RotLeft% 3}{%RotUp% 3}
			send {%ZoomOut% 8}
		} else {
			;false positive, ABORT!
			VBState:=0
			if WinExist("background.ahk ahk_class AutoHotkey")
				PostMessage, 0x5554, 3, VBState
			NightLastDetected:=nowUnix()-300-1 ;make NightLastDetected older than 5 minutes
			IniWrite, %NightLastDetected%, settings\nm_config.ini, Collect, NightLastDetected
			nm_setStatus("Aborting", "Vicious Bee - Not Night")
			sendinput {%RotLeft% 3}{%RotUp% 3}
			send {%ZoomOut% 8}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			return
		}
	}

	PreviousAction:=CurrentAction, CurrentAction:="Stingers"
	startTime:=nowUnix()

	fieldsChecked := 0
	for k,v in ["Pepper","MountainTop","Rose","Cactus","Spider","Clover"]
	{
		if !Stinger%v%Check
			continue
		else
			fieldsChecked++

		Loop, 10 ; attempt each field a maximum of n (10) times
		{
			click, up
			if(VBState=0) {
				nm_setStatus("Aborting", "No Vicious Bee")
				break 2
			}

			if ((v = "Spider") && (A_Index = 1) && StingerSpiderCheck && StingerCactusCheck)
			{
				;walk from Cactus to Spider
				nm_setStatus("Traveling", "Vicious Bee (" v ")")
				movement := "
				(LTrim Join`r`n
				" nm_Walk(20, LeftKey) "
				" nm_Walk(44, FwdKey, LeftKey) "
				Loop, 4
					Send {" RotLeft "}
				" nm_Walk(20, FwdKey) "
				" nm_Walk(20, LeftKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()
			}
			else
			{
				(fieldsChecked > 1 || A_Index > 1) ? nm_Reset(0, 2000, 0)
				nm_setStatus("Traveling", "Vicious Bee (" v ")" ((A_Index > 1) ? " - Attempt " A_Index : ""))

				if(MoveMethod="walk")
					nm_walkTo((v = "MountainTop") ? "Mountain Top" : v)
				else {
					nm_cannonTo((v = "MountainTop") ? "Mountain Top" : v)
					Loop % ((v = "MountainTop") ? 2 : 0)
						send {%RotLeft%}
				}

				if (v = "Spider")
				{
					movement := "
					(LTrim Join`r`n
					" nm_Walk(3500*9/2000, FwdKey) "
					" nm_Walk(3000*9/2000, LeftKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
				}
			}

			if(!DisableToolUse)
				click, down

			;search pattern
			if (VBState=1)
			{
				nm_setStatus("Searching", "Vicious Bee (" v ")")

				;configure
				reps := (v = "Pepper") ? 2 : (v = "MountainTop") ? 1 : (v = "Rose") ? 2 : (v = "Cactus") ? 1 : (v = "Spider") ? 2 : 2
				leftOrRightDist := (v = "Pepper") ? 4000 : (v = "MountainTop") ? 3500 : (v = "Rose") ? 3000 : (v = "Cactus") ? 4500 : (v = "Spider") ? 3750 : 4000
				forwardOrBackDist := (v = "Pepper") ? 900 : (v = "MountainTop") ? 1500 : (v = "Rose") ? 1500 : (v = "Cactus") ? 1500 : (v = "Spider") ? 1500 : 1500

				movement := "
				(LTrim Join`r`n
				" nm_Walk(((v = "Pepper") ? 1700 : (v = "MountainTop") ? 2000 : (v = "Rose") ? 1800 : (v = "Cactus") ? 2000 : (v = "Spider") ? 1000 : 1500)*9/2000, RightKey) "
				" nm_Walk(((v = "Pepper") ? 1600 : (v = "MountainTop") ? 1600 : (v = "Rose") ? 1875 : (v = "Cactus") ? 750 : (v = "Spider") ? 1000 : 1500)*9/2000, (v = "Spider") ? BackKey : FwdKey) "
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T60 L
				nm_endWalk()

				if ((v = "Pepper") || (v = "Rose") || (v = "Clover") || (v = "Cactus"))
				{
					loop, %reps% {
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 2
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" ((A_Index < reps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "") "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 2
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement := "
						(LTrim Join`r`n
						" nm_Walk(forwardOrBackDist*2*(reps-0.5)*9/2000, FwdKey) "
						" ((v != "Cactus") ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "") "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
					}
				}
				else if (v = "MountainTop")
				{
					loop, %reps% {
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						" nm_Walk(leftOrRightDist*9/2000, RightKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 2
						movement := "
						(LTrim Join`r`n
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 2
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" nm_Walk(forwardOrBackDist*9/2000, FwdKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
					}
				}
				else ; spider
				{
					loop, %reps% {
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" ((A_Index < reps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "") "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if (A_Index < reps)
						{
							if(not nm_activeHoney())
								continue 2
							movement := "
							(LTrim Join`r`n
							" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
							" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
							)"
							nm_createWalk(movement)
							KeyWait, F14, D T5 L
							KeyWait, F14, T60 L
							nm_endWalk()
						}
						if(not nm_activeHoney())
							continue 2
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement := "
						(LTrim Join`r`n
						" nm_Walk(forwardOrBackDist*2*(reps-0.5)*9/2000, FwdKey) "
						" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
					}
				}
			}

			;battle pattern
			if (VBState=2) {
				nm_setStatus("Attacking", "Vicious Bee (" v ")" ((A_Index > 1) ? " - Round " A_Index : ""))
				startBattle := (A_Index = 1) ? nowUnix() : startBattle

				;configure
				breps := 1
				leftOrRightDist := (v = "Pepper") ? 3000 : (v = "MountainTop") ? 3000 : (v = "Rose") ? 2500 : (v = "Cactus") ? 3250 : (v = "Spider") ? 2500 : 1800
				forwardOrBackDist := (v = "Pepper") ? 1000 : (v = "MountainTop") ? 1000 : (v = "Rose") ? 1000 : (v = "Cactus") ? 750 : (v = "Spider") ? 1000 : 1000

				while (VBState=2) {
					loop, %breps% {
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, (v = "Spider") ? RightKey : LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 3
						movement := "
						(LTrim Join`r`n
						" nm_Walk(leftOrRightDist*9/2000, (v = "Spider") ? LeftKey : RightKey) "
						" ((A_Index < breps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "") "
						)"
						nm_createWalk(movement)
						KeyWait, F14, D T5 L
						KeyWait, F14, T60 L
						nm_endWalk()
						if(not nm_activeHoney())
							continue 3
						killed := nm_ViciousCheck()
					}
					movement := "
					(LTrim Join`r`n
					" nm_Walk(forwardOrBackDist*2*(breps-0.5)*9/2000, FwdKey) "
					)"
					nm_createWalk(movement)
					KeyWait, F14, D T5 L
					KeyWait, F14, T60 L
					nm_endWalk()
				}
				if killed
				{
					VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(nowUnix() - startBattle)*10000000,"wstr","mm:ss","str",duration,"int",256)
					nm_setStatus("Defeated", "Vicious Bee`nTime: " duration)
					Sleep, 500
				}
				break 2
			}
			break
		}
	}
	click, up
	VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(nowUnix() - startTime)*10000000,"wstr","mm:ss","str",duration,"int",256)
	nm_setStatus("Completed", "Vicious Bee Cycle`nTime: " duration " - Fields: " fieldsChecked " - Defeated: " ((killed) ? "Yes" : "No"))
	VBState:=0 ;0=no VB, 1=searching for VB, 2=VB found
	if WinExist("background.ahk ahk_class AutoHotkey")
		PostMessage, 0x5554, 3, VBState
	DetectHiddenWindows %Prev_DetectHiddenWindows%  ; Restore original setting for the caller.
	SetTitleMatchMode %Prev_TitleMatchMode%         ; Same.
	return
}
nm_hotbar(boost:=0){
	global state, fieldOverrideReason, GatherStartTime, ActiveHotkeys, bitmaps
		, HotkeyMax2, HotkeyMax3, HotkeyMax4, HotkeyMax5, HotkeyMax6, HotkeyMax7
	;whileNames:=["Always", "Attacking", "Gathering", "At Hive"]
	;ActiveHotkeys.push([val, slot, HBSecs, LastHotkey%slot%])
	for key, val in ActiveHotkeys {
		;ActiveLen:=ActiveHotkeys.length()
		;temp1:=ActiveHotkeys[1][1]
		;temp2:=ActiveHotkeys[key][2]
		;temp3:=ActiveHotkeys[key][3]
		;temp4:=ActiveHotkeys[key][4]
		;msgbox len=%Activelen% key=%key% val=%val%`n1=%temp1%`n2=%temp2%`n3=%temp3%`n4=%temp4%
		;always
		if(ActiveHotkeys[key][1]="Always" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send % "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;attacking
		else if(state="Attacking" && ActiveHotkeys[key][1]="Attacking" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send % "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;gathering
		else if(state="Gathering" && fieldOverrideReason="None" && ActiveHotkeys[key][1]="Gathering" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send % "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;GatherStart
		else if(state="Gathering" && (fieldOverrideReason="None" || fieldOverrideReason="Boost") && (nowUnix()-GatherStartTime)<10 && ActiveHotkeys[key][1]="GatherStart" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send % "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			if(ActiveHotkeys[key][3]<=10) {
				ActiveHotkeys[key][4]:=LastHotkeyN+10
			} else {
				ActiveHotkeys[key][4]:=LastHotkeyN
			}
			break
		}
		;at hive
		else if(state="Converting" && ActiveHotkeys[key][1]="At Hive" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send % "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;snowflake
		else if(ActiveHotkeys[key][1]="Snowflake" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			WinGetClientPos(_x, _y, _w, _h, "ahk_id " GetRobloxHWND())
			;check that roblox window exists
			if (_w > 0) {
				pBMArea := Gdip_BitmapFromScreen(_x "|" _y+30 "|" _w "|50")
				;check that: science buff visible and e button not visible (buffs not obscured)
				if ((Gdip_ImageSearch(pBMArea, bitmaps["science"]) = 1) && (Gdip_ImageSearch(pBMArea, bitmaps["e_button"]) = 0)) {
					if (Gdip_ImageSearch(pBMArea, bitmaps["snowflake_identifier"], pos, , 20, , , , , 7) = 1) {
						;detect current snowflake buff amount
						x := SubStr(pos, 1, InStr(pos, ",")-1)

						digits := {}
						Loop, 10
						{
							n := 10-A_Index
							if ((n = 1) || (n = 3))
								continue
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
							Loop, Parse, list, `n
								if (A_Index & 1)
									digits[A_LoopField] := n
						}
						for m,n in [1,3]
						{
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
							Loop, Parse, list, `n
							{
								if (A_Index & 1)
								{
									if (((n = 1) && (digits[A_LoopField - 5] = 4)) || ((n = 3) && (digits[A_LoopField - 1] = 8)))
										continue
									digits[A_LoopField] := n
								}
							}
						}
						num := ""
						for m,n in digits
							num .= n
					}
					else
						num := 0

					Gdip_DisposeImage(pBMArea)
					HotkeyNum:=ActiveHotkeys[key][2]
					;use snowflake if detected snowflake buff is below user selected maximum (num = "" implies 100% or indeterminate)
					if ((num != "") && (num < HotkeyMax%HotkeyNum%)) {
						send % "{sc00" HotkeyNum+1 "}"
						LastHotkeyN:=nowUnix()
						Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
						ActiveHotkeys[key][4]:=LastHotkeyN
						break
					}
				}
				Gdip_DisposeImage(pBMArea)
			}
		}
	}
}
nm_HoneyQuest(){
	global HoneyStart
	global HoneyQuestCheck
	global HoneyQuestProgress
	global HoneyQuestComplete:=1
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, CurrentAction, PreviousAction, bitmaps
	if(!HoneyQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")
	;search for honey quest
	Loop, 70
	{
		Qfound:=nm_imgSearch("honeyhunt.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		WinActivate, Roblox
		switch A_Index
		{
			case 1:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, windowX+30, windowX+200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")

			default:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			sendinput {WheelDown}
			Sleep, 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep, 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		HoneyStart:=[ErrorLevel, FoundX-windowX, FoundY-windowY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			Loop, 3 {
				xi := windowX
				yi := windowY+HoneyStart[3]+15
				ww := windowX+306
				wh := windowY+HoneyStart[3]+100
				ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 nm_image_assets\questbargap.png
				if(ErrorLevel=0) {
					QuestBarSize:=FoundY-windowY-HoneyStart[3]
					QuestBarGapSize:=3
					QuestBarInset:=3
					NextY:=FoundY+1
					NextX:=FoundX+1
					loop 20 {
						ImageSearch, FoundX, FoundY, FoundX, NextY, ww, wh, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=FoundY+1
							QuestBarGapSize:=QuestBarGapSize+1
						} else {
							break
						}
					}
					wh := windowY+HoneyStart[3]+200
					loop 20 {
						ImageSearch, FoundX, FoundY, NextX, yi, ww, wh, *5 nm_image_assets\questbarinset.png
						if(ErrorLevel=0) {
							NextX:=FoundX+1
							QuestBarInset:=QuestBarInset+1
						} else {
							break
						}
					}
					break
					;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
				} else {
					MouseMove, windowX+30, windowY+225
					Sleep, 50
					send, {WheelDown 1}
					Sleep, 50
					HoneyStart[3]-=150
					Sleep, 500
				}
			}
		}
		;Update Honey quest progress in GUI
		honeyProgress:=""
		;also set next steps
		PixelGetColor, questbarColor, windowX+QuestBarInset+10, windowY+HoneyStart[3]+QuestBarGapSize+5, RGB fast
		;temp%A_Index%:=questbarColor
		if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
			HoneyQuestComplete:=0
			completeness:="Incomplete"
		}
		;border color, white (titlebar), black (text)
		else if((questbarColor!=Format("{:d}",0x96C3DE)) && (questbarColor!=Format("{:d}",0xE5F0F7)) && (questbarColor!=Format("{:d}",0x1B2A35))) {
			HoneyQuestComplete:=1
			completeness:="Complete"
		} else {
			completeness:="Unknown"
		}
		honeyProgress:=("Honey Tokens: " . completeness)
		IniWrite, %honeyProgress%, settings\nm_config.ini, Quests, HoneyQuestProgress
		GuiControl,,HoneyQuestProgress, % StrReplace(honeyProgress, "|", "`n")
	}
	if(HoneyQuestComplete)
	{
		if(CurrentAction!="Quest") {
			PreviousAction:=CurrentAction
			CurrentAction:="Quest"
		}
		nm_gotoQuestgiver("Honey")
		nm_setStatus("Starting", "Honey Quest: Honey Hunt")
	}
}
nm_PolarQuestProg(){
	global PolarQuestCheck
	global PolarBear
	global PolarQuest
	global PolarStart
	global PolarQuestProgress
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global PolarQuestComplete:=1
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!PolarQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")
	;search for polar quest
	Loop, 70
	{
		Qfound:=nm_imgSearch("polar_bear.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("polar_bear2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		WinActivate, Roblox
		switch A_Index
		{
			case 1:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, windowX+30, windowY+200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")

			default:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			sendinput {WheelDown}
			Sleep, 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep, 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		PolarStart:=[ErrorLevel, FoundX-windowX, FoundY-windowY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			Loop, 3 {
				xi := windowX
				yi := windowY+PolarStart[3]+15
				ww := windowX+306
				wh := windowY+PolarStart[3]+100
				ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 nm_image_assets\questbargap.png
				if(ErrorLevel=0) {
					QuestBarSize:=FoundY-windowY-PolarStart[3]
					QuestBarGapSize:=3
					QuestBarInset:=3
					NextY:=FoundY+1
					NextX:=FoundX+1
					loop 20 {
						ImageSearch, FoundX, FoundY, FoundX, NextY, ww, wh, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=FoundY+1
							QuestBarGapSize:=QuestBarGapSize+1
						} else {
							break
						}
					}
					wh := windowY+PolarStart[3]+200
					loop 20 {
						ImageSearch, FoundX, FoundY, NextX, yi, ww, wh, *5 nm_image_assets\questbarinset.png
						if(ErrorLevel=0) {
							NextX:=FoundX+1
							QuestBarInset:=QuestBarInset+1
						} else {
							break
						}
					}
					break
					;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
				} else {
					MouseMove, windowX+30, windowY+225
					Sleep, 50
					send, {WheelDown 1}
					Sleep, 50
					PolarStart[3]-=150
					Sleep, 500
				}
			}
		}
		;determine Quest name
		xi := windowX
		yi := windowY+PolarStart[3]-30
		ww := windowX+306
		wh := windowY+PolarStart[3]
		for key, value in PolarBear {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *10 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				PolarQuest:=key
				questSteps:=PolarBear[key].length()
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+PolarStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, windowX+30, windowY+225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
						PolarStart[3]-=150
						Sleep, 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Polar quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		newLine:="|"
		polarProgress:=""
		num:=PolarBear[PolarQuest].length()
		loop %num% {
			action:=PolarBear[PolarQuest][A_Index][2]
			where:=PolarBear[PolarQuest][A_Index][3]
			PixelGetColor, questbarColor, windowX+QuestBarInset+10, windowY+QuestBarSize*(PolarBear[PolarQuest][A_Index][1]-1)+PolarStart[3]+QuestBarGapSize+5, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				PolarQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Quest%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					QuestGatherField:=where
					QuestGatherFieldSlot:=PolarBear[PolarQuest][A_Index][1]
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=Format("{:d}",0x96C3DE)) && (questbarColor!=Format("{:d}",0xE5F0F7)) && (questbarColor!=Format("{:d}",0x1B2A35))) {
				completeness:="Complete"
				if(action="kill"){
					Quest%where%:=0
				}
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				polarProgress:=(PolarQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				polarProgress:=(polarProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		IniWrite, %polarProgress%, settings\nm_config.ini, Quests, PolarQuestProgress
		GuiControl,,PolarQuestProgress, % StrReplace(polarProgress, "|", "`n")
		if(QuestLadybugs=0 && QuestRhinoBeetles=0 && QuestSpider=0 && QuestMantis=0 && QuestScorpions=0 && QuestWerewolf=0 && QuestGatherField="None"){
			PolarQuestComplete:=1
		}
	}
}
nm_PolarQuest(){
	global PolarQuestCheck, PolarQuest, PolarQuestComplete, QuestGatherField, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RotateQuest, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!PolarQuestCheck)
		return
	nm_setShiftLock(0)
	RotateQuest:="Polar"
	nm_PolarQuestProg()
	if(PolarQuestComplete = 1) {
		if(CurrentAction!="Quest") {
			PreviousAction:=CurrentAction
			CurrentAction:="Quest"
		}
		nm_gotoQuestgiver("Polar")
		nm_PolarQuestProg()
		if(!PolarQuestComplete){
			nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 5, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
		}
	}
	;do quest stuff
	if(PolarQuestComplete != 1) {
		if ((QuestLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestSpider && (nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (QuestWerewolf && (nowUnix()-LastBugrunWerewolf)>floor(3600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){
			nm_Bugrun()
		}
		if(VBState=1)
			return
		nm_PolarQuestProg()
		if(PolarQuestComplete) {
			if(CurrentAction!="Quest") {
				PreviousAction:=CurrentAction
				CurrentAction:="Quest"
			}
			nm_gotoQuestgiver("Polar")
			nm_PolarQuestProg()
			if(!PolarQuestComplete){
				nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 5, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
}
nm_QuestRotate(){
	global QuestGatherField, RotateQuest, BlackQuestCheck, BlackQuestComplete, LastBlackQuest, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete, HoneyQuestCheck, PolarQuestCheck, GatherFieldBoostedStart, LastGlitter, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, VBState, bitmaps

	if ((BlackQuestCheck=0) && (BuckoQuestCheck=0) && (RileyQuestCheck=0) && (HoneyQuestCheck=0) && (PolarQuestCheck=0))
		return
	if(VBState=1)
		return
	if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return

	;open quest log
	nm_OpenMenu("questlog")

	;polar bear quest
	nm_PolarQuest()

	if (QuestGatherField = "None") {
		;black bear quest first
		nm_BlackQuest()

		;black bear quest is complete but not yet time to turn in, move onto next quest
		if(BlackQuestCheck=0 || (BlackQuestComplete && (nowUnix()-LastBlackQuest)<3600)) {
			;bucko quest
			nm_BuckoQuest()
			if(BuckoQuestCheck=0 || BuckoQuestComplete=2) {
				nm_RileyQuest()
			}
		}
	}

	;honey bee quest
	nm_HoneyQuest()
}
nm_Feed(food){
	global bitmaps
	nm_setShiftLock(0)
	nm_Reset(0,0,0,1)
	nm_setStatus("Feeding", food)
	;feed
	nm_OpenMenu("itemmenu")
	nm_InventorySearch(food)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Max(480, windowHeight-120))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop, 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Missing", food)
						return 0
					}
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Max(480, windowHeight-120))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[food], pos, 0, 0, 306, Max(480, windowHeight-120), 10, , 5) = 0) || (nm_imgSearch("feeder.png",30)[1] = 0)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag, Left, windowX+30, windowY+SubStr(pos, InStr(pos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2-10*A_Index, 5
		sleep, 500
	}
	Sleep, 250
	;check if food is already visible
	imgPos := nm_imgSearch("feeder.png",30)
	If (imgPos[1]=0){
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+imgPos[2], windowY+imgPos[3]
		sleep 100
		Click
		sleep 100
		send 100
		sleep 1000
		imgPos := nm_imgSearch("feed.png",30)
		If (imgPos[1]=0){
			MouseMove, windowX+imgPos[2], windowY+imgPos[3]
			Click
			nm_setStatus("Completed", "Feed " food)
		}
		MouseMove, windowX+350, windowY+100
	}
	;close inventory
	nm_OpenMenu()
}
nm_RileyQuestProg(){
	global RileyQuestCheck, RileyBee, RileyQuest, RileyStart, HiveBees, FieldName1, LastAntPass, LastRedBoost, RileyLadybugs, RileyScorpions, RileyAll
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global RileyQuestComplete:=1
	global RileyQuestProgress
	global QuestAnt:=0
	global QuestRedBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state
	global LastBugrunLadybugs, MonsterRespawnTime, LastBugrunScorpions, bitmaps
	if(!RileyQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")
	;search for riley quest
	Loop, 70
	{
		Qfound:=nm_imgSearch("riley.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("riley2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		WinActivate, Roblox
		switch A_Index
		{
			case 1:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, windowX+30, windowY+200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")

			default:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			sendinput {WheelDown}
			Sleep, 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep, 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		RileyStart:=[ErrorLevel, FoundX-windowX, FoundY-windowY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			Loop, 3 {
				xi := windowX
				yi := windowY+RileyStart[3]+15
				ww := windowX+306
				wh := windowY+RileyStart[3]+100
				ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 nm_image_assets\questbargap.png
				if(ErrorLevel=0) {
					QuestBarSize:=FoundY-windowY-RileyStart[3]
					QuestBarGapSize:=3
					QuestBarInset:=3
					NextY:=FoundY+1
					NextX:=FoundX+1
					loop 20 {
						ImageSearch, FoundX, FoundY, FoundX, NextY, ww, wh, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=FoundY+1
							QuestBarGapSize:=QuestBarGapSize+1
						} else {
							break
						}
					}
					wh := windowY+RileyStart[3]+200
					loop 20 {
						ImageSearch, FoundX, FoundY, NextX, yi, ww, wh, *5 nm_image_assets\questbarinset.png
						if(ErrorLevel=0) {
							NextX:=FoundX+1
							QuestBarInset:=QuestBarInset+1
						} else {
							break
						}
					}
					break
					;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
				} else {
					MouseMove, windowX+30, windowY+225
					Sleep, 50
					send, {WheelDown 1}
					Sleep, 50
					RileyStart[3]-=150
					Sleep, 500
				}
			}
		}
		;determine Quest name
		xi := windowX
		yi := windowY+RileyStart[3]-30
		ww := windowX+306
		wh := windowY+RileyStart[3]
		for key, value in RileyBee {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				RileyQuest:=key
				questSteps:=RileyBee[key].length()
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+RileyStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, windowX+30, windowY+225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
						RileyStart[3]-=150
						Sleep, 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Riley quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestRedAnyField:=0
		RileyLadybugs:=0
		RileyScorpions:=0
		RileyAll:=0
		newLine:="|"
		rileyProgress:=""
		num:=RileyBee[RileyQuest].length()
		loop %num% {
			action:=RileyBee[RileyQuest][A_Index][2]
			where:=RileyBee[RileyQuest][A_Index][3]
			PixelGetColor, questbarColor, windowX+QuestBarInset+10, windowY+QuestBarSize*(RileyBee[RileyQuest][A_Index][1]-1)+RileyStart[3]+QuestBarGapSize+5, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				RileyQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Riley%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=35){
							where:="Pepper"
						} else if(HiveBees>=15){
							where:="Rose"
						} else if (HiveBees>=5) {
							where:="Strawberry"
						} else {
							where:="Mushroom"
						}
					} else if (where="blue") {
					 	if(HiveBees>=15){
							where:="Pine Tree"
						} else if (HiveBees>=5) {
							where:="Bamboo"
						} else {
							where:="Blue Flower"
						}
					} else if (where="white") {
						if (HiveBees>=10) {
							where:="Pineapple"
						} else if (HiveBees>=5) {
							where:="Spider"
						} else {
							where:="Sunflower"
						}
					} else if (where="any") {
						;where:=FieldName1
						where:="None"
						QuestRedAnyField:=1
					}
					QuestGatherField:=where
					QuestGatherFieldSlot:=RileyBee[RileyQuest][A_Index][1]
				}
				else if(action="get"){ ;Ant, RedBoost
					if(where="ant") {
						QuestAnt:=1
					}
					else if(where="RedBoost"){
						QuestRedBoost:=1
					}
				}
				else if(action="feed"){ ;Strawberries
					QuestFeed:=where
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=Format("{:d}",0x96C3DE)) && (questbarColor!=Format("{:d}",0xE5F0F7)) && (questbarColor!=Format("{:d}",0x1B2A35))) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				rileyProgress:=(RileyQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				rileyProgress:=(rileyProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		IniWrite, %rileyProgress%, settings\nm_config.ini, Quests, RileyQuestProgress
		GuiControl,,RileyQuestProgress, % StrReplace(rileyProgress, "|", "`n")
		if(RileyLadybugs=0 && RileyScorpions=0 && RileyAll=0 && QuestGatherField="None" && QuestAnt=0 && QuestRedBoost=0 && QuestFeed="None" && QuestRedAnyField=0){
			RileyQuestComplete:=1
		} else { ;check if all doable things are done and everything else is on cooldown
			if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (RileyLadybugs && (nowUnix()-LastBugrunLadybugs)<floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)<floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) { ;there is at least one thing no longer on cooldown
				RileyQuestComplete:=0
			} else {
				RileyQuestComplete:=2
			}
		}
	}
}
nm_RileyQuest(){
	global RileyQuestCheck, RileyQuestComplete, RileyQuest, RotateQuest, QuestGatherField, QuestAnt, QuestRedBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RileyLadybugs, RileyScorpions, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!RileyQuestCheck)
		return
	RotateQuest:="Riley"
	nm_RileyQuestProg()
	if(RileyQuestComplete=1) {
		if(CurrentAction!="Quest") {
			PreviousAction:=CurrentAction
			CurrentAction:="Quest"
		}
		nm_gotoQuestgiver("Riley")
		nm_RileyQuestProg()
		if(RileyQuestComplete!=1){
			nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 5, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
		}
	}
	if(RileyQuestComplete!=1){
		if(QuestFeed!="none") {
			if(CurrentAction!="Quest") {
				PreviousAction:=CurrentAction
				CurrentAction:="Quest"
			}
			nm_feed(QuestFeed)
		}
		if(QuestAnt)
			nm_Collect()
		if(QuestRedBoost)
			nm_ToAnyBooster()
		if((RileyLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) {
			nm_Bugrun()
		}
		if(VBState=1)
			return
		nm_RileyQuestProg()
		if(RileyQuestComplete=1) {
			nm_gotoQuestgiver("Riley")
			nm_RileyQuestProg()
			if(!RileyQuestComplete){
				nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 5, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
}
nm_BuckoQuestProg(){
	global BuckoQuestCheck, BuckoBee, BuckoQuest, BuckoStart, HiveBees, FieldName1, LastAntPass, LastBlueBoost, BuckoRhinoBeetles, BuckoMantis
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BuckoQuestComplete:=1
	global BuckoQuestProgress
	global QuestAnt:=0
	global QuestBlueBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state
	global MonsterRespawnTime, LastBugrunRhinoBeetles, LastBugrunMantis, bitmaps
	if(!BuckoQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")
	;search for bucko quest
	Loop, 70
	{
		Qfound:=nm_imgSearch("bucko.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("bucko2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		WinActivate, Roblox
		switch A_Index
		{
			case 1:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, windowX+30, windowY+200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")

			default:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			sendinput {WheelDown}
			Sleep, 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep, 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BuckoStart:=[ErrorLevel, FoundX-windowX, FoundY-windowY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			Loop, 3 {
				xi := windowX
				yi := windowY+BuckoStart[3]+15
				ww := windowX+306
				wh := windowY+BuckoStart[3]+100
				ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 nm_image_assets\questbargap.png
				if(ErrorLevel=0) {
					QuestBarSize:=FoundY-windowY-BuckoStart[3]
					QuestBarGapSize:=3
					QuestBarInset:=3
					NextY:=FoundY+1
					NextX:=FoundX+1
					loop 20 {
						ImageSearch, FoundX, FoundY, FoundX, NextY, ww, wh, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=FoundY+1
							QuestBarGapSize:=QuestBarGapSize+1
						} else {
							break
						}
					}
					wh := windowY+BuckoStart[3]+200
					loop 20 {
						ImageSearch, FoundX, FoundY, NextX, yi, ww, wh, *5 nm_image_assets\questbarinset.png
						if(ErrorLevel=0) {
							NextX:=FoundX+1
							QuestBarInset:=QuestBarInset+1
						} else {
							break
						}
					}
					break
					;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
				} else {
					MouseMove, windowX+30, windowY+225
					Sleep, 50
					send, {WheelDown 1}
					Sleep, 50
					BuckoStart[3]-=150
					Sleep, 500
				}
			}
		}
		;determine Quest name
		xi := windowX
		yi := windowY+BuckoStart[3]-30
		ww := windowX+306
		wh := windowY+BuckoStart[3]
		for key, value in BuckoBee {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				BuckoQuest:=key
				questSteps:=BuckoBee[key].length()
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BuckoStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, windowX+30, windowY+225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
						BuckoStart[3]-=150
						Sleep, 500
					} else {
						break 2
					}
				}
				break
			}
		}
		;Update Bucko quest progress in GUI
		;also set next steps
		BuckoRhinoBeetles:=0
		BuckoMantis:=0
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestBlueAnyField:=0
		QuestAnt:=0
		newLine:="|"
		buckoProgress:=""
		num:=BuckoBee[BuckoQuest].length()
		loop %num% {
			action:=BuckoBee[BuckoQuest][A_Index][2]
			where:=BuckoBee[BuckoQuest][A_Index][3]
			PixelGetColor, questbarColor, windowX+QuestBarInset+10, windowY+QuestBarSize*(BuckoBee[BuckoQuest][A_Index][1]-1)+BuckoStart[3]+QuestBarGapSize+5, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				BuckoQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Bucko%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=35){
							where:="Pepper"
						} else if(HiveBees>=15){
							where:="Rose"
						} else if (HiveBees>=5) {
							where:="Strawberry"
						} else {
							where:="Mushroom"
						}
					} else if (where="blue") {
						if(HiveBees>=15){
							where:="Pine Tree"
						} else if (HiveBees>=5) {
							where:="Bamboo"
						} else {
							where:="Blue Flower"
						}
					} else if (where="white") {
						if (HiveBees>=10) {
							where:="Pineapple"
						} else if (HiveBees>=5) {
							where:="Spider"
						} else {
							where:="Sunflower"
						}
					} else if (where="any") {
						;where:=FieldName1
						where:="None"
						QuestBlueAnyField:=1
					}
					QuestGatherField:=where
					QuestGatherFieldSlot:=BuckoBee[BuckoQuest][A_Index][1]
				}
				else if(action="get"){ ;Ant, BlueBoost
					if(where="ant") {
						QuestAnt:=1
					}
					else if(where="BlueBoost"){
						QuestBlueBoost:=1
					}
				}
				else if(action="feed"){ ;Blueberries
					QuestFeed:=where
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=Format("{:d}",0x96C3DE)) && (questbarColor!=Format("{:d}",0xE5F0F7)) && (questbarColor!=Format("{:d}",0x1B2A35))) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				buckoProgress:=(BuckoQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				buckoProgress:=(buckoProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		IniWrite, %buckoProgress%, settings\nm_config.ini, Quests, BuckoQuestProgress
		GuiControl,,BuckoQuestProgress, % StrReplace(buckoProgress, "|", "`n")
		if(BuckoRhinoBeetles=0 && BuckoMantis=0 && QuestGatherField="None" && QuestAnt=0 && QuestBlueBoost=0 && QuestFeed="None" && QuestBlueAnyField=0) {
				BuckoQuestComplete:=1
			} else { ;check if all doable things are done and everything else is on cooldown
				if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)<floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)<floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) { ;there is at least one thing no longer on cooldown
					BuckoQuestComplete:=0
				} else {
					BuckoQuestComplete:=2
				}
			}
	}
}
nm_BuckoQuest(){
	global BuckoQuestCheck, BuckoQuestComplete, BuckoQuest, RotateQuest, QuestGatherField, QuestAnt, QuestBlueBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, BuckoRhinoBeetles, BuckoMantis, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!BuckoQuestCheck)
		return
	RotateQuest:="Bucko"
	nm_BuckoQuestProg()
	if(BuckoQuestComplete=1) {
		if(CurrentAction!="Quest") {
			PreviousAction:=CurrentAction
			CurrentAction:="Quest"
		}
		nm_gotoQuestgiver("Bucko")
		nm_BuckoQuestProg()
		if(BuckoQuestComplete!=1){
			nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 5, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
		}
	}
	if(BuckoQuestComplete!=1){
		if(QuestFeed!="none") {
			if(CurrentAction!="Quest") {
				PreviousAction:=CurrentAction
				CurrentAction:="Quest"
			}
			nm_feed(QuestFeed)
		}
		if(QuestAnt)
			nm_Collect()
		if(QuestBlueBoost)
			nm_ToAnyBooster()
		if((BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))) {
			nm_Bugrun()
		}
		if(VBState=1)
			return
		nm_BuckoQuestProg()
		if(BuckoQuestComplete=1) {
			nm_gotoQuestgiver("Bucko")
			nm_BuckoQuestProg()
			if(!BuckoQuestComplete){
				nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 5, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
				IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
}
nm_BlackQuestProg(){
	global BlackQuestCheck, BlackBear, BlackQuest, BlackStart, HiveBees, FieldName1
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BlackQuestComplete:=1
	global BlackQuestProgress
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!BlackQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")
	;search for black quest
	Loop, 70
	{
		Qfound:=nm_imgSearch("black_bear.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear2.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear3.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear4.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		WinActivate, Roblox
		switch A_Index
		{
			case 1:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, windowX+30, windowY+200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")

			default:
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			MouseMove, windowX+30, windowY+200, 5
			sendinput {WheelDown}
			Sleep, 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep, 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+350, windowY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BlackStart:=[ErrorLevel, FoundX-windowX, FoundY-windowY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			Loop, 3 {
				xi := windowX
				yi := windowY+BlackStart[3]+15
				ww := windowX+306
				wh := windowY+BlackStart[3]+100
				ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *5 nm_image_assets\questbargap.png
				if(ErrorLevel=0) {
					QuestBarSize:=FoundY-windowY-BlackStart[3]
					QuestBarGapSize:=3
					QuestBarInset:=3
					NextY:=FoundY+1
					NextX:=FoundX+1
					loop 20 {
						ImageSearch, FoundX, FoundY, FoundX, NextY, ww, wh, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=FoundY+1
							QuestBarGapSize:=QuestBarGapSize+1
						} else {
							break
						}
					}
					wh := windowY+BlackStart[3]+200
					loop 20 {
						ImageSearch, FoundX, FoundY, NextX, yi, ww, wh, *5 nm_image_assets\questbarinset.png
						if(ErrorLevel=0) {
							NextX:=FoundX+1
							QuestBarInset:=QuestBarInset+1
						} else {
							break
						}
					}
					break
					;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
				} else {
					MouseMove, windowX+30, windowY+225
					Sleep, 50
					send, {WheelDown 1}
					Sleep, 50
					BlackStart[3]-=150
					Sleep, 500
				}
			}
		}
		;determine Quest name
		xi := windowX
		yi := windowY+BlackStart[3]-30
		ww := windowX+306
		wh := windowY+BlackStart[3]
		for key, value in BlackBear {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, xi, yi, ww, wh, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				BlackQuest:=key
				questSteps:=BlackBear[key].length()
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BlackStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, windowX+30, windowY+225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
						BlackStart[3]-=150
						Sleep, 500
					} else {
						break 2
					}
				}
				Break
			}
		}
		;Update Black quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestBlackAnyField:=0
		newLine:="|"
		blackProgress:=""
		num:=BlackBear[BlackQuest].length()
		loop %num% {
			action:=BlackBear[BlackQuest][A_Index][2]
			where:=BlackBear[BlackQuest][A_Index][3]
			PixelGetColor, questbarColor, windowX+QuestBarInset+10, windowY+QuestBarSize*(BlackBear[BlackQuest][A_Index][1]-1)+BlackStart[3]+QuestBarGapSize+5, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				BlackQuestComplete:=0
				completeness:="Incomplete"
				;red, blue, white, any
				if(where="red"){
					if(HiveBees>=35){
						where:="Pepper"
					} else if(HiveBees>=15){
						where:="Rose"
					} else if (HiveBees>=5) {
						where:="Strawberry"
					} else {
						where:="Mushroom"
					}
				} else if (where="blue") {
					if(HiveBees>=15){
						where:="Pine Tree"
					} else if (HiveBees>=5) {
						where:="Bamboo"
					} else {
						where:="Blue Flower"
					}
				} else if (where="white") {
					if (HiveBees>=10) {
						where:="Pineapple"
					} else if (HiveBees>=5) {
						where:="Spider"
					} else {
						where:="Sunflower"
					}
				} else if (where="any") {
					;where:=FieldName1
					where:="None"
					QuestBlackAnyField:=1
				}
				if(QuestGatherField="None") {
					QuestGatherField:=where
					QuestGatherFieldSlot:=BlackBear[BlackQuest][A_Index][1]
				}
			}
			;border color, white (titlebar), black (text)
			else if((questbarColor!=Format("{:d}",0x96C3DE)) && (questbarColor!=Format("{:d}",0xE5F0F7)) && (questbarColor!=Format("{:d}",0x1B2A35))) {
				completeness:="Complete"
				if(action="kill"){
					Quest%where%:=0
				}
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				blackProgress:=(BlackQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				blackProgress:=(blackProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		IniWrite, %blackProgress%, settings\nm_config.ini, Quests, BlackQuestProgress
		GuiControl,,BlackQuestProgress, % StrReplace(blackProgress, "|", "`n")
		if(QuestGatherField="None" && QuestBlackAnyField=0) {
			BlackQuestComplete:=1
		}
	}
}
nm_BlackQuest(){
	global BlackQuestCheck, BlackQuestComplete, BlackQuest, LastBlackQuest, RotateQuest, QuestGatherField, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete
	if(!BlackQuestCheck)
		return
	RotateQuest:="Black"
	nm_BlackQuestProg()
	if(BlackQuestComplete && (nowUnix()-LastBlackQuest)>3600) {
		if(CurrentAction!="Quest") {
			PreviousAction:=CurrentAction
			CurrentAction:="Quest"
		}
		nm_gotoQuestgiver("Black")
		nm_BlackQuestProg()
		if(!BlackQuestComplete){
			nm_setStatus("Starting", "Black Bear Quest: " . BlackQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 5, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalQuestsComplete%, settings\nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, settings\nm_config.ini, Status, SessionQuestsComplete
		}
		LastBlackQuest:=nowUnix()
		IniWrite, %LastBlackQuest%, settings\nm_config.ini, Quests, LastBlackQuest
	}
}
nm_gotoQuestgiver(giver){
	global
	static paths := {}, SetMoveMethod, SetHiveSlot, SetHiveBees
	local success, searchRet, windowX, windowY, windowWidth, windowHeight

	nm_setShiftLock(0)

	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot) || (SetHiveBees != HiveBees))
	{
		#Include %A_ScriptDir%\paths\gtq-polar.ahk
		#Include %A_ScriptDir%\paths\gtq-honey.ahk
		#Include %A_ScriptDir%\paths\gtq-black.ahk
		#Include %A_ScriptDir%\paths\gtq-riley.ahk
		#Include %A_ScriptDir%\paths\gtq-bucko.ahk
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot, SetHiveBees := HiveBees
	}

	success:=0
	Loop, 2
	{
		nm_Reset()

		HiveConfirmed:=0

		nm_setStatus("Traveling", "Questgiver: " giver)

		InStr(paths[giver], "gotoramp") ? nm_gotoRamp()
		InStr(paths[giver], "gotocannon") ? nm_gotoCannon()

		nm_createWalk(paths[giver])
		KeyWait, F14, D T5 L
		KeyWait, F14, T120 L
		nm_endWalk()

		Loop, 2
		{
			Sleep, 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				success:=1
				sendinput {%SC_E% down}
				Sleep, 100
				sendinput {%SC_E% up}
				sleep, 2000
				Loop, 500
				{
					WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], pos, , , , , 10, , 3) = 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
					Click
					sleep, 150
				}
				MouseMove, windowX+350, windowY+100
			}
		}

		QuestGatherField:="None"
		if(success)
			return
	}
}
nm_bugDeathCheck(){
	global objective, TotalBugKills, SessionBugKills, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, BugDeathCheckLockout, BugrunLadybugsCheck, BugrunRhinoBeetlesCheck, BugrunMantisCheck, BugrunWerewolfCheck
	if(BugDeathCheckLockout && (nowUnix() - BugDeathCheckLockout)>20)
		BugDeathCheckLockout:=0
	if(BugDeathCheckLockout)
		return
	;ladybugs
	if(InStr(objective,"strawberry") || InStr(objective,"mushroom") || InStr(objective,"clover")) {
		searchRet := nm_imgSearch("ladybug.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunLadybugs:=nowUnix()
			IniWrite, %LastBugrunLadybugs%, settings\nm_config.ini, Collect, LastBugrunLadybugs
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;rhino beetles
	else if(InStr(objective,"blue flower") || InStr(objective,"bamboo")) {
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, settings\nm_config.ini, Collect, LastBugrunRhinoBeetles
			if(InStr(objective,"bamboo")) {
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 2
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
			} else {
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				Prev_DetectHiddenWindows := A_DetectHiddenWindows
				Prev_TitleMatchMode := A_TitleMatchMode
				DetectHiddenWindows On
				SetTitleMatchMode 2
				if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
					PostMessage, 0x5555, 3, 1
				}
				DetectHiddenWindows %Prev_DetectHiddenWindows%
				SetTitleMatchMode %Prev_TitleMatchMode%
			}
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;spider
	else if(InStr(objective,"spider")) {
		searchRet := nm_imgSearch("spider.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunSpider:=nowUnix()
			IniWrite, %LastBugrunSpider%, settings\nm_config.ini, Collect, LastBugrunSpider
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;mantis/rhino beetle
	else if(InStr(objective,"pineapple")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite, %LastBugrunMantis%, settings\nm_config.ini, Collect, LastBugrunMantis
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			if(!BugrunMantisCheck)
				BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, settings\nm_config.ini, Collect, LastBugrunRhinoBeetles
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;mantis/werewolf
	else if(InStr(objective,"pine tree")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite, %LastBugrunMantis%, settings\nm_config.ini, Collect, LastBugrunMantis
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 2
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite, %LastBugrunWerewolf%, settings\nm_config.ini, Collect, LastBugrunWerewolf
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;werewolf
	else if(InStr(objective,"pumpkin") || InStr(objective,"cactus")) {
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite, %LastBugrunWerewolf%, settings\nm_config.ini, Collect, LastBugrunWerewolf
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
	;scorpions
	else if(InStr(objective,"rose")) {
		searchRet := nm_imgSearch("scorpion.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunScorpions:=nowUnix()
			IniWrite, %LastBugrunScorpions%, settings\nm_config.ini, Collect, LastBugrunScorpions
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			Prev_DetectHiddenWindows := A_DetectHiddenWindows
			Prev_TitleMatchMode := A_TitleMatchMode
			DetectHiddenWindows On
			SetTitleMatchMode 2
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, 3, 1
			}
			DetectHiddenWindows %Prev_DetectHiddenWindows%
			SetTitleMatchMode %Prev_TitleMatchMode%
			IniWrite, %TotalBugKills%, settings\nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, settings\nm_config.ini, Status, SessionBugKills
		}
	}
}
nm_ReadIni(path)
{
	global
	local ini, str, c, p, k

	ini := FileOpen(path, "r"), str := ini.Read(), ini.Close()
	Loop, Parse, str, `r`n, %A_Space%%A_Tab%
	{
		switch (c := SubStr(A_LoopField, 1, 1))
		{
			; ignore comments and section names
			case "[",";":
			continue

			default:
			if (p := InStr(A_LoopField, "="))
				k := SubStr(A_LoopField, 1, p-1), %k% := SubStr(A_LoopField, p+1)
		}
	}
}
nm_LoadFieldDefaults()
{
	global FieldDefault

	ini := FileOpen(A_ScriptDir "\settings\field_config.ini", "r"), str := ini.Read(), ini.Close()
	Loop, Parse, str, `r`n, %A_Space%%A_Tab%
	{
		switch (c := SubStr(A_LoopField, 1, 1))
		{
			; ignore comments and section names
			case "[":
			s := SubStr(A_LoopField, 2, -1)

			case ";":
			continue

			default:
			if (p := InStr(A_LoopField, "="))
				k := SubStr(A_LoopField, 1, p-1), FieldDefault[s][k] := SubStr(A_LoopField, p+1)
		}
	}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NATRO ENHANCEMENT FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ba_planterSwitch(){
	global PlanterMode, MaxAllowedPlanters, HarvestFullGrown, AutomaticHarvestInterval, MPageIndex
	static PlantersPlusControls := ["N1Priority","N2Priority","N3Priority","N4Priority","N5Priority","N1MinPercent","N2MinPercent","N3MinPercent","N4MinPercent","N5MinPercent","DandelionFieldCheck","SunflowerFieldCheck","MushroomFieldCheck","BlueFlowerFieldCheck","CloverFieldCheck","SpiderFieldCheck","StrawberryFieldCheck","BambooFieldCheck","PineappleFieldCheck","StumpFieldCheck","PumpkinFieldCheck","PineTreeFieldCheck","RoseFieldCheck","MountainTopFieldCheck","CactusFieldCheck","CoconutFieldCheck","PepperFieldCheck","Text1","Text2","Text3","Text4","Text5","TextLine1","TextLine2","TextLine3","TextLine4","TextLine5","TextLine6","TextLine7","TextZone1","TextZone2","TextZone3","TextZone4","TextZone5","TextZone6","NPreset","TextPresets","TextNp","TextMin","PlasticPlanterCheck","CandyPlanterCheck","BlueClayPlanterCheck","RedClayPlanterCheck","TackyPlanterCheck","PesticidePlanterCheck","HeatTreatedPlanterCheck","HydroponicPlanterCheck","PetalPlanterCheck","PlanterOfPlentyCheck","PaperPlanterCheck","TicketPlanterCheck","TextHarvest","HarvestFullGrown","gotoPlanterField","gatherFieldSipping","TextHours","TextMax","MaxAllowedPlanters","MaxAllowedPlantersEdit","TextAllowedPlanters","TextAllowedFields","TimersButton","AutomaticHarvestInterval","ConvertFullBagHarvest","GatherPlanterLoot","TextBox1"]
	, ManualPlantersControls := ["MHeader1Text","MHeader2Text","MHeader3Text","MSlot1PlanterText","MSlot1FieldText","MSlot1SettingsText","MSlot1SeparatorLine","MSlot2PlanterText","MSlot2FieldText","MSlot2SettingsText","MSlot2SeparatorLine","MSlot3PlanterText","MSlot3FieldText","MSlot3SettingsText","MSectionSeparatorLine","MSliderSeparatorLine","MSlot1CycleText","MSlot1LocationText","MSlot1Left","MSlot1ChangeText","MSlot1Right","MSlot2CycleText","MSlot2LocationText","MSlot2Left","MSlot2ChangeText","MSlot2Right","MSlot3CycleText","MSlot3LocationText","MSlot3Left","MSlot3ChangeText","MSlot3Right","MHarvestText","MHarvestInterval","MPageLeft","MPageNumberText","MPageRight"]
	, ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"]

	GuiControlGet, PlanterMode
	GuiControl, Disable, PlanterMode

	for i,c in ["Hide","Show"] ; hide first, then show
	{
		if (((i = 1) && (PlanterMode != 2)) || ((i = 2) && (PlanterMode = 2))) ; hide/show all planters+ controls
		{
			for k,v in PlantersPlusControls
				GuiControl, %c%, %v%
			GuiControl, %c%, % (HarvestFullGrown ? "FullText" : AutomaticHarvestInterval ? "AutoText" : "HarvestInterval")
		}

		if (((i = 1) && (PlanterMode != 1)) || ((i = 2) && (PlanterMode = 1))) ; hide/show all manual planters controls
		{
			for k,v in ManualPlantersControls
				GuiControl, %c%, %v%
			Loop, 3
			{
				i := A_Index
				for k,v in ManualPlantersOptions
					Loop, 3
						GuiControl, %c%, % "MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v
			}
		}
	}

	; handle MaxAllowedPlanters
	GuiControlGet, MaxAllowedPlanters
	if ((PlanterMode = 2) && (MaxAllowedPlanters = 0)) {
		MaxAllowedPlanters:=3
		IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
		GuiControl,,MaxAllowedPlanters,3
	}

	; handle PlanterTimers window
	if (PlanterMode = 0)
	{
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows, On
		SetTitleMatchMode, 2
		if WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
			WinClose
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
		SetTitleMatchMode, %Prev_TitleMatchMode%
	}

	IniWrite, %PlanterMode%, settings\nm_config.ini, gui, PlanterMode
	GuiControl, Enable, PlanterMode
}
ba_maxAllowedPlantersSwitch(){
	GuiControlGet, MaxAllowedPlanters
	if(MaxAllowedPlanters=0){
		GuiControl,, PlanterMode, 1
		ba_planterSwitch()
	} else {
		GuiControl,, PlanterMode, 2
	}
	ba_saveConfig_()
}
ba_N1unswitch_(){
	guiControlGet, nPreset
    GuiControlGet, n1priority
	GuiControlGet, n2priority
	GuiControlGet, n3priority
	GuiControlGet, n4priority
	GuiControlGet, n5priority
	global n1string
	global n2string
	global n3string
	global n4string
	global n5string
    ;GuiControl,,currentp1Field,Current Field:`n%p1Choice1%
	GuiControl,chooseString,n2priority,None
	GuiControl,chooseString,n3priority,None
	GuiControl,chooseString,n4priority,None
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n2minPercent,10
	GuiControl,chooseString,n3minPercent,10
	GuiControl,chooseString,n4minPercent,10
	GuiControl,chooseString,n5minPercent,10
    GuiControl,chooseString,nectarPreset,None
	if ((nPreset="Blue" && n1Priority!="Comforting") || (nPreset="Red" && n1Priority!="Invigorating") || (nPreset="White" && n1Priority!="Satisfying")) {
		nPreset:=Custom
		guiControl,ChooseString,nPreset,Custom
		ba_nPresetSwitch_()
	}
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N2unswitch_(){
    GuiControlGet, n2priority
	GuiControl,chooseString,n3priority,None
	GuiControl,chooseString,n4priority,None
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n3minPercent,10
	GuiControl,chooseString,n4minPercent,10
	GuiControl,chooseString,n5minPercent,10
    GuiControl,chooseString,nectarPreset,None

	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N3unswitch_(){
    GuiControlGet, n3priority
	GuiControl,chooseString,n4priority,None
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n2minPercent,10
	GuiControl,chooseString,n3minPercent,10

    GuiControl,chooseString,nectarPreset,None
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N4unswitch_(){
    GuiControlGet, n4priority
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n5minPercent,10
    GuiControl,chooseString,nectarPreset,None
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N5unswitch_(){
    GuiControlGet, n5priority
	GuiControl,chooseString,nectarPreset,None
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N1Punswitch_(){
	GuiControlGet, n1priority
	if(n1priority="none"){
		GuiControl,chooseString,n1minPercent,10
	}
	GuiControlGet, n1minPercent
	ba_saveConfig_()
}
ba_N2Punswitch_(){
	GuiControlGet, n2priority
	if(n2priority="none"){
		GuiControl,chooseString,n2minPercent,10
	}
	GuiControlGet, n2minPercent
	ba_saveConfig_()
}
ba_N3Punswitch_(){
	GuiControlGet, n3priority
	if(n3priority="none"){
		GuiControl,chooseString,n3minPercent,10
	}
	GuiControlGet, n3minPercent
	ba_saveConfig_()
}
ba_N4Punswitch_(){
	GuiControlGet, n4priority
	if(n4priority="none"){
		GuiControl,chooseString,n4minPercent,10
	}
	GuiControlGet, n4minPercent
	ba_saveConfig_()
}
ba_N5Punswitch_(){
	GuiControlGet, n5priority
	if(n5priority="none"){
		GuiControl,chooseString,n5minPercent,10
	}
	GuiControlGet, n5minPercent
	ba_saveConfig_()
}
ba_AutoHarvestSwitch_(){
	global AutomaticHarvestInterval
	GuiControlGet, AutomaticHarvestInterval
	if(AutomaticHarvestInterval) {
		GuiControl, Hide, HarvestInterval
		GuiControl, Hide, FullText
		GuiControl, Show, AutoText
		GuiControl,, HarvestFullGrown, 0
	} else {
		GuiControl, Show, HarvestInterval
		GuiControl, Hide, FullText
		GuiControl, Hide, AutoText
	}
	ba_saveConfig_()
}
ba_HarvestFullGrownSwitch_(){
	global HarvestFullGrown
	GuiControlGet, HarvestFullGrown
	if(HarvestFullGrown) {
		GuiControl, Hide, HarvestInterval
		GuiControl, Hide, AutoText
		GuiControl, Show, FullText
		GuiControl,, AutomaticHarvestInterval, 0
	} else {
		GuiControl, Show, HarvestInterval
		GuiControl, Hide, FullText
		GuiControl, Hide, AutoText
	}
	ba_saveConfig_()
}
ba_gotoPlanterFieldSwitch_(){
	global gotoPlanterField
	GuiControlGet, GotoPlanterField
	if(GotoPlanterField){
		Guicontrol,,GotoPlanterField,0
		msgbox, 1, WARNING!!,You have selected to "Only Gather in Planter Field".`n`nI understand that by selecting this option will cause the macro to IGNORE the gathering fields specified in the Main tab.`n`nEnabling this option will make you gather in a field that contains a planter as selected by Planters+ instead.`n`nI understand that this option will result in gathering Nectar much faster but will also result in less pollen/honey collection overall.
		IfMsgBox Ok
		{
			Guicontrol,,GotoPlanterField,1
		} else {
			Guicontrol,,GotoPlanterField,0
		}
	}
	ba_saveConfig_()
}

ba_gatherFieldSippingSwitch_(){
	global GatherFieldSipping
	GuiControlGet, GatherFieldSipping
	if(GatherFieldSipping){
		Guicontrol,,GatherFieldSipping,0
		msgbox, 1, INFORMATION,You have selected to "Gather Field Nectar Sipping".`n`nThis option will force planters to always be placed in your current gathering field if you need the nectar type that field provides.  This is done regardless of the allowed field selections.  This will allow your bees to sip from the planter and greatly increase the amount of nectar gained.
		IfMsgBox Ok
		{
			Guicontrol,,GatherFieldSipping,1
		} else {
			Guicontrol,,GatherFieldSipping,0
		}
	}
	ba_saveConfig_()
}


ba_nPresetSwitch_(){
	guiControlGet, nPreset
	if (nPreset="Blue"){
		GuiControl,ChooseString,n1Priority,Comforting
		ba_N1unswitch_()
		GuiControl,ChooseString,n2Priority,Motivating
		ba_N2unswitch_()
		GuiControl,ChooseString,n3Priority,Satisfying
		ba_N3unswitch_()
		GuiControl,ChooseString,n4Priority,Refreshing
		ba_N4unswitch_()
		GuiControl,ChooseString,n5Priority,Invigorating
		ba_N5unswitch_()
		GuiControl,chooseString,n1minPercent,70 ;COM
		GuiControl,chooseString,n2minPercent,80 ;MOT
		GuiControl,chooseString,n3minPercent,80 ;SAT
		GuiControl,chooseString,n4minPercent,80 ;REF
		GuiControl,chooseString,n5minPercent,40 ;INV
		;COM
		Guicontrol,,DandelionFieldCheck,1
		Guicontrol,,BambooFieldCheck,0
		Guicontrol,,PineTreeFieldCheck,1
		;MOT
		Guicontrol,,MushroomFieldCheck,0
		Guicontrol,,SpiderFieldCheck,1
		Guicontrol,,RoseFieldCheck,1
		Guicontrol,,StumpFieldCheck,0
		;SAT
		Guicontrol,,SunflowerFieldCheck,1
		Guicontrol,,PineappleFieldCheck,1
		Guicontrol,,PumpkinFieldCheck,0
		;REF
		Guicontrol,,BlueFlowerFieldCheck,1
		Guicontrol,,StrawberryFieldCheck,1
		Guicontrol,,CoconutFieldCheck,0
		;INV
		Guicontrol,,CloverFieldCheck,1
		Guicontrol,,CactusFieldCheck,1
		Guicontrol,,MountainTopFieldCheck,0
		Guicontrol,,PepperFieldCheck,1
	} else if (nPreset="Red") {
		GuiControl,ChooseString,n1Priority,Invigorating
		ba_N1unswitch_()
		GuiControl,ChooseString,n2Priority,Refreshing
		ba_N2unswitch_()
		GuiControl,ChooseString,n3Priority,Motivating
		ba_N3unswitch_()
		GuiControl,ChooseString,n4Priority,Satisfying
		ba_N4unswitch_()
		GuiControl,ChooseString,n5Priority,Comforting
		ba_N5unswitch_()
		GuiControl,chooseString,n1minPercent,70 ;INV
		GuiControl,chooseString,n2minPercent,80 ;REF
		GuiControl,chooseString,n3minPercent,80 ;MOT
		GuiControl,chooseString,n4minPercent,80 ;SAT
		GuiControl,chooseString,n5minPercent,40 ;COM
		;INV
		Guicontrol,,CloverFieldCheck,0
		Guicontrol,,CactusFieldCheck,1
		Guicontrol,,MountainTopFieldCheck,0
		Guicontrol,,PepperFieldCheck,1
		;REF
		Guicontrol,,BlueFlowerFieldCheck,1
		Guicontrol,,StrawberryFieldCheck,1
		Guicontrol,,CoconutFieldCheck,0
		;MOT
		Guicontrol,,MushroomFieldCheck,0
		Guicontrol,,SpiderFieldCheck,1
		Guicontrol,,RoseFieldCheck,1
		Guicontrol,,StumpFieldCheck,0
		;SAT
		Guicontrol,,SunflowerFieldCheck,1
		Guicontrol,,PineappleFieldCheck,1
		Guicontrol,,PumpkinFieldCheck,1
		;COM
		Guicontrol,,DandelionFieldCheck,1
		Guicontrol,,BambooFieldCheck,1
		Guicontrol,,PineTreeFieldCheck,1
	} else if (nPreset="White") {
		GuiControl,ChooseString,n1Priority,Satisfying
		ba_N1unswitch_()
		GuiControl,ChooseString,n2Priority,Motivating
		ba_N2unswitch_()
		GuiControl,ChooseString,n3Priority,Refreshing
		ba_N3unswitch_()
		GuiControl,ChooseString,n4Priority,Comforting
		ba_N4unswitch_()
		GuiControl,ChooseString,n5Priority,Invigorating
		ba_N5unswitch_()
		GuiControl,chooseString,n1minPercent,70 ;SAT
		GuiControl,chooseString,n2minPercent,80 ;MOT
		GuiControl,chooseString,n3minPercent,80 ;REF
		GuiControl,chooseString,n4minPercent,80 ;COM
		GuiControl,chooseString,n5minPercent,40 ;INV
		;SAT
		Guicontrol,,SunflowerFieldCheck,1
		Guicontrol,,PineappleFieldCheck,1
		Guicontrol,,PumpkinFieldCheck,0
		;MOT
		Guicontrol,,MushroomFieldCheck,0
		Guicontrol,,SpiderFieldCheck,1
		Guicontrol,,RoseFieldCheck,1
		Guicontrol,,StumpFieldCheck,0
		;REF
		Guicontrol,,BlueFlowerFieldCheck,1
		Guicontrol,,StrawberryFieldCheck,1
		Guicontrol,,CoconutFieldCheck,0
		;COM
		Guicontrol,,DandelionFieldCheck,1
		Guicontrol,,BambooFieldCheck,1
		Guicontrol,,PineTreeFieldCheck,1
		;INV
		Guicontrol,,CloverFieldCheck,1
		Guicontrol,,CactusFieldCheck,1
		Guicontrol,,MountainTopFieldCheck,0
		Guicontrol,,PepperFieldCheck,1
	}
	ba_saveConfig_()
}
ba_saveConfig_(){
	global
	guiControlGet, nPreset
    GuiControlGet, n1priority
	GuiControlGet, n2priority
	GuiControlGet, n3priority
	GuiControlGet, n4priority
	GuiControlGet, n5priority
	GuiControlGet, n1minPercent
	GuiControlGet, n2minPercent
	GuiControlGet, n3minPercent
	GuiControlGet, n4minPercent
	GuiControlGet, n5minPercent
	GuiControlGet, HarvestInterval
	GuiControlGet, AutomaticHarvestInterval
	GuiControlGet, HarvestFullGrown
	GuiControlGet, GotoPlanterField
	GuiControlGet, GatherFieldSipping
	GuiControlGet, ConvertFullBagHarvest
	GuiControlGet, GatherPlanterLoot
	GuiControlGet, PlasticPlanterCheck
	GuiControlGet, CandyPlanterCheck
	GuiControlGet, BlueClayPlanterCheck
	GuiControlGet, RedClayPlanterCheck
	GuiControlGet, TackyPlanterCheck
	GuiControlGet, PesticidePlanterCheck
	GuiControlGet, HeatTreatedPlanterCheck
	GuiControlGet, HydroponicPlanterCheck
	GuiControlGet, PetalPlanterCheck
	GuiControlGet, PaperPlanterCheck
	GuiControlGet, TicketPlanterCheck
	GuiControlGet, PlanterOfPlentyCheck
	GuiControlGet, BambooFieldCheck
	GuiControlGet, BlueFlowerFieldCheck
	GuiControlGet, CactusFieldCheck
	GuiControlGet, CloverFieldCheck
	GuiControlGet, CoconutFieldCheck
	GuiControlGet, DandelionFieldCheck
	GuiControlGet, MountainTopFieldCheck
	GuiControlGet, MushroomFieldCheck
	GuiControlGet, PepperFieldCheck
	GuiControlGet, PineTreeFieldCheck
	GuiControlGet, PineappleFieldCheck
	GuiControlGet, PumpkinFieldCheck
	GuiControlGet, RoseFieldCheck
	GuiControlGet, SpiderFieldCheck
	GuiControlGet, StrawberryFieldCheck
	GuiControlGet, StumpFieldCheck
	GuiControlGet, SunflowerFieldCheck
	GuiControlGet, PlanterMode
	GuiControlGet, MaxAllowedPlanters
	IniWrite, %nPreset%, settings\nm_config.ini, gui, nPreset
    IniWrite, %n1priority%, settings\nm_config.ini, gui, n1priority
	IniWrite, %n2priority%, settings\nm_config.ini, gui, n2priority
	IniWrite, %n3priority%, settings\nm_config.ini, gui, n3priority
	IniWrite, %n4priority%, settings\nm_config.ini, gui, n4priority
	IniWrite, %n5priority%, settings\nm_config.ini, gui, n5priority
	IniWrite, %n1string%, settings\nm_config.ini, gui, n1string
	IniWrite, %n2string%, settings\nm_config.ini, gui, n2string
	IniWrite, %n3string%, settings\nm_config.ini, gui, n3string
	IniWrite, %n4string%, settings\nm_config.ini, gui, n4string
	IniWrite, %n5string%, settings\nm_config.ini, gui, n5string
	IniWrite, %n1minPercent%, settings\nm_config.ini, gui, n1minPercent
	IniWrite, %n2minPercent%, settings\nm_config.ini, gui, n2minPercent
	IniWrite, %n3minPercent%, settings\nm_config.ini, gui, n3minPercent
	IniWrite, %n4minPercent%, settings\nm_config.ini, gui, n4minPercent
	IniWrite, %n5minPercent%, settings\nm_config.ini, gui, n5minPercent
	IniWrite, %PlasticPlanterCheck%, settings\nm_config.ini, gui, PlasticPlanterCheck
	IniWrite, %CandyPlanterCheck%, settings\nm_config.ini, gui, CandyPlanterCheck
	IniWrite, %BlueClayPlanterCheck%, settings\nm_config.ini, gui, BlueClayPlanterCheck
	IniWrite, %RedClayPlanterCheck%, settings\nm_config.ini, gui, RedClayPlanterCheck
	IniWrite, %TackyPlanterCheck%, settings\nm_config.ini, gui, TackyPlanterCheck
	IniWrite, %PesticidePlanterCheck%, settings\nm_config.ini, gui, PesticidePlanterCheck
	IniWrite, %HeatTreatedPlanterCheck%, settings\nm_config.ini, gui, HeatTreatedPlanterCheck
	IniWrite, %HydroponicPlanterCheck%, settings\nm_config.ini, gui, HydroponicPlanterCheck
	IniWrite, %PetalPlanterCheck%, settings\nm_config.ini, gui, PetalPlanterCheck
	IniWrite, %PaperPlanterCheck%, settings\nm_config.ini, gui, PaperPlanterCheck
	IniWrite, %TicketPlanterCheck%, settings\nm_config.ini, gui, TicketPlanterCheck
	IniWrite, %PlanterOfPlentyCheck%, settings\nm_config.ini, gui, PlanterOfPlentyCheck
	IniWrite, %BambooFieldCheck%, settings\nm_config.ini, gui, BambooFieldCheck
	IniWrite, %BlueFlowerFieldCheck%, settings\nm_config.ini, gui, BlueFlowerFieldCheck
	IniWrite, %CactusFieldCheck%, settings\nm_config.ini, gui, CactusFieldCheck
	IniWrite, %CloverFieldCheck%, settings\nm_config.ini, gui, CloverFieldCheck
	IniWrite, %CoconutFieldCheck%, settings\nm_config.ini, gui, CoconutFieldCheck
	IniWrite, %DandelionFieldCheck%, settings\nm_config.ini, gui, DandelionFieldCheck
	IniWrite, %MountainTopFieldCheck%, settings\nm_config.ini, gui, MountainTopFieldCheck
	IniWrite, %MushroomFieldCheck%, settings\nm_config.ini, gui, MushroomFieldCheck
	IniWrite, %PepperFieldCheck%, settings\nm_config.ini, gui, PepperFieldCheck
	IniWrite, %PineTreeFieldCheck%, settings\nm_config.ini, gui, PineTreeFieldCheck
	IniWrite, %PineappleFieldCheck%, settings\nm_config.ini, gui, PineappleFieldCheck
	IniWrite, %PumpkinFieldCheck%, settings\nm_config.ini, gui, PumpkinFieldCheck
	IniWrite, %RoseFieldCheck%, settings\nm_config.ini, gui, RoseFieldCheck
	IniWrite, %SpiderFieldCheck%, settings\nm_config.ini, gui, SpiderFieldCheck
	IniWrite, %StrawberryFieldCheck%, settings\nm_config.ini, gui, StrawberryFieldCheck
	IniWrite, %StumpFieldCheck%, settings\nm_config.ini, gui, StumpFieldCheck
	IniWrite, %SunflowerFieldCheck%, settings\nm_config.ini, gui, SunflowerFieldCheck
	IniWrite, %PlanterMode%, settings\nm_config.ini, gui, PlanterMode
	IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
	IniWrite, %HarvestInterval%, settings\nm_config.ini, gui, HarvestInterval
	IniWrite, %AutomaticHarvestInterval%, settings\nm_config.ini, gui, AutomaticHarvestInterval
	IniWrite, %HarvestFullGrown%, settings\nm_config.ini, gui, HarvestFullGrown
	IniWrite, %GotoPlanterField%, settings\nm_config.ini, gui, GotoPlanterField
	IniWrite, %GatherFieldSipping%, settings\nm_config.ini, gui, GatherFieldSipping
	IniWrite, %ConvertFullBagHarvest%, settings\nm_config.ini, gui, ConvertFullBagHarvest
	IniWrite, %GatherPlanterLoot%, settings\nm_config.ini, gui, GatherPlanterLoot
}
ba_nectarstring(){
	global n1string
	global n2string
	global n3string
	global n4string
	global n5string
	GuiControlGet, n1priority
	GuiControlGet, n2priority
	GuiControlGet, n3priority
	GuiControlGet, n4priority
	GuiControlGet, n5priority
	if (n1priority!="none"){
		n2string:=strreplace(n1string, "|"n1priority, "")
		guicontrol, show, n2priority
		guicontrol, show, n2minPercent
		guicontrol,, n2priority, % StrReplace("|" LTrim(n2string, "|") "|", "|" n2priority "|", "|" n2priority "||")
	} else {
		guicontrol, hide, n2priority
		guicontrol, hide, n3priority
		guicontrol, hide, n4priority
		guicontrol, hide, n5priority
		guicontrol, hide, n2minPercent
		guicontrol, hide, n3minPercent
		guicontrol, hide, n4minPercent
		guicontrol, hide, n5minPercent
		n2string:="||None"
		n3string:="||None"
		n4string:="||None"
		n5string:="||None"
	}
	if (n2priority!="none"){
		n3string:=strreplace(n2string, "|"n2priority, "")
		guicontrol, show, n3priority
		guicontrol, show, n3minPercent
		guicontrol,, n3priority, % StrReplace("|" LTrim(n3string, "|") "|", "|" n3priority "|", "|" n3priority "||")
	} else {
		guicontrol, hide, n3priority
		guicontrol, hide, n4priority
		guicontrol, hide, n5priority
		guicontrol, hide, n3minPercent
		guicontrol, hide, n4minPercent
		guicontrol, hide, n5minPercent
		n3string:="||None"
		n4string:="||None"
		n5string:="||None"
	}
	if (n3priority!="none"){
		n4string:=strreplace(n3string, "|"n3priority, "")
		guicontrol, show, n4priority
		guicontrol, show, n4minPercent
		guicontrol,, n4priority, % StrReplace("|" LTrim(n4string, "|") "|", "|" n4priority "|", "|" n4priority "||")
	} else {
		guicontrol, hide, n4priority
		guicontrol, hide, n5priority
		guicontrol, hide, n4minPercent
		guicontrol, hide, n5minPercent
		n4string:="||None"
		n5string:="||None"
	}
	if (n4priority!="none"){
		n5string:=strreplace(n4string, "|"n4priority, "")
		guicontrol, show, n5priority
		guicontrol, show, n5minPercent
		guicontrol,, n5priority, % StrReplace("|" LTrim(n5string, "|") "|", "|" n5priority "|", "|" n5priority "||")
	} else {
		guicontrol, hide, n5priority
		guicontrol, hide, n5minPercent
		n5string:="||None"
	}
	return
}
ba_harvestInterval(){
	global HarvestInterval
	GuiControlGet, HarvestInterval
	if HarvestInterval is number
	{
		if HarvestInterval>0
		{
		HarvestInterval:=HarvestInterval
		ba_saveConfig_()
		} else {
		GuiControl, Text, HarvestInterval , %HarvestInterval%
	}
	} else {
		GuiControl, Text, HarvestInterval , %HarvestInterval%
	}
}
ba_planter(){
	global planternames
	global nectarnames
	global CurrentField
	global PlanterName1
	global PlanterName2
	global PlanterName3
	global PlanterField1
	global PlanterField2
	global PlanterField3
	global PlanterHarvestTime1
	global PlanterHarvestTime2
	global PlanterHarvestTime3
	global PlanterNectar1
	global PlanterNectar2
	global PlanterNectar3
	global PlanterEstPercent1
	global PlanterEstPercent2
	global PlanterEstPercent3
	global ComfortingFields, MotivatingFields, SatisfyingFields, RefreshingFields, InvigoratingFields
	global LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField
	global MaxAllowedPlanters
	global GotoPlanterField
	global GatherFieldSipping
	global LostPlanters
	global CurrentAction, PreviousAction, GatherFieldBoostedStart, LastGlitter
	global PlanterMode
	global HarvestInterval
	global HarvestFullGrown
	global n1priority
	global n2priority
	global n3priority
	global n4priority
	global n5priority
	global n1minPercent
	global n2minPercent
	global n3minPercent
	global n4minPercent
	global n5minPercent
	global PlasticPlanterCheck
	global CandyPlanterCheck
	global BlueClayPlanterCheck
	global RedClayPlanterCheck
	global TackyPlanterCheck
	global PesticidePlanterCheck
	global HeatTreatedPlanterCheck
	global HydroponicPlanterCheck
	global PetalPlanterCheck
	global PaperPlanterCheck
	global TicketPlanterCheck
	global PlanterOfPlentyCheck
	global BambooFieldCheck
	global BlueFlowerFieldCheck
	global CactusFieldCheck
	global CloverFieldCheck
	global CoconutFieldCheck
	global DandelionFieldCheck
	global MountainTopFieldCheck
	global MushroomFieldCheck
	global PepperFieldCheck
	global PineTreeFieldCheck
	global PineappleFieldCheck
	global PumpkinFieldCheck
	global RoseFieldCheck
	global SpiderFieldCheck
	global StrawberryFieldCheck
	global StumpFieldCheck
	global SunflowerFieldCheck
	global VBState
	global MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff
	loop, 3 {
	IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
	IniRead, PlanterField%A_Index%, settings\nm_config.ini, Planters, PlanterField%A_Index%
	IniRead, PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
	IniRead, PlanterNectar%A_Index%, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
	IniRead, PlanterEstPercent%A_Index%, settings\nm_config.ini, Planters, PlanterEstPercent%A_Index%
	}
	;skip over planters in this critical timeframe if AFB is active.  It helps avoid the loss of 4x field boost.
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, AutoFieldBoostActive, FieldLastBoosted, FieldLastBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable
	if(AutoFieldBoostActive && (FieldLastBoostedBy="dice") && (nowUnix()-FieldLastBoosted)>360 && (nowUnix()-FieldLastBoosted)<900) {
		return
	}
	if (PlanterMode != 2)
		return
	if(VBState=1)
		return
	FormatTime, utc_min, %A_NowUTC%, m
	if((MondoBuffCheck && utc_min>=0 && utc_min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && utc_min>=0 && utc_min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (utc_min>=0 && utc_min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if ((nowUnix()-GatherFieldBoostedStart)<900 || (nowUnix()-LastGlitter)<900 || nm_boostBypassCheck())
		return
	nectars:=["n1", "n2", "n3", "n4", "n5"]
	;get current field nectar
	currentFieldNectar:="None"
	for i, val in nectarnames {
		for j, k in %val%Fields {
			if(CurrentField=k) {
				currentFieldNectar:=val
				break
			}
		}
	}
	loop, 2 {
		;re-optimize planters
		for key, value in nectars {
			;--- get nectar priority --
			varstring:=(value . "priority")
			currentNectar:=%varstring%
			if (currentNectar!="none") {
				estimatedNectarPercent:=0
				loop, 3 { ;3 max positions
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				nectarPercent:=ba_GetNectarPercent(currentnectar)
				;recover planters that are collecting same nectar as currentField AND are not placed in currentField
				if(currentNectar=currentFieldNectar && not HarvestFullGrown && GatherFieldSipping) {
					loop, 3 { ;3 max positions
						if(currentField!=PlanterField%A_Index% && currentFieldNectar=PlanterNectar%A_Index%) {
							temp1:=PlanterField%A_Index%
							PlanterHarvestTime%A_Index% := nowUnix()-1
							PlanterHarvestTimeN:=PlanterHarvestTime%A_Index%
							IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
							IniRead, PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
						}
					}
				}
				;recover planters that will overfill nectars
				if (AutomaticHarvestInterval && ((nectarPercent>99)||(nectarPercent>90 && (nectarPercent+estimatedNectarPercent)>110)||(nectarPercent+estimatedNectarPercent)>120)){
					loop, 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							PlanterHarvestTime%A_Index% := nowUnix()-1
							PlanterHarvestTimeN:=PlanterHarvestTime%A_Index%
							IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
							IniRead, PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
						}
					}
				}
			} else {
				break
			}
		}
		;recover placed planters here
		loop, 3 {
			if((PlanterHarvestTime%A_Index% < nowUnix()) && PlanterName%A_Index%!="None"){
				i := A_Index
				Loop, 5 {
					if (ba_harvestPlanter(i) = 1)
						break
					if (A_Index = 5) {
						nm_setStatus("Error", "Failed to harvest " PlanterName%i% " in " PlanterField%i% "!")
						;clear planter
						PlanterName%i% := "None"
						PlanterField%i% := "None"
						PlanterNectar%i% := "None"
						PlanterHarvestTime%i% := 20211106000000
						PlanterEstPercent%i% := 0
						;write values to ini
						IniWrite, None, settings\nm_config.ini, Planters, PlanterName%i%
						IniWrite, None, settings\nm_config.ini, Planters, PlanterField%i%
						IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar%i%
						IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime%i%
						IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent%i%
						break
					}
				}
			}
		}
	}
	;re-place planters here
	;--- determine max number of planters ---
	maxplanters:=0
	for key, value in planternames {
		maxplanters := maxplanters + %value%Check
	}
	maxplanters := min(MaxAllowedPlanters, maxplanters)
	if (maxplanters=0)
		return
	;determine number of placed planters
	plantersplaced:=0
	planterSlots:=[]
	loop, 3 {
		if(PlanterName%A_Index%="none")
			planterSlots.push(A_Index)
	}
	plantersplaced:=3-planterSlots.length()
	;temp1:=planterSlots[1]
	;temp2:=planterSlots[2]
	;temp3:=planterSlots[3]
	;temp4:=planterSlots.length()
	;msgbox Planterslots`n%temp1% %temp2% %temp3%`n%temp4%
	if(not planterSlots.length())
		return
	;--- determine max number of nectars ---
	maxnectars:=0

	for key, value in nectars {
		if(%value%priority != "none")
			maxnectars:=maxnectars+1
	}
	if (maxnectars=0)
		return

	;//////// STAGE 1: Fill nectars to thresholds ///////////////
	;---- fill in priority order until all thresholds have been met
	;msgbox stage 1
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		nextPlanter:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		loop, 3{
			IniRead, PlanterNectar%A_Index%, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		;msgbox %currentNectar% %maxNectarPlanters%
		if (currentNectar!="none") {
			planterSlots:=[]
			loop, 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
			for i, planterNum in planterSlots {
			;loop, 3 { ;3 max planters
			;temp1:=planterSlots[1]
			;temp2:=planterSlots[2]
			;temp3:=planterSlots[3]
			;temp4:=planterSlots.length()
			;msgbox Planterslots`n%temp1% %temp2% %temp3%`n%temp4%`nPlanterNum=%PlanterNum% i=%i%
			;msgbox planterNum=%planterNum%`ni=%i%
				;--- determine max number of planters ---
				maxplanters:=0
				for x, y in planternames {
					maxplanters := maxplanters + %y%Check
				}

				maxplanters := min(MaxAllowedPlanters, maxplanters)
				;msgbox maxplanters=%maxplanters%
				;determine last and next fields
				if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){ ;always place planter in field you are collecting from
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=CurrentField
					maxNectarPlanters:=1
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
				}
				LostPlanters:=""
				nextPlanter:=ba_getNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				;temp1:=nextPlanter[1]
				;msgbox nextField=%nextField% nextPlanter=%temp1%`nplantersplaced:=%plantersplaced% maxplanters:=%maxplanters% MaxAllowedPlanters:=%MaxAllowedPlanters%
				if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
					;determine current nectar percent
					nectarPercent:=ba_GetNectarPercent(currentnectar)
					nectarMinPercent:=%value%minPercent
					estimatedNectarPercent:=0
					loop, 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
						}
					}
					;temp1:=nectarPercent + estimatedNectarPercent
					;msgbox estNectarPercent=%temp1% < nectarMinPercent=%nectarMinPercent%
					if(currentNectar=currentFieldNectar && estimatedNectarPercent>0){
						break
					}
					if (((nectarPercent + estimatedNectarPercent) < nectarMinPercent)){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch % success {
								case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

								case 2: ;already a planter in this field, change field and try
								lastnextfield:=ba_getlastfield(currentNectar)
								lastField:=lastNextField[1]
								nextField:=lastNextField[2]
								nextPlanter:=ba_getNextPlanter(nextField)
								atField:=0
								LostPlanters:=""
								Last%currentnectar%Field := nextField
								IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field

								case 3: ;3 planters have been placed already, return
								nm_OpenMenu()
								return

								case 4: ;not in a field, try again
								atField:=0

								default: ;cannot find planter, try alternative planter in this field
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
								{
									nm_endWalk()
									break
								}
								else
									atField:=1
							}
							if (A_Index = 10) {
								nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
								MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
								GuiControl,,MaxAllowedPlanters,%MaxAllowedPlanters%
								IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
								break
							}
						}
					} else {
						break
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
					nm_OpenMenu()
					return
				}
			;msgbox next planterNum?
			}
		} else {
			break
		}
	}
	;//////// STAGE 2: All Nectars are at or will be above thresholds after harvested ///////////////
	;---- fill from lowest to highest nectar percent
	;msgbox Stage 2
	tempArray:=[]
	lowToHigh:=[] ;nectarname list
	sortstring:=""
	;create sort list
	for key, value in nectars {
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		estimatedNectarPercent:=0
		;msgbox %currentNectar%
		loop, 3 {
			planterNectar:=PlanterNectar%A_Index%
			if (PlanterNectar=currentNectar) {
				estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
			}
		}
		if (currentNectar!="none") {
			nectarPercent:=ba_GetNectarPercent(currentnectar)+estimatedNectarPercent
			if(key>1)
				sortstring:=(sortstring . ";")
			sortstring:=(sortstring . nectarPercent . "," . value . "," . currentNectar)
		} else {
			break
		}
	}
	;sort list and re-extract nectars in low to high percent order
	sort, sortstring, d;
	tempArray := StrSplit(sortstring , ";")
	for i, val in tempArray {
		tempstring:=tempArray[A_Index]
		lowToHigh.InsertAt(A_Index, StrSplit(tempArray[A_Index], ","))
	}
	;temp1:=lowToHigh[1][3]
	;temp2:=lowToHigh[2][3]
	;temp3:=lowToHigh[3][3]
	;temp4:=lowToHigh[4][3]
	;temp5:=lowToHigh[5][3]
	;msgbox lowToHigh`n1:%temp1%`n2:%temp2%`n3:%temp3%`n4:%temp4%`n5:%temp5%
	for key, value in lowToHigh {
		currentNectar:=lowToHigh[key][3]
		nextPlanter:=[]
		;msgbox S2 Current=%currentNectar%
		planterSlots:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		loop, 3{
			IniRead, PlanterNectar%A_Index%, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		loop, 3 {
			if(PlanterName%A_Index%="none")
				planterSlots.push(A_Index)
		}
		for i, planterNum in planterSlots {
		;loop, 3 {
			;--- determine max number of planters ---
			maxplanters:=0
			for x, y in planternames {
				maxplanters := maxplanters + %y%Check
			}
			maxplanters := min(MaxAllowedPlanters, maxplanters)
			;determine last and next fields
			if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){
				lastnextfield:=ba_getlastfield(currentNectar)
				lastField:=lastNextField[1]
				nextField:=CurrentField
				maxNectarPlanters:=1
			} else {
				lastnextfield:=ba_getlastfield(currentNectar)
				lastField:=lastNextField[1]
				nextField:=lastNextField[2]
			}
			LostPlanters:=""
			nextPlanter:=ba_getNextPlanter(nextField)
			;there is an allowed field for this nectar and an available planter
			if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
				;determine current nectar percent
				nectarPercent:=ba_GetNectarPercent(currentnectar)
				estimatedNectarPercent:=0
				loop, 3 {
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				;msgbox %estimatednectarpercent% %nectarMinPercent%`nkey=%key%
				;is the last element in the array
				if (key=lowToHigh.length()){
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch % success {
							case 1: ;planter placed successfully, break loop
							plantersplaced++
							nectarPlantersPlaced++
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							break

							case 2: ;already a planter in this field, change field and try
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							nextPlanter:=ba_getNextPlanter(nextField)
							atField:=0
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field

							case 3: ;3 planters have been placed already, return
							nm_OpenMenu()
							return

							case 4: ;not in a field, try again
							atField:=0

							default: ;cannot find planter, try alternative planter in this field
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
							else
								atField:=1
						}
						if (A_Index = 10) {
							nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
							MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
							GuiControl,,MaxAllowedPlanters,%MaxAllowedPlanters%
							IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
							break
						}
					}
				} else { ;is not the last element in the array
					temp:=lowToHigh[key+1][1]
					;msgbox %estimatednectarpercent% %nectarMinPercent%`nkey=%temp%
					if ((nectarPercent + estimatedNectarPercent) <= lowToHigh[key+1][1]){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch % success {
								case 1: ;planter placed successfully, break loop
								plantersplaced++
								nectarPlantersPlaced++
								ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break

								case 2: ;already a planter in this field, change field and try
								lastnextfield:=ba_getlastfield(currentNectar)
								lastField:=lastNextField[1]
								nextField:=lastNextField[2]
								nextPlanter:=ba_getNextPlanter(nextField)
								atField:=0
								LostPlanters:=""
								Last%currentnectar%Field := nextField
								IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field

								case 3: ;3 planters have been placed already, return
								nm_OpenMenu()
								return

								case 4: ;not in a field, try again
								atField:=0

								default: ;cannot find planter, try alternative planter in this field
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
								{
									nm_endWalk()
									break
								}
								else
									atField:=1
							}
							if (A_Index = 10) {
								nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
								MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
								GuiControl,,MaxAllowedPlanters,%MaxAllowedPlanters%
								IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
								break
							}
						}
					} else {
						break
					}
				}
			} else {
				break
			}
			;maximum planters have been placed. leave function
			if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
				nm_OpenMenu()
				return
			}
		}
	}
	;//////// STAGE 3: All Nectars are full? ///////////////
	;just place planters in priority order (this is a failsafe stage)
	;msgbox Stage 3
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		nextPlanter:=[]
		;get maxNectarPlanters
		maxNectarPlanters:=0
		for ind, field in %currentNectar%Fields
		{
			tempfieldname := StrReplace(field, " ", "")
			if(%tempfieldname%FieldCheck)
				maxNectarPlanters:=maxNectarPlanters+1
		}
		;get nectarPlantersPlaced
		nectarPlantersPlaced:=0
		loop, 3{
			IniRead, PlanterNectar%A_Index%, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		if (currentNectar!="none") {
			planterSlots:=[]
			loop, 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
					for i, planterNum in planterSlots {
			;loop, 3 {
				;--- determine max number of planters ---
				maxplanters:=0
				for x, y in planternames {
					maxplanters := maxplanters + %y%Check
				}
				maxplanters := min(MaxAllowedPlanters, maxplanters)
				;determine last and next fields
				if(currentNectar=currentFieldNectar && not GotoPlanterField && GatherFieldSipping){
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=CurrentField
					maxNectarPlanters:=1
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
				}
				LostPlanters:=""
				nextPlanter:=ba_getNextPlanter(nextField)
				;there is an allowed field for this nectar and an available planter
				if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
					;determine current nectar percent
					nectarPercent:=ba_GetNectarPercent(currentnectar)
					estimatedNectarPercent:=0
					loop, 3 {
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%

						}
					}
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch % success {
							case 1: ;planter placed successfully, break loop
							plantersplaced++
							nectarPlantersPlaced++
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							break

							case 2: ;already a planter in this field, change field and try
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							nextPlanter:=ba_getNextPlanter(nextField)
							atField:=0
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field

							case 3: ;3 planters have been placed already, return
							nm_OpenMenu()
							return

							case 4: ;not in a field, try again
							atField:=0

							default: ;cannot find planter, try alternative planter in this field
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
							else
								atField:=1
						}
						if (A_Index = 10) {
							nm_setStatus("Error", "Failed to place planter in 10 tries!`nMaxAllowedPlanters has been reduced.")
							MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
							GuiControl,,MaxAllowedPlanters,%MaxAllowedPlanters%
							IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
							break
						}
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters) {
					nm_OpenMenu()
					return
				}
			}
		} else {
			break
		}
	}
	nm_OpenMenu()
}
ba_GetNectarPercent(var){
	global nectarnames
	global graphicsKey
    global resolutionKey
	global totalCom, totalMot, totalRef, totalSat, totalInv
	for key, value in nectarnames {
		if (var=value){
			;(var="comforting") ? nectarColor:=0x7E9EB3
			;: (var="motivating") ? nectarColor:=0x937DB3
			;: (var="satisfying") ? nectarColor:=0xB398A7
			;: (var="refreshing") ? nectarColor:=0x78B375
			;: (var="invigorating") ? nectarColor:=0xB35951
			;PixelSearch, bx2, by2, 0, 30, 860, 150, %nectarColor%, 0, RGB Fast
			(var="comforting") ? nectarColor:=0xB39E7E
			: (var="motivating") ? nectarColor:=0xB37D93
			: (var="satisfying") ? nectarColor:=0xA798B3
			: (var="refreshing") ? nectarColor:=0x75B378
			: (var="invigorating") ? nectarColor:=0x5159B3
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			PixelSearch, bx2, by2, windowX, windowY+30, windowX+860, windowY+150, %nectarColor%,0, Fast
			If (ErrorLevel=0) {
				nexty:=by2+1
				pixels:=1
				loop 38 {
					;PixelGetColor, OutputVar, %bx2%, %nexty%, RGB fast
					PixelGetColor, OutputVar, %bx2%, %nexty%, fast
					;PixelSearch, bx3, by3, %bx2%-1, %nexty%, %bx2%+38, 150, %nectarColor%,0, Fast
					If (OutputVar=nectarColor) {
					;If (ErrorLevel=0) {
						nexty:=nexty+1
						pixels:=pixels+1
					} else {
						nectarpercent:=round(pixels/38*100, 0)
						break
					}
				}
			} else {
				nectarpercent:=0
			}
			/*
			nectarpercent:=0
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;check 50%
			filename:=(value . "_50.png")
			searchRet := nm_imgSearch(filename,10,"buff")
			If (searchRet[1] = 0) { ;50 found, Check 70
				;check 70%
				filename:=(value . "_70.png")
				searchRet := nm_imgSearch(filename,10,"buff")
				If (searchRet[1] = 0) { ;70 found, Check 90
					;check 90%
					filename:=(value . "_90.png")
					searchRet := nm_imgSearch(filename,10,"buff")
					If (searchRet[1] = 0) { ;90 found, Check 100
						;check 100%
						filename:=(value . "_100.png")
						searchRet := nm_imgSearch(filename,10,"buff")
						If (searchRet[1] = 0) { ;100 found, done
							nectarpercent:=99.99
						} else { ;100 not found, done
							nectarpercent:=90
						}
					} else { ;90 not found, check 80
						;check 80%
						filename:=(value . "_80.png")
						searchRet := nm_imgSearch(filename,10,"buff")
						If (searchRet[1] = 0) { ;80 found, done
							nectarpercent:=80
						} else { ;80 not found, done
							nectarpercent:=70
						}
					}
				} else { ;70 not found, check 60
					;check 60%
					filename:=(value . "_60.png")
					searchRet := nm_imgSearch(filename,10,"buff")
					If (searchRet[1] = 0) { ;60 found, done
						nectarpercent:=60
					} else { ;60 not found, done
						nectarpercent:=50
					}
				}
			} else { ;50 not found, check 30
				;check 30%
				filename:=(value . "_30.png")
				searchRet := nm_imgSearch(filename,10,"buff")
				If (searchRet[1] = 0) { ;30 found, check 40
					;check 40%
					filename:=(value . "_40.png")
					searchRet := nm_imgSearch(filename,10,"buff")
					If (searchRet[1] = 0) { ;40 found, done
						nectarpercent:=40
					} else { ;40 not found, done
						nectarpercent:=30
					}
				} else { ;30 not found, check 10
					;check 10%
					filename:=(value . "_10.png")
					searchRet := nm_imgSearch(filename,10,"buff")
					If (searchRet[1] = 0) { ;10 found, check 20
						;check 20%
						filename:=(value . "_20.png")
						searchRet := nm_imgSearch(filename,10,"buff")
						If (searchRet[1] = 0) { ;20 found, done
							nectarpercent:=20
						} else { ;20 not found, done
							nectarpercent:=10
						}
					} else { ;10 not found, done
						nectarpercent:=0
					}
				}
			}
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			break
			*/
		}
	}
	if (nectarpercent=100)
		nectarpercent:=99.99
	;msgbox %var%: %nectarpercent%
	if (var="comforting"){
		totalCom := nectarpercent
	}
	else if (var="motivating"){
		totalMot := nectarpercent
	}
	else if (var="refreshing"){
		totalRef := nectarpercent
	}
	else if (var="satisfying"){
		totalSat := nectarpercent
	}
	else if (var="invigorating"){
		totalInv := nectarpercent
	}
	return nectarpercent
}
ba_getLastField(currentnectar){
	global ComfortingFields
	global RefreshingFields
	global SatisfyingFields
	global MotivatingFields
	global InvigoratingFields
	global LastComfortingField
	global LastRefreshingField
	global LastSatisfyingField
	global LastMotivatingField
	global LastInvigoratingField
	global BambooFieldCheck
	global BlueFlowerFieldCheck
	global CactusFieldCheck
	global CloverFieldCheck
	global CoconutFieldCheck
	global DandelionFieldCheck
	global MountainTopFieldCheck
	global MushroomFieldCheck
	global PepperFieldCheck
	global PineTreeFieldCheck
	global PineappleFieldCheck
	global PumpkinFieldCheck
	global RoseFieldCheck
	global SpiderFieldCheck
	global StrawberryFieldCheck
	global StumpFieldCheck
	global SunflowerFieldCheck
	loop, 3 {
		IniRead, PlanterField%A_Index%, settings\nm_config.ini, Planters, PlanterField%A_Index%
	}

	availablefields:=[]
	arr := []
	arr[1] := Last%currentnectar%Field
	;determine allowed fields
	for key, value in %currentnectar%Fields {
		tempfieldname := StrReplace(value, " ", "")
		if(%tempfieldname%FieldCheck && value!=PlanterField1 && value!=PlanterField2 && value!=PlanterField3)
			availablefields.Push(value)
	}
	arraylen:=availablefields.Length()
	;no allowed fields exist for this nectar
	if(arraylen=0)
		arr[2] := "None"
	;find index of last nectar field
	for k, v in availablefields {
		;found index of last nectar field in availablefields
		if (v=Last%currentnectar%Field)
		{
			arr[2] := availablefields[Mod(k,arrayLen)+1]
			break
		}
	}
	if !arr[2]
		arr[1] := availablefields[1], arr[2] := availablefields[2] ? availablefields[2] : availablefields[1]
	return arr
}
ba_getNextPlanter(nextfield){
	global BambooPlanters
	global BlueFlowerPlanters
	global CactusPlanters
	global CloverPlanters
	global CoconutPlanters
	global DandelionPlanters
	global MountainTopPlanters
	global MushroomPlanters
	global PepperPlanters
	global PineTreePlanters
	global PineapplePlanters
	global PumpkinPlanters
	global RosePlanters
	global SpiderPlanters
	global StrawberryPlanters
	global StumpPlanters
	global SunflowerPlanters
	global PlasticPlanterCheck
	global CandyPlanterCheck
	global BlueClayPlanterCheck
	global RedClayPlanterCheck
	global TackyPlanterCheck
	global PesticidePlanterCheck
	global HeatTreatedPlanterCheck
	global HydroponicPlanterCheck
	global PetalPlanterCheck
	global PaperPlanterCheck
	global TicketPlanterCheck
	global PlanterOfPlentyCheck
	loop, 3 {
		IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
	}
	global LostPlanters
	;determine available planters
	tempFieldName := StrReplace(nextfield, " ", "")
	tempArrayName := (tempfieldname . "Planters")
	arrayLen:=%tempfieldname%Planters.Length()
	nextPlanterName:="none"
	nextPlanterBonus:=0
	nextPlanterGrowTime:=0
	loop, %arrayLen% {
		tempPlanter:=Trim(%tempfieldname%Planters[A_Index][1])
		tempPlanterCheck:=%tempPlanter%Check
		if(tempPlanterCheck && tempPlanter!=PlanterName1 && tempPlanter!=PlanterName2 && tempPlanter!=PlanterName3)
		{
			IfNotInString, LostPlanters, %tempPlanter%
			{
				nextPlanterName:=%tempfieldname%Planters[A_Index][1]
				nextPlanterNectarBonus:=%tempfieldname%Planters[A_Index][2]
				nextPlanterGrowBonus:=%tempfieldname%Planters[A_Index][3]
				nextPlanterGrowTime:=%tempfieldname%Planters[A_Index][4]
				break
			}
		}
	}
	return [nextPlanterName, nextPlanterNectarBonus, nextPlanterGrowBonus, nextPlanterGrowTime]
}
ba_placePlanter(fieldName, planter, planterNum, atField:=0){
	global BambooFieldCheck, BlueFlowerFieldCheck, CactusFieldCheck, CloverFieldCheck, CoconutFieldCheck, DandelionFieldCheck, MountainTopFieldCheck, MushroomFieldCheck, PepperFieldCheck, PineTreeFieldCheck, PineappleFieldCheck, PumpkinFieldCheck, RoseFieldCheck, SpiderFieldCheck, StrawberryFieldCheck, StumpFieldCheck, SunflowerFieldCheck, MaxAllowedPlanters, LostPlanters, CurrentAction, PreviousAction, bitmaps

	if(CurrentAction!="Planters") {
		PreviousAction:=CurrentAction
		CurrentAction:="Planters"
	}

	nm_setShiftLock(0)
	nm_OpenMenu("itemmenu")

	planterName := planter[1]
	if (atField = 0)
	{
		nm_Reset()
		nm_setStatus("Traveling", (planterName . " (" . fieldName . ")"))
		nm_gotoPlanter(fieldName, 0)
	}

	planterPos := nm_InventorySearch(planterName, "up", 4)

	if (planterPos = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", planterName)
		LostPlanters.=planterName
		ba_saveConfig_()
		return 0
	}
	else
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		MouseMove, windowX+planterPos[1], windowY+planterPos[2]
	}

	KeyWait, F14, T120 L ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", planterName)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|" windowWidth//2 "|" Max(480, windowHeight-120))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop, 40
			{
				if (Gdip_ImageSearch(pBMScreen, bitmaps["item"], , , , 6, , 2) = 1)
					break
				else
				{
					if (A_Index = 40)
					{
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Missing", planterName)
						LostPlanters.=planterName
						ba_saveConfig_()
						return 0
					}
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Max(480, windowHeight-120))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[planterName], planterPos, 0, 0, 306, Max(480, windowHeight-120), 10, , 5) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag, Left, windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		sleep, 200
	}
	Loop, 50
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 2, , 2) = 1) {
				MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
				sleep, 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+350, windowY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", planterName)
			LostPlanters.=planterName
			ba_saveConfig_()
			return 0
		}

		Sleep, 100
	}

	Loop, 10
	{
		Sleep, 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
			GuiControl,,MaxAllowedPlanters,%MaxAllowedPlanters%
			nm_setStatus("Error", "3 Planters already placed!`nMaxAllowedPlanters has been reduced.")
			ba_saveConfig_()
			Sleep, 500
			return 3
		}
		imgPos := nm_imgSearch("planteralready.png",30,"lowright")
		If (imgPos[1] = 0){
			return 2
		}
		imgPos := nm_imgSearch("standing.png",30,"lowright")
		If (imgPos[1] = 0){
			return 4
		}
	}
	return 1
}
ba_harvestPlanter(planterNum){
	global PlanterName1, PlanterName2, PlanterName3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3, PlanterNectar1, PlanterNectar2, PlanterNectar3, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3, BackKey, RightKey, objective, TotalPlantersCollected, SessionPlantersCollected, HarvestFullGrown, ConvertFullBagHarvest, GatherPlanterLoot, BackpackPercent, bitmaps, SC_E, HiveBees

	if(CurrentAction!="Planters"){
		PreviousAction:=CurrentAction
		CurrentAction:="Planters"
	}

	planterName:=PlanterName%planterNum%
	fieldName:=PlanterField%planterNum%
	nm_setShiftLock(0)
	nm_Reset(1, ((GatherPlanterLoot = 1) && ((fieldname = "Rose") || (fieldname = "Pine Tree") || (fieldname = "Pumpkin") || (fieldname = "Cactus") || (fieldname = "Spider"))) ? min(20000, (60-HiveBees)*1000) : 0)
	nm_setStatus("Traveling", planterName . " (" . fieldName . ")")
	nm_gotoPlanter(fieldName)
	nm_setStatus("Collecting", (planterName . " (" . fieldName . ")"))
	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep, 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (planterName . " (" . fieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . planterName)
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())

		nm_OpenMenu("itemmenu")
		planterPos := nm_InventorySearch(planterName, "up", 4)

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", planterName . ". Clearing Data.")
			;reset values
			PlanterName%planterNum% := "None"
			PlanterField%planterNum% := "None"
			PlanterNectar%planterNum% := "None"
			PlanterHarvestTime%planterNum% := 20211106000000
			PlanterEstPercent%planterNum% := 0
			;write values to ini
			IniWrite, None, settings\nm_config.ini, Planters, PlanterName%planterNum%
			IniWrite, None, settings\nm_config.ini, Planters, PlanterField%planterNum%
			IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar%planterNum%
			IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime%planterNum%
			IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent%planterNum%
			return 1
		}
		else
			return 0
	}
	else {
        sendinput {%SC_E% down}
		Sleep, 100
		sendinput {%SC_E% up}

		Loop, 50
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep, 100

			if (A_Index = 50)
				return 0
		}

		Sleep, 50 ; wait for game to update frame
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
		if (HarvestFullGrown = 1) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], pos, , , , , 2, , 3) = 1) {
					MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
					sleep, 150
					Click
					sleep 100
					MouseMove, windowX+350, windowY+100
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(FieldName)
					return 1
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+((6*windowHeight)//10 - 60) "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 2, , 2) = 1) {
					MouseMove, windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+((6*windowHeight)//10 - 60)+SubStr(pos, InStr(pos, ",")+1)
					sleep, 150
					Click
					sleep 100
					MouseMove, windowX+350, windowY+100
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}


		;reset values
		PlanterName%planterNum% := "None"
		PlanterField%planterNum% := "None"
		PlanterNectar%planterNum% := "None"
		PlanterHarvestTime%planterNum% := 20211106000000
		PlanterEstPercent%planterNum% := 0
		;write values to ini
		IniWrite, None, settings\nm_config.ini, Planters, PlanterName%planterNum%
		IniWrite, None, settings\nm_config.ini, Planters, PlanterField%planterNum%
		IniWrite, None, settings\nm_config.ini, Planters, PlanterNectar%planterNum%
		IniWrite, 20211106000000, settings\nm_config.ini, Planters, PlanterHarvestTime%planterNum%
		IniWrite, 0, settings\nm_config.ini, Planters, PlanterEstPercent%planterNum%
		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		Prev_TitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
			PostMessage, 0x5555, 4, 1
		}
		DetectHiddenWindows %Prev_DetectHiddenWindows%
		SetTitleMatchMode %Prev_TitleMatchMode%
		IniWrite, %TotalPlantersCollected%, settings\nm_config.ini, Status, TotalPlantersCollected
		IniWrite, %SessionPlantersCollected%, settings\nm_config.ini, Status, SessionPlantersCollected
		;gather loot
		if (GatherPlanterLoot = 1)
		{
			nm_setStatus("Looting", planterName . " Loot")
			sleep, 1000
			movement := nm_Walk(7, BackKey, RightKey)
			nm_createWalk(movement)
			KeyWait, F14, D T5 L
			KeyWait, F14, T20 L
			nm_endWalk()
			nm_loot(9, 5, "left")
		}
		if ((ConvertFullBagHarvest = 1) && (BackpackPercent >= 95))
		{
			nm_walkFrom(fieldName)
			DisconnectCheck()
			nm_findHiveSlot()
		}
		return 1
	}
}
ba_SavePlacedPlanter(fieldName, planter, planterNum, nectar){
	global PlanterName1
	global PlanterName2
	global PlanterName3
	global PlanterField1
	global PlanterField2
	global PlanterField3
	global PlanterHarvestTime1
	global PlanterHarvestTime2
	global PlanterHarvestTime3
	global PlanterNectar1
	global PlanterNectar2
	global PlanterNectar3
	global PlanterEstPercent1
	global PlanterEstPercent2
	global PlanterEstPercent3
	global HarvestInterval
	global LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField
	global HarvestInterval
	loop, 3{
		IniRead, PlanterName%A_Index%, settings\nm_config.ini, Planters, PlanterName%A_Index%
		IniRead, PlanterField%A_Index%, settings\nm_config.ini, Planters, PlanterField%A_Index%
		IniRead, PlanterHarvestTime%A_Index%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
		IniRead, PlanterNectar%A_Index%, settings\nm_config.ini, Planters, PlanterNectar%A_Index%
		IniRead, PlanterEstPercent%A_Index%, settings\nm_config.ini, Planters, PlanterEstPercent%A_Index%
	}
	IniRead, HarvestInterval, settings\nm_config.ini, gui, HarvestInterval
	global PlasticPlanterCheck
	global CandyPlanterCheck
	global BlueClayPlanterCheck
	global RedClayPlanterCheck
	global TackyPlanterCheck
	global PesticidePlanterCheck
	global HeatTreatedPlanterCheck
	global HydroponicPlanterCheck
	global PetalPlanterCheck
	global PaperPlanterCheck
	global TicketPlanterCheck
	global PlanterOfPlentyCheck
	global n1minPercent
	global n2minPercent
	global n3minPercent
	global n4minPercent
	global n5minPercent
	guicontrolget AutomaticHarvestInterval
	guicontrolget HarvestFullGrown
	;temp1:=planter[1]
	;temp2:=planter[2]
	;temp3:=planter[3]
	;temp4:=planter[4]
	;msgbox Attempting to Place %temp1% in %fieldname%`n NectarBonus=%temp2% GrowBonus=%temp3% Hours=%temp4%
	;save placed planter to ini
	PlanterName%planterNum%:=planter[1]
	PlanterField%planterNum%:=fieldName
	PlanterNectar%planterNum%:=nectar
	PlanterNameN:=PlanterName%planterNum%
	PlanterFieldN:=PlanterField%planterNum%
	PlanterNectarN:=PlanterNectar%planterNum%
	Last%nectar%Field:=fieldname
	;calculate harvest time
	estimatedNectarPercent:=0
	loop, 3 { ;3 max positions
		planterNectar:=PlanterNectar%A_Index%
		if (PlanterNectar=nectar) {
			estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
		}
	}
	estimatedNectarPercent:=estimatedNectarPercent+ba_GetNectarPercent(nectar) ;projected nectar percent
	;msgbox estPercent=%estimatedNectarPercent%
	minPercent:=estimatedNectarPercent
	loop, 5{ ;5 nectar priorities
		if(n%A_Index%priority=nectar && minPercent<=n%A_Index%minPercent)
			minPercent:=n%A_Index%minPercent ; minPercent > estimatedNectarPercent
	}
	temp1:=minPercent-estimatedNectarPercent
	;msgbox min=%minPercent% estPercent=%estimatedNectarPercent%`nmin-est=%temp1%
	;timeToCap:=(max(0,(100-estimatedNectarPercent))*.24)/planter[2] ;hours
	timeToCap:=max(0.25,((max(0,(100-estimatedNectarPercent)/planter[2]))*.24)/planter[3]) ;hours
	;msgbox timeToCap=%timeToCap%
	if(planter[2]*planter[3]<1.2){ ;less than 20% overall bonus
		autoInterval:=min(timeToCap, 0.5)
	}
	;if((minPercent > estimatedNectarPercent) && ((minPercent-estimatedNectarPercent)>=5) && ((estimatedNectarPercent)<=100)){
	else if((minPercent > estimatedNectarPercent) && ((estimatedNectarPercent)<=90)){
		;autoInterval:=((minPercent-estimatedNectarPercent)*.24)/planter[2] ;hours
		if (estimatedNectarPercent>0) {
			bonusTime:=(100/estimatedNectarPercent)*planter[2]*planter[3]
			autoInterval:=(((minPercent-estimatedNectarPercent+bonusTime)/planter[2])*.24)/planter[3] ;hours
		} else {
			autoInterval:=planter[4] ;hours
		}

		;msgbox to threshold
	} else { ;minPercent <= estimatedNectarPercent
		autoInterval:=timeToCap
		;msgbox to cap
	}
	;nec=planter[2]
	;gro=planter[3]
	;msgbox min=%minPercent% Est=%estimatedNectarPercent% nec=%nec% gro=%gro% int=%autointerval%
	if(AutomaticHarvestInterval) {
		planterHarvestInterval:=floor(min(planter[4], (autoInterval+autoInterval/(planter[2]*planter[3])), (timeToCap+timeToCap/(planter[2]*planter[3])))*60*60)
		PlanterHarvestTime%planterNum%:=nowUnix()+planterHarvestInterval
	} else if(HarvestFullGrown) {
		planterHarvestInterval:=floor(planter[4]*60*60)
		PlanterHarvestTime%planterNum%:=nowUnix()+planterHarvestInterval
	} else {
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval, (timeToCap+timeToCap/(planter[2]*planter[3])))*60*60)
		;planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		;temp1:=planter[4]
		;msgbox planter[4]=%temp1% HarvestInterval=%HarvestInterval% TimeToCap=%timeToCap%
		planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		;msgbox planterHarvestInterval=%planterHarvestInterval%
		smallestHarvestInterval:=nowUnix()+planterHarvestInterval
		loop, 3 {
			if(PlanterHarvestTime%A_Index%>nowUnix() && PlanterHarvestTime%A_Index%<smallestHarvestInterval)
				smallestHarvestInterval:=PlanterHarvestTime%A_Index%
		}
		PlanterHarvestTime%planterNum%:=min(smallestHarvestInterval, nowUnix()+planterHarvestInterval)
		temp:=PlanterHarvestTime%planterNum%
		;msgbox PlanterHarvestTime=%temp%
	}
	;PlanterHarvestTime%planterNum%:=toUnix_()+planterHarvestInterval
	PlanterHarvestTimeN:=PlanterHarvestTime%planterNum%
	;PlanterEstPercent%planterNum%:=round((floor(min(planter[3], HarvestInterval)*60*60)*planter[2]-floor(min(planter[3], HarvestInterval)*60*60))/864, 1)
	PlanterEstPercent%planterNum%:=round((floor(planterHarvestInterval)*planter[2])/864, 1)
	PlanterEstPercentN:=PlanterEstPercent%planterNum%
	;save changes
	IniWrite, %PlanterNameN%, settings\nm_config.ini, Planters, PlanterName%planterNum%
	IniWrite, %PlanterFieldN%, settings\nm_config.ini, Planters, PlanterField%planterNum%
	IniWrite, %PlanterNectarN%, settings\nm_config.ini, Planters, PlanterNectar%planterNum%

	;make all harvest times equal
	loop, 3 {
		if(not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < PlanterHarvestTimeN + 600)
			IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime%A_Index%
		else if(A_Index=planterNum)
			IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime%planterNum%
	}

	;IniWrite, %PlanterHarvestTimeN%, settings\nm_config.ini, Planters, PlanterHarvestTime%planterNum%
	IniWrite, %PlanterEstPercentN%, settings\nm_config.ini, Planters, PlanterEstPercent%planterNum%
	IniWrite, %fieldname%, settings\nm_config.ini, Planters, Last%nectar%Field
}
ba_showPlanterTimers(){
	global
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	if !WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
		run, "%exe_path32%" /script "submacros\PlanterTimers.ahk" "%hwndstate%"
	else
		WinClose
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	SetTitleMatchMode, %Prev_TitleMatchMode%
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LABELS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getout(){
global
Prev_DetectHiddenWindows := A_DetectHiddenWindows
Prev_TitleMatchMode := A_TitleMatchMode
DetectHiddenWindows On
SetTitleMatchMode 2
if(winexist("Timers") && not pass) {
if(fileexist("settings\nm_config.ini"))
    IniWrite, 1, settings\nm_config.ini, gui, TimersOpen
    winclose, PlanterTimers.ahk ahk_class AutoHotkey
    pass:=1
} else if (not winexist("Timers") && not pass){
if(fileexist("settings\nm_config.ini"))
    IniWrite, 0, settings\nm_config.ini, gui, TimersOpen
    pass:=1
}
nm_SaveGui()
nm_endWalk()
WinClose, StatMonitor.ahk ahk_class AutoHotkey
WinClose, background.ahk ahk_class AutoHotkey
WinClose, Status.ahk ahk_class AutoHotkey
WinGet, script_list, List, % A_ScriptDir " ahk_class AutoHotkey"
	Loop %script_list%
		if ((script_hwnd := script_list%A_Index%) != A_ScriptHwnd)
			WinClose, ahk_id %script_hwnd%
Gdip_Shutdown(pToken)
}

GuiClose:
ExitApp
return

Background:
global AFBrollingDice
;auto field boost
if (AFBrollingDice && not disableDayorNight && state!="Disconnected")
    nm_fieldBoostDice()
;use/check hotbar boosts
if(PFieldBoosted) {
	nm_hotbar(1)
} else {
	nm_hotbar()
}
;bug death check
if(state="Gathering" || state="Searching" || (VBState=2 && state="Attacking"))
	nm_bugDeathCheck()
;stats
nm_setStats()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HOTKEYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;START MACRO
start:
ControlFocus
SetKeyDelay, 100+KeyDelay
send ^{Alt}
;lock tabs
nm_TabGatherLock()
nm_TabCollectLock()
nm_TabBoostLock()
nm_TabPlantersLock()
nm_TabSettingsLock()
Gui, Font, s8 w700 cDefault
for k,v in ["Discord","Roblox","Donate"]
{
	GuiControl, Font, Text%v%Link
	GuiControl, -g, Text%v%Link
	GuiControl, -g, Image%v%Link
}
GuiControl, -g, ImageGitHubLink
GuiControl, -g, ImageUpdateLink
Gui, Font, s8 cDefault Norm Tahoma
nm_setStatus("Begin", "Macro")
Sleep, 100
if !GetRobloxHWND()
	disconnectCheck()
WinActivate, Roblox
;check UIPI
PostMessage, 0x100, 0x7, 0, , % "ahk_id " GetRobloxHWND()
if (ErrorLevel = 1)
	msgbox, 0x1030, WARNING!!, % "Your Roblox window is run as admin, but the macro is not!`nThis means the macro will be unable to send any inputs to Roblox.`nYou must either reinstall Roblox without administrative rights, or run Natro Macro as admin!`n`nNOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active.", 60
PostMessage, 0x101, 0x7, 0xC0000000, , % "ahk_id " GetRobloxHWND()
nm_setShiftLock(0)
nm_OpenMenu()
WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " GetRobloxHWND())
MouseMove, windowX+350, windowY+100
Prev_DetectHiddenWindows := A_DetectHiddenWindows
Prev_TitleMatchMode := A_TitleMatchMode
DetectHiddenWindows, On
SetTitleMatchMode, 2
MacroState:=2
if WinExist("Status.ahk ahk_class AutoHotkey") {
	PostMessage, 0x5552, 23, MacroState
}
if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
	PostMessage, 0x5552, 23, MacroState
}
if WinExist("background.ahk ahk_class AutoHotkey") {
	PostMessage, 0x5552, 23, MacroState
}
if (WGUIPID && WinExist("ahk_pid " WGUIPID " ahk_class AutoHotkey"))
	WinClose
DetectHiddenWindows, %Prev_DetectHiddenWindows%
SetTitleMatchMode, %Prev_TitleMatchMode%
;set stats
MacroStartTime:=nowUnix()
global PausedRuntime:=0
;set globals
nm_setStatus("Startup", "Setting Globals")
for k,v in config
{
	for i in v
	{
		GuiControlGet, temp, , %i%
		if ((temp = "") || InStr(temp, "`n"))
			IniRead, %i%, settings\nm_config.ini, %k%, %i%
		else
			GuiControlGet, %i%
	}
}
nm_ResetSessionStats()
global CurrentField
global RecentFBoost:="None"
global QuestGatherField:="None"
global BugDeathCheckLockout:=0
global AFBrollingDice:=0
global AFBuseGlitter:=0
global AFBuseBooster:=0
global QuestLadybugs:=0
global QuestRhinoBeetles:=0
global QuestSpider:=0
global QuestMantis:=0
global QuestScorpions:=0
global QuestWerewolf:=0
global QuestBarSize:=0
global QuestBarGapSize:=0
global QuestBarInset:=0
global BuckoRhinoBeetles:=0
global BuckoMantis:=0
global RileyLadybugs:=0
global RileyScorpions:=0
global RileyAll:=0
global GatherFieldBoostedStart:=nowUnix()-3600
global LastNatroSoBroke:=1
GuiControlGet, CurrentField
;set ActiveHotkeys[]
global ActiveHotkeys:=[]
;set hotbar values for actions handled by nm_hotbar()
whileNames:=["Always", "Attacking", "Gathering", "At Hive", "GatherStart"]
for key, val in whileNames {
	loop 6 {
		slot:=A_Index+1
		if(HotbarWhile%slot%=val) {
			;calculate seconds
			HBSecs:=HotbarTime%slot%
			;set array values
			last:=LastHotkey%slot%
			ActiveHotkeys.push([val, slot, HBSecs, last])
			;temp:=HotbarTime%slot%
			;msgbox %val%, %slot%, %HBSecs%, %last%`n%temp%
		}
	}
	;temp:=ActiveHotkeys.Length()
	;msgbox %val%=%temp%
}
;special hotbar cases
;MicroConverterKey
global MicroConverterKey
MicroConverterKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotbarWhile%slot%="Microconverter") {
		MicroConverterKey:="sc00" slot+1
		break
	}
}
;WhirligigKey
global WhirligigKey
WhirligigKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotbarWhile%slot%="Whirligig") {
		WhirligigKey:="sc00" slot+1
		break
	}
}
;EnzymesKey
global EnzymesKey
EnzymesKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotbarWhile%slot%="Enzymes") {
		EnzymesKey:="sc00" slot+1
		break
	}
}
;GlitterKey
global GlitterKey
GlitterKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotbarWhile%slot%="Glitter") {
		GlitterKey:="sc00" slot+1
		break
	}
}
;Snowflake
loop 6 {
	slot:=A_Index+1
	if(HotbarWhile%slot%="Snowflake") {
		ActiveHotkeys.push(["Snowflake", slot, HotbarTime%slot%, LastHotkey%slot%])
		break
	}
}
;Auto Field Boost WARNING @ start
if(AutoFieldBoostActive){
    if(AFBDiceEnable)
        if(AFBDiceLimitEnable)
            futureDice:=AFBDiceLimit-AFBdiceUsed
        else
            futureDice:="ALL"
    else
        futureDice:="None"
    if(AFBGlitterEnable)
        if(AFBGlitterLimitEnable)
            futureGlitter:=AFBGlitterLimit-AFBglitterUsed
        else
            futureGlitter:="ALL"
    else
        futureGlitter:="None"
	if(A_Args[1]!=1){
		msgbox, 257, WARNING!!, % """Automatic Field Boost"" is ACTIVATED.`n------------------------------------------------------------------------------------`nIf you continue the following quantity of items can be used:`nDice: " futureDice "`nGlitter: " futureGlitter "`n`nHIGHLY RECOMMENDED:`nDisable any non-essential tasks such as quests, bug runs, stingers, etc. Any time away from your gathering field can result in the loss of your field boost.", 30
		IfMsgBox Cancel
			return
	}
}
;start ancillary macros
run, "%exe_path32%" /script "submacros\background.ahk" "%NightLastDetected%" "%VBLastKilled%" "%StingerCheck%" "%StingerDailyBonusCheck%" "%AnnounceGuidingStar%" "%ReconnectInterval%" "%ReconnectHour%" "%ReconnectMin%" "%EmergencyBalloonPingCheck%" "%ConvertBalloon%"
;(re)start stat monitor
if (discordCheck && (((discordMode = 0) && RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$")) || ((discordMode = 1) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID))))
	run, "%exe_path64%" /script "submacros\StatMonitor.ahk" "%VersionID%"
;start main loop
nm_setStatus(0, "Main Loop")
nm_Start()
return
;STOP MACRO
stop:
Hotkey, %StopHotkey%, Off, UseErrorLevel
Hotkey, %PauseHotkey%, Off, UseErrorLevel
Hotkey, %StartHotkey%, Off, UseErrorLevel
nm_endWalk()
sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{%SC_Space% up}
click, up
if(MacroState) {
	TotalRuntime:=TotalRuntime+(nowUnix()-MacroStartTime)
	SessionRuntime:=SessionRuntime+(nowUnix()-MacroStartTime)
	if(!GatherStartTime)
		GatherStartTime:=nowUnix()
	TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
	SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	if(!ConvertStartTime)
		ConvertStartTime:=nowUnix()
	TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
	SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
}
IniWrite, %TotalRuntime%, settings\nm_config.ini, Status, TotalRuntime
IniWrite, %SessionRuntime%, settings\nm_config.ini, Status, SessionRuntime
IniWrite, %TotalGatherTime%, settings\nm_config.ini, Status, TotalGatherTime
IniWrite, %SessionGatherTime%, settings\nm_config.ini, Status, SessionGatherTime
IniWrite, %TotalConvertTime%, settings\nm_config.ini, Status, TotalConvertTime
IniWrite, %SessionConvertTime%, settings\nm_config.ini, Status, SessionConvertTime
nm_setStatus("End", "Macro")
DetectHiddenWindows, On
SetTitleMatchMode, 2
MacroState:=0
WinClose, StatMonitor.ahk ahk_class AutoHotkey
WinClose, background.ahk ahk_class AutoHotkey
WinClose, Status.ahk ahk_class AutoHotkey
getout()
Reload
Sleep, 10000
return
;PAUSE MACRO
pause:
if(state="startup")
	return
if(A_IsPaused) {
	WinActivate, Roblox
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
		Send {F16}
	else
	{
		if(FwdKeyState)
			sendinput {%FwdKey% down}
		if(BackKeyState)
			sendinput {%BackKey% down}
		if(LeftKeyState)
			sendinput {%LeftKey% down}
		if(RightKeyState)
			sendinput {%RightKey% down}
		if(SpaceKeyState)
			sendinput {%SC_Space% down}
	}
	nm_setStatus(PauseState, PauseObjective)
	MacroState:=2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	if WinExist("background.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	youDied:=0
	;manage runtimes
	MacroStartTime:=nowUnix()
	GatherStartTime:=nowUnix()
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	SetTitleMatchMode, %Prev_TitleMatchMode%
} else {
	if (ShowOnPause = 1)
		WinActivate, ahk_id %hGUI%
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows, On
	SetTitleMatchMode, 2
	if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
		Send {F16}
	else
	{
		FwdKeyState:=GetKeyState(FwdKey), BackKeyState:=GetKeyState(BackKey), LeftKeyState:=GetKeyState(LeftKey), RightKeyState:=GetKeyState(RightKey), SpaceKeyState:=GetKeyState(SC_Space)
		sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{%SC_Space% up}
		click, up
	}
	MacroState:=1
	if WinExist("Status.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	if WinExist("background.ahk ahk_class AutoHotkey")
		PostMessage, 0x5552, 23, MacroState
	PauseState:=state
	PauseObjective:=objective
	;manage runtimes
	TotalRuntime:=TotalRuntime+(nowUnix()-MacroStartTime)
	PausedRuntime:=PausedRuntime+(nowUnix()-MacroStartTime)
	SessionRuntime:=SessionRuntime+(nowUnix()-MacroStartTime)
	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	IniWrite, %TotalRuntime%, settings\nm_config.ini, Status, TotalRuntime
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	SetTitleMatchMode, %Prev_TitleMatchMode%
	nm_setStatus("Paused", "Press F2 to Continue")
}
Pause, Toggle, 1
return
;AUTOCLICKER
autoclicker(){
	global ClickMode, ClickCount, ClickDelay
	static toggle:=0
	toggle := !toggle
	while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
		click
		sleep %ClickDelay%
	}
}
toggle := 0
return
;TIMERS
timers:
ba_showPlanterTimers()
return

nm_WM_COPYDATA(wParam, lParam){
	Critical
	global LastGuid, PMondoGuid, MondoAction, MondoBuffCheck, currentWalk, FwdKey, BackKey, LeftKey, RightKey, SC_Space
	StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
    StringText := StrGet(StringAddress)  ; Copy the string out of the structure.
	if(wParam=1){ ;guiding star detected
		nm_setStatus("Detected", "Guiding Star in " . StringText)
		;pause
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
			Send {F16}
		else
		{
			FwdKeyState:=GetKeyState(FwdKey)
			BackKeyState:=GetKeyState(BackKey)
			LeftKeyState:=GetKeyState(LeftKey)
			RightKeyState:=GetKeyState(RightKey)
			SpaceKeyState:=GetKeyState(SC_Space)
			PauseState:=state
			PauseObjective:=objective
			sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{%SC_Space% up}
			click up
		}
		;Announce Guiding Star
		;calculate mins
		GSMins:=SubStr("0" Mod(A_Min+10, 60), -1)
		Sleep, 200
		Send {Text} /<<Guiding Star>> in %StringText% until __:%GSMins%`n
		sleep 250
		;set LastGuid
		LastGuid:=nowUnix()
		IniWrite, %LastGuid%, settings\nm_config.ini, Boost, LastGuid
		if(PMondoGuid && MondoBuffCheck && MondoAction="Guid") {
			nm_mondo()
			DetectHiddenWindows, %Prev_DetectHiddenWindows%
			return 0
		} else {
			if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
				Send {F16}
			else
			{
				if(FwdKeyState)
					sendinput {%FwdKey% down}
				if(BackKeyState)
					sendinput {%BackKey% down}
				if(LeftKeyState)
					sendinput {%LeftKey% down}
				if(RightKeyState)
					sendinput {%RightKey% down}
				if(SpaceKeyState)
					sendinput {%SC_Space% down}
			}
		}
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
	}
	else {
		InStr(StringText, ": ") ? nm_setStatus(SubStr(StringText, 1, InStr(StringText, ": ")-1), SubStr(StringText, InStr(StringText, ": ")+2)) : nm_setStatus(StringText)
	}
	return 0
}
nm_ForceLabel(wParam){
	Critical
	switch wParam
	{
		case 1:
		SetTimer, start, -500

		case 2:
		GoSub, pause

		case 3:
		GoSub, stop
	}
	return 0
}
nm_ForceReconnect(wParam){
	Critical
	global ReconnectDelay := wParam
	nm_endWalk()
	CloseRoblox()
	return 0
}
nm_sendHeartbeat(){
	Critical
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey") {
		PostMessage, 0x5556, 1
	}
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
	return 0
}
nm_backgroundEvent(wParam, lParam){
	Critical
	global youDied, NightLastDetected, VBState, BackpackPercent, BackpackPercentFiltered, FieldGuidDetected, HasPopStar, PopStarActive, DailyReconnect
	static arr:=["youDied", "NightLastDetected", "VBState", "BackpackPercent", "BackpackPercentFiltered", "FieldGuidDetected", "HasPopStar", "PopStarActive", "DailyReconnect"]

	var := arr[wParam], %var% := lParam
	return 0
}
nm_setGlobalStr(wParam, lParam)
{
	global
	Critical
	local var
	; enumeration
	#Include %A_ScriptDir%\submacros\shared\EnumStr.ahk
	static sections := ["Boost","Collect","Gather","Gui","Planters","Quests","Settings","Status"]

	var := arr[wParam], section := sections[lParam]
	IniRead, %var%, settings\nm_config.ini, %section%, %var%
	nm_UpdateGUIVar(var)
	return 0
}
nm_setGlobalInt(wParam, lParam)
{
	global
	Critical
	local var
	; enumeration
	#Include %A_ScriptDir%\submacros\shared\EnumInt.ahk

	var := arr[wParam], %var% := lParam
	nm_UpdateGUIVar(var)
	return 0
}
nm_UpdateGUIVar(var)
{
	global
	local k, hCtrl
	static patternsizelist:="|XS|S|M|L|XL|"
		, patternrepslist:="|1|2|3|4|5|6|7|8|9|"
		, untilpacklist:="|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|"
		, returntypelist:="|Walk|Reset|"
		, sprinklerloclist:="|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|"
		, sprinklerdistlist:="|1|2|3|4|5|6|7|8|9|10|"
		, rotatedirectionlist:="|None|Left|Right|"
		, rotatetimeslist:="|1|2|3|4|"
		, fieldnamelist:="|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|"
		, hiveslotlist:="|1|2|3|4|5|6|"
		, movemethodlist:="|Walk|Cannon|"
		, sprinklertypelist:="|None|Basic|Silver|Golden|Diamond|Supreme|"
		, convertballoonlist:="|Always|Never|Every|"
		, antpassactionlist:="|Pass|Challenge|"
		, fieldboosterlist:="|None|Blue|Red|Mountain|"
		, fieldboosterminslist:="|0|5|10|15|20|30|"
	GuiControlGet, k, Name, %var%
	switch % k
	{
		case "FieldPatternSize1", "FieldPatternSize2", "FieldPatternSize3":
		GuiControl, , %k%, % StrReplace(patternsizelist, "|" %k% "|", "|" %k% "||")

		case "FieldPatternReps1", "FieldPatternReps2", "FieldPatternReps3":
		GuiControl, , %k%, % StrReplace(patternrepslist, "|" %k% "|", "|" %k% "||")

		case "FieldUntilPack1", "FieldUntilPack2", "FieldUntilPack3":
		GuiControl, , %k%, % StrReplace(untilpacklist, "|" %k% "|", "|" %k% "||")

		case "FieldReturnType1", "FieldReturnType2", "FieldReturnType3":
		GuiControl, , %k%, % StrReplace(returntypelist, "|" %k% "|", "|" %k% "||")

		case "FieldSprinklerLoc1", "FieldSprinklerLoc2", "FieldSprinklerLoc3":
		GuiControl, , %k%, % StrReplace(sprinklerloclist, "|" %k% "|", "|" %k% "||")

		case "FieldSprinklerDist1", "FieldSprinklerDist2", "FieldSprinklerDist3":
		GuiControl, , %k%, % StrReplace(sprinklerdistlist, "|" %k% "|", "|" %k% "||")

		case "FieldRotateDirection1", "FieldRotateDirection2", "FieldRotateDirection3":
		GuiControl, , %k%, % StrReplace(rotatedirectionlist, "|" %k% "|", "|" %k% "||")

		case "FieldRotateTimes1", "FieldRotateTimes2", "FieldRotateTimes3":
		GuiControl, , %k%, % StrReplace(rotatetimeslist, "|" %k% "|", "|" %k% "||")

		case "FieldName1":
		GuiControl, , %k%, % StrReplace(fieldnamelist, "|" %k% "|", "|" %k% "||")
		nm_FieldSelect1()

		case "FieldName2":
		GuiControl, , %k%, % StrReplace(fieldnamelist, "|" %k% "|", "|" %k% "||")
		nm_FieldSelect2()

		case "FieldName3":
		GuiControl, , %k%, % StrReplace(fieldnamelist, "|" %k% "|", "|" %k% "||")
		nm_FieldSelect3()

		case "FieldPattern1", "FieldPattern2", "FieldPattern3":
		GuiControl, , %k%, % StrReplace(patternlist "Stationary|", "|" %k% "|", "|" %k% "||")

		case "HiveSlot", "MoveMethod", "SprinklerType", "MondoAction", "AntPassAction":
		GuiControl, , %k%, % StrReplace(%k%list, "|" %k% "|", "|" %k% "||")

		case "ConvertBalloon":
		GuiControl, , %k%, % StrReplace(convertballoonlist, "|" %k% "|", "|" %k% "||")
		nm_ConvertBalloon()

		case "FieldBooster1":
		GuiControl, , %k%, % StrReplace(fieldboosterlist, "|" %k% "|", "|" %k% "||")
		nm_FieldBooster1()

		case "FieldBooster2":
		GuiControl, , %k%, % StrReplace(fieldboosterlist, "|" %k% "|", "|" %k% "||")
		nm_FieldBooster2()

		case "FieldBooster3":
		GuiControl, , %k%, % StrReplace(fieldboosterlist, "|" %k% "|", "|" %k% "||")
		nm_FieldBooster3()

		case "FieldBoosterMins":
		GuiControl, , %k%, % StrReplace(fieldboosterminslist, "|" %k% "|", "|" %k% "||")

		case "HotbarWhile2", "HotbarWhile3", "HotbarWhile4", "HotbarWhile5", "HotbarWhile6", "HotbarWhile7":
		GuiControl, , %k%, % StrReplace(hotbarwhilelist, "|" %k% "|", "|" %k% "||")
		nm_HotbarWhile()

		case "QuestGatherReturnBy":
		GuiControl, , %k%, % StrReplace(returntypelist, "|" %k% "|", "|" %k% "||")

		case "KingBeetleAmuletMode", "ShellAmuletMode":
		GuiControlGet, hCtrl, Hwnd, %k%
		GuiControl, , %k%, % %k%
		nm_saveAmulet(hCtrl)

		case "HotbarTime2", "HotbarTime3", "HotbarTime4", "HotbarTime5", "HotbarTime6", "HotbarTime7":
		GuiControl, , %k%, % %k%
		nm_HotbarWhile()

		Case "SnailTime":
		GuiControl, , SnailTimeUpDown, % (SnailTime = "Kill") ? 4 : SnailTime//5
		nm_SnailTime()

		Case "ChickTime":
		GuiControl, , ChickTimeUpDown, % (ChickTime = "Kill") ? 4 : ChickTime//5
		nm_ChickTime()

		case "InputSnailHealth":
		GuiControl, , SnailHealthEdit, Round(30000000*InputSnailHealth/100)
		GuiControl, % "+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0) " +Redraw", SnailHealthText
		GuiControl, , SnailHealthText, % InputSnailHealth "%"

		case "InputChickHealth":
		GuiControl, % "+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0) " +Redraw", ChickHealthText
		GuiControl, , ChickHealthText, % InputChickHealth "%"

		case "":

		default:
		GuiControl, , %k%, % %k%
	}
}
