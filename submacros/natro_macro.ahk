/*
Natro Macro (https://github.com/NatroTeam/NatroMacro)
Copyright © Natro Team (https://github.com/NatroTeam)

This file is part of Natro Macro. Our source code will always be open and available.

Natro Macro is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later version.

Natro Macro is distributed in the hope that it will be useful. This does not give you the right to steal sections from our code, distribute it under your own name, then slander the macro.

You should have received a copy of the license along with Natro Macro. If not, please redownload from an official source.
*/

;Compiler directives (currently not in use):
;@Ahk2Exe-SetName Natro Macro
;@Ahk2Exe-SetDescription Natro Macro
;@Ahk2Exe-SetCompanyName Natro Team
;@Ahk2Exe-SetCopyright Copyright © Natro Team
;@Ahk2Exe-SetOrigFilename natro_macro.exe
#MaxThreads 255
#Requires AutoHotkey v2.0
#SingleInstance Force

#Include "%A_ScriptDir%\..\lib"
#Include "Gdip_All.ahk"
#Include "Gdip_ImageSearch.ahk"
#Include "JSON.ahk"
#Include "Roblox.ahk"
#Include "DurationFromSeconds.ahk"
#Include "nowUnix.ahk"

#Warn VarUnset, Off
OnError (e, mode) => (mode = "Return") ? -1 : 0

SetWorkingDir A_ScriptDir "\.."
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

; check for the correct AHK version before starting
RunWith32() {
	if (A_PtrSize != 4) {
		SplitPath A_AhkPath, , &ahkDirectory

		if !FileExist(ahkPath := ahkDirectory "\AutoHotkey32.exe")
			MsgBox "Couldn't find the 32-bit version of Autohotkey in:`n" ahkPath, "Error", 0x10
		else
			ReloadScript(ahkpath)

		ExitApp
	}
}
RunWith32()

ReloadScript(ahkpath) {
	static cmd := DllCall("GetCommandLine", "Str"), params := DllCall("shlwapi\PathGetArgs","Str",cmd,"Str")
	Run '"' ahkpath '" /restart ' params
}

; elevate script if required (check write permissions in ScriptDir using Heartbeat.ahk)
ElevateScript() {
	try
		file := FileOpen("submacros\Heartbeat.ahk", "a")
	catch {
		if (!A_IsAdmin || !(DllCall("GetCommandLine","Str") ~= " /restart(?!\S)"))
			Try RunWait '*RunAs "' A_AhkPath '" /script /restart "' A_ScriptFullPath '"'
		if !A_IsAdmin {
			MsgBox "You must run Natro Macro as administrator in this folder!`nIf you don't want to do this, move the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010
			ExitApp
		}
		; elevated but still can't write, read-only directory?
		MsgBox "You cannot run Natro Macro in this folder!`nTry moving the macro to a different folder (e.g. Downloads, Desktop)", "Error", 0x40010
	}
	else
		file.Close()
}
ElevateScript()

; declare executable paths
exe_path32 := A_AhkPath
exe_path64 := (A_Is64bitOS && FileExist("submacros\AutoHotkey64.exe")) ? (A_WorkingDir "\submacros\AutoHotkey64.exe") : A_AhkPath

; close any remnant running natro scripts and start heartbeat
CloseScripts(hb:=0) {
	list := WinGetList("ahk_class AutoHotkey ahk_exe " exe_path32)
	if (exe_path32 != exe_path64)
		list.Push(WinGetList("ahk_class AutoHotkey ahk_exe " exe_path64)*)
	for hwnd in list
		if !((hwnd = A_ScriptHwnd) || ((hb = 1) && A_Args.Has(2) && (hwnd = A_Args[2])))
			try WinClose "ahk_id " hwnd
}
DetectHiddenWindows 1
CloseScripts(1)
if !WinExist("Heartbeat.ahk ahk_class AutoHotkey")
	run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\Heartbeat.ahk"'
DetectHiddenWindows 0

; OnMessages
OnMessage(0x004A, nm_WM_COPYDATA)
OnMessage(0x5550, nm_ForceLabel, 255)
OnMessage(0x5551, nm_setShiftLock, 255)
OnMessage(0x5552, nm_setGlobalInt, 255)
OnMessage(0x5553, nm_setGlobalStr, 255)
OnMessage(0x5555, nm_backgroundEvent, 255)
OnMessage(0x5556, nm_sendHeartbeat)
OnMessage(0x5557, nm_ForceReconnect)
OnMessage(0x5558, nm_AmuletPrompt)
OnMessage(0x5559, nm_FindItem)

; set version identifier
VersionID := "1.0.1"

;initial load warnings
if (A_ScreenDPI != 96)
	MsgBox "
	(
	Your Display Scale seems to be a value other than 100%. This means the macro will NOT work correctly!

	To change this:
	Right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100% -> Close and Restart Roblox before starting the macro.
	)", "WARNING!!", 0x1030 " T60"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE SETTINGS FOLDERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_CreateFolder(folder) {
	if !FileExist(folder)
	{
		try
			DirCreate folder
		catch
			MsgBox
			(
			'Could not create the ' folder ' directory!
			This means the macro will NOT work correctly!
			Try moving the macro to a different folder (e.g. Downloads, Desktop)'
			), "Error", 0x40010 " T60"
	}
}
nm_CreateFolder("settings")
nm_CreateFolder("settings\imported")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IMPORT PATTERNS AND PATHS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; assign scan codes to key variables
TCFBKey:=FwdKey:="sc011" ; w
TCLRKey:=LeftKey:="sc01e" ; a
AFCFBKey:=BackKey:="sc01f" ; s
AFCLRKey:=RightKey:="sc020" ; d
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

; import patterns and syntax check
nm_importPatterns()
{
	global patterns := Map()
	patterns.CaseSense := 0
	global patternlist := []

	if FileExist("settings\imported\patterns.ahk")
		file := FileOpen("settings\imported\patterns.ahk", "r"), imported := file.Read(), file.Close()
	else
		imported := ""

	import := ""
	Loop Files A_WorkingDir "\patterns\*.ahk"
	{
		file := FileOpen(A_LoopFilePath, "r"), pattern := file.Read(), file.Close()
		if RegexMatch(pattern, "im)patterns\[")
			MsgBox
			(
			"Pattern '" A_LoopFileName "' seems to be deprecated!
			This means the pattern will NOT work!
			Check for an updated version of the pattern
			or ask the creator to update it"
			), "Error", 0x40010 " T60"
		if !InStr(imported, imported_pattern := '("' (pattern_name := StrReplace(A_LoopFileName, "." A_LoopFileExt)) '")`r`n' pattern '`r`n`r`n')
		{
			script :=
			(
			'
			#NoTrayIcon
			#SingleInstance Off
			#Warn All, StdOut

			' nm_KeyVars() '

			size:=1, reps:=1, facingcorner:=0
			FieldName:=FieldPattern:=FieldPatternSize:=FieldReturnType:=FieldSprinklerLoc:=FieldRotateDirection:=""
			FieldUntilPack:=FieldPatternReps:=FieldPatternShift:=FieldSprinklerDist:=FieldRotateTimes:=FieldDriftCheck:=FieldPatternInvertFB:=FieldPatternInvertLR:=FieldUntilMins:=0

			Walk(param1, param2?) => ""
			HyperSleep(param1) => ""
			nm_Walk(param1, param2, param3?) => ""
			Gdip_ImageSearch(*) => ""
			Gdip_BitmapFromBase64(*) => ""
			nm_CameraRotation(param1, param2) => ""

			' pattern '

			'
			)

			exec := ComObject("WScript.Shell").Exec('"' exe_path64 '" /script /Validate /ErrorStdOut *'), exec.StdIn.Write(script), exec.StdIn.Close()
			if (stdout := exec.StdOut.ReadAll())
			{
				MsgBox
				(
				"Unable to import '" pattern_name "' pattern!
				Click 'OK' to continue loading the macro without this pattern installed, otherwise fix the error and reload the macro.

				The error found on loading is stated below:
				" stdout
				), "Unable to Import Pattern!", 0x40010 " T60"
				continue
			}
		}

		import .= imported_pattern
		patternlist.Push(pattern_name)
		patterns[pattern_name] := pattern
	}

	if (import != imported)
		file := FileOpen(A_WorkingDir "\settings\imported\patterns.ahk", "w-d"), file.Write(import), file.Close()
}
nm_importPatterns()

; import paths
nm_importPaths()
{
	static path_names := Map(
		"gtb", ["blue", "mountain", "red"], ; go to (field) booster
		"gtc", ["clock", "antpass", "robopass", "honeydis", "treatdis", "blueberrydis", "strawberrydis", "coconutdis", "gluedis", "royaljellydis", "blender", "windshrine", ; go to collect (machine)
				"stockings", "wreath", "feast", "gingerbread", "snowmachine", "candles", "samovar", "lidart", "gummybeacon", "rbpdelevel", ; beesmas
				"honeylb", "honeystorm", "stickerstack", "stickerprinter", "normalmm", "megamm", "nightmm", "extrememm", "wintermm"], ; other
		"gtf", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"], ; go to field
		"gtp", ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"], ; go to planter
		"gtq", ["black", "brown", "bucko", "honey", "polar", "riley"], ; go to questgiver
		"wf",  ["bamboo", "blueflower", "cactus", "clover", "coconut", "dandelion", "mountaintop", "mushroom", "pepper", "pinetree", "pineapple", "pumpkin",
				"rose", "spider", "strawberry", "stump", "sunflower"]  ; walk from (field to hive)
	)

	global paths := Map()
	paths.CaseSense := 0

	for k, list in path_names
	{
		(paths[k] := Map()).CaseSense := 0
		for v in list
		{
			try {
				file := FileOpen(A_WorkingDir "\paths\" k "-" v ".ahk", "r"), paths[k][v] := file.Read(), file.Close()
				if regexMatch(paths[k][v], "im)paths\[")
					MsgBox
					(
					"Path '" k '-' v "' seems to be deprecated!
					This means the macro will NOT work correctly!
					Check for an updated version of the path or
					restore the default path"
					), "Error", 0x40010 " T60"
			}
			catch
				MsgBox
				(
				"Could not find the '" k '-' v "' path!
				This means the macro will NOT work correctly!
				Make sure the path exists in the 'paths' folder and redownload if it doesn't!"
				), "Error", 0x40010 " T60"
		}
	}
}
nm_importPaths()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IMPORT GLOBALS FROM CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importConfig()
{
	global
	local config := Map() ; store default values, these are loaded initially

	config["Settings"] := Map("GuiTheme", "MacLion3"
		, "AlwaysOnTop", 0
		, "MoveSpeedNum", 28
		, "MoveMethod", "Cannon"
		, "SprinklerType", "Supreme"
		, "MultiReset", 0
		, "ConvertBalloon", "Gather"
		, "ConvertMins", 30
		, "LastConvertBalloon", 1
		, "GatherDoubleReset", 1
		, "DisableToolUse", 0
		, "AnnounceGuidingStar", 0
		, "NewWalk", 1
		, "HiveSlot", 6
		, "HiveBees", 50
		, "ConvertDelay", 5
		, "PrivServer", ""
		, "FallbackServer1", ""
		, "FallbackServer2", ""
		, "FallbackServer3", ""
		, "ReconnectMethod", "Deeplink"
		, "ReconnectInterval", ""
		, "ReconnectHour", ""
		, "ReconnectMin", ""
		, "ReconnectMessage", 0
		, "PublicFallback", 1
		, "GuiX", ""
		, "GuiY", ""
		, "GuiTransparency", 0
		, "BuffDetectReset", 0
		, "ClickCount", 1000
		, "ClickDelay", 10
		, "ClickMode", 1
		, "ClickDuration", 50
		, "KeyDelay", 20
		, "StartHotkey", "F1"
		, "PauseHotkey", "F2"
		, "StopHotkey", "F3"
		, "AutoClickerHotkey", "F4"
		, "TimersHotkey", "F5"
		, "ShowOnPause", 0
		, "IgnoreUpdateVersion", ""
		, "FDCWarn", 1
		, "priorityListNumeric", 12345678)

	config["Status"] := Map("StatusLogReverse", 0
		, "TotalRuntime", 0
		, "SessionRuntime", 0
		, "TotalGatherTime", 0
		, "SessionGatherTime", 0
		, "TotalConvertTime", 0
		, "SessionConvertTime", 0
		, "TotalViciousKills", 0
		, "SessionViciousKills", 0
		, "TotalBossKills", 0
		, "SessionBossKills", 0
		, "TotalBugKills", 0
		, "SessionBugKills", 0
		, "TotalPlantersCollected", 0
		, "SessionPlantersCollected", 0
		, "TotalQuestsComplete", 0
		, "SessionQuestsComplete", 0
		, "TotalDisconnects", 0
		, "SessionDisconnects", 0
		, "DiscordMode", 0
		, "DiscordCheck", 0
		, "Webhook", ""
		, "BotToken", ""
		, "MainChannelCheck", 1
		, "MainChannelID", ""
		, "ReportChannelCheck", 1
		, "ReportChannelID", ""
		, "WebhookEasterEgg", 0
		, "ssCheck", 0
		, "ssDebugging", 0
		, "CriticalSSCheck", 1
		, "AmuletSSCheck", 1
		, "MachineSSCheck", 1
		, "BalloonSSCheck", 1
		, "ViciousSSCheck", 1
		, "DeathSSCheck", 1
		, "PlanterSSCheck", 1
		, "HoneySSCheck", 0
		, "criticalCheck", 0
		, "discordUID", ""
		, "CriticalErrorPingCheck", 1
		, "DisconnectPingCheck", 1
		, "GameFrozenPingCheck", 1
		, "PhantomPingCheck", 1
		, "UnexpectedDeathPingCheck", 0
		, "EmergencyBalloonPingCheck", 0
		, "commandPrefix", "?"
		, "NightAnnouncementCheck", 0
		, "NightAnnouncementName", ""
		, "NightAnnouncementPingID", ""
		, "NightAnnouncementWebhook", ""
		, "DebugLogEnabled", 1
		, "SessionTotalHoney", 0
		, "HoneyAverage", 0
		, "HoneyUpdateSSCheck", 1)

	config["Gather"] := Map("FieldName1", "Sunflower"
		, "FieldName2", "None"
		, "FieldName3", "None"
		, "FieldPattern1", "Squares"
		, "FieldPattern2", "Lines"
		, "FieldPattern3", "Lines"
		, "FieldPatternSize1", "M"
		, "FieldPatternSize2", "M"
		, "FieldPatternSize3", "M"
		, "FieldPatternReps1", 3
		, "FieldPatternReps2", 3
		, "FieldPatternReps3", 3
		, "FieldPatternShift1", 0
		, "FieldPatternShift2", 0
		, "FieldPatternShift3", 0
		, "FieldPatternInvertFB1", 0
		, "FieldPatternInvertFB2", 0
		, "FieldPatternInvertFB3", 0
		, "FieldPatternInvertLR1", 0
		, "FieldPatternInvertLR2", 0
		, "FieldPatternInvertLR3", 0
		, "FieldUntilMins1", 20
		, "FieldUntilMins2", 15
		, "FieldUntilMins3", 15
		, "FieldUntilPack1", 95
		, "FieldUntilPack2", 95
		, "FieldUntilPack3", 95
		, "FieldReturnType1", "Walk"
		, "FieldReturnType2", "Walk"
		, "FieldReturnType3", "Walk"
		, "FieldSprinklerLoc1", "Center"
		, "FieldSprinklerLoc2", "Center"
		, "FieldSprinklerLoc3", "Center"
		, "FieldSprinklerDist1", 10
		, "FieldSprinklerDist2", 10
		, "FieldSprinklerDist3", 10
		, "FieldRotateDirection1", "None"
		, "FieldRotateDirection2", "None"
		, "FieldRotateDirection3", "None"
		, "FieldRotateTimes1", 1
		, "FieldRotateTimes2", 1
		, "FieldRotateTimes3", 1
		, "FieldDriftCheck1", 1
		, "FieldDriftCheck2", 1
		, "FieldDriftCheck3", 1
		, "CurrentFieldNum", 1)

	config["Collect"] := Map("ClockCheck", 1
		, "LastClock", 1
		, "MondoBuffCheck", 0
		, "MondoAction", "Buff"
		, "MondoLootDirection", "Random"
		, "LastMondoBuff", 1
		, "AntPassCheck", 0
		, "AntPassBuyCheck", 0
		, "AntPassAction", "Pass"
		, "LastAntPass", 1
		, "RoboPassCheck", 0
		, "LastRoboPass", 1
		, "HoneystormCheck", 0
		, "LastHoneystorm", 1
		, "HoneyDisCheck", 0
		, "LastHoneyDis", 1
		, "TreatDisCheck", 0
		, "LastTreatDis", 1
		, "BlueberryDisCheck", 0
		, "LastBlueberryDis", 1
		, "StrawberryDisCheck", 0
		, "LastStrawberryDis", 1
		, "CoconutDisCheck", 0
		, "LastCoconutDis", 1
		, "RoyalJellyDisCheck", 0
		, "LastRoyalJellyDis", 1
		, "GlueDisCheck", 0
		, "LastGlueDis", 1
		, "LastBlueBoost", 1
		, "LastRedBoost", 1
		, "LastMountainBoost", 1
		, "BeesmasGatherInterruptCheck", 0
		, "StockingsCheck", 0
		, "LastStockings", 1
		, "WreathCheck", 0
		, "LastWreath", 1
		, "FeastCheck", 0
		, "LastFeast", 1
		, "RBPDelevelCheck", 0
		, "LastRBPDelevel", 1
		, "GingerbreadCheck", 0
		, "LastGingerbread", 1
		, "SnowMachineCheck", 0
		, "LastSnowMachine", 1
		, "CandlesCheck", 0
		, "LastCandles", 1
		, "SamovarCheck", 0
		, "LastSamovar", 1
		, "LidArtCheck", 0
		, "LastLidArt", 1
		, "GummyBeaconCheck", 0
		, "LastGummyBeacon", 1
		, "MonsterRespawnTime", 0
		, "BugrunInterruptCheck", 0
		, "BugrunLadybugsCheck", 0
		, "BugrunLadybugsLoot", 0
		, "LastBugrunLadybugs", 1
		, "BugrunRhinoBeetlesCheck", 0
		, "BugrunRhinoBeetlesLoot", 0
		, "LastBugrunRhinoBeetles", 1
		, "BugrunSpiderCheck", 0
		, "BugrunSpiderLoot", 0
		, "LastBugrunSpider", 1
		, "BugrunMantisCheck", 0
		, "BugrunMantisLoot", 0
		, "LastBugrunMantis", 1
		, "BugrunScorpionsCheck", 0
		, "BugrunScorpionsLoot", 0
		, "LastBugrunScorpions", 1
		, "BugrunWerewolfCheck", 0
		, "BugrunWerewolfLoot", 0
		, "LastBugrunWerewolf", 1
		, "TunnelBearCheck", 0
		, "TunnelBearBabyCheck", 0
		, "LastTunnelBear", 1
		, "KingBeetleCheck", 0
		, "KingBeetleBabyCheck", 0
		, "KingBeetleAmuletMode", 1
		, "LastKingBeetle", 1
		, "InputSnailHealth", 100.00
		, "SnailTime", 15
		, "InputChickHealth", 100.00
		, "ChickLevel", 10
		, "ChickTime", 15
		, "StumpSnailCheck", 0
		, "ShellAmuletMode", 1
		, "LastStumpSnail", 1
		, "CommandoCheck", 0
		, "LastCommando", 1
		, "CocoCrabCheck", 0
		, "LastCocoCrab", 1
		, "StingerCheck", 0
		, "StingerPepperCheck", 1
		, "StingerMountainTopCheck", 1
		, "StingerRoseCheck", 1
		, "StingerCactusCheck", 1
		, "StingerSpiderCheck", 1
		, "StingerCloverCheck", 1
		, "StingerDailyBonusCheck", 0
		, "NightLastDetected", 1
		, "VBLastKilled", 1
		, "MondoSecs", 120
		, "NormalMemoryMatchCheck", 0
		, "LastNormalMemoryMatch", 1
		, "MegaMemoryMatchCheck", 0
		, "LastMegaMemoryMatch", 1
		, "ExtremeMemoryMatchCheck", 0
		, "LastExtremeMemoryMatch", 1
		, "NightMemoryMatchCheck", 0
		, "LastNightMemoryMatch", 1
		, "WinterMemoryMatchCheck", 0
		, "LastWinterMemoryMatch", 1
		, "MicroConverterMatchIgnore", 0
		, "SunflowerSeedMatchIgnore", 0
		, "JellyBeanMatchIgnore", 0
		, "RoyalJellyMatchIgnore", 0
		, "TicketMatchIgnore", 0
		, "CyanTrimMatchIgnore", 0
		, "OilMatchIgnore", 0
		, "StrawberryMatchIgnore", 0
		, "CoconutMatchIgnore", 0
		, "TropicalDrinkMatchIgnore", 0
		, "RedExtractMatchIgnore", 0
		, "MagicBeanMatchIgnore", 0
		, "PineappleMatchIgnore", 0
		, "StarJellyMatchIgnore", 0
		, "EnzymeMatchIgnore", 0
		, "BlueExtractMatchIgnore", 0
		, "GumdropMatchIgnore", 0
		, "FieldDiceMatchIgnore", 0
		, "MoonCharmMatchIgnore", 0
		, "BlueberryMatchIgnore", 0
		, "GlitterMatchIgnore", 0
		, "StingerMatchIgnore", 0
		, "TreatMatchIgnore", 0
		, "GlueMatchIgnore", 0
		, "CloudVialMatchIgnore", 0
		, "SoftWaxMatchIgnore", 0
		, "HardWaxMatchIgnore", 0
		, "SwirledWaxMatchIgnore", 0
		, "NightBellMatchIgnore", 0
		, "HoneysuckleMatchIgnore", 0
		, "SuperSmoothieMatchIgnore", 0
		, "SmoothDiceMatchIgnore", 0
		, "NeonberryMatchIgnore", 0
		, "GingerbreadMatchIgnore", 0
		, "SilverEggMatchIgnore", 0
		, "GoldEggMatchIgnore", 0
		, "DiamondEggMatchIgnore", 0
		, "MemoryMatchInterruptCheck", 0
		, "StickerPrinterCheck", 0
		, "LastStickerPrinter", 1
		, "StickerPrinterEgg", "Basic")

	config["Shrine"] := Map("ShrineCheck", 0
		, "LastShrine", 1
		, "ShrineAmount1", 0
		, "ShrineAmount2", 0
		, "ShrineItem1", "None"
		, "ShrineItem2", "None"
		, "ShrineIndex1", 1
		, "ShrineIndex2", 1
		, "ShrineRot", 1)

	config["Blender"] := Map("BlenderRot", 1
		, "BlenderCheck", 1
		, "TimerInterval", 0
		, "BlenderItem1", "None"
		, "BlenderItem2", "None"
		, "BlenderItem3", "None"
		, "BlenderAmount1", 0
		, "BlenderAmount2", 0
		, "BlenderAmount3", 0
		, "BlenderIndex1", 1
		, "BlenderIndex2", 1
		, "BlenderIndex3", 1
		, "BlenderTime1", 0
		, "BlenderTime2", 0
		, "BlenderTime3", 0
		, "BlenderEnd",  0
		, "LastBlenderRot", 1
		, "BlenderCount1", 0
		, "BlenderCount2", 0
		, "BlenderCount3", 0)

	config["Boost"] := Map("FieldBoostStacks", 0
		, "FieldBooster1", "None"
		, "FieldBooster2", "None"
		, "FieldBooster3", "None"
		, "BoostChaserCheck", 0
		, "HotbarWhile2", "Never"
		, "HotbarWhile3", "Never"
		, "HotbarWhile4", "Never"
		, "HotbarWhile5", "Never"
		, "HotbarWhile6", "Never"
		, "HotbarWhile7", "Never"
		, "FieldBoosterMins", 15
		, "HotbarTime2", 900
		, "HotbarTime3", 900
		, "HotbarTime4", 900
		, "HotbarTime5", 900
		, "HotbarTime6", 900
		, "HotbarTime7", 900
		, "HotbarMax2", 0
		, "HotbarMax3", 0
		, "HotbarMax4", 0
		, "HotbarMax5", 0
		, "HotbarMax6", 0
		, "HotbarMax7", 0
		, "LastHotkey2", 1
		, "LastHotkey3", 1
		, "LastHotkey4", 1
		, "LastHotkey5", 1
		, "LastHotkey6", 1
		, "LastHotkey7", 1
		, "LastWhirligig", 1
		, "LastEnzymes", 1
		, "LastGlitter", 1
		, "LastMicroConverter", 1
		, "LastGuid", 1
		, "AutoFieldBoostActive", 0
		, "AutoFieldBoostRefresh", 12.5
		, "AFBDiceEnable", 0
		, "AFBGlitterEnable", 0
		, "AFBFieldEnable", 0
		, "AFBDiceHotbar", "None"
		, "AFBGlitterHotbar", "None"
		, "AFBDiceLimitEnable", 1
		, "AFBGlitterLimitEnable", 1
		, "AFBHoursLimitEnable", 0
		, "AFBDiceLimit", 1
		, "AFBGlitterLimit", 1
		, "AFBHoursLimit", .01
		, "FieldLastBoosted", 1
		, "FieldLastBoostedBy", "None"
		, "FieldNextBoostedBy", "None"
		, "AFBdiceUsed", 0
		, "AFBglitterUsed", 0
		, "BlueFlowerBoosterCheck", 1
		, "BambooBoosterCheck", 1
		, "PineTreeBoosterCheck", 1
		, "DandelionBoosterCheck", 1
		, "SunflowerBoosterCheck", 1
		, "CloverBoosterCheck", 1
		, "SpiderBoosterCheck", 1
		, "PineappleBoosterCheck", 1
		, "CactusBoosterCheck", 1
		, "PumpkinBoosterCheck", 1
		, "MushroomBoosterCheck", 1
		, "StrawberryBoosterCheck", 1
		, "RoseBoosterCheck", 1
		, "PepperBoosterCheck", 1
		, "StumpBoosterCheck", 1
		, "CoconutBoosterCheck", 0
		, "StickerStackCheck", 0
		, "LastStickerStack", 1
		, "StickerStackItem", "Tickets"
		, "StickerStackMode", 0
		, "StickerStackTimer", 900
		, "StickerStackHive", 0
		, "StickerStackCub", 0
		, "StickerStackVoucher", 0)

	config["Quests"] := Map("QuestGatherMins", 5
		, "QuestGatherReturnBy", "Walk"
		, "QuestBoostCheck", 0
		, "PolarQuestCheck", 0
		, "PolarQuestGatherInterruptCheck", 1
		, "PolarQuestProgress", "Unknown"
		, "HoneyQuestCheck", 0
		, "HoneyQuestProgress", "Unknown"
		, "BlackQuestCheck", 0
		, "BlackQuestProgress", "Unknown"
		, "LastBlackQuest", 1
		, "BrownQuestCheck", 0
		, "BrownQuestProgress", "Unknown"
		, "LastBrownQuest", 1
		, "BuckoQuestCheck", 0
		, "BuckoQuestGatherInterruptCheck", 1
		, "BuckoQuestProgress", "Unknown"
		, "RileyQuestCheck", 0
		, "RileyQuestGatherInterruptCheck", 1
		, "RileyQuestProgress", "Unknown")

	config["Planters"] := Map("LastComfortingField", "None"
		, "LastRefreshingField", "None"
		, "LastSatisfyingField", "None"
		, "LastMotivatingField", "None"
		, "LastInvigoratingField", "None"
		, "MPlanterGatherA", 0
		, "MPlanterGather1", 0
		, "MPlanterGather2", 0
		, "MPlanterGather3", 0
		, "MPlanterHold1", 0
		, "MPlanterHold2", 0
		, "MPlanterHold3", 0
		, "MPlanterSmoking1", 0
		, "MPlanterSmoking2", 0
		, "MPlanterSmoking3", 0
		, "MPuffModeA", 0
		, "MPuffMode1", 0
		, "MPuffMode2", 0
		, "MPuffMode3", 0
		, "MConvertFullBagHarvest", 0
		, "MGatherPlanterLoot", 1
		, "PlanterHarvestNow1", 0
		, "PlanterHarvestNow2", 0
		, "PlanterHarvestNow3", 0
		, "PlanterSS1", 0
		, "PlanterSS2", 0
		, "PlanterSS3", 0
		, "LastPlanterGatherSlot", 3
		, "PlanterName1", "None"
		, "PlanterName2", "None"
		, "PlanterName3", "None"
		, "PlanterField1", "None"
		, "PlanterField2", "None"
		, "PlanterField3", "None"
		, "PlanterHarvestTime1", 2147483647
		, "PlanterHarvestTime2", 2147483647
		, "PlanterHarvestTime3", 2147483647
		, "PlanterNectar1", "None"
		, "PlanterNectar2", "None"
		, "PlanterNectar3", "None"
		, "PlanterEstPercent1", 0
		, "PlanterEstPercent2", 0
		, "PlanterEstPercent3", 0
		, "PlanterGlitter1", 0
		, "PlanterGlitter2", 0
		, "PlanterGlitter3", 0
		, "PlanterGlitterC1", 0
		, "PlanterGlitterC2", 0
		, "PlanterGlitterC3", 0
		, "PlanterHarvestFull1", ""
		, "PlanterHarvestFull2", ""
		, "PlanterHarvestFull3", ""
		, "PlanterManualCycle1", 1
		, "PlanterManualCycle2", 1
		, "PlanterManualCycle3", 1
		, "dayOrNight", "Day"
		, "PlanterMode", 0
		, "nPreset", "Blue"
		, "MaxAllowedPlanters", 3
		, "n1priority", "Comforting"
		, "n2priority", "Motivating"
		, "n3priority", "Satisfying"
		, "n4priority", "Refreshing"
		, "n5priority", "Invigorating"
		, "n1minPercent", 70
		, "n2minPercent", 80
		, "n3minPercent", 80
		, "n4minPercent", 80
		, "n5minPercent", 40
		, "HarvestInterval", 2
		, "AutomaticHarvestInterval", 0
		, "HarvestFullGrown", 0
		, "GotoPlanterField", 0
		, "GatherFieldSipping", 0
		, "ConvertFullBagHarvest", 0
		, "GatherPlanterLoot", 1
		, "PlasticPlanterCheck", 1
		, "CandyPlanterCheck", 1
		, "BlueClayPlanterCheck", 1
		, "RedClayPlanterCheck", 1
		, "TackyPlanterCheck", 1
		, "PesticidePlanterCheck", 1
		, "HeatTreatedPlanterCheck", 0
		, "HydroponicPlanterCheck", 0
		, "PetalPlanterCheck", 0
		, "PaperPlanterCheck", 0
		, "TicketPlanterCheck", 0
		, "PlanterOfPlentyCheck", 0
		, "BambooFieldCheck", 0
		, "BlueFlowerFieldCheck", 1
		, "CactusFieldCheck", 1
		, "CloverFieldCheck", 1
		, "CoconutFieldCheck", 0
		, "DandelionFieldCheck", 1
		, "MountainTopFieldCheck", 0
		, "MushroomFieldCheck", 0
		, "PepperFieldCheck", 1
		, "PineTreeFieldCheck", 1
		, "PineappleFieldCheck", 1
		, "PumpkinFieldCheck", 0
		, "RoseFieldCheck", 1
		, "SpiderFieldCheck", 1
		, "StrawberryFieldCheck", 1
		, "StumpFieldCheck", 0
		, "SunflowerFieldCheck", 1
		, "TimerGuiTransparency", 0
		, "TimerX", 150
		, "TimerY", 150
		, "TimersOpen", 0)

	local k, v, i, j
	for k,v in config ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\nm_config.ini"

	if FileExist(inipath) ; update default values with new ones read from any existing .ini
		nm_ReadIni(inipath)

	local ini := ""
	for k,v in config ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}

	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}
nm_importConfig()

nm_ReadIni(path)
{
	global
	local ini, str, c, p, k, v

	ini := FileOpen(path, "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab
	{
		switch (c := SubStr(A_LoopField, 1, 1))
		{
			; ignore comments and section names
			case "[",";":
			continue

			default:
			if (p := InStr(A_LoopField, "="))
				try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GAME DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nectarnames:=["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
planternames:=["PlasticPlanter", "CandyPlanter", "BlueClayPlanter", "RedClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "PlanterOfPlenty", "PaperPlanter", "TicketPlanter"]
fieldnames:=["dandelion", "sunflower", "mushroom", "blueflower", "clover", "strawberry", "spider", "bamboo", "pineapple", "stump", "cactus", "pumpkin", "pinetree", "rose", "mountaintop", "pepper", "coconut"]

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

;quest data
QuestBarGapSize := 10
QuestBarSize := 50
QuestBarInset := 16

;map: quest name, [objective array]
PolarBear := Map("Aromatic Pie",
		[[3,"Kill","Mantis"]
		,[4,"Kill","Ladybugs"]
		,[1,"Collect","Rose"]
		,[2,"Collect","Pine Tree"]]

	, "Beetle Brew",
		[[3,"Kill","Ladybugs"]
		,[4,"Kill","RhinoBeetles"]
		,[1,"Collect","Pineapple"]
		,[2,"Collect","Dandelion"]]

	, "Candied Beetles",
		[[3,"Kill","RhinoBeetles"]
		,[1,"Collect","Strawberry"]
		,[2,"Collect","Blue Flower"]]

	, "Exotic Salad",
		[[1,"Collect","Cactus"]
		,[2,"Collect","Rose"]
		,[3,"Collect","Blue Flower"]
		,[4,"Collect","Clover"]]

	, "Extreme Stir-Fry",
		[[6,"Kill","Werewolf"]
		,[5,"Kill","Scorpions"]
		,[4,"Kill","Spider"]
		,[1,"Collect","Cactus"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Dandelion"]]

	, "High Protein",
		[[4,"Kill","Spider"]
		,[3,"Kill","Scorpions"]
		,[2,"Kill","Mantis"]
		,[1,"Collect","Sunflower"]]

	, "Ladybug Poppers",
		[[2,"Kill","Ladybugs"]
		,[1,"Collect","Blue Flower"]]

	, "Mantis Meatballs",
		[[2,"Kill","Mantis"]
		,[1,"Collect","Pine Tree"]]

	, "Prickly Pears",
		[[1,"Collect","Cactus"]]

	, "Pumpkin Pie",
		[[3,"Kill","Mantis"]
		,[1,"Collect","Pumpkin"]
		,[2,"Collect","Sunflower"]]

	, "Scorpion Salad",
		[[2,"Kill","Scorpions"]
		,[1,"Collect","Rose"]]

	, "Spiced Kebab",
		[[3,"Kill","Werewolf"]
		,[1,"Collect","Clover"]
		,[2,"Collect","Bamboo"]]

	, "Spider Pot-Pie",
		[[2,"Kill","Spider"]
		,[1,"Collect","Mushroom"]]

	, "Spooky Stew",
		[[4,"Kill","Werewolf"]
		,[3,"Kill","Spider"]
		,[1,"Collect","Spider"]
		,[2,"Collect","Mushroom"]]

	, "Strawberry Skewers",
		[[3,"Kill","Scorpions"]
		,[1,"Collect","Strawberry"]
		,[2,"Collect","Bamboo"]]

	, "Teriyaki Jerky",
		[[3,"Kill","Werewolf"]
		,[1,"Collect","Pineapple"]
		,[2,"Collect","Spider"]]

	, "Thick Smoothie",
		[[1,"Collect","Strawberry"]
		,[2,"Collect","Pumpkin"]]

	, "Trail Mix",
		[[1,"Collect","Sunflower"]
		,[2,"Collect","Pineapple"]])


BlackBear := Map("Just White",
		[[1,"Collect","White"]]

	, "Just Red",
		[[1,"Collect","Red"]]

	, "Just Blue",
		[[1,"Collect","Blue"]]

	, "A Bit Of Both",
		[[1,"Collect","Red"]
		,[2,"Collect","Blue"]]

	, "Any Pollen",
		[[1,"Collect","Any"]]

	, "The Whole Lot",
		[[1,"Collect","Red"]
		,[2,"Collect","Blue"]
		,[3,"Collect","White"]]

	, "Between The Bamboo",
		[[2,"Collect","Bamboo"]
		,[1,"Collect","Blue"]]

	, "Play In The Pumpkins",
		[[2,"Collect","Pumpkin"]
		,[1,"Collect","White"]]

	, "Plundering Pineapples",
		[[2,"Collect","Pineapple"]
		,[1,"Collect","Any"]]

	, "Stroll In The Strawberries",
		[[2,"Collect","Strawberry"]
		,[1,"Collect","Red"]]

	, "Mid-Level Mission",
		[[1,"Collect","Spider"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Bamboo"]]

	, "Blue Flower Bliss",
		[[1,"Collect","Blue Flower"]]

	, "Delve Into Dandelions",
		[[1,"Collect","Dandelion"]]

	, "Fun In The Sunflowers",
		[[1,"Collect","Sunflower"]]

	, "Mission For Mushrooms",
		[[1,"Collect","Mushroom"]]

	, "Leisurely Lowlands",
		[[1,"Collect","Sunflower"]
		,[2,"Collect","Dandelion"]
		,[3,"Collect","Mushroom"]
		,[4,"Collect","Blue Flower"]]

	, "Triple Trek",
		[[1,"Collect","Mountain Top"]
		,[2,"Collect","Pepper"]
		,[3,"Collect","Coconut"]]

	, "Pepper Patrol",
		[[1,"Collect","Pepper"]])


BuckoBee := Map("Abilities",
		[[1,"Collect","Any"]]

	, "Bamboo",
		[[1,"Collect","Bamboo"]]

	, "Bombard",
		[[4,"Get","Ant"]
		,[3,"Get","Ant"]
		,[2,"Kill","RhinoBeetles"]
		,[1,"Collect","Any"]]

	, "Booster",
		[[2,"Get","BlueBoost"]
		,[1,"Collect","Any"]]

	, "Clean-Up",
		[[1,"Collect","Blue Flower"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]]

	, "Extraction",
		[[1,"Collect","Clover"]
		,[2,"Collect","Cactus"]
		,[3,"Collect","Pumpkin"]]

	, "Flowers",
		[[1,"Collect","Blue Flower"]]

	, "Goo",
		[[1,"Collect","Blue"]]

	, "Medley",
		[[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]
		,[1,"Collect","Any"]]

	, "Picnic",
		[[5,"Get","Ant"]
		,[4,"Get","Ant"]
		,[3,"Feed","Blueberry"]
		,[1,"Collect","Blue Flower"]
		,[2,"Collect","Blue"]]

	, "Pine Trees",
		[[1,"Collect","Pine Tree"]]

	, "Pollen",
		[[1,"Collect","Blue"]]

	, "Scavenge",
		[[1,"Collect","Blue"]
		,[3,"Collect","Blue"]
		,[2,"Collect","Any"]]

	, "Skirmish",
		[[2,"Kill","RhinoBeetles"]
		,[1,"Collect","Blue Flower"]]

	, "Tango",
		[[3,"Kill","Mantis"]
		,[1,"Collect","Blue"]
		,[2,"Collect","Any"]]

	, "Tour",
		[[5,"Kill","Mantis"]
		,[4,"Kill","RhinoBeetles"]
		,[1,"Collect","Blue Flower"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]])


RileyBee := Map("Abilities",
		[[1,"Collect","Any"]]

	, "Booster",
		[[2,"Get","RedBoost"]
		,[1,"Collect","Any"]]

	, "Clean-Up",
		[[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]]

	, "Extraction",
		[[1,"Collect","Clover"]
		,[2,"Collect","Cactus"]
		,[3,"Collect","Pumpkin"]]

	, "Goo",
		[[1,"Collect","Red"]]

	, "Medley",
		[[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]
		,[1,"Collect","Any"]]

	, "Mushrooms",
		[[1,"Collect","Mushroom"]]

	, "Picnic",
		[[4,"Get","Ant"]
		,[3,"Feed","Strawberry"]
		,[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]]

	, "Pollen",
		[[1,"Collect","Red"]]

	, "Rampage",
		[[3,"Get","Ant"]
		,[2,"Kill","Ladybugs"]
		,[1,"Kill","All"]]

	, "Roses",
		[[1,"Collect","Rose"]]

	, "Scavenge",
		[[1,"Collect","Red"]
		,[3,"Collect","Strawberry"]
		,[2,"Collect","Any"]]

	, "Skirmish",
		[[2,"Kill","Ladybugs"]
		,[1,"Collect","Mushroom"]]

	, "Strawberries",
		[[1,"Collect","Strawberry"]]

	, "Tango",
		[[3,"Kill","Scorpions"]
		,[1,"Collect","Red"]
		,[2,"Collect","Any"]]

	, "Tour",
		[[5,"Kill","Scorpions"]
		,[4,"Kill","Ladybugs"]
		,[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]])

;field booster data
FieldBooster:=Map("pine tree", {booster:"blue", stacks:1}
	, "bamboo", {booster:"blue", stacks:1}
	, "blue flower", {booster:"blue", stacks:3}
	, "stump", {booster:"blue", stacks:1}
	, "rose", {booster:"red", stacks:1}
	, "strawberry", {booster:"red", stacks:1}
	, "mushroom", {booster:"red", stacks:3}
	, "pepper", {booster:"red", stacks:1}
	, "sunflower", {booster:"mountain", stacks:3}
	, "dandelion", {booster:"mountain", stacks:3}
	, "spider", {booster:"mountain", stacks:2}
	, "clover", {booster:"mountain", stacks:2}
	, "pineapple", {booster:"mountain", stacks:2}
	, "pumpkin", {booster:"mountain", stacks:1}
	, "cactus", {booster:"mountain", stacks:1}
	, "mountain top", {booster:"none", stacks:0}
	, "coconut", {booster:"none", stacks:0})

;Gumdrops carried me, they so pro
CommandoChickHealth := Map(3, 150
	, 4, 2000
	, 5, 10000
	, 6, 15000
	, 7, 25000
	, 8, 50000
	, 9, 100000
	, 10, 150000
	, 11, 200000
	, 12, 300000
	, 13, 400000
	, 14, 500000
	, 15, 750000
	, 16, 1000000
	, 17, 2500000
	, 18, 5000000
	, 19, 7500000)

#Include "data\memorymatch.ahk"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIELD DEFAULT OVERRIDES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importFieldDefaults()
{
	global FieldDefault := Map()
	FieldDefault.CaseSense := 0

	FieldDefault["Sunflower"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 4
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Dandelion"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 6
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 10
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Mushroom"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 2
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Blue Flower"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 7
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Clover"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Spider"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Strawberry"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Upper Right"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Bamboo"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 2
		, "sprinkler", "Upper Left"
		, "distance", 4
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pineapple"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Left"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Stump"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Cactus"] := Map("pattern", "Stationary"
		, "size", "S"
		, "width", 1
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Center"
		, "distance", 1
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Pumpkin"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 5
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Right"
		, "distance", 8
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pine Tree"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 2
		, "sprinkler", "Upper Left"
		, "distance", 7
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Rose"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 1
		, "camera", "Left"
		, "turns", 4
		, "sprinkler", "Lower Right"
		, "distance", 10
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Mountain Top"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Left"
		, "turns", 4
		, "sprinkler", "Lower Left"
		, "distance", 5
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	FieldDefault["Coconut"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 3
		, "camera", "Right"
		, "turns", 2
		, "sprinkler", "Right"
		, "distance", 6
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 1)

	FieldDefault["Pepper"] := Map("pattern", "CornerXSnake"
		, "size", "M"
		, "width", 5
		, "camera", "None"
		, "turns", 1
		, "sprinkler", "Upper Right"
		, "distance", 7
		, "percent", 95
		, "gathertime", 10
		, "convert", "Walk"
		, "drift", 0
		, "shiftlock", 0
		, "invertFB", 0
		, "invertLR", 0)

	global StandardFieldDefault := ObjFullyClone(FieldDefault)

	inipath := A_WorkingDir "\settings\field_config.ini"

	if FileExist(inipath) ; update default values with new ones read from any existing .ini
		nm_LoadFieldDefaults()

	; reset pattern to default if not exist
	global FieldPattern1, FieldPattern2, FieldPattern3
	loop 3 {
		i := A_Index
		if (FieldName%i% != "None") {
			for pattern in patternlist
				if (pattern = FieldPattern%i%)
					continue 2
			FieldPattern%i% := FieldDefault[FieldName%i%]["pattern"]
		}
	}

	ini := ""
	for k,v in FieldDefault ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i,j in v
			ini .= i "=" j "`r`n"
		ini .= "`r`n"
	}
	file := FileOpen(inipath, "w-d"), file.Write(ini), file.Close()
}
nm_importFieldDefaults()

nm_LoadFieldDefaults()
{
	global FieldDefault

	ini := FileOpen(A_WorkingDir "\settings\field_config.ini", "r"), str := ini.Read(), ini.Close()
	Loop Parse str, "`n", "`r" A_Space A_Tab
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

; auxiliary map/array functions
ObjFullyClone(obj)
{
	nobj := obj.Clone()
	for k,v in nobj
		if IsObject(v)
			nobj[k] := ObjFullyClone(v)
	return nobj
}
ObjHasValue(obj, value)
{
	for k,v in obj
		if (v = value)
			return 1
	return 0
}
ObjMinIndex(obj)
{
	for k,v in obj
		return k
	return 0
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MANUAL PLANTERS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_importManualPlanters()
{
	global
	local ManualPlanters := Map()

	ManualPlanters["General"] := Map("MHarvestInterval", "2 hours")

	ManualPlanters["Slot 1"] := Map("MSlot1Cycle1Planter", ""
		, "MSlot1Cycle2Planter", ""
		, "MSlot1Cycle3Planter", ""
		, "MSlot1Cycle4Planter", ""
		, "MSlot1Cycle5Planter", ""
		, "MSlot1Cycle6Planter", ""
		, "MSlot1Cycle7Planter", ""
		, "MSlot1Cycle8Planter", ""
		, "MSlot1Cycle9Planter", ""
		, "MSlot1Cycle1Field", ""
		, "MSlot1Cycle2Field", ""
		, "MSlot1Cycle3Field", ""
		, "MSlot1Cycle4Field", ""
		, "MSlot1Cycle5Field", ""
		, "MSlot1Cycle6Field", ""
		, "MSlot1Cycle7Field", ""
		, "MSlot1Cycle8Field", ""
		, "MSlot1Cycle9Field", ""
		, "MSlot1Cycle1Glitter", 0
		, "MSlot1Cycle2Glitter", 0
		, "MSlot1Cycle3Glitter", 0
		, "MSlot1Cycle4Glitter", 0
		, "MSlot1Cycle5Glitter", 0
		, "MSlot1Cycle6Glitter", 0
		, "MSlot1Cycle7Glitter", 0
		, "MSlot1Cycle8Glitter", 0
		, "MSlot1Cycle9Glitter", 0
		, "MSlot1Cycle1AutoFull", "Timed"
		, "MSlot1Cycle2AutoFull", "Timed"
		, "MSlot1Cycle3AutoFull", "Timed"
		, "MSlot1Cycle4AutoFull", "Timed"
		, "MSlot1Cycle5AutoFull", "Timed"
		, "MSlot1Cycle6AutoFull", "Timed"
		, "MSlot1Cycle7AutoFull", "Timed"
		, "MSlot1Cycle8AutoFull", "Timed"
		, "MSlot1Cycle9AutoFull", "Timed")

	ManualPlanters["Slot 2"] := Map("MSlot2Cycle1Planter", ""
		, "MSlot2Cycle2Planter", ""
		, "MSlot2Cycle3Planter", ""
		, "MSlot2Cycle4Planter", ""
		, "MSlot2Cycle5Planter", ""
		, "MSlot2Cycle6Planter", ""
		, "MSlot2Cycle7Planter", ""
		, "MSlot2Cycle8Planter", ""
		, "MSlot2Cycle9Planter", ""
		, "MSlot2Cycle1Field", ""
		, "MSlot2Cycle2Field", ""
		, "MSlot2Cycle3Field", ""
		, "MSlot2Cycle4Field", ""
		, "MSlot2Cycle5Field", ""
		, "MSlot2Cycle6Field", ""
		, "MSlot2Cycle7Field", ""
		, "MSlot2Cycle8Field", ""
		, "MSlot2Cycle9Field", ""
		, "MSlot2Cycle1Glitter", 0
		, "MSlot2Cycle2Glitter", 0
		, "MSlot2Cycle3Glitter", 0
		, "MSlot2Cycle4Glitter", 0
		, "MSlot2Cycle5Glitter", 0
		, "MSlot2Cycle6Glitter", 0
		, "MSlot2Cycle7Glitter", 0
		, "MSlot2Cycle8Glitter", 0
		, "MSlot2Cycle9Glitter", 0
		, "MSlot2Cycle1AutoFull", "Timed"
		, "MSlot2Cycle2AutoFull", "Timed"
		, "MSlot2Cycle3AutoFull", "Timed"
		, "MSlot2Cycle4AutoFull", "Timed"
		, "MSlot2Cycle5AutoFull", "Timed"
		, "MSlot2Cycle6AutoFull", "Timed"
		, "MSlot2Cycle7AutoFull", "Timed"
		, "MSlot2Cycle8AutoFull", "Timed"
		, "MSlot2Cycle9AutoFull", "Timed")

	ManualPlanters["Slot 3"] := Map("MSlot3Cycle1Planter", ""
		, "MSlot3Cycle2Planter", ""
		, "MSlot3Cycle3Planter", ""
		, "MSlot3Cycle4Planter", ""
		, "MSlot3Cycle5Planter", ""
		, "MSlot3Cycle6Planter", ""
		, "MSlot3Cycle7Planter", ""
		, "MSlot3Cycle8Planter", ""
		, "MSlot3Cycle9Planter", ""
		, "MSlot3Cycle1Field", ""
		, "MSlot3Cycle2Field", ""
		, "MSlot3Cycle3Field", ""
		, "MSlot3Cycle4Field", ""
		, "MSlot3Cycle5Field", ""
		, "MSlot3Cycle6Field", ""
		, "MSlot3Cycle7Field", ""
		, "MSlot3Cycle8Field", ""
		, "MSlot3Cycle9Field", ""
		, "MSlot3Cycle1Glitter", 0
		, "MSlot3Cycle2Glitter", 0
		, "MSlot3Cycle3Glitter", 0
		, "MSlot3Cycle4Glitter", 0
		, "MSlot3Cycle5Glitter", 0
		, "MSlot3Cycle6Glitter", 0
		, "MSlot3Cycle7Glitter", 0
		, "MSlot3Cycle8Glitter", 0
		, "MSlot3Cycle9Glitter", 0
		, "MSlot3Cycle1AutoFull", "Timed"
		, "MSlot3Cycle2AutoFull", "Timed"
		, "MSlot3Cycle3AutoFull", "Timed"
		, "MSlot3Cycle4AutoFull", "Timed"
		, "MSlot3Cycle5AutoFull", "Timed"
		, "MSlot3Cycle6AutoFull", "Timed"
		, "MSlot3Cycle7AutoFull", "Timed"
		, "MSlot3Cycle8AutoFull", "Timed"
		, "MSlot3Cycle9AutoFull", "Timed")

	local k, v, i, j
	for k,v in ManualPlanters ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\manual_planters.ini"

	if FileExist(inipath)
		nm_ReadIni(inipath)

	local ini := ""
	for k,v in ManualPlanters ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}
	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}
nm_importManualPlanters()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DECLARE GLOBALS AND PREPARE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
try Hotkey StopHotkey, stop, "On"

pToken := Gdip_Startup()
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)

priorityList:=[], defaultPriorityList:=["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Boost", "GoGather"]
for x in StrSplit(priorityListNumeric)
	priorityList.push(defaultPriorityList[x])

VBState:=0
LostPlanters:=""
QuestFields:=""
youDied:=0
GameFrozenCounter:=0
AFBrollingDice:=0
AFBuseGlitter:=0
AFBuseBooster:=0
MacroState:=0 ; 0=stopped, 1=paused, 2=running
resetTime := MacroStartTime:=MacroReloadTime:=nowUnix()
PausedRuntime:=0
FieldGuidDetected:=0
HasPopStar:=0
PopStarActive:=0
PreviousAction:="None"
CurrentAction:="Startup"
fieldnamelist := ["Bamboo","Blue Flower","Cactus","Clover","Coconut","Dandelion","Mountain Top","Mushroom","Pepper","Pine Tree","Pineapple","Pumpkin","Rose","Spider","Strawberry","Stump","Sunflower"]
hotbarwhilelist := ["Never","Always","At Hive","Gathering","Attacking","Microconverter","Whirligig","Enzymes","GatherStart","Snowflake"]
sprinklerImages := ["saturator"]
ReconnectDelay:=0
GatherStartTime := ConvertStartTime := 0
QuestAnt := 0
QuestBlueBoost := 0
QuestRedBoost := 0
HiveConfirmed := 0
ShiftLockEnabled := 0

;ensure Gui will be visible
if (GuiX && GuiY)
{
	Loop (MonitorCount := MonitorGetCount())
	{
		MonitorGetWorkArea A_Index, &MonLeft, &MonTop, &MonRight, &MonBottom
		if(GuiX>MonLeft && GuiX<MonRight && GuiY>MonTop && GuiY<MonBottom)
			break
		if(A_Index=MonitorCount)
			guiX:=guiY:=0
	}
}
else
	guiX:=guiY:=0
BackpackPercent:=BackpackPercentFiltered:=0
ActiveHotkeys:=[]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RUN STATUS HANDLER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Run
(
'"' exe_path64 '" /script "' A_WorkingDir '\submacros\Status.ahk" '
'"' discordMode '" "' discordCheck '" "' webhook '" "' bottoken '" "' MainChannelCheck '" "' MainChannelID '" "' ReportChannelCheck '" "' ReportChannelID '" '
'"' WebhookEasterEgg '" "' ssCheck '" "' ssDebugging '" "' CriticalSSCheck '" "' AmuletSSCheck '" "' MachineSSCheck '" "' BalloonSSCheck '" "' ViciousSSCheck '" '
'"' DeathSSCheck '" "' PlanterSSCheck '" "' HoneySSCheck '" "' criticalCheck '" "' discordUID '" "' CriticalErrorPingCheck '" "' DisconnectPingCheck '" "' GameFrozenPingCheck '" '
'"' PhantomPingCheck '" "' UnexpectedDeathPingCheck '" "' EmergencyBalloonPingCheck '" "' commandPrefix '" "' NightAnnouncementCheck '" "' NightAnnouncementName '" '
'"' NightAnnouncementPingID '" "' NightAnnouncementWebhook '" "' PrivServer '" "' DebugLogEnabled '" "' MonsterRespawnTime '" "' HoneyUpdateSSCheck '"'
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDIP BITMAPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bitmaps := Map(), bitmaps.CaseSense := 0
shrine := Map(), shrine.CaseSense := 0
hBitmapsSBT := Map(), hBitmapsSBT.CaseSense := 0
#Include "%A_ScriptDir%\..\nm_image_assets"
#Include "general\bitmaps.ahk"
#Include "gui\bitmaps.ahk"
#Include "beemenu\bitmaps.ahk"
#Include "buffs\bitmaps.ahk"
#Include "convert\bitmaps.ahk"
#Include "collect\bitmaps.ahk"
#Include "kill\bitmaps.ahk"
#Include "boost\bitmaps.ahk"
#Include "inventory\bitmaps.ahk"
#Include "reconnect\bitmaps.ahk"
#Include "fdc\bitmaps.ahk"
#Include "offset\bitmaps.ahk"
#Include "perfstats\bitmaps.ahk"
#Include "gui\blendershrine_bitmaps.ahk"
#Include "quests\bitmaps.ahk"
#Include "sprinkler\bitmaps.ahk"
#Include "stickerstack\bitmaps.ahk"
#Include "stickerprinter\bitmaps.ahk"
#Include "memorymatch\bitmaps.ahk"
#include "reset\bitmaps.ahk"

(hBitmapsSB := Map()).CaseSense := 0
for x,y in hBitmapsSBT
	hBitmapsSB[x] := Gdip_CreateHBITMAPFromBitmap(y), Gdip_DisposeImage(y)
hBitmapsSB["None"] := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SYSTEM TRAY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TraySetIcon "nm_image_assets\auryn.ico"
A_TrayMenu.Delete()
A_TrayMenu.Add()
A_TrayMenu.Add("Open Logs", (*) => ListLines())
A_TrayMenu.Add("Copy Logs", copyLogFile)
A_TrayMenu.Add()

A_TrayMenu.Add("Edit This Script", (*) => Edit())
A_TrayMenu.Add("Suspend Hotkeys", (*) => (A_TrayMenu.ToggleCheck("Suspend Hotkeys"), Suspend()))
A_TrayMenu.Add()
A_TrayMenu.Add("Start Macro", start)
A_TrayMenu.Add("Pause Macro", nm_pause)
A_TrayMenu.Add("Stop Macro", stop)
A_TrayMenu.Add()
A_TrayMenu.Add("Show Timers", timers)
A_TrayMenu.Add()
A_TrayMenu.Add("Close", (*) => ExitApp())
A_TrayMenu.Add()
A_TrayMenu.Default := "Start Macro"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI SKINNING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
DllCall(DllCall("GetProcAddress"
		, "Ptr",DllCall("LoadLibrary", "Str",A_WorkingDir "\nm_image_assets\Styles\USkin.dll")
		, "AStr","USkinInit", "Ptr")
	, "Int",0, "Int",0, "AStr",A_WorkingDir "\nm_image_assets\styles\" GuiTheme ".msstyles")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AUTO-UPDATE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_AutoUpdateHandler(req)
{
	global

	if (req.readyState != 4)
		return

	if (req.status = 200)
	{
		LatestVer := Trim((latest_release := JSON.parse(req.responseText))["tag_name"], "v")
		if (VerCompare(VersionID, LatestVer) < 0)
		{
			MainGui["ImageUpdateLink"].Visible := 1
			VersionWidth += 16
			MainGui["VersionText"].Move(494 - VersionWidth), MainGui["VersionText"].Redraw()
			MainGui["ImageGitHubLink"].Move(494 - VersionWidth - 23), MainGui["ImageGitHubLink"].Redraw()
			MainGui["ImageDiscordLink"].Move(494 - VersionWidth - 48), MainGui["ImageDiscordLink"].Redraw()
			try MainGui["SecretButton"].Move(494-VersionWidth-104), MainGui["SecretButton"].Redraw()

			if (LatestVer != IgnoreUpdateVersion)
				nm_AutoUpdateGUI()
		}
	}
}
nm_AutoUpdateGUI(*)
{
	global
	local size, downloads, posW, hBM, UpdateText, GuiCtrl
	GuiClose(*){
		if (IsSet(UpdateGui) && IsObject(UpdateGui))
			UpdateGui.Destroy(), UpdateGui := ""
	}
	GuiClose()
	UpdateGui := Gui("+Border +Owner" MainGui.Hwnd " -MinimizeBox", "Natro Macro Update")
	UpdateGui.OnEvent("Close", GuiClose), UpdateGui.OnEvent("Escape", GuiClose)
	UpdateGui.SetFont("s9 cDefault Norm", "Tahoma")
	UpdateText := UpdateGui.Add("Text", "x20 w260 +Center +BackgroundTrans", "A newer version of Natro Macro was found!`nDo you want to update now?")

	posW := TextExtent("Natro Macro v" VersionID " ⮕ v" LatestVer, UpdateText)
	UpdateGui.Add("Text", "x" 149-posW//2 " y40 +BackgroundTrans", "Natro Macro v" VersionID " ⮕ ")
	UpdateGui.Add("Text", "x+0 yp +c379e37 +BackgroundTrans", "v" LatestVer)

	posW := TextExtent((size := Round(latest_release["assets"][1]["size"]/1048576, 2)) " MB // Downloads: " (downloads := latest_release["assets"][1]["download_count"]), UpdateText)
	UpdateGui.Add("Text", "x" 150-posW//2 " y54 +BackgroundTrans", size " MB // Downloads: " downloads)

	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["githubgui"]), UpdateGui.Add("Picture", "x76 y+1 w16 h16 +BackgroundTrans", "HBITMAP:*" hBM).OnEvent("Click", GitHubRepoLink), DllCall("DeleteObject", "ptr", hBM)
	UpdateGui.Add("Text", "x+4 yp+1 c0046ee +BackgroundTrans", "Patch Notes && Updates").OnEvent("Click", GitHubReleaseLink)

	UpdateGui.SetFont("s8 w700")
	local MajorUpdate := (StrSplit(VersionID, ".")[1] < StrSplit(LatestVer, ".")[1])
	UpdateGui.Add("GroupBox", "x50 y+4 w200 h" (MajorUpdate ? 74 : 50), "Options")
	UpdateGui.SetFont("Norm")
	UpdateGui.Add("CheckBox", "xp+8 yp+16 Checked vCopySettings", "Copy Settings")
	UpdateGui.Add("CheckBox", "xp+92 yp vCopyPatterns Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Patterns")
	UpdateGui.Add("CheckBox", "xp-92 yp+16 vCopyPaths Checked" (!MajorUpdate) " Disabled" MajorUpdate, "Copy Paths")
	UpdateGui.Add("CheckBox", "xp+92 yp vDeleteOld", "Delete v" VersionID)
	if MajorUpdate
		UpdateGui.Add("Button", "x60 y+5 w180 h18", "Why are some options disabled?").OnEvent("Click", nm_MajorUpdateHelp)

	UpdateGui.SetFont("s9")
	UpdateGui.Add("Button", "x8 y+12 w92 h26", "Never").OnEvent("Click", nm_NeverButton)
	UpdateGui.Add("Button", "xp+96 yp wp hp vDismissButton", "Dismiss (120)").OnEvent("Click", nm_DismissButton)
	SetTimer nm_DismissLabel, -1000

	UpdateGui.SetFont("Bold")
	(GuiCtrl := UpdateGui.Add("Button", "xp+96 yp wp hp", "Update")).OnEvent("Click", nm_UpdateButton)
	UpdateGui.Show("w290 h168")
	GuiCtrl.Focus()
	WinWaitClose "ahk_id " UpdateGui.Hwnd, , 125
	GuiClose()
}
nm_DismissLabel()
{
	static countdown := unset
	global UpdateGUI
	if !IsSet(countdown)
		countdown := 120

	if UpdateGui {
		if (--countdown <= 0) {
			countdown := unset
			UpdateGui.Destroy()
		} else {
			UpdateGui["DismissButton"].Text := "Dismiss (" countdown ")"
			SetTimer nm_DismissLabel, -1000
		}
	}
	else
		countdown := unset
}
nm_DismissButton(*)
{
	global UpdateGui
	UpdateGui.Destroy(), UpdateGui := ""
}
nm_NeverButton(*)
{
	global UpdateGui
	if (MsgBox(
	(
	"Are you sure you want to disable prompts for v" LatestVer "?
	You can still update manually, or by clicking the red symbol in the bottom right corner of the GUI."
	), "Disable Automatic Update", 0x1044 " Owner" UpdateGui.Hwnd) = "Yes")
	{
		IniWrite (IgnoreUpdateVersion := LatestVer), "settings\nm_config.ini", "Settings", "IgnoreUpdateVersion"
		UpdateGui.Destroy(), UpdateGui := ""
	}
}
nm_UpdateButton(*)
{
	global latest_release, VersionID, UpdateGui
	url := latest_release["assets"][1]["browser_download_url"]
	olddir := A_WorkingDir
	CopySettings := UpdateGui["CopySettings"].Value
	CopyPatterns := UpdateGui["CopyPatterns"].Value
	CopyPaths := UpdateGui["CopyPaths"].Value
	DeleteOld := UpdateGui["DeleteOld"].Value
	changedpaths := ""
	UpdateGui.Destroy(), UpdateGui := ""

	if (CopyPaths = 1)
	{
		try
		{
			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/tags?per_page=100", 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.Send()
			wr.WaitForResponse()
			for k,v in (tags := JSON.parse(wr.ResponseText))
				if ((VerCompare(Trim(v["name"], "v"), VersionID) <= 0) && (base := v["name"]))
					break
			if !base
				throw

			wr := ComObject("WinHttp.WinHttpRequest.5.1")
			wr.Open("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/compare/" base "..." latest_release["tag_name"] , 1)
			wr.SetRequestHeader("accept", "application/vnd.github+json")
			wr.Send()
			wr.WaitForResponse()
			for k,v in (files := JSON.parse(wr.ResponseText)["files"])
				if (SubStr(v["filename"], 1, 6) = "paths/")
					changedpaths .= '"' SubStr(v["filename"], 7) '" '
			changedpaths := RTrim(changedpaths)
		}
		catch
		{
			MsgBox "Unable to fetch changed paths from GitHub!`nIf you still want to update, disable 'Copy Paths' (and copy them manually) or try again later.", "Error", 0x1010 " T30"
			return
		}
	}

	Run '"' A_WorkingDir '\submacros\update.bat" "' url '" "' olddir '" "' CopySettings '" "' CopyPatterns '" "' CopyPaths '" "' DeleteOld '" "' changedpaths '"'
	ExitApp
}
nm_MajorUpdateHelp(*)
{
	MsgBox "v" VersionID " to v" LatestVer " is a major version update.`n`n"
	. "This means that backward compatibility of Paths and Patterns cannot be guaranteed, so they cannot be automatically copied.`n"
	. "However, in Natro Macro, your Settings are guaranteed to be transferable to any new version, so that option remains enabled.`n`n"
	. "For more information, you can review the convention at https://semver.org/", "Major Update", 0x1040
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OnExit(GetOut)
MainGui := Gui((AlwaysOnTop ? "+AlwaysOnTop " : "") "+Border +OwnDialogs", "Natro Macro (Loading 0%)")
WinSetTransparent 255-floor(GuiTransparency*2.55), MainGui
MainGui.Show("x" GuiX " y" GuiY " w490 h275")
SetLoadingProgress(percent) => MainGui.Title := "Natro Macro (Loading " Round(percent) "%)"
MainGui.OnEvent("Close", (*) => ExitApp())
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.SetFont("w700")
MainGui.Add("Text", "x5 y241 w80 -Wrap +BackgroundTrans", "Current Field:")
MainGui.Add("Text", "x177 y241 w30 +BackgroundTrans", "Status:")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x82 y240 w10 h15 vcurrentFieldUp Disabled", "<").OnEvent("Click", nm_currentFieldUp)
MainGui.Add("Button", "x165 y240 w10 h15 vcurrentFieldDown Disabled", ">").OnEvent("Click", nm_currentFieldDown)
MainGui.Add("Text", "x92 y240 w73 +center +BackgroundTrans +border vCurrentField", CurrentField:=FieldName%CurrentFieldNum%)
MainGui.Add("Text", "x220 y240 w275 +BackgroundTrans +border vstate", "Startup: UI")

; version label and links
(GuiCtrl := MainGui.Add("Text", "x435 y264 vVersionText", "v" versionID)).OnEvent("Click", nm_showAdvancedSettings), GuiCtrl.Move(494 - (VersionWidth := TextExtent("v" VersionID, GuiCtrl)))
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["warninggui"])
MainGui.Add("Picture", "+BackgroundTrans x482 y264 w14 h14 Hidden vImageUpdateLink", "HBITMAP:*" hBM).OnEvent("Click", nm_AutoUpdateGUI)
DllCall("DeleteObject", "Ptr", hBM)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["githubgui"])
MainGui.Add("Picture", "+BackgroundTrans x" 494-VersionWidth-23 " y262 w18 h18 vImageGitHubLink", "HBITMAP:*" hBM)
DllCall("DeleteObject", "Ptr", hBM)
pBM := Gdip_BitmapConvertGray(bitmaps["discordgui"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
MainGui.Add("Picture", "+BackgroundTrans x" 494-VersionWidth-48 " y263 w21 h16 vImageDiscordLink", "HBITMAP:*" hBM)
Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)

; control buttons
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x5 y260 w65 h20 -Wrap Disabled vStartButton", " Start (" StartHotkey ")").OnEvent("Click", nm_StartButton)
MainGui.Add("Button", "x75 y260 w65 h20 -Wrap Disabled vPauseButton", " Pause (" PauseHotkey ")").OnEvent("Click", nm_PauseButton)
MainGui.Add("Button", "x145 y260 w65 h20 -Wrap Disabled vStopButton", " Stop (" StopHotkey ")").OnEvent("Click", nm_StopButton)
for k,v in ["PMondoGuid","PMondoGuidComplete","PFieldBoosted","PFieldGuidExtend","PFieldGuidExtendMins","PFieldBoostExtend","PPopStarExtend"]
	%v%:=0
#include "*i %A_ScriptDir%\..\settings\personal.ahk"

; add tabs
TabArr := ["Gather","Collect/Kill","Boost","Quests","Planters","Status","Settings","Misc","Credits"], (BuffDetectReset = 1) && TabArr.Push("Advanced")
(TabCtrl := MainGui.Add("Tab", "x0 y-1 w500 h240 -Wrap", TabArr)).OnEvent("Change", (*) => TabCtrl.Focus())
SendMessage 0x1331, 0, 20, , TabCtrl ; set minimum tab width
; check for update
try AsyncHttpRequest("GET", "https://api.github.com/repos/NatroTeam/NatroMacro/releases/latest", nm_AutoUpdateHandler, Map("accept", "application/vnd.github+json"))
; open Timers
if (TimersOpen = 1)
	run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\PlanterTimers.ahk"'

; GATHER TAB
; ------------------------
TabCtrl.UseTab("Gather") ; not needed since TabCtrl creation defaults to using first tab, but specified for readability
MainGui.SetFont("w700 Underline")
MainGui.Add("Text", "x0 y25 w126 +center +BackgroundTrans", "Gathering")
MainGui.Add("Text", "x126 y25 w205 +center +BackgroundTrans", "Pattern")
MainGui.Add("Text", "x331 y25 w83 +center +BackgroundTrans", "Until")
MainGui.Add("Text", "x414 y25 w86 +center +BackgroundTrans", "Sprinkler")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x2 y39 w124 +center +BackgroundTrans", "Field Rotation")
MainGui.Add("Text", "x126 y25 w1 h206 0x7") ; 0x7 = SS_BLACKFRAME - faster drawing of lines since no text rendered
MainGui.Add("Text", "x130 y39 w112 +center +BackgroundTrans", "Pattern Shape")
MainGui.Add("Text", "x253 y39 w100 +BackgroundTrans", "Length")
MainGui.Add("Text", "x295 y39 w100 +BackgroundTrans", "Width")
MainGui.Add("Text", "x331 y25 w1 h206 0x7")
MainGui.Add("Text", "x342 y39 w100 +BackgroundTrans", "Mins")
MainGui.Add("Text", "x376 y39 w100 +BackgroundTrans", "Pack%")
MainGui.Add("Text", "x412 y25 w1 h206 0x7")
MainGui.Add("Text", "x423 y39 w100 +BackgroundTrans", "Start Location")
MainGui.Add("Text", "x5 y53 w492 h2 0x7")
MainGui.Add("Text", "xp y115 wp h1 0x7")
MainGui.Add("Text", "xp yp+60 wp h1 0x7")
MainGui.Add("Text", "xp yp+60 wp h1 0x7")
MainGui.SetFont("w700")
MainGui.Add("Text", "x4 y61 w10 +BackgroundTrans", "1:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans", "2:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans", "3:")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

(GuiCtrl := MainGui.Add("DropDownList", "x18 y57 w106 Disabled vFieldName1", fieldnamelist)).Text := FieldName1, GuiCtrl.OnEvent("Change", nm_FieldSelect1)
SetLoadingProgress(3)
(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldName2", ["None"])).Add(fieldnamelist), GuiCtrl.Text := FieldName2, GuiCtrl.OnEvent("Change", nm_FieldSelect2)
SetLoadingProgress(6)
(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldName3", ["None"])).Add(fieldnamelist), GuiCtrl.Text := FieldName3, GuiCtrl.OnEvent("Change", nm_FieldSelect3)
SetLoadingProgress(9)

hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
MainGui.Add("Picture", "x2 y86 w18 h18 Disabled vSaveFieldDefault1", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
MainGui.Add("Picture", "xp yp+60 wp hp Disabled vSaveFieldDefault2", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
MainGui.Add("Picture", "xp yp+60 wp hp Disabled vSaveFieldDefault3", "HBITMAP:*" hBM).OnEvent("Click", nm_SaveFieldDefault)
DllCall("DeleteObject", "ptr", hBM)

(GuiCtrl := MainGui.Add("CheckBox", "x65 y83 w50 +Center Disabled vFieldDriftCheck1 Checked" FieldDriftCheck1, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 wp +Center Disabled vFieldDriftCheck2 Checked" FieldDriftCheck2, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 wp +Center Disabled vFieldDriftCheck3 Checked" FieldDriftCheck3, "Drift`nComp")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("Button", "x115 y89 w9 h14 Disabled vFDCHelp1", "?").OnEvent("Click", nm_FDCHelp)
MainGui.Add("Button", "xp yp+60 w9 h14 Disabled vFDCHelp2", "?").OnEvent("Click", nm_FDCHelp)
MainGui.Add("Button", "xp yp+60 w9 h14 Disabled vFDCHelp3", "?").OnEvent("Click", nm_FDCHelp)

MainGui.Add("Button", "x22 y82 h14 w40 Disabled vCopyGather1", "Copy").OnEvent("Click", nm_CopyGatherSettings)
MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather1", "Paste").OnEvent("Click", nm_PasteGatherSettings)
MainGui.Add("Button", "xp yp+45 hp wp Disabled vCopyGather2", "Copy").OnEvent("Click", nm_CopyGatherSettings)
MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather2", "Paste").OnEvent("Click", nm_PasteGatherSettings)
MainGui.Add("Button", "xp yp+45 hp wp Disabled vCopyGather3", "Copy").OnEvent("Click", nm_CopyGatherSettings)
MainGui.Add("Button", "xp yp+15 hp wp Disabled vPasteGather3", "Paste").OnEvent("Click", nm_PasteGatherSettings)

(GuiCtrl := MainGui.Add("DropDownList", "x129 y57 w112 Disabled vFieldPattern1", patternlist)).Text := FieldPattern1
GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig), SetLoadingProgress(12)
(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldPattern2", patternlist)).Text := FieldPattern2
GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig), SetLoadingProgress(15)
(GuiCtrl := MainGui.Add("DropDownList", "xp yp+60 wp Disabled vFieldPattern3", patternlist)).Text := FieldPattern3
GuiCtrl.Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig), SetLoadingProgress(18)

FieldPatternSizeArr := Map("XS",1, "S",2, "M",3, "L",4, "XL",5)
MainGui.Add("Text", "x254 y60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize1", FieldPatternSize1)
MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize1UpDown", FieldPatternSizeArr[FieldPatternSize1]).OnEvent("Change", nm_FieldPatternSize)
MainGui.Add("Text", "x254 yp+60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize2", FieldPatternSize2)
MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize2UpDown", FieldPatternSizeArr[FieldPatternSize2]).OnEvent("Change", nm_FieldPatternSize)
MainGui.Add("Text", "x254 yp+60 h16 w12 0x201 +Center +BackgroundTrans vFieldPatternSize3", FieldPatternSize3)
MainGui.Add("UpDown", "xp+14 yp h16 -16 Range1-5 Disabled vFieldPatternSize3UpDown", FieldPatternSizeArr[FieldPatternSize3]).OnEvent("Change", nm_FieldPatternSize)

MainGui.Add("Text", "x294 y60 w28 h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps1", FieldPatternReps1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps2", FieldPatternReps2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-9 Disabled vFieldPatternReps3", FieldPatternReps3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

(GuiCtrl := MainGui.Add("CheckBox", "x129 y82 Disabled vFieldPatternShift1 Checked" FieldPatternShift1, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternShift2 Checked" FieldPatternShift2, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternShift3 Checked" FieldPatternShift3, "Gather w/Shift-Lock")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("Text", "x132 y97", "Invert:")
MainGui.Add("Text", "xp yp+60", "Invert:")
MainGui.Add("Text", "xp yp+60", "Invert:")
(GuiCtrl := MainGui.Add("CheckBox", "x171 y97 Disabled vFieldPatternInvertFB1 Checked" FieldPatternInvertFB1, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertFB2 Checked" FieldPatternInvertFB2, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertFB3 Checked" FieldPatternInvertFB3, "F/B")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x208 y97 Disabled vFieldPatternInvertLR1 Checked" FieldPatternInvertLR1, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertLR2 Checked" FieldPatternInvertLR2, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+60 Disabled vFieldPatternInvertLR3 Checked" FieldPatternInvertLR3, "L/R")).Section := "Gather", GuiCtrl.OnEvent("Click", nm_saveConfig)
SetLoadingProgress(22)

MainGui.Add("Text", "x251 y79 +BackgroundTrans +Center", "Rotate Camera:")
MainGui.Add("Text", "xp yp+60 +BackgroundTrans +Center", "Rotate Camera:")
MainGui.Add("Text", "xp yp+60 +BackgroundTrans +Center", "Rotate Camera:")
MainGui.Add("Text", "x258 y96 w31 +Center +BackgroundTrans vFieldRotateDirection1", FieldRotateDirection1)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD1Left", "<").OnEvent("Click", nm_FieldRotateDirection)
MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD1Right", ">").OnEvent("Click", nm_FieldRotateDirection)
MainGui.Add("Text", "x258 yp+61 w31 +Center +BackgroundTrans vFieldRotateDirection2", FieldRotateDirection2)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD2Left", "<").OnEvent("Click", nm_FieldRotateDirection)
MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD2Right", ">").OnEvent("Click", nm_FieldRotateDirection)
MainGui.Add("Text", "x258 yp+61 w31 +Center +BackgroundTrans vFieldRotateDirection3", FieldRotateDirection3)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFRD3Left", "<").OnEvent("Click", nm_FieldRotateDirection)
MainGui.Add("Button", "xp+42 yp w12 h16 Disabled vFRD3Right", ">").OnEvent("Click", nm_FieldRotateDirection)

MainGui.Add("Text", "x301 y95 w28 h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes1", FieldRotateTimes1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes2", FieldRotateTimes2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-4 Disabled vFieldRotateTimes3", FieldRotateTimes3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

(GuiCtrl := MainGui.Add("Edit", "x334 y58 w36 h20 limit4 number Disabled vFieldUntilMins1", ValidateInt(&FieldUntilMins1, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
(GuiCtrl := MainGui.Add("Edit", "xp yp+60 wp h20 limit4 number Disabled vFieldUntilMins2", ValidateInt(&FieldUntilMins2, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
(GuiCtrl := MainGui.Add("Edit", "xp yp+60 wp h20 limit4 number Disabled vFieldUntilMins3", ValidateInt(&FieldUntilMins3, 10))).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)

MainGui.Add("Text", "x375 y60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack1", FieldUntilPack1)
MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack1UpDown", FieldUntilPack1//5).OnEvent("Change", nm_FieldUntilPack)
MainGui.Add("Text", "x375 yp+60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack2", FieldUntilPack2)
MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack2UpDown", FieldUntilPack2//5).OnEvent("Change", nm_FieldUntilPack)
MainGui.Add("Text", "x375 yp+60 h16 w16 0x201 +Center +BackgroundTrans vFieldUntilPack3", FieldUntilPack3)
MainGui.Add("UpDown", "xp+18 yp h16 -16 Range1-20 Disabled vFieldUntilPack3UpDown", FieldUntilPack3//5).OnEvent("Change", nm_FieldUntilPack)
SetLoadingProgress(24)

MainGui.Add("Text", "x327 y79 w93 +BackgroundTrans +Center", "To Hive By:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "To Hive By:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "To Hive By:")
MainGui.Add("Text", "x356 y96 w33 +Center +BackgroundTrans vFieldReturnType1", FieldReturnType1)
MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT1Left", "<").OnEvent("Click", nm_FieldReturnType)
MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT1Right", ">").OnEvent("Click", nm_FieldReturnType)
MainGui.Add("Text", "x356 yp+61 w33 +Center +BackgroundTrans vFieldReturnType2", FieldReturnType2)
MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT2Left", "<").OnEvent("Click", nm_FieldReturnType)
MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT2Right", ">").OnEvent("Click", nm_FieldReturnType)
MainGui.Add("Text", "x356 yp+61 w33 +Center +BackgroundTrans vFieldReturnType3", FieldReturnType3)
MainGui.Add("Button", "xp-16 yp-1 w12 h16 Disabled vFRT3Left", "<").OnEvent("Click", nm_FieldReturnType)
MainGui.Add("Button", "xp+52 yp w12 h16 Disabled vFRT3Right", ">").OnEvent("Click", nm_FieldReturnType)

MainGui.Add("Text", "x427 y61 w60 +Center +BackgroundTrans vFieldSprinklerLoc1", FieldSprinklerLoc1)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL1Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL1Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)
MainGui.Add("Text", "x427 yp+61 w60 +Center +BackgroundTrans vFieldSprinklerLoc2", FieldSprinklerLoc2)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL2Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL2Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)
MainGui.Add("Text", "x427 yp+61 w60 +Center +BackgroundTrans vFieldSprinklerLoc3", FieldSprinklerLoc3)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 Disabled vFSL3Left", "<").OnEvent("Click", nm_FieldSprinklerLoc)
MainGui.Add("Button", "xp+71 yp w12 h16 Disabled vFSL3Right", ">").OnEvent("Click", nm_FieldSprinklerLoc)

MainGui.Add("Text", "x415 y79 w86 +BackgroundTrans +Center", "Distance:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "Distance:")
MainGui.Add("Text", "xp yp+60 wp +BackgroundTrans +Center", "Distance:")
MainGui.Add("Text", "x440 y95 w32 h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist1", FieldSprinklerDist1)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist2", FieldSprinklerDist2)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "xp yp+60 wp h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-10 Disabled vFieldSprinklerDist3", FieldSprinklerDist3)).Section := "Gather", GuiCtrl.OnEvent("Change", nm_saveConfig)
SetLoadingProgress(26)

; CREDITS TAB
; ------------------------
TabCtrl.UseTab("Credits")
MainGui.Add("Picture", "+BackgroundTrans vContributorsDevImage x5 y24 AltSubmit")
MainGui.Add("Picture", "+BackgroundTrans vContributorsImage x253 y24 AltSubmit")

MainGui.SetFont("w700")
MainGui.Add("Text", "x15 y28 w225 +wrap +backgroundtrans cWhite", "Development")
MainGui.Add("Text", "x261 y28 w225 +wrap +backgroundtrans cWhite", "Supporters")

MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x18 y43 w225 +wrap +backgroundtrans cWhite", "Special Thanks to the developers and testers!`nClick the names to view their Discord profiles!")
MainGui.Add("Text", "x264 y43 w180 +wrap +backgroundtrans cWhite", "Thank you for your donations and contributions to this project!")

MainGui.Add("Button", "x440 y46 w18 h18 vContributorsLeft Disabled", "<").OnEvent("Click", nm_ContributorsPageButton)
MainGui.Add("Button", "x464 y46 w18 h18 vContributorsRight Disabled", ">").OnEvent("Click", nm_ContributorsPageButton)

try AsyncHttpRequest("GET", "https://raw.githubusercontent.com/NatroTeam/.github/main/data/contributors.txt", nm_ContributorsHandler, Map("accept", "application/vnd.github.v3.raw"))
SetLoadingProgress(27)

; MISC TAB
; ------------------------
TabCtrl.UseTab("Misc")
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y24 w160 h144", "Hive Tools")
MainGui.Add("GroupBox", "x5 y168 w160 h62", "Other Tools")
MainGui.Add("GroupBox", "x170 y24 w160 h144", "Calculators")
MainGui.Add("GroupBox", "x170 y168 w160 h62 vAutoClickerButton", "AutoClicker (" AutoClickerHotkey ")")
MainGui.Add("GroupBox", "x335 y24 w160 h84", "Macro Tools")
MainGui.Add("GroupBox", "x335 y108 w160 h60", "Discord Tools")
MainGui.Add("GroupBox", "x335 y168 w160 h62", "Bugs and Suggestions")
MainGui.SetFont("s9 cDefault Norm", "Tahoma")
;hive tools
MainGui.Add("Button", "x10 y40 w150 h40 vBasicEggHatcherButton Disabled", "Gifted Basic Bee`nAuto-Hatcher").OnEvent("Click", nm_BasicEggHatcher)
MainGui.Add("Button", "x10 y82 w150 h40 vBitterberryFeederButton Disabled", "Bitterberry`nAuto-Feeder").OnEvent("Click", nm_BitterberryFeeder)
MainGui.Add("Button", "x10 y124 w150 h40 vAutoMutatorButton Disabled", "Auto-Jelly").OnEvent("Click", blc_mutations)
;other tools
MainGui.Add("Button", "x10 y184 w150 h42 vGenerateBeeListButton Disabled", "Export Hive Bee List`n(for Hive Builder)").OnEvent("Click", nm_GenerateBeeList)
;calculators
MainGui.Add("Button", "x175 y40 w150 h40 vTicketShopCalculatorButton Disabled", "Ticket Shop Calculator`n(Google Sheets)").OnEvent("Click", nm_TicketShopCalculatorButton)
MainGui.Add("Button", "x175 y82 w150 h40 vSSACalculatorButton Disabled", "SSA Calculator`n(Google Sheets)").OnEvent("Click", nm_SSACalculatorButton)
MainGui.Add("Button", "x175 y124 w150 h40 vBondCalculatorButton Disabled", "Bond Calculator`n(Google Sheets)").OnEvent("Click", nm_BondCalculatorButton)
;autoclicker
MainGui.Add("Button", "x175 y184 w150 h42 vAutoClickerGUI Disabled", "AutoClicker`nSettings").OnEvent("Click", nm_AutoClickerButton)
;macro tools
MainGui.Add("Button", "x340 y40 w150 h20 vHotkeyGUI Disabled", "Change Hotkeys").OnEvent("Click", nm_HotkeyGUI)
MainGui.Add("Button", "x340 y62 w150 h20 vDebugLogGUI Disabled", "Debug Log Options").OnEvent("Click", nm_DebugLogGUI)
MainGui.Add("Button", "x340 y84 w150 h20 vAutoStartManagerGUI Disabled", "Auto-Start Manager").OnEvent("Click", nm_AutoStartManager)
;discord tools
MainGui.Add("Button", "x340 y124 w150 h40 vNightAnnouncementGUI Disabled", "Night Detection`nAnnouncement").OnEvent("Click", nm_NightAnnouncementGUI)
;reporting
MainGui.Add("Button", "x340 y184 w150 h20 vReportBugButton Disabled", "Report Bugs").OnEvent("Click", nm_ReportBugButton)
MainGui.Add("Button", "x340 y206 w150 h20 vMakeSuggestionButton Disabled", "Make Suggestions").OnEvent("Click", nm_MakeSuggestionButton)
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

; STATUS TAB
; ------------------------
TabCtrl.UseTab("Status")
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y23 w240 h210", "Status Log")
MainGui.Add("GroupBox", "x250 y23 w245 h160", "Stats")
MainGui.Add("GroupBox", "x250 y185 w245 h48", "Discord Integration")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

MainGui.Add("CheckBox", "x85 y23 Disabled vStatusLogReverse Checked" StatusLogReverse, "Reverse Order").OnEvent("Click", nm_StatusLogReverseCheck)
MainGui.Add("Text", "x10 y37 w230 r15 +BackgroundTrans -Wrap vstatuslog")

MainGui.SetFont("w700")
MainGui.Add("Text", "x255 y40", "Total")
MainGui.Add("Text", "x375 y40", "Session")

MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x255 y55 w119 h120 -Wrap vTotalStats")
MainGui.Add("Text", "x375 y55 w119 h120 -Wrap vSessionStats")
MainGui.Add("Button", "x290 y39 w50 h15 vResetTotalStats Disabled", "Reset").OnEvent("Click", nm_ResetTotalStats)
MainGui.Add("Button", "x265 y202 w215 h24 vWebhookGUI Disabled", "Change Discord Settings").OnEvent("Click", nm_WebhookGUI)
nm_setStats()
SetLoadingProgress(28)

; SETTINGS TAB
; ------------------------
TabCtrl.UseTab("Settings")
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y25 w160 h65", "Gui")
MainGui.Add("GroupBox", "x5 y95 w160 h65", "Hive")
MainGui.Add("GroupBox", "x5 y165 w160 h70", "Reset")
MainGui.Add("GroupBox", "x170 y25 w160 h35", "Input")
MainGui.Add("GroupBox", "x170 y65 w160 h170", "Reconnect")
MainGui.Add("GroupBox", "x335 y25 w160 h210", "Character")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

;gui settings
MainGui.Add("CheckBox", "x10 y73 Disabled vAlwaysOnTop Checked" AlwaysOnTop, "Always On Top").OnEvent("Click", nm_AlwaysOnTop)
MainGui.Add("Text", "x10 y40 w70 +BackgroundTrans", "GUI Theme:")
StylesList := []
Loop Files A_WorkingDir "\nm_image_assets\Styles\*.msstyles"
	StylesList.Push(StrReplace(A_LoopFileName, ".msstyles"))
(GuiCtrl := MainGui.Add("DropDownList", "x75 y34 w72 h100 vGuiTheme Disabled", StylesList)).Text := GuiTheme, GuiCtrl.OnEvent("Change", nm_guiThemeSelect)
MainGui.Add("Text", "x10 y57 w100 +BackgroundTrans", "GUI Transparency:")
MainGui.Add("Text", "x104 y57 w20 +Center +BackgroundTrans vGuiTransparency", GuiTransparency)
MainGui.Add("UpDown", "xp+22 yp-1 h16 -16 Range0-14 vGuiTransparencyUpDown Disabled", GuiTransparency//5).OnEvent("Change", nm_guiTransparencySet)
SetLoadingProgress(29)

;hive settings
MainGui.Add("Text", "x10 y110 w60 +BackgroundTrans", "Hive Slot:")
MainGui.SetFont("s6")
MainGui.Add("Text", "x61 y112 w60 +BackgroundTrans", "(6-5-4-3-2-1)")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x110 y109 w34 h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-6 vHiveSlot Disabled", HiveSlot)).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "x10 y125 w110 +BackgroundTrans", "My Hive Has:")
MainGui.Add("Edit", "x75 y124 w18 h16 Limit2 number vHiveBees Disabled", ValidateInt(&HiveBees, 50)).OnEvent("Change", nm_HiveBees)
MainGui.Add("Text", "x98 y125 w110 +BackgroundTrans", "Bees")
MainGui.Add("Button", "x150 y124 w10 h15 vHiveBeesHelp Disabled", "?").OnEvent("Click", nm_HiveBeesHelp)
MainGui.Add("Text", "x9 y142 w110 +BackgroundTrans", "Wait")
(GuiCtrl := MainGui.Add("Edit", "x33 y141 w18 h16 Limit2 number vConvertDelay Disabled", ValidateInt(&ConvertDelay))).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "x54 y142 w110 +BackgroundTrans", "seconds after convert")

;reset settings
MainGui.Add("Button", "x20 y183 w130 h22 vResetFieldDefaultsButton Disabled", "Reset Field Defaults").OnEvent("Click", nm_ResetFieldDefaultGUI)
MainGui.Add("Button", "x20 y207 w130 h22 vResetAllButton Disabled", "Reset All Settings").OnEvent("Click", nm_ResetConfig)

;input settings
MainGui.Add("Text", "x178 y41 w100 +BackgroundTrans", "Add Key Delay (ms):")
MainGui.Add("Text", "x278 y39 w47 h18 0x201")
MainGui.Add("UpDown", "Range0-9999 vKeyDelay Disabled", KeyDelay).OnEvent("Change", nm_saveKeyDelay)

;reconnect settings
MainGui.Add("Button", "x248 y64 w40 h16 vTestReconnectButton Disabled", "Test").OnEvent("Click", nm_testReconnect)
MainGui.Add("Text", "x178 y82 +BackgroundTrans", "Private Server Link:")
MainGui.Add("Edit", "x176 yp+15 w148 h16 vPrivServer Disabled", PrivServer).OnEvent("Change", nm_ServerLink)
MainGui.Add("Text", "x178 yp+21 +BackgroundTrans", "Join Method:")
MainGui.Add("Text", "x254 yp w48 vReconnectMethod +Center +BackgroundTrans", ReconnectMethod)
MainGui.Add("Button", "xp-12 yp-1 w12 h15 vRMLeft Disabled", "<").OnEvent("Click", nm_ReconnectMethod)
MainGui.Add("Button", "xp+59 yp w12 h15 vRMRight Disabled", ">").OnEvent("Click", nm_ReconnectMethod)
MainGui.Add("Button", "x315 yp w10 h15 vReconnectMethodHelp Disabled", "?").OnEvent("Click", nm_ReconnectMethodHelp)
MainGui.Add("Text", "x178 yp+21 +BackgroundTrans", "Daily Reconnect (optional):")
MainGui.Add("Text", "x178 yp+18 +BackgroundTrans", "Reconnect every")
MainGui.Add("Edit", "x264 yp-1 w18 h16 Number Limit2 vReconnectInterval Disabled", ValidateInt(&ReconnectInterval, "")).OnEvent("Change", nm_setReconnectInterval)
MainGui.Add("Text", "x287 yp+1 +BackgroundTrans", "hours")
MainGui.Add("Text", "x196 yp+18 +BackgroundTrans", "starting at")
MainGui.Add("Edit", "x250 yp-1 w18 h16 Number Limit2 vReconnectHour Disabled", IsInteger(ReconnectHour) ? SubStr("0" ReconnectHour, -2) : "").OnEvent("Change", nm_setReconnectHour)
MainGui.Add("Edit", "x275 yp w18 h16 Number Limit2 vReconnectMin Disabled", IsInteger(ReconnectMin) ? SubStr("0" ReconnectMin, -2) : "").OnEvent("Change", nm_setReconnectMin)
MainGui.SetFont("w1000 s11")
MainGui.Add("Text", "x269 yp-3 +BackgroundTrans", ":")
MainGui.SetFont("s6 w700")
MainGui.Add("Text", "x295 yp+6 +BackgroundTrans", "UTC")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x315 yp-3 w10 h15 vReconnectTimeHelp Disabled", "?").OnEvent("Click", nm_ReconnectTimeHelp)
(GuiCtrl := MainGui.Add("CheckBox", "x176 yp+24 w88 h15 vReconnectMessage Disabled Checked" ReconnectMessage, "Natro so broke")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["weary"])
MainGui.Add("Picture", "+BackgroundTrans x269 yp-2 w20 h20", "HBITMAP:*" hBM)
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["weary"])
MainGui.Add("Button", "x315 yp+2 w10 h15 vNatroSoBrokeHelp Disabled", "?").OnEvent("Click", nm_NatroSoBrokeHelp)
(GuiCtrl := MainGui.Add("CheckBox", "x176 yp+18 w132 h15 vPublicFallback Disabled Checked" PublicFallback, "Fallback to Public Server")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Button", "x315 yp w10 h15 vPublicFallbackHelp Disabled", "?").OnEvent("Click", nm_PublicFallbackHelp)

;character settings
MainGui.Add("Text", "x345 y40 w110 +BackgroundTrans", "Movement Speed:")
MainGui.SetFont("s6")
MainGui.Add("Text", "x345 y55 w80 +right +BackgroundTrans", "(WITHOUT HASTE)")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Edit", "x438 y43 w43 r1 limit5 vMoveSpeedNum Disabled", MoveSpeedNum).OnEvent("Change", nm_moveSpeed)
(GuiCtrl := MainGui.Add("CheckBox", "x345 y68 w125 h15 vNewWalk Disabled Checked" NewWalk, "MoveSpeed Correction")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Button", "x475 y68 w10 h15 vNewWalkHelp Disabled", "?").OnEvent("Click", nm_NewWalkHelp)
MainGui.Add("Text", "x338 y90 w85 +Center +BackgroundTrans", "Move Method:")
MainGui.Add("Text", "x434 yp w48 vMoveMethod +Center +BackgroundTrans", MoveMethod)
MainGui.Add("Button", "x422 y89 w12 h16 vMMLeft Disabled", "<").OnEvent("Click", nm_MoveMethod)
MainGui.Add("Button", "x480 y89 w12 h16 vMMRight Disabled", ">").OnEvent("Click", nm_MoveMethod)
MainGui.Add("Text", "x338 y111 w85 +Center +BackgroundTrans", "Sprinkler Type:")
MainGui.Add("Text", "x434 yp w48 vSprinklerType +Center +BackgroundTrans", SprinklerType)
MainGui.Add("Button", "x422 y110 w12 h16 vSTLeft Disabled", "<").OnEvent("Click", nm_SprinklerType)
MainGui.Add("Button", "x480 y110 w12 h16 vSTRight Disabled", ">").OnEvent("Click", nm_SprinklerType)
MainGui.Add("Text", "x338 y132 w85 +Center +BackgroundTrans", "Convert Balloon:")
MainGui.Add("Text", "x434 yp w48 vConvertBalloon +Center +BackgroundTrans", ConvertBalloon)
MainGui.Add("Button", "x422 y131 w12 h16 vCBLeft Disabled", "<").OnEvent("Click", nm_ConvertBalloon)
MainGui.Add("Button", "x480 y131 w12 h16 vCBRight Disabled", ">").OnEvent("Click", nm_ConvertBalloon)
MainGui.Add("Text", "x370 y147 w110 +BackgroundTrans", "\____\___")
(GuiCtrl := MainGui.Add("Edit", "x422 y150 w30 h18 number Limit3 vConvertMins Disabled", ValidateInt(&ConvertMins, 30))).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "x456 y152", "Mins")
MainGui.Add("Text", "x345 y170 w110 +BackgroundTrans", "Multiple Reset:")
(GuiCtrl := MainGui.Add("Slider", "x415 y168 w78 h16 vMultiReset Thick16 Disabled ToolTipTop Range0-3 Page1 TickInterval1", MultiReset)).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x345 y186 vGatherDoubleReset Disabled Checked" GatherDoubleReset, "Gather Double Reset")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x345 y201 vDisableToolUse Disabled Checked" DisableToolUse, "Disable Tool Use")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
GuiCtrl := MainGui.Add("CheckBox", "x345 y216 vAnnounceGuidingStar Disabled Checked" AnnounceGuidingStar, "Announce Guiding Star").OnEvent("Click", nm_AnnounceGuidWarn)
SetLoadingProgress(30)

;COLLECT/Kill TAB
;------------------------
TabCtrl.UseTab("Collect/Kill")
;sub-tabs
MainGui.Add("Button", "x4 y21 w246 h18 vCollectSubTab Disabled", "Collect").OnEvent("Click", nm_CollectKillButton)
MainGui.Add("Button", "x250 y21 w246 h18 vKillSubTab", "Kill").OnEvent("Click", nm_CollectKillButton)
;collect
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y42 w125 h124 vCollectGroupBox", "Collect")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
(GuiCtrl := MainGui.Add("CheckBox", "x10 y57 vClockCheck Disabled Checked" ClockCheck, "Clock (tickets)")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x10 yp+18 w50 vMondoBuffCheck Disabled Checked" MondoBuffCheck, "Mondo")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MondoActionList := ["Buff", "Kill"], PMondoGuid && MondoActionList.Push("Tag", "Guid"), MondoActionList.Default := "", MondoActionList.Length := 4
MainGui.Add("Text", "x75 yp w40 vMondoAction +Center +BackgroundTrans", MondoAction)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vMALeft Disabled", "<").OnEvent("Click", nm_MondoAction)
MainGui.Add("Button", "xp+51 yp w12 h16 vMARight Disabled", ">").OnEvent("Click", nm_MondoAction)
MainGui.Add("Text", "x14 yp+15 w110 vMondoPointText +BackgroundTrans Section Hidden" (MondoAction != "Buff" && MondoAction != "Kill"), "\__")
(GuiCtrl := MainGui.Add("Edit", "xs+20 ys+3 w30 h18 number Limit3 vMondoSecs Disabled Hidden" (MondoAction != "Buff"), ValidateInt(&MondoSecs, 120))).Section := "Collect", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "x+4 yp+2 vMondoSecsText Hidden" (MondoAction != "Buff"), "Secs")
MainGui.Add("Text", "xs+18 ys+4 vMondoLootText Hidden" (MondoAction != "Kill"), "Loot:")
MainGui.Add("Text", "x+13 yp w45 vMondoLootDirection +Center +BackgroundTrans Hidden" (MondoAction != "Kill"), MondoLootDirection)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vMLDLeft Disabled Hidden" (MondoAction != "Kill"), "<").OnEvent("Click", nm_MondoLootDirection)
MainGui.Add("Button", "xp+56 yp w12 h16 vMLDRight Disabled Hidden" (MondoAction != "Kill"), ">").OnEvent("Click", nm_MondoLootDirection)
(GuiCtrl := MainGui.Add("CheckBox", "x10 y112 w35 vAntPassCheck Disabled Checked" AntPassCheck, "Ant")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Text", "x60 yp w55 vAntPassAction +Center +BackgroundTrans", AntPassAction)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vAPALeft Disabled", "<").OnEvent("Click", nm_AntPassAction)
MainGui.Add("Button", "xp+66 yp w12 h16 vAPARight Disabled", ">").OnEvent("Click", nm_AntPassAction)
MainGui.Add("Text", "x14 yp+15 vAntPassPointText +BackgroundTrans", "\__")
MainGui.Add("CheckBox", "x+4 yp+5 vAntPassBuyCheck Disabled Checked" AntPassBuyCheck, "Use Tickets").OnEvent("Click", nm_AntPassBuyCheck)
(GuiCtrl := MainGui.Add("CheckBox", "x10 yp+17 vHoneystormCheck Disabled Checked" HoneystormCheck, "Honeystorm")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
;memory match
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y168 w125 h68 vMemoryMatchGroupBox", "Memory Match")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
(GuiCtrl := MainGui.Add("CheckBox", "x10 yp+15 w58 vNormalMemoryMatchCheck Disabled Checked" NormalMemoryMatchCheck, "Normal")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("CheckBox", "xp yp+18 wp vNightMemoryMatchCheck Disabled Checked" NightMemoryMatchCheck, "Night").OnEvent("Click", nm_NightMemoryMatchCheck)
(GuiCtrl := MainGui.Add("CheckBox", "xp+58 yp-18 wp vMegaMemoryMatchCheck Disabled Checked" MegaMemoryMatchCheck, "Mega")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 wp vExtremeMemoryMatchCheck Disabled Checked" ExtremeMemoryMatchCheck, "Extreme")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Button", "x43 yp+16 w49 h16 vMemoryMatchOptions Disabled", "Options").OnEvent("Click", nm_MemoryMatchOptions)
;dispensers
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x135 y42 w165 h105 vDispensersGroupBox", "Dispensers")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
(GuiCtrl := MainGui.Add("CheckBox", "x140 y57 vHoneyDisCheck Disabled Checked" HoneyDisCheck, "Honey")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vTreatDisCheck Disabled Checked" TreatDisCheck, "Treat")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBlueberryDisCheck Disabled Checked" BlueberryDisCheck, "Blueberry")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vStrawberryDisCheck Disabled Checked" StrawberryDisCheck, "Strawberry")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vCoconutDisCheck Disabled Checked" CoconutDisCheck, "Coconut")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp+85 y57 vRoyalJellyDisCheck Disabled Checked" RoyalJellyDisCheck, "Royal Jelly")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vGlueDisCheck Disabled Checked" GlueDisCheck, "Glue")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vRoboPassCheck Disabled Checked" RoboPassCheck, "Robo Pass")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
;beesmas
beesmasActive := 0
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x135 y149 w360 h87 vBeesmasGroupBox", "Beesmas (Inactive)")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["warninggui"])
MainGui.Add("Picture", "+BackgroundTrans x261 yp w14 h14 vBeesmasFailImage", "HBITMAP:*" hBM).OnEvent("Click", BeesmasActiveFail)
DllCall("DeleteObject", "ptr", hBM)
MainGui.Add("Picture", "+BackgroundTrans x247 yp-3 w20 h20 vBeesmasImage")
(GuiCtrl := MainGui.Add("CheckBox", "x350 yp+4 vBeesmasGatherInterruptCheck Disabled", "Allow Gather Interrupt")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x140 yp+14 Section vStockingsCheck Disabled", "Stockings")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vWreathCheck Disabled", "Honey Wreath")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vFeastCheck Disabled", "Feast")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vRBPDelevelCheck Disabled", "Robo Party De-level")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp+120 ys vGingerbreadCheck Disabled", "Gingerbread")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vSnowMachineCheck Disabled", "Snow Machine")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vCandlesCheck Disabled", "Candles")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vWinterMemoryMatchCheck Disabled", "Winter Memory Match")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp+130 ys+6 vSamovarCheck Disabled", "Samovar")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vLidArtCheck Disabled", "Lid Art")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vGummyBeaconCheck Disabled", "Gummy Beacon")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
try AsyncHttpRequest("GET", "https://raw.githubusercontent.com/NatroTeam/.github/main/data/beesmas.txt", nm_BeesmasHandler, Map("accept", "application/vnd.github.v3.raw"))
;Blender
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x305 y42 w190 h105 vBlenderGroupBox", "Blender")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
loop 3 {
	xCoords := 256 + (62 * A_index)
	MainGui.Add("Button", "x" xCoords " y124 w40 h15 vBlenderAdd" A_index " Disabled", (BlenderItem%A_index% = "None") ? "Add" : "Clear").OnEvent("Click", nm_setBlenderData)
	MainGui.Add("Picture", "x" xCoords " y78 h40 w40 vBlenderItem" A_index "Picture +BackgroundTrans +0xE"
		, (BlenderItem%A_index% = "None") ? "" : hBitmapsSB[BlenderItem%A_index%] ? ("HBITMAP:*" hBitmapsSB[BlenderItem%A_index%]) : "")
	MainGui.Add("Text", "x" (247 + (62 * A_index)) " y58 w60 +Center vBlenderData" A_index, "(" BlenderAmount%A_Index% ") [" ((BlenderIndex%A_index% = "Infinite") ? "∞" : BlenderIndex%A_index%) "]")
}
BlenderAdd := 0 ;setup BlenderAdd for later use in the GUI

MainGui.Add("Text", "x431 y125 w41 h16 +Center +0x200 vBlenderAmountNum Hidden")
MainGui.Add("UpDown", "vBlenderAmount Range1-999 Hidden", 1)
MainGui.Add("Text", "x435 y106 vBlenderAmountText Hidden", "Amount")
MainGui.Add("Text", "x435 y50 h13 vBlenderRepeatText Hidden", "Repeat")
MainGui.SetFont("w700 underline")
MainGui.Add("Text", "x332 y58 w80 vblendertitle1 Hidden", "Add Item")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x307 y74 w103 h1 vblenderline1 Hidden 0x7")
MainGui.Add("Text", "x409 y49 w1 h97 vblenderline2 Hidden 0x7")
MainGui.Add("Text", "x410 y64 w83 h1 vblenderline3 Hidden 0x7")
MainGui.Add("Text", "x410 y121 w83 h1 vblenderline4 Hidden 0x7")
MainGui.Add("Text", "x431 y86 w41 h16 +Center +0x200 vBlenderIndexNum Hidden")
MainGui.Add("UpDown", "vBlenderIndex Range1-999 Hidden", 1)
MainGui.Add("CheckBox", "x427 y69 w60 vBlenderIndexOption Hidden", "Infinite").OnEvent("Click", nm_BlenderIndexOption)
MainGui.Add("Picture", "x336 y80 w40 h40 vBlenderItem Hidden +0xE")
MainGui.SetFont("s8 cDefault Bold", "Tahoma")
MainGui.Add("Button", "x312 y95 w18 h18 vBlenderLeft Hidden", "<").OnEvent("Click", ba_AddBlenderItemButton)
MainGui.Add("Button", "x385 y95 w18 h18 vBlenderRight Hidden", ">").OnEvent("Click", ba_AddBlenderItemButton)
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x318 y125 w80 h16 +Center vBlenderAddSlot Hidden").OnEvent("Click", ba_AddBlenderItem)

;KILL
;bugrun
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x10 y42 w134 h188 vBugRunGroupBox Hidden", "Bug Run")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("CheckBox", "x76 y43 vBugRunCheck Disabled Hidden", "Select All").OnEvent("Click", nm_BugRunCheck)
MainGui.Add("Text", "x16 y62 +BackgroundTrans Hidden vTextMonsterRespawnPercent", "–       %")
MainGui.Add("Text", "x52 y55 w80 +BackgroundTrans +Center vTextMonsterRespawn Hidden", "Monster Respawn Time")
MainGui.Add("Edit", "x24 y61 w18 h16 Limit2 number vMonsterRespawnTime Disabled Hidden", ValidateNumber(&MonsterRespawnTime)).OnEvent("Change", nm_MonsterRespawnTime)
MainGui.Add("Button", "x128 y63 w12 h14 vMonsterRespawnTimeHelp Disabled Hidden", "?").OnEvent("Click", nm_MonsterRespawnTimeHelp)
GuiCtrl := MainGui.Add("CheckBox", "x16 y82 w125 h15 vBugrunInterruptCheck Disabled Hidden Checked" BugrunInterruptCheck, "Allow Gather Interrupt")
GuiCtrl.Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("Text", "x16 y100 +BackgroundTrans Hidden vTextLoot", "Loot")
MainGui.Add("Text", "x49 y100 +BackgroundTrans Hidden vTextKill", "Kill")
MainGui.Add("Text", "x15 y114 w114 h1 0x7 Hidden vTextLineBugRun1")
MainGui.Add("Text", "x40 y100 w1 h124 0x7 Hidden vTextLineBugRun2")
(GuiCtrl := MainGui.Add("CheckBox", "x20 y120 w13 h13 vBugrunLadybugsLoot Disabled Hidden Checked" BugrunLadybugsLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 w13 h13 vBugrunRhinoBeetlesLoot Disabled Hidden Checked" BugrunRhinoBeetlesLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 w13 h13 vBugrunSpiderLoot Disabled Hidden Checked" BugrunSpiderLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 w13 h13 vBugrunMantisLoot Disabled Hidden Checked" BugrunMantisLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 w13 h13 vBugrunScorpionsLoot Disabled Hidden Checked" BugrunScorpionsLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 w13 h13 vBugrunWerewolfLoot Disabled Hidden Checked" BugrunWerewolfLoot)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x48 y120 vBugrunLadybugsCheck Disabled Hidden Checked" BugrunLadybugsCheck, "Ladybugs")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBugrunRhinoBeetlesCheck Disabled Hidden Checked" BugrunRhinoBeetlesCheck, "Rhino Beetles")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBugrunSpiderCheck Disabled Hidden Checked" BugrunSpiderCheck, "Spider")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBugrunMantisCheck Disabled Hidden Checked" BugrunMantisCheck, "Mantis")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBugrunScorpionsCheck Disabled Hidden Checked" BugrunScorpionsCheck, "Scorpions")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+18 vBugrunWerewolfCheck Disabled Hidden Checked" BugrunWerewolfCheck, "Werewolf")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)

;stingers
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x149 y42 w341 h60 vStingersGroupBox Hidden", "Stingers")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("CheckBox", "x217 y43 vStingerCheck Disabled Hidden Checked" StingerCheck, "Kill Vicious Bee").OnEvent("Click", nm_saveStingers)
(GuiCtrl := MainGui.Add("CheckBox", "x315 y43 vStingerDailyBonusCheck Disabled Hidden Checked" StingerDailyBonusCheck, "Only Daily Bonus")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Text", "x168 y69 +BackgroundTrans Hidden vTextFields", "Fields:")
(GuiCtrl := MainGui.Add("CheckBox", "x220 y62 vStingerCloverCheck Disabled Hidden Checked" StingerCloverCheck, "Clover")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x220 y80 vStingerSpiderCheck Disabled Hidden Checked" StingerSpiderCheck, "Spider")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x305 y62 vStingerCactusCheck Disabled Hidden Checked" StingerCactusCheck, "Cactus")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x305 y80 vStingerRoseCheck Disabled Hidden Checked" StingerRoseCheck, "Rose")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x390 y62 vStingerMountainTopCheck Disabled Hidden Checked" StingerMountainTopCheck, "Mountain Top")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x390 y80 vStingerPepperCheck Disabled Hidden Checked" StingerPepperCheck, "Pepper")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)

;bosses
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x149 y104 w341 h126 vBossesGroupBox Hidden", "Bosses")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Button", "x209 y104 w12 h14 vBossConfigHelp Disabled Hidden", "?").OnEvent("Click", nm_BossConfigHelp)
(GuiCtrl := MainGui.Add("CheckBox", "x152 y123 vKingBeetleCheck Disabled Hidden Checked" KingBeetleCheck, "King Beetle")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+21 vTunnelBearCheck Disabled Hidden Checked" TunnelBearCheck, "Tunnel Bear")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("CheckBox", "xp yp+21 vCocoCrabCheck Disabled Hidden Checked" CocoCrabCheck, "Coco Crab").OnEvent("Click", nm_CocoCrabCheck)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+21 vStumpSnailCheck Disabled Hidden Checked" StumpSnailCheck, "Stump Snail")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+21 vCommandoCheck Disabled Hidden Checked" CommandoCheck, "Commando")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x270 y123 w13 h13 vKingBeetleBabyCheck Disabled Hidden Checked" KingBeetleBabyCheck)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+21 w13 h13 vTunnelBearBabyCheck Disabled Hidden Checked" TunnelBearBabyCheck)).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["babylovegui"])
MainGui.Add("Picture", "+BackgroundTrans vBabyLovePicture1 x286 y120 w18 h18 Hidden", "HBITMAP:*" hBM)
MainGui.Add("Picture", "+BackgroundTrans vBabyLovePicture2 xp yp+21 w18 h18 Hidden", "HBITMAP:*" hBM)
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["babylovegui"])
MainGui.Add("CheckBox", "x370 y123 w13 h13 vKingBeetleAmuletMode Disabled Hidden Checked" KingBeetleAmuletMode).OnEvent("Click", nm_saveAmulet)
MainGui.Add("CheckBox", "x229 y186 w13 h13 vShellAmuletMode Disabled Hidden Checked" ShellAmuletMode).OnEvent("Click", nm_saveAmulet)
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["kingbeetleamu"])
MainGui.Add("Picture", "+BackgroundTrans vKingBeetleAmuPicture x386 y119 w20 h20 Hidden", "HBITMAP:*" hBM)
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["kingbeetleamu"])
MainGui.Add("Text", "x226 y180 w261 h1 0x7 Hidden vTextLineBosses1")
MainGui.Add("Text", "x322 yp-10 w1 h57 0x7 Hidden vTextLineBosses2")
MainGui.Add("Text", "x446 yp w1 h57 0x7 Hidden vTextLineBosses3")
MainGui.Add("Text", "x255.5 yp-3 w37 h13 Hidden vTextBosses1", "Options")
MainGui.Add("Text", "x369 yp w30 h13 Hidden vTextBosses2", "Health")
MainGui.Add("Text", "x456 yp w22 h13 Hidden vTextBosses3", "Time")
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["supremeshellamu"])
MainGui.Add("Picture", "+BackgroundTrans vShellAmuPicture x245 y182 w20 h20 Hidden", "HBITMAP:*" hBM)
DllCall("DeleteObject", "ptr", hBM)
Gdip_DisposeImage(bitmaps["supremeshellamu"])
MainGui.Add("Text", "x410 y123 w56 vKingBeetleAmuletModeText Hidden", (KingBeetleAmuletMode = 1) ? " Keep Old" : "Do Nothing")
MainGui.Add("Text", "x269 y186 w53 vShellAmuletModeText Hidden", (ShellAmuletMode = 1) ? " Keep Old" : "Do Nothing")
MainGui.Add("Text", "x242 y207 h16 vChickLevelTextLabel Hidden", "Level:")
MainGui.Add("Text", "x272 yp-1 w34 h16 0x200 vChickLevelText +Center Hidden", "?")
MainGui.Add("UpDown", "w10 h16 vChickLevel Range3-25 Disabled Hidden", ChickLevel).OnEvent("Change", nm_setChickHealth)
MainGui.Add("Text", "x325 y186 vSnailHPText Hidden", "HP:")
MainGui.Add("Text", "xp yp+21 vChickHPText Hidden", "HP:")
MainGui.Add("Edit", "x343 y184 w60 h18 Number Limit8 vSnailHealthEdit Disabled Hidden", Round(30000000*ValidateNumber(&InputSnailHealth)/100)).OnEvent("Change", nm_setSnailHealth)
MainGui.Add("Edit", "xp yp+21 w60 h18 Number Limit8 vChickHealthEdit Disabled Hidden", Round(CommandoChickHealth[ValidateInt(&ChickLevel, 7)]*ValidateNumber(&InputChickHealth)/100)).OnEvent("Change", nm_setChickHealth)
MainGui.SetFont("s7")
MainGui.Add("Text", "x405 y188 w40 vSnailHealthText Hidden c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0), InputSnailHealth "%")
MainGui.Add("Text", "xp yp+21 w40 vChickHealthText Hidden c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0), InputChickHealth "%")
MainGui.SetFont("s8")
MainGui.Add("Text", "x448 y186 w22 vSnailTimeText +Center Hidden", (SnailTime = "Kill") ? SnailTime : SnailTime "m")
MainGui.Add("UpDown", "xp+22 yp-1 w10 h16 -16 Range1-4 vSnailTimeUpDown Disabled Hidden", (SnailTime = "Kill") ? 4 : SnailTime//5).OnEvent("Change", nm_SnailTime)
MainGui.Add("Text", "x448 y207 w22 vChickTimeText +Center Hidden", (ChickTime = "Kill") ? ChickTime : ChickTime "m")
MainGui.Add("UpDown", "xp+22 yp-1 w10 h16 -16 Range1-4 vChickTimeUpDown Disabled Hidden", (ChickTime = "Kill") ? 4 : ChickTime//5).OnEvent("Change", nm_ChickTime)
SetLoadingProgress(31)

;BOOST TAB
;------------------------
TabCtrl.UseTab("Boost")

;boosters
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x10 y25 w285 h72", "Field Boost")
MainGui.Add("GroupBox", "x10 y97 w285 h138", "Hotbar Slots")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

;field booster
MainGui.Add("Text", "x15 y40 +BackgroundTrans Section", "1:")
MainGui.Add("Text", "x+14 yp w50 vFieldBooster1 +Center +BackgroundTrans", FieldBooster1)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB1Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Button", "xp+61 yp w12 h16 vFB1Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Text", "xs ys+18 +BackgroundTrans", "2:")
MainGui.Add("Text", "x+14 yp w50 vFieldBooster2 +Center +BackgroundTrans", FieldBooster2)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB2Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Button", "xp+61 yp w12 h16 vFB2Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Text", "xs ys+36 +BackgroundTrans", "3:")
MainGui.Add("Text", "x+14 yp w50 vFieldBooster3 +Center +BackgroundTrans", FieldBooster3)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vFB3Left Disabled", "<").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Button", "xp+61 yp w12 h16 vFB3Right Disabled", ">").OnEvent("Click", nm_FieldBooster)
MainGui.Add("Text", "x120 y35 left +BackgroundTrans", "Separate By:")
MainGui.Add("Text", "xp+3 y+1 w12 vFieldBoosterMins +Center", FieldBoosterMins)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range0-12 vFieldBoosterMinsUpDown Disabled", FieldBoosterMins//5).OnEvent("Change", nm_FieldBoosterMins)
MainGui.Add("Text", "xp+20 yp+1 w100 left +BackgroundTrans", "Mins")
MainGui.Add("CheckBox", "x109 y67 +center vBoostChaserCheck Disabled Checked" BoostChaserCheck, "Gather in`nBoosted Field").OnEvent("Click", nm_BoostChaserCheck)
MainGui.Add("Button", "x200 y65 w90 h30 vBoostedFieldSelectButton Disabled", "Select Boosted Gather Fields").OnEvent("Click", nm_BoostedFieldSelectButton)
MainGui.SetFont("w700")

;shrine
MainGui.Add("GroupBox", "x300 y25 w190 h105", "Wind Shrine")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
loop 2 {
	xCoords := 246 + (86 * A_Index)
	MainGui.Add("Button", "x" xCoords " y107 w40 h13 vShrineAdd" A_Index " Disabled", (ShrineItem%A_Index% = "None") ? "Add" : "Clear").OnEvent("Click", ba_setShrineData)
	MainGui.Add("Picture", "x" xCoords " y61 h40 w40 vShrineItem" A_Index "Picture +BackgroundTrans +0xE"
		, (ShrineItem%A_Index% = "None") ? "" : hBitmapsSB[ShrineItem%A_index%] ? ("HBITMAP:*" hBitmapsSB[ShrineItem%A_index%]) : "")
	MainGui.Add("Text", "x" (237 + (86 * A_index)) " y41 w60 +Center vShrineData" A_index, "(" ShrineAmount%A_Index% ") [" ((ShrineIndex%A_index% = "Infinite") ? "∞" : ShrineIndex%A_index%) "]")
}
ShrineAdd := 0
MainGui.Add("Text", "x426 y108 w41 h16 +Center +0x200 vShrineAmountNum Hidden")
MainGui.Add("UpDown", "vShrineAmount Range1-999 Hidden", 1)
MainGui.Add("Text", "x430 y89 vShrineAmountText Hidden", "Amount")
MainGui.Add("Text", "x430 y33 vShrineRepeatText Hidden", "Repeat")
MainGui.SetFont("w700 underline")
MainGui.Add("Text", "x327 y41 w80 vshrinetitle1 Hidden", "Add Item")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("Text", "x302 y57 w103 h1 vShrineline1 Hidden 0x7")
MainGui.Add("Text", "x404 y32 w1 h97 vShrineline2 Hidden 0x7")
MainGui.Add("Text", "x405 y47 w83 h1 vShrineline3 Hidden 0x7")
MainGui.Add("Text", "x405 y104 w83 h1 vShrineline4 Hidden 0x7")
MainGui.Add("Text", "x426 y69 w41 h16 +Center +0x200 vShrineIndexNum Hidden")
MainGui.Add("UpDown", "vShrineIndex Range1-999 Hidden", 1)
MainGui.Add("CheckBox", "x422 y52 w60 vShrineIndexOption Hidden", "Infinite").OnEvent("Click", nm_ShrineIndexOption)
MainGui.Add("Picture", "x331 y63 w40 h40 vShrineItem Hidden +0xE")
MainGui.Add("Button", "x307 y78 w18 h18 vShrineLeft Hidden", "<").OnEvent("Click", ba_AddShrineItemButton)
MainGui.Add("Button", "x380 y78 w18 h18 vShrineRight Hidden", ">").OnEvent("Click", ba_AddShrineItemButton)
MainGui.Add("Button", "x313 y108 w80 h16 +Center vShrineAddSlot Hidden").OnEvent("Click", ba_AddShrineItem)

;hotbar
Loop 6
{
	i := A_Index + 1
	MainGui.Add("Text", "x15 y" (95 + 20 * A_Index) " w10 +BackgroundTrans", i ":")
	(GuiCtrl := MainGui.Add("DropDownList", "x25 y" (92 + 20 * A_Index) " w80 vHotbarWhile" i " Disabled", hotbarwhilelist)).Text := HotbarWhile%i%, GuiCtrl.OnEvent("Change", nm_HotbarWhile)
	MainGui.Add("Text", "x113 y" (95 + 20 * A_Index) " cRed vHBOffText" i, "<-- OFF")
	MainGui.Add("Text", "x106 y" (95 + 20 * A_Index) " w120 vHBText" i " Hidden")
	MainGui.Add("Text", "x108 y" (95 + 20 * A_Index) " w62 vHBTimeText" i " +Center Hidden").OnEvent("Click", nm_HotbarEditTime)
	MainGui.Add("UpDown", "x170 y" (94 + 20 * A_Index) " w10 h16 -16 Range1-99999 vHotbarTime" i " Hidden Disabled", HotbarTime%i%).OnEvent("Change", nm_HotbarTimeUpDown)
	MainGui.Add("Text", "x188 y" (94 + 20 * A_Index) " w62 vHBConditionText" i " +Center Hidden")
	(GuiCtrl := MainGui.Add("UpDown", "x250 y" (94 + 20 * A_Index) " w10 h16 -16 Range1-100 vHotbarMax" i " Hidden Disabled", HotbarMax%i%)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_hotbarMaxUpDown)
	SetLoadingProgress(31+A_Index)
}
nm_HotbarWhile()
MainGui.Add("Button", "x200 y34 w90 h30 vAutoFieldBoostButton Disabled", (AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]")).OnEvent("Click", nm_autoFieldBoostGui)
MainGui.SetFont("w700")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

;stickers
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x300 y130 w191 h105", "Stickers")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")
MainGui.Add("CheckBox", "x305 yp+16 vStickerStackCheck Disabled Checked" StickerStackCheck, "Sticker Stack").OnEvent("Click", nm_StickerStackCheck)
MainGui.Add("Text", "xp+6 yp+13 +BackgroundTrans", "\__")
MainGui.Add("Text", "x+0 yp+4 w36 +Center +BackgroundTrans Section", "Timer:")
MainGui.Add("Text", "x+12 yp w" ((StickerStackMode = 0) ? 85 : 68) " vStickerStackModeText +Center +BackgroundTrans", (StickerStackMode = 0) ? "Detect" : hmsFromSeconds(StickerStackTimer)).OnEvent("Click", nm_StickerStackModeText)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSSMLeft Disabled", "<").OnEvent("Click", nm_StickerStackMode)
MainGui.Add("Button", "xp+96 yp w12 h16 vSSMRight Disabled", ">").OnEvent("Click", nm_StickerStackMode)
MainGui.Add("UpDown", "xp-18 yp h16 -16 Range900-86400 vStickerStackTimer Disabled Hidden" (StickerStackMode = 0), StickerStackTimer).OnEvent("Change", nm_StickerStackTimer)
MainGui.Add("Button", "xp+36 yp+1 w12 h14 vStickerStackModeHelp Disabled", "?").OnEvent("Click", nm_StickerStackModeHelp)
MainGui.Add("Text", "xs yp+17 w36 +Center +BackgroundTrans", "Item:")
MainGui.Add("Text", "x+12 yp w85 vStickerStackItem +Center +BackgroundTrans", StickerStackItem)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSSILeft Disabled", "<").OnEvent("Click", nm_StickerStackItem)
MainGui.Add("Button", "xp+96 yp w12 h16 vSSIRight Disabled", ">").OnEvent("Click", nm_StickerStackItem)
MainGui.Add("Button", "xp+18 yp+1 w12 h14 vStickerStackItemHelp Disabled", "?").OnEvent("Click", nm_StickerStackItemHelp)
MainGui.Add("Text", "xs-27 yp+17 w36 +Center +BackgroundTrans", "Skins:")
MainGui.Add("CheckBox", "x332 yp vStickerStackHive Disabled Checked" StickerStackHive, "Hive").OnEvent("Click", nm_StickerStackSkins)
MainGui.Add("CheckBox", "x375 yp vStickerStackCub Disabled Checked" StickerStackCub, "Cub").OnEvent("Click", nm_StickerStackSkins)
MainGui.Add("CheckBox", "x416 yp w36 vStickerStackVoucher Disabled Checked" StickerStackVoucher, "Voucher").OnEvent("Click", nm_StickerStackSkins)
MainGui.Add("Button", "xs+150 yp w12 h14 vStickerStackSkinsHelp Disabled", "?").OnEvent("Click", nm_StickerStackSkinsHelp)
MainGui.Add("CheckBox", "x305 yp+19 w86 h13 vStickerPrinterCheck Disabled Checked" StickerPrinterCheck, "Sticker Printer").OnEvent("Click", nm_StickerPrinterCheck)
MainGui.Add("Text", "x+0 yp w24 +Center +BackgroundTrans", "Egg:")
MainGui.Add("Text", "x+12 yp w48 vStickerPrinterEgg +Center +BackgroundTrans", StickerPrinterEgg)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vSPELeft Disabled", "<").OnEvent("Click", nm_StickerPrinterEgg)
MainGui.Add("Button", "xp+59 yp w12 h16 vSPERight Disabled", ">").OnEvent("Click", nm_StickerPrinterEgg)
;QUESTS TAB
;------------------------
TabCtrl.UseTab("Quests")
MainGui.SetFont("w700")
MainGui.Add("GroupBox", "x5 y23 w150 h108", "Polar Bear")
MainGui.Add("GroupBox", "x5 y131 w150 h38", "Honey Bee")
MainGui.Add("GroupBox", "x5 y170 w150 h68", "Settings")
MainGui.Add("GroupBox", "x160 y23 w165 h108", "Black Bear")
MainGui.Add("GroupBox", "x160 y131 w165 h108", "Brown Bear")
MainGui.Add("GroupBox", "x330 y23 w165 h108", "Bucko Bee")
MainGui.Add("GroupBox", "x330 y131 w165 h108", "Riley Bee")

MainGui.SetFont("s8 cDefault Norm", "Tahoma")
(GuiCtrl := MainGui.Add("CheckBox", "x80 y23 vPolarQuestCheck Disabled Checked" PolarQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x15 y37 vPolarQuestGatherInterruptCheck Disabled Checked" PolarQuestGatherInterruptCheck, "Allow Gather Interrupt")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Text", "x8 y51 w145 h78 vPolarQuestProgress", StrReplace(PolarQuestProgress, "|", "`n"))

(GuiCtrl := MainGui.Add("CheckBox", "x80 y131 vHoneyQuestCheck Disabled Checked" HoneyQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Text", "x8 y145 w143 h20 vHoneyQuestProgress", StrReplace(HoneyQuestProgress, "|", "`n"))

MainGui.Add("Text", "x8 y184 +BackgroundTrans", "Gather Limit:")
MainGui.Add("Text", "x+4 y183 w36 h16 0x201 +Center")
(GuiCtrl := MainGui.Add("UpDown", "Range1-999 vQuestGatherMins Disabled", QuestGatherMins)).Section := "Quests", GuiCtrl.OnEvent("Change", nm_saveConfig)
MainGui.Add("Text", "x+4 y184 +BackgroundTrans", "Mins")
MainGui.Add("Text", "x8 y201 +BackgroundTrans", "To Hive By:")
MainGui.Add("Text", "x+18 yp w34 vQuestGatherReturnBy +Center +BackgroundTrans", QuestGatherReturnBy)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vQGRBLeft Disabled", "<").OnEvent("Click", nm_QuestGatherReturnBy)
MainGui.Add("Button", "xp+45 yp w12 h16 vQGRBRight Disabled", ">").OnEvent("Click", nm_QuestGatherReturnBy)
(GuiCtrl := MainGui.Add("CheckBox", "x8 yp+18 vQuestBoostCheck Disabled Checked" QuestBoostCheck, "Use Boost Tab for Quests")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("CheckBox", "x240 y23 vBlackQuestCheck Disabled Checked" BlackQuestCheck, "Enable").OnEvent("Click", nm_BlackQuestCheck)
MainGui.Add("Text", "x163 y38 w158 h92 vBlackQuestProgress", StrReplace(BlackQuestProgress, "|", "`n"))

(GuiCtrl := MainGui.Add("CheckBox", "x240 y131 vBrownQuestCheck Disabled Checked" BrownQuestCheck, "Enable")).Section := "Quests", GuiCtrl.OnEvent("Click", nm_saveConfig)
MainGui.Add("Text", "x163 y146 w158 h92 vBrownQuestProgress", StrReplace(BrownQuestProgress, "|", "`n"))

MainGui.Add("CheckBox", "x410 y23 vBuckoQuestCheck Disabled Checked" BuckoQuestCheck, "Enable").OnEvent("Click", nm_BuckoQuestCheck)
MainGui.Add("CheckBox", "x340 y37 vBuckoQuestGatherInterruptCheck Disabled Checked" BuckoQuestGatherInterruptCheck, "Allow Gather Interrupt").OnEvent("Click", nm_BuckoQuestCheck)
MainGui.Add("Text", "x333 y51 w158 h78 vBuckoQuestProgress", StrReplace(BuckoQuestProgress, "|", "`n"))

MainGui.Add("CheckBox", "x410 y131 vRileyQuestCheck Disabled Checked" RileyQuestCheck, "Enable").OnEvent("Click", nm_RileyQuestCheck)
MainGui.Add("CheckBox", "x340 y145 vRileyQuestGatherInterruptCheck Disabled Checked" RileyQuestGatherInterruptCheck, "Allow Gather Interrupt").OnEvent("Click", nm_RileyQuestCheck)
MainGui.Add("Text", "x333 y159 w158 h78 vRileyQuestProgress", StrReplace(RileyQuestProgress, "|", "`n"))

MainGui.SetFont("w700")
MainGui.SetFont("s8 cDefault Norm", "Tahoma")

;PLANTERS TAB
;------------------------
TabCtrl.UseTab("Planters")
MainGui.Add("Slider", "x364 y24 w130 h19 vPlanterMode Range0-2 AltSubmit Thick16 TickInterval1 Page1 Disabled", PlanterMode).OnEvent("Change", ba_PlanterSwitch)
MainGui.Add("Text", "x366 y43 h20 cRed +Center +BackgroundTrans", "OFF")
MainGui.Add("Text", "x410 y43 h20 c0xFF9200 +Center +BackgroundTrans", "MANUAL")
MainGui.Add("Text", "x478 y43 h20 cGreen +Center +BackgroundTrans", "+")

;Planters+
hidden := ((PlanterMode = 2) ? "" : " Hidden")

MainGui.Add("Text", "x23 y27 w40 h20 +BackgroundTrans vTextPresets" hidden, "Presets:")
MainGui.Add("Text", "x+14 yp w40 vNPreset +Center +BackgroundTrans" hidden, NPreset)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNPLeft Disabled" hidden, "<").OnEvent("Click", nm_NectarPreset)
MainGui.Add("Button", "xp+51 yp w12 h16 vNPRight Disabled" hidden, ">").OnEvent("Click", nm_NectarPreset)

MainGui.Add("Text", "x18 y47 w80 h20 +center +BackgroundTrans vTextNP" hidden, "Nectar Priority")
MainGui.Add("Text", "x104 y47 w47 h30 +center +BackgroundTrans vTextMin" hidden, "Min %")
MainGui.Add("Text", "x10 y62 w137 h1 0x7 vTextLine1" hidden)
MainGui.Add("Text", "x10 y70 +BackgroundTrans vText1" hidden, 1)
MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText2" hidden, 2)
MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText3" hidden, 3)
MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText4" hidden, 4)
MainGui.Add("Text", "x10 yp+20 +BackgroundTrans vText5" hidden, 5)

MainGui.Add("Text", "x32 y70 w64 vN1priority +Center +BackgroundTrans Section" hidden, N1priority)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP1Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Button", "xp+75 yp w12 h16 vNP1Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Text", "xs ys+20 w64 vN2priority +Center +BackgroundTrans" hidden, N2priority)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP2Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Button", "xp+75 yp w12 h16 vNP2Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Text", "xs ys+40 w64 vN3priority +Center +BackgroundTrans" hidden, N3priority)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP3Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Button", "xp+75 yp w12 h16 vNP3Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Text", "xs ys+60 w64 vN4priority +Center +BackgroundTrans" hidden, N4priority)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP4Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Button", "xp+75 yp w12 h16 vNP4Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Text", "xs ys+80 w64 vN5priority +Center +BackgroundTrans" hidden, N5priority)
MainGui.Add("Button", "xp-12 yp-1 w12 h16 vNP5Left Disabled" hidden, "<").OnEvent("Click", nm_NectarPriority)
MainGui.Add("Button", "xp+75 yp w12 h16 vNP5Right Disabled" hidden, ">").OnEvent("Click", nm_NectarPriority)

MainGui.Add("Text", "x113 y70 w12 vN1minPercent +Center Section" hidden, N1minPercent)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN1minPercentUpDown Disabled" hidden, N1minPercent//10).OnEvent("Change", nm_NectarMinPercent)
MainGui.Add("Text", "xs ys+20 w12 vN2minPercent +Center" hidden, N2minPercent)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN2minPercentUpDown Disabled" hidden, N2minPercent//10).OnEvent("Change", nm_NectarMinPercent)
MainGui.Add("Text", "xs ys+40 w12 vN3minPercent +Center" hidden, N3minPercent)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN3minPercentUpDown Disabled" hidden, N3minPercent//10).OnEvent("Change", nm_NectarMinPercent)
MainGui.Add("Text", "xs ys+60 w12 vN4minPercent +Center" hidden, N4minPercent)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN4minPercentUpDown Disabled" hidden, N4minPercent//10).OnEvent("Change", nm_NectarMinPercent)
MainGui.Add("Text", "xs ys+80 w12 vN5minPercent +Center" hidden, N5minPercent)
MainGui.Add("UpDown", "xp+14 yp-1 h16 -16 Range1-9 vN5minPercentUpDown Disabled" hidden, N5minPercent//10).OnEvent("Change", nm_NectarMinPercent)

MainGui.Add("Text", "x10 y171 w137 h1 0x7 vTextLine2" hidden)
MainGui.Add("Text", "x5 y178 w70 h20 +right +BackgroundTrans vTextHarvest" hidden, "Harvest Every")
MainGui.Add("CheckBox", "x103 y194 w40 vAutomaticHarvestInterval Disabled Checked" AutomaticHarvestInterval hidden, "Auto").OnEvent("Click", ba_AutoHarvestSwitch_)
MainGui.Add("CheckBox", "x28 y194 vHarvestFullGrown Disabled Checked" HarvestFullGrown hidden, "Full Grown").OnEvent("Click", ba_HarvestFullGrownSwitch_)
MainGui.Add("CheckBox", "x2 y211 w150 h13 vgotoPlanterField Disabled Checked" gotoPlanterField hidden, "Only Gather in Planter Field").OnEvent("Click", ba_gotoPlanterFieldSwitch_)
MainGui.Add("CheckBox", "x2 y224 w150 h13 vgatherFieldSipping Disabled Checked" gatherFieldSipping hidden, "Gather Field Nectar Sipping").OnEvent("Click", ba_gatherFieldSippingSwitch_)
MainGui.Add("Text", "x80 y178 w32 h20 cRed vAutoText +BackgroundTrans" (((PlanterMode = 2) && AutomaticHarvestInterval) ? "" : " Hidden"), "[Auto]")
MainGui.Add("Text", "x80 y178 w32 h20 cRed vFullText +BackgroundTrans" (((PlanterMode = 2) && HarvestFullGrown) ? "" : " Hidden"), "[Full]")
GuiCtrl := MainGui.Add("Edit", "x80 y174 w32 h20 limit2 Number vHarvestInterval Disabled" (((PlanterMode = 2) && !HarvestFullGrown && !AutomaticHarvestInterval) ? "" : " Hidden"), ValidateNumber(&HarvestInterval, 2))
GuiCtrl.OnEvent("Change", ba_harvestInterval)
MainGui.Add("Text", "x115 y178 w70 h20 +BackgroundTrans vTextHours" hidden, "Hours")
MainGui.Add("Text", "x10 y209 w137 h1 0x7 vTextLine3" hidden)
MainGui.Add("Button", "x261 y24 w96 h18 -Wrap vTimersButton Disabled" hidden, " Show Timers (" TimersHotkey ")").OnEvent("Click", ba_showPlanterTimers)
MainGui.Add("Text", "x147 y28 w1 h182 0x7 vTextLine4" hidden)
MainGui.Add("Text", "x147 y27 w108 h20 +Center +BackgroundTrans vTextAllowedPlanters" hidden, "Allowed Planters")
MainGui.Add("Text", "x255 y43 w100 h20 +Center +BackgroundTrans vTextAllowedFields" hidden, "Allowed Fields")
MainGui.Add("Text", "x147 y42 w108 h1 0x7 vTextLine5" hidden)

(GuiCtrl := MainGui.Add("CheckBox", "x152 y45 vPlasticPlanterCheck Disabled Checked" PlasticPlanterCheck hidden, "Plastic")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vCandyPlanterCheck Disabled Checked" CandyPlanterCheck hidden, "Candy")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vBlueClayPlanterCheck Disabled Checked" BlueClayPlanterCheck hidden, "Blue Clay")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vRedClayPlanterCheck Disabled Checked" RedClayPlanterCheck hidden, "Red Clay")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vTackyPlanterCheck Disabled Checked" TackyPlanterCheck hidden, "Tacky")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPesticidePlanterCheck Disabled Checked" PesticidePlanterCheck hidden, "Pesticide")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vHeatTreatedPlanterCheck Disabled Checked" HeatTreatedPlanterCheck hidden, "Heat-Treated")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vHydroponicPlanterCheck Disabled Checked" HydroponicPlanterCheck hidden, "Hydroponic")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPetalPlanterCheck Disabled Checked" PetalPlanterCheck hidden, "Petal")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 w100 h13 vPlanterOfPlentyCheck Disabled Checked" PlanterOfPlentyCheck hidden, "Planter of Plenty")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vPaperPlanterCheck Disabled Checked" PaperPlanterCheck hidden, "Paper")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp yp+14 vTicketPlanterCheck Disabled Checked" TicketPlanterCheck hidden, "Ticket")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("Text", "x155 y217 w80 h20 +BackgroundTrans vTextMax" hidden, "Max Planters")
MainGui.Add("Text", "x222 y217 w24 vMaxAllowedPlantersText" hidden)
MainGui.Add("UpDown", "vMaxAllowedPlanters Range0-3 Disabled" hidden, MaxAllowedPlanters).OnEvent("Change", ba_maxAllowedPlantersSwitch)
MainGui.Add("Text", "x255 y28 w1 h204 0x7 vTextLine6" hidden)
MainGui.Add("Text", "x255 y58 w240 h1 0x7 vTextLine7" hidden)

MainGui.SetFont("s7")
MainGui.Add("Text", "x250 y61 w100 h20 +Center +BackgroundTrans vTextZone1" hidden, "-- starting zone --")
MainGui.Add("Text", "x250 y142 w100 h20 +Center +BackgroundTrans vTextZone2" hidden, "-- 5 bee zone --")
MainGui.Add("Text", "x250 y195 w100 h20 +Center +BackgroundTrans vTextZone3" hidden, "-- 10 bee zone --")
MainGui.Add("Text", "x375 y61 w100 h20 +Center +BackgroundTrans vTextZone4" hidden, "-- 15 bee zone --")
MainGui.Add("Text", "x375 y128 w100 h20 +Center +BackgroundTrans vTextZone5" hidden, "-- 25 bee zone --")
MainGui.Add("Text", "x375 y153 w100 h20 +Center +BackgroundTrans vTextZone6" hidden, "-- 35 bee zone --")

MainGui.SetFont("s8 cDefault Norm", "Tahoma")
(GuiCtrl := MainGui.Add("CheckBox", "x258 y72 vDandelionFieldCheck Disabled Checked" DandelionFieldCheck hidden, "Dandelion (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y86 vSunflowerFieldCheck Disabled Checked" SunflowerFieldCheck hidden, "Sunflower (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y100 vMushroomFieldCheck Disabled Checked" MushroomFieldCheck hidden, "Mushroom (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y114 vBlueFlowerFieldCheck Disabled Checked" BlueFlowerFieldCheck hidden, "Blue Flower (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y128 vCloverFieldCheck Disabled Checked" CloverFieldCheck hidden, "Clover (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y153 vSpiderFieldCheck Disabled Checked" SpiderFieldCheck hidden, "Spider (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y167 vStrawberryFieldCheck Disabled Checked" StrawberryFieldCheck hidden, "Strawberry (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y181 vBambooFieldCheck Disabled Checked" BambooFieldCheck hidden, "Bamboo (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y206 w93 h13 vPineappleFieldCheck Disabled Checked" PineappleFieldCheck hidden, "Pineapple (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y220 vStumpFieldCheck Disabled Checked" StumpFieldCheck hidden, "Stump (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp+122 y72 vCactusFieldCheck Disabled Checked" CactusFieldCheck hidden, "Cactus (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y86 vPumpkinFieldCheck Disabled Checked" PumpkinFieldCheck hidden, "Pumpkin (SAT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y100 vPineTreeFieldCheck Disabled Checked" PineTreeFieldCheck hidden, "Pine Tree (COM)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y114 vRoseFieldCheck Disabled Checked" RoseFieldCheck hidden, "Rose (MOT)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y139 vMountainTopFieldCheck Disabled Checked" MountainTopFieldCheck hidden, "Mountain Top (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y164 vCoconutFieldCheck Disabled Checked" CoconutFieldCheck hidden, "Coconut (REF)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "xp y178 vPepperFieldCheck Disabled Checked" PepperFieldCheck hidden, "Pepper (INV)")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)

MainGui.Add("Text", "x354 y196 w144 h36 0x7 vTextBox1" hidden)
(GuiCtrl := MainGui.Add("CheckBox", "x358 y200 w138 h13 vConvertFullBagHarvest Disabled Checked" ConvertFullBagHarvest hidden, "Convert Full Bag Harvest")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
(GuiCtrl := MainGui.Add("CheckBox", "x358 y216 w138 h13 vGatherPlanterLoot Disabled Checked" GatherPlanterLoot hidden, "Gather Planter Loot")).Section := "Planters", GuiCtrl.OnEvent("Click", nm_saveConfig)
SetLoadingProgress(38)

;Manual Planters
MPlanterList := ["", "Plastic", "Candy", "Blue Clay", "Red Clay", "Tacky", "Pesticide", "Heat Treated", "Hydroponic", "Petal", "Planter of Plenty", "Paper", "Ticket"]
(MFieldList := [""]).Push(fieldnamelist*)
hidden := ((PlanterMode = 1) ? "" : " Hidden")

; Headers
MainGui.Add("Text", "x67 y23 w92 +BackgroundTrans +Center vMHeader1Text" hidden, "Cycle #1")
MainGui.Add("Text", "xp+96 yp wp +BackgroundTrans +Center vMHeader2Text" hidden, "Cycle #2")
MainGui.Add("Text", "xp+96 yp wp +BackgroundTrans +Center vMHeader3Text" hidden, "Cycle #3")

Loop 3 {
	i := A_Index
	MainGui.Add("Text", ((i = 1) ? "x5 y40" : "xs ys+29") " +Center Section vMSlot" i "PlanterText" hidden, "S" i " Planters:")
	Loop 9 {
		hiddenPlanter := (((PlanterMode == 1) && (A_Index < 4)) ? "" : " Hidden")
		(GuiCtrl := MainGui.Add("DropDownList", "x" (x := (Mod(A_Index, 3) = 1) ? "s+62" : "p+50") " ys-3 w92 vMSlot" i "Cycle" A_Index "Planter Disabled" hiddenPlanter, MPlanterList)).OnEvent("Change", mp_SaveConfig)
		if MSlot%i%Cycle%A_Index%Planter
			GuiCtrl.Text := MSlot%i%Cycle%A_Index%Planter
		x := (x = "p+50") ? "p" : x
		(GuiCtrl := MainGui.Add("DropDownList", "x" x " ys+17 w92 vMSlot" i "Cycle" A_Index "Field Disabled" hiddenPlanter, MFieldList)).OnEvent("Change", mp_SaveConfig)
		if MSlot%i%Cycle%A_Index%Field
			GuiCtrl.Text := MSlot%i%Cycle%A_Index%Field
		MainGui.Add("CheckBox", "x" x " ys+41 w46 vMSlot" i "Cycle" A_Index "Glitter Disabled" hiddenPlanter " Checked" MSlot%i%Cycle%A_Index%Glitter, "Glitter").OnEvent("Click", mp_SaveConfig)
		x := (Mod(A_Index, 3) = 1) ? "s+108" : "p+46"
		(GuiCtrl := MainGui.Add("DropDownList", "x" x " ys+38 w46 vMSlot" i "Cycle" A_Index "AutoFull Disabled" hiddenPlanter, ["Full", "Timed"])).OnEvent("Change", mp_SaveConfig)
		GuiCtrl.Text := MSlot%i%Cycle%A_Index%AutoFull
		SetLoadingProgress(17.25+i*20.25+A_Index*2.25)
	}
	MainGui.Add("Text", "xs ys+20 +Center Section vMSlot" i "FieldText" hidden, "S" i " Fields:")
	MainGui.Add("Text", "xs ys+20 +Center Section vMSlot" i "SettingsText" hidden, "S" i " Settings:")
	if (i < 3)
		MainGui.Add("Text", "xs ys+22 w350 h1 0x7 vMSlot" i "SeparatorLine" hidden)
}

; page movement
MainGui.Add("Text", "x360 y63 vMPageNumberText" hidden, "Page " (MPageIndex := 1))
MainGui.Add("Button", "xp+36 y63 w11 h14 vMPageLeft Disabled" hidden, "<").OnEvent("Click", mp_UpdatePage)
MainGui.Add("Button", "xp+13 y63 w11 h14 vMPageRight Disabled" hidden, ">").OnEvent("Click", mp_UpdatePage)
MainGui.Add("Text", "x360 y80 h1 w60 0x7 vMPagesSeparatorLine" hidden)


MainGui.Add("Text", "x371 y82 +BackgroundTrans Section +center vMCurrentCycle" hidden, "Current`nCycle:")
Loop 3 {
	MainGui.Add("Text", ((A_Index = 1) ? "x428 y63" : "x428 ys+16") " w200 +BackgroundTrans Section vMSlot" A_Index "CycleText" hidden, "Slot " A_Index ": ")
	MainGui.Add("Text", ((A_Index = 1) ? "x476 y63" : "x476 ys") " w200 +BackgroundTrans Section vMSlot" A_Index "CycleNo" hidden, PlanterManualCycle%A_Index%)
	MainGui.Add("Button", "x462 ys w11 h14 +Center vMSlot" A_Index "Left Disabled" hidden, "<").OnEvent("Click", mp_Slot%A_Index%ChangeLeft)
	MainGui.Add("Button", "x484 ys w11 h14 +Center vMSlot" A_Index "Right Disabled" hidden, ">").OnEvent("Click", mp_Slot%A_Index%ChangeRight)
}

MainGui.Add("Text", "x355 y23 h215 w1 0x7 vMSectionSeparatorLine" hidden)
MainGui.Add("Text", "x355 y58 h1 w150 0x7 vMSliderSeparatorLine" hidden)

; disable automatic harvest
MainGui.Add("Text", "x355 y112 h1 w150 0x7 Section vMPuffModeSeparatorLine" hidden)
MainGui.Add("CheckBox", "xs+5 ys+4 w150 h16 vMPuffModeA Section Disabled Checked" MPuffModeA hidden, "Disable Auto-Harvest").OnEvent("Click", mp_MPuffMode)
MainGui.Add("Text", "xs+16 ys+16 vMPuffModeText " hidden, "Slots:")
MainGui.Add("CheckBox", "xs+46 yp-1 w24 h16 vMPuffMode1 Disabled Checked" MPuffMode1 hidden, 1).OnEvent("Click", mp_SaveConfig)
MainGui.Add("CheckBox", "xs+70 yp w24 h16 vMPuffMode2 Disabled Checked" MPuffMode2 hidden, 2).OnEvent("Click", mp_SaveConfig)
MainGui.Add("CheckBox", "xs+95 yp w24 h16 vMPuffMode3 Disabled Checked" MPuffMode3 hidden, 3).OnEvent("Click", mp_SaveConfig)
MainGui.Add("Button", "x484 yp+1 w11 h14 vMPuffModeHelp Disabled" hidden, "?").OnEvent("Click", nm_MPuffModeHelp)

; gather in planter field and slots
MainGui.Add("Text", "x355 y149 h1 w156 0x7 Section vMGatherSeparatorLine" hidden)
MainGui.Add("CheckBox", "xs+5 ys+4 w150 h16 vMPlanterGatherA Section Disabled Checked" MPlanterGatherA hidden, "Gather in Planter Fields").OnEvent("Click", mp_MPlanterGatherSwitch_)
MainGui.Add("Text", "xs+16 ys+16 vMPlanterGatherText " hidden, "Slots:")
MainGui.Add("CheckBox", "xs+46 yp-1 w24 h16 vMPlanterGather1 Disabled Checked" MPlanterGather1 hidden, 1).OnEvent("Click", mp_SaveConfig)
MainGui.Add("CheckBox", "xs+70 yp w24 h16 vMPlanterGather2 Disabled Checked" MPlanterGather2 hidden, 2).OnEvent("Click", mp_SaveConfig)
MainGui.Add("CheckBox", "xs+95 yp w24 h16 vMPlanterGather3 Disabled Checked" MPlanterGather3 hidden, 3).OnEvent("Click", mp_SaveConfig)
MainGui.Add("Button", "x484 yp+1 w11 h14 vMPlanterGatherHelp Disabled" hidden, "?").OnEvent("Click", nm_MPlanterGatherHelp)

; harvest every interval
MainGui.Add("Text", "x355 y186 h1 w150 0x7 Section vMHarvestSeparatorLine" hidden)
MainGui.Add("CheckBox", "x360 ys+4 w138 h13 vMConvertFullBagHarvest Disabled Checked" MConvertFullBagHarvest hidden, "Convert Full Bag Harvest").OnEvent("Click", mp_SaveConfig)
MainGui.Add("CheckBox", "x373 ys+19 w138 h13 vMGatherPlanterLoot Disabled Checked" MGatherPlanterLoot hidden, "Gather Planter Loot").OnEvent("Click", mp_SaveConfig)
MainGui.Add("Text", "xs+6 ys+34 vMHarvestText Section" hidden, "Harvest every")
MainGui.Add("Text", "xs+65 ys w48 vMHarvestInterval +Center +BackgroundTrans " hidden, MHarvestInterval)
MainGui.Add("Button", "x471 ys w11 h14 vMHILeft Disabled" hidden, "<").OnEvent("Click", nm_MHarvestInterval)
MainGui.Add("Button", "x484 ys w11 h14 vMHIRight Disabled" hidden, ">").OnEvent("Click", nm_MHarvestInterval)

SetLoadingProgress(99)

if (BuffDetectReset = 1)
	nm_AdvancedGUI()
SetLoadingProgress(100)

;unlock tabs
nm_LockTabs(0)
nm_setStatus("Startup", "UI")
TabCtrl.Focus()
MainGui.Title := "Natro Macro"
MainGui["StartButton"].Enabled := 1
MainGui["PauseButton"].Enabled := 1
MainGui["StopButton"].Enabled := 1

;enable hotkeys
try {
	Hotkey StartHotkey, start, "On"
	Hotkey PauseHotkey, nm_pause, "On"
	Hotkey AutoClickerHotkey, autoclicker, "On T2"
	Hotkey TimersHotkey, timers, "On"
}

SetTimer Background, 2000
if (A_Args.Has(1) && (A_Args[1] = 1))
	SetTimer start, -1000

return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUI FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;buttons
nm_StartButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		SetTimer start, -50
}
nm_PauseButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		return nm_pause()
}
nm_StopButton(GuiCtrl, *){
	MouseGetPos , , , &hCtrl, 2
	if (hCtrl = GuiCtrl.Hwnd)
		return stop()
}

;save GUI position (on exit)
nm_saveGUIPos(){
	global GuiX, GuiY
	wp := Buffer(44)
	DllCall("GetWindowPlacement", "UInt", MainGui.Hwnd, "Ptr", wp)
	x := NumGet(wp, 28, "Int"), y := NumGet(wp, 32, "Int")
	if (x > 0)
		try IniWrite x, "settings\nm_config.ini", "Settings", "GuiX"
	if (y > 0)
		try IniWrite y, "settings\nm_config.ini", "Settings", "GuiY"
}

;tab (un)lock
nm_LockTabs(lock:=1){
	static tabs := ["Gather","Collect","Boost","Quests","Planters","Status","Settings","Misc"]
	global bitmaps

	;controls outside tabs
	if (lock = 1)
	{
		MainGui["CurrentFieldUp"].Enabled := 0
		MainGui["CurrentFieldDown"].Enabled := 0
		try MainGui["SecretButton"].Enabled := 0

		pBM := Gdip_BitmapConvertGray(bitmaps["discordgui"]), hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		MainGui["ImageDiscordLink"].Value := "HBITMAP:*" hBM, MainGui["ImageDiscordLink"].OnEvent("Click", DiscordLink, 0)
		Gdip_DisposeImage(pBM), DllCall("DeleteObject", "Ptr", hBM)

		MainGui["ImageGitHubLink"].OnEvent("Click", GitHubRepoLink, 0)

		c := "Lock"
	}
	else
	{
		MainGui["CurrentFieldUp"].Enabled := 1
		MainGui["CurrentFieldDown"].Enabled := 1
		try MainGui["SecretButton"].Enabled := 1

		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["discordgui"])
		MainGui["ImageDiscordLink"].Value := "HBITMAP:*" hBM, MainGui["ImageDiscordLink"].OnEvent("Click", DiscordLink)
		DllCall("DeleteObject", "Ptr", hBM)

		MainGui["ImageGitHubLink"].OnEvent("Click", GitHubRepoLink)

		c := "UnLock"
	}

	for i,tab in tabs
		nm_Tab%tab%%c%()
}
nm_TabGatherLock(){
	global
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
	MainGui["FieldName1"].Enabled := 0
	MainGui["FieldPattern1"].Enabled := 0
	MainGui["FieldPatternSize1UpDown"].Enabled := 0
	MainGui["FieldPatternReps1"].Enabled := 0
	MainGui["FieldPatternShift1"].Enabled := 0
	MainGui["FieldPatternInvertFB1"].Enabled := 0
	MainGui["FieldPatternInvertLR1"].Enabled := 0
	MainGui["FieldUntilMins1"].Enabled := 0
	MainGui["FieldUntilPack1UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist1"].Enabled := 0
	MainGui["FieldRotateTimes1"].Enabled := 0
	MainGui["FieldDriftCheck1"].Enabled := 0
	MainGui["FRD1Left"].Enabled := 0
	MainGui["FRD1Right"].Enabled := 0
	MainGui["FRT1Left"].Enabled := 0
	MainGui["FRT1Right"].Enabled := 0
	MainGui["FSL1Left"].Enabled := 0
	MainGui["FSL1Right"].Enabled := 0
	MainGui["FDCHelp1"].Enabled := 0
	MainGui["CopyGather1"].Enabled := 0
	MainGui["PasteGather1"].Enabled := 0
	MainGui["SaveFieldDefault1"].Enabled := 0
	MainGui["SaveFieldDefault1"].Value := "HBITMAP:*" hBM
	MainGui["FieldName2"].Enabled := 0
	MainGui["FieldPattern2"].Enabled := 0
	MainGui["FieldPatternSize2UpDown"].Enabled := 0
	MainGui["FieldPatternReps2"].Enabled := 0
	MainGui["FieldPatternShift2"].Enabled := 0
	MainGui["FieldPatternInvertFB2"].Enabled := 0
	MainGui["FieldPatternInvertLR2"].Enabled := 0
	MainGui["FieldUntilMins2"].Enabled := 0
	MainGui["FieldUntilPack2UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist2"].Enabled := 0
	MainGui["FieldRotateTimes2"].Enabled := 0
	MainGui["FieldDriftCheck2"].Enabled := 0
	MainGui["FRD2Left"].Enabled := 0
	MainGui["FRD2Right"].Enabled := 0
	MainGui["FRT2Left"].Enabled := 0
	MainGui["FRT2Right"].Enabled := 0
	MainGui["FSL2Left"].Enabled := 0
	MainGui["FSL2Right"].Enabled := 0
	MainGui["FDCHelp2"].Enabled := 0
	MainGui["CopyGather2"].Enabled := 0
	MainGui["PasteGather2"].Enabled := 0
	MainGui["SaveFieldDefault2"].Enabled := 0
	MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
	MainGui["FieldName3"].Enabled := 0
	MainGui["FieldPattern3"].Enabled := 0
	MainGui["FieldPatternSize3UpDown"].Enabled := 0
	MainGui["FieldPatternReps3"].Enabled := 0
	MainGui["FieldPatternShift3"].Enabled := 0
	MainGui["FieldPatternInvertFB3"].Enabled := 0
	MainGui["FieldPatternInvertLR3"].Enabled := 0
	MainGui["FieldUntilMins3"].Enabled := 0
	MainGui["FieldUntilPack3UpDown"].Enabled := 0
	MainGui["FieldSprinklerDist3"].Enabled := 0
	MainGui["FieldRotateTimes3"].Enabled := 0
	MainGui["FieldDriftCheck3"].Enabled := 0
	MainGui["FRD3Left"].Enabled := 0
	MainGui["FRD3Right"].Enabled := 0
	MainGui["FRT3Left"].Enabled := 0
	MainGui["FRT3Right"].Enabled := 0
	MainGui["FSL3Left"].Enabled := 0
	MainGui["FSL3Right"].Enabled := 0
	MainGui["FDCHelp3"].Enabled := 0
	MainGui["CopyGather3"].Enabled := 0
	MainGui["PasteGather3"].Enabled := 0
	MainGui["SaveFieldDefault3"].Enabled := 0
	MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
}
nm_TabGatherUnLock(){
	global
	local hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
	MainGui["FieldName1"].Enabled := 1
	MainGui["FieldName2"].Enabled := 1
	MainGui["FieldPattern1"].Enabled := 1
	MainGui["FieldPatternSize1UpDown"].Enabled := 1
	MainGui["FieldPatternReps1"].Enabled := 1
	MainGui["FieldPatternShift1"].Enabled := 1
	MainGui["FieldPatternInvertFB1"].Enabled := 1
	MainGui["FieldPatternInvertLR1"].Enabled := 1
	MainGui["FieldUntilMins1"].Enabled := 1
	MainGui["FieldUntilPack1UpDown"].Enabled := 1
	MainGui["FieldSprinklerDist1"].Enabled := 1
	MainGui["FieldRotateTimes1"].Enabled := 1
	MainGui["FieldDriftCheck1"].Enabled := 1
	MainGui["FRD1Left"].Enabled := 1
	MainGui["FRD1Right"].Enabled := 1
	MainGui["FRT1Left"].Enabled := 1
	MainGui["FRT1Right"].Enabled := 1
	MainGui["FSL1Left"].Enabled := 1
	MainGui["FSL1Right"].Enabled := 1
	MainGui["FDCHelp1"].Enabled := 1
	MainGui["CopyGather1"].Enabled := 1
	MainGui["PasteGather1"].Enabled := 1
	MainGui["PasteGather2"].Enabled := 1
	MainGui["SaveFieldDefault1"].Enabled := 1
	MainGui["SaveFieldDefault1"].Value := "HBITMAP:*" hBM
	if(FieldName2!="none"){
		MainGui["FieldName3"].Enabled := 1
		MainGui["FieldPattern2"].Enabled := 1
		MainGui["FieldPatternSize2UpDown"].Enabled := 1
		MainGui["FieldPatternReps2"].Enabled := 1
		MainGui["FieldPatternShift2"].Enabled := 1
		MainGui["FieldPatternInvertFB2"].Enabled := 1
		MainGui["FieldPatternInvertLR2"].Enabled := 1
		MainGui["FieldUntilMins2"].Enabled := 1
		MainGui["FieldUntilPack2UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist2"].Enabled := 1
		MainGui["FieldRotateTimes2"].Enabled := 1
		MainGui["FieldDriftCheck2"].Enabled := 1
		MainGui["FRD2Left"].Enabled := 1
		MainGui["FRD2Right"].Enabled := 1
		MainGui["FRT2Left"].Enabled := 1
		MainGui["FRT2Right"].Enabled := 1
		MainGui["FSL2Left"].Enabled := 1
		MainGui["FSL2Right"].Enabled := 1
		MainGui["FDCHelp2"].Enabled := 1
		MainGui["CopyGather2"].Enabled := 1
		MainGui["PasteGather3"].Enabled := 1
		MainGui["SaveFieldDefault2"].Enabled := 1
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
	}
	if(FieldName3!="none"){
		MainGui["FieldPattern3"].Enabled := 1
		MainGui["FieldPatternSize3UpDown"].Enabled := 1
		MainGui["FieldPatternReps3"].Enabled := 1
		MainGui["FieldPatternShift3"].Enabled := 1
		MainGui["FieldPatternInvertFB3"].Enabled := 1
		MainGui["FieldPatternInvertLR3"].Enabled := 1
		MainGui["FieldUntilMins3"].Enabled := 1
		MainGui["FieldUntilPack3UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist3"].Enabled := 1
		MainGui["FieldRotateTimes3"].Enabled := 1
		MainGui["FieldDriftCheck3"].Enabled := 1
		MainGui["FRD3Left"].Enabled := 1
		MainGui["FRD3Right"].Enabled := 1
		MainGui["FRT3Left"].Enabled := 1
		MainGui["FRT3Right"].Enabled := 1
		MainGui["FSL3Left"].Enabled := 1
		MainGui["FSL3Right"].Enabled := 1
		MainGui["FDCHelp3"].Enabled := 1
		MainGui["CopyGather3"].Enabled := 1
		MainGui["SaveFieldDefault3"].Enabled := 1
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
	}
	DllCall("DeleteObject", "ptr", hBM)
}
nm_TabCollectLock(){
	global
	;collect
	MainGui["BlenderAddSlot"].Enabled := 0
	MainGui["BlenderAdd1"].Enabled := 0
	MainGui["BlenderAdd2"].Enabled := 0
	MainGui["BlenderAdd3"].Enabled := 0
	MainGui["BlenderAmount"].Enabled := 0
	MainGui["BlenderIndex"].Enabled := 0
	MainGui["BlenderIndexOption"].Enabled := 0
	MainGui["BlenderLeft"].Enabled := 0
	MainGui["BlenderRight"].Enabled := 0
	MainGui["ClockCheck"].Enabled := 0
	MainGui["MondoBuffCheck"].Enabled := 0
	MainGui["MondoSecs"].Enabled := 0
	MainGui["MLDLeft"].Enabled := 0
	MainGui["MLDRight"].Enabled := 0
	MainGui["MALeft"].Enabled := 0
	MainGui["MARight"].Enabled := 0
	MainGui["RoboPassCheck"].Enabled := 0
	MainGui["HoneystormCheck"].Enabled := 0
	MainGui["AntPassCheck"].Enabled := 0
	MainGui["AntPassBuyCheck"].Enabled := 0
	MainGui["APALeft"].Enabled := 0
	MainGui["APARight"].Enabled := 0
	MainGui["HoneyDisCheck"].Enabled := 0
	MainGui["TreatDisCheck"].Enabled := 0
	MainGui["BlueberryDisCheck"].Enabled := 0
	MainGui["StrawberryDisCheck"].Enabled := 0
	MainGui["CoconutDisCheck"].Enabled := 0
	MainGui["RoyalJellyDisCheck"].Enabled := 0
	MainGui["GlueDisCheck"].Enabled := 0
	MainGui["BeesmasGatherInterruptCheck"].Enabled := 0
	MainGui["StockingsCheck"].Enabled := 0
	MainGui["WreathCheck"].Enabled := 0
	MainGui["FeastCheck"].Enabled := 0
	MainGui["RBPDelevelCheck"].Enabled := 0
	MainGui["GingerbreadCheck"].Enabled := 0
	MainGui["SnowMachineCheck"].Enabled := 0
	MainGui["CandlesCheck"].Enabled := 0
	MainGui["WinterMemoryMatchCheck"].Enabled := 0
	MainGui["SamovarCheck"].Enabled := 0
	MainGui["LidArtCheck"].Enabled := 0
	MainGui["GummyBeaconCheck"].Enabled := 0
	MainGui["NormalMemoryMatchCheck"].Enabled := 0
	MainGui["MegaMemoryMatchCheck"].Enabled := 0
	MainGui["NightMemoryMatchCheck"].Enabled := 0
	MainGui["ExtremeMemoryMatchCheck"].Enabled := 0
	MainGui["MemoryMatchOptions"].Enabled := 0
	;kill
	MainGui["BugRunCheck"].Enabled := 0
	MainGui["MonsterRespawnTime"].Enabled := 0
	MainGui["MonsterRespawnTimeHelp"].Enabled := 0
	MainGui["BugrunInterruptCheck"].Enabled := 0
	MainGui["BugrunLadybugsCheck"].Enabled := 0
	MainGui["BugrunRhinoBeetlesCheck"].Enabled := 0
	MainGui["BugrunSpiderCheck"].Enabled := 0
	MainGui["BugrunMantisCheck"].Enabled := 0
	MainGui["BugrunScorpionsCheck"].Enabled := 0
	MainGui["BugrunWerewolfCheck"].Enabled := 0
	MainGui["BugrunLadybugsLoot"].Enabled := 0
	MainGui["BugrunRhinoBeetlesLoot"].Enabled := 0
	MainGui["BugrunSpiderLoot"].Enabled := 0
	MainGui["BugrunMantisLoot"].Enabled := 0
	MainGui["BugrunScorpionsLoot"].Enabled := 0
	MainGui["BugrunWerewolfLoot"].Enabled := 0
	MainGui["StingerCheck"].Enabled := 0
	MainGui["StingerDailyBonusCheck"].Enabled := 0
	MainGui["StingerCloverCheck"].Enabled := 0
	MainGui["StingerSpiderCheck"].Enabled := 0
	MainGui["StingerCactusCheck"].Enabled := 0
	MainGui["StingerRoseCheck"].Enabled := 0
	MainGui["StingerMountainTopCheck"].Enabled := 0
	MainGui["StingerPepperCheck"].Enabled := 0
	MainGui["TunnelBearCheck"].Enabled := 0
	MainGui["TunnelBearBabyCheck"].Enabled := 0
	MainGui["KingBeetleCheck"].Enabled := 0
	MainGui["KingBeetleBabyCheck"].Enabled := 0
	MainGui["KingBeetleAmuletMode"].Enabled := 0
	MainGui["CocoCrabCheck"].Enabled := 0
	MainGui["StumpSnailCheck"].Enabled := 0
	MainGui["ShellAmuletMode"].Enabled := 0
	MainGui["SnailHealthEdit"].Enabled := 0
	MainGui["SnailTimeUpDown"].Enabled := 0
	MainGui["CommandoCheck"].Enabled := 0
	MainGui["ChickLevel"].Enabled := 0
	MainGui["ChickHealthEdit"].Enabled := 0
	MainGui["ChickTimeUpDown"].Enabled := 0
	MainGui["BossConfigHelp"].Enabled := 0
}
nm_TabCollectUnLock(){
	global
	;collect
	MainGui["BlenderAddSlot"].Enabled := 1
	MainGui["BlenderAdd1"].Enabled := 1
	MainGui["BlenderAdd2"].Enabled := 1
	MainGui["BlenderAdd3"].Enabled := 1
	MainGui["BlenderAmount"].Enabled := 1
	MainGui["BlenderIndexOption"].Enabled := 1
	MainGui["BlenderIndex"].Enabled := 1
	MainGui["BlenderLeft"].Enabled := 1
	MainGui["BlenderRight"].Enabled := 1
	MainGui["ClockCheck"].Enabled := 1
	MainGui["MondoBuffCheck"].Enabled := 1
	MainGui["MondoSecs"].Enabled := 1
	MainGui["MLDLeft"].Enabled := 1
	MainGui["MLDRight"].Enabled := 1
	MainGui["MALeft"].Enabled := 1
	MainGui["MARight"].Enabled := 1
	MainGui["RoboPassCheck"].Enabled := 1
	MainGui["HoneystormCheck"].Enabled := 1
	MainGui["AntPassCheck"].Enabled := 1
	MainGui["AntPassBuyCheck"].Enabled := 1
	MainGui["APALeft"].Enabled := 1
	MainGui["APARight"].Enabled := 1
	MainGui["HoneyDisCheck"].Enabled := 1
	MainGui["TreatDisCheck"].Enabled := 1
	MainGui["BlueberryDisCheck"].Enabled := 1
	MainGui["StrawberryDisCheck"].Enabled := 1
	MainGui["CoconutDisCheck"].Enabled := 1
	MainGui["RoyalJellyDisCheck"].Enabled := 1
	MainGui["GlueDisCheck"].Enabled := 1
	if (beesmasActive = 1)
	{
		MainGui["BeesmasGatherInterruptCheck"].Enabled := 1
		MainGui["StockingsCheck"].Enabled := 1
		MainGui["WreathCheck"].Enabled := 1
		MainGui["FeastCheck"].Enabled := 1
		MainGui["RBPDelevelCheck"].Enabled := 1
		MainGui["GingerbreadCheck"].Enabled := 1
		MainGui["SnowMachineCheck"].Enabled := 1
		MainGui["CandlesCheck"].Enabled := 1
		MainGui["WinterMemoryMatchCheck"].Enabled := 1
		MainGui["SamovarCheck"].Enabled := 1
		MainGui["LidArtCheck"].Enabled := 1
		MainGui["GummyBeaconCheck"].Enabled := 1
	}
	MainGui["NormalMemoryMatchCheck"].Enabled := 1
	MainGui["MegaMemoryMatchCheck"].Enabled := 1
	MainGui["NightMemoryMatchCheck"].Enabled := 1
	MainGui["ExtremeMemoryMatchCheck"].Enabled := 1
	MainGui["MemoryMatchOptions"].Enabled := 1
	;kill
	MainGui["BugRunCheck"].Enabled := 1
	MainGui["MonsterRespawnTime"].Enabled := 1
	MainGui["MonsterRespawnTimeHelp"].Enabled := 1
	MainGui["BugrunInterruptCheck"].Enabled := 1
	MainGui["BugrunLadybugsCheck"].Enabled := 1
	MainGui["BugrunRhinoBeetlesCheck"].Enabled := 1
	MainGui["BugrunSpiderCheck"].Enabled := 1
	MainGui["BugrunMantisCheck"].Enabled := 1
	MainGui["BugrunScorpionsCheck"].Enabled := 1
	MainGui["BugrunWerewolfCheck"].Enabled := 1
	MainGui["BugrunLadybugsLoot"].Enabled := 1
	MainGui["BugrunRhinoBeetlesLoot"].Enabled := 1
	MainGui["BugrunSpiderLoot"].Enabled := 1
	MainGui["BugrunMantisLoot"].Enabled := 1
	MainGui["BugrunScorpionsLoot"].Enabled := 1
	MainGui["BugrunWerewolfLoot"].Enabled := 1
	MainGui["StingerCheck"].Enabled := 1
	if (StingerCheck = 1)
	{
		MainGui["StingerDailyBonusCheck"].Enabled := 1
		MainGui["StingerCloverCheck"].Enabled := 1
		MainGui["StingerSpiderCheck"].Enabled := 1
		MainGui["StingerCactusCheck"].Enabled := 1
		MainGui["StingerRoseCheck"].Enabled := 1
		MainGui["StingerMountainTopCheck"].Enabled := 1
		MainGui["StingerPepperCheck"].Enabled := 1
	}
	MainGui["TunnelBearCheck"].Enabled := 1
	MainGui["TunnelBearBabyCheck"].Enabled := 1
	MainGui["KingBeetleCheck"].Enabled := 1
	MainGui["KingBeetleBabyCheck"].Enabled := 1
	MainGui["KingBeetleAmuletMode"].Enabled := 1
	MainGui["CocoCrabCheck"].Enabled := 1
	MainGui["StumpSnailCheck"].Enabled := 1
	MainGui["ShellAmuletMode"].Enabled := 1
	MainGui["SnailHealthEdit"].Enabled := 1
	MainGui["SnailTimeUpDown"].Enabled := 1
	MainGui["CommandoCheck"].Enabled := 1
	MainGui["ChickLevel"].Enabled := 1
	MainGui["ChickHealthEdit"].Enabled := 1
	MainGui["ChickTimeUpDown"].Enabled := 1
	MainGui["BossConfigHelp"].Enabled := 1
}
nm_TabBoostLock(){
	global
	MainGui["ShrineAddSlot"].Enabled := 0
	MainGui["ShrineAdd1"].Enabled := 0
	MainGui["ShrineAdd2"].Enabled := 0
	MainGui["ShrineAmount"].Enabled := 0
	MainGui["ShrineIndex"].Enabled := 0
	MainGui["ShrineIndexOption"].Enabled := 0
	MainGui["ShrineLeft"].Enabled := 0
	MainGui["ShrineRight"].Enabled := 0
	MainGui["FB1Left"].Enabled := 0
	MainGui["FB1Right"].Enabled := 0
	MainGui["FB2Left"].Enabled := 0
	MainGui["FB2Right"].Enabled := 0
	MainGui["FB3Left"].Enabled := 0
	MainGui["FB3Right"].Enabled := 0
	MainGui["FieldBoosterMinsUpDown"].Enabled := 0
	MainGui["BoostChaserCheck"].Enabled := 0
	MainGui["AutoFieldBoostButton"].Enabled := 0
	MainGui["BoostedFieldSelectButton"].Enabled := 0
	MainGui["HotbarWhile2"].Enabled := 0
	MainGui["HotbarWhile3"].Enabled := 0
	MainGui["HotbarWhile4"].Enabled := 0
	MainGui["HotbarWhile5"].Enabled := 0
	MainGui["HotbarWhile6"].Enabled := 0
	MainGui["HotbarWhile7"].Enabled := 0
	MainGui["HotbarTime2"].Enabled := 0
	MainGui["HotbarTime3"].Enabled := 0
	MainGui["HotbarTime4"].Enabled := 0
	MainGui["HotbarTime5"].Enabled := 0
	MainGui["HotbarTime6"].Enabled := 0
	MainGui["HotbarTime7"].Enabled := 0
	MainGui["HotbarMax2"].Enabled := 0
	MainGui["HotbarMax3"].Enabled := 0
	MainGui["HotbarMax4"].Enabled := 0
	MainGui["HotbarMax5"].Enabled := 0
	MainGui["HotbarMax6"].Enabled := 0
	MainGui["HotbarMax7"].Enabled := 0
	MainGui["StickerStackCheck"].Enabled := 0
	MainGui["SSILeft"].Enabled := 0
	MainGui["SSIRight"].Enabled := 0
	MainGui["SSMLeft"].Enabled := 0
	MainGui["SSMRight"].Enabled := 0
	MainGui["StickerStackTimer"].Enabled := 0
	MainGui["StickerStackItemHelp"].Enabled := 0
	MainGui["StickerStackModeHelp"].Enabled := 0
	MainGui["StickerStackHive"].Enabled := 0
	MainGui["StickerStackCub"].Enabled := 0
	MainGui["StickerStackVoucher"].Enabled := 0
	MainGui["StickerStackSkinsHelp"].Enabled := 0
	MainGui["StickerPrinterCheck"].Enabled := 0
	MainGui["SPELeft"].Enabled := 0
	MainGui["SPERight"].Enabled := 0
}
nm_TabBoostUnLock(){
	global
	MainGui["ShrineAddSlot"].Enabled := 1
	MainGui["ShrineAdd1"].Enabled := 1
	MainGui["ShrineAdd2"].Enabled := 1
	MainGui["ShrineAmount"].Enabled := 1
	MainGui["ShrineIndexOption"].Enabled := 1
	MainGui["ShrineIndex"].Enabled := 1
	MainGui["ShrineLeft"].Enabled := 1
	MainGui["ShrineRight"].Enabled := 1
	MainGui["FB1Left"].Enabled := 1
	MainGui["FB1Right"].Enabled := 1
	nm_FieldBooster()
	MainGui["FieldBoosterMinsUpDown"].Enabled := 1
	MainGui["BoostChaserCheck"].Enabled := 1
	MainGui["AutoFieldBoostButton"].Enabled := 1
	MainGui["BoostedFieldSelectButton"].Enabled := 1
	MainGui["HotbarWhile2"].Enabled := 1
	MainGui["HotbarWhile3"].Enabled := 1
	MainGui["HotbarWhile4"].Enabled := 1
	MainGui["HotbarWhile5"].Enabled := 1
	MainGui["HotbarWhile6"].Enabled := 1
	MainGui["HotbarWhile7"].Enabled := 1
	MainGui["HotbarTime2"].Enabled := 1
	MainGui["HotbarTime3"].Enabled := 1
	MainGui["HotbarTime4"].Enabled := 1
	MainGui["HotbarTime5"].Enabled := 1
	MainGui["HotbarTime6"].Enabled := 1
	MainGui["HotbarTime7"].Enabled := 1
	MainGui["HotbarMax2"].Enabled := 1
	MainGui["HotbarMax3"].Enabled := 1
	MainGui["HotbarMax4"].Enabled := 1
	MainGui["HotbarMax5"].Enabled := 1
	MainGui["HotbarMax6"].Enabled := 1
	MainGui["HotbarMax7"].Enabled := 1
	MainGui["StickerStackCheck"].Enabled := 1
	if (StickerStackCheck = 1) {
		MainGui["SSILeft"].Enabled := 1
		MainGui["SSIRight"].Enabled := 1
		MainGui["SSMLeft"].Enabled := 1
		MainGui["SSMRight"].Enabled := 1
		MainGui["StickerStackTimer"].Enabled := 1
		MainGui["StickerStackItemHelp"].Enabled := 1
		MainGui["StickerStackModeHelp"].Enabled := 1
		MainGui["StickerStackSkinsHelp"].Enabled := 1
		if InStr(StickerStackItem, "Sticker") {
			MainGui["StickerStackHive"].Enabled := 1
			MainGui["StickerStackCub"].Enabled := 1
			MainGui["StickerStackVoucher"].Enabled := 1
		}
	}
	MainGui["StickerPrinterCheck"].Enabled := 1
	if (StickerPrinterCheck = 1) {
		MainGui["SPELeft"].Enabled := 1
		MainGui["SPERight"].Enabled := 1
	}
}
nm_TabQuestsLock(){
	global
	MainGui["PolarQuestCheck"].Enabled := 0
	MainGui["PolarQuestGatherInterruptCheck"].Enabled := 0
	MainGui["BuckoQuestCheck"].Enabled := 0
	MainGui["BuckoQuestGatherInterruptCheck"].Enabled := 0
	MainGui["RileyQuestCheck"].Enabled := 0
	MainGui["RileyQuestGatherInterruptCheck"].Enabled := 0
	MainGui["HoneyQuestCheck"].Enabled := 0
	MainGui["BlackQuestCheck"].Enabled := 0
	MainGui["BrownQuestCheck"].Enabled := 0
	MainGui["QuestGatherMins"].Enabled := 0
	MainGui["QuestBoostCheck"].Enabled := 0
	MainGui["QGRBLeft"].Enabled := 0
	MainGui["QGRBRight"].Enabled := 0
}
nm_TabQuestsUnLock(){
	global
	MainGui["PolarQuestCheck"].Enabled := 1
	MainGui["PolarQuestGatherInterruptCheck"].Enabled := 1
	MainGui["BuckoQuestCheck"].Enabled := 1
	MainGui["BuckoQuestGatherInterruptCheck"].Enabled := 1
	MainGui["RileyQuestCheck"].Enabled := 1
	MainGui["RileyQuestGatherInterruptCheck"].Enabled := 1
	MainGui["HoneyQuestCheck"].Enabled := 1
	MainGui["BlackQuestCheck"].Enabled := 1
	MainGui["BrownQuestCheck"].Enabled := 1
	MainGui["QuestGatherMins"].Enabled := 1
	MainGui["QuestBoostCheck"].Enabled := 1
	MainGui["QGRBLeft"].Enabled := 1
	MainGui["QGRBRight"].Enabled := 1
}
nm_TabPlantersLock(){
	global
	MainGui["PlanterMode"].Enabled := 0
	;planters+
	MainGui["TimersButton"].Enabled := 0
	MainGui["NPLeft"].Enabled := 0
	MainGui["NPRight"].Enabled := 0
	Loop 5 {
		MainGui["NP" A_Index "Left"].Enabled := 0
		MainGui["NP" A_Index "Right"].Enabled := 0
	}
	MainGui["N1MinPercentUpDown"].Enabled := 0
	MainGui["N2MinPercentUpDown"].Enabled := 0
	MainGui["N3MinPercentUpDown"].Enabled := 0
	MainGui["N4MinPercentUpDown"].Enabled := 0
	MainGui["N5MinPercentUpDown"].Enabled := 0
	MainGui["MaxAllowedPlanters"].Enabled := 0
	MainGui["AutomaticHarvestInterval"].Enabled := 0
	MainGui["HarvestFullGrown"].Enabled := 0
	MainGui["gotoPlanterField"].Enabled := 0
	MainGui["gatherFieldSipping"].Enabled := 0
	MainGui["ConvertFullBagHarvest"].Enabled := 0
	MainGui["GatherPlanterLoot"].Enabled := 0
	MainGui["HarvestInterval"].Enabled := 0
	MainGui["PlasticPlanterCheck"].Enabled := 0
	MainGui["CandyPlanterCheck"].Enabled := 0
	MainGui["BlueClayPlanterCheck"].Enabled := 0
	MainGui["RedClayPlanterCheck"].Enabled := 0
	MainGui["TackyPlanterCheck"].Enabled := 0
	MainGui["PesticidePlanterCheck"].Enabled := 0
	MainGui["HeatTreatedPlanterCheck"].Enabled := 0
	MainGui["HydroponicPlanterCheck"].Enabled := 0
	MainGui["PetalPlanterCheck"].Enabled := 0
	MainGui["PlanterOfPlentyCheck"].Enabled := 0
	MainGui["PaperPlanterCheck"].Enabled := 0
	MainGui["TicketPlanterCheck"].Enabled := 0
	MainGui["DandelionFieldCheck"].Enabled := 0
	MainGui["SunflowerFieldCheck"].Enabled := 0
	MainGui["MushroomFieldCheck"].Enabled := 0
	MainGui["BlueFlowerFieldCheck"].Enabled := 0
	MainGui["CloverFieldCheck"].Enabled := 0
	MainGui["SpiderFieldCheck"].Enabled := 0
	MainGui["StrawberryFieldCheck"].Enabled := 0
	MainGui["BambooFieldCheck"].Enabled := 0
	MainGui["PineappleFieldCheck"].Enabled := 0
	MainGui["StumpFieldCheck"].Enabled := 0
	MainGui["CactusFieldCheck"].Enabled := 0
	MainGui["PumpkinFieldCheck"].Enabled := 0
	MainGui["PineTreeFieldCheck"].Enabled := 0
	MainGui["RoseFieldCheck"].Enabled := 0
	MainGui["MountainTopFieldCheck"].Enabled := 0
	MainGui["CoconutFieldCheck"].Enabled := 0
	MainGui["PepperFieldCheck"].Enabled := 0
	;manual
	MainGui["MHILeft"].Enabled := 0
	MainGui["MHIRight"].Enabled := 0
	Static ManualPlantersControls := ["MPageLeft", "MPageRight", "MSlot1Left", "MSlot1Right", "MSlot2Left", "MSlot2Right", "MSlot3Left", "MSlot3Right"
	, "MPuffModeA", "MPuffMode1", "MPuffMode2", "MPuffMode3", "MPuffModeHelp", "MPlanterGatherA", "MPlanterGather1", "MPlanterGather2", "MPlanterGather3", "MPlanterGatherHelp", "MConvertFullBagHarvest", "MGatherPlanterLoot"
	, "MSlot1Cycle1Planter", "MSlot1Cycle2Planter", "MSlot1Cycle3Planter", "MSlot1Cycle4Planter", "MSlot1Cycle5Planter", "MSlot1Cycle6Planter", "MSlot1Cycle7Planter", "MSlot1Cycle8Planter", "MSlot1Cycle9Planter"
	, "MSlot1Cycle1Field", "MSlot1Cycle2Field", "MSlot1Cycle3Field", "MSlot1Cycle4Field", "MSlot1Cycle5Field", "MSlot1Cycle6Field", "MSlot1Cycle7Field", "MSlot1Cycle8Field", "MSlot1Cycle9Field"
	, "MSlot1Cycle1Glitter", "MSlot1Cycle2Glitter", "MSlot1Cycle3Glitter", "MSlot1Cycle4Glitter", "MSlot1Cycle5Glitter", "MSlot1Cycle6Glitter", "MSlot1Cycle7Glitter", "MSlot1Cycle8Glitter", "MSlot1Cycle9Glitter"
	, "MSlot1Cycle1AutoFull", "MSlot1Cycle2AutoFull", "MSlot1Cycle3AutoFull", "MSlot1Cycle4AutoFull", "MSlot1Cycle5AutoFull", "MSlot1Cycle6AutoFull", "MSlot1Cycle7AutoFull", "MSlot1Cycle8AutoFull", "MSlot1Cycle9AutoFull"
	, "MSlot2Cycle1Planter", "MSlot2Cycle2Planter", "MSlot2Cycle3Planter", "MSlot2Cycle4Planter", "MSlot2Cycle5Planter", "MSlot2Cycle6Planter", "MSlot2Cycle7Planter", "MSlot2Cycle8Planter", "MSlot2Cycle9Planter"
	, "MSlot2Cycle1Field", "MSlot2Cycle2Field", "MSlot2Cycle3Field", "MSlot2Cycle4Field", "MSlot2Cycle5Field", "MSlot2Cycle6Field", "MSlot2Cycle7Field", "MSlot2Cycle8Field", "MSlot2Cycle9Field"
	, "MSlot2Cycle1Glitter", "MSlot2Cycle2Glitter", "MSlot2Cycle3Glitter", "MSlot2Cycle4Glitter", "MSlot2Cycle5Glitter", "MSlot2Cycle6Glitter", "MSlot2Cycle7Glitter", "MSlot2Cycle8Glitter", "MSlot2Cycle9Glitter"
	, "MSlot2Cycle1AutoFull", "MSlot2Cycle2AutoFull", "MSlot2Cycle3AutoFull", "MSlot2Cycle4AutoFull", "MSlot2Cycle5AutoFull", "MSlot2Cycle6AutoFull", "MSlot2Cycle7AutoFull", "MSlot2Cycle8AutoFull", "MSlot2Cycle9AutoFull"
	, "MSlot3Cycle1Planter", "MSlot3Cycle2Planter", "MSlot3Cycle3Planter", "MSlot3Cycle4Planter", "MSlot3Cycle5Planter", "MSlot3Cycle6Planter", "MSlot3Cycle7Planter", "MSlot3Cycle8Planter", "MSlot3Cycle9Planter"
	, "MSlot3Cycle1Field", "MSlot3Cycle2Field", "MSlot3Cycle3Field", "MSlot3Cycle4Field", "MSlot3Cycle5Field", "MSlot3Cycle6Field", "MSlot3Cycle7Field", "MSlot3Cycle8Field", "MSlot3Cycle9Field"
	, "MSlot3Cycle1Glitter", "MSlot3Cycle2Glitter", "MSlot3Cycle3Glitter", "MSlot3Cycle4Glitter", "MSlot3Cycle5Glitter", "MSlot3Cycle6Glitter", "MSlot3Cycle7Glitter", "MSlot3Cycle8Glitter", "MSlot3Cycle9Glitter"
	, "MSlot3Cycle1AutoFull", "MSlot3Cycle2AutoFull", "MSlot3Cycle3AutoFull", "MSlot3Cycle4AutoFull", "MSlot3Cycle5AutoFull", "MSlot3Cycle6AutoFull", "MSlot3Cycle7AutoFull", "MSlot3Cycle8AutoFull", "MSlot3Cycle9AutoFull"]
	For v in ManualPlantersControls
		MainGui[v].Enabled := 0
}
nm_TabPlantersUnLock(){
	global
	MainGui["PlanterMode"].Enabled := 1
	;planters+
	MainGui["TimersButton"].Enabled := 1
	MainGui["NPLeft"].Enabled := 1
	MainGui["NPRight"].Enabled := 1
	MainGui["NP1Left"].Enabled := 1
	MainGui["NP1Right"].Enabled := 1
	nm_NectarPriority()
	MainGui["N1MinPercentUpDown"].Enabled := 1
	MainGui["N2MinPercentUpDown"].Enabled := 1
	MainGui["N3MinPercentUpDown"].Enabled := 1
	MainGui["N4MinPercentUpDown"].Enabled := 1
	MainGui["N5MinPercentUpDown"].Enabled := 1
	MainGui["MaxAllowedPlanters"].Enabled := 1
	MainGui["AutomaticHarvestInterval"].Enabled := 1
	MainGui["HarvestFullGrown"].Enabled := 1
	MainGui["gotoPlanterField"].Enabled := 1
	MainGui["gatherFieldSipping"].Enabled := 1
	MainGui["ConvertFullBagHarvest"].Enabled := 1
	MainGui["GatherPlanterLoot"].Enabled := 1
	MainGui["HarvestInterval"].Enabled := 1
	MainGui["PlasticPlanterCheck"].Enabled := 1
	MainGui["CandyPlanterCheck"].Enabled := 1
	MainGui["BlueClayPlanterCheck"].Enabled := 1
	MainGui["RedClayPlanterCheck"].Enabled := 1
	MainGui["TackyPlanterCheck"].Enabled := 1
	MainGui["PesticidePlanterCheck"].Enabled := 1
	MainGui["HeatTreatedPlanterCheck"].Enabled := 1
	MainGui["HydroponicPlanterCheck"].Enabled := 1
	MainGui["PetalPlanterCheck"].Enabled := 1
	MainGui["PlanterOfPlentyCheck"].Enabled := 1
	MainGui["PaperPlanterCheck"].Enabled := 1
	MainGui["TicketPlanterCheck"].Enabled := 1
	MainGui["DandelionFieldCheck"].Enabled := 1
	MainGui["SunflowerFieldCheck"].Enabled := 1
	MainGui["MushroomFieldCheck"].Enabled := 1
	MainGui["BlueFlowerFieldCheck"].Enabled := 1
	MainGui["CloverFieldCheck"].Enabled := 1
	MainGui["SpiderFieldCheck"].Enabled := 1
	MainGui["StrawberryFieldCheck"].Enabled := 1
	MainGui["BambooFieldCheck"].Enabled := 1
	MainGui["PineappleFieldCheck"].Enabled := 1
	MainGui["StumpFieldCheck"].Enabled := 1
	MainGui["CactusFieldCheck"].Enabled := 1
	MainGui["PumpkinFieldCheck"].Enabled := 1
	MainGui["PineTreeFieldCheck"].Enabled := 1
	MainGui["RoseFieldCheck"].Enabled := 1
	MainGui["MountainTopFieldCheck"].Enabled := 1
	MainGui["CoconutFieldCheck"].Enabled := 1
	MainGui["PepperFieldCheck"].Enabled := 1
	;manual
	MainGui["MHILeft"].Enabled := 1
	MainGui["MHIRight"].Enabled := 1
	MainGui["MSlot1Cycle1Planter"].Enabled := 1
	MainGui["MPuffModeA"].Enabled := 1
	MainGui["MPuffModeHelp"].Enabled := 1
	MainGui["MPlanterGatherA"].Enabled := 1
	MainGui["MPlanterGatherHelp"].Enabled := 1
	MainGui["MConvertFullBagHarvest"].Enabled := 1
	MainGui["MGatherPlanterLoot"].Enabled := 1
	mp_UpdatePage()
	mp_UpdateControls()
}
nm_TabStatusLock(){
	MainGui["StatusLogReverse"].Enabled := 0
	MainGui["ResetTotalStats"].Enabled := 0
	MainGui["WebhookGUI"].Enabled := 0
}
nm_TabStatusUnLock(){
	MainGui["StatusLogReverse"].Enabled := 1
	MainGui["ResetTotalStats"].Enabled := 1
	MainGui["WebhookGUI"].Enabled := 1
}
nm_TabSettingsLock(){
	global
	MainGui["GuiTheme"].Enabled := 0
	MainGui["GuiTransparencyUpDown"].Enabled := 0
	MainGui["AlwaysOnTop"].Enabled := 0
	MainGui["KeyDelay"].Enabled := 0
	MainGui["MoveSpeedNum"].Enabled := 0
	MainGui["RMLeft"].Enabled := 0
	MainGui["RMRight"].Enabled := 0
	MainGui["MMLeft"].Enabled := 0
	MainGui["MMRight"].Enabled := 0
	MainGui["STLeft"].Enabled := 0
	MainGui["STRight"].Enabled := 0
	MainGui["CBLeft"].Enabled := 0
	MainGui["CBRight"].Enabled := 0
	MainGui["MultiReset"].Enabled := 0
	MainGui["ConvertMins"].Enabled := 0
	MainGui["GatherDoubleReset"].Enabled := 0
	MainGui["DisableToolUse"].Enabled := 0
	MainGui["AnnounceGuidingStar"].Enabled := 0
	MainGui["NewWalk"].Enabled := 0
	MainGui["HiveSlot"].Enabled := 0
	MainGui["HiveBees"].Enabled := 0
	MainGui["HiveBeesHelp"].Enabled := 0
	MainGui["ConvertDelay"].Enabled := 0
	MainGui["PrivServer"].Enabled := 0
	MainGui["ReconnectMessage"].Enabled := 0
	MainGui["PublicFallback"].Enabled := 0
	MainGui["ResetFieldDefaultsButton"].Enabled := 0
	MainGui["ResetAllButton"].Enabled := 0
	MainGui["TestReconnectButton"].Enabled := 0
	MainGui["ReconnectMethodHelp"].Enabled := 0
	MainGui["ReconnectInterval"].Enabled := 0
	MainGui["ReconnectHour"].Enabled := 0
	MainGui["ReconnectMin"].Enabled := 0
	MainGui["ReconnectTimeHelp"].Enabled := 0
	MainGui["NatroSoBrokeHelp"].Enabled := 0
	MainGui["PublicFallbackHelp"].Enabled := 0
	MainGui["NewWalkHelp"].Enabled := 0
}
nm_TabSettingsUnLock(){
	global
	MainGui["GuiTheme"].Enabled := 1
	MainGui["GuiTransparencyUpDown"].Enabled := 1
	MainGui["AlwaysOnTop"].Enabled := 1
	MainGui["KeyDelay"].Enabled := 1
	MainGui["MoveSpeedNum"].Enabled := 1
	MainGui["RMLeft"].Enabled := 1
	MainGui["RMRight"].Enabled := 1
	MainGui["MMLeft"].Enabled := 1
	MainGui["MMRight"].Enabled := 1
	MainGui["STLeft"].Enabled := 1
	MainGui["STRight"].Enabled := 1
	MainGui["CBLeft"].Enabled := 1
	MainGui["CBRight"].Enabled := 1
	MainGui["MultiReset"].Enabled := 1
	if (ConvertBalloon="every")
		MainGui["ConvertMins"].Enabled := 1
	MainGui["GatherDoubleReset"].Enabled := 1
	MainGui["DisableToolUse"].Enabled := 1
	MainGui["AnnounceGuidingStar"].Enabled := 1
	MainGui["NewWalk"].Enabled := 1
	MainGui["HiveSlot"].Enabled := 1
	MainGui["HiveBees"].Enabled := 1
	MainGui["HiveBeesHelp"].Enabled := 1
	MainGui["ConvertDelay"].Enabled := 1
	MainGui["PrivServer"].Enabled := 1
	MainGui["ReconnectMessage"].Enabled := 1
	MainGui["PublicFallback"].Enabled := 1
	MainGui["ResetFieldDefaultsButton"].Enabled := 1
	MainGui["ResetAllButton"].Enabled := 1
	MainGui["TestReconnectButton"].Enabled := 1
	MainGui["ReconnectMethodHelp"].Enabled := 1
	MainGui["ReconnectInterval"].Enabled := 1
	MainGui["ReconnectHour"].Enabled := 1
	MainGui["ReconnectMin"].Enabled := 1
	MainGui["ReconnectTimeHelp"].Enabled := 1
	MainGui["NatroSoBrokeHelp"].Enabled := 1
	MainGui["PublicFallbackHelp"].Enabled := 1
	MainGui["NewWalkHelp"].Enabled := 1
}
nm_TabMiscLock(){
	MainGui["BasicEggHatcherButton"].Enabled := 0
	MainGui["BitterberryFeederButton"].Enabled := 0
	MainGui["GenerateBeeListButton"].Enabled := 0
	MainGui["TicketShopCalculatorButton"].Enabled := 0
	MainGui["SSACalculatorButton"].Enabled := 0
	MainGui["BondCalculatorButton"].Enabled := 0
	MainGui["AutoClickerGUI"].Enabled := 0
	MainGui["HotkeyGUI"].Enabled := 0
	MainGui["DebugLogGUI"].Enabled := 0
	MainGui["AutoStartManagerGUI"].Enabled := 0
	MainGui["NightAnnouncementGUI"].Enabled := 0
	MainGui["ReportBugButton"].Enabled := 0
	MainGui["MakeSuggestionButton"].Enabled := 0
	MainGui["AutoMutatorButton"].Enabled := 0
}
nm_TabMiscUnLock(){
	MainGui["BasicEggHatcherButton"].Enabled := 1
	MainGui["BitterberryFeederButton"].Enabled := 1
	MainGui["GenerateBeeListButton"].Enabled := 1
	MainGui["TicketShopCalculatorButton"].Enabled := 1
	MainGui["SSACalculatorButton"].Enabled := 1
	MainGui["BondCalculatorButton"].Enabled := 1
	MainGui["AutoClickerGUI"].Enabled := 1
	MainGui["HotkeyGUI"].Enabled := 1
	MainGui["DebugLogGUI"].Enabled := 1
	MainGui["AutoStartManagerGUI"].Enabled := 1
	MainGui["NightAnnouncementGUI"].Enabled := 1
	MainGui["ReportBugButton"].Enabled := 1
	MainGui["MakeSuggestionButton"].Enabled := 1
	MainGui["AutoMutatorButton"].Enabled := 1
}

;update config
nm_saveConfig(GuiCtrl, *){
	global
	switch GuiCtrl.Type, 0 {
		case "DDL":
		%GuiCtrl.Name% := GuiCtrl.Text
		default: ; "CheckBox", "Edit", "UpDown", "Slider"
		%GuiCtrl.Name% := GuiCtrl.Value
	}
	IniWrite %GuiCtrl.Name%, "settings\nm_config.ini", GuiCtrl.Section, GuiCtrl.Name
}

;link buttons
DiscordLink(*){
	nm_RunDiscord("invite/xbkXjwWh8U")
}
GitHubRepoLink(*){
	Run "https://github.com/NatroTeam/NatroMacro"
}
GitHubReleaseLink(*){
	Run "https://github.com/NatroTeam/NatroMacro/releases"
}
nm_RunDiscord(path){
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","discord", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""
	, appenabled := (StrLen(exe) > 0)

	Run appenabled ? ('"' exe '" ' StrReplace(params, "%1", "discord://-/" path)) : ('"https://discord.com/' path '"')
}

;(used to update GUI with info fetched from GitHub)
AsyncHttpRequest(method, url, func?, headers?)
{
	req := ComObject("Msxml2.XMLHTTP")
	req.open(method, url, true)
	if IsSet(headers)
		for h, v in headers
			req.setRequestHeader(h, v)
	IsSet(func) && (req.onreadystatechange := func.Bind(req))
	req.send()
}

;current field up/down
nm_currentFieldUp(*){
	global CurrentField, CurrentFieldNum
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
	MainGui["CurrentField"].Text := CurrentField
	IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
}
nm_currentFieldDown(*){
	global CurrentField, CurrentFieldNum
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
	MainGui["CurrentField"].Text := CurrentField
	IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
}

;error balloon tip (used to show info on incorrect inputs)
nm_ShowErrorBalloonTip(Ctrl, Title, Text){
	EBT := Buffer(4 * A_PtrSize, 0)
	NumPut("UInt", 4 * A_PtrSize
		, "Ptr", StrPtr(Title)
		, "Ptr", StrPtr(Text)
		, "UInt", 3, EBT)
	DllCall("SendMessage", "UPtr", Ctrl.Hwnd, "UInt", 0x1503, "Ptr", 0, "Ptr", EBT.Ptr, "Ptr")
}

;text control positioning functions
CenterText(Text1, Text2, Font, w:=260)
{
	w1 := TextExtent(Text1.Text, Font), w2 := TextExtent(Text2.Text, Font)
	Text1.Move(x1 := (w - w1 - w2)//2, , w1), Text2.Move(x1 + w1, , w2)
	Text1.Redraw(), Text2.Redraw()
}
TextExtent(text, textCtrl)
{
	hDC := DllCall("GetDC", "Ptr", textCtrl.Hwnd, "Ptr")
	hFold := DllCall("SelectObject", "Ptr", hDC, "Ptr", SendMessage(0x31, , , textCtrl), "Ptr")
	nSize := Buffer(8)
	DllCall("GetTextExtentPoint32", "Ptr", hDC, "Str", text, "Int", StrLen(text), "Ptr", nSize)
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hFold)
	DllCall("ReleaseDC", "Ptr", textCtrl.Hwnd, "Ptr", hDC)
	return NumGet(nSize, 0, "UInt")
}

;miscellaneous functions
ValidateNumber(&var, default := 0) => IsNumber(var) ? var : (var := default)
ValidateInt(&var, default := 0) => IsInteger(var) ? var : (var := default)

; GATHER TAB
; ------------------------
nm_FieldSelect1(GuiCtrl?, *){
	global FieldName1, CurrentFieldNum, CurrentField
	if IsSet(GuiCtrl) {
		FieldName1 := MainGui["FieldName1"].Text
		nm_FieldDefaults(1)
		IniWrite FieldName1, "settings\nm_config.ini", "Gather", "FieldName1"
	}
	CurrentFieldNum:=1
	IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
	MainGui["CurrentField"].Text := FieldName1
	CurrentField:=FieldName1
	nm_WebhookEasterEgg()
}
nm_FieldSelect2(GuiCtrl?, *){
	global
	local hBM
	if IsSet(GuiCtrl)
		FieldName2 := MainGui["FieldName2"].Text
	if(FieldName2!="none"){
		MainGui["FieldName3"].Enabled := 1
		MainGui["FieldPattern2"].Enabled := 1
		MainGui["FieldPatternSize2UpDown"].Enabled := 1
		MainGui["FieldPatternReps2"].Enabled := 1
		MainGui["FieldPatternShift2"].Enabled := 1
		MainGui["FieldPatternInvertFB2"].Enabled := 1
		MainGui["FieldPatternInvertLR2"].Enabled := 1
		MainGui["FieldUntilMins2"].Enabled := 1
		MainGui["FieldUntilPack2UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist2"].Enabled := 1
		MainGui["FieldRotateTimes2"].Enabled := 1
		MainGui["FieldDriftCheck2"].Enabled := 1
		MainGui["FRD2Left"].Enabled := 1
		MainGui["FRD2Right"].Enabled := 1
		MainGui["FRT2Left"].Enabled := 1
		MainGui["FRT2Right"].Enabled := 1
		MainGui["FSL2Left"].Enabled := 1
		MainGui["FSL2Right"].Enabled := 1
		MainGui["FDCHelp2"].Enabled := 1
		MainGui["CopyGather2"].Enabled := 1
		MainGui["PasteGather3"].Enabled := 1
		MainGui["SaveFieldDefault2"].Enabled := 1
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		FieldName1 := MainGui["FieldName1"].Text
		CurrentFieldNum:=1
		IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
		MainGui["CurrentField"].Text := FieldName1
		CurrentField:=FieldName1
		MainGui["FieldPattern2"].Enabled := 0
		MainGui["FieldPatternSize2UpDown"].Enabled := 0
		MainGui["FieldPatternReps2"].Enabled := 0
		MainGui["FieldPatternShift2"].Enabled := 0
		MainGui["FieldPatternInvertFB2"].Enabled := 0
		MainGui["FieldPatternInvertLR2"].Enabled := 0
		MainGui["FieldUntilMins2"].Enabled := 0
		MainGui["FieldUntilPack2UpDown"].Enabled := 0
		MainGui["FieldSprinklerDist2"].Enabled := 0
		MainGui["FieldRotateTimes2"].Enabled := 0
		MainGui["FieldDriftCheck2"].Enabled := 0
		MainGui["FRD2Left"].Enabled := 0
		MainGui["FRD2Right"].Enabled := 0
		MainGui["FRT2Left"].Enabled := 0
		MainGui["FRT2Right"].Enabled := 0
		MainGui["FSL2Left"].Enabled := 0
		MainGui["FSL2Right"].Enabled := 0
		MainGui["FDCHelp2"].Enabled := 0
		MainGui["CopyGather2"].Enabled := 0
		MainGui["PasteGather3"].Enabled := 0
		MainGui["SaveFieldDefault2"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		MainGui["SaveFieldDefault2"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
		MainGui["FieldName3"].Text := "None"
		MainGui["FieldName3"].Enabled := 0
		nm_fieldSelect3(1)
	}
	if IsSet(GuiCtrl) {
		nm_FieldDefaults(2)
		IniWrite FieldName2, "settings\nm_config.ini", "Gather", "FieldName2"
	}
	nm_WebhookEasterEgg()
}
nm_FieldSelect3(GuiCtrl?, *){
	global
	local hBM
	if IsSet(GuiCtrl)
		FieldName3 := MainGui["FieldName3"].Text
	if(FieldName3!="none"){
		MainGui["FieldPattern3"].Enabled := 1
		MainGui["FieldPatternSize3UpDown"].Enabled := 1
		MainGui["FieldPatternReps3"].Enabled := 1
		MainGui["FieldPatternShift3"].Enabled := 1
		MainGui["FieldPatternInvertFB3"].Enabled := 1
		MainGui["FieldPatternInvertLR3"].Enabled := 1
		MainGui["FieldUntilMins3"].Enabled := 1
		MainGui["FieldUntilPack3UpDown"].Enabled := 1
		MainGui["FieldSprinklerDist3"].Enabled := 1
		MainGui["FieldRotateTimes3"].Enabled := 1
		MainGui["FieldDriftCheck3"].Enabled := 1
		MainGui["FRD3Left"].Enabled := 1
		MainGui["FRD3Right"].Enabled := 1
		MainGui["FRT3Left"].Enabled := 1
		MainGui["FRT3Right"].Enabled := 1
		MainGui["FSL3Left"].Enabled := 1
		MainGui["FSL3Right"].Enabled := 1
		MainGui["FDCHelp3"].Enabled := 1
		MainGui["CopyGather3"].Enabled := 1
		MainGui["SaveFieldDefault3"].Enabled := 1
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefield"])
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	} else {
		FieldName1 := MainGui["FieldName1"].Text
		CurrentFieldNum:=1
		IniWrite CurrentFieldNum, "settings\nm_config.ini", "Gather", "CurrentFieldNum"
		MainGui["CurrentField"].Text := FieldName1
		CurrentField:=FieldName1
		MainGui["FieldPattern3"].Enabled := 0
		MainGui["FieldPatternSize3UpDown"].Enabled := 0
		MainGui["FieldPatternReps3"].Enabled := 0
		MainGui["FieldPatternShift3"].Enabled := 0
		MainGui["FieldPatternInvertFB3"].Enabled := 0
		MainGui["FieldPatternInvertLR3"].Enabled := 0
		MainGui["FieldUntilMins3"].Enabled := 0
		MainGui["FieldUntilPack3UpDown"].Enabled := 0
		MainGui["FieldSprinklerDist3"].Enabled := 0
		MainGui["FieldRotateTimes3"].Enabled := 0
		MainGui["FieldDriftCheck3"].Enabled := 0
		MainGui["FRD3Left"].Enabled := 0
		MainGui["FRD3Right"].Enabled := 0
		MainGui["FRT3Left"].Enabled := 0
		MainGui["FRT3Right"].Enabled := 0
		MainGui["FSL3Left"].Enabled := 0
		MainGui["FSL3Right"].Enabled := 0
		MainGui["FDCHelp3"].Enabled := 0
		MainGui["CopyGather3"].Enabled := 0
		MainGui["SaveFieldDefault3"].Enabled := 0
		hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["savefielddisabled"])
		MainGui["SaveFieldDefault3"].Value := "HBITMAP:*" hBM
		DllCall("DeleteObject", "ptr", hBM)
	}
	if IsSet(GuiCtrl) {
		nm_FieldDefaults(3)
		IniWrite FieldName3, "settings\nm_config.ini", "Gather", "FieldName3"
	}
	nm_WebhookEasterEgg()
}
nm_FieldDefaults(num){
	global FieldDefault, FieldPatternSizeArr
		, FieldName1, FieldName2, FieldName3
		, FieldPattern1, FieldPattern2, FieldPattern3
		, FieldPatternSize1, FieldPatternSize2, FieldPatternSize3
		, FieldPatternReps1, FieldPatternReps2, FieldPatternReps3
		, FieldPatternShift1, FieldPatternShift2, FieldPatternShift3
		, FieldPatternInvertFB1, FieldPatternInvertFB2, FieldPatternInvertFB3
		, FieldPatternInvertLR1, FieldPatternInvertLR2, FieldPatternInvertLR3
		, FieldUntilMins1, FieldUntilMins2, FieldUntilMins3
		, FieldUntilPack1, FieldUntilPack2, FieldUntilPack3
		, FieldReturnType1, FieldReturnType2, FieldReturnType3
		, FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3
		, FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3
		, FieldRotateDirection1, FieldRotateDirection2, FieldRotateDirection3
		, FieldRotateTimes1, FieldRotateTimes2, FieldRotateTimes3
		, FieldDriftCheck1, FieldDriftCheck2, FieldDriftCheck3
		, patternlist, disableSave:=1

	FieldName%num% := MainGui["FieldName" num].Text
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
	MainGui["FieldPattern" num].Text := FieldPattern%num%
	MainGui["FieldPatternSize" num].Text := FieldPatternSize%num%
	MainGui["FieldPatternSize" num "UpDown"].Value := FieldPatternSizeArr[FieldPatternSize%num%]
	MainGui["FieldPatternReps" num].Value := FieldPatternReps%num%
	MainGui["FieldPatternShift" num].Value := FieldPatternShift%num%
	MainGui["FieldPatternInvertFB" num].Value := FieldPatternInvertFB%num%
	MainGui["FieldPatternInvertLR" num].Value := FieldPatternInvertLR%num%
	MainGui["FieldUntilMins" num].Value := FieldUntilMins%num%
	MainGui["FieldUntilPack" num].Text := FieldUntilPack%num%
	MainGui["FieldUntilPack" num "UpDown"].Value := FieldUntilPack%num%//5
	MainGui["FieldReturnType" num].Text := FieldReturnType%num%
	MainGui["FieldSprinklerLoc" num].Text := FieldSprinklerLoc%num%
	MainGui["FieldSprinklerDist" num].Value := FieldSprinklerDist%num%
	MainGui["FieldRotateDirection" num].Text := FieldRotateDirection%num%
	MainGui["FieldRotateTimes" num].Value := FieldRotateTimes%num%
	MainGui["FieldDriftCheck" num].Value := FieldDriftCheck%num%
	IniWrite FieldPattern%num%, "settings\nm_config.ini", "Gather", "FieldPattern" num
	IniWrite FieldPatternSize%num%, "settings\nm_config.ini", "Gather", "FieldPatternSize" num
	IniWrite FieldPatternReps%num%, "settings\nm_config.ini", "Gather", "FieldPatternReps" num
	IniWrite FieldPatternShift%num%, "settings\nm_config.ini", "Gather", "FieldPatternShift" num
	IniWrite FieldPatternInvertFB%num%, "settings\nm_config.ini", "Gather", "FieldPatternInvertFB" num
	IniWrite FieldPatternInvertLR%num%, "settings\nm_config.ini", "Gather", "FieldPatternInvertLR" num
	IniWrite FieldUntilMins%num%, "settings\nm_config.ini", "Gather", "FieldUntilMins" num
	IniWrite FieldUntilPack%num%, "settings\nm_config.ini", "Gather", "FieldUntilPack" num
	IniWrite FieldReturnType%num%, "settings\nm_config.ini", "Gather", "FieldReturnType" num
	IniWrite FieldSprinklerLoc%num%, "settings\nm_config.ini", "Gather", "FieldSprinklerLoc" num
	IniWrite FieldSprinklerDist%num%, "settings\nm_config.ini", "Gather", "FieldSprinklerDist" num
	IniWrite FieldRotateDirection%num%, "settings\nm_config.ini", "Gather", "FieldRotateDirection" num
	IniWrite FieldRotateTimes%num%, "settings\nm_config.ini", "Gather", "FieldRotateTimes" num
	IniWrite FieldDriftCheck%num%, "settings\nm_config.ini", "Gather", "FieldDriftCheck" num
	disableSave:=0
}
nm_FDCHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	Field Drift Compensation is a way to stop what we call field drift (AKA falling/running out of the field.)
	Enabling this checkbox will re-align you to your saturator every so often by searching for the neon blue pixel and moving towards it.

	Note that this feature requires The Supreme Saturator, otherwise you will drift more. If you would like more info, join our Discord.
	)", "Field Drift Compensation", 0x40000
}
nm_FieldPatternSize(GuiCtrl, *){
	global
	static arr := ["XS","S","M","L","XL"]
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := arr[GuiCtrl.Value]
	IniWrite %k%, "settings\nm_config.ini", "Gather", k
}
nm_FieldRotateDirection(GuiCtrl, *){
	global
	static val := ["None", "Left", "Right"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FRD1Left", "FRD1Right":
		index := 1
		case "FRD2Left", "FRD2Right":
		index := 2
		case "FRD3Left", "FRD3Right":
		index := 3
	}

	i := (FieldRotateDirection%index% = "None") ? 1 : (FieldRotateDirection%index% = "Left") ? 2 : 3

	MainGui["FieldRotateDirection" index].Text := FieldRotateDirection%index% := val[(GuiCtrl.Name = "FRD" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldRotateDirection%index%, "settings\nm_config.ini", "Gather", "FieldRotateDirection" index
}
nm_FieldUntilPack(GuiCtrl, *){
	global
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := GuiCtrl.Value * 5
	IniWrite %k%, "settings\nm_config.ini", "Gather", k
}
nm_FieldReturnType(GuiCtrl, *){
	global
	static val := ["Walk", "Reset"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FRT1Left", "FRT1Right":
		index := 1
		case "FRT2Left", "FRT2Right":
		index := 2
		case "FRT3Left", "FRT3Right":
		index := 3
	}

	i := (FieldReturnType%index% = "Walk") ? 1 : 2

	MainGui["FieldReturnType" index].Text := FieldReturnType%index% := val[(GuiCtrl.Name = "FRT" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldReturnType%index%, "settings\nm_config.ini", "Gather", "FieldReturnType" index
}
nm_FieldSprinklerLoc(GuiCtrl, *){
	global
	static val := ["Center", "Upper Left", "Upper", "Upper Right", "Right", "Lower Right", "Lower", "Lower Left", "Left"], l := val.Length
	local i, index

	switch GuiCtrl.Name, 0
	{
		case "FSL1Left", "FSL1Right":
		index := 1
		case "FSL2Left", "FSL2Right":
		index := 2
		case "FSL3Left", "FSL3Right":
		index := 3
	}

	switch FieldSprinklerLoc%index%, 0
	{
		case "Center":
		i := 1
		case "Upper Left":
		i := 2
		case "Upper":
		i := 3
		case "Upper Right":
		i := 4
		case "Right":
		i := 5
		case "Lower Right":
		i := 6
		case "Lower":
		i := 7
		case "Lower Left":
		i := 8
		default:
		i := 9
	}

	MainGui["FieldSprinklerLoc" index].Text := FieldSprinklerLoc%index% := val[(GuiCtrl.Name = "FSL" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite FieldSprinklerLoc%index%, "settings\nm_config.ini", "Gather", "FieldSprinklerLoc" index
}
nm_SaveFieldDefault(GuiCtrl, *){
	global
	local i,k,v
	i := SubStr(GuiCtrl.Name, -1)
	if (FieldName%i% != "None")
	{
		if (MsgBox("Update " FieldName%i% " default settings with the currently selected settings? These will become the default settings when you change to this field.`n`n"
			. "The macro will use the updated settings when gathering for Quests/Planters.", "Change Field Defaults", 0x40044 " Owner" MainGui.Hwnd) = "Yes")
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
				IniWrite v, "settings\field_config.ini", FieldName%i%, k
		}
	}
}
nm_CopyGatherSettings(GuiCtrl, *){
	static q := Chr(34), ob := Chr(123), cb := Chr(125)
	local i := SubStr(GuiCtrl.Name, -1)
	A_Clipboard := ob q "Name" q ":" q FieldName%i% q ","
		. q "Pattern" q ":" q FieldPattern%i% q ","
		. q "DriftCheck" q ":" FieldDriftCheck%i% ","
		. q "PatternInvertFB" q ":" FieldPatternInvertFB%i% ","
		. q "PatternInvertLR" q ":" FieldPatternInvertLR%i% ","
		. q "PatternReps" q ":" FieldPatternReps%i% ","
		. q "PatternShift" q ":" FieldPatternShift%i% ","
		. q "PatternSize" q ":" q FieldPatternSize%i% q ","
		. q "ReturnType" q ":" q FieldReturnType%i% q ","
		. q "RotateDirection" q ":" q FieldRotateDirection%i% q ","
		. q "RotateTimes" q ":" FieldRotateTimes%i% ","
		. q "SprinklerDist" q ":" FieldSprinklerDist%i% ","
		. q "SprinklerLoc" q ":" q FieldSprinklerLoc%i% q ","
		. q "UntilMins" q ":" FieldUntilMins%i% ","
		. q "UntilPack" q ":" FieldUntilPack%i% cb
}
nm_PasteGatherSettings(GuiCtrl, *){
	global
	static validation := Map("DriftCheck", "^(0|1)$"
		, "PatternInvertFB", "^(0|1)$"
		, "PatternInvertLR", "^(0|1)$"
		, "PatternReps", "^[1-9]$"
		, "PatternShift", "^(0|1)$"
		, "PatternSize", "i)^(XS|S|M|L|XL)$"
		, "ReturnType", "i)^(Walk|Reset)$"
		, "RotateDirection", "i)^(None|Left|Right)$"
		, "RotateTimes", "^[1-4]$"
		, "SprinklerDist", "^([1-9]|10)$"
		, "SprinklerLoc", "i)^(Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left)$"
		, "UntilMins", "^\d{1,4}$"
		, "UntilPack", "^(5|10|15|20|25|30|35|40|45|50|55|60|65|70|75|80|85|90|95|100)$"), q := Chr(34)
	local i := SubStr(GuiCtrl.Name, -1), obj, ctrl

	If (!RegExMatch(A_Clipboard, "^\s*\{.*\}\s*$")){
		MsgBox "Your String Format is incorrect!`nMake sure you also copy the " q "{" q " and the " q "}" q, "WARNING!!", 0x1030 " T60"
		Return
	}
	obj := json.parse(A_Clipboard)
	if obj.Has("Name") {
		if ObjHasValue(fieldnamelist, obj["Name"]) {
			FieldName%i% := obj["Name"]
			IniWrite obj["Name"], "settings\nm_config.ini", "Gather", "FieldName" i
			MainGui["FieldName" i].Text := FieldName%i%
		} else
			MsgBox "The Field Name you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " obj["Name"], "WARNING!!", 0x1030 " T60"
	}
	if obj.Has("Pattern") {
		if ObjHasValue(patternlist, obj["Pattern"]) {
			FieldPattern%i% := obj["Pattern"]
			IniWrite obj["Pattern"], "settings\nm_config.ini", "Gather", "FieldPattern" i
			MainGui["FieldPattern" i].Text := FieldPattern%i%
		} else
			MsgBox "The Pattern you tried to import is NOT valid!`nMake sure you copied the string correctly and have the pattern installed.`nSpecific: " obj["Pattern"], "WARNING!!", 0x1030 " T60"
	}
	for k,v in validation {
		if obj.Has(k) {
			if (obj[k] ~= v) {
				Field%k%%i% := obj[k]
				IniWrite obj[k], "settings\nm_config.ini", "Gather", "Field" k i
				ctrl := MainGui["Field" k i]
				switch ctrl.Type, 0 {
					case "DDL", "Text":
					ctrl.Text := obj[k]
					default:
					ctrl.Value := obj[k]
				}
			} else
				MsgBox "The item you tried to import is NOT valid!`nMake sure you copied the string correctly.`nSpecific: " k ":" obj[k], "WARNING!!", 0x1030 " T60"
		}
	}
	nm_FieldSelect%i%()
}
nm_WebhookEasterEgg(){
	global WebhookEasterEgg
	FieldName1 := MainGui["FieldName1"].Text
	FieldName2 := MainGui["FieldName2"].Text
	FieldName3 := MainGui["FieldName3"].Text
	if ((FieldName1 = FieldName2) && (FieldName2 = FieldName3))
	{
		If(MsgBox("You found an easter egg!`nEnable Rainbow Webhook?", , 0x1024 " Owner" MainGui.Hwnd) = "Yes")
			WebhookEasterEgg := 1
		else
			WebhookEasterEgg := 0
		IniWrite WebhookEasterEgg, "settings\nm_config.ini", "Status", "WebhookEasterEgg"
		PostSubmacroMessage("Status", 0x5552, 5, WebhookEasterEgg)
	}
}

; COLLECT/KILL TAB
; ------------------------
nm_CollectKillButton(GuiCtrl, *){
	global
	static CollectControls := ["CollectGroupBox","DispensersGroupBox","BeesmasGroupBox","BlenderGroupBox","BeesmasFailImage","BeesmasImage"
		,"ClockCheck","MondoBuffCheck","MondoAction","AntPassCheck","AntPassPointText","AntPassBuyCheck","AntPassAction","RoboPassCheck","HoneystormCheck"
		,"HoneyDisCheck","TreatDisCheck","BlueberryDisCheck","StrawberryDisCheck","CoconutDisCheck","RoyalJellyDisCheck","GlueDisCheck"
		,"MALeft","MARight","APALeft","APARight"
		,"BeesmasGatherInterruptCheck","StockingsCheck","WreathCheck","FeastCheck","RBPDelevelCheck","GingerbreadCheck","SnowMachineCheck","CandlesCheck","WinterMemoryMatchCheck","SamovarCheck","LidArtCheck","GummyBeaconCheck"
		,"MemoryMatchGroupBox","NormalMemoryMatchCheck","MegaMemoryMatchCheck","NightMemoryMatchCheck","ExtremeMemoryMatchCheck","MemoryMatchOptions"]
	, KillControls := ["BugRunGroupBox","BugRunCheck","MonsterRespawnTime","TextMonsterRespawnPercent","TextMonsterRespawn","MonsterRespawnTimeHelp"
		,"BugrunInterruptCheck","TextLoot","TextKill","TextLineBugRun1","TextLineBugRun2"
		,"BugrunLadybugsLoot","BugrunRhinoBeetlesLoot","BugrunSpiderLoot","BugrunMantisLoot","BugrunScorpionsLoot","BugrunWerewolfLoot"
		,"BugrunLadybugsCheck","BugrunRhinoBeetlesCheck","BugrunSpiderCheck","BugrunMantisCheck","BugrunScorpionsCheck","BugrunWerewolfCheck"
		,"StingersGroupBox","StingerCheck","StingerDailyBonusCheck","TextFields","StingerCloverCheck","StingerSpiderCheck","StingerCactusCheck","StingerRoseCheck","StingerMountainTopCheck","StingerPepperCheck"
		,"BossesGroupBox","TunnelBearCheck","KingBeetleCheck","CocoCrabCheck","StumpSnailCheck","CommandoCheck","TunnelBearBabyCheck","KingBeetleBabyCheck"
		,"BabyLovePicture1","BabyLovePicture2","KingBeetleAmuletMode","ShellAmuletMode","KingBeetleAmuPicture","ShellAmuPicture","KingBeetleAmuletModeText","ShellAmuletModeText"
		,"ChickLevelTextLabel","ChickLevelText","ChickLevel","SnailHPText","SnailHealthEdit","SnailHealthText","ChickHPText","ChickHealthEdit","ChickHealthText","SnailTimeText","SnailTimeUpDown","ChickTimeText","ChickTimeUpDown"
		,"BossConfigHelp","TextLineBosses1","TextLineBosses2","TextLineBosses3","TextBosses1","TextBosses2","TextBosses3"]
	, BlenderMain := ["BlenderItem1Picture", "BlenderItem2Picture", "BlenderItem3Picture", "BlenderAdd1", "BlenderAdd2", "BlenderAdd3", "BlenderData1", "BlenderData2", "BlenderData3"]
	, BlenderSide := ["BlenderAmount", "BlenderAmountNum", "BlenderAmountText"
		, "BlenderRepeatText", "BlenderIndex", "BlenderIndexNum"
		, "BlenderItem", "BlenderLeft", "BlenderRight", "BlenderAddSlot", "BlenderIndexOption"
		, "blenderline1", "blenderline2", "blenderline3", "blenderline4", "blendertitle1"]
	, MondoKillControls := ["MondoLootText", "MondoLootDirection", "MLDLeft", "MLDRight"]
	, MondoBuffControls := ["MondoSecs", "MondoSecsText"]

	local p, i, c, k, v, arr

	p := (GuiCtrl.Name = "KillSubTab")
	MainGui["CollectSubTab"].Enabled := p
	MainGui["KillSubTab"].Enabled := !p

	for i,c in [0,1] ; hide first, then show
	{
		if (((i = 1) && (p = 1)) || ((i = 2) && (p = 0))) ; hide/show all collect controls
		{
			for k,v in CollectControls
				MainGui[v].Visible := c
			if ((MondoAction = "Buff") || (MondoAction = "Kill"))
			{
				MainGui["MondoPointText"].Visible := c
				for k,v in Mondo%MondoAction%Controls
					MainGui[v].Visible := c
			}
			arr := (BlenderAdd > 0) ? "BlenderSide" : "BlenderMain"
			for k,v in %arr%
				MainGui[v].Visible := c
		}

		if (((i = 1) && (p = 0)) || ((i = 2) && (p = 1))) ; hide/show all kill controls
		{
			for k,v in KillControls
				MainGui[v].Visible := c
		}
	}
}
nm_MondoAction(GuiCtrl?, *){
	global MondoAction, MondoActionList

	for v in MondoActionList
		if IsSet(v)
			l := A_Index
	switch MondoAction, 0
	{
		case MondoActionList[1]:
		i := 1
		case MondoActionList[2]:
		i := 2
		case MondoActionList[3]:
		i := 3
		default:
		i := 4
	}

	MainGui["MondoAction"].Text := MondoAction := MondoActionList[(GuiCtrl.Name = "MARight") ? (Mod(i, l) + 1) : (GuiCtrl.Name = "MALeft") ? (Mod(l + i - 2, l) + 1) : i]
	MainGui["MondoPointText"].Visible := (MondoAction = "Buff") || (MondoAction = "Kill")
	MainGui["MondoSecs"].Visible := MainGui["MondoSecsText"].Visible := (MondoAction = "Buff")
	MainGui["MondoLootText"].Visible := MainGui["MondoLootDirection"].Visible := MainGui["MLDLeft"].Visible := MainGui["MLDRight"].Visible := (MondoAction = "Kill")
	IniWrite MondoAction, "settings\nm_config.ini", "Collect", "MondoAction"
}
nm_MondoLootDirection(GuiCtrl, *){
	global MondoLootDirection
	static val := ["Left", "Right", "Random", "Ignore"], l := val.Length

	i := (MondoLootDirection = "Left") ? 1 : (MondoLootDirection = "Right") ? 2 : (MondoLootDirection = "Random") ? 3 : 4

	MainGui["MondoLootDirection"].Text := MondoLootDirection := val[(GuiCtrl.Name = "MLDRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite MondoLootDirection, "settings\nm_config.ini", "Collect", "MondoLootDirection"
}
nm_AntPassAction(GuiCtrl, *){
	global AntPassAction
	static val := ["Pass", "Challenge"], l := val.Length

	i := (AntPassAction = "Pass") ? 1 : 2

	MainGui["AntPassAction"].Text := AntPassAction := val[(GuiCtrl.Name = "APARight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite AntPassAction, "settings\nm_config.ini", "Collect", "AntPassAction"
}
nm_AntPassBuyCheck(*){
	global
	AntPassBuyCheck := MainGui["AntPassBuyCheck"].Value
	IniWrite AntPassBuyCheck, "settings\nm_config.ini", "Collect", "AntPassBuyCheck"
	if AntPassBuyCheck
		msgbox "
		(
		This option will make the macro buy Ant Passes with Tickets when:
		 1. You have no Ant Passes in your inventory.
		 2. The Free Ant Pass Dispenser is under cooldown.
		 3. You have a quest that requires you to kill ants.
		)", "Ant Pass", "Owner" MainGui.Hwnd
}
nm_BlenderIndexOption(*) {
	global BlenderIndexOption, BlenderIndex
	BlenderIndexOption := MainGui["BlenderIndexOption"].Value
	if (BlenderIndexOption)
		MainGui["BlenderIndex"].Enabled := 0
	else
		MainGui["BlenderIndex"].Enabled := 1
}
nm_setBlenderData(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	static uiList := ["BlenderItem", "BlenderLeft", "BlenderRight", "BlenderAddSlot", "BlenderAmountText", "BlenderAmount"
		, "BlenderAmountNum", "BlenderRepeatText", "BlenderIndexOption", "BlenderIndexNum", "BlenderIndex"
		, "blenderline1", "blendertitle1", "blenderline2", "blenderline3", "blenderline4"]

	if (BlenderItem%i% = "None") {
		BlenderaddIndex := i, BlenderAdd := i
		loop 3 {
			MainGui["BlenderAdd" A_Index].Visible := 0
			MainGui["BlenderData" A_Index].Visible := 0
			MainGui["BlenderItem" A_Index "Picture"].Visible := 0
		}

		MainGui["BlenderAmount"].Value := BlenderAmount%i%
		MainGui["BlenderIndex"].Value := ((BlenderIndex%i% != "Infinite" && BlenderIndex%i% != "∞") ? BlenderIndex%i% : 1)
		ba_AddBlenderItemButton()
		MainGui["BlenderIndexOption"].Value := 0
		MainGui["BlenderIndex"].Enabled := 1
		MainGui["BlenderAddSlot"].Text := "Add to Slot " BlenderaddIndex

		For ui in uiList
			MainGui[ui].Visible := 1
	} else {
		BlenderItem%i% := "None", BlenderAmount%i% := 0, BlenderIndex%i% := 1, BlenderTime%i% := 0

		IniWrite "None", "settings\nm_config.ini", "Blender", "BlenderItem" i
		IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderAmount" i
		IniWrite 1, "settings\nm_config.ini", "Blender", "BlenderIndex" i
		IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderTime" i

		MainGui["BlenderAdd" i].Text := ((BlenderItem%i% = "None" || BlenderItem%i% = "") ? "Add" : "Clear")
		MainGui["BlenderData" i].Text := "(" BlenderAmount%i% ") [" ((BlenderIndex%i% = "Infinite") ? "∞" : BlenderIndex%i%) "]"

		MainGui["BlenderItem" i "Picture"].Value := ""
	}
}
ba_AddBlenderItemButton(GuiCtrl?, *){
	global AddBlenderItem, BlenderAdd, hBitmapsSB
	static items := ["RedExtract", "BlueExtract", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops"
		, "MoonCharms", "Glitter", "StarJelly", "PurplePotion", "SoftWax", "HardWax", "SwirledWax"
		, "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "SuperSmoothie", "Turpentine"], i := 0, h := 0

	if (h != BlenderAdd)
		i := 0, h := BlenderAdd
	i := Mod(items.Length + i + (IsSet(GuiCtrl) ? ((GuiCtrl.Name = "BlenderLeft") ? -1 : 1) : 0), items.Length), AddBlenderItem := items[i+1]
	SetImage(MainGui["BlenderItem"].Hwnd, hBitmapsSB[AddBlenderItem])
}
ba_AddBlenderItem(*){
	global
	local BlenderIndex, BlenderAmount, BlenderIndexOption, BlenderIndex
	static uiList := ["BlenderItem", "BlenderLeft", "BlenderRight", "BlenderAddSlot", "BlenderAmountText", "BlenderAmount"
		, "BlenderAmountNum", "BlenderRepeatText", "BlenderIndexOption", "BlenderIndex", "BlenderIndexNum"
		, "blenderline1", "blenderline2", "blenderline3", "blenderline4", "blendertitle1"]

	BlenderIndex := MainGui["BlenderIndex"].Value
	BlenderAmount := MainGui["BlenderAmount"].Value
	BlenderIndexOption := MainGui["BlenderIndexOption"].Value
	BlenderIndex := ((BlenderIndexOption) ? "Infinite" : BlenderIndex)

	IniWrite (BlenderItem%BlenderaddIndex% := AddBlenderItem), "settings\nm_config.ini", "Blender", "BlenderItem" BlenderaddIndex
	IniWrite (BlenderIndex%BlenderaddIndex% := BlenderIndex), "settings\nm_config.ini", "Blender", "BlenderIndex" BlenderaddIndex
	IniWrite (BlenderAmount%BlenderaddIndex% := BlenderAmount), "settings\nm_config.ini", "Blender", "BlenderAmount" BlenderaddIndex

	MainGui["BlenderItem" BlenderaddIndex "Picture"].Value := hBitmapsSB[BlenderItem%BlenderaddIndex%] ? ("HBITMAP:*" hBitmapsSB[BlenderItem%BlenderaddIndex%]) : ""
	MainGui["BlenderData" BlenderaddIndex].Text := "(" BlenderAmount%BlenderaddIndex% ") [" ((BlenderIndex%BlenderaddIndex% = "Infinite") ? "∞" : BlenderIndex%BlenderaddIndex%) "]"
	MainGui["BlenderAdd" BlenderaddIndex].Text := ((AddBlenderItem = "None" || AddBlenderItem = "") ? "Add" : "Clear")

	For ui in uiList
		MainGui[ui].Visible := 0
	loop 3 {
		MainGui["BlenderAdd" A_Index].Visible := 1
		MainGui["BlenderData" A_Index].Visible := 1
		MainGui["BlenderItem" A_Index "Picture"].Visible := 1
	}
	BlenderAdd := 0
}
nm_BeesmasHandler(req)
{
	global
	local hBM, k, v

	if (req.readyState != 4)
		return

	if (req.status = 200)
	{
		switch Trim(req.responseText, " `t`r`n")
		{
			case 1:
			beesmasActive := 1

			MainGui["BeesmasGroupBox"].Text := "Beesmas (Active)"

			hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["beesmas"])
			MainGui["BeesmasImage"].Value := "HBITMAP:*" hBM
			DllCall("DeleteObject", "ptr", hBM)

			for ctrl in ["BeesmasGatherInterruptCheck","StockingsCheck","WreathCheck","FeastCheck","RBPDelevelCheck","GingerbreadCheck","SnowMachineCheck","CandlesCheck","WinterMemoryMatchCheck","SamovarCheck","LidArtCheck","GummyBeaconCheck"]
				MainGui[ctrl].Enabled := 1, MainGui[ctrl].Value := %ctrl%

			sprinklerImages.Push("saturatorWS")
			MainGui["BeesmasFailImage"].Value := ""

			case 0:
			MainGui["BeesmasFailImage"].Value := ""
		}
	}
}
BeesmasActiveFail(*){
	MsgBox "Could not fetch Beesmas data from GitHub!`r`nTo use Beesmas features, make sure you have a working internet connection and then reload the macro!", "Error", 0x1030 " Owner" MainGui.Hwnd
}
nm_NightMemoryMatchCheck(*){
	global NightMemoryMatchCheck
	PostSubmacroMessage("background", 0x5554, 7, NightMemoryMatchCheck := MainGui["NightMemoryMatchCheck"].Value)
	IniWrite NightMemoryMatchCheck, "settings\nm_config.ini", "Collect", "NightMemoryMatchCheck"
	if (NightMemoryMatchCheck = 1)
		MsgBox "The night memory match path is heavily affected by lag and haste! This is because there are no good anchor points to align to. It works best at standard movespeeds and without haste. If it doesn't work for you, we recommend disabling it.", "Night Memory Match", 0x1030 " Owner" MainGui.Hwnd
}
nm_MemoryMatchOptions(*){
	global MMGui, MicroConverterMatchIgnore, SunflowerSeedMatchIgnore, JellyBeanMatchIgnore, RoyalJellyMatchIgnore, TicketMatchIgnore
		, CyanTrimMatchIgnore, OilMatchIgnore, StrawberryMatchIgnore, CoconutMatchIgnore, TropicalDrinkMatchIgnore, RedExtractMatchIgnore
		, MagicBeanMatchIgnore, PineappleMatchIgnore, StarJellyMatchIgnore, EnzymeMatchIgnore, BlueExtractMatchIgnore, GumdropMatchIgnore
		, FieldDiceMatchIgnore, MoonCharmMatchIgnore, BlueberryMatchIgnore, GlitterMatchIgnore, StingerMatchIgnore, TreatMatchIgnore, GlueMatchIgnore
		, CloudVialMatchIgnore, SoftWaxMatchIgnore, HardWaxMatchIgnore, SwirledWaxMatchIgnore, NightBellMatchIgnore, HoneysuckleMatchIgnore
		, SuperSmoothieMatchIgnore, SmoothDiceMatchIgnore, NeonberryMatchIgnore, GingerbreadMatchIgnore
		, SilverEggMatchIgnore, GoldEggMatchIgnore, DiamondEggMatchIgnore
	local MatchIgnoreGui := ""

	GuiClose(*){
		if (IsSet(MMGui) && IsObject(MMGui))
			MMGui.Destroy(), MMGui := ""
	}
	GuiClose()

	MMGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Memory Match Options")
	MMGui.OnEvent("Close", GuiClose)
	MMGui.SetFont("s8 cDefault Norm", "Tahoma")
	MMGui.Add("Text", "x6 y6 w360 Center Section", "
	(
	Enable the option below to stop gathering when a Memory Match is ready.
	Night Memory Match will always interrupt gathering, even if this option is disabled, so that it jumps on the Moons during nighttime.
	)")
	(GuiCtrl := MMGui.Add("CheckBox", "x122 y+3 vMemoryMatchInterruptCheck Checked" MemoryMatchInterruptCheck, "Allow Gather Interrupt")).Section := "Collect", GuiCtrl.OnEvent("Click", nm_saveConfig)
	TextCtrl := MMGui.Add("Text", "x6 y+8 w360 Center Section", "
	(
	Pick the items you do NOT want to match in Memory Match games below!
	The macro will IGNORE these items and look for every other item.
	Rare items like Mythic Egg that aren't on this list will always be looked for.
	Click on the item names to configure settings for each Memory Match!
	)")
	for item, data in MemoryMatch {
		MMGui.Add("CheckBox", "xs+" 8+(A_Index-1)//13*120 " ys+" 57+Mod(A_Index-1,13)*16 " w13 h13 v" item " Check3 Checked" ((%item%MatchIgnore = 0) ? 0 : (%item%MatchIgnore = data.games) ? 1 : -1)).OnEvent("Click", MatchIgnoreCheck)
		MMGui.Add("Button", "x+2 yp-1 w" TextExtent(data.name, TextCtrl)+8 " h15 v" item "Button", data.name).OnEvent("Click", MatchIgnoreButton)
	}
	MMGui.Show("w360 h330")

	MatchIgnoreCheck(GuiCtrl, *) {
		item := GuiCtrl.Name, %item%MatchIgnore := (GuiCtrl.Value := (%item%MatchIgnore = 0)) ? MemoryMatch[item].games : 0
		if (IsObject(MatchIgnoreGui) && (MatchIgnoreGui.Item = item))
			for ctrl in MatchIgnoreGui
				if (ctrl.Type = "CheckBox")
					ctrl.Value := (%item%MatchIgnore & MemoryMatchGames[ctrl.Name].bit > 0)
		IniWrite %item%MatchIgnore, "settings\nm_config.ini", "Collect", item "MatchIgnore"
	}

	MatchIgnoreButton(GuiCtrl, *) {
		item := StrReplace(GuiCtrl.Name, "Button")
		if IsObject(MatchIgnoreGui) {
			prevItem := MatchIgnoreGui.Item
			MatchIgnoreGui.Destroy(), MatchIgnoreGui := ""
			if (item = prevItem)
				return
		}

		(MatchIgnoreGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MMGui.Hwnd, "Ignore " MemoryMatch[item].name)).Item := item
		MatchIgnoreGui.OnEvent("Close", (*) => (MatchIgnoreGui.Destroy(), MatchIgnoreGui := ""))
		MatchIgnoreGui.SetFont("s8 cDefault Norm", "Tahoma")
		for game in ["Normal", "Mega", "Night", "Extreme", "Winter"]
			bit := MemoryMatchGames[game].bit, MatchIgnoreGui.Add("CheckBox", "x+1 y36 v" game " Disabled" (MemoryMatch[item].games & bit = 0) " Checked" (%item%MatchIgnore & bit > 0), game).OnEvent("Click", MatchIgnoreGameCheck)
		MatchIgnoreGui.Add("Text", "x6 y4 w275 Center", "Choose the Memory Match games you want to ignore " MemoryMatch[item].name " for:")
		WinGetPos(&x, &y, , , GuiCtrl)
		MatchIgnoreGui.Show("x" x-112 " y" y-82 " w275 h44")

		MatchIgnoreGameCheck(GuiCtrl, *) {
			bit := MemoryMatchGames[GuiCtrl.Name].bit, %item%MatchIgnore := (GuiCtrl.Value = 0) ? (%item%MatchIgnore & ~bit) : (%item%MatchIgnore | bit)
			MMGui[item].Value := (%item%MatchIgnore = 0) ? 0 : (%item%MatchIgnore = MemoryMatch[item].games) ? 1 : -1
			IniWrite %item%MatchIgnore, "settings\nm_config.ini", "Collect", item "MatchIgnore"
		}
	}
}
;kill
nm_BugrunCheck(*){
	global
	local ctrl
	static ctrlList := ["BugrunInterruptCheck", "BugrunLadybugsCheck", "BugrunRhinoBeetlesCheck", "BugrunSpiderCheck", "BugrunMantisCheck", "BugrunScorpionsCheck", "BugrunWerewolfCheck"
		, "BugrunLadybugsLoot", "BugrunRhinoBeetlesLoot", "BugrunSpiderLoot", "BugrunMantisLoot", "BugrunScorpionsLoot", "BugrunWerewolfLoot"]

	for ctrl in ctrlList {
		MainGui[ctrl].Value := %ctrl% := MainGui["BugrunCheck"].Value
		IniWrite %ctrl%, "settings\nm_config.ini", "Collect", ctrl
	}
}
nm_MonsterRespawnTime(GuiCtrl, *){
	global MonsterRespawnTime
	p := EditGetCurrentCol(GuiCtrl)
	NewMonsterRespawnTime := GuiCtrl.Value

	if (IsInteger(NewMonsterRespawnTime) && (NewMonsterRespawnTime > 40)) ; integer and more than 40
	{
		GuiCtrl.Value := MonsterRespawnTime
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "You cannot enter a number above 40!")
	}
	else
	{
		MonsterRespawnTime := NewMonsterRespawnTime
		IniWrite MonsterRespawnTime, "settings\nm_config.ini", "Collect", "MonsterRespawnTime"
	}
}
nm_MonsterRespawnTimeHelp(*){ ; monster respawn time information
	MsgBox "
	(
	DESCRIPTION:
	Enter the sum of all of your Monster Respawn Time buffs here. These can come from:
	- Gifted Vicious Bee (-15%)
	- Stick Bug Amulet (up to -10%)
	- Icicles Beequip (-1% to -5%)

	EXAMPLE:
	I have a Gifted Vicious Bee (-15%), a Stick Bug Amulet with -8% Monster Respawn Time, and 2 Icicles Beequips with -2% Monster Respawn Time each.
	I will enter '27' in the input box.
	)", "Monster Respawn Time", 0x40000
}
nm_saveStingers(*){
	global
	static fields := ["Pepper","MountainTop","Rose","Cactus","Spider","Clover"]
	local field
	IniWrite (StingerCheck := MainGui["StingerCheck"].Value), "settings\nm_config.ini", "Collect", "StingerCheck"
	for field in fields
		MainGui["Stinger" field "Check"].Enabled := StingerCheck
	MainGui["StingerDailyBonusCheck"].Enabled := StingerCheck
}
nm_BossConfigHelp(*){ ; monster respawn time information
	MsgBox "
	(
	DESCRIPTION:
	The Bosses menu allows for you to customize whether to wait for baby love, to keep your old amulet or keep it on the screen for manual input and to configure the health and time interval for Snail and chick.

	Baby Love:
	The baby love option will allow for the macro to wait a certain amount of time to try to get a baby love token to increase loot luck. This option is only for king beetle and tunnel bear.

	Boss Amulet options:
	Enabling the checkbox will allow for the macro to automatically keep your old amulet so that you don't lose your perfect amulet.
	Unchecking this box will allow for the amulet prompt to stay on screen for manual input whether to keep or replace.
	The only bosses with this feature are Stump Snail and King beetle

	Boss health/time settings:
	Enter the boss's health in the text box.
	The health needs to be written in without commas separating the health and it will automatically be converted into a percentage.
	As for the time, the time options are in 5,10,15 minutes with another option being the kill option.
	The Kill option will basically attack the boss until the boss dies or if you die.
	The only bosses with this feature are Stump Snail and Commando Chick.
	)", "Boss configuration", 0x40000
}
nm_saveAmulet(GuiCtrl, *){
	global
	MainGui[GuiCtrl.Name "Text"].Text := ((%GuiCtrl.Name% := GuiCtrl.Value) = 1) ? " Keep Old" : "Do Nothing"
	IniWrite GuiCtrl.Value, "settings\nm_config.ini", "Collect", GuiCtrl.Name
}
nm_CocoCrabCheck(*){
	global
	IniWrite (CocoCrabCheck := MainGui["CocoCrabCheck"].Value), "settings\nm_config.ini", "Collect", "CocoCrabCheck"
	if (CocoCrabCheck = 1)
		MsgBox "Being able to kill Coco Crab with the macro depends heavily on your hive level, attack, number of bees, and server lag!", "Coconut Crab", 0x1030 " Owner" MainGui.Hwnd
}
nm_setSnailHealth(GuiCtrl, *)
{
	global InputSnailHealth
	p := EditGetCurrentCol(GuiCtrl)
	inputHP := MainGui["SnailHealthEdit"].Value

	if (IsInteger(inputHP) && (inputHP > 30000000)) ; invalid HP
	{
		MainGui["SnailHealthEdit"].Value := Round(30000000*InputSnailHealth/100)
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "You cannot enter a number above 30M!")
	}
	else
	{
		InputSnailHealth := Round(((inputHP || 0) / 30000000) * 100, 2)
		MainGui["SnailHealthText"].Opt("+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0) " +Redraw")
		MainGui["SnailHealthText"].Text := InputSnailHealth "%"
		IniWrite InputSnailHealth, "settings\nm_config.ini", "Collect", "InputSnailHealth"
	}
}
nm_setChickHealth(GuiCtrl, *)
{
	global InputChickHealth, CommandoChickHealth

	inputHP := MainGui["ChickHealthEdit"].Value
	ChickLevel := MainGui["ChickLevel"].Value
	MaxHealth := CommandoChickHealth.Has(ChickLevel) ? CommandoChickHealth[ChickLevel] : 10000000

	if (GuiCtrl.Name = "ChickHealthEdit")
	{
		if (IsInteger(inputHP) && (inputHP > MaxHealth))
		{
			p := EditGetCurrentCol(GuiCtrl)
			GuiCtrl.Value := MaxHealth
			SendMessage 0xB1, p-2, p-2, GuiCtrl
			nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "You cannot enter a number above " MaxHealth " for this level!")
		}
	}
	else if (inputHP > MaxHealth)
		MainGui["ChickHealthEdit"].Value := (inputHP := MaxHealth)
	MainGui["ChickLevelText"].Text := ChickLevel

	InputChickHealth := Round(Min(100, ((inputHP || 0) / (CommandoChickHealth.Has(ChickLevel) ? CommandoChickHealth[ChickLevel] : 10000000)) * 100), 2)
	MainGui["ChickHealthText"].Opt("+c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0) " +Redraw")
	MainGui["ChickHealthText"].Text := InputChickHealth "%"
	IniWrite ChickLevel, "settings\nm_config.ini", "Collect", "ChickLevel"
	IniWrite InputChickHealth, "settings\nm_config.ini", "Collect", "InputChickHealth"
}
nm_SnailTime(*){
	global SnailTime
	static arr := [5,10,15,"Kill"]
	SnailTimeUpDown := MainGui["SnailTimeUpDown"].Value
	MainGui["SnailTimeText"].Text := ((SnailTime := arr[SnailTimeUpDown]) = "Kill") ? SnailTime : SnailTime "m"
	IniWrite SnailTime, "settings\nm_config.ini", "Collect", "SnailTime"
}
nm_ChickTime(*){
	global ChickTime
	static arr := [5,10,15,"Kill"]
	ChickTimeUpDown := MainGui["ChickTimeUpDown"].Value
	MainGui["ChickTimeText"].Text := ((ChickTime := arr[ChickTimeUpDown]) = "Kill") ? ChickTime : ChickTime "m"
	IniWrite ChickTime, "settings\nm_config.ini", "Collect", "ChickTime"
}

; BOOST TAB
; ------------------------
nm_FieldBooster(GuiCtrl?, *){
	global
	static val := ["None", "Blue", "Red", "Mountain"]
	local i, l, index, n, j, arr := []

	switch IsSet(GuiCtrl) ? GuiCtrl.Name : "", 0
	{
		case "FB2Left", "FB2Right":
		index := 2
		case "FB3Left", "FB3Right":
		index := 3
		default:
		index := 1
	}

	for k,v in val
	{
		if (k > 1)
			Loop (index - 1)
				if (v = FieldBooster%A_Index%)
					continue 2
		arr.Push(v)
	}
	l := arr.Length

	switch FieldBooster%index%, 0
	{
		case arr[1]:
		i := 1
		case arr[2]:
		i := 2
		case arr[3]:
		i := 3
		default:
		i := l
	}

	MainGui["FieldBooster" index].Text := (FieldBooster%index% := arr[IsSet(GuiCtrl) ? ((GuiCtrl.Name = "FB" index "Right") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)) : i])

	Loop 3 {
		n := A_Index
		Loop (n - 1) {
			if (FieldBooster%n% = FieldBooster%A_Index%) {
				MainGui["FieldBooster" n].Text := FieldBooster%n% := "None"
				if IsSet(GuiCtrl)
					IniWrite FieldBooster%n%, "settings\nm_config.ini", "Boost", "FieldBooster" n
			}
		}
		if (FieldBooster%n% = "None") {
			Loop (3 - n) {
				j := n + A_Index
				MainGui["FB" j "Left"].Enabled := 0
				MainGui["FB" j "Right"].Enabled := 0
				if (FieldBooster%j% != "None") {
					MainGui["FieldBooster" j].Text := FieldBooster%j% := "None"
					if IsSet(GuiCtrl)
						IniWrite FieldBooster%j%, "settings\nm_config.ini", "Boost", "FieldBooster" j
				}
			}
			break
		} else if (n < 3) {
			j := n + 1
			MainGui["FB" j "Left"].Enabled := 1
			MainGui["FB" j "Right"].Enabled := 1
		}
	}

	if IsSet(GuiCtrl)
		IniWrite FieldBooster%index%, "settings\nm_config.ini", "Boost", "FieldBooster" index
}
nm_FieldBoosterMins(*){
	global FieldBoosterMins
	MainGui["FieldBoosterMins"].Text := FieldBoosterMins := MainGui["FieldBoosterMinsUpDown"].Value * 5
	IniWrite FieldBoosterMins, "settings\nm_config.ini", "Boost", "FieldBoosterMins"
}
nm_HotbarWhile(GuiCtrl?, *){
	global HotbarWhile2, HotbarWhile3, HotbarWhile4, HotbarWhile5, HotbarWhile6, HotbarWhile7
		, HotbarTime2, HotbarTime3, HotbarTime4, HotbarTime5, HotbarTime6, HotbarTime7
		, HotbarMax2, HotbarMax3, HotbarMax4, HotbarMax5, HotbarMax6, HotbarMax7
		, hHB2, hHB3, hHB4, hHB5, hHB6, hHB7
		, PFieldBoosted, hotbarwhilelist, beesmasActive, MainGui

	Loop 6 {
		i := A_Index + 1
		if (!IsSet(GuiCtrl) || (GuiCtrl.Name = "HotbarWhile" i)) {
			HotbarWhile%i% := MainGui["HotbarWhile" i].Text
			switch HotbarWhile%i%, 0
			{
				case "microconverter":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Full Pack"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "whirligig":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Hive Return"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "enzymes":
				MainGui["HBText" i].Text := PFieldBoosted ? "@ Boosted" : "@ Converting Balloon"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "glitter":
				MainGui["HBText" i].Text := "@ Boosted"
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 1

				case "snowflake":
				if (beesmasActive = 0)
				{
					if IsSet(GuiCtrl)
					{
						MsgBox "This option is only available during Beesmas!", "Snowflake", 0x1030
						HotbarWhile%i% := "Never"
						MainGui["HotbarWhile" i].Text := "Never"
						MainGui["HotbarTime" i].Visible := 0
						MainGui["HBTimeText" i].Visible := 0
						MainGui["HBConditionText" i].Visible := 0
						MainGui["HotbarMax" i].Visible := 0
						MainGui["HBText" i].Visible := 0
					}
				}
				else
				{
					HotbarMax%i% := MainGui["HotbarMax" i].Value
					HotbarTime%i% := MainGui["HotbarTime" i].Value
					MainGui["HBConditionText" i].Text := "Until: " HotbarMax%i% "%"
					MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
					MainGui["HBText" i].Visible := 0
					MainGui["HotbarTime" i].Visible := 1
					MainGui["HBTimeText" i].Visible := 1
					MainGui["HBConditionText" i].Visible := 1
					MainGui["HotbarMax" i].Visible := 1
				}

				case "never":
				MainGui["HotbarTime" i].Visible := 0
				MainGui["HBTimeText" i].Visible := 0
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 0

				default:
				HotbarTime%i% := MainGui["HotbarTime" i].Value
				MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
				MainGui["HBConditionText" i].Visible := 0
				MainGui["HotbarMax" i].Visible := 0
				MainGui["HBText" i].Visible := 0
				MainGui["HotbarTime" i].Visible := 1
				MainGui["HBTimeText" i].Visible := 1
			}
			IniWrite HotbarWhile%i%, "settings\nm_config.ini", "Boost", "HotbarWhile" i
		}
	}
}
nm_HotbarTimeUpDown(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	HotbarTime%i% := MainGui["HotbarTime" i].Value
	MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
	IniWrite HotbarTime%i%, "settings\nm_config.ini", "Boost", "HotbarTime" i
}
nm_HotbarEditTime(GuiCtrl, *){
	global HotbarTime2, HotbarTime3, HotbarTime4, HotbarTime5, HotbarTime6, HotbarTime7
	MainGui.Opt("+OwnDialogs")
	i := SubStr(GuiCtrl.Name, -1)
	time := InputBox("Enter the number of seconds (1-99999) to wait between each use of Hotbar " i ":", "Hotbar Slot Time", "T30").Value
	if (time ~= "i)^\d{1,5}$")
	{
		MainGui["HotbarTime" i].Value := HotbarTime%i% := time
		MainGui["HBTimeText" i].Text := hmsFromSeconds(HotbarTime%i%)
		IniWrite HotbarTime%i%, "settings\nm_config.ini", "Boost", "HotbarTime" i
	}
	else if (time != "")
		MsgBox "You must enter a valid number of seconds between 1 and 99999!", "Hotbar Slot Time", 0x40030 " T20"
}
nm_hotbarMaxUpDown(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	MainGui["HBConditionText" i].Text := "Until: " GuiCtrl.Value "%"
	IniWrite (HotbarMax%i% := GuiCtrl.Value), "settings\nm_config.ini", "Boost", "HotbarMax" i
}
nm_ShrineIndexOption(*) {
	global ShrineIndexOption, ShrineIndex
	ShrineIndexOption := MainGui["ShrineIndexOption"].Value
	if(ShrineIndexOption)
		MainGui["ShrineIndex"].Enabled := 0
	else
		MainGui["ShrineIndex"].Enabled := 1
}
ba_setShrineData(GuiCtrl, *){
	global
	local i := SubStr(GuiCtrl.Name, -1)
	static uiList := ["ShrineItem", "ShrineLeft", "ShrineRight", "ShrineAddSlot", "ShrineAmountText", "ShrineAmount"
		, "ShrineAmountNum", "ShrineRepeatText", "ShrineIndexOption", "ShrineIndexNum", "ShrineIndex"
		, "shrineline1", "shrinetitle1", "shrineline2", "shrineline3", "shrineline4"]

	if (ShrineItem%i% = "None") {
		ShrineaddIndex := i, ShrineAdd := i
		loop 2 {
			MainGui["ShrineAdd" A_Index].Visible := 0
			MainGui["ShrineData" A_Index].Visible := 0
			MainGui["ShrineItem" A_Index "Picture"].Visible := 0
		}

		MainGui["ShrineAmount"].Value := ShrineAmount%i%
		MainGui["ShrineIndex"].Value := ((ShrineIndex%i% != "Infinite" && ShrineIndex%i% != "∞") ? ShrineIndex%i% : 1)
		ba_AddShrineItemButton()
		MainGui["ShrineIndexOption"].Value := 0
		MainGui["ShrineIndex"].Enabled := 1
		MainGui["ShrineAddSlot"].Text := "Add to Slot " shrineaddIndex

		For ui in uiList
			MainGui[ui].Visible := 1
	} else {
		ShrineItem%i% := "None", ShrineAmount%i% := 0, ShrineIndex%i% := 1

		IniWrite "None", "settings\nm_config.ini", "Shrine", "ShrineItem" i
		IniWrite 0, "settings\nm_config.ini", "Shrine", "ShrineAmount" i
		IniWrite 1, "settings\nm_config.ini", "Shrine", "ShrineIndex" i

		MainGui["ShrineAdd" i].Text := ((ShrineItem%i% = "None" || ShrineItem%i% = "") ? "Add" : "Clear")
		MainGui["ShrineData" i].Text := "(" ShrineAmount%i% ") [" ((ShrineIndex%i% = "Infinite") ? "∞" : ShrineIndex%i%) "]"

		MainGui["ShrineItem" i "Picture"].Value := ""
	}
}
ba_AddShrineItemButton(GuiCtrl?, *){
	global AddShrineItem, ShrineAdd, hBitmapsSB
	static items := ["RedExtract", "BlueExtract", "BlueBerry", "Pineapple", "StrawBerry"
		, "Sunflower", "Enzymes", "Oil", "Glue", "TropicalDrink", "Gumdrops", "MoonCharms"
		, "Glitter", "StarJelly", "PurplePotion", "CloudVial", "AntPass", "SoftWax"
		, "HardWax", "SwirledWax", "CausticWax", "FieldDice", "SmoothDice", "LoadedDice", "Turpentine"], i := 0, h := 0

	if (h != ShrineAdd)
		i := 0, h := ShrineAdd
	i := Mod(items.Length + i + (IsSet(GuiCtrl) ? ((GuiCtrl.Name = "ShrineLeft") ? -1 : 1) : 0), items.Length), AddShrineItem := items[i+1]
	SetImage(MainGui["ShrineItem"].Hwnd, hBitmapsSB[AddShrineItem])
}
ba_AddShrineItem(*){
	global
	local ShrineIndex, ShrineAmount, ShrineIndexOption, ShrineIndex
	static uiList := ["ShrineItem", "ShrineLeft", "ShrineRight", "ShrineAddSlot", "ShrineAmountText", "ShrineAmount"
		, "ShrineAmountNum", "ShrineRepeatText", "ShrineIndex", "ShrineIndexOption", "ShrineIndexNum", "ShrineIndex"
		, "shrineline1", "shrinetitle1", "shrineline2", "shrineline3", "shrineline4"]

	ShrineIndex := MainGui["ShrineIndex"].Value
	ShrineAmount := MainGui["ShrineAmount"].Value
	ShrineIndexOption := MainGui["ShrineIndexOption"].Value
	ShrineIndex := ((ShrineIndexOption) ? "Infinite" : ShrineIndex)

	IniWrite (ShrineItem%ShrineaddIndex% := AddShrineItem), "settings\nm_config.ini", "Shrine", "ShrineItem" ShrineaddIndex
	IniWrite (ShrineIndex%ShrineaddIndex% := ShrineIndex), "settings\nm_config.ini", "Shrine", "ShrineIndex" ShrineaddIndex
	IniWrite (ShrineAmount%ShrineaddIndex% := ShrineAmount), "settings\nm_config.ini", "Shrine", "ShrineAmount" ShrineaddIndex

	MainGui["ShrineItem" ShrineaddIndex "Picture"].Value := hBitmapsSB[ShrineItem%ShrineaddIndex%] ? ("HBITMAP:*" hBitmapsSB[ShrineItem%ShrineaddIndex%]) : ""
	MainGui["ShrineData" ShrineaddIndex].Text := "(" ShrineAmount%ShrineaddIndex% ") [" ((ShrineIndex%ShrineaddIndex% = "Infinite") ? "∞" : ShrineIndex%ShrineaddIndex%) "]"
	MainGui["ShrineAdd" ShrineaddIndex].Text := ((AddShrineItem = "None" || AddShrineItem = "") ? "Add" : "Clear")

	For ui in uiList
		MainGui[ui].Visible := 0
	loop 2 {
		MainGui["ShrineAdd" A_Index].Visible := 1
		MainGui["ShrineData" A_Index].Visible := 1
		MainGui["ShrineItem" A_Index "Picture"].Visible := 1
	}
	ShrineAdd := 0
}
nm_StickerStackCheck(*){
	global
	local c
	StickerStackCheck := MainGui["StickerStackCheck"].Value
	c := (StickerStackCheck = 1)
	MainGui["SSILeft"].Enabled := c
	MainGui["SSIRight"].Enabled := c
	MainGui["SSMLeft"].Enabled := c
	MainGui["SSMRight"].Enabled := c
	MainGui["StickerStackTimer"].Enabled := c
	MainGui["StickerStackItemHelp"].Enabled := c
	MainGui["StickerStackModeHelp"].Enabled := c
	MainGui["StickerStackSkinsHelp"].Enabled := c
	if (((c = 1) && InStr(StickerStackItem, "Sticker")) || (c = 0)) {
		MainGui["StickerStackHive"].Enabled := c
		MainGui["StickerStackCub"].Enabled := c
		MainGui["StickerStackVoucher"].Enabled := c
	}
	IniWrite StickerStackCheck, "settings\nm_config.ini", "Boost", "StickerStackCheck"
}
nm_StickerStackItem(GuiCtrl, *){
	global StickerStackItem
	static val := ["Tickets", "Sticker", "Sticker+Tickets"], l := val.Length

	if (StickerStackItem = "Tickets")
	{
		if (msgbox("Consider trading all of your valuable stickers to alternative account, to ensure that you do not lose any valuable stickers. Are you sure you want to use Stickers?", "Sticker Stack", 0x1034 " T60 Owner" MainGui.Hwnd) = "Yes")
			i := 1
		else
			return
	}
	else
		i := (StickerStackItem = "Sticker") ? 2 : 3

	MainGui["StickerStackItem"].Text := StickerStackItem := val[(GuiCtrl.Name = "SSIRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	MainGui["StickerStackHive"].Enabled := MainGui["StickerStackCub"].Enabled := MainGui["StickerStackVoucher"].Enabled := (InStr(StickerStackItem, "Sticker") > 0)
	IniWrite StickerStackItem, "settings\nm_config.ini", "Boost", "StickerStackItem"
}
nm_StickerStackMode(GuiCtrl?, *){
	global StickerStackMode

	if IsSet(GuiCtrl)
		StickerStackMode := (StickerStackMode != 1)

	if (StickerStackMode = 0) {
		MainGui["StickerStackModeText"].Move(, , 85), MainGui["StickerStackModeText"].Redraw(), MainGui["StickerStackModeText"].Text := "Detect"
		MainGui["StickerStackTimer"].Visible := 0
	} else {
		MainGui["StickerStackModeText"].Move(, , 68), MainGui["StickerStackModeText"].Redraw(), MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer)
		MainGui["StickerStackTimer"].Visible := 1
	}

	IniWrite StickerStackMode, "settings\nm_config.ini", "Boost", "StickerStackMode"
}
nm_StickerStackTimer(*){
	global StickerStackTimer
	StickerStackTimer := MainGui["StickerStackTimer"].Value
	MainGui["StickerStackModeText"].Opt("-Redraw"), MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer), MainGui["StickerStackModeText"].Opt("+Redraw")
	IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
}
nm_StickerStackModeText(*){
	global StickerStackMode, StickerStackTimer
	if (StickerStackMode = 1) {
		if IsInteger(time := InputBox("Enter the number of seconds (900-86400) to wait between each use of the Sticker Stack:", "Sticker Stack Timer", "T60").Value)
		{
			if ((time >= 900) && (time <= 86400)) {
				MainGui["StickerStackTimer"].Value := StickerStackTimer := time
				MainGui["StickerStackModeText"].Text := hmsFromSeconds(StickerStackTimer)
				IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
			} else {
				msgbox "You must enter an integer between 900 and 86400!", "Sticker Stack Timer", 0x40030 " T20"
			}
		} else {
			msgbox "You must enter an integer!", "Sticker Stack Timer", 0x40030 " T20"
		}
	}
}
nm_StickerStackSkins(GuiCtrl, *){
	global
	%GuiCtrl.Name% := GuiCtrl.Value
	if (%GuiCtrl.Name% = 1) {
		%GuiCtrl.Name% := GuiCtrl.Value := 0
		if (msgbox("You have enabled the use of " StrReplace(GuiCtrl.Name, "StickerStack") . (GuiCtrl.Name != "StickerStackVoucher" ? " Skins":"s") " on the Sticker Stack!`nAre you sure you want to enable this?", "WARNING!!", 0x40034 " T60") = "Yes")
			%GuiCtrl.Name% := GuiCtrl.Value := 1
	}
	IniWrite GuiCtrl.Value, "settings\nm_config.ini", "Boost", GuiCtrl.Name
}
nm_StickerStackItemHelp(*){
	msgbox "
	(
	Choose the item you prefer to use for activating the Sticker Stack!

	'Tickets' is the default option: it will use the 25 Tickets option to activate the boost.

	'Sticker' is an option if you want to stack your Stickers. It will always use your first Sticker if there is one, otherwise it will stop using the Sticker Stack.

	'Sticker+Tickets' is an option that uses all of your Stickers first, then uses your Tickets once you have run out of Stickers.
	)", "Sticker Stack Item", 0x40000 " T60"
}
nm_StickerStackModeHelp(*){
	msgbox "
	(
	Choose how long you want to wait between each Sticker Stack boost!

	'Detect' is the default option: it will detect the time each boost lasts and will go back to activate the Sticker Stack when it's over.

	The other option is a custom timer, you can set it to any value between 15 minutes and 24 hours, the macro will activate Sticker Stack at this time interval.

	NOTE: If you change from a custom timer to 'Detect', the macro will still use your custom timer for the time until your next visit to the Sticker Stack.
	)", "Sticker Stack Timer", 0x40000 " T60"
}
nm_StickerStackSkinsHelp(*){
	msgbox "
	(
	Choose which Stickers you want to stack on the Sticker Stack.

	If 'Hive' is checked, the macro will donate Hive Skins to the Sticker Stack after all normal Stickers have been used up. Otherwise, these will not be used.

	If 'Cub' is checked, the macro will donate Cub Skins to the Sticker Stack after all normal Stickers and Hive Skins (if enabled) have been used up. Otherwise, these will not be used.

	If 'Voucher' is checked, the macro will donate Vouchers to the Sticker Stack after all normal Stickers, Hive Skins, and Cubs (if enabled) have been used up. Otherwise, these will not be used.

	)", "Sticker Stack Skins", 0x40000 " T60"
}
nm_StickerPrinterCheck(*){
	global
	StickerPrinterCheck := MainGui["StickerPrinterCheck"].Value
	MainGui["SPELeft"].Enabled := MainGui["SPERight"].Enabled := (StickerPrinterCheck = 1)
	IniWrite StickerPrinterCheck, "settings\nm_config.ini", "Collect", "StickerPrinterCheck"
}
nm_StickerPrinterEgg(GuiCtrl, *){
	global StickerPrinterEgg
	static val := ["Basic", "Silver", "Gold", "Diamond", "Mythic"], l := val.Length

	switch StickerPrinterEgg, 0
	{
		case "Basic":
		i := 1
		case "Silver":
		i := 2
		case "Gold":
		i := 3
		case "Diamond":
		i := 4
		default:
		i := 5
	}

	MainGui["StickerPrinterEgg"].Text := StickerPrinterEgg := val[(GuiCtrl.Name = "SPERight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite StickerPrinterEgg, "settings\nm_config.ini", "Collect", "StickerPrinterEgg"
}
nm_BoostChaserCheck(*){
	global BoostChaserCheck, AutoFieldBoostActive
	IniWrite (BoostChaserCheck := MainGui["BoostChaserCheck"].Value), "settings\nm_config.ini", "Boost", "BoostChaserCheck"
	;disable AutoFieldBoost (mutually exclusive features)
	if (BoostChaserCheck = 1) {
		(IsSet(AFBGui) && IsObject(AFBGui)) && (AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 0)
		IniWrite 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
	}
}
nm_BoostedFieldSelectButton(*){
	global BoostedFieldSelectGui
	GuiClose(*){
		if (IsSet(BoostedFieldSelectGui) && IsObject(BoostedFieldSelectGui))
			BoostedFieldSelectGui.Destroy(), BoostedFieldSelectGui := ""
	}
	GuiClose()
	BoostedFieldSelectGui := Gui("+AlwaysOnTop +Border", "Select boosted gather fields")
	BoostedFieldSelectGui.OnEvent("Close", GuiClose)
	BoostedFieldSelectGui.Add("Text", "x9 y10", "
	(
	This option allows you to select which fields to gather in, if boosted.
	If the free field booster boosts a field that is not selected here,
	the macro will ignore it and continue with other tasks.
	)")
	BoostedFieldSelectGui.SetFont("Norm")
	BoostedFieldSelectGui.Add("Text", "x10 y54", "Blue")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vBlueFlowerBoosterCheck Checked" BlueFlowerBoosterCheck, "Blue Flower")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vBambooBoosterCheck Checked" BambooBoosterCheck, "Bamboo")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPineTreeBoosterCheck Checked" PineTreeBoosterCheck, "Pine Tree")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vStumpBoosterCheck Checked" StumpBoosterCheck, "Stump")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)

	BoostedFieldSelectGui.Add("Text", "x10 y138", "Other")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vCoconutBoosterCheck Checked" CoconutBoosterCheck, "Coconut")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_coconutBoosterCheck)

	BoostedFieldSelectGui.Add("Text", "x134 y54", "Mountain top")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vDandelionBoosterCheck Checked" DandelionBoosterCheck, "Dandelion")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vSunflowerBoosterCheck Checked" SunflowerBoosterCheck, "Sunflower")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vCloverBoosterCheck Checked" CloverBoosterCheck, "Clover")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vSpiderBoosterCheck Checked" SpiderBoosterCheck, "Spider")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPineappleBoosterCheck Checked" PineappleBoosterCheck, "Pineapple")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vCactusBoosterCheck Checked" CactusBoosterCheck, "Cactus")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPumpkinBoosterCheck Checked" PumpkinBoosterCheck, "Pumpkin")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)

	BoostedFieldSelectGui.Add("Text", "x256 y54", "Red")
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp-2 yp+18 vMushroomBoosterCheck Checked" MushroomBoosterCheck, "Mushroom")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vStrawberryBoosterCheck Checked" StrawberryBoosterCheck, "Strawberry")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vRoseBoosterCheck Checked" RoseBoosterCheck, "Rose")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	(GuiCtrl := BoostedFieldSelectGui.Add("CheckBox", "xp yp+14 vPepperBoosterCheck Checked" PepperBoosterCheck, "Pepper")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	BoostedFieldSelectGui.Show("w335 h175")
}
nm_coconutBoosterCheck(*){
	global CoconutBoosterCheck, CoconutDisCheck, BoostChaserCheck
	BoostedFieldSelectGui.Opt("+OwnDialogs")
	IniWrite (CoconutBoosterCheck := BoostedFieldSelectGui["CoconutBoosterCheck"].Value), "settings\nm_config.ini", "Boost", "CoconutBoosterCheck"
	if(BoostChaserCheck && CoconutBoosterCheck) {
		MainGui["CoconutDisCheck"].Value := CoconutDisCheck := 1
		IniWrite 1, "settings\nm_config.ini", "Collect", "CoconutDisCheck"
		msgbox "Coconut Dispenser collection has been automatically enabled in the Collect Tab. This will allow the macro to boost and gather in coconut field every four hours.", "Coconut Dispenser Enabled!"
	}
}
nm_autoFieldBoostGui(*){
	global
	local GuiCtrl
	GuiClose(*){
		if (IsSet(AFBGui) && IsObject(AFBGui))
			AFBGui.Destroy(), AFBGui := ""
	}
	GuiClose()
	AFBGui := Gui("+Border", "Auto Field Boost Settings")
	AFBGui.OnEvent("Close", GuiClose)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("CheckBox", "x5 y5 vAutoFieldBoostActive Checked" AutoFieldBoostActive, "Activate Automatic Field Boost for Gathering Field:").OnEvent("Click", nm_autoFieldBoostCheck)
	AFBGui.SetFont("w800 cBlue")
	AFBGui.Add("Text", "x270 y5 left vAFBcurrentField", currentField)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("Button", "x20 y22 w120 h15", "What does this do?").OnEvent("Click", nm_AFBHelpButton)
	AFBGui.Add("Text", "x5 y42 w355 h1 0x7")
	AFBGui.Add("Text", "x20 y48", "Re-Buff Field Boost Every:")
	(GuiCtrl := AFBGui.Add("DropDownList", "x147 y46 w45 h150 vAutoFieldBoostRefresh", [8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15])).Text := AutoFieldBoostRefresh
	GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x195 y48", "Minutes")
	AFBGui.Add("Button", "x5 y48 w10 h15", "?").OnEvent("Click", nm_AFBRebuffHelpButton)
	AFBGui.Add("Text", "x20 y70 +BackgroundTrans", "Use")
	AFBGui.Add("Text", "x5 y86 w355 h1 0x7")
	AFBGui.SetFont("s10")
	AFBGui.Add("Button", "x5 y90 w10 h15", "?").OnEvent("Click", nm_AFBDiceEnableHelpButton)
	AFBGui.Add("CheckBox", "x20 y90 vAFBDiceEnable Checked" AFBDiceEnable, "Dice:").OnEvent("Click", nm_AFBDiceEnableCheck)
	AFBGui.Add("Button", "x5 y113 w10 h15", "?").OnEvent("Click", nm_AFBGlitterEnableHelpButton)
	AFBGui.Add("CheckBox", "x20 y113 vAFBGlitterEnable Checked" AFBGlitterEnable, "Glitter:").OnEvent("Click", nm_AFBGlitterEnableCheck)
	AFBGui.Add("Button", "x5 y136 w10 h15", "?").OnEvent("Click", nm_AFBFieldEnableHelpButton)
	(GuiCtrl := AFBGui.Add("CheckBox", "x20 y136 vAFBFieldEnable Checked" AFBFieldEnable, "Free Field Boosters")).Section := "Boost", GuiCtrl.OnEvent("Click", nm_saveConfig)
	AFBGui.SetFont("s8 cDefault Norm", "Tahoma")
	AFBGui.Add("Text", "x80 y70 +BackgroundTrans", "Hotbar Slot")
	(GuiCtrl := AFBGui.Add("DropDownList", "x80 y88 w50 h120 vAFBDiceHotbar Disabled" (!AFBDiceEnable), ["None",2,3,4,5,6,7])).Text := AFBDiceHotbar, GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := AFBGui.Add("DropDownList", "x80 y110 w50 h120 vAFBGlitterHotbar Disabled" (!AFBGlitterEnable), ["None",2,3,4,5,6,7])).Text := AFBGlitterHotbar, GuiCtrl.Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x160 y73 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y83 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y93 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y103 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y113 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y123 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y133 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y143 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y153 +BackgroundTrans", "|")
	AFBGui.Add("Text", "x160 y163 +BackgroundTrans", "|")
	AFBGui.Add("Button", "x170 y70 w10 h15", "?").OnEvent("Click", nm_AFBDeactivationLimitsHelpButton)
	AFBGui.Add("Text", "x185 y70 cRED +BackgroundTrans", "DEACTIVATION LIMITS:")
	AFBGui.Add("Text", "x298 y42 +BackgroundTrans", "Reset Used:")
	AFBGui.Add("Button", "x318 y55 w40 h15", "Dice").OnEvent("Click", nm_resetUsedDice)
	AFBGui.Add("Button", "x318 y70 w40 h15", "Glitter").OnEvent("Click", nm_resetUsedGlitter)
	;AFBGui.Add("Text", "x155 y40 +BackgroundTrans", "Set Limits")
	AFBGui.Add("Button", "x170 y90 w10 h15", "?").OnEvent("Click", nm_AFBDiceLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y88 w50 h120 vAFBDiceLimitEnableSel Disabled" (!AFBDiceEnable), ["Limit", "None"])).Text := AFBDiceLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBDiceLimitEnable)
	AFBGui.Add("Button", "x170 y113 w10 h15", "?").OnEvent("Click", nm_AFBGlitterLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y110 w50 h120 vAFBGlitterLimitEnableSel Disabled" (!AFBGlitterEnable), ["Limit", "None"])).Text := AFBGlitterLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBGlitterLimitEnable)
	AFBGui.Add("Button", "x170 y156 w10 h15", "?").OnEvent("Click", nm_AFBHoursLimitEnableHelpButton)
	(GuiCtrl := AFBGui.Add("DropDownList", "x185 y152 w50 h120 vAFBHoursLimitEnableSel", ["Limit", "None"])).Text := AFBHoursLimitEnable ? "Limit" : "None", GuiCtrl.OnEvent("Change", nm_AFBHoursLimitEnable)
	AFBGui.Add("Text", "x240 y90 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y90 +BackgroundTrans", "Dice Used")
	AFBGui.Add("Text", "x240 y113 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y113 +BackgroundTrans", "Glitter Used")
	AFBGui.Add("Text", "x240 y156 +BackgroundTrans", "to")
	AFBGui.Add("Text", "x305 y156 +BackgroundTrans", "Hours")
	(GuiCtrl := AFBGui.Add("Edit", "x255 y88 w45 h20 limit6 number vAFBDiceLimit Disabled" (!AFBDiceLimitEnable || !AFBDiceEnable), AFBDiceLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	(GuiCtrl := AFBGui.Add("Edit", "x255 y110 w45 h20 limit6 number vAFBGlitterLimit Disabled" (!AFBGlitterLimitEnable || !AFBGlitterEnable), AFBGlitterLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AFBGui.Add("Text", "x185 y136 +BackgroundTrans", "Deactivate Field Boosting After:")
	(GuiCtrl := AFBGui.Add("Edit", "x255 y152 w45 h20 limit6 Number vAFBHoursLimit Disabled" (!AFBHoursLimitEnable), AFBHoursLimit)).Section := "Boost", GuiCtrl.OnEvent("Change", nm_saveConfig)
	;AFBGui.Add("Text", "x5 y123 +BackgroundTrans", "________________________________________________________")
	AFBGui.Show("w360 h170")
}
nm_AFBHelpButton(*){
	MsgBox "
	(
	PURPOSE:
	This option will use the selected Dice, Glitter, and Field Boosters automatically to build and maintain a field boost for your current gathering field (as defined in the Main tab).

	THIS DOES NOT:
	* quickly build your boost multiplier up to x4.  If this is what you want then it is best to manually do this before using this feature.
	* use items from your inventory.  You must include the Dice and Glitter on your hotbar and make sure the slots match the settings.

	HOW IT WORKS:
	This field boost will be Re-buffed at the interval defined in the settings.
	It will use the items that are selected in the following priority:
	1) Free Field Booster, 2) Dice, 3) Glitter.
	The Dice and Glitter item uses will be alternated so it can stack field boosts.
	If there are any deactivation limits set, this option will disable itself once both the Dice and Glitter or the Hours limits have been reached.

	RECOMMENDATIONS:
	It is highly recommended to disable all other macro options except your gathering field.
	This will ensure you are actually benefiting from the use of your materials!

	Please reference the various "?" buttons for additional information.
	)", "Auto Field Boost Description"
}
nm_AFBRebuffHelpButton(*){
	MsgBox "This setting defines the time interval between each Field Boost buff.", "Re-Buff Field Boost"
}
nm_AFBDiceEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use Field Dice (NOT Smooth or Loaded) to boost your current gathering field.
	The Hotbar Slot indicates which slot on your hotbar contains these dice.

	These Dice will be re-rolled until your your gathering field is boosted.
	If Glitter is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.

	CAUTION!!
	This can use up a lot of dice quickly!
	If you would like to limit the number of dice used for this, then make sure to set a limit for them in the DEACTIVATION LIMITS.
	)", "Enable Dice Use"
}
nm_AFBGlitterEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use Glitter to boost your current gathering field.
	The Hotbar Slot indicates which slot on your hotbar contains these dice.

	The macro will only attempt to use Glitter if you are currently in the field.
	If Dice is also selected the macro will alternate between using Dice and Glitter so it will stack Field Boost multipliers.
	)", "Enable Glitter Use"
}
nm_AFBFieldEnableHelpButton(*){
	MsgBox "
	(
	This setting indicates if you would like to use the Free Field Boosters (Blue, Red, or Mountain Top) to boost your current gathering field.

	The macro will determine which Field Booster applies for your current gathering field and will use the Free Field Booster first if it available.
	If this does not boost your gathering field, the macro will use Dice or Glitter instead (if enabled in settings).
	)", "Enable Free Field Booster Use"
}
nm_AFBDeactivationLimitsHelpButton(*){
	MsgBox "
	(
	These settings are limits that you can set to deactivate (turn off) Auto Field Boost.

	If any of the limits defined are met, then Auto Field Boost will be deactivated.
	)", "Deactivation Limits"
}
nm_AFBDiceLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of dice are used.

	The setting of "None" indicates that there is no Dice use limit.
	The macro will continue to use Dice for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the used Dice is reset each time you activate Auto Field Boost, enable Dice, or press the Reset Used: 'Dice' button.
	)", "Dice Limit Deactivation"
}
nm_AFBGlitterLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Glitter are used.

	The setting of "None" indicates that there is no Glitter use limit.
	The macro will continue to use Glitter for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the used Glitter is reset each time you activate Auto Field Boost, enable Glitter, or press the Reset Used: 'Glitter' button.
	)", "Glitter Limit Deactivation"
}
nm_AFBHoursLimitEnableHelpButton(*){
	MsgBox "
	(
	The setting of "Limit" will cause Auto Field Boost to become deactivated (turned off) after the specified total number of Hours have elapsed since starting the macro.

	The setting of "None" indicates that there is no Hours limit.
	The macro will continue use Dice and/or Glitter (if enabled in settings) for as long as Auto Field Boost is enabled.

	NOTE:
	The counter for the elapsed Hours is reset each time you stop the macro (F3).
	)", "Hours Limit Deactivation"
}
nm_resetUsedDice(*){
	global AFBdiceUsed:=0
	IniWrite AFBdiceUsed, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
}
nm_resetUsedGlitter(*){
	global AFBglitterUsed:=0
	IniWrite 0, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
}
nm_autoFieldBoostCheck(*){
	global
	if ((AutoFieldBoostActive := AFBGui["AutoFieldBoostActive"].Value) = 1) {
		if (MsgBox("
		(
		You have selected to "Activate Automatic Field Boost".

		If no DEACTIVATION LIMITS are set then this option will continue to use the selected items until they are completely gone.

		Please make ABSOLUTELY SURE that the settings you have selected are correct!
		)", "WARNING!!", 1) = "Ok")
		{
			AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 1
			IniWrite AFBdiceUsed:=0, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
			IniWrite AFBglitterUsed:=0, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
			MainGui["BoostChaserCheck"].Value := BoostChaserCheck := 0
			IniWrite 0, "settings\nm_config.ini", "Boost", "BoostChaserCheck"
		} else {
			AFBGui["AutoFieldBoostActive"].Value := AutoFieldBoostActive := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
		}
	}
	IniWrite AutoFieldBoostActive, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
	MainGui["AutoFieldBoostButton"].Text := AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]"
}
nm_AFBDiceEnableCheck(*){
	global
	AFBDiceEnable := AFBGui["AFBDiceEnable"].Value
	AFBDiceLimitEnableSel := AFBGui["AFBDiceLimitEnableSel"].Text
	if(not AFBDiceEnable){
		AFBGui["AFBDiceHotbar"].Enabled := 0
		AFBGui["AFBDiceLimitEnableSel"].Enabled := 0
		AFBGui["AFBDiceLimit"].Enabled := 0
	} else {
		AFBGui["AFBDiceHotbar"].Enabled := 1
		AFBGui["AFBDiceLimitEnableSel"].Enabled := 1
		AFBGui["AFBDiceLimit"].Enabled := (AFBDiceLimitEnableSel="Limit")
		IniWrite AFBdiceUsed:=0, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
	}
	IniWrite AFBDiceEnable, "settings\nm_config.ini", "Boost", "AFBDiceEnable"
}
nm_AFBGlitterEnableCheck(*){
	global
	AFBGlitterEnable := AFBGui["AFBGlitterEnable"].Value
	AFBGlitterLimitEnableSel := AFBGui["AFBGlitterLimitEnableSel"].Text
	if(not AFBGlitterEnable){
		AFBGui["AFBGlitterHotbar"].Enabled := 0
		AFBGui["AFBGlitterLimitEnableSel"].Enabled := 0
		AFBGui["AFBGlitterLimit"].Enabled := 0
	} else {
		AFBGui["AFBGlitterHotbar"].Enabled := 1
		AFBGui["AFBGlitterLimitEnableSel"].Enabled := 1
		AFBGui["AFBGlitterLimit"].Enabled := (AFBGlitterLimitEnableSel="Limit")
		IniWrite AFBglitterUsed:=0, "settings\nm_config.ini", "Boost", "AFBGlitterUsed"
	}
	IniWrite AFBGlitterEnable, "settings\nm_config.ini", "Boost", "AFBGlitterEnable"
}
nm_AFBDiceLimitEnable(*){
	global
	AFBDiceLimitEnableSel := AFBGui["AFBDiceLimitEnableSel"].Text
	IniWrite (AFBGui["AFBDiceLimit"].Enabled := (AFBDiceLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBDiceLimitEnable"
}
nm_AFBGlitterLimitEnable(*){
	global
	AFBGlitterLimitEnableSel := AFBGui["AFBGlitterLimitEnableSel"].Text
	IniWrite (AFBGui["AFBGlitterLimit"].Enabled := (AFBGlitterLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBGlitterLimitEnable"
}
nm_AFBHoursLimitEnable(*){
	global
	AFBHoursLimitEnableSel := AFBGui["AFBHoursLimitEnableSel"].Text
	IniWrite (AFBGui["AFBHoursLimit"].Enabled := (AFBHoursLimitEnableSel="Limit")), "settings\nm_config.ini", "Boost", "AFBHoursLimitEnable"
}

; QUESTS TAB
; ------------------------
nm_BlackQuestCheck(*){
	global
	IniWrite (BlackQuestCheck := MainGui["BlackQuestCheck"].Value), "settings\nm_config.ini", "Quests", "BlackQuestCheck"
	if (BlackQuestCheck = 1)
		MsgBox "This option only works for the repeatable quests. You must first complete the main questline before this option will work properly.", "Black Bear Quest", "Owner" MainGui.Hwnd
}
nm_BuckoQuestCheck(*){
	global
	IniWrite (BuckoQuestCheck := MainGui["BuckoQuestCheck"].Value), "settings\nm_config.ini", "Quests", "BuckoQuestCheck"
	IniWrite (BuckoQuestGatherInterruptCheck := MainGui["BuckoQuestGatherInterruptCheck"].Value), "settings\nm_config.ini", "Quests", "BuckoQuestGatherInterruptCheck"
	if ((BuckoQuestCheck = 1) && (AntPassCheck = 0)) {
		IniWrite (MainGui["AntPassCheck"].Value := AntPassCheck := 1), "settings\nm_config.ini", "Collect", "AntPassCheck"
		IniWrite (MainGui["AntPassAction"].Text := AntPassAction := "Pass"), "settings\nm_config.ini", "Collect", "AntPassAction"
		MsgBox 'Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.', "Bucko Bee Quest", "Owner" MainGui.Hwnd
	}
}
nm_RileyQuestCheck(*){
	global
	IniWrite (RileyQuestCheck := MainGui["RileyQuestCheck"].Value), "settings\nm_config.ini", "Quests", "RileyQuestCheck"
	IniWrite (RileyQuestGatherInterruptCheck := MainGui["RileyQuestGatherInterruptCheck"].Value), "settings\nm_config.ini", "Quests", "RileyQuestGatherInterruptCheck"
	if ((RileyQuestCheck = 1) && (AntPassCheck = 0)) {
		IniWrite (MainGui["AntPassCheck"].Value := AntPassCheck := 1), "settings\nm_config.ini", "Collect", "AntPassCheck"
		IniWrite (MainGui["AntPassAction"].Text := AntPassAction := "Pass"), "settings\nm_config.ini", "Collect", "AntPassAction"
		MsgBox 'Ant Pass collection has been automatically enabled so the passes can be stockpiled for the "Picnic" quest.', "Riley Bee Quest", "Owner" MainGui.Hwnd
	}
}
nm_QuestGatherReturnBy(GuiCtrl, *){
	global QuestGatherReturnBy
	static val := ["Walk", "Reset"], l := val.Length

	i := (QuestGatherReturnBy = "Walk") ? 1 : 2

	MainGui["QuestGatherReturnBy"].Text := QuestGatherReturnBy := val[(GuiCtrl.Name = "QGRBRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite QuestGatherReturnBy, "settings\nm_config.ini", "Quests", "QuestGatherReturnBy"
}

; PLANTERS TAB
; ------------------------
ba_planterSwitch(*){
	global
	static PlantersPlusControls := ["N1Priority","N2Priority","N3Priority","N4Priority","N5Priority"
		,"N1MinPercent","N2MinPercent","N3MinPercent","N4MinPercent","N5MinPercent"
		,"N1MinPercentUpDown","N2MinPercentUpDown","N3MinPercentUpDown","N4MinPercentUpDown","N5MinPercentUpDown"
		,"DandelionFieldCheck","SunflowerFieldCheck","MushroomFieldCheck","BlueFlowerFieldCheck","CloverFieldCheck","SpiderFieldCheck","StrawberryFieldCheck","BambooFieldCheck"
		,"PineappleFieldCheck","StumpFieldCheck","PumpkinFieldCheck","PineTreeFieldCheck","RoseFieldCheck","MountainTopFieldCheck","CactusFieldCheck","CoconutFieldCheck","PepperFieldCheck"
		,"Text1","Text2","Text3","Text4","Text5"
		,"TextLine1","TextLine2","TextLine3","TextLine4","TextLine5","TextLine6","TextLine7"
		,"TextZone1","TextZone2","TextZone3","TextZone4","TextZone5","TextZone6"
		,"NPreset","TextPresets","TextNp","TextMin"
		,"PlasticPlanterCheck","CandyPlanterCheck","BlueClayPlanterCheck","RedClayPlanterCheck","TackyPlanterCheck","PesticidePlanterCheck"
		,"HeatTreatedPlanterCheck","HydroponicPlanterCheck","PetalPlanterCheck","PlanterOfPlentyCheck","PaperPlanterCheck","TicketPlanterCheck"
		,"TextHarvest","HarvestFullGrown","gotoPlanterField","gatherFieldSipping","TextHours","TextMax","MaxAllowedPlanters","MaxAllowedPlantersText"
		,"TextAllowedPlanters","TextAllowedFields","TimersButton","AutomaticHarvestInterval","ConvertFullBagHarvest","GatherPlanterLoot","TextBox1"
		,"NPLeft","NPRight","NP1Left","NP1Right","NP2Left","NP2Right","NP3Left","NP3Right","NP4Left","NP4Right","NP5Left","NP5Right"]
	, ManualPlantersControls := ["MHeader1Text","MHeader2Text","MHeader3Text"
		,"MSlot1PlanterText","MSlot1FieldText","MSlot1SettingsText","MSlot1SeparatorLine"
		,"MSlot2PlanterText","MSlot2FieldText","MSlot2SettingsText","MSlot2SeparatorLine"
		,"MSlot3PlanterText","MSlot3FieldText","MSlot3SettingsText"
		,"MSectionSeparatorLine","MSliderSeparatorLine"
		,"MSlot1CycleText","MSlot1CycleNo","MSlot1Left","MSlot1Right","MSlot2CycleText","MSlot2CycleNo","MSlot2Left","MSlot2Right","MSlot3CycleText","MSlot3CycleNo","MSlot3Left","MSlot3Right"
		,"MCurrentCycle","MHarvestText","MHarvestInterval","MHarvestSeparatorLine","MPageLeft","MPageNumberText","MPageRight", "MPagesSeparatorLine" 
		,"MPuffModeSeparatorLine","MPuffModeHelp","MPuffModeText","MPuffModeA","MPuffMode1","MPuffMode2","MPuffMode3"
		,"MGatherSeparatorLine","MPlanterGatherHelp","MPlanterGatherText","MPlanterGatherA","MPlanterGather1","MPlanterGather2","MPlanterGather3","MConvertFullBagHarvest","MGatherPlanterLoot"
		,"MHILeft","MHIRight"]
	, ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"]
	local i, c, k, v

	PlanterMode := MainGui["PlanterMode"].Value
	MainGui["PlanterMode"].Enabled := 0

	for i,c in [0,1] ; hide first, then show
	{
		if (((i = 1) && (PlanterMode != 2)) || ((i = 2) && (PlanterMode = 2))) ; hide/show all planters+ controls
		{
			for k,v in PlantersPlusControls
				MainGui[v].Visible := c
			MainGui[HarvestFullGrown ? "FullText" : AutomaticHarvestInterval ? "AutoText" : "HarvestInterval"].Visible := c
		}

		if (((i = 1) && (PlanterMode != 1)) || ((i = 2) && (PlanterMode = 1))) ; hide/show all manual planters controls
		{
			for k,v in ManualPlantersControls
				MainGui[v].Visible := c
			Loop 3
			{
				i := A_Index
				for k,v in ManualPlantersOptions
					Loop 3
						MainGui["MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v].Visible := c
			}
		}
	}

	; handle MaxAllowedPlanters
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	if ((PlanterMode = 2) && (MaxAllowedPlanters = 0)) {
		MaxAllowedPlanters:=3
		IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
		MainGui["MaxAllowedPlanters"].Value := 3
	}

	; handle PlanterTimers window
	if (PlanterMode = 0)
	{
		DetectHiddenWindows 1
		if WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
			WinClose
		DetectHiddenWindows 0
	}

	IniWrite PlanterMode, "settings\nm_config.ini", "Planters", "PlanterMode"
	MainGui["PlanterMode"].Enabled := 1
}
ba_showPlanterTimers(*){
	global TimerGuiTransparency, TimerX, TimerY
	DetectHiddenWindows 1
	if WinExist("PlanterTimers.ahk ahk_class AutoHotkey")
		WinClose
	else
		Run '"' exe_path32 '" /script "' A_WorkingDir '\submacros\PlanterTimers.ahk"'
	DetectHiddenWindows 0
}
;Manual Planters
mp_UpdatePage(GuiCtrl?, *)
{
	Static ManualPlantersOptions := ["Planter","Field","Glitter","AutoFull"], LastPageIndex := 1

	Global MPageIndex += IsSet(GuiCtrl) ? ((GuiCtrl.Name = "MPageLeft") ? -1 : 1) : 0

	MainGui["MPageLeft"].Enabled := (MPageIndex != 1)
	MainGui["MPageRight"].Enabled := (MPageIndex != 3)

	If IsSet(GuiCtrl) {
		MainGui["MPageNumberText"].Text := "Page " MPageIndex

		Loop 3 {
			MainGui["MHeader" A_Index "Text"].Text := "Cycle #" ((MPageIndex - 1) * 3 + A_Index)
			i := A_Index
			for v in ManualPlantersOptions {
				Loop 3 {
					MainGui["MSlot" A_Index "Cycle" (3 * (LastPageIndex - 1) + i) v].Visible := 0
					MainGui["MSlot" A_Index "Cycle" (3 * (MPageIndex - 1) + i) v].Visible := 1
				}
			}
		}

		LastPageIndex := MPageIndex
	}
}

mp_UpdateControls() {
	global
	local i, j

	Loop 3 {
		i := A_Index
		Loop 9 {
			MainGui["MSlot" i "Cycle" A_Index "Planter"].Text := (MSlot%i%Cycle%A_Index%Planter ? MSlot%i%Cycle%A_Index%Planter : "")
			MainGui["MSlot" i "Cycle" A_Index "Field"].Text := (MSlot%i%Cycle%A_Index%Field ? MSlot%i%Cycle%A_Index%Field : "")
			MainGui["MSlot" i "Cycle" A_Index "Glitter"].Value := MSlot%i%Cycle%A_Index%Glitter
			MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Text := MSlot%i%Cycle%A_Index%AutoFull
		}
	}

	Loop 3 {
		i := A_Index
		Loop 9 {
			j := A_Index - 1
			If (A_Index != 1)
				MainGui["MSlot" i "Cycle" A_Index "Planter"].Enabled := (MSlot%i%Cycle%j%Field ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "Field"].Enabled := (MSlot%i%Cycle%A_Index%Planter ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "Glitter"].Enabled := (MSlot%i%Cycle%A_Index%Field ? 1 : 0)
			MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Enabled := (MSlot%i%Cycle%A_Index%Field ? 1 : 0)
		}
		j := A_Index - 1
		If (i > 1)
			MainGui["MSlot" i "Cycle1Planter"].Enabled := (MSlot%j%Cycle1Field ? 1 : 0)
	}

	MainGui["MPlanterGather1"].Enabled := (MPlanterGatherA ? 1 : 0)
	MainGui["MPlanterGather2"].Enabled := (MPlanterGatherA ? 1 : 0)
	MainGui["MPlanterGather3"].Enabled := (MPlanterGatherA ? 1 : 0)

	MainGui["MPuffMode1"].Enabled := (MPuffModeA ? 1 : 0)
	MainGui["MPuffMode2"].Enabled := (MPuffModeA ? 1 : 0)
	MainGui["MPuffMode3"].Enabled := (MPuffModeA ? 1 : 0)

	mp_UpdateCycles()

}

mp_SaveConfig(*) {
	global
	local i, j
	global MSlot1Cycle1Planter, MSlot1Cycle2Planter, MSlot1Cycle3Planter, MSlot1Cycle4Planter, MSlot1Cycle5Planter, MSlot1Cycle6Planter, MSlot1Cycle7Planter, MSlot1Cycle8Planter, MSlot1Cycle9Planter
	, MSlot1Cycle1Field, MSlot1Cycle2Field, MSlot1Cycle3Field, MSlot1Cycle4Field, MSlot1Cycle5Field, MSlot1Cycle6Field, MSlot1Cycle7Field, MSlot1Cycle8Field, MSlot1Cycle9Field
	, MSlot1Cycle1Glitter, MSlot1Cycle2Glitter, MSlot1Cycle3Glitter, MSlot1Cycle4Glitter, MSlot1Cycle5Glitter, MSlot1Cycle6Glitter, MSlot1Cycle7Glitter, MSlot1Cycle8Glitter, MSlot1Cycle9Glitter
	, MSlot1Cycle1AutoFull, MSlot1Cycle2AutoFull, MSlot1Cycle3AutoFull, MSlot1Cycle4AutoFull, MSlot1Cycle5AutoFull, MSlot1Cycle6AutoFull, MSlot1Cycle7AutoFull, MSlot1Cycle8AutoFull, MSlot1Cycle9AutoFull
	, MSlot2Cycle1Planter, MSlot2Cycle2Planter, MSlot2Cycle3Planter, MSlot2Cycle4Planter, MSlot2Cycle5Planter, MSlot2Cycle6Planter, MSlot2Cycle7Planter, MSlot2Cycle8Planter, MSlot2Cycle9Planter
	, MSlot2Cycle1Field, MSlot2Cycle2Field, MSlot2Cycle3Field, MSlot2Cycle4Field, MSlot2Cycle5Field, MSlot2Cycle6Field, MSlot2Cycle7Field, MSlot2Cycle8Field, MSlot2Cycle9Field
	, MSlot2Cycle1Glitter, MSlot2Cycle2Glitter, MSlot2Cycle3Glitter, MSlot2Cycle4Glitter, MSlot2Cycle5Glitter, MSlot2Cycle6Glitter, MSlot2Cycle7Glitter, MSlot2Cycle8Glitter, MSlot2Cycle9Glitter
	, MSlot2Cycle1AutoFull, MSlot2Cycle2AutoFull, MSlot2Cycle3AutoFull, MSlot2Cycle4AutoFull, MSlot2Cycle5AutoFull, MSlot2Cycle6AutoFull, MSlot2Cycle7AutoFull, MSlot2Cycle8AutoFull, MSlot2Cycle9AutoFull
	, MSlot3Cycle1Planter, MSlot3Cycle2Planter, MSlot3Cycle3Planter, MSlot3Cycle4Planter, MSlot3Cycle5Planter, MSlot3Cycle6Planter, MSlot3Cycle7Planter, MSlot3Cycle8Planter, MSlot3Cycle9Planter
	, MSlot3Cycle1Field, MSlot3Cycle2Field, MSlot3Cycle3Field, MSlot3Cycle4Field, MSlot3Cycle5Field, MSlot3Cycle6Field, MSlot3Cycle7Field, MSlot3Cycle8Field, MSlot3Cycle9Field
	, MSlot3Cycle1Glitter, MSlot3Cycle2Glitter, MSlot3Cycle3Glitter, MSlot3Cycle4Glitter, MSlot3Cycle5Glitter, MSlot3Cycle6Glitter, MSlot3Cycle7Glitter, MSlot3Cycle8Glitter, MSlot3Cycle9Glitter
	, MSlot3Cycle1AutoFull, MSlot3Cycle2AutoFull, MSlot3Cycle3AutoFull, MSlot3Cycle4AutoFull, MSlot3Cycle5AutoFull, MSlot3Cycle6AutoFull, MSlot3Cycle7AutoFull, MSlot3Cycle8AutoFull, MSlot3Cycle9AutoFull

	Loop 3 {
		i := A_Index
		Loop 9 {
			MSlot%i%Cycle%A_Index%Planter := MainGui["MSlot" i "Cycle" A_Index "Planter"].Text
			MSlot%i%Cycle%A_Index%Field := MainGui["MSlot" i "Cycle" A_Index "Field"].Text
			MSlot%i%Cycle%A_Index%Glitter := MainGui["MSlot" i "Cycle" A_Index "Glitter"].Value
			MSlot%i%Cycle%A_Index%AutoFull := MainGui["MSlot" i "Cycle" A_Index "AutoFull"].Text
		}
	}

	MPuffModeA := MainGui["MPuffModeA"].Value
	MPuffMode1 := MainGui["MPuffMode1"].Value
	MPuffMode2 := MainGui["MPuffMode2"].Value
	MPuffMode3 := MainGui["MPuffMode3"].Value

	MPlanterGatherA := MainGui["MPlanterGatherA"].Value
	MPlanterGather1 := MainGui["MPlanterGather1"].Value
	MPlanterGather2 := MainGui["MPlanterGather2"].Value
	MPlanterGather3 := MainGui["MPlanterGather3"].Value

	MConvertFullBagHarvest := MainGui["MConvertFullBagHarvest"].Value
	MGatherPlanterLoot := MainGui["MGatherPlanterLoot"].Value

	Loop 3 {
		i := A_Index
		Loop 9 {
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

	Loop 3 {
		i := A_Index
		Loop 9 {
			IniWrite MSlot%i%Cycle%A_Index%Planter, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Planter"
			IniWrite MSlot%i%Cycle%A_Index%Field, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Field"
			IniWrite MSlot%i%Cycle%A_Index%Glitter, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "Glitter"
			IniWrite MSlot%i%Cycle%A_Index%AutoFull, "settings\manual_planters.ini", "Slot " i, "MSlot" i "Cycle" A_Index "AutoFull"
		}
	}

	IniWrite MPuffModeA, "settings\nm_config.ini", "Planters", "MPuffModeA"
	IniWrite MPuffMode1, "settings\nm_config.ini", "Planters", "MPuffMode1"
	IniWrite MPuffMode2, "settings\nm_config.ini", "Planters", "MPuffMode2"
	IniWrite MPuffMode3, "settings\nm_config.ini", "Planters", "MPuffMode3"
	IniWrite MPlanterGatherA, "settings\nm_config.ini", "Planters", "MPlanterGatherA"
	IniWrite MPlanterGather1, "settings\nm_config.ini", "Planters", "MPlanterGather1"
	IniWrite MPlanterGather2, "settings\nm_config.ini", "Planters", "MPlanterGather2"
	IniWrite MPlanterGather3, "settings\nm_config.ini", "Planters", "MPlanterGather3"
	IniWrite MConvertFullBagHarvest, "settings\nm_config.ini", "Planters", "MConvertFullBagHarvest"
	IniWrite MGatherPlanterLoot, "settings\nm_config.ini", "Planters", "MGatherPlanterLoot"

	mp_UpdateControls()

}

mp_UpdateCycles() {
	global
	local i
	global MSlot1MaxCycle, MSlot2MaxCycle, MSlot3MaxCycle

	Loop 3 {
		i := A_Index, MSlot%A_Index%MaxCycle := 9
		Loop 9 {
			If (!MSlot%i%Cycle%A_Index%Field) {
				MSlot%i%MaxCycle := Max(A_Index - 1, 1)
				break
			}
		}

		PlanterManualCycle%i% := Min(MSlot%i%MaxCycle, PlanterManualCycle%i%)
		IniWrite PlanterManualCycle%i%, "settings\nm_config.ini", "Planters", "PlanterManualCycle" i

		MainGui["MSlot" i "Left"].Enabled := (PlanterManualCycle%i% != 1)
		MainGui["MSlot" i "Right"].Enabled := (PlanterManualCycle%i% < MSlot%i%MaxCycle)
		MainGui["MSlot" i "CycleNo"].Text := PlanterManualCycle%i%
	}
}

mp_Slot1ChangeLeft(*) {
	Global PlanterManualCycle1 -= 1
	mp_UpdateCycles()
}

mp_Slot1ChangeRight(*) {
	Global PlanterManualCycle1 += 1
	mp_UpdateCycles()
}

mp_Slot2ChangeLeft(*) {
	Global PlanterManualCycle2 -= 1
	mp_UpdateCycles()
}

mp_Slot2ChangeRight(*) {
	Global PlanterManualCycle2 += 1
	mp_UpdateCycles()
}

mp_Slot3ChangeLeft(*) {
	Global PlanterManualCycle3 -= 1
	mp_UpdateCycles()
}

mp_Slot3ChangeRight(*) {
	Global PlanterManualCycle3 += 1
	mp_UpdateCycles()
}
mp_MPuffMode(*){
	global
	MPuffModeA := MainGui["MPuffModeA"].Value
	if(MPuffModeA) {
		MainGui["MPuffModeA"].Value := 0
		if (MsgBox("
		(
		Enabling 'Disable auto harvest' will cause the macro NOT to harvest the planter when ready.

		Instead, it will 'hold' the full-grown planter until you harvest it either manually or through remote control.
		This option is designed for users trying to grow smoking planters for puffshroom runs, and allows you to check before harvesting.
		More information on how to use this feature is available in the 'Disable auto harvest' ? Help button.

		Do you wish to proceed with disabling auto harvest?
		)", "WARNING!", 1) = "Ok")
		{
			MainGui["MPuffModeA"].Value := 1
		} else {
			MainGui["MPuffModeA"].Value := 0
		}
	}
	mp_SaveConfig()
}
mp_MPlanterGatherSwitch_(*){
	global MPlanterGatherA
	MPlanterGatherA := MainGui["MPlanterGatherA"].Value
	if(MPlanterGatherA) {
		MainGui["MPlanterGatherA"].Value := 0
		if (MsgBox("
		(
		You have selected to "Gather only in planter field".

		Seleting this option will cause the macro to IGNORE the gathering fields specified in the Gather tab, and gather ONLY in planter fields for the slots you select using this option instead.

		This option can result in faster planter growth depending on your polar power, but will also result in less pollen/honey collection overall.
		More information on how to use this feature is available in the 'Gather in planter field' ? Help button.

		Do you wish to proceed with gathering in planter field?
		)", "WARNING!", 1) = "Ok")
		{
			MainGui["MPlanterGatherA"].Value := 1
		} else {
			MainGui["MPlanterGatherA"].Value := 0
		}
	}
	mp_SaveConfig()
}
nm_MPuffModeHelp(*){ ; disable auto harvest information for manual planters
	MsgBox "
	(
	DESCRIPTION:
	This option is designed for users trying to grow smoking planters for puffshrooms.
	Enabling it for a planter slot will cause the macro NOT to harvest the planter.
	Instead, it will 'hold' the planter until you harvest and clear it either manually or through remote control.
	This allows you to check whether it is smoking before harvesting.

	To use this feature:
	- Choose which slots to disable auto harvest for, depending on how many planters you wish to use for puffshrooms versus loot or nectar.
	- If you have set up a Discord webhook and would like a ping and screenshot of the planter when full grown, select Planter Progress in Natro Status tab > Change Discord Settings.
	- When ready, either:
	 - harvest manually in game, clear the planter in the Planter Timers pop-up (F5), and move to next cycle by pressing + in the planter tab
	 - or do nothing if the planter is smoking and you wish to keep holding it.
	- If you turn off 'Disable Auto Harvest' or switch to Planters Plus mode, the macro will harvest any planters marked holding or smoking.

	Advanced options:
	If you have set up remote control, after receiving a ping you can also optionally set your planter to smoking to help you keep track, or release from hold and plant next using these commands:
	- ?planter smoking [1][2][3]
	- ?planter harvest [1][2][3]
	See these planter commands and your planter status using ?planter

	See our Discord server for more details on how to set up and use webhook or remote control!
	)", "Disable auto harvest", 0x40000
}
nm_MPlanterGatherHelp(*){ ; gather in planter field information for manual planters
	MsgBox "
	(
	DESCRIPTION:
	Gather in planter field will enable you to gather only in the fields where planters are placed, instead of the fields selected in your gather tab.
	You can choose which planter slots you wish to gather in. If you choose more than one planter slot to gather in, the macro will rotate between each selected slot.
	If there are no slots available for planter gather (none selected, none with planters, or all 'holding' if 'disable auto harvest' mode is also selected), the macro will revert to gathering in the fields specified in the gather tab.
	)", "Gather in planter field", 0x40000
}
nm_MHarvestInterval(GuiCtrl, *){
	global MHarvestInterval
	static val := ["30 mins", "1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours"], l := val.Length

	switch MHarvestInterval, 0
	{
		case "30 mins":
		i := 1
		case "1 hour":
		i := 2
		default:
		i := 3
		case "3 hours":
		i := 4
		case "4 hours":
		i := 5
		case "5 hours":
		i := 6
		case "6 hours":
		i := 7
	}

	MainGui["MHarvestInterval"].Text := MHarvestInterval := val[(GuiCtrl.Name = "MHIRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite MHarvestInterval, "settings\manual_planters.ini", "General", "MHarvestInterval"
}
;Planters~
nm_NectarPreset(GuiCtrl, *){
	global
	static val := ["Custom", "Blue", "Red", "White"], l := val.Length
	local i

	i := (NPreset = "Custom") ? 1 : (NPreset = "Blue") ? 2 : (NPreset = "Red") ? 3 : 4

	MainGui["NPreset"].Text := NPreset := val[(GuiCtrl.Name = "NPRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"

	switch NPreset, 0
	{
		case "Blue":
		MainGui["n1Priority"].Text := n1Priority := "Comforting"
		MainGui["n2Priority"].Text := n2Priority := "Motivating"
		MainGui["n3Priority"].Text := n3Priority := "Satisfying"
		MainGui["n4Priority"].Text := n4Priority := "Refreshing"
		MainGui["n5Priority"].Text := n5Priority := "Invigorating"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;COM
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;MOT
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;SAT
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;REF
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;INV
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 0
		MainGui["PineTreeFieldCheck"].Value := 1
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 0
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;INV
		MainGui["CloverFieldCheck"].Value := 1
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1

		case "Red":
		MainGui["n1Priority"].Text := n1Priority := "Invigorating"
		MainGui["n2Priority"].Text := n2Priority := "Refreshing"
		MainGui["n3Priority"].Text := n3Priority := "Motivating"
		MainGui["n4Priority"].Text := n4Priority := "Satisfying"
		MainGui["n5Priority"].Text := n5Priority := "Comforting"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;INV
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;REF
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;MOT
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;SAT
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;COM
		;INV
		MainGui["CloverFieldCheck"].Value := 0
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 1
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 1
		MainGui["PineTreeFieldCheck"].Value := 1

		case "White":
		MainGui["n1Priority"].Text := n1Priority := "Satisfying"
		MainGui["n2Priority"].Text := n2Priority := "Motivating"
		MainGui["n3Priority"].Text := n3Priority := "Refreshing"
		MainGui["n4Priority"].Text := n4Priority := "Comforting"
		MainGui["n5Priority"].Text := n5Priority := "Invigorating"
		nm_NectarPriority()
		MainGui["n1minPercent"].Text := 70, MainGui["n1minPercentUpDown"].Value := 7 ;SAT
		MainGui["n2minPercent"].Text := 80, MainGui["n2minPercentUpDown"].Value := 8 ;MOT
		MainGui["n3minPercent"].Text := 80, MainGui["n3minPercentUpDown"].Value := 8 ;REF
		MainGui["n4minPercent"].Text := 80, MainGui["n4minPercentUpDown"].Value := 8 ;COM
		MainGui["n5minPercent"].Text := 40, MainGui["n5minPercentUpDown"].Value := 4 ;INV
		;SAT
		MainGui["SunflowerFieldCheck"].Value := 1
		MainGui["PineappleFieldCheck"].Value := 1
		MainGui["PumpkinFieldCheck"].Value := 0
		;MOT
		MainGui["MushroomFieldCheck"].Value := 0
		MainGui["SpiderFieldCheck"].Value := 1
		MainGui["RoseFieldCheck"].Value := 1
		MainGui["StumpFieldCheck"].Value := 0
		;REF
		MainGui["BlueFlowerFieldCheck"].Value := 1
		MainGui["StrawberryFieldCheck"].Value := 1
		MainGui["CoconutFieldCheck"].Value := 0
		;COM
		MainGui["DandelionFieldCheck"].Value := 1
		MainGui["BambooFieldCheck"].Value := 1
		MainGui["PineTreeFieldCheck"].Value := 1
		;INV
		MainGui["CloverFieldCheck"].Value := 1
		MainGui["CactusFieldCheck"].Value := 1
		MainGui["MountainTopFieldCheck"].Value := 0
		MainGui["PepperFieldCheck"].Value := 1
	}
	ba_saveConfig_()
}
nm_NectarPriority(GuiCtrl?, *){
	global
	static val := ["None", "Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
	local i, l, index, n, j, arr := []

	switch IsSet(GuiCtrl) ? GuiCtrl.Name : ""
	{
		case "NP2Left", "NP2Right":
		index := 2
		case "NP3Left", "NP3Right":
		index := 3
		case "NP4Left", "NP4Right":
		index := 4
		case "NP5Left", "NP5Right":
		index := 5
		default:
		index := 1
	}

	for k,v in val
	{
		if (k > 1)
			Loop (index - 1)
				if (v = N%A_Index%priority)
					continue 2
		arr.Push(v)
	}
	l := arr.Length

	switch N%index%priority, 0
	{
		case arr[1]:
		i := 1
		case arr[2]:
		i := 2
		case arr[3]:
		i := 3
		case arr[4]:
		i := 4
		case arr[5]:
		i := 5
		default:
		i := l
	}

	MainGui["N" index "priority"].Text := N%index%priority := arr[IsSet(GuiCtrl) ? ((GuiCtrl.Name = "NP" index "Right") ? Mod(i, l) + 1 : Mod(l + i - 2, l) + 1) : i]

	Loop 5 {
		n := A_Index
		Loop (n - 1) {
			if (N%n%priority = N%A_Index%priority) {
				MainGui["N" n "priority"].Text := N%n%priority := "None"
				if IsSet(GuiCtrl)
					IniWrite N%n%priority, "settings\nm_config.ini", "Planters", "N" n "priority"
			}
		}
		if (N%n%priority = "None") {
			Loop (5 - n) {
				j := n + A_Index
				MainGui["NP" j "Left"].Enabled := 0
				MainGui["NP" j "Right"].Enabled := 0
				MainGui["N" j "MinPercentUpDown"].Enabled := 0
				if (N%j%priority != "None") {
					MainGui["N" j "priority"].Text := N%j%priority := "None"
					if IsSet(GuiCtrl)
						IniWrite N%j%priority, "settings\nm_config.ini", "Planters", "N" j "priority"
				}
			}
			break
		} else if (A_Index < 5) {
			j := n + 1
			MainGui["NP" j "Left"].Enabled := 1
			MainGui["NP" j "Right"].Enabled := 1
			MainGui["N" j "MinPercentUpDown"].Enabled := 1
		}
	}

	if IsSet(GuiCtrl) {
		IniWrite N%index%priority, "settings\nm_config.ini", "Planters", "N" index "priority"
		if (NPreset != "Custom") {
			MainGui["NPreset"].Text := (NPreset := "Custom")
			IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"
		}
	}
}
nm_NectarMinPercent(GuiCtrl, *){
	global
	local k
	MainGui[k := StrReplace(GuiCtrl.Name, "UpDown")].Text := %k% := GuiCtrl.Value * 10
	IniWrite %k%, "settings\nm_config.ini", "Planters", k
	if (NPreset != "Custom") {
		MainGui["NPreset"].Text := NPreset := "Custom"
		IniWrite NPreset, "settings\nm_config.ini", "Planters", "NPreset"
	}
}
ba_harvestInterval(*){
	global HarvestInterval
	HarvestInterval := MainGui["HarvestInterval"].Value
	if HarvestInterval is number
	{
		if HarvestInterval>0
		{
			HarvestInterval:=HarvestInterval
			ba_saveConfig_()
		} else {
			MainGui["HarvestInterval"].Value := HarvestInterval
		}
	} else {
		MainGui["HarvestInterval"].Value := HarvestInterval
	}
}
ba_HarvestFullGrownSwitch_(*){
	global HarvestFullGrown
	HarvestFullGrown := MainGui["HarvestFullGrown"].Value
	if(HarvestFullGrown) {
		MainGui["HarvestInterval"].Visible := 0
		MainGui["AutoText"].Visible := 0
		MainGui["FullText"].Visible := 1
		MainGui["AutomaticHarvestInterval"].Value := 0
	} else {
		MainGui["HarvestInterval"].Visible := 1
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 0
	}
	ba_saveConfig_()
}
ba_AutoHarvestSwitch_(*){
	global AutomaticHarvestInterval
	AutomaticHarvestInterval := MainGui["AutomaticHarvestInterval"].Value
	if(AutomaticHarvestInterval) {
		MainGui["HarvestInterval"].Visible := 0
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 1
		MainGui["HarvestFullGrown"].Value := 0
	} else {
		MainGui["HarvestInterval"].Visible := 1
		MainGui["FullText"].Visible := 0
		MainGui["AutoText"].Visible := 0
	}
	ba_saveConfig_()
}
ba_gotoPlanterFieldSwitch_(*){
	global gotoPlanterField
	GotoPlanterField := MainGui["GotoPlanterField"].Value
	if(GotoPlanterField){
		MainGui["GotoPlanterField"].Value := 0
		if (MsgBox("
		(
		You have selected to "Only Gather in Planter Field".

		I understand that by selecting this option will cause the macro to IGNORE the gathering fields specified in the Main tab.

		Enabling this option will make you gather in a field that contains a planter as selected by Planters+ instead.

		I understand that this option will result in gathering Nectar much faster but will also result in less pollen/honey collection overall.
		)", "WARNING!!", 1) = "Ok")
		{
			MainGui["GotoPlanterField"].Value := 1
		} else {
			MainGui["GotoPlanterField"].Value := 0
		}
	}
	ba_saveConfig_()
}
ba_gatherFieldSippingSwitch_(*){
	global GatherFieldSipping
	GatherFieldSipping := MainGui["GatherFieldSipping"].Value
	if(GatherFieldSipping){
		MainGui["GatherFieldSipping"].Value := 0
		if (MsgBox("
		(
		You have selected to "Gather Field Nectar Sipping".

		This option will force planters to always be placed in your current gathering field if you need the nectar type that field provides.
		This is done regardless of the allowed field selections.
		This will allow your bees to sip from the planter and greatly increase the amount of nectar gained.
		)", "INFORMATION", 1) = "Ok")
		{
			MainGui["GatherFieldSipping"].Value := 1
		} else {
			MainGui["GatherFieldSipping"].Value := 0
		}
	}
	ba_saveConfig_()
}
ba_maxAllowedPlantersSwitch(*){
	global
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	if(MaxAllowedPlanters=0){
		MainGui["PlanterMode"].Value := 1
		ba_planterSwitch()
	} else {
		MainGui["PlanterMode"].Value := 2
	}
	ba_saveConfig_()
}
ba_saveConfig_(*){ ;//todo: needs replacing!
	global
	nPreset := MainGui["nPreset"].Text
	n1priority := MainGui["n1priority"].Text
	n2priority := MainGui["n2priority"].Text
	n3priority := MainGui["n3priority"].Text
	n4priority := MainGui["n4priority"].Text
	n5priority := MainGui["n5priority"].Text
	n1minPercent := MainGui["n1minPercent"].Text
	n2minPercent := MainGui["n2minPercent"].Text
	n3minPercent := MainGui["n3minPercent"].Text
	n4minPercent := MainGui["n4minPercent"].Text
	n5minPercent := MainGui["n5minPercent"].Text
	HarvestInterval := MainGui["HarvestInterval"].Value
	AutomaticHarvestInterval := MainGui["AutomaticHarvestInterval"].Value
	HarvestFullGrown := MainGui["HarvestFullGrown"].Value
	GotoPlanterField := MainGui["GotoPlanterField"].Value
	GatherFieldSipping := MainGui["GatherFieldSipping"].Value
	ConvertFullBagHarvest := MainGui["ConvertFullBagHarvest"].Value
	GatherPlanterLoot := MainGui["GatherPlanterLoot"].Value
	PlasticPlanterCheck := MainGui["PlasticPlanterCheck"].Value
	CandyPlanterCheck := MainGui["CandyPlanterCheck"].Value
	BlueClayPlanterCheck := MainGui["BlueClayPlanterCheck"].Value
	RedClayPlanterCheck := MainGui["RedClayPlanterCheck"].Value
	TackyPlanterCheck := MainGui["TackyPlanterCheck"].Value
	PesticidePlanterCheck := MainGui["PesticidePlanterCheck"].Value
	HeatTreatedPlanterCheck := MainGui["HeatTreatedPlanterCheck"].Value
	HydroponicPlanterCheck := MainGui["HydroponicPlanterCheck"].Value
	PetalPlanterCheck := MainGui["PetalPlanterCheck"].Value
	PaperPlanterCheck := MainGui["PaperPlanterCheck"].Value
	TicketPlanterCheck := MainGui["TicketPlanterCheck"].Value
	PlanterOfPlentyCheck := MainGui["PlanterOfPlentyCheck"].Value
	BambooFieldCheck := MainGui["BambooFieldCheck"].Value
	BlueFlowerFieldCheck := MainGui["BlueFlowerFieldCheck"].Value
	CactusFieldCheck := MainGui["CactusFieldCheck"].Value
	CloverFieldCheck := MainGui["CloverFieldCheck"].Value
	CoconutFieldCheck := MainGui["CoconutFieldCheck"].Value
	DandelionFieldCheck := MainGui["DandelionFieldCheck"].Value
	MountainTopFieldCheck := MainGui["MountainTopFieldCheck"].Value
	MushroomFieldCheck := MainGui["MushroomFieldCheck"].Value
	PepperFieldCheck := MainGui["PepperFieldCheck"].Value
	PineTreeFieldCheck := MainGui["PineTreeFieldCheck"].Value
	PineappleFieldCheck := MainGui["PineappleFieldCheck"].Value
	PumpkinFieldCheck := MainGui["PumpkinFieldCheck"].Value
	RoseFieldCheck := MainGui["RoseFieldCheck"].Value
	SpiderFieldCheck := MainGui["SpiderFieldCheck"].Value
	StrawberryFieldCheck := MainGui["StrawberryFieldCheck"].Value
	StumpFieldCheck := MainGui["StumpFieldCheck"].Value
	SunflowerFieldCheck := MainGui["SunflowerFieldCheck"].Value
	PlanterMode := MainGui["PlanterMode"].Value
	MaxAllowedPlanters := MainGui["MaxAllowedPlanters"].Value
	IniWrite nPreset, "settings\nm_config.ini", "Planters", "nPreset"
	IniWrite n1priority, "settings\nm_config.ini", "Planters", "n1priority"
	IniWrite n2priority, "settings\nm_config.ini", "Planters", "n2priority"
	IniWrite n3priority, "settings\nm_config.ini", "Planters", "n3priority"
	IniWrite n4priority, "settings\nm_config.ini", "Planters", "n4priority"
	IniWrite n5priority, "settings\nm_config.ini", "Planters", "n5priority"
	IniWrite n1minPercent, "settings\nm_config.ini", "Planters", "n1minPercent"
	IniWrite n2minPercent, "settings\nm_config.ini", "Planters", "n2minPercent"
	IniWrite n3minPercent, "settings\nm_config.ini", "Planters", "n3minPercent"
	IniWrite n4minPercent, "settings\nm_config.ini", "Planters", "n4minPercent"
	IniWrite n5minPercent, "settings\nm_config.ini", "Planters", "n5minPercent"
	IniWrite PlasticPlanterCheck, "settings\nm_config.ini", "Planters", "PlasticPlanterCheck"
	IniWrite CandyPlanterCheck, "settings\nm_config.ini", "Planters", "CandyPlanterCheck"
	IniWrite BlueClayPlanterCheck, "settings\nm_config.ini", "Planters", "BlueClayPlanterCheck"
	IniWrite RedClayPlanterCheck, "settings\nm_config.ini", "Planters", "RedClayPlanterCheck"
	IniWrite TackyPlanterCheck, "settings\nm_config.ini", "Planters", "TackyPlanterCheck"
	IniWrite PesticidePlanterCheck, "settings\nm_config.ini", "Planters", "PesticidePlanterCheck"
	IniWrite HeatTreatedPlanterCheck, "settings\nm_config.ini", "Planters", "HeatTreatedPlanterCheck"
	IniWrite HydroponicPlanterCheck, "settings\nm_config.ini", "Planters", "HydroponicPlanterCheck"
	IniWrite PetalPlanterCheck, "settings\nm_config.ini", "Planters", "PetalPlanterCheck"
	IniWrite PaperPlanterCheck, "settings\nm_config.ini", "Planters", "PaperPlanterCheck"
	IniWrite TicketPlanterCheck, "settings\nm_config.ini", "Planters", "TicketPlanterCheck"
	IniWrite PlanterOfPlentyCheck, "settings\nm_config.ini", "Planters", "PlanterOfPlentyCheck"
	IniWrite BambooFieldCheck, "settings\nm_config.ini", "Planters", "BambooFieldCheck"
	IniWrite BlueFlowerFieldCheck, "settings\nm_config.ini", "Planters", "BlueFlowerFieldCheck"
	IniWrite CactusFieldCheck, "settings\nm_config.ini", "Planters", "CactusFieldCheck"
	IniWrite CloverFieldCheck, "settings\nm_config.ini", "Planters", "CloverFieldCheck"
	IniWrite CoconutFieldCheck, "settings\nm_config.ini", "Planters", "CoconutFieldCheck"
	IniWrite DandelionFieldCheck, "settings\nm_config.ini", "Planters", "DandelionFieldCheck"
	IniWrite MountainTopFieldCheck, "settings\nm_config.ini", "Planters", "MountainTopFieldCheck"
	IniWrite MushroomFieldCheck, "settings\nm_config.ini", "Planters", "MushroomFieldCheck"
	IniWrite PepperFieldCheck, "settings\nm_config.ini", "Planters", "PepperFieldCheck"
	IniWrite PineTreeFieldCheck, "settings\nm_config.ini", "Planters", "PineTreeFieldCheck"
	IniWrite PineappleFieldCheck, "settings\nm_config.ini", "Planters", "PineappleFieldCheck"
	IniWrite PumpkinFieldCheck, "settings\nm_config.ini", "Planters", "PumpkinFieldCheck"
	IniWrite RoseFieldCheck, "settings\nm_config.ini", "Planters", "RoseFieldCheck"
	IniWrite SpiderFieldCheck, "settings\nm_config.ini", "Planters", "SpiderFieldCheck"
	IniWrite StrawberryFieldCheck, "settings\nm_config.ini", "Planters", "StrawberryFieldCheck"
	IniWrite StumpFieldCheck, "settings\nm_config.ini", "Planters", "StumpFieldCheck"
	IniWrite SunflowerFieldCheck, "settings\nm_config.ini", "Planters", "SunflowerFieldCheck"
	IniWrite PlanterMode, "settings\nm_config.ini", "Planters", "PlanterMode"
	IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
	IniWrite HarvestInterval, "settings\nm_config.ini", "Planters", "HarvestInterval"
	IniWrite AutomaticHarvestInterval, "settings\nm_config.ini", "Planters", "AutomaticHarvestInterval"
	IniWrite HarvestFullGrown, "settings\nm_config.ini", "Planters", "HarvestFullGrown"
	IniWrite GotoPlanterField, "settings\nm_config.ini", "Planters", "GotoPlanterField"
	IniWrite GatherFieldSipping, "settings\nm_config.ini", "Planters", "GatherFieldSipping"
	IniWrite ConvertFullBagHarvest, "settings\nm_config.ini", "Planters", "ConvertFullBagHarvest"
	IniWrite GatherPlanterLoot, "settings\nm_config.ini", "Planters", "GatherPlanterLoot"
}

; STATUS TAB
; ------------------------
nm_StatusLogReverseCheck(*){
	global StatusLogReverse
	StatusLogReverse := MainGui["StatusLogReverse"].Value
	MainGui["StatusLogReverse"].Enabled := 0
	IniWrite StatusLogReverse, "settings\nm_config.ini", "Status", "StatusLogReverse"
	if (StatusLogReverse) {
		nm_setStatus("GUI", "Status Log Reversed")
	} else {
		nm_setStatus("GUI", "Status Log NOT Reversed")
	}
	MainGui["StatusLogReverse"].Enabled := 1
}
nm_ResetTotalStats(*){
	global
	IniWrite TotalRuntime:=0, "settings\nm_config.ini", "Status", "TotalRuntime"
	IniWrite TotalGatherTime:=0, "settings\nm_config.ini", "Status", "TotalGatherTime"
	IniWrite TotalConvertTime:=0, "settings\nm_config.ini", "Status", "TotalConvertTime"
	IniWrite TotalViciousKills:=0, "settings\nm_config.ini", "Status", "TotalViciousKills"
	IniWrite TotalBossKills:=0, "settings\nm_config.ini", "Status", "TotalBossKills"
	IniWrite TotalBugKills:=0, "settings\nm_config.ini", "Status", "TotalBugKills"
	IniWrite TotalPlantersCollected:=0, "settings\nm_config.ini", "Status", "TotalPlantersCollected"
	IniWrite TotalQuestsComplete:=0, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
	IniWrite TotalDisconnects:=0, "settings\nm_config.ini", "Status", "TotalDisconnects"
	nm_setStats()
}
nm_ResetSessionStats(*){
	global
	IniWrite SessionRuntime:=0, "settings\nm_config.ini", "Status", "SessionRuntime"
	IniWrite SessionGatherTime:=0, "settings\nm_config.ini", "Status", "SessionGatherTime"
	IniWrite SessionConvertTime:=0, "settings\nm_config.ini", "Status", "SessionConvertTime"
	IniWrite SessionViciousKills:=0, "settings\nm_config.ini", "Status", "SessionViciousKills"
	IniWrite SessionBossKills:=0, "settings\nm_config.ini", "Status", "SessionBossKills"
	IniWrite SessionBugKills:=0, "settings\nm_config.ini", "Status", "SessionBugKills"
	IniWrite SessionPlantersCollected:=0, "settings\nm_config.ini", "Status", "SessionPlantersCollected"
	IniWrite SessionQuestsComplete:=0, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
	IniWrite SessionDisconnects:=0, "settings\nm_config.ini", "Status", "SessionDisconnects"
	nm_setStats()
}
nm_WebhookGUI(*){
	global
	local script, exec, shell

	try ProcessClose WGUIPID

	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force
	#MaxThreads 255
	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"

	DetectHiddenWindows 1

	pToken := Gdip_Startup()

	(bitmaps := Map()).CaseSense := 0
	#Include "%A_ScriptDir%\nm_image_assets\webhook_gui\bitmaps.ahk"

	; config
	discordMode := ' discordMode '
	discordCheck := ' discordCheck '

	webhook := "' webhook '"
	bottoken := "' bottoken '"

	MainChannelCheck := ' MainChannelCheck '
	MainChannelID := "' MainChannelID '"
	ReportChannelCheck := ' ReportChannelCheck '
	ReportChannelID := "' ReportChannelID '"

	ssCheck := ' ssCheck '
	CriticalSSCheck := ' CriticalSSCheck '
	AmuletSSCheck := ' AmuletSSCheck '
	MachineSSCheck := ' MachineSSCheck '
	BalloonSSCheck := ' BalloonSSCheck '
	ViciousSSCheck := ' ViciousSSCheck '
	DeathSSCheck := ' DeathSSCheck '
	PlanterSSCheck := ' PlanterSSCheck '
	HoneySSCheck := ' HoneySSCheck '

	criticalCheck := ' criticalCheck '
	discordUID := "' discordUID '"
	CriticalErrorPingCheck := ' CriticalErrorPingCheck '
	DisconnectPingCheck := ' DisconnectPingCheck '
	GameFrozenPingCheck := ' GameFrozenPingCheck '
	PhantomPingCheck := ' PhantomPingCheck '
	UnexpectedDeathPingCheck := ' UnexpectedDeathPingCheck '
	EmergencyBalloonPingCheck := ' EmergencyBalloonPingCheck '
	HoneyUpdateSSCheck := ' HoneyUpdateSSCheck '

	enum := Map("discordMode", 1
		, "discordCheck", 2
		, "MainChannelCheck", 3
		, "ReportChannelCheck", 4
		, "ssCheck", 6
		, "CriticalSSCheck", 8
		, "AmuletSSCheck", 9
		, "MachineSSCheck", 10
		, "BalloonSSCheck", 11
		, "ViciousSSCheck", 12
		, "DeathSSCheck", 13
		, "PlanterSSCheck", 14
		, "HoneySSCheck", 15
		, "criticalCheck", 16
		, "CriticalErrorPingCheck", 17
		, "DisconnectPingCheck", 18
		, "GameFrozenPingCheck", 19
		, "PhantomPingCheck", 20
		, "UnexpectedDeathPingCheck", 21
		, "EmergencyBalloonPingCheck", 22
		, "HoneyUpdateSSCheck", 363)

	str_enum := Map("webhook", 1
		, "bottoken", 2
		, "MainChannelID", 3
		, "ReportChannelID", 4
		, "discordUID", 5)

	w := 500, h := 500
	DiscordGui := Gui("-Caption +E0x80000 +E0x8000000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale")
	hMain := DiscordGui.Hwnd
	DiscordGui.OnEvent("Close", (*) => ExitApp()), DiscordGui.OnEvent("Escape", (*) => ExitApp())
	DiscordGui.Show("NA")
	DiscordGui.Add("Text", "x8 y0 w" w-16 " h32 vTitle")
	DiscordGui.Add("Text", "x18 y5 w32 h24 vChangeMode")
	DiscordGui.Add("Text", "x" w-42 " y4 w26 h26 vClose")

	for k,v in enum
		if (v != 1)
			DiscordGui.Add("Text", "Hidden v" k)
	DiscordGui.Add("Text", "Hidden vCopyDiscord")
	DiscordGui.Add("Text", "Hidden vPasteDiscord")
	DiscordGui.Add("Text", "Hidden vPasteMainID")
	DiscordGui.Add("Text", "Hidden vPasteReportID")
	DiscordGui.Add("Text", "Hidden vPasteUserID")

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

	nm_WebhookGUI()
	{
		global
		local k,v,x,y,w,h,str
		static ss_list := ["critical","amulet","machine","balloon","vicious","death","planter","honey", "honeyUpdate"]
		static ping_list := ["criticalerror","disconnect","gamefrozen","phantom","unexpecteddeath","emergencyballoon"]

		Gdip_GraphicsClear(G)
		w := 500, h := 420 + discordMode * 80

		; edge shadow
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h, 0x00000000, 0x78000000), 14, 6, w-16, h-16, 12), Gdip_DeleteBrush(pBrush)

		; title bar and control
		pBrush := Gdip_BrushCreateSolid(0xff5865f2), Gdip_FillRoundedRectanglePath(G, pBrush, 8, 0, w-16, 30, 12), Gdip_FillRectangle(G, pBrush, 8, 13, w-16, 20), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps["logo_mode" discordMode], 18, 5)
		Gdip_DrawImage(G, bitmaps["text_mode" discordMode], w//2 - Gdip_GetImageWidth(bitmaps["text_mode" discordMode])//2, 9)
		Gdip_DrawImage(G, bitmaps["close"], w-42, 4)

		; main background
		pBrush := Gdip_BrushCreateSolid(0xff131416)
		Gdip_FillRectangle(G, pBrush, 8, 32, w-16, h-80), Gdip_FillRoundedRectanglePath(G, pBrush, 8, h-100, w-16, 84, 12)
		Gdip_DeleteBrush(pBrush)

		; webhook url / bot token
		Gdip_DrawImage(G, bitmaps[(discordMode = 0) ? "text_webhookurl" : "text_bottoken"], 22, 47)
		x := 30 + Gdip_GetImageWidth(bitmaps[(discordMode = 0) ? "text_webhookurl" : "text_bottoken"])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(discordCheck ? 0xff4bb543 : 0xffff3333), x, 42, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (discordCheck ? 19 : 3), 45, 18, 18), Gdip_DeleteBrush(pBrush)
		DiscordGui["DiscordCheck"].Move(x, 42, 40, 24), DiscordGui["DiscordCheck"].Visible := 1
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), 20, 72, w-40, 50, 20), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(0xff222932)
		Gdip_FillRoundedRectanglePath(G, pBrush, 20, 72, w-136, 50, 20), Gdip_FillRectangle(G, pBrush, w-148, 72, 32, 50)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawOrientedString(G, str := (discordMode = 0) ? webhook : bottoken, "Calibri", (StrLen(str) < 56) ? 19 : (StrLen(str) < 84) ? 17 : 13, 1, 32,
			72 + 3 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), w-160, 50 - 6 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps["copy"], w-110, 72)
		DiscordGui["CopyDiscord"].Move(w-106, 72, 32, 50), DiscordGui["CopyDiscord"].Visible := discordCheck
		Gdip_DrawImage(G, bitmaps["paste"], w-65, 72)
		DiscordGui["PasteDiscord"].Move(w-61, 72, 32, 50), DiscordGui["PasteDiscord"].Visible := discordCheck


		; channel ids
		if (discordMode = 1)
		{
			if MainChannelCheck
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), 24, 130, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], 25, 131)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), 25, 131, 18, 18, 4), Gdip_DeletePen(pPen)
			DiscordGui["MainChannelCheck"].Move(25, 131, 18, 18), DiscordGui["MainChannelCheck"].Visible := discordCheck
			Gdip_DrawImage(G, bitmaps["text_mainchannelid"], 52, 134)
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), 22, 158, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
			pBrush := Gdip_BrushCreateSolid(0xff222932)
			Gdip_FillRoundedRectanglePath(G, pBrush, 22, 158, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w//2-86, 158, 32, 40)
			Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, MainChannelID, "Calibri", 16, 1, 22, 168, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
			Gdip_DrawImage(G, bitmaps["paste"], w//2-50, 158, 32, 40)
			DiscordGui["PasteMainID"].Move(w//2-47, 158, 26, 40), DiscordGui["PasteMainID"].Visible := discordCheck

			if ReportChannelCheck
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), w//2+16, 130, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], w//2+17, 131)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), w//2+17, 131, 18, 18, 4), Gdip_DeletePen(pPen)
			DiscordGui["ReportChannelCheck"].Move(w//2+17, 131, 18, 18), DiscordGui["ReportChannelCheck"].Visible := discordCheck
			Gdip_DrawImage(G, bitmaps["text_reportchannelid"], w//2+44, 134)
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), w//2+14, 158, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
			pBrush := Gdip_BrushCreateSolid(0xff222932)
			Gdip_FillRoundedRectanglePath(G, pBrush, w//2+14, 158, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w-94, 158, 32, 40)
			Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ReportChannelID, "Calibri", 16, 1, w//2+14, 168, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
			Gdip_DrawImage(G, bitmaps["paste"], w-58, 158, 32, 40)
			DiscordGui["PasteReportID"].Move(w-55, 158, 26, 40), DiscordGui["PasteReportID"].Visible := discordCheck
		}
		else
		{
			DiscordGui["MainChannelCheck"].Move(0, 0, 0, 0)
			DiscordGui["ReportChannelCheck"].Move(0, 0, 0, 0)
			DiscordGui["PasteMainID"].Move(0, 0, 0, 0)
			DiscordGui["PasteReportID"].Move(0, 0, 0, 0)
			DiscordGui["MainChannelCheck"].Visible := 0
			DiscordGui["ReportChannelCheck"].Visible := 0
			DiscordGui["PasteMainID"].Visible := 0
			DiscordGui["PasteReportID"].Visible := 0
		}

		; screenshots
		Gdip_DrawImage(G, bitmaps["text_screenshots"], 22, h-282)
		x := 30 + Gdip_GetImageWidth(bitmaps["text_screenshots"])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(ssCheck ? 0xff4bb543 : 0xffff3333), x, h-286, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (ssCheck ? 19 : 3), h-283, 18, 18), Gdip_DeleteBrush(pBrush)
		DiscordGui["SSCheck"].Move(x, h-286, 40, 24), DiscordGui["SSCheck"].Visible := discordCheck
		for k,v in ss_list
		{
			if (%v%SSCheck = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), 24, h-283 + k * 26, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], 25, h-282 + k * 26)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), 25, h-282 + k * 26, 18, 18, 4), Gdip_DeletePen(pPen)
			DiscordGui[v "SSCheck"].Move(25, h-282 + k * 26, 18, 18), DiscordGui[v "SSCheck"].Visible := (discordCheck && ssCheck)
			Gdip_DrawImage(G, bitmaps["text_" v], 52, h-278 + k * 26)
		}

		; pings
		Gdip_DrawImage(G, bitmaps["text_userid"], w//2+16, h-283)
		x := w//2+24 + Gdip_GetImageWidth(bitmaps["text_userid"])
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(criticalCheck ? 0xff4bb543 : 0xffff3333), x, h-286, 40, 24, 12), Gdip_DeleteBrush(pBrush)
		Gdip_FillEllipse(G, pBrush := Gdip_BrushCreateSolid(0xffffffff), x + (criticalCheck ? 19 : 3), h-283, 18, 18), Gdip_DeleteBrush(pBrush)
		DiscordGui["CriticalCheck"].Move(x, h-286, 40, 24), DiscordGui["CriticalCheck"].Visible := discordCheck
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff323942), w//2+14, h-256, w//2-36, 40, 15), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(0xff222932)
		Gdip_FillRoundedRectanglePath(G, pBrush, w//2+14, h-256, w//2-76, 40, 15), Gdip_FillRectangle(G, pBrush, w-94, h-256, 32, 40)
		Gdip_DeleteBrush(pBrush)
		Gdip_DrawOrientedString(G, discordUID, "Calibri", 16, 1, w//2+14, h-246, w//2-74, 40, 0, pBrush := Gdip_BrushCreateSolid(0xffffffff), 0, 1), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps["paste"], w-58, h-256, 32, 40)
		DiscordGui["PasteUserID"].Move(w-55, h-256, 26, 40), DiscordGui["PasteUserID"].Visible := (discordCheck && criticalCheck)
		for k,v in ping_list
		{
			if (%v%PingCheck = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), w//2+18, h-231 + k * 26, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], w//2+19, h-230 + k * 26)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), w//2+19, h-230 + k * 26, 18, 18, 4), Gdip_DeletePen(pPen)
			DiscordGui[v "PingCheck"].Move(w//2+19, h-230 + k * 26, 18, 18), DiscordGui[v "PingCheck"].Visible := (discordCheck && criticalCheck)
			Gdip_DrawImage(G, bitmaps["text_" v], w//2+46, h-226 + k * 26)
		}

		; grey out disabled options
		if (discordCheck = 0)
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), 16, 70, w-32, h-90), Gdip_DeleteBrush(pBrush)
		else
		{
			if (ssCheck = 0)
				Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), 16, h-260, w//2-24, 235), Gdip_DeleteBrush(pBrush)
			if (criticalCheck = 0)
				Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x80131416), w//2+8, h-260, w//2-24, 235), Gdip_DeleteBrush(pBrush)
		}

		UpdateLayeredWindow(hMain, hdc, , , w, h)
		OnMessage(0x201, WM_LBUTTONDOWN)
		OnMessage(0x200, WM_MOUSEMOVE)
		OnExit(ExitFunc)
	}

	WM_LBUTTONDOWN(*)
	{
		global
		local hCtrl, k, pBrush, pPen, ctrl_x, ctrl_y, ctrl_w, ctrl_h, s, str
		MouseGetPos , , , &hCtrl, 2
		if !hCtrl
			return

		name := DiscordGui[hCtrl].Name
		switch name, 0
		{
			case "Title":
			PostMessage 0xA1, 2

			case "ChangeMode":
			discordMode := !discordMode
			nm_WebhookGUI()
			UpdateInt("discordMode")

			case "Close":
			ReplaceSystemCursors()
			ExitApp

			case "DiscordCheck":
			discordCheck := !discordCheck
			nm_WebhookGUI()
			UpdateInt("discordCheck")

			case "SSCheck":
			ssCheck := !ssCheck
			nm_WebhookGUI()
			UpdateInt("ssCheck")

			case "CriticalCheck":
			criticalCheck := !criticalCheck
			nm_WebhookGUI()
			UpdateInt("criticalCheck")

			case "MainChannelCheck", "ReportChannelCheck", "CriticalSSCheck", "AmuletSSCheck", "MachineSSCheck", "BalloonSSCheck", "ViciousSSCheck", "DeathSSCheck", "PlanterSSCheck", "HoneySSCheck"
				, "CriticalErrorPingCheck", "DisconnectPingCheck", "GameFrozenPingCheck", "PhantomPingCheck", "UnexpectedDeathPingCheck", "EmergencyBalloonPingCheck", "HoneyUpdateSSCheck":
			k := name
			ControlGetPos &ctrl_x, &ctrl_y, &ctrl_w, &ctrl_h, hCtrl
			%k% := !%k%
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xff131416), ctrl_x-3, ctrl_y-3, ctrl_w+6, ctrl_h+6), Gdip_DeleteBrush(pBrush)
			if (%k% = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), ctrl_x-1, ctrl_y-1, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], ctrl_x, ctrl_y)
			else
				Gdip_DrawRoundedRectanglePath(G, pPen := Gdip_CreatePen(0xff808080, 4), ctrl_x, ctrl_y, 18, 18, 4), Gdip_DeletePen(pPen)
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x40131416), ctrl_x-2, ctrl_y-2, ctrl_w+4, ctrl_h+4), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			UpdateInt(k)

			case "CopyDiscord":
			ControlGetPos , &ctrl_y, , &ctrl_h, hCtrl
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 21, ctrl_y+1, w-138, ctrl_h-2, 20), Gdip_FillRectangle(G, pBrush, w-148, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, "Copied to Clipboard!", "Calibri", 22, 1, 32, ctrl_y+11, w-160, ctrl_h-11, 0, pBrush := Gdip_BrushCreateSolid(0xff00a000), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			A_Clipboard := (discordMode = 0) ? webhook : bottoken
			SetTimer nm_WebhookGUI, -1000, 1

			case "PasteDiscord":
			ControlGetPos , &ctrl_y, , &ctrl_h, hCtrl
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 21, ctrl_y+1, w-138, ctrl_h-2, 20), Gdip_FillRectangle(G, pBrush, w-148, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, (s := (((discordMode = 0) && RegExMatch(A_Clipboard, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)", &str) && (str := str[0])) || ((discordMode = 1) && RegExMatch(A_Clipboard, "i)^[\w-.]{50,83}$", &str) && (str := str[0])))) ? (((discordMode = 0) ? webhook : bottoken) := str) : ("No valid " ((discordMode = 0) ? "Webhook URL" : "Bot Token") " found``nin Clipboard!"), "Calibri", (s = 0) ? 20 : ((StrLen(str) < 56) ? 19 : (StrLen(str) < 84) ? 17 : 13), 1, 32, ctrl_y + 3 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), w-160, ctrl_h - 6 * ((StrLen(str) >= 56) && (StrLen(str) < 84)), 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer nm_WebhookGUI, -1000, 1
			(s != 0) && UpdateStr((discordMode = 0) ? "webhook" : "bottoken")

			case "PasteMainID":
			ControlGetPos , &ctrl_y, , &ctrl_h, hCtrl
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), 23, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w//2-86, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ((s := RegExMatch(A_Clipboard, "i)^\d{17,20}$", &str)) && (str := str[0])) ? (MainChannelID := str) : "Invalid Channel ID!", "Calibri", 16, 1, 22, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer nm_WebhookGUI, -1000, 1
			(s != 0) && UpdateStr("MainChannelID")

			case "PasteReportID":
			ControlGetPos , &ctrl_y, , &ctrl_h, hCtrl
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), w//2+15, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w-94, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ((s := RegExMatch(A_Clipboard, "i)^\d{17,20}$", &str)) && (str := str[0])) ? (ReportChannelID := str) : "Invalid Channel ID!", "Calibri", 16, 1, w//2+14, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer nm_WebhookGUI, -1000, 1
			(s != 0) && UpdateStr("ReportChannelID")

			case "PasteUserID":
			ControlGetPos , &ctrl_y, , &ctrl_h, hCtrl
			Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff222932), w//2+15, ctrl_y+1, w//2-78, ctrl_h-2, 15), Gdip_FillRectangle(G, pBrush, w-94, ctrl_y+1, 28, ctrl_h-2), Gdip_DeleteBrush(pBrush)
			Gdip_DrawOrientedString(G, ((s := RegExMatch(A_Clipboard, "i)^&?\d{17,20}$", &str)) && (str := str[0])) ? (discordUID := str) : "Invalid User ID!", "Calibri", 16, 1, w//2+14, ctrl_y+10, w//2-74, ctrl_h, 0, pBrush := Gdip_BrushCreateSolid((s = 0) ? 0xffff3030 : 0xffffa500), 0, 1), Gdip_DeleteBrush(pBrush)
			UpdateLayeredWindow(hMain, hdc)
			SetTimer nm_WebhookGUI, -1000, 1
			(s != 0) && UpdateStr("discordUID")
		}
	}

	WM_MOUSEMOVE(*)
	{
		global
		local hCtrl, pBrush, pPen, k, hover_x, hover_y, hover_w, hover_h
		MouseGetPos , , , &hCtrl, 2

		if (!hCtrl || (hCtrl = DiscordGui["Title"].Hwnd))
			return 0

		name := DiscordGui[hCtrl].Name
		switch name, 0
		{
			case "ChangeMode", "Close", "DiscordCheck", "SSCheck", "CriticalCheck", "CopyDiscord", "PasteDiscord", "PasteMainID", "PasteReportID", "PasteUserID":
			hover_ctrl := hCtrl
			ReplaceSystemCursors("IDC_HAND")
			while (hCtrl = hover_ctrl)
			{
				Sleep 20
				MouseGetPos , , , &hCtrl, 2
			}
			ReplaceSystemCursors()

			case "MainChannelCheck", "ReportChannelCheck", "CriticalSSCheck", "AmuletSSCheck", "MachineSSCheck", "BalloonSSCheck", "ViciousSSCheck", "DeathSSCheck", "PlanterSSCheck", "HoneySSCheck", "CriticalErrorPingCheck", "DisconnectPingCheck", "GameFrozenPingCheck", "PhantomPingCheck", "UnexpectedDeathPingCheck", "EmergencyBalloonPingCheck", "HoneyUpdateSSCheck":
			hover_ctrl := hCtrl
			k := name
			ControlGetPos &hover_x, &hover_y, &hover_w, &hover_h, hCtrl
			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x40131416), hover_x-2, hover_y-2, hover_w+4, hover_h+4), Gdip_DeleteBrush(pBrush)

			ReplaceSystemCursors("IDC_HAND")
			UpdateLayeredWindow(hMain, hdc)

			while (hCtrl = hover_ctrl)
			{
				Sleep 20
				MouseGetPos , , , &hCtrl, 2
			}

			Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xff131416), hover_x-3, hover_y-3, hover_w+6, hover_h+6), Gdip_DeleteBrush(pBrush)
			if (%k% = 1)
				Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_BrushCreateSolid(0xff4bb543), hover_x-1, hover_y-1, 20, 20, 4), Gdip_DeleteBrush(pBrush), Gdip_DrawImage(G, bitmaps["check"], hover_x, hover_y)
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
		IniWrite v, "settings\nm_config.ini", "Status", var
		if WinExist("natro_macro.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, enum[var], v
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, enum[var], v
	}

	UpdateStr(var)
	{
		global
		IniWrite %var%, "settings\nm_config.ini", "Status", var
		if WinExist("natro_macro.ahk ahk_class AutoHotkey")
			PostMessage 0x5553, str_enum[var], 7
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage 0x5553, str_enum[var], 7
	}

	ReplaceSystemCursors(IDC := "")
	{
		static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := Map(  "IDC_APPSTARTING", 32650
								, "IDC_ARROW"      , 32512
								, "IDC_CROSS"      , 32515
								, "IDC_HAND"       , 32649
								, "IDC_HELP"       , 32651
								, "IDC_IBEAM"      , 32513
								, "IDC_NO"         , 32648
								, "IDC_SIZEALL"    , 32646
								, "IDC_SIZENESW"   , 32643
								, "IDC_SIZENWSE"   , 32642
								, "IDC_SIZEWE"     , 32644
								, "IDC_SIZENS"     , 32645
								, "IDC_UPARROW"    , 32516
								, "IDC_WAIT"       , 32514 )
		if !IDC
			DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
		else
		{
			hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
			for k, v in SysCursors
			{
				hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
				DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
			}
		}
	}

	ExitFunc(*)
	{
		DiscordGui.Destroy()
		try Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
	}
	'
	)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	return (WGUIPID := exec.ProcessID)
}

; SETTINGS TAB
; ------------------------
nm_guiThemeSelect(*){
	GuiTheme := MainGui["GuiTheme"].Text
	IniWrite GuiTheme, "settings\nm_config.ini", "Settings", "GuiTheme"
	reload
	Sleep 10000
}
nm_guiTransparencySet(*){
	global GuiTransparency
	MainGui["GuiTransparency"].Text := GuiTransparency := MainGui["GuiTransparencyUpDown"].Value * 5
	IniWrite GuiTransparency, "settings\nm_config.ini", "Settings", "GuiTransparency"
	WinSetTransparent 255-floor(GuiTransparency*2.55), MainGui
}
nm_AlwaysOnTop(*){
	global
	IniWrite (AlwaysOnTop := MainGui["AlwaysOnTop"].Value), "settings\nm_config.ini", "Settings", "AlwaysOnTop"
	MainGui.Opt((AlwaysOnTop ? "+" : "-") "AlwaysOnTop")
}
nm_HiveBees(GuiCtrl, *){
	global HiveBees
	p := EditGetCurrentCol(GuiCtrl)
	NewHiveBees := GuiCtrl.Value

	if (IsInteger(NewHiveBees) && (NewHiveBees > 50)) ; contains char other than digit, or more than 50
	{
		GuiCtrl.Value := HiveBees
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "You cannot enter a number above 50!")
	}
	else
	{
		HiveBees := NewHiveBees
		IniWrite HiveBees, "settings\nm_config.ini", "Settings", "HiveBees"
	}
}
nm_HiveBeesHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	Enter the number of Bees you have in your Hive.
	This doesn't have to be exactly the same as your in-game amount, but the macro will use this value to determine whether it can travel to the 35 Bee Zone, use the Red Cannon, etc.

	NOTE:
	Lowering this number will increase the time your character waits at hive after converting or before going to battle.
	If you notice that your bees don't finish converting or haven't recovered to fight mobs, reduce this value but keep it above 35 to enable access to all areas in the map.
	)", "Hive Bees", 0x40000
}
nm_AnnounceGuidWarn(GuiCtrl, *){
	if GuiCtrl.Value = 0
		IniWrite (GuiCtrl.Value := 0), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
	else {
		if (MsgBox("
		(
		WARNING:
		There have been reports of players getting warned on Roblox for using this feature. It is recommended to only enable when using private servers.
		There is still a chance of being warned, or potentially banned, even in private servers. Use at your own risk.

		DESCRIPTION:
		When enabled, the macro will send a message to the Roblox chat reading <<Guiding Star in (field) until __:mm>> when the "Guiding star in (field)" text is detected on the bottom right of your screen.
		)", "Announce Guiding Star", 0x40031)="Ok"){
			IniWrite (GuiCtrl.Value := 1), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
		} else IniWrite (GuiCtrl.Value := 0), "settings\nm_config.ini", "Settings", "AnnounceGuidingStar"
	}
}
nm_ResetConfig(*){
	if (MsgBox("
	(
	Are you sure you want to reset ALL Natro settings?
	This will set all settings (Gather, Planters, Boost, Quests, etc.) to the default AND reset all timers (Collect/Kill, Planters, etc.), as if you freshly started the macro.

	If you want to proceed, click 'Yes'. Backup your 'settings' folder if you're unsure.
	)", "Reset Settings", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
	{
		DirDelete A_WorkingDir "\settings"
		return stop()
	}
}
nm_ResetFieldDefaultGUI(*){
	global
	local x,y,i,k,v,hBM
	GuiClose(*){
		if (IsSet(FieldDefaultGui) && IsObject(FieldDefaultGui))
			FieldDefaultGui.Destroy(), FieldDefaultGui := ""
	}
	GuiClose()
	FieldDefaultGui := Gui("+AlwaysOnTop +Owner" MainGui.Hwnd, "Reset Field Defaults")
	FieldDefaultGui.OnEvent("Close", GuiClose)
	FieldDefaultGui.SetFont("s9 cDefault Norm", "Tahoma")
	i := 0
	for k,v in StandardFieldDefault
	{
		i++
		x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
		FieldDefaultGui.Add("Button", "x" x " y" y " w100 h20 vResetFieldDefault" i, k).OnEvent("Click", nm_ResetFieldDefault)
	}
	i++
	x := 10+((i-1)//6)*110, y := 6+Mod(i-1, 6)*22
	hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["allfields"])
	FieldDefaultGui.Add("Picture", "x" x " y" y " w100 h20", "HBITMAP:*" hBM).OnEvent("Click", nm_ResetAllFieldDefaults)
	DllCall("DeleteObject", "ptr", hBM)
	FieldDefaultGui.Show("w330 h132")
}
nm_ResetFieldDefault(GuiCtrl, *){
	global FieldDefault, StandardFieldDefault
	n := SubStr(GuiCtrl.Name, 18) ; ResetFieldDefault
	for k,v in StandardFieldDefault
	{
		if (A_Index = n)
		{
			if (MsgBox(
			(
			"Reset " k " default settings to these standard settings?

			Pattern Shape: " v["pattern"] "
			Pattern Length: " v["size"] "
			Pattern Width: " v["width"] "
			Pattern Invert F/B: " (v["invertFB"] ? "Enabled" : "Disabled") "
			Pattern Invert L/R: " (v["invertLR"] ? "Enabled" : "Disabled") "
			Shift-Lock: " (v["shiftlock"] ? "Enabled" : "Disabled") "

			Until Mins: " v["gathertime"] "
			Until Pack: " v["percent"] "%
			To Hive By: " v["convert"] "

			Rotate Camera Direction: " v["camera"] "
			Rotate Camera Turns: " v["turns"] "

			Sprinkler Location: " v["sprinkler"] "
			Sprinkler Distance: " v["distance"]
			), "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
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
					IniWrite j, "settings\field_config.ini", k, i
				MsgBox "Changed " k " field defaults back to their standard settings!", "Reset Field Defaults", 0x40040 " Owner" MainGui.Hwnd
			}

			break
		}
	}
}
nm_ResetAllFieldDefaults(*){
	global FieldDefault, StandardFieldDefault
	if (MsgBox("Are you sure you want to reset all field default settings to their standard settings?", "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
	{
		if (MsgBox("ARE YOU SUPER DUPER SURE?", "Reset Field Defaults", 0x40034 " Owner" MainGui.Hwnd) = "Yes")
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

			file := FileOpen(A_WorkingDir "\settings\field_config.ini", "w-d"), file.Write(ini), file.Close()

			MsgBox "Changed all field defaults back to their standard settings!", "Reset Field Defaults", 0x40040 " Owner" MainGui.Hwnd
		}
	}
}
nm_testReconnect(*){
	CloseRoblox()
	if (DisconnectCheck(1) = 1)
		MsgBox "Success!", "Reconnect Test", 0x1000
}
nm_ServerLink(GuiCtrl, *){
	global PrivServer, FallbackServer1, FallbackServer2, FallbackServer3
	p := EditGetCurrentCol(GuiCtrl)
	k := GuiCtrl.Name
	str := GuiCtrl.Value

	RegExMatch(str, "i)((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/([a-z]{2}\/)?games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*", &NewPrivServer)
	if ((StrLen(str) > 0) && !IsObject(NewPrivServer))
	{
		GuiCtrl.Value := %k%
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		if InStr(str, "/share?code")
			nm_ShowErrorBalloonTip(GuiCtrl, "Unresolved Private Server Link", "
				(
				You entered a 'share?code' link!
				To fix this:
				 1. Paste this link into your browser
				 2. Wait for Bee Swarm Simulator to load
				 3. Copy the link at the top of your browser.
				)")
		else
			nm_ShowErrorBalloonTip(GuiCtrl, "Invalid Private Server Link", "Make sure your link is:`r`n- copied correctly and completely`r`n- for Bee Swarm Simulator by Onett")
	}
	else
	{
		GuiCtrl.Value := %k% := IsObject(NewPrivServer) ? NewPrivServer[0] : ""
		IniWrite %k%, "settings\nm_config.ini", "Settings", k

		if (k = "PrivServer")
			PostSubmacroMessage("Status", 0x5553, 10, 6)
	}
}
nm_ReconnectMethod(GuiCtrl, *){
	global ReconnectMethod
	static val := ["Deeplink", "Browser"], l := val.Length

	if (ReconnectMethod = "Deeplink")
	{
		if (MsgBox("
		(
		Setting Join Method to 'Browser' is not recommended!

		Even if you have a problem with the 'Deeplink' method, fixing it is a much better option than using the 'Browser' method.
		Read [?] for more information!

		Are you sure you want to change this?
		)", "Join Method", 0x1034 " T60 Owner" MainGui.Hwnd) = "Yes")
			i := 1
		else
			return
	}
	else
		i := 2

	i := (ReconnectMethod = "Deeplink") ? 1 : 2

	MainGui["ReconnectMethod"].Text := ReconnectMethod := val[(GuiCtrl.Name = "RMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite ReconnectMethod, "settings\nm_config.ini", "Settings", "ReconnectMethod"
}
nm_setReconnectInterval(GuiCtrl, *){
	global ReconnectInterval
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectInterval := GuiCtrl.Value

	if (IsNumber(NewReconnectInterval) && ((NewReconnectInterval = 0) || ((Mod(24, NewReconnectInterval) != 0) && NewReconnectInterval))) ; not a factor of 24 or 0
	{
		GuiCtrl.Value := ReconnectInterval
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Interval must be a factor of 24!`r`nThese are: 1, 2, 3, 4, 6, 8, 12, 24.")
	}
	else
	{
		ReconnectInterval := NewReconnectInterval
		IniWrite ReconnectInterval, "settings\nm_config.ini", "Settings", "ReconnectInterval"
	}
}
nm_setReconnectHour(GuiCtrl, *){
	global ReconnectHour
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectHour := GuiCtrl.Value

	if (IsNumber(NewReconnectHour) && (NewReconnectHour > 23)) ; not between 00 and 24
	{
		GuiCtrl.Value := ReconnectHour
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Hour must be between 00 and 23!")
	}
	else
	{
		ReconnectHour := NewReconnectHour
		IniWrite ReconnectHour, "settings\nm_config.ini", "Settings", "ReconnectHour"
	}
}
nm_setReconnectMin(GuiCtrl, *){
	global ReconnectMin
	p := EditGetCurrentCol(GuiCtrl)
	NewReconnectMin := GuiCtrl.Value

	if (IsNumber(NewReconnectMin) && (NewReconnectMin > 59)) ; not between 00 and 59
	{
		GuiCtrl.Value := ReconnectMin
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Number", "Reconnect Minute must be between 00 and 59!")
	}
	else
	{
		ReconnectMin := NewReconnectMin
		IniWrite ReconnectMin, "settings\nm_config.ini", "Settings", "ReconnectMin"
	}
}
nm_ReconnectMethodHelp(*){ ; join method information
	MsgBox "
	(
	DESCRIPTION:
	This option lets you choose between 'Deeplink' and 'Browser' reconnect methods.

	'Deeplink' is the recommended method: it's faster (skips the browser step completely) and works with the Roblox Store app.
	It can also join BSS directly without the need for a redirecting game like BSS Rejoin. You can search "Roblox Developer Deeplinking" online for more info.

	'Browser' should only be used when 'Deeplink' does not work.
	This is the old/legacy method of reconnecting: it can have inconsistencies between browsers (e.g. failure to close tabs, Roblox not logged in)
	and you will not be able to join a public server directly ('Deeplink' is forced when joining public servers).
	)", "Join Method", 0x40000
}
nm_ReconnectTimeHelp(*){
	global ReconnectHour, ReconnectMin, ReconnectInterval
	hhmmUTC := FormatTime(A_NowUTC, "HH:mm")
	hhmmLOC := FormatTime(A_Now, "HH:mm")
	s := DateDiff(A_Now, A_NowUTC, "S")
	o := Buffer(256), DllCall("GetDurationFormatEx"
		, "Ptr", 0
		, "UInt", 0
		, "Ptr", 0
		, "Int64", Abs(s)*10000000
		, "WStr", ((s>=0)?"+":"-") "hh:mm"
		, "Ptr", o.Ptr
		, "Int", 256), o := StrGet(o)

	if((!ReconnectHour && ReconnectHour!=0) || (!ReconnectMin && ReconnectMin!=0) || (Mod(24, ReconnectInterval) != 0)) {
		ReconnectTimeString:="`n<Invalid Time>"
	} else {
		ReconnectTimeString:=""
		Loop 24//ReconnectInterval {
			time := "19700101" SubStr("0" Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24), -2) SubStr("0" Mod(ReconnectMin, 60), -2) "00"
			hhmmReconnectUTC := FormatTime(time, "HH:mm")
			time := DateAdd(time, s, "S")
			hhmmReconnectLOC := FormatTime(time, "HH:mm")
			ReconnectTimeString.="`n" hhmmReconnectUTC " UTC = Local Time: " hhmmReconnectLOC
		}
	}

	MsgBox
	(
	"DEFINITION:
	UTC is the time standard commonly used across the world.
	The world's timing centers have agreed to keep their time scales closely synchronized - or coordinated - therefore the name Coordinated Universal Time.

	Why use UTC?
	This allows all players on the same server to enter the same time value into the GUI regardless of the local timezone.

	TIME NOW:
	Local Time: " hhmmLOC " (UTC" o " hours) = UTC Time: " hhmmUTC "

	RECONNECT TIMES: " ReconnectTimeString
	), "Coordinated Universal Time (UTC)", 0x40000 " Owner" MainGui.Hwnd
}
nm_NatroSoBrokeHelp(*){ ; so broke information
	MsgBox "
	(
	DESCRIPTION:
	Enable this to have the macro say 'Natro so broke :weary:' in chat after it reconnects! This is a reference to e_lol's macros which type 'e_lol so pro :weary:' in chat.
	)", "Natro so broke :weary:", 0x40000
}
nm_PublicFallbackHelp(*){ ; public fallback information
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will revert to attempting to join a Public Server if your Server Link failed three times.
	Otherwise, it will keep trying the Server Link you entered above until it succeeds.
	)", "Public Server Fallback", 0x40000
}
nm_moveSpeed(GuiCtrl, *){
	global MoveSpeedNum
	p := EditGetCurrentCol(GuiCtrl)
	NewMoveSpeed := GuiCtrl.Value
	StrReplace(NewMoveSpeed, ".", , , &n)

	if (NewMoveSpeed ~= "[^\d\.]" || (n > 1)) ; contains char other than digit or dpt, or more than 1 dpt
	{
		GuiCtrl.Value := MoveSpeedNum
		SendMessage 0xB1, p-2, p-2, GuiCtrl
	}
	else
	{
		MoveSpeedNum := NewMoveSpeed
		IniWrite MoveSpeedNum, "settings\nm_config.ini", "Settings", "MoveSpeedNum"
	}
}
nm_NewWalkHelp(*){ ; movespeed correction information
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will detect your Haste, Bear Morph, Coconut Haste, Haste+, Oil and Super Smoothie values real-time.
	Using this information, it will calculate the distance you have moved and use that for more accurate movements.
	If working as intended, this option will dramatically reduce drift and make Traveling anywhere in game much more accurate.

	IMPORTANT:
	If you have this option enabled, make sure your 'Movement Speed' is EXACTLY as shown in BSS Settings menu without haste or other temporary buffs (e.g. write 33.6 as 33.6 without any rounding).
	Also, it is ESSENTIAL that your Display Scale is 100%, otherwise the buffs will not be detected properly.
	)", "MoveSpeed Correction", 0x40000
}
nm_MoveMethod(GuiCtrl, *){
	global MoveMethod
	static val := ["Walk", "Cannon"], l := val.Length

	i := (MoveMethod = "Walk") ? 1 : 2

	MainGui["MoveMethod"].Text := MoveMethod := val[(GuiCtrl.Name = "MMRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite MoveMethod, "settings\nm_config.ini", "Settings", "MoveMethod"
}
nm_SprinklerType(GuiCtrl, *){
	global SprinklerType
	static val := ["None", "Basic", "Silver", "Golden", "Diamond", "Supreme"], l := val.Length

	switch SprinklerType, 0
	{
		case "None":
		i := 1
		case "Basic":
		i := 2
		case "Silver":
		i := 3
		case "Golden":
		i := 4
		case "Diamond":
		i := 5
		default:
		i := 6
	}

	MainGui["SprinklerType"].Text := SprinklerType := val[(GuiCtrl.Name = "STRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	IniWrite SprinklerType, "settings\nm_config.ini", "Settings", "SprinklerType"
}
nm_ConvertBalloon(GuiCtrl, *){
	global ConvertBalloon
	static val := ["Never", "Every", "Always", "Gather"], l := val.Length

	i := (ConvertBalloon = "Never") ? 1 : (ConvertBalloon = "Every") ? 2 : (ConvertBalloon = "Always") ? 3 : 4

	MainGui["ConvertBalloon"].Text := ConvertBalloon := val[(GuiCtrl.Name = "CBRight") ? (Mod(i, l) + 1) : (Mod(l + i - 2, l) + 1)]
	MainGui["ConvertMins"].Enabled := (ConvertBalloon = "Every")
	IniWrite ConvertBalloon, "settings\nm_config.ini", "Settings", "ConvertBalloon"
}

; MISC TAB
; ------------------------
nm_BitterberryFeeder(*)
{
	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Bitterberry Auto-Feeder", 0x40030 " T20"
		return
	}

	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "Roblox.ahk"
	#Include "nm_OpenMenu.ahk"
	#Include "nm_InventorySearch.ahk"

	CoordMode "Mouse", "Screen"
	OnExit(ExitFunc)
	pToken := Gdip_Startup()

	bitmaps := Map()
	bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
	bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
	bitmaps["beemenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC")
	bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
	bitmaps["bitterberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAG8AAAAbCAMAAABFqCGFAAAB11BMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8oNkApN0EqOEMrOUMsOkQtO0UuPEYvPUcwPkgyQEkzQUo0QUs1Q0w3RU44RU85Rk86SFE8SVM9SlM+S1Q/TFVATVZCT1hDUFlEUVlFUVpGU1xHVFxJVV5KVl9LV19NWWJPW2NRXWVSXmZUYGhVYWhWYWlXYmpXY2tbZm5cZ29daG9eanFibXRibnVkb3ZlcHdoc3ptd35ueX9veoBweoFzfYN0foR1f4V2gIZ4god6hIp7hYt+h41/iY6Aio+FjpSGj5SHkJWKk5iLlJmMlZqNlpqOl5uQmJ2QmZ2Rmp6Sm5+UnKCVnaGZoaWbo6ecpKigp6uhqKyjq66mrbCnrrGnr7Kor7OrsrWss7avtrmwt7myuLu2vL+4v8G5wMK6wMO8wsS+xMa/xcfAxsjBx8nDyMrEyszGzM3HzM7Izc/Jzs/Jz9DK0NHN0tPP1NXQ1dbR1tfS19jV2drX3NzY3N3Z3d7b4ODc4OHe4uLf4+Pg5OTg5eXi5ubj5+fm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/ZX5XClAAACKElEQVR42u3W61NMYQDH8W9iu7uEhAhJURIphYRci0QiFXKJXAttQnIPXdVWK/3+WHvK6dnZfaY3O443fm9+L34zz2fmzDPnHORt+O/9BS8HJ6mlL2Xys6XJlCVTLbUxepDQJaln9b5ZSXs4J7dsKeZIzB45kvzpRY6XHYLcsiU/Ju+YpOHD8NEdPPDUD8+kL52dwcW9K2kF3cazzqYX8d5Ar9QMQ7qMk/o/JU3WZfnWnx2RVEpWPLSFvJ1FKekVvZIss9v10C9JfXAy0hsswTdu937tx0nepHMgkDCifHPFLLPbn5dQI0k18NpyX05r3ot8nq2sejz+dCVNcwfeDAwq5CW1TzzPZLttNl3CmqA0k0G+or3kd7J7uTRIqqNw7oFJcrwKSbfhvWU2fRfuSw+h1eKxdsjqBeKYT6pz0G4Z7yt0WGbTkys4IFWSPKpwr1rSjzPQbPW+4SYY4U1Dm3V2WyeIHxhOpEpRnoJJnLJ6E3BJ84nwQlS7bTaeHxquwwuLN5XIeRmvVgu1iTJJ09FeB7wys83TNjYXslXR3mg1+Be8XeTe8bt1gbgbga6Msu5wL+lWoG8L62ZkZpt3FeCa/f15VAteLfDJrYkdOFn+NtybS9w9ycw27/tS8A1ZvGXZjTPGGzuYvNfUaM0GX2bVB5mDqgoOFaWkFT+SrLPxVA6VXn5vG+GJl14eG2c99Hrgojz0jhM/4KE3lkK5PPRa4cG/+x/8DdlCsT+3EwaSAAAAAElFTkSuQmCC")
	bitmaps["feed"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAADwAAAAUAQMAAADrzcxqAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAE1JREFUeNqNzbENwCAMRNHfpYxLSo/ACB4pG8SjMkImIAiwRIe46lX3+QtzAcE5wQ1cHeKQHhw10EwFwISK6YAvvCVg7LBamuM5fRGFBk/MFx8u1mbtAAAAAElFTkSuQmCC")
	bitmaps["greensuccess"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAA4AAAALCAYAAABPhbxiAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhdEVYdENyZWF0aW9uIFRpbWUAMjAyMzowMzowOCAxNToyMzo1N/c+ABwAAAAdSURBVChTY3T+H/6fgQzABKVJBqMa8YDhr5GBAQBwxAKu5PiUjAAAAA5lWElmTU0AKgAAAAgAAAAAAAAA0lOTAAAAAElFTkSuQmCC")
	#Include "%A_ScriptDir%\nm_image_assets\offset\bitmaps.ahk"

	if (MsgBox("BITTERBERRY AUTO FEEDER v0.2 by anniespony#8135``nMake sure BEE SLOT TO MUTATE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE BEE IS RADIOACTIVE AT ALL TIMES!", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel")
		ExitApp

	bitterberrynos := InputBox("Enter the amount of bitterberry used each time", "How many bitterberry?", "w320 h180 T60").Value
	if IsInteger(bitterberrynos) {
		if (bitterberrynos > 30)
			if (MsgBox("You have entered " bitterberrynos " which is more than 30.``nAre you sure?", "Bitterberry Auto-Feeder v0.2", 0x40034) = "No")
				ExitApp
	} else {
		MsgBox "You must enter a number for Bitterberries!!``nStopping Feeder!", "Bitterberry Auto-Feeder v0.2", 0x40010
		ExitApp
	}

	if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Bitterberry Auto-Feeder v0.2", 0x40001) = "Cancel")
		ExitApp

	hwnd := GetRobloxHWND()
	ActivateRoblox()
	GetRobloxClientPos(hwnd)
	offsetY := GetYOffset(hwnd, &offsetfail)
	if (offsetfail = 1) {
		MsgBox "Unable to detect in-game GUI offset!``nStopping Feeder!``n``nThere are a few reasons why this can happen, including:``n - Incorrect graphics settings``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!", "WARNING!!", "0x40030"
		ExitApp
	}

	StatusBar := Gui("-Caption +E0x80000 +AlwaysOnTop +ToolWindow -DPIScale")
	StatusBar.Show("NA")
	hbm := CreateDIBSection(windowWidth, windowHeight), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 2)
	Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x60000000), -1, -1, windowWidth+1, windowHeight+1), Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, windowHeight)

	KeyWait "LButton", "D" ; Wait for the left mouse button to be pressed down.
	MouseGetPos &beeX, &beeY
	Gdip_GraphicsClear(G), Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xd0000000), -1, -1, windowWidth+1, 38), Gdip_DeleteBrush(pBrush)
	Gdip_TextToGraphics(G, "Mutating... Right Click or Shift to Stop!", "x0 y0 cffff5f1f Bold Center vCenter s24", "Tahoma", windowWidth, 38)
	UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, 38)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	try
	{
		Hotkey "Shift", ExitFunc, "On"
		Hotkey "RButton", ExitFunc, "On"
		Hotkey "F11", ExitFunc, "On"
	}
	Sleep 250

	Loop
	{
		if ((pos := nm_InventorySearch("bitterberry", "down", , , , (A_Index = 1) ? 40 : 4)) = 0)
		{
			MsgBox "You ran out of Bitterberries!", "Bitterberry Auto-Feeder v0.2", 0x40010
			break
		}
		GetRobloxClientPos(hwnd)

		SendEvent "{Click " windowX+pos[1] " " windowY+pos[2] " 0}"
		Send "{Click Down}"
		Sleep 100
		SendEvent "{Click " beeX " " beeY " 0}"
		Sleep 100
		Send "{Click Up}"
		Loop 10
		{
			Sleep 100
			pBMScreen := Gdip_BitmapFromScreen(windowX+(54*windowWidth)//100-300 "|" windowY+offsetY+(46*windowHeight)//100-59 "|250|100")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], &pos, , , , , 2, , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1)+140 " " windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+5 "}" ; Click Number
				Sleep 100
				Loop StrLen(bitterberrynos)
				{
					SendEvent "{Text}" SubStr(bitterberrynos, A_Index, 1)
					Sleep 100
				}
				SendEvent "{Click " windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1) " " windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1) "}" ; Click Feed
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 10)
				continue 2
		}
		Sleep 750

		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-295 "|" windowY+offsetY+((4*windowHeight)//10 - 15) "|150|50")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["greensuccess"], , , , , , 20) = 1) {
			if (MsgBox("SUCCESS!!!!``nKeep this?", "Bitterberry Auto-Feeder v0.2", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				ActivateRoblox()
				SendEvent "{Click " windowX + (windowWidth//2 - 132) " " windowY + offsetY + ((4*windowHeight)//10 - 150) "}" ; Close Bee
			}
		}
		Gdip_DisposeImage(pBMScreen)
	}
	ExitApp

	ExitFunc(*)
	{
		try StatusBar.Destroy()
		try Gdip_Shutdown(pToken)
		ExitApp
	}
	'
	)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_BasicEggHatcher(*)
{
	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Basic Bee Replacement Program", 0x40030 " T20"
		return
	}

	script :=
	(
	'
	#NoTrayIcon
	#SingleInstance Force

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "Roblox.ahk"
	#Include "nm_OpenMenu.ahk"
	#Include "nm_InventorySearch.ahk"

	CoordMode "Mouse", "Screen"
	OnExit(ExitFunc)
	pToken := Gdip_Startup()

	bitmaps := Map()
	bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
	bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
	bitmaps["beemenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACsAAAAsAQAAAADUI3zVAAAAAnRSTlMAAHaTzTgAAACaSURBVHjadc5BDgIhDAXQT9U4y1m6G24inkyO4lGaOUm9AW7MzMY6HyQxJjaBFwotxdW3UAEjNhCc+/1z+mXGmgCH22Ti/S5bIRoXSMgtmTASBeOFsx6td/lDIgGIJ8Czl6kVRAguGL4mW9NcC8zJUjRvlCXXZH3kxiUYW+sBgewhRPq3exIwEOhYiZHl/nS3HdIBePQBlfvtDUnsNfflK46tAAAAAElFTkSuQmCC")
	bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
	bitmaps["basicegg"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGIAAAAaCAMAAAB7CnmQAAABuVBMVEUbKjUdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0lND4nNUAoNkApOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgxP0kyQEkzQUo0QUs1Qkw2RE03RU44RU85Rk86SFE7SVI8SVNATVZEUVlGUltGU1xKVl9LV19MWWFPW2NQXGRRXWVVYWhWYWlXYmpXY2tdaXBeanFga3JhbHNibXRibnVjbnVkb3ZmcXhncnhoc3ppdHtqdXtsdn1td35ueX9veoBweoFzfYN0foR1f4V2gIZ3gYd4god6hIp+h42Ci5GFjpSGj5SIkZaJkpePl5yQmJ2VnaGWnqKZoaWaoqabo6ecpKidpamfp6qjq66mrbCnr7Kor7Ots7avtrmwt7m1vL63vcC+xMa/xcfAxsjBx8nCyMnDyMrEyszFy8zGzM3HzM7Izc/Jzs/Jz9DN0tPQ1dbR1tfS19jT2NjU2NnV2drV2tvW29zY3N3Z3d7a39/c4OHe4uLg5OTg5eXi5ubj5+fl6ejm6enm6uro7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9PPx9fTy9fTz9vX09/Y9aLFlAAACKklEQVR42u3Ta1MSUQDG8cfiVmZBUoqmBhVkRtj9JkmoSRGmlbZadiG6mXnpSmG6QWlqCDyfuNlYTu3sMsNM6zufV/9X5zc7Zw+46cMWUTvhg7KdoenNJgDbU1bZa9fxEvXzQt2zWgn4WGVTzs7/JSIkc+eBNGubIKJq1UZwHkiRfHm5xdI8mOW/yySTeTOIWeANmd4GZQdzJJOd9Q1d4wVyBJBJyv0t1v3nZoyJwu1DDncEkDStIZaCsK6QHDgQH+sGhsgndVAWrhDf2qHM8cKQCKM8SbSGUDdIkqt5stiGIHkS/uzHIW+6QtxA3f21lNOaoPa6ZaWfA+GFhR5AEm1A7HhLkp/ONmxvqkeAjMDzuMgSK8Q+nCY5vUQjIgbnL/IrIIk2IOCWyczecvvJd7sAT2K5QqwAd6pf9wl0Uz1WbS0RJbkcA0bIa2ifXf/QoRD8fNEKtM6pRBp4UJ3wo1c9VrSOYN6BAfIwxkge+UOQi3EbAjV9RRdOqceK1hPrdsSVw28JYoPkKPBTcxevFg2JCJqK6rFq64nvUWCK7IcrlbtrU4gJz/gPuQeODe0fZUkYEY+A69nMBUASbXTdvSS/iOuWG8t1U7yLNt27UBciS0G1JdE6wuIdLlAxrrjtR6+GYqQc99ldxyb593X3NVvdZ2ZoRHA13mFtvARIogVh6uaBh5o2nxgG5jRtOvF+N1oLmjabmNwDjGradOIe0Kdp84m1wERJ378B3+p4iisaatgAAAAASUVORK5CYII=")
	bitmaps["royaljelly"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGwAAAAcCAMAAACzmqo+AAAB+FBMVEUbKjUcKzYdLDceLDceLTgfLjkgLzohMDoiMDsjMTwkMj0kMz0lND4mND8nNUAoNkApN0EpOEIqOEMrOUMsOkQtO0UuPEYvPEYvPUcwPkgyQEkzQUo0QUs1Qkw1Q0w3RU44RU85Rk86SFE7SVI8SVM+S1Q/TFVDUFlEUVlFUVpGUltGU1xIVV1KVl9LV19MWWFPW2NWYWlXYmpXY2tbZm5cZ29daG9daXBga3JibXRibnVlcHdpdHttd35weoFxe4FyfIJzfYN0foR1f4V2gIZ3gYd4god5goh6hIp7hYt8hot+h41/iI6Aio+BipCCi5GFjpSFjpOGj5SHkJWIkZaJkpeKk5iKk5eLlJmMlZqNlpqPl5yQmJ2QmZ2Rmp6Sm5+UnKCVnaGaoqabo6ecpKigp6ujq66kq6+lrLCor7Ots7avtrmwt7mxt7qyuLu1vL62vL+3vcC5wMK6wMO8wsS9w8W/xcfAxsjDyMrDycvEyszGzM3HzM7Jzs/K0NHL0NLN0tPO09TP1NXQ1dbR1tfS19jT2NjV2drV2tvW29zX3NzY3N3a39/b4ODc4OHd4eLe4uLf4+Pg5OTg5eXi5ubj5+fk6Ojm6enm6urn6+vo7Ovp7ezq7e3r7u7r7+7s8O/t8fDu8fHv8vHw8/Lx9fTy9fTz9vX09/a7z3nGAAACf0lEQVR42u3W+VOMcQDH8Y9KVkUUkXQqJEqH0OWokHLlzplyRSgJFZWjnEmOtqhWx77/TbNPzHeenbZtZk3GjPcPO7O73/m8dvZ5fnjEPKb/2L+IpcqTI+sBc6s9d2RuR8xBb0wKaWEuXZe+Y69Beul9ZPrVJ6Z1bvBf7eyYOVI7M7YHGMiROucLo0tqwmdtRfEL4/YN/insmfQC+FyW4EiqGIRT1nvr81LeBk//0c5ZMFd1UujaiiEbZlsx2NBOpQMD8fKU8pX3QaoEqJSeQlni0frt0knf2FSOPKW7bJhtReYGWfwEKFdks6txsY5AtmImYDJWGcDYBEwlKds3Vqfo5pGWKF2yYbYVgwV1A1NLdBo4qFVwU7oF96Q64HXB8pA1S5XpG9ugGqBamXbMrJhr1ig1Ax+kx1jfDeNapm1QqLBh6IuR1Raf2NgCTRdhx8yKwcajVAR0Sr1Ah/QK9iq43+lQMVCu5K4fvSm+sZ4B/W7ChpkVg7Fb4SPwUWoDmqxz7VJNvfQI2KR6IMMbw9kHcE3qH5XOznjrmxWDtUo3wB3965rFA6xXSqbSsJhzM2CTu8K2TgIlWuEmWXnAuB2zrRjMHa9s4LAi7rpuO6Z/5UVJugxQqpUPnVcWeWHsl3b0OOtCVAXHteDqWGtsXpsXZlYMxiEF9YMzTZ7SRwA+hUihXwDezXyDuApktXkURjfKU+Rzb8ysGKxbugAMVyU7Uo+NYpUvFYKlFa92ZJXkHrBjuBuyYxelnrCOD1cmhMYVv8EbMytits5L9wkks+IfS1eimwAyK/6xDukMgWRW/GMlCu4ngMyKf+xbuPIJJLPiH6uT7hBAZuVvPMr9BDBOM9MqS26gAAAAAElFTkSuQmCC")
	bitmaps["giftedstar"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAgMAAAC5YVYYAAAACVBMVEX9rDT+rDT/rDOj6H2ZAAAAFElEQVR42mNYtYoBgVYyrFoBYQMAf4AKnlh184sAAAAASUVORK5CYII=")
	bitmaps["yes"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAAPAQMAAAAiQ1bcAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFZJREFUeAEBSwC0/wDDAAfAAEIACGAAfgAQMAA8ABAQABgAIAgAGAAgCAAYACAYABgAP/gAGAAgAAAYAAAAABgAIAAAGAAwAAAYADAAABgAGDAAGAAP4FGfB+0KKAbEAAAAAElFTkSuQmCC")
	#Include "%A_ScriptDir%\nm_image_assets\offset\bitmaps.ahk"

	if (MsgBox("WELCOME TO THE BASIC BEE REPLACEMENT PROGRAM!!!!!``nMade by anniespony#8135``n``nMake sure BEE SLOT TO CHANGE is always visible``nDO NOT MOVE THE SCREEN OR RESIZE WINDOW FROM NOW ON.``nMAKE SURE AUTO-JELLY IS DISABLED!!", "Basic Bee Replacement Program", 0x40001) = "Cancel")
		ExitApp

	if (MsgBox("After dismissing this message,``nleft click ONLY once on BEE SLOT", "Basic Bee Replacement Program", 0x40001) = "Cancel")
		ExitApp

	hwnd := GetRobloxHWND()
	ActivateRoblox()
	GetRobloxClientPos()
	offsetY := GetYOffset(hwnd, &offsetfail)
	if (offsetfail = 1) {
		MsgBox "Unable to detect in-game GUI offset!``nStopping Feeder!``n``nThere are a few reasons why this can happen, including:``n - Incorrect graphics settings``n - Your `'Experience Language`' is not set to English``n - Something is covering the top of your Roblox window``n``nJoin our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!", "WARNING!!", 0x40030
		ExitApp
	}
	StatusBar := Gui("-Caption +E0x80000 +AlwaysOnTop +ToolWindow -DPIScale")
	StatusBar.Show("NA")
	hbm := CreateDIBSection(windowWidth, windowHeight), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 2)
	Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0x60000000), -1, -1, windowWidth+1, windowHeight+1), Gdip_DeleteBrush(pBrush)
	UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, windowHeight)

	KeyWait "LButton", "D" ; Wait for the left mouse button to be pressed down.
	MouseGetPos &beeX, &beeY
	Gdip_GraphicsClear(G), Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(0xd0000000), -1, -1, windowWidth+1, 38), Gdip_DeleteBrush(pBrush)
	Gdip_TextToGraphics(G, "Hatching... Right Click or Shift to Stop!", "x0 y0 cffff5f1f Bold Center vCenter s24", "Tahoma", windowWidth, 38)
	UpdateLayeredWindow(StatusBar.Hwnd, hdc, windowX, windowY, windowWidth, 38)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Hotkey "Shift", ExitFunc, "On"
	Hotkey "RButton", ExitFunc, "On"
	Hotkey "F11", ExitFunc, "On"
	Sleep 250

	pBMC := Gdip_CreateBitmap(2,2), G := Gdip_GraphicsFromImage(pBMC), Gdip_GraphicsClear(G,0xffae792f), Gdip_DeleteGraphics(G) ; Common
	pBMM := Gdip_CreateBitmap(2,2), G := Gdip_GraphicsFromImage(pBMM), Gdip_GraphicsClear(G,0xffbda4ff), Gdip_DeleteGraphics(G) ; Mythic

	rj := 0
	Loop
	{
		if ((pos := (A_Index = 1) ? nm_InventorySearch("basicegg", "up", , , , 70) : (rj = 1) ? nm_InventorySearch("royaljelly", "down", , , 0, 7) : nm_InventorySearch("basicegg", "up", , , 0, 7)) = 0)
		{
			MsgBox "You ran out of " ((rj = 1) ? "Royal Jellies!" : "Basic Eggs!"), "Basic Bee Replacement Program", 0x40010
			break
		}
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+pos[1] " " windowY+pos[2] " 0}"
		Send "{Click Down}"
		Sleep 100
		SendEvent "{Click " beeX " " beeY " 0}"
		Sleep 100
		Send "{Click Up}"
		Loop 10
		{
			Sleep 100
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+offsetY+windowHeight//2-52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1) " " windowY+offsetY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1) "}"
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 10)
			{
				rj := 1
				continue 2
			}
		}
		Sleep 750

		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-155 "|" windowY+offsetY+((4*windowHeight)//10 - 135) "|310|205"), rj := 0
		if (Gdip_ImageSearch(pBMScreen, pBMM, , 50, 165, 260, 205, 2, , , 5) = 5) { ; Mythic Hatched
			if (MsgBox("MYTHIC!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, pBMC, , 50, 165, 260, 205, 2, , , 5) = 5) {
			rj := 1
			if (Gdip_ImageSearch(pBMScreen, bitmaps["giftedstar"], , 0, 20, 130, 50, 5) = 1) { ; If gifted is hatched, stop
				MsgBox "SUCCESS!!!!", "Basic Bee Replacement Program", 0x40020
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		else if (Gdip_ImageSearch(pBMScreen, bitmaps["giftedstar"], , 0, 20, 130, 50, 5) = 1) { ; Non-Basic Gifted Hatched
			if (MsgBox("GIFTED!!!!``nKeep this?", "Basic Bee Replacement Program", 0x40024) = "Yes")
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
		}
		Gdip_DisposeImage(pBMScreen)
	}
	ExitApp

	ExitFunc(*)
	{
		try Gdip_DisposeImage(pBMC), Gdip_DisposeImage(pBMM)
		try StatusBar.Destroy()
		try Gdip_Shutdown(pToken)
		ExitApp
	}
	'
	)

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
}
nm_GenerateBeeList(*)
{
	global bitmaps
	static bees := ["basic"
		,"bomber","brave","bumble","cool","hasty","looker","rad","rascal","stubborn"
		,"bubble","bucko","commander","demo","exhausted","fire","frosty","honey","rage","riley","shocked"
		,"baby","carpenter","demon","diamond","lion","music","ninja","shy"
		,"buoyant","fuzzy","precise","spicy","tadpole","vector"
		,"bear","cobalt","crimson","digital","festive","gummy","photon","puppy","tabby","vicious","windy"]

	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Export Bee List", 0x40030 " T20"
		return
	}

	; initialise object to fill
	bee_data := Map()

	; open menu
	ActivateRoblox()
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	nm_OpenMenu()
	nm_OpenMenu("beemenu")
	MouseMove windowX+30, windowY+offsetY+200, 5

	; obtain lower bound of search
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" windowHeight-offsetY-150)
	local pBMWhite, pBMRed, pBMBlue
	lb := 450
	for k,v in Map("white",0xffc4c8cb, "red",0xffc7403c, "blue",0xff4d87ca)
	{
		pBM%k% := Gdip_CreateBitmap(6, 2), G := Gdip_GraphicsFromImage(pBM%k%), Gdip_GraphicsClear(G, v), Gdip_DeleteGraphics(G)
		if (Gdip_ImageSearch(pBMScreen, pBM%k%, &lpos, , , 10, , 2, , 2) = 1)
		{
			l := SubStr(lpos, InStr(lpos, ",")+1)
			lb := Max(l+2, lb)
		}
	}
	Gdip_DisposeImage(pBMScreen)

	; loop through bees and fill object
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" lb)
	ub := 0
	for k,v in bees
	{
		Loop 3
		{
			; find upper coordinate of current bee
			uc := lb
			for i,j in ["white","red","blue"]
			{
				if (Gdip_ImageSearch(pBMScreen, pBM%j%, &upos, , ub, 10, , 2) = 1)
				{
					u := SubStr(upos, InStr(upos, ",")+1)
					uc := Min(u, uc)
				}
			}

			; if bee is too low, scroll up, else, set upper bound for next
			if (lb-uc < 120)
			{
				Loop (lb//150 - 2)
				{
					MouseMove windowX+30, windowY+offsetY+200, 5
					Sleep 50
					SendInput "{WheelDown}"
				}

				; obtain reference image for scroll distance
				DllCall("GetSystemTimeAsFileTime","Int64P",&s:=0)
				pBM := Gdip_CloneBitmapArea(pBMScreen, 6, Gdip_GetImageHeight(pBMScreen)-206, 294, 200)
				Gdip_LockBits(pBM, 0, 0, 294, 200, &stride, &scan0, &bmData)
				Loop 294
				{
					x := A_Index - 1
					if ((x+6 < windowWidth//2 - 261) || ((x+6 > windowWidth//2 - 190) && (x+6 < windowWidth//2 - 186)) || ((x+6 > windowWidth//2 - 115) && (x+6 < windowWidth//2 - 111)))
					{
						Loop 200
						{
							y := A_Index - 1
							switch Gdip_GetLockBitPixel(scan0, x, y, stride)
							{
								case 0xff4d87ca, 0xffc4c8cb, 0xffc7403c, 0xff74a9e6, 0xffe1e4e7, 0xffe46764:
								default:
								Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
							}
						}
					}
					else
					{
						Loop 200
						{
							y := A_Index - 1
							Gdip_SetLockBitPixel(0x00000000, scan0, x, y, stride)
						}
					}
				}
				Gdip_UnlockBits(pBM, &bmData)
				DllCall("GetSystemTimeAsFileTime","Int64P",&f:=0)

				; wait for scroll end then measure distance
				Sleep 500 - (f-s)//10000
				Gdip_DisposeImage(pBMScreen)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" lb)
				ub := Max(0, ub - (((Gdip_ImageSearch(pBMScreen, pBM, &pos) = 1)) ? Min(lb - 206 - SubStr(pos, InStr(pos, ",")+1), 150 * (lb//150 - 2)) : (150 * (lb//150 - 2))))
				Gdip_DisposeImage(pBM)
			}
			else
			{
				ub := uc + 120
				break
			}
		}

		; detect number of current bee
		(digits := Map()).Default := ""
		Loop 10
		{
			n := 10-A_Index
			Gdip_ImageSearch(pBMScreen, bitmaps["beedigit" n], &pos, 0, uc+100, 100, uc+120, , , 5, 2, , "`n")
			Loop Parse pos, "`n"
				if (A_Index & 1)
					digits[Integer(A_LoopField)] := n
		}
		num := (digits.Count > 0) ? "" : 0
		for x,y in digits
			num .= y


		; detect if current bee has gifted status
		gifted := ((num > 0) && (Gdip_ImageSearch(pBMScreen, bitmaps["gifted"], , 260, uc, 306, uc+40, 2) = 1))

		bee_data[v] := Map("amount",num, "gifted",gifted)
	}

	; stringify the object into JSON format for export
	str := '{"type":"natro",'
	for k,v in bee_data
		str .= (v["amount"] > 0) ? ('"' k '":{"amount":' v["amount"] ',"gifted":' (v["gifted"] ? "true" : "false") '},') : ""
	str := RTrim(str, ",") "}"

	A_Clipboard := str
	MsgBox "Copied Bee List to clipboard!`nPaste the output into the '/hive import' command of Hive Builder to view your hive!", "Export Bee List", 0x40040 " T20"
}
nm_TicketShopCalculatorButton(*){
	Run "https://docs.google.com/spreadsheets/d/1_5JP_9uZUv7PUqjL76T5orEA3MIHe4R8gLu27L8KJ-A/"
}
nm_SSACalculatorButton(*)
{
	Run "https://docs.google.com/spreadsheets/d/1nupF_6g1TLJk1W5MpLBsfe1yk6C99-ooMMffuxdn580/edit?usp=sharing"
}
nm_BondCalculatorButton(*)
{
	Run "https://docs.google.com/spreadsheets/d/1TFTAahwsB4WRmRkX4YiM8mPQyk53CDmfAKOSOYv-Bow/edit?usp=sharing"
}
nm_AutoClickerButton(*)
{
	global
	local GuiCtrl,GuiCtrlDuration, GuiCtrlDelay
	GuiClose(*){
		if (IsSet(AutoClickerGui) && IsObject(AutoClickerGui))
			AutoClickerGui.Destroy(), AutoClickerGui := ""
	}
	GuiClose()
	AutoClickerGui := Gui("+AlwaysOnTop +Border", "AutoClicker")
	AutoClickerGui.OnEvent("Close", GuiClose)
	AutoClickerGui.SetFont("s8 cDefault w700", "Tahoma")
	AutoClickerGui.Add("GroupBox", "x5 y2 w161 h80", "Settings")
	AutoClickerGui.SetFont("Norm")
	AutoClickerGui.Add("CheckBox", "x76 y2 vClickMode Checked" ClickMode, "Infinite").OnEvent("Click", nm_ClickMode)
	AutoClickerGui.Add("Text", "x13 y21", "Repeat")
	AutoClickerGui.Add("Edit", "x50 y19 w80 h18 vClickCountEdit Number Limit7 Disabled" ClickMode)
	(GuiCtrl := AutoClickerGui.Add("UpDown", "vClickCount Range0-9999999 Disabled" ClickMode, ClickCount)).Section := "Settings", GuiCtrl.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Text", "x133 y21", "times")
	AutoClickerGui.Add("Text", "x10 y41", "Click Interval (ms):")
	AutoClickerGui.Add("Edit", "x100 y39 w61 h18 Number Limit5", ClickDelay).OnEvent("Change", (*) => nm_saveConfig(GuiCtrlDelay))
	(GuiCtrlDelay := AutoClickerGui.Add("UpDown", "vClickDelay Range0-99999", ClickDelay)).Section := "Settings", GuiCtrlDelay.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Text", "x10 y61", "Click Duration (ms):")
	AutoClickerGui.Add("Edit", "x104 y59 w57 h18 Number Limit4", ClickDuration).OnEvent("Change", (*) => nm_saveConfig(GuiCtrlDuration))
	(GuiCtrlDuration := AutoClickerGui.Add("UpDown", "vClickDuration Range0-9999", ClickDuration)).Section := "Settings", GuiCtrlDuration.OnEvent("Change", nm_saveConfig)
	AutoClickerGui.Add("Button", "x45 y88 w80 h20", "Start (" AutoClickerHotkey ")").OnEvent("Click", nm_StartAutoClicker)
	AutoClickerGui.Show("w160 h104")
	nm_StartAutoClicker(*){
		GuiClose()
		MainGui.Minimize()
		autoclicker()
	}
}
nm_ClickMode(*){
	global
	IniWrite (ClickMode := AutoClickerGui["ClickMode"].Value), "settings\nm_config.ini", "Settings", "ClickMode"
	AutoClickerGui["ClickCount"].Enabled := AutoClickerGui["ClickCountEdit"].Enabled := ClickMode
}
nm_saveKeyDelay(*){
	global
	KeyDelay := MainGui["KeyDelay"].Value
	IniWrite KeyDelay, "settings\nm_config.ini", "Settings", "KeyDelay"
}
nm_HotkeyGUI(*){
	global
	local GuiCtrl
	GuiClose(*){
		if (IsSet(HotkeyGui) && IsObject(HotkeyGui))
			HotkeyGui.Destroy(), HotkeyGui := ""
	}
	GuiClose()
	HotkeyGui := Gui("+AlwaysOnTop -MinimizeBox +Owner" MainGui.Hwnd, "Hotkeys")
	HotkeyGui.OnEvent("Close", GuiClose)
	HotkeyGui.SetFont("s8 cDefault Bold", "Tahoma")
	HotkeyGui.Add("GroupBox", "x5 y2 w190 h144", "Change Hotkeys")
	HotkeyGui.Add("GroupBox", "x5 y146 w190 h34", "Settings")
	HotkeyGui.SetFont("Norm")
	HotkeyGui.Add("Text", "x10 y23 w60 +BackgroundTrans", "Start:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Pause:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Stop:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "AutoClicker:")
	HotkeyGui.Add("Text", "x10 yp+19 w60 +BackgroundTrans", "Timers:")
	HotkeyGui.Add("Hotkey", "x70 y20 w120 h18 vStartHotkeyEdit", StartHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vPauseHotkeyEdit", PauseHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vStopHotkeyEdit", StopHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vAutoClickerHotkeyEdit", AutoClickerHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Hotkey", "x70 yp+19 w120 h18 vTimersHotkeyEdit", TimersHotkey).OnEvent("Change", nm_saveHotkey)
	HotkeyGui.Add("Button", "x30 yp+24 w140 h20", "Restore Defaults").OnEvent("Click", nm_ResetHotkeys)
	(GuiCtrl := HotkeyGui.Add("CheckBox", "x10 y162 vShowOnPause Checked" ShowOnPause, "Show Natro on Pause")).Section := "Settings", GuiCtrl.OnEvent("Click", nm_saveConfig)
	HotkeyGui.Show("w190 h175")
}
nm_ResetHotkeys(*){
	global
	try {
		Hotkey StartHotkey, start, "Off"
		Hotkey PauseHotkey, nm_pause, "Off"
		Hotkey StopHotkey, stop, "Off"
		Hotkey AutoClickerHotkey, autoclicker, "Off"
		Hotkey TimersHotkey, timers, "Off"
	}
	IniWrite (StartHotkey := "F1"), "settings\nm_config.ini", "Settings", "StartHotkey"
	IniWrite (PauseHotkey := "F2"), "settings\nm_config.ini", "Settings", "PauseHotkey"
	IniWrite (StopHotkey := "F3"), "settings\nm_config.ini", "Settings", "StopHotkey"
	IniWrite (AutoClickerHotkey := "F4"), "settings\nm_config.ini", "Settings", "AutoClickerHotkey"
	IniWrite (TimersHotkey := "F5"), "settings\nm_config.ini", "Settings", "TimersHotkey"
	HotkeyGui["StartHotkeyEdit"].Value := "F1"
	HotkeyGui["PauseHotkeyEdit"].Value := "F2"
	HotkeyGui["StopHotkeyEdit"].Value := "F3"
	HotkeyGui["AutoClickerHotkeyEdit"].Value := "F4"
	HotkeyGui["TimersHotkeyEdit"].Value := "F5"
	MainGui["StartButton"].Text := " Start (F1)"
	MainGui["PauseButton"].Text := " Pause (F2)"
	MainGui["StopButton"].Text := " Stop (F3)"
	MainGui["AutoClickerButton"].Text := "AutoClicker (F4)"
	MainGui["TimersButton"].Text := " Show Timers (F5)"
	try {
		Hotkey StartHotkey, start, "On"
		Hotkey PauseHotkey, nm_pause, "On"
		Hotkey StopHotkey, stop, "On"
		Hotkey AutoClickerHotkey, autoclicker, "On T2"
		Hotkey TimersHotkey, timers, "On"
	}
}
nm_saveHotkey(GuiCtrl, *){
	global
	local k, v, l, NewHotkey, StartHotkeyEdit, PauseHotkeyEdit, StopHotkeyEdit, TimersHotkeyEdit, AutoClickerHotkeyEdit
	k := GuiCtrl.Name, %k% := GuiCtrl.Value

	v := StrReplace(k, "Edit")
	if !(%k% ~= "^[!^+]+$")
	{
		; do not allow necessary keys
		switch Format("sc{:03X}", GetKeySC(%k%)), 0
		{
			case FwdKey,LeftKey,BackKey,RightKey,RotLeft,RotRight,RotUp,RotDown,ZoomIn,ZoomOut,SC_E,SC_R,SC_L,SC_Esc,SC_Enter,SC_LShift,SC_Space:
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nThe key is already used elsewhere in the macro.", "Unacceptable Hotkey!", 0x1030
			return

			case SC_1,"sc003","sc004","sc005","sc006","sc007","sc008":
			GuiCtrl.Value := %v%
			MsgBox "That hotkey cannot be used!`nIt will be required to use your hotbar slots.", "Unacceptable Hotkey!", 0x1030
			return
		}

		if ((StrLen(%k%) = 0) || (%k% = StartHotkey) || (%k% = PauseHotkey) || (%k% = StopHotkey) || (%k% = AutoClickerHotkey) || (%k% = TimersHotkey)) ; do not allow empty or already used hotkey (not necessary in most cases)
			GuiCtrl.Value := %v%
		else ; update the hotkey
		{
			l := StrReplace(v, "Hotkey")
			try Hotkey %v%, (l = "Pause") ? nm_Pause : %l%, "Off"
			IniWrite (%v% := %k%), "settings\nm_config.ini", "Settings", v
			MainGui[l "Button"].Text := ((l = "Timers") ? " Show " : (l = "AutoClicker") ? "" : " ") l " (" %v% ")"
			try Hotkey %v%, (l = "Pause") ? nm_Pause : %l%, (v = "AutoClickerHotkey") ? "On T2" : "On"
		}
	}
}
nm_DebugLogGUI(*){
	global
	GuiClose(*){
		if (IsSet(DebugLogGui) && IsObject(DebugLogGui))
			DebugLogGui.Destroy(), DebugLogGui := ""
	}
	GuiClose()
	DebugLogGui := Gui("+AlwaysOnTop +Owner" MainGui.Hwnd, "Debug Log Options")
	DebugLogGui.OnEvent("Close", GuiClose)
	DebugLogGui.SetFont("s8 cDefault Norm", "Tahoma")
	DebugLogGui.Add("CheckBox", "x10 y6 vDebugLogEnabled Checked" DebugLogEnabled, "Enable Debug Logging").OnEvent("Click", nm_DebugLogCheck)
	DebugLogGui.Add("Button", "xp+140 y5 h16", "Go To File").OnEvent("Click", (*) => Run('explorer.exe /e, /n, /select,"' A_WorkingDir '\settings\debug_log.txt"'))
	DebugLogGui.Add("Button", "xp yp+20 hp wp", "Copy Logs").OnEvent("Click", copyLogFile)
	DebugLogGui.Show("w210 h36")
}
nm_DebugLogCheck(*){
	global
	IniWrite (DebugLogEnabled := DebugLogGui["DebugLogEnabled"].Value), "settings\nm_config.ini", "Status", "DebugLogEnabled"
	PostSubmacroMessage("Status", 0x5552, 222, DebugLogEnabled)
}
nm_AutoStartManager(*){
	global ASMGui

	if A_IsAdmin
		MsgBox "
		(
		Natro Macro has been run as administrator!
		Auto-Start Manager can only launch Natro Macro on logon without admin privileges.

		If you need to run Natro Macro as admin, either:
		- fix the reason why admin is required (reinstall Roblox unelevated, move Natro Macro folder)
		- manually set up a Scheduled Task in Task Scheduler with 'Run with highest privileges' checked
		- disable UAC (not recommended at all!)
		)", "Auto-Start Manager", 0x40030 " T120 Owner" MainGui.Hwnd

	if !(task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro", ""))
		validScript := 0, autostart := 0, delay := "None", status := 1
	else
	{
		; modified from Args() By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
		A := [], pArgs := DllCall("Shell32\CommandLineToArgvW", "Str",task, "PtrP",&nArgs:=0, "Ptr")
		Loop nArgs
			A.Push(StrGet(NumGet((A_Index - 1) * A_PtrSize + pArgs, "UPtr"), "UTF-16"))
		DllCall("LocalFree", "Ptr", pArgs)

		validScript := (A.Has(1) && (A[1] = A_WorkingDir "\START.bat"))
		autostart := (A.Has(2) && (A[2] = 1))
		delay := (A.Has(4) && IsNumber(A[4])) ? hmsFromSeconds(A[4]) : "None"
		status := validScript ? 0 : 2
	}

	w := 260, h := 200
	GuiClose(*){
		if (IsSet(ASMGui) && IsObject(ASMGui))
			ASMGui.Destroy(), ASMGui := ""
	}
	GuiClose()
	ASMGui := Gui("+AlwaysOnTop -MinimizeBox", "Auto-Start Manager")
	ASMGui.OnEvent("Close", GuiClose)
	ASMGui.SetFont("s11 cDefault Bold", "Tahoma")
	ASMGui.Add("Text", "x0 y4 vStatusLabel", "Current Status: ")
	ASMGui.Add("Text", "x0 y4 vStatusVal c" ((status > 0) ? "Red" : "Green"), (status > 0) ? "Inactive" : "Active")
	CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
	ASMGui.SetFont("s9 cDefault Bold", "Tahoma")
	ASMGui.Add("Text", "x0 y24 w" w " h36 vStatusText +Center c" ((status > 0) ? "Red" : "Green")
		, ((status = 0) ? "Natro Macro will automatically start on user login using the settings below:"
		: (status = 1) ? "No Natro Macro auto-start found!`nUse the 'Add' button below."
		: "Your auto-start needs updating!`nUse 'Add' to create a new auto-start."))

	ASMGui.Add("Text", "x0 yp+34 vNTLabel", "Natro Macro Path: ")
	ASMGui.Add("Text", "x0 yp vNTVal c" ((validScript) ? "Green" : "Red"), (status = 1) ? "None" : (validScript) ? "Valid" : "Invalid")
	CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
	ASMGui.Add("Text", "x0 yp+16 vASLabel", "Start Macro On Run: ")
	ASMGui.Add("Text", "x0 yp vASVal c" ((autostart) ? "Green" : "Red"), (status = 1) ? "None" : (autostart) ? "Enabled" : "Disabled")
	CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
	ASMGui.Add("Text", "x0 yp+16 w" w " vDelay +Center", "Delay Duration: " delay)

	ASMGui.Add("Button", "x10 yp+22 w115 h24", "Remove").OnEvent("Click", RemoveButton)
	ASMGui.Add("Button", "x135 yp w115 h24", "Add").OnEvent("Click", AddButton)

	ASMGui.Add("GroupBox", "x5 yp+30 w250 h54 Section", "New Task Settings")
	ASMGui.SetFont("s8 cDefault Norm", "Tahoma")
	ASMGui.Add("CheckBox", "vAutoStartCheck x12 ys+18 Checked", "Start Macro on Run")
	ASMGui.Add("Text", "x13 yp+16", "Delay Before Run:")
	ASMGui.Add("Text", "vDelayText x+0 yp w50 +Center", "0s")
	ASMGui.Add("UpDown", "vDelayDuration x+0 yp-1 w10 h16 -16 Range0-3599", 0).OnEvent("Change", ChangeDelay)

	ASMGui.Show("w" w-10 " h" h-10)
}
ChangeDelay(*)
{
	ASMGui["DelayText"].Text := hmsFromSeconds(ASMGui["DelayDuration"].Value)
}
AddButton(*)
{
	global
	local task, autostart, secs

	if (task := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro", ""))
		if (MsgBox("Are you sure?`nThis will overwrite the existing Natro Macro auto-start!", "Overwrite Existing Entry", 0x40024 " T30 Owner" ASMGui.Hwnd) != "Yes")
			return

	autostart := ASMGui["AutoStartCheck"].Value
	secs := ASMGui["DelayDuration"].Value

	RegWrite '"' A_WorkingDir '\START.bat"'
		. ((autostart = 1) ?  ' "1"' : ' ""')		; autostart parameter
		. ' ""'										; existing heartbeat PID
		. ((secs > 0) ?  ' "' secs '"' : ' ""')		; delay before run (.bat)
		, "REG_SZ", "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro"

	ASMGui["Delay"].Text := "Delay Duration: " ((secs > 0) ? hmsFromSeconds(secs) : "None")
	ASMGui["StatusVal"].SetFont("cGreen", "Tahoma"), ASMGui["StatusVal"].Text := "Active"
	CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
	ASMGui["StatusText"].SetFont("cGreen"), ASMGui["StatusText"].Text := "Natro Macro will automatically start on user login using the settings below:"
	ASMGui["NTVal"].SetFont("cGreen"), ASMGui["NTVal"].Text := "Valid"
	CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
	ASMGui["ASVal"].SetFont((autostart = 1) ? "cGreen" : "cRed"), ASMGui["ASVal"].Text := (autostart = 1) ? "Enabled" : "Disabled"
	CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
}
RemoveButton(*)
{
	global

	try RegDelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run", "NatroMacro"
	catch
	{
		; show msgbox
	}
	else
	{
		ASMGui["Delay"].Text := "Delay Duration: None"
		ASMGui["StatusVal"].SetFont("cRed", "Tahoma"), ASMGui["StatusVal"].Text := "Inactive"
		CenterText(ASMGui["StatusLabel"], ASMGui["StatusVal"], ASMGui["StatusLabel"])
		ASMGui["StatusText"].SetFont("cRed"), ASMGui["StatusText"].Text := "No Natro Macro auto-start found!`nUse the 'Add' button below."
		ASMGui["NTVal"].SetFont("cRed"), ASMGui["NTVal"].Text := "None"
		CenterText(ASMGui["NTLabel"], ASMGui["NTVal"], ASMGui["StatusText"])
		ASMGui["ASVal"].SetFont("cRed"), ASMGui["ASVal"].Text := "None"
		CenterText(ASMGui["ASLabel"], ASMGui["ASVal"], ASMGui["StatusText"])
	}
}
nm_NightAnnouncementGUI(*){
	global
	GuiClose(*){
		if (IsSet(NightGui) && IsObject(NightGui))
			NightGui.Destroy(), NightGui := ""
	}
	GuiClose()
	NightGui := Gui("+AlwaysOnTop +Border", "Announce Night Detection")
	NightGui.OnEvent("Close", GuiClose)
	NightGui.SetFont("s8 cDefault Bold", "Tahoma")
	NightGui.Add("GroupBox", "x5 y2 w290 h65", "Settings")
	NightGui.Add("CheckBox", "x73 y2 vNightAnnouncementCheck Checked" NightAnnouncementCheck, "Enabled").OnEvent("Click", nm_NightAnnouncementCheck)
	NightGui.SetFont("Norm")
	NightGui.Add("Button", "x150 y1 w135 h16", "What does this do?").OnEvent("Click", nm_NightAnnouncementHelp)
	NightGui.Add("Text", "x15 y23", "Name:")
	NightGui.Add("Edit", "x48 y21 w75 h18 vNightAnnouncementName Disabled" (NightAnnouncementCheck = 0), NightAnnouncementName).OnEvent("Change", nm_saveNightAnnouncementName)
	NightGui.Add("Text", "x130 y23", "Ping ID:")
	NightGui.Add("Edit", "x170 y21 w115 h18 vNightAnnouncementPingID Disabled" (NightAnnouncementCheck = 0), NightAnnouncementPingID).OnEvent("Change", nm_saveNightAnnouncementPingID)
	NightGui.Add("Text", "x15 y45", "Webhook:")
	NightGui.Add("Edit", "x67 y43 w218 h18 vNightAnnouncementWebhook Disabled" (NightAnnouncementCheck = 0), NightAnnouncementWebhook).OnEvent("Change", nm_saveNightAnnouncementWebhook)
	NightGui.Show("w290 h62")
}
nm_NightAnnouncementCheck(*){
	global NightAnnouncementCheck, NightGui
	NightAnnouncementCheck := NightGui["NightAnnouncementCheck"].Value
	PostSubmacroMessage("Status", 0x5552, 220, NightAnnouncementCheck)
	IniWrite NightAnnouncementCheck, "settings\nm_config.ini", "Status", "NightAnnouncementCheck"
	NightGui["NightAnnouncementName"].Enabled := NightGui["NightAnnouncementPingID"].Enabled := NightGui["NightAnnouncementWebhook"].Enabled := NightAnnouncementCheck
}
nm_saveNightAnnouncementName(GuiCtrl, *){
	global NightAnnouncementName
	p := EditGetCurrentCol(GuiCtrl)
	NewNightAnnouncementName := GuiCtrl.Value

	if InStr(NewNightAnnouncementName, "\")
	{
		GuiCtrl.Value := NightAnnouncementName
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Unacceptable Character", "The name cannot include the following characters:`n'\'")
	}
	else
	{
		NightAnnouncementName := NewNightAnnouncementName
		IniWrite NightAnnouncementName, "settings\nm_config.ini", "Status", "NightAnnouncementName"
		PostSubmacroMessage("Status", 0x5553, 48, 7)
	}

	;enum
	IniWrite NightAnnouncementName, "settings\nm_config.ini", "Status", "NightAnnouncementName"
}
nm_saveNightAnnouncementPingID(GuiCtrl, *){
	global NightAnnouncementPingID
	p := EditGetCurrentCol(GuiCtrl)
	NewNightAnnouncementPingID := GuiCtrl.Value

	if (NewNightAnnouncementPingID ~= "i)^&?[0-9]*$")
	{
		NightAnnouncementPingID := NewNightAnnouncementPingID
		IniWrite NightAnnouncementPingID, "settings\nm_config.ini", "Status", "NightAnnouncementPingID"
		PostSubmacroMessage("Status", 0x5553, 49, 7)
	}
	else
	{
		GuiCtrl.Value := NightAnnouncementPingID
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Invalid Discord Ping ID!", "Make sure it is a valid User ID or Role ID (starting with &).")
	}
}
nm_saveNightAnnouncementWebhook(GuiCtrl, *){
	global NightAnnouncementWebhook
	p := EditGetCurrentCol(GuiCtrl)
	str := GuiCtrl.Value
	RegexMatch(str, "i)https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)", &NewNightAnnouncementWebhook)

	if ((StrLen(str) = 0) || IsObject(NewNightAnnouncementWebhook))
	{
		NightAnnouncementWebhook := IsObject(NewNightAnnouncementWebhook) ? NewNightAnnouncementWebhook[0] : ""
		IniWrite NightAnnouncementWebhook, "settings\nm_config.ini", "Status", "NightAnnouncementWebhook"
		PostSubmacroMessage("Status", 0x5553, 50, 7)
	}
	else
	{
		GuiCtrl.Value := NightAnnouncementWebhook
		SendMessage 0xB1, p-2, p-2, GuiCtrl
		nm_ShowErrorBalloonTip(GuiCtrl, "Invalid Discord Webhook Link!", "Make sure your link is copied directly from Discord.")
	}
}
nm_NightAnnouncementHelp(*){
	MsgBox "
	(
	DESCRIPTION:
	When this option is enabled, the macro will send a message to the specified webhook alerting others that night has been detected in your server, allowing them to join and help fight Vicious Bee.
	NOTE: 'Kill Vicious Bee' must be enabled in Collect/Kill tab for night detection to run!

	Name:
	This is just what your name will show as, i.e. ___'s Server.

	Ping ID:
	You can enter either a User ID or Role ID here. Make sure to start a Role ID with '&'. If this option is not empty, the macro will ping this user/role when it sends the Night Detection message.

	Webhook:
	Here, you must enter the destination webhook for Night Detection Announcements.
	This is the channel where messages will be sent and people with access to the channel will be informed that it is nighttime in your server.
	)", "Announce Night Detection", 0x40000
}
nm_ReportBugButton(*){
	Run "https://github.com/NatroTeam/NatroMacro/issues/new?assignees=&labels=bug%2Cneeds+triage&projects=&template=bug.yml"
}
nm_MakeSuggestionButton(*){
	Run "https://github.com/NatroTeam/NatroMacro/issues/new?assignees=&labels=suggestion%2Cneeds+triage&projects=&template=suggestion.yml"
}
blc_mutations(*) {
	global
	local script, exec
	try ProcessClose(MGUIPID)
	script :=
	(
	'
	/************************************************************************
	 * @description Auto-Jelly is a macro for the game Bee Swarm Simulator on Roblox. It automatically rolls bees for mutations and stops when a bee with the desired mutation is found. It also has the ability to stop on mythic and gifted bees.
	 * @file auto-jelly.ahk
	 * @author ninju | .ninju.
	 * @date 2024/07/24
	 * @version 0.0.1
	 ***********************************************************************/

	#SingleInstance Force
	#Requires AutoHotkey v2.0
	#Warn VarUnset, Off
	;=============INCLUDES=============
	#Include %A_ScriptDir%\lib\Gdip_All.ahk
	#include %A_ScriptDir%\lib\Roblox.ahk
	#include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
	;==================================
	SendMode("Event")
	CoordMode(`'Pixel`', `'Screen`')
	CoordMode(`'Mouse`', `'Screen`')
	;==================================
	pToken := Gdip_Startup()
	OnExit((*) => (closefunction()), -1)
	OnError (e, mode) => (mode = "Return") ? -1 : 0
	stopToggle(*) {
		global stopping := true
	}
	class __ArrEx extends Array {
		static __New() {
			Super.Prototype.includes := ObjBindMethod(this, `'includes`')
		}
		static includes(arr, val) {
			for i, j in arr {
				if j = val
					return i
			}
			return 0
		}
	}

	if A_ScreenDPI !== 96
		throw Error("This macro requires a display-scale of 100%")
	traySetIcon(".\nm_image_assets\birb.ico")
	getConfig() {
		global
		local k, v, p, c, i, section, key, value, inipath, config, f, ini
		config := {
			mutations: {
				Mutations: 0,
				Ability: 0,
				Gather: 0,
				Convert: 0,
				Energy: 0,
				Movespeed: 0,
				Crit: 0,
				Instant: 0,
				Attack: 0
			},
			bees: {
				Bomber: 0,
				Brave: 0,
				Bumble: 0,
				Cool: 0,
				Hasty: 0,
				Looker: 0,
				Rad: 0,
				Rascal: 0,
				Stubborn: 0,
				Bubble: 0,
				Bucko: 0,
				Commander: 0,
				Demo: 0,
				Exhausted: 0,
				Fire: 0,
				Frosty: 0,
				Honey: 0,
				Rage: 0,
				Riley: 0,
				Shocked: 0,
				Baby: 0,
				Carpenter: 0,
				Demon: 0,
				Diamond: 0,
				Lion: 0,
				Music: 0,
				Ninja: 0,
				Shy: 0,
				Buoyant: 0,
				Fuzzy: 0,
				Precise: 0,
				Spicy: 0,
				Tadpole: 0,
				Vector: 0,
				selectAll: 0
			},
			GUI : {
				xPos: A_ScreenWidth//2-w//2,
				yPos: A_ScreenHeight//2-h//2
			},
			extrasettings: {
				mythicStop: 0,
				giftedStop: 0
			}
		}
		for i, section in config.OwnProps()
			for key, value in section.OwnProps()
				%key% := value
		if !FileExist(".\settings")
			DirCreate(".\settings")
		inipath := ".\settings\mutations.ini"
		if FileExist(inipath) {
			loop parse FileRead(inipath), "``n", "``r" A_Space A_Tab {
				switch (c:=SubStr(A_LoopField,1,1)) {
					case "[", ";": continue
					default:
					if (p := InStr(A_LoopField, "="))
						try k := SubStr(A_LoopField, 1, p-1), %k% := IsInteger(v := SubStr(A_LoopField, p+1)) ? Integer(v) : v
				}
			}
		}
		ini:=""
		for k, v in config.OwnProps() {
			ini .= "[" k "]``r``n"
			for i in v.OwnProps()
				ini .= i "=" %i% "``r``n"
			ini .= "``r``n"
		}
		(f:=FileOpen(inipath, "w")).Write(ini), f.Close()
	}
	;===Dimensions===
	w:=500,h:=397
	;===Bee Array===
	beeArr := ["Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley", "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
	mutationsArr := [
		{name:"Ability", triggers:["rate", "abil", "ity"], full:"AbilityRate"},
		{name:"Gather", triggers:["gath", "herAm"], full:"GatherAmount"},
		{name:"Convert", triggers:["convert", "vertAm"], full:"ConvertAmount"},
		{name:"Instant", triggers:["inst", "antConv"], full:"InstantConversion"},
		{name:"Crit", triggers:["crit", "chance"], full:"CriticalChance"},
		{name:"Attack", triggers:["attack", "att", "ack"], full:"Attack"},
		{name:"Energy", triggers:["energy", "rgy"], full:"Energy"},
		{name:"Movespeed", triggers:["movespeed", "speed", "move"], full:"MoveSpeed"},
	]
	extrasettings:=[
		{name:"mythicStop", text: "Stop on mythics"},
		{name:"giftedStop", text: "Stop on gifteds"}
	]
	getConfig()
	(bitmaps := Map()).CaseSense:=0
	#Include .\nm_image_assets\mutator\bitmaps.ahk
	#include .\nm_image_assets\mutatorgui\bitmaps.ahk
	#include .\nm_image_assets\offset\bitmaps.ahk
	startGui() {
		global
		local i,j,y,hBM,x
		(mgui := Gui("+E" (0x00080000) " +OwnDialogs -Caption -DPIScale", "Auto-Jelly")).OnEvent("Close", ExitApp)
		mgui.Show()
		for i, j in [
			{name:"move", options:"x0 y0 w" w " h36"},
			{name:"selectall", options:"x" w-330 " y220 w40 h18"},
			{name:"mutations", options:"x" w-170 " y220 w40 h18"},
			{name:"close", options:"x" w-40 " y5 w28 h28"},
			{name:"roll", options:"x10 y" h-42 " w" w-56 " h30"},
			{name:"help", options:"x" w-40 " y" h-42 " w28 h28"}
		]
			mgui.AddText("v" j.name " " j.options)
		for i, j in beeArr {
			y := (A_Index-1)//8*1
			mgui.AddText("v" j " x" 10+mod(A_Index-1,8)*60 " y" 50+y*40 " w45 h36")
		}
		for i, j in mutationsArr {
			y := (A_Index-1)//4*1
			mgui.AddText("v" j.name " x" 10+mod(A_Index-1,4)*120 " y" 260+y*25 " w40 h18")
		}
		for i, j in extrasettings {
			x := 10 + (w-12)/extrasettings.length * (i-1), y:=(316+h-42)//2-10
			mgui.AddText("v" j.name " x" x " y" y " w40 h18")
		}
		hBM := CreateDIBSection(w, h)
		hDC := CreateCompatibleDC()
		SelectObject(hDC, hBM)
		G := Gdip_GraphicsFromHDC(hDC)
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetInterpolationMode(G, 7)
		update := UpdateLayeredWindow.Bind(mgui.hwnd, hDC)
		update(xpos < 0 ? 0 : xpos > A_ScreenWidth ? 0 : xpos, ypos < 0 ? 0 : ypos > A_ScreenHeight ? 0 : ypos, w, h)
		hovercontrol := ""
		DrawGUI()
	}
	startGUI()
	OnMessage(0x201, WM_LBUTTONDOWN)
	OnMessage(0x200, WM_MOUSEMOVE)
	DrawGUI() {
		Gdip_GraphicsClear(G)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid(0xFF131416), 2, 2, w-4, h-4, 20), Gdip_DeleteBrush(brush)
		region := Gdip_GetClipRegion(G)
		Gdip_SetClipRect(G, 2, 21, w-2, 30, 4)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFFFEC6DF"), 2, 2, w-4, 40, 20)
		Gdip_SetClipRegion(G, region)
		Gdip_FillRectangle(G, brush, 2, 20, w-4, 14)
		Gdip_DeleteBrush(brush), Gdip_DeleteRegion(region)
		Gdip_TextToGraphics(G, "Auto-Jelly", "s20 x20 y5 w460 Near vCenter c" (brush := Gdip_BrushCreateSolid("0xFF131416")), "Comic Sans MS", 460, 30), Gdip_DeleteBrush(brush)
		Gdip_DrawImage(G, bitmaps["close"], w-40, 5, 28, 28)
		for i, j in beeArr {
			;bitmaps are w45 h36
			y := (A_Index-1)//8
			bm := hovercontrol = j && (%j% || SelectAll) ? j "bghover" : %j% || SelectAll ? j "bg" : hovercontrol = j ? j "hover" : j
			Gdip_DrawImage(G, bitmaps[bm], 10+mod(A_Index-1,8)*60, 50+y*40, 45, 36)
		}
		;===Switches===
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), selectAll ? w-310 : w-332, 218, 22, 22)
		Gdip_TextToGraphics(G, "Select All Bees", "s14 x" w-284 " y220 Near vCenter c" brush, "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
		if !SelectAll {
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-330, 220, 18, 18), Gdip_DeleteBrush(brush)
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-325, 225], [w-317, 233]])
			Gdip_DrawLines(G, Pen								  , [[w-325, 233], [w-317, 225]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-303, 229], [w-300, 232], [w-295, 225]]), Gdip_DeletePen(Pen)
		Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 40, 18, 9), Gdip_DeleteBrush(brush)
		Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), mutations ? w-150 : w-172, 218, 22, 22)
		Gdip_TextToGraphics(G, "Mutations", "s14 x" w-124 " y220 Near vCenter c" (brush), "Comic Sans MS",, 20), Gdip_DeleteBrush(brush)
		if !mutations {
			Gdip_FillEllipse(G, brush:= Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), w-170, 220, 18, 18), Gdip_DeleteBrush(brush)
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[w-165, 225], [w-157, 233]])
			Gdip_DrawLines(G, Pen								  , [[w-165, 233], [w-157, 225]]), Gdip_DeletePen(Pen)
		}
		else
			Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[w-143, 229], [w-140, 232], [w-135, 225]]), Gdip_DeletePen(Pen)
		For i, j in mutationsArr {
			y := (A_Index-1)//4
			Gdip_FillRoundedRectanglePath(G, brush := Gdip_BrushCreateSolid("0xFF" . 13*2 . 14*2 . 16*2), 10+mod(A_Index-1,4)*120, 260+y*25, 40, 18, 9), Gdip_DeleteBrush(brush)
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), (%j.name% ? 3.2 : 1) * 8+mod(A_Index-1,4)*120, 258+y*25, 22, 22), Gdip_DeleteBrush(brush)
			Gdip_TextToGraphics(G, j.name, "s13 x" 56+mod(A_Index-1,4)*120 " y" 260+y*25 " vCenter c" (brush := Gdip_BrushCreateSolid("0xFFFEC6DF")), "Comic Sans MS", 100, 20), Gdip_DeleteBrush(brush)
			if !%j.name% {
				Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x:=10+mod(A_Index-1,4)*120, yp:=258+y*25+2, 18, 18), Gdip_DeleteBrush(brush)
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, yp+5 ], [x+13, yp+13]])
				Gdip_DrawLines(G, Pen								  , [[x+5, yp+13], [x+13, yp+5 ]]), Gdip_DeletePen(Pen)
			}
			else
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x:=32.6+mod(A_Index-1,4)*120, yp:=269+y*25], [x+3, yp+3], [x+8, yp-4]]), Gdip_DeletePen(Pen)
		}
		if !mutations
			Gdip_FillRectangle(G, brush:=Gdip_BrushCreateSolid("0x70131416"), 9, 255, w-18, 52), Gdip_DeleteBrush(brush)
		Gdip_DrawLine(G, Pen:=Gdip_CreatePen("0xFFFEC6DF", 2), 10, 315, w-12, 315), Gdip_DeletePen(Pen)
		;two more switches for "stop on mythic" and "stop on gifted"
		for i, j in extrasettings {
			x := 10 + (tw:=(w-12)/extrasettings.length) * (i-1), y:=(316+h-42)//2-10
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 40, 18, 9), Gdip_DeleteBrush(brush), Gdip_DeleteBrush(brush)
			Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFFFEC6DF"), %j.name% ? x+18 : x-2, y-2, 22, 22)
			Gdip_TextToGraphics(G, j.text, "s14 x" x+46 " y" y " vCenter c" brush, "Comic Sans MS", tw,20), Gdip_DeleteBrush(brush)
			if !%j.name% {
				Gdip_FillEllipse(G, brush:=Gdip_BrushCreateSolid("0xFF262832"), x, y, 18, 18), Gdip_deleteBrush(brush)
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFFCC0000", 2), [[x+5, y+5 ], [x+13, y+13]])
				Gdip_DrawLines(G, Pen								  , [[x+5, y+13], [x+13, y+5 ]]), Gdip_DeletePen(Pen)
			}
			else
				Gdip_DrawLines(G, Pen:=Gdip_CreatePen("0xFF006600", 2), [[x+25, y+9], [x+28, y+12], [x+33, y+5]]), Gdip_DeletePen(Pen)
		}
		if hovercontrol = "roll"
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), 10, h-42, w-56, 30, 10), Gdip_DeleteBrush(brush)
		if hovercontrol = "help"
			Gdip_FillRoundedRectanglePath(G, brush:=Gdip_BrushCreateSolid("0x30FEC6DF"), w-40, h-42, 30, 30, 10), Gdip_DeleteBrush(brush)
		Gdip_TextToGraphics(G, "Roll!", "x10 y" h-40 " Center vCenter s15 c" (brush:=Gdip_BrushCreateSolid("0xFFFEC6DF")),"Comic Sans MS",w-56, 28)
		Gdip_TextToGraphics(G, "?", "x" w-39 " y" h-40 " Center vCenter s15 c" brush,"Comic Sans MS",30, 28), Gdip_DeleteBrush(brush)
		Gdip_DrawRoundedRectanglePath(G, pen:=Gdip_CreatePen("0xFFFEC6DF", 4), 10, h-42, w-56, 30, 10)
		Gdip_DrawRoundedRectanglePath(G, pen, w-40, h-42, 30, 30, 10), Gdip_DeletePen(pen)
		update()
	}
	WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
		global hovercontrol, mutations, Bomber, Brave, Bumble, Cool, Hasty, Looker, Rad, Rascal
		, Stubborn, Bubble, Bucko, Commander, Demo, Exhausted, Fire, Frosty, Honey, Rage
		, Riley, Shocked, Baby, Carpenter, Demon, Diamond, Lion, Music, Ninja, Shy, Buoyant
		, Fuzzy, Precise, Spicy, Tadpole, Vector, SelectAll, Ability, Gather, Convert, Energy
		, Movespeed, Crit, Instant, Attack, mythicStop, giftedStop
		MouseGetPos(,,,&ctrl,2)
		if !ctrl
			return
		switch mgui[ctrl].name, 0 {
			case "move":
				PostMessage(0x00A1,2)
			case "close":
				while GetKeyState("LButton", "P")
					sleep -1
				mousegetpos ,,, &ctrl2, 2
				if ctrl = ctrl2
					PostMessage(0x0112,0xF060)
			case "roll":
				ReplaceSystemCursors()
				blc_start()
			case "help":
				ReplaceSystemCursors()	
				Msgbox("This feature allows you to roll royal jellies until you obtain your specified bees and/or mutations!``n``nTo use:``n- Select the bees and mutations you want``n- Make sure your in-game Auto-Jelly settings are right``n- Put a neonberry on the bee you want to change (if trying ``n  to obtain a mutated bee) ``n- Use one royal jelly on the bee and click Yes``n- Click on Roll.``n``nTo stop: ``n- Press the escape key``n``nAdditional options:``n- Stop on Gifteds stops on any gifted bee, ``n  ignoring the mutation and your bee selection``n- Stop on Mythics stops on any mythic bee, ``n  ignoring the mutation and your bee selection", "Auto-Jelly Help", "0x40040")
			case "selectAll":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "Bomber", "Brave", "Bumble", "Cool", "Hasty", "Looker", "Rad", "Rascal", "Stubborn", "Bubble", "Bucko", "Commander", "Demo", "Exhausted", "Fire", "Frosty", "Honey", "Rage", "Riley":
				if !selectAll
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "Shocked", "Baby", "Carpenter", "Demon", "Diamond", "Lion", "Music", "Ninja", "Shy", "Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector":
				if !selectAll
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "bees", mgui[ctrl].name)
			case "giftedStop", "mythicStop":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "extrasettings", mgui[ctrl].name)
			case "mutations":
				IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
			default:
				if mutations
					IniWrite(%mgui[ctrl].name% ^= 1, ".\settings\mutations.ini", "mutations", mgui[ctrl].name)
		}
		DrawGUI()
	}
	WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
		global
		local ctrl, hover_ctrl, tt := 0
		MouseGetPos(,,,&ctrl,2)
		if !ctrl || mgui["move"].hwnd = ctrl || mgui["close"].hwnd = ctrl
			return
		ReplaceSystemCursors("IDC_HAND")
		hovercontrol := mgui[ctrl].name
		hover_ctrl := mgui[ctrl].hwnd
		DrawGUI()
		while ctrl = hover_ctrl {
			sleep(20),MouseGetPos(,,,&ctrl,2)
			if A_Index > 120 && beeArr.includes(hovercontrol) && !tt
				tt:=1,ToolTip(hovercontrol . " Bee")
		}
		hovercontrol := ""
		ToolTip()
		ReplaceSystemCursors()
		DrawGUI()
	}
	ReplaceSystemCursors(IDC := "")
	{
		static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := Map(  "IDC_APPSTARTING", 32650
								, "IDC_ARROW"      , 32512
								, "IDC_CROSS"      , 32515
								, "IDC_HAND"       , 32649
								, "IDC_HELP"       , 32651
								, "IDC_IBEAM"      , 32513
								, "IDC_NO"         , 32648
								, "IDC_SIZEALL"    , 32646
								, "IDC_SIZENESW"   , 32643
								, "IDC_SIZENWSE"   , 32642
								, "IDC_SIZEWE"     , 32644
								, "IDC_SIZENS"     , 32645
								, "IDC_UPARROW"    , 32516
								, "IDC_WAIT"       , 32514 )
		if !IDC
			DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
		else
		{
			hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
			for k, v in SysCursors
			{
				hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
				DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
			}
		}
	}
	blc_start() {
		global stopping:=false
		hotkey "~*esc", stopToggle, "On"
		selectedBees := [], selectedMutations := []
		for i in beeArr
			if %i% || SelectAll
				selectedBees.push(i)
		if mutations {
			selectedMutations := []
			for i in mutationsArr
				if %i.name%
					selectedMutations.push(i)
		}
		ocr_enabled := 1
		ocr_language := ""
		for k,v in Map("Windows.Globalization.Language","{9B0252AC-0C27-44F8-B792-9793FB66C63E}", "Windows.Graphics.Imaging.BitmapDecoder","{438CCB26-BCEF-4E95-BAD6-23A822E58D01}", "Windows.Media.Ocr.OcrEngine","{5BFFA85A-3384-3540-9940-699120D428A8}") {
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
		if !(ocr_enabled) && mutations
			msgbox "OCR is disabled. This means that the macro will not be able to detect mutations.",, 0x40010
		list := ocr("ShowAvailableLanguages")
		lang:="en-"
		Loop Parse list, "``n", "``r" {
			if (InStr(A_LoopField, lang) = 1) {
				ocr_language := A_LoopField
				break
			}
		}
		if (ocr_language = "" && ocr_enabled)
			if ((ocr_language := SubStr(list, 1, InStr(list, "``n")-1)) = "")
				return msgbox("No OCR supporting languages are installed on your system! Please follow the Knowledge Base guide to install a supported language as a secondary language on Windows.", "WARNING!!", 0x1030)
		if !(hwndRoblox:=GetRobloxHWND()) || !(GetRobloxClientPos(), windowWidth)
			return msgbox("You must have Bee Swarm Simulator open to use this!", "Auto-Jelly", 0x40030)
		if !selectedBees.length
			return msgbox("You must select at least one bee to run this macro!", "Auto-Jelly", 0x40030)
		yOffset := GetYOffset(hwndRoblox, &fail)
		if fail	
			MsgBox("Unable to detect in-game GUI offset!``nThis means the macro will NOT work correctly!``n``nThere are a few reasons why this can happen:``n- Incorrect graphics settings (check Troubleshooting Guide!)``n- Your Experience Language is not set to English``n- Something is covering the top of your Roblox window``n``nJoin our Discord server for support!", "WARNING!!", 0x1030 " T60")
		if mgui is Gui
			mgui.hide()
		While !stopping {
			ActivateRoblox()
			click windowX + Round(0.5 * windowWidth + 10) " " windowY + yOffset + Round(0.4 * windowHeight + 230)
			sleep 800
			pBitmap := Gdip_BitmapFromScreen(windowX + 0.5*windowWidth - 155 "|" windowY + yOffset + 0.425*windowHeight - 200 "|" 320 "|" 140)
			if mythicStop
				for i, j in ["Buoyant", "Fuzzy", "Precise", "Spicy", "Tadpole", "Vector"]
					if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
						Gdip_DisposeImage(pBitmap)
						msgbox "Found a mythic bee!", "Auto-Jelly", 0x40040
						break 2
					}
			if giftedStop
				for i, j in beeArr {
					if Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
						Gdip_DisposeImage(pBitmap)
						msgbox "Found a gifted bee!", "Auto-Jelly", 0x40040
						break 2	
					}	
				}
			found := 0
			for i, j in selectedBees {
				if Gdip_ImageSearch(pBitmap, bitmaps["-" j]) || Gdip_ImageSearch(pBitmap, bitmaps["+" j]) {
					if (!mutations || !ocr_enabled || !selectedMutations.length) {
						Gdip_DisposeImage(pBitmap)
						if msgbox("Found a match!``nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
							break 2
						else
							continue 2
					}
					found := 1
					break
				}
			}
			Gdip_DisposeImage(pBitmap)
			if !found
				continue
			pBitmap := Gdip_BitmapFromScreen(windowX + Round(0.5 * windowWidth - 320) "|" windowY + yOffset + Round(0.4 * windowHeight + 17) "|210|90")
			pEffect := Gdip_CreateEffect(5, -60,30)
			Gdip_BitmapApplyEffect(pBitmap, pEffect)
			Gdip_DisposeEffect(pEffect)
			hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
			pIRandomAccessStream := HBitmapToRandomAccessStream(hBitmap)
			text:= RegExReplace(ocr(pIRandomAccessStream), "i)([\r\n\s]|mutation)*")
			found := 0
			for i, j in selectedMutations
				for k, trigger in j.triggers
					if inStr(text, trigger) { 
						found := 1
						break
					}
			if !found
				continue
			if msgbox("Found a match!``nDo you want to keep this?","Auto-Jelly!", 0x40044) = "Yes"
				break
		}
		hotkey "~*esc", stopToggle, "Off"
		mgui.show()
	}
	closeFunction(*) {
		global xPos, yPos
		Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
		try {
			mgui.getPos(&xp, &yp)
			if !(xp < 0) && !(xp > A_ScreenWidth) && !(yp < 0) && !(yp > A_ScreenHeight)
				xPos := xp, yPos := yp
			IniWrite(xpos, ".\settings\mutations.ini", "GUI", "xpos")
			IniWrite(ypos, ".\settings\mutations.ini", "GUI", "ypos")
		}
	}
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
					text .= StrGet(b, "UTF-16") "``n"
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
				ComCall(10, OcrEngineStatics, "ptr*", &OcrEngine:=0)   ; TryCreateFromUserProfileLanguages
			else
			{
				CreateHString(lang, &hString)
				ComCall(6, LanguageFactory, "ptr", hString, "ptr*", &Language:=0)   ; CreateLanguage
				DeleteHString(hString)
				ComCall(9, OcrEngineStatics, "ptr", Language, "ptr*", &OcrEngine:=0)   ; TryCreateFromLanguage
			}
			if (OcrEngine = 0)
			{
				msgbox `'Can not use language "`' lang `'" for OCR, please install language pack.`'
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
			msgbox "Image is to big - " width "x" height ".``nIt should be maximum - " MaxDimension " pixels"
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
			text .= StrGet(buf, "UTF-16") "``n"
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
	'
	)
	exec := ComObject("WScript.shell").Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()
	return (MGUIPID := exec.processID)
}

; CREDITS TAB
; ------------------------
nm_ContributorsHandler(req)
{
	if (req.readyState != 4)
		return

	nm_ContributorsImage(1, (req.status = 200) ? StrSplit(req.responseText || "Error while loading,red`ncontributors!,red`n`nMake sure you have,red`na working internet,red`nconnection and then,red`nreload the macro.,red", "`n", " `t")
		: ["Error while loading,red", "contributors!,red", "", "Make sure you have,red", "a working internet,red", "connection and then,red", "reload the macro.,red"])
}
nm_ContributorsImage(page:=1, contributors:=""){
	static hBM1, hBM2, hBM3, hBM4, hBM5, hBM6, hBM7, hBM8, hBM9, hBM10
		, hBM11, hBM12, hBM13, hBM14, hBM15, hBM16, hBM17, hBM18, hBM19, hBM20 ; 20 pages max
		, colorArr := Map("blue", [0xff83c6e2, 0xff2779d8, 0xff83c6e2]
			, "gold", [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f]
			, "red", [0xffA82428, 0xffA82428, 0xffA82428]
			, "interrobang", [0xff9992FE, 0xff5246FD, 0xff9992FE])
	local pBM1, pBM2, pBM3, pBM4, pBM5, pBM6, pBM7, pBM8, pBM9, pBM10
	, pBM11, pBM12, pBM13, pBM14, pBM15, pBM16, pBM17, pBM18, pBM19, pBM20 ; 20 pages max

	if !IsSet(hBM1)
	{
		devs := [["bastianauryn",0xffa202c0,"779430642043191307"]
			, ["zez_",0xff7df9ff,"253742141124116481"]
			, ["ScriptingNoob",0xfffa01c5,"245481556355973121"]
			, ["zaappiix",0xffa2a4a3,"747945550888042537"]
			, ["xspx",0xfffc6600,"240431161191432193"]
			, ["SuperDadof6 ❤",0xff8780ff,"278608676296589313"]
			, ["baguetto",0xff3d85c6,"323507959957028874"]
			, ["raychal71",0xffb7c9e2,"259441167068954624"]
			, ["axetar",0xffec8fd0,"487989990937198602"]
			, ["mis.c",0xffa174fe,"996025853286817815"]
			, ["ninju",0xffe6a157,"727937385274540046"]]

		testers := [["thatcasualkiwi",0xffff00ff,"334634052361650177"]
			, ["ziz_jake",0xffa45ee9,"227604929806729217"]
			, ["nick9",0xffdfdfdf,"700353887512690759"]
			, ["heatsky",0xff3f8d4d,"725444258835726407"]
			, ["valibreaz",0xff7aa22c,"244504077579452417"]
			, ["randomuserhere",0xff2bc016,"744072472890179665"]
			, ["chaxe",0xff794044,"529089693749608468"]
			, ["_phucduc_",0xffffde48,"710486399744475136"]
			, ["anniespony",0xff0096ff,"217700684835979265"]
			, ["idote",0xfff47fff,"350433227380621322"]
			, ["mahirishere",0xffa3bded,"724740667158429747"]
			, ["Pinwheel",0xfff49fbc,"849962858774003712"]]

		pBM := Gdip_CreateBitmap(244,212)
		G := Gdip_GraphicsFromImage(pBM)
		Gdip_SetSmoothingMode(G, 2)
		Gdip_SetInterpolationMode(G, 7)

		pBrush := Gdip_BrushCreateSolid(0xff202020)
		Gdip_FillRoundedRectangle(G, pBrush, 0, 0, 242, 210, 5)
		Gdip_DeleteBrush(pBrush)

		x := 5, y := 50
		pos := Gdip_TextToGraphics(G, "Developers", "s12 x" x + 1 " y" y " Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(x + 1, y, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+2, 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, x + 1, y, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Developers", "s12 x" x + 2 " y" y " r4 Bold cff000000", "Tahoma")

		y += 16
		for v in devs
		{
			pos := Gdip_TextToGraphics(G, v[1], "s11", "Tahoma", , , 1)
			if (x + (w := Number(SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1))) > 239)
				x := 5, y += 13
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, y + 1, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1,2), 255)
				, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, x, y, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
			v.Push([x, y, x + w, y + 12])
			x += w + 4
		}

		x := 5, y += 19
		pos := Gdip_TextToGraphics(G, "Testers", "s12 x" x + 1 " y" y " Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(x + 1, y, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, x + 1, y, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+1, 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Testers", "s12 x" x + 2 " y" y " r4 Bold cff000000", "Tahoma")

		y += 16
		for v in testers
		{
			pos := Gdip_TextToGraphics(G, v[1], "s11", "Tahoma", , , 1)
			if (x + (w := Number(SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1))) > 239)
				x := 5, y += 13
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, y + 1, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1.2), 255)
				, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, x, y, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
			v.Push([x, y, x + w, y + 12])
			x += w + 4
		}

		Gdip_DeleteGraphics(G)

		hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		Gdip_DisposeImage(pBM)
		MainGui["ContributorsDevImage"].Value := "HBITMAP:*" hBM
		MainGui["ContributorsDevImage"].OnEvent("Click", nm_ContributorsDiscordLink)
		nm_ContributorsDiscordLink(GuiCtrl, *){
			static users := (users := devs.Clone(), users.Push(testers*), users)
			MouseGetPos &mouse_x, &mouse_y
			try WinGetClientPos &ctrl_x, &ctrl_y, , , "ahk_id " GuiCtrl.Hwnd
			x := mouse_x - ctrl_x, y := mouse_y - ctrl_y
			for v in users
			{
				if ((x >= v[4][1]) && (x <= v[4][3]) && (y >= v[4][2]) && (y <= v[4][4]))
				{
					nm_RunDiscord("users/" v[3])
					break
				}
			}
		}
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

			name := Trim(SubStr(v, 1, (pos := InStr(v, ",", , -1))-1)), color := Trim(SubStr(v, pos+1))
			x := (Mod(k-1, 24) > 11) ? 124 : 4, y := 48+Mod(k-1, 12)*13
			pos := Gdip_TextToGraphics(G, name, "s11 x" x " y0 cff000000", "Tahoma", , , 1)
			pBrush := Gdip_CreateLinearGrBrushFromRect(x, y+1, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 12, 0x00000000, 0x00000000, 2)
			Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], colorArr[colorArr.Has(color) ? color : "gold"].Clone())
			pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, name, "Tahoma", 11, 0, x, y, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		Gdip_DeleteGraphics(G)
		hBM%i% := Gdip_CreateHBITMAPFromBitmap(pBM%i%)
		Gdip_DisposeImage(pBM%i%)

		MainGui["ContributorsImage"].Value := "HBITMAP:*" hBM1
	}
	else
	{
		;GDI_SetImageX() by SKAN
		hdcSrc  := DllCall("CreateCompatibleDC", "UInt",0)
		hdcDst  := DllCall("GetDC", "UInt",MainGui["ContributorsImage"].Hwnd)
		bm := Buffer(24, 0) ; BITMAP Structure
		DllCall("GetObject", "UInt",hBM%page%, "UInt",24, "UPtr",bm.Ptr)
		w := NumGet(bm, 4, "Int"), h := NumGet(bm, 8, "Int")
		hbmOld  := DllCall("SelectObject", "UInt",hdcSrc, "UInt",hBM%page%)
		hbmNew  := DllCall("CreateBitmap", "Int",w-6, "Int",h-50, "UInt",NumGet(bm, 16, "UShort")
						, "UInt",NumGet(bm, 18,"UShort"), "Int",0)
		hbmOld2 := DllCall("SelectObject", "UInt",hdcDst, "UInt",hbmNew)
		DllCall("BitBlt", "UInt",hdcDst, "Int",3, "Int",48, "Int",w-6, "Int",h-50
						, "UInt",hdcSrc, "Int",3, "Int",48, "UInt",0x00CC0020)
		DllCall("SelectObject", "UInt",hdcSrc, "UInt",hbmOld)
		DllCall("DeleteDC", "UInt",hdcSrc), DllCall("ReleaseDC", "UInt",MainGui["ContributorsImage"].Hwnd, "UInt",hdcDst)
		DllCall("SendMessage", "UInt",MainGui["ContributorsImage"].Hwnd, "UInt",0x0B, "UInt",0, "UInt",0)        ; WM_SETREDRAW OFF
		oBM := DllCall("SendMessage", "UInt",MainGui["ContributorsImage"].Hwnd, "UInt",0x172, "UInt",0, "UInt",hBM%page%) ; STM_SETIMAGE
		DllCall("SendMessage", "UInt",MainGui["ContributorsImage"].Hwnd, "UInt",0x0B, "UInt",1, "UInt",0)        ; WM_SETREDRAW ON
		DllCall("DeleteObject", "UInt",oBM)
	}

	i := page + 1

	MainGui["ContributorsLeft"].Enabled := (page != 1)
	MainGui["ContributorsRight"].Enabled := IsSet(hBM%i%)
}
nm_ContributorsPageButton(GuiCtrl, *){
	static p := 1
	nm_ContributorsImage(p += (GuiCtrl.Name = "ContributorsLeft") ? -1 : 1)
}

; ADV. TAB
; ------------------------
nm_showAdvancedSettings(*){
	global BuffDetectReset
	static i := 0, t1, init := DllCall("GetSystemTimeAsFileTime", "int64p", &t1:=0)
	if (BuffDetectReset = 1)
		return
	DllCall("GetSystemTimeAsFileTime", "int64p", &t2:=0)
	if (t2 - t1 < 50000000)
	{
		if (++i >= 7)
		{
			TabCtrl.Add(["Advanced"])
			nm_AdvancedGUI(1), i := 0
		}
	}
	else
		i := 1, t1 := t2
}
nm_AdvancedGUI(init:=0){
	global
	local hBM, GuiCtrl
	TabCtrl.UseTab("Advanced")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	MainGui.SetFont("w700")
	MainGui.Add("GroupBox", "x5 y24 w240 h90", "Fallback Private Servers")
	MainGui.Add("GroupBox", "x255 y24 w240 h38", "Debugging")
	MainGui.Add("GroupBox", "x255 y62 w240 h168", "Test Paths/Patterns")
	MainGui.Add("GroupBox", "x5 y114 w240 h50", "Priorities")
	MainGui.SetFont("s8 cDefault Norm", "Tahoma")
	;reconnect
	MainGui.Add("Text", "x15 y44", "3 Fails:")
	MainGui.Add("Edit", "x55 y42 w180 h18 vFallbackServer1", FallbackServer1).OnEvent("Change", nm_ServerLink)
	MainGui.Add("Text", "x15 y66", "6 Fails:")
	MainGui.Add("Edit", "x55 y64 w180 h18 vFallbackServer2", FallbackServer2).OnEvent("Change", nm_ServerLink)
	MainGui.Add("Text", "x15 y88", "9 Fails:")
	MainGui.Add("Edit", "x55 y86 w180 h18 vFallbackServer3", FallbackServer3).OnEvent("Change", nm_ServerLink)
	;debugging
	(GuiCtrl := MainGui.Add("CheckBox", "x265 y42 vssDebugging Checked" ssDebugging, "Enable Discord Debugging Screenshots")).Section := "Status", GuiCtrl.OnEvent("Click", nm_saveConfig)
	;test
	MainGui.Add("CheckBox", "x265 y89 w14 h14 Checked vTest1Check")
	MainGui.Add("CheckBox", "x265 y121 w14 h14 vTest2Check")
	MainGui.Add("Text", "x285 y88 w174 vTest1Text -Wrap", "<none>")
	MainGui.Add("Text", "x285 y120 w174 vTest2Text -Wrap", "<none>")
	hBM := LoadPicture("shell32.dll", "w20 h-1 Icon046")
	MainGui.Add("Picture", "x465 y86 w20 h20 vBrowse1", "HBITMAP:*" hBM).OnEvent("Click", nm_selectTestPath)
	MainGui.Add("Picture", "x465 y118 w20 h20 vBrowse2", "HBITMAP:*" hBM).OnEvent("Click", nm_selectTestPath)
	DllCall("DeleteObject", "ptr", hBM)
	MainGui.Add("Text", "x298 y149", "Repeat:")
	MainGui.Add("Text", "x342 y147 w54 h18 0x201")
	MainGui.Add("UpDown", "vTestCount Range1-99999", 1)
	MainGui.Add("CheckBox", "x404 y149 vTestInfinite", "Infinite").OnEvent("Click", nm_TestInfinite)
	MainGui.Add("Text", "x283 y174", "On Cycle Start:")
	MainGui.Add("CheckBox", "x362 y174 vTestReset Checked", "Reset")
	MainGui.Add("CheckBox", "x413 y174 vTestMsgBox", "MsgBox")
	MainGui.Add("Button", "x325 y197 w100 h24", "Start Test").OnEvent("Click", nm_testButton)
	MainGui.Add("Button", "x15 y130 w220 h25 vMainLoopPriorityButton", "Main Loop Priority List").OnEvent("Click", nm_priorityListGui)
	if (init = 1)
	{
		TabCtrl.Choose("Advanced")
		IniWrite (BuffDetectReset := 1), "settings\nm_config.ini", "Settings", "BuffDetectReset"
		MsgBox "
		(
		You have enabled Advanced Settings!
		Here you can find options that are not recommended to change.
		Remember that most of these settings are experimental and mainly intended for debugging and testing purposes!
		)", "Advanced Settings", 0x40040 " T20"
	}
}
nm_TestInfinite(*){
	global
	MainGui["TestCount"].Enabled := !(TestInfinite := MainGui["TestInfinite"].Value)
}
nm_selectTestPath(GuiCtrl, *){
	global Test1Path, Test2Path
	i := SubStr(GuiCtrl.Name, -1), nl := 0
	path := FileSelect(, A_WorkingDir "\paths", "Select Path/Pattern", "AHK Files (*.ahk)")
	if (SubStr(path, -4) = ".ahk")
	{
		Test%i%Path := path
		Loop Parse (str := StrReplace(path, A_WorkingDir "\")), "\"
		{
			if (TextExtent(line := ((p := InStr(str, "\", , , A_Index)-1) > 0) ? SubStr(str, 1, p) : str, MainGui["Test" i "Text"]) > 174)
			{
				str := SubStr(str, 1, InStr(str, "\", , , A_Index-1)-1) "`n" SubStr(str, InStr(str, "\", , , A_Index-1)), nl := 1
				break
			}
		}
		MainGui["Test" i "Text"].Text := str
		MainGui["Test" i "Text"].Move(, (((nl = 1) ? 50 : 56) + 32 * i), , ((nl = 1) ? 28 : 14))
	}
	else if path
		MsgBox "You must select an .ahk file!", "Select Path/Pattern", 0x40030 " T20 Owner" MainGui.Hwnd
}
nm_testButton(*){
	global
	local Test1:="", Test2:="", file
	Test1Check := MainGui["Test1Check"].Value
	Test2Check := MainGui["Test2Check"].Value
	TestCount := MainGui["TestCount"].Value
	TestInfinite := MainGui["TestInfinite"].Value
	TestReset := MainGui["TestReset"].Value
	TestMsgBox := MainGui["TestMsgBox"].Value

	if !GetRobloxHWND()
	{
		MsgBox "You must have Bee Swarm Simulator open to use this!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
		return 0
	}

	if ((Test1Check = 0) && (Test2Check = 0))
	{
		MsgBox "No paths were selected for testing!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
		return 0
	}

	Loop 2
	{
		if (Test%A_Index%Check = 1)
		{
			if (IsSet(Test%A_Index%Path) && (SubStr(Test%A_Index%Path, -4) = ".ahk"))
				file := FileOpen(Test%A_Index%Path, "r"), Test%A_Index% := file.Read(), file.Close()
			else
			{
				MsgBox "Test Path " A_Index " is enabled but not valid!", "Test Paths/Patterns", 0x40030 " T20 Owner" MainGui.Hwnd
				return 0
			}
		}
	}

	movement :=
	(
	'
	Loop' ((TestInfinite = 0) ? (" " TestCount) : "") '
	{
		ActivateRoblox()
		GetRobloxClientPos()
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
		' ((TestMsgBox = 1) ? 'if (MsgBox("Start Cycle: " A_Index "``r``nContinue?", "Test Paths/Patterns", 0x40044) != "Yes")`r`nExitApp' : 'tooltip "Testing``nCycle: " A_Index') '
		' ((TestReset = 1) ? "nm_reset()" : "") '
		' Test1 '
		' Test2 '
	}
	MsgBox "Test Complete!", "Test Paths/Patterns", 0x40040
	ExitApp
	'
	)

	nm_createWalk(movement, "test",
		(
		'
		size:=1, reps:=1, facingcorner:=0
		FieldName:=FieldPattern:=FieldPatternSize:=FieldReturnType:=FieldSprinklerLoc:=FieldRotateDirection:=""
		FieldUntilPack:=FieldPatternReps:=FieldPatternShift:=FieldSprinklerDist:=FieldRotateTimes:=FieldDriftCheck:=FieldPatternInvertFB:=FieldPatternInvertLR:=FieldUntilMins:=0

		nm_CameraRotation(Dir, count) {
			Static LR := 0, UD := 0, init := OnExit((*) => send("{" Rot%(LR > 0 ? "Left" : "Right")% " " Mod(Abs(LR), 8) "}{" Rot%(UD > 0 ? "Up" : "Down")% " " Abs(UD) "}"), -1)
			send "{" Rot%Dir% " " count "}"
			Switch Dir,0 {
				Case "Left": LR -= count
				Case "Right": LR += count
				Case "Up": UD -= count
				Case "Down": UD += count
			}
		}
		' nm_PathVars()
		)
	)
}
nm_priorityListGui(*) {
	global
	local script, exec

	try ProcessClose(PGUIPID)

	script := 
	(
	'
	#NoTrayIcon
	#SingleInstance Force
	#MaxThreads 255
	#Include lib
	#Include Gdip_All.ahk
	pToken := Gdip_Startup()
	DetectHiddenWindows 1

	(bitmaps := Map()).CaseSense := 0
	#Include "%A_ScriptDir%\nm_image_assets\webhook_gui\bitmaps.ahk"

	;;config
	defaultList := ["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Boost", "GoGather"]
	priorityList := []
	for i in StrSplit(' priorityListNumeric ')
		priorityList.push(defaultList[i])

	priorityGui := Gui("-Caption +E0x80000 +E0x8000000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs -DPIScale")
	priorityGui.OnEvent("Close", (*) => ExitApp()), priorityGui.OnEvent("Escape", (*) => ExitApp())
	priorityGui.Show("NA")

	for i in ["moveRegion", "close", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "Reset", "ToolTip"]
		priorityGui.AddText("v" i)
	priorityGui["Reset"].enabled := false
	w:=250, h:=priorityList.Length * 34 + 87
	hbm := CreateDIBSection(w, h)
	hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetSmoothingMode(G, 2)
	Gdip_SetInterpolationMode(G, 2)
	UpdateLayeredWindow(priorityGui.hwnd, hdc, A_ScreenWidth//2-w//2,A_ScreenHeight//2-h//2, w, h)

	;colors:
	backgroundColor := "0xff131416"
	textColor := "0xffffffff"
	itemsColor := "0xff323942"
	accentColors := [
		"0xFFF24646", "0xFFF34F4F", "0xFFF45858", "0xFFF56161", 
		"0xFFF66A6A", "0xFFF77373", "0xFFF87C7C", "0xFFF98585", 
		"0xFFFA8E8E", "0xFFFB9797", "0xFFF9B5B5"
	]

	nm_priorityGui()
	Msgbox("Warning:``n``nThis option will change the ORDER in which the macro attempts each task, but not necessarily the AMOUNT OF TIME spent on each task.``n``nIf you have enabled any Gather Interrupts, or options requiring interrupts, those will also override the order you specify here. For example:``n- if you enable Vicious Bee or Night Memory Match, it will interrupt gather to attempt these every night time even if you place these lower on the priority list.``n- if you enable Gather Interrupt for Quests or Bug Kills, it will interrupt gather to do these tasks every time they come off cool-down, even if you place them lower on the priority list.``n``nGenerally, the DEFAULT ORDER is recommended in most cases.","Priority list",0x40040)

	priorityGui["moveRegion"].move(0, 0, w-42, 30)
	priorityGui["close"].move(w-42, 4, 28, 28)
	for i,v in priorityList
		priorityGui["p" i].move(15, i*34+3, w-30, 30)
	priorityGui["Reset"].move(15, h-50, w-62, 30)
	priorityGui["ToolTip"].move(w-45, h-50, 30, 30)
	nm_priorityGui(movingItem?, mouseY?, drop?) {
		global priorityList
		local v,i
		;;Title Bar
		Gdip_GraphicsClear(G)
		Gdip_FillRoundedRectanglePath(G, pBrush := Gdip_CreateLineBrushFromRect(0, 0, w, h, 0x00000000, 0x78000000), 14, 6, w-16, h-16, 12), Gdip_DeleteBrush(pBrush)
		pBrush := Gdip_BrushCreateSolid(accentColors[1]), Gdip_FillRoundedRectanglePath(G, pBrush, 8, 0, w-16, 30, 12), Gdip_FillRectangle(G, pBrush, 8, 13, w-16, 20), Gdip_DeleteBrush(pBrush)
		Gdip_DrawImage(G, bitmaps["close"], w-42, 4)
		Gdip_TextToGraphics(G, "Priority List", "x23 y8 s17 cffffffff Bold","Arial", w-16, 30)

		;;Background
		Gdip_FillRectangle(G, pBrush := Gdip_BrushCreateSolid(backgroundColor), 8, 32, w-16, h-80), Gdip_FillRoundedRectanglePath(G, pBrush, 8, h-100, w-16, 84, 12),Gdip_DeleteBrush(pBrush)

		;;Check for update in priority list
		if IsSet(movingItem) && !IsSet(drop) {
			index := ((mouseY > priorityList.Length * 34+3) ? priorityList.Length*34+3 : mouseY < 44 ? 44 : mouseY) // 34
			Gdip_DrawLine(G , pPen:=Gdip_CreatePen(accentColors[1], 2), 15, (index*34+3), w-15,  (index*34+3)), Gdip_DeletePen(pPen)
		}
		if IsSet(drop) {
			index := ((mouseY > priorityList.Length * 34 + 3) ? priorityList.Length*34+3 : mouseY < 44 ? 44 : mouseY) // 34
			priorityList.InsertAt(index, priorityList.RemoveAt(ObjHasValue(priorityList, movingItem)))
		}
		lower := 0
		;;Priority List
		for i, v in priorityList {
			if IsSet(movingItem) && movingItem = v && !IsSet(drop) {
				lower := 1
				continue
			}
			groupx := 15, groupy := ((i-=lower)*34)+3, groupw := w-30, grouph := 30
			Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid(itemsColor), groupx, groupy, groupw, grouph, 8), Gdip_DeleteBrush(pBrush)
			Gdip_TextToGraphics(G, v, "x" groupx+8 " y" groupY + 7 " s15 cffffffff Bolder","Arial")
			Gdip_DrawLine(G, pPen := Gdip_CreatePen(accentColors[i+1], 3), groupw-20, groupy + 10, groupw-5, groupy + 10)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 15, groupw-5, groupy + 15)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 20, groupw-5, groupy + 20), Gdip_DeletePen(pPen)
		}
		if IsSet(movingItem) && !IsSet(drop) {
			groupy := (mouseY > priorityList.Length * 34+3) ? priorityList.Length * 34+3 : mouseY < 44 ? 44 : mouseY 
			Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid("0x99323942"), groupx, groupy, groupw, grouph, 8), Gdip_DeleteBrush(pBrush)
			Gdip_TextToGraphics(G, movingItem, "x" groupx+8 " y" groupY + 7 " s15 c99ffffff Bolder","Arial")
			Gdip_DrawLine(G, pPen := Gdip_CreatePen(accentColors[10], 3), groupw-20, groupy + 10, groupw-5, groupy + 10)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 15, groupw-5, groupy + 15)
			Gdip_DrawLine(G, pPen, groupw-20, groupy + 20, groupw-5, groupy + 20), Gdip_DeletePen(pPen)
		}
		Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid(accentColors[5]), 15, h-50, w-62, 30, 8)
		Gdip_FillRoundedRectangle(G, pBrush, w-45, h-50, 30, 30, 8), Gdip_DeleteBrush(pBrush)
		if (default := (priorityList[1] == defaultList[1] && priorityList[2] == defaultList[2] && priorityList[3] == defaultList[3] && priorityList[4] == defaultList[4] && priorityList[5] == defaultList[5] && priorityList[6] == defaultList[6] && priorityList[7] == defaultList[7] && priorityList[8] == defaultList[8]))
			Gdip_FillRoundedRectangle(G, pBrush := Gdip_BrushCreateSolid("0x50000000"), 17, h-48, w-66, 26, 8), Gdip_DeleteBrush(pBrush), priorityGui["Reset"].enabled := false
		else
			priorityGui["Reset"].enabled := true
		Gdip_TextToGraphics(G, "Reset", "x15 y" h-43 " s15 c" (default ? "FFCCCCCC" : "FFFFFFFF") " Bold Center","Arial", w-62)
		Gdip_TextToGraphics(G, "?", "x" w-45 " y" h-43 " s15 cFFFFFFFF Bold Center","Arial", 30)
		UpdateLayeredWindow(priorityGui.hwnd, hdc)
		OnMessage(0x201, WM_LBUTTONDOWN)
		OnExit(ExitFunc)
	}
	ObjHasValue(obj,value) {
		for q,o in obj
			if o = value
				return q
		return false
	}

	WM_LBUTTONDOWN(*) {
		global priorityList
		MouseGetPos ,,,&hCtrl,2
		if !hCtrl
			return
		switch priorityGui[hCtrl].name, 0 {
			case "moveRegion":
				PostMessage(0xA1, 2)
			case "close":
				ExitApp()
			case "Reset":
				priorityList := ["Night", "Mondo", "Planter", "Bugrun", "Collect", "QuestRotate", "Boost", "GoGather"]
				updateInt("priorityListNumeric", 12345678)
				nm_priorityGui()
			case "ToolTip":
				Msgbox("Priority List``r``n``r``nDrag and drop to reorder the priority list.``r``nPress Reset to reset the priority list back to default.``n``nNote:``n - The priority list will not override interrupts, e.g., for bug kills or vicious bee.``n - In one loop each task will be completed.``n - The DEFAULT priority is usually optimal for most players.","Priority List",0x40040)
			default:
				MouseGetPos(,&y)
				priorityGui.GetPos(,&wy)
				index := SubStr(priorityGui[hCtrl].name,2)
				offset := y - wy-(index*34+3)
				ReplaceSystemCursors("IDC_HAND")
				While GetKeyState("LButton", "P") {
					MouseGetPos(,&y)
					y-=offset + wy
					nm_priorityGui(priorityList[index], y)
				}
				ReplaceSystemCursors()
				nm_priorityGui(priorityList[index], y, 1)
				for k,v in priorityList
					out .= ObjHasValue(defaultList, v)
				updateInt("priorityListNumeric", out)
		}
	}
	ReplaceSystemCursors(IDC := "")
	{
		static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
			, SysCursors := Map(  "IDC_APPSTARTING", 32650
								, "IDC_ARROW"      , 32512
								, "IDC_CROSS"      , 32515
								, "IDC_HAND"       , 32649
								, "IDC_HELP"       , 32651
								, "IDC_IBEAM"      , 32513
								, "IDC_NO"         , 32648
								, "IDC_SIZEALL"    , 32646
								, "IDC_SIZENESW"   , 32643
								, "IDC_SIZENWSE"   , 32642
								, "IDC_SIZEWE"     , 32644
								, "IDC_SIZENS"     , 32645
								, "IDC_UPARROW"    , 32516
								, "IDC_WAIT"       , 32514 )
		if !IDC
			DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS, "UInt", 0, "UInt", 0, "UInt", 0)
		else
		{
			hCursor := DllCall("LoadCursor", "Ptr", 0, "UInt", SysCursors[IDC], "Ptr")
			for k, v in SysCursors
			{
				hCopy := DllCall("CopyImage", "Ptr", hCursor, "UInt", IMAGE_CURSOR, "Int", 0, "Int", 0, "UInt", 0, "Ptr")
				DllCall("SetSystemCursor", "Ptr", hCopy, "UInt", v)
			}
		}
	}
	UpdateInt(name, value)
	{
		IniWrite value, "settings\nm_config.ini", "settings", name
		if WinExist("natro_macro.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, 366, value
		if WinExist("Status.ahk ahk_class AutoHotkey")
			PostMessage 0x5552, 366, value
	}

	ExitFunc(*)
	{
		PriorityGui.Destroy()
		try Gdip_Shutdown(pToken)
		ReplaceSystemCursors()
	}
	'
	)
	exec := ComObject("WScript.Shell")
			.exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	return (PGUIPID := exec.ProcessID)
}

copyLogFile(*) {
	static tempPath := A_Temp "\debug_log.txt", os_version := "Cannot detect OS version", processorName := '', RAMAmount := 0
	alt := !!GetKeyState("Control")
	if ((!processorName) || (os_version = "Cannot detect OS version"))
		winmgmts := ComObjGet("winmgmts:")
	if (os_version = "Cannot detect OS version") {
		for objItem in winmgmts.ExecQuery("SELECT * FROM Win32_OperatingSystem")
			os_version := Trim(StrReplace(StrReplace(StrReplace(StrReplace(objItem.Caption, "Microsoft"), "Майкрософт"), "مايكروسوفت"), "微软"))
	}
	if (!processorName){
		for objItem in winmgmts.ExecQuery("SELECT * FROM Win32_Processor")
			processorName := Trim(objItem.Name)
	}
	if (!RAMAmount) {
		MEMORYSTATUSEX := Buffer(64,0)
		NumPut("uint", 64, MEMORYSTATUSEX)
		DllCall("kernel32\GlobalMemoryStatusEx", "ptr", MEMORYSTATUSEX)
		RAMAmount := Round(NumGet(MEMORYSTATUSEX, 8, "int64") / 1073741824, 1)
	}
	out :=	
	(
	'``````md
	# Info -----------------------------------------------
	OSVersion: ' os_version ' (' (A_Is64bitOS ? '64-bit' : '32-bit') ')
	AutoHotkey Version: ' A_AhkVersion '; ' (A_AhkPath = A_WorkingDir '\submacros\AutoHotkey32.exe' ? "Using included AHK" : "Using installed AHK") '
	Natro Version: ' VersionID '
	Installation Path: ' StrReplace(A_WorkingDir, A_UserName, '<user>')
	. (processorName ? '`r`nCPU: ' processorName : '')
	. (RAMAmount ? '`r`nRAM: ' RAMAmount 'GB' : '')
	'
	# Latest Logs ----------------------------------------
	'
	)
	LatestDebuglog := FileRead(".\settings\debug_log.txt")
	out .= SubStr(LatestDebugLog, InStr(LatestDebuglog, "`n", , ,-(alt ? 40 : 26)) + 1) "``````" ;InStr: retrieve the last 25 lines of the debug log (log is oldest to newest) [Integer] | SubStr: retrieve the content of the last 25 lines
	A_Clipboard := out
	MsgBox("Copied Debug stats to your clipboard.", "Copy Debug Logs", 0x40040)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_Start(){
	ActivateRoblox()
	global serverStart := nowUnix()
	Loop 
		for i in priorityList
			(%"nm_" i%)()
	nm_planter() => (mp_Planter(),ba_planter())
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Include "%A_ScriptDir%\..\lib"
#Include "nm_OpenMenu.ahk"
#Include "nm_InventorySearch.ahk"
;interrupts
nm_MondoInterrupt() => (utc_min := FormatTime(A_NowUTC, "m"), now := nowUnix(),
	((MondoBuffCheck = 1) && ((utc_min<14 && (now-LastMondoBuff)>960 && MondoAction="Kill")
		|| (!nm_GatherBoostInterrupt()
			&& ((utc_min<14 && (now-LastMondoBuff)>960 && MondoAction="Buff")
			|| (utc_min<12 && (now-LastGuid)<60 && PMondoGuid && MondoAction="Guid")
			|| (utc_min<=8 && (now-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")))
		)
	)
)
nm_BeesmasInterrupt() {
	global BeesmasGatherInterruptCheck
	now := nowUnix()
	return ((beesmasActive = 1) && (BeesmasGatherInterruptCheck = 1)
		&& ((StockingsCheck && (now-LastStockings)>3600)
		|| (FeastCheck && (now-LastFeast)>5400)
		|| (RBPDelevelCheck && (now-LastRBPDelevel)>10800)
		|| (GingerbreadCheck && (now-LastGingerbread)>7200)
		|| (SnowMachineCheck && (now-LastSnowMachine)>7200)
		|| (CandlesCheck && (now-LastCandles)>14400)
		|| (SamovarCheck && (now-LastSamovar)>21600)
		|| (LidArtCheck && (now-LastLidArt)>28800)
		|| (GummyBeaconCheck && (now-LastGummyBeacon)>28800)
		|| (WinterMemoryMatchCheck && (now-LastWinterMemoryMatch)>14400))
	)
}
nm_BugrunInterrupt() {
	global BugrunInterruptCheck
	now := nowUnix()
	multiplier := 1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01
	return ((((BugrunInterruptCheck && BugrunLadybugsCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll)))
			&& ((now-LastBugrunLadybugs)>floor(330*multiplier)))
		|| (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)
			|| (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles))
			&& ((now-LastBugrunRhinoBeetles)>floor(330*multiplier)))
		|| (((BugrunInterruptCheck && BugrunSpiderCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll))
			&& ((now-LastBugrunSpider)>floor(1830*multiplier)))
		|| (((BugrunInterruptCheck && BugrunMantisCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)
			|| (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis))
			&& ((now-LastBugrunMantis)>floor(1230*multiplier)))
		|| (((BugrunInterruptCheck && BugrunScorpionsCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll)))
			&& ((now-LastBugrunScorpions)>floor(1230*multiplier)))
		|| (((BugrunInterruptCheck && BugrunWerewolfCheck)
			|| (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf)
			|| (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll))
			&& ((now-LastBugrunWerewolf)>floor(3600*multiplier))))
}
nm_GatherBoostInterrupt() => (now := nowUnix(), ((now-GatherFieldBoostedStart<900) || (now-LastGlitter<900) || nm_boostBypassCheck()))
nm_MemoryMatchInterrupt() {
	global MemoryMatchInterruptCheck
	now := nowUnix()
	return ((MemoryMatchInterruptCheck = 1)
		&& ((NormalMemoryMatchCheck && (now-LastNormalMemoryMatch)>7200)
		|| (MegaMemoryMatchCheck && (now-LastMegaMemoryMatch)>14400)
		|| (ExtremeMemoryMatchCheck && (now-LastExtremeMemoryMatch)>28800)
		|| ((beesmasActive = 1) && WinterMemoryMatchCheck && (now-LastWinterMemoryMatch)>14400))
	)
}

;stats/status
nm_setStats(){
	global
	local rundelta:=0, gatherdelta:=0, convertdelta:=0, TotalStatsString, SessionStatsString

	if (MacroState=2) {
		rundelta:=(nowUnix()-MacroStartTime)
		if(GatherStartTime > 0)
			gatherdelta:=(nowUnix()-GatherStartTime)
		if(ConvertStartTime > 0)
			convertdelta:=(nowUnix()-ConvertStartTime)
	}

	TotalStatsString :=
	(
		"Runtime: " DurationFromSeconds(TotalRuntime+rundelta) "
		Gather: " DurationFromSeconds(TotalGatherTime+gatherdelta) "
		Convert: " DurationFromSeconds(TotalConvertTime+convertdelta) "
		ViciousKills=" TotalViciousKills "
		BossKills=" TotalBossKills "
		BugKills=" TotalBugKills "
		PlantersCollected=" TotalPlantersCollected "
		QuestsComplete=" TotalQuestsComplete "
		Disconnects=" TotalDisconnects
	)

	SessionStatsString :=
	(
		"Runtime: " DurationFromSeconds(SessionRuntime+rundelta) "
		Gather: " DurationFromSeconds(SessionGatherTime+gatherdelta) "
		Convert: " DurationFromSeconds(SessionConvertTime+convertdelta) "
		ViciousKills=" SessionViciousKills "
		BossKills=" SessionBossKills "
		BugKills=" SessionBugKills "
		PlantersCollected=" SessionPlantersCollected "
		QuestsComplete=" SessionQuestsComplete "
		Disconnects=" SessionDisconnects
	)

	MainGui["TotalStats"].Text := TotalStatsString
	MainGui["SessionStats"].Text := SessionStatsString
}
nm_setStatus(newState:=0, newObjective:=0){
	global state, objective, StatusLogReverse, DebugLogEnabled
	static statuslog:=[], status_number:=0

	if ((DebugLogEnabled = 1) && (statuslog.Length = 0) && FileExist("settings\debug_log.txt")) {
		txt := FileOpen("settings\debug_log.txt", "r"), c := f := 0
		while ((c < 15) && !f && (A_Index < 100))
			txt.Seek(- (((p := (A_Index * 128)) > txt.Length) ? (f := txt.Length) : p), 2), log := txt.Read(), StrReplace(log, "`n", , , &c)
		txt.Close()
		Loop Parse SubStr(RTrim(log, "`r`n"), f ? 1 : InStr(log, "`n", , , Max(c - 15, 1)) + 1), "`n", "`r"
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
	statuslog.RemoveAt(1,(statuslog.Length>15) ? statuslog.Length-15 : 0), len:=statuslog.Length
	statuslogtext:=""
	for k,v in statuslog
		i := ((StatusLogReverse) ? len+1-k : k), statuslogtext .= (((A_Index>1) ? "`r`n" : "") statuslog[i])

	try {
		MainGui["state"].Text := stateString
		MainGui["statuslog"].Text := statuslogtext
	}

	; update status
	DetectHiddenWindows 1
	if (newState != "Detected") {
		num := ((state = "Gathering") && !InStr(objective, "Ended")) ? 1 : ((state = "Converting") && !InStr(objective, "Refreshed") && !InStr(objective, "Emptied")) ? 2 : 0
		if (num != status_number) {
			status_number := num
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey")
				try PostMessage 0x5554, status_number, 60 * A_Min + A_Sec
			if WinExist("background.ahk ahk_class AutoHotkey")
				try PostMessage 0x5555, status_number, nowUnix()
		}
	}
	if WinExist("Status.ahk ahk_class AutoHotkey")
		try SendMessage 0xC2, 0, StrPtr("[" A_MM "/" A_DD "][" A_Hour ":" A_Min ":" A_Sec "] " stateString)
	DetectHiddenWindows 0
}
nm_updateAction(action){
	global CurrentAction, PreviousAction
	if(CurrentAction!=action){
		PreviousAction:=CurrentAction
		CurrentAction:=action
	}
}
nm_PlanterDetection()
{
	static pBMProgressStart, pBMProgressEnd, pBMRemain

	;defines the bitmaps via hex color
	if !(IsSet(pBMProgressStart) && IsSet(pBMProgressEnd) && IsSet(pBMRemain))
	{
		pBMProgressStart := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressStart), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMProgressEnd := Gdip_CreateBitmap(1,2)
		pGraphics := Gdip_GraphicsFromImage(pBMProgressEnd), Gdip_GraphicsClear(pGraphics, 0xff86d570), Gdip_DeleteGraphics(pGraphics)
		pBMRemain := Gdip_CreateBitmap(1,8)
		pGraphics := Gdip_GraphicsFromImage(pBMRemain), Gdip_GraphicsClear(pGraphics, 0xff567848), Gdip_DeleteGraphics(pGraphics)
	}

	ActivateRoblox()
	GetRobloxClientPos()
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)

	if ((sPlanterStart := Gdip_ImageSearch(pBMScreen, pBMProgressStart, &PStart, , , , , , , 5)) = 1) {
		x := SubStr(PStart, 1, InStr(PStart, ",")-1), y := SubStr(PStart, InStr(PStart, ",")+1)
		sPlanterEnd := Gdip_ImageSearch(pBMScreen, pBMProgressEnd, &PEnd, x, y, , y+2, , , 8)
		sPBarEnd := Gdip_ImageSearch(pBMScreen, pBMRemain, &PBarEnd, x, y, , y+8, , , 8)
	}

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
nm_PlanterTimeUpdate(FieldName, SetStatus := 1)
{
	global
	local i, field, k, v, r:=0, PlanterGrowTime, PlanterBarProgress, CurrentPlanterBarProgress, NewPlanterBarProgress, VerifiedPlanterBarProgress

	Loop 3
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

			sendinput "{" RotUp " 4}"
			Sleep 200

			; get prior PlanterBarProgress bounds for comparison
			CurrentPlanterBarProgress := 1 - ((PlanterHarvestTime%i% - nowUnix()) / 3600 / PlanterGrowTime)  ; PlanterBarProgress0

			Loop 20
			{
				if (((PlanterBarProgress := nm_PlanterDetection()) > 0) && PlanterBarProgress <= 1)
				{
					; if new estimate within +/-10%, update
					if (Abs(PlanterBarProgress - CurrentPlanterBarProgress) <= 0.10)
					{
						PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
						IniWrite PlanterHarvestTime%i%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
						(SetStatus) && nm_setStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress*100) "%")
						;NewPlanterBarProgress := PlanterBarProgress  ; variable only needed here for testing status update
						break
					}
					else ; if new estimate not within +/-10%, screenshot again
					{
						NewPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress1

						sleep 2000

						sendinput "{" RotRight " 2}"
						sleep 100
						PlanterBarProgress := nm_PlanterDetection()
						sendinput "{" RotLeft " 2}"
						sleep 100

						; if second screenshot within +/-10% of first, update
						if ((PlanterBarProgress > 0) && (PlanterBarProgress <= 1) && (Abs(PlanterBarProgress - NewPlanterBarProgress) <= 0.10))
						{
							VerifiedPlanterBarProgress := PlanterBarProgress  ; PlanterBarProgress2, variable only needed for testing status update
							PlanterBarProgress := (NewPlanterBarProgress + PlanterBarProgress) / 2

							PlanterHarvestTime%i% := nowUnix() + Round((1 - PlanterBarProgress) * PlanterGrowTime * 3600)
							IniWrite PlanterHarvestTime%i%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
							(SetStatus) && nm_setStatus("Detected", PlanterName%i% "`nField: " FieldName " - Est. Progress: " Round(PlanterBarProgress*100) "%")
							break
						}
					}
				}

				Sleep 100
				sendinput "{" ZoomOut "}"
				if (A_Index = 10)
				{
					sendinput "{" RotLeft " 2}"
					r := 1
				}
			}
			sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
			Sleep 500
		}
	}
}
;syspalk if you're reading this hi
;(+) Keep this in for the final
nm_HealthDetection(w:=0)
{
	static pBMHealth, pBMDamage
	HealthBars := []
	if !(IsSet(pBMHealth) && IsSet(pBMDamage))
	{
		pBMHealth := Gdip_CreateBitmap(1,4)
		pGraphics := Gdip_GraphicsFromImage(pBMHealth), Gdip_GraphicsClear(pGraphics, 0xff1fe744), Gdip_DeleteGraphics(pGraphics)
		pBMDamage := Gdip_CreateBitmap(1,4)
		pGraphics := Gdip_GraphicsFromImage(pBMDamage), Gdip_GraphicsClear(pGraphics, 0xff6b131a), Gdip_DeleteGraphics(pGraphics)
	}
	ActivateRoblox()
	GetRobloxClientPos()
	if w = 1 ; king beetle, right half search only to avoid false detections
		pBMScreen := Gdip_BitmapFromScreen((windowX + windowWidth//2) "|" windowY "|" windowWidth//2 "|" windowHeight)
	else
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)	
	G := Gdip_GraphicsFromImage(pBMScreen)
	pBrush := Gdip_BrushCreateSolid(0xff000000)
	while ((Gdip_ImageSearch(pBMScreen, pBMHealth, &HPStart, , , , , , , 5) > 0) || (Gdip_ImageSearch(pBMScreen, pBMDamage, &HPStart, , , , , , , 5) > 0))
	{
		x := SubStr(HPStart, 1, InStr(HPStart, ",")-1), y := SubStr(HPStart, InStr(HPStart, ",")+1)
		x1 := x, y1 := y
		Loop (windowWidth - x)
		{
			i := x + A_Index - 1
			switch Gdip_GetPixel(pBMScreen, i, y)
			{
				case 4280280900:
				x1++

				case 4285207322:
				x2 := i

				default:
				Break
			}
		}
		Loop (windowHeight - y)
		{
			switch Gdip_GetPixel(pBMScreen, x, y1)
			{
				case 4280280900, 4285207322:
				y1++

				default:
				Break
			}
		}
		HealthBarPercent := (x1 > x) ? ((IsSet(x2) && (x2 > x)) ? Round((x1-x)/(x2-x)*100, 2) : 100.00) : 0.00
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
	static bosses := Map()
	confidenceArray := []
	confidenceTotal := 0
	if (!IsSet(intialHealthCheck) || (intialHealthCheck = 0) || !bosses.Has(bossName "Health"))
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
			else if (!IsSet(healthDiff) || Abs(bosses[bossName "Health"] - v) < healthDiff)
			{
				healthDiff := Abs(bosses[bossName "Health"] - v)
				lastHealth := v
				confidenceArray.Push(v)
			}
		}
	}
	if (!IsSet(lastHealth) || (confidenceArray.Length = 0))
		return 0
	for index, value in confidenceArray
	{
		confidenceTotal += value
	}
	confidenceMean := confidenceTotal / confidenceArray.Length
	if ((confidenceMean >= lastHealth - 1) && (confidenceMean <= lastHealth + 1))
	{
		dmgDealt := round((bosses[bossName "Health"]-lastHealth)/(bosses[bossName "TimeInterval"]/60000), 4)
		if ((dmgDealt > 0) && ((abs(bosses[bossName "Health"]-lastHealth) >= 2.5) && lastHealth > 0))
		{
			timeEstimation := round(lastHealth/abs(dmgDealt), 2)
			elapsedMins := floor(bossTimer/60000)
			elapsedSecs := Mod(bossTimer, 60)
			if (timeEstimation > 60)
			{
				sHours := Floor(timeEstimation/60)
				sMinutes := Mod(timeEstimation, 60)
				nm_setStatus("Detected",
					(
					"Health
					Boss: " bossName "
					Est Previous Health: " round(bosses[bossName "Health"], 2) "%
					Est Current Health: " lastHealth "%
					Est Change of health: " round(abs(dmgDealt), 2) "% Per minute
					Est Time until dead: " round(sHours) " Hours " round(sMinutes) " Minutes
					Time Elasped: " elapsedMins " Minutes " elapsedSecs " Seconds"
					)
				)
			}
			else
			{
				sMinutes := Floor(timeEstimation)
				Sseconds := Round((timeEstimation - sMinutes) * 60)
				nm_setStatus("Detected",
					(
					"Health
					Boss: " bossName "
					Est Previous Health: " round(bosses[bossName "Health"], 2) "%
					Est Current Health: " lastHealth "%
					Est Change of health: " round(abs(dmgDealt), 2) "% Per minute
					Est Time until dead: " round(sMinutes) " Minutes " round(sSeconds) " Seconds
					Time Elasped: " elapsedMins " Minutes " elapsedSecs " Seconds"
					)
				)
			}
			IniWrite lastHealth, "settings\nm_config.ini", "Collect", "Input" bossName "Health"
			bosses[bossName "Health"] := lastHealth
		}
		else
		{
			Return 0
		}
	}
}
nm_imgSearch(fileName,v,aim := "full", trans:="none"){
	GetRobloxClientPos()
	;xi := 0
	;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi:=(aim="actionbar") ? windowWidth//4 : (aim="highright") ? windowWidth//2 : (aim="right") ? windowWidth//2 : (aim="center") ? windowWidth//4 : (aim="lowright") ? windowWidth//2 : 0
	yi:=(aim="low") ? windowHeight//2 : (aim="actionbar") ? (windowHeight//4)*3 : (aim="center") ? windowHeight//4 : (aim="lowright") ? windowHeight//2 : (aim="quest") ? 150 : 0
	ww:=(aim="actionbar") ? xi*3 : (aim="highleft") ? windowWidth//2 : (aim="left") ? windowWidth//2 : (aim="center") ? xi*3 : (aim="quest" || aim="questbrown") ? 310 : windowWidth
	wh:=(aim="high") ? windowHeight//2 : (aim="highright") ? windowHeight//2 : (aim="highleft") ? windowHeight//2 : (aim="buff") ? 150 : (aim="abovebuff") ? 30 : (aim="center") ? yi*3 : (aim="quest") ? Max(560, windowHeight-100) : (aim="questbrown") ? windowHeight//2 : windowHeight
	if DirExist(A_WorkingDir "\nm_image_assets")
	{
		try result := ImageSearch(&FoundX, &FoundY, windowX + xi, windowY + yi, windowX + ww, windowY + wh, "*" v ((trans != "none") ? (" *Trans" trans) : "") " " A_WorkingDir "\nm_image_assets\" fileName)
		catch {
			nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
			Sleep 5000
			ProcessClose DllCall("GetCurrentProcessId")
		}
		if (result = 1)
			return [0,FoundX-windowX,FoundY-windowY]
		else
			return [1, 0, 0]
	} else {
		MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		return [3, 0, 0]
	}
}
PostSubmacroMessage(submacro, args*){
	DetectHiddenWindows 1
	if WinExist(submacro ".ahk ahk_class AutoHotkey")
		try PostMessage(args*)
	DetectHiddenWindows 0
}
nm_Reset(checkAll:=1, wait:=2000, convert:=1, force:=0){
	global resetTime, youDied, VBState, KeyDelay, SC_E, SC_Esc, SC_R, SC_Enter, RotRight, RotLeft, RotUp, RotDown, ZoomOut, objective, AFBrollingDice, AFBuseGlitter, AFBuseBooster, currentField, HiveConfirmed, GameFrozenCounter, MultiReset, bitmaps
	static hivedown := 0
	;check for game frozen conditions
	if (GameFrozenCounter>=3) { ;3 strikes
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		CloseRoblox()
		GameFrozenCounter:=0
	}
	DisconnectCheck()
	nm_setShiftLock(0)
	nm_OpenMenu()
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
		ActivateRoblox()
		nm_setShiftLock(0)
		nm_OpenMenu()

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		;check that performance stats is disabled
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+36 "|" windowWidth "|24")
		if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfmem"], &pos, , , , , 2, , 5) = 1)
		&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfcpu"], &pos, x + 17, y, , y + 7, 2) = 1)
			&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["perfgpu"], &pos, x + 17, y, , y + 7, 2) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["perfwhitefill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 17, y + 7, 2) = 0)) {
					Send "^{F7}"
				}
			}
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in dialog before reset
		Loop 500
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
			Click
			Sleep 150
		}
		MouseMove windowX+350, windowY+offsetY+100
		;check to make sure you are not in a yes/no prompt
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
			MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
			Click
			MouseMove windowX+350, windowY+offsetY+100
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in feed window on accident
		imgPos := nm_imgSearch("cancel.png",30)
		If (imgPos[1] = 0){
			MouseMove windowX+(imgPos[2]), windowY+(imgPos[3])
			Click
			MouseMove windowX+350, windowY+offsetY+100
		}
		;check to make sure you are not in blender screen
		BlenderSS := Gdip_BitmapFromScreen(windowX+windowWidth//2 - 275 "|" windowY+Floor(0.48*windowHeight) - 220 "|550|400")
		if (Gdip_ImageSearch(BlenderSS, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX+windowWidth//2 - 250, windowY+Floor(0.48*windowHeight) - 200
			Sleep 150
			click
		}
		Gdip_DisposeImage(BlenderSS)
		;check to make sure you are not in sticker screen
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 - 275 "|" windowY+4*windowHeight//10-178 "|56|56")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["CloseGUI"], , , , , , 5) > 0) {
			MouseMove windowX+windowWidth//2 - 250, windowY+4*windowHeight//10 - 150
			sleep 150
			click
		}
		Gdip_DisposeImage(pBMScreen)
		;check to make sure you are not in shop before reset
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0) {
			loop 2 {
				shopG := nm_imgSearch("shop_corner_G.png",30,"right")
				shopR := nm_imgSearch("shop_corner_R.png",30,"right")
				If (shopG[1] = 0 || shopR[1] = 0) {
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					Sleep 1000
				}
			}
		}
		;check to make sure there is not a window open
		searchRet := nm_imgSearch("close.png",30,"full")
		If (searchRet[1] = 0) {
			MouseMove windowX+searchRet[2],windowY+searchRet[3]
			click
			MouseMove windowX+350, windowY+offsetY+100
			Sleep 1000
		}
		;check to make sure there is no Memory Match
		nm_SolveMemoryMatch()

		nm_setStatus("Resetting", "Character " . Mod(A_Index, 10))
		MouseMove windowX+350, windowY+offsetY+100
		PrevKeyDelay:=A_KeyDelay
		SetKeyDelay 250+KeyDelay
		Loop (VBState = 0) ? (1 + MultiReset + (GatherDoubleReset && (CheckAll=2))) : 1
		{
			resetTime:=nowUnix()
			PostSubmacroMessage("background", 0x5554, 1, resetTime)
			;reset
			ActivateRoblox()
			GetRobloxClientPos()
			send "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000
		}
		SetKeyDelay PrevKeyDelay

		; hive check
		if hivedown
			sendinput "{" RotDown "}"
		region := windowX "|" windowY+3*windowHeight//4 "|" windowWidth "|" windowHeight//4
		sconf := windowWidth**2//3200
		loop 4 {
			sleep 250+KeyDelay
			pBMScreen := Gdip_BitmapFromScreen(region), s := 0
			for i, k in bitmaps["hive"] {
				s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 4, , , sconf))
				if (s >= sconf) {
					Gdip_DisposeImage(pBMScreen)
					HiveConfirmed := 1
					sendinput "{" RotRight " 4}" (hivedown ? ("{" RotUp "}") : "")
					Send "{" ZoomOut " 5}"
					break 2
				}
			}
			Gdip_DisposeImage(pBMScreen)
			sendinput "{" RotRight " 4}" ((A_Index = 2) ? ("{" ((hivedown := !hivedown) ? RotDown : RotUp) "}") : "")
		}
	}
	;convert
	(convert=1) && nm_convert()
	;ensure minimum delay has been met
	if((nowUnix()-resetTime)<wait) {
		remaining:=floor((wait-(nowUnix()-resetTime))/1000) ;seconds
		if(remaining>5){
			Sleep 1000
			nm_setStatus("Waiting", remaining . " Seconds")
			Sleep (remaining-1)*1000
		}
		else {
			Sleep (remaining*1000) ;miliseconds
		}
	}
}
nm_setShiftLock(state, *){
	global bitmaps, SC_LShift, ShiftLockEnabled

	if !(hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) ; Shift Lock is not supported on UWP app at the moment
		return

	ActivateRoblox()
	GetRobloxClientPos(hwnd)

	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50")

	switch (v := Gdip_ImageSearch(pBMScreen, bitmaps["shiftlock"], , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
		if (state = 0)
		{
			send "{" SC_LShift "}"
			result := 0
		}
		else
			result := 1

		; shift lock disabled - enable if needed
		case 0:
		if (state = 1)
		{
			send "{" SC_LShift "}"
			result := 1
		}
		else
			result := 0
	}

	Gdip_DisposeImage(pBMScreen)
	return (ShiftLockEnabled := result)
}
; decision: "keep", 1; "replace", 2; "obtained", 3 // returns 0 - no prompt, 1 - prompt exists, 2 - no roblox window
nm_AmuletPrompt(decision:=0, type:=0, *){
	global bitmaps, ShiftLockEnabled

	Prev_ShiftLock := ShiftLockEnabled
	nm_setShiftLock(0)

	GetRobloxClientPos()
	if (windowWidth = 0)
		return 2
	else
		ActivateRoblox()

	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)

	if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
	{
		switch decision, 0
		{
			case "keep",1:
			if type = "Ant" || type = "King Beetle" || type = "Shell"
				nm_setStatus("Keeping", type " Amulet")	
			Gdip_DisposeImage(pBMScreen)
			loop 10
			{
				MouseMove windowX+350, windowY+offsetY+100
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["keep"], &pos, , , , , 2, , 2) = 1)
				{
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+10, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
					Sleep 200
					Click
				} 
				Gdip_DisposeImage(pBMScreen)
			}
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			case "replace",2:
			MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)+190, windowY+SubStr(pos, InStr(pos, ",")+1)+10, 5
			Click
			Gdip_DisposeImage(pBMScreen)
			Loop 25
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY "|500|" windowHeight)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1)
				{
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+SubStr(pos, InStr(pos, ",")+1), 5
					Click
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 100
			}
			nm_setShiftLock(Prev_ShiftLock)
			return 1

			case "obtained",3:
			nm_setStatus("Obtained", type " Amulet")
			Gdip_DisposeImage(pBMScreen)
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
nm_FindItem(chosenItem, *) {
	global shiftLockEnabled, bitmaps
	static items := ["Cog", "Ticket", "SprinklerBuilder", "BeequipCase", "Gumdrops", "Coconut", "Stinger", "Snowflake", "MicroConverter", "Honeysuckle", "Whirligig", "FieldDice", "SmoothDice", "LoadedDice", "JellyBeans", "RedExtract", "BlueExtract", "Glitter", "Glue", "Oil", "Enzymes", "TropicalDrink", "PurplePotion", "SuperSmoothie", "MarshmallowBee", "Sprout", "MagicBean", "FestiveBean", "CloudVial", "NightBell", "BoxOFrogs", "AntPass", "BrokenDrive", "7ProngedCog", "RoboPass", "Translator", "SpiritPetal", "Present", "Treat", "StarTreat", "AtomicTreat", "SunflowerSeed", "Strawberry", "Pineapple", "Blueberry", "Bitterberry", "Neonberry", "MoonCharm", "GingerbreadBear", "AgedGingerbreadBear", "WhiteDrive", "RedDrive", "BlueDrive", "GlitchedDrive", "ComfortingVial", "InvigoratingVial", "MotivatingVial", "RefreshingVial", "SatisfyingVial", "PinkBalloon", "RedBalloon", "WhiteBalloon", "BlackBalloon", "SoftWax", "HardWax", "CausticWax", "SwirledWax", "Turpentine", "PaperPlanter", "TicketPlanter", "FestivePlanter", "PlasticPlanter", "CandyPlanter", "RedClayPlanter", "BlueClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "ThePlanterOfPlenty", "BasicEgg", "SilverEgg", "GoldEgg", "DiamondEgg", "MythicEgg", "StarEgg", "GiftedSilverEgg", "GiftedGoldEgg", "GiftedDiamondEgg", "GiftedMythicEgg", "RoyalJelly", "StarJelly", "BumbleBeeEgg", "BumbleBeeJelly", "RageBeeJelly", "ShockedBeeJelly"]
	GetRobloxClientPos()
	DetectHiddenWindows 1
	if windowWidth == 0 {
		if WinExist("Status.ahk ahk_class AutoHotkey")
			sendMessage 0x5559
		DetectHiddenWindows 0
		return 0
	}
	Prev_ShiftLock := ShiftLockEnabled
	yOffset := GetYOffset()
	nm_setShiftLock(0)
	ActivateRoblox()
	if (nm_OpenMenu("itemmenu") = 0) {
		if WinExist("Status.ahk ahk_class AutoHotkey")
			SendMessage 0x5559,, 2
		DetectHiddenWindows 0
		nm_setShiftLock(Prev_ShiftLock)
		return 0
	}
	MouseMove windowX+46, windowY+yOffset+219
	Loop 60 {
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" windowHeight-300)
		if (Gdip_ImageSearch(pBMScreen, bitmaps[items[chosenitem]], &itemCoords,,,,,5)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		for k,v in items {
			if (Gdip_ImageSearch(pBMScreen, bitmaps[v], , , , , , 5)) {
				Send "{Wheel" (k > chosenItem ? "Up" : "Down") " 1}"
				break
			}
			if A_Index = items.length
				Send "{WheelUp 1}"
		}
		Gdip_DisposeImage(pBMScreen)
		sleep 300
	}
	DetectHiddenWindows 1
	if !itemCoords
		WinExist("Status.ahk ahk_class AutoHotkey") ? SendMessage(0x5559, 0, 1, , , , , , 2000) : ""
	else
		WinExist("Status.ahk ahk_class AutoHotkey") ? SendMessage(0x5559, StrSplit(itemCoords,",")[2]+windowY+140, , , , , , , 2000) : ""
	sleep 1000
	DetectHiddenWindows 0
	nm_OpenMenu()
	nm_setShiftLock(Prev_ShiftLock)
}
nm_gotoRamp(){
	global FwdKey, RightKey, HiveSlot, state, objective, HiveConfirmed
	HiveConfirmed := 0

	movement :=
	(
	nm_Walk(5, FwdKey) "
	" nm_Walk(9.2*HiveSlot-4, RightKey)
	)

	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T60 L"
	nm_endWalk()
}
nm_gotoCannon(){
	global LeftKey, RightKey, FwdKey, BackKey, currentWalk, objective, SC_Space, bitmaps

	nm_setShiftLock(0)

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100

	success := 0
	Loop 10
	{
		movement :=
		(
		'Send "{' SC_Space ' down}{' RightKey ' down}"
		Sleep 100
		Send "{' SC_Space ' up}"
		Walk(2)
		Send "{' FwdKey ' down}"
		Walk(1.5)
		Send "{' FwdKey ' up}"'
		)
		nm_createWalk(movement)
		KeyWait "F14", "D T5 L"
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
		n := s, f := s+200000000
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
			{
				success := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
		nm_endWalk()

		if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
		{
			Loop 10
			{
				if (A_Index = 10)
				{
					success := 0
					break
				}
				Sleep 500
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 2, , 2) = 1)
				{
					Gdip_DisposeImage(pBMScreen)
					break 2
				}
				else
				{
					movement := nm_Walk(1.5, LeftKey)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T5 L"
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

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100

	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
	if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
		HiveConfirmed := 1, Gdip_DisposeImage(pBMScreen)
	else
	{
		Gdip_DisposeImage(pBMScreen)

		; find hive slot
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
		n := s, f := s+150000000
		SendInput "{" LeftKey " down}"
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				HiveConfirmed := 1, Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
		SendInput "{" LeftKey " up}"
	}

	if (HiveConfirmed = 1) ; check that hive slot was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				HiveConfirmed := 0
				break
			}
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 2, , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				nm_convert()
				break
			}
			else
			{
				movement := nm_Walk(1.5, RightKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T5 L"
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}

	return HiveConfirmed
}

;//todo: add: 1. cooldown detection, set Last__ according to detected time, 2. remove double loop for going to collects unless cooldown could not be detected
nm_Collect(){
	global GatherFieldBoostedStart, LastGlitter, resetTime

	if ((VBState=1) || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	;MACHINES
	nm_Clock()
	nm_Blender()
	nm_Ant()
	nm_RoboPass()

	;DISPENSERS
	nm_HoneyDis()
	nm_TreatDis()
	nm_BlueberryDis()
	nm_StrawberryDis()
	nm_CoconutDis()
	nm_GlueDis()
	nm_RoyalJellyDis()

	;BEESMAS
	if beesmasActive {
		nm_Stockings()
		nm_Feast()
		nm_GingerbreadHouse()
		nm_SnowMachine()
		nm_Candles()
		nm_Samovar()
		nm_LidArt()
		nm_GummyBeacon()
		nm_RBPDelevel()
		nm_MemoryMatch("Winter")
	}

	;MEMORY MATCH
	nm_MemoryMatch("Normal")
	nm_MemoryMatch("Mega")
	nm_MemoryMatch("Extreme")

	;OTHER
	nm_Honeystorm()
	nm_HoneyLB()
	nm_StickerPrinter()
}
nm_Clock(){
	global ClockCheck, LastClock
	if (ClockCheck && (nowUnix()-LastClock)>3600) { ;1 hour
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)
		nm_updateAction("Collect")

		Loop 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Wealth Clock" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("clock")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Wealth Clock")
				break
			}
		}

		LastClock:=nowUnix()
		IniWrite LastClock, "settings\nm_config.ini", "Collect", "LastClock"
		if beesmasActive
			nm_Stockings(1)
	}
}
nm_Blender(){
	global BlenderCheck, BlenderRot, LastBlenderRot, BlenderEnd, TimerInterval
	, BlenderIndex1, BlenderIndex2, BlenderIndex3
	, BlenderItem1, BlenderItem2, BlenderItem3
	, BlenderTime1, BlenderTime2, BlenderTime3
	, BlenderAmount1, BlenderAmount2, BlenderAmount3
	, BlenderCount1, BlenderCount2, BlenderCount3

	nm_BlenderRotation()
	TimeForBlender := BlenderTime%LastBlenderRot% - TimerInterval ; due to BlenderTime being calcuted with TimerInterval integrated to fix that we simply subtract it before

	if (BlenderCheck && (nowUnix() - TimeForBlender) > TimerInterval) {
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			z := A_Index ;Set variable for fail safe
			nm_Reset()
			nm_setStatus("Traveling", "Blender" ((A_Index > 1) ? " (Attempt 2)" : ""))
			nm_gotoCollect("Blender")

			searchRet := nm_imgSearch("e_button.png", 30, "high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500

				SearchX := windowX+windowWidth//2 - 275, SearchY := windowY+Floor(0.48*windowHeight) - 220, BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|550|400")

				if (Gdip_ImageSearch(BlenderSS, bitmaps["CancelCraft"], , , , , , 2, , 7) > 0) {
					MouseMove windowX+windowWidth//2 + 230, windowY+Floor(0.48*windowHeight) + 130 ; click cancel button
					Sleep 150
					Click
				}

				if (!BlenderEnd && Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftR"], , , , , , 3, , 6) > 0)
				{
					nm_setStatus("Confirmed", "Blender is already in use")
					MouseMove windowX+windowwidth//2 - 250, windowY+Floor(0.48*windowHeight) - 200
					Gdip_disposeimage(BlenderSS) ;Close GUI and dispose of bitmap
					Sleep 150
					Click
					break
				} else if (BlenderEnd && Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftR"], , , , , , 3, , 6) > 0) {
					IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderEnd"
					BlenderEnd := 0
					MouseMove windowX+windowWidth//2 - 120, windowY+Floor(0.48*windowHeight) + 120 ; close red craft button
					Sleep 150
					Click
				}

				if (Gdip_ImageSearch(BlenderSS, bitmaps["EndCraftG"], , , , , , 4, , 6) > 0) {
					MouseMove windowX+WindowWidth//2 - 120, windowY+Floor(0.48*windowHeight) + 120 ; close green craft button
					Sleep 150
					Click
				}
				gdip_disposeimage(BlenderSS)
				Sleep 800
				loop
				{
					BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|170|245")

					Blender := %("BlenderItem" BlenderRot)%
					BlenderIMG := Blender "B"

					if (Gdip_ImageSearch(BlenderSS, bitmaps[BlenderIMG], , , , , , 2, , 4) > 0)
					{
						gdip_disposeimage(BlenderSS)  ; Dispose of the bitmap
						Sleep 200
						BlenderSS := Gdip_BitmapFromScreen(SearchX "|" SearchY "|553|400")
						if (Gdip_ImageSearch(BlenderSS, bitmaps["NoItems"], , , , , , 2) > 0) {
							BlenderItem%BlenderRot% := "None", BlenderAmount%BlenderRot% := 0, BlenderIndex%BlenderRot% := 1, BlenderTime%BlenderRot% := 0

							IniWrite "None", "settings\nm_config.ini", "Blender", "BlenderItem" BlenderRot
							IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderAmount" BlenderRot
							IniWrite 1, "settings\nm_config.ini", "Blender", "BlenderIndex" BlenderRot
							IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderTime" BlenderRot

							MainGui["BlenderAdd" BlenderRot].Text := ((BlenderItem%BlenderRot% = "None" || BlenderItem%BlenderRot% = "") ? "Add" : "Clear")
							MainGui["BlenderData" BlenderRot].Text := "(" BlenderAmount%BlenderRot% ") [" ((BlenderIndex%BlenderRot% = "Infinite") ? "∞" : BlenderIndex%BlenderRot%) "]"

							MainGui["BlenderItem" BlenderRot "Picture"].Value := ""
							gdip_disposeimage(BlenderSS)
							nm_BlenderRotation()
							if !(BlenderCheck)
								break 2
							break
						}
						gdip_disposeimage(BlenderSS)
						MouseMove windowX+windowWidth//2, windowY+Floor(0.48*windowHeight) + 130 ;Open item menu
						Sleep 150
						click
						Sleep 150
						MouseMove windowX+windowWidth//2 - 60, windowY+Floor(0.48*windowHeight) + 140 ;Add more of x item
						Sleep 150
						While (A_Index < BlenderAmount%BlenderRot%) {
							Click
							Sleep 30
						}
						Sleep 200
						IniWrite 0, "settings\nm_config.ini", "Blender", "BlenderCount" LastBlenderRot ; reset GUI counter

						nm_setStatus("Collected", "Blender")

						BlenderTime%BlenderRot% := BlenderAmount%BlenderRot% * 300 ;calculate first time variable
						BlenderTimeTemp := BlenderTime%BlenderRot% ;set up a temporary varible to hold time
						TempBlenderRot := BlenderRot ; save a temporary rotation holder

						BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% + nowUnix() ;add nowunix for time after temporoary varible has been created
						IniWrite BlenderTime%TempBlenderRot%, "settings\nm_config.ini", "Blender", "BlenderTime" TempBlenderRot ; save timer to config

						loop {
							TempBlenderRot := Mod(TempBlenderRot, 3) + 1
							if (TempBlenderRot = BlenderRot) ;makes sure it doesnt do the already calculated time again
								break

							if ((BlenderIndex%TempBlenderRot% = "Infinite" || BlenderIndex%TempBlenderRot% > 0) && (BlenderItem%TempBlenderRot% != "None" && BlenderItem%TempBlenderRot% != "")) { ;start time calculation process
								BlenderTime%TempBlenderRot% := (BlenderAmount%TempBlenderRot% * 300) + BlenderTimeTemp ;add previous time to this one after to show time until its done
								BlenderTimeTemp := BlenderTime%TempBlenderRot% ;create a new temp for next
								BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% + nowUnix() ;add now unix to it for the counter
								IniWrite BlenderTime%TempBlenderRot%, "settings\nm_config.ini", "Blender", "BlenderTime" TempBlenderRot ;save the value to the config for GUI use and Remote control
							}
						}
						TimerInterval := BlenderAmount%BlenderRot% * 300 ;set up time
						IniWrite BlenderRot, "settings\nm_config.ini", "Blender", "LastBlenderRot" ; define this for GUI and to reset counter as used above

						BlenderRot := Mod(BlenderRot, 3) + 1
						nm_BlenderRotation()
						if (BlenderIndex%BlenderRot% != "Infinite") {
							BlenderIndex%BlenderRot%-- ;subtract from blenderindex for looping only if its a number
							MainGui["BlenderData" BlenderRot].Text := "(" BlenderAmount%BlenderRot% ") [" ((BlenderIndex%BlenderRot% = "Infinite") ? "∞" : BlenderIndex%BlenderRot%) "]"
							IniWrite BlenderIndex%BlenderRot%, "settings\nm_config.ini", "Blender", "BlenderIndex" BlenderRot
						}
						Sleep 100
						MouseMove windowX+windowWidth//2 + 70, windowY+Floor(0.48*windowHeight) + 130 ;Click Confirm
						Sleep 150
						Click
						Sleep 100
						MouseMove windowX+windowWidth//2 - 250, windowY+Floor(0.48*windowHeight) - 200 ;Close GUI
						Sleep 150
						Click
						break 2
					} else {
						Sleep 50
						MouseMove windowX+windowWidth//2 + 230, windowY+Floor(0.48*windowHeight) + 110 ;not found go next item
						Sleep 150
						Click
						Sleep 100
						if (A_Index = 60) {
							if (z = 2) {
								nm_setStatus("Failed", "Blender")
								MouseMove windowX+windowWidth//2 - 250, windowY+Floor(0.48*windowHeight) - 200 ;Close GUI
								Sleep 150
								Click

								BlenderTime%BlenderRot% := BlenderAmount%BlenderRot% * 300 ;calculate first time variable
								BlenderTimeTemp := BlenderTime%BlenderRot% ;set up a temporary varible to hold time
								TempBlenderRot := BlenderRot ; save a temporary rotation holder

								BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% + nowUnix() ;add nowunix for time after temporoary varible has been created
								IniWrite BlenderTime%TempBlenderRot%, "settings\nm_config.ini", "Blender", "BlenderTime" TempBlenderRot ; save timer to config

								loop {
									TempBlenderRot := Mod(TempBlenderRot, 3) + 1
									if (TempBlenderRot = BlenderRot) ;makes sure it doesnt do the already calculated time again
										break

									if ((BlenderIndex%TempBlenderRot% = "Infinite" || BlenderIndex%TempBlenderRot% > 0) && (BlenderItem%TempBlenderRot% != "None" && BlenderItem%TempBlenderRot% != "")) { ;start time calculation process
										BlenderTime%TempBlenderRot% := (BlenderAmount%TempBlenderRot% * 300) + BlenderTimeTemp ;add previous time to this one after to show time until its done
										BlenderTimeTemp := BlenderTime%TempBlenderRot% ;create a new temp for next
										BlenderTime%TempBlenderRot% := BlenderTime%TempBlenderRot% + nowUnix() ;add now unix to it for the counter
										IniWrite BlenderTime%TempBlenderRot%, "settings\nm_config.ini", "Blender", "BlenderTime" TempBlenderRot ;save the value to the config for GUI use and Remote control
									}
								}
							}
							break
						}
					}
				}
			}
		}
		IniWrite TimerInterval, "settings\nm_config.ini", "Blender", "TimerInterval"
		IniWrite BlenderRot, "settings\nm_config.ini", "Blender", "BlenderRot"
		IniWrite BlenderIndex%BlenderRot%, "settings\nm_config.ini", "Blender", "BlenderIndex" BlenderRot
	}
}
nm_BlenderRotation() {
	global BlenderRot, BlenderItem1, BlenderItem2, BlenderItem3, BlenderIndex1, BlenderIndex2, BlenderIndex3, BlenderCheck
	loop {
		if ((BlenderIndex%BlenderRot% = "Infinite" || BlenderIndex%BlenderRot% > 0) && (BlenderItem%BlenderRot% != "None" && BlenderItem%BlenderRot% != "")) {
			BlenderCheck := 1
			IniWrite BlenderCheck, "settings\nm_config.ini", "Blender", "BlenderCheck"
			break
		} else {
			BlenderRot := Mod(BlenderRot, 3) + 1
			if (A_Index = 4) {
				if (BlenderCheck) {
					BlenderCheck := 0
					IniWrite BlenderCheck, "settings\nm_config.ini", "Blender", "BlenderCheck"
					nm_setStatus("Confirmed", "No more items to rotate through. Turning blender off")
				}
				break
			}
		}
	}
}
nm_Ant() { ;collect Ant Pass then do Challenge
	global AntPassCheck, AntPassBuyCheck, AntPassAction, QuestAnt, LastAntPass
	static AntPassNum:=2

	if(((AntPassCheck && ((AntPassNum<10) || (AntPassAction="challenge"))) && (nowUnix()-LastAntPass>7200)) || (QuestAnt && ((AntPassNum>0) || (AntPassBuyCheck = 1)))){ ;2 hours OR ant quest
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset(1, (QuestAnt || (AntPassAction = "challenge")) ? 20000 : 2000)
			nm_setStatus("Traveling", (QuestAnt ? "Ant Challenge" : ("Ant " . AntPassAction)) ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("antpass")

			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				updateConfig()
				Sleep 500
				nm_setStatus("Collected", "Ant Pass")
				++AntPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(AntPassNum < 10) && nm_setStatus("Confirmed", "10/10 Ant Passes")
					AntPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					updateConfig()
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}

		;do ant challenge
		if(QuestAnt || AntPassAction="challenge"){
			QuestAnt:=0
			movement :=
			(
			nm_Walk(12, FwdKey, RightKey) '
			' nm_Walk(4, FwdKey)
			)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T30 L"
			nm_endWalk()
			Sleep 500
			Loop 2 {
				If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					--AntPassNum
					nm_setStatus("Attacking", "Ant Challenge")
					Sleep 500
					send "{" SC_1 "}"
					movement :=
					(
					nm_Walk(9, BackKey) "
					" nm_Walk(3, RightKey, FwdKey) "
					" nm_Walk(1, FwdKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T30 L"
					nm_endWalk()
					click "down"
					loop 300 {
						if (Mod(A_Index, 10) = 1)
							PostSubmacroMessage("background", 0x5554, 1, nowUnix())
						if nm_AmuletPrompt(1, "Ant") {
							MouseMove windowX+350, windowY+offsetY+100
							break 2
						}
						sleep 1000
					}
					click "up"
				}
				else {
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["passnone"], , , , , , 2, , 2) = 1) {
						Gdip_DisposeImage(pBMScreen)
						AntPassNum:=0
						if ((AntPassBuyCheck = 1) && (A_Index = 1)) {
							movement :=
							(
							nm_Walk(6, LeftKey) "
							" nm_Walk(10, BackKey, LeftKey)
							)
							nm_createWalk(movement)
							KeyWait "F14", "D T5 L"
							KeyWait "F14", "T30 L"
							nm_endWalk()
							Sleep 200

							If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
								sendinput "{" SC_E " down}"
								Sleep 100
								sendinput "{" SC_E " up}"
								Sleep 500
								nm_setStatus("Bought", "Ant Pass")
								++AntPassNum
							} else {
								nm_setStatus("Aborting", "Cannot buy Ant Pass")
								break
							}

							movement :=
							(
							nm_Walk(10, FwdKey, RightKey) "
							" nm_Walk(6, RightKey)
							)
							nm_createWalk(movement)
							KeyWait "F14", "D T5 L"
							KeyWait "F14", "T30 L"
							nm_endWalk()
							Sleep 200
							continue
						} else {
							nm_setStatus("Aborting", "No Ant Pass in Inventory")
							break
						}
					}
					Gdip_DisposeImage(pBMScreen)
				}
			}
		}
	}

	updateConfig() {
		LastAntPass:=nowUnix()
		IniWrite LastAntPass, "settings\nm_config.ini", "Collect", "LastAntPass"
	}
}
nm_RoboPass(){
	global RoboPassCheck, LastRoboPass
	static RoboPassNum:=1

	if (RoboPassCheck && (RoboPassNum < 10) && (nowUnix()-LastRoboPass)>79200) { ;22 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Robo Pass" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("robopass")

			if (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				updateConfig()
				Sleep 500
				nm_setStatus("Collected", "Robo Pass")
				++RoboPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 2, , 2) = 1) {
					(RoboPassNum < 10) && nm_setStatus("Confirmed", "10/10 Robo Passes")
					RoboPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 2, , 2) = 1) {
					updateConfig()
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
	}

	updateConfig() {
		LastRoboPass:=nowUnix()
		IniWrite LastRoboPass, "settings\nm_config.ini", "Collect", "LastRoboPass"
	}
}
nm_HoneyDis(){
	global HoneyDisCheck, LastHoneyDis
	if (HoneyDisCheck && (nowUnix()-LastHoneyDis)>3600) { ;1 hour
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Honey Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("honeydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Honey Dispenser")
				break
			}
		}
		LastHoneyDis:=nowUnix()
		IniWrite LastHoneyDis, "settings\nm_config.ini", "Collect", "LastHoneyDis"
	}
}
nm_TreatDis(){
	global TreatDisCheck, LastTreatDis
	if (TreatDisCheck && (nowUnix()-LastTreatDis)>3600) { ;1 hour
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Treat Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("treatdis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Treat Dispenser")
				break
			}
		}
		LastTreatDis:=nowUnix()
		IniWrite LastTreatDis, "settings\nm_config.ini", "Collect", "LastTreatDis"
	}
}
nm_BlueberryDis(){
	global BlueberryDisCheck, LastBlueberryDis
	if (BlueberryDisCheck && (nowUnix()-LastBlueberryDis)>14400) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Blueberry Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("blueberrydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				sleep 500
				nm_setStatus("Collected", "Blueberry Dispenser")
				break
			}
		}
		LastBlueberryDis:=nowUnix()
		IniWrite LastBlueberryDis, "settings\nm_config.ini", "Collect", "LastBlueberryDis"
	}
}
nm_StrawberryDis(){
	global StrawberryDisCheck, LastStrawberryDis
	if (StrawberryDisCheck && (nowUnix()-LastStrawberryDis)>14400) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Strawberry Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("strawberrydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				sleep 500
				nm_setStatus("Collected", "Strawberry Dispenser")
				break
			}
		}
		LastStrawberryDis:=nowUnix()
		IniWrite LastStrawberryDis, "settings\nm_config.ini", "Collect", "LastStrawberryDis"
	}
}
nm_CoconutDis(){
	global CoconutDisCheck, LastCoconutDis, CoconutBoosterCheck, BoostChaserCheck
	if (CoconutDisCheck && (nowUnix()-LastCoconutDis)>14400 && !(CoconutBoosterCheck && BoostChaserCheck)) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Coconut Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("coconutdis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				sleep 500
				nm_setStatus("Collected", "Coconut Dispenser")
				break
			}
		}
		LastCoconutDis:=nowUnix()
		IniWrite LastCoconutDis, "settings\nm_config.ini", "Collect", "LastCoconutDis"
	}
}
nm_GlueDis(){
	global GlueDisCheck, LastGlueDis
	if (GlueDisCheck && (nowUnix()-LastGlueDis)>(79200)) { ;22 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_OpenMenu("itemmenu")

			nm_setStatus("Traveling", "Glue Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("gluedis", 0) ; do not wait for end

			;locate gumdrops
			if ((gumdropPos := nm_InventorySearch("gumdrops")) = 0) { ;~ new function
				nm_OpenMenu()
				continue
			}
			MouseMove windowX+gumdropPos[1], windowY+gumdropPos[2]
			KeyWait "F14", "T120 L"
			nm_endWalk()

			MouseClickDrag "Left", windowX+gumdropPos[1], windowY+gumdropPos[2], windowX+(windowWidth//2), windowY+(windowHeight//2), 5
			;close inventory
			nm_OpenMenu()
			Sleep 500
			;inside gummy lair
			movement := nm_Walk(6, FwdKey)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T20 L"
			nm_endWalk()
			Sleep 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 1000
				nm_setStatus("Collected", "Glue Dispenser")
				break
			}
		}
		LastGlueDis:=nowUnix()
		IniWrite LastGlueDis, "settings\nm_config.ini", "Collect", "LastGlueDis"
	}
}
nm_RoyalJellyDis(){
	global RoyalJellyDisCheck, LastRoyalJellyDis
	if (RoyalJellyDisCheck && (nowUnix()-LastRoyalJellyDis)>(79200) && (MoveMethod != "Walk")) { ;22 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Royal Jelly Dispenser" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("royaljellydis")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Royal Jelly Dispenser")
				sleep 10000
				break
			}
		}
		LastRoyalJellyDis:=nowUnix()
		IniWrite LastRoyalJellyDis, "settings\nm_config.ini", "Collect", "LastRoyalJellyDis"
	}
}
nm_Stockings(fromClock:=0){
	global StockingsCheck, LastStockings
	if (StockingsCheck && (nowUnix()-LastStockings)>(fromClock ? 3580 : 3600)) { ;1 hour
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			if (fromClock && (A_Index = 1)) {
				Sleep 500
				nm_setStatus("Traveling", "Stockings (Clock)")

				movement :=
				(
				'
				Send "{' FwdKey ' down}"
				Walk(6.5)
				Send "{' SC_Space ' down}"
				Sleep 100
				Send "{' SC_Space ' up}"
				Walk(6.5)
				Send "{' FwdKey ' up}"
				' nm_Walk(24.5, RightKey) '
				' nm_Walk(3, FwdKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()
			} else {
				nm_Reset()
				nm_setStatus("Traveling", "Stockings" ((A_Index > 1) ? " (Attempt 2)" : ""))

				nm_gotoCollect("stockings")
			}

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500

				movement :=
				(
				nm_Walk(8, FwdKey) '
				' nm_Walk(2.5, BackKey) '
				' nm_Walk(3, RightKey) '
				Send "{' SC_Space ' down}"
				HyperSleep(500)
				Send "{' SC_Space ' up}"
				DllCall("GetSystemTimeAsFileTime", "int64p", &s:=0)
				' nm_Walk(3, RightKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &t:=0)
				Sleep 600-(t-s)//10000
				' nm_Walk(9, LeftKey) '
				Send "{' SC_Space ' down}"
				HyperSleep(500)
				Send "{' SC_Space ' up}"
				DllCall("GetSystemTimeAsFileTime", "int64p", &s:=0)
				' nm_Walk(3, LeftKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &t:=0)
				Sleep 600-(t-s)//10000
				' nm_Walk(6, RightKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				nm_setStatus("Collected", "Stockings")
				break
			}
		}
		LastStockings:=nowUnix()
		IniWrite LastStockings, "settings\nm_config.ini", "Collect", "LastStockings"
	}
}
nm_Feast(){ ; Beesmas Feast
	global FeastCheck, LastFeast
	if (FeastCheck && (nowUnix()-LastFeast)>5400) { ;1.5 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Beesmas Feast" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("feast")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 3000
				sendinput "{" RotLeft "}"

				movement :=
				(
				nm_Walk(3, FwdKey, RightKey) '
				' nm_Walk(1, RightKey) '
				Loop 2 {
					' nm_Walk(5, BackKey) '
					' nm_Walk(1.5, LeftKey) '
					' nm_Walk(5, FwdKey) '
					' nm_Walk(1.5, LeftKey) '
				}
				' nm_Walk(5, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				nm_setStatus("Collected", "Beesmas Feast")
				break
			}
		}
		LastFeast:=nowUnix()
		IniWrite LastFeast, "settings\nm_config.ini", "Collect", "LastFeast"
	}
}
nm_GingerbreadHouse(){
	global GingerbreadCheck, LastGingerbread
	if (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) { ;2 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Gingerbread House" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("gingerbread")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 3000
				nm_setStatus("Collected", "Gingerbread House")
				break
			}
		}
		LastGingerbread:=nowUnix()
		IniWrite LastGingerbread, "settings\nm_config.ini", "Collect", "LastGingerbread"
	}
}
nm_SnowMachine(){
	global SnowMachineCheck, LastSnowMachine
	if (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) { ;2 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Snow Machine" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("snowmachine")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				nm_setStatus("Collected", "Snow Machine")
				updateConfig()
				nm_Honeystorm(1) ;collect Honeystorm on the way, then loot
				return
			}
		}
		updateConfig()
	}
	updateConfig() {
		LastSnowMachine:=nowUnix()
		IniWrite LastSnowMachine, "settings\nm_config.ini", "Collect", "LastSnowMachine"
	}
}
nm_Candles(){
	global CandlesCheck, LastCandles
	if (CandlesCheck && (nowUnix()-LastCandles)>14400) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Candles" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("candles")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 4000

				movement :=
				(
				nm_Walk(4, FwdKey) "
				" nm_Walk(6, RightKey) "
				" nm_Walk(10, LeftKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				nm_setStatus("Collected", "Candles")
				break
			}
		}
		LastCandles:=nowUnix()
		IniWrite LastCandles, "settings\nm_config.ini", "Collect", "LastCandles"
	}
}
nm_Samovar(){
	global SamovarCheck, LastSamovar
	if (SamovarCheck && (nowUnix()-LastSamovar)>21600) { ;6 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Samovar" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("samovar")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 5000

				movement :=
				(
				nm_Walk(4, FwdKey, RightKey) "
				" nm_Walk(1, RightKey) "
				Loop 3 {
					" nm_Walk(6, BackKey) "
					" nm_Walk(1.25, LeftKey) "
					" nm_Walk(6, FwdKey) "
					" nm_Walk(1.25, LeftKey) "
				}
				" nm_Walk(6, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				nm_setStatus("Collected", "Samovar")
				break
			}
		}
		LastSamovar:=nowUnix()
		IniWrite LastSamovar, "settings\nm_config.ini", "Collect", "LastSamovar"
	}
}
nm_LidArt(){
	global LidArtCheck, LastLidArt
	if (LidArtCheck && (nowUnix()-LastLidArt)>28800) { ;8 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Lid Art" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("lidart")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 5000

				movement :=
				(
				nm_Walk(3, FwdKey, RightKey) "
				Loop 2 {
					" nm_Walk(4.5, BackKey) "
					" nm_Walk(1.25, LeftKey) "
					" nm_Walk(4.5, FwdKey) "
					" nm_Walk(1.25, LeftKey) "
				}
				" nm_Walk(4.5, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				nm_setStatus("Collected", "Lid Art")
				break
			}
		}
		LastLidArt:=nowUnix()
		IniWrite LastLidArt, "settings\nm_config.ini", "Collect", "LastLidArt"
	}
}
nm_GummyBeacon(){
	global GummyBeaconCheck, LastGummyBeacon
	if (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800 && (MoveMethod != "Walk")) { ;8 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Gummy Beacon" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("gummybeacon")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "Gummy Beacon")
				break
			}
		}
		LastGummyBeacon:=nowUnix()
		IniWrite LastGummyBeacon, "settings\nm_config.ini", "Collect", "LastGummyBeacon"
	}
}
nm_RBPDelevel(){ ;Robo Bear Party De-level
	global RBPDelevelCheck, LastRBPDelevel
	if (RBPDelevelCheck && (nowUnix()-LastRBPDelevel)>10800 && (MoveMethod != "Walk")) { ;3 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "RBP De-Level" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("rbpdelevel")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500
				nm_setStatus("Collected", "RBP De-Level")
				break
			}
		}
		LastRBPDelevel:=nowUnix()
		IniWrite LastRBPDelevel, "settings\nm_config.ini", "Collect", "LastRBPDelevel"
	}
}
; Memory Match code written by OfficerAC
nm_MemoryMatch(MemoryMatchGame) {

	global NormalMemoryMatchCheck, MegaMemoryMatchCheck, ExtremeMemoryMatchCheck, NightMemoryMatchCheck, WinterMemoryMatchCheck
		, LastNormalMemoryMatch, LastMegaMemoryMatch, LastExtremeMemoryMatch, LastNightMemoryMatch, LastWinterMemoryMatch

	if !(%MemoryMatchGame%MemoryMatchCheck && (nowUnix()-Last%MemoryMatchGame%MemoryMatch)>MemoryMatchGames[MemoryMatchGame].cooldown)
		return

	success := deaths := 0
	loop 2 {
		nm_reset(0, 0, 0)
		nm_SetStatus("Traveling", MemoryMatchGame " Memory Match" ((A_Index > 1) ? " (Attempt 2)" : "" ))
		nm_GoToCollect(MemoryMatchGame "mm", 0)
		loop 720 { ; 3 min timeout
			Sleep 250
			if ((!GetKeyState("F14") && success := 1) || (youDied && ++deaths))
				break
		}
		nm_endWalk()

		If ((success = 1) && nm_imgSearch("e_button.png",30,"high")[1] = 0) {
			nm_setStatus("Found", MemoryMatchGame " Memory Match")
			sendinput "{" SC_E " down}"
			Sleep 100
			sendinput "{" SC_E " up}"
			UpdateConfig()
			sleep 1500
			Break
		} else if (A_Index = 2) {
			(MemoryMatchGame != "Night") && UpdateConfig()
			return
		}
	} ;  close Try twice to find MM

	nm_SolveMemoryMatch(MemoryMatchGame)

	UpdateConfig() {
		IniWrite Last%MemoryMatchGame%MemoryMatch:=nowUnix(), "settings\nm_config.ini", "Collect", "Last" MemoryMatchGame "MemoryMatch"
	}
}
nm_SolveMemoryMatch(MemoryMatchGame:="") {

	; initialize variables
	GetRobloxClientPos()
	middleX := windowX+(windowWidth//2)
	middleY := windowY+(windowHeight//2)

	switch MemoryMatchGame {
		case "Extreme","Winter":
		Xoffset := 40, Tiles := 20

		case "Normal","Mega","Night":
		Xoffset := 0, Tiles := 16

		default:
		pBMScreen := Gdip_BitmapFromScreen(middleX-250 "|" middleY-210 "|500|50")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["MMTitleWide"], , , , , , 8) = 1)
			Xoffset := 40, Tiles := 20
		else if (Gdip_ImageSearch(pBMScreen, bitmaps["MMTitle"], , , , , , 8) = 1)
			Xoffset := 0, Tiles := 16
		else {
			Gdip_DisposeImage(pBMScreen)
			return
		}
		Gdip_DisposeImage(pBMScreen)
	}

	StoreItemOAC := [], StoreItemOAC.Default := "", StoreItemOAC.Length := 20
	IgnoreItemOAC := [], IgnoreItemOAC.Default := 0, IgnoreItemOAC.Length := 20

	GridOAC:= [] ;Define MM Tile Coordinates
	Loop 5 {
		Xcord:=middleX-200+80*A_Index
		x:=A_index
		Loop 4 {
			row := []
			Ycord:=middleY-200+80*A_Index
			R:=A_index+(x-1)*4
			Row.push(Xcord)
			Row.push(Ycord)
			GridOAC.push(row)
		}
	}
	Tile:=0
	PriorityClaimedOAC:=0
	MMTempTile1OAC:=0
	MMTempTile2OAC:=0
	PairFoundOAC:=0
	MatchFoundOAC:=0
	ClickNum:=0
	Chances:=8
	LastChance:=0

	Loop 10 { ; Numer of available Chances.
		if(Chances=2) {
			Loop 1000 {
				pBMScreen := Gdip_BitmapFromScreen(middleX-275-Xoffset "|" middleY-146 "|100|100") ; Detect Number of Chances
				if(Gdip_ImageSearch(pBMScreen, bitmaps["Chances1"], , , , , , 10, , 2) = 1)  {
					LastChance := 1
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				sleep 10
			}
		}
		loop 2 { ;Click tile, store item and compare
			if(A_Index=1) {
				; Compare Tiles before Click 1
				loop Tiles {
					i:=A_index
					loop Tiles {
						j := A_index

						if (i = j)
							continue ; Skip self-comparison

						; Check if either variable is Null or Ignored
						if(StoreitemOAC[i] = 0 || StoreitemOAC[j] = 0 || IgnoreitemOAC[i] = 1 || IgnoreitemOAC[j] = 1 || StoreitemOAC[i] = "" || StoreitemOAC[j] = "")
							continue ; Skip the comparison if either Item is Null or Not Priority

						; Check if variables have the same value
						if (Gdip_ImageSearch(StoreitemOAC[i], StoreitemOAC[j], , , , , , 10, , 2)=1) {
							MMTempTile1OAC:=i
							MMTempTile2OAC:=j
							Gdip_DisposeImage(StoreitemOAC[i]), StoreitemOAC[i]:=0	;claimed
							Gdip_DisposeImage(StoreitemOAC[j]), StoreitemOAC[j]:=0	;claimed
							PairFoundOAC:=1
							Break 2
						} else {
							PairFoundOAC:=0
						}
					}
				}
				;end compare1
				if(PairFoundOAC) {
					LastTile:=Tile
					Tile:=MMTempTile1OAC ;-1
				}
			} else {
				if(PairFoundOAC=0 || LastChance=1) {
					; Compare all other tiles to click 1
					j:=Tile

					loop Tiles {
						i:=A_index

						if (i = Tile)
							continue ; Skip self-comparison

						; Check if either variable is Null or Ignored
						if(StoreitemOAC[i] = 0 || StoreitemOAC[j] = 0 || (IgnoreitemOAC[i] = 1 && LastChance!=1) || StoreitemOAC[i] = "" || StoreitemOAC[j] = "")
							continue ; Skip the comparison if either Item is Null or Not Priority

						; Check if Items are the same.
						if (Gdip_ImageSearch(StoreitemOAC[j], StoreitemOAC[i], , , , , , 10, , 2)=1) {
							MMTempTile2OAC:=i
							Gdip_DisposeImage(StoreitemOAC[i]), StoreitemOAC[i]:=0	;claimed
							Gdip_DisposeImage(StoreitemOAC[j]), StoreitemOAC[j]:=0	;claimed
							MatchFoundOAC:=1
							Break
						} else {
							MatchFoundOAC:=0
						}
					}
					;end compare2
					if(MatchFoundOAC) {
						LastTile:=Tile
						Tile:=MMTempTile2OAC
					}
				}
				if(PairFoundOAC)
					Tile:=MMTempTile2OAC
			}

			if(!MatchFoundOAC && !PairFoundOAC) {
				Loop 20 {
					Tile := Random(1, Tiles)
					If(StoreItemOAC[Tile]="")
						break
				}
			}
			;tile:=1
			TileXCordOAC:=GridOAC[Tile][1]-Xoffset ; Determine click coordinates
			TileYCordOAC:=GridOAC[Tile][2]
			ClickNum++
			MMItemOAC:=0

			MouseMove TileXCordOAC, TileYCordOAC
			sleep 400 ; I know this looks excessive, but it is to compensate for lag.
			sendinput "{click down}"
			sleep 100
			sendinput "{click up}"
			DllCall("GetSystemTimeAsFileTime", "int64p", &s:=0)
			sleep 100
			MouseMove middleX, middleY-190
			DllCall("GetSystemTimeAsFileTime", "int64p", &f:=s)
			Sleep Max(500 - (f - s)//10000, -1) ; match previous version's total sleep 500

			Loop 300 {
				pBMScreen := Gdip_BitmapFromScreen(TileXCordOAC-35 "|" TileYCordOAC-20 "|45|30") ; Detect Clicked Item
				;Gdip_SaveBitmapToFile(pBMScreen, "empty" A_index ".png")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["MMBorder"], , , , 8, 20, 1, , 2) = 1) {
					if (Gdip_ImageSearch(pBMScreen, bitmaps["MMEmptyTile"], , 25, 10, , , 1, , 2) != 1) {
						MMItemOAC := 1
						Gdip_DisposeImage(pBMScreen)
						break
					}
				}
				Gdip_DisposeImage(pBMScreen)
				sleep 10
			}
			Sleep 300

			if(MMItemOAC=1 && PairFoundOAC!=1 && (A_Index=1 || (A_Index=2 && MatchFoundOAC!=1))) {
				StoreItemOAC[Tile] := Gdip_BitmapFromScreen(TileXCordOAC-25 "|" TileYCordOAC-25 "|50|50") ; Detect Clicked Item
				;nm_CreateFolder(path := A_WorkingDir "\MMScreenshots"), Gdip_SaveBitmapToFile(StoreItemOAC[Tile], path "\image" Tile ".png") ; comment out this line for public release
				for item, data in MemoryMatch {
  					if ((MemoryMatchGame && (%item%MatchIgnore & MemoryMatchGames[MemoryMatchGame].bit)) || (!MemoryMatchGame && (%item%MatchIgnore = data.games))) {
						loop 2 {
							bitmap:="MM" . item . A_index
							if (Gdip_ImageSearch(StoreItemOAC[Tile], bitmaps[bitmap], , , , , , 10, , 2) = 1 && LastChance!=1) {
								IgnoreitemOAC[Tile]:=1
								Break 2
							}
						}
					}
				}
			}

			if(A_index=1) {
				pBMScreen := Gdip_BitmapFromScreen(middleX-275-Xoffset "|" middleY-146 "|100|100") ; Detect Number of Chances
				if (Gdip_ImageSearch(pBMScreen, bitmaps["Chances2"], , , , , , 10, , 2) = 1)
				Chances:=2
				Gdip_DisposeImage(pBMScreen)
			}

			if(A_Index=1) {
				Click1Tile:=Tile
				if(PairFoundOAC) {
					Tile:=MMTempTile2OAC
				}
			} else {
				if((Gdip_ImageSearch(StoreitemOAC[Click1Tile], StoreitemOAC[Tile], , , , , , 10, , 2) = 1) && PairFoundOAC!=1 && MatchFoundOAC!=1) {
					Gdip_DisposeImage(StoreitemOAC[Click1Tile]), StoreitemOAC[Click1Tile]:=0 ;"claimed"
					Gdip_DisposeImage(StoreitemOAC[Tile]), StoreitemOAC[Tile]:=0 ;"claimed"
					Continue
				}
				if(PairFoundOAC || MatchFoundOAC) {
					Tile:=LastTile
					if(PairFoundOAC)
						PairFoundOAC:=0
					if(MatchFoundOAC)
						MatchFoundOAC:=0
				}
			}

			if(A_Index=2 && LastChance=1)
				break 2
		} ;Close loop 2 Click tile, store item, and compare
	} ;close Chances Loop

	; dispose remnant bitmaps
	for pBM in StoreitemOAC
		IsSet(pBM) && IsInteger(pBM) && (pBM > 0) && Gdip_DisposeImage(pBM)

	MouseMove windowX+350, windowY+GetYOffset()+100
	Sleep 1200
	nm_setStatus("Collected", (MemoryMatchGame ? (MemoryMatchGame " ") : "") "Memory Match")

	; wait for window to close
	Loop 50 {
		pBMScreen := Gdip_BitmapFromScreen(middleX-250 "|" middleY-210 "|500|50")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["MMTitle"], , , , , , 8) = 0) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		Sleep 250
	}
}
nm_Honeystorm(fromSnowMachine:=0){
	global HoneystormCheck, LastHoneyStorm
	if (fromSnowMachine || (HoneystormCheck && (nowUnix()-LastHoneystorm)>14400)) { ;4 hours
		Loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			if (fromSnowMachine && (A_Index = 1)) {
				movement :=
				(
				nm_Walk(18, LeftKey) '
				' nm_Walk(7, RightKey) '
				' nm_Walk(11, FwdKey) '
				' nm_Walk(2, LeftKey) '
				Sleep 1000
				'
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T30 L"
				nm_endWalk()
			} else {
				nm_Reset()
				nm_setStatus("Traveling", "Honeystorm" ((A_Index > 1) ? " (Attempt 2)" : ""))

				nm_gotoCollect("honeystorm")
			}

			collected := 0
			If (HoneystormCheck && (nm_imgSearch("e_button.png",30,"high")[1] = 0)) {
				collected := 1
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				nm_setStatus("Collected", "Honeystorm")
				updateConfig()
			}

			if (fromSnowMachine || collected) {
				movement :=
				(
				nm_Walk(11, FwdKey) '
				loop 2 {
					loop 3 {
					' nm_Walk(20, LeftKey) '
					' nm_Walk(3, FwdKey) '
					' nm_Walk(20, RightKey) '
					' nm_Walk(3, FwdKey) '
					}
					' nm_Walk(1.5, FwdKey) '
					loop 3 {
					' nm_Walk(20, LeftKey) '
					' nm_Walk(3, BackKey) '
					' nm_Walk(20, RightKey) '
					' nm_Walk(3, BackKey) '
					}
				}'
				)

				if(!DisableToolUse)
					Click "Down"
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T35 L"
				nm_endWalk()
				Click "Up"

				if (!collected && HoneystormCheck) ;try again if Honeystorm collection failed but enabled
					continue
				else
					break
			}
		}
		(HoneystormCheck) && updateConfig()
	}
	updateConfig() {
		LastHoneystorm:=nowUnix()
		IniWrite LastHoneystorm, "settings\nm_config.ini", "Collect", "LastHoneystorm"
	}
}
nm_HoneyLB(){ ;Daily Honey LB
	global HoneySSCheck
	static LastHoneyLB:=1
	if (HoneySSCheck) {
		utc_hour := FormatTime(A_NowUTC, "H")
		if ((utc_hour = 4) && (nowUnix()-LastHoneyLB)>3600) {
			nm_Reset()
			nm_setStatus("Traveling", "Daily Honey LB")
			nm_gotoCollect("honeylb")
			FormatStr := Buffer(256), DllCall("GetLocaleInfoEx", "Ptr",0, "UInt",0x20, "Ptr",FormatStr.Ptr, "Int",256)
			DateStr := Buffer(512), DllCall("GetDateFormatEx", "Ptr",0, "UInt",0, "Ptr",0, "Ptr",FormatStr.Ptr, "Ptr",DateStr.Ptr, "Int",512, "Ptr",0)
			nm_setStatus("Reporting", "Daily Honey LB`nDate: " StrGet(DateStr))
			LastHoneyLB:=nowUnix()
		}
	}
}
nm_StickerPrinter(){
	global StickerPrinterCheck, LastStickerPrinter, StickerPrinterEgg

	If (StickerPrinterCheck && (nowUnix()-LastStickerPrinter)>3600) { ;1 hour
		loop 2 {
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			nm_updateAction("Collect")

			nm_Reset()
			nm_setStatus("Traveling", "Sticker Printer" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("stickerprinter")
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep 500 ;//todo: wait for GUI with timeout instead of fixed time
				GetRobloxClientPos()
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2+150 "|" windowY+4*windowHeight//10+160 "|100|60")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerprinterCD"], , , , , , 10) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Sticker Printer on Cooldown")
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Gdip_DisposeImage(pBMScreen)
				pos := Map("basic",-95, "silver",-40, "gold",15, "diamond",70, "mythic",125)
				MouseMove windowX+windowWidth//2+pos[StrLower(StickerPrinterEgg)], windowY+4*windowHeight//10-20
				Sleep 200
				Click
				Sleep 200
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2+150 "|" windowY+4*windowHeight//10+160 "|100|60")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerprinterConfirm"], , , , , , 10) != 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Error", "No Eggs left in inventory!`nSticker Printer has been disabled.")
					StickerPrinterCheck := 0
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX+windowWidth//2+225, windowY+4*windowHeight//10+195
				Sleep 200
				Click
				i := 0
				loop 16 {
					sleep 250
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)-50, windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
						sleep 150
						Click
						sleep 100
						i++
					} else if (i > 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					if (A_Index = 16)
						break
				}
				Sleep 8000 ; wait for printer to print
				nm_setStatus("Collected", "Sticker Printer (" StickerPrinterEgg " Egg)")
				break
			}
		}
		if (StickerPrinterCheck = 1) {
			LastStickerPrinter:=nowUnix()
			IniWrite LastStickerPrinter, "settings\nm_config.ini", "Collect", "LastStickerPrinter"
		}
	}
}

;//todo: pending rewrite of detections?
nm_Boost(){
	if(VBState=1 || nm_MondoInterrupt())
		return

	nm_StickerStack()

	if ((QuestBoostCheck = 0) && QuestGatherField && (QuestGatherField != "None"))
		return
	try
		if (nm_PBoost() = 1)
			return
	nm_shrine()
	nm_toAnyBooster()
}
nm_StickerStack(){
	global StickerStackCheck, LastStickerStack, StickerStackItem, StickerStackMode, StickerStackTimer, StickerStackHive, StickerStackCub, StickerStackVoucher, SC_E, bitmaps

	if (StickerStackCheck && (nowUnix()-LastStickerStack)>StickerStackTimer) {
		loop 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Sticker Stack" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("stickerstack")
			GetRobloxClientPos()

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				sleep 500 ;//todo: wait for GUI with timeout instead of fixed time

				; detect stack boost time
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-275 "|" windowY+4*windowHeight//10 "|550|220")
				Loop 1 {
					if (Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][")"], &pos, 275, , , 45, 20) = 1) {
						x := SubStr(pos, 1, InStr(pos, ",")-1)
						(digits := Map()).Default := ""
						Loop 10 {
							n := 10-A_Index
							Gdip_ImageSearch(pBMScreen, bitmaps["stickerstackdigits"][n], &pos, x, , , 45, 20, , , 4, , "`n")
							Loop Parse pos, "`n"
								if (A_Index & 1)
									digits[Integer(A_LoopField)] := n
						}

						num := ""
						for x,y in digits
							num .= y

						if ((StrLen(num) = 4) && (SubStr(num, 4) = "0")) { ; check valid time before updating
							nm_setStatus("Detected", "Stack Boost Time: " hmsFromSeconds(time := 60 * SubStr(num, 1, 2) + SubStr(num, 3)))
							if (StickerStackMode = 0)
								StickerStackTimer := time
							break
						}
					}
					nm_setStatus("Error", "Unable to detect Stack Boost time!")
				}

				; check if sticker is available to donate
				if (InStr(StickerStackItem, "Sticker") && (((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormal"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((Gdip_ImageSearch(pBMScreen, bitmaps["stickernormalalt"], &pos, , , 275, , 25) = 1) && (stack := "Sticker"))
					|| ((StickerStackHive = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickerhive"], &pos, , , 275, , 25) = 1) && (stack := "Hive Skin"))
					|| ((StickerStackCub = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickercub"], &pos, , , 275, , 25) = 1) && (stack := "Cub Skin"))
					|| ((StickerStackVoucher = 1) && (Gdip_ImageSearch(pBMScreen, bitmaps["stickervoucher"], &pos, , , 275, , 25) = 1) && (stack := "Voucher")))) {
					nm_setStatus("Stacking", stack)
					MouseMove windowX+windowWidth//2-275+SubStr(pos, 1, InStr(pos, ",")-1)+26, windowY+4*windowHeight//10+SubStr(pos, InStr(pos, ",")+1)-10 ; select sticker
					if (StickerStackMode = 0)
						StickerStackTimer += 10
				} else if InStr(StickerStackItem, "Tickets") {
					nm_setStatus("Stacking", stack := "Tickets")
					MouseMove windowX+windowWidth//2+105, windowY+4*windowHeight//10-78 ; select tickets
				} else { ; StickerStackItem = "Sticker", and nosticker was found or error
					nm_setStatus("Error", "No Stickers left to stack!`nSticker Stack has been disabled.")
					StickerStackCheck := 0
					Sleep 500
					sendinput "{" SC_E " down}"
					Sleep 100
					sendinput "{" SC_E " up}"
					break
				}
				Sleep 100
				Click
				Gdip_DisposeImage(pBMScreen)

				i := 0
				loop 16 {
					sleep 250
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
					if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
						MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1)-50, windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
						sleep 150
						Click
						sleep 100
						; voucher separate for aesthetic
						if ((++i >= 4) && !InStr(stack, "Skin") && !(stack="Voucher")) { ; Yes/No prompt appeared too many times, assume this is not a regular sticker
							Gdip_DisposeImage(pBMScreen)
							nm_setStatus("Error", "Yes/No appeared too many times!")
							Sleep 500
							sendinput "{" SC_E " down}"
							Sleep 100
							sendinput "{" SC_E " up}"
							break 2
						}
					} else if (i > 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					} else if (A_Index = 16) {
						Gdip_DisposeImage(pBMScreen)
						nm_setStatus("Error", "No Tickets left to use!`nSticker Stack has been disabled.")
						StickerStackCheck := 0
						Sleep 500
						sendinput "{" SC_E " down}"
						Sleep 100
						sendinput "{" SC_E " up}"
						break 2
					}
					Gdip_DisposeImage(pBMScreen)
				}
				Sleep 2000
				nm_SetStatus("Collected", "Sticker Stack")
				break
			}
		}
		if (StickerStackCheck = 1) {
			LastStickerStack:=nowUnix()
			IniWrite LastStickerStack, "settings\nm_config.ini", "Boost", "LastStickerStack"
			if (StickerStackMode = 0) {
				MainGui["StickerStackTimer"].Value := StickerStackTimer
				IniWrite StickerStackTimer, "settings\nm_config.ini", "Boost", "StickerStackTimer"
			}
		}
	}
}
nm_shrine(){
	global GatherFieldBoostedStart, LastGlitter, VBState, LastShrine, ShrineCheck, ShrineItem1, ShrineItem2, ShrineAmount1, ShrineAmount2, ShrineIndex1, ShrineIndex2, ShrineRot

	nm_ShrineRotation() ; make sure ShrineRot hasnt changed
	if (ShrineCheck && (nowUnix()-LastShrine)>3600) { ;1 hour
		loop 2 {
			z := A_Index
			nm_Reset()
			nm_setStatus("Traveling", "Wind Shrine" ((A_Index > 1) ? " (Attempt 2)" : ""))

			nm_gotoCollect("WindShrine")

			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sendinput "{" SC_E " down}"
				Sleep 100
				sendinput "{" SC_E " up}"
				Sleep (2000+KeyDelay)

				GetRobloxClientPos(hwnd := GetRobloxHWND())
				MouseMove windowX+windowWidth//2, windowY+Floor(0.74*windowHeight) - 5 ;dialog
				sleep 150
				Click
				sleep 300
				Loop {
					sleep 150
					pBMScreen := Gdip_BitmapFromScreen(WindowX+Floor(0.515*windowWidth)-250 "|" windowY+Floor(0.535*windowHeight)-100 "|500|300")
					Donation := %("ShrineItem" ShrineRot)%

					if (Gdip_ImageSearch(pBMScreen, Shrine[Donation], , , , , , 2, , 4) > 0) {
						sleep 200
						MouseMove windowX+Floor(0.515*windowWidth)+157, windowY+Floor(0.535*windowHeight)+40 ; add more of x item
						sleep 150
						While (A_index < ShrineAmount%ShrineRot%) {
							Click
							sleep 35
						}
						sleep 300
						MouseMove windowX+Floor(0.515*windowWidth)-72, windowY+Floor(0.535*windowHeight)+116 ; donate button
						Gdip_DisposeImage(pBMScreen)
						sleep 150
						Click
						sleep 2000
						GetRobloxClientPos(hwnd)
						Loop 500 {
							pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
							if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
								Gdip_DisposeImage(pBMScreen)
								break
							}
							Gdip_DisposeImage(pBMScreen)
							MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
							Click
							sleep 150
						}
						sleep 500
						gatherloot :=
						(
							nm_Walk(7, RightKey, FwdKey) "
							" nm_Walk(10, FwdKey) "
							" nm_Walk(10, FwdKey, RightKey) "
							" nm_Walk(7, BackKey) "
							" nm_Walk(2, RightKey) "
							" nm_Walk(3.75, BackKey) "
							" nm_Walk(3, LeftKey) "
							loop 4 {
							" nm_Walk(5, LeftKey) "
							" nm_Walk(1.5, BackKey) "
							" nm_Walk(5, RightKey) "
							" nm_Walk(1.5, BackKey) "
							}
							loop 2 {
							" nm_Walk(15, LeftKey) "
							" nm_Walk(1, FwdKey) "
							" nm_Walk(15, RightKey) "
							" nm_Walk(1, FwdKey) "
							}
							" nm_Walk(15, LeftKey) "
							loop 4 {
							" nm_Walk(1.5, FwdKey) "
							" nm_Walk(5, RightKey) "
							" nm_Walk(1.5, FwdKey) "
							" nm_Walk(5, LeftKey) "
							}"
						)
						nm_createWalk(gatherloot)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						nm_SetStatus("Collected", "Wind Shrine")

						if (ShrineIndex%ShrineRot% != "Infinite")  {
							ShrineIndex%shrineRot%-- ;subtract from shrineindex for looping only if its a number
							MainGui["ShrineData" ShrineRot].Text := "(" ShrineAmount%ShrineRot% ") [" ((ShrineIndex%ShrineRot% = "Infinite") ? "∞" : ShrineIndex%ShrineRot%) "]"
							IniWrite ShrineIndex%ShrineRot%, "settings\nm_config.ini", "Shrine", "ShrineIndex" ShrineRot
						}
						ShrineRot := Mod(ShrineRot, 2) + 1 ; determine Shrinerot
						nm_ShrineRotation()

						break 2
					} else {
						MouseMove windowX+Floor(0.515*windowWidth)+157, WindowY+Floor(0.535*windowHeight)-45
						sleep 150
						click
						Gdip_DisposeImage(pBMScreen)
						if (A_Index = 60) {
							if (z = 2)
								nm_setStatus("Failed", "Wind shrine")
							break
						}
						sleep 100
					}
				}
			}
		}
		LastShrine := nowUnix()
		IniWrite LastShrine, "settings\nm_config.ini", "Shrine", "LastShrine"
		IniWrite ShrineRot, "settings\nm_config.ini", "Shrine", "ShrineRot"
	}
}
nm_ShrineRotation() {
	global ShrineRot, ShrineItem1, ShrineItem2, ShrineCheck, ShrineIndex1, ShrineIndex2
	loop {
		if ((ShrineItem%ShrineRot% != "None" && ShrineItem%ShrineRot% != "") && (ShrineIndex%ShrineRot% = "Infinite" || ShrineIndex%ShrineRot% > 0)) {
			ShrineCheck := 1
			IniWrite 1, "settings\nm_config.ini", "Shrine", "ShrineCheck"
			break
		} else {
			ShrineRot := Mod(ShrineRot, 2) + 1
			if (A_Index = 3) {
				if (ShrineCheck) {
					ShrineCheck := 0
					IniWrite 0, "settings\nm_config.ini", "Shrine", "ShrineCheck"
					nm_setStatus("Confirmed", "No more items to rotate through. Turning shrine off")
				}
				break
			}
		}
	}
}
nm_toAnyBooster(){	
	global LastBooster

	; prioritise coconut every 4 hours if enabled
	if((BoostChaserCheck && CoconutBoosterCheck && CoconutDisCheck) && (BoosterCooldown("coconut") && LastBoosterCheck()))
		nm_updateAction("Booster"), nm_toBooster("coconut")

	; other
	eligible := [], available := 0
	while(A_Index < 4 && (FieldBooster%A_Index%!="none" || QuestBlueBoost || QuestRedBoost))
	{
		i := A_Index
		for name in ["Red", "Blue", "Mountain"]
		{
			if (FieldBooster%i% = name) || ((name = "Red" || name = "Blue") && Quest%name%Boost)
			{
				loop 2
					if eligible.Length >= A_Index && eligible[A_Index][1] = name
						continue 2

				if BoosterCooldown(name) && LastBoosterCheck() 
					eligible.Push([name, "available"]), available++ 
				else
					eligible.Push([name, "unavailable"])
			}
		}
	}
	; ensure rotation through all available boosters, even if earlier one comes off cool-down
	if available > 0
	{
		loop 1 
		{
			if IsSet(LastBooster) 
			{
				loop eligible.Length
				{
					i := A_Index
					if eligible[i][1] = LastBooster 
					{
						loop eligible.Length
						{
							i := (i < eligible.Length) ? i+1 : 1
							if eligible[i][2] = "available"
							{
								next := eligible[i][1] 
								break 3
							}
						}
						break 
					}
				}
			}
			; otherwise default to first available, for session start and as failsafe
			loop eligible.Length 
				if eligible[A_Index][2] = "available" 
				{
					next := eligible[A_Index][1]
					break 2
				}
		}
		LastBooster := next	
		nm_updateAction("Booster"), nm_toBooster(next)
	}
	LastBoosterCheck() => ((nowUnix()-max(LastBlueBoost, LastRedBoost, LastMountainBoost, (BoostChaserCheck && CoconutBoosterCheck && CoconutDisCheck) ? LastCoconutDis : 1))>(FieldBoosterMins*60))
	BoosterCooldown(booster) => (booster = "coconut" ? ((nowUnix()-LastCoconutDis)>14400) : (nowUnix()-Last%booster%Boost)>2700)
}
nm_toBooster(location){
	global LastBlueBoost, LastRedBoost, LastMountainBoost, LastCoconutDis, RecentFBoost
	static blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower", "Stump"], redBoosterFields:=["Rose", "Strawberry", "Mushroom", "Pepper"], mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"], coconutBoosterfields:=["Coconut"]
	
	Loop 2 {
		nm_Reset(0)
		nm_setStatus("Traveling", ((location="Mountain") ? "Mountain Top Booster" : StrTitle(location) " Field Booster") . ((A_Index=2) ? " (Attempt 2)" : ""))
		(location="coconut") ? (nm_gotoCollect("coconutdis")) : (nm_gotoBooster(location))
		if (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
			sendinput "{" SC_E " down}"
			Sleep 100
			sendinput "{" SC_E " up}"
			Sleep 1000
			If (location = "coconut")
				LastCoconutDis:=nowUnix(), IniWrite(LastCoconutDis, "settings\nm_config.ini", "Collect", "LastCoconutDis")
			else
				Last%location%Boost:=nowUnix(), IniWrite(Last%location%Boost, "settings\nm_config.ini", "Collect", "Last" location "Boost")
			
			nm_createWalk((location = "mountain") ? nm_Walk(8, LeftKey) : (location = "red") ? nm_Walk(8, BackKey) : nm_Walk(8, RightKey))
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T10 L"
			nm_endWalk()
			if location = "red"
				nm_Move(2000*round(18/MoveSpeedNum, 3), FwdKey, RightKey) ; red needs additional steps to avoid the leaderboard area
			Loop 10 {
				for k,v in %location%BoosterFields {
					if nm_fieldBoostCheck(v, 1)
					{
						nm_setStatus("Boosted", v), RecentFBoost := v
						break 2
					}

				}
				
				sleep 200
				If A_Index = 10 
					nm_setStatus("Failed", "Could not find field boost!")
			} 
			break
		}
		else if (A_Index = 2)
		{
			If (location = "coconut") {
				LastCoconutDis:=nowUnix()-7200
				IniWrite LastCoconutDis, "settings\nm_config.ini", "Collect", "LastCoconutDis"
			} else {
				Last%location%Boost:=nowUnix()-1500
				IniWrite Last%location%Boost, "settings\nm_config.ini", "Collect", "Last" location "Boost"
			}
		}
	}
}

;;;;;;;;; START AFB
nm_AutoFieldBoost(fieldName){
	global FieldBooster, AFBrollingDice, AFBuseGlitter, AFBuseBooster, serverStart, AutoFieldBoostActive
		, FieldLastBoosted, FieldLastBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh, AFBHoursLimitEnable
		, AFBHoursLimit, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, MainGui, AFBGui
		, LastBlueBoost, LastRedBoost, LastMountainBoost

	if(not AutoFieldBoostActive)
		return
	if(AFBHoursLimitEnable && (nowUnix()-serverStart)>(AFBHoursLimit*60*60)){
		MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
		try AFBGui["AutoFieldBoostActive"].Value := 0
		IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		return
	}

	if(not AFBrollingDice && ((nowUnix()-FieldLastBoosted)>(AutoFieldBoostRefresh*60) || (nowUnix()-FieldLastBoosted)<0)){ ;refresh period exceeded
		;check for field boost stack reset
		if((nowUnix()-FieldLastBoosted)>=(15*60)){ ;longer than 15 mins since last boost buff
			IniWrite FieldBoostStacks:=0, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
			IniWrite FieldLastBoostedBy:="None", "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		}
		;free booster first
		if(AFBFieldEnable){
			;determine which booster applies
			if((booster := FieldBooster[StrLower(fieldName)].booster)!="none") {
				boosterTimer := Last%booster%Boost
				if (nowUnix() - boosterTimer > 2700){
					AFBuseBooster:=1
				}
			}
		}
		;dice next
		if(AFBDiceEnable && not AFBrollingDice && (FieldLastBoostedBy="none" || FieldLastBoostedBy="glitter" || FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"
			|| (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
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

	GetRobloxClientPos(hwnd:=GetRobloxHWND())
	pBMScreen:=Gdip_BitmapFromScreen(windowX "|" windowY + GetYOffset(hwnd) + 36 "|" windowWidth "|" 38)
	loop Floor(windowWidth/38) ; flooring because you won't have half of an icon
	{ 
		ico:=(A_Index-1)*38
		if (Gdip_ImageSearch(pBMScreen, bitmaps["boost"][StrReplace(fieldName, " ") variant],,ico,,ico+38,,(variant=1 || variant=0) ? 35 : 50)) ; testing tighter variation
		{ ; check with original 30 not 35
			p:=PixelGetColor(ico+windowX, windowY+GetYOffset(hwnd)+73)
			if ((p & 0xFF0000 >= 0xa60000) && (p & 0xFF0000 <= 0xcf0000)) ; a6b2b8-blackBG|cfdbe1-whiteBG
			&& ((p & 0x00FF00 >= 0x00b200) && (p & 0x00FF00 <= 0x00db00))
			&& ((p & 0x0000FF >= 0x0000b8) && (p & 0x0000FF <= 0x0000e1))
				continue ; winds: keep searching, winds and booster may both have boosted the field
			else if ((p & 0xFF0000 >= 0xb80000) && (p & 0xFF0000 <= 0xe10000)) ; b8a43a-blackBG|e1cd63-whiteBG
				&& ((p & 0x00FF00 >= 0x00a400) && (p & 0x00FF00 <= 0x00cd00))
				&& ((p & 0x0000FF >= 0x00003a) && (p & 0x0000FF <= 0x000063)) 
				{
					Gdip_DisposeImage(pBMScreen)
					return 1 ; booster
				}	
		}
	}
	Gdip_DisposeImage(pBMScreen)
	return 0

}
nm_fieldBoostBooster(){
	global CurrentField, FieldBooster, AFBuseBooster, FieldLastBoosted, FieldBoostStacks, FieldLastBoostedBy, FieldNextBoostedBy, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, FieldBoostStacks
	if (!AFBuseBooster)
		return
	nm_setStatus(0, "Boosting Field: Booster")
	booster := FieldBooster[StrLower(CurrentField)].booster
	if(booster="blue") {
		boosterName:="bbooster"
		nm_toBooster("blue")
	}
	else if(booster="red") {
		boosterName:="rbooster"
		nm_toBooster("red")
	}
	else if(booster="mountain") {
		boosterName:="mbooster"
		nm_toBooster("mountain")
	}
	AFBuseBooster:=0
	Sleep 5000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Booster")
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:=boosterName
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		FieldBoostStacks:=FieldBoostStacks+FieldBooster[StrLower(CurrentField)].stacks
		IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		if(FieldBoostStacks>4)
			return
	}
	;determine next boost item
	;is it dice?
	if(AFBDiceEnable && (FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"|| FieldLastBoostedBy="glitter" || (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
		FieldNextBoostedBy:="dice"
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
	;is it glitter?
	else if(AFBGlitterEnable && (FieldLastBoostedBy="dice" || ((FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")|| not AFBDiceEnable) || (FieldLastBoostedBy="glitter" && not AFBDiceEnable))) {
		FieldNextBoostedBy:="glitter"
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
	;is it booster?
	else if(AFBFieldEnable && not AFBDiceEnable && not AFBGlitterEnable) {
		FieldNextBoostedBy:=boosterName
		IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
	}
}
nm_fieldBoostDice(){
	global AFBrollingDice, AFBdiceUsed, AFBDiceLimit, AFBDiceLimitEnable, CurrentField, FieldBooster, boostTimer
		, FieldLastBoosted, FieldLastBoostedBy, FieldNextBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh
		, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, AFBDiceHotbar, MainGui, AFBGui
	if(not nm_fieldBoostCheck(CurrentField)) {
		send "{sc00" AFBDiceHotbar+1 "}"
		AFBdiceUsed:=AFBdiceUsed+1
		IniWrite AFBdiceUsed, "settings\nm_config.ini", "Boost", "AFBdiceUsed"
		if(AFBDiceLimitEnable && AFBdiceUsed >= AFBDiceLimit) {
			AFBrollingDice:=0
			try AFBGui["AFBDiceEnable"].Value := 0
			IniWrite AFBDiceEnable := 0, "settings\nm_config.ini", "Boost", "AFBDiceEnable"
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			try AFBGui["AutoFieldBoostActive"].Value := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
			IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		}
	} else {
		AFBrollingDice:=0
		nm_setStatus(0, "Field was Boosted: Dice")
		if(FieldLastBoostedBy!="dice" || FieldBoostStacks=0) {
			FieldBoostStacks:=FieldBoostStacks+1
			FieldLastBoostedBy:="dice"
			IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
			IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		}
		FieldLastBoosted:=nowUnix()
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		;determine next boost item
		;is it booster?
		booster := FieldBooster[StrLower(CurrentField)].booster
		if(booster="blue") {
			boosterName:="bbooster"
			boostTimer := LastBlueBoost
		}
		else if(booster="red") {
			boosterName:="rbooster"
			boostTimer := LastRedBoost
		}
		else if(booster="mountain") {
			boosterName:="mbooster"
			boostTimer := LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it glitter?
		else if(AFBGlitterEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it dice?
		else if(not AFBGlitterEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
	}
}
nm_fieldBoostGlitter(){
	global AFBuseGlitter, AFBglitterUsed, CurrentField, FieldBooster, boostTimer, FieldLastBoosted, FieldLastBoostedBy, FieldNextBoostedBy, FieldBoostStacks
		, AutoFieldBoostRefresh, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable, AFBdiceHotbar, AFBGlitterHotbar, AFBGlitterLimit, AFBGlitterLimitEnable
	if(not AFBuseGlitter)
		return
	send "{sc00" AFBGlitterHotbar+1 "}"
	Sleep 2000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Glitter")
		AFBglitterUsed:=AFBglitterUsed+1
		IniWrite AFBglitterUsed, "settings\nm_config.ini", "Boost", "AFBglitterUsed"
		if(AFBGlitterLimitEnable && AFBglitterUsed >= AFBglitterLimit) {
			try AFBGui["AFBGlitterEnable"].Value := 0
			IniWrite AFBGlitterEnable := 0, "settings\nm_config.ini", "Boost", "AFBGlitterEnable"
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			try AFBGui["AutoFieldBoostActive"].Value := 0
			MainGui["AutoFieldBoostButton"].Text := "Auto Field Boost`n[OFF]"
			IniWrite AutoFieldBoostActive := 0, "settings\nm_config.ini", "Boost", "AutoFieldBoostActive"
		}
		AFBuseGlitter:=0
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:="glitter"
		IniWrite FieldLastBoosted, "settings\nm_config.ini", "Boost", "FieldLastBoosted"
		IniWrite FieldLastBoostedBy, "settings\nm_config.ini", "Boost", "FieldLastBoostedBy"
		FieldBoostStacks:=FieldBoostStacks+1
		IniWrite FieldBoostStacks, "settings\nm_config.ini", "Boost", "FieldBoostStacks"
		;determine next boost item
		;is it booster?
		booster := FieldBooster[StrLower(CurrentField)].booster
		if(booster="blue") {
			boosterName:="bbooster"
			boostTimer := LastBlueBoost
		}
		else if(booster="red") {
			boosterName:="rbooster"
			boostTimer := LastRedBoost
		}
		else if(booster="mountain") {
			boosterName:="mbooster"
			boostTimer := LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it dice?
		else if(AFBDiceEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}
		;is it glitter?
		else if(not AFBDiceEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite FieldNextBoostedBy, "settings\nm_config.ini", "Boost", "FieldNextBoostedBy"
		}

	}
}
;;;;;;;;; END AFB

;//todo: pending rewrite! health detection bugs, generally inefficient
nm_Bugrun(){
	global youDied, VBState, MoveMethod, MoveSpeedNum, currentWalk, objective, HiveBees, MonsterRespawnTime, DisableToolUse
		, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
		, BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll
		, GatherFieldBoostedStart, LastGlitter
		, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff
		, BugrunSpiderCheck, BugrunSpiderLoot, LastBugrunSpider
		, BugrunLadybugsCheck, BugrunLadybugsLoot, LastBugrunLadybugs
		, BugrunRhinoBeetlesCheck, BugrunRhinoBeetlesLoot, LastBugrunRhinoBeetles
		, BugrunMantisCheck, BugrunMantisLoot, LastBugrunMantis
		, BugrunWerewolfCheck, BugrunWerewolfLoot, LastBugrunWerewolf
		, BugrunScorpionsCheck, BugrunScorpionsLoot, LastBugrunScorpions
		, intialHealthCheck
		, CocoCrabCheck, LastCocoCrab
		, StumpSnailCheck, LastStumpSnail
		, CommandoCheck, LastCommando
		, TunnelBearCheck, TunnelBearBabyCheck
		, KingBeetleCheck, KingBeetleBabyCheck
		, LastTunnelBear, LastKingBeetle
		, InputSnailHealth, SnailTime
		, InputChickHealth, ChickTime
		, SprinklerType
		, TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills
		, KingBeetleAmuletMode, ShellAmuletMode

	;interrupts
	if ((VBState=1) || nm_MondoInterrupt() || nm_GatherBoostInterrupt() || nm_BeesmasInterrupt() || nm_MemoryMatchInterrupt())
		return

	nm_setShiftLock(0)
	bypass:=0
	MoveSpeedFactor := round(18/MoveSpeedNum, 2)
	if(((BugrunSpiderCheck || QuestSpider || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) && HiveBees>=5){ ;30 minutes
		nm_updateAction("Bugrun")
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
				nm_gotoField(BugRunField)
				found:=0
				Loop 20
				{
					spiderBug:=nm_HealthDetection()
					if(spiderBug.Length > 0)
					{
						found:= 1
						break
					}
					Sleep 150
				}
				if (found)
				{
					nm_setStatus("Attacking", "Spider")
					;Send "{" SC_1 "}"
					SendInput "{" RotUp " 4}"
					if(!DisableToolUse)
						Click "Down"
					r := 0
					Loop 30
					{ ;wait to kill
						if(A_Index=30)
							success:=1
						Loop 20
						{
							spiderDead:=nm_HealthDetection()
							if(spiderDead.Length > 0)
								Break
							if (A_Index=10)
							{
								SendInput "{" RotLeft " 2}"
								r := 1
							}
							SendInput "{" ZoomOut "}"
							Sleep 100
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
					}
					sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					Sleep 500
					Click "Up"
					if(VBState=1)
						return
				}
			}
			LastBugrunSpider:=nowUnix()
			IniWrite LastBugrunSpider, "settings\nm_config.ini", "Collect", "LastBugrunSpider"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
			if(BugrunSpiderLoot){
				if(!DisableToolUse)
					Click "Down"
				nm_setStatus("Looting", "Spider")
				movement :=
				(
				nm_Walk(3, RightKey) "
				loop 3 {
					" nm_Walk(9, FwdKey) "
					" nm_Walk(1.5, LeftKey) "
					" nm_Walk(9, BackKey) "
					" nm_Walk(1.5, LeftKey) "
				}
				" nm_Walk(6, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()
				Click "Up"
			}
			if(VBState=1)
				return
			;head to ladybugs?
			if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))) {
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Strawberry)")
				movement :=
				(
				((BugrunSpiderLoot=0) ? (nm_Walk(4.5, BackKey) "`r`n" nm_Walk(4.5, LeftKey)) : "") "
				" nm_Walk(30, LeftKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()
				SendInput "{" RotLeft " 2}"
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
						nm_gotoField(BugRunField)
						Sleep 1000
					}
					bypass:=0
					;(+) new detection
					found:=0
					loop 20
					{
						strawBug:=nm_HealthDetection()
						if(strawBug.Length > 0)
						{
							found:= 1
							break
						}
						Sleep 150
					}
					if (found)
					{
						nm_setStatus("Attacking", "Ladybugs (Strawberry)")
						SendInput "{" RotUp " 4}"
						;Send "{" SC_1 "}"
						if(!DisableToolUse)
							Click "Down"
						r := 0
						loop 10
						{ ;wait to kill
							if(A_Index=10)
								success:=1
							Loop 10
							{
								ladybugDead:=nm_HealthDetection()
								if(ladybugDead.Length > 0)
									Break
								if (A_Index=5)
								{
									SendInput "{" RotLeft " 2}"
									r := 1
								}
								Sleep 100
								SendInput "{" ZoomOut "}"
								if (A_Index=10)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
						}
						sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						Sleep 500
						Click "Up"
						if(VBState=1)
							return
					}
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
				IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
				IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
				if(BugrunLadybugsLoot){
					if(!DisableToolUse)
						Click "Down"
					nm_setStatus("Looting", "Ladybugs (Strawberry)")
					movement :=
					(
					nm_Walk(2, BackKey) "
					" nm_Walk(8, RightKey, BackKey) "
					loop 2 {
						" nm_Walk(14, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(14, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(14, FwdKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
					Click "Up"
				}
				if(VBState=1)
					return
				;mushroom
				BugRunField:="mushroom"
				success:=0
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Mushroom)")
				movement :=
				(
				nm_Walk(12, LeftKey) "
				" nm_Walk(16, BackKey) "
				" nm_Walk(16, BackKey, LeftKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
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
					nm_gotoField(BugRunField)
					SendInput "{" RotLeft " 2}"
				}
				bypass:=0
				found:=0
				loop 20
				{
					mushBug:=nm_HealthDetection()
					if(mushBug.Length > 0)
					{
						found:= 1
						break
					}
					Sleep 150
				}
				if(found)
				{
					nm_setStatus("Attacking", "Ladybugs (Mushroom)")
					;Send "{" SC_1 "}"
					SendInput "{" RotUp " 4}"
					if(!DisableToolUse)
						Click "Down"
					r := 0
					loop 10 { ;wait to kill
						if(A_Index=10)
							success:=1
						Loop 20
						{
							ladybugDead:=nm_HealthDetection()
							if(ladybugDead.Length > 0)
								Break
							if (A_Index=10)
							{
								SendInput "{" RotLeft " 2}"
								r := 1
							}
							Sleep 100
							SendInput "{" ZoomOut "}"
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
					}
					sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					Sleep 500
					Click "Up"
					if(VBState=1)
					{
						return
					}
				}
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
			if(BugrunLadybugsLoot){
				if(!DisableToolUse)
					Click "Down"
				nm_setStatus("Looting", "Ladybugs (Mushroom)")
				movement :=
				(
				nm_Walk(5, RightKey, BackKey) "
				" nm_Walk(2, RightKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()
				nm_loot(9, 4, "left", 1)
				Click "Up"
			}
		}
	}
	if(VBState=1)
		return
	nm_Mondo()
	;Ladybugs and/or Rhino Beetles
	if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))
		|| ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){ ;5 minutes
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
					nm_gotoField(BugRunField)
				}
				bypass:=0
				found:=0
				loop 20
				{
					cloverBug:=nm_HealthDetection()
					if(cloverBug.Length > 0)
					{
						found:= 1
						break
					}
					Sleep 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					;Send "{" SC_1 "}"
					SendInput "{" RotUp " 4}"
					if(!DisableToolUse)
						Click "Down"
					loop 10 { ;wait to kill
						if(A_Index=10)
							success:=1
						Loop 10
						{
							cloverDead:=nm_HealthDetection()
							if(cloverDead.Length > 0)
								Break
							else if (A_Index=10)
							{
								success:=1
								break 2
							}
							Sleep 250
						}
						if(youDied)
							break
					}
					SendInput "{" RotDown " 4}"
					click "up"
					if(VBState=1)
						return
				}

			}
			;done with ladybugs
			LastBugrunLadybugs:=nowUnix()
			IniWrite LastBugrunLadybugs, "settings\nm_config.ini", "Collect", "LastBugrunLadybugs"
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
			;loot
			if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && BugrunLadybugsLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && BugrunRhinoBeetlesLoot)){
				if(!DisableToolUse)
					Click "Down"
				nm_setStatus("Looting")
				movement :=
				(
				nm_Walk(4, RightKey) "
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
				}"
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()
				Click "Up"
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
				Sleep 5000
				BugRunField:="blue flower"
				nm_setStatus("Traveling", "Rhino Beetles (Blue Flower)")
				movement :=
				(
				nm_Walk(18, BackKey) '
				send "{' RotLeft ' 2}"
				' nm_Walk(10, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T30 L"
				nm_endWalk()
			}
			else {
				BugRunField:="blue flower"
				wait:=min(5000, (50-HiveBees)*1000)
				nm_Reset(1,wait)
				nm_setStatus("Traveling", "Rhino Beetles (Blue Flower)")
				nm_gotoField(BugRunField)
			}
			while (not success){
				if(A_Index>=3)
					break
				found:=0
				loop 20
				{
					blufBug:=nm_HealthDetection()
					if(blufBug.Length > 0)
					{
						found:= 1
						break
					}
					Sleep 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					;Send "{" SC_1 "}"
					SendInput "{" RotUp " 4}"
					if(!DisableToolUse)
						Click "Down"
					r := 0
					loop 12 { ;wait to kill
						if(A_Index=12)
							success:=1
						Loop 20
						{
							blufDead:=nm_HealthDetection()
							if(blufDead.Length > 0)
								Break
							if (A_Index=10)
							{
								SendInput "{" RotLeft " 2}"
								r := 1
							}
							Sleep 100
							SendInput "{" ZoomOut "}"
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
					}
					sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					Sleep 500
					Click "Up"
					if(VBState=1)
						return
				}
			}
			;done with Rhino Beetles if Hive has less than 5 bees
			if(HiveBees<5){
				LastBugrunRhinoBeetles:=nowUnix()
				IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
			;loot
			if(BugrunRhinoBeetlesLoot){
				if(!DisableToolUse)
					Click "Down"
				nm_setStatus("Looting")
				movement :=
				(
				nm_Walk(2, BackKey) "
				" nm_Walk(5, RightKey, BackKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T30 L"
				nm_endWalk()
				nm_loot(8, 3, "left", 1)
				Click "Up"
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
						nm_gotoField(BugRunField)
					}
					bypass:=0
					found:=0
					loop 20
					{
						bambBug:=nm_HealthDetection()
						if(bambBug.Length > 0)
						{
							found:= 1
							break
						}
						Sleep 150
					}
					if (found)
					{
						nm_setStatus("Attacking")
						;Send "{" SC_1 "}"
						SendInput "{" RotUp " 4}"
						if(!DisableToolUse)
							Click "Down"
						r := 0
						loop 15 { ;wait to kill
							if(A_Index=15)
								success:=1
							Loop 20
							{
								bambDead:=nm_HealthDetection()
								if(bambDead.Length > 0)
									Break
								if (A_Index=10)
								{
									SendInput "{" RotLeft " 2}"
									r := 1
								}
								Sleep 100
								SendInput "{" ZoomOut "}"
								if (A_Index=20)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
						}
						sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						Sleep 500
						Click "Up"
						if(VBState=1)
							return
					}
				}
				;done with Rhino Beetles if Hive has less than 10 bees
				if(HiveBees<10){
					LastBugrunRhinoBeetles:=nowUnix()
					IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
				IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
				IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
				;loot
				if(BugrunRhinoBeetlesLoot){
					if(!DisableToolUse)
						Click "Down"
					nm_setStatus("Looting")
					movement :=
					(
					nm_Walk(9, BackKey) "
					" nm_Walk(1.5, RightKey) "
					loop 2 {
						" nm_Walk(18, FwdKey) "
						" nm_Walk(1.5, LeftKey) "
						" nm_Walk(18, BackKey) "
						" nm_Walk(1.5, LeftKey) "
					}
					" nm_Walk(18, FwdKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
					Click "Up"
				}
			}
		}
	}
	if(VBState=1)
		Return
	;Rhino Beetles and/or Mantis
	if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))
		|| ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01)))){ ;5 min Rhino 20min Mantis
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
				SetKeyDelay 5
				Send "{" FwdKey " down}"
				DllCall("Sleep","UInt",200)
				Send "{" SC_Space " down}"
				DllCall("Sleep","UInt",100)
				Send "{" SC_Space " up}"
				DllCall("Sleep","UInt",800)
				Send "{" FwdKey " up}"
				SendInput "{" RotLeft " 2}"
				SetKeyDelay PrevKeyDelay
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
					nm_gotoField(BugRunField)
				}
				bypass:=0
				found:=0
				loop 20
				{
					pineappleBug:=nm_HealthDetection()
					if(pineappleBug.Length > 0)
					{
						found:= 1
						break
					}
					Sleep 150
				}
				if (found)
				{
					nm_setStatus("Attacking")
					;Send "{" SC_1 "}"
					SendInput "{" RotUp " 4}"
					if(!DisableToolUse)
						Click "Down"
					;disableDayOrNight:=1
					r := 0
					loop 20 { ;wait to kill
						if(A_Index=20)
							success:=1
						Loop 20
						{
							pineappleDead:=nm_HealthDetection()
							if(pineappleDead.Length > 0)
								Break
							if (A_Index=10)
							{
								SendInput "{" RotLeft " 2}"
								r := 1
							}
							Sleep 100
							SendInput "{" ZoomOut "}"
							if (A_Index=20)
							{
								success:=1
								break 2
							}
						}
						if(youDied)
							break
						Sleep 250
					}
					sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
					Sleep 500
					Click "Up"
					;disableDayOrNight:=0
					if(VBState=1)
						return
				}
			}
			;done with Rhino Beetles
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			;done with Mantis if Hive is smaller than 15 bees
			if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && HiveBees<15){
				LastBugrunMantis:=nowUnix()
				IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
			}
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
			;loot
			if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && BugrunMantisLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles) && BugrunRhinoBeetlesLoot || RileyAll)){
				if(!DisableToolUse)
					Click "Down"
				nm_setStatus("Looting")
				nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(13.5, 5, "left")
				Click "Up"
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
				i:=0
				while (not success){
					if(A_Index>=3)
						break
					wait:=min(20000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					nm_setStatus("Traveling", "Werewolf (Pumpkin)")
					nm_gotoField(BugRunField)
					found:=0
					loop 20
					{
						wereBug:=nm_HealthDetection()
						if(wereBug.Length > 0)
						{
							found:= 1
							break
						}
						Sleep 150
					}
					if (found)
					{
						nm_setStatus("Attacking", "Werewolf (Pumpkin)")
						;Send "{" SC_1 "}"
						SendInput "{" RotUp " 4}"
						if(!DisableToolUse)
							Click "Down"
						loop 25 { ;wait to kill
							i:=A_Index
							if(mod(A_Index,4)=1){
								nm_Move(1500*MoveSpeedFactor, FwdKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									SendInput "{" ZoomOut "}"
									Sleep 250
								}
							} else if(mod(A_Index,4)=2){
								nm_Move(1500*MoveSpeedFactor, LeftKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									SendInput "{" ZoomOut "}"
									Sleep 250
								}
							} else if(mod(A_Index,4)=3){
								nm_Move(1500*MoveSpeedFactor, BackKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									SendInput "{" ZoomOut "}"
									Sleep 250
								}
							} else if(mod(A_Index,4)=0){
								nm_Move(1500*MoveSpeedFactor, RightKey)
								loop 5
								{
									wereDead:=nm_HealthDetection()
									if(wereDead.Length > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									SendInput "{" ZoomOut "}"
									Sleep 250
								}
							}
							if(A_Index=25)
								success:=1
							if(youDied)
								break
						}
						SendInput "{" RotDown " 4}"
						Sleep 500
						Click "Up"
						if(VBState=1)
							return
					}
				}
				LastBugrunWerewolf:=nowUnix()
				IniWrite LastBugrunWerewolf, "settings\nm_config.ini", "Collect", "LastBugrunWerewolf"
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
				IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
				IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
				if(BugrunWerewolfLoot){
					if(!DisableToolUse)
						Click "Down"
					nm_setStatus("Looting", "Werewolf (Pumpkin)")
					movement :=
					(
					(((Mod(i, 4) = 1) || (Mod(i, 4) = 2)) ? nm_Walk(4.5, BackKey) : nm_Walk(4.5, FwdKey)) "
					" (((Mod(i, 4) = 0) || (Mod(i, 4) = 1)) ? nm_Walk(4.5, LeftKey) : nm_Walk(4.5, RightKey)) "
					" nm_Walk(4, BackKey) "
					" nm_Walk(6, BackKey, LeftKey) "
					loop 4 {
						" nm_Walk(14, FwdKey) "
						" nm_Walk(1.5, RightKey) "
						" nm_Walk(14, BackKey) "
						" nm_Walk(1.5, RightKey) "
					}
					" nm_Walk(14, FwdKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
					Click "Up"
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
						nm_gotoField(BugRunField)
					}
					bypass:=0
					found:=0
					loop 20
					{
						pineBug:=nm_HealthDetection()
						if(pineBug.Length > 0)
						{
							found:= 1
							break
						}
						Sleep 200
					}
					if (found)
					{
						nm_setStatus("Attacking")
						;Send "{" SC_1 "}"
						SendInput "{" RotUp " 4}"
						if(!DisableToolUse)
							Click "Down"
						r := 0
						loop 20 { ;wait to kill
							if(A_Index=20)
								success:=1
							Loop 10
							{
								pineDead:=nm_HealthDetection()
								if(pineDead.Length > 0)
									Break
								if (A_Index=5)
								{
									SendInput "{" RotLeft " 2}"
									r := 1
								}
								Sleep 100
								SendInput "{" ZoomOut "}"
								if (A_Index=10)
								{
									success:=1
									break 2
								}
							}
							if(youDied)
								break
						}
						sendinput "{" RotDown " 4}" ((r = 1) ? "{" RotRight " 2}" : "")
						Sleep 500
						Click "Up"
						if(VBState=1)
							return
					}
				}
				;done with Mantis
				LastBugrunMantis:=nowUnix()
				IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
				IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
				IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
				;loot
				if(BugrunMantisLoot){
					if(!DisableToolUse)
						Click "Down"
					nm_setStatus("Looting")
					movement :=
					(
					nm_Walk(10, BackKey) "
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
					}"
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T90 L"
					nm_endWalk()
					Click "Up"
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
						Send "{" RotLeft "}"
					}
					nm_Move(4000*MoveSpeedFactor, RightKey)
					nm_Move(2000*MoveSpeedFactor, LeftKey)
					nm_Move(17500*MoveSpeedFactor, FwdKey)
					loop 2 {
						Send "{" RotRight "}"
					}
				} else {
					success:=0
					bypass:=0
				}
				i:=0
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(20000, (60-HiveBees)*1000)
						nm_Reset(1, wait)
						nm_setStatus("Traveling", "Scorpions (Rose)")
						nm_gotoField(BugRunField)
						nm_Move(1000*MoveSpeedFactor, BackKey)
						nm_Move(1500*MoveSpeedFactor, RightKey)
					}
					bypass:=0
					found:=0
					loop 20
					{
						roseBug:=nm_HealthDetection()
						if(roseBug.Length > 0)
						{
							found:= 1
							break
						}
						Sleep 150
					}
					if (found)
					{
						nm_setStatus("Attacking")
						SendInput "{" RotUp " 4}"
						SendInput "{" RotLeft " 4}"
						;Send "{" SC_1 "}"
						if(!DisableToolUse)
							Click "Down"
						loop 17 { ;wait to kill
							i:=A_Index
							if(mod(A_Index,4)=1){
								nm_Move(1500*MoveSpeedFactor, BackKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length > 0)
									{
										Break
									}
									SendInput "{" ZoomOut "}"
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep 250
								}
							} else if(mod(A_Index,4)=2){
								nm_Move(1500*MoveSpeedFactor, RightKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length > 0)
									{
										Break
									}
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep 250
								}
							} else if(mod(A_Index,4)=3){
								nm_Move(1500*MoveSpeedFactor, FwdKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length > 0)
									{
										Break
									}
									SendInput "{" ZoomOut "}"
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep 250
								}
							} else if(mod(A_Index,4)=0){
								nm_Move(1500*MoveSpeedFactor, LeftKey)
								loop 5
								{
									roseDead:=nm_HealthDetection()
									if(roseDead.Length > 0)
									{
										Break
									}
									SendInput "{" ZoomOut "}"
									if (A_Index=5)
									{
										Success:=1
										Break 2
									}
									Sleep 250
								}
							}
							if(A_Index=17)
								success:=1
							if(youDied)
								break
						}
						SendInput "{" RotDown " 4}"
						Sleep 500
						Click "Up"
						if(VBState=1)
							return
					}
				}
				;done with Scorpions
				LastBugrunScorpions:=nowUnix()
				IniWrite LastBugrunScorpions, "settings\nm_config.ini", "Collect", "LastBugrunScorpions"
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
				IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
				IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
				;loot
				if(BugrunScorpionsLoot){
					if(!DisableToolUse)
						Click "Down"
					nm_setStatus("Looting")
					movement :=
					(
					(((Mod(i, 4) = 1) || (Mod(i, 4) = 2)) ? nm_Walk(4.5, FwdKey) : nm_Walk(4.5, BackKey)) "
					" (((Mod(i, 4) = 0) || (Mod(i, 4) = 1)) ? nm_Walk(4.5, RightKey) : nm_Walk(4.5, LeftKey)) "
					" nm_Walk(2, FwdKey) "
					" nm_Walk(10, FwdKey, LeftKey) "
					loop 4 {
						" nm_Walk(16, BackKey) "
						" nm_Walk(1.5, RightKey) "
						" nm_Walk(16, FwdKey) "
						" nm_Walk(1.5, RightKey) "
					}
					" nm_Walk(16, BackKey) "
					" nm_Walk(6, FwdKey, LeftKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T90 L"
					nm_endWalk()
					Click "Up"
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
				if (MoveMethod = "walk") {
					nm_gotoramp()
	
					movement := 
					(
					nm_Walk(67.5, BackKey, LeftKey) "
					send '{" RotRight " 4}'
					" nm_Walk(23.5, FwdKey) "
					" nm_Walk(31.5, FwdKey, RightKey) "
					" nm_Walk(10, RightKey) "
					send '{" RotRight " 2}' 
					" nm_Walk(28, FwdKey) "
					" nm_Walk(13, LeftKey) "
					" nm_Walk(25, RightKey) "
					send '{" SC_Space " down}{" FwdKey " down}'
					Walk(12)
					send '{" SC_Space " up}{" FwdKey " up}{" RotLeft " 2}'
					" nm_Walk(35, FwdKey) "
					" nm_Walk(25, RightKey) "
					" nm_Walk(12, FwdKey) "
					" nm_Walk(3.5, RightKey) "
					send '{" RotRight " 4}'
					" nm_Walk(37, Fwdkey) "
					" nm_Walk(10, FwdKey, LeftKey) "
					" nm_Walk(5, Backkey) "
					" nm_Walk(15, RightKey) "
					" nm_Walk(10, BackKey) "
					Sleep(3000) 
					send '{" RotRight " 4}{" RotUp " 3}' "
					)
				} else {
					nm_gotoramp()
					nm_gotocannon()
	
					movement := 
					(
					" send '{" SC_E " down}'
					sleep 100
					send '{" SC_E " up}'
					HyperSleep(1000)
					send '{" LeftKey " down}'
					HyperSleep(100)
					send '{" SC_space " 2}'
					HyperSleep(900)
					send '{" LeftKey " up}'
					HyperSleep(6000)
					" nm_Walk(10, FwdKey, LeftKey) "
					" nm_Walk(5, Backkey) "
					" nm_Walk(15, RightKey) "
					" nm_Walk(10, BackKey) "
					Sleep(3000) 
					send '{" RotRight " 4}{" RotUp " 3}' "
					)
				}
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T90 L"
				nm_endWalk()
				;confirm tunnel
				GetRobloxClientPos()
				pBM := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight//2)
				for , value in bitmaps["tunnelbearconfirm"] {
					if (Gdip_ImageSearch(pBM, value, , , , , , 15) = 1)
						break
					if A_Index = bitmaps["tunnelbearconfirm"].Count {
						Gdip_DisposeImage(pBM)
						continue 2 ;retry
					}
				}
				Gdip_DisposeImage(pBM)
				Send "{" RotLeft " 2}{" RotDown " 3}"
				;wait for baby love
				DllCall("Sleep","UInt",2000)
				if (TunnelBearBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					DllCall("Sleep","UInt",1500)
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						DllCall("Sleep","UInt",1000)
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
					if(tBear.Length > 0)
					{
						found:=1
						break
					}
					DllCall("Sleep","UInt",250)
				}
				;attack tunnel bear
				TBdead:=0
				if(found) {
					SendInput "{" RotUp " 3}"
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
							SendInput "{" RotDown " 3}"
							break
						}
						if(youDied)
							break
						Sleep 1000
					}
				} else { ;No TunnelBear here...try again in 2 hours
					LastTunnelBear:=nowUnix()-floor(172800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
					IniWrite LastTunnelBear, "settings\nm_config.ini", "Collect", "LastTunnelBear"
				}
				;loot
				if(TBdead) {
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					PostSubmacroMessage("StatMonitor", 0x5555, 1, 1)
					IniWrite TotalBossKills, "settings\nm_config.ini", "Status", "TotalBossKills"
					IniWrite SessionBossKills, "settings\nm_config.ini", "Status", "SessionBossKills"
					nm_setStatus("Looting")
					nm_Move(12000*MoveSpeedFactor, FwdKey)
					nm_Move(18000*MoveSpeedFactor, BackKey)
					LastTunnelBear:=nowUnix()
					IniWrite LastTunnelBear, "settings\nm_config.ini", "Collect", "LastTunnelBear"
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
				nm_gotoField("Blue Flower")
				nm_Move(5000*MoveSpeedFactor, RightKey, FwdKey)
				nm_Move(4000*MoveSpeedFactor, FwdKey)
				Send "{" RotRight " 2}"
				;wait for baby love
				DllCall("Sleep","UInt",1000)
				if (KingBeetleBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					nm_Move(2000*MoveSpeedFactor, BackKey)
					DllCall("Sleep","UInt",1500)
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						DllCall("Sleep","UInt",1000)
					}
					nm_Move(1500*MoveSpeedFactor, FwdKey)
					nm_Move(1500*MoveSpeedFactor, LeftKey)
				}
				lairConfirmed:=0
				;Go inside
				movement :=
				(
				nm_Walk(5, RightKey) '
				Send "{' SC_Space ' down}"
				Sleep 200
				Send "{' SC_Space ' up}"
				' nm_Walk(3, RightKey) '
				' nm_Walk(5, RightKey, FwdKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T30 L"
				nm_endWalk()
				loop 2 {
					Send "{" RotLeft "}"
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
					kBeetle:= nm_HealthDetection(1)
					if(kBeetle.Length > 0)
					{
						found:=1
						break
					}
					Sleep 250
				}
				if(!found) { ;No King Beetle here...try again in 2 hours
					if(A_Index=2){
						LastKingBeetle:=nowUnix()-floor(79200*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
						IniWrite LastKingBeetle, "settings\nm_config.ini", "Collect", "LastKingBeetle"
					}
					continue
				}
				nm_setStatus("Attacking", "King Beetle")
				kingdead:=0
				Sleep 2000
				loop 1 {
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
						nm_Move(2500*MoveSpeedFactor, BackKey)
						nm_Move(500*MoveSpeedFactor, RightKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, BackKey)
					Sleep 1000
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1000*MoveSpeedFactor, BackKey, RightKey)
						nm_Move(1000*MoveSpeedFactor, BackKey)
						nm_Move(500*MoveSpeedFactor, RightKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, RightKey)
					Sleep 100
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1500*MoveSpeedFactor, BackKey)
						nm_Move(1000*MoveSpeedFactor, LeftKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, BackKey)
					Sleep 1000
					if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
						kingdead:=1
						nm_Move(1250*MoveSpeedFactor, FwdKey)
						nm_Move(1000*MoveSpeedFactor, LeftKey)
						break
					}
					nm_Move(2000*MoveSpeedFactor, RightKey)
					Sleep 1000
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
					Sleep 500
					Send "{" RotLeft "}"
					loop 300 {
						if(nm_imgSearch("king.png",25,"lowright")[1] = 0){
							kingdead:=1
							Send "{" RotRight "}"
							nm_Move(3500*MoveSpeedFactor, FwdKey, LeftKey)
							nm_Move(2500*MoveSpeedFactor, LeftKey)
							break
						}
						sleep 1000
					}
				}
				if(kingdead) {
					;check for amulet
					if !nm_AmuletPrompt(((KingBeetleAmuletMode = 1) ? 1 : 3), "King Beetle")
						nm_setStatus("Looting", "King Beetle"), nm_loot(13.5, 7, "right", 1)							
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					PostSubmacroMessage("StatMonitor", 0x5555, 1, 1)
					IniWrite TotalBossKills, "settings\nm_config.ini", "Status", "TotalBossKills"
					IniWrite SessionBossKills, "settings\nm_config.ini", "Status", "SessionBossKills"
					LastKingBeetle:=nowUnix()
					IniWrite LastKingBeetle, "settings\nm_config.ini", "Collect", "LastKingBeetle"
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
				nm_gotoField("stump")

				;search for Stump snail
				nm_setStatus("Searching", "Stump Snail")
				found:=0
				loop 20
				{
					sSnail:= nm_HealthDetection()
					if(sSnail.Length > 0)
					{
						found:=1
						break
					}
					Sleep 150
				}
				;attack Snail
				movement := nm_Walk(1, FwdKey)
				nm_createWalk(movement, "snailWalk")
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				movement :=
				(
				nm_Walk(2.5, RightKey) "
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
				" nm_Walk(2.5, Rightkey)
				)

				Ssdead:=0
				if(found) {
					nm_setStatus("Attacking", "Stump Snail")
					DllCall("GetSystemTimeAsFileTime", "int64p", &SnailStartTime:=0)
					KillCheck := SnailStartTime
					UpdateTimer := SnailStartTime
					Send "{" SC_1 "}"
					loop 2
					{
						Send "{" RotUp "}"
					}
					inactiveHoney:=0
					loop ;Custom Stump timer to keep blessings, Will rehunt in an hour
					{
						if (SprinklerType = "Supreme")
						{
							if (currentWalk.name != "snail")
							{
								nm_createWalk(movement, "snail") ; create cycled walk script for this snail session
							}
							else
							{
								Send "{F13}" ; start new cycle
							}
							KeyWait "F14", "D T5 L" ; wait for pattern start
						}
						Click "Down"
						Loop 600
						{
							Sleep 50
							If ((nm_AmuletPrompt(((ShellAmuletMode = 1) ? 1 : 3), "Shell")) = 1)
							{
								Ssdead := 1
								Send "{" RotDown " 2}"
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
								if nm_MondoInterrupt()
									break
							}
							if(youDied)
								break 2
							if(VBState=1){
								nm_endWalk()
								Click "Up"
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
						Click "Up"
						;(+) New detection system for snail
						DllCall("GetSystemTimeAsFileTime", "int64p", &currentTime:=0)
						ElaspedSnailTime :=  (currentTime - SnailStartTime)//10000
						LastHealthCheck := (currentTime - KillCheck)//10000
						LastUpdate := (currentTime - UpdateTimer)//10000
						If(SnailTime != "Kill" && ElaspedSnailTime > SnailTime*60000)
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
					IniWrite LastStumpSnail, "settings\nm_config.ini", "Collect", "LastStumpSnail"
					nm_setStatus("Missing", "Stump Snail")
				}

				;loot
				if(SSdead) {
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					PostSubmacroMessage("StatMonitor", 0x5555, 1, 1)
					IniWrite TotalBossKills, "settings\nm_config.ini", "Status", "TotalBossKills"
					IniWrite SessionBossKills, "settings\nm_config.ini", "Status", "SessionBossKills"
					LastStumpSnail:=nowUnix()
					IniWrite LastStumpSnail, "settings\nm_config.ini", "Collect", "LastStumpSnail"
					InputSnailHealth := 100.00
					IniWrite InputSnailHealth, "settings\nm_config.ini", "Collect", "InputSnailHealth"
					intialHealthCheck:=0
					break
				}
				else if (A_Index = 2){ ;stump snail not dead, come again in 30 mins
					LastStumpSnail:=nowUnix()-floor(345600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
					IniWrite LastStumpSnail, "settings\nm_config.ini", "Collect", "LastStumpSnail"
				}
			}
		}
		if(VBState=1)
			return

		;Commando
		if((CommandoCheck) && (nowUnix()-LastCommando)>floor(1800*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))){ ;30 minutes
			Loop 2 {
				nm_Reset()
				;Go to Commando tunnel
				nm_setStatus("Traveling", "Commando")
				nm_gotoRamp()
				if (MoveMethod = "Walk")
				{
					movement :=
					(
					nm_Walk(44.75, BackKey, LeftKey) '
					' nm_Walk(42.5, LeftKey) '
					' nm_Walk(8.5, BackKey) '
					' nm_Walk(22.5, LeftKey) '
					send "{' RotLeft ' 2}"
					' nm_Walk(27, FwdKey) '
					' nm_Walk(12, LeftKey, FwdKey) '
					' nm_Walk(11, FwdKey)
					)
				}
				else
				{
					nm_gotoCannon()
					movement :=
					(
					'
					send "{' SC_E ' down}"
					HyperSleep(100)
					send "{' SC_E ' up}"
					HyperSleep(400)
					send "{' LeftKey ' down}{' FwdKey ' down}"
					HyperSleep(1050)
					send "{' SC_Space ' 2}"
					HyperSleep(5850)
					send "{' FwdKey ' up}"
					HyperSleep(750)
					send "{' SC_Space '}{' RotLeft ' 2}"
					HyperSleep(1500)
					send "{' LeftKey ' up}"
					' nm_Walk(4, BackKey) '
					' nm_Walk(4.5, LeftKey)
					)
				}

				if (MoveSpeedNum < 34)
				{
					movement .=
					(
					'
					' nm_Walk(10, LeftKey) '
					HyperSleep(50)
					' nm_Walk(6, RightKey) '
					HyperSleep(50)
					' nm_Walk(2, LeftKey) '
					HyperSleep(50)
					' nm_Walk(7, FwdKey) '
					HyperSleep(750)
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(5.5, FwdKey) '
					HyperSleep(750)
					Loop 3
					{
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' nm_Walk(6, FwdKey) '
						HyperSleep(750)
					}
					' nm_Walk(1, FwdKey) '
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(6, FwdKey) '
					HyperSleep(750)
					' nm_Walk(5, FwdKey) '
					HyperSleep(50)
					' nm_Walk(9, BackKey) '
					Sleep 4000
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(0.5, BackKey) '
					HyperSleep(1500)'
					)
				}
				else
				{
					movement .=
					(
					'
					' nm_Walk(10, LeftKey) '
					HyperSleep(50)
					' nm_Walk(6, RightKey) '
					HyperSleep(50)
					' nm_Walk(2, LeftKey) '
					HyperSleep(50)
					' nm_Walk(7, FwdKey) '
					HyperSleep(750)
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(4.5, FwdKey) '
					HyperSleep(750)
					Loop 3
					{
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' nm_Walk(5, FwdKey) '
						HyperSleep(750)
					}
					' nm_Walk(1, FwdKey) '
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(6, FwdKey) '
					HyperSleep(750)
					' nm_Walk(5, FwdKey) '
					HyperSleep(50)
					' nm_Walk(9, BackKey) '
					Sleep 4000
					send "{' SC_Space ' down}"
					HyperSleep(50)
					send "{' SC_Space ' up}"
					' nm_Walk(0.5, BackKey) '
					HyperSleep(1500)'
					)
				}

				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T90 L"
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
					if ((A_Index = 1) || (currentWalk.name != "commando"))
					{
						movement :=
						(
						nm_Walk(5, FwdKey) '
						HyperSleep(50)
						' nm_Walk(9, BackKey) '
						Sleep 4000
						send "{' SC_Space ' down}"
						HyperSleep(50)
						send "{' SC_Space ' up}"
						' nm_Walk(0.5, BackKey) '
						HyperSleep(1500)'
						)
						nm_createWalk(movement, "commando")
					}
					else
						Send "{F13}"

					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T20 L"
				}
				nm_endWalk()

				nm_setStatus("Searching", "Commando Chick")
				found:=0
				loop 4 {
					Send "{" ZoomIn "}"
				}
				;(+) Update health detection
				loop 20
				{
					cChick:= nm_HealthDetection()
					if(cChick.Length > 0)
					{
						found:=1
						break
					}
					Sleep 250
				}
				Global ChickStartTime
				Global ElaspedChickTime
				Ccdead:=0
				if(found) {
					nm_setStatus("Attacking", "Commando Chick")

					DllCall("GetSystemTimeAsFileTime", "int64p", &ChickStartTime:=0)
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
							if nm_MondoInterrupt()
								break
						}
						;(+) New detection system for Chick
						DllCall("GetSystemTimeAsFileTime", "int64p", &currentTime:=0)
						LastHealthCheck := (currentTime - KillCheck)//10000
						ElaspedChickTime := (currentTime-ChickStartTime)//10000
						LastUpdate := (currentTime - UpdateTimer)//10000
						If(ChickTime != "Kill" && ElaspedChickTime > ChickTime*60000)
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
							if(comChick.Length > 0)
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
									break 2
								}
							}
							if(nm_imgSearch("ChickDead.png",50,"lowright")[1] = 0){
								CCdead:=1
								break 2
							}
							Sleep 250
						}
					}
				}
				else { ;No Commando chick try again in 30 mins
					LastCommando:=nowUnix()
					IniWrite LastCommando, "settings\nm_config.ini", "Collect", "LastCommando"
					nm_setStatus("Missing", "Commando Chick")
				}

				;loot
				if(CCdead) {
					nm_setStatus("Defeated", "Commando Chick")
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					PostSubmacroMessage("StatMonitor", 0x5555, 1, 1)
					IniWrite TotalBossKills, "settings\nm_config.ini", "Status", "TotalBossKills"
					IniWrite SessionBossKills, "settings\nm_config.ini", "Status", "SessionBossKills"
					LastCommando:=nowUnix()
					IniWrite LastCommando, "settings\nm_config.ini", "Collect", "LastCommando"
					InputChickHealth:=100.00
					IniWrite InputChickHealth, "settings\nm_config.ini", "Collect", "InputChickHealth"
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
				nm_gotoField("coconut")
				Send "{" SC_1 "}"
				nm_Move(1400, RightKey)
				nm_Move(1000, BackKey)

				;search for Crab
				nm_setStatus("Searching", "Coco Crab")
				found:=0

				;(+) new detection here
				loop 20
				{
					cCrab:= nm_HealthDetection()
					if(cCrab.Length > 0)
					{
						found:=1
						break
					}
					Sleep 250
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

				movement :=
				(
				'
				DllCall("GetSystemTimeAsFileTime", "int64p", &start_time:=0)
				' nm_Walk(4, FwdKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &time:=0)
				Sleep ' leftright_start ' -(time-start_time)//10000
				loop 2 {
					i := A_Index
					' nm_Walk(1, FwdKey) '
					Loop ' moves ' {
						' nm_Walk(2, LeftKey) '
						DllCall("GetSystemTimeAsFileTime", "int64p", &time)
						Sleep i*' 2*move_delay*moves '-' 2*move_delay*moves-leftright_start '+A_Index*' move_delay '-(time-start_time)//10000
					}
					' nm_Walk(1, BackKey) '
					Loop ' moves ' {
						' nm_Walk(2, RightKey) '
						DllCall("GetSystemTimeAsFileTime", "int64p", &time)
						Sleep i*' 2*move_delay*moves '-' move_delay*moves-leftright_start '+A_Index*' move_delay '-(time-start_time)//10000
					}
				}
				DllCall("GetSystemTimeAsFileTime", "int64p", &time)
				Sleep ' leftright_end '-(time-start_time)//10000
				' nm_Walk(6.5, BackKey) '
				DllCall("GetSystemTimeAsFileTime", "int64p", &time)
				Sleep ' cycle_end '-(time-start_time)//10000
				'
				)

				Crdead:=0
				if(found) {

					nm_setStatus("Attacking", "Coco Crab")
					DllCall("GetSystemTimeAsFileTime", "int64p", &CrabStartTime:=0)
					inactiveHoney:=0
					loop { ;30 minute crab timer to keep blessings, Will rehunt in an hour
						DllCall("GetSystemTimeAsFileTime", "int64p", &PatternStartTime:=0)
						if (currentWalk.name != "crab")
							nm_createWalk(movement, "crab") ; create cycled walk script for this gather session
						else
							Send "{F13}" ; start new cycle

						KeyWait "F14", "D T5 L" ; wait for pattern start

						Loop 600
						{
							if(!DisableToolUse) {
								sendinput "{click down}"
								sleep 50
								sendinput "{click up}"
							}
							if(nm_imgSearch("crab.png",70,"lowright")[1] = 0){
								Crdead:=1
								Send "{" RotUp " 2}"
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
							Sleep 50
						}
						DllCall("GetSystemTimeAsFileTime", "int64p", &time:=0)
						ElaspedCrabTime := (time-CrabStartTime)//10000
						If (ElaspedCrabTime > 900000){
							nm_setStatus("Time Limit", "Coco Crab")
							LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
							IniWrite LastCocoCrab, "settings\nm_config.ini", "Collect", "LastCocoCrab"
							nm_endWalk()
							Return
						}
					}
					nm_endWalk()
				}
				else { ;No Crab try again in 2 hours
					LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+7200
					IniWrite LastCocoCrab, "settings\nm_config.ini", "Collect", "LastCocoCrab"
					nm_setStatus("Missing", "Coco Crab")
				}

				;loot
				if(Crdead) {
					DllCall("GetSystemTimeAsFileTime", "int64p", &time:=0)
					duration := DurationFromSeconds((time-CrabStartTime)//10000000, "mm:ss")
					nm_setStatus("Defeated", "Coco Crab`nTime: " duration)
					ElapsedPatternTime := (time-PatternStartTime)//10000
					movement :=
					(
					nm_Walk(((ElapsedPatternTime > leftright_start) && (ElapsedPatternTime < leftright_start+4*moves*move_delay)) ? Abs(Abs(Mod((ElapsedPatternTime-moves*move_delay-leftright_start)*2/move_delay, moves*4)-moves*2)-moves*3/2) : moves*3/2, (((ElapsedPatternTime > leftright_start+moves/2*move_delay) && (ElapsedPatternTime < leftright_start+3*moves/2*move_delay)) || ((ElapsedPatternTime > leftright_start+5*moves/2*move_delay) && (ElapsedPatternTime < leftright_start+7*moves/2*move_delay))) ? RightKey : LeftKey) "
					" (((ElapsedPatternTime < leftright_start) || (ElapsedPatternTime > leftright_end)) ? nm_Walk(4, FwdKey) : "")
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T20 L"
					nm_endWalk()
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					PostSubmacroMessage("StatMonitor", 0x5555, 1, 1)
					IniWrite TotalBossKills, "settings\nm_config.ini", "Status", "TotalBossKills"
					IniWrite SessionBossKills, "settings\nm_config.ini", "Status", "SessionBossKills"
					nm_setStatus("Looting", "Coco Crab")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					nm_loot(9, 4, "right")
					nm_loot(9, 4, "left")
					LastCocoCrab:=nowUnix()
					IniWrite LastCocoCrab, "settings\nm_config.ini", "Collect", "LastCocoCrab"
					break
				}
				else if (A_Index = 2) { ;crab kill failed, try again in 30 mins
					LastCocoCrab:=nowUnix()-floor(129600*(1-(MonsterRespawnTime?MonsterRespawnTime:0)*0.01))+1800
					IniWrite LastCocoCrab, "settings\nm_config.ini", "Collect", "LastCocoCrab"
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
	if(VBState=1)
		return
	if nm_MondoInterrupt(){
		mondobuff := nm_imgSearch("mondobuff.png",50,"buff")
		If (mondobuff[1] = 0) {
			LastMondoBuff:=nowUnix()
			IniWrite LastMondoBuff, "settings\nm_config.ini", "Collect", "LastMondoBuff"
			return
		}
		repeat:=1
		global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, DisableToolUse
		global KeyDelay
		global MoveMethod
		global MoveSpeedNum
		global AFBrollingDice
		global AFBuseGlitter
		global AFBuseBooster
		global CurrentField
		global MondoSecs, MondoLootDirection
		nm_updateAction("Mondo")
		MoveSpeedFactor:=round(18/MoveSpeedNum, 2)
		while(repeat){
			nm_Reset(0, 2000, 0)
			nm_setStatus("Traveling", ("Mondo (" . MondoAction . ")"))
			nm_gotoPlanter("mountain top")
			nm_createWalk(nm_Walk(14, RightKey) "`nsend '{" RotLeft "}'")
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T30 L"
			nm_endWalk()
			;;; (+) new conditions probably
			found := 0
			mondoChick := 0
			loop 20
			{
				mChick:= nm_HealthDetection()
				if(mChick.Length > 0)
				{
					found:=1
					break
				}
				Sleep 250
			}
			if (found)
			{
				nm_setStatus("Found", "Mondo")
				for index, value in mChick ;Mondo is already dmging itself before we get there
				{
					if (value = 100.00) ;Planter detected since mondo will already have taken dmg by the time you come up
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
					nm_setStatus("Attacking", "Mondo")
					if(MondoAction="Buff"){
						repeat:=0
						loop MondoSecs { ;2 mins
							nm_autoFieldBoost(CurrentField)
							if(youDied || AFBrollingDice || AFBuseGlitter || AFBuseBooster)
								break
							Sleep 1000
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
							Sleep 1000
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
							Sleep 1000
							utc_min := FormatTime(A_NowUTC, "m")
						}
					} else if(MondoAction="Kill"){
						repeat:=1
						success:=count:=0
						loop 3600 { ;15 mins
							mondoDead:=nm_HealthDetection()
							if ((mondoDead.Length = 0) || (mondoDead.Length = 1 && mondoDead[1] = 100.00)) {
								if (++count >= 60) { ; Changed from 5 seconds to 15 seconds for when mondo goes off screen
									success := 1
									break
								}
							}
							else ; one health bar < 100 or multiple health bars (assumed Mondo is one of them)
								count := 0
							if(Mod(A_Index, 4)=0) { ; 1 second
								nm_autoFieldBoost(CurrentField)
								if(VBState=1 || AFBrollingDice || AFBuseGlitter || AFBuseBooster) {
									return
								}
								if(youDied)
									break
								if(FormatTime(A_NowUTC, "m")>14) {
									repeat:=0
									break
								}
								If (nm_imgSearch("mondo3.png",50,"lowright")[1] = 0) { ;check for mondo death here
									success := 1
									break
								}
							}
							if(Mod(A_Index, 40)=0) ; 10 seconds
								nm_OpenMenu()
							if(Mod(A_Index, 240)=0) ; 1 minute
								click
							if(A_Index=3600) {
								repeat:=0
								break
							}
							sleep 250
						}
						if (success = 1) {
							nm_setStatus("Defeated", "Mondo")
							repeat := 0
							if !(MondoLootDirection = "Ignore") {
								;loot mondo after death
								if (MondoLootDirection = "Random")
									dir := Random(0, 1)
								else
									dir := (MondoLootDirection = "Right")

								if (dir = 0)
									tc := "left", afc := "right"
								else
									tc := "right", afc := "left"

								nm_setStatus("Looting", "Mondo")
								movement :=
								(
								"send '{" RotLeft "}'
								" nm_Walk(7.5, FwdKey, RightKey) "
								" nm_Walk(7.5, %tc%Key)
								)
								nm_createWalk(movement)
								KeyWait "F14", "D T5 L"
								KeyWait "F14", "T30 L"
								nm_endWalk()

								if(!DisableToolUse)
									click "down"
								DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
								n := s, f := s+450000000 ; 45 seconds loot timeout
								while ((n < f) && (A_Index <= 12)) {
									nm_loot(16, 5, Mod(A_Index, 2) = 1 ? afc : tc)
									DllCall("GetSystemTimeAsFileTime","int64p",&n)
								}
								click "up"
							}
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
		IniWrite LastMondoBuff, "settings\nm_config.ini", "Collect", "LastMondoBuff"
	}
}
nm_GoGather(){
	global youDied, VBState
		, TCFBKey, AFCFBKey, TCLRKey, AFCLRKey, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, SC_E, KeyDelay
		, MoveMethod
		, CurrentFieldNum
		, objective
		, BackpackPercentFiltered
		, MicroConverterKey
		, WhirligigKey, PFieldBoosted, GlitterKey, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, PMondoGuidComplete, LastGuid, PMondoGuid, PFieldGuidExtend, PFieldGuidExtendMins, PFieldBoostExtend, PPopStarExtend, HasPopStar, PopStarActive, FieldGuidDetected, ConvertGatherFlag
		, LastWhirligig
		, BoostChaserCheck, LastBlueBoost, LastRedBoost, LastMountainBoost, FieldBooster3, FieldBooster2, FieldBooster1, FieldDefault, LastMicroConverter, HiveConfirmed, LastWreath, WreathCheck
		, BlueFlowerBoosterCheck, BambooBoosterCheck, PineTreeBoosterCheck, StumpBoosterCheck, DandelionBoosterCheck, SunflowerBoosterCheck, CloverBoosterCheck, SpiderBoosterCheck, PineappleBoosterCheck, CactusBoosterCheck, PumpkinBoosterCheck, MushroomBoosterCheck, StrawberryBoosterCheck, RoseBoosterCheck, PepperBoosterCheck, CoconutBoosterCheck
		, FieldName1, FieldPattern1, FieldPatternSize1, FieldPatternReps1, FieldPatternShift1, FieldPatternInvertFB1, FieldPatternInvertLR1, FieldUntilMins1, FieldUntilPack1, FieldReturnType1, FieldSprinklerLoc1, FieldSprinklerDist1, FieldRotateDirection1, FieldRotateTimes1, FieldDriftCheck1
		, FieldName2, FieldPattern2, FieldPatternSize2, FieldPatternReps2, FieldPatternShift2, FieldPatternInvertFB2, FieldPatternInvertLR2, FieldUntilMins2, FieldUntilPack2, FieldReturnType2, FieldSprinklerLoc2, FieldSprinklerDist2, FieldRotateDirection2, FieldRotateTimes2, FieldDriftCheck2
		, FieldName3, FieldPattern3, FieldPatternSize3, FieldPatternReps3, FieldPatternShift3, FieldPatternInvertFB3, FieldPatternInvertLR3, FieldUntilMins3, FieldUntilPack3, FieldReturnType3, FieldSprinklerLoc3, FieldSprinklerDist3, FieldRotateDirection3, FieldRotateTimes3, FieldDriftCheck3
		, FieldName, FieldPattern, FieldPatternSize, FieldPatternReps, FieldPatternShift, FieldPatternInvertFB, FieldPatternInvertLR, FieldUntilMins, FieldUntilPack, FieldReturnType, FieldSprinklerLoc, FieldSprinklerDist, FieldRotateDirection, FieldRotateTimes, FieldDriftCheck
		, MondoBuffCheck, MondoAction, LastMondoBuff
		, PlanterMode, gotoPlanterField, MPlanterGatherA, MPlanterGather1, MPlanterGather2, MPlanterGather3, LastPlanterGatherSlot, MPlanterHold1, MPlanterHold2, MPlanterHold3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
		, GatherStartTime, TotalGatherTime, SessionGatherTime, ConvertStartTime, TotalConvertTime, SessionConvertTime
		, GameFrozenCounter
		, BlackQuestCheck, BrownQuestCheck, BuckoQuestCheck, RileyQuestCheck, PolarQuestCheck
		, BlackQuestComplete, BrownQuestComplete, BuckoQuestComplete, RileyQuestComplete, PolarQuestComplete

	;VICIOUS BEE
	if (VBState = 1)
		return
	;MONDO
	if nm_MondoInterrupt()
		return
	if !(nm_GatherBoostInterrupt()){
		;BUGS GatherInterruptCheck
		if nm_BugrunInterrupt()
			return
		;BEESMAS GatherInterruptCheck
		if nm_BeesmasInterrupt()
			return
		;Memory Match
		if nm_MemoryMatchInterrupt()
			return
	}
	utc_min := FormatTime(A_NowUTC, "m")
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
	;FIELD OVERRIDES
	global fieldOverrideReason:="None"
	loop 1 {
		;boosted field override
		if(BoostChaserCheck){

			BoostChaserField:="None"
			blueBoosterFields		:=Map("PineTreeBoosterCheck","Pine Tree", "BambooBoosterCheck","Bamboo", "BlueFlowerBoosterCheck","Blue Flower", "StumpBoosterCheck","Stump")
			redBoosterFields		:=Map("RoseBoosterCheck","Rose", "StrawberryBoosterCheck","Strawberry", "MushroomBoosterCheck","Mushroom", "PepperBoosterCheck","Pepper")
			mountainBoosterfields	:=Map("CactusBoosterCheck","Cactus", "PumpkinBoosterCheck","Pumpkin", "PineappleBoosterCheck","Pineapple", "SpiderBoosterCheck","Spider", "CloverBoosterCheck","Clover", "DandelionBoosterCheck","Dandelion", "SunflowerBoosterCheck","Sunflower")
			coconutBoosterfields	:=Map("CoconutBoosterCheck","Coconut")
			otherFields				:=["Mountain Top"]

			loop 1 {
				for i, location in ["blue", "mountain", "red", "coconut"] {
					for k, v in %location%BoosterFields {
						if((nm_fieldBoostCheck(v, 1)) && (%k%)) {
							BoostChaserField:=v
							break
						}
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
		if((BlackQuestCheck || BrownQuestCheck || BuckoQuestCheck || RileyQuestCheck || PolarQuestCheck) && (QuestGatherField && QuestGatherField!="None")){
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
				FieldDriftCheck:=FieldDriftCheck1
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
		;Gather in manual planters field override

		if((MPlanterGatherA) && (PlanterMode = 1)) {

			; define available planter gather slots/fields: selected by user for planter gather, with planter in field, and not 'holding at full grown'
			(eligible := []).Length := 3
			Loop 3 {
				if((MPlanterGather%A_Index%) && (PlanterField%A_Index% != "None") && (!MPlanterHold%A_Index%))
					eligible[A_Index] := planterField%A_Index%
			}

			if !(LastPlanterGatherSlot ~= "^(1|2|3)$")
				LastPlanterGatherSlot := 3

			; if at least one slot is available for planter gather, proceed, else revert to gather tab
			if (eligible.Has(1) || eligible.Has(2) || eligible.Has(3)) {

				; find next eligible field and slot
				if 		((eligible.Has(1)) && (((LastPlanterGatherSlot=1) && (!eligible.Has(2)) && (!eligible.Has(3))) || ((LastPlanterGatherSlot=2) && (!eligible.Has(3))) || (LastPlanterGatherSlot=3)))
						{
						LastPlanterGatherSlot:= 1
						field := PlanterField1
						}
				else if ((eligible.Has(2)) && (((LastPlanterGatherSlot=2) && (!eligible.Has(3)) && (!eligible.Has(1))) || ((LastPlanterGatherSlot=3) && (!eligible.Has(1))) || (LastPlanterGatherSlot=1)))
						{
						LastPlanterGatherSlot:= 2
						field := PlanterField2
						}
				else if ((eligible.Has(3)) && (((LastPlanterGatherSlot=3) && (!eligible.Has(1)) && (!eligible.Has(2))) || ((LastPlanterGatherSlot=1) && (!eligible.Has(2))) || (LastPlanterGatherSlot=2)))
						{
						LastPlanterGatherSlot:= 3
						field := PlanterField3
						}

				; set gather field and settings
				fieldOverrideReason:="Manual Planter"
				FieldName:=field
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
				MPlanterGatherDetectionTime:=0

				; write currentfield to file as LastPlanterGatherSlot, to read on next loop
				IniWrite LastPlanterGatherSlot, "settings\nm_config.ini", "Planters", "LastPlanterGatherSlot"

				break
			}

		}

		;Gather in planters+ field override
		if((gotoPlanterField) && (PlanterMode = 2)){
			Loop 3{
				inverseIndex:=(4-A_Index)
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
	nm_updateAction("Gather")
	;close all menus
	nm_OpenMenu()
	;reset
	if(fieldOverrideReason="None" || fieldOverrideReason="Boost") {
		nm_Reset(2)
		;check if gathering field is boosted
		blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower", "Stump"]
		redBoosterFields:=["Rose", "Strawberry", "Mushroom", "Pepper"]
		mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
		otherFields:=["Coconut", "Mountain Top"]
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
	nm_gotoField(FieldName)
	nm_autoFieldBoost(FieldName)
	nm_fieldBoostGlitter()
	nm_PlanterTimeUpdate(FieldName)
	field_limit := DurationFromSeconds(FieldUntilMins*60, "mm:ss")
	ConvertGatherFlag := 1
	if(fieldOverrideReason="None") {
		nm_setStatus("Gathering", FieldName (GatherFieldBoosted ? " - Boosted" : "") "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else if(fieldOverrideReason="Quest") {
		if ((RotateQuest = "Polar") || (RotateQuest = "Black"))
			ConvertGatherFlag := 0
		if (IsSet(RotateQuest) && (%RotateQuest%QuestCheck = 1))
			nm_%RotateQuest%QuestProg()
		nm_setStatus("Gathering", RotateQuest . " " . fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	} else {
		nm_setStatus("Gathering", fieldOverrideReason . " - " . FieldName "`nLimit " field_limit " - " FieldPattern " - " FieldPatternSize " - " FieldSprinklerLoc " " FieldSprinklerDist)
	}
	;set sprinkler
	nm_setSprinkler(FieldName, FieldSprinklerLoc, FieldSprinklerDist)
	;rotate
	if (FieldRotateDirection != "None") {
		direction:=FieldRotateDirection
		sendinput "{" Rot%direction% " " FieldRotateTimes "}"
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
	;set FDC switch
	FDCEnabled := (FieldDriftCheck && (FieldPattern != "Stationary"))

	;gather loop
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100
	inactiveHoney:=0
	bypass:=0
	interruptReason := ""
	GatherStartTime:=gatherStart:=nowUnix()
	if(FieldPatternShift) {
		nm_setShiftLock(1)
	}
	while(((nowUnix()-gatherStart)<(FieldUntilMins*60)) || (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)<840) || (PFieldBoostExtend && (nowUnix()-GatherFieldBoostedStart)<1800 && (nowUnix()-LastGlitter)<900) || (PFieldGuidExtend && FieldGuidDetected && (nowUnix()-gatherStart)<(FieldUntilMins*60+PFieldGuidExtend*60) && (nowUnix()-GatherFieldBoostedStart)>900 && (nowUnix()-LastGlitter)>900) || (PPopStarExtend && HasPopStar && PopStarActive)){
		if !fieldPatternShift
			MouseMove windowX+350, windowY+GetYOffset()+100
		if(!DisableToolUse)
			Click "Down"
		nm_gather(FieldPattern, A_Index, FieldPatternSize, FieldPatternReps, FacingFieldCorner)

		while ((GetKeyState("F14") && (A_Index <= 3600)) || (A_Index = 1)) { ; timeout 3m
			;use glitter
			if (Mod(A_Index, 20) = 1) { ; every 1s
				if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && fieldOverrideReason="None") { ;between 9 and 15 mins (-minus an extra 15 seconds)
					Send "{" GlitterKey "}"
					LastGlitter:=nowUnix()
					IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
				}
				nm_autoFieldBoost(FieldName)
				nm_fieldBoostGlitter()
			}

			;high priority interrupts
			if (Mod(A_Index, 5) = 1) { ; every 250ms
				if DisconnectCheck() {
					interruptReason := "Disconnect"
					break
				}
				if youDied {
					interruptReason := "You Died!"
					break
				}
				if (VBState=1) {
					interruptReason := "Night"
					break
				}
			}
			if (Mod(A_Index, 20) = 1) { ; every 1s
				;full backpack
				if (BackpackPercentFiltered>=(FieldUntilPack-2)) {
					if((BackpackPercentFiltered>=(FieldUntilPack < 90 ? 98 : FieldUntilPack-2)) && ((nowUnix()-LastMicroConverter)>30) && ((MicroConverterKey!="none" && !PFieldBoosted) || (MicroConverterKey!="none" && PFieldBoosted && GatherFieldBoosted))) { ;30 seconds cooldown
						Send "{" MicroConverterKey "}"
						LastMicroConverter:=nowUnix()
						IniWrite LastMicroConverter, "settings\nm_config.ini", "Boost", "LastMicroConverter"
					} else if ((nowUnix()-LastMicroConverter)>10) {
						interruptReason := "Backpack exceeds " .  FieldUntilPack . " percent"
						;use glitter early if boosted and close to glitter time
						if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>600 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && (fieldOverrideReason="None" || fieldOverrideReason="Boost")){ ;between 10 and 15 mins
							Send "{" GlitterKey "}"
							LastGlitter:=nowUnix()
							IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
						}
						break
					}
				}
				;inactive honey
				if (BackpackPercentFiltered<FieldUntilPack) {
					inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
					if (inactiveHoney>30) {
						interruptReason := "Inactive Honey"
						GameFrozenCounter++
						break
					}
				}
				;boost is over
				if (fieldOverrideReason="Boost" && (nowUnix()-GatherFieldBoostedStart>900) && (nowUnix()-LastGlitter>900)) {
					interruptReason := "Boost Over"
					break
				}
				;mondo
				if nm_MondoInterrupt(){
					interruptReason := "Mondo"
					if (PMondoGuidComplete)
						PMondoGuidComplete:=0
					break
				}
			}
			if (Mod(A_Index, 100) = 1) { ; every 5s
				;quest interrupts
				if ((fieldOverrideReason="Quest") && IsSet(RotateQuest) && (%RotateQuest%QuestCheck = 1)) {
					nm_%RotateQuest%QuestProg()
					if(FieldPatternShift) {
						nm_setShiftLock(1)
					}
					;interrupt if
					if (thisfield!=QuestGatherField || %RotateQuest%QuestComplete){ ;change fields or this field is complete
						interruptReason := "Next Quest Step"
						break
					}
				}
			}

			;low priority interrupts
			if (Mod(A_Index, 20) = 1) {
				;continue if boosted
				if nm_GatherBoostInterrupt()
					continue
				;Manual planter gather interrupt
				if ((fieldOverrideReason="Manual Planter") && (PlanterMode = 1) && (MPlanterGatherA)) {
					;update current field planter progress every 2 minutes during planter gather
					If ((nowUnix()-MPlanterGatherDetectionTime)>120) {
						nm_PlanterTimeUpdate(FieldName, 0)
						MPlanterGatherDetectionTime := nowUnix()
					}
					;interrupt if
					if (((nowUnix() >= PlanterHarvestTime1) && (eligible.Has(1))) || ((nowUnix() >= PlanterHarvestTime2) && (eligible.Has(2))) || ((nowUnix() >= PlanterHarvestTime3) && (eligible.Has(3)))) {
						interruptReason := "Planter Harvest"
						break
					}
				}
				if nm_BugrunInterrupt() {
					interruptReason := "Kill Bugs"
					break
				}
				if nm_BeesmasInterrupt() {
					interruptReason := "Beesmas Machine"
					break
				}
				if nm_MemoryMatchInterrupt() {
					interruptReason := "Memory Match"
					break
				}
			}
			Sleep 50
		}

		Click "Up"
		if interruptReason {
			bypass := (interruptReason ~= "i)Disconnect|You Died!|Night|Inactive Honey")
			if (!bypass && InStr(patterns[FieldPattern], ";@NoInterrupt"))
				KeyWait "F14", "T180 L"
			break
		}
		(FDCEnabled) && nm_fieldDriftCompensation()
	}
	nm_endWalk()

	; set gather ended status
	gatherDuration := DurationFromSeconds(nowUnix()-gatherStart, "mm:ss")
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
			sendinput "{" Rot%direction% " " FieldRotateTimes "}"
		}
		;close quest log if necessary
		nm_OpenMenu()
		;check any planter progress
		nm_PlanterTimeUpdate(FieldName)
		;whirligig //todo: needs a major rework!
		if(FieldReturnType="walk") { ;walk back
			if((WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)){
				if(FieldName="sunflower"){
					Send "{" RotLeft " 2}"
				}
				else if(FieldName="dandelion"){
					Send "{" RotRight " 2}"
				}
				else if(FieldName="mushroom"){
					Send "{" RotLeft " 4}"
				}
				else if(FieldName="blue flower"){
					Send "{" RotRight " 2}"
				}
				else if(FieldName="spider"){
					Send "{" RotLeft " 4}"
				}
				else if(FieldName="strawberry"){
					Send "{" RotLeft " 2}"
				}
				else if(FieldName="bamboo"){
					Send "{" RotRight " 2}"
				}
				else if(FieldName="pineapple"){
					Send "{" RotLeft " 4}"
				}
				else if(FieldName="stump"){
					Send "{" RotRight " 2}"
				}
				else if(FieldName="pumpkin"){
					Send "{" RotLeft " 4}"
				}
				else if(FieldName="pine tree"){
					Send "{" RotLeft " 4}"
				}
				else if(FieldName="rose"){
					Send "{" RotLeft " 2}"
				}
				else if(FieldName="pepper"){
					Send "{" RotLeft " 2}"
				}
				Send "{" WhirligigKey "}"
				sleep (2500+KeyDelay)
				;Confirm hive
				send "{PgUp 4}"
				loop 8 {
					Send "{" ZoomOut "}"
				}
				loop 4
				{
					If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0))
					{
						send "{" RotRight " 4}{" RotDown " 4}"
						HiveConfirmed:=1
						LastWhirligig:=nowUnix()
						IniWrite LastWhirligig, "settings\nm_config.ini", "Boost", "LastWhirligig"
						Sleep 1000
						break
					}
					SendInput "{" RotRight " 4}"
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
						SendInput "{" SC_E " down}"
						Sleep 100
						SendInput "{" SC_E " up}"

						LastWreath:=nowUnix()
						IniWrite LastWreath, "settings\nm_config.ini", "Collect", "LastWreath"

						Sleep 4000

						;loot
						movement :=
						(
						nm_Walk(1, BackKey) "
						" nm_Walk(4.5, BackKey, LeftKey) "
						" nm_Walk(1, LeftKey) "
						Loop 3 {
							" nm_Walk(6, FwdKey) "
							" nm_Walk(1.25, RightKey) "
							" nm_Walk(6, BackKey) "
							" nm_Walk(1.25, RightKey) "
						}
						" nm_Walk(6, FwdKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()

						nm_setStatus("Collected", "Honey Wreath")
					}

					;walk back
					movement :=
					(
					nm_Walk(4, BackKey) "
					" nm_Walk(12, FwdKey, RightKey) "
					" nm_Walk(24, LeftKey) "
					" nm_Walk(6, BackKey, LeftKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
				}
				nm_findHiveSlot()
			}
		} else { ;reset back
			if ((WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="None" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)) {
				if(FieldName="sunflower"){
					loop 2 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="dandelion"){
					loop 2 {
						Send "{" RotRight "}"
					}
				}
				else if(FieldName="mushroom"){
					loop 4 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="blue flower"){
					loop 2 {
						Send "{" RotRight "}"
					}
				}
				else if(FieldName="spider"){
					loop 4 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="strawberry"){
					loop 2 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="bamboo"){
					loop 2 {
						Send "{" RotRight "}"
					}
				}
				else if(FieldName="pineapple"){
					loop 4 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="stump"){
					loop 2 {
						Send "{" RotRight "}"
					}
				}
				else if(FieldName="pumpkin"){
					loop 4 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="pine tree"){
					loop 4 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="rose"){
					loop 2 {
						Send "{" RotLeft "}"
					}
				}
				else if(FieldName="pepper"){
					loop 2 {
						Send "{" RotLeft "}"
					}
				}
				Send "{" WhirligigKey "}"
				sleep (2500+KeyDelay)
				;Confirm hive
				send "{PgUp 4}"
				loop 8 {
					Send "{" ZoomOut "}"
				}
				loop 4
				{
					If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0))
					{
						send "{" RotRight " 4}{" RotDown " 4}"
						HiveConfirmed:=1
						LastWhirligig:=nowUnix()
						IniWrite LastWhirligig, "settings\nm_config.ini", "Boost", "LastWhirligig"
						Sleep 1000
						break
					}
					SendInput "{" RotRight " 4}"
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
	utc_min := FormatTime(A_NowUTC, "m")
	if(CurrentField="mountain top" && (utc_min>=0 && utc_min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
}
nm_gather(pattern, index, patternsize:="M", reps:=1, facingcorner:=0){
	if !patterns.Has(pattern) {
		global FieldPattern
		nm_setStatus("Error", "Pattern '" pattern "' does not exist!`nChanged back to '" (FieldPattern := pattern := StandardFieldDefault[FieldName]["pattern"]) "'")
		IniWrite FieldDefault[FieldName]["pattern"] := pattern, "settings\field_config.ini", FieldName, "pattern"
	}

	size := (patternsize="XS") ? 0.25
		: (patternsize="S") ? 0.5
		: (patternsize="L") ? 1.5
		: (patternsize="XL") ? 2
		: 1 ; medium (default)

	DetectHiddenWindows 1
	if ((index = 1) || !WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid))
		nm_createWalk(patterns[pattern], "pattern",
			(
			'
			size:=' size '
			reps:=' reps '
			facingcorner:=' facingcorner '

			FieldName:="' FieldName '"
			FieldPattern:="' FieldPattern '"
			FieldPatternSize:="' FieldPatternSize '"
			FieldPatternReps:=' FieldPatternReps '
			FieldPatternShift:=' FieldPatternShift '
			FieldPatternInvertFB:=' FieldPatternInvertFB '
			FieldPatternInvertLR:=' FieldPatternInvertLR '
			FieldUntilMins:=' FieldUntilMins '
			FieldUntilPack:=' FieldUntilPack '
			FieldReturnType:="' FieldReturnType '"
			FieldSprinklerLoc:="' FieldSprinklerLoc '"
			FieldSprinklerDist:=' FieldSprinklerDist '
			FieldRotateDirection:="' FieldRotateDirection '"
			FieldRotateTimes:=' FieldRotateTimes '
			FieldDriftCheck:=' FieldDriftCheck '
			nm_CameraRotation(Dir, count) {
				Static LR := 0, UD := 0, init := OnExit((*) => send("{" Rot%(LR > 0 ? "Left" : "Right")% " " Mod(Abs(LR), 8) "}{" Rot%(UD > 0 ? "Up" : "Down")% " " Abs(UD) "}"), -1)
				send "{" Rot%Dir% " " count "}"
				Switch Dir,0 {
					Case "Left": LR -= count
					Case "Right": LR += count
					Case "Up": UD -= count
					Case "Down": UD += count
				}
			}
			'
			)
		) ; create / replace cycled walk script for this gather session
	else
		Send "{F13}" ; start new cycle
	DetectHiddenWindows 0

	if (KeyWait("F14", "D T5 L") = 0) ; wait for pattern start
		nm_endWalk()
}
nm_KeyVars() {
	return
	(
	'
	FwdKey:="' FwdKey '"
	LeftKey:="' LeftKey '"
	BackKey:="' BackKey '"
	RightKey:="' RightKey '"
	RotLeft:="' RotLeft '"
	RotRight:="' RotRight '"
	RotUp:="' RotUp '"
	RotDown:="' RotDown '"
	ZoomIn:="' ZoomIn '"
	ZoomOut:="' ZoomOut '"
	SC_E:="' SC_E '"
	SC_R:="' SC_R '"
	SC_L:="' SC_L '"
	SC_Esc:="' SC_Esc '"
	SC_Enter:="' SC_Enter '"
	SC_LShift:="' SC_LShift '"
	SC_Space:="' SC_Space '"
	SC_1:="' SC_1 '"
	TCFBKey:="' TCFBKey '"
	AFCFBKey:="' AFCFBKey '"
	TCLRKey:="' TCLRKey '"
	AFCLRKey:="' AFCLRKey '"
	'
	)
}
nm_Walk(tiles, MoveKey1, MoveKey2:=0){ ; string form of the function which holds MoveKey1 (and optionally MoveKey2) down for 'tiles' tiles, not to be confused with the pure form in nm_createWalk below
	return
	(
	'Send "{' MoveKey1 ' down}' (MoveKey2 ? '{' MoveKey2 ' down}"' : '"') '
	Walk(' tiles ')
	Send "{' MoveKey1 ' up}' (MoveKey2 ? '{' MoveKey2 ' up}"' : '"')
	)
}
nm_createWalk(movement, name:="", vars:="") ; this function generates the 'walk' code and runs it for a given 'movement' (AHK code string), using movespeed correction if 'NewWalk' is enabled and legacy movement otherwise
{
	; F13 is used by 'natro_macro.ahk' to tell 'walk' to complete a cycle
	; F14 is held down by 'walk' to indicate that the cycle is in progress, then released when the cycle is finished
	; F16 can be used by any script to pause / unpause the walk script, when unpaused it will resume from where it left off

	DetectHiddenWindows 1 ; allow communication with walk script

	if WinExist("ahk_pid " currentWalk.pid " ahk_class AutoHotkey")
		nm_endWalk()

	script :=
	(
	'
	#SingleInstance Off
	#NoTrayIcon
	ProcessSetPriority("AboveNormal")
	KeyHistory 0
	ListLines 0
	OnExit(ExitFunc)

	#Include "%A_ScriptDir%\lib"
	#Include "Gdip_All.ahk"
	#Include "Gdip_ImageSearch.ahk"
	#Include "HyperSleep.ahk"
	#Include "Roblox.ahk"
	'
	)

	; #Include Walk.ahk performs most of the initialisation, i.e. creating bitmaps and storing the necessary functions
	; MoveSpeedNum must contain the exact in-game movespeed without buffs so the script can calculate the true base movespeed

	. (NewWalk ?
	(
	'
	#Include "Walk.ahk"
	
	movespeed := ' MoveSpeedNum '
	both            := (Mod(movespeed*1000, 1265) = 0) || (Mod(Round((movespeed+0.005)*1000), 1265) = 0)
	hasty_guard     := (both || Mod(movespeed*1000, 1100) < 0.00001)
	gifted_hasty    := (both || Mod(movespeed*1000, 1150) < 0.00001)
	base_movespeed  := round(movespeed / (both ? 1.265 : (hasty_guard ? 1.1 : (gifted_hasty ? 1.15 : 1))), 0)
	'
	) :
	(
	'
	(bitmaps := Map()).CaseSense := 0
	pToken := Gdip_Startup()
	Walk(param, *) => HyperSleep(4000/' MoveSpeedNum '*param)
	'
	))

	. (
	(
	'
	offsetY := ' GetYOffset() '

	' nm_KeyVars() '
	' vars '

	start()
	return

	nm_Walk(tiles, MoveKey1, MoveKey2:=0)
	{
		Send "{" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "")
		' (NewWalk ? 'Walk(tiles)' : ('HyperSleep(4000/' MoveSpeedNum '*tiles)')) '
		Send "{" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "")
	}

	F13::
		start(hk?)
		{
			Send "{F14 down}"
			' movement '
			Send "{F14 up}"
		}

	F16::
	{
		static key_states := Map(LeftKey,0, RightKey,0, FwdKey,0, BackKey,0, "LButton",0, "RButton",0, SC_E,0)
		if A_IsPaused
		{
			for k,v in key_states
				if (v = 1)
					Send "{" k " down}"
		}
		else
		{
			for k,v in key_states
			{
				key_states[k] := GetKeyState(k)
				Send "{" k " up}"
			}
		}
		Pause -1
	}

	ExitFunc(*)
	{
		Send "{' LeftKey ' up}{' RightKey ' up}{' FwdKey ' up}{' BackKey ' up}{' SC_Space ' up}{F14 up}{' SC_E ' up}"
		try Gdip_Shutdown(pToken)
	}
	'
	)) ; this is just ahk code, it will be executed as a new script

	shell := ComObject("WScript.Shell")
	exec := shell.Exec('"' exe_path64 '" /script /force *')
	exec.StdIn.Write(script), exec.StdIn.Close()

	if WinWait("ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2) {
		DetectHiddenWindows 0
		currentWalk.pid := exec.ProcessID, currentWalk.name := name
		return 1
	}
	else {
		DetectHiddenWindows 0
		return 0
	}
}
nm_endWalk() ; this function ends the walk script
{
	global currentWalk
	DetectHiddenWindows 1
	try WinClose "ahk_class AutoHotkey ahk_pid " currentWalk.pid
	DetectHiddenWindows 0
	currentWalk.pid := currentWalk.name := ""
	; if issues, we can check if closed, else kill and force keys up
}
nm_loot(length, reps, direction, tokenlink:=0){ ; length in tiles instead of ms (old)
	global FwdKey, LeftKey, BackKey, RightKey, KeyDelay, bitmaps

	movement :=
	(
	'
	loop ' reps ' {
		' nm_Walk(length, FwdKey) '
		' nm_Walk(1.5, %direction%Key) '
		' nm_Walk(length, BackKey) '
		' nm_Walk(1.5, %direction%Key) '
	}
	'
	)

	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"

	if (tokenlink = 0) ; wait for pattern finish
		KeyWait "F14", "T" length*reps " L"
	else ; wait for token link or pattern finish
	{
		GetRobloxClientPos()
		Sleep 1000 ; primary delay, only accept token links after this
		DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
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
			Sleep 50
			DllCall("GetSystemTimeAsFileTime","int64p",&n)
		}
	}
	nm_endWalk()
}
nm_convert(){
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey, LastEnzymes
		, ConvertStartTime, TotalConvertTime, SessionConvertTime
		, BackpackPercent, BackpackPercentFiltered
		, PFieldBoosted, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, GlitterKey
		, GameFrozenCounter, LastConvertBalloon, ConvertBalloon, ConvertMins, HiveBees, ConvertDelay, ConvertGatherFlag

	if ((VBState = 1) || nm_MondoInterrupt())
		return

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|400|120")
	if ((HiveConfirmed = 0) || (state = "Converting") || (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 2, , 2) = 1) {
		SendInput "{" SC_E " down}"
		Sleep 100
		SendInput "{" SC_E " up}"
	}
	Gdip_DisposeImage(pBMScreen)
	ConvertStartTime:=nowUnix()
	inactiveHoney:=0
	ballooncomplete:=0
	;empty pack
	if (BackpackPercentFiltered > 0) {
		nm_setStatus("Converting", "Backpack")
		while (((BackpackConvertTime := nowUnix()-ConvertStartTime)<300) && (BackpackPercentFiltered>0)) { ;5 mins
			Sleep 1000
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
				GameFrozenCounter++
				return
			}
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
			}
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
				|| ((Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1) && (ballooncomplete:=1))) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
		}
		duration := DurationFromSeconds(BackpackConvertTime, "mm:ss")
		nm_setStatus("Converting", "Backpack Emptied`nTime: " duration)
	}
	;empty balloon
	if((ConvertBalloon="always") || (ConvertBalloon="Every" && (nowUnix() - LastConvertBalloon)>(ConvertMins*60)) || (ConvertBalloon="Gather" && (ConvertGatherFlag=1 || (nowUnix() - LastConvertBalloon)>2700))) {
		ConvertGatherFlag := 0
		;balloon check
		strikes:=0
		while ((strikes <= 5) && (A_Index <= 50)) {
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
			if ((ballooncomplete = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1)) {
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Converting", "Balloon Refreshed")
				IniWrite LastConvertBalloon:=nowUnix(), "settings\nm_config.ini", "Settings", "LastConvertBalloon"
				PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
				strikes := 10
				break
			}
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) != 1)
				strikes++
			Gdip_DisposeImage(pBMScreen)
			Sleep 100
		}
		if (strikes <= 5) {
			BalloonStartTime:=nowUnix()
			inactiveHoney:=0
			nm_setStatus("Converting", "Balloon")
			while((BalloonConvertTime := nowUnix()-BalloonStartTime)<600) { ;10 mins
				nm_AutoFieldBoost(currentField)
				if(AFBuseGlitter || AFBuseBooster) {
					nm_setStatus("Interupted", "AFB")
					return
				}
				inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
				if(((EnzymesKey!="none") && (!PFieldBoosted || (PFieldBoosted && GatherFieldBoosted))) && (nowUnix()-LastEnzymes)>600 && (inactiveHoney = 0)) {
					Send "{" EnzymesKey "}"
					LastEnzymes:=nowUnix()
					IniWrite LastEnzymes, "settings\nm_config.ini", "Boost", "LastEnzymes"
				}
				if (BalloonConvertTime>60 && inactiveHoney>30) {
					nm_setStatus("Interupted", "Inactive Honey")
					GameFrozenCounter++
					return
				}
				if (disconnectcheck()) {
					return
				}
				if ((PFieldBoosted = 1) && (nowUnix()-GatherFieldBoostedStart)>780 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
					nm_setStatus("Interupted", "Field Boosted")
					return
				}
				GetRobloxClientPos(hwnd)
				if (Mod(A_Index, 30) = 0) {
					MouseMove windowX+windowWidth-30, windowY+offsetY+16
					click
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|" windowWidth//2+200 "|" windowHeight-offsetY-36)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , 400, 120, 2, , 2) = 1) {
					SendInput "{" SC_E " down}"
					Sleep 100
					SendInput "{" SC_E " up}"
				}
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , 400, 120, 2, , 6) = 0)
					|| (Gdip_ImageSearch(pBMScreen, bitmaps["hiveballoon"], , windowWidth//2, windowHeight-offsetY-36-400, , , 40, , 3) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					ballooncomplete:=1
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 1000
			}
			if(ballooncomplete){
				duration := DurationFromSeconds(BalloonConvertTime, "mm:ss")
				nm_setStatus("Converting", "Balloon Refreshed`nTime: " duration)
				IniWrite LastConvertBalloon:=nowUnix(), "settings\nm_config.ini", "Settings", "LastConvertBalloon"
				PostSubmacroMessage("background", 0x5554, 6, LastConvertBalloon)
			}
		}
	}
	TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
	SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
	ConvertStartTime:=0

	;hive wait
	;Sleep 500+((5-Min(HiveBees, 50)/10)**0.5)*10000
	Sleep 500+(IsNumber(ConvertDelay) ? ConvertDelay : 0)*1000
}
nm_setSprinkler(field, loc, dist){
	global FwdKey, LeftKey, BackKey, RightKey, SC_1, SC_Space, KeyDelay, SprinklerType, MoveSpeedNum

	if (SprinklerType = "None")
		return

	;field dimensions
	switch field, 0
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
		Sleep 1000
	;set sprinkler(s)
	if(SprinklerType="Supreme" || SprinklerType="Basic") {
		Send "{" SC_1 "}"
		return
	} else {
		nm_JumpSprinkler(1)
	}
	if(SprinklerType="Silver" || SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, BackKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		}
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
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
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
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
		DllCall("Sleep","UInt",500)
		nm_JumpSprinkler()
		if(InStr(loc, "Left")){
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, RightKey)
		}
	}
}
nm_JumpSprinkler(resetDelay := 0){
	static JumpDelay := 200
	if resetDelay
		JumpDelay := 200

	GetRobloxClientPos()
	success := 0
	Loop 3 {
		Send "{" SC_Space " down}"
		Sleep JumpDelay
		Send "{" SC_1 "}{" SC_Space " up}"
		Sleep 500
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth-356 "|" windowY+windowHeight-326 "|340|300")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["standing"], , , , , , 20) = 1) { ; jumped too high
			JumpDelay := Max(JumpDelay - 50, 100)
		} else if (Gdip_ImageSearch(pBMScreen, bitmaps["thisclose"], , , , , , 20) = 1) { ; not high enough
			JumpDelay := Min(JumpDelay + 50, 500)
		} else {
			success := 1
		}
		Gdip_DisposeImage(pBMScreen)
		Sleep 600 - JumpDelay
		if (success = 1)
			break
	}

	return success
}
nm_fieldDriftCompensation(){
	global FwdKey, LeftKey, BackKey, RightKey, DisableToolUse

	GetRobloxClientPos()
	winUp := Floor(windowHeight / 2.14), winDown := Floor(windowHeight / 1.88)
	winLeft := Floor(windowWidth / 2.14), winRight := Floor(windowWidth / 1.88)

	hmove := vmove := 0
	if ((nm_LocateSprinkler(&x, &y) = 1) && !(x >= winLeft && x <= winRight && y >= winUp && y <= winDown)) {
		if (!DisableToolUse)
			click "down"
		if ((x < winleft) && (hmove := LeftKey))
			sendinput "{" LeftKey " down}"
		else if ((x > winRight) && (hmove := RightKey))
			sendinput "{" RightKey " down}"
		if ((y < winUp) && (vmove := FwdKey))
			sendinput "{" FwdKey " down}"
		else if ((y > winDown) && (vmove := BackKey))
			sendinput "{" BackKey " down}"
		while (hmove || vmove) {
			if (((hmove = LeftKey) && (x >= winLeft)) || ((hmove = RightKey) && (x <= winRight))) {
				sendinput "{" hmove " up}"
				hmove := ""
			}
			if (((vmove = FwdKey) && (y >= winUp)) || ((vmove = BackKey) && (y <= winDown))) {
				sendinput "{" vmove " up}"
				vmove := ""
			}
			Sleep 20
			if ((A_Index >= 300)) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				break
			}
			if (nm_LocateSprinkler(&x, &y) = 0) {
				sendinput "{" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}"
				Loop 25 {
					Sleep 20
					if (nm_LocateSprinkler(&x, &y) = 1) {
						sendinput (hmove ? "{" hmove " down} " : "") (vmove ? "{" vmove " down} " : "")
						continue 2
					}
				}
				break
			}
		}
		click "up"
	}
}
nm_LocateSprinkler(&X:="", &Y:=""){ ; find client coordinates of approximately closest saturator to player/center
	global bitmaps, sprinklerImages
	n := sprinklerImages.Length

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" (windowY + offsetY + 75) "|" (hWidth := windowWidth) "|" (hHeight := windowHeight - offsetY - 75) "|")

	Gdip_LockBits(pBMScreen, 0, 0, hWidth, hHeight, &hStride, &hScan, &hBitmapData, 1)
	hWidth := NumGet(hBitmapData, 0, "UInt"), hHeight := NumGet(hBitmapData, 4, "UInt")

	local n1width, n1height, n1Stride, n1Scan, n1BitmapData
		, n1width, n1height, n2Stride, n2Scan, n2BitmapData
		, n1width, n1height, n3Stride, n3Scan, n3BitmapData
	for i,k in sprinklerImages
	{
		Gdip_GetImageDimensions(bitmaps[k], &n%i%Width, &n%i%Height)
		Gdip_LockBits(bitmaps[k], 0, 0, n%i%Width, n%i%Height, &n%i%Stride, &n%i%Scan, &n%i%BitmapData)
		n%i%Width := NumGet(n%i%BitmapData, 0, "UInt"), n%i%Height := NumGet(n%i%BitmapData, 4, "UInt")
	}

	d := 11 ; divisions (odd positive integer such that w,h > n%i%Width,n%i%Height for all i<=n)
	m := d//2 ; midpoint of d (along with m + 1), used frequently in calculations
	v := 50 ; variation
	w := hWidth//d, h := hHeight//d

	; to search from centre (approximately), we will split the rectangle like a pinwheel configuration and search outwards (notice SearchDirection)
	Loop m + 1
	{
		if (A_Index = 1)
		{
			; initial rectangle (center)
			d1 := m, d2 := m + 1
			OuterX1 := d1 * w, OuterX2 := d2 * w
			OuterY1 := d1 * h, OuterY2 := d2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 1, 1) > 0)
					break 2
		}
		else
		{
			; upper-right
			dx1 := m + 2 - A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m + 2 - A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 2, 1) > 0)
					break 2

			; lower-right
			dx1 := m - 1 + A_Index, dx2 := m + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 2 - A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 5, 1) > 0)
					break 2

			; lower-left
			dx1 := m + 1 - A_Index, dx2 := m - 1 + A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m - 1 + A_Index, dy2 := m + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 4, 1) > 0)
					break 2

			; upper-left
			dx1 := m + 1 - A_Index, dx2 := m + 2 - A_Index
			OuterX1 := dx1 * w, OuterX2 := dx2 * w
			dy1 := m + 1 - A_Index, dy2 := m - 1 + A_Index
			OuterY1 := dy1 * h, OuterY2 := dy2 * h
			Loop n
				if (Gdip_MultiLockedBitsSearch(hStride, hScan, hWidth, hHeight, n%A_Index%Stride, n%A_Index%Scan, n%A_Index%Width, n%A_Index%Height, &pos, OuterX1, OuterY1, OuterX2-n%A_Index%Width+1, OuterY2-n%A_Index%Height+1, v, 7, 1) > 0)
					break 2
		}
	}

	Gdip_UnlockBits(pBMScreen,&hBitmapData)
	for i,k in sprinklerImages
		Gdip_UnlockBits(bitmaps[k],&n%i%BitmapData)
	Gdip_DisposeImage(pBMScreen)

	if pos
	{
		x := SubStr(pos, 1, InStr(pos, ",") - 1), y := 75 + SubStr(pos, InStr(pos, ",") + 1)
		return 1
	}
	else
	{
		x := "", y := ""
		return 0
	}
}
;move function //todo: deprecated! replace throughout script with nm_Walk
nm_Move(MoveTime, MoveKey1, MoveKey2:="None"){
	PrevKeyDelay:=A_KeyDelay
	SetKeyDelay 5
	Send "{" MoveKey1 " down}"
	if(MoveKey2!="None")
		Send "{" MoveKey2 " down}"
	DllCall("Sleep","UInt",MoveTime)
	Send "{" MoveKey1 " up}"
	if(MoveKey2!="None")
		Send "{" MoveKey2 " up}"
	SetKeyDelay PrevKeyDelay
}
CloseRoblox()
{
	; if roblox exists, activate it and send Esc+L+Enter
	if (hwnd := GetRobloxHWND())
	{
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) ; requirement for L to activate "Leave"
		{
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 250+KeyDelay
			send "{" SC_Esc "}{" SC_L "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
		}
		try WinClose "Roblox"
		Sleep 500
		try WinClose "Roblox"
		Sleep 4500 ;Delay to prevent Roblox Error Code 264
	}
	; kill any remnant processes
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
		ProcessClose p.ProcessID
}
DisconnectCheck(testCheck := 0)
{
	global LastClock, LastGingerbread, HiveSlot, PrivServer, TotalDisconnects, SessionDisconnects, ReconnectMethod, PublicFallback, resetTime
		, PlanterName1, PlanterName2, PlanterName3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, MacroState, ReconnectDelay
		, FallbackServer1, FallbackServer2, FallbackServer3, beesmasActive
	static ServerLabels := Map(0,"Public Server", 1,"Private Server", 2,"Fallback Server 1", 3,"Fallback Server 2", 4,"Fallback Server 3")

	; return if not disconnected or crashed
	ActivateRoblox()
	GetRobloxClientPos()
	if ((windowWidth > 0) && !WinExist("Roblox Crash")) {
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY+windowHeight//2 "|200|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) != 1) {
			Gdip_DisposeImage(pBMScreen)
			return 0
		}
		Gdip_DisposeImage(pBMScreen)
	}

	; end any residual movement and set reconnect start time
	Click "Up"
	nm_endWalk()
	ReconnectStart := nowUnix()
	nm_updateAction("Reconnect")

	; wait for any requested delay time (e.g. from remote control or daily reconnect)
	if (ReconnectDelay) {
		nm_setStatus("Waiting", ReconnectDelay " seconds before Reconnect")
		Sleep 1000*ReconnectDelay
		ReconnectDelay := 0
	}
	else if (MacroState = 2) {
		TotalDisconnects:=TotalDisconnects+1
		SessionDisconnects:=SessionDisconnects+1
		PostSubmacroMessage("StatMonitor", 0x5555, 6, 1)
		IniWrite TotalDisconnects, "settings\nm_config.ini", "Status", "TotalDisconnects"
		IniWrite SessionDisconnects, "settings\nm_config.ini", "Status", "SessionDisconnects"
		nm_setStatus("Disconnected", "Reconnecting")
	}

	; obtain link codes from Private Server and Fallback Server links
	linkCodes := Map()
	for k,v in ["PrivServer", "FallbackServer1", "FallbackServer2", "FallbackServer3"] {
		if (%v% && (StrLen(%v%) > 0)) {
			if RegexMatch(%v%, "i)(?<=privateServerLinkCode=)(.{32})", &linkCode)
				linkCodes[k] := linkCode[0]
			else
				nm_setStatus("Error", ServerLabels[k] " Invalid")
		}
	}

	; main reconnect loop
	Loop {
		;Decide Server
		server := ((A_Index <= 20) && linkCodes.Has(n := (A_Index-1)//5 + 1)) ? n : ((PublicFallback = 0) && (n := ObjMinIndex(linkcodes))) ? n : 0

		;Wait For Success
		i := A_Index, success := 0
		Loop 5 {
			;START
			switch (ReconnectMethod = "Browser") ? 0 : Mod(i, 5) {
				case 1,2:
				;Close Roblox
				CloseRoblox()
				;Run Server Deeplink
				nm_setStatus("Attempting", ServerLabels[server])
				try Run '"roblox://placeID=1537690962' (server ? ("&linkCode=" linkCodes[server]) : "") '"'

				case 3,4:
				;Run Server Deeplink (without closing)
				nm_setStatus("Attempting", ServerLabels[server])
				try Run '"roblox://placeID=1537690962' (server ? ("&linkCode=" linkCodes[server]) : "") '"'

				default:
				if server {
					;Close Roblox
					CloseRoblox()
					;Run Server Link (legacy method w/ browser)
					nm_setStatus("Attempting", ServerLabels[server] " (Browser)")
					if ((success := LegacyReconnect(linkCodes[server], i)) = 1) {
						if (ReconnectMethod != "Browser") {
							ReconnectMethod := "Browser"
							nm_setStatus("Warning", "Deeplink reconnect failed, switched to legacy reconnect (browser) for this session!")
						}
						break
					}
					else
						continue 2
				} else {
					;Close Roblox
					(i = 1) && CloseRoblox()
					;Run Server Link (spam deeplink method)
					try Run '"roblox://placeID=1537690962"'
				}
			}
			;STAGE 1 - wait for Roblox window
			Loop 240 {
				if GetRobloxHWND() {
					ActivateRoblox()
					nm_setStatus("Detected", "Roblox Open")
					break
				}
				if (A_Index = 240) {
					nm_setStatus("Error", "No Roblox Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 4 mins, wait for any Roblox update to finish
			}
			;STAGE 2 - wait for loading screen (or loaded game)
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if (Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Open")
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					nm_setStatus("Error", "No BSS Found`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
			;STAGE 3 - wait for loaded game
			Loop 180 {
				ActivateRoblox()
				if !GetRobloxClientPos() {
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+30 "|" windowWidth "|" windowHeight-30)
				if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , 150, 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , 150, 2) = 1)) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Detected", "Game Loaded")
					success := 1
					break 2
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					nm_setStatus("Warning", "Disconnected during Reconnect")
					continue 2
				}
				Gdip_DisposeImage(pBMScreen)
				if (A_Index = 180) {
					nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
					break 2
				}
				Sleep 1000 ; timeout 3 mins, slow loading
			}
		}

		;Successful Reconnect
		if (success = 1)
		{
			ActivateRoblox()
			GetRobloxClientPos()
			MouseMove windowX + windowWidth//2, windowY + windowHeight//2
			duration := DurationFromSeconds(ReconnectDuration := (nowUnix() - ReconnectStart), "mm:ss")
			nm_setStatus("Completed", "Reconnect`nTime: " duration " - Attempts: " i)
			Sleep 500

			LastClock:=nowUnix()
			IniWrite LastClock, "settings\nm_config.ini", "Collect", "LastClock"
			if (beesmasActive)
			{
				LastGingerbread += ReconnectDuration ? ReconnectDuration : 300
				IniWrite LastGingerbread, "settings\nm_config.ini", "Collect", "LastGingerbread"
			}
			Loop 3 {
				PlanterHarvestTime%A_Index% += PlanterName%A_Index% ? (ReconnectDuration ? ReconnectDuration : 300) : 0
				IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
			}

			if (server > 1) ; swap PrivServer and FallbackServer - original PrivServer probably has an issue
			{
				n := server - 1
				temp := PrivServer, PrivServer := FallbackServer%n%, FallbackServer%n% := temp
				MainGui["PrivServer"].Value := PrivServer
				MainGui["FallbackServer" n].Value := FallbackServer%n%
				IniWrite PrivServer, "settings\nm_config.ini", "Settings", "PrivServer"
				IniWrite FallbackServer%n%, "settings\nm_config.ini", "Settings", "FallbackServer" n
				PostSubmacroMessage("Status", 0x5553, 10, 6)
			}
			PostSubmacroMessage("Status", 0x5552, 221, (server = 0))

			if (testCheck || (nm_claimHiveSlot() = 1))
				return 1
		}
	}
}
LegacyReconnect(linkCode, i)
{
	global bitmaps
	static cmd := Buffer(512), init := (DllCall("shlwapi\AssocQueryString", "Int",0, "Int",1, "Str","http", "Str","open", "Ptr",cmd.Ptr, "IntP",512),
		DllCall("Shell32\SHEvaluateSystemCommandTemplate", "Ptr",cmd.Ptr, "PtrP",&pEXE:=0,"Ptr",0,"PtrP",&pPARAMS:=0))
	, exe := (pEXE > 0) ? StrGet(pEXE) : ""
	, params := (pPARAMS > 0) ? StrGet(pPARAMS) : ""

	url := "https://www.roblox.com/games/1537690962?privateServerLinkCode=" linkCode
	if ((StrLen(exe) > 0) && (StrLen(params) > 0))
		ShellRun(exe, StrReplace(params, "%1", url)), success := 0
	else
		Run '"' url '"'

	Loop 1 {
		;STAGE 1 - wait for Roblox Launcher
		Loop 120 {
			if WinExist("Roblox") {
				break
			}
			if (A_Index = 120) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 2 mins, slow internet / not logged in
		}
		;STAGE 2 - wait for RobloxPlayerBeta.exe
		Loop 180 {
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate
				nm_setStatus("Detected", "Roblox Open")
				break
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, wait for any Roblox update to finish
		}
		;STAGE 3 - wait for loading screen (or loaded game)
		Loop 180 {
			if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) {
				WinActivate
				GetRobloxClientPos(hwnd)
			} else {
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
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
				Sleep 1000
				break 2
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No BSS Found`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 3 mins, slow loading
		}
		;STAGE 4 - wait for loaded game
		Loop 240 {
			if (hwnd := WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")) {
				WinActivate
				GetRobloxClientPos(hwnd)
			} else {
				nm_setStatus("Error", "Disconnected during Reconnect`nRetry: " i)
				Sleep 1000
				break 2
			}
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
				Sleep 1000
				break 2
			}
			if (A_Index = 240) {
				nm_setStatus("Error", "BSS Load Timeout`nRetry: " i)
				Sleep 1000
				break 2
			}
			Sleep 1000 ; timeout 4 mins, slow loading
		}
	}
	;Close Browser Tab
	for hwnd in WinGetList(,, "Program Manager")
	{
		p := WinGetProcessName("ahk_id " hwnd)
		if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
			continue ; skip roblox and AHK windows
		title := WinGetTitle("ahk_id " hwnd)
		if (title = "")
			continue ; skip empty title windows
		s := WinGetStyle("ahk_id " hwnd)
		if ((s & 0x8000000) || !(s & 0x10000000))
			continue ; skip NoActivate and invisible windows
		s := WinGetExStyle("ahk_id " hwnd)
		if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
			continue ; skip ToolWindow and AlwaysOnTop windows
		try
		{
			WinActivate "ahk_id " hwnd
			Sleep 500
			Send "^{w}"
		}
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
	shellWindows := ComObject("Shell.Application").Windows
	desktop := shellWindows.FindWindowSW(0, 0, 8, 0, 1) ; SWC_DESKTOP, SWFO_NEEDDISPATCH

	; Retrieve top-level browser object.
	tlb := ComObjQuery(desktop,
		"{4C96BE40-915C-11CF-99D3-00AA004AE837}", ; SID_STopLevelBrowser
		"{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser

	; IShellBrowser.QueryActiveShellView -> IShellView
	ComCall(15, tlb, "ptr*", sv := ComValue(13, 0)) ; VT_UNKNOWN

	; Define IID_IDispatch.
	NumPut("int64", 0x20400, "int64", 0x46000000000000C0, IID_IDispatch := Buffer(16))

	; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
	ComCall(15, sv, "uint", 0, "ptr", IID_IDispatch, "ptr*", sfvd := ComValue(9, 0)) ; VT_DISPATCH

	; Get Shell object.
	shell := sfvd.Application

	; IShellDispatch2.ShellExecute
	shell.ShellExecute(prms*)
}
nm_claimHiveSlot(){
	global KeyDelay, FwdKey, RightKey, LeftKey, BackKey, ZoomOut, HiveSlot, HiveConfirmed, SC_E, SC_Esc, SC_R, SC_Enter, bitmaps, ReconnectMessage
	static LastNatroSoBroke := 1

	GetBitmap() {
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
		while ((A_Index <= 20) && (Gdip_ImageSearch(pBMScreen, bitmaps["FriendJoin"], , , , , , 6) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX+windowWidth//2-3, windowY+24
			Click
			MouseMove windowX+350, windowY+offsetY+100
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
		}
		return pBMScreen
	}

	Loop 5
	{
		ActivateRoblox()
		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100

		;reset
		if (A_Index > 1)
		{
			resetTime:=nowUnix()
			PostSubmacroMessage("background", 0x5554, 1, resetTime)
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 250+KeyDelay
			send "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				GetRobloxClientPos(hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, bitmaps["emptyhealth"], , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000
		}

		;go to slot 1
		Sleep 500
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		send "{" ZoomOut " 8}"

		movement :=
		(
		'Send "{' RightKey ' down}"
		Walk(4)
		Send "{' FwdKey ' down}"
		Walk(20)
		Send "{' RightKey ' up}{' FwdKey ' up}"'
		)
		nm_createWalk(movement)
		KeyWait "F14", "D T5 L"
		KeyWait "F14", "T20 L"
		nm_endWalk()

		;check slots 1 to old HiveSlot
		slots := Map()
		movement := nm_Walk(9.2, LeftKey)
		Loop HiveSlot
		{
			if (A_Index > 1)
			{
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()
			}

			Sleep 500
			pBMScreen := GetBitmap()
			if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1)
				slots[A_Index] := 1
			Gdip_DisposeImage(pBMScreen)
		}

		if (slots.Has(HiveSlot) && (slots[HiveSlot] = 1))
			break
		else
		{
			if ((slot := ObjMinIndex(slots)) > 0)
			{
				movement := nm_Walk((HiveSlot - slot) * 9.2, RightKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T20 L"
				nm_endWalk()

				Sleep 500
				pBMScreen := GetBitmap()
				if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1) {
					Gdip_DisposeImage(pBMScreen)
					HiveSlot := slot
					break
				}
				Gdip_DisposeImage(pBMScreen)
			}
			else {
				Loop (6 - HiveSlot)
				{
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T20 L"
					nm_endWalk()

					Sleep 500
					pBMScreen := GetBitmap()
					if (Gdip_ImageSearch(pBMScreen, bitmaps["claimhive"], , , , , , 2, , 6) = 1) {
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

	SendInput "{" SC_E " down}"
	Sleep 100
	SendInput "{" SC_E " up}"
	HiveConfirmed := 1
	;update hive slot
	MainGui["HiveSlot"].Text := HiveSlot
	IniWrite HiveSlot, "settings\nm_config.ini", "Settings", "HiveSlot"
	nm_setStatus("Claimed", "Hive Slot " . HiveSlot)
	;;;;; Natro so broke :weary:
	if(ReconnectMessage && ((nowUnix()-LastNatroSoBroke)>3600)) { ;limit to once per hour
		LastNatroSoBroke:=nowUnix()
		Send "{Text}/[" A_Hour ":" A_Min "] Natro so broke :weary:`n"
		sleep 250
	}
	MouseMove windowX+350, windowY+offsetY+100

	return 1
}
nm_activeHoney(){
	global HiveBees, GameFrozenCounter
	if (hwnd := GetRobloxHWND()) {
		GetRobloxClientPos(hwnd)
		offsetY := GetYOffset(hwnd)
		x1 := windowX + windowWidth//2 - 90
		y1 := windowY + offsetY
		try
			result := PixelSearch(&bx2, &by2, x1, y1, x1+70, y1+34, 0xFFE280, 20)
		catch
			result := 0
		if (result = 1){
			GameFrozenCounter:=0
			return 1
		} else {
			if(HiveBees<25){
				x1 := windowX + windowWidth//2 + 210
				y1 := windowY + offsetY
				try
					result := PixelSearch(&bx2, &by2, x1, y1, x1+70, y1+34, 0xFFFFFF, 20)
				catch
					result := 0
				return result
			} else {
				return 0
			}
		}
	} else {
		return 0
	}
}
nm_searchForE(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, bitmaps

	movement :=
	(
	'
	Loop 8
	{
		i := A_Index
		Loop 2
		{
			Send "{' FwdKey ' down}"
			Walk(3*i)
			Send "{' FwdKey ' up}{' RotRight ' 2}"
		}
	}
	'
	)
	nm_createWalk(movement)
	KeyWait "F14", "D T5 L"

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	GetRobloxClientPos(hwnd)
	MouseMove windowX+350, windowY+offsetY+100
	success := 0
	DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
	n := s, f := s+90*10000000 ; 90 second timeout
	while (n < f && GetKeyState("F14"))
	{
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
		{
			success := 1, Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		DllCall("GetSystemTimeAsFileTime","int64p",&n)
	}
	nm_endWalk()

	if (success = 1) ; check that planter was not overrun, at the expense of a small delay
	{
		Loop 10
		{
			if (A_Index = 10)
			{
				success := 0
				break
			}
			Sleep 500
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1)
			{
				Gdip_DisposeImage(pBMScreen)
				break
			}
			else
			{
				movement := nm_Walk(1.5, BackKey)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T5 L"
				nm_endWalk()
			}
			Gdip_DisposeImage(pBMScreen)
		}
	}
	return success
}
nm_boostBypassCheck() => 0 ; always returns 0 for now: no field boost bypass implemented
nm_ViciousCheck(){
	global VBState ;0=no VB, 1=searching for VB, 2=VB found
	global VBLastKilled, TotalViciousKills, SessionViciousKills, KeyDelay
	Send "{Text}/`n"
	Sleep 250
	killed := 0
	if(VBState=1){
		if(nm_imgSearch("VBfoundSymbol2.png", 50, "highright")[1]=0){
			VBState:=2
			VBLastKilled:=nowUnix()
			;send VBState to background.ahk
			PostSubmacroMessage("background", 0x5554, 3, VBState)
			PostSubmacroMessage("background", 0x5554, 5, VBLastKilled)
			;nm_setStatus("VBState " . VBState, " <1>")
			IniWrite VBLastKilled, "settings\nm_config.ini", "Collect", "VBLastKilled"
		}
		;check if VB was already killed by someone else
		if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
			VBState:=0
			VBLastKilled:=nowUnix()
			;send VBState to background.ahk
			PostSubmacroMessage("background", 0x5554, 3, VBState)
			PostSubmacroMessage("background", 0x5554, 5, VBLastKilled)
			IniWrite VBLastKilled, "settings\nm_config.ini", "Collect", "VBLastKilled"
			;nm_setStatus("VBState " . VBState, " <2>")
			nm_setStatus("Defeated", "Vicious Bee - Other Player")
		}
	}
	if(VBState=2){
	;temp:=(nowUnix()-VBLastKilled)
		if((nowUnix()-VBLastKilled)<(600)) { ;it has been less than 10 minutes since VB was found
			if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
				VBState:=0
				VBLastKilled:=nowUnix()
				;send VBState to background.ahk
				PostSubmacroMessage("background", 0x5554, 3, VBState)
				PostSubmacroMessage("background", 0x5554, 5, VBLastKilled)
				IniWrite VBLastKilled, "settings\nm_config.ini", "Collect", "VBLastKilled"
				;nm_setStatus("VBState " . VBState, " <3>")
				;nm_setStatus("Defeated", "VB")
				TotalViciousKills:=TotalViciousKills+1
				SessionViciousKills:=SessionViciousKills+1
				PostSubmacroMessage("StatMonitor", 0x5555, 2, 1)
				IniWrite TotalViciousKills, "settings\nm_config.ini", "Status", "TotalViciousKills"
				IniWrite SessionViciousKills, "settings\nm_config.ini", "Status", "SessionViciousKills"
				killed := 1
			}
		} else { ;it has been greater than 10 minutes since VB was found
				VBState:=0
				;send VBState to background.ahk
				PostSubmacroMessage("background", 0x5554, 3, VBState)
				;nm_setStatus("VBState " . VBState, " <4>")
				nm_setStatus("Aborted", "Vicious Fight > 10 Mins")
		}
	}
	return killed
}
nm_Night(){
	nm_NightMemoryMatch()
	nm_locateVB()
}
nm_confirmNight(){
	nm_setStatus("Confirming", "Night")
	nm_Reset(0, 2000, 0)
	sendinput "{" RotDown " 1}"
	loop 10 {
		SendInput "{" ZoomOut "}"
		Sleep 100
		if ((findImg := nm_imgSearch("nightsky.png", 50, "abovebuff"))[1] = 0)
			break
		sendinput "{" RotLeft " 4}"
		findImg := nm_imgSearch("nightsky.png", 50, "abovebuff")
		sendinput "{" RotRight " 4}"
		if findImg[1] = 0		
			break

	}
	sendinput "{" RotUp " 1}"
	send "{" ZoomOut " 8}"
	return (findImg[1]=0)
}
nm_NightMemoryMatch(){
	global VBState, NightLastDetected

	if (!(NightMemoryMatchCheck && (nowUnix()-LastNightMemoryMatch)>28800) || (VBState = 0))
		return

	if !nm_confirmNight(){
		;false positive, ABORT!
		VBState:=0
		PostSubmacroMessage("background", 0x5554, 3, VBState)
		NightLastDetected:=nowUnix()-300-1 ;make NightLastDetected older than 5 minutes
		IniWrite NightLastDetected, "settings\nm_config.ini", "Collect", "NightLastDetected"
		nm_setStatus("Aborting", "Night Memory Match - Not Night")
		return
	}

	nm_MemoryMatch("Night")
	PostSubmacroMessage("background", 0x5554, 8, LastNightMemoryMatch)
}
nm_locateVB(){
	global VBState, StingerCheck, StingerDailyBonusCheck, StingerPepperCheck, StingerMountainTopCheck, StingerRoseCheck, StingerCactusCheck, StingerSpiderCheck, StingerCloverCheck, NightLastDetected, VBLastKilled, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, RotDown, RotUp, ZoomOut, MoveMethod, objective, DisableToolUse, dayorNight

	time := nowUnix()
	; don't run if stinger check Disabled", VB last killed less than 5m ago, night last detected more than 5m ago
	if ((StingerCheck=0) || (StingerDailyBonusCheck=1 && (time-VBLastKilled)<79200) || (time-VBLastKilled)<300 || ((time-NightLastDetected)>300 || (time-NightLastDetected)<0) || (VBState = 0)) {
		VBState:=0
		;send VBState to background.ahk
		PostSubmacroMessage("background", 0x5554, 3, VBState)
		return
	}

	; check if VB has already been activated / killed
	nm_ViciousCheck()

	if(VBState=2){
		nm_setStatus("Attacking", "Vicious Bee")
		startBattle := nowUnix()
		if(!DisableToolUse)
			Click "Down"

		killed := 0
		while (VBState=2) { ; generic battle pattern
			movement :=
			(
			nm_Walk(13.5, LeftKey) "
			" nm_Walk(4.5, BackKey)
			)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T60 L"
			nm_endWalk()
			movement :=
			(
			nm_Walk(13.5, RightKey) "
			" nm_Walk(4.5, FwdKey)
			)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T60 L"
			nm_endWalk()
			killed := nm_ViciousCheck()
		}
		if killed {
			duration := DurationFromSeconds(nowUnix() - startBattle, "mm:ss")
			nm_setStatus("Defeated", "Vicious Bee`nTime: " duration)
		}
		VBState:=0 ;0=no VB, 1=searching for VB, 2=VB found
		Click "Up"

		PostSubmacroMessage("background", 0x5554, 3, VBState)
		return
	}

	; confirm night time
	if(VBState=1){
		if(nm_confirmNight()){
			;night confirmed, proceed!
			nm_setStatus("Starting", "Vicious Bee Cycle")
		} else {
			;false positive, ABORT!
			VBState:=0
			PostSubmacroMessage("background", 0x5554, 3, VBState)
			NightLastDetected:=nowUnix()-300-1 ;make NightLastDetected older than 5 minutes
			IniWrite NightLastDetected, "settings\nm_config.ini", "Collect", "NightLastDetected"
			nm_setStatus("Aborting", "Vicious Bee - Not Night")
			return
		}
	}

	nm_updateAction("Stingers")
	startTime:=nowUnix()

	fieldsChecked := 0
	killed := 0
	for k,v in ["Pepper","MountainTop","Rose","Cactus","Spider","Clover"]
	{
		if !Stinger%v%Check
			continue
		else
			fieldsChecked++

		Loop 10 ; attempt each field a maximum of n (10) times
		{
			if(VBState=0) {
				nm_setStatus("Aborting", "No Vicious Bee")
				break 2
			}

			if ((v = "Spider") && (A_Index = 1) && StingerSpiderCheck && StingerCactusCheck)
			{
				;walk from Cactus to Spider
				nm_setStatus("Traveling", "Vicious Bee (" v ")")
				movement :=
				(
				nm_Walk(20, LeftKey) '
				' nm_Walk(44, FwdKey, LeftKey) '
				Loop 4
					Send "{' RotLeft '}"
				' nm_Walk(20, FwdKey) '
				' nm_Walk(20, LeftKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()
			}
			else
			{
				(fieldsChecked > 1 || A_Index > 1) && nm_Reset(0, 2000, 0)
				nm_setStatus("Traveling", "Vicious Bee (" v ")" ((A_Index > 1) ? " - Attempt " A_Index : ""))
				nm_gotoField((v = "MountainTop") ? "Mountain Top" : v)

				if (v = "Spider")
				{
					movement :=
					(
					nm_Walk(3500*9/2000, FwdKey) "
					" nm_Walk(3000*9/2000, LeftKey)
					)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
				}
			}

			if(!DisableToolUse)
				Click "Down"

			;search pattern
			if (VBState=1)
			{
				nm_setStatus("Searching", "Vicious Bee (" v ")")

				;configure
				reps := (v = "Pepper") ? 2 : (v = "MountainTop") ? 1 : (v = "Rose") ? 2 : (v = "Cactus") ? 1 : (v = "Spider") ? 2 : 2
				leftOrRightDist := (v = "Pepper") ? 4000 : (v = "MountainTop") ? 3500 : (v = "Rose") ? 3000 : (v = "Cactus") ? 4500 : (v = "Spider") ? 3750 : 4000
				forwardOrBackDist := (v = "Pepper") ? 900 : (v = "MountainTop") ? 1500 : (v = "Rose") ? 1500 : (v = "Cactus") ? 1500 : (v = "Spider") ? 1500 : 1500

				movement :=
				(
				nm_Walk(((v = "Pepper") ? 1700 : (v = "MountainTop") ? 2000 : (v = "Rose") ? 1800 : (v = "Cactus") ? 2000 : (v = "Spider") ? 1000 : 1500)*9/2000, RightKey) "
				" nm_Walk(((v = "Pepper") ? 1600 : (v = "MountainTop") ? 1600 : (v = "Rose") ? 1875 : (v = "Cactus") ? 750 : (v = "Spider") ? 1000 : 1500)*9/2000, (v = "Spider") ? BackKey : FwdKey)
				)
				nm_createWalk(movement)
				KeyWait "F14", "D T5 L"
				KeyWait "F14", "T60 L"
				nm_endWalk()

				if ((v = "Pepper") || (v = "Rose") || (v = "Clover") || (v = "Cactus"))
				{
					Loop reps {
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 2
						}
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" ((A_Index < reps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "")
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 2
						}
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement :=
						(
						nm_Walk(forwardOrBackDist*2*(reps-0.5)*9/2000, FwdKey) "
						" ((v != "Cactus") ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "")
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
					}
				}
				else if (v = "MountainTop")
				{
					Loop reps {
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						" nm_Walk(leftOrRightDist*9/2000, RightKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 2
						}
						movement :=
						(
						nm_Walk(forwardOrBackDist*9/2000, BackKey) "
						" nm_Walk(leftOrRightDist*9/2000, LeftKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 2
						}
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" nm_Walk(forwardOrBackDist*9/2000, FwdKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
					}
				}
				else ; spider
				{
					Loop reps {
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, RightKey) "
						" ((A_Index < reps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "")
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if (A_Index < reps)
						{
							if(not nm_activeHoney()) {
								Click "Up"
								continue 2
							}
							movement :=
							(
							nm_Walk(leftOrRightDist*9/2000, LeftKey) "
							" nm_Walk(forwardOrBackDist*9/2000, BackKey)
							)
							nm_createWalk(movement)
							KeyWait "F14", "D T5 L"
							KeyWait "F14", "T60 L"
							nm_endWalk()
						}
						if(not nm_activeHoney()) {
							Click "Up"
							continue 2
						}
						nm_ViciousCheck()
					}
					if(VBState=2){
						movement :=
						(
						nm_Walk(forwardOrBackDist*2*(reps-0.5)*9/2000, FwdKey) "
						" nm_Walk(leftOrRightDist*9/2000, LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
					}
				}
			}

			;battle pattern
			if (VBState=2) {
				nm_setStatus("Attacking", "Vicious Bee (" v ")" ((A_Index > 1) ? " - Round " A_Index : ""))
				(!IsSet(startBattle)) && (startBattle := nowUnix())

				;configure
				breps := 1
				leftOrRightDist := (v = "Pepper") ? 3000 : (v = "MountainTop") ? 3000 : (v = "Rose") ? 2500 : (v = "Cactus") ? 3250 : (v = "Spider") ? 2500 : 1800
				forwardOrBackDist := (v = "Pepper") ? 1000 : (v = "MountainTop") ? 1000 : (v = "Rose") ? 1000 : (v = "Cactus") ? 750 : (v = "Spider") ? 1000 : 1000

				while (VBState=2) {
					Loop breps {
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, (v = "Spider") ? RightKey : LeftKey) "
						" nm_Walk(forwardOrBackDist*9/2000, BackKey)
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 3
						}
						movement :=
						(
						nm_Walk(leftOrRightDist*9/2000, (v = "Spider") ? LeftKey : RightKey) "
						" ((A_Index < breps) ? nm_Walk(forwardOrBackDist*9/2000, BackKey) : "")
						)
						nm_createWalk(movement)
						KeyWait "F14", "D T5 L"
						KeyWait "F14", "T60 L"
						nm_endWalk()
						if(not nm_activeHoney()) {
							Click "Up"
							continue 3
						}
						killed := nm_ViciousCheck()
					}
					movement := nm_Walk(forwardOrBackDist*2*(breps-0.5)*9/2000, FwdKey)
					nm_createWalk(movement)
					KeyWait "F14", "D T5 L"
					KeyWait "F14", "T60 L"
					nm_endWalk()
				}
				if killed
				{
					duration := DurationFromSeconds(nowUnix() - startBattle, "mm:ss")
					nm_setStatus("Defeated", "Vicious Bee`nTime: " duration)
					Sleep 500
				}
				break 2
			}
			Click "Up"
			break
		}
	}
	Click "Up"
	duration := DurationFromSeconds(nowUnix() - startTime, "mm:ss")
	nm_setStatus("Completed", "Vicious Bee Cycle`nTime: " duration " - Fields: " fieldsChecked " - Defeated: " ((killed) ? "Yes" : "No"))
	VBState:=0 ;0=no VB, 1=searching for VB, 2=VB found
	PostSubmacroMessage("background", 0x5554, 3, VBState)
	return
}
nm_hotbar(boost:=0){
	global state, fieldOverrideReason, GatherStartTime, ActiveHotkeys, bitmaps
		, HotbarMax2, HotbarMax3, HotbarMax4, HotbarMax5, HotbarMax6, HotbarMax7
		, LastHotkey2, LastHotkey3, LastHotkey4, LastHotkey5, LastHotkey6, LastHotkey7
		, beesmasActive, QuestBoostCheck
	;whileNames:=["Always", "Attacking", "Gathering", "At Hive"]
	;ActiveHotkeys.push([val, slot, HBSecs, LastHotkey%slot%])
	for key, val in ActiveHotkeys {
		;ActiveLen:=ActiveHotkeys.Length
		;temp1:=ActiveHotkeys[1][1]
		;temp2:=ActiveHotkeys[key][2]
		;temp3:=ActiveHotkeys[key][3]
		;temp4:=ActiveHotkeys[key][4]
		;always
		if(ActiveHotkeys[key][1]="Always" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;attacking
		else if(state="Attacking" && ActiveHotkeys[key][1]="Attacking" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;gathering
		else if(state="Gathering" && (fieldOverrideReason="None" || (QuestBoostCheck = 1 && fieldOverrideReason="Quest")) && ActiveHotkeys[key][1]="Gathering" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;GatherStart
		else if(state="Gathering" && (fieldOverrideReason="None" || fieldOverrideReason="Boost" || (QuestBoostCheck = 1 && fieldOverrideReason="Quest")) && (nowUnix()-GatherStartTime)<10 && ActiveHotkeys[key][1]="GatherStart" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
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
			send "{sc00" HotkeyNum+1 "}"
			LastHotkeyN:=nowUnix()
			IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;snowflake
		else if(beesmasActive && (ActiveHotkeys[key][1]="Snowflake") && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			GetRobloxClientPos()
			offsetY := GetYOffset()
			;check that roblox window exists
			if (windowWidth > 0) {
				pBMArea := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+30 "|" windowWidth "|50")
				;check that: science buff visible and e button not visible (buffs not obscured)
				if ((Gdip_ImageSearch(pBMArea, bitmaps["science"]) = 1) && (Gdip_ImageSearch(pBMArea, bitmaps["e_button"]) = 0)) {
					if (Gdip_ImageSearch(pBMArea, bitmaps["snowflake_identifier"], &pos, , 20, , , , , 7) = 1) {
						;detect current snowflake buff amount
						x := SubStr(pos, 1, InStr(pos, ",")-1)

						(digits := Map()).Default := ""
						Loop 10
						{
							n := 10-A_Index
							if ((n = 1) || (n = 3))
								continue
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], &list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
							Loop Parse list, "`n"
								if (A_Index & 1)
									digits[Integer(A_LoopField)] := n
						}
						for m,n in [1,3]
						{
							Gdip_ImageSearch(pBMArea, bitmaps["buffdigit" n], &list, x-32, 15, x-8, 50, 1, , 5, 5, , "`n")
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
						for m,n in digits
							num .= n
					}
					else
						num := 0

					Gdip_DisposeImage(pBMArea)
					HotkeyNum:=ActiveHotkeys[key][2]
					;use snowflake if detected snowflake buff is below user selected maximum (num = "" implies 100% or indeterminate)
					if ((num != "") && (num < HotbarMax%HotkeyNum%)) {
						send "{sc00" HotkeyNum+1 "}"
						LastHotkeyN:=nowUnix()
						IniWrite LastHotkeyN, "settings\nm_config.ini", "Boost", "LastHotkey" HotkeyNum
						ActiveHotkeys[key][4]:=LastHotkeyN
						break
					}
				}
				Gdip_DisposeImage(pBMArea)
			}
		}
	}
}

;quest functions //todo: pending rewrite: lots of code duplication and inefficiencies!
nm_QuestRotate(){
	global QuestGatherField, RotateQuest, BlackQuestCheck, BlackQuestComplete, LastBlackQuest, BrownQuestCheck, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete, HoneyQuestCheck, PolarQuestCheck, GatherFieldBoostedStart, LastGlitter, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, VBState, bitmaps

	if ((BlackQuestCheck=0) && (BrownQuestCheck=0) && (BuckoQuestCheck=0) && (RileyQuestCheck=0) && (HoneyQuestCheck=0) && (PolarQuestCheck=0))
		return
	if ((VBState=1) || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
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

	if (QuestGatherField = "None") {
		;all previous quests did not set a QuestGatherField, so check brown bear quest
		nm_BrownQuest()
	}

	;honey bee quest
	nm_HoneyQuest()
}
nm_HoneyQuest(){
	global HoneyStart
	global HoneyQuestCheck
	global HoneyQuestProgress
	global HoneyQuestComplete:=1
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!HoneyQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for honey quest
	Loop 70
	{
		Qfound:=nm_imgSearch("honeyhunt.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		HoneyStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;Update Honey quest progress in GUI
		honeyProgress:=""
		;also set next steps
		questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+HoneyStart[3]+QuestBarGapSize+5)
		;temp%A_Index%:=questbarColor
		if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
			HoneyQuestComplete:=0
			completeness:="Incomplete"
		}
		;border color, white (titlebar), black (text)
		else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
			HoneyQuestComplete:=1
			completeness:="Complete"
		} else {
			completeness:="Unknown"
		}
		honeyProgress:=("Honey Tokens: " . completeness)
		IniWrite honeyProgress, "settings\nm_config.ini", "Quests", "HoneyQuestProgress"
		MainGui["HoneyQuestProgress"].Text := StrReplace(honeyProgress, "|", "`n")
	}
	if(HoneyQuestComplete)
	{
		nm_updateAction("Quest")
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

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for polar quest
	Loop 70
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

		Qfound:=nm_imgSearch("polar_bear3.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		PolarStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+PolarStart[3]-30
		ww := windowX+306
		wh := windowY+PolarStart[3]
		for key, value in PolarBear {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*10 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				PolarQuest:=key
				questSteps:=PolarBear[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+PolarStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						PolarStart[3]-=150
						Sleep 500
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
		num:=PolarBear[PolarQuest].Length
		loop num {
			action:=PolarBear[PolarQuest][A_Index][2]
			where:=PolarBear[PolarQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(PolarBear[PolarQuest][A_Index][1]-1)+PolarStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
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
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
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
		IniWrite polarProgress, "settings\nm_config.ini", "Quests", "PolarQuestProgress"
		MainGui["PolarQuestProgress"].Text := StrReplace(polarProgress, "|", "`n")
		if(QuestLadybugs=0 && QuestRhinoBeetles=0 && QuestSpider=0 && QuestMantis=0 && QuestScorpions=0 && QuestWerewolf=0 && QuestGatherField="None"){
			PolarQuestComplete:=1
		}
	}
}
nm_PolarQuest(){
	global PolarQuestCheck, PolarQuest, PolarQuestComplete, QuestGatherField, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RotateQuest, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!PolarQuestCheck)
		return
	nm_setShiftLock(0)
	RotateQuest:="Polar"
	nm_PolarQuestProg()
	if(PolarQuestComplete = 1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Polar")
		nm_PolarQuestProg()
		if(!PolarQuestComplete){
			nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
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
			nm_updateAction("Quest")
			nm_gotoQuestgiver("Polar")
			nm_PolarQuestProg()
			if(!PolarQuestComplete){
				nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
			}
		}
	}
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

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for riley quest
	Loop 70
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

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		RileyStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+RileyStart[3]-30
		ww := windowX+306
		wh := windowY+RileyStart[3]
		for key, value in RileyBee {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				RileyQuest:=key
				questSteps:=RileyBee[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+RileyStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						RileyStart[3]-=150
						Sleep 500
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
		num:=RileyBee[RileyQuest].Length
		loop num {
			action:=RileyBee[RileyQuest][A_Index][2]
			where:=RileyBee[RileyQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(RileyBee[RileyQuest][A_Index][1]-1)+RileyStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
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
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				rileyProgress:=(RileyQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				rileyProgress:=(rileyProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite rileyProgress, "settings\nm_config.ini", "Quests", "RileyQuestProgress"
		MainGui["RileyQuestProgress"].Text := StrReplace(rileyProgress, "|", "`n")
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
	global RileyQuestCheck, RileyQuestComplete, RileyQuest, RotateQuest, QuestGatherField, QuestAnt, QuestRedBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, RileyLadybugs, RileyScorpions, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!RileyQuestCheck)
		return
	RotateQuest:="Riley"
	nm_RileyQuestProg()
	if(RileyQuestComplete=1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Riley")
		nm_RileyQuestProg()
		if(RileyQuestComplete!=1){
			nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
	}
	if(RileyQuestComplete!=1){
		if(QuestFeed!="none") {
			nm_updateAction("Quest")
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
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
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

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for bucko quest
	Loop 70
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

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		BuckoStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+BuckoStart[3]-30
		ww := windowX+306
		wh := windowY+BuckoStart[3]
		for key, value in BuckoBee {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				BuckoQuest:=key
				questSteps:=BuckoBee[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BuckoStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						BuckoStart[3]-=150
						Sleep 500
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
		num:=BuckoBee[BuckoQuest].Length
		loop num {
			action:=BuckoBee[BuckoQuest][A_Index][2]
			where:=BuckoBee[BuckoQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(BuckoBee[BuckoQuest][A_Index][1]-1)+BuckoStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
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
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
				completeness:="Complete"
			} else {
				completeness:="Unknown"
			}
			if(A_Index=1)
				buckoProgress:=(BuckoQuest . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
			else
				buckoProgress:=(buckoProgress . newline . action . " " . (where = "None" ? "Any" : where) . ": " . completeness)
		}
		IniWrite buckoProgress, "settings\nm_config.ini", "Quests", "BuckoQuestProgress"
		MainGui["BuckoQuestProgress"].Text := StrReplace(buckoProgress, "|", "`n")
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
	global BuckoQuestCheck, BuckoQuestComplete, BuckoQuest, RotateQuest, QuestGatherField, QuestAnt, QuestBlueBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, MonsterRespawnTime, BuckoRhinoBeetles, BuckoMantis, TotalQuestsComplete, SessionQuestsComplete, VBState
	if(!BuckoQuestCheck)
		return
	RotateQuest:="Bucko"
	nm_BuckoQuestProg()
	if(BuckoQuestComplete=1) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Bucko")
		nm_BuckoQuestProg()
		if(BuckoQuestComplete!=1){
			nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
	}
	if(BuckoQuestComplete!=1){
		if(QuestFeed!="none") {
			nm_updateAction("Quest")
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
				PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
				IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
				IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
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

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;search for black quest
	Loop 70
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

		Qfound:=nm_imgSearch("black_bear5.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		Qfound:=nm_imgSearch("black_bear6.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}

		ActivateRoblox()
		switch A_Index
		{
			case 1:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			Loop 50 ; scroll all the way up
			{
				MouseMove windowX+30, windowY+offsetY+200, 5
				sendinput "{WheelUp}"
				Sleep 50
			}
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

			default:
			GetRobloxClientPos(hwnd)
			MouseMove windowX+30, windowY+offsetY+200, 5
			sendinput "{WheelDown}"
			Sleep 500 ; wait for scroll to finish
			pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
			if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
				Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
		}
	}
	Sleep 500

	if(Qfound[1]=0){
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		GetRobloxClientPos(hwnd)
		MouseMove windowX+350, windowY+offsetY+100
		xi := windowX
		yi := windowY+Qfound[3]
		ww := windowX+306
		wh := windowY+windowHeight
		fileName:="questbargap.png"
		if DirExist(A_WorkingDir "\nm_image_assets")
		{
			try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
			catch {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
				Sleep 5000
				ProcessClose DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
		}
		BlackStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
		;determine Quest name
		xi := windowX
		yi := windowY+BlackStart[3]-30
		ww := windowX+306
		wh := windowY+BlackStart[3]
		for key, value in BlackBear {
			filename:=(key . ".png")
			try
				result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*100 nm_image_assets\" fileName)
			catch
				result := 0
			if(result = 1) {
				BlackQuest:=key
				questSteps:=BlackBear[key].Length
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=windowY+BlackStart[3]
					loop questSteps {
						try
							result := ImageSearch(&FoundX, &FoundY, windowX+QuestBarInset, NextY, windowX+QuestBarInset+300, NextY+QuestBarGapSize, "*5 nm_image_assets\questbargap.png")
						catch
							result := 0
						if(result = 1) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove windowX+30, windowY+offsetY+225
						Sleep 50
						Send "{WheelDown 1}"
						Sleep 50
						BlackStart[3]-=150
						Sleep 500
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
		num:=BlackBear[BlackQuest].Length
		loop num {
			action:=BlackBear[BlackQuest][A_Index][2]
			where:=BlackBear[BlackQuest][A_Index][3]
			questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(BlackBear[BlackQuest][A_Index][1]-1)+BlackStart[3]+QuestBarGapSize+5)
			if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
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
			else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
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
		IniWrite blackProgress, "settings\nm_config.ini", "Quests", "BlackQuestProgress"
		MainGui["BlackQuestProgress"].Text := StrReplace(blackProgress, "|", "`n")
		if(QuestGatherField="None" && QuestBlackAnyField=0) {
			BlackQuestComplete:=1
		}
	}
}
nm_BlackQuest(){
	global BlackQuestCheck, BlackQuestComplete, BlackQuest, LastBlackQuest, RotateQuest, QuestGatherField, TotalQuestsComplete, SessionQuestsComplete
	if(!BlackQuestCheck)
		return
	RotateQuest:="Black"
	nm_BlackQuestProg()
	if(BlackQuestComplete && (nowUnix()-LastBlackQuest)>3600) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Black")
		nm_BlackQuestProg()
		if(!BlackQuestComplete){
			nm_setStatus("Starting", "Black Bear Quest: " . BlackQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
		LastBlackQuest:=nowUnix()
		IniWrite LastBlackQuest, "settings\nm_config.ini", "Quests", "LastBlackQuest"
	}
}
nm_BrownQuestProg(){
	global BrownQuestCheck, BrownQuest, BrownStart, HiveBees, FieldName1
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BrownQuestComplete:=1
	global BrownQuestProgress
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global state, bitmaps
	if(!BrownQuestCheck)
		return
	nm_setShiftLock(0)
	nm_OpenMenu("questlog")

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	;2 scrolls
	Loop 3 {
		;search for brown quest
		; if possible, move quest to top half of screen, to ensure quest tasks not cut off
		aim := ["questbrown", "quest"]
		loop aim.Length 
		{
			i := A_Index
			Loop 70
			{
				n := A_Index				
				loop 5 
				{
					Qfound:=nm_imgSearch("brown_bear" A_Index ".png",50,aim[i])
					if (Qfound[1]=0) {
						if (n > 1)
							Gdip_DisposeImage(pBMLog)
						break 3
					}
				}

				ActivateRoblox()
				switch A_Index
				{
					case 1:
					GetRobloxClientPos(hwnd)
					MouseMove windowX+30, windowY+offsetY+200, 5
					Loop 50 ; scroll all the way up
					{
						MouseMove windowX+30, windowY+offsetY+200, 5
						sendinput "{WheelUp}"
						Sleep 50
					}
					pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")

					default:
					GetRobloxClientPos(hwnd)
					MouseMove windowX+30, windowY+offsetY+200, 5
					sendinput "{WheelDown}"
					Sleep 500 ; wait for scroll to finish
					pBMScreen := Gdip_BitmapFromScreen(windowX+30 "|" windowY+offsetY+180 "|30|400")
					if (Gdip_ImageSearch(pBMScreen, pBMLog, , , , , , 50) = 1) { ; end of quest log
						Gdip_DisposeImage(pBMLog), Gdip_DisposeImage(pBMScreen)
						if i = 2
							break 2
						else
							continue 2 ; if not detected in top half, search rest
					}
					Gdip_DisposeImage(pBMLog), pBMLog := Gdip_CloneBitmap(pBMScreen), Gdip_DisposeImage(pBMScreen)
				}
			}
		}
		Sleep 500

		if(Qfound[1]=0){
			;locate exact bottom of quest title bar coordinates
			;titlebar = 30 pixels high
			;quest objective bar spacing = 10 pixels
			;quest objective bar height = 40 pixels
			GetRobloxClientPos(hwnd)
			MouseMove windowX+350, windowY+offsetY+100
			xi := windowX
			yi := windowY+Qfound[3]
			ww := windowX+306
			wh := windowY+windowHeight
			fileName:="questbargap.png"
			if DirExist(A_WorkingDir "\nm_image_assets\")
			{
				try result := ImageSearch(&FoundX, &FoundY, xi, yi, ww, wh, "*5 " A_WorkingDir "\nm_image_assets\" fileName)
				catch {
					nm_setStatus("Error", "Image file " filename " was not found in:`n" A_WorkingDir "\nm_image_assets\" fileName)
					Sleep 5000
					ProcessClose DllCall("GetCurrentProcessId")
				}
			} else {
				MsgBox "Folder location cannot be found:`n" A_WorkingDir "\nm_image_assets\"
			}
			BrownStart:=(result = 1) ? [0, FoundX-windowX, FoundY-windowY] : [1, 0, 0]
			;determine Quest objecives
			static objectiveList := Map("dandelion","Dand", "sunflower","Sunf", "mushroom","Mush", "blueflower","Bluf", "clover","Clove"
				, "strawberry","Straw", "spider","Spide", "bamboo","Bamb", "pineapple","Pinap", "stump","Stump"
				, "cactus","Cact", "pumpkin","Pump", "pinetree","Pine"
				, "rose","Rose", "mountaintop","Mount", "pepper","Pepp", "coconut","Coco"
				, "redpollen","Red", "bluepollen","Blue", "whitepollen","White")
			objectives := []

			GetRobloxClientPos(hwnd)
			while ((objectives.Length < 4) && (A_Index <= 5)) { ; maximum 4 objectives
				objectivePos := objectives.Length * QuestBarSize, objectiveSize := 0
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+BrownStart[3]+QuestBarGapSize+objectivePos "|304|" QuestBarSize-QuestBarGapSize)

				if (Gdip_ImageSearch(pBMScreen, bitmaps["questbarinset"], , , , 6, , 5) = 1) {
					for size in [16,15,14,18,17] { ; in approximate order of probability
						if (Gdip_ImageSearch(pBMScreen, bitmaps["s" size "collect"], , 6, , , , 30) = 1) {
							objectiveSize := size
							break
						}
					}

					if (objectiveSize = 0)
						objectives.Push("unknown")
					else {
						for k in objectiveList {
							for v in objectives ; if objective already exists, cannot be duplicated
								if (k = v)
									continue 2
							if (bitmaps.Has("s" objectiveSize k) && (Gdip_ImageSearch(pBMScreen, bitmaps["s" objectiveSize k], , 6, , , , 30) = 1))
								objectives.Push(k)
						}
					}
				} else {
					;//todo: replace this with proper questlog endpoint detection (similar to inventory) to determine if quest is cut off or not, instead of next quest title (which may not exist)
					if ((Gdip_ImageSearch(pBMScreen, bitmaps["questbartitle"], , , , 6, , 5) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["questbartitlebeesmas"], , , , 6, , 5) = 1)) {
						Gdip_DisposeImage(pBMScreen)
						break ; end of quest reached confirmed, since there is a quest below
					}

					;//todo: detect if scrollbar is already at end before scrolling, or how much has scrolled instead of fixed 150. every quest needs this, should be in rewrite
					Gdip_DisposeImage(pBMScreen)
					; scroll, but only if the questgiver name is in the lower part of the screen
					if (yi > (wh - (windowHeight//2))) {
						MouseMove windowX+30, windowY+offsetY+200, 5
						Sleep 50
						sendinput "{WheelDown 1}" ; to allow for tasks not on screen, if applicable
						Sleep 500 ; wait for scroll to finish
					}
					continue 2
				}

				Gdip_DisposeImage(pBMScreen)
			}
			break
		} else {
			return
		}
	}

	;Update Brown quest progress in GUI
	;also set next steps
	QuestGatherField:="None"
	QuestGatherFieldSlot:=0
	QuestGatherObjective:=""
	newLine:="|"
	brownProgress:=""
	BrownQuest:=(objectives.Length = 1) ? "Solo" : ""
	for i,obj in objectives {
		action:="Collect"
		; decide field (where)
		;//todo: make this into a function for use in other quest functions
		switch obj {
			case "redpollen":
			if(HiveBees>=35){
				where:="Pepper"
			} else if(HiveBees>=15){
				where:="Rose"
			} else if (HiveBees>=5) {
				where:="Strawberry"
			} else {
				where:="Mushroom"
			}

			case "bluepollen":
			if(HiveBees>=15){
				where:="Pine Tree"
			} else if (HiveBees>=5) {
				where:="Bamboo"
			} else {
				where:="Blue Flower"
			}

			case "whitepollen":
			if (HiveBees>=10) {
				where:="Pineapple"
			} else if (HiveBees>=5) {
				where:="Spider"
			} else {
				where:="Sunflower"
			}

			case "blueflower":
			where:="Blue Flower"

			case "pinetree":
			where:="Pine Tree"

			case "mountaintop":
			where:="Mountain Top"

			default:
			where:=StrTitle(obj) ; title case, capitalise first letter
		}

		questbarColor := PixelGetColor(windowX+QuestBarInset+10, windowY+QuestBarSize*(i-1)+BrownStart[3]+QuestBarGapSize+5)
		if((questbarColor=0xF46C55) || (questbarColor=0x6EFF60)) {
			BrownQuestComplete:=0
			completeness:="Incomplete"
			if(QuestGatherField="None" || InStr(QuestGatherObjective, "pollen")) { ; override colour pollen if there is an incomplete field objective
				QuestGatherField:=where
				QuestGatherFieldSlot:=i
				QuestGatherObjective:=obj
			}
		}
		;border color, white (titlebar), black (text)
		else if((questbarColor!=0x96C3DE) && (questbarColor!=0xE5F0F7) && (questbarColor!=0x1B2A35)) {
			completeness:="Complete"
		} else {
			completeness:="Unknown"
		}
		BrownQuest .= "-" . ((obj = "unknown") ? "Unknown" : objectiveList[obj])
		brownProgress .= newline . action . " " . where . ": " . completeness
	}
	brownProgress := (BrownQuest := LTrim(BrownQuest, "-")) . brownProgress

	IniWrite brownProgress, "settings\nm_config.ini", "Quests", "BrownQuestProgress"
	MainGui["BrownQuestProgress"].Text := StrReplace(brownProgress, "|", "`n")
	if(QuestGatherField="None") {
		BrownQuestComplete:=1
	}
}
nm_BrownQuest(){
	global BrownQuestCheck, BrownQuestComplete, BrownQuest, LastBrownQuest, RotateQuest, QuestGatherField, TotalQuestsComplete, SessionQuestsComplete
	if(!BrownQuestCheck)
		return
	RotateQuest:="Brown"
	nm_BrownQuestProg()
	if(BrownQuestComplete && (nowUnix()-LastBrownQuest)>3600) {
		nm_updateAction("Quest")
		nm_gotoQuestgiver("Brown")
		nm_BrownQuestProg()
		if(!BrownQuestComplete){
			nm_setStatus("Starting", "Brown Bear Quest: " . BrownQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			PostSubmacroMessage("StatMonitor", 0x5555, 5, 1)
			IniWrite TotalQuestsComplete, "settings\nm_config.ini", "Status", "TotalQuestsComplete"
			IniWrite SessionQuestsComplete, "settings\nm_config.ini", "Status", "SessionQuestsComplete"
		}
		LastBrownQuest:=nowUnix()
		IniWrite LastBrownQuest, "settings\nm_config.ini", "Quests", "LastBrownQuest"
	}
}
nm_Feed(food){
	global bitmaps
	nm_setShiftLock(0)
	nm_Reset(0,0,0,1)
	nm_setStatus("Feeding", food)
	;feed
	nm_InventorySearch(food)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" (54*windowWidth)//100-50 "|" Max(480, windowHeight-offsetY-150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
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
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" (54*windowWidth)//100-50 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[food], &pos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], , (54*windowWidth)//100-300, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(pos, InStr(pos, ",")+1)+190, windowX+windowWidth//2, windowY+41*windowHeight//100-10*(A_Index-1), 5
		Sleep 500
	}
	Loop 20 {
		Sleep 100
		pBMScreen := Gdip_BitmapFromScreen(windowX+(54*windowWidth)//100-300 "|" windowY+offsetY+(46*windowHeight)//100-59 "|250|100")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["feed"], &pos, , , , , 2, , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1)+140, windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+5 ; Number
			Sleep 100
			Click
			Sleep 100
			Send "{Text}100"
			Sleep 1000
			MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1), windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1) ; Feed
			Sleep 100
			Click
			nm_setStatus("Completed", "Feed " food)
			break
		} else {
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 20) {
				MouseMove windowX+(54*windowWidth)//100-300+SubStr(pos, 1, InStr(pos, ",")-1), windowY+offsetY+(46*windowHeight)//100-59+SubStr(pos, InStr(pos, ",")+1)+64 ; Cancel
				Sleep 100
				Click
				nm_setStatus("Failed", "Feed " food)
			}
		}
	}
	MouseMove windowX+350, windowY+offsetY+100
	;close inventory
	nm_OpenMenu()
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
			IniWrite LastBugrunLadybugs, "settings\nm_config.ini", "Collect", "LastBugrunLadybugs"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;rhino beetles
	else if(InStr(objective,"blue flower") || InStr(objective,"bamboo")) {
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			if(InStr(objective,"bamboo")) {
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			} else {
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			}
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;spider
	else if(InStr(objective,"spider")) {
		searchRet := nm_imgSearch("spider.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunSpider:=nowUnix()
			IniWrite LastBugrunSpider, "settings\nm_config.ini", "Collect", "LastBugrunSpider"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;mantis/rhino beetle
	else if(InStr(objective,"pineapple")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			if(!BugrunMantisCheck)
				BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite LastBugrunRhinoBeetles, "settings\nm_config.ini", "Collect", "LastBugrunRhinoBeetles"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;mantis/werewolf
	else if(InStr(objective,"pine tree")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite LastBugrunMantis, "settings\nm_config.ini", "Collect", "LastBugrunMantis"
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 2)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite LastBugrunWerewolf, "settings\nm_config.ini", "Collect", "LastBugrunWerewolf"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;werewolf
	else if(InStr(objective,"pumpkin") || InStr(objective,"cactus")) {
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite LastBugrunWerewolf, "settings\nm_config.ini", "Collect", "LastBugrunWerewolf"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
	;scorpions
	else if(InStr(objective,"rose")) {
		searchRet := nm_imgSearch("scorpion.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunScorpions:=nowUnix()
			IniWrite LastBugrunScorpions, "settings\nm_config.ini", "Collect", "LastBugrunScorpions"
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			PostSubmacroMessage("StatMonitor", 0x5555, 3, 1)
			IniWrite TotalBugKills, "settings\nm_config.ini", "Status", "TotalBugKills"
			IniWrite SessionBugKills, "settings\nm_config.ini", "Status", "SessionBugKills"
		}
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PATH FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_createPath(path) => nm_createWalk(path, , nm_PathVars())
nm_PathVars(){
	return
	(
	'
	HiveSlot:=' HiveSlot '
	MoveMethod:="' MoveMethod '"
	HiveBees:=' HiveBees '
	KeyDelay:=' KeyDelay '

	CoordMode "Mouse", "Screen"
	CoordMode "Pixel", "Screen"

	nm_gotoRamp() {
		nm_Walk(5, FwdKey)
		nm_Walk(9.2*HiveSlot-4, RightKey)
	}

	nm_gotoCannon() {
		static pBMCannon := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABsAAAAMAQMAAACpyVQ1AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEdJREFUeAEBPADD/wDAAGBgAMAAYGAA/gBgYAD+AGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYDdgEn1l8cC/AAAAAElFTkSuQmCC")

		hwnd := GetRobloxHWND()
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"

		success := 0
		Loop 10
		{
			Send "{" SC_Space " down}{" RightKey " down}"
			Sleep 100
			Send "{" SC_Space " up}"
			nm_Walk(2, RightKey)
			nm_Walk(1.5, FwdKey, RightKey)
			Send "{" RightKey " down}"

			DllCall("GetSystemTimeAsFileTime","int64p",&s:=0)
			n := s, f := s+100000000
			while (n < f)
			{
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
				{
					success := 1, Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				DllCall("GetSystemTimeAsFileTime","int64p",&n)
			}
			Send "{" RightKey " up}"

			if (success = 1) ; check that cannon was not overrun, at the expense of a small delay
			{
				Loop 10
				{
					if (A_Index = 10)
					{
						success := 0
						break
					}
					Sleep 500
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY "|400|125")
					if (Gdip_ImageSearch(pBMScreen, pBMCannon, , , , , , 2, , 2) = 1)
					{
						Gdip_DisposeImage(pBMScreen)
						break 2
					}
					else
						nm_Walk(1.5, LeftKey)
					Gdip_DisposeImage(pBMScreen)
				}
			}

			if (success = 0)
			{
				nm_Reset()
				nm_gotoRamp()
			}
		}
		if (success = 0)
			ExitApp
	}

	nm_Reset()
	{
		static hivedown := 0
		static pBMR := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACgAAAAGCAAAAACUM4P3AAAAAnRSTlMAAHaTzTgAAAAXdEVYdFNvZnR3YXJlAFBob3RvRGVtb24gOS4wzRzYMQAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0n77u/JyBpZD0nVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkJz8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0nYWRvYmU6bnM6bWV0YS8nIHg6eG1wdGs9J0ltYWdlOjpFeGlmVG9vbCAxMi40NCc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpleGlmPSdodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyc+CiAgPGV4aWY6UGl4ZWxYRGltZW5zaW9uPjQwPC9leGlmOlBpeGVsWERpbWVuc2lvbj4KICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NjwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOnRpZmY9J2h0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvJz4KICA8dGlmZjpJbWFnZUxlbmd0aD42PC90aWZmOkltYWdlTGVuZ3RoPgogIDx0aWZmOkltYWdlV2lkdGg+NDA8L3RpZmY6SW1hZ2VXaWR0aD4KICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgPHRpZmY6WFJlc29sdXRpb24+OTYvMTwvdGlmZjpYUmVzb2x1dGlvbj4KICA8dGlmZjpZUmVzb2x1dGlvbj45Ni8xPC90aWZmOllSZXNvbHV0aW9uPgogPC9yZGY6RGVzY3JpcHRpb24+CjwvcmRmOlJERj4KPC94OnhtcG1ldGE+Cjw/eHBhY2tldCBlbmQ9J3InPz77yGiWAAAAI0lEQVR42mNUYyAOMDJggOUMDAyRmAqXMxAHmBiobjWxngEAj7gC+wwAe1AAAAAASUVORK5CYII=")

		(bitmaps:=Map()).CaseSense := 0
		#include "%A_ScriptDir%\nm_image_assets\reset\bitmaps.ahk"

		success := 0
		hwnd := GetRobloxHWND()
		GetRobloxClientPos(hwnd)
		SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"

		Loop 10
		{
			DetectHiddenWindows 1
			if WinExist("background.ahk ahk_class AutoHotkey") {
				PostMessage 0x5554, 1, DateDiff(A_NowUTC, "19700101000000", "Seconds")
			}
			DetectHiddenWindows 0
			ActivateRoblox()
			GetRobloxClientPos(hwnd)
			SetKeyDelay 250+KeyDelay
			SendEvent "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			SetKeyDelay 100+KeyDelay

			n := 0
			while ((n < 2) && (A_Index <= 80))
			{
				Sleep 100
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|50")
				n += (Gdip_ImageSearch(pBMScreen, pBMR, , , , , , 10) = (n = 0))
				Gdip_DisposeImage(pBMScreen)
			}
			Sleep 1000

			if hivedown
				Send "{" RotDown "}"
			region := windowX "|" windowY+3*windowHeight//4 "|" windowWidth "|" windowHeight//4
			sconf := windowWidth**2//3200
			Loop 4 {
				sleep 250
				pBMScreen := Gdip_BitmapFromScreen(region), s := 0
				for i, k in bitmaps["hive"] {
					s := Max(s, Gdip_ImageSearch(pBMScreen, k, , , , , , 4, , , sconf))
					if (s >= sconf) {						
						Gdip_DisposeImage(pBMScreen)
						success := 1
						Send "{" RotRight " 4}"
						if hivedown
							Send "{" RotUp "}"
						SendEvent "{" ZoomOut " 5}"
						break 3
					}
				}
				Gdip_DisposeImage(pBMScreen)
				Send "{" RotRight " 4}"
				if (A_Index = 2)
				{
					if hivedown := !hivedown
						Send "{" RotDown "}"
					else
						Send "{" RotUp "}"
				}
			}
		}
		for k,v in bitmaps["hive"]
			Gdip_DisposeImage(v)
		if (success = 0)
			ExitApp
	}
	'
	)
}
nm_gotoField(location){
	global HiveConfirmed:=0
	path := paths["gtf"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_walkFrom(field){
	path := paths["wf"][StrReplace(field, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	nm_setStatus("Traveling", "Hive")
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_gotoPlanter(location, waitEnd := 1){
	global HiveConfirmed:=0
	path := paths["gtp"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	if WaitEnd
	{
		KeyWait "F14", "T120 L"
		nm_endWalk()
	}
}
nm_gotoCollect(location, waitEnd := 1){
	global HiveConfirmed:=0
	path := paths["gtc"][StrReplace(location, " ")]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	if waitEnd
	{
		KeyWait "F14", "T120 L"
		nm_endWalk()
	}
}
nm_gotoBooster(booster){
	global HiveConfirmed:=0
	path := paths["gtb"][booster]

	nm_setShiftLock(0)

	nm_createPath(path)
	KeyWait "F14", "D T5 L"
	KeyWait "F14", "T120 L"
	nm_endWalk()
}
nm_gotoQuestgiver(giver){
	path := paths["gtq"][giver]
	nm_setShiftLock(0)
	success:=0
	Loop 2
	{
		nm_Reset()

		global HiveConfirmed := 0

		nm_setStatus("Traveling", "Questgiver: " giver)

		nm_createPath(path)
		KeyWait "F14", "D T5 L"
		KeyWait "F14", "T120 L"
		nm_endWalk()

		Loop 2
		{
			Sleep 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				success:=1
				SendInput "{" SC_E " down}"
				Sleep 100
				SendInput "{" SC_E " up}"
				Sleep 2000
				hwnd := GetRobloxHWND()
				offsetY := GetYOffset(hwnd)
				Loop 500
				{
					GetRobloxClientPos(hwnd)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], &pos, , , , , 10, , 3) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX+windowWidth//2, windowY+2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
					Click
					Sleep 150
				}
				MouseMove windowX+350, windowY+offsetY+100
			}
		}

		global QuestGatherField:="None"
		if(success)
			return
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
	global GatherFieldBoostedStart, LastGlitter
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
	global PlanterSS1, PlanterSS2, PlanterSS3
	global MPlanterHold1, MPlanterHold2, MPlanterHold3
	global MPlanterSmoking1, MPlanterSmoking2, MPlanterSmoking3
	Loop 3 {
		;reset manual planter disable auto harvest variables to 0
		if (PlanterMode = 2) {
			MPlanterHold%A_Index% := 0
			IniWrite MPlanterHold%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterHold" A_Index
			MPlanterSmoking%A_Index% := 0
			IniWrite MPlanterSmoking%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" A_Index
		}
	}
	;skip over planters in this critical timeframe if AFB is active.  It helps avoid the loss of 4x field boost.
	global AFBrollingDice, AFBuseGlitter, AFBuseBooster, AutoFieldBoostActive, FieldLastBoosted, FieldLastBoostedBy, FieldBoostStacks, AutoFieldBoostRefresh, AFBFieldEnable, AFBDiceEnable, AFBGlitterEnable
	if(AutoFieldBoostActive && (FieldLastBoostedBy="dice") && (nowUnix()-FieldLastBoosted)>360 && (nowUnix()-FieldLastBoosted)<900) {
		return
	}
	if (PlanterMode != 2)
		return
	if ((VBState=1) || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	; if enabled, take any/all planter screenshots before further planter actions
	If (PlanterSS1 || PlanterSS2 || PlanterSS3)
		nm_planterSS()

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
	Loop 2 {
		;re-optimize planters
		for key, value in nectars {
			;--- get nectar priority --
			varstring:=(value . "priority")
			currentNectar:=%varstring%
			if (currentNectar!="none") {
				estimatedNectarPercent:=0
				Loop 3 { ;3 max positions
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				nectarPercent:=ba_GetNectarPercent(currentnectar)
				;recover planters that are collecting same nectar as currentField AND are not placed in currentField
				if(currentNectar=currentFieldNectar && not HarvestFullGrown && GatherFieldSipping) {
					Loop 3 { ;3 max positions
						if(currentField!=PlanterField%A_Index% && currentFieldNectar=PlanterNectar%A_Index%) {
							temp1:=PlanterField%A_Index%
							PlanterHarvestTime%A_Index% := nowUnix()-1
							IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
						}
					}
				}
				;recover planters that will overfill nectars
				if (AutomaticHarvestInterval && ((nectarPercent>99)||(nectarPercent>90 && (nectarPercent+estimatedNectarPercent)>110)||(nectarPercent+estimatedNectarPercent)>120)){
					Loop 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							PlanterHarvestTime%A_Index% := nowUnix()-1
							IniWrite PlanterHarvestTime%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
						}
					}
				}
			} else {
				break
			}
		}
		;recover placed planters here
		Loop 3 {
			if((PlanterHarvestTime%A_Index% < nowUnix()) && (PlanterName%A_Index%!="None") && (PlanterField%A_Index%!="None")){
				i := A_Index
				Loop 5 {
					if (ba_harvestPlanter(i) = 1)
						break
					if (A_Index = 5) {
						nm_setStatus("Error", "Failed to harvest " PlanterName%i% " in " PlanterField%i% "!")
						;clear planter
						PlanterName%i% := "None"
						PlanterField%i% := "None"
						PlanterNectar%i% := "None"
						PlanterHarvestTime%i% := 2147483647
						PlanterEstPercent%i% := 0
						;write values to ini
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" i
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" i
						IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" i
						IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" i
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" i
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
	Loop 3 {
		if(PlanterName%A_Index%="none")
			planterSlots.push(A_Index)
	}
	plantersplaced:=3-planterSlots.Length
	;temp1:=planterSlots[1]
	;temp2:=planterSlots[2]
	;temp3:=planterSlots[3]
	;temp4:=planterSlots.Length
	if(not planterSlots.Length)
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
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		if (currentNectar = "None")
			continue
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
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		if (currentNectar!="none") {
			planterSlots:=[]
			Loop 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
			for i, planterNum in planterSlots {
			;Loop 3 { ;3 max planters
			;temp1:=planterSlots[1]
			;temp2:=planterSlots[2]
			;temp3:=planterSlots[3]
			;temp4:=planterSlots.Length
				;--- determine max number of planters ---
				maxplanters:=0
				for x, y in planternames {
					maxplanters := maxplanters + %y%Check
				}

				maxplanters := min(MaxAllowedPlanters, maxplanters)
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
				if(nextField!="none" && nextPlanter[1]!="none" && plantersplaced<maxplanters && plantersplaced<MaxAllowedPlanters && nectarPlantersPlaced<maxNectarPlanters){
					;determine current nectar percent
					nectarPercent:=ba_GetNectarPercent(currentnectar)
					nectarMinPercent:=%value%minPercent
					estimatedNectarPercent:=0
					Loop 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
						}
					}
					;temp1:=nectarPercent + estimatedNectarPercent
					if(currentNectar=currentFieldNectar && estimatedNectarPercent>0){
						break
					}
					if (((nectarPercent + estimatedNectarPercent) < nectarMinPercent)){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
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
								IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

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
								MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
								IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
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
			}
		} else {
			break
		}
	}
	;//////// STAGE 2: All Nectars are at or will be above thresholds after harvested ///////////////
	;---- fill from lowest to highest nectar percent
	tempArray:=[]
	lowToHigh:=[] ;nectarname list
	sortstring:=""
	;create sort list
	for key, value in nectars {
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		estimatedNectarPercent:=0
		Loop 3 {
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
	sortstring := Sort(sortstring, "D;")
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
	for key, value in lowToHigh {
		currentNectar:=lowToHigh[key][3]
		if (currentNectar = "None")
			continue
		nextPlanter:=[]
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
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		Loop 3 {
			if(PlanterName%A_Index%="none")
				planterSlots.push(A_Index)
		}
		for i, planterNum in planterSlots {
		;Loop 3 {
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
				Loop 3 {
					planterNectar:=PlanterNectar%A_Index%
					if (PlanterNectar=currentNectar) {
						estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
					}
				}
				;is the last element in the array
				if (key=lowToHigh.Length){
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
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
							IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

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
							MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
							IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
							break
						}
					}
				} else { ;is not the last element in the array
					temp:=lowToHigh[key+1][1]
					if ((nectarPercent + estimatedNectarPercent) <= lowToHigh[key+1][1]){
						success:=-1, atField:=0
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
							success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
							switch success {
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
								IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

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
								MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
								IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
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
	for key, value in nectars {
		;--- get nectar priority --
		varstring:=(value . "priority")
		currentNectar:=%varstring%
		if (currentNectar = "None")
			continue
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
		Loop 3{
			if(PlanterNectar%A_Index%=currentNectar)
				nectarPlantersPlaced:=nectarPlantersPlaced+1
		}
		if (currentNectar!="none") {
			planterSlots:=[]
			Loop 3 {
				if(PlanterName%A_Index%="none")
					planterSlots.push(A_Index)
			}
					for i, planterNum in planterSlots {
			;Loop 3 {
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
					Loop 3 {
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%

						}
					}
					success:=-1, atField:=0
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none") {
						success := ba_placePlanter(nextField, nextPlanter, planterNum, atField)
						switch success {
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
							IniWrite Last%currentnectar%Field, "settings\nm_config.ini", "Planters", "Last" currentnectar "Field"

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
							MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
							IniWrite MaxAllowedPlanters, "settings\nm_config.ini", "Planters", "MaxAllowedPlanters"
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
	global nectarnames, totalCom, totalMot, totalRef, totalSat, totalInv
	static nectarcolors := Map("comforting",0x7E9EB3, "motivating",0x937DB3, "satisfying",0xB398A7, "refreshing",0x78B375, "invigorating",0xB35951)
	for key, value in nectarnames {
		if (var=value){
			nectarColor := nectarcolors[StrLower(var)]
			hwnd := GetRobloxHWND()
			offsetY := GetYOffset(hwnd)
			GetRobloxClientPos(hwnd)
			try
				result := PixelSearch(&bx2, &by2, windowX, windowY+offsetY+30, windowX+860, windowY+offsetY+150, nectarColor)
			catch
				result := 0
			If (result = 1) {
				nexty:=by2+1
				pixels:=1
				loop 38 {
					OutputVar := PixelGetColor(bx2, nexty)
					If (OutputVar=nectarColor) {
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
		}
	}
	if (nectarpercent=100)
		nectarpercent:=99.99
	total%SubStr(var, 1, 3)% := nectarpercent
	return nectarpercent
}
ba_getLastField(currentnectar){
	global ComfortingFields, RefreshingFields, SatisfyingFields, MotivatingFields, InvigoratingFields
		, LastComfortingField, LastRefreshingField, LastSatisfyingField, LastMotivatingField, LastInvigoratingField
		, BambooFieldCheck, BlueFlowerFieldCheck, CactusFieldCheck, CloverFieldCheck, CoconutFieldCheck, DandelionFieldCheck, MountainTopFieldCheck, MushroomFieldCheck
		, PepperFieldCheck, PineTreeFieldCheck, PineappleFieldCheck, PumpkinFieldCheck, RoseFieldCheck, SpiderFieldCheck, StrawberryFieldCheck, StumpFieldCheck, SunflowerFieldCheck
		, PlanterField1, PlanterField2, PlanterField3

	(arr := []).Length := 2, arr.Default := ""
	if (currentNectar = "None")
		return arr
	availablefields:=[]
	arr[1] := Last%currentnectar%Field
	;determine allowed fields
	for key, value in %currentnectar%Fields {
		tempfieldname := StrReplace(value, " ", "")
		if(%tempfieldname%FieldCheck && value!=PlanterField1 && value!=PlanterField2 && value!=PlanterField3)
			availablefields.Push(value)
	}
	arraylen:=availablefields.Length
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
		arr[1] := availablefields[1], arr[2] := availablefields.Has(2) ? availablefields[2] : availablefields[1]
	return arr
}
ba_getNextPlanter(nextfield){
	global BambooPlanters, BlueFlowerPlanters, CactusPlanters, CloverPlanters, CoconutPlanters, DandelionPlanters, MountainTopPlanters, MushroomPlanters, PepperPlanters
		, PineTreePlanters, PineapplePlanters, PumpkinPlanters, RosePlanters, SpiderPlanters, StrawberryPlanters, StumpPlanters, SunflowerPlanters
		, PlasticPlanterCheck, CandyPlanterCheck, BlueClayPlanterCheck, RedClayPlanterCheck, TackyPlanterCheck, PesticidePlanterCheck, HeatTreatedPlanterCheck
		, HydroponicPlanterCheck, PetalPlanterCheck, PaperPlanterCheck, TicketPlanterCheck, PlanterOfPlentyCheck
		, PlanterName1, PlanterName2, PlanterName3
	global LostPlanters
	;determine available planters
	tempFieldName := StrReplace(nextfield, " ", "")
	tempArrayName := (tempfieldname . "Planters")
	arrayLen:=IsSet(%tempfieldname%Planters) ? %tempfieldname%Planters.Length : 0
	nextPlanterName:="none"
	nextPlanterNectarBonus:=0
	nextPlanterGrowBonus:=0
	nextPlanterGrowTime:=0
	Loop arrayLen {
		tempPlanter:=Trim(%tempfieldname%Planters[A_Index][1])
		tempPlanterCheck:=%tempPlanter%Check
		if(tempPlanterCheck && tempPlanter!=PlanterName1 && tempPlanter!=PlanterName2 && tempPlanter!=PlanterName3)
		{
			if !InStr(LostPlanters, tempPlanter)
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
	global BambooFieldCheck, BlueFlowerFieldCheck, CactusFieldCheck, CloverFieldCheck, CoconutFieldCheck, DandelionFieldCheck, MountainTopFieldCheck, MushroomFieldCheck, PepperFieldCheck, PineTreeFieldCheck, PineappleFieldCheck, PumpkinFieldCheck, RoseFieldCheck, SpiderFieldCheck, StrawberryFieldCheck, StumpFieldCheck, SunflowerFieldCheck, MaxAllowedPlanters, LostPlanters, bitmaps

	nm_updateAction("Planters")

	nm_setShiftLock(0)

	planterName := planter[1]
	if (atField = 0)
	{
		nm_Reset()
		nm_OpenMenu("itemmenu")
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
		GetRobloxClientPos()
		MouseMove windowX+planterPos[1], windowY+planterPos[2]
	}

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", planterName)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
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
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[planterName], &planterPos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}
	Loop 50
	{
		GetRobloxClientPos(hwnd)
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
				Sleep 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX+350, windowY+offsetY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50 ; delay in case of lag
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", planterName)
			LostPlanters.=planterName
			ba_saveConfig_()
			return 0
		}

		Sleep 100
	}

	Loop 10
	{
		Sleep 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
			MainGui["MaxAllowedPlanters"].Value := MaxAllowedPlanters
			nm_setStatus("Error", "3 Planters already placed!`nMaxAllowedPlanters has been reduced.")
			ba_saveConfig_()
			Sleep 500
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
	global PlanterName1, PlanterName2, PlanterName3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3, PlanterNectar1, PlanterNectar2, PlanterNectar3, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3, PlanterGlitterC1, PlanterGlitterC2, PlanterGlitterC3, PlanterGlitter1, PlanterGlitter2, PlanterGlitter3, BackKey, RightKey, objective, TotalPlantersCollected, SessionPlantersCollected, HarvestFullGrown, ConvertFullBagHarvest, GatherPlanterLoot, BackpackPercent, bitmaps, SC_E, HiveBees, PlanterHarvestNow1, PlanterHarvestNow2, PlanterHarvestNow3

	nm_updateAction("Planters")

	planterName:=PlanterName%planterNum%
	fieldName:=PlanterField%planterNum%
	nm_setShiftLock(0)
	nm_Reset(1, ((GatherPlanterLoot = 1) && ((fieldname = "Rose") || (fieldname = "Pine Tree") || (fieldname = "Pumpkin") || (fieldname = "Cactus") || (fieldname = "Spider"))) ? min(20000, (60-HiveBees)*1000) : 0)
	nm_setStatus("Traveling", planterName . " (" . fieldName . ")")
	nm_gotoPlanter(fieldName)
	nm_setStatus("Collecting", (planterName . " (" . fieldName . ")"))
	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (planterName . " (" . fieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . planterName)
		ActivateRoblox()
		GetRobloxClientPos()

		nm_OpenMenu("itemmenu")
		planterPos := nm_InventorySearch(planterName, "up", 4)

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", planterName . ". Clearing Data.")
			;reset values
			PlanterName%planterNum% := "None"
			PlanterField%planterNum% := "None"
			PlanterNectar%planterNum% := "None"
			PlanterHarvestTime%planterNum% := 2147483647
			PlanterEstPercent%planterNum% := 0
			PlanterGlitterC%planterNum% := 0
			PlanterGlitter%planterNum% := 0
			;write values to ini
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" planterNum
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" planterNum
			IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum
			IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
			IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
			IniWrite PlanterGlitter%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitter" planterNum
			IniWrite PlanterGlitterC%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" planterNum
			return 1
		}
		else
			return 0
	}
	else {
		SendInput "{" SC_E " down}"
		Sleep 100
		SendInput "{" SC_E " up}"

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		Loop 50
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep 100

			if (A_Index = 50)
				return 0
		}

		Sleep 50 ; wait for game to update frame
		GetRobloxClientPos(hwnd)
		if ((HarvestFullGrown = 1) && !PlanterHarvestNow%planterNum%) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(FieldName)
					return 1
				}
				Gdip_DisposeImage(pBMScreen)
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					Gdip_DisposeImage(pBMScreen)
					If PlanterHarvestNow%planterNum%
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" planterNum
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}


		;reset values
		PlanterName%planterNum% := "None"
		PlanterField%planterNum% := "None"
		PlanterNectar%planterNum% := "None"
		PlanterHarvestTime%planterNum% := 2147483647
		PlanterEstPercent%planterNum% := 0
		PlanterGlitterC%planterNum% := 0
		PlanterGlitter%planterNum% := 0
		;write values to ini
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterName" planterNum
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterField" planterNum
		IniWrite "None", "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum
		IniWrite 2147483647, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
		IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
		IniWrite PlanterGlitter%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitter" planterNum
		IniWrite PlanterGlitterC%planterNum%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" planterNum
		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		PostSubmacroMessage("StatMonitor", 0x5555, 4, 1)
		IniWrite TotalPlantersCollected, "settings\nm_config.ini", "Status", "TotalPlantersCollected"
		IniWrite SessionPlantersCollected, "settings\nm_config.ini", "Status", "SessionPlantersCollected"
		;gather loot
		if (GatherPlanterLoot = 1)
		{
			nm_setStatus("Looting", planterName . " Loot")
			Sleep 1000
			movement := nm_Walk(7, BackKey, RightKey)
			nm_createWalk(movement)
			KeyWait "F14", "D T5 L"
			KeyWait "F14", "T20 L"
			nm_endWalk()
			nm_loot(9, 5, "left")
		}
		if ((ConvertFullBagHarvest = 1) && (BackpackPercent >= 95))
		{
			; loot path end location for some fields prevents successful return to hive
			If (GatherPlanterLoot = 1) {
				If (fieldname = "Cactus") || (fieldname = "Sunflower") {
					sleep 200
					nm_Move(1500*round(18/MoveSpeedNum, 8), RightKey)
					sleep 200
				}
			}
			nm_walkFrom(fieldName)
			DisconnectCheck()
			nm_findHiveSlot()
		}
		return 1
	}
}
ba_SavePlacedPlanter(fieldName, planter, planterNum, nectar){
	global PlanterName1, PlanterName2, PlanterName3
		, PlanterField1, PlanterField2, PlanterField3
		, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3
		, PlanterNectar1, PlanterNectar2, PlanterNectar3
		, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3
		, LastComfortingField, LastMotivatingField, LastSatisfyingField, LastRefreshingField, LastInvigoratingField, HarvestInterval
	global PlasticPlanterCheck, CandyPlanterCheck, BlueClayPlanterCheck, RedClayPlanterCheck, TackyPlanterCheck, PesticidePlanterCheck, HeatTreatedPlanterCheck
		, HydroponicPlanterCheck, PetalPlanterCheck, PaperPlanterCheck, TicketPlanterCheck, PlanterOfPlentyCheck
		, n1minPercent, n2minPercent, n3minPercent, n4minPercent, n5minPercent, AutomaticHarvestInterval, HarvestFullGrown
	;temp1:=planter[1]
	;temp2:=planter[2]
	;temp3:=planter[3]
	;temp4:=planter[4]
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
	Loop 3 { ;3 max positions
		planterNectar:=PlanterNectar%A_Index%
		if (PlanterNectar=nectar) {
			estimatedNectarPercent:=estimatedNectarPercent+PlanterEstPercent%A_Index%
		}
	}
	estimatedNectarPercent:=estimatedNectarPercent+ba_GetNectarPercent(nectar) ;projected nectar percent
	minPercent:=estimatedNectarPercent
	Loop 5{ ;5 nectar priorities
		if(n%A_Index%priority=nectar && minPercent<=n%A_Index%minPercent)
			minPercent:=n%A_Index%minPercent ; minPercent > estimatedNectarPercent
	}
	temp1:=minPercent-estimatedNectarPercent
	;timeToCap:=(max(0,(100-estimatedNectarPercent))*.24)/planter[2] ;hours
	timeToCap:=max(0.25,((max(0,(100-estimatedNectarPercent)/planter[2]))*.24)/planter[3]) ;hours
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

	} else { ;minPercent <= estimatedNectarPercent
		autoInterval:=timeToCap
	}
	;nec=planter[2]
	;gro=planter[3]
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
		planterHarvestInterval:=floor(min(planter[4], HarvestInterval)*60*60)
		smallestHarvestInterval:=nowUnix()+planterHarvestInterval
		Loop 3 {
			if(PlanterHarvestTime%A_Index%>nowUnix() && PlanterHarvestTime%A_Index%<smallestHarvestInterval)
				smallestHarvestInterval:=PlanterHarvestTime%A_Index%
		}
		PlanterHarvestTime%planterNum%:=min(smallestHarvestInterval, nowUnix()+planterHarvestInterval)
		temp:=PlanterHarvestTime%planterNum%
	}
	;PlanterHarvestTime%planterNum%:=toUnix_()+planterHarvestInterval
	PlanterHarvestTimeN:=PlanterHarvestTime%planterNum%
	;PlanterEstPercent%planterNum%:=round((floor(min(planter[3], HarvestInterval)*60*60)*planter[2]-floor(min(planter[3], HarvestInterval)*60*60))/864, 1)
	PlanterEstPercent%planterNum%:=round((floor(planterHarvestInterval)*planter[2])/864, 1)
	PlanterEstPercentN:=PlanterEstPercent%planterNum%
	;save changes
	IniWrite PlanterNameN, "settings\nm_config.ini", "Planters", "PlanterName" planterNum
	IniWrite PlanterFieldN, "settings\nm_config.ini", "Planters", "PlanterField" planterNum
	IniWrite PlanterNectarN, "settings\nm_config.ini", "Planters", "PlanterNectar" planterNum

	;make all harvest times equal
	Loop 3 {
		if(not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < PlanterHarvestTimeN + 600)
			IniWrite PlanterHarvestTimeN, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" A_Index
		else if(A_Index=planterNum)
			IniWrite PlanterHarvestTimeN, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" planterNum
	}

	IniWrite PlanterEstPercentN, "settings\nm_config.ini", "Planters", "PlanterEstPercent" planterNum
	IniWrite fieldname, "settings\nm_config.ini", "Planters", "Last" nectar "Field"
}

mp_Planter() { ;//todo: merge these manual planter functions as much as possible with Planters+ functions, lots of code duplication here!
	Global
	Local TimeElapsed, GlitterPos, field, i, k, v
	Global PlanterGlitter1, PlanterGlitter2, PlanterGlitter3, PlanterGlitterC1, PlanterGlitterC2, PlanterGlitterC3, PlanterHarvestFull1, PlanterHarvestFull2, PlanterHarvestFull3, PlanterSS1, PlanterSS2, PlanterSS3

	If (PlanterMode != 1)
		Return
	if ((VBState=1) || nm_MondoInterrupt() || nm_GatherBoostInterrupt())
		return

	; if enabled, take any/all planter screenshots before further planter actions
	If (PlanterSS1 || PlanterSS2 || PlanterSS3)
		nm_planterSS()

	Loop 2 {
		Loop 3 {
			If (!MSlot%A_Index%Cycle1Field)
				Continue
			; reset Release variable to 0 if planter slot empty
			If (PlanterField%A_Index% = "None") {
				PlanterHarvestNow%A_Index% := 0
				IniWrite PlanterHarvestNow%A_Index%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" A_Index
			}
			; reset Hold and Smoking variables to 0 if planter slot empty, disable auto harvest no longer selected, or user has set to Harvest Now with remote control
			If ((!MPuffModeA) || (!MPuffMode%A_Index%) || (PlanterField%A_Index% = "None")  || (PlanterHarvestNow%A_Index%)) {
				MPlanterHold%A_Index% := 0
				IniWrite MPlanterHold%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterHold" A_Index
				MPlanterSmoking%A_Index% := 0
				IniWrite MPlanterSmoking%A_Index%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" A_Index
			}
			If (PlanterHarvestTime%A_Index% > 2147483646 ) {
				mp_PlantPlanter(A_Index)
			} Else if (!MPlanterHold%A_Index% && (PlanterName%A_Index%!="None") && (PlanterField%A_Index%!="None")) {
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

nm_planterSS(){
	Global

	Loop 3 {
		If (PlanterSS%A_Index%) {
			nm_setShiftLock(0)
			nm_Reset(nm_Reset(1, ((PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Pine Tree") || (PlanterField%A_Index% = "Pumpkin") || (PlanterField%A_Index% = "Cactus") || (PlanterField%A_Index% = "Spider")) ? min(20000, (60-HiveBees)*1000) : 0))
			nm_setStatus("Traveling", PlanterName%A_Index% " (" PlanterField%A_Index% ")")
			nm_gotoPlanter(PlanterField%A_Index%, 1)

			sendinput "{" ZoomIn " 2}"

			; fields where the view is initially obstructed
			If ((PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Mountain Top")) {
				sleep 200
				sendinput "{" RotRight " 3}"
			}
			If ((PlanterField%A_Index% = "Bamboo") || (PlanterField%A_Index% = "Rose") || (PlanterField%A_Index% = "Cactus") || (PlanterField%A_Index% = "Mountain Top")) {
				loop 3 {
					sleep 200
					sendinput "{" ZoomOut " 2}"
				}
			}

			Sleep 2000
			nm_setStatus("Screenshot", (PlanterName%A_Index% . " (" . PlanterField%A_Index% . ")"))
			Sleep 2000

			PlanterSS%A_Index%:=0
			IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterSS" A_Index
		}
	}
}

mp_PlantPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MFieldName, MPlanterName, planterPos, pBMScreen, imgPos, field, k, v, hwnd
	Static MHarvestIntervalValue := Map("30 mins", 0.5
		, "1 hour", 1
		, "2 hours", 2
		, "3 hours", 3
		, "4 hours", 4
		, "5 hours", 5
		, "6 hours", 6)
	, MFieldNectars := Map("Dandelion", "Comforting"
		, "Bamboo", "Comforting"
		, "Pine Tree", "Comforting"
		, "Coconut", "Refreshing"
		, "Strawberry", "Refreshing"
		, "Blue Flower", "Refreshing"
		, "Pineapple", "Satisfying"
		, "Sunflower", "Satisfying"
		, "Pumpkin", "Satisfying"
		, "Stump", "Motivating"
		, "Spider", "Motivating"
		, "Mushroom", "Motivating"
		, "Rose", "Motivating"
		, "Pepper", "Invigorating"
		, "Mountain Top", "Invigorating"
		, "Clover", "Invigorating"
		, "Cactus", "Invigorating")

	nm_updateAction("Planters")

	Loop MSlot%PlanterIndex%MaxCycle {
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

	nm_Reset()
	nm_OpenMenu("itemmenu")
	nm_setStatus("Traveling", MPlanterName " (" MFieldName ")")
	nm_gotoPlanter(MFieldName, 0)

	ActivateRoblox()
	GetRobloxClientPos()

	planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

	if (planterPos = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", MPlanterName)
		return 0
	}
	else
		MouseMove windowX+planterPos[1], windowY+planterPos[2]

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	nm_setStatus("Placing", MPlanterName)
	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
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
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps[MPlanterName], &planterPos, , , 306, , 10, , 5) != 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}
	Loop 50
	{
		GetRobloxClientPos(hwnd)
		loop 3 {
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
				MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
				Sleep 150
				Click
				sleep 100
				Gdip_DisposeImage(pBMScreen)
				MouseMove windowX+350, windowY+offsetY+100
				break 2
			}
			Gdip_DisposeImage(pBMScreen)
			Sleep 50 ; delay in case of lag
		}

		if (A_Index = 50) {
			nm_setStatus("Missing", MPlanterName)
			return 0
		}

		Sleep 100
	}

	Loop 10
	{
		Sleep 100
		imgPos := nm_imgSearch("3Planters.png",30,"lowright")
		If (imgPos[1] = 0){
			nm_setStatus("Error", "3 Planters already placed!")
			Sleep 500
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
	PlanterNectar%PlanterIndex% := MFieldNectars[StrTitle(MFieldName)]
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
		PlanterHarvestTime%PlanterIndex% := nowUnix() + Integer(3600 * MHarvestIntervalValue[MHarvestInterval])
		Loop 3
			If (PlanterHarvestTime%A_Index% < PlanterHarvestTime%PlanterIndex% && PlanterHarvestTime%A_Index% > PlanterHarvestTime%PlanterIndex% - 300)
				PlanterHarvestTime%PlanterIndex% := PlanterHarvestTime%A_Index%
	}

	IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
	IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
	IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
	IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
	IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
	IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
	IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex

	If (nowUnix() - LastGlitter >= 900 && PlanterGlitterC%PlanterIndex% && !PlanterGlitter%PlanterIndex%)
		mp_UseGlitter(PlanterIndex, 1)

	return 1
}

mp_UseGlitter(PlanterIndex, atField:=0) {
	Global
	Local pBMScreen, glitterPos

	nm_setShiftLock(0)

	if (atField = 0) {
		nm_Reset()
		nm_OpenMenu("itemmenu")
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
		GetRobloxClientPos()
		MouseMove windowX+glitterPos[1], windowY+glitterPos[2]
	}

	KeyWait "F14", "T120 L" ; wait for gotoPlanter finish
	nm_endWalk()

	hwnd := GetRobloxHWND()
	offsetY := GetYOffset(hwnd)
	Loop 10
	{
		GetRobloxClientPos(hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|" windowWidth//2 "|" Max(480, windowHeight-offsetY-150))

		if (A_Index = 1)
		{
			; wait for red vignette effect to disappear
			Loop 40
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
						Sleep 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+150 "|306|" Max(480, windowHeight-offsetY-150))
					}
				}
			}
		}

		if ((Gdip_ImageSearch(pBMScreen, bitmaps["glitter"], &glitterPos, , , 306, , 10, , 5) != 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)

		MouseClickDrag "Left", windowX+30, windowY+SubStr(glitterPos, InStr(glitterPos, ",")+1)+190, windowX+windowWidth//2, windowY+windowHeight//2, 5
		Sleep 200
	}

	nm_setStatus("Boosted", "Glitter: " PlanterName%PlanterIndex%)
	LastGlitter:=nowUnix()
	IniWrite LastGlitter, "settings\nm_config.ini", "Boost", "LastGlitter"
	PlanterGlitter%PlanterIndex% := LastGlitter
	PlanterHarvestTime%PlanterIndex% := nowUnix() + Integer((PlanterHarvestTime%PlanterIndex% - nowUnix()) * 0.75)
	IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
	IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex
}

mp_HarvestPlanter(PlanterIndex) {
	Global
	Local CycleIndex, MPlanterName, MFieldName, findPlanter, planterPos, pBMScreen, hwnd

	nm_updateAction("Planters")

	MPlanterName := PlanterName%PlanterIndex%
	MFieldName := PlanterField%PlanterIndex%

	nm_setShiftLock(0)
	nm_Reset(nm_Reset(1, ((MFieldName = "Rose") || (MFieldName = "Pine Tree") || (MFieldName = "Pumpkin") || (MFieldName = "Cactus") || (MFieldName = "Spider")) ? min(20000, (60-HiveBees)*1000) : 0))

	nm_setStatus("Traveling", MPlanterName . " (" . MFieldName . ")")
	nm_gotoPlanter(MFieldName)
	if ((!MPuffModeA) || (!MPuffMode%PlanterIndex%) || (PlanterHarvestNow%PlanterIndex%))
		nm_setStatus("Collecting", (MPlanterName . " (" . MFieldName . ")"))
	else
		nm_setStatus("Checking", (MPlanterName . " (" . MFieldName . ")"))
	while ((A_Index <= 5) && !(findPlanter := (nm_imgSearch("e_button.png",10)[1] = 0)))
		Sleep 200
	if (findPlanter = 0) {
		nm_setStatus("Searching", (MPlanterName . " (" . MFieldName . ")"))
		findPlanter := nm_searchForE()
	}
	if (findPlanter = 0) {
		;check for phantom planter
		nm_setStatus("Checking", "Phantom Planter: " . MPlanterName)

		planterPos := nm_InventorySearch(MPlanterName, "up", 4) ;~ new function

		if (planterPos != 0) { ; found planter in inventory planter is a phantom
			nm_setStatus("Found", MPlanterName . ". Clearing Data.")

			;reset disable auto harvest values if phantom planter
			PlanterHarvestNow%PlanterIndex% := 0
			IniWrite PlanterHarvestNow%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
			MPlanterSmoking%PlanterIndex% := 0
			IniWrite MPlanterSmoking%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" PlanterIndex

			;reset values
			CycleIndex := PlanterManualCycle%PlanterIndex%
			if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
				PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
				mp_UpdateCycles()
			}

			PlanterName%PlanterIndex% := "None"
			PlanterField%PlanterIndex% := "None"
			PlanterNectar%PlanterIndex% := "None"
			PlanterGlitterC%PlanterIndex% := 0
			PlanterGlitter%PlanterIndex% := 0
			PlanterHarvestFull%PlanterIndex% := ""
			PlanterHarvestTime%PlanterIndex% := 2147483647

			IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
			IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
			IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
			IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
			IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
			IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
			IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex
		}

		return 1
	}
	else if ((MPuffModeA = 1) && (MPuffMode%PlanterIndex% = 1) && (PlanterHarvestNow%PlanterIndex% != 1)) {
		; screenshot and set to hold instead of harvest, if auto harvest is disabled for the slot, and the user hasn't selected to release it by remote control
		Sleep 200 ; wait for game to update frame
		nm_PlanterTimeUpdate(MFieldName)
		sleep 1000
		If (nowUnix() >= PlanterHarvestTime%PlanterIndex%) {
			nm_setStatus("Holding", (MPlanterName . " (" . MFieldName . ")"))
			Sleep 2000
			MPlanterHold%PlanterIndex% := 1
			IniWrite MPlanterHold%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterHold" PlanterIndex
		}
		return 1
	}
	else {
		sendinput "{" SC_E " down}"
		Sleep 100
		sendinput "{" SC_E " up}"

		hwnd := GetRobloxHWND()
		offsetY := GetYOffset(hwnd)
		Loop 50
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+offsetY+36 "|200|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)

			Sleep 100

			if (A_Index = 50)
				return 0
		}

		Sleep 50 ; wait for game to update frame
		GetRobloxClientPos(hwnd)
		if ((PlanterHarvestFull%PlanterIndex% == "Full") && !PlanterHarvestNow%PlanterIndex%) {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], &pos, , , , , 2, , 3) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					MouseMove windowX+350, windowY+offsetY+100
					If PlanterHarvestNow%PlanterIndex%
						IniWrite 0, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
					Gdip_DisposeImage(pBMScreen)
					nm_PlanterTimeUpdate(MFieldName)
					return 2
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}
		else {
			loop 3 {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-52 "|500|150")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], &pos, , , , , 2, , 2) = 1) {
					MouseMove windowX+windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowY+windowHeight//2-52+SubStr(pos, InStr(pos, ",")+1)
					Sleep 150
					Click
					sleep 100
					Gdip_DisposeImage(pBMScreen)
					MouseMove windowX+350, windowY+offsetY+100
					break
				}
				Gdip_DisposeImage(pBMScreen)
				Sleep 50 ; delay in case of lag
			}
		}

		PlanterHarvestNow%PlanterIndex% := 0
		IniWrite PlanterHarvestNow%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestNow" PlanterIndex
		MPlanterSmoking%PlanterIndex% := 0
		IniWrite MPlanterSmoking%PlanterIndex%, "settings\nm_config.ini", "Planters", "MPlanterSmoking" PlanterIndex

		;reset values
		CycleIndex := PlanterManualCycle%PlanterIndex%
		if ((MPlanterName = (StrReplace(MSlot%PlanterIndex%Cycle%CycleIndex%Planter, " ") (MSlot%PlanterIndex%Cycle%CycleIndex%Planter = "Planter Of Plenty" ? "" : "Planter"))) && (MFieldName = MSlot%PlanterIndex%Cycle%CycleIndex%Field)) {
			PlanterManualCycle%PlanterIndex% := Mod(PlanterManualCycle%PlanterIndex%, MSlot%PlanterIndex%MaxCycle) + 1
			mp_UpdateCycles()
		}

		PlanterName%PlanterIndex% := "None"
		PlanterField%PlanterIndex% := "None"
		PlanterNectar%PlanterIndex% := "None"
		PlanterGlitterC%PlanterIndex% := 0
		PlanterGlitter%PlanterIndex% := 0
		PlanterHarvestFull%PlanterIndex% := ""
		PlanterHarvestTime%PlanterIndex% := 2147483647

		IniWrite PlanterName%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterName" PlanterIndex
		IniWrite PlanterField%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterField" PlanterIndex
		IniWrite PlanterNectar%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterNectar" PlanterIndex
		IniWrite PlanterGlitter%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitter" PlanterIndex
		IniWrite PlanterGlitterC%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterGlitterC" PlanterIndex
		IniWrite PlanterHarvestFull%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestFull" PlanterIndex
		IniWrite PlanterHarvestTime%PlanterIndex%, "settings\nm_config.ini", "Planters", "PlanterHarvestTime" PlanterIndex

		TotalPlantersCollected:=TotalPlantersCollected+1
		SessionPlantersCollected:=SessionPlantersCollected+1
		PostSubmacroMessage("StatMonitor", 0x5555, 4, 1)
		IniWrite TotalPlantersCollected, "settings\nm_config.ini", "Status", "TotalPlantersCollected"
		IniWrite SessionPlantersCollected, "settings\nm_config.ini", "Status", "SessionPlantersCollected"
		;gather loot
		if (MGatherPlanterLoot = 1)
			{
				nm_setStatus("Looting", MPlanterName . " Loot")
				Sleep 1000
				nm_Move(1500*round(18/MoveSpeedNum, 2), BackKey, RightKey)
				nm_loot(9, 5, "left")
			}
		if ((MConvertFullBagHarvest = 1) && (BackpackPercent >= 95))
		{
			; loot path end location for some fields prevents successful return to hive
			If (MGatherPlanterLoot = 1) {
				If (MFieldName = "Cactus") || (MFieldName = "Sunflower") {
					sleep 200
					nm_Move(1500*round(18/MoveSpeedNum, 6), RightKey)
					sleep 200
				}
			}
			;nm_setStatus("Holding", "Inside if MConvertFullBagHarvest=1 && BackpackPercent>=95 " (MPlanterName . " (" . MFieldName . ")")) ; //testing
			nm_walkFrom(MFieldName)
			DisconnectCheck()
			nm_findHiveSlot()
		}
		return 1
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TIMER FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getout(*){
	global
	nm_saveGUIPos()
	nm_endWalk()
	DetectHiddenWindows 1
	try IniWrite !!WinExist("PlanterTimers.ahk ahk_class AutoHotkey"), "settings\nm_config.ini", "Planters", "TimersOpen"
	CloseScripts()
	try Gdip_Shutdown(pToken)
	DllCall(A_WorkingDir "\nm_image_assets\Styles\USkin.dll\USkinExit")
}

Background(){
	;auto field boost
	if (AFBrollingDice && state!="Disconnected")
		nm_fieldBoostDice()
	;use/check hotbar boosts
	if PFieldBoosted {
		nm_hotbar(1)
	} else {
		nm_hotbar()
	}
	;bug death check
	if(state="Gathering" || state="Searching" || (VBState=2 && state="Attacking"))
		nm_bugDeathCheck()
	;stats
	nm_setStats()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HOTKEYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;START MACRO
start(*){
	global
	SetKeyDelay 100+KeyDelay
	nm_LockTabs()
	MainGui["StartButton"].Enabled := 0
	Hotkey StartHotkey, "Off"
	nm_setStatus("Begin", "Macro")
	local ForceStart := (A_Args.Has(1) && (A_Args[1] = 1))
	for i in StrSplit(priorityListNumeric)
		priorityList.push(defaultPriorityList[i])
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
		if !ForceStart {
			if (MsgBox(
			(
			"Automatic Field Boost is ACTIVATED.
			------------------------------------------------------------------------------------
			If you continue the following quantity of items can be used:
			Dice: " futureDice "
			Glitter: " futureGlitter "

			HIGHLY RECOMMENDED:
			Disable any non-essential tasks such as quests, bug runs, stingers, etc. Any time away from your gathering field can result in the loss of your field boost."
			), "WARNING!!", 257 " T30") = "Cancel")
				return
		}
	}
	if !ForceStart {
		;Field drift compensation warning
		Loop 3 {
			;if gathering in a field with FDC on and without supreme set in settings, warn user
			if (FDCWarn = 1 && FieldName%A_Index% != "None" && FieldName%A_Index% && FieldDriftCheck%A_Index% && SprinklerType != "Supreme") {
				MsgBox
				(
				"You have Field Drift Compensation enabled for Gathering Field " A_Index ", however you do not have supreme saturator as your sprinkler type set in settings.
				Please note that Field Drift Compensation requires you to own the Supreme saturator, as it searches for the blue pixel."
				), "Field Drift Compensation", 0x1040 " T30"
				if (MsgBox("Would you like to disable this warning for the future?", "Field Drift Compensation", 0x1124 " T30") = "Yes")
					IniWrite (FDCWarn := 0), "settings\nm_config.ini", "Settings", "FDCWarn"
				break
			}
		}
		;Sticker Warning
		if ((StickerStackCheck = 1) && InStr(StickerStackItem, "Sticker")) { ;Warns user about stickers
			msgbox
			(
			"You have enabled the Sticker option for Sticker Stack!
			Consider trading all of your valuable stickers to alternative account, to ensure that you do not lose any valuable stickers."
			(((StickerStackHive + StickerStackCub + StickerStackVoucher > 0) &&
			(
			"

			EXTRA WARNING!!
			You have enabled the donation of:" ((StickerStackHive = 1) ? "`n- Hive Skins" : "") ((StickerStackCub = 1) ? "`n- Cub Skins" : "") ((StickerStackVoucher = 1) ? "`n- Vouchers" : "") "
			Make sure this is correct because the macro WILL use them!"
			)
			) || "")
			), "Sticker Stack", 0x1040 " T30"
		}
	}
	ActivateRoblox()
	disconnectCheck()
	;check UIPI
	try PostMessage 0x100, 0x7, 0, , "ahk_id " (hRoblox := GetRobloxHWND())
	catch
		MsgBox "
		(
		Your Roblox window is run as admin, but the macro is not!
		This means the macro will be unable to send any inputs to Roblox.
		You must either reinstall Roblox without administrative rights, or run Natro Macro as admin!

		NOTE: It is recommended to stop the macro now, as this issue also causes hotkeys to not work while Roblox is active."
		)", "WARNING!!", 0x1030 " T60"
	try PostMessage 0x101, 0x7, 0xC0000000, , "ahk_id " hRoblox
	nm_setShiftLock(0)
	GetRobloxClientPos(hRoblox)
	offsetY := GetYOffset(hRoblox, &offsetfail)
	if (offsetfail = 1)
		MsgBox "
		(
		Unable to detect in-game GUI offset!
		This means the macro will NOT work correctly!

		There are a few reasons why this can happen, including:
		- Incorrect graphics settings
		- Your 'Experience Language' is not set to English
		- Something is covering the top of your Roblox window

		Join our Discord server for support and our Knowledge Base post on this topic (Unable to detect in-game GUI offset)!
		)", "WARNING!!", 0x1030 " T60"
	nm_OpenMenu()
	MouseMove windowX+350, windowY+offsetY+100
	DetectHiddenWindows 1
	MacroState:=2
	if WinExist("Status.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	if WinExist("background.ahk ahk_class AutoHotkey")
		try PostMessage 0x5552, 23, MacroState
	DetectHiddenWindows 0
	;set stats
	MacroStartTime:=nowUnix()
	global PausedRuntime:=0
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
	global BuckoRhinoBeetles:=0
	global BuckoMantis:=0
	global RileyLadybugs:=0
	global RileyScorpions:=0
	global RileyAll:=0
	global GatherFieldBoosted:=0
	global GatherFieldBoostedStart:=nowUnix()-3600
	global ConvertGatherFlag:=0
	CurrentField := MainGui["CurrentField"].Text
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
			}
		}
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
	;start ancillary macros
	try run
	(
	'"' exe_path32 '" /script "' A_WorkingDir '\submacros\background.ahk" "' NightLastDetected '" "' VBLastKilled '" "' StingerCheck '" "' StingerDailyBonusCheck '" '
	'"' AnnounceGuidingStar '" "' ReconnectInterval '" "' ReconnectHour '" "' ReconnectMin '" "' EmergencyBalloonPingCheck '" "' ConvertBalloon '" "' NightMemoryMatchCheck '" "' LastNightMemoryMatch '"'
	)
	;(re)start stat monitor
	global SessionTotalHoney, HoneyAverage
	if (discordCheck && (((discordMode = 0) && RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
		|| ((discordMode = 1) && (ReportChannelCheck = 1) && (ReportChannelID || MainChannelID))))
		run '"' exe_path64 '" /script "' A_WorkingDir '\submacros\StatMonitor.ahk" "' VersionID '"'
	;start main loop
	nm_setStatus("Begin", "Main Loop")
	nm_Start()
}
;STOP MACRO
stop(*){
	global
	try {
		Hotkey StopHotkey, "Off"
		Hotkey PauseHotkey, "Off"
		Hotkey StartHotkey, "Off"
	}
	nm_endWalk()
	sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
	Click "Up"
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
	IniWrite TotalRuntime, "settings\nm_config.ini", "Status", "TotalRuntime"
	IniWrite SessionRuntime, "settings\nm_config.ini", "Status", "SessionRuntime"
	IniWrite TotalGatherTime, "settings\nm_config.ini", "Status", "TotalGatherTime"
	IniWrite SessionGatherTime, "settings\nm_config.ini", "Status", "SessionGatherTime"
	IniWrite TotalConvertTime, "settings\nm_config.ini", "Status", "TotalConvertTime"
	IniWrite SessionConvertTime, "settings\nm_config.ini", "Status", "SessionConvertTime"
	nm_setStatus("End", "Macro")
	DetectHiddenWindows 1
	MacroState:=0
	Reload
	Sleep 10000
}
;PAUSE MACRO
nm_Pause(*){
	global
	if(state="startup")
		return
	if(A_IsPaused) {
		nm_LockTabs()
		ActivateRoblox()
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			if(FwdKeyState)
				sendinput "{" FwdKey " down}"
			if(BackKeyState)
				sendinput "{" BackKey " down}"
			if(LeftKeyState)
				sendinput "{" LeftKey " down}"
			if(RightKeyState)
				sendinput "{" RightKey " down}"
			if(SpaceKeyState)
				sendinput "{" SC_Space " down}"
		}
		MacroState:=2
		if WinExist("Status.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("background.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		youDied:=0
		;manage runtimes
		MacroStartTime:=nowUnix()
		GatherStartTime:=nowUnix()
		DetectHiddenWindows 0
		nm_setStatus(PauseState, PauseObjective)
	} else {
		if (ShowOnPause = 1)
			WinActivate "ahk_id " MainGui.Hwnd
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			FwdKeyState:=GetKeyState(FwdKey), BackKeyState:=GetKeyState(BackKey), LeftKeyState:=GetKeyState(LeftKey), RightKeyState:=GetKeyState(RightKey), SpaceKeyState:=GetKeyState(SC_Space)
			sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
			Click "Up"
		}
		MacroState:=1
		if WinExist("Status.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("Heartbeat.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
		if WinExist("background.ahk ahk_class AutoHotkey")
			try PostMessage 0x5552, 23, MacroState
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
		IniWrite TotalRuntime, "settings\nm_config.ini", "Status", "TotalRuntime"
		DetectHiddenWindows 0
		nm_setStatus("Paused", "Press " PauseHotkey " to Continue")
		nm_LockTabs(0)
	}
	Pause -1
}
;AUTOCLICKER
autoclicker(*){
	global ClickDuration, ClickDelay
	static toggle:=0
	toggle := !toggle

	for var, default in Map("ClickDuration", 50, "ClickDelay", 10)
		if !IsNumber(%var%)
			%var% := default

	while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
		sendinput "{click down}"
		sleep ClickDuration
		sendinput "{click up}"
		sleep ClickDelay
	}
	toggle := 0
}
;TIMERS
timers(*) => ba_showPlanterTimers()

nm_WM_COPYDATA(wParam, lParam, *){
	Critical
	global LastGuid, PMondoGuid, MondoAction, MondoBuffCheck, currentWalk, FwdKey, BackKey, LeftKey, RightKey, SC_Space
	StringAddress := NumGet(lParam + 2*A_PtrSize, "Ptr")  ; Retrieves the CopyDataStruct's lpData member.
	StringText := StrGet(StringAddress)  ; Copy the string out of the structure.
	if(wParam=1){ ;guiding star detected
		nm_setStatus("Detected", "Guiding Star in " . StringText)
		;pause
		DetectHiddenWindows 1
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
			Send "{F16}"
		else
		{
			FwdKeyState:=GetKeyState(FwdKey)
			BackKeyState:=GetKeyState(BackKey)
			LeftKeyState:=GetKeyState(LeftKey)
			RightKeyState:=GetKeyState(RightKey)
			SpaceKeyState:=GetKeyState(SC_Space)
			PauseState:=state
			PauseObjective:=objective
			sendinput "{" FwdKey " up}{" BackKey " up}{" LeftKey " up}{" RightKey " up}{" SC_Space " up}"
			click "up"
		}
		;Announce Guiding Star
		;calculate mins
		GSMins:=SubStr("0" Mod(A_Min+10, 60), -2)
		Sleep 200
		Send "{Text}/<<Guiding Star>> in " StringText " until __:" GSMins "`n"
		sleep 250
		;set LastGuid
		LastGuid:=nowUnix()
		IniWrite LastGuid, "settings\nm_config.ini", "Boost", "LastGuid"
		if(PMondoGuid && MondoBuffCheck && MondoAction="Guid") {
			nm_mondo()
			DetectHiddenWindows 0
			return 0
		} else {
			if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk.pid)
				Send "{F16}"
			else
			{
				if(FwdKeyState)
					sendinput "{" FwdKey " down}"
				if(BackKeyState)
					sendinput "{" BackKey " down}"
				if(LeftKeyState)
					sendinput "{" LeftKey " down}"
				if(RightKeyState)
					sendinput "{" RightKey " down}"
				if(SpaceKeyState)
					sendinput "{" SC_Space " down}"
			}
		}
		DetectHiddenWindows 0
	}
	else {
		InStr(StringText, ": ") ? nm_setStatus(SubStr(StringText, 1, InStr(StringText, ": ")-1), SubStr(StringText, InStr(StringText, ": ")+2)) : nm_setStatus(StringText)
	}
	return 0
}
nm_ForceLabel(wParam, *){
	Critical
	switch wParam
	{
		case 1:
		if (MainGui["StartButton"].Enabled = 1)
			SetTimer start, -500

		case 2:
		nm_pause()

		case 3:
		stop()
	}
	return 0
}
nm_ForceReconnect(wParam, *){
	Critical
	global ReconnectDelay := wParam
	nm_endWalk()
	CloseRoblox()
	return 0
}
nm_sendHeartbeat(*){
	Critical
	PostSubmacroMessage("Heartbeat", 0x5556, 1)
	return 0
}
nm_backgroundEvent(wParam, lParam, *){
	Critical
	global youDied, NightLastDetected, VBState, BackpackPercent, BackpackPercentFiltered, FieldGuidDetected, HasPopStar, PopStarActive
	static arr:=["youDied", "NightLastDetected", "VBState", "BackpackPercent", "BackpackPercentFiltered", "FieldGuidDetected", "HasPopStar", "PopStarActive"]

	var := arr[wParam], %var% := lParam
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
	nm_UpdateGUIVar(var)
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
	nm_UpdateGUIVar(var)
	return 0
}
nm_UpdateGUIVar(var)
{
	global
	local k, z, num

	try
		MainGui[var]
	catch
		k := ""
	else
		k := var

	switch k, 0
	{
		case "FieldPatternSize1", "FieldPatternSize2", "FieldPatternSize3":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := FieldPatternSizeArr[%k%]

		case "FieldUntilPack1", "FieldUntilPack2", "FieldUntilPack3", "FieldBoosterMins":
		MainGui[k].Text := %k%
		MainGui[k "UpDown"].Value := %k%//5

		case "FieldName1":
		MainGui[k].Text := %k%
		nm_FieldSelect1(1)

		case "FieldName2":
		MainGui[k].Text := %k%
		nm_FieldSelect2(1)

		case "FieldName3":
		MainGui[k].Text := %k%
		nm_FieldSelect3(1)

		case "FieldPattern1", "FieldPattern2", "FieldPattern3":
		MainGui[k].Text := %k%

		case "FieldBooster1", "FieldBooster2", "FieldBooster3":
		MainGui[k].Text := %k%
		nm_FieldBooster()

		case "HotbarWhile2", "HotbarWhile3", "HotbarWhile4", "HotbarWhile5", "HotbarWhile6", "HotbarWhile7":
		MainGui[k].Text := %k%
		nm_HotbarWhile()

		case "KingBeetleAmuletMode", "ShellAmuletMode":
		MainGui[k].Value := %k%
		nm_saveAmulet(MainGui[k])

		case "HotbarTime2", "HotbarTime3", "HotbarTime4", "HotbarTime5", "HotbarTime6", "HotbarTime7":
		MainGui[k].Value := %k%
		nm_HotbarWhile()

		Case "SnailTime":
		MainGui["SnailTimeUpDown"].Value := (SnailTime = "Kill") ? 4 : SnailTime//5
		nm_SnailTime()

		Case "ChickTime":
		MainGui["ChickTimeUpDown"].Value := (ChickTime = "Kill") ? 4 : ChickTime//5
		nm_ChickTime()

		case "InputSnailHealth":
		MainGui["SnailHealthEdit"].Value := Round(30000000*InputSnailHealth/100)
		MainGui["SnailHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputSnailHealth), 150)), Round(Min(3*InputSnailHealth, 150)), 0)), MainGui["SnailHealthText"].Redraw()
		MainGui["SnailHealthText"].Text := InputSnailHealth "%"

		case "InputChickHealth":
		MainGui["ChickHealthText"].SetFont("c" Format("0x{1:02x}{2:02x}{3:02x}", Round(Min(3*(100-InputChickHealth), 150)), Round(Min(3*InputChickHealth, 150)), 0)), MainGui["ChickHealthText"].Redraw()
		MainGui["ChickHealthText"].Text := InputChickHealth "%"

		case "MondoAction":
		MainGui[k].Text := %k%
		nm_MondoAction()

		case "":
		k := var
		switch k, 0
		{
			case "BlenderItem1", "BlenderItem2", "BlenderItem3":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["BlenderAdd" z].Text := (BlenderItem%z% = "None") ? "Add" : "Clear"

			case "BlenderIndex1", "BlenderIndex2", "BlenderIndex3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, InStr(BlenderData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "BlenderAmount1", "BlenderAmount2", "BlenderAmount3":
			Num := SubStr(k, -1)
			local BlenderData1, BlenderData2, BlenderData3
			BlenderData%Num% := MainGui["BlenderData" Num].Text
			MainGui["BlenderData" Num].Text := StrReplace(BlenderData%Num%, SubStr(BlenderData%Num%, 1, InStr(BlenderData%Num%, " ") - 1), "(" %k% ")")

			case "ShrineItem1", "ShrineItem2":
			MainGui[k "Picture"].Value := hBitmapsSB[%k%] ? ("HBITMAP:*" hBitmapsSB[%k%]) : ""
			z := SubStr(k, -1)
			MainGui["ShrineAdd" z].Text := (ShrineItem%z% = "None") ? "Add" : "Clear"

			case "ShrineIndex1", "ShrineIndex2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, InStr(ShrineData%Num%, " ") + 1), "[" ((%k% = "Infinite") ? "∞" : %k%) "]")

			case "ShrineAmount1", "ShrineAmount2":
			Num := SubStr(k, -1)
			local ShrineData1, ShrineData2, ShrineData3
			ShrineData%Num% := MainGui["ShrineData" Num].Text
			MainGui["ShrineData" Num].Text := StrReplace(ShrineData%Num%, SubStr(ShrineData%Num%, 1, InStr(ShrineData%Num%, " ") - 1), "(" %k% ")")

			case "StickerStackMode":
			nm_StickerStackMode()
		}

		default:
		switch MainGui[k].Type, 0
		{
			case "DDL", "Text":
			MainGui[k].Text := %k%
			default: ; "CheckBox", "Edit", "UpDown", "Slider"
			MainGui[k].Value := %k%
		}
	}
}
