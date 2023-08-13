#NoEnv
#SingleInstance force
#Requires AutoHotkey v1.1.31+
SetBatchLines -1
#MaxThreads 255
#include %A_ScriptDir%\lib\Gdip_All.ahk
#include %A_ScriptDir%\lib\Gdip_ImageSearch.ahk
SetWorkingDir %A_ScriptDir% ; ~ recommended, working directory will be correct more often
CoordMode, Mouse, Client
CoordMode, Pixel, Client
;check if correct AHK version is installed before running anything
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
OnMessage(0x004A, "nm_WM_COPYDATA")
OnMessage(0x5550, "nm_ForceStart", 255)
OnMessage(0x5555, "nm_backgroundEvent", 255)
OnMessage(0x5556, "nm_setLastHeartbeat")
;run, test.ahk ; ~ run the test script for debugging issues, can comment this and 'WinClose, test.ahk' out when fixed or not want to test
pToken := Gdip_Startup()
;hotkey options
Hotkey, F4, , T2
Hotkey, F1, Off
toggle := 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE CONFIG FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
If !FileExist("settings") ; ~ make sure the settings folder exists
{
	FileCreateDir, settings
	If ErrorLevel
	{
		msgbox, 0x30, , Couldn't create the settings directory! Make sure the script is elevated if it needs to be.
		ExitApp
	}
}
VersionID:="0.8.9"
currentWalk:={"pid":"", "name":""} ; ~ stores "pid" (script process ID) and "name" (pattern/movement name)
nm_import() ; ~ import patterns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SET CONFIG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
config := {} ; store default values, these are loaded initially

config["Gui"] := {"dayOrNight":"Day"
	, "StartOnReload":0
	, "EnablePlantersPlus":0
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
	, "MaxPlanters":3
	, "TimerGuiTransparency":0
	, "TimerX":150
	, "TimerY":150
	, "TimerW":500
	, "TimerH":100
	, "TimersOpen":0
	, "HiveDistance":450
	, "FieldDriftCompensation":0
	, "FDCMoveDirFB":"None"
	, "FDCMoveDirLR":"None"
	, "FDCMoveDurFB":0
	, "FDCMoveDurLR":0
	, "AltPineStart":0}

config["Settings"] := {"GuiTheme":"MacLion3"
	, "AlwaysOnTop":0
	, "MoveSpeedNum":28
	, "MoveSpeedFactor":0.64
	, "MoveMethod":"Cannon"
	, "SprinklerType":"Supreme"
	, "MultiReset":0
	, "ConvertBalloon":"Always"
	, "ConvertMins":30
	, "LastConvertBalloon":1
	, "DisableToolUse":0
	, "AnnounceGuidingStar":0
	, "NewWalk":1
	, "HiveSlot":6
	, "HiveBees":50
	, "PrivServer":""
	, "ReconnectInterval":24
	, "ReconnectHour":""
	, "ReconnectMin":""
	, "GuiX":""
	, "GuiY":""
	, "GuiTransparency":0
	, "BuffDetectReset":0
	, "GuiMode":1
	, "ClickCount":1000
	, "ClickDelay":10
	, "ClickMode":0}

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
	, "TotalDisconnects":1
	, "SessionDisconnects":1
	, "Webhook":""
	, "Webhook2":""
	, "WebhookEasterEgg":0
	, "WebhookCheck":0
	, "discordUID":""
	, "ssCheck":0
	, "ssDebugging":0}
	
config["Keys"] := {"KeyboardLayout":"qwerty"
	, "FwdKey":"w"
	, "BackKey":"s"
	, "LeftKey":"a"
	, "RightKey":"d"
	, "RotLeft":","
	, "RotRight":"."
	, "ZoomIn":"i"
	, "ZoomOut":"o"
	, "KeyDelay":"20"}
	
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
	, "BeesmasGatherInterruptCheck":1
	, "StockingsCheck":0
	, "LastStockings":1
	, "WreathCheck":0
	, "LastWreath":1
	, "FeastCheck":0
	, "LastFeast":1
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
	, "BugRunCheck":0
	, "GiftedViciousCheck":0
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
	, "StingerCheck":0
	, "TunnelBearCheck":0
	, "TunnelBearBabyCheck":0
	, "LastTunnelBear":1
	, "KingBeetleCheck":0
	, "KingBeetleBabyCheck":0
	, "LastKingBeetle":1
	, "StumpSnailCheck":0
	, "LastStumpSnail":1
	, "CommandoCheck":0
	, "LastCommando":1
	, "CocoCrabCheck":0
	, "LastCrab":1
	, "StingerPepperCheck":1
	, "StingerMountainTopCheck":1
	, "StingerRoseCheck":1
	, "StingerCactusCheck":1
	, "StingerSpiderCheck":1
	, "StingerCloverCheck":1
	, "NightLastDetected":1
	, "VBLastKilled":1}
	
config["Boost"] := {"FieldBoostStacks":0
	, "FieldBooster3":"None"
	, "FieldBooster2":"None"
	, "FieldBooster1":"None"
	, "BoostChaserCheck":0
	, "HotkeyWhile2":"Never"
	, "HotkeyWhile3":"Never"
	, "HotkeyWhile4":"Never"
	, "HotkeyWhile5":"Never"
	, "HotkeyWhile6":"Never"
	, "HotkeyWhile7":"Never"
	, "FieldBoosterMins":15
	, "HotkeyTime2":30
	, "HotkeyTime3":30
	, "HotkeyTime4":30
	, "HotkeyTime5":30
	, "HotkeyTime6":30
	, "HotkeyTime7":30
	, "HotkeyTimeUnits2":"Mins"
	, "HotkeyTimeUnits3":"Mins"
	, "HotkeyTimeUnits4":"Mins"
	, "HotkeyTimeUnits5":"Mins"
	, "HotkeyTimeUnits6":"Mins"
	, "HotkeyTimeUnits7":"Mins"
	, "LastHotkey2":1
	, "LastHotkey3":1
	, "LastHotkey4":1
	, "LastHotkey5":1
	, "LastHotkey6":1
	, "LastHotkey7":1
	, "LastWhirligig":1
	, "LastEnzymes":1
	, "LastGlitter":1
	, "LastWindShrine":1
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
	, "AFBglitterUsed":0
	, "LastMicroConverter":1}
	
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
	, "n1Switch":1
	, "n2switch":1
	, "n3Switch":1
	, "n4Switch":1
	, "n5Switch":1}
	
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
; DISABLE ROBLOX BETA APP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\ROBLOX Corporation\Environments\roblox-player, LaunchExp, InBrowser ~ no longer works
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
	, "width":6
	, "camera":"Left"
	, "turns":2
	, "sprinkler":"Upper"
	, "distance":7
	, "percent":95
	, "gathertime":10
	, "convert":"Walk"
	, "drift":0
	, "shiftlock":0
	, "invertFB":0
	, "invertLR":0}

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
	, "drift":1
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

if FileExist(A_ScriptDir "\settings\field_config.ini") ; update default values with new ones read from any existing .ini
	nm_LoadFieldDefaults()

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

;msgbox % FieldDefault["sunflower"]["pattern"][1]
;msgbox % FieldDefault["blue flower"]["pattern"][1]
;for key, value in bambooplanters {
;	temp++
;}
;msgbox bambooplanters.length()=%temp%
global resetTime:=nowUnix()
global youDied:=0
global GameFrozenCounter:=0
global state, objective
global AFBrollingDice:=0
global AFBuseGlitter:=0
global AFBuseBooster:=0
global MacroRunning:=0
global MacroStartTime:=nowUnix()
global MacroReloadTime:=nowUnix()
;global delta:=0
global SessionRuntime:=0
global PausedRuntime:=0
global LastHeartbeat:=nowUnix()
global FieldGuidDetected:=0
global HasPopStar:=0
global PopStarActive:=0
global PreviousAction:="None"
global CurrentAction:="Startup"
TCFBKey := FwdKey
AFCFBKey := BackKey
TCLRKey := LeftKey
AFCLRKey := RightKey
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GDIP BITMAPS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bitmaps := {}

;general
bitmaps["e_button"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAADIAAAAEAQMAAAD20v5CAAAAA1BMVEXu7vKXSI0iAAAAK0lEQVR4AQEgAN//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAABaSL1yAAAAABJRU5ErkJggg==")
bitmaps["redcannon"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABsAAAAMAQMAAACpyVQ1AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEdJREFUeAEBPADD/wDAAGBgAMAAYGAA/gBgYAD+AGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYADAAGBgAMAAYGAAwABgYDdgEn1l8cC/AAAAAElFTkSuQmCC")
bitmaps["tokenlink"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAFAAAAAOCAMAAACPS2sYAAABelBMVEUiV6gjWKgkWakmWqonW6ooXKspXasqXasrXqwrX6wsX6wxY642Z7E3aLE6arM9bbQ/brVAb7VBcLZDcbZEcrdIdrlLeLpMeLpMebpNertOertPe7tRfbxSfb1Tfr1Uf75VgL5Xgr9Zg8BchcFdhsJeh8JfiMNkjMVljMVljcVmjsZnjsZoj8Zpj8dpkMdqkcdrkchskshtk8ltk8hulMlvlMlwlcpwlspyl8tzmMt0mMt0mcx1msx3m817ns97n89+oNB/otGCpNKNrNaNrdeQr9iTsdmYtduZttybuN2cuN2cud2eut6fu96hvd+lwOGpw+OsxeSux+WvyOW0zOe5z+q50Oq60eq+1Oy/1OzA1u3C1+7E2O7E2e/F2u/G2u/H2/DI3PDK3fHL3/LM3/LN4PLO4PPP4fPP4vPQ4vTS5PTU5fXV5vbX6Pfa6vjb6/nc7Pnf7vrh7/vh8Pvi8fzj8fzk8vzl8/3m9P3n9P7o9f7o9v7p9v/q9/8MEYKwAAAEeUlEQVR4AQFuBJH7AAAAAAAAAAAAASdPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAABAbhIAAAAAAAAAAAAAASdPAAAAAAAAAAVnVgAAAAAAAAAAAAAAGX1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAABBcBMAAAAAAAAAAAAAGX1hAAAAAAAAAAAkfS4AAAAAAAAAAAAAGn1hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACX13AAAAAAAAAAAAAAAAAAAAAAAAAAAAGn1hAAAAAAAAAAAAX1sAAAA2YXZiOgAAGn1hAAAgJyEAAAAAJV53Yy0AABZ9ZE9vcU0HAAAAAAAACX13AAAAAAAAAAAXJQ0AFn1kT29xTQcAGn1hAAAgJyEAAAAAQn0RADx9fX19fT8AGn1hADt9chsAAAAfen19fXwmABZ9fX19fX1GAAAAAAAACX13AAAAAAAAAABTfS8AFn19fX19fUYAGn1hADt9chsAAAAAHn01AGx9OAY0fW4DGn1hMHx1IAAAAABafUAKMn1cABZ9fS8IOX10BAAAAAAACX13AAAAAAAAAABTfS8AFn19Lwg5fXQEGn1hMHx1IAAAAAAADH1EAH1eAAAAWX0bGn1zen1RAAAAAAx9agAAAF59CxZ9aQAAAGB9EQAAAAAACX13AAAAAAAAAABTfS8AFn1pAAAAYH0RGn1zen1RAAAAAAAACH1KAH1MAAAASH0pGn19dnp7FAAAABx9fX19fX19GRZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn19dnp7FAAAAAAAB31JAH1MAAAAR30oGn14JE59UAAAAB19fX19fX19IhZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn14JE59UAAAAAAADn1DAH1dAAAAWH0YGn1hAA95fBUAAA59bQAAAAAAABZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn1hAA95fBUAAAAAI30zAGh9PQU3fWsCGn1hAABLfVIAAABlfT4JJ1gzABZ9XgAAAFV9FgAAAAAACX13AAAAAAAAAABTfS8AFn1eAAAAVX0WGn1hAABLfVIAAAAARX0QADB9fX19fTcAGn1hAAAOd30ZAAApfX19fX1FABZ9XgAAAFV9FgAAAAAACX19fX19fX1nAABTfS8AFn1eAAAAVX0WGn1hAAAOd30ZAAACa1oAAAAsXnVgMQAAGn1hAAAAR31UAAAAK2F3ZkEBABZ9XgAAAFV9FgAAAAAACX19fX19fX1nAABTfS8AFn1eAAAAVX0WGn1hAAAAR31UAAAqfS4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAVpVwAAqhit0/6UWu4AAAAASUVORK5CYII=")
bitmaps["itemmenu"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACcAAAAuAQAAAACD1z1QAAAAAnRSTlMAAHaTzTgAAAB4SURBVHjanc2hDcJQGAbAex9NQCCQyA6CqGMswiaM0lGACSoQDWn6I5A4zNnDiY32aCPbuoujA1rNUIsggqZRrgmGdJAd+qwN2YdDdEiPXUCgy3lGQJ6I8VK1ZoT4cQBjVa2tUAH/uTHwvZbcMWfClBduVK2i9/YB0wgl4MlLHxIAAAAASUVORK5CYII=")
bitmaps["item"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAMAAAAUAQMAAAByNRXfAAAAA1BMVEXU3dp/aiCuAAAAC0lEQVR42mMgEgAAACgAAU1752oAAAAASUVORK5CYII=")
bitmaps["questlog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACoAAAAnAQAAAABRJucoAAAAAnRSTlMAAHaTzTgAAACASURBVHjajczBCcJAEEbhl42wuSUVmFjJphRL2dLGEuxAxQIiePCw+MswBRgY+OANMxgUoJG1gZj1Bd0lWeIIkKCrgBqjxzcfjxs4/GcKhiBXVyL7M0WEIZiCJVgDoJPPJUGtcV5ksWMHB6jCWQv0dl46ToxqzJZePHnQw9W4/QAf0C04CGYsYgAAAABJRU5ErkJggg==")
bitmaps["dialog"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABQAAAAUAQMAAAC3R49OAAAABlBMVEUiV6gyg//3rCo4AAAAEElEQVR42mMgFvz//4EYDABK9B1Nh2RNtgAAAABJRU5ErkJggg==")
bitmaps["shiftlock"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABkAAAAZAgMAAAC5h23wAAAADFBMVEUAAAAFov4Fov0Gov5PyD1RAAAAAXRSTlMAQObYZgAAAG1JREFUeNp1zrENwlAMhOEvOOmQQsEgGSBSVkjB24dRMgIjeBRGyAZBLhBpKOz/ijvdEcfyhpEZXkQST+yMMHNFvUm3CjZ9L1K6dZzYtbYWh9YekoE7sij/cit/pKny8e379Udiryt92ns5lp0PKyEgGjSX+tcAAAAASUVORK5CYII=")

;gui
bitmaps["beesmas"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAC1lBMVEUAAABkuTNitTJfqTPSdVGQakFhqjJkpDRgpjP+5l3211ZdqjBgpzNcnzJhrjNdqi5jpTVhtC5epDM9wCNenzNhojf84mBayjForTVbrzL30RmZb07z4F/+XV/y0k9fuzH91y9dnTRkrDRkojNXnyZeuTCeclKBsz1SwC6SaUOYi0FjtTJWqTD+4m3y3mTsYVhiqDT+42NWuy6gdFSrviRitzPcaVRiqDT01FKVa0RPviz72EVfsjH7WVljtzGWdU9gtTJ+ljpYlTObblBkuDJ/pDhGrC5fpTT1zyWOnD1nrzf311b63l6wf0mQYkVTqy9hsC/Uvw7+Om2LakH+4mcr0iEajBpitTJitjJhpjNfpDBjsjJnvzT/V19gpjJWqzBesy1boyv/T2L/U2D4XVxpqz1jozRjrDNhpTNgtS9YsSTP5cH/UWH+W13oZVhpuTtmrjdqxDZntDVnvDRjsDNhuDFhsTFcujBUrDBTqDBYvC9cpC9UvS3////7/v2y1Jyn1Yz/72j/aWKGxWHlaFfhalTBe02Zeky9eku4ekqbikGNcUGGpT6MnD18njtqszp8pDlqmDZrsTVvqzVkoDRcmjRfqDJVtDFdrzFaqTFPoDFXmTFatjBatDBYozBXuS5bsyhbqyZXoSZNqCVUoCPc7dG/2q2936mw2Zms0JSazYOWxHiPwG+NyWv/6WiJvmaLw2X/YmL7312rhln/UVl7tVXv11Scm1Oef1PW1VLWclLXcVLQcFF3s1DJbVD42E/TzU9tuU/Jc0+tjkuReEtyrkm1fkmvgEite0hwvEWbs0Scq0SjmUSfiUOciUP+1kKyyEL/5kGOh0GKsz6Qnj6Kkz6Kkj7/4D2AujyFlTx4lDptujm30TdrwjdqozdynjdkuTZftzVvrjVnojRgqDNXnTNXvTFYrzFTrTFMojBmwy9eoS9Uui5ivi1RtC1jsSxaridTpCZajVxKAAAAV3RSTlMA/s8a/vLizsmpmpN+em5DOy8iDwv9/Pv6+Pj29fXs7Ojn5ubg393b0MvBu7i1tLGvrq2soZ+ckpCQjYSEf395eGhnXlpZVlJQSklAPTMrKikjIh4aFggjtvGzAAACC0lEQVQ4y2JAA1zeDPiBmAU+WWtO3XVyXJw+OBV4KFzcv6nRMAS3EYFS5xv18Nlhcv3ANhkB3PJudy48n7xTPQyXfKh88dyy6nnvuXEp0L88PyI6KnV9Pz92edemvPDy6EWrazeoiGBVYHUqaXf5nKjUNanpQlgVMGucSdoVHR+1KJ0Hhxs4pp9Lyrv18qmoE3Z57rsz3vWmJJ+Y8kLSH5s8f0wEY0TN5EM5Kcd62LHIC6vGJCzNXjA3/uae2OQmW0wFAJndmJ+womFBWUZ8/P2uNhZfdHnPjS1FVVlZEdEZkZEfF1eEs6MHhdHpnJZHNeFABXGJ9fWJcUXoUcYnfiU2pbemHKQgOzsxnY0Z3Q62ZxPyktomvZkZGRcVFVXAiy7PW5BWmdaZk3t84qxZs2dPnaqIZoIgY0RZyYzpfSzJsfsuTZxXWflQB1UB09usCCCoqprQkZKc29px9mqPI7I8YDavmhvCQSBiTkXatc7W3NgtsbJBCPmA4qzldfkJIAUfqqfFV8x83Le967AWkgUxmfknM8FGNB+NioyMW7Kq7uDiB+5wBcWM4ZkJIOmE/NplSyIjIxO3rkyNuo1IFg4xhYWFMTGlpZmla/dWP5mWXlCysKhfSQjJly52ptpMEpNKohe+TptyT5nDwJzPSxgjQu0372g/0t3dzhqMK907G6tJs2pa+iGLAQCiD78p46afzQAAAABJRU5ErkJggg==")

;conversion
bitmaps["makehoney"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABkAAAAOAQMAAADg9CUDAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFFJREFUeAEBRgC5/wDgAAOAAOAAA4AA4AADgADh/4OAAOB/g4AA4H4DgADgPgOAAOAYA4AA4BgDgADgGAOAAOAYA4AA4AgDgADgAAOAAOAAA4BWYxcOMd0SeAAAAABJRU5ErkJggg==")
bitmaps["collectpollen"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAABcAAAALAQMAAACu8IQDAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAADdJREFUeAEBLADT/wDBgAAAwYAAAMGAAADBgAAAwYMGAMGDBgDBg/4AwYP+AMGDAADBgwAAwYMAV/YP6c5DNZYAAAAASUVORK5CYII=")

;collect
bitmaps["passfull"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAANAQMAAABvi/fXAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAExJREFUeAEBQQC+/wAGAMAAAA8AwAAACYDB+AAYgMH4ABCAwYAAEMDBgAAwwMGAACBAwYAAP+DBgABgIMGAAEAgwYAAQBDBgADAEMGAw1sXQS/tL+4AAAAASUVORK5CYII=")
bitmaps["passnone"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACMAAAAHAQMAAAC4KmY6AAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAADVJREFUeAEBKgDV/wB/A/gfwADBgggQQADBhgwwYADBhgwwYADBhgwwYADBh/w/4ADBh/w/4DR2EGRmE1R+AAAAAElFTkSuQmCC")
bitmaps["passcooldown"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAACAAAAALAQMAAAAk3x1CAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAEJJREFUeAEBNwDI/wDAA/B8AMADAIIA/gMAAADAAwEBAMADAQEAwAMB/wDAAwD+AMADAAAAwAMAgADAAwDGAMADADiYVQ4O+iTe6QAAAABJRU5ErkJggg==")

;inventory
bitmaps["blueberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAFkAAAASBAMAAADCum8zAAAAD1BMVEUAAAAbKjUcKzYdLDceLDe8hzzeAAAAAXRSTlMAQObYZgAAAJlJREFUeNq10oEJAjEMheEXXSD/TaCb6P5LSfo42sAhRTAkIYGvB1cqSO0Hg0c7Et80+zqL/lsz1arznVVhV11TB4yWkkaHUfc0AhadlaGZyJXeIK+0e20unO3bN+DUT2BqH+x/GRSxrjGnfslai6711DVOnbHqGGrR0bQyPMWij6Gdj6ahvRMPuB2+76kHEaTHy+h6M37Qkj4y8wuCNNqdxAAAAABJRU5ErkJggg==")
bitmaps["strawberry"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGUAAAARBAMAAAA24X8rAAAAD1BMVEUAAAAbKjUcKzYdLDceLDe8hzzeAAAAAXRSTlMAQObYZgAAALlJREFUeNqd0tFNQzEUg+HftAPYwADtBowA+y+FsJKGqO3DrZUTXTn3e4gUaMR9xLMouRw1VzhsDLxklKBzOCdGdG3GP/4bGWRyMylPSxOUNt2Tzqlm/Kp+lw9jxFqBjkHAKR4nw2A8zZSGTiiFLJMELHIz1yTLDA76ombSTyFNkyRe5nsa7yZBYRqAZazHRv+NNoO1LrMZ87bqy2aSbgkoNSSpoV3eW5llZHqyPZ/Rf7BlM0fysgF+AYk1CtE5QOD0AAAAAElFTkSuQmCC")

;planters
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
bitmaps["yes"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB0AAAAPAQMAAAAiQ1bcAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFZJREFUeAEBSwC0/wDDAAfAAEIACGAAfgAQMAA8ABAQABgAIAgAGAAgCAAYACAYABgAP/gAGAAgAAAYAAAAABgAIAAAGAAwAAAYADAAABgAGDAAGAAP4FGfB+0KKAbEAAAAAElFTkSuQmCC")
bitmaps["no"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAB4AAAAQAQMAAAA79F2RAAAABlBMVEUAAAD3//lCqWtQAAAAAXRSTlMAQObYZgAAAFtJREFUeAEBUACv/wD4CAHAANwIB/AAjAgMGACGCAgIAIYIEAwAgwgQBACBiBAEAIGIEAQAgMgQBACAeBAEAIA4EAQAgDgQBACAOBAEAIAYCAgAgAgMGACACAfwttYQFVcrYb0AAAAASUVORK5CYII=")

;reconnect
bitmaps["loading"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAGQAAABkAQMAAABKLAcXAAAAA1BMVEUiV6ixRE8dAAAAE0lEQVR42mMYBaNgFIyCUUBXAAAFeAABSanTpAAAAABJRU5ErkJggg==")
bitmaps["science"] := Gdip_BitmapFromBase64("iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKAQMAAAC3/F3+AAAAA1BMVEX0qQ0Uw53LAAAACklEQVR42mPACwAAHgAB3XenRQAAAABJRU5ErkJggg==")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu, tray, Icon, %A_ScriptDir%\nm_image_assets\auryn.ico, 1, 1
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
SkinForm(Apply, A_ScriptDir . "\styles\USkin.dll", A_ScriptDir . "\styles\" . GuiTheme . ".msstyles")
OnExit("GetOut")
if (AlwaysOnTop)
	gui +AlwaysOnTop
gui +border +hwndhGUI +OwnDialogs
Gui, Font, s8 cDefault Norm, Tahoma
CurrentField:=FieldName%CurrentFieldNum%
patternlist := "|" ; ~ retrieve list of patterns from 'patterns' folder
Loop, Files, %A_ScriptDir%\patterns\*.ahk
	patternlist .= StrReplace(A_LoopFileName, ".ahk") "|"
Gui, Font, w700
Gui, Add, Text, x5 y240 w50 +left +BackgroundTrans,CurrentField:
Gui, Add, Text, x172 y240 w30 +left +BackgroundTrans,Status:
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Button, x80 y240 w10 h15 gnm_currentFieldUp, <
Gui, Add, Button, x160 y240 w10 h15 gnm_currentFieldDown, >
Gui, Add, Text, x90 y240 w70 +left +BackgroundTrans +border vCurrentField,%CurrentField%
Gui, Add, Text, x215 y240 w280 +left +BackgroundTrans vstate hwndhwndstate +border, %state%
;Gui, Add, Text, x140 y270 w200 +left +BackgroundTrans vobjective,
;Gui, Add, Text, x300 y270 w200 +left +BackgroundTrans +border vpp, <no data>
;Gui, Add, Text, x5 y285 w100 +left +BackgroundTrans vtimeofDay, Day
;Gui, Add, Text, x40 y285 w100 +left +BackgroundTrans vVBState, -1
Gui, Font, s8 w700 Underline cBlue
Gui, Add, Text, x421 y255 gDiscordLink, Join Discord
Gui, Add, Text, x421 y269 gDonateLink, >>Donate<<
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x423 y285 gnm_ShowAdvancedSettings, Ver. %versionID%
;control buttons
Gui, Add, Button, x10 y275 w60 h20 gf1, Start (F1)
Gui, Add, Button, x75 y275 w60 h20 gf3, Stop (F3)
Gui, Add, Button, x140 y275 w60 h20 gf2, Pause (F2)
;gui mode
Gui, Add, Button, x315 y260 w100 h30 vGuiModeButton gnm_guiModeButton, % GuiMode ? "Current Mode:`nADVANCED" : "EASY MODE"
nm_createStatusUpdater()

;ADD TABS
Gui, Add, Tab, x1 y-1 w550 h240 vTab gnm_TabSelect, Gather|Collect/Kill|Boost|Quest|Planters+|Status|Settings|Contributors
;GuiControl,focus, Tab ~ seems to already set focus to tabs by default?
Gui, Add, Text, x15 y260 cRED +BackgroundTrans vLockedText Hidden, Tabs Locked While Running, F3 to Unlock
Gui, Font, w700
Gui, Add, Text, x40 y25 w100 +left +BackgroundTrans,Gathering
Gui, Add, Text, x180 y25 w100 +left +BackgroundTrans,Pattern
Gui, Add, Text, x280 y25 w100 +left +BackgroundTrans,Until
Gui, Add, Text, x430 y25 w100 +left +BackgroundTrans vSprinklerTitle,Sprinkler
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x30 y40 w100 +left +BackgroundTrans,Field Rotation
Gui, Add, Text, x111 y31 w1 h200 0x7 ; ~ 0x7 = SS_BLACKFRAME - faster drawing of lines since no text rendered
Gui, Add, Text, x125 y40 w100 +left +BackgroundTrans,Shape
Gui, Add, Text, x180 y40 w100 +left +BackgroundTrans,Length
Gui, Add, Text, x225 y40 w100 +left +BackgroundTrans vpatternRepsHeader,Width
Gui, Add, Text, x261 y31 w1 h200 0x7
Gui, Add, Text, x270 y40 w100 +left +BackgroundTrans,Mins
Gui, Add, Text, x305 y40 w100 +left +BackgroundTrans vuntilPackHeader,Pack`%
Gui, Add, Text, x350 y40 w100 +left +BackgroundTrans,To Hive By:
Gui, Add, Text, x410 y31 w1 h200 0x7
Gui, Add, Text, x420 y40 w100 +left +BackgroundTrans vsprinklerStartHeader,Start Location
Gui, Add, Text, x5 y54 w492 h1 0x7
Gui, Add, Text, x20 y110 w474 h1 0x7
Gui, Add, Text, x20 y170 w474 h1 0x7
Gui, Add, Text, x20 y230 w474 h1 0x7
Gui, Font, w700
Gui, Add, Text, x5 y62 w10 +left +BackgroundTrans,1:
Gui, Add, Text, x5 y120 w10 +left +BackgroundTrans,2:
Gui, Add, Text, x5 y180 w10 +left +BackgroundTrans,3:
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, DropDownList, x18 y57 w90 vFieldName1 gnm_FieldSelect1 Disabled, % LTrim(StrReplace("|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName1 "|", "|" FieldName1 "||"), "|")
Gui, Add, DropDownList, x18 y115 w90 vFieldName2 gnm_FieldSelect2 Disabled, % LTrim(StrReplace("|None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName2 "|", "|" FieldName2 "||"), "|")
Gui, Add, DropDownList, x18 y175 w90 vFieldName3 gnm_FieldSelect3 Disabled, % LTrim(StrReplace("|None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower|", "|" FieldName3 "|", "|" FieldName3 "||"), "|")
Gui, Add, DropDownList, x118 y57 w60 vFieldPattern1 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern1 "|", "|" FieldPattern1 "||"), "|")
Gui, Add, DropDownList, x118 y115 w60 vFieldPattern2 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern2 "|", "|" FieldPattern2 "||"), "|")
Gui, Add, DropDownList, x118 y175 w60 vFieldPattern3 gnm_SaveGather Disabled, % LTrim(StrReplace(patternlist "Stationary|", "|" FieldPattern3 "|", "|" FieldPattern3 "||"), "|")
Gui, Add, DropDownList, x180 y57 w40 vFieldPatternSize1 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize1 "|", "|" FieldPatternSize1 "||"), "|")
Gui, Add, DropDownList, x180 y115 w40 vFieldPatternSize2 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize2 "|", "|" FieldPatternSize2 "||"), "|")
Gui, Add, DropDownList, x180 y175 w40 vFieldPatternSize3 gnm_SaveGather Disabled, % LTrim(StrReplace("|XS|S|M|L|XL|", "|" FieldPatternSize3 "|", "|" FieldPatternSize3 "||"), "|")
Gui, Add, DropDownList, x222 y57 w35 vFieldPatternReps1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps1 "|", "|" FieldPatternReps1 "||"), "|")
Gui, Add, DropDownList, x222 y115 w35 vFieldPatternReps2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps2 "|", "|" FieldPatternReps2 "||"), "|")
Gui, Add, DropDownList, x222 y175 w35 vFieldPatternReps3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|", "|" FieldPatternReps3 "|", "|" FieldPatternReps3 "||"), "|")
Gui, Add, Checkbox, x20 y80 +BackgroundTrans vFieldDriftCheck1 gnm_SaveGather Checked%FieldDriftCheck1% Disabled,Field Drift`nCompensation
Gui, Add, Checkbox, x20 y140 +BackgroundTrans vFieldDriftCheck2 gnm_SaveGather Checked%FieldDriftCheck2% Disabled,Field Drift`nCompensation
Gui, Add, Checkbox, x20 y200 +BackgroundTrans vFieldDriftCheck3 gnm_SaveGather Checked%FieldDriftCheck3% Disabled,Field Drift`nCompensation
Gui, Add, Checkbox, x115 y80 +BackgroundTrans vFieldPatternShift1 gnm_SaveGather Checked%FieldPatternShift1% Disabled, Gather w/Shift-Lock
Gui, Add, Text, x115 y95 vFieldInvertText1, Invert:
Gui, Add, Checkbox, x145 y95 vFieldPatternInvertFB1 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB1% Disabled, F/B
Gui, Add, Checkbox, x185 y95 vFieldPatternInvertLR1 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR1% Disabled, L/R
Gui, Add, Checkbox, x115 y140 +BackgroundTrans vFieldPatternShift2 gnm_SaveGather Checked%FieldPatternShift2% Disabled, Gather w/Shift-Lock
Gui, Add, Text, x115 y155 vFieldInvertText2, Invert:
Gui, Add, Checkbox, x145 y155 vFieldPatternInvertFB2 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB2% Disabled, F/B
Gui, Add, Checkbox, x185 y155 vFieldPatternInvertLR2 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR2% Disabled, L/R
Gui, Add, Checkbox, x115 y200 +BackgroundTrans vFieldPatternShift3 gnm_SaveGather Checked%FieldPatternShift3% Disabled, Gather w/Shift-Lock
Gui, Add, Text, x115 y215 vFieldInvertText3, Invert:
Gui, Add, Checkbox, x145 y215 vFieldPatternInvertFB3 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertFB3% Disabled, F/B
Gui, Add, Checkbox, x185 y215 vFieldPatternInvertLR3 gnm_SaveGather +BackgroundTrans Checked%FieldPatternInvertLR3% Disabled, L/R
Gui, Add, Text, x235 y80 vrotateCam1, Before Gathering,`n   Rotate Camera:
Gui, Add, Text, x235 y140 vrotateCam2, Before Gathering,`n   Rotate Camera:
Gui, Add, Text, x235 y200 vrotateCam3, Before Gathering,`n   Rotate Camera:
Gui, Add, DropDownList, x325 y82 w50 vFieldRotateDirection1 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection1 "|", "|" FieldRotateDirection1 "||"), "|")
Gui, Add, DropDownList, x325 y142 w50 vFieldRotateDirection2 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection2 "|", "|" FieldRotateDirection2 "||"), "|")
Gui, Add, DropDownList, x325 y202 w50 vFieldRotateDirection3 gnm_SaveGather Disabled, % LTrim(StrReplace("|None|Left|Right|", "|" FieldRotateDirection3 "|", "|" FieldRotateDirection3 "||"), "|")
Gui, Add, DropDownList, x375 y82 w32 vFieldRotateTimes1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes1 "|", "|" FieldRotateTimes1 "||"), "|")
Gui, Add, DropDownList, x375 y142 w32 vFieldRotateTimes2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes2 "|", "|" FieldRotateTimes2 "||"), "|")
Gui, Add, DropDownList, x375 y202 w32 vFieldRotateTimes3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|", "|" FieldRotateTimes3 "|", "|" FieldRotateTimes3 "||"), "|")
Gui, Add, Edit, x268 y57 w30 h20 limit3 number vFieldUntilMins1 gnm_SaveGather Disabled, %FieldUntilMins1%
Gui, Add, Edit, x268 y115 w30 h20 limit3 number vFieldUntilMins2 gnm_SaveGather Disabled, %FieldUntilMins2%
Gui, Add, Edit, x268 y175 w30 h20 limit3 number vFieldUntilMins3 gnm_SaveGather Disabled, %FieldUntilMins3%
Gui, Add, DropDownList, x300 y57 w45 vFieldUntilPack1 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack1 "|", "|" FieldUntilPack1 "||"), "|")
Gui, Add, DropDownList, x300 y115 w45 vFieldUntilPack2 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack2 "|", "|" FieldUntilPack2 "||"), "|")
Gui, Add, DropDownList, x300 y175 w45 vFieldUntilPack3 gnm_SaveGather Disabled, % LTrim(StrReplace("|100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5|", "|" FieldUntilPack3 "|", "|" FieldUntilPack3 "||"), "|")
Gui, Add, DropDownList, x347 y57 w60 vFieldReturnType1 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|Rejoin|", "|" FieldReturnType1 "|", "|" FieldReturnType1 "||"), "|")
Gui, Add, DropDownList, x347 y115 w60 vFieldReturnType2 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|Rejoin|", "|" FieldReturnType2 "|", "|" FieldReturnType2 "||"), "|")
Gui, Add, DropDownList, x347 y175 w60 vFieldReturnType3 gnm_SaveGather Disabled, % LTrim(StrReplace("|Walk|Reset|Rejoin|", "|" FieldReturnType3 "|", "|" FieldReturnType3 "||"), "|")
Gui, Add, DropDownList, x415 y57 w80 vFieldSprinklerLoc1 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc1 "|", "|" FieldSprinklerLoc1 "||"), "|")
Gui, Add, DropDownList, x415 y115 w80 vFieldSprinklerLoc2 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc2 "|", "|" FieldSprinklerLoc2 "||"), "|")
Gui, Add, DropDownList, x415 y175 w80 vFieldSprinklerLoc3 gnm_SaveGather Disabled, % LTrim(StrReplace("|Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left|", "|" FieldSprinklerLoc3 "|", "|" FieldSprinklerLoc3 "||"), "|")
Gui, Add, Text, x415 y82 w80 vsprinklerDistance1,Distance:
Gui, Add, Text, x415 y140 w80 vsprinklerDistance2,Distance:
Gui, Add, Text, x415 y200 w80 vsprinklerDistance3,Distance:
Gui, Add, DropDownList,x460 y80 w35 vFieldSprinklerDist1 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist1 "|", "|" FieldSprinklerDist1 "||"), "|")
Gui, Add, DropDownList, x460 y138 w35 vFieldSprinklerDist2 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist2 "|", "|" FieldSprinklerDist2 "||"), "|")
Gui, Add, DropDownList, x460 y198 w35 vFieldSprinklerDist3 gnm_SaveGather Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|7|8|9|10|", "|" FieldSprinklerDist3 "|", "|" FieldSprinklerDist3 "||"), "|")

;Contributors TAB
;------------------------
Gui, Tab, Contributors
;GuiControl,focus, Tab
page_end := nm_ContributorsImage()
Gui, Font, w700
Gui, Add, Text, x15 y30 w225 +wrap +backgroundtrans cWhite, Development
Gui, Add, Text, x261 y30 w225 +wrap +backgroundtrans cWhite, Contributors
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x18 y45 w225 +wrap +backgroundtrans cWhite, Special Thanks for your contributions in the development and testing of this project!
Gui, Add, Text, x264 y45 w180 +wrap +backgroundtrans cWhite, Thank you for your donations and contributions to this project!
Gui, Add, Button, x440 y46 w18 h18 hwndhcleft gnm_ContributorsPageButton Disabled, <
Gui, Add, Button, % "x464 y46 w18 h18 hwndhcright gnm_ContributorsPageButton Disabled" page_end, >

;STATUS TAB
;------------------------
Gui, Tab, Status
;GuiControl,focus, Tab
Gui, Font, w700
Gui, Add, GroupBox, x5 y23 w250 h214, Status Log
Gui, Add, GroupBox, x255 y23 w240 h160, Stats
Gui, Add, GroupBox, x255 y183 w240 h54, Discord Webhook ; ~ new groupbox for webhook options, 'Discord' hopefully results in fewer "wHaT iS wEbHoOk?" questions
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Checkbox, x85 y23 vStatusLogReverse gnm_StatusLogReverseCheck Checked%StatusLogReverse%, Reverse Order
Gui, Add, Text, x10 y37 w240 r15 -Wrap left vstatuslog, Status Log:
Gui, font, w700
Gui, Add, Text, x260 y37, Total
Gui, Add, Text, x380 y37, Session
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x260 y52 w230 h130 -Wrap left vstats,
Gui, Add, Button, x290 y37 w50 h15 vResetTotalStats gnm_ResetTotalStats, Reset
Gui, Add, Checkbox, x375 y183 +BackgroundTrans vWebhookCheck gnm_saveWebhook Checked%WebhookCheck%, Enable
Gui, Add, Button, x437 y183 w10 h15 gnm_WebhookHelp, ?
Gui, Add, Text, x260 y199 w100 +left +BackgroundTrans, Link (full address):
Gui, Add, Edit, % "x348 y198 w142 h16 +BackgroundTrans vWebhook gnm_saveWebhook Disabled" !WebhookCheck, %Webhook%
Gui, Add, Checkbox, % "x260 y217 w77 +BackgroundTrans vssCheck gnm_saveWebhook Checked" ssCheck " Disabled" !WebhookCheck, Screenshots
Gui, Add, Text, x340 y217 w80 +left +BackgroundTrans, User ID (Ping):
Gui, Add, Edit, % "x410 y216 w80 h16 +BackgroundTrans vdiscordUID Limit20 Number gnm_saveWebhook Disabled" !WebhookCheck, %discordUID%
nm_setStats()

;SETTINGS TAB
;------------------------
Gui, Tab, Settings
;gui settings
Gui, Add, GroupBox, x10 y25 w160 h65, GUI SETTINGS
Gui, Add, Checkbox, x15 y73 vAlwaysOnTop gnm_AlwaysOnTop Checked%AlwaysOnTop%, Always On Top
Gui, Add, Text, x15 y40 w70 +left +BackgroundTrans,GUI Theme:
Gui, Add, DropDownList, x90 y34 w72 h100 vGuiTheme gnm_guiThemeSelect Disabled, % LTrim(StrReplace("|Allure|Ayofe|BluePaper|Concaved|Core|Cosmo|Fanta|GrayGray|Hana|Invoice|Lakrits|Luminous|MacLion3|Minimal|Museo|Panther|PaperAGV|PINK|Relapse|Simplex3|SNAS|Stomp|VS7|WhiteGray|Woodwork|", "|" GuiTheme "|", "|" GuiTheme "||"), "|")

Gui, Add, Text, x15 y57 w100 +left +BackgroundTrans,GUI Transparency:
Gui, Add, DropDownList, x110 y55 w52 h100 vGuiTransparency gnm_guiTransparencySet Disabled, % LTrim(StrReplace("|0|5|10|15|20|25|30|35|40|45|50|55|60|65|70|", "|" GuiTransparency "|", "|" GuiTransparency "||"), "|")

;key settings
Gui, Add, GroupBox, x340 y25 w150 h210, KEY SETTINGS
Gui, Add, DropDownList, x425 y25 w60 vKeyboardLayout gnm_keyboardLayout, % LTrim(StrReplace("|qwerty|azerty|other|", "|" KeyboardLayout "|", "|" KeyboardLayout "||"), "|")
Gui, Add, Text, x340 y55 w80 +right +BackgroundTrans,Move Forward:
Gui, Add, Text, x340 y75 w80 +right +BackgroundTrans,Move Left:
Gui, Add, Text, x340 y95 w80 +right +BackgroundTrans,Move Back:
Gui, Add, Text, x340 y115 w80 +right +BackgroundTrans,Move Right:
Gui, Add, Text, x340 y135 w80 +right +BackgroundTrans,Camera Left:
Gui, Add, Text, x340 y155 w80 +right +BackgroundTrans,Camera Right:
Gui, Add, Text, x340 y175 w80 +right +BackgroundTrans,Zoom In:
Gui, Add, Text, x340 y195 w80 +right +BackgroundTrans,Zoom Out:
Gui, Add, Text, x340 y215 w80 +right +BackgroundTrans,Add Key Delay:
Gui, Add, Edit, x425 y50 w20 limit1 vFwdKey gnm_saveKeys Disabled, %FwdKey%
Gui, Add, Edit, x425 y70 w20 limit1 vLeftKey gnm_saveKeys Disabled, %LeftKey%
Gui, Add, Edit, x425 y90 w20 limit1 vBackKey gnm_saveKeys Disabled, %BackKey%
Gui, Add, Edit, x425 y110 w20 limit1 vRightKey gnm_saveKeys Disabled, %RightKey%
Gui, Add, Edit, x425 y130 w20 limit1 vRotLeft gnm_saveKeys Disabled, %RotLeft%
Gui, Add, Edit, x425 y150 w20 limit1 vRotRight gnm_saveKeys Disabled, %RotRight%
Gui, Add, Edit, x425 y170 w20 limit1 vZoomIn gnm_saveKeys Disabled, %ZoomIn%
Gui, Add, Edit, x425 y190 w20 limit1 vZoomOut gnm_saveKeys Disabled, %ZoomOut%
Gui, Add, Edit, x425 y210 w30 limit3 number vKeyDelay gnm_saveKeys Disabled, %KeyDelay%

;character settings
Gui, Add, GroupBox, x180 y25 w150 h210, CHARACTER SETTINGS
Gui, Add, Text, x185 y40 w110 +left +BackgroundTrans,Movement Speed:
Gui, Font, s6
Gui, Add, Text, x185 y55 w80 +right +BackgroundTrans,(WITHOUT HASTE)
Gui, Add, Text, x66 y112 w60 +left +BackgroundTrans,(6-5-4-3-2-1)
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Edit, x278 y43 w43 r1 limit5 vMoveSpeedNum gnm_moveSpeed Disabled, %MoveSpeedNum%
Gui, Add, CheckBox, x185 y69 w125 h15 vNewWalk gnm_saveConfig +BackgroundTrans Checked%NewWalk%, MoveSpeed Correction
Gui, Add, Button, x315 y68 w10 h15 gnm_NewWalkHelp, ?
Gui, Add, Text, x185 y90 w110 +left +BackgroundTrans,Move Method:
Gui, Add, DropDownList, x254 y87 w68 vMoveMethod gnm_saveConfig Disabled, % LTrim(StrReplace("|Walk|Cannon|", "|" MoveMethod "|", "|" MoveMethod "||"), "|")
Gui, Add, Text, x185 y111 w110 +left +BackgroundTrans,Sprinkler Type:
Gui, Add, DropDownList, x257 y108 w65 vSprinklerType gnm_saveConfig Disabled, % LTrim(StrReplace("|None|Basic|Silver|Golden|Diamond|Supreme|", "|" SprinklerType "|", "|" SprinklerType "||"), "|")
Gui, Add, Text, x185 y132 w110 +left +BackgroundTrans,Convert Balloon:
Gui, Add, Text, x210 y147 w110 +left +BackgroundTrans,\____\___
Gui, Add, DropDownList, x265 y129 w57 vConvertBalloon gnm_convertBalloon Disabled, % LTrim(StrReplace("|Always|Never|Every|", "|" ConvertBalloon "|", "|" ConvertBalloon "||"), "|")
Gui, Add, Edit, % "x262 y150 w25 r1 number +BackgroundTrans vConvertMins gnm_saveConfig" ((ConvertBalloon = "Every") ? "" : " Disabled") , %ConvertMins%
Gui, Add, Text, x292 y154, Mins
Gui, Add, Text, x185 y175 w110 +left +BackgroundTrans,Multiple Reset:
Gui, Add, Slider, x256 y174 w70 h16 vMultiReset gnm_saveConfig Disabled ToolTipTop Range0-3 TickInterval1, %MultiReset%
Gui, Add, CheckBox, x185 y195 vDisableToolUse gnm_saveConfig +BackgroundTrans Checked%DisableToolUse%, Disable Tool Use
Gui, Add, CheckBox, x185 y210 vAnnounceGuidingStar gnm_saveConfig +BackgroundTrans Checked%AnnounceGuidingStar%, Announce Guiding Star

;hive settings
Gui, Add, GroupBox, x10 y94 w160 h50, HIVE SETTINGS
Gui, Add, Text, x15 y110 w60 +left +BackgroundTrans,Hive Slot:
Gui, Add, DropDownList, x115 y105 w30 vHiveSlot gnm_saveConfig Disabled, % LTrim(StrReplace("|1|2|3|4|5|6|", "|" HiveSlot "|", "|" HiveSlot "||"), "|")
Gui, Add, Text, x15 y125 w110 +left +BackgroundTrans,My Hive Has:
Gui, Add, Edit, x80 y124 w18 h16 Limit2 number +BackgroundTrans vHiveBees gnm_HiveBees Disabled, %HiveBees%
Gui, Add, Text, x103 y125 w110 +left +BackgroundTrans,Bees
Gui, Add, Button, x155 y124 w10 h15 gnm_HiveBeesHelp, ?

;misc. settings
Gui, Add, GroupBox, x10 y148 w160 h90, MISC. SETTINGS
Gui, Add, Text, x15 y165 w80 +Left +BackgroundTrans,Private Server:
Gui, Add, Edit, x90 y164 w75 h16 +BackgroundTrans vPrivServer gnm_ServerLink Disabled, %PrivServer%
Gui, Add, Text, x15 y184 +BackgroundTrans, Reconnect every
Gui, Add, Edit, x100 y183 w18 h16 Number Limit2 vReconnectInterval gnm_setReconnectInterval, %ReconnectInterval%
Gui, Add, Text, x122 y184 +BackgroundTrans, hours
Gui, Add, Text, x36 y202 +BackgroundTrans, starting at
Gui, Add, Edit, x90 y201 w18 h16 Number Limit2 vReconnectHour gnm_setReconnectHour, %ReconnectHour%
Gui, font, w1000 s11
Gui, Add, Text, x109 y198 +BackgroundTrans, :
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Edit, x115 y201 w18 h16 Number Limit2 vReconnectMin gnm_setReconnectMin, %ReconnectMin%
Gui, font, s6 w700
Gui, Add, Text, x135 y204 +BackgroundTrans, UTC
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Button, x155 y201 w10 h15 gnm_ReconnectTimeHelp, ?
Gui, Add, Button, x25 y220 w130 h15 gnm_AutoClickerOptionsButton, AutoClicker Options (F4)


;COLLECT TAB
;------------------------
Gui, Tab, Collect/Kill
;GuiControl,focus, Tab
;collect
Gui, Font, w700
Gui, Add, GroupBox, x10 y25 w115 h120, Collect
Gui, Add, GroupBox, x130 y25 w110 h120, Dispensers
Gui, Add, Text, x260 y25 w80 left +BackgroundTrans, Bug Run
Gui, Add, Text, x390 y25 w80 left +BackgroundTrans, Other
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, Text, x260 y39 w110 h1 0x7
Gui, Add, Text, x380 y39 w110 h1 0x7
Gui, Add, Text, x248 y25 w2 h210 0x7
Gui, Add, Text, x251 y25 w2 h210 0x7
Gui, Add, Checkbox, x12 y40 +BackgroundTrans vClockCheck gnm_saveCollect Checked%ClockCheck% Disabled, Clock (tickets)
Gui, Add, Checkbox, x12 y60 +BackgroundTrans vMondoBuffCheck gnm_saveCollect Checked%MondoBuffCheck% Disabled, Mondo
Gui, Add, DropDownList, x77 y55 w45 vMondoAction gnm_saveCollect Disabled, % LTrim(StrReplace("|Buff|Kill" (PMondoGuid ? "|Tag|Guid" : "") "|", "|" MondoAction "|", "|" MondoAction "||"), "|")
Gui, Add, Checkbox, x12 y80 +BackgroundTrans vAntPassCheck gnm_saveCollect Checked%AntPassCheck% Disabled, Ant
Gui, Add, DropDownList, x52 y75 w70 vAntPassAction gnm_saveCollect Disabled, % LTrim(StrReplace("|Pass|Challenge|", "|" AntPassAction "|", "|" AntPassAction "||"), "|")
Gui, Add, Checkbox, x12 y100 +BackgroundTrans vRoboPassCheck gnm_saveCollect Checked%RoboPassCheck% Disabled, Robo Pass
;dispensers
Gui, Add, Checkbox, x132 y40 +BackgroundTrans vHoneyDisCheck gnm_saveCollect Checked%HoneyDisCheck% Disabled, Honey
Gui, Add, Checkbox, x132 y55 +BackgroundTrans vTreatDisCheck gnm_saveCollect Checked%TreatDisCheck% Disabled, Treat
Gui, Add, Checkbox, x132 y70 +BackgroundTrans vBlueberryDisCheck gnm_saveCollect Checked%BlueberryDisCheck% Disabled, Blueberry
Gui, Add, Checkbox, x132 y85 +BackgroundTrans vStrawberryDisCheck gnm_saveCollect Checked%StrawberryDisCheck% Disabled, Strawberry
Gui, Add, Checkbox, x132 y100 +BackgroundTrans vCoconutDisCheck gnm_saveCollect Checked%CoconutDisCheck% Disabled, Coconut
Gui, Add, Checkbox, x132 y115 +BackgroundTrans vRoyalJellyDisCheck gnm_saveCollect Checked%RoyalJellyDisCheck% Disabled, Royal Jelly (star)
Gui, Add, Checkbox, x132 y130 +BackgroundTrans vGlueDisCheck gnm_saveCollect Checked%GlueDisCheck% Disabled, Glue

;BEESMAS
beesmasActive:=1
Gui, Font, w700
Gui, Add, GroupBox, x10 y147 w230 h90, % "Beesmas" (beesmasActive ? "" : " (Reserved)")
Gui, Font, s8 cDefault Norm, Tahoma
hBM := Gdip_CreateHBITMAPFromBitmap(bitmaps["beesmas"])
Gui, Add, Picture, % "+BackgroundTrans x77 y144 w20 h20 Hidden" !beesmasActive, HBITMAP:*%hBM%
DllCall("DeleteObject", "ptr", hBM)
Gui, Add, Checkbox, % "x102 y148 +BackgroundTrans vBeesmasGatherInterruptCheck gnm_saveCollect Checked" (BeesmasGatherInterruptCheck && beesmasActive) " Disabled" !beesmasActive, Allow Gather Interrupt
Gui, Add, Checkbox, % "x15 y160 w62 +BackgroundTrans vStockingsCheck gnm_saveCollect Checked" (StockingsCheck && beesmasActive) " Disabled" !beesmasActive, Stockings
Gui, Add, Checkbox, % "x15 y175 +BackgroundTrans vWreathCheck gnm_saveCollect Checked" (WreathCheck && beesmasActive) " Disabled" !beesmasActive, Wreath
Gui, Add, Checkbox, % "x15 y190 +BackgroundTrans vFeastCheck gnm_saveCollect Checked" (FeastCheck && beesmasActive) " Disabled" !beesmasActive, Feast
Gui, Add, Checkbox, % "x15 y205 +BackgroundTrans vGingerbreadCheck gnm_saveCollect Checked" (GingerbreadCheck && beesmasActive) " Disabled" !beesmasActive, Gingerbread
Gui, Add, Checkbox, % "x15 y220 +BackgroundTrans vSnowMachineCheck gnm_saveCollect Checked" (SnowMachineCheck && beesmasActive) " Disabled" !beesmasActive, Snow Machine
Gui, Add, Checkbox, % "x135 y167 +BackgroundTrans vCandlesCheck gnm_saveCollect Checked" (CandlesCheck && beesmasActive) " Disabled" !beesmasActive, Candles
Gui, Add, Checkbox, % "x135 y182 +BackgroundTrans vSamovarCheck gnm_saveCollect Checked" (SamovarCheck && beesmasActive) " Disabled" !beesmasActive, Samovar
Gui, Add, Checkbox, % "x135 y197 +BackgroundTrans vLidArtCheck gnm_saveCollect Checked" (LidArtCheck && beesmasActive) " Disabled" !beesmasActive, Lid Art
Gui, Add, Checkbox, % "x135 y212 +BackgroundTrans vGummyBeaconCheck gnm_saveCollect Checked" (GummyBeaconCheck && beesmasActive) " Disabled" !beesmasActive, Gummy Beacon

;BUGS
Gui, Add, Checkbox, x310 y25 vBugRunCheck gnm_BugRunCheck Checked%BugRunCheck%, Select All
Gui, Add, Checkbox, x260 y43 w110 +border vGiftedViciousCheck gnm_saveCollect Checked%GiftedViciousCheck%, Apply Hive Bonus:`nGifted Vicious Bee
Gui, Add, Checkbox, x257 y70 w125 h15 +BackgroundTrans vBugrunInterruptCheck gnm_saveCollect Checked%BugrunInterruptCheck%, Allow Gather Interrupt
Gui, Add, text, x260 y90 +BackgroundTrans, Loot
Gui, Add, text, x295 y90 +BackgroundTrans, Kill
Gui, Add, text, x260 y92 +BackgroundTrans, _ _ _ _ _ _ _ _ _ _ _ _
Gui, Add, text, x285 y90 +BackgroundTrans, !
Gui, Add, text, x285 y100 +BackgroundTrans, !
Gui, Add, text, x285 y120 +BackgroundTrans, !
Gui, Add, text, x285 y140 +BackgroundTrans, !
Gui, Add, text, x285 y160 +BackgroundTrans, !
Gui, Add, text, x285 y180 +BackgroundTrans, !
Gui, Add, text, x285 y200 +BackgroundTrans, !
Gui, Add, Checkbox, x266 y110 +BackgroundTrans vBugrunLadybugsLoot  gnm_saveCollect Checked%BugrunLadybugsLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x266 y130 +BackgroundTrans vBugrunRhinoBeetlesLoot gnm_saveCollect Checked%BugrunRhinoBeetlesLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x266 y150 +BackgroundTrans vBugrunSpiderLoot gnm_saveCollect Checked%BugrunSpiderLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x266 y170 +BackgroundTrans vBugrunMantisLoot gnm_saveCollect Checked%BugrunMantisLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x266 y190 +BackgroundTrans vBugrunScorpionsLoot gnm_saveCollect Checked%BugrunScorpionsLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x266 y210 +BackgroundTrans vBugrunWerewolfLoot gnm_saveCollect Checked%BugrunWerewolfLoot% Disabled, %A_Space%!
Gui, Add, Checkbox, x294 y110 +BackgroundTrans vBugrunLadybugsCheck gnm_saveCollect Checked%BugrunLadybugsCheck% Disabled, Ladybugs
Gui, Add, Checkbox, x294 y130 +BackgroundTrans vBugrunRhinoBeetlesCheck gnm_saveCollect Checked%BugrunRhinoBeetlesCheck% Disabled, Rhino Beetles
Gui, Add, Checkbox, x294 y150 +BackgroundTrans vBugrunSpiderCheck gnm_saveCollect Checked%BugrunSpiderCheck% Disabled, Spider
Gui, Add, Checkbox, x294 y170 +BackgroundTrans vBugrunMantisCheck gnm_saveCollect Checked%BugrunMantisCheck% Disabled, Mantis
Gui, Add, Checkbox, x294 y190 +BackgroundTrans vBugrunScorpionsCheck gnm_saveCollect Checked%BugrunScorpionsCheck% Disabled, Scorpions
Gui, Add, Checkbox, x294 y210 +BackgroundTrans vBugrunWerewolfCheck gnm_saveCollect Checked%BugrunWerewolfCheck% Disabled, Werewolf
Gui, Add, Checkbox, x390 y45 +BackgroundTrans vStingerCheck gnm_saveCollect Checked%StingerCheck% Disabled, Stingers
Gui, Add, Button, x452 y45 w38 h15 gnm_stingerFields, Fields
Gui, Add, Text, x385 y62, Baby`nLove
Gui, Add, Text, x422 y75, Kill
Gui, Add, text, x387 y77 +BackgroundTrans, _ _ _ _ _ _ _ _ _ _ _ _
Gui, Add, text, x412 y65 +BackgroundTrans, !
Gui, Add, text, x412 y75 +BackgroundTrans, !
Gui, Add, text, x412 y85 +BackgroundTrans, !
Gui, Add, text, x412 y95 +BackgroundTrans, !
Gui, Add, text, x412 y105 +BackgroundTrans, !
Gui, Add, text, x412 y115 +BackgroundTrans, !
Gui, Add, Checkbox, x393 y95 +BackgroundTrans vTunnelBearBabyCheck gnm_saveCollect Checked%TunnelBearBabyCheck% Disabled, %A_Space%!
Gui, Add, Checkbox, x393 y115 +BackgroundTrans vKingBeetleBabyCheck gnm_saveCollect Checked%KingBeetleBabyCheck% Disabled, %A_Space%!
Gui, Add, Checkbox, x421 y95 +BackgroundTrans vTunnelBearCheck gnm_saveCollect Checked%TunnelBearCheck% Disabled, Tunnel Bear
Gui, Add, Checkbox, x421 y115 +BackgroundTrans vKingBeetleCheck gnm_saveCollect Checked%KingBeetleCheck% Disabled, King Beetle
Gui, Add, Checkbox, x421 y135 +BackgroundTrans vCocoCrabCheck gnm_CocoCrabCheck Checked%CocoCrabCheck% Disabled, Coco Crab
Gui, Add, Checkbox, x421 y155 +BackgroundTrans vStumpSnailCheck gnm_saveCollect Checked%StumpSnailCheck% Disabled, Stump Snail
Gui, Add, Checkbox, x421 y175 +BackgroundTrans vCommandoCheck gnm_saveCollect Checked%CommandoCheck% Disabled, Commando

;Other
;Gui, Add, Checkbox, x202 y64 , Ants
nm_saveCollect()

;BOOST TAB
;------------------------
Gui, Tab, Boost
;GuiControl,focus, Tab
;boosters
Gui, Font, W700
Gui, Add, GroupBox, x5 y25 w120 h135, HQ Field Boosters
Gui, Add, GroupBox, x130 y25 w170 h155, Hotbar Slots
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
Gui, Add, Text, x155 y40 w140 left +BackgroundTrans, Use
Gui, Add, Text, x235 y40 w140 left +BackgroundTrans, Mins/Secs
Gui, Add, Text, x134 y54 w162 h1 0x7
Gui, Add, Text, x135 y62 w10 left +BackgroundTrans, 2:
Gui, Add, Text, x135 y82 w10 left +BackgroundTrans, 3:
Gui, Add, Text, x135 y102 w10 left +BackgroundTrans, 4:
Gui, Add, Text, x135 y122 w10 left +BackgroundTrans, 5:
Gui, Add, Text, x135 y142 w10 left +BackgroundTrans, 6:
Gui, Add, Text, x135 y162 w10 left +BackgroundTrans, 7:
Gui, Add, DropDownList, x145 y57 w70 vHotkeyWhile2  gnm_HotkeyWhile2 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile2 "|", "|" HotkeyWhile2 "||"), "|")
Gui, Add, DropDownList, x145 y77 w70 vHotkeyWhile3 gnm_HotkeyWhile3 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile3 "|", "|" HotkeyWhile3 "||"), "|")
Gui, Add, DropDownList, x145 y97 w70 vHotkeyWhile4 gnm_HotkeyWhile4 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile4 "|", "|" HotkeyWhile4 "||"), "|")
Gui, Add, DropDownList, x145 y117 w70 vHotkeyWhile5 gnm_HotkeyWhile5 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile5 "|", "|" HotkeyWhile5 "||"), "|")
Gui, Add, DropDownList, x145 y137 w70 vHotkeyWhile6 gnm_HotkeyWhile6 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile6 "|", "|" HotkeyWhile6 "||"), "|")
Gui, Add, DropDownList, x145 y157 w70 vHotkeyWhile7 gnm_HotkeyWhile7 Disabled, % LTrim(StrReplace("|Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes|GatherStart" (PMondoGuid ? "|Glitter" : "") "|", "|" HotkeyWhile7 "|", "|" HotkeyWhile7 "||"), "|")
Gui, Add, Text, x225 y61 cRED, <-- OFF
Gui, Add, Text, x225 y81 cRED, <-- OFF
Gui, Add, Text, x225 y101 cRED, <-- OFF
Gui, Add, Text, x225 y121 cRED, <-- OFF
Gui, Add, Text, x225 y141 cRED, <-- OFF
Gui, Add, Text, x225 y161 cRED, <-- OFF
Gui, Add, Text, x218 y61 w80 vHBText2 Hidden, ""
Gui, Add, Text, x218 y81 w80 vHBText3 Hidden, ""
Gui, Add, Text, x218 y101 w80 vHBText4 Hidden, ""
Gui, Add, Text, x218 y121 w80 vHBText5 Hidden, ""
Gui, Add, Text, x218 y141 w80 vHBText6 Hidden, ""
Gui, Add, Text, x218 y161 w80 vHBText7 Hidden, ""
Gui, Add, Edit, x220 y57 w30 h20 r1 limit4 number vHotkeyTime2 gnm_saveBoost Disabled, %HotkeyTime2%
Gui, Add, Edit, x220 y77 w30 h20 r1 limit4 number vHotkeyTime3 gnm_saveBoost Disabled, %HotkeyTime3%
Gui, Add, Edit, x220 y97 w30 h20 r1 limit4 number vHotkeyTime4 gnm_saveBoost Disabled, %HotkeyTime4%
Gui, Add, Edit, x220 y117 w30 h20 r1 limit4 number vHotkeyTime5 gnm_saveBoost Disabled, %HotkeyTime5%
Gui, Add, Edit, x220 y137 w30 h20 r1 limit4 number vHotkeyTime6 gnm_saveBoost Disabled, %HotkeyTime6%
Gui, Add, Edit, x220 y157 w30 h20 r1 limit4 number vHotkeyTime7 gnm_saveBoost Disabled, %HotkeyTime7%
Gui, Add, DropDownList, x250 y57 w47 vHotkeyTimeUnits2 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits2 "|", "|" HotkeyTimeUnits2 "||"), "|")
Gui, Add, DropDownList, x250 y77 w47 vHotkeyTimeUnits3 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits3 "|", "|" HotkeyTimeUnits3 "||"), "|")
Gui, Add, DropDownList, x250 y97 w47 vHotkeyTimeUnits4 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits4 "|", "|" HotkeyTimeUnits4 "||"), "|")
Gui, Add, DropDownList, x250 y117 w47 vHotkeyTimeUnits5 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits5 "|", "|" HotkeyTimeUnits5 "||"), "|")
Gui, Add, DropDownList, x250 y137 w47 vHotkeyTimeUnits6 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits6 "|", "|" HotkeyTimeUnits6 "||"), "|")
Gui, Add, DropDownList, x250 y157 w47 vHotkeyTimeUnits7 gnm_saveBoost Disabled, % LTrim(StrReplace("|Secs|Mins|", "|" HotkeyTimeUnits7 "|", "|" HotkeyTimeUnits7 "||"), "|")
nm_HotkeyWhile2(), nm_HotkeyWhile3(), nm_HotkeyWhile4(), nm_HotkeyWhile5(), nm_HotkeyWhile6(), nm_HotkeyWhile7()
;Gui, Add, CheckBox, x135 y185, Unlock Active Play Hotbar
;auto field boost
Gui, Add, Button, x20 y200 w90 h30 vAutoFieldBoostButton gnm_autoFieldBoostButton, % (AutoFieldBoostActive ? "Auto Field Boost`n[ON]" : "Auto Field Boost`n[OFF]")
Gui, Font, w700
Gui, Add, Text, x5 y25 w490 h210 vBoostTabEasyMode +border +center Hidden,`n`nThis Tab Unavailable in Easy Mode
Gui, Font, s8 cDefault Norm, Tahoma



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
Gui, Add, Text, x5 y25 w490 h210 vQuestTabEasyMode +border +center Hidden,`n`nThis Tab Unavailable in Easy Mode
Gui, Font, s8 cDefault Norm, Tahoma

;PLANTERS+ TAB
;------------------------
Gui, Tab, Planters+
;GuiControl,focus, Tab
Gui, Add, Checkbox, x364 y25 +BackgroundTrans vEnablePlantersPlus gba_enableSwitch Checked%EnablePlantersPlus%, Planters+:
Gui, Add, Text, x440 y25 w60 h20 cGreen +left +BackgroundTrans vEnabled, ENABLED
Gui, Add, Text, x440 y25 w60 h20 cRed +left +BackgroundTrans vDisabled, DISABLED
Gui, Add, Text, x17 y24 w40 h20 +left +BackgroundTrans, Presets
Gui, Add, DropDownList, x57 y24 w60 h100 vNPreset gba_nPresetSwitch_ Disabled, %nPreset%||Custom|Blue|Red|White
Gui, Add, Text, x10 y47 w80 h20 +center +BackgroundTrans, Nectar Priority
Gui, Add, Text, x100 y47 w47 h30 +center +BackgroundTrans, Min `%
Gui, Add, Text, x10 y62 w137 h1 0x7
Gui, Add, Text, x10 y69 w10 h20 +Left +BackgroundTrans, 1
Gui, Add, Text, x10 y89 w10 h20 +Left +BackgroundTrans, 2
Gui, Add, Text, x10 y109 w10 h20 +Left +BackgroundTrans, 3
Gui, Add, Text, x10 y129 w10 h20 +Left +BackgroundTrans, 4
Gui, Add, Text, x10 y149 w10 h20 +Left +BackgroundTrans, 5
Gui, Add, DropDownList, x20 y66 w80 h120 vN1priority gba_N1unswitch_ Disabled, % LTrim(StrReplace("|" LTrim(n1string, "|") "|", "|" n1priority "|", "|" n1priority "||"), "|")
Gui, Add, DropDownList, x20 y86 w80 h120 vN2priority gba_N2unswitch_ Disabled, % LTrim(StrReplace("|" LTrim(n2string, "|") "|", "|" n2priority "|", "|" n2priority "||"), "|")
Gui, Add, DropDownList, x20 y106 w80 h120 vN3priority gba_N3unswitch_ Disabled, % LTrim(StrReplace("|" LTrim(n3string, "|") "|", "|" n3priority "|", "|" n3priority "||"), "|")
Gui, Add, DropDownList, x20 y126 w80 h120 vN4priority gba_N4unswitch_ Disabled, % LTrim(StrReplace("|" LTrim(n4string, "|") "|", "|" n4priority "|", "|" n4priority "||"), "|")
Gui, Add, DropDownList, x20 y146 w80 h120 vN5priority gba_N5unswitch_ Disabled, % LTrim(StrReplace("|" LTrim(n5string, "|") "|", "|" n5priority "|", "|" n5priority "||"), "|")
Gui, Add, DropDownList, x105 y66 w40 h100 vN1minPercent gba_N1Punswitch_ Disabled, % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n1minPercent "|", "|" n1minPercent "||"), "|")
Gui, Add, DropDownList, x105 y86 w40 h100 vN2minPercent gba_N2Punswitch_ Disabled, % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n2minPercent "|", "|" n2minPercent "||"), "|")
Gui, Add, DropDownList, x105 y106 w40 h100 vN3minPercent gba_N3Punswitch_ Disabled, % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n3minPercent "|", "|" n3minPercent "||"), "|")
Gui, Add, DropDownList, x105 y126 w40 h100 vN4minPercent gba_N4Punswitch_ Disabled, % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n4minPercent "|", "|" n4minPercent "||"), "|")
Gui, Add, DropDownList, x105 y146 w40 h100 vN5minPercent gba_N5Punswitch_ Disabled, % LTrim(StrReplace("|10|20|30|40|50|60|70|80|90|", "|" n5minPercent "|", "|" n5minPercent "||"), "|")
Gui, Add, Text, x10 y171 w137 h1 0x7
Gui, Add, Text, x5 y178 w70 h20 +right +BackgroundTrans, Harvest Every
Gui, Add, Checkbox, x103 y194 +BackgroundTrans vAutomaticHarvestInterval gba_AutoHarvestSwitch_ Checked%AutomaticHarvestInterval% Disabled, Auto
Gui, Add, Checkbox, x28 y194 +BackgroundTrans vHarvestFullGrown gba_HarvestFullGrownSwitch_ Checked%HarvestFullGrown% Disabled, Full Grown
Gui, Add, Checkbox, x2 y211 +BackgroundTrans vgotoPlanterField gba_gotoPlanterFieldSwitch_ Checked%gotoPlanterField% Disabled, Only Gather in Planter Field
Gui, Add, Checkbox, x2 y224 w150 h14 +BackgroundTrans vgatherFieldSipping gba_gatherFieldSippingSwitch_ Checked%gatherFieldSipping% Disabled, Gather Field Nectar Sipping
Gui, Add, Text, x80 y178 w32 h20 cRed +left vAutoText +BackgroundTrans, [Auto]
Gui, Add, Text, x80 y178 w32 h20 cRed +left vFullText +BackgroundTrans, [Full]
Gui, Add, Edit, x80 y174 w32 h20 limit5 Number vHarvestInterval gba_harvestInterval Disabled, %HarvestInterval%
Gui, Add, Text, x115 y178 w70 h20 +left +BackgroundTrans, Hours
Gui, Add, Text, x10 y209 w137 h1 0x7
Gui, Add, Button, x380 y192 w90 h20 vShowTimersButton gba_showPlanterTimers, Show Timers
Gui, Add, Text, x410 y218 w80 h20 +left +BackgroundTrans, Max Planters
Gui, Add, DropDownList, x375 y215 w30 vMaxAllowedPlanters gba_maxAllowedPlantersSwitch Disabled, % LTrim(StrReplace("|3|2|1|0|", "|" MaxAllowedPlanters "|", "|" MaxAllowedPlanters "||"), "|")
;Gui, Add, Button, x380 y220 w30 h15 gba_testButton, test
Gui, Add, Text, x147 y28 w1 h182 0x7
Gui, Add, Text, x147 y27 w108 h20 +Center +BackgroundTrans, Allowed Planters
Gui, Add, Text, x147 y42 w108 h1 0x7
Gui, Add, Checkbox, x155 y44 vPlasticPlanterCheck gba_saveConfig_ Checked%PlasticPlanterCheck% Disabled, Plastic
Gui, Add, Checkbox, x155 y59 vCandyPlanterCheck gba_saveConfig_ Checked%CandyPlanterCheck% Disabled, Candy
Gui, Add, Checkbox, x155 y74 vBlueClayPlanterCheck gba_saveConfig_ Checked%BlueClayPlanterCheck% Disabled, Blue Clay
Gui, Add, Checkbox, x155 y89 vRedClayPlanterCheck gba_saveConfig_ Checked%RedClayPlanterCheck% Disabled, Red Clay
Gui, Add, Checkbox, x155 y104 vTackyPlanterCheck gba_saveConfig_ Checked%TackyPlanterCheck% Disabled, Tacky
Gui, Add, Checkbox, x155 y119 vPesticidePlanterCheck gba_saveConfig_ Checked%PesticidePlanterCheck% Disabled, Pesticide
Gui, Add, Checkbox, x155 y134 vHeatTreatedPlanterCheck gba_saveConfig_ Checked%HeatTreatedPlanterCheck% Disabled, Heat-Treated
Gui, Add, Checkbox, x155 y149 vHydroponicPlanterCheck gba_saveConfig_ Checked%HydroponicPlanterCheck% Disabled, Hydroponic
Gui, Add, Checkbox, x155 y164 vPetalPlanterCheck gba_saveConfig_ Checked%PetalPlanterCheck% Disabled, Petal
Gui, Add, Checkbox, x155 y179 w100 h13 vPlanterOfPlentyCheck gba_saveConfig_ Checked%PlanterOfPlentyCheck% Disabled, Planter of Plenty
Gui, Add, Checkbox, x155 y194 vPaperPlanterCheck gba_saveConfig_ Checked%PaperPlanterCheck% Disabled, Paper
Gui, Add, Checkbox, x155 y209 vTicketPlanterCheck gba_saveConfig_ Checked%TicketPlanterCheck% Disabled, Ticket
Gui, Add, Text, x255 y28 w1 h204 0x7
Gui, Add, Text, x255 y27 w100 h20 +Center +BackgroundTrans, Allowed Fields
Gui, Add, Text, x255 y42 w240 h1 0x7
Gui, Add, Text, x255 y44 w100 h20 +Center +BackgroundTrans, -- starting zone --
Gui, Add, Checkbox, x260 y59 vDandelionFieldCheck gba_saveConfig_ Checked%DandelionFieldCheck% Disabled, Dandelion (COM)
Gui, Add, Checkbox, x260 y74 vSunflowerFieldCheck gba_saveConfig_ Checked%SunflowerFieldCheck% Disabled, Sunflower (SAT)
Gui, Add, Checkbox, x260 y89 vMushroomFieldCheck gba_saveConfig_ Checked%MushroomFieldCheck% Disabled, Mushroom (MOT)
Gui, Add, Checkbox, x260 y104 vBlueFlowerFieldCheck gba_saveConfig_ Checked%BlueFlowerFieldCheck% Disabled, Blue Flower (REF)
Gui, Add, Checkbox, x260 y119 vCloverFieldCheck gba_saveConfig_ Checked%CloverFieldCheck% Disabled, Clover (INV)
Gui, Add, Text, x255 y132 w100 h20 +Center +BackgroundTrans, -- 5 bee zone --
Gui, Add, Checkbox, x260 y147 vSpiderFieldCheck gba_saveConfig_ Checked%SpiderFieldCheck% Disabled, Spider (MOT)
Gui, Add, Checkbox, x260 y162 vStrawberryFieldCheck gba_saveConfig_ Checked%StrawberryFieldCheck% Disabled, Strawberry (REF)
Gui, Add, Checkbox, x260 y177 vBambooFieldCheck gba_saveConfig_ Checked%BambooFieldCheck% Disabled, Bamboo (COM)
Gui, Add, Text, x255 y190 w100 h20 +Center +BackgroundTrans, -- 10 bee zone --
Gui, Add, Checkbox, x260 y205 vPineappleFieldCheck gba_saveConfig_ Checked%PineappleFieldCheck% Disabled, Pineapple (SAT)
Gui, Add, Checkbox, x260 y220 vStumpFieldCheck gba_saveConfig_ Checked%StumpFieldCheck% Disabled, Stump (MOT)
Gui, Add, Text, x375 y44 w100 h20 +Center +BackgroundTrans, -- 15 bee zone --
Gui, Add, Checkbox, x380 y59 vCactusFieldCheck gba_saveConfig_ Checked%CactusFieldCheck% Disabled, Cactus (INV)
Gui, Add, Checkbox, x380 y74 vPumpkinFieldCheck gba_saveConfig_ Checked%PumpkinFieldCheck% Disabled, Pumpkin (SAT)
Gui, Add, Checkbox, x380 y89 vPineTreeFieldCheck gba_saveConfig_ Checked%PineTreeFieldCheck% Disabled, Pine Tree (COM)
Gui, Add, Checkbox, x380 y104 vRoseFieldCheck gba_saveConfig_ Checked%RoseFieldCheck% Disabled, Rose (MOT)
Gui, Add, Text, x375 y117 w100 h20 +Center +BackgroundTrans, -- 25 bee zone --
Gui, Add, Checkbox, x380 y132 vMountainTopFieldCheck gba_saveConfig_ Checked%MountainTopFieldCheck% Disabled, Mountain Top (INV)
Gui, Add, Text, x375 y145 w100 h20 +Center +BackgroundTrans, -- 35 bee zone --
Gui, Add, Checkbox, x380 y160 vCoconutFieldCheck gba_saveConfig_ Checked%CoconutFieldCheck% Disabled, Coconut (REF)
Gui, Add, Checkbox, x380 y175 vPepperFieldCheck gba_saveConfig_ Checked%PepperFieldCheck% Disabled, Pepper (INV)
if(n1priority="none"){
	guicontrol, hide, n2priority
	guicontrol, hide, n2minPercent
}
if(n2priority="none"){
	guicontrol, hide, n3priority
	guicontrol, hide, n3minPercent
}
if(n3priority="none"){
	guicontrol, hide, n4priority
	guicontrol, hide, n4minPercent
}
if(n4priority="none"){
	guicontrol, hide, n5priority
	guicontrol, hide, n5minPercent
}
if(AutomaticHarvestInterval){
	GuiControl, Hide, HarvestInterval
	GuiControl, Hide, FullText
}
if(HarvestFullGrown){
	GuiControl, Hide, HarvestInterval
	GuiControl, Hide, AutoText
}
if(EnablePlantersPlus) {
	GuiControl, Hide, Disabled
} else {
	GuiControl, Hide, Enabled
}
nm_showAdvancedSettings()

/*
;PLANTERS TAB
;------------------------
Gui, Tab, Planters
GuiControl,focus, Tab
Gui, Font, w700
Gui, Add, Text, x20 y25 w100 +left +BackgroundTrans,Planter 1
Gui, Add, Text, x180 y25 w100 +left +BackgroundTrans,Planter 2
Gui, Add, Text, x340 y25 w100 +left +BackgroundTrans,Planter 3
Gui, Font, s8 cDefault Norm, Tahoma
Gui, Add, DropDownList, x60 y75 w70 vPlanterSelectedName1 gnm_plantersPlacedBy1, %PlanterSelectedName1%||None|Automatic|Plastic|Candy|BlueClay|RedClay|Tacky|Pesticide|Petal|Plenty|Paper|Ticket
Gui, Add, DropDownList, x220 y75 w70 vPlanterSelectedName2 gnm_plantersPlacedBy2, %PlanterSelectedName2%||None|Automatic|Plastic|Candy|BlueClay|RedClay|Tacky|Pesticide|Petal|Plenty|Paper|Ticket
Gui, Add, DropDownList, x380 y75 w70 vPlanterSelectedName3 gnm_plantersPlacedBy3, %PlanterSelectedName3%||None|Automatic|Plastic|Candy|BlueClay|RedClay|Tacky|Pesticide|Petal|Plenty|Paper|Ticket
Gui, Add, Text, x20 y40 w50 +left +BackgroundTrans,placed by
Gui, Add, Text, x180 y40 w50 +left +BackgroundTrans,placed by
Gui, Add, Text, x340 y40 w50 +left +BackgroundTrans,placed by
Gui, Add, Text, x85 y40 w40 +left +BackgroundTrans,slot
Gui, Add, Text, x245 y40 w40 +left +BackgroundTrans,slot
Gui, Add, Text, x405 y40 w40 +left +BackgroundTrans,slot
Gui, Add, Text, x30 y77 w50 +left +BackgroundTrans,Name:
Gui, Add, Text, x190 y77 w50 +left +BackgroundTrans,Name:
Gui, Add, Text, x350 y77 w50 +left +BackgroundTrans,Name:
Gui, Add, Text, x20 y77 w50 +left +BackgroundTrans,\______
Gui, Add, Text, x180 y77 w50 +left +BackgroundTrans,\______
Gui, Add, Text, x340 y77 w50 +left +BackgroundTrans,\______
Gui, Add, DropDownList, x10 y54 w70 vPlanterPlacedBy1 gnm_plantersPlacedBy1, %PlanterPlacedBy1%||Inventory|Hotkey
Gui, Add, DropDownList, x170 y54 w70 vPlanterPlacedBy2 gnm_plantersPlacedBy2, %PlanterPlacedBy2%||Inventory|Hotkey
Gui, Add, DropDownList, x330 y54 w70 vPlanterPlacedBy3 gnm_plantersPlacedBy3, %PlanterPlacedBy3%||Inventory|Hotkey
Gui, Add, DropDownList, x85 y54 w30 vPlanterHotkeySlot1 gnm_savePlanters, %PlanterHotkeySlot1%||3|4|5|6|7
Gui, Add, DropDownList, x245 y54 w30 vPlanterHotkeySlot2 gnm_savePlanters, %PlanterHotkeySlot2%||3|4|5|6|7
Gui, Add, DropDownList, x405 y54 w30 vPlanterHotkeySlot3 gnm_savePlanters, %PlanterHotkeySlot3%||3|4|5|6|7
Gui, Add, Text, x20 y95 w60 +left +BackgroundTrans,into field
Gui, Add, Text, x180 y95 w60 +left +BackgroundTrans,into field
Gui, Add, Text, x340 y95 w60 +left +BackgroundTrans,into field
Gui, Add, Text, x100 y95 w50 +left +BackgroundTrans,until (hrs)
Gui, Add, Text, x260 y95 w50 +left +BackgroundTrans,until (hrs)
Gui, Add, Text, x420 y95 w50 +left +BackgroundTrans,until (hrs)
;planter 1
Gui, Add, DropDownList, x10 y110 w90 vPlanter1Field1 gnm_Planter1Field1, %Planter1Field1%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x105 y110 w40 vPlanter1Until1 gnm_Planter1Field1, %Planter1Until1%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x10 y130 w90 vPlanter1Field2 gnm_Planter1Field2, %Planter1Field2%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x105 y130 w40 vPlanter1Until2 gnm_Planter1Field2, %Planter1Until2%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x10 y150 w90 vPlanter1Field3 gnm_Planter1Field3, %Planter1Field3%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x105 y150 w40 vPlanter1Until3 gnm_Planter1Field3, %Planter1Until3%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x10 y170 w90 vPlanter1Field4 gnm_Planter1Field4, %Planter1Field4%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x105 y170 w40 vPlanter1Until4 gnm_Planter1Field4, %Planter1Until4%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
;planter 2
Gui, Add, DropDownList, x170 y110 w90 vPlanter2Field1 gnm_Planter2Field1, %Planter2Field1%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x265 y110 w40 vPlanter2Until1, %Planter2Until1%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x170 y130 w90 vPlanter2Field2 gnm_Planter2Field2, %Planter2Field2%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x265 y130 w40 vPlanter2Until2, %Planter2Until2%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x170 y150 w90 vPlanter2Field3 gnm_Planter2Field3, %Planter2Field3%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x265 y150 w40 vPlanter2Until3, %Planter2Until3%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x170 y170 w90 vPlanter2Field4 gnm_Planter2Field4, %Planter2Field4%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x265 y170 w40 vPlanter2Until4, %Planter2Until4%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
;planter 3
Gui, Add, DropDownList, x330 y110 w90 vPlanter3Field1 gnm_Planter3Field1, %Planter3Field1%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x425 y110 w40 vPlanter3Until1, %Planter3Until1%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x330 y130 w90 vPlanter3Field2 gnm_Planter3Field2, %Planter3Field2%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x425 y130 w40 vPlanter3Until2, %Planter3Until2%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x330 y150 w90 vPlanter3Field3 gnm_Planter3Field3, %Planter3Field3%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x425 y150 w40 vPlanter3Until3, %Planter3Until3%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, DropDownList, x330 y170 w90 vPlanter3Field4 gnm_Planter3Field4, %Planter3Field4%||None|Dandelion|Sunflower|Mushroom|BlueFlower|Clover|Strawberry|Spider|Bamboo|Pineapple|Stump|Cactus|Pumpkin|PineTree|Rose|MountainTop|Pepper|Coconut
Gui, Add, DropDownList, x425 y170 w40 vPlanter3Until4, %Planter3Until4%||Full|0.5|1|2|3|4|5|6|7|8|9|10|14|16
Gui, Add, Button, x20 y195 w100 h30, Automatic Settings
nm_plantersPlacedBy1(), nm_plantersPlacedBy2(), nm_plantersPlacedBy3(), nm_Planter1Field1(), nm_Planter2Field1(), nm_Planter3Field1()
*/

if (A_ScreenDPI*100//96 != 100)
	msgbox, 0x1030, WARNING!!, % "Your Display Scale seems to be a value other than 100`%. This means the macro will NOT work correctly!`n`nTo change this, right click on your Desktop -> Click 'Display Settings' -> Under 'Scale & Layout', set Scale to 100`% -> Close and Restart Roblox before starting the macro.", 60
	
str:="", i:=1
while (i := RegExMatch(A_ScriptDir, "[^\x00-\x7F]", m, i+StrLen(m)))
    str.=m
if (StrLen(str)>0)
	msgbox, 0x1030, WARNING!!, % "Invalid characters found in file path: " str "`n`nYour Natro Macro file path contains non-ASCII characters (generally non-English characters). This will cause the macro to fail when launching new processes. Please extract your macro to a different folder!`n`nExamples of valid file paths: 'C:\Macro\Natro_Macro_v" versionID "', 'C:\Users\user\Downloads\Natro_Macro_v" versionID "'", 60

nm_guiModeButton(0)
Hotkey, F1, On
Gui, Show, x%GuiX% y%GuiY% w500 h300 , Natro Macro
GuiControl,focus, Tab
nm_guiTransparencySet()
;unlock tabs
nm_FieldUnlock()
nm_TabCollectUnLock()
nm_TabBoostUnLock()
nm_TabPlantersPlusUnLock()
nm_TabSettingsUnLock()
nm_setStatus()

if(TimersOpen)
    run, "%A_AhkPath%" "submacros\PlanterTimers.ahk" "%hwndstate%"

settimer, StartBackground, -5000

return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_Start(){
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
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
nm_guiModeButton(toggle:=1){
	global GuiMode
	if(!toggle)
		GuiMode:=!GuiMode
	if(GuiMode) { ;is advanced, change to easy
		GuiMode:=0
		GuiControl,,GuiModeButton, % ("Macro Mode:`nEASY")
		;Gather Tab
		GuiControl, ChooseString, FieldName2, None
		nm_FieldSelect2()
		loop 3 {
			GuiControl, hide, FieldPatternReps%A_Index%
			GuiControl, hide, FieldPatternShift%A_Index%
			GuiControl, hide, FieldPatternInvertFB%A_Index%
			GuiControl, hide, FieldPatternInvertLR%A_Index%
			GuiControl, hide, FieldInvertText%A_Index%
			GuiControl, hide, FieldUntilPack%A_Index%
			GuiControl, hide, FieldSprinklerLoc%A_Index%
			GuiControl, hide, FieldSprinklerDist%A_Index%
			GuiControl, hide, FieldRotateDirection%A_Index%
			GuiControl, hide, FieldRotateTimes%A_Index%
			GuiControl, hide, rotateCam%A_Index%
			GuiControl, hide, rotateCamTimes%A_Index%
			GuiControl, hide, FieldDriftCheck%A_Index%
			GuiControl, hide, sprinklerDistance%A_Index%
		}
		loop 2 {
			N_Index:=A_Index+1
			GuiControl, hide, FieldName%N_Index%
			GuiControl, hide, FieldPattern%N_Index%
			GuiControl, hide, FieldPatternSize%N_Index%
			GuiControl, hide, FieldUntilMins%N_Index%
			GuiControl, hide, FieldReturnType%N_Index%
		}
		GuiControl, hide, patternRepsHeader
		GuiControl, hide, untilPackHeader
		GuiControl, hide, sprinklerTitle
		GuiControl, hide, sprinklerStartHeader
		GuiControl, hide, BeesmasGatherInterruptCheck
		GuiControl, hide, StockingsCheck
		GuiControl, hide, WreathCheck
		GuiControl, hide, FeastCheck
		GuiControl, hide, GingerbreadCheck
		GuiControl, hide, SnowMachineCheck
		GuiControl, hide, CandlesCheck
		GuiControl, hide, SamovarCheck
		GuiControl, hide, LidArtCheck
		GuiControl, hide, GummyBeaconCheck
		GuiControl, hide, RoboPassCheck
		GuiControl, hide, AntPassCheck
		GuiControl, hide, AntPassAction
		GuiControl, hide, MondoBuffCheck
		GuiControl, hide, MondoAction
		GuiControl, hide, CoconutDisCheck
		GuiControl, hide, RoyalJellyDisCheck
		GuiControl, hide, GlueDisCheck
		GuiControl, hide, TunnelBearCheck
		GuiControl, hide, TunnelBearBabyCheck
		GuiControl, hide, KingBeetleCheck
		GuiControl, hide, KingBeetleBabyCheck
		GuiControl, hide, CocoCrabCheck
		GuiControl, hide, StumpSnailCheck
		GuiControl, hide, CommandoCheck
		GuiControl, hide,BugrunInterruptCheck
		GuiControl, hide,BugrunLadybugsCheck
		GuiControl, hide,BugrunRhinoBeetlesCheck
		GuiControl, hide,BugrunSpiderCheck
		GuiControl, hide,BugrunMantisCheck
		GuiControl, hide,BugrunScorpionsCheck
		GuiControl, hide,BugrunWerewolfCheck
		GuiControl, hide,BugrunLadybugsLoot
		GuiControl, hide,BugrunRhinoBeetlesLoot
		GuiControl, hide,BugrunSpiderLoot
		GuiControl, hide,BugrunMantisLoot
		GuiControl, hide,BugrunScorpionsLoot
		GuiControl, hide,BugrunWerewolfLoot
		nm_saveCollect()
		;Boost Tab
		;disable all options
		GuiControl,ChooseString,FieldBooster1,None
		GuiControl,ChooseString,FieldBooster2,None
		GuiControl,ChooseString,FieldBooster3,None
		;GuiControl,,BoostChaserCheck,0
		GuiControl,ChooseString,HotkeyWhile2,Never
		GuiControl,ChooseString,HotkeyWhile3,Never
		GuiControl,ChooseString,HotkeyWhile4,Never
		GuiControl,ChooseString,HotkeyWhile5,Never
		GuiControl,ChooseString,HotkeyWhile6,Never
		GuiControl,ChooseString,HotkeyWhile7,Never
		nm_FieldBooster1(), nm_FieldBooster2(), nm_FieldBooster3(), nm_HotkeyWhile2(), nm_HotkeyWhile3(), nm_HotkeyWhile4(), nm_HotkeyWhile5(), nm_HotkeyWhile6(), nm_HotkeyWhile7()
		;disble AFB
		;GuiControl,afb:, AutoFieldBoostActive, 0
		;GuiControl,, AutoFieldBoostActive, 0
		IniWrite, %AutoFieldBoostActive%, settings\nm_config.ini, Boost, AutoFieldBoostActive
		;GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
		GuiControl,disable,Boost
		;hide
		GuiControl,hide,FieldBooster1
		GuiControl,hide,FieldBooster2
		GuiControl,hide,FieldBooster3
		GuiControl,hide,FieldBoosterMins
		GuiControl,hide,HotkeyWhile2
		GuiControl,hide,HotkeyWhile3
		GuiControl,hide,HotkeyWhile4
		GuiControl,hide,HotkeyWhile5
		GuiControl,hide,HotkeyWhile6
		GuiControl,hide,HotkeyWhile7
		GuiControl,hide,HotkeyTime2
		GuiControl,hide,HotkeyTime3
		GuiControl,hide,HotkeyTime4
		GuiControl,hide,HotkeyTime5
		GuiControl,hide,HotkeyTime6
		GuiControl,hide,HotkeyTime7
		GuiControl,hide,HotkeyTimeUnits2
		GuiControl,hide,HotkeyTimeUnits3
		GuiControl,hide,HotkeyTimeUnits4
		GuiControl,hide,HotkeyTimeUnits5
		GuiControl,hide,HotkeyTimeUnits6
		GuiControl,hide,HotkeyTimeUnits7
		GuiControl,hide,AutoFieldBoostButton
		GuiControl,hide,BoostChaserCheck
		GuiControl,show,BoostTabEasyMode
		;quest tab
		;disable all options
		;GuiControl,,PolarQuestCheck,0
		;GuiControl,,BlackQuestCheck,0
		;GuiControl,,HoneyQuestCheck,0
		;GuiControl,,BuckoQuestCheck,0
		;GuiControl,,RileyQuestCheck,0
		;hide
		GuiControl,hide,QuestGatherMins
		GuiControl,hide,PolarQuestCheck
		GuiControl,hide,PolarQuestGatherInterruptCheck
		GuiControl,hide,BlackQuestCheck
		GuiControl,hide,HoneyQuestCheck
		GuiControl,hide,BuckoQuestCheck
		GuiControl,hide,BuckoQuestGatherInterruptCheck
		GuiControl,hide,RileyQuestCheck
		GuiControl,hide,RileyQuestGatherInterruptCheck
		GuiControl,hide,PolarQuestProgress
		GuiControl,hide,BlackQuestProgress
		GuiControl,hide,HoneyQuestProgress
		GuiControl,hide,BuckoQuestProgress
		GuiControl,hide,RileyQuestProgress
		GuiControl,show,QuestTabEasyMode
		;planters+ tab
		;set easy mode defaults
		;GuiControl,,EnablePlantersPlus,0
		GuiControl,hide,Enabled
		GuiControl,show,Disabled
		GuiControl,ChooseString,NPreset,Blue
		ba_nPresetSwitch_()
		;GuiControl,,PlasticPlanterCheck,1
		;GuiControl,,CandyPlanterCheck,1
		;GuiControl,,BlueClayPlanterCheck,1
		;GuiControl,,RedClayPlanterCheck,1
		;GuiControl,,TackyPlanterCheck,1
		;GuiControl,,PesticidePlanterCheck,1
		;GuiControl,,PetalPlanterCheck,0
		;GuiControl,,PlanterOfPlentyCheck,0
		;GuiControl,,PaperPlanterCheck,0
		;GuiControl,,TicketPlanterCheck,0
		;GuiControl,,MaxAllowedPlanters,3
		;hide
		GuiControl,hide,N1Priority
		GuiControl,hide,N2Priority
		GuiControl,hide,N3Priority
		GuiControl,hide,N4Priority
		GuiControl,hide,N5Priority
		GuiControl,hide,N1MinPercent
		GuiControl,hide,N2MinPercent
		GuiControl,hide,N3MinPercent
		GuiControl,hide,N4MinPercent
		GuiControl,hide,N5MinPercent
		GuiControl,hide,DandelionFieldCheck
		GuiControl,hide,SunflowerFieldCheck
		GuiControl,hide,MushroomFieldCheck
		GuiControl,hide,BlueFlowerFieldCheck
		GuiControl,hide,CloverFieldCheck
		GuiControl,hide,SpiderFieldCheck
		GuiControl,hide,StrawberryFieldCheck
		GuiControl,hide,BambooFieldCheck
		GuiControl,hide,PineappleFieldCheck
		GuiControl,hide,StumpFieldCheck
		GuiControl,hide,CactusFieldCheck
		GuiControl,hide,PumpkinFieldCheck
		GuiControl,hide,PineTreeFieldCheck
		GuiControl,hide,RoseFieldCheck
		GuiControl,hide,MountainTopFieldCheck
		GuiControl,hide,CoconutFieldCheck
		GuiControl,hide,PepperFieldCheck
		
		
	} else { ;is easy, change to advanced
		GuiMode:=1
		GuiControl,,GuiModeButton, % ("Macro Mode:`nADVANCED")
		;Gather Tab
		loop 3 {
			GuiControl, show, FieldPatternReps%A_Index%
			GuiControl, show, FieldPatternShift%A_Index%
			GuiControl, show, FieldPatternInvertFB%A_Index%
			GuiControl, show, FieldPatternInvertLR%A_Index%
			GuiControl, show, FieldUntilPack%A_Index%
			GuiControl, show, FieldSprinklerLoc%A_Index%
			GuiControl, show, FieldSprinklerDist%A_Index%
			GuiControl, show, FieldRotateDirection%A_Index%
			GuiControl, show, FieldRotateTimes%A_Index%
			GuiControl, show, rotateCam%A_Index%
			GuiControl, show, rotateCamTimes%A_Index%
			GuiControl, show, FieldDriftCheck%A_Index%
			GuiControl, show, sprinklerDistance%A_Index%
		}
		loop 2 {
			N_Index:=A_Index+1
			GuiControl, show, FieldName%N_Index%
			GuiControl, show, FieldPattern%N_Index%
			GuiControl, show, FieldPatternSize%N_Index%
			GuiControl, show, FieldUntilMins%N_Index%
			GuiControl, show, FieldReturnType%N_Index%
		}
		GuiControl, show, patternRepsHeader
		GuiControl, show, untilPackHeader
		GuiControl, show, sprinklerTitle
		GuiControl, show, sprinklerStartHeader
		;Collect/Kill Tab
		GuiControl, show, BeesmasGatherInterruptCheck
		GuiControl, show, StockingsCheck
		GuiControl, show, WreathCheck
		GuiControl, show, FeastCheck
		GuiControl, show, GingerbreadCheck
		GuiControl, show, SnowMachineCheck
		GuiControl, show, CandlesCheck
		GuiControl, show, SamovarCheck
		GuiControl, show, LidArtCheck
		GuiControl, show, GummyBeaconCheck
		GuiControl, show, RoboPassCheck
		GuiControl, show, AntPassCheck
		GuiControl, show, AntPassAction
		GuiControl, show, MondoBuffCheck
		GuiControl, show, MondoAction
		GuiControl, show, CoconutDisCheck
		GuiControl, show, RoyalJellyDisCheck
		GuiControl, show, GlueDisCheck
		GuiControl, show, TunnelBearCheck
		GuiControl, show, TunnelBearBabyCheck
		GuiControl, show, KingBeetleCheck
		GuiControl, show, KingBeetleBabyCheck
		GuiControl, show, CocoCrabCheck
		GuiControl, show, StumpSnailCheck
		GuiControl, show, CommandoCheck
		GuiControl, show,BugrunInterruptCheck
		GuiControl, show,BugrunLadybugsCheck
		GuiControl, show,BugrunRhinoBeetlesCheck
		GuiControl, show,BugrunSpiderCheck
		GuiControl, show,BugrunMantisCheck
		GuiControl, show,BugrunScorpionsCheck
		GuiControl, show,BugrunWerewolfCheck
		GuiControl, show,BugrunLadybugsLoot
		GuiControl, show,BugrunRhinoBeetlesLoot
		GuiControl, show,BugrunSpiderLoot
		GuiControl, show,BugrunMantisLoot
		GuiControl, show,BugrunScorpionsLoot
		GuiControl, show,BugrunWerewolfLoot
		nm_saveCollect()
		;Boost Tab
		GuiControl,show,FieldBooster1
		GuiControl,show,FieldBooster2
		GuiControl,show,FieldBooster3
		GuiControl,show,FieldBoosterMins
		GuiControl,show,HotkeyWhile2
		GuiControl,show,HotkeyWhile3
		GuiControl,show,HotkeyWhile4
		GuiControl,show,HotkeyWhile5
		GuiControl,show,HotkeyWhile6
		GuiControl,show,HotkeyWhile7
		GuiControl,show,AutoFieldBoostButton
		GuiControl,show,BoostChaserCheck
		GuiControl,hide,BoostTabEasyMode
		;quest tab
		GuiControl,show,QuestGatherMins
		GuiControl,show,PolarQuestCheck
		GuiControl,show,PolarQuestGatherInterruptCheck
		GuiControl,show,BlackQuestCheck
		GuiControl,show,HoneyQuestCheck
		GuiControl,show,BuckoQuestCheck
		GuiControl,show,BuckoQuestGatherInterruptCheck
		GuiControl,show,RileyQuestCheck
		GuiControl,show,RileyQuestGatherInterruptCheck
		GuiControl,show,PolarQuestProgress
		GuiControl,show,BlackQuestProgress
		GuiControl,show,HoneyQuestProgress
		GuiControl,show,BuckoQuestProgress
		GuiControl,show,RileyQuestProgress
		GuiControl,hide,QuestTabEasyMode
		;planters+ tab
		GuiControl,show,N1Priority
		GuiControl,show,N2Priority
		GuiControl,show,N3Priority
		GuiControl,show,N4Priority
		GuiControl,show,N5Priority
		GuiControl,show,N1MinPercent
		GuiControl,show,N2MinPercent
		GuiControl,show,N3MinPercent
		GuiControl,show,N4MinPercent
		GuiControl,show,N5MinPercent
		GuiControl,show,DandelionFieldCheck
		GuiControl,show,SunflowerFieldCheck
		GuiControl,show,MushroomFieldCheck
		GuiControl,show,BlueFlowerFieldCheck
		GuiControl,show,CloverFieldCheck
		GuiControl,show,SpiderFieldCheck
		GuiControl,show,StrawberryFieldCheck
		GuiControl,show,BambooFieldCheck
		GuiControl,show,PineappleFieldCheck
		GuiControl,show,StumpFieldCheck
		GuiControl,show,CactusFieldCheck
		GuiControl,show,PumpkinFieldCheck
		GuiControl,show,PineTreeFieldCheck
		GuiControl,show,RoseFieldCheck
		GuiControl,show,MountainTopFieldCheck
		GuiControl,show,CoconutFieldCheck
		GuiControl,show,PepperFieldCheck
	}
	IniWrite, %GuiMode%, settings\nm_config.ini, Settings, GuiMode
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
	}
}
nm_showAdvancedSettings(){
	global
	static i := 0, r := 0, t1, init := DllCall("GetSystemTimeAsFileTime", "int64p", t1)
	local t2
	DllCall("GetSystemTimeAsFileTime", "int64p", t2)
	if (r = 1)
		return
	if (t2 - t1 < 50000000)
	{
		i++
		if (i >= 7 || BuffDetectReset)
		{
			r := 1
			GuiControl, , Tab, Advanced
			Gui, Tab, Advanced
			Gui, Font, w700
			Gui, Add, GroupBox, x270 y23 w224 h148, Debugging and Testing
			Gui, Font, w400 s7 cGreen
			Gui, Add, Text, x280 y52, (split reports)
			Gui, Font, s8 cDefault Norm, Tahoma
			Gui, Add, Text, x280 y40, Webhook 2:
			Gui, Add, Edit, x344 y42 w140 r1 +BackgroundTrans vWebhook2 gnm_saveAdvanced, %Webhook2%
			Gui, Add, Checkbox, x282 y68 w206 +BackgroundTrans vssDebugging gnm_saveAdvanced Checked%ssDebugging%, Force Enable Debugging Screenshots
			Gui, Add, DropDownList, x282 y122 w96 gnm_setTest vTestFunction, Pattern||walkTo|walkFrom|gotoPlanter|gotoQuestgiver|gotoCollect|cannonTo|gotoBooster|temp
			Gui, Add, DropDownList, x386 y122 w96 vTestPath Sort, % StrReplace(LTrim(patternlist, "|"), "|", "||", , 1)
			Gui, Add, Text, x282 y108 w96 Center +BackgroundTrans, Function
			Gui, Add, Text, x386 y108 w96 Center +BackgroundTrans, Path/Pattern
			Gui, Add, Button, x342 y146 w80 h20 gnm_testButton, Test
			if (i >= 7)
			{
				BuffDetectReset := 1
				IniWrite, %BuffDetectReset%, settings\nm_config.ini, Settings, BuffDetectReset
			}
		}
	}
	else
		i := 1, t1 := t2
}
nm_saveAdvanced(){
	global
	for k,v in {"Webhook2":"Status","ssDebugging":"Status"}
	{
		GuiControlGet, temp, , %k%
		if (temp != "")
		{
			GuiControlGet, %k%
			IniWrite, % %k%, settings\nm_config.ini, %v%, %k%
		}
	}
}
nm_setTest(){
	global patternlist, TestFunction, TestPath
	static lists := {"walkTo":"|Bamboo||Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower"
		, "walkFrom":"|Bamboo||Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower"
		, "gotoPlanter":"|Bamboo||Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower"
		, "gotoQuestgiver":"|Black||Bucko|Honey|Polar|Riley"
		, "gotoCollect":"|clock||antpass|robopass|blueberrydis|strawberrydis|treatdis|honeydis|coconutdis|gluedis|royaljellydis|stockings|wreath|feast|gingerbread|snowmachine|candles|samovar|lidart|gummybeacon"
		, "cannonTo":"|Bamboo||Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower"
		, "gotoBooster":"|Blue||Red|Mountain"
		, "temp":"|1||2|3"}
		
	GuiControlGet, TestFunction
	GuiControl, , TestPath, % ((TestFunction = "Pattern") ? ("|" StrReplace(patternlist, "|", "||", , 1)) : lists[TestFunction])
}
nm_testButton(){
	global TestFunction, TestPath, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveMethod, HiveSlot, state, objective
	static paths := {}
	
	PrevKeyDelay := A_KeyDelay
	SetKeyDelay, 100+KeyDelay
	
	#Include *i %A_ScriptDir%\paths\temp1.ahk
	#Include *i %A_ScriptDir%\paths\temp2.ahk
	#Include *i %A_ScriptDir%\paths\temp3.ahk
		
	GuiControlGet, TestFunction
	GuiControlGet, TestPath
	
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
	
	if (TestFunction = "temp")
	{
		if (paths.HasKey("temp" TestPath) && FileExist(A_ScriptDir "\paths\temp" TestPath ".ahk"))
		{
			InStr(paths["temp" TestPath], "gotoramp") ? nm_gotoRamp()
			InStr(paths["temp" TestPath], "gotocannon") ? nm_gotoCannon()
			
			nm_createWalk(paths["temp" TestPath])
			KeyWait, F14, D T5 L
			KeyWait, F14, T120 L
			nm_endWalk()
		}
		else
			msgbox % "temp" TestPath ".ahk not in paths folder or the path is not defined as paths[""tempN""]!"
	}
	else
	{
		((TestFunction != "Pattern") && (TestFunction != "walkFrom") && (TestFunction != "gotoQuestgiver")) ? nm_Reset(0, 0, 0)	
		(TestFunction = "Pattern") ? nm_gather(TestPath) : nm_%TestFunction%(TestPath)
		nm_endWalk()
	}
	
	SetKeyDelay, PrevKeyDelay
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
	global TotalRuntime, SessionRuntime, TotalGatherTime, SessionGatherTime, TotalConvertTime, SessionConvertTime
	global MacroStartTime, GatherStartTime, ConvertStartTime
	global TotalViciousKills, SessionViciousKills, TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills, TotalPlantersCollected, SessionPlantersCollected, TotalQuestsComplete, SessionQuestsComplete, TotalDisconnects, SessionDisconnects
	newLine:="`n"
	tab:="`t"
	rundelta:=0
	gatherdelta:=0
	convertdelta:=0
	if(MacroRunning) {
		rundelta:=(nowUnix()-MacroStartTime)
		if(GatherStartTime)
			gatherdelta:=(nowUnix()-GatherStartTime)
		if(ConvertStartTime)
			convertdelta:=(nowUnix()-ConvertStartTime)
	}
	statsString:=("Runtime: " nm_TimeFromSeconds(TotalRuntime+rundelta) . tab . "Runtime: " . nm_TimeFromSeconds(SessionRuntime+rundelta) . newline . "GatherTime: " nm_TimeFromSeconds(TotalGatherTime+gatherdelta) . Tab . "GatherTime: " nm_TimeFromSeconds(SessionGatherTime+gatherdelta) . newline . "ConvertTime: " nm_TimeFromSeconds(TotalConvertTime+convertdelta) . Tab . "ConvertTime: " nm_TimeFromSeconds(SessionConvertTime+convertdelta) . newline . "ViciousKills=" . TotalViciousKills . Tab . Tab . "ViciousKills=" . SessionViciousKills . newline . "BossKills=" . TotalBossKills . Tab . Tab . "BossKills=" . SessionBossKills . newline . "BugKills=" . TotalBugKills . Tab . Tab . "BugKills=" . SessionBugKills . newline . "PlantersCollected=" . TotalPlantersCollected . Tab . "PlantersCollected=" . SessionPlantersCollected . newline . "QuestsComplete=" . TotalQuestsComplete . Tab . "QuestsComplete=" . SessionQuestsComplete . newline . "Disconnects=" . TotalDisconnects . Tab . Tab . "Disconnects=" . SessionDisconnects)
	GuiControl,,stats, %statsString%
}
nm_TimeFromSeconds(secs)
{
    time := 20220101
    time += secs, seconds
    FormatTime, mmss, %time%, mm:ss
    return secs//3600 ":" mmss
}
nm_setStatus(newState:=0, newObjective:=0){
	global state, objective, StatusLogReverse, hwndstate, StatusPID
	static statuslog:=[], status_number:=0
	
	if (statuslog.Length() = 0) {
		FileRead, log, %A_ScriptDir%\settings\status_log.txt
		statuslog := StrSplit(log, "`r`n")
	}
	
	if (newState != "Detected") {
		if(newState)
			state:=newState
		if(newObjective)
			objective:=newObjective
	}
	stateString:=((newState ? newState : state) . ": " . (newObjective ? newObjective : objective))
	
	statuslog.Push("[" A_Hour ":" A_Min ":" A_Sec "] " (InStr(stateString, "`n") ? SubStr(stateString, 1, InStr(stateString, "`n")-1) : stateString))
	statuslog.RemoveAt(1,(statuslog.MaxIndex()>15) ? statuslog.MaxIndex()-15 : 0), len:=statuslog.MaxIndex()
	statuslogtext:=""
	for k,v in statuslog {
		i := (StatusLogReverse) ? len+1-k : k
		statuslogtext .= ((A_Index>1) ? "`r`n" : "") statuslog[i]
	}
	
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
			if WinExist("StatMonitor.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5554, status_number, 60 * A_Min + A_Sec
			}
			if WinExist("background.ahk ahk_class AutoHotkey") {
				PostMessage, 0x5555, status_number, nowUnix()
			}
		}
	}
	if WinExist("ahk_pid " StatusPID " ahk_class AutoHotkey") {
		PostMessage, 0x5554
	}
	DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
}
nm_createStatusUpdater()
{
	global webhook, discordUID, webhookCheck, ssCheck, ssDebugging, WebhookEasterEgg, hwndstate, StatusPID
	
	if StatusPID
	{
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows On
		WinClose % "ahk_class AutoHotkey ahk_pid " StatusPID
		DetectHiddenWindows %Prev_DetectHiddenWindows%
	}
	
	script := "
	(LTrim Join`r`n
	#NoEnv
	#NoTrayIcon
	#SingleInstance, Off
	SetBatchLines -1
	#MaxThreads 255
	SetWorkingDir " A_ScriptDir "\submacros
	#Include " A_ScriptDir "\lib\Gdip_All.ahk
	#Include " A_ScriptDir "\lib\CreateFormData.ahk

	;initialization
	webhook := """ webhook """
	discordUID := """ discordUID """
	webhookCheck := (" WebhookCheck " && " RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$") ") ? 1 : 0
	ssCheck := " ssCheck "
	ssDebugging := " ssDebugging "
	WebhookEasterEgg := " WebhookEasterEgg "
	pToken := Gdip_Startup()
	OnExit(""ExitFunc"")
	OnMessage(0x5554, ""nm_setStatus"", 255)

	nm_status(stateString)
	{
		global webhook, discordUID, webhookCheck, ssCheck, ssDebugging, WebhookEasterEgg
		static statuslog:=[]
		
		if (statuslog.Length() = 0)
		{
			FileRead, log, ..\settings\status_log.txt
			statuslog := StrSplit(log, ""``r``n"")
		}
		
		state := SubStr(stateString, 1, InStr(stateString, "": "")-1), objective := SubStr(stateString, InStr(stateString, "": "")+2)
		
		;manage status_log
		statuslog.Push(""["" A_Hour "":"" A_Min "":"" A_Sec ""] "" (InStr(stateString, ""``n"") ? SubStr(stateString, 1, InStr(stateString, ""``n"")-1) : stateString))
		statuslog.RemoveAt(1,(statuslog.MaxIndex()>20) ? statuslog.MaxIndex()-20 : 0)
		statuslogtext:=""""
		for k,v in statuslog
			statuslogtext .= ((A_Index>1) ? ""``r``n"" : """") v
			
		FileDelete, ..\settings\status_log.txt
		FileAppend, %statuslogtext%, ..\settings\status_log.txt
		FileAppend ``[%A_MM%/%A_DD%``]``[%A_Hour%:%A_Min%:%A_Sec%``] %stateString%``n, ..\settings\debug_log.txt
		
		;;;;;;;;
		;webhook
		;;;;;;;;
		static lastCritical:=0, colorIndex:=0		
		if WebhookCheck {
			; set colour based on state string
			if WebhookEasterEgg
			{
				color := (colorIndex = 0) ? 16711680 ; red
				: (colorIndex = 1) ? 16744192 ; orange
				: (colorIndex = 2) ? 16776960 ; yellow
				: (colorIndex = 3) ? 65280 ; green
				: (colorIndex = 4) ? 255 ; blue
				: (colorIndex = 5) ? 4915330 ; indigo
				: 9699539 ; violet
				colorIndex := Mod(colorIndex+1, 7)
			}
			else
			{
				color := ((state = ""Disconnected"") || (state = ""You Died"") || (state = ""Failed"") || (state = ""Error"") || (state = ""Aborting"") || (state = ""Missing"") || (state = ""Canceling"") || InStr(objective, ""Phantom"")) ? 15085139 ; red - error
				: (InStr(objective, ""Tunnel Bear"") || InStr(objective, ""King Beetle"") || InStr(objective, ""Vicious Bee"") || InStr(objective, ""Snail"") || InStr(objective, ""Crab"") || InStr(objective, ""Mondo"") || InStr(objective, ""Commando"")) ? 7036559 ; purple - boss / attacking
				: (InStr(objective, ""Planter"") || (state = ""Placing"") || (state = ""Collecting"")) ? 48355 ; blue - planters
				: ((state = ""Interupted"")) ? 14408468 ; yellow - alert
				: ((state = ""Gathering"")) ? 9755247 ; light green - gathering
				: ((state = ""Converting"")) ? 8871681 ; yellow-brown - converting
				: ((state = ""Boosted"") || (state = ""Looting"") || (state = ""Keeping"") || (state = ""Claimed"") || (state = ""Completed"") || (state = ""Collected"") || InStr(stateString,""confirmed"") || InStr(stateString,""found"")) ? 48128 ; green - success
				: ((state = ""Starting"")) ? 16366336 ; orange - quests
				: ((state = ""Startup"") || (state = ""GUI"") || (state = ""Detected"") || (state = ""Closing"") || (state = ""Begin"") || (state = ""End"")) ? 15658739 ; white - startup / utility
				: 3223350
			}

			; check if event needs screenshot
			critical_event := ((state = ""Error"") || ((nowUnix() - lastCritical > 300) && ((state = ""Disconnected"") || (InStr(stateString, ""Resetting: Character"") && (SubStr(objective, InStr(objective, "" "")+1) > 4)) || InStr(stateString, ""Phantom"")))) ? 1 : 0
			if critical_event
				lastCritical := nowUnix()
			content := (discordUID && critical_event) ? ""<@"" discordUID "">"" : """"
			debug_event := (ssDebugging && ((state = ""Placing"") || (state = ""Collecting"") || (state = ""Failed"") || InStr(stateString, ""Next Quest Step""))) ? 1 : 0
			ss_event := (InStr(stateString, ""Amulet"") || InStr(stateString, ""Completed: Vicious Bee"") || (state = ""You Died"") || (state = ""Collected"") || (stateString = ""Converting: Balloon"")) ? 1 : 0
			
			; create postdata and send to discord
			message := ""["" A_Hour "":"" A_Min "":"" A_Sec ""] "" StrReplace(StrReplace(StrReplace(StrReplace(stateString, ""\"", ""\\""), ""``n"", ""\n""), Chr(9), ""  ""), ""``r"")
			if (ssCheck && (critical_event || debug_event || ss_event))
			{
				SysGet, pmonN, MonitorPrimary
				pBM := Gdip_BitmapFromScreen(pmonN)
				Gdip_SaveBitmapToFile(pBM, ""ss.png"")
				Gdip_DisposeImage(pBM)
				
				path := ""ss.png""
				
				payload_json = {""content"": ""`%content`%"", ""embeds"": [{""description"": ""`%message`%"", ""color"": ""`%color`%"", ""image"": {""url"": ""attachment://ss.png""}}]}
				
				try
				{
					objParam := {payload_json: payload_json, file: [path]}
					CreateFormData(postdata, hdr_ContentType, objParam)
					
					wr := ComObjCreate(""WinHTTP.WinHTTPRequest.5.1"")
					wr.Option(9) := 2048
					wr.Open(""POST"", webhook)
					wr.SetRequestHeader(""User-Agent"", ""AHK"")
					wr.SetRequestHeader(""Content-Type"", hdr_ContentType)
					wr.Send(postdata)
				}
				
				FileDelete, ss.png
			}
			else
			{
				postdata = {""content"": ""`%content`%"", ""embeds"": [{""description"": ""`%message`%"", ""color"": ""`%color`%""}]}
			
				; post to webhook
				try
				{
					wr := ComObjCreate(""WinHTTP.WinHTTPRequest.5.1"")
					wr.Option(9) := 2048
					wr.Open(""POST"", webhook)
					wr.SetRequestHeader(""User-Agent"", ""AHK"")
					wr.SetRequestHeader(""Content-Type"", ""application/json"")
					wr.Send(postdata)
				}
			}
		}
	}

	nm_setStatus() {
		Critical
		VarSetCapacity(stateString, 1024)
		ControlGetText, stateString, , `% ""ahk_id"" " hwndstate "
		stateString ? nm_status(stateString)
		return 0
	}

	nowUnix(){
		Time := A_NowUTC
		EnvSub, Time, 19700101000000, Seconds
		return Time
	}

	ExitFunc()
	{
		Process, Close, % DllCall(""GetCurrentProcessId"")
	}
	)"
	
	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(A_AhkPath " /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()
	
	return (StatusPID := exec.ProcessID)
}
nm_StatusLogReverseCheck(){
	global StatusLogReverse
	GuiControlGet, StatusLogReverse
	IniWrite, %StatusLogReverse%, settings\nm_config.ini, Status, StatusLogReverse
	if (StatusLogReverse) {
		nm_setStatus("GUI", "Status Log Reversed")
	} else {
		nm_setStatus("GUI", "Status Log NOT Reversed")
	}
}
nm_FieldSelect1(){
	global CurrentFieldNum
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
	global CurrentField, CurrentFieldNum
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
		GuiControl, ChooseString, FieldName3, None
		GuiControl, Disable, FieldName3
		nm_fieldSelect3()
	}
	nm_FieldDefaults(2)
	IniWrite, %FieldName2%, settings\nm_config.ini, Gather, FieldName2
	nm_WebhookEasterEgg()
}
nm_FieldSelect3(){
	global CurrentField, CurrentFieldNum
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
		, returntypelist:="|Walk|Reset|Rejoin|"
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
	GuiControl, disable, GingerbreadCheck
	GuiControl, disable, SnowMachineCheck
	GuiControl, disable, CandlesCheck
	GuiControl, disable, SamovarCheck
	GuiControl, disable, LidArtCheck
	GuiControl, disable, GummyBeaconCheck
	GuiControl, disable, GiftedViciousCheck
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
	GuiControl, disable, CocoCrabCheck
	GuiControl, disable, StumpSnailCheck
	GuiControl, disable, CommandoCheck
}
nm_TabCollectUnLock(){
	GuiControl, enable, ClockCheck
	GuiControl, enable, MondoBuffCheck
	GuiControl, enable, MondoAction
	GuiControl, enable, RoboPassCheck
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
		GuiControl, enable, GingerbreadCheck
		GuiControl, enable, SnowMachineCheck
		GuiControl, enable, CandlesCheck
		GuiControl, enable, SamovarCheck
		GuiControl, enable, LidArtCheck
		GuiControl, enable, GummyBeaconCheck
	}
	GuiControl, enable, GiftedViciousCheck
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
	GuiControl, enable, CocoCrabCheck
	GuiControl, enable, StumpSnailCheck
	GuiControl, enable, CommandoCheck
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
	GuiControl, disable, HotkeyWhile2
	GuiControl, disable, HotkeyWhile3
	GuiControl, disable, HotkeyWhile4
	GuiControl, disable, HotkeyWhile5
	GuiControl, disable, HotkeyWhile6
	GuiControl, disable, HotkeyWhile7
	GuiControl, disable, HotkeyTime2
	GuiControl, disable, HotkeyTime3
	GuiControl, disable, HotkeyTime4
	GuiControl, disable, HotkeyTime5
	GuiControl, disable, HotkeyTime6
	GuiControl, disable, HotkeyTime7
	GuiControl, disable, HotkeyTimeUnits2
	GuiControl, disable, HotkeyTimeUnits3
	GuiControl, disable, HotkeyTimeUnits4
	GuiControl, disable, HotkeyTimeUnits5
	GuiControl, disable, HotkeyTimeUnits6
	GuiControl, disable, HotkeyTimeUnits7
}
nm_TabBoostUnLock(){
	GuiControl, enable, FieldBooster1
	nm_FieldBooster1()
	GuiControl, enable, FieldBoosterMins
	GuiControl, enable, HotkeyWhile2
	GuiControl, enable, HotkeyWhile3
	GuiControl, enable, HotkeyWhile4
	GuiControl, enable, HotkeyWhile5
	GuiControl, enable, HotkeyWhile6
	GuiControl, enable, HotkeyWhile7
	GuiControl, enable, HotkeyTime2
	GuiControl, enable, HotkeyTime3
	GuiControl, enable, HotkeyTime4
	GuiControl, enable, HotkeyTime5
	GuiControl, enable, HotkeyTime6
	GuiControl, enable, HotkeyTime7
	GuiControl, enable, HotkeyTimeUnits2
	GuiControl, enable, HotkeyTimeUnits3
	GuiControl, enable, HotkeyTimeUnits4
	GuiControl, enable, HotkeyTimeUnits5
	GuiControl, enable, HotkeyTimeUnits6
	GuiControl, enable, HotkeyTimeUnits7
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
nm_HotkeyWhile2(){
	global HotkeyWhile2, PFieldBoosted
	GuiControlGet HotkeyWhile2
	if(HotkeyWhile2="never") {
		GuiControl,hide, HotkeyTime2
		GuiControl,hide, HotkeyTimeUnits2
		GuiControl, hide, HBText2
	} else if(HotkeyWhile2="microconverter" || HotkeyWhile2="whirligig" || HotkeyWhile2="enzymes" || HotkeyWhile2="glitter") {
		if(HotkeyWhile2="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText2, @ Boosted
			} else {
				GuiControl,,HBText2, @ Full Pack
			}
		}
		else if (HotkeyWhile2="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText2, @ Boosted
			} else {
				GuiControl,,HBText2, @ Hive Return
			}
		}
		else if (HotkeyWhile2="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText2, @ Boosted
			} else {
				GuiControl,,HBText2, @ Conv Balloon
			}
		}
		else if (HotkeyWhile2="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText2, @ Boosted
			}
		}
		GuiControl, show, HBText2
		GuiControl,hide, HotkeyTime2
		GuiControl,hide, HotkeyTimeUnits2
	} else {
		GuiControl,show, HotkeyTime2
		GuiControl,show, HotkeyTimeUnits2
		GuiControl, hide, HBText2
	}
	IniWrite, %HotkeyWhile2%, settings\nm_config.ini, Boost, HotkeyWhile2
}
nm_HotkeyWhile3(){
	global HotkeyWhile3, PFieldBoosted
	GuiControlGet HotkeyWhile3
	if(HotkeyWhile3="never") {
		GuiControl,hide, HotkeyTime3
		GuiControl,hide, HotkeyTimeUnits3
		GuiControl, hide, HBText3
	} else if(HotkeyWhile3="microconverter" || HotkeyWhile3="whirligig" || HotkeyWhile3="enzymes" || HotkeyWhile3="glitter") {
		if(HotkeyWhile3="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText3, @ Boosted
			} else {
				GuiControl,,HBText3, @ Full Pack
			}
		}
		else if (HotkeyWhile3="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText3, @ Boosted
			} else {
				GuiControl,,HBText3, @ Hive Return
			}
		}
		else if (HotkeyWhile3="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText3, @ Boosted
			} else {
				GuiControl,,HBText3, @ Conv Balloon
			}
		}
		else if (HotkeyWhile3="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText3, @ Boosted
			}
		}
		GuiControl, show, HBText3
		GuiControl,hide, HotkeyTime3
		GuiControl,hide, HotkeyTimeUnits3
	} else {
		GuiControl,show, HotkeyTime3
		GuiControl,show, HotkeyTimeUnits3
		GuiControl, hide, HBText3
	}
	IniWrite, %HotkeyWhile3%, settings\nm_config.ini, Boost, HotkeyWhile3
}
nm_HotkeyWhile4(){
	global HotkeyWhile4, PFieldBoosted
	GuiControlGet HotkeyWhile4
	if(HotkeyWhile4="never") {
		GuiControl,hide, HotkeyTime4
		GuiControl,hide, HotkeyTimeUnits4
		GuiControl, hide, HBText4
	} else if(HotkeyWhile4="microconverter" || HotkeyWhile4="whirligig" || HotkeyWhile4="enzymes" || HotkeyWhile4="glitter") {
		if(HotkeyWhile4="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText4, @ Boosted
			} else {
				GuiControl,,HBText4, @ Full Pack
			}
		}
		else if (HotkeyWhile4="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText4, @ Boosted
			} else {
				GuiControl,,HBText4, @ Hive Return
			}
		}
		else if (HotkeyWhile4="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText4, @ Boosted
			} else {
				GuiControl,,HBText4, @ Conv Balloon
			}
		}
		else if (HotkeyWhile4="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText4, @ Boosted
			}
		}
		GuiControl, show, HBText4
		GuiControl,hide, HotkeyTime4
		GuiControl,hide, HotkeyTimeUnits4
	} else {
		GuiControl,show, HotkeyTime4
		GuiControl,show, HotkeyTimeUnits4
		GuiControl, hide, HBText4
	}
	IniWrite, %HotkeyWhile4%, settings\nm_config.ini, Boost, HotkeyWhile4
}
nm_HotkeyWhile5(){
	global HotkeyWhile5, PFieldBoosted
	GuiControlGet HotkeyWhile5
	if(HotkeyWhile5="never") {
		GuiControl,hide, HotkeyTime5
		GuiControl,hide, HotkeyTimeUnits5
		GuiControl, hide, HBText5
	} else if(HotkeyWhile5="microconverter" || HotkeyWhile5="whirligig" || HotkeyWhile5="enzymes" || HotkeyWhile5="glitter") {
		if(HotkeyWhile5="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText5, @ Boosted
			} else {
				GuiControl,,HBText5, @ Full Pack
			}
		}
		else if (HotkeyWhile5="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText5, @ Boosted
			} else {
				GuiControl,,HBText5, @ Hive Return
			}
		}
		else if (HotkeyWhile5="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText5, @ Boosted
			} else {
				GuiControl,,HBText5, @ Conv Balloon
			}
		}
		else if (HotkeyWhile5="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText5, @ Boosted
			}
		}
		GuiControl, show, HBText5
		GuiControl,hide, HotkeyTime5
		GuiControl,hide, HotkeyTimeUnits5
	} else {
		GuiControl,show, HotkeyTime5
		GuiControl,show, HotkeyTimeUnits5
		GuiControl, hide, HBText5
	}
	IniWrite, %HotkeyWhile5%, settings\nm_config.ini, Boost, HotkeyWhile5
}
nm_HotkeyWhile6(){
	global HotkeyWhile6, PFieldBoosted
	GuiControlGet HotkeyWhile6
	if(HotkeyWhile6="never") {
		GuiControl,hide, HotkeyTime6
		GuiControl,hide, HotkeyTimeUnits6
		GuiControl, hide, HBText6
	} else if(HotkeyWhile6="microconverter" || HotkeyWhile6="whirligig" || HotkeyWhile6="enzymes" || HotkeyWhile6="glitter") {
		if(HotkeyWhile6="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText6, @ Boosted
			} else {
				GuiControl,,HBText6, @ Full Pack
			}
		}
		else if (HotkeyWhile6="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText6, @ Boosted
			} else {
				GuiControl,,HBText6, @ Hive Return
			}
		}
		else if (HotkeyWhile6="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText6, @ Boosted
			} else {
				GuiControl,,HBText6, @ Conv Balloon
			}
		}
		else if (HotkeyWhile6="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText6, @ Boosted
			}
		}
		GuiControl, show, HBText6
		GuiControl,hide, HotkeyTime6
		GuiControl,hide, HotkeyTimeUnits6
	} else {
		GuiControl,show, HotkeyTime6
		GuiControl,show, HotkeyTimeUnits6
		GuiControl, hide, HBText6
	}
	IniWrite, %HotkeyWhile6%, settings\nm_config.ini, Boost, HotkeyWhile6
}
nm_HotkeyWhile7(){
	global HotkeyWhile7, PFieldBoosted
	GuiControlGet HotkeyWhile7
	if(HotkeyWhile7="never") {
		GuiControl,hide, HotkeyTime7
		GuiControl,hide, HotkeyTimeUnits7
		GuiControl, hide, HBText7
	} else if(HotkeyWhile7="microconverter" || HotkeyWhile7="whirligig" || HotkeyWhile7="enzymes" || HotkeyWhile7="glitter") {
		if(HotkeyWhile7="microconverter") {
			if(PFieldBoosted) {
				GuiControl,,HBText7, @ Boosted
			} else {
				GuiControl,,HBText7, @ Full Pack
			}
		}
		else if (HotkeyWhile7="whirligig") {
			if(PFieldBoosted) {
				GuiControl,,HBText7, @ Boosted
			} else {
				GuiControl,,HBText7, @ Hive Return
			}
		}
		else if (HotkeyWhile7="enzymes") {
			if(PFieldBoosted) {
				GuiControl,,HBText7, @ Boosted
			} else {
				GuiControl,,HBText7, @ Conv Balloon
			}
		}
		else if (HotkeyWhile7="glitter") {
			if(PFieldBoosted) {
				GuiControl,,HBText7, @ Boosted
			}
		}
		GuiControl, show, HBText7
		GuiControl,hide, HotkeyTime7
		GuiControl,hide, HotkeyTimeUnits7
	} else {
		GuiControl,show, HotkeyTime7
		GuiControl,show, HotkeyTimeUnits7
		GuiControl, hide, HBText7
	}
	IniWrite, %HotkeyWhile7%, settings\nm_config.ini, Boost, HotkeyWhile7
}
nm_savequest(){
	global
	GuiControlGet, PolarQuestCheck
	GuiControlGet, PolarQuestGatherInterruptCheck
	GuiControlGet, HoneyQuestCheck
	;GuiControlGet, BlackQuestCheck
	GuiControlGet, QuestGatherMins
	GuiControlGet, QuestGatherReturnBy
	IniWrite, %PolarQuestCheck%, settings\nm_config.ini, Quests, PolarQuestCheck
	IniWrite, %PolarQuestGatherInterruptCheck%, settings\nm_config.ini, Quests, PolarQuestGatherInterruptCheck
	IniWrite, %HoneyQuestCheck%, settings\nm_config.ini, Quests, HoneyQuestCheck
	;IniWrite, %BlackQuestCheck%, settings\nm_config.ini, Quests, BlackQuestCheck
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
	msgbox, 0, Auto Field Boost Description,PURPOSE:`nThis option will use the selected Dice, Glitter, and Field Boosters automatically to build and maintain a field boost for your current gathering field (as defined in the Main tab).`n`nTHIS DOES NOT:`n* quickly build your boost multiplier up to x4.  If this is what you want then it is best to manually do this before using this feature.`n* use items from your inventory.  You must include the Dice and Glitter on your hotbar and make sure the slots match the settings.`n`nHOW IT WORKS:`nThis field boost will be Re-buffed at the interval defined in the settings.  It will use the items that are selected in the following priority: 1) Free Field Booster, 2) Dice, 3) Glitter.  The Dice and Glitter item uses will alternated so it can stack field boosts.  If there are any deactivation limits set, this option will disable itself once both the Dice and Glitter or the Hours limits have been reached.`n`nRECOMMENDATIONS:`nIt is highly recommended to disable all other macro options except your gathering field.  This will ensure you are actually benefiting from the use of your materials!`n`nPlease reference the various "?" buttons for additional information.
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
		send, %AFBDiceHotbar%
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
	send, %AFBGlitterHotbar%
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
		MoveSpeedFactor:=round(18/MoveSpeedNum, 2)
		IniWrite, %MoveSpeedNum%, settings\nm_config.ini, Settings, MoveSpeedNum
		IniWrite, %MoveSpeedFactor%, settings\nm_config.ini, Settings, MoveSpeedFactor
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
		Title := "Unacceptable Number", Text := "You cannot enter a number above 50!"
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
		DllCall("User32.dll\SendMessage", "Ptr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
    }
    else
	{
		HiveBees := NewHiveBees
		IniWrite, %HiveBees%, settings\nm_config.ini, Settings, HiveBees
	}
}
nm_saveConfig(){
	global
	GuiControlGet HiveSlot
	GuiControlGet, MoveMethod
	GuiControlGet, SprinklerType
	GuiControlGet, MultiReset
	GuiControlGet, ConvertMins
	GuiControlGet, DisableToolUse
	GuiControlGet, AnnounceGuidingStar
	GuiControlGet, NewWalk
	IniWrite, %HiveSlot%, settings\nm_config.ini, Settings, HiveSlot
	IniWrite, %MoveMethod%, settings\nm_config.ini, Settings, MoveMethod
	IniWrite, %SprinklerType%, settings\nm_config.ini, Settings, SprinklerType
	IniWrite, %MultiReset%, settings\nm_config.ini, Settings, MultiReset
	IniWrite, %ConvertMins%, settings\nm_config.ini, Settings, ConvertMins
	IniWrite, %DisableToolUse%, settings\nm_config.ini, Settings, DisableToolUse
	IniWrite, %AnnounceGuidingStar%, settings\nm_config.ini, Settings, AnnounceGuidingStar
	IniWrite, %NewWalk%, settings\nm_config.ini, Settings, NewWalk
}
nm_saveWebhook(){ ; ~ replaced nm_webhookcheck to work on whole webhook section in Status tab
	global
	GuiControlGet, Webhook
	GuiControlGet, WebhookCheck
	GuiControlGet, discordUID
	GuiControlGet, ssCheck
	GuiControl, % webhookCheck ? "Enable" : "Disable", Webhook
	GuiControl, % webhookCheck ? "Enable" : "Disable", discordUID
	GuiControl, % webhookCheck ? "Enable" : "Disable", ssCheck
	IniWrite, %Webhook%, settings\nm_config.ini, Status, Webhook
	IniWrite, %WebhookCheck%, settings\nm_config.ini, Status, WebhookCheck
	IniWrite, %discordUID%, settings\nm_config.ini, Status, discordUID
	IniWrite, %ssCheck%, settings\nm_config.ini, Status, ssCheck
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
nm_keyboardLayout(){
	GuiControlGet, KeyboardLayout
	if(KeyboardLayout="qwerty"){
		GuiControl, disable, FwdKey
		GuiControl, disable, LeftKey
		GuiControl, disable, BackKey
		GuiControl, disable, RightKey
		GuiControl, disable, RotLeft
		GuiControl, disable, RotRight
		GuiControl, disable, ZoomIn
		GuiControl, disable, ZoomOut
		GuiControl,,FwdKey, w
		GuiControl,,LeftKey, a
		GuiControl,,BackKey, s
		GuiControl,,RightKey, d
		GuiControl,,RotLeft, `,
		GuiControl,,RotRight, `.
		GuiControl,,ZoomIn, i
		GuiControl,,ZoomOut, o
		nm_saveKeys()
	} else if(KeyboardLayout="azerty"){
		GuiControl, disable, FwdKey
		GuiControl, disable, LeftKey
		GuiControl, disable, BackKey
		GuiControl, disable, RightKey
		GuiControl, disable, RotLeft
		GuiControl, disable, RotRight
		GuiControl, disable, ZoomIn
		GuiControl, disable, ZoomOut
		GuiControl,,FwdKey, z
		GuiControl,,LeftKey, q
		GuiControl,,BackKey, s
		GuiControl,,RightKey, d
		GuiControl,,RotLeft, % ";"
		GuiControl,,RotRight, % ":"
		GuiControl,,ZoomIn, i
		GuiControl,,ZoomOut, o
		nm_saveKeys()
	}else if(KeyboardLayout="other"){
		GuiControl, enable, FwdKey
		GuiControl, enable, LeftKey
		GuiControl, enable, BackKey
		GuiControl, enable, RightKey
		GuiControl, enable, RotLeft
		GuiControl, enable, RotRight
		GuiControl, enable, ZoomIn
		GuiControl, enable, ZoomOut
	}
}
nm_saveKeys(){
	global
	GuiControlGet, KeyboardLayout
	GuiControlGet, FwdKey
	GuiControlGet, LeftKey
	GuiControlGet, BackKey
	GuiControlGet, RightKey
	GuiControlGet, RotLeft
	GuiControlGet, RotRight
	GuiControlGet, KeyDelay
	IniWrite, %KeyboardLayout%, settings\nm_config.ini, Keys, KeyboardLayout
	IniWrite, %FwdKey%, settings\nm_config.ini, Keys, FwdKey
	IniWrite, %LeftKey%, settings\nm_config.ini, Keys, LeftKey
	IniWrite, %BackKey%, settings\nm_config.ini, Keys, BackKey
	IniWrite, %RightKey%, settings\nm_config.ini, Keys, RightKey
	IniWrite, %RotLeft%, settings\nm_config.ini, Keys, RotLeft
	IniWrite, %RotRight%, settings\nm_config.ini, Keys, RotRight
	IniWrite, %KeyDelay%, settings\nm_config.ini, Keys, KeyDelay
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
	global PrivServer
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, str, , %hEdit%
	
	RegExMatch(str, "i)((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*", NewPrivServer)
    if ((StrLen(str) > 0) && (StrLen(NewPrivServer) = 0))
	{
        GuiControl, , %hEdit%, %PrivServer%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		Title := "Invalid Private Server Link", Text := "Make sure your link is:`r`n- copied correctly and completely`r`n- for Bee Swarm Simulator by Onett"
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
		DllCall("User32.dll\SendMessage", "Ptr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
    }
    else
	{
		PrivServer := NewPrivServer
		GuiControl, , %hEdit%, %PrivServer%
		IniWrite, %PrivServer%, settings\nm_config.ini, Settings, PrivServer
	}
}
nm_setReconnectInterval(hEdit){
	global ReconnectInterval
	ControlGet, p, CurrentCol, , , ahk_id %hEdit%
	GuiControlGet, NewReconnectInterval, , %hEdit%

    if (((Mod(24, NewReconnectInterval) != 0) && NewReconnectInterval) || (ReconnectInterval = 0)) ; not a factor of 24 or 0
	{
        GuiControl, , %hEdit%, %ReconnectInterval%
        SendMessage, 0xB1, % p-2, % p-2, , ahk_id %hEdit%
		Title := "Unacceptable Number", Text := "Reconnect Interval must be a factor of 24!`r`nThese are: 1, 2, 3, 4, 6, 8, 12, 24."
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
		DllCall("User32.dll\SendMessage", "Ptr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
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
		Title := "Unacceptable Number", Text := "Reconnect Hour must be between 00 and 23!"
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
		DllCall("User32.dll\SendMessage", "Ptr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
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
		Title := "Unacceptable Number", Text := "Reconnect Minute must be between 00 and 59!"
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
		DllCall("User32.dll\SendMessage", "Ptr", hEdit, "UInt", 0x1503, "Ptr", 0, "Ptr", &EBT, "Ptr")
    }
    else
	{
		ReconnectMin := NewReconnectMin
		IniWrite, %ReconnectMin%, settings\nm_config.ini, Settings, ReconnectMin
	}
}
nm_WebhookHelp(){ ; ~ webhook section information
	msgbox, 0x40000, Discord Webhook Integration, WEBHOOK:`nEnable this feature to get status updates and hourly reports sent to your Discord webhook! This is especially useful if you want to monitor the macro remotely, and also monitor the amount of honey you're making or buff uptime. To enable this, tick the checkbox next to 'Discord Webhook' and enter your webhook link below, directly copied from Discord.`n`nSCREENSHOTS:`nEnable this option to have screenshots sent to your Discord webhook after certain events. Screenshots will be sent after:`n- Critical Events (disconnect messages, inventory errors, etc.)`n- Amulets (to show the amulet that was not replaced)`n- Collecting Machines (to monitor loot)`n- Converting Balloon (to check balloon size)`n- Completing Vicious Cycle (to see Stingers gained)`n- Character Deaths (to investigate death reason)`n`nUSER ID `& CRITICAL EVENTS:`nThere are some status updates that require immediate attention, e.g. disconnects and Phantom Planter checks. You can choose to have the webhook ping you on Discord (with a 5 minute cooldown) by entering your Discord User ID (18-digit number). If screenshots are enabled, these updates will also be sent with a screenshot.
}
nm_NewWalkHelp(){ ; ~ movespeed correction information
	msgbox, 0x40000, MoveSpeed Correction, DESCRIPTION:`nWhen this option is enabled, the macro will detect your Haste, Bear Morph, Coconut Haste, Haste+, Oil and Super Smoothie values real-time. Using this information, it will calculate the distance you have moved and use that for more accurate movements. If working as intended, this option will dramatically reduce drift and make Traveling anywhere in game much more accurate.`n`nIMPORTANT:`nIf you have this option enabled, make sure your 'Movement Speed' value is EXACTLY as shown in BSS Settings menu without haste or other temporary buffs (e.g. write 33.6 as 33.6 without any rounding). Also, it is ESSENTIAL that your Display Scale is 100`%, otherwise the buffs will not be detected properly.
}
nm_ReconnectTimeHelp(){
	global ReconnectHour, ReconnectMin, ReconnectInterval
	Gui +OwnDialogs
	FormatTime, hourUTC, %A_NowUTC%, HH
	FormatTime, hourLOC, %A_Now%, HH
	FormatTime, timeUTC, %A_NowUTC%, HH:mm
	FormatTime, timeLOC, %A_Now%, HH:mm
	timeDiff:=hourUTC-hourLOC
	
	if((!ReconnectHour && ReconnectHour!=0) || (!ReconnectMin && ReconnectMin!=0) || (Mod(24, ReconnectInterval) != 0)) {
		ReconnectTimeString:="`n<Invalid Time>"
	} else {
		ReconnectTimeString:=""
		PaddedReconnectMin:=SubStr("0" Mod(ReconnectMin, 60), -1)
		Loop % 24//ReconnectInterval {
			PaddedConvertedLocalHour:=SubStr("0" Mod(ReconnectHour+ReconnectInterval*(A_Index-1)-timeDiff, 24), -1)
			PaddedReconnectHour:=SubStr("0" Mod(ReconnectHour+ReconnectInterval*(A_Index-1), 24), -1)
			ReconnectTimeString.="`n" (PaddedReconnectHour . ":" . PaddedReconnectMin . " UTC = Local Time: " . PaddedConvertedLocalHour . ":" . PaddedReconnectMin)
		}
	}

	msgbox, 0x40000, Coordinated Universal Time (UTC),% "DEFINITION:`nUTC is the time standard commonly used across the world. The world's timing centers have agreed to keep their time scales closely synchronized - or coordinated - therefore the name Coordinated Universal Time.`n`nWhy use UTC?`nThis allows all players on the same server to enter the same time value into the GUI regardless of the local timezone.`n`nTIME NOW:`nLocal Time: " timeLOC " (UTC " timeDiff " hours) = UTC Time: " timeUTC "`n`nRECONNECT TIMES:" ReconnectTimeString
}
nm_HiveBeesHelp(){
	msgbox, 0x40000, Hive Bees, DESCRIPTION:`nEnter the number of Bees you have in your Hive. This doesn't have to be exactly the same as your in-game amount, but the macro will use this value to determine whether it can travel to the 35 Bee Zone, use the Red Cannon, etc.`n`nNOTE:`nLowering this number will increase the time your character waits at hive after converting or before going to battle. If you notice that your bees don't finish converting or haven't recovered to fight mobs, reduce this value but keep it above 35 to enable access to all areas in the map.
}
nm_ContributorsImage(page:=1){
	static hCtrl, hBM1, hBM2, hBM3, hBM4, hBM5 ; 5 pages max
	
	if (hBM1 = "")
	{
		devs := [["natro#9071",0xffa202c0]
			, ["zez#8710",0xff7df9ff]
			, ["LittleChurch#1631",0xfffa01c5]
			, ["Zaappiix#2372",0xffa2a4a3]
			, ["SP#0305",0xfffc6600]
			, ["Ziz | Jake#9154",0xffa45ee9]
			, ["BlackBeard6#2691",0xff8780ff]
			, ["baguetto#8775",0xff3d85c6]]
		
		testers := [["FHL09#4061",0xffff00ff]
			, ["Nick 9#9476",0xffdfdfdf]
			, ["Heat#9350",0xff3f8d4d]
			, ["valibreaz#8493",0xff7aa22c]
			, ["RandomUserHere#7409",0xff2bc016]
			, ["crazyrocketman#5003",0xffffdc64]
			, ["chase#9999",0xff6082b6]]
			
		contributors := ["wilalwil2#4175"
			, "Ashtonishing#4420"
			, "TheRealXoli#1017"
			, "K_Money#0001"
			, "Sasuel#5393"
			, "Disco#9130"
			, "Ethereal_Sparks#7693"
			, "Inzainiac#9806"
			, "Raccoon City#2912"
			, "Gambols#1084"
			, "Anonymous_D"
			, "olnumber8#1487"
			, "Trystar001#5076"
			, "IceBreaker420#7887"
			, "YarikzBSS"
			, "sheeva#1786"
			, "misc#4583"
			, "Bobbythebob12#6969"
			, "3xykoz#5481"
			, "bacon#2389"
			, "Mxeil#9534"
			, "Novi1Alpha#2360"
			, "Wheezy#9419"
			, "Albert#9999"
			, "swiftlyanerd#6969"
			, "Techy.#0001"
			, "J4m3z#0184"
			, "Anonymous 1"
			, "Anonymous 2"
			, "Anonymous 3"]
	
		pBM := Gdip_CreateBitmap(244,210)
		G := Gdip_GraphicsFromImage(pBM)
		Gdip_SetSmoothingMode(G, 2)
		Gdip_SetInterpolationMode(G, 7)
		
		pBrush := Gdip_BrushCreateSolid(0xff202020)
		Gdip_FillRoundedRectangle(G, pBrush, 0, 0, 242, 208, 5)
		Gdip_DeleteBrush(pBrush)
		
		pos := Gdip_TextToGraphics(G, "Dev Team", "s12 x6 y50 Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(6, 50, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+2, 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, 6, 50, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Dev Team", "s12 x7 y50 r4 Bold cff000000", "Tahoma")
		
		pos := Gdip_TextToGraphics(G, "Testers", "s12 x115 y50 Bold cff000000", "Tahoma", , , 1)
		pBrush := Gdip_CreateLinearGrBrushFromRect(115, 50, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 14, 0x00000000, 0x00000000, 2)
		Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
		Gdip_FillRoundedRectangle(G, pBrush, 115, 50, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1)+1, 14, 4)
		Gdip_DeleteBrush(pBrush)
		Gdip_TextToGraphics(G, "Testers", "s12 x116 y50 r4 Bold cff000000", "Tahoma")
		
		for k,v in devs
		{
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, 67+(k-1)*13, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1,2), 255), 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, 5, 66+(k-1)*13, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		for k,v in testers
		{
			pBrush := Gdip_CreateLinearGrBrushFromRect(0, 67+(k-1)*13, 242, 12, 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*1.2), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*1.2), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*1.2), 255), 0xff000000 + (Min(Round(Gdip_RFromARGB(v[2])*0.9), 255) << 16) + (Min(Round(Gdip_GFromARGB(v[2])*0.9), 255) << 8) + Min(Round(Gdip_BFromARGB(v[2])*0.9), 255)), pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v[1], "Tahoma", 11, 0, 114, 66+(k-1)*13, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		
		Gdip_DeleteGraphics(G)
		hBM := Gdip_CreateHBITMAPFromBitmap(pBM)
		Gdip_DisposeImage(pBM)
		Gui, Add, Picture, +BackgroundTrans x5 y25, HBITMAP:*%hBM%
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
				pBM%i% := Gdip_CreateBitmap(244,210)
				G := Gdip_GraphicsFromImage(pBM%i%)
				Gdip_SetSmoothingMode(G, 2)
				Gdip_SetInterpolationMode(G, 7)
				
				pBrush := Gdip_BrushCreateSolid(0xff202020)
				Gdip_FillRoundedRectangle(G, pBrush, 0, 0, 242, 208, 5)
				Gdip_DeleteBrush(pBrush)
			}
			
			x := (Mod(k-1, 24) > 11) ? 124 : 4, y := 48+Mod(k-1, 12)*13
			pos := Gdip_TextToGraphics(G, v, "s11 x" x " y0 cff000000", "Tahoma", , , 1)
			pBrush := Gdip_CreateLinearGrBrushFromRect(x, y+1, SubStr(pos, InStr(pos, "|", , , 2)+1, InStr(pos, "|", , , 3)-InStr(pos, "|", , , 2)-1), 12, 0x00000000, 0x00000000, 2)
			Gdip_SetLinearGrBrushPresetBlend(pBrush, [0.0, 0.5, 1], [0xfff0ca8f, 0xffd48d22, 0xfff0ca8f])
			pPen := Gdip_CreatePenFromBrush(pBrush,1)
			Gdip_DrawOrientedString(G, v, "Tahoma", 11, 0, x, y, 130, 10, 0, pBrush, pPen)
			Gdip_DeletePen(pPen), Gdip_DeleteBrush(pBrush)
		}
		Gdip_DeleteGraphics(G)
		hBM%i% := Gdip_CreateHBITMAPFromBitmap(pBM%i%)
		Gdip_DisposeImage(pBM%i%)
		
		Gui, Add, Picture, +BackgroundTrans hwndhCtrl x253 y25 AltSubmit, % "HBITMAP:*" hBM1
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
nm_ContributorsPageButton(hwnd){
	global
	static p := 1
	
	p += (hwnd = hcleft) ? -1 : 1
	
	GuiControl, % ((p=1) ? "Disable" : "Enable"), % hcleft
	GuiControl, % ((nm_ContributorsImage(p)=1) ? "Disable" : "Enable"), % hcright
}
nm_AutoClickerOptionsButton(){
	global
	Gui ac:Destroy
	Gui ac:+AlwaysOnTop +Border
	Gui ac:Font, s7 cGreen Norm, Tahoma
	Gui ac:Add, Text, x146 y5, Start/Stop - F4
	Gui ac:Font, s8 cDefault Norm, Tahoma
	Gui ac:Add, Text, x10 y4, Click Interval (ms)
	Gui ac:Add, Edit, x100 y2 w40 h18 +BackgroundTrans Number vClickDelay gnm_saveAutoClicker, %ClickDelay%
	Gui ac:Add, Text, x10 y24, Repeat
	Gui ac:Add, Checkbox, x156 y24 +BackgroundTrans vClickMode gnm_saveAutoClicker Checked%ClickMode%, Infinite
	Gui ac:Add, Edit, % "x50 y21 w60 h18 vClickCountEdit +BackgroundTrans gnm_saveAutoClicker Number Disabled" ClickMode
	Gui ac:Add, UpDown, % "vClickCount gnm_saveAutoClicker Range0-100000 Disabled" ClickMode, %ClickCount%
	Gui ac:Add, Text, x116 y24, times
	Gui ac:Show,,AutoClicker Options
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
nm_stingerFields(){
	gui, stingerFields:destroy
	global StingerPepperCheck
	global StingerMountainTopCheck
	global StingerRoseCheck
	global StingerCactusCheck
	global StingerSpiderCheck
	global StingerCloverCheck
	gui stingerFields:+AlwaysOnTop +border +minsize50x30
	gui stingerFields:font, s8 cDefault Norm, Tahoma
	gui stingerFields:add, text,x5 y5 +left +BackgroundTrans,Allowed Stinger Fields
	gui stingerFields:add, text,x5 y8 +left +BackgroundTrans,___________________
	IniRead, StingerPepperCheck, settings\nm_config.ini, Collect, StingerPepperCheck
	IniRead, StingerMountainTopCheck, settings\nm_config.ini, Collect, StingerMountainTopCheck
	IniRead, StingerRoseCheck, settings\nm_config.ini, Collect, StingerRoseCheck
	IniRead, StingerCactusCheck, settings\nm_config.ini, Collect, StingerCactusCheck
	IniRead, StingerSpiderCheck, settings\nm_config.ini, Collect, StingerSpiderCheck
	IniRead, StingerCloverCheck, settings\nm_config.ini, Collect, StingerCloverCheck
	Gui, stingerFields:Add, Checkbox, x5 y25 vStingerPepperCheck gnm_stingerFieldsCheck checked%StingerPepperCheck%, Pepper
	Gui, stingerFields:Add, Checkbox, x5 y40 vStingerMountainTopCheck gnm_stingerFieldsCheck checked%StingerMountainTopCheck%, Mountain Top
	Gui, stingerFields:Add, Checkbox, x5 y55 vStingerRoseCheck gnm_stingerFieldsCheck checked%StingerRoseCheck%, Rose
	Gui, stingerFields:Add, Checkbox, x5 y70 vStingerCactusCheck gnm_stingerFieldsCheck checked%StingerCactusCheck%, Cactus
	Gui, stingerFields:Add, Checkbox, x5 y85 vStingerSpiderCheck gnm_stingerFieldsCheck checked%StingerSpiderCheck%, Spider
	Gui, stingerFields:Add, Checkbox, x5 y100 vStingerCloverCheck gnm_stingerFieldsCheck checked%StingerCloverCheck%, Clover
	Gui stingerFields:show,,Stinger Fields
}
nm_stingerFieldsCheck(){
	global
	GuiControlGet, StingerPepperCheck
	GuiControlGet, StingerMountainTopCheck
	GuiControlGet, StingerRoseCheck
	GuiControlGet, StingerCactusCheck
	GuiControlGet, StingerSpiderCheck
	GuiControlGet, StingerCloverCheck
	IniWrite, %StingerPepperCheck%, settings\nm_config.ini, Collect, StingerPepperCheck
	IniWrite, %StingerMountainTopCheck%, settings\nm_config.ini, Collect, StingerMountainTopCheck
	IniWrite, %StingerRoseCheck%, settings\nm_config.ini, Collect, StingerRoseCheck
	IniWrite, %StingerCactusCheck%, settings\nm_config.ini, Collect, StingerCactusCheck
	IniWrite, %StingerSpiderCheck%, settings\nm_config.ini, Collect, StingerSpiderCheck
	IniWrite, %StingerCloverCheck%, settings\nm_config.ini, Collect, StingerCloverCheck	
}
DiscordLink(){
    run, https://bit.ly/NatroMacro
}
DonateLink(){
    run, https://www.paypal.com/donate/?hosted_button_id=9KN7JHBCTAU8U&no_recurring=0&currency_code=USD
}
;Gui, Tab, Planters+
nm_TabPlantersPlusLock(){
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
	GuiControl, disable, AutomaticHarvestInterval
	GuiControl, disable, HarvestFullGrown
	GuiControl, disable, gotoPlanterField
	GuiControl, disable, gatherFieldSipping
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
}
nm_TabPlantersPlusUnLock(){
	global
	if (EnablePlantersPlus = 1) {
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
		GuiControl, enable, AutomaticHarvestInterval
		GuiControl, enable, HarvestFullGrown
		GuiControl, enable, gotoPlanterField
		GuiControl, enable, gatherFieldSipping
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
	}
}
;Gui, Tab, Settings
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
	GuiControl, disable, MoveSpeedNum
	GuiControl, disable, MoveMethod
	GuiControl, disable, SprinklerType
	GuiControl, disable, MultiReset
	GuiControl, disable, ConvertBalloon
	GuiControl, disable, ConvertMins
	GuiControl, disable, DisableToolUse
	GuiControl, disable, AnnounceGuidingStar
	GuiControl, disable, NewWalk
	GuiControl, disable, HiveSlot
	GuiControl, disable, HiveBees
	GuiControl, disable, PrivServer
}
nm_TabSettingsUnLock(){
	GuiControlGet, KeyboardLayout
	GuiControlGet, ConvertBalloon
	GuiControl, enable, GuiTheme
	GuiControl, enable, GuiTransparency
	if(KeyboardLayout="other") {
		GuiControl, enable, FwdKey
		GuiControl, enable, LeftKey
		GuiControl, enable, BackKey
		GuiControl, enable, RightKey
		GuiControl, enable, RotLeft
		GuiControl, enable, RotRight
		GuiControl, enable, ZoomIn
		GuiControl, enable, ZoomOut
	}
	GuiControl, enable, KeyDelay
	GuiControl, enable, MoveSpeedNum
	GuiControl, enable, MoveMethod
	GuiControl, enable, SprinklerType
	GuiControl, enable, MultiReset
	GuiControl, enable, ConvertBalloon
	if(ConvertBalloon="every")
		GuiControl, enable, ConvertMins
	GuiControl, enable, DisableToolUse
	GuiControl, enable, AnnounceGuidingStar
	GuiControl, enable, NewWalk
	GuiControl, enable, HiveSlot
	GuiControl, enable, HiveBees
	GuiControl, enable, PrivServer
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
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
nm_imgSearch(fileName,v,aim := "full", trans:="none"){
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
    ;xi := 0
    ;yi := 0
	;ww := windowWidth
	;wh := windowHeight
	xi:=(aim="actionbar") ? windowWidth/4 : (aim="highright") ? windowWidth/2 : (aim="right") ? windowWidth/2 : (aim="center") ? windowWidth/4 : (aim="lowright") ? windowWidth/2 : 0
	yi:=(aim="low") ? windowHeight/2 : (aim="actionbar") ? (windowHeight/4)*3 : (aim="center") ? yi:=windowHeight/4 : (aim="lowright") ? windowHeight/2 : (aim="quest") ? 150 : 0
	ww:=(aim="actionbar") ? xi*3 : (aim="highleft") ? windowWidth/2 : (aim="left") ? windowWidth/2 : (aim="center") ? xi*3 : (aim="quest") ? 310 : windowWidth
	wh:=(aim="high") ? windowHeight/2 : (aim="highright") ? windowHeight/2 : (aim="highleft") ? windowHeight/2 : (aim="buff") ? 150 : (aim="abovebuff") ? 30 : (aim="center") ? yi*3 : (aim="quest") ? Min(480, windowHeight-150) : windowHeight
	IfExist, %A_ScriptDir%\nm_image_assets\
	{	
		if(trans!="none")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *%v% *Trans%trans% %A_ScriptDir%\nm_image_assets\%fileName%
		else
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *%v% %A_ScriptDir%\nm_image_assets\%fileName%
		if (ErrorLevel = 2) {
			nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
			Sleep, 5000
			Process, Close, % DllCall("GetCurrentProcessId")
		}
		return [ErrorLevel,FoundX,FoundY]
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
    DllCall("user32\GetClientRect", Ptr,hWnd, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,hWnd, Ptr,&RECT)
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
	global RotRight
	global ZoomOut
	global objective
	global AFBrollingDice
	global AFBuseGlitter
	global AFBuseBooster
	global currentField
	global HiveConfirmed, WebhookCheck, GameFrozenCounter, MultiReset, bitmaps
	nm_setShiftLock(0)
	;check for game frozen conditions
	if (GameFrozenCounter>=5) { ;5 strikes
		nm_setStatus("Detected", "Roblox Game Frozen, Restarting")
		While(winexist("Roblox ahk_exe RobloxPlayerBeta.exe")){
			WinKill, Roblox ahk_exe RobloxPlayerBeta.exe
			;WinWaitClose, Roblox
			;WinClose StatMonitor.ahk
			sleep, 8000
		}
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
	while(!HiveConfirmed){
		;failsafe game frozen
		if(A_Index>10) {
			nm_setStatus("Closing", "and Re-Open Roblox")
			While(winexist("Roblox ahk_exe RobloxPlayerBeta.exe")){
				;WinClose, Roblox
				WinKill, Roblox ahk_exe RobloxPlayerBeta.exe
				;WinWaitClose, Roblox
				;WinClose StatMonitor.ahk
				sleep, 8000
			}
			DisconnectCheck()
		}
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		;check to make sure you are not in dialog before reset
		Loop, 500
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
			if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], pos, , , , , 2, , 3) = 0) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, windowWidth//2, 2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
			Click
			sleep, 150
		}
		MouseMove, 350, 100
		;check to make sure you are not in feed window on accident
		imgPos := nm_imgSearch("cancel.png",30)
		If (imgPos[1] = 0){
			MouseMove, (imgPos[2]), (imgPos[3])
			Click
			MouseMove, 350, 100
		}
		;check to make sure you are not in shop before reset
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0) {
			loop 2 {
				shopG := nm_imgSearch("shop_corner_G.png",30,"right")
				shopR := nm_imgSearch("shop_corner_R.png",30,"right")
				If (shopG[1] = 0 || shopR[1] = 0) {
					sendinput {e down}
					Sleep, 100
					sendinput {e up}
					sleep, 1000
				}
			}
		}
		;check to make sure there is not a window open
		searchRet := nm_imgSearch("close.png",30,"full")
		If (searchRet[1] = 0) {
			MouseMove, searchRet[2],searchRet[3]
			click
			MouseMove, 350, 100
			sleep, 1000
		}
		;check to make sure there is no ant amulet window open still
		searchRet := nm_imgSearch("keep.png",30,"center")
		searchRet2 := nm_imgSearch("d_ant_amulet.png",30,"center")
		searchRet3 := nm_imgSearch("g_ant_amulet.png",30,"center")
		If (searchRet[1]=0 && (searchRet2[1]=0 || searchRet3[1]=0)) {
			nm_setStatus("Keeping", "Ant Amulet")
			MouseMove, searchRet[2], searchRet[3], 5
			click
			MouseMove, 350, 100
			sleep, 1000
		}
		nm_setStatus("Resetting", "Character " . A_Index)
		MouseMove, 350, 100
		PrevKeyDelay:=A_KeyDelay
		SetKeyDelay, 250+KeyDelay
		Loop % (1 + MultiReset + ((CheckAll=2) ? 1 : 0)) {
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
			send {esc}
			send r
			send {enter}
			sleep,7000
		}
		SetKeyDelay, PrevKeyDelay
		sendinput {PgUp 4}
		loop 6 {
			send %ZoomOut%
		}
		sleep,1000
		loop, 4 { ;16
			If ((nm_imgSearch("hive4.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_honeystorm.png",20,"actionbar")[1] = 0) || (nm_imgSearch("hive_snowstorm.png",20,"actionbar")[1] = 0)){
				sendinput {%RotRight% 4}{PgDn 4}
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
	global bitmaps
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	if (windowWidth = 0)
		return 0
	
	pBMScreen := Gdip_BitmapFromScreen(windowX+5 "|" windowY+windowHeight-54 "|50|50")
	
	switch (v := Gdip_ImageSearch(pBMScreen, bitmaps["shiftlock"], , , , , , 2))
	{
		; shift lock enabled - disable if needed
		case 1:
		if (state = 0)
		{
			send {shift}
			result := 0
		}
		else
			result := 1
		
		
		; shift lock disabled - enable if needed
		case 0:
		if (state = 1)
		{
			send {shift}
			result := 1
		}
		else
			result := 0
		
		; shift lock indeterminate - error
		default:
		nm_setStatus("Error", "Invalid Shift Lock Detection!")
		Sleep, 5000
		Process, Close, % DllCall("GetCurrentProcessId")
	}
	
	Gdip_DisposeImage(pBMScreen)
	return result
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
    KeyWait, F14, T30 L
    nm_endWalk()
}
nm_gotoCannon(){
	global LeftKey, RightKey, MoveSpeedFactor, currentWalk, objective, bitmaps
	
	nm_setShiftLock(0)
		
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	MouseMove, 350, 100
	
	success := 0
	Loop, 10
	{
		SendInput {space down}
		Sleep, 100
		SendInput {space up}{%RightKey% down}
		DllCall("GetSystemTimeAsFileTime","int64p",s)
		n := s, f := s+10*MovespeedFactor*10000000
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 5, , 2) = 1)
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
				if (Gdip_ImageSearch(pBMScreen, bitmaps["redcannon"], , , , , , 5, , 2) = 1)
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
		While(winexist("Roblox ahk_exe RobloxPlayerBeta.exe")){
			WinKill, Roblox ahk_exe RobloxPlayerBeta.exe
			sleep, 5000
		}
	}
}
nm_claimHiveSlot(slotnum:=0){
	global FwdKey, RightKey, LeftKey, BackKey, ZoomOut, HiveSlot, HiveConfirmed, bitmaps
	
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	MouseMove, 350, 100
	send {%ZoomOut% 6}
	
	movement := "
	(LTrim Join`r`n
	" nm_Walk(35, FwdKey, RightKey) "
	" nm_Walk(5, BackKey) "
	)"
	nm_createWalk(movement)
	KeyWait, F14, D T5 L
	KeyWait, F14, T20 L
	nm_endWalk()
	
	Loop, 6
	{
		movement := "
		(LTrim Join`r`n
		" nm_Walk((A_Index = 1) ? 3.3 : 8.35, LeftKey) "
		)"
		nm_createWalk(movement)
		KeyWait, F14, D T5 L
		KeyWait, F14, T20 L
		nm_endWalk()
		
		Sleep, 500
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|200|120")
		if ((Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 1) && ((slotnum=0) || (slotnum=A_Index)))
		{
			Gdip_DisposeImage(pBMScreen)
			SendInput {e down}
			Sleep, 100
			SendInput {e up}
			HiveSlot := A_Index, HiveConfirmed := 1
			return HiveSlot
		}
		Gdip_DisposeImage(pBMScreen)
		
		if (A_Index = 6)
			return 0
	}
}
nm_findHiveSlot(){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveSpeedFactor, HiveConfirmed, bitmaps
	
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	MouseMove, 350, 100
	
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
	if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 5, , 2) = 1))
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
		n := s, f := s+15*MovespeedFactor*10000000
		SendInput {%LeftKey% down}
		while (n < f)
		{
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 5, , 2) = 1))
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
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["collectpollen"], , , , , , 5, , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				SendInput {e down}
				Sleep, 100
				SendInput {e up}
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
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveSpeedFactor, HiveSlot, state, objective, HiveConfirmed
	static paths := {}, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot))
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
		SetHiveSlot := HiveSlot
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
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveMethod, HiveSlot, state, objective, HiveConfirmed
	static paths := {}, SetMoveMethod, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot))
	{
		#Include %A_ScriptDir%\paths\gtb-red.ahk
		#Include %A_ScriptDir%\paths\gtb-blue.ahk
		#Include %A_ScriptDir%\paths\gtb-mountain.ahk
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot
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
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, KeyDelay, MoveSpeedFactor, MoveMethod
	global LastBlueBoost, LastRedBoost, LastMountainBoost, RecentFBoost, objective
	static blueBoosterFields:=["Pine Tree", "Bamboo", "Blue Flower"], redBoosterFields:=["Rose", "Strawberry", "Mushroom"], mountainBoosterfields:=["Cactus", "Pumpkin", "Pineapple", "Spider", "Clover", "Dandelion", "Sunflower"]
	
	success:=0
	Loop, 2 {
		nm_Reset(0)
		nm_setStatus("Traveling", (location="red") ? "Red Field Booster" : (location="blue") ? "Blue Field Booster" : "Mountain Top Field Booster")
		nm_gotoBooster(location)
		searchRet := nm_imgSearch("e_button.png",30,"high")
		if (searchRet[1] = 0) {
			sendinput {e down}
			Sleep, 100
			sendinput {e up}
			Sleep, 1000
			success:=1
			break
		}
	}
	
	if (success = 1)
	{
		Last%location%Boost:=nowUnix()
		IniWrite, % Last%location%Boost, settings\nm_config.ini, Collect, Last%location%Boost
		nm_Move(2000*MoveSpeedFactor, (location = "mountain") ? BackKey : RightKey)
		
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
	global MoveSpeedFactor
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
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
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
	global FwdKey, BackKey, LeftKey, RightKey, RotLeft, RotRight, KeyDelay, MovespeedFactor, objective, CurrentAction, PreviousAction, GatherFieldBoostedStart, LastGlitter, MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff, VBState, ClockCheck, LastClock, AntPassCheck, AntPassAction, QuestAnt, LastAntPass, HoneyDisCheck, LastHoneyDis, TreatDisCheck, LastTreatDis, BlueberryDisCheck, LastBlueberryDis, StrawberryDisCheck, LastStrawberryDis, CoconutDisCheck, LastCoconutDis, GlueDisCheck, LastGlueDis, RoboPassCheck, LastRoboPass, RoyalJellyDisCheck, LastRoyalJellyDis, StockingsCheck, LastStockings, FeastCheck, LastFeast, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon, resetTime, bitmaps
	static AntPassNum:=2, RoboPassNum:=1
	
	if(VBState=1)
		return
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
		return
		
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
			Send {space down}
			Sleep 100
			Send {space up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				Sleep, 500
				
				movement := "
				(LTrim Join`r`n
				" nm_Walk(8, FwdKey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(3, RightKey) "
				Send {space down}
				HyperSleep(500)
				Send {space up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, RightKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(9, LeftKey) "
				Send {space down}
				HyperSleep(500)
				Send {space up}
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
			nm_Reset()
			nm_setStatus("Traveling", (QuestAnt ? "Ant Challenge" : ("Ant " . AntPassAction)) ((A_Index > 1) ? " (Attempt 2)" : ""))
			
			nm_gotoCollect("antpass")
			
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				
				LastAntPass:=nowUnix()
				IniWrite, %LastAntPass%, settings\nm_config.ini, Collect, LastAntPass
				
				Sleep, 500
				nm_setStatus("Collected", "Ant Pass")
				++AntPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 5, , 2) = 1) {
					(AntPassNum < 10) ? nm_setStatus("Confirmed", "10/10 Ant Passes")
					AntPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 5, , 2) = 1) {
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				--AntPassNum
				nm_setStatus("Attacking", "Ant Challenge")
				Sleep, 500
				send {1}
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
					If (searchRet[1]=0) {
						nm_setStatus("Keeping", "Ant Amulet")
						MouseMove, searchRet[2], searchRet[3], 5
						click
						MouseMove, 350, 100
						break
					}
					sleep, 1000
					click
				}
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passnone"], , , , , , 5, , 2) = 1) {
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				
				LastRoboPass:=nowUnix()
				IniWrite, %LastRoboPass%, settings\nm_config.ini, Collect, LastRoboPass
				
				Sleep, 500
				nm_setStatus("Collected", "Robo Pass")
				++RoboPassNum
				break
			}
			else {
				pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passfull"], , , , , , 5, , 2) = 1) {
					(RoboPassNum < 10) ? nm_setStatus("Confirmed", "10/10 Robo Passes")
					RoboPassNum:=10
					Gdip_DisposeImage(pBMScreen)
					break
				}
				if (Gdip_ImageSearch(pBMScreen, bitmaps["passcooldown"], , , , , , 5, , 2) = 1) {
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
			
			nm_gotoCollect("gluedis", 0) ; do not wait for end
			
			;locate gumdrops
			Loop, 10
			{
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 1) {
					Gdip_DisposeImage(pBMScreen)
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, 30, 120
				Click
				MouseMove, 350, 100
				sleep, 400
			}
			imgPos := nm_imgSearch("gumdrops.png",10, "left")
			If (imgPos[1]=0){ ;gumdrops found
				If (imgPos[1]=0){
					mousemove imgPos[2], imgpos[3], 5
				}
			} else { ;gumdrops not found
				;scroll through inventory
				MouseMove, 30, 225, 5
				Loop, 50 {
					send, {WheelUp 1}
					Sleep, 50
				}
				Loop, 50 {
					;search for Gumdrops
					imgPos := nm_imgSearch("gumdrops.png",10, "left")
					If (imgPos[1]=0){ ;gumdrops found
						If (imgPos[1]=0){
							mousemove imgPos[2], imgpos[3], 5
							break
						}
					}
					loop, 2 {
						send, {WheelDown 1}
						Sleep, 50
					}
					sleep, 350
				}
			}
			KeyWait, F14, T120 L
			nm_endWalk()
			MouseClickDrag, Left, (30), (imgpos[3]+40), (windowWidth/2), (windowHeight/2), 5
			;close inventory
			MouseMove, 30, 120
			Click
			MouseMove, 350, 100
			sleep,1000
			;inside gummy lair
			nm_Move(2000*MoveSpeedFactor, FwdKey)
			sendinput {%FwdKey% down}
			Loop, 50
			{
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					sendinput {e down}
					Sleep, 100
					sendinput {e up}{%FwdKey% up}
					sleep 1000
					nm_setStatus("Collected", "Glue Dispenser")
					break 2
				} 
				Sleep, 50
			}
			sendinput {%FwdKey% up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				Sleep, 500
				
				movement := "
				(LTrim Join`r`n
				" nm_Walk(8, FwdKey) "
				" nm_Walk(2.5, BackKey) "
				" nm_Walk(3, RightKey) "
				Send {space down}
				HyperSleep(500)
				Send {space up}
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", s)
				" nm_Walk(3, RightKey) "
				DllCall(""GetSystemTimeAsFileTime"", ""int64p"", t)
				Sleep, 600-(t-s)//10000
				" nm_Walk(9, LeftKey) "
				Send {space down}
				HyperSleep(500)
				Send {space up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				Sleep, 1000
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				
				movement := "
				(LTrim Join`r`n
				" nm_Walk(18, LeftKey) "
				" nm_Walk(7, RightKey) "
				" nm_Walk(12, FwdKey) "
				Sleep, 2000
				send {e down}
				HyperSleep(100)
				send {e up}
				" nm_Walk(6.5, FwdKey, LeftKey) "
				" nm_Walk(6, FwdKey) "
				loop 2 {
					loop 3 {
					" nm_Walk(18, LeftKey) "
					" nm_Walk(2.5, FwdKey) "
					" nm_Walk(18, RightKey) "
					" nm_Walk(2.5, FwdKey) "
					}
					loop 3 {
					" nm_Walk(18, LeftKey) "
					" nm_Walk(2.5, BackKey) "
					" nm_Walk(18, RightKey) "
					" nm_Walk(2.5, BackKey) "
					}
				}
				)"
				nm_createWalk(movement)
				KeyWait, F14, D T5 L
				KeyWait, F14, T45 L
				nm_endWalk()
				
				nm_setStatus("Collected", "Snow Machine")
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				Sleep, 500
				nm_setStatus("Collected", "Gummy Beacon")
				break
			}
		}
		LastGummyBeacon:=nowUnix()
		IniWrite, %LastGummyBeacon%, settings\nm_config.ini, Collect, LastGummyBeacon
	}
}
nm_gotoCollect(location, waitEnd := 1){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, KeyDelay, MoveMethod, MoveSpeedFactor, HiveSlot, state, objective, HiveConfirmed
	static paths := {}, SetMoveMethod, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot))
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
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot
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
	global youDied, VBState, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveMethod, MoveSpeedFactor, MoveSpeedNum, currentWalk, objective, HiveBees, GiftedViciousCheck, DisableToolUse
	global QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf
	global BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll
	global CurrentAction, PreviousAction
	global GatherFieldBoostedStart, LastGlitter
	global BeesmasGatherInterruptCheck, StockingsCheck, LastStockings, FeastCheck, LastFeast, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon
	global MondoBuffCheck, PMondoGuid, LastGuid, MondoAction, LastMondoBuff
	global BugrunSpiderCheck, BugrunSpiderLoot, LastBugrunSpider, BugrunLadybugsCheck, BugrunLadybugsLoot, LastBugrunLadybugs, BugrunRhinoBeetlesCheck, BugrunRhinoBeetlesLoot, LastBugrunRhinoBeetles, BugrunMantisCheck, BugrunMantisLoot, LastBugrunMantis, BugrunWerewolfCheck, BugrunWerewolfLoot, LastBugrunWerewolf, BugrunScorpionsCheck, BugrunScorpionsLoot, LastBugrunScorpions
	global CocoCrabCheck, LastCrab, StumpSnailCheck, LastStumpSnail, CommandoCheck, LastCommando, TunnelBearCheck, TunnelBearBabyCheck, KingBeetleCheck, KingBeetleBabyCheck, LastTunnelBear, LastKingBeetle
	global TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills
	
	;interrupts
	if(VBState=1)
		return
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
	if((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck()){
		return
	}
	if (BeesmasGatherInterruptCheck && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800)))
		return
	
	nm_setShiftLock(0)
	bypass:=0
	if(((BugrunSpiderCheck || QuestSpider || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) && HiveBees>=5){ ;30 minutes
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
				nm_setStatus("Attacking", "Spider")
				send, 1
				if(!DisableToolUse)
					click, down
				loop 30 { ;wait to kill
					if(A_Index=30)
						success:=1
					searchRet := nm_imgSearch("spider.png",30,"lowright")
					If (searchRet[1] = 0) {
						success:=1
						break
					}
					if(youDied)
						break
					if(!DisableToolUse)
						click
					sleep, 1000
				}
				click, up
				if(VBState=1)
					return
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
			if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) {
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
	if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll)  && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))){ ;5 minutes
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
						else {
							nm_cannonTo(BugRunField)
						}
						Sleep, 1000
					}
					bypass:=0
					nm_setStatus("Attacking", "Ladybugs (Strawberry)")
					send, 1
					if(!DisableToolUse)
						click, down
					loop 10 { ;wait to kill
						if(A_Index=10)
							success:=1
						searchRet := nm_imgSearch("ladybug.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							break
						}
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						sleep, 1000
					}
					click, up
					if(VBState=1)
						return
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
				nm_setStatus("Attacking", "Ladybugs (Mushroom)")
				send, 1
				if(!DisableToolUse)
					click, down
				loop 10 { ;wait to kill
					if(A_Index=10)
						success:=1
					searchRet := nm_imgSearch("ladybug.png",30,"lowright")
					If (searchRet[1] = 0) {
						success:=1
						break
					}
					if(youDied)
						break
					if(!DisableToolUse)
						click
					sleep, 1000
				}
				click, up
				if(VBState=1)
					return
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
	if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15)))){ ;5 minutes
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
				nm_setStatus("Attacking")
				send, 1
				if(!DisableToolUse)
					click, down
				loop 10 { ;wait to kill
					if(A_Index=10)
						success:=1
					if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll)){
						searchRet := nm_imgSearch("ladybug.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							break
						}
					}
					if((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						searchRet := nm_imgSearch("rhino.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							break
						}
					}
					if(youDied)
						break
					if(!DisableToolUse)
						Click
					sleep, 1000
				}
				click up
				if(VBState=1)
					return
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
	if((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))){ ;5 minutes
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
				nm_setStatus("Attacking")
				send, 1
				if(!DisableToolUse)
					click, down
				loop 12 { ;wait to kill
					if(A_Index=12)
						success:=1
					searchRet := nm_imgSearch("rhino.png",30,"lowright")
					If (searchRet[1] = 0) {
						success:=1
						break
					}
					if(youDied)
						break
					if(!DisableToolUse)
						Click
					sleep, 1000
				}
				click, up
				if(VBState=1)
					return
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
					nm_setStatus("Attacking")
					send, 1
					if(!DisableToolUse)
						click, down
					loop 15 { ;wait to kill
						if(A_Index=15)
							success:=1
						searchRet := nm_imgSearch("rhino.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							sleep 3000
							break
						}
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						sleep, 1000
					}
					click, up
					if(VBState=1)
						return
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
	if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll)  && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15)))){ ;5 min Rhino 20min Mantis
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
				send, {space down}
				DllCall("Sleep",UInt,100)
				send, {space up}
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
				nm_setStatus("Attacking")
				send, 1
				if(!DisableToolUse)
					click, down
				;disableDayOrNight:=1
				loop 20 { ;wait to kill
					if(A_Index=20)
						success:=1
					if(not (BugrunMantisCheck || QuestMantis || BuckoMantis) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						searchRet := nm_imgSearch("rhino.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							break
						}
					} else if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll)){
						searchRet := nm_imgSearch("mantis.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							break
						}
					}
					if(youDied)
						break
					if(!DisableToolUse)
						Click
					sleep, 1000
				}
				click, up
				;disableDayOrNight:=0
				if(VBState=1)
					return
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
		if((BugrunWerewolfCheck || QuestWerewolf || RileyAll)  && (nowUnix()-LastBugrunWerewolf)>floor(3630*(1-GiftedViciousCheck*.15))){ ;60 minutes
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
					nm_setStatus("Attacking", "Werewolf (Pumpkin)")
					send, 1
					if(!DisableToolUse)
						click, down
					loop 25 { ;wait to kill
						i:=A_Index
						if(mod(A_Index,4)=1){
							nm_Move(1500*MoveSpeedFactor, FwdKey)
							searchRet := nm_imgSearch("werewolf.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						} else if(mod(A_Index,4)=2){
							nm_Move(1500*MoveSpeedFactor, LeftKey)
							searchRet := nm_imgSearch("werewolf.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						} else if(mod(A_Index,4)=3){
							nm_Move(1500*MoveSpeedFactor, BackKey)
							searchRet := nm_imgSearch("werewolf.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						} else if(mod(A_Index,4)=0){
							nm_Move(1500*MoveSpeedFactor, RightKey)
							searchRet := nm_imgSearch("werewolf.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						}
						if(A_Index=25)
							success:=1
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						;sleep, 1000
					}
					click, up
					if(VBState=1)
						return
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
		if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))){ ;20 minutes
			loop 1 {
				if(VBState=1)
					return
				;pine tree
				BugRunField:="pine tree"
				;walk to pine tree from pumpkin if just killed werewolf
				if((BugrunWerewolfCheck || QuestWerewolf || RileyAll) && (nowUnix()-LastBugrunWerewolf)>floor(3630*(1-GiftedViciousCheck*.15))){
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
					nm_setStatus("Attacking")
					send, 1
					if(!DisableToolUse)
						click, down
					loop 20 { ;wait to kill
						if(A_Index=20)
							success:=1
						searchRet := nm_imgSearch("mantis.png",30,"lowright")
						If (searchRet[1] = 0) {
							success:=1
							sleep, 4000
							break
						}
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						sleep, 1000
					}
					click, up
					if(VBState=1)
						return
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
		if((BugrunScorpionsCheck || QuestScorpions || RileyScorpions || RileyAll)  && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))){ ;20 minutes
			loop 1 {
				if(VBState=1)
					return
				;rose
				BugRunField:="rose"
				;walk to rose from pine tree if just killed mantis
				if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15)) && MoveMethod="walk"){
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
					nm_setStatus("Attacking")
					send, 1
					if(!DisableToolUse)
						click, down
					loop 17 { ;wait to kill
						i:=A_Index
						if(mod(A_Index,4)=1){
							nm_Move(1500*MoveSpeedFactor, FwdKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
								nm_Move(1500*MoveSpeedFactor, BackKey)
								success:=1
								break
							}
						} else if(mod(A_Index,4)=2){
							nm_Move(1500*MoveSpeedFactor, LeftKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
								nm_Move(1500*MoveSpeedFactor, BackKey)
								success:=1
								break
							}
						} else if(mod(A_Index,4)=3){
							nm_Move(1500*MoveSpeedFactor, BackKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						} else if(mod(A_Index,4)=0){
							nm_Move(1500*MoveSpeedFactor, RightKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						}
						if(A_Index=17)
							success:=1
						if(youDied)
							break
						if(!DisableToolUse)
							Click
						;sleep, 1000
					}
					click, up
					if(VBState=1)
						return
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
		if((TunnelBearCheck)  && (nowUnix()-LastTunnelBear)>floor(172800*(1-GiftedViciousCheck*.15))){ ;48 hours
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
					sendinput {e down}
					Sleep, 100
					sendinput {e up}
					DllCall("Sleep",UInt,50)
					send {%LeftKey% down}
					DllCall("Sleep",UInt,1050)
					send {space}
					send {space}
					DllCall("Sleep",UInt,4500)
					send {%LeftKey% up}
					send {space}
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
				loop 3 {
					DllCall("Sleep",UInt,1000)
					if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
						found:=1
						break
					} else {
						nm_Move(250*MoveSpeedFactor, FwdKey)
						DllCall("Sleep",UInt,150)
						loop 3{
							DllCall("Sleep",UInt,1000)
							if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
								found:=1
								break
							}
						}
					}
				}
				;attack tunnel bear
				TBdead:=0
				if(found) {
					loop 2 {
						send {PgUp}
					}
					nm_setStatus("Attacking", "Tunnel Bear")
					loop 75 {
						while(nm_imgSearch("tunnelbear.png",5,"high")[1] = 0){
							nm_Move(200*MoveSpeedFactor, BackKey)
						}
						if(nm_imgSearch("tunnelbeardead.png",25,"lowright")[1] = 0){
							TBdead:=1
							loop 2 {
								send {PgDn}
							}
							break
						}
						if(youDied)
							break
						sleep, 1000
					}
				} else { ;No TunnelBear here...try again in 2 hours
					LastTunnelBear:=nowUnix()-floor(172800*(1-GiftedViciousCheck*.15))+7200
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
		if((KingBeetleCheck) && (nowUnix()-LastKingBeetle)>floor(86400*(1-GiftedViciousCheck*.15))){ ;24 hours
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
					nm_Move(1500*MoveSpeedFactor, RightKey, BackKey)
					nm_Move(1700*MoveSpeedFactor, RightKey, FwdKey)
				} else {
					nm_gotoRamp()
					nm_gotoCannon()
					PrevKeyDelay := A_KeyDelay
					SetKeyDelay, 5
					sendinput {e down}
					Sleep, 100
					sendinput {e up}
					DllCall("Sleep",UInt,50)
					send {%LeftKey% down}
					DllCall("Sleep",UInt,575)
					send {space}
					send {space}
					DllCall("Sleep",UInt,4600)
					send {%LeftKey% up}
					send {space}
					DllCall("Sleep",UInt,1000)
					nm_Move(3000*MoveSpeedFactor, LeftKey, FwdKey)
					nm_Move(1500*MoveSpeedFactor, RightKey, BackKey)
					nm_Move(1700*MoveSpeedFactor, RightKey, FwdKey)
					SetKeyDelay, PrevKeyDelay
				}
				;wait for baby love
				DllCall("Sleep",UInt,1000)
				if (KingBeetleBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					DllCall("Sleep",UInt,1500)
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						DllCall("Sleep",UInt,1000)
					}
				}
				lairConfirmed:=0
				;Go inside
				nm_Move(1000*MoveSpeedFactor, FwdKey)
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
				loop 50 {
					sleep 200
					if(nm_imgSearch("planterConfirm3.png",10,"right")[1] = 0){
						found:=1
						break
					}
				}
				if(!found) { ;No King Beetle here...try again in 2 hours
					if(A_Index=2){
						LastKingBeetle:=nowUnix()-floor(79200*(1-GiftedViciousCheck*.15))+7200
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
						nm_setStatus("Keeping", "King Beetle Amulet")
						MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
						Click
						sleep, 1000
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
		if((StumpSnailCheck) && (nowUnix()-LastStumpSnail)>floor(345600*(1-GiftedViciousCheck*.15))){ ;4 days
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
				loop 2 {
					Sleep, 1000
					if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
						found:=1
						break
					} else {
						nm_Move(250*MoveSpeedFactor, FwdKey)
						Sleep, 150
						loop 3{
							Sleep, 1000
							if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
								found:=1
								break
							}
						}
					}
				}
				;attack Snail
				
				Global SnailStartTime
				Global ElaspedSnailTime
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
					loop 10 {
						send {PgUp}
					}
					nm_setStatus("Attacking", "StumpSnail")
					
					DllCall("GetSystemTimeAsFileTime", "int64p", SnailStartTime)

					Send {1}

					inactiveHoney:=0
					loop { ;30 minute Stump timer to keep blessings, Will rehunt in an hour
						
						if (currentWalk["name"] != "snail"){
							nm_createWalk(movement, "snail") ; create cycled walk script for this gather session
						}
						else
							Send {F13} ; start new cycle
							
						KeyWait, F14, D T5 L ; wait for pattern start
						
						Loop, 600
						{
							if(!DisableToolUse)
								Click
							imgPos := nm_imgSearch("keep.png",25,"full")
							If (imgPos[1] = 0){
								Ssdead := 1
								Send {PgDn 2}
								nm_setStatus("Keeping", "Snail Amulet")
								MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
								Click
								sleep, 1000
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
							{
								nm_fieldDriftCompensation()
								break
							}
							if(VBState=1){
								nm_endWalk()
								return
							}
							Sleep, 50
						}
							
						DllCall("GetSystemTimeAsFileTime", "int64p", time)

						ElaspedSnailTime :=  (time - SnailStartTime)//10000
						If(ElaspedSnailTime > 900000){
							nm_setStatus("Time Limit", "Stump Snail")
							LastStumpSnail:=nowUnix()-floor(345600*(1-GiftedViciousCheck*.15))+1800
							nm_endWalk()
							Return
						}
					}
					nm_endWalk()
				}
				else { ;No Stump Snail try again in 2 hours
					LastStumpSnail:=nowUnix()-floor(345600*(1-GiftedViciousCheck*.15))+7200
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
					break
				}
				else if (A_Index = 2){ ;stump snail not dead, come again in 30 mins
					LastStumpSnail:=nowUnix()-floor(345600*(1-GiftedViciousCheck*.15))+1800
					IniWrite, %LastStumpSnail%, settings\nm_config.ini, Collect, LastStumpSnail
				}
			}
		}
		if(VBState=1)
			return
		;Commando
		if((CommandoCheck) && (nowUnix()-LastCommando)>floor(1800*(1-GiftedViciousCheck*.15))){ ;30 minutes 
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
					send {e down}
					HyperSleep(100)
					send {e up}
					HyperSleep(400)
					send {" LeftKey " down}{" FwdKey " down}
					HyperSleep(1050)
					send {space 2}
					HyperSleep(5850)
					send {" FwdKey " up}
					HyperSleep(750)
					send {space}{" RotLeft " 2}
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
					send {space down}
					HyperSleep(50)
					send {space up}
					" nm_Walk(5.5, FwdKey) "              
					HyperSleep(750)    
					Loop, 3
					{
						send {space down}
						HyperSleep(50)
						send {space up}
						" nm_Walk(6, FwdKey) "              
						HyperSleep(750)
					}
					" nm_Walk(1, FwdKey) "
					send {space down}
					HyperSleep(50)
					send {space up}
					" nm_Walk(6, FwdKey) "
					HyperSleep(750)
					" nm_Walk(5, FwdKey) "
					HyperSleep(50)
					" nm_Walk(9, BackKey) "
					Sleep 4000
					send {space down}
					HyperSleep(50)
					send {space up}
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
					send {space down}
					HyperSleep(50)
					send {space up}
					" nm_Walk(4.5, FwdKey) "               
					HyperSleep(750)    
					Loop, 3
					{
						send {space down}
						HyperSleep(50)
						send {space up}
						" nm_Walk(5, FwdKey) "              
						HyperSleep(750)
					}
					" nm_Walk(1, FwdKey) "
					send {space down}
					HyperSleep(50)
					send {space up}
					" nm_Walk(6, FwdKey) "
					HyperSleep(750)
					" nm_Walk(5, FwdKey) "
					HyperSleep(50)
					" nm_Walk(9, BackKey) "
					Sleep 4000
					send {space down}
					HyperSleep(50)
					send {space up}
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
						continue 2
					if ((A_Index = 1) || (currentWalk["name"] != "commando"))
					{
						movement := "
						(LTrim Join`r`n
						" nm_Walk(5, FwdKey) "
						HyperSleep(50)
						" nm_Walk(9, BackKey) "
						Sleep 4000
						send {space down}
						HyperSleep(50)
						send {space up}
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
				loop 3 {
				;	DllCall("Sleep",UInt,1000)
				;	nm_Move(10* MoveSpeedFactor, FwdKey)
					if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
						found:=1
						break
					} else {
						DllCall("Sleep",UInt,150)
						loop 3{
							DllCall("Sleep",UInt,1000)
							if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
								found:=1
								break
							}
						}
					}
				}
				Global ChickStartTime
				Global ElaspedChickTime
				
				Ccdead:=0
				if(found) {
					nm_setStatus("Attacking", "Commando Chick")
					
					DllCall("GetSystemTimeAsFileTime", "int64p", ChickStartTime)
							
					loop { ;10 minute chick timer to keep blessings, Will rehunt in an hour
						click
						sleep 100
							
						if(nm_imgSearch("ChickDead.png",50,"lowright")[1] = 0){
							CCdead:=1
							break
						}
						if(youDied)
							break
						
						if ((Mod(A_Index, 20) = 0) && disconnectCheck())
							break
							
						DllCall("GetSystemTimeAsFileTime", "int64p", time)
						ElaspedChickTime := (time-ChickStartTime)//10000
						If(ElaspedChickTime > 600000){
							nm_setStatus("Time Limit", "Commando Chick")
							LastCommando:=nowUnix()
							Return
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
					break
				}
			}
		}
		if(VBState=1)
			return
		;crab
		if((CocoCrabCheck) && (nowUnix()-LastCrab)>floor(129600*(1-GiftedViciousCheck*.15))){ ;1.5 days
			loop 2 {
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				nm_setStatus("Traveling", "Coco Crab")
				If (MoveMethod="walk") {
					nm_walkTo("coconut")
				} else {
					nm_cannonTo("coconut")
				}
				Send {1}
				nm_Move(1400, RightKey)
				nm_Move(1000, BackKey)
				
				;search for Crab
				nm_setStatus("Searching", "Coco Crab")
				found:=0
				loop 3 {
					if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
						found:=1
						break
					} else {
						DllCall("Sleep",UInt,150)
						loop 3{
							DllCall("Sleep",UInt,1000)
							if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
								found:=1
								break
							}
						}
					}
					Sleep, 1000
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
								send {PgUp 2}
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
							LastCrab:=nowUnix()-floor(129600*(1-GiftedViciousCheck*.15))+1800
							IniWrite, %LastCrab%, settings\nm_config.ini, Collect, LastCrab
							nm_endWalk()
							Return
						}
					}
					nm_endWalk()
				}
				else { ;No Crab try again in 2 hours
					LastCrab:=nowUnix()-floor(129600*(1-GiftedViciousCheck*.15))+7200
					IniWrite, %LastCrab%, settings\nm_config.ini, Collect, LastCrab
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
					LastCrab:=nowUnix()
					IniWrite, %LastCrab%, settings\nm_config.ini, Collect, LastCrab
					break
				}
				else if (A_Index = 2) { ;crab kill failed, try again in 30 mins
					LastCrab:=nowUnix()-floor(129600*(1-GiftedViciousCheck*.15))+1800
					IniWrite, %LastCrab%, settings\nm_config.ini, Collect, LastCrab
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
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")){
		mondobuff := nm_imgSearch("mondobuff.png",50,"buff")
		If (mondobuff[1] = 0) {
			LastMondoBuff:=nowUnix()
			IniWrite, %LastMondoBuff%, settings\nm_config.ini, Collect, LastMondoBuff
			return
		}
		repeat:=1
		global FwdKey
		global LeftKey
		global BackKey
		global RightKey
		global RotLeft
		global RotRight
		global KeyDelay
		global MoveMethod
		global MoveSpeedFactor
		global AFBrollingDice
		global AFBuseGlitter
		global AFBuseBooster
		global CurrentField, CurrentAction, PreviousAction
		PreviousAction:=CurrentAction
		CurrentAction:="Mondo"
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
                send {e down}
                HyperSleep(100)
                send {e up}
                HyperSleep(2500)
                " nm_Walk(29, FwdKey) "
                " nm_Walk(25, RightKey) "
                " nm_Walk(3, LeftKey) "
                send {" RotRight " 2}
                " nm_Walk(12, RightKey) "
                )"
                
                nm_createWalk(movement)
                KeyWait, F14, D T5 L
                KeyWait, F14, T90 L
                nm_endWalk()
			}
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
				while ((nowUnix()-LastGuid)<=210 && A_Min<15 && A_Index<210) { ;3.5 mins since guid
					if(youDied)
						break
					;check for mondo death here
					mondo := nm_imgSearch("mondo3.png",50,"lowright")
					If (mondo[1] = 0) {
						break
					}
					sleep, 1000
				}
			} else if(MondoAction="Kill"){
				repeat:=1
				loop 900 { ;15 mins
					nm_autoFieldBoost(CurrentField)
					if(youDied || VBState=1 || AFBrollingDice || AFBuseGlitter || AFBuseBooster)
						break
					if(A_Min>14) {
						repeat:=0
						break
					}
					;check for mondo death here
					mondo := nm_imgSearch("mondo3.png",50,"lowright")
                    If (mondo[1] = 0) {
                        ;loot mondo after death
                        nm_setStatus("Looting")
                        nm_Move(250*MoveSpeedFactor, BackKey)
                        nm_Move(500*MoveSpeedFactor, LeftKey)
                        nm_Move(1150*MoveSpeedFactor, BackKey)
                        nm_Move(100*MoveSpeedFactor, LeftKey)
                        nm_loot(13.5, 6, "left")
                        nm_loot(13.5, 6, "right")
                        nm_loot(13.5, 6, "left")
                        repeat:=0
                        break
                    }
					if(Mod(A_Index, 60)=0)
						click
					sleep, 1000
				}
			}
		}
		LastMondoBuff:=nowUnix()
		IniWrite, %LastMondoBuff%, settings\nm_config.ini, Collect, LastMondoBuff
	}
}
nm_cannonTo(location){
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveSpeedFactor, HiveConfirmed, state, objective
	static paths := {}
	
	nm_setShiftLock(0)
	
	if (paths.Count() = 0)
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
	}
	
	HiveConfirmed:=0
	
	InStr(paths[location], "gotoramp") ? nm_gotoRamp()
	InStr(paths[location], "gotocannon") ? nm_gotoCannon()
	
	nm_createWalk(paths[location])
	KeyWait, F14, D T5 L
	KeyWait, F14, T60 L
	nm_endWalk()
}
nm_gotoPlanter(location, waitEnd := 1){ ; ~ zaappiix planter path rework
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, KeyDelay, MoveSpeedFactor, HiveSlot, state, objective, HiveConfirmed
	static paths := {}, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot))
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
		SetHiveSlot := HiveSlot
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
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, KeyDelay, MoveSpeedFactor, MoveMethod, HiveSlot
	static paths := {}, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetHiveSlot != HiveSlot))
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
		SetHiveSlot := HiveSlot
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
	global youDied
	global TCFBKey
	global AFCFBKey
	global TCLRKey
	global AFCLRKey
	global VBState
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global MoveMethod
	global RotLeft
	global RotRight
	global CurrentFieldNum
	global objective
	global BackpackPercentFiltered
	global MicroConverterKey
	global PackFilterArray
	global WhirligigKey, PFieldBoosted, GlitterKey, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, PMondoGuidComplete, LastGuid, PMondoGuid, PFieldGuidExtend, PFieldGuidExtendMins, PFieldBoostExtend, PPopStarExtend, HasPopStar, PopStarActive, FieldGuidDetected, CurrentAction, PreviousAction
	global LastWhirligig
	global BoostChaserCheck, LastBlueBoost, LastRedBoost, LastMountainBoost, FieldBooster3, FieldBooster2, FieldBooster1, FieldDefault, LastMicroConverter, HiveConfirmed, LastWreath, WreathCheck
	GuiControlGet, FieldName1
	GuiControlGet, FieldPattern1
	GuiControlGet, FieldPatternSize1
	GuiControlGet, FieldPatternReps1
	GuiControlGet, FieldPatternShift1
	GuiControlGet, FieldPatternInvertFB1
	GuiControlGet, FieldPatternInvertLR1
	GuiControlGet, FieldUntilMins1
	GuiControlGet, FieldUntilPack1
	GuiControlGet, FieldReturnType1
	GuiControlGet, FieldSprinklerLoc1
	GuiControlGet, FieldSprinklerDist1
	GuiControlGet, FieldRotateDirection1
	GuiControlGet, FieldRotateTimes1
	GuiControlGet, FieldDriftCheck1
	GuiControlGet, FieldName2
	GuiControlGet, FieldPattern2
	GuiControlGet, FieldPatternSize2
	GuiControlGet, FieldPatternReps2
	GuiControlGet, FieldPatternShift2
	GuiControlGet, FieldPatternInvertFB2
	GuiControlGet, FieldPatternInvertLR2
	GuiControlGet, FieldUntilMins2
	GuiControlGet, FieldUntilPack2
	GuiControlGet, FieldReturnType2
	GuiControlGet, FieldSprinklerLoc2
	GuiControlGet, FieldSprinklerDist2
	GuiControlGet, FieldRotateDirection2
	GuiControlGet, FieldRotateTimes2
	GuiControlGet, FieldDriftCheck2
	GuiControlGet, FieldName3
	GuiControlGet, FieldPattern3
	GuiControlGet, FieldPatternSize3
	GuiControlGet, FieldPatternReps3
	GuiControlGet, FieldPatternShift3
	GuiControlGet, FieldPatternInvertFB3
	GuiControlGet, FieldPatternInvertLR3
	GuiControlGet, FieldUntilMins3
	GuiControlGet, FieldUntilPack3
	GuiControlGet, FieldReturnType3
	GuiControlGet, FieldSprinklerLoc3
	GuiControlGet, FieldSprinklerDist3
	GuiControlGet, FieldRotateDirection3
	GuiControlGet, FieldRotateTimes3
	GuiControlGet, FieldDriftCheck3
	global MondoBuffCheck, MondoAction
	global StingerCheck
	global gotoPlanterField
	global EnablePlantersPlus
	global LastMondoBuff
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global PolarQuestGatherInterruptCheck, BuckoQuestGatherInterruptCheck, RileyQuestGatherInterruptCheck, BugrunInterruptCheck, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, BlackQuestCheck, BlackQuestComplete, QuestGatherField, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete, PolarQuestCheck, PolarQuestComplete, RotateQuest, QuestGatherMins, QuestGatherReturnBy, BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll, GameFrozenCounter, HiveSlot, BugrunLadybugsCheck, BugrunRhinoBeetlesCheck, BugrunSpiderCheck, BugrunMantisCheck, BugrunScorpionsCheck, BugrunWerewolfCheck, GiftedViciousCheck
	global BeesmasGatherInterruptCheck, StockingsCheck, LastStockings, FeastCheck, LastFeast, GingerbreadCheck, LastGingerbread, SnowMachineCheck, LastSnowMachine, CandlesCheck, LastCandles, SamovarCheck, LastSamovar, LidArtCheck, LastLidArt, GummyBeaconCheck, LastGummyBeacon
	global GatherStartTime, TotalGatherTime, SessionGatherTime, ConvertStartTime, TotalConvertTime, SessionConvertTime
	global bitmaps
	if !((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck()){
		;BUGS GatherInterruptCheck
		if ((((BugrunInterruptCheck && BugrunLadybugsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll))) && ((nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles)) && ((nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunSpiderCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunMantisCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis)) && ((nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunScorpionsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll))) && ((nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunWerewolfCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-)>floor(3600*(1-GiftedViciousCheck*.15))))){
			return
		}
		;BEESMAS GatherInterruptCheck
		if (BeesmasGatherInterruptCheck && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800)))
			return
		;MONDO
		if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
			return
		;VICIOUS BEE
		if (VBState = 1)
			return
	}
	if(CurrentField="mountain top" && (A_Min>=0 && A_Min<15)) ;mondo dangerzone! skip over this field if possible
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
				FieldName%CurrentFieldNum%:=BoostChaserField
				FieldPattern%CurrentFieldNum%:=FieldDefault[BoostChaserField]["pattern"]
				FieldPatternSize%CurrentFieldNum%:=FieldDefault[BoostChaserField]["size"]
				FieldPatternReps%CurrentFieldNum%:=FieldDefault[BoostChaserField]["width"]
				FieldPatternShift%CurrentFieldNum%:=FieldDefault[BoostChaserField]["shiftlock"]
				FieldPatternInvertFB%CurrentFieldNum%:=FieldDefault[BoostChaserField]["invertFB"]
				FieldPatternInvertLR%CurrentFieldNum%:=FieldDefault[BoostChaserField]["invertLR"]
				FieldUntilMins%CurrentFieldNum%:=FieldDefault[BoostChaserField]["gathertime"]
				FieldUntilPack%CurrentFieldNum%:=FieldDefault[BoostChaserField]["percent"]
				FieldReturnType%CurrentFieldNum%:=FieldDefault[BoostChaserField]["convert"]
				FieldSprinklerLoc%CurrentFieldNum%:=FieldDefault[BoostChaserField]["sprinkler"]
				FieldSprinklerDist%CurrentFieldNum%:=FieldDefault[BoostChaserField]["distance"]
				FieldRotateDirection%CurrentFieldNum%:=FieldDefault[BoostChaserField]["camera"]
				FieldRotateTimes%CurrentFieldNum%:=FieldDefault[BoostChaserField]["turns"]
				FieldDriftCheck%CurrentFieldNum%:=FieldDefault[BoostChaserField]["drift"]
				break
			}
		}
		;questing override
		if((BlackQuestCheck || BuckoQuestCheck || RileyQuestCheck || PolarQuestCheck) && QuestGatherField!="None"){
			fieldOverrideReason:="Quest"
			thisfield:=QuestGatherField
			if(QuestGatherField=FieldName1) {
				FieldName%CurrentFieldNum%:=QuestGatherField
				FieldPattern%CurrentFieldNum%:=FieldPattern1
				FieldPatternSize%CurrentFieldNum%:=FieldPatternSize1
				FieldPatternReps%CurrentFieldNum%:=FieldPatternReps1
				FieldPatternShift%CurrentFieldNum%:=FieldPatternShift1
				FieldPatternInvertFB%CurrentFieldNum%:=FieldPatternInvertFB1
				FieldPatternInvertLR%CurrentFieldNum%:=FieldPatternInvertLR1
				FieldUntilMins%CurrentFieldNum%:=FieldUntilMins1
				FieldUntilPack%CurrentFieldNum%:=FieldUntilPack1
				FieldReturnType%CurrentFieldNum%:=FieldReturnType1
				FieldRotateDirection%CurrentFieldNum%:=FieldRotateDirection1
				FieldRotateTimes%CurrentFieldNum%:=FieldRotateTimes1
				FieldSprinklerLoc%CurrentFieldNum%:=FieldSprinklerLoc1
				FieldSprinklerDist%CurrentFieldNum%:=FieldSprinklerDist1
			} else {
				FieldName%CurrentFieldNum%:=QuestGatherField
				FieldPattern%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"]
				FieldPatternSize%CurrentFieldNum%:=FieldDefault[QuestGatherField]["size"]
				FieldPatternReps%CurrentFieldNum%:=FieldDefault[QuestGatherField]["width"]
				FieldPatternShift%CurrentFieldNum%:=FieldDefault[QuestGatherField]["shiftlock"]
				FieldPatternInvertFB%CurrentFieldNum%:=FieldDefault[QuestGatherField]["invertFB"]
				FieldPatternInvertLR%CurrentFieldNum%:=FieldDefault[QuestGatherField]["invertLR"]
				FieldUntilMins%CurrentFieldNum%:=QuestGatherMins
				FieldUntilPack%CurrentFieldNum%:=FieldDefault[QuestGatherField]["percent"]
				FieldReturnType%CurrentFieldNum%:=QuestGatherReturnBy
				FieldSprinklerLoc%CurrentFieldNum%:=FieldDefault[QuestGatherField]["sprinkler"]
				FieldSprinklerDist%CurrentFieldNum%:=FieldDefault[QuestGatherField]["distance"]
				FieldRotateDirection%CurrentFieldNum%:=FieldDefault[QuestGatherField]["camera"]
				FieldRotateTimes%CurrentFieldNum%:=FieldDefault[QuestGatherField]["turns"]
				FieldDriftCheck%CurrentFieldNum%:=FieldDefault[QuestGatherField]["drift"]
			}
			break
		}
		;Gather in planter field override
		if(gotoPlanterField && EnablePlantersPlus){
			loop, 3{
				inverseIndex:=(4-A_Index)
				IniRead, PlanterField%inverseIndex%, settings\nm_config.ini, planters, PlanterField%inverseIndex%
				If(PlanterField%inverseIndex%="dandelion" || PlanterField%inverseIndex%="sunflower" || PlanterField%inverseIndex%="mushroom" || PlanterField%inverseIndex%="blue flower" || PlanterField%inverseIndex%="clover" || PlanterField%inverseIndex%="strawberry" || PlanterField%inverseIndex%="spider" || PlanterField%inverseIndex%="bamboo" || PlanterField%inverseIndex%="pineapple" || PlanterField%inverseIndex%="stump" || PlanterField%inverseIndex%="cactus" || PlanterField%inverseIndex%="pumpkin" || PlanterField%inverseIndex%="pine tree" || PlanterField%inverseIndex%="rose" || PlanterField%inverseIndex%="mountain top" || PlanterField%inverseIndex%="pepper" || PlanterField%inverseIndex%="coconut"){
					fieldOverrideReason:="Planter"
					FieldName%CurrentFieldNum%:=PlanterField%inverseIndex%
					GuiControlGet, FieldPattern1
					GuiControlGet, FieldPatternSize1
					GuiControlGet, FieldPatternReps1
					GuiControlGet, FieldPatternShift1
					GuiControlGet, FieldPatternInvertFB1
					GuiControlGet, FieldPatternInvertLR1
					GuiControlGet, FieldUntilMins1
					GuiControlGet, FieldUntilPack1
					GuiControlGet, FieldReturnType1
					GuiControlGet, FieldSprinklerLoc1
					GuiControlGet, FieldSprinklerDist1
					GuiControlGet, FieldRotateDirection1
					GuiControlGet, FieldRotateTimes1
					FieldPattern%CurrentFieldNum%:=FieldPattern1
					FieldPatternSize%CurrentFieldNum%:=FieldPatternSize1
					FieldPatternReps%CurrentFieldNum%:=FieldPatternReps1
					FieldPatternShift%CurrentFieldNum%:=FieldPatternShift1
					FieldPatternInvertFB%CurrentFieldNum%:=FieldPatternInvertFB1
					FieldPatternInvertLR%CurrentFieldNum%:=FieldPatternInvertLR1
					FieldUntilMins%CurrentFieldNum%:=FieldUntilMins1
					FieldUntilPack%CurrentFieldNum%:=FieldUntilPack1
					FieldReturnType%CurrentFieldNum%:=FieldReturnType1
					FieldRotateTimes%CurrentFieldNum%:=FieldRotateTimes1
					FieldSprinklerLoc%CurrentFieldNum%:=FieldSprinklerLoc1
					FieldSprinklerDist%CurrentFieldNum%:=FieldSprinklerDist1
					FieldRotateDirection%CurrentFieldNum%:=FieldRotateDirection1
					break
				}
			}
		}
	}
	PreviousAction:=CurrentAction
	CurrentAction:="Gather"
	;close all menus
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
	if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 0) {
		MouseMove, 30, 120
		Click
		Sleep 50
	}
	Gdip_DisposeImage(pBMScreen)
	MouseMove, 30, 120
	Click
	MouseMove, 350, 100
	;reset
	if(fieldOverrideReason="None") {
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
				if(nm_fieldBoostCheck(value, 3) && FieldName%CurrentFieldNum%=value) {
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
				if(nm_fieldBoostCheck(value, 3) && FieldName%CurrentFieldNum%=value) {
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
				if(nm_fieldBoostCheck(value, 3) && FieldName%CurrentFieldNum%=value) {
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
				if(nm_fieldBoostCheck(value, 1) && FieldName%CurrentFieldNum%=value) {
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
	nm_setStatus("Traveling", FieldName%CurrentFieldNum%)
	;goto field
	if(MoveMethod="Walk"){
		nm_walkTo(FieldName%CurrentFieldNum%)
	} else if (MoveMethod="Cannon"){
		nm_cannonTo(FieldName%CurrentFieldNum%)
	} else {
		msgbox GoGather: MoveMethod undefined!
	}
	nm_autoFieldBoost(FieldName%CurrentFieldNum%)
	nm_fieldBoostGlitter()
	;set sprinkler
	VarSetCapacity(field_limit,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",FieldUntilMins%CurrentFieldNum%*60*10000000,"wstr","mm:ss","str",field_limit,"int",256)
	if(fieldOverrideReason="None") {
		nm_setStatus("Gathering", FieldName%CurrentFieldNum% (GatherFieldBoosted ? " - Boosted" : "") "`nLimit " field_limit " - " FieldPattern%CurrentFieldNum% " - " FieldPatternSize%CurrentFieldNum% " - " FieldSprinklerLoc%CurrentFieldNum% " " FieldSprinklerDist%CurrentFieldNum%)
	} else if(fieldOverrideReason="Quest") {
		nm_setStatus("Gathering", RotateQuest . " " . fieldOverrideReason . " - " . FieldName%CurrentFieldNum% "`nLimit " field_limit " - " FieldPattern%CurrentFieldNum% " - " FieldPatternSize%CurrentFieldNum% " - " FieldSprinklerLoc%CurrentFieldNum% " " FieldSprinklerDist%CurrentFieldNum%)
	} else {
		nm_setStatus("Gathering", fieldOverrideReason . " - " . FieldName%CurrentFieldNum% "`nLimit " field_limit " - " FieldPattern%CurrentFieldNum% " - " FieldPatternSize%CurrentFieldNum% " - " FieldSprinklerLoc%CurrentFieldNum% " " FieldSprinklerDist%CurrentFieldNum%)
	}
	nm_setSprinkler(FieldName%CurrentFieldNum%, FieldSprinklerLoc%CurrentFieldNum%, FieldSprinklerDist%CurrentFieldNum%)
	;rotate
	if (FieldRotateDirection%CurrentFieldNum% != "None") {
		direction:=FieldRotateDirection%CurrentFieldNum%
		sendinput % "{" Rot%direction% " " FieldRotateTimes%CurrentFieldNum% "}"
	}
	;determine if facing corner
	FacingFieldCorner:=0
	if((FieldName%CurrentFieldNum%="pine tree" && (FieldSprinklerLoc%CurrentFieldNum%="upper" && FieldRotateDirection%CurrentFieldNum%="left" && FieldRotateTimes%CurrentFieldNum%=1)) || ((FieldName%CurrentFieldNum%="pineapple" && (FieldSprinklerLoc%CurrentFieldNum%="upper left" && FieldRotateDirection%CurrentFieldNum%="left" && FieldRotateTimes%CurrentFieldNum%=1)))) {
		FacingFieldCorner:=1
	}
	;set direction keys
	;foward/back
	if(FieldPatternInvertFB%CurrentFieldNum%){
		TCFBKey:=BackKey
		AFCFBKey:=FwdKey
	} else {
		TCFBKey:=FwdKey
		AFCFBKey:=BackKey
	}
	if(FieldPatternInvertLR%CurrentFieldNum%){
		TCLRKey:=RightKey
		AFCLRKey:=LeftKey
	} else {
		TCLRKey:=LeftKey
		AFCLRKey:=RightKey
	}
	
	;gather loop
	bypass:=0
	inactiveHoney:=0
	interruptReason := ""
	GatherStartTime:=gatherStart:=nowUnix()
	if(FieldPatternShift%CurrentFieldNum%) {
		nm_setShiftLock(1)
	}
	while(((nowUnix()-gatherStart)<(FieldUntilMins%CurrentFieldNum%*60)) || (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)<840) || (PFieldBoostExtend && (nowUnix()-GatherFieldBoostedStart)<1800 && (nowUnix()-LastGlitter)<900) || (PFieldGuidExtend && FieldGuidDetected && (nowUnix()-gatherStart)<(FieldUntilMins%CurrentFieldNum%*60+PFieldGuidExtend*60) && (nowUnix()-GatherFieldBoostedStart)>900 && (nowUnix()-LastGlitter)>900) || (PPopStarExtend && HasPopStar && PopStarActive)){
		if(PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none" && fieldOverrideReason="None") { ;between 9 and 15 mins (-minus an extra 15 seconds)
			Send {%GlitterKey%}
			LastGlitter:=nowUnix()
			IniWrite, %LastGlitter%, settings\nm_config.ini, Boost, LastGlitter
		}
		nm_gather(FieldPattern%CurrentFieldNum%, FieldPatternSize%CurrentFieldNum%, FieldPatternReps%CurrentFieldNum%, FacingFieldCorner)
		nm_autoFieldBoost(FieldName%CurrentFieldNum%)
		FieldDriftCheck%CurrentFieldNum% ? nm_fieldDriftCompensation()
		nm_fieldBoostGlitter()
		;high priority interrupts
		if(VBState=1 || (dccheck := DisconnectCheck()) || youDied) {
			bypass:=1
			interruptReason := VBState ? "Vicious Bee" : dccheck ? "Disconnect" : "You Died!"
			break
		}
		;full backpack
		if (BackpackPercentFiltered>=(FieldUntilPack%CurrentFieldNum%-2)) {
			if((BackpackPercentFiltered>=(FieldUntilPack%CurrentFieldNum% < 90 ? 98 : FieldUntilPack%CurrentFieldNum%-2)) && ((nowUnix()-LastMicroConverter)>30) && ((MicroConverterKey!="none" && !PFieldBoosted) || (MicroConverterKey!="none" && PFieldBoosted && GatherFieldBoosted))) { ;30 seconds cooldown
				send {%MicroConverterKey%}
				sleep, 500
				LastMicroConverter:=nowUnix()
				IniWrite, %LastMicroConverter%, settings\nm_config.ini, Boost, LastMicroConverter
				continue
			} else {
				interruptReason := "Backpack exceeds " .  FieldUntilPack%CurrentFieldNum% . " percent"
				break
			}
		}
		;inactive honey
		if(not nm_activeHoney() && (BackpackPercentFiltered<FieldUntilPack%CurrentFieldNum%)){
			++inactiveHoney
			if (inactiveHoney=3) {
				interruptReason := "Inactive Honey"
				GameFrozenCounter:=GameFrozenCounter+1
				break
			}
		}
		else
			inactiveHoney:=0
		;end of high priority interrupts, continue if boosted
		if ((nowUnix()-GatherFieldBoostedStart<900) || (nowUnix()-LastGlitter<900) || nm_boostBypassCheck())
			continue
		;low priority interrupts
		if ((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag")){
			interruptReason := "Mondo"
			if (PMondoGuidComplete)
				PMondoGuidComplete:=0
			break
		}
		;GatherInterruptCheck
		if ((((BugrunInterruptCheck && BugrunLadybugsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestLadybugs) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyLadybugs || RileyAll))) && ((nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunRhinoBeetlesCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestRhinoBeetles) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoRhinoBeetles)) && ((nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunSpiderCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestSpider) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunMantisCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestMantis) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll) || (BuckoQuestCheck && BuckoQuestGatherInterruptCheck && BuckoMantis)) && ((nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunScorpionsCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestScorpions) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && (RileyScorpions || RileyAll))) && ((nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15)))) || (((BugrunInterruptCheck && BugrunWerewolfCheck) || (PolarQuestCheck && PolarQuestGatherInterruptCheck && QuestWerewolf) || (RileyQuestCheck && RileyQuestGatherInterruptCheck && RileyAll)) && ((nowUnix()-)>floor(3600*(1-GiftedViciousCheck*.15))))){
			interruptReason := "Kill Bugs"
			break
		}
		if (BeesmasGatherInterruptCheck && ((StockingsCheck && (nowUnix()-LastStockings)>3600) || (FeastCheck && (nowUnix()-LastFeast)>5400) || (GingerbreadCheck && (nowUnix()-LastGingerbread)>7200) || (SnowMachineCheck && (nowUnix()-LastSnowMachine)>7200) || (CandlesCheck && (nowUnix()-LastCandles)>14400) || (SamovarCheck && (nowUnix()-LastSamovar)>21600) || (LidArtCheck && (nowUnix()-LastLidArt)>28800) || (GummyBeaconCheck && (nowUnix()-LastGummyBeacon)>28800))){
			interruptReason := "Beesmas Machine"
			break
		}
		;quest interrupts
		;Black Bear quest
		if(RotateQuest="Black" && BlackQuestCheck && fieldOverrideReason="Quest"){
			nm_BlackQuestProg()
			if(FieldPatternShift%CurrentFieldNum%) {
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
			if(FieldPatternShift%CurrentFieldNum%) {
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
			if(FieldPatternShift%CurrentFieldNum%) {
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
			if(FieldPatternShift%CurrentFieldNum%) {
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
	
	; ~ set gather ended status
	VarSetCapacity(gatherDuration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(nowUnix()-gatherStart)*10000000,"wstr","mm:ss","str",gatherDuration,"int",256)
	nm_setStatus("Gathering", "Ended`nTime " gatherDuration " - " (interruptReason ? (InStr(interruptReason, "Backpack exceeds") ? "Bag Limit" : interruptReason) : "Time Limit") " - Return: " FieldReturnType%CurrentFieldNum%)
	
	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	GatherStartTime:=0
	nm_setShiftLock(0)
	if(bypass = 0){
		;rotate back
		if (FieldRotateDirection%CurrentFieldNum% != "None") {
			direction:=(FieldRotateDirection%CurrentFieldNum% = "left") ? "right" : "left"
			sendinput % "{" Rot%direction% " " FieldRotateTimes%CurrentFieldNum% "}"
		}
		;close quest log if necessary
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			MouseMove, 85, 120
			Click
			MouseMove, 350, 100
		}
		Gdip_DisposeImage(pBMScreen)
		;whirligig
		if(FieldReturnType%CurrentFieldNum%="walk") { ;walk back
			if((WhirligigKey!="none" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="none" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)){
				if(FieldName%CurrentFieldNum%="sunflower"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="dandelion"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="mushroom"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="blue flower"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="spider"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="strawberry"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="bamboo"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pineapple"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="stump"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pumpkin"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pine tree"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="rose"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pepper"){
					loop 2 {
						send {%RotLeft%}
					}
				}
				send {%WhirligigKey%}
				LastWhirligig:=nowUnix()
				HiveConfirmed := 1
				IniWrite, %LastWhirligig%, settings\nm_config.ini, Boost, LastWhirligig
				sleep, 1000
			} else { ;walk to hive
				nm_walkFrom(FieldName%CurrentFieldNum%)
				;Honey Wreath
				if (WreathCheck && ((interruptReason = "") || InStr(interruptReason, "Backpack exceeds")) && (nowUnix()-LastWreath)>1800) { ;0.5 hours
					nm_setStatus("Traveling", "Honey Wreath")
					nm_gotoCollect("wreath")
					
					searchRet := nm_imgSearch("e_button.png",30,"high")
					if (searchRet[1] = 0) {
						sendinput {e down}
						Sleep, 100
						sendinput {e up}
						
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
		} else if(FieldReturnType%CurrentFieldNum%="rejoin") { ;exit and rejoin game
			while(winexist("Roblox ahk_exe RobloxPlayerBeta.exe")){
				WinKill, Roblox ahk_exe RobloxPlayerBeta.exe
				sleep, 1000
			}
			return
		} else { ;reset back
			if ((WhirligigKey!="none" && (nowUnix()-LastWhirligig)>180 && !PFieldBoosted) || (WhirligigKey!="none" && (nowUnix()-LastWhirligig)>180 && PFieldBoosted && GatherFieldBoosted)) {
				if(FieldName%CurrentFieldNum%="sunflower"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="dandelion"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="mushroom"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="blue flower"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="spider"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="strawberry"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="bamboo"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pineapple"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="stump"){
					loop 2 {
						send, {%RotRight%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pumpkin"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pine tree"){
					loop 4 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="rose"){
					loop 2 {
						send, {%RotLeft%}
					}
				}
				else if(FieldName%CurrentFieldNum%="pepper"){
					loop 2 {
						send {%RotLeft%}
					}
				}
				send {%WhirligigKey%}
				LastWhirligig:=nowUnix()
				HiveConfirmed := 1
				IniWrite, %LastWhirligig%, settings\nm_config.ini, Boost, LastWhirligig
				sleep, 1000
			}
		}
	}
	nm_currentFieldDown()
	if(CurrentField="mountain top" && (A_Min>=0 && A_Min<15)) ;mondo dangerzone! skip over this field if possible
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
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
nm_gather(pattern, patternsize:="M", reps:=1, facingcorner:=0){
	global TCFBKey, AFCFBKey, TCLRKey, AFCLRKey, FwdKey, BackKey, LeftKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveSpeedFactor, DisableToolUse, currentWalk
	static patterns := {}
	
	if(pattern="stationary"){
		loop 10 {
			click
			sleep 1000
		}
		return
	}
	
	;set size ~ replaced if-else with ternary, slightly speeds up delay between cycles
	size := (patternsize="XS") ? 0.25
		: (patternsize="S") ? 0.5
		: (patternsize="L") ? 1.5
		: (patternsize="XL") ? 2
		: 1 ; medium (default)
		
	if(!DisableToolUse)
		click, down
	
	; ~ obtain all patterns, which are stored as code in settings\imported\patterns.ahk
	; Walk(" n * size ")" / "Walk(n)" - new general form, can alter to include variables
	; HyperSleep(" 2000/9*MoveSpeedFactor*walkparam ") - old form derived from new form (see RegExMatch below)
	; ask me if you need any help with translating old form to new form or vice versa
	; almost all of this function has been revamped to improve gathering timing inaccuracies, feel free to ask about anything
	
	patternChange := (currentWalk["name"] = (pattern . patternsize . reps . TCFBKey . AFCFBKey . TCLRKey . AFCLRKey)) ? 0 : 1
	
	if (patternChange || (patterns.Count() = 0))
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
		
		patterns["typewriter"] := "
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
	
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows, On
	if (patternChange || !WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"]))
		nm_createWalk(patterns[pattern], (pattern . patternsize . reps . TCFBKey . AFCFBKey . TCLRKey . AFCLRKey)) ; create / replace cycled walk script for this gather session
	else
		Send {F13} ; start new cycle
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	
	KeyWait, F14, D T5 L ; wait for pattern start
	if ErrorLevel
		nm_endWalk()
	KeyWait, F14, T90 L ; wait for pattern finish
	if ErrorLevel
		nm_endWalk()
	
	click, up
}
nm_Walk(tiles, MoveKey1, MoveKey2:=0){ ; ~ this function returns a string of AHK code which holds MoveKey1 (and optionally MoveKey2) down for 'tiles' tiles. NOTE: this only helps creating a movement, put this through nm_createWalk() to execute
	return "
	(LTrim Join`r`n
	Send {" MoveKey1 " down}" (MoveKey2 ? "{" MoveKey2 " down}" : "") "
	Walk(" tiles ")
	Send {" MoveKey1 " up}" (MoveKey2 ? "{" MoveKey2 " up}" : "") "
	)"
}
nm_createWalk(movement, name:="") ; ~ this function generates the 'walk' code and runs it for a given 'movement' (AHK code string), using movespeed correction if 'NewWalk' is enabled and legacy movement otherwise
{
	global newWalk, MoveSpeedNum, MoveSpeedFactor, currentWalk, LeftKey, RightKey, FwdKey, BackKey
	
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
		
		#Include " A_ScriptDir "\lib
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
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, ""Space"", ""LButton"", ""RButton"", ""e""]
				if %v%state
					Send % ""{"" v "" down}""
		}
		else
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, ""Space"", ""LButton"", ""RButton"", ""e""]
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
			Send {" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}{Space up}{F14 up}{e up}
			Gdip_Shutdown(pToken)
		}
		)" ; this is just ahk code, it will be executed as a new script
	}
	else
	{
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
		
		#Include " A_ScriptDir "\lib
		#Include Gdip_All.ahk
		#Include Gdip_ImageSearch.ahk
		#Include HyperSleep.ahk
		
		Gosub, F13
		return
		
		F13::
		Send {F14 down}
		" RegExReplace(movement, "im)Walk\((?<param>(?:\([^)]*\)|[^(),]*)+).*\)", "HyperSleep(2000/9*" MoveSpeedFactor "*(${param}))") "
		Send {F14 up}
		return
		
		F16::
		if A_IsPaused
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, ""Space"", ""LButton"", ""RButton"", ""e""]
				if %v%state
					Send % ""{"" v "" down}""
		}
		else
		{
			for k,v in [""" LeftKey """, """ RightKey """, """ FwdKey """, """ BackKey """, ""Space"", ""LButton"", ""RButton"", ""e""]
			{
				%v%state := GetKeyState(v)
				Send % ""{"" v "" up}""
			}
		}
		Pause, Toggle, 1
		return
		
		ExitFunc()
		{
			Send {" LeftKey " up}{" RightKey " up}{" FwdKey " up}{" BackKey " up}{Space up}{F14 up}{e up}
		}
		)"
	}
	
	shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(A_AhkPath " /f *")
    exec.StdIn.Write(script), exec.StdIn.Close()
	
	WinWait, % "ahk_class AutoHotkey ahk_pid " exec.ProcessID, , 2
	currentWalk["pid"] := exec.ProcessID, currentWalk["name"] := name
	DetectHiddenWindows, %Prev_DetectHiddenWindows%
	return !ErrorLevel ; return 1 if successful, 0 otherwise
}
nm_endWalk() ; ~ this function forcefully ends the walk script
{
	global currentWalk
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	DetectHiddenWindows On
	WinClose % "ahk_class AutoHotkey ahk_pid " currentWalk["pid"]
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	currentWalk["pid"] := "", currentWalk["name"] := ""
	; if issues, we can check if closed, else kill and force keys up
}
nm_convert(){
	global KeyDelay, RotRight, ZoomOut, AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey, LastEnzymes, ConvertStartTime, TotalConvertTime, SessionConvertTime, BackpackPercent, BackpackPercentFiltered, PFieldBoosted, GatherFieldBoosted, GameFrozenCounter, CurrentAction, PreviousAction, PFieldBoosted, GatherFieldBoosted, GatherFieldBoostedStart, LastGlitter, GlitterKey, LastConvertBalloon, ConvertBalloon, ConvertMins, HiveBees, bitmaps
	
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
	if ((HiveConfirmed = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)) {
		Gdip_DisposeImage(pBMScreen)
		return
	}
	if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) {
		sendinput {e down}
		Sleep, 100
		sendinput {e up}
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
			if(AFBuseGlitter || AFBuseBooster)
				break
			if (disconnectcheck()) {
				return
			}
			if (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
				return
			}
			inactiveHoney := (nm_activeHoney() = 0) ? inactiveHoney + 1 : 0
			if (BackpackConvertTime>60 && inactiveHoney>30) {
				nm_setStatus("Interupted", "Inactive Honey")
				GameFrozenCounter:=GameFrozenCounter+1
				return
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) {
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
	;balloon check
	strikes:=0
	while ((strikes <= 5) && (A_Index <= 20)) {
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY+36 "|400|120")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["e_button"], , , , , , 2, , 6) = 0)
			strikes++
		Gdip_DisposeImage(pBMScreen)
		Sleep, 100
	}
	if (strikes > 5) {
		TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
		SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
		ConvertStartTime:=0
		return
	}
	;empty balloon
	if((ConvertBalloon="always") || (ConvertBalloon="Every" && (nowUnix() - LastConvertBalloon)>(ConvertMins*60))) {
		BalloonStartTime:=nowUnix()
		inactiveHoney:=0
		ballooncomplete:=0
		nm_setStatus("Converting", "Balloon")
		while((BalloonConvertTime := nowUnix()-BalloonStartTime)<600) { ;10 mins
			nm_AutoFieldBoost(currentField)
			if(AFBuseGlitter || AFBuseBooster)
				break
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
			if (PFieldBoosted && (nowUnix()-GatherFieldBoostedStart)>525 && (nowUnix()-GatherFieldBoostedStart)<900 && (nowUnix()-LastGlitter)>900 && GlitterKey!="none") {
				return
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			if (Mod(A_Index, 30) = 0) {
				MouseMove, windowWidth-30, 16
				click
			}
			pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-200 "|" windowY "|400|125")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["makehoney"], , , , , , 5, , 2) = 1) {
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
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
		}
	}
	TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
	SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
	ConvertStartTime:=0
	
	;hive wait
	Sleep, 500+((5-Min(HiveBees, 50)/10)**0.5)*10000
}
nm_setSprinkler(field, loc, dist){
	global FwdKey, LeftKey, BackKey, RightKey, KeyDelay, MoveSpeedFactor, SprinklerType
	
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
		Send {1}
		return
	} else {
		send {space down}
		DllCall("Sleep",UInt,200)
		send {1}
		send {space up}
		DllCall("Sleep",UInt,900)
	}
	if(SprinklerType="Silver" || SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(loc, "Upper")){
			nm_Move(1000*MoveSpeedFactor, BackKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		}
		DllCall("Sleep",UInt,500)
		send {space down}
		DllCall("Sleep",UInt,200)
		send {1}
		send {space up}
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
		send {space down}
		DllCall("Sleep",UInt,200)
		send {1}
		send {space up}
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
		send {space down}
		DllCall("Sleep",UInt,200)
		send {1}
		send {space up}
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
	global MoveSpeedFactor
	global CurrentFieldNum
	global FieldSprinklerLoc1
	global FieldSprinklerLoc2
	global FieldSprinklerLoc3
	global DisableToolUse, PFieldDriftSteps
	if (!PFieldDriftSteps) {
		PFieldDriftSteps:=10
	}
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	winUp := windowHeight / 2.14
	winDown := windowHeight / 1.88
	winLeft := windowWidth / 2.14
	winRight := windowWidth / 1.88
	saturatorFinder := nm_imgSearch("saturator.png",50)
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
			DllCall("Sleep",UInt,200*MoveSpeedFactor)
			;sleep, 200*MoveSpeedFactor
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
nm_releaseKeys(){
	global FwdKey, LeftKey, BackKey, RightKey
	sendinput {%FwdKey% up}{%LeftKey% up}{%BackKey% up}{%RightKey% up}{space up}{click up}
	nm_setShiftLock(0)
}
DisconnectCheck(){
	global LastClock, LastGingerbread, KeyDelay, HiveSlot, StartOnReload, CurrentAction, PreviousAction, PrivServer, TotalDisconnects, SessionDisconnects, DailyReconnect, LastNatroSoBroke, bitmaps
	static PublicServer:=["https://www.roblox.com/games/4189852503?privateServerLinkCode=94175309348158422142147035472390"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=67638568200755121963952934967879"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=24262120063156705121074729566447"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=99290510522180059587431510446613"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=75908441775181472560138244729490"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=39932261356868784375906027447412"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=35586820242929920103315802001744"
		, "https://www.roblox.com/games/4189852503?privateServerLinkCode=56511033403232366819916242922747"]
	static browsers:=["msedge.exe","chrome.exe","iexplore.exe","firefox.exe","opera.exe","brave.exe"]
	
	if (nm_imgSearch("disconnected.png",25, "center")[1] = 1 && WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")){
		return 0
	}
	
	while(1){
		if (A_Index = 1)
			ReconnectStart := nowUnix()
		nm_setStatus("Disconnected", "Reconnecting" ((A_Index > 1) ? (" (Attempt " A_Index ")") : ""))
		PreviousAction:=CurrentAction
		CurrentAction:="Reconnect"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;StartOnReload:=1
;IniWrite, %StartOnReload%, settings\nm_config.ini, Gui, StartOnReload
;sleep, 1000
;Reload
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		if(A_Index=1){
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
		}
		browsers := ["msedge.exe","chrome.exe","iexplore.exe","firefox.exe","opera.exe","brave.exe"]
		for k, value in browsers {
			if (WinExist("ahk_exe " . value)){
				WinKill, ahk_exe %value%
				;winwaitclose, ahk_exe %value%
			}
		}
		Sleep, 500
		if(PrivServer && !RegExMatch(PrivServer, "i)^((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\/?([^\/]*)\?privateServerLinkCode=.{32}(\&[^\/]*)*$")){ ; ~ updated ps link RegEx, only send "Invalid Link" if PrivServer actually contains an input
			;null out the invalid private server link
			PrivServer:=""
			nm_setStatus("Error", "Private Server Link Invalid")
			Sleep, 1000
		}
		;Daily Reconnect
		if(DailyReconnect) {
			staggerDelay:=30000*HiveSlot
			nm_setStatus("Waiting", round(2+(staggerDelay/60000), 1) " minutes before Reconnect")
			sleep, 120000+staggerDelay
			DailyReconnect := 0
			if WinExist("background.ahk ahk_class AutoHotkey"){
				PostMessage, 0x5554, 6, 0
			}
		}
		;Close Roblox
		while(winexist("Roblox")){
			WinKill
			sleep, 1000
		}
		;Run Server Link
		if (PrivServer && (StrLen(PrivServer) > 0) && (A_Index<4)){
			nm_setStatus("Attempting", "Private Server Link")
			run, %PrivServer%
		} else {
			nm_setStatus("Attempting", "Public Server Link")
			random, x, 1, % PublicServer.Length()
			run, % PublicServer[x]
		}
		i := A_Index
		;STAGE 1 - wait for Roblox Launcher
		Loop, 120 {
			sleep, 1000 ; timeout 2 mins, slow internet / not logged in
			if WinExist("Roblox") {
				break
			}
			if (A_Index = 120) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				continue 2
			}
		}
		;STAGE 2 - wait for RobloxPlayerBeta.exe
		Loop, 180 {
			sleep, 1000 ; timeout 3 mins, wait for any Roblox update to finish
			if WinExist("Roblox ahk_exe RobloxPlayerBeta.exe") {
				WinActivate
				nm_setStatus("Detected", "Roblox Open")
				break
			}
			if (A_Index = 180) {
				nm_setStatus("Error", "No Roblox Found`nRetry: " i)
				continue 2
			}
		}
		;STAGE 3 - wait for loading screen (or loaded game)
		Loop, 180 {
			sleep, 1000 ; timeout 3 mins, slow loading
			WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|30|" windowWidth "|150")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 1) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Open")
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 180) {
				nm_setStatus("Error", "No BSS Found`nRetry: " i)
				continue 2
			}
		}
		;STAGE 4 - wait for loaded game
		Loop, 120 {
			sleep, 1000 ; timeout 2 mins, slow loading
			WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|30|" windowWidth "|150")
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["loading"], , , , , , 4) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["science"], , , , , , 2) = 1))
			{
				Gdip_DisposeImage(pBMScreen)
				nm_setStatus("Detected", "Game Loaded")
				break
			}
			Gdip_DisposeImage(pBMScreen)
			if (A_Index = 120) {
				nm_setStatus("Error", "No BSS Found`nRetry: " i)
				continue 2
			}
		}
		;Close Browser
		for k, value in browsers {
			if (WinExist("ahk_exe " . value)){
				winactivate, ahk_exe %value%
				send ^w
			}
		}
		;Successful Reconnect
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		VarSetCapacity(duration,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(ReconnectDuration := (nowUnix() - ReconnectStart))*10000000,"wstr","mm:ss","str",duration,"int",256)
		nm_setStatus("Completed", "Reconnect`nTime: " duration " - Attempts: " i)
		Sleep, 1000
		break
	}
	PrevKeyDelay:=A_KeyDelay
	SetKeyDelay, 200+KeyDelay
	loop 10 {
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		MouseMove, 350, 100
		Click
		;reset
		if(A_Index>1) {
			send {esc}
			send r
			send {enter}
			sleep,7000
		}
		;set hiveslot
		If (nm_claimHiveSlot((A_Index=1) ? HiveSlot : 0) > 0){
			LastClock:=nowUnix()
			IniWrite, %LastClock%, settings\nm_config.ini, Collect, LastClock
			LastGingerbread+=ReconnectDuration ? ReconnectDuration : 300
			IniWrite, %LastGingerbread%, settings\nm_config.ini, Collect, LastGingerbread
			GuiControl, Choose, HiveSlot, %HiveSlot%
			IniWrite, %HiveSlot%, settings\nm_config.ini, Settings, HiveSlot
			nm_setStatus("Claimed", "Hive Slot " . HiveSlot)
			;;;;; Natro so broke :weary:
			if((nowUnix()-LastNatroSoBroke)>3600) { ;limit to once per hour
				LastNatroSoBroke:=nowUnix()
				Send {Text} /[%A_Hour%:%A_Min%] Natro so broke :weary:`n
				sleep 250
			}
			break
		}
	}
	SetKeyDelay, PrevKeyDelay
	sendinput {e down}
	Sleep, 100
	sendinput {e up}
	return 1
}
nm_activeHoney(){
	global HiveBees, GameFrozenCounter
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
    x1 := (windowWidth//2)-90
    x2 := (windowWidth//2)-20
    PixelSearch, bx2, by2, x1, 0, x2, 36, 0xFFE280, 20, RGB Fast
    if (ErrorLevel = 0){
		GameFrozenCounter:=0
        return 1
	} else {
		if(HiveBees<25){
			x1 := (windowWidth//2)+210
			x2 := (windowWidth//2)+280
			PixelSearch, bx2, by2, x1, 0, x2, 36, 0xFFFFFF, 20, RGB Fast
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
	
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	MouseMove, 350, 100
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
	Prev_DetectHiddenWindows := A_DetectHiddenWindows ; ~ to communicate with background.ahk
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
		if((nowUnix()-VBLastKilled)<(300)) { ;it has been less than 5 minutes since VB was found
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
		} else if((nowUnix()-VBLastKilled)>(300)) { ;it has been greater than 5 minutes since VB was found
				VBState:=0
				;send VBState to background.ahk
				if WinExist("background.ahk ahk_class AutoHotkey")
					PostMessage, 0x5554, 3, VBState
				;nm_setStatus("VBState " . VBState, " <4>")
				nm_setStatus("Aborted", "Vicious Fight > 5 Mins")
		}
	}
	DetectHiddenWindows %Prev_DetectHiddenWindows%
	SetTitleMatchMode %Prev_TitleMatchMode%
	return killed
}
nm_locateVB(){
	global VBState, StingerCheck, StingerPepperCheck, StingerMountainTopCheck, StingerRoseCheck, StingerCactusCheck, StingerSpiderCheck, StingerCloverCheck, NightLastDetected, VBLastKilled, FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, MoveSpeedFactor, MoveMethod, objective, DisableToolUse, CurrentAction, PreviousAction
	
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
		sendinput {%RotRight% 3}{PgDn 3}
		findImg := nm_imgSearch("nightsky.png", 50, "abovebuff")
		if(findImg[1]=0){
			;night confirmed, proceed!
			nm_setStatus("Starting", "Vicious Bee Cycle")
			sendinput {%RotLeft% 3}{PgUp 3}
		} else {
			;false positive, ABORT!
			VBState:=0
			if WinExist("background.ahk ahk_class AutoHotkey")
				PostMessage, 0x5554, 3, VBState
			NightLastDetected:=nowUnix()-300-1 ;make NightLastDetected older than 5 minutes
			IniWrite, %NightLastDetected%, settings\nm_config.ini, Collect, NightLastDetected
			nm_setStatus("Aborting", "Vicious Bee - Not Night")
			sendinput {%RotLeft% 3}{PgUp 3}
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
	global state, fieldOverrideReason, GatherStartTime
	global ActiveHotkeys
	;whileNames:=["Always", "Attacking", "Gathering", "At Hive"]
	;ActiveHotkeys.push([val, slot, HBSecs, LastHotkey%slot%])
	for key, val in ActiveHotkeys {
		ActiveLen:=ActiveHotkeys.length()
		;temp1:=ActiveHotkeys[1][1]
		;temp2:=ActiveHotkeys[key][2]
		;temp3:=ActiveHotkeys[key][3]
		;temp4:=ActiveHotkeys[key][4]
		;msgbox len=%Activelen% key=%key% val=%val%`n1=%temp1%`n2=%temp2%`n3=%temp3%`n4=%temp4%
		;always
		if(ActiveHotkeys[key][1]="Always" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;attacking
		else if(state="Attacking" && ActiveHotkeys[key][1]="Attacking" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;gathering
		else if(state="Gathering" && fieldOverrideReason="None" && ActiveHotkeys[key][1]="Gathering" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;GatherStart
		else if(state="Gathering" && fieldOverrideReason="None" && (nowUnix()-GatherStartTime)<10 && ActiveHotkeys[key][1]="GatherStart" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
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
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, settings\nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
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
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
	;search for honey quest
	Loop, 70
	{		
		Qfound:=nm_imgSearch("honeyhunt.png",50,"quest")
		if (Qfound[1]=0) {
			if (A_Index > 1)
				Gdip_DisposeImage(pBMLog)
			break
		}
		
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		switch A_Index
		{
			case 1:
			MouseMove, 30, 200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 400 ; wait for scroll to finish
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		MouseMove, 350, 100
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		xi := 0
		yi := Qfound[3]
		ww := 306
		wh := windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		HoneyStart:=[ErrorLevel, FoundX, FoundY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := HoneyStart[3]+9
			ww := 306
			wh := HoneyStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-HoneyStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := HoneyStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbarinset.png
					if(ErrorLevel=0) {
						NextX:=FoundX+1
						QuestBarInset:=QuestBarInset+1
					} else {
						break
					}
				}
				;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
			}
		}	
		;Update Honey quest progress in GUI
		honeyProgress:=""
		;also set next steps
		PixelGetColor, questbarColor, QuestBarInset+10, HoneyStart[3]+QuestBarGapSize+1, RGB fast
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
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
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
		
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		switch A_Index
		{
			case 1:
			MouseMove, 30, 200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 400 ; wait for scroll to finish
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		MouseMove, 350, 100
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		xi := 0
		yi := Qfound[3]
		ww := 306
		wh := windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		PolarStart:=[ErrorLevel, FoundX, FoundY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := PolarStart[3]+9
			ww := 306
			wh := PolarStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-PolarStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := PolarStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbarinset.png
					if(ErrorLevel=0) {
						NextX:=FoundX+1
						QuestBarInset:=QuestBarInset+1
					} else {
						break
					}
				}
				;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
			}
		}
		;MouseMove, Qstart[2], Qstart[3], 5
		;determine Quest name
		xi := 0
		yi := PolarStart[3]-36
		ww := 306
		wh := PolarStart[3]
		for key, value in PolarBear {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				PolarQuest:=key
				questSteps:=PolarBear[key].length()
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=PolarStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, 225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
						MouseMove, 350, 100
						break
					}
				}
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
			PixelGetColor, questbarColor, QuestBarInset+10, QuestBarSize*(PolarBear[PolarQuest][A_Index][1]-1)+PolarStart[3]+QuestBarGapSize+1, RGB fast
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
	global PolarQuestCheck, PolarQuest, PolarQuestComplete, QuestGatherField, QuestLadybugs, QuestRhinoBeetles, QuestSpider, QuestMantis, QuestScorpions, QuestWerewolf, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, GiftedViciousCheck, RotateQuest, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
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
		if ((QuestLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || (QuestRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || (QuestSpider && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) || (QuestMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))) || (QuestScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))) || (QuestWerewolf && (nowUnix()-LastBugrunWerewolf)>floor(3600*(1-GiftedViciousCheck*.15)))){
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
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
		return
		
	;open quest log
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
	
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
	
	;close quest log
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 0) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
}
nm_Feed(food){
	global bitmaps
	nm_setShiftLock(0)
	nm_Reset(0,0,0,1)
	nm_setStatus("Feeding", food)
	;open inventory
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 30, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
	;feed
	Loop, 70
	{
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
		
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
					return
				}				
				else
				{
					Sleep, 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
				}				
			}
		}
		
		if (Gdip_ImageSearch(pBMScreen, bitmaps[food], pos, , , , , 10, , 5) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		
		switch A_Index
		{
			case 5:
			Loop, 100 ; scroll all the way up on 5th search
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 50
		}
		Sleep, 200 ; wait for scroll to finish
	}
	Sleep, 500
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|" windowWidth "|" Min(480, windowWidth-150))
		if ((Gdip_ImageSearch(pBMScreen, bitmaps[food], pos, 0, 0, 306, Min(480, windowWidth-150), 10, , 5) = 0) || (nm_imgSearch("feeder.png",30)[1] = 0)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		
		MouseClickDrag, Left, 30, SubStr(pos, InStr(pos, ",")+1)+190, windowWidth//2, windowHeight//2-5, 5
		sleep, 200
	}
	Sleep, 250
	;check if food is already visible
	imgPos := nm_imgSearch("feeder.png",30)
	If (imgPos[1]=0){
		MouseMove, imgPos[2],imgPos[3]
		sleep 100
		Click
		sleep 100
		send 100
		sleep 1000
		imgPos := nm_imgSearch("feed.png",30)
		If (imgPos[1]=0){
			MouseMove, imgPos[2],imgPos[3]
			Click
			nm_setStatus("Completed", "Feed " food)
		}
		MouseMove, 350, 100
	}
	;close inventory
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 0) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 30, 120
		Click
		MouseMove, 350, 100
		sleep, 400
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
	global LastBugrunLadybugs, GiftedViciousCheck, LastBugrunScorpions, bitmaps
	if(!RileyQuestCheck)
		return
	nm_setShiftLock(0)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
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
		
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		switch A_Index
		{
			case 1:
			MouseMove, 30, 200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 400 ; wait for scroll to finish
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		MouseMove, 350, 100
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		xi := 0
		yi := Qfound[3]
		ww := 306
		wh := windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		RileyStart:=[ErrorLevel, FoundX, FoundY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := RileyStart[3]+9
			ww := 306
			wh := RileyStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-RileyStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := RileyStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbarinset.png
					if(ErrorLevel=0) {
						NextX:=FoundX+1
						QuestBarInset:=QuestBarInset+1
					} else {
						break
					}
				}
				;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
			}
		}	
		;determine Quest name
		xi := 0
		yi := RileyStart[3]-36
		ww := 306
		wh := RileyStart[3]
		missing:=1
		for key, value in RileyBee {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				RileyQuest:=key
				questSteps:=RileyBee[key].length()
				missing:=0
				;make sure full quest is visible
				loop 5 {
					found:=0
					NextY:=RileyStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, 225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, 100
						break
					}
				}
				Break
			}
		}
		;Update Riley quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		QuestRedAnyField:=0
		RileyLadybugs:=0
		RileyScorpions:=0
		newLine:="|"
		rileyProgress:=""
		num:=RileyBee[RileyQuest].length()
		loop %num% {
			action:=RileyBee[RileyQuest][A_Index][2]
			where:=RileyBee[RileyQuest][A_Index][3]
			PixelGetColor, questbarColor, QuestBarInset+10, QuestBarSize*(RileyBee[RileyQuest][A_Index][1]-1)+RileyStart[3]+QuestBarGapSize+1, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				RileyQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Riley%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=15){
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
		if(RileyLadybugs=0 && RileyScorpions=0 && RileyAll=0 && QuestGatherField="None" && QuestAnt=0 && QuestRedBoost=0 && QuestFeed="None" && QuestRedAnyField=0) {
				RileyQuestComplete:=1
			} else { ;check if all doable things are done and everything else is on cooldown
				if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (RileyLadybugs && (nowUnix()-LastBugrunLadybugs)<floor(330*(1-GiftedViciousCheck*.15))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)<floor(1230*(1-GiftedViciousCheck*.15)))) { ;there is at least one thing no longer on cooldown
					RileyQuestComplete:=0
				} else {
					RileyQuestComplete:=2
				}
			}
	}
}
nm_RileyQuest(){
	global RileyQuestCheck, RileyQuestComplete, RileyQuest, RotateQuest, QuestGatherField, QuestAnt, QuestRedBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, GiftedViciousCheck, RileyLadybugs, RileyScorpions, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
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
		if((RileyLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15)))) {
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
	global GiftedViciousCheck, LastBugrunRhinoBeetles, LastBugrunMantis, bitmaps
	if(!BuckoQuestCheck)
		return
	nm_setShiftLock(0)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
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
		
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		switch A_Index
		{
			case 1:
			MouseMove, 30, 200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 400 ; wait for scroll to finish
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		MouseMove, 350, 100
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		xi := 0
		yi := Qfound[3]
		ww := 306
		wh := windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BuckoStart:=[ErrorLevel, FoundX, FoundY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := BuckoStart[3]+9
			ww := 306
			wh := BuckoStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-BuckoStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := BuckoStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbarinset.png
					if(ErrorLevel=0) {
						NextX:=FoundX+1
						QuestBarInset:=QuestBarInset+1
					} else {
						break
					}
				}
				;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
			}
		}	
		;determine Quest name
		xi := 0
		yi := BuckoStart[3]-36
		ww := 306
		wh := BuckoStart[3]
		missing:=1
		for key, value in BuckoBee {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				BuckoQuest:=key
				missing:=0
				;make sure full quest is visible
				questSteps:=BuckoBee[key].length()
				loop 5 {
					found:=0
					NextY:=BuckoStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, 225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, 100
						break
					}
				}
				Break
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
			PixelGetColor, questbarColor, QuestBarInset+10, QuestBarSize*(BuckoBee[BuckoQuest][A_Index][1]-1)+BuckoStart[3]+QuestBarGapSize+1, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				BuckoQuestComplete:=0
				completeness:="Incomplete"
				if(action="kill"){
					Bucko%where%:=1
				}
				else if (action="collect" && QuestGatherField="none") {
					;red, blue, white, any
					if(where="red"){
						if(HiveBees>=15){
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
				if(QuestGatherField!="None" || (QuestAnt && (nowUnix()-LastAntPass)<7200) || (BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)<floor(330*(1-GiftedViciousCheck*.15))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)<floor(1230*(1-GiftedViciousCheck*.15)))) { ;there is at least one thing no longer on cooldown
					BuckoQuestComplete:=0
				} else {
					BuckoQuestComplete:=2
				}
			}
	}
}
nm_BuckoQuest(){
	global BuckoQuestCheck, BuckoQuestComplete, BuckoQuest, RotateQuest, QuestGatherField, QuestAnt, QuestBlueBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, GiftedViciousCheck, BuckoRhinoBeetles, BuckoMantis, CurrentAction, PreviousAction, TotalQuestsComplete, SessionQuestsComplete, VBState
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
		if((BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15)))) {
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
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["questlog"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 85, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
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
		
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		switch A_Index
		{
			case 1:
			MouseMove, 30, 200, 5
			Loop, 50 ; scroll all the way up
			{
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMLog := Gdip_BitmapFromScreen(windowX+30 "|" windowY+180 "|30|400")
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelDown}
			Sleep, 400 ; wait for scroll to finish
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		MouseMove, 350, 100
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		xi := 0
		yi := Qfound[3]
		ww := 306
		wh := windowHeight
		fileName:="questbargap.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 %A_ScriptDir%\nm_image_assets\%fileName%
			if (ErrorLevel = 2) {
				nm_setStatus("Error", "Image file " filename " was not found in:`n" A_ScriptDir "\nm_image_assets\" fileName)
				Sleep, 5000
				Process, Close, % DllCall("GetCurrentProcessId")
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BlackStart:=[ErrorLevel, FoundX, FoundY]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := BlackStart[3]+9
			ww := 306
			wh := BlackStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-BlackStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *5 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := BlackStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *5 nm_image_assets\questbarinset.png
					if(ErrorLevel=0) {
						NextX:=FoundX+1
						QuestBarInset:=QuestBarInset+1
					} else {
						break
					}
				}
				;msgbox QuestBarSize=%QuestBarSize%`nQuestBarGapSize=%QuestBarGapSize%`nQuestBarInset=%QuestBarInset%
			}
		}	
		;MouseMove, Blackstart[2], Blackstart[3], 5
		;msgbox % Blackstart[2] Blackstart[3]
		;determine Quest name
		xi := 0
		yi := BlackStart[3]-36
		ww := 306
		wh := BlackStart[3]
		missing:=1
		for key, value in BlackBear {
			filename:=(key . ".png")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *100 nm_image_assets\%fileName%
			if(ErrorLevel=0) {
				BlackQuest:=key
				missing:=0
				;make sure full quest is visible
				questSteps:=BlackBear[key].length()
				loop 5 {
					found:=0
					NextY:=BlackStart[3]
					loop %questSteps% {
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *5 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, 225
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, 100
						break
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
			PixelGetColor, questbarColor, QuestBarInset+10, QuestBarSize*(BlackBear[BlackQuest][A_Index][1]-1)+BlackStart[3]+QuestBarGapSize+1, RGB fast
			if((questbarColor=Format("{:d}",0xF46C55)) || (questbarColor=Format("{:d}",0x6EFF60))) {
				BlackQuestComplete:=0
				completeness:="Incomplete"
				;red, blue, white, any
				if(where="red"){
					if(HiveBees>=15){
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
	global FwdKey, LeftKey, BackKey, RightKey, RotLeft, RotRight, ZoomIn, ZoomOut, KeyDelay, MoveSpeedFactor, MoveMethod, QuestGatherField, HiveSlot, state, objective, HiveConfirmed, bitmaps
	static paths := {}, SetMoveMethod, SetHiveSlot
	
	nm_setShiftLock(0)
	
	if ((paths.Count() = 0) || (SetMoveMethod != MoveMethod) || (SetHiveSlot != HiveSlot))
	{
		#Include %A_ScriptDir%\paths\gtq-polar.ahk
		#Include %A_ScriptDir%\paths\gtq-honey.ahk
		#Include %A_ScriptDir%\paths\gtq-black.ahk
		#Include %A_ScriptDir%\paths\gtq-riley.ahk
		#Include %A_ScriptDir%\paths\gtq-bucko.ahk
		SetMoveMethod := MoveMethod, SetHiveSlot := HiveSlot
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
				sendinput {e down}
				Sleep, 100
				sendinput {e up}
				sleep, 2000
				Loop, 500
				{
					WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-50 "|" windowY+2*windowHeight//3 "|100|" windowHeight//3)
					if (Gdip_ImageSearch(pBMScreen, bitmaps["dialog"], pos, , , , , 2, , 3) = 0) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowWidth//2, 2*windowHeight//3+SubStr(pos, InStr(pos, ",")+1)-15
					Click
					sleep, 150
				}
				MouseMove, 350, 100
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
nm_import() ; ~ at every start of macro, import patterns
{
	If !FileExist("settings\imported") ; make sure the import folders exists
	{
		FileCreateDir, settings\imported
		If ErrorLevel
		{
			msgbox, 0x30, , Couldn't create the directory for imported files! Make sure the script is elevated if it needs to be.
			ExitApp
		}
	}
	
	init := 0
	
	; patterns
	newString := ""
	Loop, Files, %A_ScriptDir%\patterns\*.ahk
		tempFile := FileOpen(A_LoopFilePath, 0), newString .= tempFile.Read() "`r`n`r`n", tempFile.Close()
	init += FileExist(A_ScriptDir "\settings\imported\patterns.ahk") ? 0 : newString ? 1 : 0
	tempfile := FileOpen(A_ScriptDir "\settings\imported\patterns.ahk", 0), checkString := tempFile.Read(), tempFile.Close()
	if (newString != checkString)
	{
		FileDelete, % A_ScriptDir "\settings\imported\patterns.ahk"
		FileAppend, % newString, % A_ScriptDir "\settings\imported\patterns.ahk"
		new_patterns := newString ? 1 : 0
	}
	
	if init
	{
		Reload
		Sleep, 10000
	}
	
	if new_patterns
	{
		msgbox, 0x1034, , % "Change in patterns detected! Reload to update?", 30
		ifMsgBox No
			ExitApp
		else
		{
			Reload
			Sleep, 10000
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
ba_enableSwitch(){
	global
	;global resolutionKey
	GuiControlGet, EnablePlantersPlus
	GuiControlGet, MaxAllowedPlanters
	/*
	IniRead, resolution, settings\config.ini, gui, resolution
	if(EnablePlantersPlus && resolution!=720 && resolution!=1080) {
		msgbox Graphics Resolution: %resolution% is not supported by Planters+`n`nSupported resolutions are:`n720`n1080
		Guicontrol,, EnablePlantersPlus, 0
		IniWrite, 0, settings\nm_config.ini, gui, EnablePlantersPlus
		return
	}
	*/
	if(EnablePlantersPlus && MaxAllowedPlanters=0) {
		MaxAllowedPlanters:=1
		GuiControl,choosestring,MaxAllowedPlanters,1
	}
	if(EnablePlantersPlus) {
		GuiControl, Show, Enabled
		GuiControl, Hide, Disabled
	} else {
		GuiControl, Show, Disabled
		GuiControl, Hide, Enabled
	}
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), NPreset
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N1Priority
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N2Priority
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N3Priority
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N4Priority
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N5Priority
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N1MinPercent
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N2MinPercent
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N3MinPercent
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N4MinPercent
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), N5MinPercent
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), MaxAllowedPlanters
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), AutomaticHarvestInterval
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), HarvestFullGrown
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), gotoPlanterField
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), gatherFieldSipping
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), HarvestInterval
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PlasticPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), CandyPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), BlueClayPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), RedClayPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), TackyPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PesticidePlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), HeatTreatedPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), HydroponicPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PetalPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PlanterOfPlentyCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PaperPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), TicketPlanterCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), DandelionFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), SunflowerFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), MushroomFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), BlueFlowerFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), CloverFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), SpiderFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), StrawberryFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), BambooFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PineappleFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), StumpFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), CactusFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PumpkinFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PineTreeFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), RoseFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), MountainTopFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), CoconutFieldCheck
	GuiControl, % (EnablePlantersPlus ? "enable" : "disable"), PepperFieldCheck
	ba_saveConfig_()
}
ba_maxAllowedPlantersSwitch(){
	GuiControlGet, MaxAllowedPlanters
	if(MaxAllowedPlanters=0){
		Guicontrol,, EnablePlantersPlus, 0
	}
	ba_saveConfig_()
}
ba_N1unswitch_(){
    IniWrite, 1, settings\nm_config.ini, Planters, n1Switch
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
    IniWrite, 1, settings\nm_config.ini, Planters, n2Switch
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
    IniWrite, 1, settings\nm_config.ini, Planters, n3Switch
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
    IniWrite, 1, settings\nm_config.ini, Planters, n4Switch
    GuiControlGet, n4priority
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n5minPercent,10
    GuiControl,chooseString,nectarPreset,None
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N5unswitch_(){
    IniWrite, 1, settings\nm_config.ini, Planters, n5Switch
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
	GuiControlGet, AutomaticHarvestInterval
	;msgbox %AutomaticHarvestInterval%
	if(AutomaticHarvestInterval) {
		GuiControl, Hide, HarvestInterval
		GuiControl, Hide, FullText
		GuiControl, Show, AutoText
		GuiControl,, HarvestFullGrown, 0
	} else {
		GuiControl, Show, HarvestInterval
	}
	ba_saveConfig_()
}
ba_HarvestFullGrownSwitch_(){
	GuiControlGet, HarvestFullGrown
	if(HarvestFullGrown) {
		GuiControl, Hide, HarvestInterval
		GuiControl, Hide, AutoText
		GuiControl, Show, FullText
		GuiControl,, AutomaticHarvestInterval, 0
	} else {
		GuiControl, Show, HarvestInterval
	}
	ba_saveConfig_()
}
ba_gotoPlanterFieldSwitch_(){
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
	;GuiControlGet, HiveDistance
	;GuiControlGet, MoveSpeedFactor
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
	GuiControlGet, EnablePlantersPlus
	GuiControlGet, MaxAllowedPlanters
	;GuiControlGet, StingerCheck
	GuiControlGet, FDCMoveDirFB
	GuiControlGet, FDCMoveDirLR
	GuiControlGet, FDCMoveDurFB
	GuiControlGet, FDCMoveDurLR
	GuiControlGet, AltPineStart
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
	IniWrite, %EnablePlantersPlus%, settings\nm_config.ini, gui, EnablePlantersPlus
	IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
	IniWrite, %HarvestInterval%, settings\nm_config.ini, gui, HarvestInterval
	IniWrite, %AutomaticHarvestInterval%, settings\nm_config.ini, gui, AutomaticHarvestInterval
	IniWrite, %HarvestFullGrown%, settings\nm_config.ini, gui, HarvestFullGrown
	IniWrite, %GotoPlanterField%, settings\nm_config.ini, gui, GotoPlanterField
	IniWrite, %GatherFieldSipping%, settings\nm_config.ini, gui, GatherFieldSipping
	;IniWrite, %HiveDistance%, settings\nm_config.ini, gui, HiveDistance
	;IniWrite, %MoveSpeedFactor%, settings\nm_config.ini, gui, MoveSpeedFactor
	;IniWrite, %StingerCheck%, settings\nm_config.ini, gui, StingerCheck
	IniWrite, %FDCMoveDirFB%, settings\nm_config.ini, gui, FDCMoveDirFB
	IniWrite, %FDCMoveDirLR%, settings\nm_config.ini, gui, FDCMoveDirLR
	IniWrite, %FDCMoveDurFB%, settings\nm_config.ini, gui, FDCMoveDurFB
	IniWrite, %FDCMoveDurLR%, settings\nm_config.ini, gui, FDCMoveDurLR
	IniWrite, %AltPineStart%, settings\nm_config.ini, gui, AltPineStart
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
	global EnablePlantersPlus
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
	if (not EnablePlantersPlus)
		return
	if(VBState=1)
		return
	if((MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960 && (MondoAction="Buff" || MondoAction="Kill")) || (MondoBuffCheck && A_Min>=0 && A_Min<12 && (nowUnix()-LastGuid)<60 && PMondoGuid && MondoAction="Guid") || (MondoBuffCheck  && (A_Min>=0 && A_Min<=8) && (nowUnix()-LastMondoBuff)>960 && PMondoGuid && MondoAction="Tag"))
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
						nm_setStatus("Error", "Failed to harvest " PlanterName%i% " in " PlanterField%i% "!`nMaxAllowedPlanters has been reduced.")
						MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
						GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
						IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
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
					LostPlanters:=""
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
					LostPlanters:=""
				}
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
						success:=-1
						while (success!=1 && nextField!="none" && nextPlanter[1]!="none"){
							;msgbox in while %success%`nnectarpercent=%nectarPercent% + est=%estimatedNectarPercent% < min=%nectarMinPercent%
							;place nextPlanter in nextField
							success:=ba_placePlanter(nextField, nextPlanter, planterNum)
							s1bypass:
							;msgbox first if success=%success% planterNum=%planterNum%
							if(success=1){ ;planter placed successfully
								plantersplaced:=plantersplaced+1
								nectarPlantersPlaced:=nectarPlantersPlaced+1
								ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
								break
								;msgbox planter was placed
							} else if(success=2) { ;already a planter in this field
								;determine last and next fields
								lastnextfield:=ba_getlastfield(currentNectar)
								lastField:=lastNextField[1]
								nextField:=lastNextField[2]
								LostPlanters:=""
								Last%currentnectar%Field := nextField
								IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field
								;msgbox already a planter here trying next field
							} else if(success=3){ ;3 planters have been placed already
								return
							} else if(success=4){ ;not in a field
								if (A_Index = 10){
									nm_setStatus("Error", "Failed to reach field in 10 tries!`nMaxAllowedPlanters has been reduced.")
									MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
									GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
									IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
									return
								}
							} else if(success=0){ ;cannot find planter
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
								{
									nm_endWalk()
									break
								}
							;msgbox cannot find planter, trying another one
								success:=ba_placePlanter(nextField, nextPlanter, planterNum, 1)
								goto s1bypass
							}
							;msgbox after if %success%
						}
						;msgbox LEAVING while %success%`nnectarpercent=%nectarPercent% est=%estimatedNectarPercent% min=%nectarMinPercent%
					} else {
						break
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters)
					return
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
				LostPlanters:=""
			} else {
				lastnextfield:=ba_getlastfield(currentNectar)
				lastField:=lastNextField[1]
				nextField:=lastNextField[2]
				LostPlanters:=""
			}
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
					success:=-1
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none"){
						;place nextPlanter in nextField
						success:=ba_placePlanter(nextField, nextPlanter, planterNum)
						s2bypass1:
						if(success=1){ ;planter placed successfully
							plantersplaced:=plantersplaced+1
							nectarPlantersPlaced:=nectarPlantersPlaced+1
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							;msgbox planter was placed
						} else if(success=2) { ;already a planter in this field
							;determine last and next fields
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field
							;msgbox already a planter here trying next field
						} else if(success=3){ ;3 planters have been placed already
							return
						} else if(success=4){ ;not in a field
								if (A_Index = 10){
									nm_setStatus("Error", "Failed to reach field in 10 tries!`nMaxAllowedPlanters has been reduced.")
									MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
									GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
									IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
									return
								}
						} else if(success=0){ ;cannot find planter
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
						;msgbox cannot find planter, trying another one
							success:=ba_placePlanter(nextField, nextPlanter, planterNum, 1)
							goto s2bypass1
						}
					}
				} else { ;is not the last element in the array
					temp:=lowToHigh[key+1][1]
					;msgbox %estimatednectarpercent% %nectarMinPercent%`nkey=%temp%
					if ((nectarPercent + estimatedNectarPercent) <= lowToHigh[key+1][1]){
						/*
						success:=ba_placePlanter(nextField, nextPlanter, planterNum, currentNectar)
						if(success)
							plantersplaced:=plantersplaced+1
						*/
						;if ((nectarPercent + estimatedNectarPercent) <= nectarMinPercent){
							success:=-1
							while (success!=1 && nextField!="none" && nextPlanter[1]!="none"){
								;place nextPlanter in nextField
								success:=ba_placePlanter(nextField, nextPlanter, planterNum)
								s2bypass2:
								if(success=1){ ;planter placed successfully
									plantersplaced:=plantersplaced+1
									nectarPlantersPlaced:=nectarPlantersPlaced+1
									ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
									;msgbox planter was placed
								} else if(success=2) { ;already a planter in this field
									;determine last and next fields
									lastnextfield:=ba_getlastfield(currentNectar)
									lastField:=lastNextField[1]
									nextField:=lastNextField[2]
									LostPlanters:=""
									Last%currentnectar%Field := nextField
									IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field
									;msgbox already a planter here trying next field
								} else if(success=3){ ;3 planters have been placed already
									return
								} else if(success=4){ ;not in a field
									if (A_Index = 10){
										nm_setStatus("Error", "Failed to reach field in 10 tries!`nMaxAllowedPlanters has been reduced.")
										MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
										GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
										IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
										return
									}
								} else if(success=0){ ;cannot find planter
									nextPlanter:=ba_getNextPlanter(nextField)
									if (nextPlanter[1]="none")
									{
										nm_endWalk()
										break
									}
								;msgbox cannot find planter, trying another one
									success:=ba_placePlanter(nextField, nextPlanter, planterNum, 1)
									goto s2bypass2
								}
							}
						;} else {
						;	break
						;}
					} else {
						break
					}
				}
			} else {
				break
			}
			;maximum planters have been placed. leave function
			if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters)
				return
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
					LostPlanters:=""
				} else {
					lastnextfield:=ba_getlastfield(currentNectar)
					lastField:=lastNextField[1]
					nextField:=lastNextField[2]
					LostPlanters:=""
				}
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
					;place nextPlanter in nextField
					/*
					success:=ba_placePlanter(nextField, nextPlanter, planterNum, currentNectar)
					if(success)
						plantersplaced:=plantersplaced+1
					*/
					success:=-1
					while (success!=1 && nextField!="none" && nextPlanter[1]!="none"){
						;place nextPlanter in nextField
						success:=ba_placePlanter(nextField, nextPlanter, planterNum)
						s3bypass:
						if(success=1){ ;planter placed successfully
							plantersplaced:=plantersplaced+1
							nectarPlantersPlaced:=nectarPlantersPlaced+1
							ba_SavePlacedPlanter(nextField, nextPlanter, planterNum, currentNectar)
							;msgbox planter was placed
						} else if(success=2) { ;already a planter in this field
							;determine last and next fields
							lastnextfield:=ba_getlastfield(currentNectar)
							lastField:=lastNextField[1]
							nextField:=lastNextField[2]
							LostPlanters:=""
							Last%currentnectar%Field := nextField
							IniWrite, % Last%currentnectar%Field, settings\nm_config.ini, Planters, Last%currentnectar%Field
							;msgbox already a planter here trying next field
						} else if(success=3){ ;3 planters have been placed already
							return
						} else if(success=4){ ;not in a field
							if (A_Index = 10){
								nm_setStatus("Error", "Failed to reach field in 10 tries!`nMaxAllowedPlanters has been reduced.")
								MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
								GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
								IniWrite, %MaxAllowedPlanters%, settings\nm_config.ini, gui, MaxAllowedPlanters
								return
							}
						} else if(success=0){ ;cannot find planter
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
							{
								nm_endWalk()
								break
							}
						;msgbox cannot find planter, trying another one
							success:=ba_placePlanter(nextField, nextPlanter, planterNum, 1)
							goto s3bypass
						}
					}
				} else {
					break
				}
				;maximum planters have been placed. leave function
				if(plantersplaced=maxplanters || plantersplaced>=MaxAllowedPlanters)
					return
			}
		} else {
			break
		}
	}
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
			PixelSearch, bx2, by2, 0, 30, 860, 150, %nectarColor%,0, Fast
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
	
	if (atField = 0)
	{
		nm_Reset()
		nm_setStatus("Traveling", (planter[1] . " (" . fieldName . ")"))
		nm_gotoPlanter(fieldName, 0)
	}
	
	WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
	WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
	
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 1) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		MouseMove, 30, 120
		Click
		MouseMove, 350, 100
		sleep, 400
	}
	MouseMove, 30, 200, 5
	
	planterName := planter[1]
	found := 0
	Loop, 70
	{
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
		
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
					break 2
				}				
				else
				{
					Sleep, 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
				}				
			}
		}
		
		if (Gdip_ImageSearch(pBMScreen, bitmaps[planterName], planterPos, , , , , 10, , 5) = 1) {
			found:=1
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		
		switch A_Index
		{
			case 5:
			Loop, 100 ; scroll all the way down on 5th search
			{
				MouseMove, 30, 200, 5
				sendinput {WheelDown}
				Sleep, 50
			}
			
			default:
			MouseMove, 30, 200, 5
			sendinput {WheelUp}
			Sleep, 50
		}
		Sleep, 400 ; wait for scroll to finish
	}
	
	if (found = 0) ; planter not in inventory
	{
		nm_setStatus("Missing", planterName)
		LostPlanters.=planterName
		ba_saveConfig_()
		return 0
	}
	else
		MouseMove, 30, SubStr(planterPos, InStr(planterPos, ",")+1)+190
	
	KeyWait, F14, T120 L ; wait for gotoPlanter finish
	nm_endWalk()
	
	nm_setStatus("Placing", planterName)
	Loop, 10
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|" windowWidth//2 "|" Min(480, windowWidth-150))
		if ((Gdip_ImageSearch(pBMScreen, bitmaps[planterName], planterPos, 0, 0, 306, Min(480, windowWidth-150), 10, , 5) = 0) || (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], , windowWidth//2-250, , , , 2, , 2) = 1)) {
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		
		MouseClickDrag, Left, 30, SubStr(planterPos, InStr(planterPos, ",")+1)+190, windowWidth//2, windowHeight//2, 5
		sleep, 200
	}
	Loop, 50
	{
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-250 "|500|500")
		if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 5, , 2) = 1) {
			MouseMove, windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowHeight//2-250+SubStr(pos, InStr(pos, ",")+1)
			loop 3 {
				Click
				sleep 100
			}
			MouseMove, 350, 100
			Gdip_DisposeImage(pBMScreen)
			break
		}
		Gdip_DisposeImage(pBMScreen)
		
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
			GuiControl,chooseString,MaxAllowedPlanters,%MaxAllowedPlanters%
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
	global PlanterName1, PlanterName2, PlanterName3, PlanterField1, PlanterField2, PlanterField3, PlanterHarvestTime1, PlanterHarvestTime2, PlanterHarvestTime3, PlanterNectar1, PlanterNectar2, PlanterNectar3, PlanterEstPercent1, PlanterEstPercent2, PlanterEstPercent3, BackKey, RightKey, MovespeedFactor, objective, TotalPlantersCollected, SessionPlantersCollected, HarvestFullGrown, bitmaps
	
	if(CurrentAction!="Planters"){
		PreviousAction:=CurrentAction
		CurrentAction:="Planters"
	}
	
	nm_setShiftLock(0)
	nm_Reset()
	planterName:=PlanterName%planterNum%
	fieldName:=PlanterField%planterNum%
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
		WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		
		Loop, 10
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, bitmaps["itemmenu"], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, 30, 120
			Click
			MouseMove, 350, 100
			sleep, 400
		}
		MouseMove, 30, 200, 5
	
		found := 0
		Loop, 70
		{
			WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
			
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
						break 2
					}				
					else
					{
						Sleep, 50
						Gdip_DisposeImage(pBMScreen)
						pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+150 "|306|" Min(480, windowWidth-150))
					}				
				}
			}
		
			if (Gdip_ImageSearch(pBMScreen, bitmaps[planterName], , , , , , 10, , 5) = 1) {
				found := 1
				Gdip_DisposeImage(pBMScreen)
				break
			}
			Gdip_DisposeImage(pBMScreen)
			
			switch A_Index
			{
				case 5:
				Loop, 100 ; scroll all the way down on 5th search
				{
					MouseMove, 30, 200, 5
					sendinput {WheelDown}
					Sleep, 50
				}
				
				default:
				MouseMove, 30, 200, 5
				sendinput {WheelUp}
				Sleep, 50
			}
			Sleep, 400 ; wait for scroll to finish
		}
	
		if (found = 1) { ; found planter in inventory planter is a phantom
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
		}
		
		return found
	}
	else {
        sendinput {e down}
		Sleep, 100
		sendinput {e up}
		
		Loop, 50
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
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
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "Roblox ahk_exe RobloxPlayerBeta.exe")
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2-250 "|" windowY+windowHeight//2-250 "|500|500")
		if (HarvestFullGrown = 1) {
			if (Gdip_ImageSearch(pBMScreen, bitmaps["no"], pos, , , , , 5, , 3) = 1) {
				MouseMove, windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowHeight//2-250+SubStr(pos, InStr(pos, ",")+1)
				loop 3 {
					Click
					sleep 100
				}
				MouseMove, 350, 100
				PlanterHarvestTime%planterNum%:=nowUnix()+10*60
				IniWrite, % PlanterHarvestTime%planterNum%, settings\nm_config.ini, Planters, PlanterHarvestTime%planterNum%
				return 1
			}
		}
		else {
			if (Gdip_ImageSearch(pBMScreen, bitmaps["yes"], pos, , , , , 5, , 2) = 1) {
				MouseMove, windowWidth//2-250+SubStr(pos, 1, InStr(pos, ",")-1), windowHeight//2-250+SubStr(pos, InStr(pos, ",")+1)
				loop 3 {
					Click
					sleep 100
				}
				MouseMove, 350, 100
			}
		}
		Gdip_DisposeImage(pBMScreen)
		
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
		nm_setStatus("Looting", planterName . " Loot")
		sleep, 1000
		nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
		nm_loot(9, 5, "left")
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
		if(not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < 20211106000000)
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
		run, "%A_AhkPath%" "submacros\PlanterTimers.ahk" "%hwndstate%"
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
Prev_DetectHiddenWindows := A_DetectHiddenWindows
Prev_TitleMatchMode := A_TitleMatchMode
DetectHiddenWindows On
SetTitleMatchMode 2
WinGet, script_list, List, ahk_class AutoHotkey
Loop %script_list%
	if ((script_hwnd := script_list%A_Index%) != A_ScriptHwnd)
		WinClose, ahk_id %script_hwnd%
Gdip_Shutdown(pToken)
}

GuiClose:
ExitApp
return

StartBackground:
settimer, Background, 2000
bg:=1
Background:
if(bg)
	bg:=0
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
bg:=1
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HOTKEYS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\
;START MACRO
f1::
nm_createStatusUpdater()
ControlFocus
SetKeyDelay, 100+KeyDelay
send ^{Alt}
nm_setStatus("Begin", "Macro")
Sleep, 100
if !WinExist("Roblox ahk_exe RobloxPlayerBeta.exe")
	disconnectCheck()
WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
nm_setShiftLock(0)
MouseMove, 350, 100
;set stats
MacroRunning:=1
MacroStartTime:=nowUnix()
global PausedRuntime:=0
;lock tabs
nm_TabGatherLock()
nm_TabCollectLock()
nm_TabBoostLock()
nm_TabPlantersPlusLock()
nm_TabSettingsLock()
GuiControl, show, LockedText
;set globals
nm_setStatus("Startup", "Setting Globals")
global SessionRuntime:=0
global SessionGatherTime:=0
global SessionConvertTime:=0
global SessionViciousKills:=0
global SessionBossKills:=0
global SessionBugKills:=0
global SessionPlantersCollected:=0
global SessionQuestsComplete:=0
global SessionDisconnects:=0
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
;set ActiveHotkeys[]
global ActiveHotkeys:=[]
;set hotbar values for actions handled by nm_hotbar()
whileNames:=["Always", "Attacking", "Gathering", "At Hive", "GatherStart"]
for key, val in whileNames {
	loop 6 {
		slot:=A_Index+1
		if(HotkeyWhile%slot%=val) {
			;calculate seconds
			if(HotkeyTimeUnits%slot%="Mins"){
				HBSecs:=HotkeyTime%slot%*60
			} else {
				HBSecs:=HotkeyTime%slot%
			}
			;set array values
			last:=LastHotkey%slot%
			ActiveHotkeys.push([val, slot, HBSecs, last])
			;temp:=HotkeyTime%slot%
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
	if(HotkeyWhile%slot%="Microconverter") {
		MicroConverterKey:=slot
		break
	}
}
;WhirligigKey
global WhirligigKey
WhirligigKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotkeyWhile%slot%="Whirligig") {
		WhirligigKey:=slot
		break
	}
}
;EnzymesKey
global EnzymesKey
EnzymesKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotkeyWhile%slot%="Enzymes") {
		EnzymesKey:=slot
		break
	}
}
;GlitterKey
global GlitterKey
GlitterKey:="None"
loop 6 {
	slot:=A_Index+1
	if(HotkeyWhile%slot%="Glitter") {
		GlitterKey:=slot
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
	if(ForceStart!=1){
		msgbox, 257, WARNING!!,"Automatic Field Boost" is ACTIVATED.`n------------------------------------------------------------------------------------`nIf you continue the following quantity of items can be used:`nDice: %futureDice%`nGlitter: %futureGlitter%`n`nHIGHLY RECOMMENDED:`nDisable any non-essential tasks such as quests, bug runs, stingers, etc. Any time away from your gathering field can result in the loss of your field boost.
		IfMsgBox Ok
		{} else {
			return
		}
	}
}
;start ancillary macros
run, "%A_AhkPath%" "submacros\background.ahk"
;(re)start stat monitor ~ moved from previous position (around line 1464) to avoid duplicate startup reports
;myOS:=SubStr(A_OSVersion, 1 , InStr(A_OSVersion, ".")-1)
;if((myOS*1)>=10) { ~ new StatMonitors do not require win10 or above
if (WebhookCheck && RegExMatch(webhook, "i)^https:\/\/(canary\.|ptb\.)?(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$")) { ; ~ changed RegEx
	run, "%A_AhkPath%" "submacros\StatMonitor.ahk"
}
;sendMessage commands
if WinExist("background.ahk ahk_class AutoHotkey") {
	PostMessage, 0x5554, 4, StingerCheck
}
;start main loop
nm_setStatus(0, "Main Loop")
nm_Start()
return
;STOP MACRO
f3::
Hotkey, F2, Off
Hotkey, F2, Off
Hotkey, F1, Off
nm_endWalk() ; ~ end walk script
sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{space up}
click, up
;nm_releaseKeys()
if(MacroRunning) {
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
MacroRunning:=0
IniWrite, %TotalRuntime%, settings\nm_config.ini, Status, TotalRuntime
IniWrite, %SessionRuntime%, settings\nm_config.ini, Status, SessionRuntime
IniWrite, %TotalGatherTime%, settings\nm_config.ini, Status, TotalGatherTime
IniWrite, %SessionGatherTime%, settings\nm_config.ini, Status, SessionGatherTime
IniWrite, %TotalConvertTime%, settings\nm_config.ini, Status, TotalConvertTime
IniWrite, %SessionConvertTime%, settings\nm_config.ini, Status, SessionConvertTime
nm_setStatus("End", "Macro")
DetectHiddenWindows, On
SetTitleMatchMode, 2
WinClose % "ahk_class AutoHotkey ahk_pid " StatusPID
WinClose, StatMonitor.ahk ahk_class AutoHotkey
getout()
Reload
Sleep, 10000
return
;PAUSE MACRO
f2::
if(state="startup")
	return
WinActivate, Roblox ahk_exe RobloxPlayerBeta.exe
Prev_DetectHiddenWindows := A_DetectHiddenWindows
Prev_TitleMatchMode := A_TitleMatchMode
DetectHiddenWindows, On
SetTitleMatchMode, 2
if(A_IsPaused) {
	if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
		Send {F16} ; ~ unpause walk script
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
			sendinput {space down}
	}
	nm_setStatus(PauseState, PauseObjective)
	MacroRunning:=1
	youDied:=0
	;nm_sendHeartbeat(0)
	;manage runtimes
	MacroStartTime:=nowUnix()
	GatherStartTime:=nowUnix()
} else {
	if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
		Send {F16} ; ~ pause walk script
	else
	{
		FwdKeyState:=GetKeyState(FwdKey), BackKeyState:=GetKeyState(BackKey), LeftKeyState:=GetKeyState(LeftKey), RightKeyState:=GetKeyState(RightKey), SpaceKeyState:=GetKeyState(Space)
		sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{space up}
		click, up
	}
	
	MacroRunning:=0
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
	;nm_sendHeartbeat(1)
	nm_setStatus("Paused", "Press F2 to Continue")
}
DetectHiddenWindows, %Prev_DetectHiddenWindows%
SetTitleMatchMode, %Prev_TitleMatchMode%
Pause, Toggle, 1
return
f4::
toggle := !toggle
while ((ClickMode || (A_Index <= ClickCount)) && toggle) {
	click
	sleep %ClickDelay%
}
toggle := 0
return

nm_WM_COPYDATA(wParam, lParam){
	global LastGuid, PMondoGuid, MondoAction, MondoBuffCheck, currentWalk, FwdKey, BackKey, LeftKey, RightKey
	StringAddress := NumGet(lParam + 2*A_PtrSize)  ; Retrieves the CopyDataStruct's lpData member.
    StringText := StrGet(StringAddress)  ; Copy the string out of the structure.
	if(wParam=1){ ;guiding star detected
		nm_setStatus("Detected", "Guiding Star in " . StringText)
		;pause
		Prev_DetectHiddenWindows := A_DetectHiddenWindows
		DetectHiddenWindows, On
		if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
			Send {F16} ; ~ pause walk script
		else
		{
			FwdKeyState:=GetKeyState(FwdKey)
			BackKeyState:=GetKeyState(BackKey)
			LeftKeyState:=GetKeyState(LeftKey)
			RightKeyState:=GetKeyState(RightKey)
			SpaceKeyState:=GetKeyState(Space)
			PauseState:=state
			PauseObjective:=objective
			sendinput {%FwdKey% up}{%BackKey% up}{%LeftKey% up}{%RightKey% up}{space up}
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
			return 0 ; ~ return integer for OnMessage
		} else {
			if WinExist("ahk_class AutoHotkey ahk_pid " currentWalk["pid"])
				Send {F16} ; ~ unpause walk script
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
					sendinput {space down}
			}
		}
		DetectHiddenWindows, %Prev_DetectHiddenWindows%
	}
	else {
		InStr(StringText, ": ") ? nm_setStatus(SubStr(StringText, 1, InStr(StringText, ": ")-1), SubStr(StringText, InStr(StringText, ": ")+2)) : nm_setStatus(StringText)
	}
	return 0
}
nm_ForceStart(){
	Critical
	global ForceStart := 1
	SetTimer, f1, -2000
	return 0
}
nm_setLastHeartbeat(){
	Critical
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
	if WinExist("background.ahk ahk_class AutoHotkey") {
		PostMessage, 0x5554, 7, nowUnix()
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