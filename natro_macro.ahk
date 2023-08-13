#NoEnv
#SingleInstance force
SetBatchLines -1
#MaxThreads 255
#include lib\Gdip_All.ahk
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONFIG FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if(not fileexist("nm_config.ini"))
	nm_resetConfig()
VersionID:="0.6.3"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NATRO ENHANCEMENT STUFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if(not fileexist("ba_config.ini"))
	ba_resetConfig()
IniRead TimersOpen, ba_config.ini, gui, TimersOpen
if(TimersOpen)
    run, PlanterTimers.ahk
global EnablePlantersPlus:=0
global statuslog:="Status Log:"
;global resetTime:=toUnix_()
;global Roblox:=0
global Enabled:=0
global Disabled:=0
global NPreset:="Custom"
global MaxAllowedPlanters:=1
global HiveDistance:=450
global MoveSpeedFactor:=1
global MoveSpeedFactorNum:=1
global MoveSpeed
global MoveSpeedNum
global DayOrNight:=Day
global disableDayorNight:=0
;global StingerCheck:=0
global StatusLogReverse:=0
global FieldDriftCompensation:=0
global FDCMoveDirFB=None
global FDCMoveDirLR=None
global FDCMoveDurFB=0
global FDCMoveDurLR=0
global AltPineStart=0
;global AutoFieldBoostButton
;global FieldLastBoostedBy:=none
;global AFBrollingDice:=0
;global AFBuseGlitter:=0
;global AFBdiceUsed:=0
;global AFBglitterUsed:=0
;global FieldBoostStacks:=0
;global FieldBooster:=FieldBooster:={"pine tree":{booster:"b", stacks:1}, "bamboo":{booster:"b", stacks:1}, "blue flower":{booster:"b", stacks:3}, "rose":{booster:"r", stacks:1}, "strawberry":{booster:"r", stacks:1}, "mushroom":{booster:"r", stacks:3}, "sunflower":{booster:"m", stacks:3}, "dandelion":{booster:"m", stacks:3}, "spider":{booster:"m", stacks:2}, "clover":{booster:"m", stacks:2}, "pineapple":{booster:"m", stacks:2}, "pumpkin":{booster:"m", stacks:1}, "cactus":{booster:"m", stacks:1}, "stump":{booster:"none", stacks:0}, "mountain top":{booster:"none", stacks:0}, "coconut":{booster:"none", stacks:0}, "pepper":{booster:"none", stacks:0}}
global VBState:=0
global n1priority:=None
global n2priority:=None
global n3priority:=None
global n4priority:=None
global n5priority:=None
global n1string:="||None"
global n2string:="||None"
global n3string:="||None"
global n4string:="||None"
global n5string:="||None"
global n1minPercent:=0
global n2minPercent:=0
global n3minPercent:=0
global n4minPercent:=0
global n5minPercent:=0
global HarvestInterval:=1
global AutomaticHarvestInterval:=0
global AutoText:="[Auto]"
global FullText:="[Full]"
global HarvestFullGrown:=0
global GotoPlanterField:=0
global HarvestIntervalNum:=1
global PlasticPlanterCheck:=0
global CandyPlanterCheck:=0
global BlueClayPlanterCheck:=0
global RedClayPlanterCheck:=0
global TackyPlanterCheck:=0
global PesticidePlanterCheck:=0
global PetalPlanterCheck:=0
global PaperPlanterCheck:=0
global TicketPlanterCheck:=0
global PlanterOfPlentyCheck:=0
global BambooFieldCheck=0
global BlueFlowerFieldCheck=0
global CactusFieldCheck=0
global CloverFieldCheck=0
global CoconutFieldCheck=0
global DandelionFieldCheck=0
global MountainTopFieldCheck=0
global MushroomFieldCheck=0
global PepperFieldCheck=0
global PineTreeFieldCheck=0
global PineappleFieldCheck=0
global PumpkinFieldCheck=0
global RoseFieldCheck=0
global SpiderFieldCheck=0
global StrawberryFieldCheck=0
global StumpFieldCheck=0
global SunflowerFieldCheck=0
global ComfortingFields:=[]
global RefreshingFields:=[]
global SatisfyingFields:=[]
global MotivatingFields:=[]
global InvigoratingFields:=[]
global LastComfortingField:=none
global LastRefreshingField:=none
global LastSatisfyingField:=none
global LastMotivatingField:=none
global LastInvigoratingField:=none
global LostPlanters:=""
global QuestFields:=""
global BambooPlanters:=[]
global BlueFlowerPlanters:=[]
global CactusPlanters:=[]
global CloverPlanters:=[]
global CoconutPlanters:=[]
global DandelionPlanters:=[]
global MountainTopPlanters:=[]
global MushroomPlanters:=[]
global PepperPlanters:=[]
global PineTreePlanters:=[]
global PineapplePlanters:=[]
global PumpkinPlanters:=[]
global RosePlanters:=[]
global SpiderPlanters:=[]
global StrawberryPlanters:=[]
global StumpPlanters:=[]
global SunflowerPlanters:=[]
global PlanterName1=None
global PlanterName2=None
global PlanterName3=None
global PlanterField1=None
global PlanterField2=None
global PlanterField3=None
global PlanterHarvestTime1=20211106000000
global PlanterHarvestTime2=20211106000000
global PlanterHarvestTime3=20211106000000
global PlanterNectar1=None
global PlanterNectar2=None
global PlanterNectar3=None
global PlanterEstPercent1=0
global PlanterEstPercent2=0
global PlanterEstPercent3=0
global nectarnames:=["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
global planternames:=["PlasticPlanter", "CandyPlanter", "BlueClayPlanter", "RedClayPlanter", "TackyPlanter", "PesticidePlanter", "PetalPlanter", "PlanterOfPlenty", "PaperPlanter", "TicketPlanter"]
global fieldnames:=["dandelion", "sunflower", "mushroom", "blueflower", "clover", "strawberry", "spider", "bamboo", "pineapple", "stump", "cactus", "pumpkin", "pinetree", "rose", "mountaintop", "pepper", "coconut"]
Guicontrol,, SysTabControl321, Planters+
IniRead, nPreset, ba_config.ini, gui, nPreset
IniRead, n1priority, ba_config.ini, gui, n1priority
IniRead, n2priority, ba_config.ini, gui, n2priority
IniRead, n3priority, ba_config.ini, gui, n3priority
IniRead, n4priority, ba_config.ini, gui, n4priority
IniRead, n5priority, ba_config.ini, gui, n5priority
IniRead, n1string, ba_config.ini, gui, n1string
IniRead, n2string, ba_config.ini, gui, n2string
IniRead, n3string, ba_config.ini, gui, n3string
IniRead, n4string, ba_config.ini, gui, n4string
IniRead, n5string, ba_config.ini, gui, n5string
IniRead, n1minPercent, ba_config.ini, gui, n1minPercent
IniRead, n2minPercent, ba_config.ini, gui, n2minPercent
IniRead, n3minPercent, ba_config.ini, gui, n3minPercent
IniRead, n4minPercent, ba_config.ini, gui, n4minPercent
IniRead, n5minPercent, ba_config.ini, gui, n5minPercent
For key, value in planternames
{
	IniRead, %value%Check, ba_config.ini, gui, %value%Check
}
For key, value in nectarnames
{
	IniRead, %value%Fields, ba_config.ini, Planters, %value%Fields
	%value%Fields := StrSplit(%value%Fields , ", ")
	IniRead, Last%value%Field, ba_config.ini, Planters, Last%value%Field
}
For key, value in fieldnames
{
	;IniRead, %value%Planters, ba_config.ini, Planters, %value%Planters
	;%value%Planters := StrSplit(%value%Planters , ", ")
	IniRead, TempPlanters, ba_config.ini, Planters, %value%Planters
	;msgbox %TempPlanters%
	TempPlanters := StrSplit(TempPlanters , "; ")
	;MsgBox % TempPlanters[1]
	;MsgBox % TempPlanters.length()
	for i, val in TempPlanters {
		tempstring:=TempPlanters[A_Index]
		%value%Planters.InsertAt(A_Index, StrSplit(TempPlanters[A_Index], ", "))
	}
	IniRead, %value%FieldCheck, ba_config.ini, gui, %value%FieldCheck
}
loop, 3 {
	IniRead, PlanterName%A_Index%, ba_config.ini, Planters, PlanterName%A_Index%
	IniRead, PlanterField%A_Index%, ba_config.ini, Planters, PlanterField%A_Index%
	IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
	IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
	IniRead, PlanterEstPercent%A_Index%, ba_config.ini, Planters, PlanterEstPercent%A_Index%
}
IniRead, EnablePlantersPlus, ba_config.ini, gui, EnablePlantersPlus
IniRead, MaxAllowedPlanters, ba_config.ini, gui, MaxAllowedPlanters
IniRead, HarvestInterval, ba_config.ini, gui, HarvestInterval
IniRead, AutomaticHarvestInterval, ba_config.ini, gui, AutomaticHarvestInterval
IniRead, HarvestFullGrown, ba_config.ini, gui, HarvestFullGrown
IniRead, GotoPlanterField, ba_config.ini, gui, GotoPlanterField
IniRead, HiveDistance, ba_config.ini, gui, HiveDistance
;IniRead, MoveSpeedFactorNum, ba_config.ini, gui, MoveSpeedFactor
;IniRead, MoveSpeedFactor, ba_config.ini, gui, MoveSpeedFactor
IniRead, MoveSpeedNum, ba_config.ini, gui, MoveSpeed
;IniRead, StingerCheck, ba_config.ini, gui, StingerCheck
IniRead, StatusLogReverse, ba_config.ini, gui, StatusLogReverse
IniRead, FieldDriftCompensation, ba_config.ini, gui, FieldDriftCompensation
IniRead, FDCMoveDirFB, ba_config.ini, gui, FDCMoveDirFB
IniRead, FDCMoveDirLR, ba_config.ini, gui, FDCMoveDirLR
IniRead, FDCMoveDurFB, ba_config.ini, gui, FDCMoveDurFB
IniRead, FDCMoveDurLR, ba_config.ini, gui, FDCMoveDurLR
IniRead, AltPineStart, ba_config.ini, gui, AltPineStart
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; END NATRO ENHANCEMENT STUFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READ INI VALUES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global PolarBear:={"Aromatic Pie":[[3,"kill","mantis"],[4,"kill","ladybugs"],[1,"collect","rose"],[2,"collect","Pine Tree"]], "Beetle Brew":[[3,"kill", "ladybugs"],[4,"kill", "rhinobeetles"],[1,"collect","Pineapple"],[2,"collect","Dandelion"]], "Candied Beetles":[[3, "kill","rhinobeetles"],[1,"collect","Strawberry"],[2,"collect","Blue Flower"]], "Exotic Salad":[[1,"collect", "Cactus"],[2, "collect", "Rose"],[3,"collect","Blue Flower"],[4,"collect","Clover"]], "Extreme Stir-Fry":[[6,"kill","werewolf"],[5,"kill","scorpions"],[4,"kill","spider"],[1,"collect","Cactus"],[2,"collect","Bamboo"],[3,"collect","Dandelion"]], "High Protein":[[4,"kill","spider"],[3,"kill","scorpions"],[2,"kill","mantis"],[1,"collect","Sunflower"]], "Ladybug Poppers":[[2,"kill","ladybugs"],[1,"collect","Blue Flower"]], "Mantis Meatballs":[[2,"kill","mantis"],[1,"collect","Pine Tree"]], "Prickly Pears":[[1,"collect","Cactus"]], "Pumpkin Pie":[[3,"kill","mantis"],[1,"collect","Pumpkin"],[2,"collect","Sunflower"]], "Scorpion Salad":[[2,"kill","scorpions"],[1,"collect","Rose"]], "Spiced Kebab":[[3,"kill","werewolf"],[1,"collect","Clover"],[2,"collect","Bamboo"]], "Spider Pot-Pie":[[2,"kill","spider"],[1,"collect","Mushroom"]], "Spooky Stew":[[4,"kill","werewolf"],[3,"kill","spider"],[1,"collect","Spider"],[2,"collect","Mushroom"]], "Strawberry Skewers":[[3,"kill","scorpions"],[1,"collect","Strawberry"],[2,"collect","Bamboo"]], "Teriyaki Jerky":[[3,"kill","werewolf"],[1,"collect","Pineapple"],[2,"collect","Spider"]], "Thick Smoothie":[[1,"collect","Strawberry"],[2,"collect","Pumpkin"]], "Trail Mix":[[1,"collect","Sunflower"],[2,"collect","Pineapple"]]}
global BlackBear:={"Just White":[[1,"collect","white"]], "Just Red":[[1,"collect","red"]], "Just Blue":[[1,"collect","blue"]], "A Bit Of Both":[[1,"collect","red"],[2,"collect","blue"]], "Any Pollen":[[1,"collect","any"]], "The Whole Lot":[[1,"collect","red"],[2,"collect","blue"],[3,"collect","white"]], "Between The Bamboo":[[2,"collect","Bamboo"], [1,"collect","blue"]], "Play In The Pumpkins":[[2,"collect","Pumpkin"],[1,"collect","white"]], "Plundering Pineapples":[[2,"collect","Pineapple"],[1,"collect","any"]], "Stroll In The Strawberries":[[2, "collect", "Strawberry"],[1,"collect","red"]], "Mid-Level Mission":[[1,"collect","Spider"],[2, "collect","Strawberry"],[3,"collect","Bamboo"]], "Blue Flower Bliss":[[1,"collect","Blue Flower"]], "Delve Into Dandelions":[[1,"collect","Dandelion"]], "Fun In The Sunflowers":[[1,"collect","Sunflower"]], "Mission For Mushrooms":[[1,"collect","Mushroom"]], "Leisurely Lowlands":[[1,"collect","Sunflower"],[2,"collect","Dandelion"],[3,"collect","Mushroom"],[4,"collect","Blue Flower"]], "Triple Trek":[[1,"collect", "Mountain Top"],[2,"collect","Pepper"],[3,"collect","Coconut"]], "Pepper Patrol":[[1,"collect","Pepper"]]}
;global BlackBear:={"Just White":[[1,"collect","white"]], "Just Red":[[1,"collect","red"]], "Just Blue":[[1,"collect","Mountain Top"]], "A Bit Of Both":[[1,"collect","Mountain Top"],[2,"collect","Mountain Top"]], "Any Pollen":[[1,"collect","any"]], "The Whole Lot":[[1,"collect","Mountain Top"],[2,"collect","Mountain Top"],[3,"collect","white"]], "Between The Bamboo":[[2,"collect","Bamboo"], [1,"collect","Mountain Top"]], "Play In The Pumpkins":[[2,"collect","Pumpkin"],[1,"collect","white"]], "Plundering Pineapples":[[2,"collect","Pineapple"],[1,"collect","any"]], "Stroll In The Strawberries":[[2, "collect", "Strawberry"],[1,"collect","red"]], "Mid-Level Mission":[[1,"collect","Spider"],[2, "collect","Strawberry"],[3,"collect","Bamboo"]], "Blue Flower Bliss":[[1,"collect","Blue Flower"]], "Delve Into Dandelions":[[1,"collect","Dandelion"]], "Fun In The Sunflowers":[[1,"collect","Sunflower"]], "Mission For Mushrooms":[[1,"collect","Mushroom"]], "Leisurely Lowlands":[[1,"collect","Sunflower"],[2,"collect","Dandelion"],[3,"collect","Mushroom"],[4,"collect","Blue Flower"]], "Triple Trek":[[1,"collect", "Mountain Top"],[2,"collect","Pepper"],[3,"collect","Coconut"]], "Pepper Patrol":[[1,"collect","Pepper"]]}
global BuckoBee:={"Abilities":[[1,"Collect","Any"]], "Bamboo":[[1,"Collect","Bamboo"]], "Bombard":[[4,"Get","Ant"],[3,"Get","Ant"],[2,"Kill","RhinoBeetles"],[1,"Collect","Any"]], "Booster":[[2,"Get","BlueBoost"],[1,"Collect","Any"]], "Clean-Up":[[1,"Collect","Blue Flower"],[2,"Collect","Bamboo"],[3,"Collect","Pine Tree"]], "Extraction":[[1,"Collect","Clover"],[2,"Collect","Cactus"],[3,"Collect","Pumpkin"]], "Flowers":[[1,"Collect","Blue Flower"]], "Goo":[[1,"Collect","Blue"]], "Medley":[[2,"Collect","Bamboo"],[3,"Collect","Pine Tree"],[1,"Collect","Any"]], "Picnic":[[5, "Get", "Ant"],[4,"Get","Ant"],[3,"Feed","Blueberry"],[1,"Collect","Blue Flower"],[2,"Collect","Blue"]], "Pine Trees":[[1, "Collect", "Pine Tree"]], "Pollen":[[1,"Collect","Blue"]], "Scavenge":[[1,"Collect","Blue"],[3,"Collect","Blue"],[2,"Collect","Any"]], "Skirmish":[[2,"Kill","RhinoBeetles"],[1,"Collect","Blue Flower"]], "Tango":[[3,"Kill","Mantis"],[1,"Collect","Blue"],[2,"Collect","Any"]], "Tour":[[5,"Kill","Mantis"],[4,"Kill","RhinoBeetles"],[1,"Collect","Blue Flower"],[2,"Collect","Bamboo"],[3,"Collect","Pine Tree"]]}
global RileyBee:={"Abilities":[[1,"Collect","Any"]], "Booster":[[2,"Get","RedBoost"],[1,"Collect","Any"]], "Clean-Up":[[1,"Collect","Mushroom"],[2,"Collect","Strawberry"],[3,"Collect","Rose"]], "Extraction":[[1,"Collect","Clover"],[2,"Collect","Cactus"],[3,"Collect","Pumpkin"]], "Goo":[[1,"Collect","Red"]], "Medley":[[2,"Collect","Strawberry"],[3,"Collect","Rose"],[1,"Collect","Any"]], "Mushrooms":[[1,"collect","Mushroom"]], "Picnic":[[4,"Get","Ant"],[3,"Feed","Strawberry"],[1,"Collect","Mushroom"],[2,"Collect","Red"]], "Pollen":[[1,"Collect","Red"]], "Rampage":[[3,"Get","Ant"],[2,"kill","Ladybugs"],[1,"Kill","All"]], "Roses":[[1,"Collect","Rose"]], "Scavenge":[[1,"Collect","Red"],[3,"Collect","Red"],[2,"Collect","Any"]], "Skirmish":[[2,"Kill","Ladybugs"],[1,"Collect","Mushroom"]], "Strawberries":[[1,"Collect","Strawberry"]], "Tango":[[3,"Kill","Scorpions"],[1,"Collect","Red"],[2,"Collect","Any"]], "Tour":[[5,"Kill","Scorpions"],[4,"Kill","Ladybugs"],[1,"Collect","Mushroom"],[2,"Collect","Strawberry"],[3,"Collect","Rose"]]}
;key:="Aromatic Pie"
;msgbox % PolarBear["Aromatic Pie"][1][2]
global FieldBooster:={"pine tree":{booster:"blue", stacks:1}, "bamboo":{booster:"blue", stacks:1}, "blue flower":{booster:"blue", stacks:3}, "rose":{booster:"red", stacks:1}, "strawberry":{booster:"red", stacks:1}, "mushroom":{booster:"red", stacks:3}, "sunflower":{booster:"mountain", stacks:3}, "dandelion":{booster:"mountain", stacks:3}, "spider":{booster:"mountain", stacks:2}, "clover":{booster:"mountain", stacks:2}, "pineapple":{booster:"mountain", stacks:2}, "pumpkin":{booster:"mountain", stacks:1}, "cactus":{booster:"mountain", stacks:1}, "stump":{booster:"none", stacks:0}, "mountain top":{booster:"none", stacks:0}, "coconut":{booster:"none", stacks:0}, "pepper":{booster:"none", stacks:0}}
global FieldDefault:={"Sunflower":{pattern:["Snake","M", 2],camera:["None",1],sprinkler:["Right",8]}, "Dandelion":{pattern:["Lines","M",2],camera:["None",1],sprinkler:["Upper Right",9]}, "Mushroom":{pattern:["Snake","M",1],camera:["None",1], sprinkler:["Right",10]}, "Blue Flower":{pattern:["Lines","M",2],camera:["None",1],sprinkler:["Center",1]}, "Clover":{pattern:["Lines","S",1],camera:["None",1],sprinkler:["Upper",10]}, "Spider":{pattern:["Lines","M",2],camera:["None",1],sprinkler:["Left",6]}, "Strawberry":{pattern:["Snake","S",2],camera:["Right",10],sprinkler:["Lower Left",2]}, "Bamboo":{pattern:["Lines","M",2],camera:["None",1],sprinkler:["Upper Left",3]}, "Pineapple":{pattern:["Snake","M",2],camera:["None",1],sprinkler:["Lower Right",2]}, "Stump":{pattern:["Stationary","S",1],camera:["Right",2],sprinkler:["Center",1]}, "Cactus":{pattern:["Squares","S",1],camera:["None",1],sprinkler:["Lower",5]}, "Pumpkin":{pattern:["Snake","M",2],camera:["None",1],sprinkler:["Right",7]},"Pine Tree":{pattern:["Snake","M",2],camera:["Left",2],sprinkler:["Upper",6]}, "Rose":{pattern:["Lines","M",2],camera:["None",1],sprinkler:["Upper Right",5]}, "Mountain Top":{pattern:["Snake","S",2],camera:["Right",2],sprinkler:["Right",5]}, "Coconut":{pattern:["Snake","M",2],camera:["None",1],sprinkler:["Right",10]}, "Pepper":{pattern:["Snake","M",2],camera:["None",1],sprinkler:["Right",6]}}
;msgbox % FieldDefault["sunflower"]["pattern"][1]
;msgbox % FieldDefault["blue flower"]["pattern"][1]
;global BambooPlanters:={"PetalPlanter":{nectar:1.5, speed:1.16, growth:12.12}, "PlentyPlanter":{nectar:1.5, speed:1, growth:16}, "BlueClayPlanter":{nectar:1.2, speed:1.17, growth:5.12}, "PesticidePlanter":{nectar:1, speed:1.3, growth:7.69}, "TackyPlanter":{nectar:1.25, speed:1, growth:8}, "PlasticPlanter":{nectar:1, speed:1, growth:2}, "CandyPlanter":{nectar:1, speed:1, growth:4}, "RedClayPlanter":{nectar:1, speed:1, growth:6}, "PaperPlanter":{nectar:.75, speed:1, growth:1}, "TicketPlanter":{nectar:2, speed:1, growth:2}}
;global BlueFlowerPlanters:={"PlentyPlanter":{nectar:1.5, speed:1, growth:16}, "BlueClayPlanter":{nectar:1.2, speed:1.17, growth:5.12}, "TackyPlanter":{nectar:1, speed:1.25, growth:6.4}, "PetalPlanter":{nectar:1, speed:1.16, growth:12.12}, "PlasticPlanter":{nectar:1, speed:1, growth:2}, "CandyPlanter":{nectar:1, speed:1, growth:4}, "RedClayPlanter":{nectar:1, speed:1, growth:6}, "PesticidePlanter":{nectar:1, speed:1, growth:10}, "PaperPlanter":{nectar:.75, speed:1, growth:1}, "TicketPlanter":{nectar:2, speed:1, growth:2}}
;for key, value in bambooplanters {
;	temp++
;}
;msgbox bambooplanters.length()=%temp%
global resetTime:=nowUnix()
global youDied:=0
global state
global objective
global WindowedScreen:=0
global AFBrollingDice:=0
global AFBuseGlitter:=0
global AFBuseBooster:=0
global FieldLastBoostedBy:="None"
global MacroRunning:=0
global MacroStartTime:=nowUnix()
;global delta:=0
global SessionRuntime:=0
global PausedRuntime:=0
state:="Startup"
objective:="UI"
IniRead, GuiTheme, nm_config.ini, Settings, GuiTheme
IniRead, GuiTransparency, nm_config.ini, Settings, GuiTransparency
IniRead, AlwaysOnTop, nm_config.ini, Settings, AlwaysOnTop
IniRead, GuiX, nm_config.ini, Settings, GuiX
IniRead, GuiY, nm_config.ini, Settings, GuiY
IniRead, MoveSpeedFactor, nm_config.ini, Settings, MoveSpeedFactor
;ensure Gui will be visible
SysGet, MonNum, MonitorCount
loop %MonNum% {
	if(!GuiX || !GuiY) {
		guiX:=0
		guiY:=0
		break
	}
	SysGet, Mon, Monitor, %A_Index%
	if(GuiX>MonLeft && GuiX<MonRight && GuiY>MonTop && GuiY<MonBottom) {
		break
	}
	if(A_Index=MonNum) {
		guiX:=0
		guiY:=0
		break
	}
}
loop 3 {
	IniRead, FieldName%A_Index%, nm_config.ini, Gather, FieldName%A_Index%
	IniRead, FieldPattern%A_Index%, nm_config.ini, Gather, FieldPattern%A_Index%
	IniRead, FieldPatternSize%A_Index%, nm_config.ini, Gather, FieldPatternSize%A_Index%
	IniRead, FieldPatternReps%A_Index%, nm_config.ini, Gather, FieldPatternReps%A_Index%
	IniRead, FieldPatternShift%A_Index%, nm_config.ini, Gather, FieldPatternShift%A_Index%
	IniRead, FieldUntilMins%A_Index%, nm_config.ini, Gather, FieldUntilMins%A_Index%
	IniRead, FieldUntilPack%A_Index%, nm_config.ini, Gather, FieldUntilPack%A_Index%
	IniRead, FieldReturnType%A_Index%, nm_config.ini, Gather, FieldReturnType%A_Index%
	IniRead, FieldSprinklerLoc%A_Index%, nm_config.ini, Gather, FieldSprinklerLoc%A_Index%
	IniRead, FieldSprinklerDist%A_Index%, nm_config.ini, Gather, FieldSprinklerDist%A_Index%
	IniRead, FieldRotateDirection%A_Index%, nm_config.ini, Gather, FieldRotateDirection%A_Index%
	IniRead, FieldRotateTimes%A_Index%, nm_config.ini, Gather, FieldRotateTimes%A_Index%
	IniRead, FieldDriftCheck%A_Index%, nm_config.ini, Gather, FieldDriftCheck%A_Index%
}
IniRead, CurrentFieldNum, nm_config.ini, Gather, CurrentFieldNum
IniRead, MoveMethod, nm_config.ini, Settings, MoveMethod
IniRead, SprinklerType, nm_config.ini, Settings, SprinklerType
IniRead, ConvertBalloon, nm_config.ini, Settings, ConvertBalloon
IniRead, ConvertMins, nm_config.ini, Settings, ConvertMins
IniRead, PrivServer, nm_config.ini, Settings, PrivServer
IniRead, ReloadRobloxSecs, nm_config.ini, Settings, ReloadRobloxSecs
;set initial windowed mode
global Roblox:=[]
WinActivate, Roblox
Roblox:=nm_imgSearch("roblox2.png",10,"buff")
If(Roblox[3]>30)
	WindowedScreen:=1
else
	WindowedScreen:=0
global PackFilterArray:=[]
global BackpackPercentFiltered
global ActiveHotkeys:=[]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CREATE GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Menu, tray, Icon, auryn.ico, 1, 1
;https://www.autohotkey.com/boards/viewtopic.php?f=6&t=5841&hilit=gui+skin
SkinForm(Apply, A_ScriptDir . "\styles\USkin.dll", A_ScriptDir . "\styles\" . GuiTheme . ".msstyles")
OnExit, GetOut
gui, destroy
if (AlwaysOnTop)
	gui +AlwaysOnTop
gui +border
CurrentField:=FieldName%CurrentFieldNum%
Gui, Font, w700
Gui, Add, Text, x5 y240 w50 +left +BackgroundTrans,CurrentField:
Gui, Add, Text, x175 y240 w30 +left +BackgroundTrans,Status:
Gui, Font
Gui, Add, Button, x77 y240 w10 h15 gnm_currentFieldUp, <
Gui, Add, Button, x157 y240 w10 h15 gnm_currentFieldDown, >
Gui, Add, Text, x87 y240 w70 +left +BackgroundTrans +border vCurrentField,%CurrentField%
Gui, Add, Text, x215 y240 w280 +left +BackgroundTrans vstate +border, %state%
;Gui, Add, Text, x140 y270 w200 +left +BackgroundTrans vobjective,
;Gui, Add, Text, x300 y270 w200 +left +BackgroundTrans +border vpp, <no data>
;Gui, Add, Text, x5 y285 w100 +left +BackgroundTrans vtimeofDay, Day
;Gui, Add, Text, x40 y285 w100 +left +BackgroundTrans vVBState, -1
Gui, Font, s12 w700 Underline cBlue
Gui, Add, Text, x432 y255 gDonateLink, Donate
Gui, Font
Gui, Add, Text, x442 y280, Ver. %versionID%
;control buttons
Gui, Add, Button, x10 y275 w60 h20 gf1, Start (F1)
Gui, Add, Button, x75 y275 w60 h20 gf3, Stop (F3)
Gui, Add, Button, x140 y275 w60 h20 gf2, Pause (F2)
;gui mode
IniRead, GuiMode, nm_config.ini, Settings, GuiMode
if(GuiMode)
	buttonText:=("Current Mode:`nADVANCED")
else if(not AutoFieldBoostActive)
	buttonText:=("EASY MODE")
Gui, Add, Button, x320 y260 w100 h30 vGuiModeButton gnm_guiModeButton, %buttonText%

;ADD TABS
Gui, Add, Tab, x1 y-1 w550 h240 vTab gnm_TabSelect, Gather|Collect/Kill|Boost|Quest|Planters+|Status|Settings|Contributors
GuiControl,focus, Tab
Gui, Add, Text, x15 y260 cRED +BackgroundTrans vLockedText, Tabs Locked While Running, F3 to Unlock
Gui, Font, w700
GuiControl, hide, LockedText
Gui, Add, Text, x40 y25 w100 +left +BackgroundTrans,Gathering
Gui, Add, Text, x180 y25 w100 +left +BackgroundTrans,Pattern
Gui, Add, Text, x280 y25 w100 +left +BackgroundTrans,Until
Gui, Add, Text, x430 y25 w100 +left +BackgroundTrans vSprinklerTitle,Sprinkler
Gui, Font
Gui, Add, Text, x30 y40 w100 +left +BackgroundTrans,Field Rotation
Gui, Add, Text, x111 y32 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y42 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y52 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y62 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y72 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y82 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y92 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y102 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y112 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y122 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y132 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y142 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y152 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y162 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y172 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y182 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y192 w100 +left +BackgroundTrans,!
Gui, Add, Text, x111 y202 w100 +left +BackgroundTrans,!
Gui, Add, Text, x125 y40 w100 +left +BackgroundTrans,Shape
Gui, Add, Text, x180 y40 w100 +left +BackgroundTrans,Length
Gui, Add, Text, x225 y40 w100 +left +BackgroundTrans vpatternRepsHeader,Width
Gui, Add, Text, x261 y32 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y42 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y52 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y62 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y72 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y82 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y92 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y102 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y112 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y122 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y132 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y142 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y152 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y162 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y172 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y182 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y192 w100 +left +BackgroundTrans,!
Gui, Add, Text, x261 y202 w100 +left +BackgroundTrans,!
Gui, Add, Text, x270 y40 w100 +left +BackgroundTrans,Mins
Gui, Add, Text, x305 y40 w100 +left +BackgroundTrans vuntilPackHeader,Pack`%
Gui, Add, Text, x350 y40 w100 +left +BackgroundTrans,To Hive By:
Gui, Add, Text, x410 y32 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y42 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y52 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y62 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y72 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y82 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y92 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y102 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y112 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y122 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y132 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y142 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y152 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y162 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y172 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y182 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y192 w100 +left +BackgroundTrans,!
Gui, Add, Text, x410 y202 w100 +left +BackgroundTrans,!
Gui, Add, Text, x420 y40 w100 +left +BackgroundTrans vsprinklerStartHeader,Start Location
Gui, Add, Text, x5 y42 w100 +left +BackgroundTrans,__________________________________________________________________________________
Gui, Add, Text, x20 y98 +left +BackgroundTrans,_______________________________________________________________________________
Gui, Add, Text, x20 y158 +left +BackgroundTrans,_______________________________________________________________________________
Gui, Add, Text, x20 y218 +left +BackgroundTrans,_______________________________________________________________________________
Gui, Font, w700
Gui, Add, Text, x5 y62 w10 +left +BackgroundTrans,1:
Gui, Add, Text, x5 y120 w10 +left +BackgroundTrans,2:
Gui, Add, Text, x5 y180 w10 +left +BackgroundTrans,3:
Gui, Font
Gui, Add, DropDownList, x18 y57 w90 vFieldName1 gnm_FieldSelect1, %FieldName1%||Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower
GuiControl, disable, FieldName1
Gui, Add, DropDownList, x18 y115 w90 vFieldName2 gnm_FieldSelect2, %FieldName2%||None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower
GuiControl, disable, FieldName2
Gui, Add, DropDownList, x18 y175 w90 vFieldName3 gnm_FieldSelect3, %FieldName3%||None|Bamboo|Blue Flower|Cactus|Clover|Coconut|Dandelion|Mountain Top|Mushroom|Pepper|Pine Tree|Pineapple|Pumpkin|Rose|Spider|Strawberry|Stump|Sunflower
GuiControl, disable, FieldName3
Gui, Add, DropDownList, x118 y57 w60 vFieldPattern1 gnm_SaveGather, %FieldPattern1%||Lines|Snake|Diamonds|Squares|Typewriter|Auryn|Stationary
GuiControl, disable, FieldPattern1
Gui, Add, DropDownList, x118 y115 w60 vFieldPattern2 gnm_SaveGather, %FieldPattern2%||Lines|Snake|Diamonds|Squares|Typewriter|Auryn|Stationary
GuiControl, disable, FieldPattern2
Gui, Add, DropDownList, x118 y175 w60 vFieldPattern3 gnm_SaveGather, %FieldPattern3%||Lines|Snake|Diamonds|Squares|Typewriter|Auryn|Stationary
GuiControl, disable, FieldPattern3
Gui, Add, DropDownList, x180 y57 w40 vFieldPatternSize1 gnm_SaveGather, %FieldPatternSize1%||XS|S|M|L|XL
GuiControl, disable, FieldPatternSize1
Gui, Add, DropDownList, x180 y115 w40 vFieldPatternSize2 gnm_SaveGather, %FieldPatternSize2%||XS|S|M|L|XL
GuiControl, disable, FieldPatternSize2
Gui, Add, DropDownList, x180 y175 w40 vFieldPatternSize3 gnm_SaveGather, %FieldPatternSize3%||XS|S|M|L|XL
GuiControl, disable, FieldPatternSize3
Gui, Add, DropDownList, x222 y57 w35 vFieldPatternReps1 gnm_SaveGather, %FieldPatternReps1%||1|2|3|4|5|6|7|8|9
GuiControl, disable, FieldPatternReps1
Gui, Add, DropDownList, x222 y115 w35 vFieldPatternReps2 gnm_SaveGather, %FieldPatternReps2%||1|2|3|4|5|6|7|8|9
GuiControl, disable, FieldPatternReps2
Gui, Add, DropDownList, x222 y175 w35 vFieldPatternReps3 gnm_SaveGather, %FieldPatternReps3%||1|2|3|4|5|6|7|8|9
GuiControl, disable, FieldPatternReps3
Gui, Add, Checkbox, x20 y80 +BackgroundTrans vFieldDriftCheck1 gnm_SaveGather Checked%FieldDriftCheck1%,Field Drift`nCompensation
GuiControl, disable, FieldDriftCheck1
Gui, Add, Checkbox, x20 y140 +BackgroundTrans vFieldDriftCheck2 gnm_SaveGather Checked%FieldDriftCheck2%,Field Drift`nCompensation
GuiControl, disable, FieldDriftCheck2
Gui, Add, Checkbox, x20 y200 +BackgroundTrans vFieldDriftCheck3 gnm_SaveGather Checked%FieldDriftCheck3%,Field Drift`nCompensation
GuiControl, disable, FieldDriftCheck3
Gui, Add, Checkbox, x115 y85 +BackgroundTrans vFieldPatternShift1 gnm_SaveGather Checked%FieldPatternShift1%, Gather w/Shift-Lock
GuiControl, disable, FieldPatternShift1
Gui, Add, Checkbox, x115 y145 +BackgroundTrans vFieldPatternShift2 gnm_SaveGather Checked%FieldPatternShift2%, Gather w/Shift-Lock
GuiControl, disable, FieldPatternShift2
Gui, Add, Checkbox, x115 y205 +BackgroundTrans vFieldPatternShift3 gnm_SaveGather Checked%FieldPatternShift3%, Gather w/Shift-Lock
GuiControl, disable, FieldPatternShift3
Gui, Add, Text, x235 y80 vrotateCam1, Before Gathering,`n    Rotate Camera:
Gui, Add, Text, x235 y140 vrotateCam2, Before Gathering,`n    Rotate Camera:
Gui, Add, Text, x235 y200 vrotateCam3, Before Gathering,`n    Rotate Camera:
Gui, Add, DropDownList, x325 y82 w50 vFieldRotateDirection1 gnm_SaveGather, %FieldRotateDirection1%||None|Left|Right
GuiControl, disable, FieldRotateDirection1
Gui, Add, DropDownList, x325 y142 w50 vFieldRotateDirection2 gnm_SaveGather, %FieldRotateDirection2%||None|Left|Right
GuiControl, disable, FieldRotateDirection2
Gui, Add, DropDownList, x325 y202 w50 vFieldRotateDirection3 gnm_SaveGather, %FieldRotateDirection3%||None|Left|Right
GuiControl, disable, FieldRotateDirection3
Gui, Add, DropDownList, x375 y82 w32 vFieldRotateTimes1 gnm_SaveGather, %FieldRotateTimes1%||1|2|3|4
GuiControl, disable, FieldRotateTimes1
Gui, Add, DropDownList, x375 y142 w32 vFieldRotateTimes2 gnm_SaveGather, %FieldRotateTimes2%||1|2|3|4
GuiControl, disable, FieldRotateTimes2
Gui, Add, DropDownList, x375 y202 w32 vFieldRotateTimes3 gnm_SaveGather, %FieldRotateTimes3%||1|2|3|4
GuiControl, disable, FieldRotateTimes3
;Gui, Add, Text, x410 y85 vrotateCamTimes1, times
;Gui, Add, Text, x410 y145 vrotateCamTimes2, times
;Gui, Add, Text, x410 y205 vrotateCamTimes3, times
Gui, Add, Edit, x268 y57 w30 h20 limit3 number vFieldUntilMins1 gnm_SaveGather, %FieldUntilMins1%
GuiControl, disable, FieldUntilMins1
Gui, Add, Edit, x268 y115 w30 h20 limit3 number vFieldUntilMins2 gnm_SaveGather, %FieldUntilMins2%
GuiControl, disable, FieldUntilMins2
Gui, Add, Edit, x268 y175 w30 h20 limit3 number vFieldUntilMins3 gnm_SaveGather, %FieldUntilMins3%
GuiControl, disable, FieldUntilMins3
Gui, Add, DropDownList, x300 y57 w45 vFieldUntilPack1 gnm_SaveGather, %FieldUntilPack1%||100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5
GuiControl, disable, FieldUntilPack1
Gui, Add, DropDownList, x300 y115 w45 vFieldUntilPack2 gnm_SaveGather, %FieldUntilPack2%||100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5
GuiControl, disable, FieldUntilPack2
Gui, Add, DropDownList, x300 y175 w45 vFieldUntilPack3 gnm_SaveGather, %FieldUntilPack3%||100|95|90|85|80|75|70|65|60|55|50|45|40|35|30|25|20|15|10|5
GuiControl, disable, FieldUntilPack3
Gui, Add, DropDownList, x347 y57 w60 vFieldReturnType1 gnm_SaveGather, %FieldReturnType1%||Walk|Reset|Rejoin
GuiControl, disable, FieldReturnType1
Gui, Add, DropDownList, x347 y115 w60 vFieldReturnType2 gnm_SaveGather, %FieldReturnType2%||Walk|Reset|Rejoin
GuiControl, disable, FieldReturnType2
Gui, Add, DropDownList, x347 y175 w60 vFieldReturnType3 gnm_SaveGather, %FieldReturnType3%||Walk|Reset|Rejoin
GuiControl, disable, FieldReturnType3
Gui, Add, DropDownList, x415 y57 w80 vFieldSprinklerLoc1 gnm_SaveGather, %FieldSprinklerLoc1%||Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left
GuiControl, disable, FieldSprinklerLoc1
Gui, Add, DropDownList, x415 y115 w80 vFieldSprinklerLoc2 gnm_SaveGather, %FieldSprinklerLoc2%||Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left
GuiControl, disable, FieldSprinklerLoc2
Gui, Add, DropDownList, x415 y175 w80 vFieldSprinklerLoc3 gnm_SaveGather, %FieldSprinklerLoc3%||Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left
GuiControl, disable, FieldSprinklerLoc3
Gui, Add, Text, x420 y77 w80 vsprinklerDistance1,distance
Gui, Add, DropDownList,x460 y80 w35 vFieldSprinklerDist1 gnm_SaveGather, %FieldSprinklerDist1%||1|2|3|4|5|6|7|8|9|10
GuiControl, disable, FieldSprinklerDist1
Gui, Add, Text, x420 y135 w80 vsprinklerDistance2,distance
Gui, Add, DropDownList, x460 y138 w35 vFieldSprinklerDist2 gnm_SaveGather, %FieldSprinklerDist2%||1|2|3|4|5|6|7|8|9|10
GuiControl, disable, FieldSprinklerDist2
Gui, Add, Text, x420 y195 w80 vsprinklerDistance3,distance
Gui, Add, DropDownList, x460 y198 w35 vFieldSprinklerDist3 gnm_SaveGather, %FieldSprinklerDist3%||1|2|3|4|5|6|7|8|9|10
GuiControl, disable, FieldSprinklerDist3

;Contributors TAB
;------------------------
Gui, Tab, Contributors
GuiControl,focus, Tab
Gui, Font, w700
Gui, Add, GroupBox, x3 y23 w160 h215, Development
Gui, Add, GroupBox, x163 y23 w335 h215, Contributors
Gui, Font
Gui, Add, Text, x5 y38 w155 +wrap +backgroundtrans, Special Thanks for your contributions in the development and testing of this project.  Your feedback and ideas have been invaluable in the design process!`n`nzez#8710`nFHL09#4061`nLittleChurch#1631 (N00b)`nZaappiix#2372`nSP#0305
Gui, Add, Text, x170 y38 w330 +wrap +backgroundtrans, Thank you for your donations to this project!`n`nFHL09#4061`nNick 9#9476



;STATUS TAB
;------------------------
Gui, Tab, Status
GuiControl,focus, Tab
IniRead, StatusLogReverse, nm_config.ini, Status, StatusLogReverse
IniRead, TotalRuntime, nm_config.ini, Status, TotalRuntime
IniRead, SessionRuntime, nm_config.ini, Status, SessionRuntime
IniRead, TotalGatherTime, nm_config.ini, Status, TotalGatherTime
IniRead, SessionGatherTime, nm_config.ini, Status, SessionGatherTime
IniRead, TotalConvertTime, nm_config.ini, Status, TotalConvertTime
IniRead, SessionConvertTime, nm_config.ini, Status, SessionConvertTime
IniRead, TotalViciousKills, nm_config.ini, Status, TotalViciousKills
IniRead, SessionViciousKills, nm_config.ini, Status, SessionViciousKills
IniRead, TotalBossKills, nm_config.ini, Status, TotalBossKills
IniRead, SessionBossKills, nm_config.ini, Status, SessionBossKills
IniRead, TotalBugKills, nm_config.ini, Status, TotalBugKills
IniRead, SessionBugKills, nm_config.ini, Status, SessionBugKills
IniRead, TotalPlantersCollected, nm_config.ini, Status, TotalPlantersCollected
IniRead, SessionPlantersCollected, nm_config.ini, Status, SessionPlantersCollected
IniRead, TotalQuestsComplete, nm_config.ini, Status, TotalQuestsComplete
IniRead, SessionQuestsComplete, nm_config.ini, Status, SessionQuestsComplete
IniRead, TotalDisconnects, nm_config.ini, Status, TotalDisconnects
IniRead, SessionDisconnects, nm_config.ini, Status, SessionDisconnects
IniRead, Webhook, nm_config.ini, Status, Webhook
IniRead, WebhookCheck, nm_config.ini, Status, WebhookCheck
Gui, Font, w700
Gui, Add, GroupBox, x5 y23 w250 h214, Status Log
Gui, Add, GroupBox, x255 y23 w240 h179, Stats
Gui, Font
Gui, Add, Checkbox, x85 y23 vStatusLogReverse gnm_StatusLogReverseCheck Checked%StatusLogReverse%, Reverse Order
Gui, Add, Text, x10 y37 w240 h198 left vstatuslog,
Gui, font, w700
Gui, Add, Text, x260 y37, Total
Gui, Add, Text, x380 y37, Session
Gui, Font
Gui, Add, Text, x260 y52 w230 h148 left vstats,
Gui, Add, Button, x290 y37 w50 h15 vResetTotalStats gnm_ResetTotalStats, Reset
Gui, Add, Text, x260 y202 w160 +left +BackgroundTrans,Webhook Link (full address):
Gui, Add, Checkbox, x400 y202 +BackgroundTrans vWebhookCheck gnm_webhookcheck Checked%WebhookCheck%, Enable
Gui, Add, Edit, x260 y215 w160 r1 +BackgroundTrans vWebhook gnm_saveConfig, %Webhook%
nm_setStatus()
nm_setStats()

;SETTINGS TAB
;------------------------
Gui, Tab, Settings
GuiControl,focus, Tab
;Gui, Add, Button, x290 y25 w43 h15 gnm_testButton, Test
Gui, Add, Checkbox, x15 y25 vAlwaysOnTop gnm_AlwaysOnTop Checked%AlwaysOnTop%, Always On Top
Gui, Add, Text, x5 y50 w60 +Right +BackgroundTrans,GUI Theme:
Gui, Add, DropDownList, x70 y45 w80 h100 vGuiTheme gnm_guiThemeSelect, %GuiTheme%||Allure|Ayofe|BluePaper|Concaved|Core|Cosmo|Fanta|GrayGray|Hana|Invoice|Lakrits|Luminous|MacLion3|Minimal|Museo|Panther|PaperAGV|PINK|Relapse|Simplex3|SNAS|Stomp|VS7|WhiteGray|Woodwork
GuiControl, disable, GuiTheme
Gui, Add, Text, x5 y70 w70 +left +BackgroundTrans,Transparency:
Gui, Add, DropDownList, x70 y65 w40 h100 vGuiTransparency gnm_guiTransparencySet, %GuiTransparency%||0|5|10|15|20|25|30|35|40|45|50|55|60|65|70
GuiControl, disable, GuiTransparency
IniRead, KeyboardLayout, nm_config.ini, Keys, KeyboardLayout
IniRead, FwdKey, nm_config.ini, Keys, FwdKey
IniRead, BackKey, nm_config.ini, Keys, BackKey
IniRead, LeftKey, nm_config.ini, Keys, LeftKey
IniRead, RightKey, nm_config.ini, Keys, RightKey
IniRead, RotLeft, nm_config.ini, Keys, RotLeft
IniRead, RotRight, nm_config.ini, Keys, RotRight
IniRead, ZoomIn, nm_config.ini, Keys, ZoomIn
IniRead, ZoomOut, nm_config.ini, Keys, ZoomOut
IniRead, KeyDelay, nm_config.ini, Keys, KeyDelay
;Gui, Add, Text, x340 y25 w80 +left +BackgroundTrans,KEY SETTINGS
Gui, Add, GroupBox, x340 y25 w150 h210, KEY SETTINGS
Gui, Add, Text, x340 y35 w100 +left +BackgroundTrans,______________________
Gui, Add, DropDownList, x430 y25 w55 vKeyboardLayout gnm_keyboardLayout, %KeyboardLayout%||qwerty|azerty|other
Gui, Add, Text, x340 y55 w80 +right +BackgroundTrans,Move Forward:
Gui, Add, Text, x340 y75 w80 +right +BackgroundTrans,Move Left:
Gui, Add, Text, x340 y95 w80 +right +BackgroundTrans,Move Back:
Gui, Add, Text, x340 y115 w80 +right +BackgroundTrans,Move Right:
Gui, Add, Text, x340 y135 w80 +right +BackgroundTrans,Camera Left:
Gui, Add, Text, x340 y155 w80 +right +BackgroundTrans,Camera Right:
Gui, Add, Text, x340 y175 w80 +right +BackgroundTrans,Zoom In:
Gui, Add, Text, x340 y195 w80 +right +BackgroundTrans,Zoom Out:
Gui, Add, Text, x340 y215 w80 +right +BackgroundTrans,Add Key Delay:
Gui, Add, Edit, x425 y50 w20 limit1 vFwdKey gnm_saveKeys, %FwdKey%
GuiControl, disable, FwdKey
Gui, Add, Edit, x425 y70 w20 limit1 vLeftKey gnm_saveKeys, %LeftKey%
GuiControl, disable, LeftKey
Gui, Add, Edit, x425 y90 w20 limit1 vBackKey gnm_saveKeys, %BackKey%
GuiControl, disable, BackKey
Gui, Add, Edit, x425 y110 w20 limit1 vRightKey gnm_saveKeys, %RightKey%
GuiControl, disable, RightKey
Gui, Add, Edit, x425 y130 w20 limit1 vRotLeft gnm_saveKeys, %RotLeft%
GuiControl, disable, RotLeft
Gui, Add, Edit, x425 y150 w20 limit1 vRotRight gnm_saveKeys, %RotRight%
GuiControl, disable, RotRight
Gui, Add, Edit, x425 y170 w20 limit1 vZoomIn gnm_saveKeys, %ZoomIn%
GuiControl, disable, ZoomIn
Gui, Add, Edit, x425 y190 w20 limit1 vZoomOut gnm_saveKeys, %ZoomOut%
GuiControl, disable, ZoomOut
Gui, Add, Edit, x425 y210 w25 limit3 number vKeyDelay gnm_saveKeys, %KeyDelay%
GuiControl, disable, KeyDelay
;character settings
;Gui, Add, Text, x175 y25 w110 +left +BackgroundTrans,CHARACTER STATS
Gui, Add, GroupBox, x170 y25 w150 h210, CHARACTER STATS
Gui, Add, Text, x175 y27 w100 +left +BackgroundTrans,______________________
IniRead, MoveSpeedNum, nm_config.ini, Settings, MoveSpeed
IniRead, HiveSlot, nm_config.ini, Settings, HiveSlot
IniRead, HiveVariation, nm_config.ini, Settings, HiveVariation
IniRead, HiveBees, nm_config.ini, Settings, HiveBees
IniRead, DisableToolUse, nm_config.ini, Settings, DisableToolUse
Gui, Add, Text, x175 y42 w110 +left +BackgroundTrans,Movement Speed:
Gui, Font, s6
Gui, Add, Text, x175 y57 w80 +right +BackgroundTrans,(WITHOUT HASTE)
Gui, Add, Text, x57 y118 w60 +left +BackgroundTrans,(6-5-4-3-2-1)
Gui, Font
Gui, Add, Edit, x265 y45 w30 limit4 vMoveSpeed gnm_moveSpeed, %MoveSpeedNum%
GuiControl, disable, MoveSpeed
Gui, Add, Text, x175 y75 w110 +left +BackgroundTrans,Move Method:
Gui, Add, DropDownList, x247 y70 w65 vMoveMethod gnm_saveConfig, %MoveMethod%||Walk|Cannon
GuiControl, disable, MoveMethod
Gui, Add, Text, x175 y95 w110 +left +BackgroundTrans,Sprinkler Type:
Gui, Add, DropDownList, x247 y90 w65 vSprinklerType gnm_saveConfig, %SprinklerType%||None|Basic|Silver|Golden|Diamond|Supreme
GuiControl, disable, SprinklerType
Gui, Add, Text, x175 y115 w110 +left +BackgroundTrans,Convert Balloon:
Gui, Add, Text, x200 y127 w110 +left +BackgroundTrans,\____\___
Gui, Add, DropDownList, x252 y110 w60 vConvertBalloon gnm_convertBalloon, %ConvertBalloon%||Always|Never|Every
GuiControl, disable, ConvertBalloon
Gui, Add, Edit, x252 y130 w25 r1 number +BackgroundTrans vConvertMins gnm_saveConfig, %ConvertMins%
GuiControl, disable, ConvertMins
Gui, Add, Text, x282 y135, Mins
Gui, Add, CheckBox, x175 y155 vDisableToolUse gnm_saveConfig +BackgroundTrans Checked%DisableToolUse%, Disable Tool Use

;hive settings
Gui, Add, Text, x10 y95 w110 +left +BackgroundTrans,HIVE SETTINGS
Gui, Add, Text, x10 y97 w100 +left +BackgroundTrans,______________________
Gui, Add, Text, x10 y115 w60 +left +BackgroundTrans,Hive Slot:
Gui, Add, Text, x103 y115 w10 +left +BackgroundTrans,:
Gui, Add, DropDownList, x110 y110 w30 vHiveSlot gnm_saveConfig, %HiveSlot%||1|2|3|4|5|6
GuiControl, disable, HiveSlot
Gui, Add, Text, x10 y135 w120 +left +BackgroundTrans,Hive Image Variation:
Gui, Add, Edit, x110 y130 w30 h20 limit3 number vHiveVariation gnm_HiveVariation,%HiveVariation%
GuiControl, disable, HiveVariation
Gui, Add, Text, x10 y155 w110 +left +BackgroundTrans,My Hive Has:
Gui, Add, Edit, x75 y150 w20 h15 r1 number +BackgroundTrans vHiveBees gnm_saveConfig, %HiveBees%
GuiControl, disable, HiveBees
Gui, Add, Text, x100 y155 w110 +left +BackgroundTrans,Bees
Gui, Add, Text, x5 y180 w160 +left +BackgroundTrans,Private Server Link (full address):
Gui, Add, Edit, x5 y195 w160 r1 +BackgroundTrans vPrivServer gnm_ServerLink, %PrivServer%
GuiControl, disable, PrivServer
Gui, Add, Text, x5 y218 w160 +left +BackgroundTrans,Wait
Gui, Add, Edit, x28 y215 w20 h15 r1 number +BackgroundTrans vReloadRobloxSecs gnm_saveConfig, %ReloadRobloxSecs%
GuiControl, disable, ReloadRobloxSecs
Gui, Add, Text, x51 y218 w160 +left +BackgroundTrans,seconds to load Roblox.
nm_convertBalloon()


;COLLECT TAB
;------------------------
global ClockCheck
global MondoBuffCheck
global MondoAction
global AntPassCheck, AntPassAction
global HoneyDisCheck
global TreatDisCheck
global BlueberryDisCheck
global StrawberryDisCheck
global RoyalJellyDisCheck
global CoconutDisCheck
IniRead, ClockCheck, nm_config.ini, Collect, ClockCheck
IniRead, MondoBuffCheck, nm_config.ini, Collect, MondoBuffCheck
IniRead, MondoAction, nm_config.ini, Collect, MondoAction
IniRead, AntPassCheck, nm_config.ini, Collect, AntPassCheck
IniRead, AntPassAction, nm_config.ini, Collect, AntPassAction
IniRead, HoneyDisCheck, nm_config.ini, Collect, HoneyDisCheck
IniRead, TreatDisCheck, nm_config.ini, Collect, TreatDisCheck
IniRead, BlueberryDisCheck, nm_config.ini, Collect, BlueberryDisCheck
IniRead, StrawberryDisCheck, nm_config.ini, Collect, StrawberryDisCheck
IniRead, CoconutDisCheck, nm_config.ini, Collect, CoconutDisCheck
IniRead, RoyalJellyDisCheck, nm_config.ini, Collect, RoyalJellyDisCheck
IniRead, GlueDisCheck, nm_config.ini, Collect, GlueDisCheck

Gui, Tab, Collect/Kill
GuiControl,focus, Tab
;collect
Gui, Font, w700
Gui, Add, Text, x20 y25 w50 left +BackgroundTrans, Collect
Gui, Add, Text, x20 y105 w50 left +BackgroundTrans, Beesmas
Gui, Add, Text, x140 y25 w50 left +BackgroundTrans, Dispensers
Gui, Add, Text, x260 y25 w80 left +BackgroundTrans, Bug Run
Gui, Add, Text, x390 y25 w80 left +BackgroundTrans, Other
Gui, Font, w400
Gui, Add, Text, x10 y27 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x10 y107 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x130 y27 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x260 y27 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x380 y27 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x250 y25 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y35 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y45 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y55 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y65 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y75 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y85 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y95 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y105 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y115 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y125 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y135 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y145 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y155 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y165 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y175 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y185 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y195 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y205 w50 left +BackgroundTrans, ||
Gui, Add, Text, x250 y215 w50 left +BackgroundTrans, ||
Gui, Add, Checkbox, x15 y45 +BackgroundTrans vClockCheck gnm_saveCollect Checked%ClockCheck%, Clock (tickets)
GuiControl, disable, ClockCheck
Gui, Add, Checkbox, x15 y65 +BackgroundTrans vMondoBuffCheck gnm_saveCollect Checked%MondoBuffCheck%, Mondo
GuiControl, disable, MondoBuffCheck
Gui, Add, DropDownList, x75 y60 w45 vMondoAction gnm_saveCollect, %MondoAction%||Buff|Kill
GuiControl, disable, MondoAction
Gui, Add, Checkbox, x15 y85 +BackgroundTrans vAntPassCheck gnm_saveCollect Checked%AntPassCheck%, Ant
GuiControl, disable, AntPassCheck
Gui, Add, DropDownList, x50 y80 w70 vAntPassAction gnm_saveCollect, %AntPassAction%||Pass|Challenge
GuiControl, disable, AntPassAction
;dispensers
Gui, Add, Checkbox, x135 y45 +BackgroundTrans vHoneyDisCheck gnm_saveCollect Checked%HoneyDisCheck%, Honey
GuiControl, disable, HoneyDisCheck
Gui, Add, Checkbox, x135 y65 +BackgroundTrans vTreatDisCheck gnm_saveCollect Checked%TreatDisCheck%, Treat
GuiControl, disable, TreatDisCheck
Gui, Add, Checkbox, x135 y85 +BackgroundTrans vBlueberryDisCheck gnm_saveCollect Checked%BlueberryDisCheck%, Blueberry
GuiControl, disable, BlueberryDisCheck
Gui, Add, Checkbox, x135 y105 +BackgroundTrans vStrawberryDisCheck gnm_saveCollect Checked%StrawberryDisCheck%, Strawberry
GuiControl, disable, StrawberryDisCheck
Gui, Add, Checkbox, x135 y125 +BackgroundTrans vCoconutDisCheck gnm_saveCollect Checked%CoconutDisCheck%, Coconut
GuiControl, disable, CoconutDisCheck
Gui, Add, Checkbox, x135 y145 +BackgroundTrans vRoyalJellyDisCheck gnm_saveCollect Checked%RoyalJellyDisCheck%, Royal Jelly (star)
GuiControl, disable, RoyalJellyDisCheck
Gui, Add, Checkbox, x135 y165 +BackgroundTrans vGlueDisCheck gnm_saveCollect Checked%GlueDisCheck%, Glue
GuiControl, disable, GlueDisCheck

;BEESMAS (Reserved = Not implemented) 
IniRead, StockingsCheck, nm_config.ini, Collect, StockingsCheck
IniRead, WreathCheck, nm_config.ini, Collect, WreathCheck
IniRead, FeastCheck, nm_config.ini, Collect, FeastCheck
IniRead, CandlesCheck, nm_config.ini, Collect, CandlesCheck
IniRead, SamovarCheck, nm_config.ini, Collect, SamovarCheck
IniRead, LidArtCheck, nm_config.ini, Collect, LidArtCheck
Gui, Add, Checkbox, x15 y125 +BackgroundTrans vStockingsCheck gnm_saveCollect Checked%StockingsCheck%, Stockings
Gui, Add, Checkbox, x15 y140 +BackgroundTrans vWreathCheck gnm_saveCollect Checked%WreathCheck%, Wreath
Gui, Add, Checkbox, x15 y155 +BackgroundTrans vFeastCheck gnm_saveCollect Checked%FeastCheck%, Feast
Gui, Add, Checkbox, x15 y170 +BackgroundTrans vCandlesCheck gnm_saveCollect Checked%CandlesCheck%, Candles
Gui, Add, Checkbox, x15 y185 +BackgroundTrans vSamovarCheck gnm_saveCollect Checked%SamovarCheck%, Samovar
Gui, Add, Checkbox, x15 y200 +BackgroundTrans vLidArtCheck gnm_saveCollect Checked%LidArtCheck%, Lid Art
beesmasActive:=0
if(not beesmasActive){
	Gui, Add, Text, x75 y105 w50 left +BackgroundTrans, (Reserved)
	GuiControl,,StockingsCheck, 0
	GuiControl,,WreathCheck, 0
	GuiControl,,FeastCheck, 0
	GuiControl,,CandlesCheck, 0
	GuiControl,,SamovarCheck, 0
	GuiControl,,LidArtCheck, 0
	GuiControl,disable,StockingsCheck
	GuiControl,disable,WreathCheck
	GuiControl,disable,FeastCheck
	GuiControl,disable,CandlesCheck
	GuiControl,disable,SamovarCheck
	GuiControl,disable,LidArtCheck
}

;BUGS
global GiftedViciousCheck
global BugRunCheck
global BugrunLadybugsCheck
global BugrunRhinoBeetlesCheck
global BugrunSpiderCheck
global BugrunMantisCheck
global BugrunScorpionsCheck
global BugrunWerewolfCheck
global BugrunLadybugsLoot
global BugrunRhinoBeetlesLoot
global BugrunSpiderLoot
global BugrunMantisLoot
global BugrunScorpionsLoot
global BugrunWerewolfLoot
global StingerCheck
IniRead, BugRunCheck, nm_config.ini, Collect, BugRunCheck
IniRead, GiftedViciousCheck, nm_config.ini, Collect, GiftedViciousCheck
IniRead, BugrunInterruptCheck, nm_config.ini, Collect, BugrunInterruptCheck
IniRead, BugrunLadybugsCheck, nm_config.ini, Collect, BugrunLadybugsCheck
IniRead, BugrunRhinoBeetlesCheck, nm_config.ini, Collect, BugrunRhinoBeetlesCheck
IniRead, BugrunSpiderCheck, nm_config.ini, Collect, BugrunSpiderCheck
IniRead, BugrunMantisCheck, nm_config.ini, Collect, BugrunMantisCheck
IniRead, BugrunScorpionsCheck, nm_config.ini, Collect, BugrunScorpionsCheck
IniRead, BugrunWerewolfCheck, nm_config.ini, Collect, BugrunWerewolfCheck
IniRead, BugrunLadybugsLoot, nm_config.ini, Collect, BugrunLadybugsLoot
IniRead, BugrunRhinoBeetlesLoot, nm_config.ini, Collect, BugrunRhinoBeetlesLoot
IniRead, BugrunSpiderLoot, nm_config.ini, Collect, BugrunSpiderLoot
IniRead, BugrunMantisLoot, nm_config.ini, Collect, BugrunMantisLoot
IniRead, BugrunScorpionsLoot, nm_config.ini, Collect, BugrunScorpionsLoot
IniRead, BugrunWerewolfLoot, nm_config.ini, Collect, BugrunWerewolfLoot
IniRead, StingerCheck, nm_config.ini, Collect, StingerCheck
IniRead, TunnelBearCheck, nm_config.ini, Collect, TunnelBearCheck
IniRead, TunnelBearBabyCheck, nm_config.ini, Collect, TunnelBearBabyCheck
IniRead, KingBeetleCheck, nm_config.ini, Collect, KingBeetleCheck
IniRead, KingBeetleBabyCheck, nm_config.ini, Collect, KingBeetleBabyCheck
Gui, Add, Checkbox, x310 y25 vBugRunCheck gnm_BugRunCheck Checked%BugRunCheck%, Select All
Gui, Add, Checkbox, x260 y43 w110 +border vGiftedViciousCheck gnm_saveCollect Checked%GiftedViciousCheck%, Apply Hive Bonus:`nGifted Vicious Bee
Gui, Add, Checkbox, x257 y70 w120 h15 +BackgroundTrans vBugrunInterruptCheck gnm_saveCollect Checked%BugrunInterruptCheck%, Allow Gather Interrupt
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
Gui, Add, Checkbox, x266 y110 +BackgroundTrans vBugrunLadybugsLoot  gnm_saveCollect Checked%BugrunLadybugsLoot%, %A_Space%!
GuiControl, disable, BugrunLadybugsLoot
Gui, Add, Checkbox, x266 y130 +BackgroundTrans vBugrunRhinoBeetlesLoot gnm_saveCollect Checked%BugrunRhinoBeetlesLoot%, %A_Space%!
GuiControl, disable, BugrunRhinoBeetlesLoot
Gui, Add, Checkbox, x266 y150 +BackgroundTrans vBugrunSpiderLoot gnm_saveCollect Checked%BugrunSpiderLoot%, %A_Space%!
GuiControl, disable, BugrunSpiderLoot
Gui, Add, Checkbox, x266 y170 +BackgroundTrans vBugrunMantisLoot gnm_saveCollect Checked%BugrunMantisLoot%, %A_Space%!
GuiControl, disable, BugrunMantisLoot
Gui, Add, Checkbox, x266 y190 +BackgroundTrans vBugrunScorpionsLoot gnm_saveCollect Checked%BugrunScorpionsLoot%, %A_Space%!
GuiControl, disable, BugrunScorpionLoot
Gui, Add, Checkbox, x266 y210 +BackgroundTrans vBugrunWerewolfLoot gnm_saveCollect Checked%BugrunWerewolfLoot%, %A_Space%!
GuiControl, disable, BugrunWerewolfLoot
Gui, Add, Checkbox, x294 y110 +BackgroundTrans vBugrunLadybugsCheck gnm_saveCollect Checked%BugrunLadybugsCheck%, Ladybugs
GuiControl, disable, BugrunLadybugsCheck
Gui, Add, Checkbox, x294 y130 +BackgroundTrans vBugrunRhinoBeetlesCheck gnm_saveCollect Checked%BugrunRhinoBeetlesCheck%, Rhino Beetles
GuiControl, disable, BugrunRhinoBeetlesCheck
Gui, Add, Checkbox, x294 y150 +BackgroundTrans vBugrunSpiderCheck gnm_saveCollect Checked%BugrunSpiderCheck%, Spider
GuiControl, disable, BugrunSpiderCheck
Gui, Add, Checkbox, x294 y170 +BackgroundTrans vBugrunMantisCheck gnm_saveCollect Checked%BugrunMantisCheck%, Mantis
GuiControl, disable, BugrunManticCheck
Gui, Add, Checkbox, x294 y190 +BackgroundTrans vBugrunScorpionsCheck gnm_saveCollect Checked%BugrunScorpionsCheck%, Scorpions
GuiControl, disable, BugrunScorpionsCheck
Gui, Add, Checkbox, x294 y210 +BackgroundTrans vBugrunWerewolfCheck gnm_saveCollect Checked%BugrunWerewolfCheck%, Werewolf
GuiControl, disable, BugrunWerewolfCheck
Gui, Add, Checkbox, x390 y45 +BackgroundTrans vStingerCheck gnm_saveCollect Checked%StingerCheck%, Stingers
GuiControl, disable, StingerCheck
Gui, Add, Button, x450 y45 w38 h15 gnm_stingerFields, Fields
Gui, Add, Text, x385 y62, Baby`nLove
Gui, Add, Text, x422 y75, Kill
Gui, Add, text, x387 y77 +BackgroundTrans, _ _ _ _ _ _ _ _ _ _ _ _
Gui, Add, text, x412 y65 +BackgroundTrans, !
Gui, Add, text, x412 y75 +BackgroundTrans, !
Gui, Add, text, x412 y85 +BackgroundTrans, !
Gui, Add, text, x412 y95 +BackgroundTrans, !
Gui, Add, text, x412 y105 +BackgroundTrans, !
Gui, Add, text, x412 y115 +BackgroundTrans, !
Gui, Add, Checkbox, x393 y95 +BackgroundTrans vTunnelBearBabyCheck gnm_saveCollect Checked%TunnelBearBabyCheck%, %A_Space%!
GuiControl, disable, TunnelBearBabyCheck
Gui, Add, Checkbox, x393 y115 +BackgroundTrans vKingBeetleBabyCheck gnm_saveCollect Checked%KingBeetleBabyCheck%, %A_Space%!
GuiControl, disable, KingBeetleBabyCheck
Gui, Add, Checkbox, x421 y95 +BackgroundTrans vTunnelBearCheck gnm_saveCollect Checked%TunnelBearCheck%, Tunnel Bear
GuiControl, disable, TunnelBearCheck
Gui, Add, Checkbox, x421 y115 +BackgroundTrans vKingBeetleCheck gnm_saveCollect Checked%KingBeetleCheck%, King Beetle
GuiControl, disable, KingBeetleCheck

;Other
;Gui, Add, Checkbox, x202 y64 , Ants
nm_saveCollect()

;BOOST TAB
;------------------------
Gui, Tab, Boost
GuiControl,focus, Tab
;boosters
global FieldBooster1
global FieldBooster2
global FieldBooster3
global FieldBoosterMins
IniRead, FieldBooster1, nm_config.ini, Boost, FieldBooster1
IniRead, FieldBooster2, nm_config.ini, Boost, FieldBooster2
IniRead, FieldBooster3, nm_config.ini, Boost, FieldBooster3
IniRead, FieldBoosterMins, nm_config.ini, Boost, FieldBoosterMins
IniRead, BoostChaserCheck, nm_config.ini, Boost, BoostChaserCheck
Gui, Font, W700
Gui, Add, GroupBox, x5 y25 w120 h135, HQ Field Boosters
Gui, Add, GroupBox, x130 y25 w170 h155, Hotbar Slots
Gui, Font
;field booster
Gui, Add, Text, x25 y40 w100 left +BackgroundTrans, Order
Gui, Add, Text, x95 y35 w100 left cGREEN +BackgroundTrans, (free)
Gui, Add, Text, x10 y42 w50 left +BackgroundTrans, __________________
Gui, Add, Text, x10 y62 w10 left +BackgroundTrans, 1:
Gui, Add, Text, x10 y82 w10 left +BackgroundTrans, 2:
Gui, Add, Text, x10 y102 w10 left +BackgroundTrans, 3:
Gui, Add, DropDownList, x20 y58 w55 vFieldBooster1 gnm_FieldBooster1, %FieldBooster1%||None|Blue|Red|Mount
GuiControl, disable, FieldBooster1
Gui, Add, DropDownList, x20 y78 w55 vFieldBooster2 gnm_FieldBooster2, %FieldBooster2%||None|Blue|Red|Mount
GuiControl, disable, FieldBooster2
Gui, Add, DropDownList, x20 y98 w55 vFieldBooster3 gnm_FieldBooster3, %FieldBooster3%||None|Blue|Red|Mount
GuiControl, disable, FieldBooster3
Gui, Add, Text, x77 y62 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x77 y82 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x77 y102 w10 left +BackgroundTrans, Booster
Gui, Add, Text, x15 y120 w120 left +BackgroundTrans, Separate Each Boost
Gui, Add, Text, x35 y137 w100 left +BackgroundTrans,By:
Gui, Add, DropDownList, x55 y135 w37 vFieldBoosterMins gnm_saveBoost, %FieldBoosterMins%||0|5|10|15|20|30
GuiControl, disable, FieldBoosterMins
Gui, Add, Text, x95 y137 w100 left +BackgroundTrans, Mins
Gui, Add, CheckBox, x20 y165 +border +center vBoostChaserCheck gnm_BoostChaserCheck Checked%BoostChaserCheck%, Gather in`nBoosted Field
;hotbar
global HotkeyTime2
global HotkeyTime3
global HotkeyTime4
global HotkeyTime5
global HotkeyTime6
global HotkeyTime7
global HotkeyTimeUnits2
global HotkeyTimeUnits3
global HotkeyTimeUnits4
global HotkeyTimeUnits5
global HotkeyTimeUnits6
global HotkeyTimeUnits7
global HotkeyWhile2
global HotkeyWhile3
global HotkeyWhile4
global HotkeyWhile5
global HotkeyWhile6
global HotkeyWhile7
IniRead, HotkeyTime2, nm_config.ini, Boost, HotkeyTime2
IniRead, HotkeyTime3, nm_config.ini, Boost, HotkeyTime3
IniRead, HotkeyTime4, nm_config.ini, Boost, HotkeyTime4
IniRead, HotkeyTime5, nm_config.ini, Boost, HotkeyTime5
IniRead, HotkeyTime6, nm_config.ini, Boost, HotkeyTime6
IniRead, HotkeyTime7, nm_config.ini, Boost, HotkeyTime7
IniRead, HotkeyTimeUnits2, nm_config.ini, Boost, HotkeyTimeUnits2
IniRead, HotkeyTimeUnits3, nm_config.ini, Boost, HotkeyTimeUnits3
IniRead, HotkeyTimeUnits4, nm_config.ini, Boost, HotkeyTimeUnits4
IniRead, HotkeyTimeUnits5, nm_config.ini, Boost, HotkeyTimeUnits5
IniRead, HotkeyTimeUnits6, nm_config.ini, Boost, HotkeyTimeUnits6
IniRead, HotkeyTimeUnits7, nm_config.ini, Boost, HotkeyTimeUnits7
IniRead, HotkeyWhile2, nm_config.ini, Boost, HotkeyWhile2
IniRead, HotkeyWhile3, nm_config.ini, Boost, HotkeyWhile3
IniRead, HotkeyWhile4, nm_config.ini, Boost, HotkeyWhile4
IniRead, HotkeyWhile5, nm_config.ini, Boost, HotkeyWhile5
IniRead, HotkeyWhile6, nm_config.ini, Boost, HotkeyWhile6
IniRead, HotkeyWhile7, nm_config.ini, Boost, HotkeyWhile7
Gui, Add, Text, x155 y40 w140 left +BackgroundTrans, Use
Gui, Add, Text, x235 y40 w140 left +BackgroundTrans, Mins/Secs
Gui, Add, Text, x135 y42 w50 left +BackgroundTrans, ___________________________
Gui, Add, Text, x135 y62 w10 left +BackgroundTrans, 2:
Gui, Add, Text, x135 y82 w10 left +BackgroundTrans, 3:
Gui, Add, Text, x135 y102 w10 left +BackgroundTrans, 4:
Gui, Add, Text, x135 y122 w10 left +BackgroundTrans, 5:
Gui, Add, Text, x135 y142 w10 left +BackgroundTrans, 6:
Gui, Add, Text, x135 y162 w10 left +BackgroundTrans, 7:
Gui, Add, DropDownList, x145 y57 w70 vHotkeyWhile2  gnm_HotkeyWhile2, %HotkeyWhile2%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile2
Gui, Add, DropDownList, x145 y77 w70 vHotkeyWhile3 gnm_HotkeyWhile3, %HotkeyWhile3%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile3
Gui, Add, DropDownList, x145 y97 w70 vHotkeyWhile4 gnm_HotkeyWhile4, %HotkeyWhile4%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile4
Gui, Add, DropDownList, x145 y117 w70 vHotkeyWhile5 gnm_HotkeyWhile5, %HotkeyWhile5%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile5
Gui, Add, DropDownList, x145 y137 w70 vHotkeyWhile6 gnm_HotkeyWhile6, %HotkeyWhile6%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile6
Gui, Add, DropDownList, x145 y157 w70 vHotkeyWhile7 gnm_HotkeyWhile7, %HotkeyWhile7%||Never|Always|At Hive|Gathering|Attacking|Microconverter|Whirligig|Enzymes
GuiControl, disable, HotkeyWhile7
Gui, Add, Text, x225 y61 cRED, <-- OFF
Gui, Add, Text, x225 y81 cRED, <-- OFF
Gui, Add, Text, x225 y101 cRED, <-- OFF
Gui, Add, Text, x225 y121 cRED, <-- OFF
Gui, Add, Text, x225 y141 cRED, <-- OFF
Gui, Add, Text, x225 y161 cRED, <-- OFF
Gui, Add, Text, x218 y61 w80 vHBText2, ""
GuiControl, hide, HBText2
Gui, Add, Text, x218 y81 w80 vHBText3, ""
GuiControl, hide, HBText3
Gui, Add, Text, x218 y101 w80 vHBText4, ""
GuiControl, hide, HBText4
Gui, Add, Text, x218 y121 w80 vHBText5, ""
GuiControl, hide, HBText5
Gui, Add, Text, x218 y141 w80 vHBText6, ""
GuiControl, hide, HBText6
Gui, Add, Text, x218 y161 w80 vHBText7, ""
GuiControl, hide, HBText7
Gui, Add, Edit, x220 y57 w30 h20 r1 limit4 number vHotkeyTime2 gnm_saveBoost, %HotkeyTime2%
GuiControl, disable, HotkeyTime2
Gui, Add, Edit, x220 y77 w30 h20 r1 limit4 number vHotkeyTime3 gnm_saveBoost, %HotkeyTime3%
GuiControl, disable, HotkeyTime3
Gui, Add, Edit, x220 y97 w30 h20 r1 limit4 number vHotkeyTime4 gnm_saveBoost, %HotkeyTime4%
GuiControl, disable, HotkeyTime4
Gui, Add, Edit, x220 y117 w30 h20 r1 limit4 number vHotkeyTime5 gnm_saveBoost, %HotkeyTime5%
GuiControl, disable, HotkeyTime5
Gui, Add, Edit, x220 y137 w30 h20 r1 limit4 number vHotkeyTime6 gnm_saveBoost, %HotkeyTime6%
GuiControl, disable, HotkeyTime6
Gui, Add, Edit, x220 y157 w30 h20 r1 limit4 number vHotkeyTime7 gnm_saveBoost, %HotkeyTime7%
GuiControl, disable, HotkeyTime7
Gui, Add, DropDownList, x250 y57 w47 vHotkeyTimeUnits2 gnm_saveBoost, %HotkeyTimeUnits2%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits2
Gui, Add, DropDownList, x250 y77 w47 vHotkeyTimeUnits3 gnm_saveBoost, %HotkeyTimeUnits3%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits3
Gui, Add, DropDownList, x250 y97 w47 vHotkeyTimeUnits4 gnm_saveBoost, %HotkeyTimeUnits4%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits4
Gui, Add, DropDownList, x250 y117 w47 vHotkeyTimeUnits5 gnm_saveBoost, %HotkeyTimeUnits5%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits5
Gui, Add, DropDownList, x250 y137 w47 vHotkeyTimeUnits6 gnm_saveBoost, %HotkeyTimeUnits6%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits6
Gui, Add, DropDownList, x250 y157 w47 vHotkeyTimeUnits7 gnm_saveBoost, %HotkeyTimeUnits7%||Secs|Mins
GuiControl, disable, HotkeyTimeUnits7
nm_HotkeyWhile2(), nm_HotkeyWhile3(), nm_HotkeyWhile4(), nm_HotkeyWhile5(), nm_HotkeyWhile6(), nm_HotkeyWhile7()
;Gui, Add, CheckBox, x135 y185, Unlock Active Play Hotbar
;auto field boost
IniRead, AutoFieldBoostActive, nm_config.ini, Boost, AutoFieldBoostActive
if(AutoFieldBoostActive)
	buttonText:=("Auto Field Boost`n[ON]")
else if(not AutoFieldBoostActive)
	buttonText:=("Auto Field Boost`n[OFF]")
Gui, Add, Button, x20 y200 w90 h30 vAutoFieldBoostButton gnm_autoFieldBoostButton, %buttonText%
Gui, Font, w700
Gui, Add, Text, x5 y25 w490 h210 vBoostTabEasyMode +border +center,`n`nThis Tab Unavailable in Easy Mode
GuiControl,hide,BoostTabEasyMode
Gui, Font



;QUEST TAB
;------------------------
Gui, Tab, Quest
GuiControl,focus, Tab
IniRead, PolarQuestCheck, nm_config.ini, Quests, PolarQuestCheck
IniRead, PolarQuestGatherInterruptCheck, nm_config.ini, Quests, PolarQuestGatherInterruptCheck
IniRead, PolarQuestProgress, nm_config.ini, Quests, PolarQuestProgress
PolarQuestProgress := StrReplace(PolarQuestProgress, "|", "`n")
IniRead, HoneyQuestCheck, nm_config.ini, Quests, HoneyQuestCheck
IniRead, BlackQuestCheck, nm_config.ini, Quests, BlackQuestCheck
IniRead, BlackQuestProgress, nm_config.ini, Quests, BlackQuestProgress
BlackQuestProgress := StrReplace(BlackQuestProgress, "|", "`n")
IniRead, BuckoQuestCheck, nm_config.ini, Quests, BuckoQuestCheck
IniRead, BuckoQuestGatherInterruptCheck, nm_config.ini, Quests, BuckoQuestGatherInterruptCheck
IniRead, BuckoQuestProgress, nm_config.ini, Quests, BuckoQuestProgress
BuckoQuestProgress := StrReplace(BuckoQuestProgress, "|", "`n")
IniRead, RileyQuestCheck, nm_config.ini, Quests, RileyQuestCheck
IniRead, RileyQuestGatherInterruptCheck, nm_config.ini, Quests, RileyQuestGatherInterruptCheck
IniRead, RileyQuestProgress, nm_config.ini, Quests, RileyQuestProgress
IniRead, QuestGatherMins, nm_config.ini, Quests, QuestGatherMins
RileyQuestProgress := StrReplace(RileyQuestProgress, "|", "`n")
Gui, Font, w700
Gui, Add, GroupBox, x5 y23 w150 h108, Polar Bear
Gui, Add, GroupBox, x5 y131 w150 h38, Honey Bee
Gui, Add, GroupBox, x5 y170 w150 h68, QUEST SETTINGS
Gui, Add, GroupBox, x160 y23 w165 h108, Black Bear
Gui, Add, GroupBox, x160 y131 w165 h108, Brown Bear
Gui, Add, Text, x165 y145 cRED, Not Yet Implemented
Gui, Add, GroupBox, x330 y23 w165 h108, Bucko Bee
Gui, Add, GroupBox, x330 y131 w165 h108, Riley Bee
Gui, Font
Gui, Add, Checkbox, x80 y23 vPolarQuestCheck gnm_savequest Checked%PolarQuestCheck%, Enable
Gui, Add, Checkbox, x15 y37 vPolarQuestGatherInterruptCheck gnm_savequest Checked%PolarQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x8 y51 w145 h78 vPolarQuestProgress, %PolarQuestProgress%
Gui, Add, Checkbox, x80 y131 vHoneyQuestCheck gnm_savequest Checked%HoneyQuestCheck%, Enable
Gui, Add, Text, x8 y145 w143 h20 vHoneyQuestProgress, Startup
Gui, Add, Text, x8 y188 +BackgroundTrans, Quest Gather Limit:
Gui, Add, Edit, x100 y185 w25 h17 limit3 number vQuestGatherMins gnm_savequest, %QuestGatherMins%
Gui, Add, Text, x126 y188 +BackgroundTrans, Mins
Gui, Add, Checkbox, x235 y23 vBlackQuestCheck gnm_savequest Checked%BlackQuestCheck%, Enable
Gui, Add, Text, x163 y38 w158 h92 vBlackQuestProgress, %BlackQuestProgress%
Gui, Add, Checkbox, x410 y23 vBuckoQuestCheck gnm_savequest Checked%BuckoQuestCheck%, Enable
Gui, Add, Checkbox, x340 y37 vBuckoQuestGatherInterruptCheck gnm_savequest Checked%BuckoQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x333 y51 w158 h78 vBuckoQuestProgress, %BuckoQuestProgress%
Gui, Add, Checkbox, x410 y131 vRileyQuestCheck gnm_savequest Checked%RileyQuestCheck%, Enable
Gui, Add, Checkbox, x340 y145 vRileyQuestGatherInterruptCheck gnm_savequest Checked%RileyQuestGatherInterruptCheck%, Allow Gather Interrupt
Gui, Add, Text, x333 y159 w158 h78 vRileyQuestProgress, %RileyQuestProgress%
Gui, Font, w700
Gui, Add, Text, x5 y25 w490 h210 vQuestTabEasyMode +border +center,`n`nThis Tab Unavailable in Easy Mode
GuiControl,hide,QuestTabEasyMode
Gui, Font

;PLANTERS+ TAB
;------------------------
Gui, Tab, Planters+
GuiControl,focus, Tab
Gui, Add, Checkbox, x370 y25 +BackgroundTrans vEnablePlantersPlus gba_enableSwitch Checked%EnablePlantersPlus%, Planters+:
Gui, Add, Text, x440 y25 w60 h20 cGreen +left +BackgroundTrans vEnabled, ENABLED
Gui, Add, Text, x440 y25 w60 h20 cRed +left +BackgroundTrans vDisabled, DISABLED
Gui, Add, Text, x17 y24 w40 h20 +left +BackgroundTrans, Presets
Gui, Add, DropDownList, x57 y24 w60 h100 vNPreset gba_nPresetSwitch_, %nPreset%||Custom|Blue|Red|White
GuiControl, disable, NPreset
Gui, Add, Text, x10 y47 w80 h20 +center +BackgroundTrans, Nectar Priority
Gui, Add, Text, x100 y47 w47 h30 +center +BackgroundTrans, Min `%
Gui, Add, Text, x10 y50 w137 h20 +center +BackgroundTrans, _____________________________
Gui, Add, Text, x10 y69 w10 h20 +Left +BackgroundTrans, 1
Gui, Add, Text, x10 y89 w10 h20 +Left +BackgroundTrans, 2
Gui, Add, Text, x10 y109 w10 h20 +Left +BackgroundTrans, 3
Gui, Add, Text, x10 y129 w10 h20 +Left +BackgroundTrans, 4
Gui, Add, Text, x10 y149 w10 h20 +Left +BackgroundTrans, 5
Gui, Add, DropDownList, x20 y66 w80 h120 vN1priority gba_N1unswitch_, %n1priority%%n1string%
GuiControl, disable, N1priority
Gui, Add, DropDownList, x20 y86 w80 h120 vN2priority gba_N2unswitch_, %n2priority%%n2string%
GuiControl, disable, N2Priority
Gui, Add, DropDownList, x20 y106 w80 h120 vN3priority gba_N3unswitch_, %n3priority%%n3string%
GuiControl, disable, N3Priority
Gui, Add, DropDownList, x20 y126 w80 h120 vN4priority gba_N4unswitch_, %n4priority%%n4string%
GuiControl, disable, N4Priority
Gui, Add, DropDownList, x20 y146 w80 h120 vN5priority gba_N5unswitch_, %n5priority%%n5string%
GuiControl, disable, N5Priority
Gui, Add, DropDownList, x105 y66 w40 h100 vN1minPercent gba_N1Punswitch_, %n1minPercent%||10|20|30|40|50|60|70|80|90
GuiControl, disable, N1MinPercent
Gui, Add, DropDownList, x105 y86 w40 h100 vN2minPercent gba_N2Punswitch_, %n2minPercent%||10|20|30|40|50|60|70|80|90
GuiControl, disable, N2MinPercent
Gui, Add, DropDownList, x105 y106 w40 h100 vN3minPercent gba_N3Punswitch_, %n3minPercent%||10|20|30|40|50|60|70|80|90
GuiControl, disable, N3MinPercent
Gui, Add, DropDownList, x105 y126 w40 h100 vN4minPercent gba_N4Punswitch_, %n4minPercent%||10|20|30|40|50|60|70|80|90
GuiControl, disable, N4MinPercent
Gui, Add, DropDownList, x105 y146 w40 h100 vN5minPercent gba_N5Punswitch_, %n5minPercent%||10|20|30|40|50|60|70|80|90
GuiControl, disable, N5MinPercent
Gui, Add, Text, x10 y159 w137 h20 +center +BackgroundTrans, _____________________________
Gui, Add, Text, x5 y178 w70 h20 +right +BackgroundTrans, Harvest Every
gui, font, s7
Gui, Add, Checkbox, x103 y194 +BackgroundTrans vAutomaticHarvestInterval gba_AutoHarvestSwitch_ Checked%AutomaticHarvestInterval%, Auto
Gui, Add, Checkbox, x28 y194 +BackgroundTrans vHarvestFullGrown gba_HarvestFullGrownSwitch_ Checked%HarvestFullGrown%, Full Grown
Gui, Add, Checkbox, x2 y222 +BackgroundTrans vgotoPlanterField gba_gotoPlanterFieldSwitch_ Checked%gotoPlanterField%, Only Gather in Planter Field
gui, font
Gui, Add, Text, x80 y178 w32 h20 cRed +left vAutoText +BackgroundTrans, [Auto]
Gui, Add, Text, x80 y178 w32 h20 cRed +left vFullText +BackgroundTrans, [Full]
Gui, Add, Edit, x80 y174 w32 h20 limit5 vHarvestIntervalNum gba_harvestInterval, %HarvestInterval%
Gui, Add, Text, x115 y178 w70 h20 +left +BackgroundTrans, Hours
Gui, Add, Text, x10 y197 w137 h20 +center +BackgroundTrans, _____________________________
Gui, Add, Button, x380 y200 w90 h20 vShowTimersButton gba_showPlanterTimers, Show Timers
;Gui, Add, Button, x380 y220 w30 h15 gba_testButton, test
Gui, Add, Text, x147 y27 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y37 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y47 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y57 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y67 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y77 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y87 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y97 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y107 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y117 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y127 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y137 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y147 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y157 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y167 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y177 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y187 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y197 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y207 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y217 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x147 y27 w108 h20 +Center +BackgroundTrans, Allowed Planters
Gui, Add, Text, x147 y30 w108 h20 +Right +BackgroundTrans, __________________
Gui, Add, Checkbox, x155 y44 vPlasticPlanterCheck gba_saveConfig_ Checked%PlasticPlanterCheck%, Plastic
Gui, Add, Checkbox, x155 y59 vCandyPlanterCheck gba_saveConfig_ Checked%CandyPlanterCheck%, Candy
Gui, Add, Checkbox, x155 y74 vBlueClayPlanterCheck gba_saveConfig_ Checked%BlueClayPlanterCheck%, Blue Clay
Gui, Add, Checkbox, x155 y89 vRedClayPlanterCheck gba_saveConfig_ Checked%RedClayPlanterCheck%, Red Clay
Gui, Add, Checkbox, x155 y104 vTackyPlanterCheck gba_saveConfig_ Checked%TackyPlanterCheck%, Tacky
Gui, Add, Checkbox, x155 y119 vPesticidePlanterCheck gba_saveConfig_ Checked%PesticidePlanterCheck%, Pesticide
Gui, Add, Checkbox, x155 y134 vPetalPlanterCheck gba_saveConfig_ Checked%PetalPlanterCheck%, Petal
Gui, Add, Checkbox, x155 y149 vPlanterOfPlentyCheck gba_saveConfig_ Checked%PlanterOfPlentyCheck%, Planter of Plenty
Gui, Add, Checkbox, x155 y164 vPaperPlanterCheck gba_saveConfig_ Checked%PaperPlanterCheck%, Paper
Gui, Add, Checkbox, x155 y179 vTicketPlanterCheck gba_saveConfig_ Checked%TicketPlanterCheck%, Ticket
Gui, Add, Text, x188 y215 w80 h20 +left +BackgroundTrans, Max Planters
Gui, Add, DropDownList, x153 y212 w30 h100 vMaxAllowedPlanters gba_maxAllowedPlantersSwitch, %MaxAllowedPlanters%||0|1|2|3
GuiControl, disable, MaxAllowedPlanters
Gui, Add, Text, x255 y27 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y37 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y47 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y57 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y67 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y77 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y87 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y97 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y107 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y117 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y127 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y137 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y147 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y157 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y167 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y177 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y187 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y197 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y207 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y217 w100 h20 +Left +BackgroundTrans, |
Gui, Add, Text, x255 y27 w100 h20 +Center +BackgroundTrans, Allowed Fields
Gui, Add, Text, x255 y30 w240 h20 +Left +BackgroundTrans, ____________________________________________
Gui, Add, Text, x255 y44 w100 h20 +Center +BackgroundTrans, -- starting zone --
Gui, Add, Checkbox, x260 y59 vDandelionFieldCheck gba_saveConfig_ Checked%DandelionFieldCheck%, Dandelion (COM)
Gui, Add, Checkbox, x260 y74 vSunflowerFieldCheck gba_saveConfig_ Checked%SunflowerFieldCheck%, Sunflower (SAT)
Gui, Add, Checkbox, x260 y89 vMushroomFieldCheck gba_saveConfig_ Checked%MushroomFieldCheck%, Mushroom (MOT)
Gui, Add, Checkbox, x260 y104 vBlueFlowerFieldCheck gba_saveConfig_ Checked%BlueFlowerFieldCheck%, Blue Flower (REF)
Gui, Add, Checkbox, x260 y119 vCloverFieldCheck gba_saveConfig_ Checked%CloverFieldCheck%, Clover (INV)
Gui, Add, Text, x255 y132 w100 h20 +Center +BackgroundTrans, -- 5 bee zone --
Gui, Add, Checkbox, x260 y147 vSpiderFieldCheck gba_saveConfig_ Checked%SpiderFieldCheck%, Spider (MOT)
Gui, Add, Checkbox, x260 y162 vStrawberryFieldCheck gba_saveConfig_ Checked%StrawberryFieldCheck%, Strawberry (REF)
Gui, Add, Checkbox, x260 y177 vBambooFieldCheck gba_saveConfig_ Checked%BambooFieldCheck%, Bamboo (COM)
Gui, Add, Text, x255 y190 w100 h20 +Center +BackgroundTrans, -- 10 bee zone --
Gui, Add, Checkbox, x260 y205 vPineappleFieldCheck gba_saveConfig_ Checked%PineappleFieldCheck%, Pineapple (SAT)
Gui, Add, Checkbox, x260 y220 vStumpFieldCheck gba_saveConfig_ Checked%StumpFieldCheck%, Stump (MOT)
Gui, Add, Text, x375 y44 w100 h20 +Center +BackgroundTrans, -- 15 bee zone --
Gui, Add, Checkbox, x380 y59 vCactusFieldCheck gba_saveConfig_ Checked%CactusFieldCheck%, Cactus (INV)
Gui, Add, Checkbox, x380 y74 vPumpkinFieldCheck gba_saveConfig_ Checked%PumpkinFieldCheck%, Pumpkin (SAT)
Gui, Add, Checkbox, x380 y89 vPineTreeFieldCheck gba_saveConfig_ Checked%PineTreeFieldCheck%, Pine Tree (COM)
Gui, Add, Checkbox, x380 y104 vRoseFieldCheck gba_saveConfig_ Checked%RoseFieldCheck%, Rose (MOT)
Gui, Add, Text, x375 y117 w100 h20 +Center +BackgroundTrans, -- 25 bee zone --
Gui, Add, Checkbox, x380 y132 vMountainTopFieldCheck gba_saveConfig_ Checked%MountainTopFieldCheck%, Mountain Top (INV)
Gui, Add, Text, x375 y145 w100 h20 +Center +BackgroundTrans, -- 35 bee zone --
Gui, Add, Checkbox, x380 y160 vCoconutFieldCheck gba_saveConfig_ Checked%CoconutFieldCheck%, Coconut (REF)
Gui, Add, Checkbox, x380 y175 vPepperFieldCheck gba_saveConfig_ Checked%PepperFieldCheck%, Pepper (INV)
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
	GuiControl, Hide, HarvestIntervalNum
	GuiControl, Hide, FullText
}
if(HarvestFullGrown){
	GuiControl, Hide, HarvestIntervalNum
	GuiControl, Hide, AutoText
}
if(EnablePlantersPlus) {
	GuiControl, Hide, Disabled
} else {
	GuiControl, Hide, Enabled
}

/*
;PLANTERS TAB
;------------------------
Gui, Tab, Planters
GuiControl,focus, Tab
loop 3 {
	IniRead, PlanterPlacedBy%A_Index%, nm_config.ini, Planters, PlanterPlacedBy%A_Index%
	IniRead, PlanterHotkeySlot%A_Index%, nm_config.ini, Planters, PlanterHotkeySlot%A_Index%
	IniRead, PlanterSelectedName%A_Index%, nm_config.ini, Planters, PlanterSelectedName%A_Index%
	IniRead, Planter%A_Index%Field1, nm_config.ini, Planters, Planter%A_Index%Field1
	IniRead, Planter%A_Index%Field2, nm_config.ini, Planters, Planter%A_Index%Field2
	IniRead, Planter%A_Index%Field3, nm_config.ini, Planters, Planter%A_Index%Field3
	IniRead, Planter%A_Index%Field4, nm_config.ini, Planters, Planter%A_Index%Field4
	IniRead, Planter%A_Index%Until1, nm_config.ini, Planters, Planter%A_Index%Until1
	IniRead, Planter%A_Index%Until2, nm_config.ini, Planters, Planter%A_Index%Until2
	IniRead, Planter%A_Index%Until3, nm_config.ini, Planters, Planter%A_Index%Until3
	IniRead, Planter%A_Index%Until4, nm_config.ini, Planters, Planter%A_Index%Until4
}
Gui, Font, w700
Gui, Add, Text, x20 y25 w100 +left +BackgroundTrans,Planter 1
Gui, Add, Text, x180 y25 w100 +left +BackgroundTrans,Planter 2
Gui, Add, Text, x340 y25 w100 +left +BackgroundTrans,Planter 3
Gui, Font, w400
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
nm_guiModeButton(0)
Gui, Show, x%GuiX% y%GuiY% w500 h300 , Natro Macro
GuiControl,focus, Tab
nm_guiTransparencySet()
;unlock tabs
nm_FieldUnlock()
nm_TabCollectUnLock()
nm_TabBoostUnLock()
nm_TabPlantersPlusUnLock()
nm_TabSettingsUnLock()

WinActivate, Roblox
WinWaitActive, Roblox
settimer, StartBackground, -5000
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MAIN LOOP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_Start(){
	WinActivate, Roblox
	WinWaitActive, Roblox
	global serverStart
	global QuestGatherField
	serverStart:=nowUnix()
	run:=1
	while(run){
		DisconnectCheck()
		;planters
		ba_planter()
		;kill things
		nm_Mondo()
		nm_Bugrun()
		;collect things
		nm_toCollect()
		nm_Mondo()
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
		;Collect/Kill Tab
		GuiControl,, ClockCheck, 1
		GuiControl,, StockingsCheck, 0
		GuiControl,, WreathCheck, 0
		GuiControl,, FeastCheck, 0
		GuiControl,, CandlesCheck, 0
		GuiControl,, SamovarCheck, 0
		GuiControl,, LidArtCheck, 0
		GuiControl,, AntPassCheck, 0
		GuiControl,, MondoBuffCheck, 0
		GuiControl,, CoconutDisCheck, 0
		GuiControl,, RoyalJellyDisCheck, 0
		GuiControl,, GlueDisCheck, 0
		GuiControl,, TunnelBearCheck, 0
		GuiControl,, TunnelBearBabyCheck, 0
		GuiControl,, KingBeetleCheck, 0
		GuiControl,, KingBeetleBabyCheck, 0
		GuiControl, hide, StockingsCheck
		GuiControl, hide, WreathCheck
		GuiControl, hide, FeastCheck
		GuiControl, hide, CandlesCheck
		GuiControl, hide, SamovarCheck
		GuiControl, hide, LidArtCheck
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
		GuiControl,,BoostChaserCheck,0
		GuiControl,ChooseString,HotkeyWhile2,Never
		GuiControl,ChooseString,HotkeyWhile3,Never
		GuiControl,ChooseString,HotkeyWhile4,Never
		GuiControl,ChooseString,HotkeyWhile5,Never
		GuiControl,ChooseString,HotkeyWhile6,Never
		GuiControl,ChooseString,HotkeyWhile7,Never
		nm_FieldBooster1(), nm_FieldBooster2(), nm_FieldBooster3(), nm_HotkeyWhile2(), nm_HotkeyWhile3(), nm_HotkeyWhile4(), nm_HotkeyWhile5(), nm_HotkeyWhile6(), nm_HotkeyWhile7()
		;disble AFB
		GuiControl,afb:, AutoFieldBoostActive, 0
		GuiControl,, AutoFieldBoostActive, 0
		IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
		GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
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
		GuiControl,,PolarQuestCheck,0
		GuiControl,,BlackQuestCheck,0
		GuiControl,,HoneyQuestCheck,0
		GuiControl,,BuckoQuestCheck,0
		GuiControl,,RileyQuestCheck,0
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
		GuiControl,,EnablePlantersPlus,0
		GuiControl,hide,Enabled
		GuiControl,show,Disabled
		GuiControl,ChooseString,NPreset,Blue
		ba_nPresetSwitch_()
		GuiControl,,PlasticPlanterCheck,1
		GuiControl,,CandyPlanterCheck,1
		GuiControl,,BlueClayPlanterCheck,1
		GuiControl,,RedClayPlanterCheck,1
		GuiControl,,TackyPlanterCheck,1
		GuiControl,,PesticidePlanterCheck,1
		GuiControl,,PetalPlanterCheck,0
		GuiControl,,PlanterOfPlentyCheck,0
		GuiControl,,PaperPlanterCheck,0
		GuiControl,,TicketPlanterCheck,0
		GuiControl,,MaxAllowedPlanters,3
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
		GuiControl, show, StockingsCheck
		GuiControl, show, WreathCheck
		GuiControl, show, FeastCheck
		GuiControl, show, CandlesCheck
		GuiControl, show, SamovarCheck
		GuiControl, show, LidArtCheck
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
	IniWrite, %GuiMode%, nm_config.ini, Settings, GuiMode
}
nm_setState(newState){
	global state
	global disableDayOrNight
	if (newState="traveling") {
		disableDayOrNight:=1
		GuiControl, Text, TimeofDay, Travel
	}
	else
		disableDayOrNight:=0
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
	global state
	global objective
	global stateString
	global disableDayOrNight
	if(newState){
		if (newState="traveling") {
			disableDayOrNight:=1
			GuiControl, Text, TimeofDay, Travel
		}
		else
			disableDayOrNight:=0
		state:=newState
	}
	if(newObjective){
		objective:=newObjective
	}
	stateString:=(state . ": " . objective)
	GuiControl, text, state, %stateString%
	;manage status_log
    if FileExist("status_log.txt"){
        ;count lines in log file
        FileRead, Var, status_log.txt
        StringReplace, Var, Var, `n,`n, UseErrorLevel
        logLines := ErrorLevel+1
        Var= ; empty it
        newLine:="`n"
        if(logLines>20) { ;only keep last X entries
            newText:=""
            Loop, Read, status_log.txt   ; read file line by line
            {
                if(A_Index>1) {
                    FileReadLine, lineText, status_log.txt, A_Index
                    newText:=(newText . lineText . newLine)
                }
            }
            FileDelete, status_log.txt
            FileAppend %newText%, status_log.txt
        }
    }
    FileAppend `[%A_Hour%:%A_Min%:%A_Sec%`] %stateString%`n, status_log.txt
	FileAppend `[%A_MM%/%A_DD%`]`[%A_Hour%:%A_Min%:%A_Sec%`] %stateString%`n, debug_log.txt
    GuiControlGet, StatusLogReverse
    displayText:=""
    Loop, Read, status_log.txt   ; read file line by line
    {
        if(A_Index>(logLines-15)) {
            if(StatusLogReverse)
                lineNum:=(logLines*2-(A_Index+14))
            else
                lineNum:=A_Index
            FileReadLine, lineText, status_log.txt, lineNum
            displayText:=(displayText . lineText . newLine)
        }
    }
    GuiControl,,statuslog,%displayText%
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;webhook test
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	global webhook, webhookCheck, lastHourlyUpdate
	static lastSuccess := 0
	global totalCom, totalMot, totalRef, totalSat, totalInv
	global TotalRuntime, SessionRuntime, MacroStartTime, TotalGatherTime, SessionGatherTime, GatherStartTime, TotalConvertTime, SessionConvertTime, ConvertStartTime, TotalViciousKills, SessionViciousKills, TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills, TotalPlantersCollected, SessionPlantersCollected, TotalQuestsComplete, SessionQuestsComplete, TotalDisconnects, SessionDisconnects
	if (WebhookCheck && RegExMatch(webhook, "i)^https:\/\/(discord|discordapp)\.com\/api\/webhooks\/([\d]+)\/([a-z0-9_-]+)$"))
	{		
		if(GatherStartTime)
			SessionGatherTimeWHT:=(SessionGatherTime+(nowUnix()-GatherStartTime))
		else
			SessionGatherTimeWHT:=SessionGatherTime
		if(ConvertStartTime)
			SessionConvertTimeWHT:=(SessionConvertTime+(nowUnix()-ConvertStartTime))
		else
			SessionConvertTimeWHT:=SessionConvertTime
		; create postdata for normal message
		color := (InStr(stateString,"disconnected") || InStr(stateString,"failed") || InStr(stateString,"died")) ? 15085139 : (InStr(stateString,"checking") || InStr(stateString,"holding") || InStr(stateString,"searching")) ? 14408468 : (InStr(stateString,"confirmed") || InStr(stateString,"found")) ? 9755247 : (InStr(stateString,"engaged") || InStr(stateString,"full")) ? 16366336 : (InStr(stateString,"mondo") || InStr(stateString,"boss") || InStr(stateString,"vb dead")) ? 7036559 : (InStr(stateString,"gathering") || InStr(stateString,"converting")) ? 8871681 : (InStr(stateString,"startup")) ? 15658739 : 3223350
		eventFormatted := StrReplace(stateString, "`r`n", "\n")
		postdata =
		(
		{
			"embeds": [{
				"description": "[%A_Hour%:%A_Min%:%A_Sec%] %eventFormatted%",
				"color": "%color%"
			}]
		}
		)
		
		; post to webhook
		try
		{
			wr := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
			wr.Option(9) := 2048
			wr.Open("POST", webhook)
			wr.SetRequestHeader("User-Agent", "AHK")
			wr.SetRequestHeader("Content-Type", "application/json")
			wr.Send(postdata)
			wr.WaitForResponse()
		}
		; check if event needs screenshot
		IniRead, ssCooldown, nm_config.ini, Status, ssCooldown, 0
		if (nowUnix() - ssCooldown > 300)
		{
			ssEvents := ["Startup", "Disconnected"]
			for k,v in ssEvents
			{
				if (stateString = v)
				{
					; save screenshot to temporary file (could use A_Temp if you want cleaner directory)
					pToken := Gdip_Startup()
					SysGet, pmonN, MonitorPrimary
					pBitmap := Gdip_BitmapFromScreen(pmonN)
					Gdip_SaveBitmapToFile(pBitmap, "file.png")
					Gdip_Shutdown(pToken)
					
					; create multipart/form-data for image
					path := A_ScriptDir . "\file.png"
					objParam := {file: [path]}
					CreateFormData(postdata, hdr_ContentType, objParam)
					
					; post to webhook
					try
					{
						wr := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
						wr.Option(9) := 2048
						wr.Open("POST", webhook)
						wr.SetRequestHeader("User-Agent", "AHK")
						wr.SetRequestHeader("Content-Type", hdr_ContentType)
						wr.Send(postdata)
						wr.WaitForResponse()
					}
					
					; delete the temporary image file and update cooldown
					FileDelete, file.png
					IniWrite, % nowUnix(), nm_config.ini, Status, ssCooldown
					break
				}
			}
		}
		; check if it is time for hourly update
		timeBetween := nowUnix() - lastHourlyUpdate
		if ((timeBetween >= 3600) && !InStr(stateString, "Startup"))
		{
			; initialise variables
			rblxid := WinExist("Roblox")
			if !rblxid
				return
			WinActivate, ahk_id %rblxid%
			WinGetPos, x, y, w, , ahk_id %rblxid%
			WinGet, style, Style, ahk_id %rblxid%
			y += (style & 0x20800000) ? 22 : 0
			static startHoney, lastHoney, lastGath, lastCon
			global totalTime, totalGath, totalCon, totalKills, totalBoss, totalVic, totalQuests, totalDcs, totalPlants, totalCom, totalMot, totalRef, totalSat, totalInv
			
			; detect honey, enlarge image if necessary
			detectedValues := {}
			pToken := Gdip_Startup()
			pBM := Gdip_BitmapFromScreen(w//2 - 300 "|" y "|300|100")
			pEffect := Gdip_CreateEffect(5,-80,40)
			Gdip_BitmapApplyEffect(pBM, pEffect)
			Gdip_DisposeEffect(pEffect)
			
			Loop, 100
			{
				pBMNew := Gdip_ResizeBitmap(pBM, 300 + A_Index * 3, 100 + A_Index, 0, 7)
				hBM := Gdip_CreateHBITMAPFromBitmap(pBMNew)
				Gdip_DisposeImage(pBMNew)
				pIRandomAccessStream := HBitmapToRandomAccessStream(hBM)
				DllCall("DeleteObject", "Ptr", hBM)
				ocrtext := StrReplace(StrReplace("L" . StrReplace(StrReplace(ocr(pIRandomAccessStream), " ", "L"), "`n", "L"), "o", "0"), ".", ",")
				RegexMatch(ocrtext, "(?<=L)\d{1,3}(,\d{3})+(?=L)", detectedHoney)
				if detectedHoney
				{
					if (detectedValues.HasKey(detectedHoney))
						detectedValues[detectedHoney]++
					else
						detectedValues[detectedHoney]:=1
				}
			}
			
			for k,v in detectedValues
				if (v > detectedValues[mode])
					mode := k
			currentHoney := StrReplace(mode, ",")
			
			Gdip_DisposeImage(pBM)
			Gdip_Shutdown(pToken)
			; check that it is appropriate to calculate metrics
			if (currentHoney && lastHourlyUpdate)
			{
				; calculate honey earned during last hour
				honeyEarned := (currentHoney - lastHoney) // (lastSuccess + 1)
				
				; calculate hourly average
				honeyTotal := currentHoney - startHoney
				honeyAverage := honeyTotal // ((SessionRuntime+(nowUnix()-MacroStartTime)) / 3600)
				lastSuccess := 0
				
				; format numerical stats for display
				numnames := ["Million","Billion","Trillion","Quadrillion","Quintillion"]
				for i,x in ["currentHoney","honeyTotal","honeyEarned","honeyAverage"]
				{
					digit := floor(log(abs(%x%)))+1
					if (digit > 6)
					{
						numname := (digit-4)//3
						numstring := SubStr((round(%x%,4-digit)) / 10**(3*numname+3), 1, 5)
						numformat := (SubStr(numstring, 0) = ".") ? 1.000 : numstring, numname += (SubStr(numstring, 0) = ".") ? 1 : 0
						%x%Formatted := SubStr((round(%x%,4-digit)) / 10**(3*numname+3), 1, 5) " " numnames[numname]
					}
					else
					{
						VarSetCapacity(%x%Formatted,32),DllCall("GetNumberFormatEx","str","!x-sys-default-locale","uint",0,"str",%x%,"ptr",0,"str",%x%Formatted,"int",32)
						%x%Formatted := SubStr(%x%Formatted, 1, -3)
					}
				}
				honeyEarnedFormatted .= lastSuccess ? " *(Adjusted for " . lastSuccess . "fails)*" : ""		
				; format time stats for display
				hourGath := SessionGatherTimeWHT - lastGath, hourCon := SessionConvertTimeWHT - lastCon
				VarSetCapacity(totalTimeFormatted,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(SessionRuntime+(nowUnix()-MacroStartTime))*10000000,"wstr","hh:mm:ss","str",totalTimeFormatted,"int",256)
				VarSetCapacity(totalGathFormatted,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",(SessionGatherTimeWHT)*10000000,"wstr","hh:mm:ss","str",totalGathFormatted,"int",256)
				VarSetCapacity(totalConFormatted,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",SessionConvertTimeWHT*10000000,"wstr","hh:mm:ss","str",totalConFormatted,"int",256)
				VarSetCapacity(hourGathFormatted,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",hourGath*10000000,"wstr","hh:mm:ss","str",hourGathFormatted,"int",256)
				VarSetCapacity(hourConFormatted,256),DllCall("GetDurationFormatEx","str","!x-sys-default-locale","uint",0,"ptr",0,"int64",hourCon*10000000,"wstr","hh:mm:ss","str",hourConFormatted,"int",256)
				totalGathFormatted .= (SessionRuntime+(nowUnix()-MacroStartTime)) ? " (" . Round((SessionGatherTimeWHT) * 100 / (SessionRuntime+(nowUnix()-MacroStartTime))) . "%)" : ""
				totalConFormatted .= (SessionRuntime+(nowUnix()-MacroStartTime)) ? " (" . Round(SessionConvertTimeWHT * 100 / (SessionRuntime+(nowUnix()-MacroStartTime))) . "%)" : ""
				hourGathFormatted .= timeBetween ? " (" . Round(hourGath * 100 / timeBetween) . "%)" : ""
				hourConFormatted .= timeBetween ? " (" . Round(hourCon * 100 / timeBetween) . "%)" : ""
				;Determine Bloat
				WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
				bloatColor:=0xCC8048
				PixelSearch, bx2, by2, 0, 0, %windowWidth%, 150, %bloatColor%,0, Fast
				If (ErrorLevel=0) {
					nexty:=by2+1
					pixels:=1
					loop 38 {
						PixelGetColor, OutputVar, %bx2%, %nexty%, fast
						If (OutputVar=bloatColor) {
							nexty:=nexty+1
							pixels:=pixels+1
						} else {
							bloatPercent:=round(pixels/38*100, 0)
							break
						}
					}
				} else {
					bloatPercent:=0
				}
				bloatNum:=round((bloatPercent/100)*6, 2)
				; create postdata for hourly report
				message := "[" A_Hour ":" A_Min ":" A_Sec "]\n"
				. "**HOURLY REPORT:**\n"
				. "Hourly Average: " honeyAverageFormatted "\n"
				. "Last Hour Honey: " honeyEarnedFormatted "\n"
				. "Last Hour Gather: " hourGathFormatted "\n"
				. "Last Hour Convert: " hourConFormatted "\n"
				. "--------------------\n"
				. "Current Honey: " currentHoneyFormatted "\n"
				. "Session Time: " totalTimeFormatted "\n"
				. "Session Honey: " honeyTotalFormatted "\n"
				. "Session Gather: " totalGathFormatted "\n"
				. "Session Convert: " totalConFormatted "\n"
				. "--------------------\n"
				. "Total Vicious Kills:" SessionViciousKills "\n"
				. "Total Boss Kills:" SessionBossKills "\n"
				. "Total Bug Kills: " SessionBugKills "\n"
				. "Total Planters: " SessionPlantersCollected "\n"
				. "Quests Done: " SessionQuestsComplete "\n"
				. "Disconnects: " SessionDisconnects "\n"
				. "--------------------\n"
				. "Bloat: " bloatNum "\n"
				. "Nectars: Com " totalCom "%\nMot " totalMot "`% - Sat " totalSat "%\nRef " totalRef "`% - Inv " totalInv "%\n"
				. "**END OF REPORT**"
				
				postdata =
				(
				{
					"embeds": [{
						"description": "%message%",
						"color": "14052794"
					}]
				}
				)
			}
			else
			{
				; possibilities are first run or failed OCR
				if (currentHoney = 0)
				{
					; if next OCR succeeds, set divisor for Recent Hour honey
					lastSuccess += 1
					postdata =
					(
					{
						"embeds": [{
							"description": "[%A_Hour%:%A_Min%:%A_Sec%] Honey OCR Failed!\nHourly Update was skipped.\n**Debugging:**%ocrtext%",
							"color": "15085139"
						}]
					}
					)
				}
				else
				{
					; initialise honey variables
					startHoney := currentHoney
					honeyAverage := 0
				}
			}
			
			; update variables for future hourly updates
			lastHoney := (currentHoney) ? currentHoney : lastHoney
			lastGath := SessionGatherTimeWHT
			lastCon := SessionConvertTimeWHT
			lastHourlyUpdate := nowUnix()			
			; post to webhook
			try
			{
				wr := ComObjCreate("WinHTTP.WinHTTPRequest.5.1")
				wr.Option(9) := 2048
				wr.Open("POST", webhook)
				wr.SetRequestHeader("User-Agent", "AHK")
				wr.SetRequestHeader("Content-Type", "application/json")
				wr.Send(postdata)
				wr.WaitForResponse()
			}
		}
	}
}
nm_StatusLogReverseCheck(){
	global StatusLogReverse
	GuiControlGet, StatusLogReverse
	IniWrite, %StatusLogReverse%, nm_config.ini, Status, StatusLogReverse
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
	IniWrite, %FieldName1%, nm_config.ini, Gather, FieldName1
	CurrentFieldNum:=1
	IniWrite, %CurrentFieldNum%, nm_config.ini, Gather, CurrentFieldNum
	GuiControl,,CurrentField, %FieldName1%
	CurrentField:=FieldName1
	nm_FieldDefaults(1)
}
nm_TabGatherLock(){
	GuiControl, Disable, FieldName1
	GuiControl, Disable, FieldPattern1
	GuiControl, Disable, FieldPatternSize1
	GuiControl, Disable, FieldPatternReps1
	GuiControl, Disable, FieldPatternShift1
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
		IniWrite, %CurrentFieldNum%, nm_config.ini, Gather, CurrentFieldNum
		GuiControl,,CurrentField, %FieldName1%
		CurrentField:=FieldName1
		GuiControl, Disable, FieldPattern2
		GuiControl, Disable, FieldPatternSize2
		GuiControl, Disable, FieldPatternReps2
		GuiControl, Disable, FieldPatternShift2
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
	IniWrite, %FieldName2%, nm_config.ini, Gather, FieldName2
}
nm_FieldSelect3(){
	global CurrentField, CurrentFieldNum
	GuiControlGet, FieldName3
	if(FieldName3!="none"){
		GuiControl, Enable, FieldPattern3
		GuiControl, Enable, FieldPatternSize3
		GuiControl, Enable, FieldPatternReps3
		GuiControl, Enable, FieldPatternShift3
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
		IniWrite, %CurrentFieldNum%, nm_config.ini, Gather, CurrentFieldNum
		GuiControl,,CurrentField, %FieldName1%
		CurrentField:=FieldName1
		GuiControl, Disable, FieldPattern3
		GuiControl, Disable, FieldPatternSize3
		GuiControl, Disable, FieldPatternReps3
		GuiControl, Disable, FieldPatternShift3
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
	IniWrite, %FieldName3%, nm_config.ini, Gather, FieldName3
}
nm_FieldDefaults(num){
	global FieldDefault, FieldPattern1, FieldPattern2, FieldPattern3, FieldPatternSize1, FieldPatternSize2, FieldPatternSize3, FieldPatternReps1, FieldPatternReps2, FieldPatternReps3, FieldPatternShift1, FieldPatternShift2, FieldPatternShift3, FieldUntilMins1, FieldUntilMins2, FieldUntilMins3, FieldUntilPack1, FieldUntilPack2, FieldUntilPack3, FieldReturnType1, FieldReturnType2, FieldReturnType3, FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3, FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3, FieldRotateDirection1, FieldRotateDirection2, FieldRotateDirection3, FieldRotateTimes1, FieldRotateTimes2, FieldRotateTimes3, FieldDriftCheck1, FieldDriftCheck2, FieldDriftCheck3
	GuiControlGet, FieldName%num%
	if(FieldName%num%="none") {
		FieldPattern%num%:="Lines"
		FieldPatternSize%num%:="M"
		FieldPatternReps%num%:=3
		FieldPatternShift%num%:=0
		FieldUntilMins%num%:=15
		FieldUntilPack%num%:=100
		FieldReturnType%num%:="Walk"
		FieldSprinklerLoc%num%:="Center"
		FieldSprinklerDist%num%:=10
		FieldRotateDirection%num%:="None"
		FieldRotateTimes%num%:=1
		FieldDriftCheck%num%:=1
	} else {
		FieldPattern%num%:=FieldDefault[FieldName%num%]["pattern"][1]
		FieldPatternSize%num%:=FieldDefault[FieldName%num%]["pattern"][2]
		FieldPatternReps%num%:=FieldDefault[FieldName%num%]["pattern"][3]
		FieldPatternShift%num%:=0
		FieldUntilMins%num%:=15
		FieldUntilPack%num%:=100
		FieldReturnType%num%:="Walk"
		FieldSprinklerLoc%num%:=FieldDefault[FieldName%num%]["sprinkler"][1]
		FieldSprinklerDist%num%:=FieldDefault[FieldName%num%]["sprinkler"][2]
		FieldRotateDirection%num%:=FieldDefault[FieldName%num%]["camera"][1]
		FieldRotateTimes%num%:=FieldDefault[FieldName%num%]["camera"][2]
		FieldDriftCheck%num%:=1
	}
	GuiControl, ChooseString, FieldPattern%num%, % FieldPattern%num%
	GuiControl, ChooseString, FieldPatternSize%num%, % FieldPatternSize%num%
	GuiControl, ChooseString, FieldPatternReps%num%, % FieldPatternReps%num%
	GuiControl, ChooseString, FieldPatternShift%num%, % FieldPatternShift%num%
	GuiControl, ChooseString, FieldUntilMins%num%, % FieldUntilMins%num%
	GuiControl, ChooseString, FieldUntilPack%num%, % FieldUntilPack%num%
	GuiControl, ChooseString, FieldReturnType%num%, % FieldReturnType%num%
	GuiControl, ChooseString, FieldSprinklerLoc%num%, % FieldSprinklerLoc%num%
	GuiControl, ChooseString, FieldSprinklerDist%num%, % FieldSprinklerDist%num%
	GuiControl, ChooseString, FieldRotateDirection%num%, % FieldRotateDirection%num%
	GuiControl, ChooseString, FieldRotateTimes%num%, % FieldRotateTimes%num%
	GuiControl, ChooseString, FieldDriftCheck%num%, % FieldDriftCheck%num%
	FieldPatternN:=FieldPattern%num%
	FieldPatternSizeN:=FieldPatternSize%num%
	FieldPatternRepsN:=FieldPatternReps%num%
	FieldPatternShiftN:=FieldPatternShift%num%
	FieldUntilMinsN:=FieldUntilMins%num%
	FieldUntilPackN:=FieldUntilPack%num%
	FieldReturnTypeN:=FieldReturnType%num%
	FieldSprinklerLocN:=FieldSprinklerLoc%num%
	FieldSprinklerDistN:=FieldSprinklerDist%num%
	FieldRotateDirectionN:=FieldRotateDirection%num%
	FieldRotateTimesN:=FieldRotateTimes%num%
	FieldDriftCheckN:=FieldDriftCheck%num%
	IniWrite, %FieldPatternN%, nm_config.ini, Gather, FieldPattern%num%
	IniWrite, %FieldPatternSizeN%, nm_config.ini, Gather, FieldPatternSize%num%
	IniWrite, %FieldPatternRepsN%, nm_config.ini, Gather, FieldPatternReps%num%
	IniWrite, %FieldPatternShiftN%, nm_config.ini, Gather, FieldPatternShift%num%
	IniWrite, %FieldUntilMinsN%, nm_config.ini, Gather, FieldUntilMins%num%
	IniWrite, %FieldUntilPackN%, nm_config.ini, Gather, FieldUntilPack%num%
	IniWrite, %FieldReturnTypeN%, nm_config.ini, Gather, FieldReturnType%num%
	IniWrite, %FieldSprinklerLocN%, nm_config.ini, Gather, FieldSprinklerLoc%num%
	IniWrite, %FieldSprinklerDistN%, nm_config.ini, Gather, FieldSprinklerDist%num%
	IniWrite, %FieldRotateDirectionN%, nm_config.ini, Gather, FieldRotateDirection%num%
	IniWrite, %FieldRotateTimesN%, nm_config.ini, Gather, FieldRotateTimes%num%
	IniWrite, %FieldDriftCheckN%, nm_config.ini, Gather, FieldDriftCheck%num%
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
	IniWrite, %CurrentFieldNum%, nm_config.ini, Gather, CurrentFieldNum
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
	IniWrite, %CurrentFieldNum%, nm_config.ini, Gather, CurrentFieldNum
}
nm_savePlanters(){
	GuiControlGet PlanterHotkeySlot1
	GuiControlGet PlanterHotkeySlot2
	GuiControlGet PlanterHotkeySlot3
	;GuiControlGet PlanterSelectedName1
	;GuiControlGet PlanterSelectedName2
	;GuiControlGet PlanterSelectedName3
	IniWrite, %PlanterHotkeySlot1%, nm_config.ini, Planters, PlanterHotkeySlot1
	IniWrite, %PlanterHotkeySlot2%, nm_config.ini, Planters, PlanterHotkeySlot2
	IniWrite, %PlanterHotkeySlot3%, nm_config.ini, Planters, PlanterHotkeySlot3
	;IniWrite, %PlanterSelectedName1%, nm_config.ini, Planters, PlanterSelectedName1
	;IniWrite, %PlanterSelectedName2%, nm_config.ini, Planters, PlanterSelectedName2
	;IniWrite, %PlanterSelectedName3%, nm_config.ini, Planters, PlanterSelectedName3
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
	IniWrite, %PlanterPlacedBy1%, nm_config.ini, Planters, PlanterPlacedBy1
	IniWrite, %PlanterSelectedName1%, nm_config.ini, Planters, PlanterSelectedName1
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
	IniWrite, %PlanterPlacedBy2%, nm_config.ini, Planters, PlanterPlacedBy2
	IniWrite, %PlanterSelectedName2%, nm_config.ini, Planters, PlanterSelectedName2
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
	IniWrite, %PlanterPlacedBy3%, nm_config.ini, Planters, PlanterPlacedBy3
	IniWrite, %PlanterSelectedName3%, nm_config.ini, Planters, PlanterSelectedName3
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
	IniWrite, %Planter1Field1%, nm_config.ini, Planters, Planter1Field1
	IniWrite, %Planter1Until1%, nm_config.ini, Planters, Planter1Until1
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
	IniWrite, %Planter1Field2%, nm_config.ini, Planters, Planter1Field2
	IniWrite, %Planter1Until2%, nm_config.ini, Planters, Planter1Until2
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
	IniWrite, %Planter1Field3%, nm_config.ini, Planters, Planter1Field3
	IniWrite, %Planter1Until3%, nm_config.ini, Planters, Planter1Until3
}
nm_Planter1Field4(){
	GuiControlGet Planter1Field4
	GuiControlGet Planter1Until4
	IniWrite, %Planter1Field4%, nm_config.ini, Planters, Planter1Field4
	IniWrite, %Planter1Until4%, nm_config.ini, Planters, Planter1Until4

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
	IniWrite, %Planter2Field1%, nm_config.ini, Planters, Planter2Field1
	IniWrite, %Planter2Until1%, nm_config.ini, Planters, Planter2Until1
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
	IniWrite, %Planter2Field2%, nm_config.ini, Planters, Planter2Field2
	IniWrite, %Planter2Until2%, nm_config.ini, Planters, Planter2Until2
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
	IniWrite, %Planter2Field3%, nm_config.ini, Planters, Planter2Field3
	IniWrite, %Planter2Until3%, nm_config.ini, Planters, Planter2Until3
}
nm_Planter2Field4(){
	GuiControlGet Planter2Field4
	GuiControlGet Planter2Until4
	IniWrite, %Planter2Field4%, nm_config.ini, Planters, Planter2Field4
	IniWrite, %Planter2Until4%, nm_config.ini, Planters, Planter2Until4
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
	IniWrite, %Planter3Field1%, nm_config.ini, Planters, Planter3Field1
	IniWrite, %Planter3Until1%, nm_config.ini, Planters, Planter3Until1
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
	IniWrite, %Planter3Field2%, nm_config.ini, Planters, Planter3Field2
	IniWrite, %Planter3Until2%, nm_config.ini, Planters, Planter3Until2
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
	IniWrite, %Planter3Field3%, nm_config.ini, Planters, Planter3Field3
	IniWrite, %Planter3Until3%, nm_config.ini, Planters, Planter3Until3
}
nm_Planter3Field4(){
	GuiControlGet Planter3Field4
	GuiControlGet Planter3Until4
	IniWrite, %Planter3Field4%, nm_config.ini, Planters, Planter3Field4
	IniWrite, %Planter3Until4%, nm_config.ini, Planters, Planter3Until4
}
nm_SaveGather(){
	loop 3 {
		;GuiControlGet, FieldName%A_Index%
		GuiControlGet, FieldPattern%A_Index%
		GuiControlGet, FieldPatternSize%A_Index%
		GuiControlGet, FieldPatternReps%A_Index%
		GuiControlGet, FieldPatternShift%A_Index%
		GuiControlGet, FieldUntilMins%A_Index%
		GuiControlGet, FieldUntilPack%A_Index%
		GuiControlGet, FieldReturnType%A_Index%
		GuiControlGet, FieldSprinklerLoc%A_Index%
		GuiControlGet, FieldSprinklerDist%A_Index%
		GuiControlGet, FieldRotateDirection%A_Index%
		GuiControlGet, FieldRotateTimes%A_Index%
		GuiControlGet, FieldDriftCheck%A_Index%
		;FieldNameN:=FieldName%A_Index%
		FieldPatternN:=FieldPattern%A_Index%
		FieldPatternSizeN:=FieldPatternSize%A_Index%
		FieldPatternRepsN:=FieldPatternReps%A_Index%
		FieldPatternShiftN:=FieldPatternShift%A_Index%
		FieldUntilMinsN:=FieldUntilMins%A_Index%
		FieldUntilPackN:=FieldUntilPack%A_Index%
		FieldReturnTypeN:=FieldReturnType%A_Index%
		FieldSprinklerLocN:=FieldSprinklerLoc%A_Index%
		FieldSprinklerDistN:=FieldSprinklerDist%A_Index%
		FieldRotateDirectionN:=FieldRotateDirection%A_Index%
		FieldRotateTimesN:=FieldRotateTimes%A_Index%
		FieldDriftCheckN:=FieldDriftCheck%A_Index%
		;IniWrite, %FieldNameN%, nm_config.ini, Gather, FieldName%A_Index%
		IniWrite, %FieldPatternN%, nm_config.ini, Gather, FieldPattern%A_Index%
		IniWrite, %FieldPatternSizeN%, nm_config.ini, Gather, FieldPatternSize%A_Index%
		IniWrite, %FieldPatternRepsN%, nm_config.ini, Gather, FieldPatternReps%A_Index%
		IniWrite, %FieldPatternShiftN%, nm_config.ini, Gather, FieldPatternShift%A_Index%
		IniWrite, %FieldUntilMinsN%, nm_config.ini, Gather, FieldUntilMins%A_Index%
		IniWrite, %FieldUntilPackN%, nm_config.ini, Gather, FieldUntilPack%A_Index%
		IniWrite, %FieldReturnTypeN%, nm_config.ini, Gather, FieldReturnType%A_Index%
		IniWrite, %FieldSprinklerLocN%, nm_config.ini, Gather, FieldSprinklerLoc%A_Index%
		IniWrite, %FieldSprinklerDistN%, nm_config.ini, Gather, FieldSprinklerDist%A_Index%
		IniWrite, %FieldRotateDirectionN%, nm_config.ini, Gather, FieldRotateDirection%A_Index%
		IniWrite, %FieldRotateTimesN%, nm_config.ini, Gather, FieldRotateTimes%A_Index%
		IniWrite, %FieldDriftCheckN%, nm_config.ini, Gather, FieldDriftCheck%A_Index%
	}
}
nm_saveCollect(){
	global ClockCheck
	global MondoBuffCheck
	global MondoAction
	global AntPassCheck, AntPassAction
	global HoneyDisCheck
	global TreatDisCheck
	global BlueberryDisCheck
	global StrawberryDisCheck
	global CoconutDisCheck
	global RoyalJellyDisCheck
	global GlueDisCheck
	global StockingsCheck
	global WreathCheck
	global FeastCheck
	global CandlesCheck
	global SamovarCheck
	global LidArtCheck
	global GiftedViciousCheck
	global BugrunInterruptCheck
	global BugrunLadybugsCheck
	global BugrunRhinoBeetlesCheck
	global BugrunSpiderCheck
	global BugrunMantisCheck
	global BugrunScorpionsCheck
	global BugrunWerewolfCheck
	global BugrunLadybugsLoot
	global BugrunRhinoBeetlesLoot
	global BugrunSpiderLoot
	global BugrunMantisLoot
	global BugrunScorpionsLoot
	global BugrunWerewolfLoot
	global StingerCheck
	global TunnelBearCheck
	global TunnelBearBabyCheck
	global KingBeetleCheck
	global KingBeetleBabyCheck
	GuiControlGet ClockCheck
	GuiControlGet MondoBuffCheck
	GuiControlGet MondoAction
	GuiControlGet AntPassCheck
	GuiControlGet AntPassAction
	GuiControlGet HoneyDisCheck
	GuiControlGet TreatDisCheck
	GuiControlGet BlueberryDisCheck
	GuiControlGet StrawberryDisCheck
	GuiControlGet CoconutDisCheck
	GuiControlGet RoyalJellyDisCheck
	GuiControlGet GlueDisCheck
	GuiControlGet StockingsCheck
	GuiControlGet WreathCheck
	GuiControlGet FeastCheck
	GuiControlGet CandlesCheck
	GuiControlGet SamovarCheck
	GuiControlGet LidArtCheck
	GuiControlGet GiftedViciousCheck
	GuiControlGet BugrunInterruptCheck
	GuiControlGet BugrunLadybugsCheck
	GuiControlGet BugrunRhinoBeetlesCheck
	GuiControlGet BugrunSpiderCheck
	GuiControlGet BugrunMantisCheck
	GuiControlGet BugrunScorpionsCheck
	GuiControlGet BugrunWerewolfCheck
	GuiControlGet BugrunLadybugsLoot
	GuiControlGet BugrunRhinoBeetlesLoot
	GuiControlGet BugrunSpiderLoot
	GuiControlGet BugrunMantisLoot
	GuiControlGet BugrunScorpionsLoot
	GuiControlGet BugrunWerewolfLoot
	GuiControlGet StingerCheck
	GuiControlGet TunnelBearCheck
	GuiControlGet TunnelBearBabyCheck
	GuiControlGet KingBeetleCheck
	GuiControlGet KingBeetleBabyCheck
	IniWrite, %ClockCheck%, nm_config.ini, Collect, ClockCheck
	IniWrite, %MondoBuffCheck%, nm_config.ini, Collect, MondoBuffCheck
	IniWrite, %MondoAction%, nm_config.ini, Collect, MondoAction
	IniWrite, %AntPassCheck%, nm_config.ini, Collect, AntPassCheck
	IniWrite, %AntPassAction%, nm_config.ini, Collect, AntPassAction
	IniWrite, %HoneyDisCheck%, nm_config.ini, Collect, HoneyDisCheck
	IniWrite, %TreatDisCheck%, nm_config.ini, Collect, TreatDisCheck
	IniWrite, %BlueberryDisCheck%, nm_config.ini, Collect, BlueberryDisCheck
	IniWrite, %StrawberryDisCheck%, nm_config.ini, Collect, StrawberryDisCheck
	IniWrite, %CoconutDisCheck%, nm_config.ini, Collect, CoconutDisCheck
	IniWrite, %RoyalJellyDisCheck%, nm_config.ini, Collect, RoyalJellyDisCheck
	IniWrite, %GlueDisCheck%, nm_config.ini, Collect, GlueDisCheck
	IniWrite, %StockingsCheck%, nm_config.ini, Collect, StockingsCheck
	IniWrite, %WreathCheck%, nm_config.ini, Collect, WreathCheck
	IniWrite, %FeastCheck%, nm_config.ini, Collect, FeastCheck
	IniWrite, %CandlesCheck%, nm_config.ini, Collect, CandlesCheck
	IniWrite, %SamovarCheck%, nm_config.ini, Collect, SamovarCheck
	IniWrite, %LidArtCheck%, nm_config.ini, Collect, LidArtCheck
	IniWrite, %GiftedViciousCheck%, nm_config.ini, Collect, GiftedViciousCheck
	IniWrite, %BugrunInterruptCheck%, nm_config.ini, Collect, BugrunInterruptCheck
	IniWrite, %BugrunLadybugsCheck%, nm_config.ini, Collect, BugrunLadybugsCheck
	IniWrite, %BugrunRhinoBeetlesCheck%, nm_config.ini, Collect, BugrunRhinoBeetlesCheck
	IniWrite, %BugrunSpiderCheck%, nm_config.ini, Collect, BugrunSpiderCheck
	IniWrite, %BugrunMantisCheck%, nm_config.ini, Collect, BugrunMantisCheck
	IniWrite, %BugrunScorpionsCheck%, nm_config.ini, Collect, BugrunScorpionsCheck
	IniWrite, %BugrunWerewolfCheck%, nm_config.ini, Collect, BugrunWerewolfCheck
	IniWrite, %BugrunLadybugsLoot%, nm_config.ini, Collect, BugrunLadybugsLoot
	IniWrite, %BugrunRhinoBeetlesLoot%, nm_config.ini, Collect, BugrunRhinoBeetlesLoot
	IniWrite, %BugrunSpiderLoot%, nm_config.ini, Collect, BugrunSpiderLoot
	IniWrite, %BugrunMantisLoot%, nm_config.ini, Collect, BugrunMantisLoot
	IniWrite, %BugrunScorpionsLoot%, nm_config.ini, Collect, BugrunScorpionsLoot
	IniWrite, %BugrunWerewolfLoot%, nm_config.ini, Collect, BugrunWerewolfLoot
	IniWrite, %StingerCheck%, nm_config.ini, Collect, StingerCheck
	IniWrite, %TunnelBearCheck%, nm_config.ini, Collect, TunnelBearCheck
	IniWrite, %TunnelBearBabyCheck%, nm_config.ini, Collect, TunnelBearBabyCheck
	IniWrite, %KingBeetleCheck%, nm_config.ini, Collect, KingBeetleCheck
	IniWrite, %KingBeetleBabyCheck%, nm_config.ini, Collect, KingBeetleBabyCheck
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
	GuiControl, disable, AntPassCheck
	GuiControl, disable, AntPassAction
	GuiControl, disable, HoneyDisCheck
	GuiControl, disable, TreatDisCheck
	GuiControl, disable, BlueberryDisCheck
	GuiControl, disable, StrawberryDisCheck
	GuiControl, disable, CoconutDisCheck
	GuiControl, disable, RoyalJellyDisCheck
	GuiControl, disable, GlueDisCheck
	GuiControl, disable, StockingsCheck
	GuiControl, disable, WreathCheck
	GuiControl, disable, FeastCheck
	GuiControl, disable, CandlesCheck
	GuiControl, disable, SamovarCheck
	GuiControl, disable, LidArtCheck
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
}
nm_TabCollectUnLock(){
	GuiControl, enable, ClockCheck
	GuiControl, enable, MondoBuffCheck
	GuiControl, enable, MondoAction
	GuiControl, enable, AntPassCheck
	GuiControl, enable, AntPassAction
	GuiControl, enable, HoneyDisCheck
	GuiControl, enable, TreatDisCheck
	GuiControl, enable, BlueberryDisCheck
	GuiControl, enable, StrawberryDisCheck
	GuiControl, enable, CoconutDisCheck
	GuiControl, enable, RoyalJellyDisCheck
	GuiControl, enable, GlueDisCheck
	GuiControl, enable, StockingsCheck
	GuiControl, enable, WreathCheck
	GuiControl, enable, FeastCheck
	GuiControl, enable, CandlesCheck
	GuiControl, enable, SamovarCheck
	GuiControl, enable, LidArtCheck
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
}
nm_saveBoost(){
	global FieldBoosterMins
	global HotkeyTime2
	global HotkeyTime3
	global HotkeyTime4
	global HotkeyTime5
	global HotkeyTime6
	global HotkeyTime7
	global HotkeyTimeUnits2
	global HotkeyTimeUnits3
	global HotkeyTimeUnits4
	global HotkeyTimeUnits5
	global HotkeyTimeUnits6
	global HotkeyTimeUnits7
	global BoostChaserCheck
	GuiControlGet FieldBoosterMins
	GuiControlGet HotkeyTime2
	GuiControlGet HotkeyTime3
	GuiControlGet HotkeyTime4
	GuiControlGet HotkeyTime5
	GuiControlGet HotkeyTime6
	GuiControlGet HotkeyTime7
	GuiControlGet HotkeyTimeUnits2
	GuiControlGet HotkeyTimeUnits3
	GuiControlGet HotkeyTimeUnits4
	GuiControlGet HotkeyTimeUnits5
	GuiControlGet HotkeyTimeUnits6
	GuiControlGet HotkeyTimeUnits7
	GuiControlGet BoostChaserCheck
	IniWrite, %FieldBoosterMins%, nm_config.ini, Boost, FieldBoosterMins
	IniWrite, %HotkeyTime2%, nm_config.ini, Boost, HotkeyTime2
	IniWrite, %HotkeyTime3%, nm_config.ini, Boost, HotkeyTime3
	IniWrite, %HotkeyTime4%, nm_config.ini, Boost, HotkeyTime4
	IniWrite, %HotkeyTime5%, nm_config.ini, Boost, HotkeyTime5
	IniWrite, %HotkeyTime6%, nm_config.ini, Boost, HotkeyTime6
	IniWrite, %HotkeyTime7%, nm_config.ini, Boost, HotkeyTime7
	IniWrite, %HotkeyTimeUnits2%, nm_config.ini, Boost, HotkeyTimeUnits2
	IniWrite, %HotkeyTimeUnits3%, nm_config.ini, Boost, HotkeyTimeUnits3
	IniWrite, %HotkeyTimeUnits4%, nm_config.ini, Boost, HotkeyTimeUnits4
	IniWrite, %HotkeyTimeUnits5%, nm_config.ini, Boost, HotkeyTimeUnits5
	IniWrite, %HotkeyTimeUnits6%, nm_config.ini, Boost, HotkeyTimeUnits6
	IniWrite, %HotkeyTimeUnits7%, nm_config.ini, Boost, HotkeyTimeUnits7
	IniWrite, %BoostChaserCheck%, nm_config.ini, Boost, BoostChaserCheck
}
nm_BoostChaserCheck(){
	global BoostChaserCheck
	global AutoFieldBoostActive
	GuiControlGet BoostChaserCheck
	IniWrite, %BoostChaserCheck%, nm_config.ini, Boost, BoostChaserCheck
	;disable AutoFieldBoost (mutually exclusive features)
	if(BoostChaserCheck) {
		AutoFieldBoostActive:=0
		GuiControl,afb:, AutoFieldBoostActive, %AutoFieldBoostActive%
		GuiControl,, AutoFieldBoostActive, %AutoFieldBoostActive%
		IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
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
	IniWrite, %FieldBooster1%, nm_config.ini, Boost, FieldBooster1
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
	IniWrite, %FieldBooster2%, nm_config.ini, Boost, FieldBooster2
}
nm_FieldBooster3(){
	global FieldBooster3
	GuiControlGet FieldBooster3
	if(FieldBooster3=FieldBooster1 || FieldBooster3=FieldBooster2) {
		FieldBooster3=None
		GuiControl, ChooseString, FieldBooster3, None
	}
	IniWrite, %FieldBooster3%, nm_config.ini, Boost, FieldBooster3
}
nm_HotkeyWhile2(){
	global HotkeyWhile2
	GuiControlGet HotkeyWhile2
	if(HotkeyWhile2="never") {
		GuiControl,hide, HotkeyTime2
		GuiControl,hide, HotkeyTimeUnits2
		GuiControl, hide, HBText2
	} else if(HotkeyWhile2="microconverter" || HotkeyWhile2="whirligig" || HotkeyWhile2="enzymes") {
		if(HotkeyWhile2="microconverter")
			GuiControl,,HBText2, @ Full Pack
		else if (HotkeyWhile2="whirligig")
			GuiControl,,HBText2, @ Hive Return
		else if (HotkeyWhile2="enzymes")
			GuiControl,,HBText2, @ Conv Balloon
		GuiControl, show, HBText2
		GuiControl,hide, HotkeyTime2
		GuiControl,hide, HotkeyTimeUnits2
	} else {
		GuiControl,show, HotkeyTime2
		GuiControl,show, HotkeyTimeUnits2
		GuiControl, hide, HBText2
	}
	IniWrite, %HotkeyWhile2%, nm_config.ini, Boost, HotkeyWhile2
}
nm_HotkeyWhile3(){
	global HotkeyWhile3
	GuiControlGet HotkeyWhile3
	if(HotkeyWhile3="never") {
		GuiControl,hide, HotkeyTime3
		GuiControl,hide, HotkeyTimeUnits3
		GuiControl, hide, HBText3
	} else if(HotkeyWhile3="microconverter" || HotkeyWhile3="whirligig" || HotkeyWhile3="enzymes") {
		if(HotkeyWhile3="microconverter")
			GuiControl,,HBText3, @ Full Pack
		else if (HotkeyWhile3="whirligig")
			GuiControl,,HBText3, @ Hive Return
		else if (HotkeyWhile3="enzymes")
			GuiControl,,HBText3, @ Conv Balloon
		GuiControl, show, HBText3
		GuiControl,hide, HotkeyTime3
		GuiControl,hide, HotkeyTimeUnits3
	} else {
		GuiControl,show, HotkeyTime3
		GuiControl,show, HotkeyTimeUnits3
		GuiControl, hide, HBText3
	}
	IniWrite, %HotkeyWhile3%, nm_config.ini, Boost, HotkeyWhile3
}
nm_HotkeyWhile4(){
	global HotkeyWhile4
	GuiControlGet HotkeyWhile4
	if(HotkeyWhile4="never") {
		GuiControl,hide, HotkeyTime4
		GuiControl,hide, HotkeyTimeUnits4
		GuiControl, hide, HBText4
	} else if(HotkeyWhile4="microconverter" || HotkeyWhile4="whirligig" || HotkeyWhile4="enzymes") {
		if(HotkeyWhile4="microconverter")
			GuiControl,,HBText4, @ Full Pack
		else if (HotkeyWhile4="whirligig")
			GuiControl,,HBText4, @ Hive Return
		else if (HotkeyWhile4="enzymes")
			GuiControl,,HBText4, @ Conv Balloon
		GuiControl, show, HBText4
		GuiControl,hide, HotkeyTime4
		GuiControl,hide, HotkeyTimeUnits4
	} else {
		GuiControl,show, HotkeyTime4
		GuiControl,show, HotkeyTimeUnits4
		GuiControl, hide, HBText4
	}
	IniWrite, %HotkeyWhile4%, nm_config.ini, Boost, HotkeyWhile4
}
nm_HotkeyWhile5(){
	global HotkeyWhile5
	GuiControlGet HotkeyWhile5
	if(HotkeyWhile5="never") {
		GuiControl,hide, HotkeyTime5
		GuiControl,hide, HotkeyTimeUnits5
		GuiControl, hide, HBText5
	} else if(HotkeyWhile5="microconverter" || HotkeyWhile5="whirligig" || HotkeyWhile5="enzymes") {
		if(HotkeyWhile5="microconverter")
			GuiControl,,HBText5, @ Full Pack
		else if (HotkeyWhile5="whirligig")
			GuiControl,,HBText5, @ Hive Return
		else if (HotkeyWhile5="enzymes")
			GuiControl,,HBText5, @ Conv Balloon
		GuiControl, show, HBText5
		GuiControl,hide, HotkeyTime5
		GuiControl,hide, HotkeyTimeUnits5
	} else {
		GuiControl,show, HotkeyTime5
		GuiControl,show, HotkeyTimeUnits5
		GuiControl, hide, HBText5
	}
	IniWrite, %HotkeyWhile5%, nm_config.ini, Boost, HotkeyWhile5
}
nm_HotkeyWhile6(){
	global HotkeyWhile6
	GuiControlGet HotkeyWhile6
	if(HotkeyWhile6="never") {
		GuiControl,hide, HotkeyTime6
		GuiControl,hide, HotkeyTimeUnits6
		GuiControl, hide, HBText6
	} else if(HotkeyWhile6="microconverter" || HotkeyWhile6="whirligig" || HotkeyWhile6="enzymes") {
		if(HotkeyWhile6="microconverter")
			GuiControl,,HBText6, @ Full Pack
		else if (HotkeyWhile6="whirligig")
			GuiControl,,HBText6, @ Hive Return
		else if (HotkeyWhile6="enzymes")
			GuiControl,,HBText6, @ Conv Balloon
		GuiControl, show, HBText6
		GuiControl,hide, HotkeyTime6
		GuiControl,hide, HotkeyTimeUnits6
	} else {
		GuiControl,show, HotkeyTime6
		GuiControl,show, HotkeyTimeUnits6
		GuiControl, hide, HBText6
	}
	IniWrite, %HotkeyWhile6%, nm_config.ini, Boost, HotkeyWhile6
}
nm_HotkeyWhile7(){
	global HotkeyWhile7
	GuiControlGet HotkeyWhile7
	if(HotkeyWhile7="never") {
		GuiControl,hide, HotkeyTime7
		GuiControl,hide, HotkeyTimeUnits7
		GuiControl, hide, HBText7
	} else if(HotkeyWhile7="microconverter" || HotkeyWhile7="whirligig" || HotkeyWhile7="enzymes") {
		if(HotkeyWhile7="microconverter")
			GuiControl,,HBText7, @ Full Pack
		else if (HotkeyWhile7="whirligig")
			GuiControl,,HBText7, @ Hive Return
		else if (HotkeyWhile7="enzymes")
			GuiControl,,HBText7, @ Conv Balloon
		GuiControl, show, HBText7
		GuiControl,hide, HotkeyTime7
		GuiControl,hide, HotkeyTimeUnits7
	} else {
		GuiControl,show, HotkeyTime7
		GuiControl,show, HotkeyTimeUnits7
		GuiControl, hide, HBText7
	}
	IniWrite, %HotkeyWhile7%, nm_config.ini, Boost, HotkeyWhile7
}
nm_savequest(){
	GuiControlGet, PolarQuestCheck
	GuiControlGet, PolarQuestGatherInterruptCheck
	GuiControlGet, HoneyQuestCheck
	GuiControlGet, BlackQuestCheck
	GuiControlGet, BuckoQuestCheck
	GuiControlGet, BuckoQuestGatherInterruptCheck
	GuiControlGet, RileyQuestCheck
	GuiControlGet, RileyQuestGatherInterruptCheck
	GuiControlGet, QuestGatherMins
	IniWrite, %PolarQuestCheck%, nm_config.ini, Quests, PolarQuestCheck
	IniWrite, %PolarQuestGatherInterruptCheck%, nm_config.ini, Quests, PolarQuestGatherInterruptCheck
	IniWrite, %HoneyQuestCheck%, nm_config.ini, Quests, HoneyQuestCheck
	IniWrite, %BlackQuestCheck%, nm_config.ini, Quests, BlackQuestCheck
	IniWrite, %BuckoQuestCheck%, nm_config.ini, Quests, BuckoQuestCheck
	IniWrite, %BuckoQuestGatherInterruptCheck%, nm_config.ini, Quests, BuckoQuestGatherInterruptCheck
	IniWrite, %RileyQuestCheck%, nm_config.ini, Quests, RileyQuestCheck
	IniWrite, %RileyQuestGatherInterruptCheck%, nm_config.ini, Quests, RileyQuestGatherInterruptCheck
	IniWrite, %QuestGatherMins%, nm_config.ini, Quests, QuestGatherMins
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
	IniWrite, %TotalRuntime%, nm_config.ini, Status, TotalRuntime
	IniWrite, %TotalGatherTime%, nm_config.ini, Status, TotalGatherTime
	IniWrite, %TotalConvertTime%, nm_config.ini, Status, TotalConvertTime
	IniWrite, %TotalViciousKills%, nm_config.ini, Status, TotalViciousKills
	IniWrite, %TotalBossKills%, nm_config.ini, Status, TotalBossKills
	IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
	IniWrite, %TotalPlantersCollected%, nm_config.ini, Status, TotalPlantersCollected
	IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
	IniWrite, %TotalDisconnects%, nm_config.ini, Status, TotalDisconnects
	nm_setStats()
}
;;;;;;;;; START AFB
nm_autoFieldBoostButton(){
	nm_autoFieldBoostGui()
}
nm_autoFieldBoostGui(){
	gui, afb:destroy
	;global AutoFieldBoostActive
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
	Menu, tray, Icon, auryn.ico, 1, 1
	gui afb:+border
	gui afb:font, s8 w400 cBlack
	IniRead, AutoFieldBoostActive, nm_config.ini, Boost, AutoFieldBoostActive
	IniRead, AutoFieldBoostRefresh, nm_config.ini, Boost, AutoFieldBoostRefresh
	Gui, afb:Add, Checkbox, x5 y5 vAutoFieldBoostActive gnm_autoFieldBoostCheck checked%AutoFieldBoostActive%, Activate Automatic Field Boost for Gathering Field:
	gui afb:font, s8 w800 cBlue
	Gui, afb:Add, text, x263 y5 left vAFBcurrentField, %currentField%
	gui afb:font, s8 w400 cBlack
	Gui, afb:Add, button, x20 y22 w120 h15 gnm_AFBHelpButton, What does this do?
	gui afb:add, text,x5 y35 +left +BackgroundTrans,----------------------------------------------------------------------------------------------------------------------
	Gui, afb:Add, text, x20 y48, Re-Buff Field Boost Every:
	Gui, afb:Add, DropDownList, x147 y46 w45 h150 vAutoFieldBoostRefresh gnm_saveAFBConfig, %AutoFieldBoostRefresh%||8|8.5|9|9.5|10|10.5|11|11.5|12|12.5|13|13.5|14|14.5|15
	Gui, afb:Add, text, x195 y48, Minutes
	Gui, afb:Add, button, x5 y48 w10 h15 gnm_AFBRebuffHelpButton, ?
	gui afb:add, text,x20 y70 +left +BackgroundTrans,Use
	gui afb:add, text,x5 y73 +left +BackgroundTrans,___________________________________________________________
	gui afb:font, s10 w400 cBlack
	IniRead, AFBDiceEnable, nm_config.ini, Boost, AFBDiceEnable
	IniRead, AFBGlitterEnable, nm_config.ini, Boost, AFBGlitterEnable
	IniRead, AFBFieldEnable, nm_config.ini, Boost, AFBFieldEnable
	Gui, afb:Add, button, x5 y90 w10 h15 gnm_AFBDiceEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y90 vAFBDiceEnable gnm_AFBDiceEnableCheck checked%AFBDiceEnable%, Dice:
	Gui, afb:Add, button, x5 y113 w10 h15 gnm_AFBGlitterEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y113 vAFBGlitterEnable gnm_AFBGlitterEnableCheck checked%AFBGlitterEnable%, Glitter:
	Gui, afb:Add, button, x5 y136 w10 h15 gnm_AFBFieldEnableHelpButton, ?
	Gui, afb:Add, Checkbox, x20 y136 vAFBFieldEnable gnm_saveAFBConfig checked%AFBFieldEnable%, Free Field Boosters
	gui afb:font, s8 w400 cBlack
	gui afb:add, text,x80 y70 +left +BackgroundTrans,Hotbar Slot
	IniRead, AFBDiceHotbar, nm_config.ini, Boost, AFBDiceHotbar
	IniRead, AFBGlitterHotbar, nm_config.ini, Boost, AFBGlitterHotbar
	Gui, afb:Add, DropDownList, x80 y88 w50 h120 vAFBDiceHotbar gnm_saveAFBConfig, %AFBDiceHotbar%||None|2|3|4|5|6|7
	Gui, afb:Add, DropDownList, x80 y110 w50 h120 vAFBGlitterHotbar gnm_saveAFBConfig, %AFBGlitterHotbar%||None|2|3|4|5|6|7
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
	IniRead, AFBDiceLimitEnable, nm_config.ini, Boost, AFBDiceLimitEnable
	if(not AFBDiceLimitEnable)
		DiceSel:="None"
	else
		DiceSel:="Limit"
	IniRead, AFBGlitterLimitEnable, nm_config.ini, Boost, AFBGlitterLimitEnable
	if(not AFBGlitterLimitEnable)
		GlitterSel:="None"
	else
		GlitterSel:="Limit"
	IniRead, AFBHoursLimitEnable, nm_config.ini, Boost, AFBHoursLimitEnable
	if(not AFBHoursLimitEnable)
		HoursSel:="None"
	else
		HoursSel:="Limit"
	Gui, afb:Add, button, x170 y90 w10 h15 gnm_AFBDiceLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y88 w50 h120 vAFBDiceLimitEnableSel gnm_AFBDiceLimitEnable, %DiceSel%||Limit|None
	Gui, afb:Add, button, x170 y113 w10 h15 gnm_AFBGlitterLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y110 w50 h120 vAFBGlitterLimitEnableSel gnm_AFBGlitterLimitEnable, %GlitterSel%||Limit|None
	Gui, afb:Add, button, x170 y156 w10 h15 gnm_AFBHoursLimitEnableHelpButton, ?
	Gui, afb:Add, DropDownList, x185 y152 w50 h120 vAFBHoursLimitEnableSel gnm_AFBHoursLimitEnable, %HoursSel%||Limit|None
	gui afb:add, text,x240 y90 +left +BackgroundTrans,to
	gui afb:add, text,x305 y90 +left +BackgroundTrans,Dice Used
	gui afb:add, text,x240 y113 +left +BackgroundTrans,to
	gui afb:add, text,x305 y113 +left +BackgroundTrans,Glitter Used
	gui afb:add, text,x240 y156 +left +BackgroundTrans,to
	gui afb:add, text,x305 y156 +left +BackgroundTrans,Hours
	IniRead, AFBDiceLimit, nm_config.ini, Boost, AFBDiceLimit
	IniRead, AFBGlitterLimit, nm_config.ini, Boost, AFBGlitterLimit
	IniRead, AFBHoursLimitNum, nm_config.ini, Boost, AFBHoursLimit
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
	IniWrite, %AFBdiceUsed%, nm_config.ini, Boost, AFBdiceUsed	
}
nm_resetUsedGlitter(){
	IniWrite, 0, nm_config.ini, Boost, AFBglitterUsed
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
			IniWrite, 0, nm_config.ini, Boost, AFBdiceUsed
			IniWrite, 0, nm_config.ini, Boost, AFBglitterUsed
			BoostChaserCheck:=0
			GuiControl,1:,BoostChaserCheck, %BoostChaserCheck%
			IniWrite, %BoostChaserCheck%, nm_config.ini, Boost, BoostChaserCheck
		} else {
			AutoFieldBoostActive:=0
			Guicontrol,,AutoFieldBoostActive,0
		}
	}
	IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
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
		IniWrite, %AFBdiceUsed%, nm_config.ini, Boost, AFBdiceUsed
		if(AFBDiceLimitEnableSel="None"){
			GuiControl afb:disable, AFBDiceLimit
		} else if(AFBDiceLimitEnableSel="Limit"){
			GuiControl afb:enable, AFBDiceLimit
		}
	}
	IniWrite, %AFBDiceEnable%, nm_config.ini, Boost, AFBDiceEnable
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
		IniWrite, %AFBglitterUsed%, nm_config.ini, Boost, AFBglitterUsed
		if(AFBGlitterLimitEnableSel="None"){
			GuiControl afb:disable, AFBGlitterLimit
		} else if(AFBGlitterLimitEnableSel="Limit"){
			GuiControl afb:enable, AFBGlitterLimit
		}
	}
	IniWrite, %AFBGlitterEnable%, nm_config.ini, Boost, AFBGlitterEnable
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
	IniWrite, %val%, nm_config.ini, Boost, AFBDiceLimitEnable
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
	IniWrite, %val%, nm_config.ini, Boost, AFBGlitterLimitEnable
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
	IniWrite, %val%, nm_config.ini, Boost, AFBHoursLimitEnable
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
	GuiControlGet, AutoFieldBoostRefresh
	GuiControlGet, AFBFieldEnable
	GuiControlGet, AFBDiceLimit
	GuiControlGet, AFBGlitterLimit
	GuiControlGet, AFBHoursLimit
	GuiControlGet, AFBDiceHotbar
	GuiControlGet, AFBGlitterHotbar
	IniWrite, %AutoFieldBoostRefresh%, nm_config.ini, Boost, AutoFieldBoostRefresh
	IniWrite, %AFBFieldEnable%, nm_config.ini, Boost, AFBFieldEnable
	IniWrite, %AFBDiceLimit%, nm_config.ini, Boost, AFBDiceLimit
	IniWrite, %AFBGlitterLimit%, nm_config.ini, Boost, AFBGlitterLimit
	IniWrite, %AFBHoursLimit%, nm_config.ini, Boost, AFBHoursLimit
	IniWrite, %AFBDiceHotbar%, nm_config.ini, Boost, AFBDiceHotbar
	IniWrite, %AFBGlitterHotbar%, nm_config.ini, Boost, AFBGlitterHotbar
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
		IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
		return
	}
	
	if(not AFBrollingDice && ((nowUnix()-FieldLastBoosted)>(AutoFieldBoostRefresh*60) || (nowUnix()-FieldLastBoosted)<0)){ ;refresh period exceeded
		;check for field boost stack reset
		if((nowUnix()-FieldLastBoosted)>=(15*60)){ ;longer than 15 mins since last boost buff
			FieldBoostStacks:=0
			FieldLastBoostedBy:="None"
			IniWrite, %FieldBoostStacks%, nm_config.ini, Boost, FieldBoostStacks
			IniWrite, %FieldLastBoostedBy%, nm_config.ini, Boost, FieldLastBoostedBy
		}
		;free booster first
		if(AFBFieldEnable){
			;determine which booster applies
			if(FieldBooster[fieldName].booster!="none") {
				booster:=FieldBooster[fieldName].booster
				boosterTimer:=("Last" . booster . "Boost")
				IniRead, boosterTimer, nm_config.ini, Boost, %boosterTimer%
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
		nm_toBooster("mount")
	}
	AFBuseBooster:=0
	sleep, 5000
	;check if gathering field was boosted
	if(nm_fieldBoostCheck(CurrentField)) {
		nm_setStatus(0, "Field was Boosted: Booster")
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:=boosterName
		IniWrite, %FieldLastBoosted%, nm_config.ini, Boost, FieldLastBoosted
		IniWrite, %FieldLastBoosted%, nm_config.ini, Boost, %boosterTimer%
		IniWrite, %FieldLastBoostedBy%, nm_config.ini, Boost, FieldLastBoostedBy
		FieldBoostStacks:=FieldBoostStacks+FieldBooster[CurrentField].stacks
		IniWrite, %FieldBoostStacks%, nm_config.ini, Boost, FieldBoostStacks
		if(FieldBoostStacks>4)
			return
	}
	;determine next boost item
	;is it dice?
	if(AFBDiceEnable && (FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster"|| FieldLastBoostedBy="glitter" || (FieldLastBoostedBy="dice" && not AFBGlitterEnable))) {
		FieldNextBoostedBy:="dice"
		IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
	}
	;is it glitter?
	else if(AFBGlitterEnable && (FieldLastBoostedBy="dice" || ((FieldLastBoostedBy="bbooster" || FieldLastBoostedBy="rbooster" || FieldLastBoostedBy="mbooster")|| not AFBDiceEnable) || (FieldLastBoostedBy="glitter" && not AFBDiceEnable))) {
		FieldNextBoostedBy:="glitter"
		IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
	}
	;is it booster?
	else if(AFBFieldEnable && not AFBDiceEnable && not AFBGlitterEnable) {
		FieldNextBoostedBy:=boosterName
		IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
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
		IniWrite, %AFBdiceUsed%, nm_config.ini, Boost, AFBdiceUsed
		if(AFBDiceLimitEnable && AFBdiceUsed >= AFBDiceLimit) {
			AFBrollingDice:=0
			AFBDiceEnable:=0
			Guicontrol,afb:,AFBDiceEnable,%AFBDiceEnable%
			IniWrite, %AFBDiceEnable%, nm_config.ini, Boost, AFBDiceEnable
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			AutoFieldBoostActive:=0
			Guicontrol,afb:,AutoFieldBoostActive,%AutoFieldBoostActive%
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
			IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
		}
	} else {
		AFBrollingDice:=0
		nm_setStatus(0, "Field was Boosted: Dice")
		if(FieldLastBoostedBy!="dice" || FieldBoostStacks=0) {
			FieldBoostStacks:=FieldBoostStacks+1
			FieldLastBoostedBy:="dice"
			IniWrite, %FieldLastBoostedBy%, nm_config.ini, Boost, FieldLastBoostedBy
			IniWrite, %FieldBoostStacks%, nm_config.ini, Boost, FieldBoostStacks
		}
		FieldLastBoosted:=nowUnix()
		IniWrite, %FieldLastBoosted%, nm_config.ini, Boost, FieldLastBoosted
		;determine next boost item
		;is it booster?
		if(FieldBooster[currentField].booster="blue") {
			boosterName:="bbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastBlueBoost
		}
		else if(FieldBooster[currentField].booster="red") {
			boosterName:="rbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastRedBoost
		}
		else if(FieldBooster[currentField].booster="mountain") {
			boosterName:="mbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it glitter?
		else if(AFBGlitterEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it dice?
		else if(not AFBGlitterEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
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
		IniWrite, %AFBglitterUsed%, nm_config.ini, Boost, AFBglitterUsed
		if(AFBGlitterLimitEnable && AFBglitterUsed >= AFBglitterLimit) {
			AFBGlitterEnable:=0
			Guicontrol,afb:,AFBGlitterEnable,%AFBGlitterEnable%
			IniWrite, %AFBGlitterEnable%, nm_config.ini, Boost, AFBGlitterEnable
		}
		if(not AFBGlitterEnable and not AFBDiceEnable){
			AutoFieldBoostActive:=0
			Guicontrol,afb:,AutoFieldBoostActive,%AutoFieldBoostActive%
			GuiControl,1:,AutoFieldBoostButton, Auto Field Boost`n[OFF]
			IniWrite, %AutoFieldBoostActive%, nm_config.ini, Boost, AutoFieldBoostActive
		}
		AFBuseGlitter:=0
		FieldLastBoosted:=nowUnix()
		FieldLastBoostedBy:="glitter"
		IniWrite, %FieldLastBoosted%, nm_config.ini, Boost, FieldLastBoosted
		IniWrite, %FieldLastBoostedBy%, nm_config.ini, Boost, FieldLastBoostedBy
		FieldBoostStacks:=FieldBoostStacks+1
		IniWrite, %FieldBoostStacks%, nm_config.ini, Boost, FieldBoostStacks
		;determine next boost item
		;is it booster?
		if(FieldBooster[currentField].booster="blue") {
			boosterName:="bbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastBlueBoost
		}
		else if(FieldBooster[currentField].booster="red") {
			boosterName:="rbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastRedBoost
		}
		else if(FieldBooster[currentField].booster="mountain") {
			boosterName:="mbooster"
			IniRead, boostTimer, nm_config.ini, Boost, LastMountainBoost
		}
		if(AFBFieldEnable && (nowUnix()-boostTimer)>(3600-AutoFieldBoostRefresh*60)) {
			FieldNextBoostedBy:=boosterName
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it dice?
		else if(AFBDiceEnable) {
			FieldNextBoostedBy:="dice"
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
		}
		;is it glitter?
		else if(not AFBDiceEnable) {
			FieldNextBoostedBy:="glitter"
			IniWrite, %FieldNextBoostedBy%, nm_config.ini, Boost, FieldNextBoostedBy
		}
		
	}
}
;;;;; END AFB

nm_SaveGui(){
	WinGetPos, windowX, windowY, windowWidth, windowHeight, Natro Macro
	IniWrite, %windowX%, nm_config.ini, Settings, GuiX
	IniWrite, %windowY%, nm_config.ini, Settings, GuiY
}
nm_moveSpeed(){
	global MoveSpeedNum
	GuiControlGet, MoveSpeed
	if MoveSpeed is number
	{
		if MoveSpeed>0 
		{
			MoveSpeedNum:=MoveSpeed
			IniWrite, %MoveSpeed%, nm_config.ini, Settings, MoveSpeed
		} else {
			GuiControl, Text, MoveSpeed, %MoveSpeedNum%
		}
	} else {
		GuiControl, Text, MoveSpeed, %MoveSpeedNum%
	}
	;calculate and save MoveSpeedFactor
	MoveSpeedFactor:=round(18/MoveSpeed, 2)
	IniWrite, %MoveSpeedFactor%, nm_config.ini, Settings, MoveSpeedFactor
}
nm_HiveVariation(){
	GuiControlGet HiveVariation
	if(HiveVariation<0 || HiveVariation>255){
		IniRead, HiveVariation, nm_config.ini, Settings, HiveVariation
		GuiControl,,HiveVariation, %HiveVariation%
		msgbox Hive Image Variation can only be 0-255.`n`n0 indicates a perfect pixel-by-pixel image match.`n`n255 will match almost anything.`n`nIn general, you want this setting to be as small as possible.
	} else {
		IniWrite, %HiveVariation%, nm_config.ini, Settings, HiveVariation
	}
}
nm_saveConfig(){
	global HiveSlot
	global HiveBees
	global MoveMethod
	global SprinklerType
	global ConvertMins
	global ReloadRobloxSecs
	global DisableToolUse
	global Webhook
	GuiControlGet HiveSlot
	GuiControlGet HiveBees
	GuiControlGet, MoveMethod
	GuiControlGet, SprinklerType
	GuiControlGet, ConvertMins
	GuiControlGet, ReloadRobloxSecs
	GuiControlGet, DisableToolUse
	GuiControlGet, Webhook
	IniWrite, %HiveSlot%, nm_config.ini, Settings, HiveSlot
	IniWrite, %HiveBees%, nm_config.ini, Settings, HiveBees
	IniWrite, %MoveMethod%, nm_config.ini, Settings, MoveMethod
	IniWrite, %SprinklerType%, nm_config.ini, Settings, SprinklerType
	IniWrite, %ConvertMins%, nm_config.ini, Settings, ConvertMins
	IniWrite, %ReloadRobloxSecs%, nm_config.ini, Settings, ReloadRobloxSecs
	IniWrite, %DisableToolUse%, nm_config.ini, Settings, DisableToolUse
	IniWrite, %Webhook%, nm_config.ini, Status, Webhook
}
nm_webhookcheck(){
	GuiControlGet, WebhookCheck
	if(WebhookCheck){
		myOS:=SubStr(A_OSVersion, 1 , InStr(A_OSVersion, ".")-1)
		if((myOS*1)<10) {
			WebhookCheck:=0
			Guicontrol,,WebhookCheck,0
			msgbox The webhook feature requires Windows 10 or higher.
		}
	}
	IniWrite, %WebhookCheck%, nm_config.ini, Status, WebhookCheck
}
nm_convertBalloon(){
	GuiControlGet, ConvertBalloon
	if(ConvertBalloon="Every") {
		GuiControl, enable, ConvertMins
	} else {
		GuiControl, disable, ConvertMins
	}
	IniWrite, %ConvertBalloon%, nm_config.ini, Settings, ConvertBalloon
}
nm_guiThemeSelect(){
	GuiControlGet, GuiTheme
	IniWrite, %GuiTheme%, nm_config.ini, Settings, GuiTheme
	reload
}
nm_guiTransparencySet(){
	GuiControlGet, GuiTransparency
	IniWrite, %GuiTransparency%, nm_config.ini, Settings, GuiTransparency
	setVal:=255-floor(GuiTransparency*2.55)
	winset, transparent, %setval%, Natro Macro
}
nm_AlwaysOnTop(){
	GuiControlGet, AlwaysOnTop
	IniWrite, %AlwaysOnTop%, nm_config.ini, Settings, AlwaysOnTop
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
		GuiControl,,RotLeft, `.
		GuiControl,,RotRight, `/
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
	global KeyboardLayout
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	GuiControlGet, KeyboardLayout
	GuiControlGet, FwdKey
	GuiControlGet, LeftKey
	GuiControlGet, BackKey
	GuiControlGet, RightKey
	GuiControlGet, RotLeft
	GuiControlGet, RotRight
	GuiControlGet, KeyDelay
	IniWrite, %KeyboardLayout%, nm_config.ini, Keys, KeyboardLayout
	IniWrite, %FwdKey%, nm_config.ini, Keys, FwdKey
	IniWrite, %LeftKey%, nm_config.ini, Keys, LeftKey
	IniWrite, %BackKey%, nm_config.ini, Keys, BackKey
	IniWrite, %RightKey%, nm_config.ini, Keys, RightKey
	IniWrite, %RotLeft%, nm_config.ini, Keys, RotLeft
	IniWrite, %RotRight%, nm_config.ini, Keys, RotRight
	IniWrite, %KeyDelay%, nm_config.ini, Keys, KeyDelay
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
nm_ServerLink(){
	GuiControlGet, PrivServer
	;https://www.roblox.com/games/
	if InStr(PrivServer, "https://www.roblox.com/games/") {
	} else {
		msgbox It appears you have not entered a full address.  Please ensure the entire private server address is included in this field.
	}
	if (InStr(PrivServer, "<") || InStr(PrivServer, ">")) {
		msgbox It appears you have an improperly formatted server address.  Please remove "<" and or ">" from the full address.
	}
	IniWrite, %PrivServer%, nm_config.ini, Settings, PrivServer
}
nm_stingerFields(){
	gui, stingerFields:destroy
	global StingerPepperCheck
	global StingerMountainTopCheck
	global StingerRoseCheck
	global StingerCactusCheck
	global StingerSpiderCheck
	global StingerCloverCheck
	Menu, tray, Icon, auryn.ico, 1, 1
	gui stingerFields:+AlwaysOnTop +border +minsize50x30
	gui stingerFields:font, s8 w400 cBlack
	gui stingerFields:add, text,x5 y5 +left +BackgroundTrans,Allowed Stinger Fields
	gui stingerFields:add, text,x5 y8 +left +BackgroundTrans,___________________
	IniRead, StingerPepperCheck, nm_config.ini, Collect, StingerPepperCheck
	IniRead, StingerMountainTopCheck, nm_config.ini, Collect, StingerMountainTopCheck
	IniRead, StingerRoseCheck, nm_config.ini, Collect, StingerRoseCheck
	IniRead, StingerCactusCheck, nm_config.ini, Collect, StingerCactusCheck
	IniRead, StingerSpiderCheck, nm_config.ini, Collect, StingerSpiderCheck
	IniRead, StingerCloverCheck, nm_config.ini, Collect, StingerCloverCheck
	Gui, stingerFields:Add, Checkbox, x5 y25 vStingerPepperCheck gnm_stingerFieldsCheck checked%StingerPepperCheck%, Pepper
	Gui, stingerFields:Add, Checkbox, x5 y40 vStingerMountainTopCheck gnm_stingerFieldsCheck checked%StingerMountainTopCheck%, Mountain Top
	Gui, stingerFields:Add, Checkbox, x5 y55 vStingerRoseCheck gnm_stingerFieldsCheck checked%StingerRoseCheck%, Rose
	Gui, stingerFields:Add, Checkbox, x5 y70 vStingerCactusCheck gnm_stingerFieldsCheck checked%StingerCactusCheck%, Cactus
	Gui, stingerFields:Add, Checkbox, x5 y85 vStingerSpiderCheck gnm_stingerFieldsCheck checked%StingerSpiderCheck%, Spider
	Gui, stingerFields:Add, Checkbox, x5 y100 vStingerCloverCheck gnm_stingerFieldsCheck checked%StingerCloverCheck%, Clover
	Gui stingerFields:show,,Stinger Fields
}
nm_stingerFieldsCheck(){
	global StingerPepperCheck
	global StingerMountainTopCheck
	global StingerRoseCheck
	global StingerCactusCheck
	global StingerSpiderCheck
	global StingerCloverCheck
	GuiControlGet, StingerPepperCheck
	GuiControlGet, StingerMountainTopCheck
	GuiControlGet, StingerRoseCheck
	GuiControlGet, StingerCactusCheck
	GuiControlGet, StingerSpiderCheck
	GuiControlGet, StingerCloverCheck
	IniWrite, %StingerPepperCheck%, nm_config.ini, Collect, StingerPepperCheck
	IniWrite, %StingerMountainTopCheck%, nm_config.ini, Collect, StingerMountainTopCheck
	IniWrite, %StingerRoseCheck%, nm_config.ini, Collect, StingerRoseCheck
	IniWrite, %StingerCactusCheck%, nm_config.ini, Collect, StingerCactusCheck
	IniWrite, %StingerSpiderCheck%, nm_config.ini, Collect, StingerSpiderCheck
	IniWrite, %StingerCloverCheck%, nm_config.ini, Collect, StingerCloverCheck	
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
}
nm_TabPlantersPlusUnLock(){
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
	GuiControl, disable, MoveSpeed
	GuiControl, disable, MoveMethod
	GuiControl, disable, SprinklerType
	GuiControl, disable, ConvertBalloon
	GuiControl, disable, ConvertMins
	GuiControl, disable, DisableToolUse
	GuiControl, disable, HiveSlot
	GuiControl, disable, HiveVariation
	GuiControl, disable, HiveBees
	GuiControl, disable, PrivServer
	GuiControl, disable, ReloadRobloxSecs
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
	GuiControl, enable, MoveSpeed
	GuiControl, enable, MoveMethod
	GuiControl, enable, SprinklerType
	GuiControl, enable, ConvertBalloon
	if(ConvertBalloon="every")
		GuiControl, enable, ConvertMins
	GuiControl, enable, DisableToolUse
	GuiControl, enable, HiveSlot
	GuiControl, enable, HiveVariation
	GuiControl, enable, HiveBees
	GuiControl, enable, PrivServer
	GuiControl, enable, ReloadRobloxSecs
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
	WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
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
; WEBHOOK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CreateFormData() by tmplinshi modified by SKAN
; for sending images to webhook
CreateFormData(ByRef retData, ByRef retHeader, objParam) {
	New CreateFormData(retData, retHeader, objParam)
}
Class CreateFormData {

	__New(ByRef retData, ByRef retHeader, objParam) {

		Local CRLF := "`r`n", i, k, v, str, pvData
		; Create a random Boundary
		Local Boundary := this.RandomBoundary()
		Local BoundaryLine := "------------------------------" . Boundary

    this.Len := 0 ; GMEM_ZEROINIT|GMEM_FIXED = 0x40
    this.Ptr := DllCall( "GlobalAlloc", "UInt",0x40, "UInt",1, "Ptr"  )          ; allocate global memory

		; Loop input paramters
		For k, v in objParam
		{
			If IsObject(v) {
				For i, FileName in v
				{
					str := BoundaryLine . CRLF
					     . "Content-Disposition: form-data; name=""" . k . """; filename=""" . FileName . """" . CRLF
					     . "Content-Type: " . this.MimeType(FileName) . CRLF . CRLF
          this.StrPutUTF8( str )
          this.LoadFromFile( Filename )
          this.StrPutUTF8( CRLF )
				}
			} Else {
				str := BoundaryLine . CRLF
				     . "Content-Disposition: form-data; name=""" . k """" . CRLF . CRLF
				     . v . CRLF
        this.StrPutUTF8( str )
			}
		}

		this.StrPutUTF8( BoundaryLine . "--" . CRLF )

    ; Create a bytearray and copy data in to it.
    retData := ComObjArray( 0x11, this.Len ) ; Create SAFEARRAY = VT_ARRAY|VT_UI1
    pvData  := NumGet( ComObjValue( retData ) + 8 + A_PtrSize )
    DllCall( "RtlMoveMemory", "Ptr",pvData, "Ptr",this.Ptr, "Ptr",this.Len )

    this.Ptr := DllCall( "GlobalFree", "Ptr",this.Ptr, "Ptr" )                   ; free global memory 

    retHeader := "multipart/form-data; boundary=----------------------------" . Boundary
	}

  StrPutUTF8( str ) {
    Local ReqSz := StrPut( str, "utf-8" ) - 1
    this.Len += ReqSz                                  ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42
    this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len + 1, "UInt", 0x42 )   
    StrPut( str, this.Ptr + this.len - ReqSz, ReqSz, "utf-8" )
  }
  
  LoadFromFile( Filename ) {
    Local objFile := FileOpen( FileName, "r" )
    this.Len += objFile.Length                     ; GMEM_ZEROINIT|GMEM_MOVEABLE = 0x42 
    this.Ptr := DllCall( "GlobalReAlloc", "Ptr",this.Ptr, "UInt",this.len, "UInt", 0x42 )
    objFile.RawRead( this.Ptr + this.Len - objFile.length, objFile.length )
    objFile.Close()       
  }

	RandomBoundary() {
		str := "0|1|2|3|4|5|6|7|8|9|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z"
		Sort, str, D| Random
		str := StrReplace(str, "|")
		Return SubStr(str, 1, 12)
	}

	MimeType(FileName) {
		n := FileOpen(FileName, "r").ReadUInt()
		Return (n        = 0x474E5089) ? "image/png"
		     : (n        = 0x38464947) ? "image/gif"
		     : (n&0xFFFF = 0x4D42    ) ? "image/bmp"
		     : (n&0xFFFF = 0xD8FF    ) ? "image/jpeg"
		     : (n&0xFFFF = 0x4949    ) ? "image/tiff"
		     : (n&0xFFFF = 0x4D4D    ) ? "image/tiff"
		     : "application/octet-stream"
	}

}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
nm_testButton(){
	WinActivate, Roblox
	WinWaitActive, Roblox
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	global MoveMethod
	global QuestGatherField, LastBlackQuest
	setkeydelay, 10
	GuiControlGet FwdKey
	GuiControlGet LeftKey
	GuiControlGet BackKey
	GuiControlGet RightKey
	GuiControlGet RotLeft
	GuiControlGet RotRight
	GuiControlGet KeyDelay
	IniRead, MoveSpeedFactor, nm_config.ini, Settings, MoveSpeedFactor
	GuiControlGet MoveMethod
	;Auryn Gathering Path
	AurynDelay:=125
	loop 5 {
		;infinity
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor
		send {%LeftKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*3*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%LeftKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%RightKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*3*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%RightKey% up}
		;big circle
		sleep AurynDelay*MoveSpeedFactor*2
		send {%LeftKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%LeftKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%RightKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%RightKey% up}
		;FLIP!!
		;move to other side (half circle)
		sleep AurynDelay*MoveSpeedFactor*2
		send {%LeftKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%LeftKey% up}
		send {%BackKey% up}
		;pause here
		sleep 50
		;reverse infinity
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor
		send {%RightKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*3*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%RightKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%LeftKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*3*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*1.4
		send {%LeftKey% up}
		;big circle
		sleep AurynDelay*MoveSpeedFactor*2
		send {%RightKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%RightKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%LeftKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%FwdKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%BackKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%LeftKey% up}
		;FLIP!!
		;move to other side (half circle)
		sleep AurynDelay*MoveSpeedFactor*2
		send {%RightKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%BackKey% up}
		sleep AurynDelay*MoveSpeedFactor*2
		send {%FwdKey% down}
		sleep AurynDelay*MoveSpeedFactor*2*1.4
		send {%RightKey% up}
		send {%FwdKey% up}
		sleep 2000
	}
	
	
	;OS:=SubStr(A_OSVersion, 1 , InStr(A_OSVersion, ".")-1)   
	;msgbox A_OSVersion=%A_OSVersion%`nOS=%OS%

	/*
	global VBState
	NightLastDetected:=nowUnix()
	IniWrite, %NightLastDetected%, nm_config.ini, Collect, NightLastDetected
	VBState:=1
	nm_locateVB()
	*/
	
	/*
	WinActivate, Roblox
	WinWaitActive, Roblox
	GuiControlGet, FwdKey
	global lenMeasure
	global moving
	if(not moving){ ;start
		moving:=1
		lenMeasure:=nowUnix()
		send, {%FwdKey% down}
	} else { ;stop
		moving:=0
		send, {%FwdKey% up}
		temp:=(nowUnix()-lenMeasure)
		msgbox sec=%temp%
	}
	*/

	;;;;; this just doesnt work ;;;;;;;;;;;;;
	/*
	sleep, 500
	SetControlDelay -1 
	ControlClick,x56 y283,ahk_exe RobloxPlayerBeta.exe,,,, NA D Pos
	sleep, 50
	ControlClick,x400 y283,ahk_exe RobloxPlayerBeta.exe,,,,NA U Pos
	*/
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
}
nm_imgSearch(fileName,v,aim := "full", trans:="none"){
	global WindowedScreen
	CoordMode, Pixel, Relative
    WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
    ;xi := 0
    ;yi := 0
	;ww := windowWidth
	;wh := windowHeight
		xi:=(aim="actionbar") ? windowWidth/4 : (aim="highright") ? windowWidth/2 : (aim="right") ? windowWidth/2 : (aim="center") ? windowWidth/4 : (aim="lowright") ? windowWidth/2 : 0
		yi:=(aim="low") ? windowHeight/2 : (aim="actionbar") ? (windowHeight/4)*3 : (aim="center") ? yi:=windowHeight/4 : (aim="lowright") ? windowHeight/2 : 0
		ww:=(aim="actionbar") ? xi*3 : (aim="highleft") ? windowWidth/2 : (aim="left") ? windowWidth/2 : (aim="center") ? xi*3 : (aim="quest") ? windowHeight/2 : windowWidth
		wh:=(aim="high") ? windowHeight/2 : (aim="highright") ? windowHeight/2 : (aim="highleft") ? windowHeight/2 : (aim="buff") ? 150 : (aim="abovebuff") ? 30+WindowedScreen*31 : (aim="center") ? yi*3 : (aim="quest") ? windowHeight*0.75 : windowHeight
	IfExist, %A_ScriptDir%\nm_image_assets\
	{	
		if(trans!="none")
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *%v% *Trans%trans% nm_image_assets\%fileName%
		else
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *%v% nm_image_assets\%fileName%
		if (ErrorLevel = 2){
			MsgBox Image file %filename% was not found in:`nnm_image_assets\
			pause
		}
		return [ErrorLevel,FoundX,FoundY]
	} else {
		MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		return 3, 0, 0
	}
}
nowUnix(){
    Time := A_NowUTC
    EnvSub, Time, 19700101000000, Seconds
    return Time
}
nm_Reset(checkAll:=1, wait:=2000){
	global resetTime
	global youDied
	global VBState
	global KeyDelay
	global HiveVariation
	global RotRight
	global ZoomOut
	global objective
	global AFBrollingDice
	global AFBuseGlitter
	global AFBuseBooster
	global currentField
	global MyField:="None"
	global HiveConfirmed
	SetKeyDelay , (170+KeyDelay)
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
	if(checkAll) {
		nm_fieldBoostBooster()
		nm_locateVB()
	}
	while (1){
		resetTime:=nowUnix()
		;failsafe game frozen
		if(A_Index>10) {
			WinClose, Roblox
			sleep, 8000
			DisconnectCheck()
		}
		;check to make sure you are not in dialog before reset
		dialog := nm_imgSearch("dialog.png",30,"center")
		If (dialog[1] = 0) {
			while(dialog[1] = 0){
				;check to make sure you are not at a planter on accident
				imgPos := nm_imgSearch("no.png",30)
				If (imgPos[1] = 0){
					MouseMove, (imgPos[2]), (imgPos[3])
					Click
					MouseMove, 350, (Roblox[3]+70)
				}
				;continue dialog checking
				MouseMove, dialog[2],dialog[3]
				click
				MouseMove, -30, 0, 0, R
				dialog := nm_imgSearch("dialog.png",30,"center")
				sleep, 100
			}
			MouseMove, 350, (Roblox[3]+70)
		}
		;check to make sure you are not in shop before reset
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0) {
			loop 2 {
				dialog := nm_imgSearch("dialog.png",30,"right")
				If (dialog[1] = 0) {
					send {e}
					sleep, 1000
				}
			}
		}
		;check to make sure there is not a window open
		searchRet := nm_imgSearch("close.png",30,"full")
		If (searchRet[1] = 0) {
			MouseMove, searchRet[2],searchRet[3]
			click
			MouseMove, 350, (Roblox[3]+70)
			sleep, 1000
		}
		;check to make sure there is no ant amulet window open still
		searchRet := nm_imgSearch("keep.png",30,"center")
		searchRet2 := nm_imgSearch("d_ant_amulet.png",30,"center")
		searchRet3 := nm_imgSearch("g_ant_amulet.png",30,"center")
		If (searchRet[1]=0 && (searchRet2[1]=0 || searchRet3[1]=0)) {
			MouseMove, searchRet[2], searchRet[3], 5
			click
			MouseMove, 350, (Roblox[3]+70)
			sleep, 1000
		}
		if(!HiveConfirmed) {
			nm_setStatus("Resetting", "Character " . A_Index)
			HiveConfirmed:=0
			MouseMove, 350, (Roblox[3]+70)
			;reset
			send {esc}
			sleep, 100
			send r
			sleep, 100
			send {enter}
			SetKeyDelay , (100+KeyDelay)
			sleep,7000
			loop 4{
				send {PgUp}
			}
			loop 6 {
				send %ZoomOut%
			}
			sleep,1000
			repeat:=0
			loop, 16 { ;60
				if(A_Index=16)
					repeat:=1
				If (nm_imgSearch("hive4.png",HiveVariation,"actionbar")[1] = 0){
					loop 4{
						send %RotRight%
					}
					loop 4{
						send {PgDn}
					}
					break
				}
				send %RotRight%
				sleep (100+KeyDelay)
			}
		}
		if(not repeat)
			break
	}
	sleep, 500
	;convert
	nm_convert()
	;ensure minimum delay has been met
	temp:=(nowUnix()-resetTime)
	if((nowUnix()-resetTime)<wait) {
		remaining:=floor((wait-(nowUnix()-resetTime))/1000) ;seconds
		if(remaining>5){
			waitStr:=(remaining . " Seconds")
			nm_setStatus("Waiting", waitStr)
		}
		sleep, (remaining*1000) ;miliseconds
	}
}

nm_backpackPercent(){
	global WindowedScreen
	WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
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
					/*
					if((backpackColor = Format("{:d}",0xF70017))) { ;is equal to 100%
						BackpackPercent:=100
					} else if((backpackColor & 0x00FFFF <= Format("{:d}",0x00342E))){
						BackpackPercent:=95
					} else {
						BackpackPercent:=0
					}
					*/
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
	;msgbox %BackpackPercent%
	Return BackpackPercent
}
nm_backpackPercentFilter(){
	global PackFilterArray
	global BackpackPercentFiltered
	samplesize:=3 ;6 seconds (3 samples @ 2 sec intervals)
	
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
	return BackpackPercentFiltered
}
nm_gotoRamp(){
	global FwdKey
	global RightKey
	global HiveSlot
	global MoveSpeedFactor
	global objective
	nm_setStatus("Traveling", objective)
	nm_Move(1000*MoveSpeedFactor, FwdKey)
	sleep, %A_KeyDelay%
	nm_Move(2000*MoveSpeedFactor*HiveSlot, RightKey)
}
nm_gotoCannon(){
	global RightKey
	while (1) {
		send, {%RightKey% down}
		sleep, 200
		send, {space down}
		sleep, 200
		send, {space up}
		sleep, 200
		send, {%RightKey% up}
		repeat:=1
		loop 10 {
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				sleep, 100
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					repeat:=0
					break
				}
			}
			nm_Move(400*MoveSpeedFactor, RightKey)
		}
		if(repeat){
			nm_Reset()
			nm_gotoRamp()
		} else {
			break
		}
	}
}
nm_findHiveslot(){
	global LeftKey
	global BackKey
	global MoveSpeedFactor
	nm_Move(750*MoveSpeedFactor, BackKey)
	loop 100 {
		nm_Move(200*MoveSpeedFactor, LeftKey)
		searchRet := nm_imgSearch("e_button.png",30,"high")
		If (searchRet[1] = 0)
			break
	}
}
nm_walkTo(location){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	; FIELDS
	;;;;;;;;;;;;;;;;;;;;;;;;
	if(location="sunflower"){
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(6000*MoveSpeedFactor, RightKey)
	}
	else if(location="dandelion"){
		nm_Move(9000*MoveSpeedFactor, BackKey, LeftKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		loop 2 {
			send, {%RotLeft%}
		}
	}
	else if(location="mushroom"){
		nm_Move(8000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
	}
	else if(location="blue flower"){
		nm_Move(19750*MoveSpeedFactor, BackKey, LeftKey)
		nm_Move(6000*MoveSpeedFactor, LeftKey)
		loop 2 {
			send, {%RotLeft%}
		}
	}
	else if(location="clover"){
		nm_Move(10500*MoveSpeedFactor, BackKey, LeftKey)
		nm_Move(9000*MoveSpeedFactor, LeftKey)
		nm_Move(1800*MoveSpeedFactor, BackKey)
		nm_Move(5000*MoveSpeedFactor, LeftKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey)
		
	}
	else if(location="spider"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
	}
	else if(location="strawberry"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(8000*MoveSpeedFactor, FwdKey)
		nm_Move(8500*MoveSpeedFactor, LeftKey)
		nm_Move(1500*MoveSpeedFactor, FwdKey, LeftKey)
		loop 2 {
			send, {%RotLeft%}
		}
	}
	else if(location="bamboo"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
	}
	else if(location="pineapple"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(13000*MoveSpeedFactor, FwdKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		send, {%FwdKey% down}
		sleep, 200
		send, {space down}
		sleep, 100
		send, {space up}
		sleep 800
		send, {%FwdKey% up}
		loop 2 {
			send, {%RotLeft%}
		}
		nm_Move(14000*MoveSpeedFactor, FwdKey)
	}
	else if(location="stump"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(13000*MoveSpeedFactor, FwdKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		send, {%FwdKey% down}
		sleep, 200
		send, {space down}
		sleep, 100
		send, {space up}
		sleep 800
		send, {%FwdKey% up}
		loop 2 {
			send, {%RotLeft%}
		}
		nm_Move(14000*MoveSpeedFactor, FwdKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, RightKey)
	}
	else if(location="cactus"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, LeftKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(3000*MoveSpeedFactor, LeftKey)
	}
	else if(location="pumpkin"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, LeftKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		nm_Move(3500*MoveSpeedFactor, RightKey)
		nm_Move(3750*MoveSpeedFactor, FwdKey)
	}
	else if(location="pine tree"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, LeftKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		nm_Move(4500*MoveSpeedFactor, LeftKey)
		nm_Move(4000*MoveSpeedFactor, FwdKey)
	}
	else if(location="rose"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, LeftKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		nm_Move(4500*MoveSpeedFactor, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(13500*MoveSpeedFactor, FwdKey)
		loop 2 {
			send, {%RotRight%}
		}
	}
	else if(location="mountain top"){
		nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
		loop 4 {
			send, {%RotRight%}
		}
		nm_Move(7000*MoveSpeedFactor, FwdKey)
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(2000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, LeftKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		nm_Move(750*MoveSpeedFactor, LeftKey)
		nm_Move(8000*MoveSpeedFactor, FwdKey)
		nm_Move(12000*MoveSpeedFactor, RightKey)
		nm_Move(12000*MoveSpeedFactor, BackKey)
		nm_Move(13000*MoveSpeedFactor, RightKey)
		nm_Move(3500*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		loop 4 {
			send, {%RotRight%}
		}
	} else if(location="pepper"){
		nm_gotoCannon()
		send {%RightKey% down}
		sleep, 5000*MovespeedFactor
		send {space down}
		sleep, 200
		send {space up}
		sleep 500*MovespeedFactor
		send {%FwdKey% down}
		sleep 400*MovespeedFactor
		send {%FwdKey% up}
		sleep 750*MovespeedFactor
		send {space down}
		sleep, 200
		send {space up}
		sleep 1000*MovespeedFactor
		send {%RightKey% up}
		send {%FwdKey% down}
		send {space down}
		sleep, 100
		send {space up}
		sleep, 200*MovespeedFactor
		send {%RightKey% down}
		sleep 5000*MovespeedFactor
		send {%FwdKey% up}
		sleep 1000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 800
		send {%RightKey% up}
		send {%FwdKey% down}
		send {%LeftKey% down}
		send {space down}
		sleep, 100
		send {space up}
		sleep 3500*MovespeedFactor
		send {%FwdKey% up}
		sleep 1000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 500
		send {%LeftKey% up}
		send {%FwdKey% down}
		sleep 400
		send {space down}
		sleep, 100
		send {space up}
		sleep 1000*MovespeedFactor
		send {%RightKey% down}
		sleep 2500*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 2100*MovespeedFactor
		send {%FwdKey% up}
		sleep 900*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 1000*MovespeedFactor
		send {%RightKey% up}
		loop 2 {
			send {%RotRight%}
		}
		nm_Move(1800*MoveSpeedFactor, FwdKey)
	}
	else if(location="coconut"){
		nm_gotoCannon()
		send {%RightKey% down}
		sleep, 5000*MovespeedFactor
		send {space down}
		sleep, 200
		send {space up}
		sleep 500*MovespeedFactor
		send {%FwdKey% down}
		sleep 400*MovespeedFactor
		send {%FwdKey% up}
		sleep 750*MovespeedFactor
		send {space down}
		sleep, 200
		send {space up}
		sleep 1000*MovespeedFactor
		send {%RightKey% up}
		send {%FwdKey% down}
		send {space down}
		sleep, 100
		send {space up}
		sleep, 200*MovespeedFactor
		send {%RightKey% down}
		sleep 5000*MovespeedFactor
		send {%FwdKey% up}
		sleep 1000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 800
		send {%RightKey% up}
		send {%FwdKey% down}
		send {%LeftKey% down}
		send {space down}
		sleep, 100
		send {space up}
		sleep 3500*MovespeedFactor
		send {%FwdKey% up}
		sleep 1000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep, 6000*MovespeedFactor
		send {%LeftKey% up}
	}
	else {
		msgbox walkTo: location not defined.
	}
}
nm_toBooster(location){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	global MoveMethod
	global LastBlueBoost
	global LastRedBoost
	global LastMountainBoost
	global objective
	;blue booster
	if(location="blue"){
		loop 2 {
			nm_Reset(0)
			objective:="Blue Field Booster"
			nm_gotoRamp()
			if(MoveMethod="walk"){
				nm_walkTo("blue flower")
			} else if(MoveMethod="cannon"){
				nm_gotoCannon()
				send, {e}
				sleep, 50
				send {%LeftKey% down}
				sleep, 700
				send {space}
				send {space}
				sleep, 4450
				send {%LeftKey% up}
				send {space}
				sleep, 1000
				loop 2 {
					send, {%RotLeft%}
				}
			}
			nm_Move(10000*MoveSpeedFactor, FwdKey)
			send {%FwdKey% down}
			sleep, 200
			send, {space down}
			sleep 200
			send, {space up}
			sleep, 500
			send {%FwdKey% up}
			nm_Move(4000*MoveSpeedFactor, RightKey)
			nm_Move(6000*MoveSpeedFactor, BackKey)
			nm_Move(750*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(4000*MoveSpeedFactor, LeftKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastBlueBoost:=nowUnix()
		IniWrite, %LastBlueBoost%, nm_config.ini, Boost, LastBlueBoost
	} 
	;red booster
	else if(location="red"){
		loop 2 {
			nm_Reset(0)
			objective:="Red Field Booster"
			nm_gotoRamp()
			if(MoveMethod="walk"){
				nm_walkTo("rose")
			} else if(MoveMethod="cannon"){
				nm_gotoCannon()
				nm_cannonTo("rose")
			}
			nm_Move(2000*MoveSpeedFactor, BackKey)
			nm_Move(3500*MoveSpeedFactor, BackKey, RightKey)
			nm_Move(6600*MoveSpeedFactor, LeftKey)
			nm_Move(2500*MoveSpeedFactor, FwdKey)
			nm_Move(3000*MoveSpeedFactor, LeftKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastRedBoost:=nowUnix()
		IniWrite, %LastRedBoost%, nm_config.ini, Boost, LastRedBoost
	}
	;mountain booster
	else if(location="mount"){
		loop 2 {
			nm_Reset(0)
			objective:="Mountain Top Field Booster"
			nm_gotoRamp()
			if(MoveMethod="walk"){
				nm_walkTo("mountain top")
				nm_Move(6000*MoveSpeedFactor, RightKey)
				nm_Move(4000*MoveSpeedFactor, BackKey)
				nm_Move(6000*MoveSpeedFactor, RightKey)
			} else if(MoveMethod="cannon"){
				nm_gotoCannon()
				send {e}
				sleep, 3000
				nm_Move(9000*MoveSpeedFactor, RightKey)
			}
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastMountainBoost:=nowUnix()
		IniWrite, %LastMountainBoost%, nm_config.ini, Boost, LastMountainBoost
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
	global LastMountainBoost, QuestRedBoost
	global FieldBooster1
	global FieldBooster2
	global FieldBooster3
	global FieldBoosterMins
	global objective
	loop 3 {
		if(FieldBooster%A_Index%="none")
			break
		LastBooster:=max(LastBlueBoost, LastRedBoost, LastMountainBoost)
		;Blue Field Booster
		if((FieldBooster%A_Index%="blue" && (nowUnix()-LastBlueBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)) || (QuestBlueBoost && (nowUnix()-LastBlueBoost)>3600)){
			nm_toBooster("blue")
		}
		;Red Field Booster
		else if((FieldBooster%A_Index%="red" && (nowUnix()-LastRedBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)) || (QuestRedBoost && (nowUnix()-LastRedBoost)>3600)){
			nm_toBooster("red")
		}
		;Mountain Top Field Booster
		else if(FieldBooster%A_Index%="mount"  && (nowUnix()-LastMountainBoost)>3600 && (nowUnix()-LastBooster)>(FieldBoosterMins*60)){ ;1 hour
			nm_toBooster("mount")
		}
	}
}
nm_toCollect(){
	global MoveMethod
	if(MoveMethod="Walk"){
		nm_walkToCollect()
	} else if(MoveMethod="Cannon"){
		nm_cannonToCollect()
	}
}
nm_walkToCollect(){
	global youDied
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	global objective
	global WindowedScreen
	global Roblox
	;COLLECT
	;clock
	global ClockCheck
	global LastClock
	if(ClockCheck  && (nowUnix()-LastClock)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			objective:="Clock"
			nm_gotoRamp()
			nm_Move(10500*MoveSpeedFactor, BackKey, LeftKey)
			nm_Move(9000*MoveSpeedFactor, LeftKey)
			nm_Move(1800*MoveSpeedFactor, BackKey)
			nm_Move(5000*MoveSpeedFactor, LeftKey)
			loop 2 {
				send {%RotLeft%}
			}
			nm_Move(6000*MoveSpeedFactor, FwdKey)
			nm_Move(2000*MoveSpeedFactor, RightKey, FwdKey)
			nm_Move(500*MoveSpeedFactor, RightKey)
			nm_Move(500*MoveSpeedFactor, FwdKey)
			nm_Move(1250*MoveSpeedFactor, LeftKey)
			nm_Move(2250*MoveSpeedFactor, FwdKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				;check to make sure you are not at a planter on accident
				imgPos := nm_imgSearch("no.png",30)
				If (imgPos[1] = 0){
					MouseMove, (imgPos[2]), (imgPos[3])
					Click
					MouseMove, 350, (Roblox[3]+70)
				}
				;check to make sure you are not in bear dialog on accident
				dialog := nm_imgSearch("dialog.png",30,"center")
				If (dialog[1] = 0) {
					while(dialog[1] = 0){
						MouseMove, dialog[2],dialog[3]
						click
						MouseMove, -30, 0, 0, R
						dialog := nm_imgSearch("dialog.png",30,"center")
						sleep, 100
					}
					MouseMove, 350, (Roblox[3]+70)
				}
				break
			}
		}
		LastClock:=nowUnix()
		IniWrite, %LastClock%, nm_config.ini, Collect, LastClock
	}
	;ant pass
	global AntPassCheck, AntPassAction, QuestAnt
	global LastAntPass
	if((AntPassCheck || QuestAnt)  && (nowUnix()-LastAntPass)>7230){ ;2 hours
		loop, 2 {
			nm_Reset()
			if(QuestAnt)
				objective:="Ant Challenge"
			else
				objective:="Ant " . AntPassAction
			nm_setStatus("Traveling")
			nm_Move(9000*MoveSpeedFactor, LeftKey)
			send {%FwdKey% down}
			send {space down}
			sleep, 200
			send {%FwdKey% up}
			send {space up}
			sleep, 800
			send {%FwdKey% down}
			send {space down}
			sleep, 200
			send {%FwdKey% up}
			send {space up}
			sleep, 800
			nm_Move(40*MoveSpeedFactor, FwdKey, RightKey)
			nm_Move(7000*MoveSpeedFactor, FwdKey)
			nm_Move(10000*MoveSpeedFactor, LeftKey)
			nm_Move(1000*MoveSpeedFactor, RightKey)
			newAntPass:=0
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				newAntPass:=1
				send {e}
				sleep, 1000
				break
			}
		}
		LastAntPass:=nowUnix()
		IniWrite, %LastAntPass%, nm_config.ini, Collect, LastAntPass
		if((QuestAnt || AntPassAction="challenge") && newAntPass){
			QuestAnt:=0
			nm_Move(4000*MoveSpeedFactor, FwdKey)
			nm_Move(500*MoveSpeedFactor, BackKey)
			loop, 10 {
				nm_Move(500*MoveSpeedFactor, RightKey)
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					send {e}
					sleep, 1000
					break
				}
			}
			nm_setStatus("Attacking", "Ant Challenge")
			nm_Move(2000*MoveSpeedFactor, BackKey)
			nm_Move(500*MoveSpeedFactor, RightKey)
			nm_Move(100*MoveSpeedFactor, FwdKey)
			send {1}
			loop 300 {
				searchRet := nm_imgSearch("keep.png",30,"center")
				searchRet2 := nm_imgSearch("d_ant_amulet.png",30,"center")
				searchRet3 := nm_imgSearch("g_ant_amulet.png",30,"center")
				If (searchRet[1]=0 && (searchRet2[1]=0 || searchRet3[1]=0)) {
					MouseMove, searchRet[2], searchRet[3], 5
					click
					MouseMove, 350, (Roblox[3]+70)
					break
				}
				sleep, 1000
				click
			}
		}
	}
	;DISPENSERS
	;Honey
	global HoneyDisCheck
	global LastHoneyDis
	if(HoneyDisCheck  && (nowUnix()-LastHoneyDis)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Honey Dispenser")
			nm_Move(11000*MoveSpeedFactor, LeftKey)
			send {%LeftKey% down}
			send {space down}
			sleep, 200
			send {%LeftKey% up}
			send {space up}
			sleep, 800
			nm_Move(2000*MoveSpeedFactor, LeftKey)
			nm_Move(750*MoveSpeedFactor, BackKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastHoneyDis:=nowUnix()
		IniWrite, %LastHoneyDis%, nm_config.ini, Collect, LastHoneyDis
	}
	;Treat
	global TreatDisCheck
	global LastTreatDis
	if(TreatDisCheck  && (nowUnix()-LastTreatDis)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			;nm_setObjective("Treat Dispenser")
			objective:="Treat Dispenser"
			nm_gotoRamp()
			nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
			loop 4 {
				send, {%RotRight%}
			}
			nm_Move(10000*MoveSpeedFactor, FwdKey)
			loop 2 {
				send, {%RotRight%}
			}
			nm_Move(13000*MoveSpeedFactor, FwdKey)
			nm_Move(4000*MoveSpeedFactor, RightKey)
			send, {%FwdKey% down}
			sleep, 200
			send, {space down}
			sleep, 100
			send, {space up}
			sleep 800
			send, {%FwdKey% up}
			loop 2 {
				send, {%RotLeft%}
			}
			nm_Move(6500*MoveSpeedFactor, FwdKey)
			nm_Move(3500*MoveSpeedFactor, FwdKey, LeftKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastTreatDis:=nowUnix()
		IniWrite, %LastTreatDis%, nm_config.ini, Collect, LastTreatDis
	}
	;Blueberry
	global BlueberryDisCheck
	global LastBlueberryDis
	if(BlueberryDisCheck  && (nowUnix()-LastBlueberryDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Blueberry Dispenser"
			nm_gotoRamp()
			nm_walkTo("blue flower")
			nm_Move(6000*MoveSpeedFactor, FwdKey)
			nm_Move(2500*MoveSpeedFactor, FwdKey, RightKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastBlueberryDis:=nowUnix()
		IniWrite, %LastBlueberryDis%, nm_config.ini, Collect, LastBlueberryDis
	}
	;Strawberry
	global StrawberryDisCheck
	global LastStrawberryDis
	if(StrawberryDisCheck  && (nowUnix()-LastStrawberryDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Strawberry Dispenser"
			nm_gotoRamp()
			nm_walkTo("rose")
			nm_Move(2000*MoveSpeedFactor, BackKey)
			nm_Move(3500*MoveSpeedFactor, BackKey, RightKey)
			nm_Move(6600*MoveSpeedFactor, LeftKey)
			nm_Move(5300*MoveSpeedFactor, FwdKey)
			nm_Move(5100*MoveSpeedFactor, LeftKey)
			nm_Move(2500*MoveSpeedFactor, BackKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastStrawberryDis:=nowUnix()
		IniWrite, %LastStrawberryDis%, nm_config.ini, Collect, LastStrawberryDis
	}
	;Coconut
	global CoconutDisCheck
	global LastCoconutDis
	if(CoconutDisCheck  && (nowUnix()-LastCoconutDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Coconut Dispenser"
			nm_gotoRamp()
			nm_walkTo("coconut")
			nm_Move(4000*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(2500*MoveSpeedFactor, LeftKey)
			nm_Move(4000*MoveSpeedFactor, FwdKey, RightKey)
			nm_Move(750*MoveSpeedFactor, BackKey, LeftKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastCoconutDis:=nowUnix()
		IniWrite, %LastCoconutDis%, nm_config.ini, Collect, LastCoconutDis
	}
	;Glue
	global GlueDisCheck
	global LastGlueDis
	if(GlueDisCheck  && (nowUnix()-LastGlueDis)>(79230)){ ;22 hours
		loop 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Glue Dispenser")
			SetKeyDelay, 1
			nm_Move(9000*MoveSpeedFactor, LeftKey)
			send {%FwdKey% down}
			sleep, 50
			send {space down}
			sleep, 400
			send {%FwdKey% up}
			send {space up}
			sleep, 600
			send {%FwdKey% down}
			send {space down}
			sleep, 200
			send {space up}
			sleep, 600
			send {%FwdKey% up}
			nm_Move(200*MoveSpeedFactor, FwdKey, RightKey)
			nm_Move(7000*MoveSpeedFactor, FwdKey)
			nm_Move(3000*MoveSpeedFactor, LeftKey)
			nm_Move(6000*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(4000*MoveSpeedFactor, LeftKey)
			nm_Move(10000*MoveSpeedFactor, FwdKey)
			nm_Move(12000*MoveSpeedFactor, RightKey)
			nm_Move(3000*MoveSpeedFactor, BackKey, LeftKey)
			nm_Move(8000*MoveSpeedFactor, BackKey)
			nm_Move(500*MoveSpeedFactor, RightKey)
			;jump onto gummy bee
			send {space down}
			sleep, 10
			send {space up}
			send {%RightKey% down}
			sleep 500
			send {%RightKey% up}
			sleep, 500
			;on top of gummy bee
			;locate gumdrops
			imgPos := nm_imgSearch("ItemMenu.png",10, "left")
			If (imgPos[1] != 0){
				MouseMove, 30, (Roblox[3]+120)
				Click
				MouseMove, 350, (Roblox[3]+70)
			}
			sleep, 500
			imgPos := nm_imgSearch("gumdrops.png",10, "left")
			If (imgPos[1]=0){ ;gumdrops found
				If (imgPos[1]=0){
					mousemove imgPos[2], imgpos[3], 5
					MouseClickDrag, Left, (30), (imgpos[3]+40), (windowWidth/2), (windowHeight/2), 5
				}
			} else { ;gumdrops not found
				;scroll through inventory
				MouseMove, 30, (Roblox[3]+225), 5
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
							MouseClickDrag, Left, (30), (imgpos[3]+40), (windowWidth/2), (windowHeight/2), 5
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
			sleep,1500
			;inside gummy lair
			nm_Move(2000*MoveSpeedFactor, FwdKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				LastGlueDis:=nowUnix()
				IniWrite, %LastGlueDis%, nm_config.ini, Collect, LastGlueDis
				break
			} else { ;try again in 2 hours
				LastGlueDis:=nowUnix()-72000
				IniWrite, %LastGlueDis%, nm_config.ini, Collect, LastGlueDis
			}
		}
		SetKeyDelay, 5
	}
}
nm_Bugrun(){
	global youDied
	global disableDayOrNight, VBState
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveMethod
	global MoveSpeedFactor
	global objective
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll
	global MyField
	;Spider
	GuiControlGet, HiveBees
	global BugrunSpiderCheck
	global BugrunSpiderLoot
	global LastBugrunSpider
	global BugrunLadybugsCheck
	global BugrunLadybugsLoot
	global LastBugrunLadybugs
	global GiftedViciousCheck
	global TunnelBearCheck, TunnelBearBabyCheck, KingBeetleCheck, KingBeetleBabyCheck, LastTunnelBear, LastKingBeetle
	global TotalBossKills, SessionBossKills, TotalBugKills, SessionBugKills
	bypass:=0
	if(((BugrunSpiderCheck || QuestSpider || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) && HiveBees>=5){ ;30 minutes
		loop 1 {
			if(VBState=1)
				break
			;spider
			BugRunField:="spider"
			success:=0
			while (not success){
				if(A_Index>=3)
					break
				wait:=min(20000, (50-HiveBees)*1000)
				nm_Reset(1, wait)
				objective:="Spider"
				nm_gotoRamp()
				If (MoveMethod="walk")
					nm_walkTo(BugRunField)
				else {
					nm_gotoCannon()
					nm_cannonTo(BugRunField)
				}
				MyField:="Spider"
				nm_setStatus("Attacking")
				sleep, 1000
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
					break
			}
			LastBugrunSpider:=nowUnix()
			IniWrite, %LastBugrunSpider%, nm_config.ini, Collect, LastBugrunSpider
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
			if(BugrunSpiderLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(3000, 5, "left")
				click, up
			}
			if(VBState=1)
				break
			;head to ladybugs?
			if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) {
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Strawberry)")
				if(not BugrunSpiderLoot) {
					nm_Move(1000*MoveSpeedFactor, BackKey)
					nm_Move(1000*MoveSpeedFactor, LeftKey)
				}
				nm_Move(6000*MoveSpeedFactor, LeftKey)
				loop 2 {
					send {%RotLeft%}
				}
			} else {
				bypass:=0
			}
		}
	}
	;Ladybugs
	if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll)  && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				break
			if(HiveBees>=5) {
				;strawberry
				BugRunField:="strawberry"
				success:=0
				while (not success){
					if(A_Index>=3)
						break
					if(not bypass){
						wait:=min(5000, (50-HiveBees)*1000)
						nm_Reset(1, wait)
						objective:="Ladybugs (Strawberry)"
						nm_gotoRamp()
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_gotoCannon()
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					sleep, 1000
					send, 1
					if(!DisableToolUse)
						click, down
					MyField:="Strawberry"
					nm_setStatus("Attacking")
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
						break
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
				if(BugrunLadybugsLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
					nm_loot(3000, 5, "left")
					nm_Move(1000*MoveSpeedFactor, FwdKey, LeftKey)
					click, up
				}
				if(VBState=1)
					break
				;mushroom
				BugRunField:="mushroom"
				success:=0
				bypass:=1
				nm_setStatus("Traveling", "Ladybugs (Mushroom)")
				nm_Move(5000*MoveSpeedFactor, LeftKey)
				nm_Move(2000*MoveSpeedFactor, BackKey)
				nm_Move(2000*MoveSpeedFactor, BackKey, LeftKey)
				nm_Move(2000*MoveSpeedFactor, LeftKey)
			} else { ;HiveBees<5
				success:=0
				bypass:=0
			}
			while (not success){
				if(A_Index>=3)
					break
				if(not bypass){
					wait:=min(5000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					objective:="Ladybugs (Mushroom)"
					nm_gotoRamp()
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_gotoCannon()
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				sleep, 1000
				send, 1
				if(!DisableToolUse)
					click, down
				nm_setStatus("Attacking")
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
					break
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
			if(BugrunLadybugsLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(3000, 5, "left")
				click, up
			}
		}
	}
	if(VBState=1)
		return
	nm_Mondo()
	;Ladybugs and/or Rhino Beetles
	global BugrunRhinoBeetlesCheck
	global BugrunRhinoBeetlesLoot
	global LastBugrunRhinoBeetles
	global BugrunMantisCheck
	global BugrunMantisLoot
	global LastBugrunMantis
	if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15)))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				break
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
						objective:="Ladybugs (Clover)"
					}
					else if(not (BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						objective:="Rhino Beetles (Clover)"
					}
					else if((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						objective:="Ladybugs / Rhino Beetles (Clover)"
					}
					nm_gotoRamp()
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_gotoCannon()
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				sleep, 1000
				send, 1
				if(!DisableToolUse)
					click, down
				nm_setStatus("Attacking")
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
					break
			}
			;done with ladybugs
			LastBugrunLadybugs:=nowUnix()
			IniWrite, %LastBugrunLadybugs%, nm_config.ini, Collect, LastBugrunLadybugs
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
			;loot
			if(((BugrunLadybugsCheck || QuestLadybugs || RileyLadybugs || RileyAll) && BugrunLadybugsLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll) && BugrunRhinoBeetlesLoot)){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(3000, 5, "left")
				click, up
			}
		}
	}
	if(VBState=1)
		Return
	;Rhino Beetles
	if((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)  && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))){ ;5 minutes
		loop 1 {
			if(VBState=1)
				break
			;blue flower
			success:=0
			bypass:=1
			sleep, 5000
			BugRunField:="blue flower"
			nm_setStatus("Traveling")
			nm_Move(5000*MoveSpeedFactor, BackKey)
			nm_Move(250*MoveSpeedFactor, FwdKey)
			while (not success){
				if(A_Index>=3)
					break
				if(not bypass){
					wait:=min(5000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					objective:="Rhino Beetles (Blue Flower)"
					nm_gotoRamp()
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_gotoCannon()
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				sleep, 1000
				send, 1
				if(!DisableToolUse)
					click, down
				nm_setStatus("Attacking")
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
					break
			}
			;done with Rhino Beetles if Hive has less than 5 bees
			if(HiveBees<5){
				LastBugrunRhinoBeetles:=nowUnix()
				IniWrite, %LastBugrunRhinoBeetles%, nm_config.ini, Collect, LastBugrunRhinoBeetles
			}
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
			;loot
			if(BugrunRhinoBeetlesLoot){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(3000, 5, "left")
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
						objective:="Rhino Beetles (Bamboo)"
						nm_gotoRamp()
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_gotoCannon()
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					sleep, 1000
					send, 1
					if(!DisableToolUse)
						click, down
					nm_setStatus("Attacking")
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
						break
				}
				;done with Rhino Beetles if Hive has less than 10 bees
				if(HiveBees<10){
					LastBugrunRhinoBeetles:=nowUnix()
					IniWrite, %LastBugrunRhinoBeetles%, nm_config.ini, Collect, LastBugrunRhinoBeetles
				}
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunRhinoBeetlesLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
					nm_loot(3000, 5, "left")
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
				send, {%FwdKey% down}
				sleep, 200
				send, {space down}
				sleep, 100
				send, {space up}
				sleep 800
				send, {%FwdKey% up}
				loop 2 {
					send, {%RotLeft%}
				}
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
						objective:="Mantis (Pineapple)"
					}
					else if(not (BugrunMantisCheck || QuestMantis || BuckoMantis) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						objective:="Rhino Beetles (Pineapple)"
					}
					else if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && (BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles || RileyAll)){
						objective:="Rhino Beetles / Mantis (Pineapple)"
					}
					nm_gotoRamp()
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_gotoCannon()
						nm_cannonTo(BugRunField)
					}
				}
				bypass:=0
				sleep, 1000
				send, 1
				if(!DisableToolUse)
					click, down
				nm_setStatus("Attacking")
				disableDayOrNight:=1
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
				disableDayOrNight:=0
				if(VBState=1)
					break
			}
			;done with Rhino Beetles
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, nm_config.ini, Collect, LastBugrunRhinoBeetles
			;done with Mantis if Hive is smaller than 15 bees
			if((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && HiveBees<15){
				LastBugrunMantis:=nowUnix()
				IniWrite, %LastBugrunMantis%, nm_config.ini, Collect, LastBugrunMantis
			}
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
			;loot
			if(((BugrunMantisCheck || QuestMantis || BuckoMantis || RileyAll) && BugrunMantisLoot) || ((BugrunRhinoBeetlesCheck || QuestRhinoBeetles || BuckoRhinoBeetles) && BugrunRhinoBeetlesLoot || RileyAll)){
				if(!DisableToolUse)
					click, down
				nm_setStatus("Looting")
				nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
				nm_loot(3000, 5, "left")
				click, up
			}
		}
	}
	if(VBState=1)
		Return
	if(HiveBees>=15) {
		nm_Mondo()
		;werewolf
		global BugrunWerewolfCheck
		global BugrunWerewolfLoot
		global LastBugrunWerewolf
		if((BugrunWerewolfCheck || QuestWerewolf || RileyAll)  && (nowUnix()-LastBugrunWerewolf)>floor(3630*(1-GiftedViciousCheck*.15))){ ;60 minutes
			loop 1 {
				if(VBState=1)
					break
				;pumpkin
				BugRunField:="pumpkin"
				success:=0
				bypass:=0
				while (not success){
					if(A_Index>=3)
						break
					wait:=min(20000, (50-HiveBees)*1000)
					nm_Reset(1, wait)
					objective:="Werewolf (Pumpkin)"
					nm_gotoRamp()
					If (MoveMethod="walk")
						nm_walkTo(BugRunField)
					else {
						nm_gotoCannon()
						nm_cannonTo(BugRunField)
					}
					sleep, 1000
					send, 1
					if(!DisableToolUse)
						click, down
					nm_setStatus("Attacking")
					loop 25 { ;wait to kill
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
						break
				}
				LastBugrunWerewolf:=nowUnix()
				IniWrite, %LastBugrunWerewolf%, nm_config.ini, Collect, LastBugrunWerewolf
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
				IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
				if(BugrunWerewolfLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
					nm_loot(3000, 5, "left")
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
					break
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
						wait:=min(20000, (50-HiveBees)*1000)
						nm_Reset(1, wait)
						objective:="Mantis (Pine Tree)"
						nm_gotoRamp()
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_gotoCannon()
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					sleep, 1000
					send, 1
					if(!DisableToolUse)
						click, down
					nm_setStatus("Attacking")
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
						break
				}
				;done with Mantis
				LastBugrunMantis:=nowUnix()
				IniWrite, %LastBugrunMantis%, nm_config.ini, Collect, LastBugrunMantis
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunMantisLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
					nm_loot(3000, 5, "left")
					click, up
				}
			}
		}
		if(VBState=1)
			return
		;scorpions
		global BugrunScorpionsCheck
		global BugrunScorpionsLoot
		global LastBugrunScorpions
		if((BugrunScorpionsCheck || QuestScorpions || RileyScorpions || RileyAll)  && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))){ ;20 minutes
			loop 1 {
				if(VBState=1)
					break
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
						wait:=min(20000, (50-HiveBees)*1000)
						nm_Reset(1, wait)
						objective:="Scorpions (Rose)"
						nm_gotoRamp()
						If (MoveMethod="walk")
							nm_walkTo(BugRunField)
						else {
							nm_gotoCannon()
							nm_cannonTo(BugRunField)
						}
					}
					bypass:=0
					sleep, 1000
					send, 1
					if(!DisableToolUse)
						click, down
					nm_setStatus("Attacking")
					loop 17 { ;wait to kill
						if(mod(A_Index,4)=1){
							nm_Move(1500*MoveSpeedFactor, FwdKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
								success:=1
								break
							}
						} else if(mod(A_Index,4)=2){
							nm_Move(1500*MoveSpeedFactor, LeftKey)
							searchRet := nm_imgSearch("scorpion.png",30,"lowright")
							If (searchRet[1] = 0) {
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
						break
				}
				;done with Scorpions
				LastBugrunScorpions:=nowUnix()
				IniWrite, %LastBugrunScorpions%, nm_config.ini, Collect, LastBugrunScorpions
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
				IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
				IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
				;loot
				if(BugrunScorpionsLoot){
					if(!DisableToolUse)
						click, down
					nm_setStatus("Looting")
					nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
					nm_loot(3000, 5, "left")
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
				objective:="Tunnel Bear"
				nm_gotoRamp()
				If (MoveMethod="walk") {
					break
				} else {
					nm_gotoCannon()
					send, {e}
					sleep, 50
					send {%LeftKey% down}
					sleep, 1150
					send {space}
					send {space}
					sleep, 4500
					send {%LeftKey% up}
					send {space}
					sleep, 1000
					nm_Move(1500*MoveSpeedFactor, RightKey, BackKey)
					loop 4 {
						send {%RotLeft%}
					}
					nm_Move(2500*MoveSpeedFactor, FwdKey)
					sleep, 2000
				}
				;confirm tunnel
				if (nm_imgSearch("tunnel.png",25,"high")[1] = 1){
					continue
				}
				loop 2 {
					send {%RotLeft%}
				}
				;wait for baby love
				sleep, 2000
				if (TunnelBearBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					sleep 1500
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						sleep 1000
					}
				}
				;search for tunnel bear
				nm_setStatus("Searching", "Tunnel Bear")
				nm_Move(6000*MoveSpeedFactor, BackKey)
				found:=0
				loop 3 {
					sleep 1000
					if(nm_imgSearch("planterConfirm3.png",10,"high")[1] = 0){
						found:=1
						break
					} else {
						nm_Move(250*MoveSpeedFactor, FwdKey)
						sleep 150
						loop 3{
							sleep 1000
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
					IniWrite %LastTunnelBear%, nm_config.ini, Collect, LastTunnelBear
				}
				;loot
				if(TBdead) {
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					IniWrite, %TotalBossKills%, nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, nm_config.ini, Status, SessionBossKills
					nm_setStatus("Looting")
					nm_Move(12000*MoveSpeedFactor, FwdKey)
					nm_Move(18000*MoveSpeedFactor, BackKey)
					LastTunnelBear:=nowUnix()
					IniWrite %LastTunnelBear%, nm_config.ini, Collect, LastTunnelBear
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
				objective:="King Beetle"
				nm_gotoRamp()
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
					nm_gotoCannon()
					send, {e}
					sleep, 50
					send {%LeftKey% down}
					sleep, 675
					send {space}
					send {space}
					sleep, 4600
					send {%LeftKey% up}
					send {space}
					sleep, 1000
					nm_Move(3000*MoveSpeedFactor, LeftKey, FwdKey)
					nm_Move(1500*MoveSpeedFactor, RightKey, BackKey)
					nm_Move(1700*MoveSpeedFactor, RightKey, FwdKey)
				}
				;wait for baby love
				sleep, 1000
				if (KingBeetleBabyCheck){
					nm_setStatus("Waiting", "BabyLove Buff")
					sleep 1500
					loop 30{
						if (nm_imgSearch("blove.png",25,"buff")[1] = 0){
							break
						}
						sleep 1000
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
						IniWrite %LastKingBeetle%, nm_config.ini, Collect, LastKingBeetle
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
						nm_setStatus("Looting", "King Beetle Amulet")
						MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
						Click
						sleep, 1000
					} else { ;loot
						nm_setStatus("Looting", "King Beetle")
						nm_loot(2500, 7, "right")
					}
					TotalBossKills:=TotalBossKills+1
					SessionBossKills:=SessionBossKills+1
					IniWrite, %TotalBossKills%, nm_config.ini, Status, TotalBossKills
					IniWrite, %SessionBossKills%, nm_config.ini, Status, SessionBossKills
					LastKingBeetle:=nowUnix()
					IniWrite %LastKingBeetle%, nm_config.ini, Collect, LastKingBeetle
					break
				}
			}
		}
	}
}
nm_Mondo(){
	global youDied
	global VBState
	;mondo buff
	global MondoBuffCheck
	global LastMondoBuff
	if(MondoBuffCheck  && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960){
		mondobuff := nm_imgSearch("mondobuff.png",50,"buff")
		If (mondobuff[1] = 0) {
			LastMondoBuff:=nowUnix()
			IniWrite, %LastMondoBuff%, nm_config.ini, Collect, LastMondoBuff
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
		global CurrentField
		while(repeat){
			nm_Reset()
			GuiControlGet, MondoAction
			objective:=("Mondo (" . MondoAction . ")")
			nm_gotoRamp()
			if (MoveMethod="walk") {
				nm_walkTo("mountain top")
				nm_Move(2500*MoveSpeedFactor, RightKey)
			} else {
				nm_gotoCannon()
				send, {e}
				sleep, 50
				send {%BackKey% down}
				sleep, 1725
				send {space}
				send {space}
				sleep, 650
				send {%BackKey% up}
				send {space}
				sleep, 1500
			}
			global MyField:="Mountain Top"
			nm_setStatus("Attacking")
			if(MondoAction="Buff"){
				repeat:=0
				loop 120 { ;2 mins
					nm_autoFieldBoost(CurrentField)
					if(youDied || AFBrollingDice || AFBuseGlitter || AFBuseBooster)
						break
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
						nm_Move(500*MoveSpeedFactor, LeftKey)
						nm_Move(1400*MoveSpeedFactor, BackKey)
						nm_Move(100*MoveSpeedFactor, LeftKey)
						nm_loot(3000, 6, "left")
						nm_loot(3000, 6, "right")
						nm_loot(3000, 6, "left")
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
		IniWrite, %LastMondoBuff%, nm_config.ini, Collect, LastMondoBuff
	}
}
nm_cannonToCollect(){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveMethod
	global MoveSpeedFactor
	global objective
	global WindowedScreen
	global Roblox
	WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	;clock
	global ClockCheck
	global LastClock
	if(ClockCheck && (nowUnix()-LastClock)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			objective:="Clock"
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%LeftKey% down}
			send {%FwdKey% down}
			sleep, 825
			send {space}
			send {space}
			sleep, 2400
			send {%FwdKey% up}
			sleep, 500
			send {%LeftKey% up}
			sleep, 3500
			send {space}
			sleep, 1000
			send, {%LeftKey% down}
			sleep, 1000
			send, {%LeftKey% up}
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 500
				break
			}
		}
		LastClock:=nowUnix()
		IniWrite, %LastClock%, nm_config.ini, Collect, LastClock
	}
	;ant pass
	global AntPassCheck, AntPassAction, QuestAnt
	global LastAntPass
	if(QuestAnt) {
		;check for ant pass in inventory
		doAntChallenge:=0
		if(QuestAnt || AntPassAction="challenge"){
			imgPos := nm_imgSearch("ItemMenu.png",10, "left")
			If (imgPos[1] != 0){
				MouseMove, 30, (Roblox[3]+120)
				Click
				MouseMove, 350, (Roblox[3]+70)
			}
			sleep, 500
			imgPos := nm_imgSearch("ant_pass.png",10, "left")
			If (imgPos[1]=0){ ;ant pass found
				If (imgPos[1]=0){
					doAntChallenge:=1
				}
			} else { ;ant pass not found
				;scroll through inventory
				MouseMove, 30, (Roblox[3]+225), 5
				Loop, 50 {
					send, {WheelUp 1}
					Sleep, 50
				}
				Loop, 50 {
					;search for Ant Pass
					imgPos := nm_imgSearch("ant_pass.png",10, "left")
					If (imgPos[1]=0){ ;ant pass found
						If (imgPos[1]=0){
							doAntChallenge:=1
							;close inventory
							MouseMove, 30, (Roblox[3]+120)
							Click
							MouseMove, 350, (Roblox[3]+70)
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
			sleep,1500
		}
	}
	if(((AntPassCheck || QuestAnt) && (nowUnix()-LastAntPass)>7230) || (QuestAnt && doAntChallenge)){ ;2 hours OR ant quest
		loop, 2 {
			AntStart:
			nm_Reset()
			if(QuestAnt)
				objective:="Ant Challenge"
			else
				objective:="Ant " . AntPassAction
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%FwdKey% down}
			send {%LeftKey% down}
			sleep, 1100
			send {space}
			send {space}
			sleep, 1500
			send {%LeftKey% up}
			sleep, 4300
			send {%LeftKey% down}
			sleep, 1400
			send {%FwdKey% up}
			send {%LeftKey% up}
			send {space}
			sleep, 1400
			newAntPass:=0
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				newAntPass:=1
				send {e}
				sleep, 1000
				break
			}
		}
		LastAntPass:=nowUnix()
		IniWrite, %LastAntPass%, nm_config.ini, Collect, LastAntPass
		;do ant challenge
		if((QuestAnt || AntPassAction="challenge") && (newAntPass || doAntChallenge)){
			QuestAnt:=0
			nm_Move(4000*MoveSpeedFactor, FwdKey)
			nm_Move(500*MoveSpeedFactor, BackKey)
			loop, 10 {
				nm_Move(500*MoveSpeedFactor, RightKey)
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					send {e}
					sleep, 1000
					break
				}
			}
			nm_setStatus("Attacking", "Ant Challenge")
			nm_Move(2000*MoveSpeedFactor, BackKey)
			nm_Move(500*MoveSpeedFactor, RightKey)
			nm_Move(100*MoveSpeedFactor, FwdKey)
			send {1}
			loop 300 {
				searchRet := nm_imgSearch("keep.png",30,"center")
				searchRet2 := nm_imgSearch("d_ant_amulet.png",30,"center")
				searchRet3 := nm_imgSearch("g_ant_amulet.png",30,"center")
				If (searchRet[1]=0 && (searchRet2[1]=0 || searchRet3[1]=0)) {
					MouseMove, searchRet[2], searchRet[3], 5
					click
					MouseMove, 350, (Roblox[3]+70)
					break
				}
				sleep, 1000
				click
			}
		}
		
	}
	;DISPENSERS
	;Honey
	global HoneyDisCheck
	global LastHoneyDis
	if(HoneyDisCheck  && (nowUnix()-LastHoneyDis)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Honey Dispenser")
			nm_Move(11000*MoveSpeedFactor, LeftKey)
			send {%LeftKey% down}
			send {space down}
			sleep, 200
			send {%LeftKey% up}
			send {space up}
			sleep, 800
			nm_Move(2000*MoveSpeedFactor, LeftKey)
			nm_Move(750*MoveSpeedFactor, BackKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastHoneyDis:=nowUnix()
		IniWrite, %LastHoneyDis%, nm_config.ini, Collect, LastHoneyDis
	}
	;Treat
	global TreatDisCheck
	global LastTreatDis
	if(TreatDisCheck  && (nowUnix()-LastTreatDis)>3630){ ;1 hour
		loop, 2 {
			nm_Reset()
			objective:="Treat Dispenser"
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%LeftKey% down}
			sleep, 1800
			send {space}
			send {space}
			sleep, 1900
			send {%LeftKey% up}
			send {space}
			loop 4 {
				send, {%RotRight%}
			}
			sleep, 1500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastTreatDis:=nowUnix()
		IniWrite, %LastTreatDis%, nm_config.ini, Collect, LastTreatDis
	}
	;Blueberry
	global BlueberryDisCheck
	global LastBlueberryDis
	if(BlueberryDisCheck  && (nowUnix()-LastBlueberryDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Blueberry Dispenser"
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%LeftKey% down}
			sleep, 700
			send {space}
			send {space}
			sleep, 4450
			send {%LeftKey% up}
			send {space}
			sleep, 1000
			loop 2 {
				send, {%RotLeft%}
			}
			nm_Move(2800*MoveSpeedFactor, FwdKey)
			nm_Move(3000*MoveSpeedFactor, FwdKey, RightKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastBlueberryDis:=nowUnix()
		IniWrite, %LastBlueberryDis%, nm_config.ini, Collect, LastBlueberryDis
	}
	;Strawberry
	global StrawberryDisCheck
	global LastStrawberryDis
	if(StrawberryDisCheck  && (nowUnix()-LastStrawberryDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Strawberry Dispenser"
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%FwdKey% down}
			send {%RightKey% down}
			sleep, 400
			send {space}
			send {space}
			sleep, 1800
			send {%FwdKey% up}
			sleep, 1150
			send {%RightKey% up}
			send {space}
			loop 2 {
				send, {%RotRight%}
			}
			sleep, 1000
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastStrawberryDis:=nowUnix()
		IniWrite, %LastStrawberryDis%, nm_config.ini, Collect, LastStrawberryDis
	}
	;Coconut
	global CoconutDisCheck
	global LastCoconutDis
	if(CoconutDisCheck  && (nowUnix()-LastCoconutDis)>14430){ ;4 hours
		loop, 2 {
			nm_Reset()
			objective:="Coconut Dispenser"
			nm_gotoRamp()
			nm_gotoCannon()
			nm_cannonTo("coconut")
			nm_Move(4000*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(2500*MoveSpeedFactor, LeftKey)
			nm_Move(4000*MoveSpeedFactor, FwdKey, RightKey)
			nm_Move(750*MoveSpeedFactor, BackKey, LeftKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				break
			}
		}
		LastCoconutDis:=nowUnix()
		IniWrite, %LastCoconutDis%, nm_config.ini, Collect, LastCoconutDis
	}
	;Royal Jelly
	global RoyalJellyDisCheck
	global LastRoyalJellyDis
	if(RoyalJellyDisCheck  && (nowUnix()-LastRoyalJellyDis)>(79230)){ ;22 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Royal Jelly Dispenser (star cave)")
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%LeftKey% down}
			sleep, 800
			send {space}
			send {space}
			sleep, 1860
			send {%FwdKey% down}
			sleep, 1000
			send {%LeftKey% up}
			sleep, 3750
			send {%FwdKey% up}
			send {%RightKey% down}
			sleep, 200
			send {%RightKey% up}
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 10000
				break
			}
		}
		LastRoyalJellyDis:=nowUnix()
		IniWrite, %LastRoyalJellyDis%, nm_config.ini, Collect, LastRoyalJellyDis
	}
	;Glue
	global GlueDisCheck
	global LastGlueDis
	if(GlueDisCheck  && (nowUnix()-LastGlueDis)>(79230)){ ;22 hours
		loop, 2 {
			nm_Reset()
			nm_setStatus("Traveling", "Glue Dispenser")
			nm_gotoRamp()
			nm_gotoCannon()
			send, {e}
			sleep, 50
			send {%FwdKey% down}
			sleep, 1100
			send {space}
			send {space}
			sleep, 6000
			send {%FwdKey% up}
			sleep, 1000
			nm_Move(4000*MoveSpeedFactor, FwdKey)
			nm_Move(2000*MoveSpeedFactor, LeftKey)
			sleep, 500
			;on top of gummy bee
			;locate gumdrops
			imgPos := nm_imgSearch("ItemMenu.png",10, "left")
			If (imgPos[1] != 0){
				MouseMove, 30, (Roblox[3]+120)
				Click
				MouseMove, 350, (Roblox[3]+70)
			}
			sleep, 500
			imgPos := nm_imgSearch("gumdrops.png",10, "left")
			If (imgPos[1]=0){ ;gumdrops found
				If (imgPos[1]=0){
					mousemove imgPos[2], imgpos[3], 5
					MouseClickDrag, Left, (30), (imgpos[3]+40), (windowWidth/2), (windowHeight/2), 5
				}
			} else { ;gumdrops not found
				;scroll through inventory
				MouseMove, 30, (Roblox[3]+225), 5
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
							MouseClickDrag, Left, (30), (imgpos[3]+40), (windowWidth/2), (windowHeight/2), 5
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
			sleep,1500
			;inside gummy lair
			nm_Move(2000*MoveSpeedFactor, FwdKey)
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				send {e}
				sleep, 1000
				LastGlueDis:=nowUnix()
				IniWrite, %LastGlueDis%, nm_config.ini, Collect, LastGlueDis
				break
			} else { ;try again in 2 hours
				LastGlueDis:=nowUnix()-72000
				IniWrite, %LastGlueDis%, nm_config.ini, Collect, LastGlueDis
			}
		}
	}
}
nm_cannonTo(location){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	SetKeyDelay, 10
	if(location="sunflower"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		sleep, 425
		send {space}
		send {space}
		sleep, 900
		send {%RightKey% up}
		send {space}
		sleep, 1000
		loop 2 {
			send, {%RotRight%}
		}
	}
	else if(location="dandelion"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		sleep, 275
		send {space}
		send {space}
		sleep, 1750
		send {%LeftKey% up}
		send {space}
		loop 2 {
			send, {%RotLeft%}
		}
		sleep, 1500
	}
	else if(location="mushroom"){
		send, {e}
		sleep, 50	
		send {%FwdKey% down}
		sleep, 725
		send {space}
		send {space}
		sleep, 150
		send {%FwdKey% up}
		send {space}
		sleep, 2000
		loop 4 {
			send, {%RotLeft%}
		}
	}
	else if(location="blue flower"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		sleep, 675
		send {space}
		send {space}
		sleep, 3250
		send {%LeftKey% up}
		send {space}
		sleep, 1000
		loop 2 {
			send, {%RotLeft%}
		}
	}
	else if(location="clover"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		send {%FwdKey% down}
		sleep, 575
		send {space}
		send {space}
		sleep, 1250
		send {%FwdKey% up}
		sleep, 2750
		send {%LeftKey% up}
		send {space}
		sleep, 1000
	}
	else if(location="spider"){
		send, {e}
		sleep, 50
		send {%BackKey% down}
		sleep, 1050
		send {space}
		send {space}
		sleep, 150
		send {%BackKey% up}
		send {space}
		sleep, 1500
		loop 4 {
			send, {%RotLeft%}
		}
	}
	else if(location="strawberry"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		send {%BackKey% down}
		sleep, 750
		send {space}
		send {space}
		sleep, 1700
		send {%RightKey% up}
		send {%BackKey% up}
		send {space}
		sleep, 2000
		loop 2 {
			send, {%RotRight%}
		}
	}
	else if(location="bamboo"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		sleep, 1250
		send {space}
		send {space}
		sleep, 2000
		send {%LeftKey% up}
		send {space}
		loop 2 {
			send, {%RotLeft%}
		}
		sleep, 2000
	}
	else if(location="pineapple"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		sleep, 1850
		send {space}
		send {space}
		sleep, 2750
		send {%LeftKey% up}
		send {%BackKey% down}
		sleep, 1150
		send {%BackKey% up}
		send {space}
		loop 4 {
			send, {%RotLeft%}
		}
		sleep, 2000
	}
	else if(location="stump"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		sleep, 1850
		send {space}
		send {space}
		sleep, 2750
		send {%LeftKey% up}
		loop 2 {
			send, {%RotLeft%}
		}
		send {%FwdKey% down}
		send {%LeftKey% down}
		sleep, 900
		send {%LeftKey% up}
		sleep, 1500
		send {%FwdKey% up}
		send {space}
		sleep, 1000
	}
	else if(location="cactus"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		send {%BackKey% down}
		sleep, 940
		send {space}
		send {space}
		sleep, 2600
		send {%RightKey% up}
		send {%BackKey% up}
		send {space}
		sleep, 2000
	}
	else if(location="pumpkin"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		send {%BackKey% down}
		sleep, 940
		send {space}
		send {space}
		sleep, 2600
		send {%RightKey% up}
		sleep, 1100
		send {%BackKey% up}
		send {space}
		loop 4 {
			send, {%RotLeft%}
		}
		sleep, 1500
	}
	else if(location="pine tree"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		send {%BackKey% down}
		sleep, 940 
		send {space}
		send {space}
		sleep, 4500 ;4250
		send {%BackKey% up}
		sleep, 500 ;750
		send {%RightKey% up}
		send {space}
		loop 4 {
			send, {%RotLeft%}
		}
		sleep, 2000
	}
	else if(location="rose"){
		send, {e}
		sleep, 50
		send {%RightKey% down}
		sleep, 600
		send {space}
		send {space}
		sleep, 3000
		send {%RightKey% up}
		send {space}
		sleep, 1000
		loop 2 {
			send, {%RotRight%}
		}

	}
	else if(location="mountain top"){
		send, {e}
		sleep, 50
		send {%LeftKey% down}
		send {%BackKey% down}
		sleep, 1500
		send {space}
		send {space}
		sleep, 1100
		send {%LeftKey% up}
		sleep, 350
		send {%BackKey% up}
		send {space}
		sleep, 1500
	}
	else if(location="pepper"){
		send, {e}
		sleep, 50
		send {%FwdKey% down}
		sleep 500
		send {space}
		send {space}
		send {%RightKey% down}
		sleep 3900
		send {%RightKey% up}
		sleep 2000
		send {%RightKey% down}
		sleep 1000
		send {%RightKey% up}
		send {space down}
		sleep 50
		send {space up}
		sleep 750
		send {space down}
		sleep 50
		send {space up}
		sleep 750
		send {space down}
		sleep 50
		send {space up}
		sleep 3000*MovespeedFactor
		send {%RightKey% down}
		send {space down}
		sleep 50
		send {space up}
		sleep 5000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 1500*MovespeedFactor
		send {%FwdKey% up}
		sleep 2000*MovespeedFactor
		send {space down}
		sleep, 100
		send {space up}
		sleep 1000*MovespeedFactor
		send {%RightKey% up}
		send {%FwdKey% up}
		loop 2 {
			send {%RotRight%}
		}
		nm_Move(1900*MoveSpeedFactor, FwdKey)
	}
	else if(location="coconut"){
		send, {e}
		sleep, 50
		send {%FwdKey% down}
		sleep 500
		send {space}
		send {space}
		send {%RightKey% down}
		sleep 3900
		send {%RightKey% up}
		sleep 2000
		send {%RightKey% down}
		sleep 1000
		send {%RightKey% up}
		send {space down}
		sleep 50
		send {space up}
		sleep 750
		send {space down}
		sleep 50
		send {space up}
		sleep 750
		send {space down}
		sleep 50
		send {space up}
		sleep 3000*MovespeedFactor
		send {%FwdKey% up}
		send {%LeftKey% down}
		sleep 3000*MovespeedFactor
		send {%LeftKey% up}
	}
	SetKeyDelay, 5
}
nm_walkFrom(field:="none")
{
	if (field != "bamboo"&& field != "blue flower" && field != "cactus" && field != "clover" && field != "coconut" && field != "dandelion" && field != "mountain top" && field != "mushroom" && field != "pepper" && field != "pine tree" && field != "pineapple" && field != "pumpkin" && field != "rose" && field != "spider" && field != "strawberry" && field != "stump" && field != "sunflower"){
		msgbox walkFrom(): Invalid fieldname= %field%
		return
	}
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	global MoveMethod
	nm_setStatus("Traveling", "Hive")
	if (field = "bamboo"){
		nm_Move(3000*MoveSpeedFactor, LeftKey)
		nm_Move(750*MoveSpeedFactor, RightKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(12000*MoveSpeedFactor, RightKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(750*MoveSpeedFactor, FwdKey, RightKey)
		nm_Move(13000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "blue flower"){
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, BackKey)
		nm_Move(9000*MoveSpeedFactor, RightKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "cactus"){
		nm_Move(2000*MoveSpeedFactor, LeftKey)
		nm_Move(5000*MoveSpeedFactor, BackKey)
		send, {%BackKey% down}
		send, {%LeftKey% down}
		sleep, 2000
		send, {space down}
		sleep,200
		send, {space up}
		sleep, 2000
		send, {%BackKey% up}
		send, {%LeftKey% up}
		nm_Move(8000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey, RightKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(20000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "clover"){
		nm_Move(4000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(1000*MoveSpeedFactor, BackKey)
		nm_Move(11000*MoveSpeedFactor, RightKey)
		nm_Move(8000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "coconut"){
		nm_Move(4500*MoveSpeedFactor, RightKey)
		send {%Backkey% down}
		sleep, (5000*MoveSpeedFactor)
		send {space down}
		sleep 50
		send {space up}
		sleep, (7000*MoveSpeedFactor)
		send {%BackKey% up}
		nm_Move(7500*MoveSpeedFactor, LeftKey)
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "dandelion"){
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "mountain top"){
		nm_Move(4000*MoveSpeedFactor, FwdKey, RightKey)
		nm_Move(20000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "mushroom"){
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		loop 4 {
			send, {%RotLeft%}
		}
		nm_Move(16000*MoveSpeedFactor, FwdKey)
		nm_Move(11000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "pepper"){
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(10000*MoveSpeedFactor, BackKey)
		nm_Move(10000*MoveSpeedFactor, RightKey)
		nm_Move(12000*MoveSpeedFactor, BackKey)
		loop 2 {
			send {%RotLeft%}
		}
		nm_Move(3000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		nm_Move(750*MoveSpeedFactor, FwdKey)
	}
	else if (field = "pine tree"){
		if(MoveMethod="walk") {
			loop 4 {
				send, {%RotLeft%}
			}
			nm_Move(3000*MoveSpeedFactor, RightKey)
			nm_Move(2500*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(15000*MoveSpeedFactor, FwdKey)
			nm_Move(2000*MoveSpeedFactor, LeftKey)
			nm_Move(5000*MoveSpeedFactor, BackKey, LeftKey)
			nm_Move(9000*MoveSpeedFactor, FwdKey)
			nm_Move(1000*MoveSpeedFactor, BackKey)
			nm_Move(1000*MoveSpeedFactor, LeftKey)
			nm_Move(1000*MoveSpeedFactor, RightKey)
			nm_Move(11000*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(500*MoveSpeedFactor, BackKey)
			nm_Move(6000*MoveSpeedFactor, RightKey)
			nm_Move(750*MoveSpeedFactor, FwdKey)
		}
		else if(MoveMethod="cannon") {
			nm_Move(10000*MoveSpeedFactor, FwdKey)
			nm_Move(16000*MoveSpeedFactor, RightKey)
			nm_Move(14000*MoveSpeedFactor, BackKey)
			loop 4 {
				send, {%RotLeft%}
			}
			sleep 250
			send {space down}
			sleep 50
			send {space up}
			sleep 400
			send {space}
			sleep 4500
			send {%FwdKey% down}
			send {%RightKey% down}
			sleep 4500
			send {%FwdKey% up}
			send {%RightKey% up}
		}
	}
	else if (field = "pineapple"){
		nm_Move(4000*MoveSpeedFactor, FwdKey)
		nm_Move(7000*MoveSpeedFactor, RightKey)
		loop 4 {
			send, {%RotLeft%}
		}
		nm_Move(18000*MoveSpeedFactor, FwdKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		send, {%RightKey% down}
		Sleep, 200
		send, {space down}
		sleep, 200
		send, {space up}
		sleep, 800
		send, {%RightKey% up}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, BackKey)
		nm_Move(15000*MoveSpeedFactor, RightKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "pumpkin"){
		nm_Move(2000*MoveSpeedFactor, RightKey)
		loop 4 {
			send, {%RotLeft%}
		}
		nm_Move(2000*MoveSpeedFactor, BackKey)
		send, {%BackKey% down}
		send, {%LeftKey% down}
		sleep, 2000
		send, {space down}
		sleep,200
		send, {space up}
		sleep, 2000
		send, {%BackKey% up}
		send, {%LeftKey% up}
		nm_Move(8000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey, RightKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(19000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "rose"){
		loop 2 {
			send, {%RotLeft%}
		}
		nm_Move(1500*MoveSpeedFactor, FwdKey)
		nm_Move(1500*MoveSpeedFactor, LeftKey)
		nm_Move(6000*MoveSpeedFactor, BackKey, LeftKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, BackKey)
		nm_Move(1500*MoveSpeedFactor, LeftKey)
		nm_Move(1500*MoveSpeedFactor, RightKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey)
	}
	else if (field = "spider"){
		nm_Move(5000*MoveSpeedFactor, FwdKey)
		nm_Move(6000*MoveSpeedFactor, LeftKey)
		loop 4 {
			send, {%RotLeft%}
		}
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(750*MoveSpeedFactor, FwdKey, RightKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "strawberry"){
		loop 2 {
			send, {%RotLeft%}
		}
		nm_Move(5000*MoveSpeedFactor, BackKey, LeftKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(1500*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(18000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "stump"){
		nm_Move(9000*MoveSpeedFactor, RightKey)
		loop 2 {
			send, {%RotRight%}
		}
		nm_Move(5000*MoveSpeedFactor, RightKey)
		nm_Move(5000*MoveSpeedFactor, BackKey)
		nm_Move(3000*MoveSpeedFactor, RightKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(4000*MoveSpeedFactor, RightKey)
		send, {%RightKey% down}
		Sleep, 200
		send, {space down}
		sleep, 200
		send, {space up}
		sleep, 800
		send, {%RightKey% up}
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		nm_Move(1000*MoveSpeedFactor, BackKey)
		nm_Move(15000*MoveSpeedFactor, RightKey)
		nm_Move(9000*MoveSpeedFactor, FwdKey)
		nm_Move(8000*MoveSpeedFactor, RightKey)
		nm_Move(6000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(500*MoveSpeedFactor, FwdKey)
	}
	else if (field = "sunflower"){
		loop 2 {
			send, {%RotLeft%}
		}
		nm_Move(3000*MoveSpeedFactor, RightKey)
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(11000*MoveSpeedFactor, FwdKey, LeftKey)
		nm_Move(500*MoveSpeedFactor, BackKey)
		nm_Move(6000*MoveSpeedFactor, RightKey)
		nm_Move(1000*MoveSpeedFactor, FwdKey)
	}
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
	global WhirligigKey
	global LastWhirligig
	global BoostChaserCheck, LastBlueBoost, LastRedBoost, LastMountainBoost, FieldBooster3, FieldBooster2, FieldBooster1, FieldDefault, LastMicroConverter
	;global FieldName1, FieldName2, FieldName3, FieldPattern1, FieldPattern2, FieldPattern3, FieldPatternSize1, FieldPatternSize2, FieldPatternSize3, FieldPatternReps1, FieldPatternReps2, FieldPatternReps3, FieldPatternShift1, FieldPatternShift2, FieldPatternShift3, FieldUntilMins1, FieldUntilMins2, FieldUntilMins3, FieldUntilPack1, FieldUntilPack2, FieldUntilPack3, FieldReturnType1, FieldReturnType2, FieldReturnType3, FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3, FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3, FieldRotateDirection1, FieldRotateDirection2, FieldRotateDirection3, FieldRotateTimes1, FieldRotateTimes2, FieldRotateTimes3
	GuiControlGet, FieldName1
	GuiControlGet, FieldPattern1
	GuiControlGet, FieldPatternSize1
	GuiControlGet, FieldPatternReps1
	GuiControlGet, FieldPatternShift1
	GuiControlGet, FieldUntilMins1
	GuiControlGet, FieldUntilPack1
	GuiControlGet, FieldReturnType1
	GuiControlGet, FieldSprinklerLoc1
	GuiControlGet, FieldSprinklerDist1
	GuiControlGet, FieldRotateDirection1
	GuiControlGet, FieldRotateTimes1
	GuiControlGet, FieldName2
	GuiControlGet, FieldPattern2
	GuiControlGet, FieldPatternSize2
	GuiControlGet, FieldPatternReps2
	GuiControlGet, FieldPatternShift2
	GuiControlGet, FieldUntilMins2
	GuiControlGet, FieldUntilPack2
	GuiControlGet, FieldReturnType2
	GuiControlGet, FieldSprinklerLoc2
	GuiControlGet, FieldSprinklerDist2
	GuiControlGet, FieldRotateDirection2
	GuiControlGet, FieldRotateTimes2
	GuiControlGet, FieldName3
	GuiControlGet, FieldPattern3
	GuiControlGet, FieldPatternSize3
	GuiControlGet, FieldPatternReps3
	GuiControlGet, FieldPatternShift3
	GuiControlGet, FieldUntilMins3
	GuiControlGet, FieldUntilPack3
	GuiControlGet, FieldReturnType3
	GuiControlGet, FieldSprinklerLoc3
	GuiControlGet, FieldSprinklerDist3
	GuiControlGet, FieldRotateDirection3
	GuiControlGet, FieldRotateTimes3
	global MondoBuffCheck
	global StingerCheck
	GuiControlGet, gotoPlanterField
	GuiControlGet, EnablePlantersPlus
	global LastMondoBuff
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global PolarQuestGatherInterruptCheck, BuckoQuestGatherInterruptCheck, RileyQuestGatherInterruptCheck, BugrunInterruptCheck, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, BlackQuestCheck, BlackQuestComplete, QuestGatherField, BuckoQuestCheck, RileyQuestCheck, RotateQuest, QuestGatherMins, BuckoRhinoBeetles, BuckoMantis, RileyLadybugs, RileyScorpions, RileyAll
	global GatherStartTime, TotalGatherTime, SessionGatherTime, ConvertStartTime, TotalConvertTime, SessionConvertTime
	nm_backpackPercentFilter()
	;BUGS GatherInterruptCheck
	if((PolarQuestGatherInterruptCheck || BuckoQuestGatherInterruptCheck || RileyQuestGatherInterruptCheck || BugrunInterruptCheck) && (((QuestLadybugs || BugrunLadybugsCheck || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || ((QuestRhinoBeetlesbugs || BugrunRhinoBeetlesCheck || BuckoRhinoBeetles || RileyAll) && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || ((QuestSpider || BugrunSpiderCheck || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) || ((QuestMantis || BugrunMantisCheck || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))) || ((QuestScorpions || BugrunScorpionsCheck || RileyScorpions || RileyAll) && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))) || ((QuestWerewolf || BugrunWerewolfCheck || RileyAll) && (nowUnix()-LastWerewolf)>floor(3600*(1-GiftedViciousCheck*.15))))){
		return
	}
	;reset
	nm_Reset()
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
				;global FieldDefault:={"sunflower":{pattern:["diamonds","S", 1],camera:["none",1],sprinkler:["left",2]}
				FieldName%CurrentFieldNum%:=BoostChaserField
				FieldPattern%CurrentFieldNum%:=FieldDefault[BoostChaserField]["pattern"][1]
				FieldPatternSize%CurrentFieldNum%:=FieldDefault[BoostChaserField]["pattern"][2]
				FieldPatternReps%CurrentFieldNum%:=FieldDefault[BoostChaserField]["pattern"][3]
				FieldPatternShift%CurrentFieldNum%:=0
				FieldUntilMins%CurrentFieldNum%:=15
				FieldUntilPack%CurrentFieldNum%:=100
				FieldReturnType%CurrentFieldNum%:=FieldReturnType1
				FieldRotateDirection%CurrentFieldNum%:=FieldDefault[BoostChaserField]["camera"][1]
				FieldRotateTimes%CurrentFieldNum%:=FieldDefault[BoostChaserField]["camera"][2]
				FieldSprinklerLoc%CurrentFieldNum%:=FieldDefault[BoostChaserField]["sprinkler"][1]
				FieldSprinklerDist%CurrentFieldNum%:=FieldDefault[BoostChaserField]["sprinkler"][2]
				break
			}
		}
		;questing override
		if((BlackQuestCheck || BuckoQuestCheck || RileyQuestCheck) && QuestGatherField!="None"){
			fieldOverrideReason:="Quest"
			thisfield:=QuestGatherField
			if(QuestGatherField=FieldName1) {
				FieldName%CurrentFieldNum%:=QuestGatherField
				FieldPattern%CurrentFieldNum%:=FieldPattern1
				FieldPatternSize%CurrentFieldNum%:=FieldPatternSize1
				FieldPatternReps%CurrentFieldNum%:=FieldPatternReps1
				FieldPatternShift%CurrentFieldNum%:=FieldPatternShift1
				FieldUntilMins%CurrentFieldNum%:=FieldUntilMins1
				FieldUntilPack%CurrentFieldNum%:=FieldUntilPack1
				FieldReturnType%CurrentFieldNum%:=FieldReturnType1
				FieldRotateDirection%CurrentFieldNum%:=FieldRotateDirection1
				FieldRotateTimes%CurrentFieldNum%:=FieldRotateTimes1
				FieldSprinklerLoc%CurrentFieldNum%:=FieldSprinklerLoc1
				FieldSprinklerDist%CurrentFieldNum%:=FieldSprinklerDist1
			} else {
				FieldName%CurrentFieldNum%:=QuestGatherField
				FieldPattern%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][1]
				FieldPatternSize%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][2]
				FieldPatternReps%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][3]
				FieldPatternShift%CurrentFieldNum%:=0
				FieldUntilMins%CurrentFieldNum%:=QuestGatherMins
				FieldUntilPack%CurrentFieldNum%:=100
				FieldReturnType%CurrentFieldNum%:=FieldReturnType1
				FieldRotateDirection%CurrentFieldNum%:=FieldDefault[QuestGatherField]["camera"][1]
				FieldRotateTimes%CurrentFieldNum%:=FieldDefault[QuestGatherField]["camera"][2]
				FieldSprinklerLoc%CurrentFieldNum%:=FieldDefault[QuestGatherField]["sprinkler"][1]
				FieldSprinklerDist%CurrentFieldNum%:=FieldDefault[QuestGatherField]["sprinkler"][2]
			}
			break
		}
		;Gather in planter field override
		if(gotoPlanterField && EnablePlantersPlus){
			loop, 3{
				inverseIndex:=(4-A_Index)
				IniRead, PlanterField%inverseIndex%, ba_config.ini, planters, PlanterField%inverseIndex%
				If(PlanterField%inverseIndex%="dandelion" || PlanterField%inverseIndex%="sunflower" || PlanterField%inverseIndex%="mushroom" || PlanterField%inverseIndex%="blue flower" || PlanterField%inverseIndex%="clover" || PlanterField%inverseIndex%="strawberry" || PlanterField%inverseIndex%="spider" || PlanterField%inverseIndex%="bamboo" || PlanterField%inverseIndex%="pineapple" || PlanterField%inverseIndex%="stump" || PlanterField%inverseIndex%="cactus" || PlanterField%inverseIndex%="pumpkin" || PlanterField%inverseIndex%="pine tree" || PlanterField%inverseIndex%="rose" || PlanterField%inverseIndex%="mountain top" || PlanterField%inverseIndex%="pepper" || PlanterField%inverseIndex%="coconut"){
					fieldOverrideReason:="Planter"
					FieldName%CurrentFieldNum%:=PlanterField%inverseIndex%
					GuiControlGet, FieldPattern1
					GuiControlGet, FieldPatternSize1
					GuiControlGet, FieldPatternReps1
					GuiControlGet, FieldPatternShift1
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
	objective:=FieldName%CurrentFieldNum%
	nm_gotoRamp()
	;goto field
	if(MoveMethod="Walk"){
		nm_walkTo(FieldName%CurrentFieldNum%)
	} else if (MoveMethod="Cannon"){
		nm_gotoCannon()
		nm_cannonTo(FieldName%CurrentFieldNum%)
	} else {
		msgbox GoGather: MoveMethod undefined!
	}
	nm_autoFieldBoost(FieldName%CurrentFieldNum%)
	nm_fieldBoostGlitter()
	;set sprinkler
	if(fieldOverrideReason="None") {
		nm_setStatus("Gathering", FieldName%CurrentFieldNum%)
	} else if(fieldOverrideReason="Quest") {
		nm_setStatus("Gathering", RotateQuest . " " . fieldOverrideReason . " - " . FieldName%CurrentFieldNum%)
	} else {
		nm_setStatus("Gathering", fieldOverrideReason . " - " . FieldName%CurrentFieldNum%)
	}
	
	
	nm_setSprinkler()
	;rotate
	num:=FieldRotateTimes%CurrentFieldNum%
	if(FieldRotateDirection%CurrentFieldNum%="left") {
		loop %num% {
			send {%RotLeft%}
		}
	} else if(FieldRotateDirection%CurrentFieldNum%="right") {
		loop %num% {
			send {%RotRight%}
		}
	}
	;set direction keys
	;foward/back
	if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
		TCFBKey:=BackKey
		AFCFBKey:=FwdKey
	} else {
		TCFBKey:=FwdKey
		AFCFBKey:=BackKey
	}
	if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
		TCLRKey:=RightKey
		AFCLRKey:=LeftKey
	} else {
		TCLRKey:=LeftKey
		AFCLRKey:=RightKey
	}
	;gather loop
	bypass:=0
	gatherStart:=nowUnix() ; used to control how long to gather in this cycle
	GatherStartTime:=nowUnix() ; used to track total and session gathering time metrics
	if(FieldPatternShift%CurrentFieldNum%)
		send, {shift}
	BackpackPercentFiltered:=0
	while(((nowUnix()-gatherStart)<(FieldUntilMins%CurrentFieldNum%*60))){
		nm_gather(FieldPattern%CurrentFieldNum%, FieldPatternSize%CurrentFieldNum%, FieldPatternReps%CurrentFieldNum%)
		nm_autoFieldBoost(FieldName%CurrentFieldNum%)
		nm_fieldBoostGlitter()
		nm_fieldDriftCompensation()
		;interrupt if...
		if(DisconnectCheck() || youDied || VBState=1) {
			bypass:=1
			if(DisconnectCheck())
				nm_setStatus("Interupted", "Disconnect")
			else if (youDied)
				nm_setStatus("Interupted", "You Died!")
			else if (VBState=1)
				nm_setStatus("Interupted", "Vicious Bee")
			break
		}
		if(MondoBuffCheck && A_Min>=0 && A_Min<14 && (nowUnix()-LastMondoBuff)>960){
			nm_setStatus("Interupted", "Mondo")
			break
		}
		;GatherInterruptCheck
		if((PolarQuestGatherInterruptCheck || BuckoQuestGatherInterruptCheck || RileyQuestGatherInterruptCheck || BugrunInterruptCheck) && (((QuestLadybugs || BugrunLadybugsCheck || RileyLadybugs || RileyAll) && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || ((QuestRhinoBeetlesbugs || BugrunRhinoBeetlesCheck || BuckoRhinoBeetles || RileyAll) && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || ((QuestSpider || BugrunSpiderCheck || RileyAll) && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) || ((QuestMantis || BugrunMantisCheck || BuckoMantis || RileyAll) && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))) || ((QuestScorpions || BugrunScorpionsCheck || RileyScorpions || RileyAll) && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))) || ((QuestWerewolf || BugrunWerewolfCheck || RileyAll) && (nowUnix()-LastWerewolf)>floor(3600*(1-GiftedViciousCheck*.15))))){
			nm_setStatus("Interupted", "Kill Bugs")
			break
		}
		;special hotkeys
		if(BackpackPercentFiltered>=95 && MicroConverterKey!="none" && (nowUnix()-LastMicroConverter)>30) { ;30 seconds cooldown
			send {%MicroConverterKey%}
			PackFilterArray:=[]
			sleep, 500
			LastMicroConverter:=nowUnix()
			IniWrite, %LastMicroConverter%, nm_config.ini, Boost, LastMicroConverter
			continue
		}
		;full backpack
		else if (BackpackPercentFiltered>=FieldUntilPack%CurrentFieldNum%) {
			tempstring:=("Backpack exceeds " .  FieldUntilPack%CurrentFieldNum% . " percent")
			nm_setStatus("Interupted", tempstring)
			break
		}
		;active honey
		if(not nm_activeHoney() && (BackpackPercentFiltered<FieldUntilPack%CurrentFieldNum%)){
			nm_setStatus("Interupted", "Inactive Honey")
			break
		}
		;Black Bear quest
		if(RotateQuest="Black" && BlackQuestCheck && fieldOverrideReason="Quest"){
			nm_BlackQuestProg()
			;interrupt if
			if (thisfield!=QuestGatherField || QuestGatherField="none" || BlackQuestComplete){ ;change fields or this field is complete
				nm_setStatus("Interupted", "Next Quest Step")
				break
			}
		}
		;Bucko Bee quest
		if(RotateQuest="Bucko" && BuckoQuestCheck && fieldOverrideReason="Quest"){
			nm_BuckoQuestProg()
			;interrupt if
			if (thisfield!=QuestGatherField || QuestGatherField="none" || BuckoQuestComplete=1){ ;change fields or this field is complete
				nm_setStatus("Interupted", "Next Quest Step")
				break
			}
		}
		;Riley Bee quest
		if(RotateQuest="Riley" && RileyQuestCheck && fieldOverrideReason="Quest"){
			nm_RileyQuestProg()
			;interrupt if
			if (thisfield!=QuestGatherField || QuestGatherField="none" || RileyQuestComplete=1){ ;change fields or this field is complete
				nm_setStatus("Interupted", "Next Quest Step")
				break
			}
		}
	}
	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	GatherStartTime:=0
	if(FieldPatternShift%CurrentFieldNum%)
		send, {shift}
	if(not bypass){
		;rotate back
		num:=FieldRotateTimes%CurrentFieldNum%
		if(FieldRotateDirection%CurrentFieldNum%="right") {
			loop %num% {
				send {%RotLeft%}
			}
		} else if(FieldRotateDirection%CurrentFieldNum%="left") {
			loop %num% {
				send {%RotRight%}
			}
		}
		;close quest log if necessary
		if(BlackQuestCheck) {
			imgPos := nm_imgSearch("questlog.png",10, "left")
			If (imgPos[1] = 0){
				MouseMove, 85, (Roblox[3]+120)
				Click
				sleep, 50
				MouseMove, 350, (Roblox[3]+70)
			}
		}
		;whirligig
		if(FieldReturnType%CurrentFieldNum%="walk") { ;walk back
			if(WhirligigKey="none" && (nowUnix()-LastWhirligig)>300){
				;walk to hive
				nm_walkFrom(FieldName%CurrentFieldNum%)
				nm_findHiveslot()
			} else {
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
				sleep, 1000
			}
			;convert
			nm_convert(1)
		} else if(FieldReturnType%CurrentFieldNum%="rejoin") { ;exit and rejoin game
			;reset
			send {esc}
			sleep, 100
			send l
			sleep, 100
			send {enter}
			sleep, 5000
			return
		} else { ;reset back
			if (WhirligigKey!="none" && (nowUnix()-LastWhirligig)>300) {
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
				sleep, 1000
				;convert
				nm_convert(1)
			}
		}
	}
	nm_currentFieldDown()
	if(CurrentField="mountain top" && (A_Min>=0 && A_Min<15)) ;mondo dangerzone! skip over this field if possible
		nm_currentFieldDown()
}
nm_loot(length, reps, direction){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global KeyDelay
	global MoveSpeedFactor
	if(direction="left") {
		loop %reps% {
			send {%FwdKey% down}
			sleep, length*MoveSpeedFactor
			send {%LeftKey% down}
			send {%FwdKey% up}
			sleep, 200*MoveSpeedFactor
			send {%BackKey% down}
			send {%LeftKey% up}
			sleep, length*MoveSpeedFactor
			send {%LeftKey% down}
			send {%BackKey% up}
			sleep, 200*MoveSpeedFactor
			send {%LeftKey% up}
		}
	}else if(direction="right") {
		loop %reps% {
			send {%FwdKey% down}
			sleep, length*MoveSpeedFactor
			send {%RightKey% down}
			send {%FwdKey% up}
			sleep, 200*MoveSpeedFactor
			send {%BackKey% down}
			send {%RightKey% up}
			sleep, length*MoveSpeedFactor
			send {%RightKey% down}
			send {%BackKey% up}
			sleep, 200*MoveSpeedFactor
			send {%RightKey% up}
		}
	}
}
nm_gather(pattern, patternsize:="M", reps:=1){
	global TCFBKey
	global AFCFBKey
	global TCLRKey
	global AFCLRKey
	global KeyDelay
	global MoveSpeedFactor
	global DisableToolUse
	;set size
	if(patternsize="XS")
		size:=0.25
	else if (patternsize="S")
		size:=0.5
	else if (patternsize="L")
		size:=1.5
	else if (patternsize="XL")
		size:=2
	else ;medium (default)
		size:=1
	setKeyDelay, 2
	if(!DisableToolUse)
		click, down
	if(pattern="lines"){
		;toward center
		loop %reps% {
			send {%TCFBKey% down}
			sleep, 2000*MoveSpeedFactor*size
			send {%TCLRKey% down}
			send {%TCFBKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCFBKey% down}
			send {%TCLRKey% up}
			sleep, 2000*MoveSpeedFactor*size
			send {%TCLRKey% down}
			send {%AFCFBKey% up}
			sleep, 200*MoveSpeedFactor
			send {%TCLRKey% up}
		}
		;away from center
		loop %reps% {
			send {%TCFBKey% down}
			sleep, 2000*MoveSpeedFactor*size
			send {%AFCLRKey% down}
			send {%TCFBKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 2000*MoveSpeedFactor*size
			send {%AFCLRKey% down}
			send {%AFCFBKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCLRKey% up}
		}
	} else if(pattern="snake"){
		;toward center
		loop %reps% {
			send {%TCLRKey% down}
			sleep, 2000*MoveSpeedFactor*size
			send {%TCFBKey% down}
			send {%TCLRKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCLRKey% down}
			send {%TCFBKey% up}
			sleep, 2000*MoveSpeedFactor*size
			send {%TCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 200*MoveSpeedFactor
			send {%TCFBKey% up}
		}
		;away from center
		loop %reps% {
			send {%TCLRKey% down}
			sleep, 2000*MoveSpeedFactor*size
			send {%AFCFBKey% down}
			send {%TCLRKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCLRKey% down}
			send {%AFCFBKey% up}
			sleep, 2000*MoveSpeedFactor*size
			send {%AFCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 200*MoveSpeedFactor
			send {%AFCFBKey% up}
		}
	} else if(pattern="diamonds"){
		loop %reps% {
			send {%TCFBKey% down}
			send {%TCLRKey% down}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%TCLRKey% up}
			send {%AFCLRKey% down}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%TCFBKey% up}
			send {%AFCFBKey% down}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%AFCLRKey% up}
			send {%TCLRKey% down}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%TCLRKey% up}
			send {%AFCFBKey% up}
		}
	} else if(pattern="squares"){
		loop %reps% {
			send {%TCFBKey% down}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%TCLRKey% down}
			send {%TCFBKey% up}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%AFCFBKey% down}
			send {%TCLRKey% up}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%AFCLRKey% down}
			send {%AFCFBKey% up}
			sleep, 500*MoveSpeedFactor*size+A_Index*200
			send {%AFCLRKey% up}
		}
	} else if(pattern="typewriter"){
		send {%TCLRKey% down}
		sleep, 300*MoveSpeedFactor*(reps*2+1)
		send {%AFCFBKey% down}
		send {%TCLRKey% up}
		sleep, 1000*MoveSpeedFactor*size
		send {%AFCFBKey% up}
		loop %reps% {
			send {%AFCLRKey% down}
			sleep, 300*MoveSpeedFactor
			send {%TCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 1000*MoveSpeedFactor*size
			send {%AFCLRKey% down}
			send {%TCFBKey% up}
			sleep, 300*MoveSpeedFactor
			send {%AFCLRKey% up}
			send {%AFCFBKey% down}
			sleep, 1000*MoveSpeedFactor*size
			send {%AFCFBKey% up}
		}
		send {%TCLRKey% down}
		sleep, 300*MoveSpeedFactor*(reps*2)
		send {%TCFBKey% down}
		send {%TCLRKey% up}
		sleep, 1000*MoveSpeedFactor*size
		send {%TCFBKey% up}
		loop %reps% {
			send {%AFCLRKey% down}
			sleep, 300*MoveSpeedFactor
			send {%AFCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 1000*MoveSpeedFactor*size
			send {%AFCLRKey% down}
			send {%AFCFBKey% up}
			sleep, 300*MoveSpeedFactor
			send {%TCFBKey% down}
			send {%AFCLRKey% up}
			sleep, 1000*MoveSpeedFactor*size
			send {%TCFBKey% up}
		}
	} else if(pattern="auryn"){
		;Auryn Gathering Path
		AurynDelay:=175
		loop %reps% {
			;infinity
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*3*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%TCLRKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*3*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%AFCLRKey% up}
			;big circle
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFacto*sizer*(A_Index*1.1)*2*1.4
			send {%TCLRKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%AFCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCLRKey% up}
			;FLIP!!
			;move to other side (half circle)
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%TCLRKey% up}
			send {%AFCFBKey% up}
			;pause here
			sleep 50
			;reverse infinity
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*3*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%AFCLRKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*3*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*1.4
			send {%TCLRKey% up}
			;big circle
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%AFCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCLRKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%TCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%AFCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%TCLRKey% up}
			;FLIP!!
			;move to other side (half circle)
			sleep AurynDelay*MoveSpeedFactor*size*size*(A_Index*1.1)*2
			send {%AFCLRKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCFBKey% up}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2
			send {%TCFBKey% down}
			sleep AurynDelay*MoveSpeedFactor*size*(A_Index*1.1)*2*1.4
			send {%AFCLRKey% up}
			send {%TCFBKey% up}
		}
	} else if(pattern="stationary"){
		loop 10 {
			click
			sleep 1000
		}
	}
	click, up
}
nm_convert(hiveConfirm:=0)
{
	global KeyDelay, HiveVariation, RotRight, ZoomOut, AFBrollingDice, AFBuseGlitter, AFBuseBooster, CurrentField, HiveConfirmed, EnzymesKey,  LastEnzymes, ConvertStartTime, TotalConvertTime, SessionConvertTime
	GuiControlGet ConvertBalloon
	GuiControlGet ConvertMins
	IniRead, LastConvertBalloon, nm_config.ini, Settings, LastConvertBalloon
	SetKeyDelay , (100+KeyDelay)
	HiveConfirmed:=0
	searchRet := nm_imgSearch("e_button.png",30,"high")
	If (searchRet[1] = 0) {
		ConvertAnyway:=0
		if(hiveConfirm){
			loop 4{
				send {PgUp}
				send %RotRight%
			}
			loop 6 {
				send %ZoomOut%
			}
			sleep,2000
			loop 10 {
				If (nm_imgSearch("hive4.png",HiveVariation,"actionbar")[1] = 0){
					loop 4{
						send %RotRight%
						send {PgDn}
						HiveConfirmed:=1
					}
					break
				}
				sleep,1000
			}
		} else {
			ConvertAnyway:=1
		}
		if(HiveConfirmed || ConvertAnyway){
			send e
			ConvertStartTime:=nowUnix()
			;empty pack
			loop 300 { ;5 mins
				If (nm_backpackPercent()>0 && A_Index=1)
					nm_setStatus("Converting", "Backpack")
				sleep, 1000
				nm_AutoFieldBoost(currentField)
				if(AFBuseGlitter || AFBuseBooster)
					break
				If (nm_backpackPercent() = 0) {
					break
				}
				If (disconnectcheck()) {
					return
				}
			}
			sleep, 6000
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 1) {
				TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
				SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
				ConvertStartTime:=0
				return
			}
			;empty balloon
			if(ConvertBalloon="always" || (ConvertBalloon="Every" && (nowUnix() - LastConvertBalloon)>(ConvertMins*60))) {
				bigBalloonConfirm:=0
				inactiveHoney:=0
				confirmActive:=0
				;;;;;;;;;;;;;;;;;;;
				while (bigBalloonConfirm<=10 && A_Index<=60) {
					nm_AutoFieldBoost(currentField)
					if(AFBuseGlitter || AFBuseBooster)
						break
					searchRet := nm_imgSearch("e_button.png",30,"high")
					If (searchRet[1] = 0) {
						bigBalloonConfirm:=bigBalloonConfirm+1
					} else {
						break
					}
					searchRet := nm_imgSearch("balloonblessing.png",30,"lowright")
					If (searchRet[1] = 0) {
						nm_setStatus(0, "Balloon Refreshed")
						LastConvertBalloon:=nowUnix()
						IniWrite, %LastConvertBalloon%, nm_config.ini, Settings, LastConvertBalloon
						TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
						SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
						ConvertStartTime:=0
						return
					}
					If (disconnectcheck()) {
						return
					}
					sleep, 1000
				}
				If (bigBalloonConfirm>=10) {
					ballooncomplete:=0
					searchRet := nm_imgSearch("e_button.png",30,"high")
					inactiveHoney:=0
					while(searchRet[1]=0 && AIndex<=600) { ;10 mins
						if(A_Index=1) {
							nm_setStatus("Converting", "Balloon")
							if(EnzymesKey!="none" && (nowUnix()-LastEnzymes)>600 && nm_activeHoney()) {
								send {%EnzymesKey%}
								LastEnzymes:=nowUnix()
								IniWrite, %LastEnzymes%, nm_config.ini, Boost, LastEnzymes
							}
						}
						nm_AutoFieldBoost(currentField)
						if(AFBuseGlitter || AFBuseBooster)
							break
						if(not nm_activeHoney()){
							inactiveHoney:=inactiveHoney+1
							if(inactiveHoney>10) { ;10 consecutive seconds of inactive honey
								nm_setStatus("Interrupted", "Inactive Honey")
								break
							}
						} else {
							inactiveHoney:=0
						}
						searchRet := nm_imgSearch("balloonblessing.png",30,"lowright")
						If (searchRet[1] = 0) {
							ballooncomplete:=1
							break
						}
						searchRet := nm_imgSearch("e_button.png",30,"high")
						If (searchRet[1] = 1) {
							ballooncomplete:=1
							break
						}
						If (disconnectcheck()) {
							return
						}
						sleep, 1000
					}
					if(ballooncomplete){
						nm_setStatus(0, "Balloon Refreshed")
						LastConvertBalloon:=nowUnix()
						IniWrite, %LastConvertBalloon%, nm_config.ini, Settings, LastConvertBalloon
					}
				}
				;;;;;;;;;;;;;;;;;;;
			}
			TotalConvertTime:=TotalConvertTime+(nowUnix()-ConvertStartTime)
			SessionConvertTime:=SessionConvertTime+(nowUnix()-ConvertStartTime)
			ConvertStartTime:=0
		}
	}
}
nm_setSprinkler(quest:=0){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global KeyDelay
	global MoveSpeedFactor
	global CurrentFieldNum
	global FieldSprinklerLoc1, FieldSprinklerLoc2, FieldSprinklerLoc3
	global FieldSprinklerDist1, FieldSprinklerDist2, FieldSprinklerDist3
	global FieldName1, FieldName2, FieldName3
	global QuestGatherField
	GuiControlGet, SprinklerType
	GuiControlGet, gotoPlanterField
	GuiControlGet, EnablePlantersPlus
	;locations= Center|Upper Left|Upper|Upper Right|Right|Lower Right|Lower|Lower Left|Left
	if(gotoPlanterField && EnablePlantersPlus){
		loop, 3{
			inverseIndex:=(4-A_Index)
			IniRead, PlanterField%inverseIndex%, ba_config.ini, planters, PlanterField%inverseIndex%
			If(PlanterField%inverseIndex%="dandelion" || PlanterField%inverseIndex%="sunflower" || PlanterField%inverseIndex%="mushroom" || PlanterField%inverseIndex%="blue flower" || PlanterField%inverseIndex%="clover" || PlanterField%inverseIndex%="strawberry" || PlanterField%inverseIndex%="spider" || PlanterField%inverseIndex%="bamboo" || PlanterField%inverseIndex%="pineapple" || PlanterField%inverseIndex%="stump" || PlanterField%inverseIndex%="cactus" || PlanterField%inverseIndex%="pumpkin" || PlanterField%inverseIndex%="pine tree" || PlanterField%inverseIndex%="rose" || PlanterField%inverseIndex%="mountain top" || PlanterField%inverseIndex%="pepper" || PlanterField%inverseIndex%="coconut"){
				FieldName%CurrentFieldNum%:=PlanterField%inverseIndex%
				FieldSprinklerLoc%CurrentFieldNum%:="center"
				break
			}
		}
	}
	;quest field override
	if(quest){
		FieldName%CurrentFieldNum%:=QuestGatherField
		FieldPattern%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][1]
		FieldPatternSize%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][2]
		FieldPatternReps%CurrentFieldNum%:=FieldDefault[QuestGatherField]["pattern"][3]
		FieldPatternShift%CurrentFieldNum%:=0
		FieldUntilMins%CurrentFieldNum%:=5
		FieldUntilPack%CurrentFieldNum%:=100
		FieldReturnType%CurrentFieldNum%:=FieldReturnType1
		FieldRotateDirection%CurrentFieldNum%:=FieldDefault[QuestGatherField]["camera"][1]
		FieldRotateTimes%CurrentFieldNum%:=FieldDefault[QuestGatherField]["camera"][2]
		FieldSprinklerLoc%CurrentFieldNum%:=FieldDefault[QuestGatherField]["sprinkler"][1]
		FieldSprinklerDist%CurrentFieldNum%:=FieldDefault[QuestGatherField]["sprinkler"][2]
	}
	;field dimensions
	if(FieldName%CurrentFieldNum%="sunflower") {
		;sunflower: L=4 W=5
		flen:=1250*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2000*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="dandelion") {
		;dandelion: L=6 W=3
		flen:=2500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1000*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="mushroom") {
		;mushroom: L=4 W=5
		flen:=1250*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1750*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="blue flower") {
		;blueflower: L=6 W=3
		flen:=2750*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=750*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="clover") {
		;clover: L=5 W=4
		flen:=2000*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="spider") {
		;spider: L=5 W=5
		flen:=2000*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2000*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="strawberry") {
		;strawberry: L=4 W=5
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2000*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="bamboo") {
		;bamboo: L=6 W=3
		flen:=3000*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1250*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="pineapple") {
		;pineapple: L=4 W=5
		flen:=1750*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=3000*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="stump") {
		;stump: L=3 W=3
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="cactus") {
		;cactus: L=3 W=6
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="pumpkin") {
		;pumpkin: L=3 W=6
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="pine tree") {
		;pine tree: L=5 W=4
		flen:=2500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1750*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="rose") {
		;rose: L=5 W=4
		flen:=2500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="mountain top") {
		;rose: L=4 W=4
		flen:=2250*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="pepper") {
		;rose: L=3 W=4
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2250*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	else if(FieldName%CurrentFieldNum%="coconut") {
		;rose: L=3 W=4
		flen:=1500*(FieldSprinklerDist%CurrentFieldNum%/10)
		fwid:=2250*(FieldSprinklerDist%CurrentFieldNum%/10)
	}
	;move to start position
	if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
		nm_Move(flen*MoveSpeedFactor, FwdKey)
	} else if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Lower")){
		nm_Move(flen*MoveSpeedFactor, BackKey)
	}
	if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
		nm_Move(fwid*MoveSpeedFactor, LeftKey)
	} else if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Right")){
		nm_Move(fwid*MoveSpeedFactor, RightKey)
	}
	if(FieldSprinklerLoc%CurrentFieldNum%:="center")
		sleep, 1000
	;set sprinkler(s)
	Send {1}
	if(SprinklerType="Silver" || SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
			nm_Move(1000*MoveSpeedFactor, BackKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		}
		sleep, 500
		send {space down}
		sleep, 200
		send {1}
		send {space up}
		sleep, 900
	}
	if(SprinklerType="Silver") {
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
	}
	if(SprinklerType="Golden" || SprinklerType="Diamond") {
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
			nm_Move(1000*MoveSpeedFactor, RightKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, LeftKey)
		}
		sleep, 500
		send {space down}
		sleep, 200
		send {1}
		send {space up}
		sleep, 900
	}
	if(SprinklerType="Golden") {
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
			if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
				nm_Move(1400*MoveSpeedFactor, FwdKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, FwdKey, RightKey)
			}
		} else {
			if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
				nm_Move(1400*MoveSpeedFactor, BackKey, LeftKey)
			} else {
				nm_Move(1400*MoveSpeedFactor, BackKey, RightKey)
			}
		}
	}
	if(SprinklerType="Diamond") {
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Upper")){
			nm_Move(1000*MoveSpeedFactor, FwdKey)
		} else {
			nm_Move(1000*MoveSpeedFactor, BackKey)
		}
		sleep, 500
		send {space down}
		sleep, 200
		send {1}
		send {space up}
		sleep, 900
		if(InStr(FieldSprinklerLoc%CurrentFieldNum%, "Left")){
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
	global FieldDriftCheck1
	global FieldDriftCheck2
	global FieldDriftCheck3
	global FieldSprinklerLoc1
	global FieldSprinklerLoc2
	global FieldSprinklerLoc3
	global DisableToolUse
	FieldDriftComp:=FieldDriftCheck%CurrentFieldNum%
	GuiControlGet, SprinklerType
	If (FieldDriftComp){
		WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
        winUp := windowHeight / 2.14
        winDown := windowHeight / 1.88
        winLeft := windowWidth / 2.14
        winRight := windowWidth /1.88
		if (sat = "golden" || sat = "diamond"){
			imgName:=(sat . ".png")
		} else {
			imgName:="saturator.png"
		}
		saturatorFinder := nm_imgSearch(imgName,50)
		If (saturatorFinder[1] = 0){
			while (saturatorFinder[1] = 0 && A_Index<=10) {
				if(saturatorFinder[2] >= winleft && saturatorFinder[2] <= winRight && saturatorFinder[3] >= winUp && saturatorFinder[3] <= winDown) {
					click up
					break
				}
				if(!DisableToolUse)
					click down
				if (saturatorFinder[2] < winleft){
					send {%LeftKey% down}
				} else if (saturatorFinder[2] > winRight){
					send {%RightKey% down}
				}
				if (saturatorFinder[3] < winUp){
					send {%FwdKey% down}
				} else if (saturatorFinder[3] > winDown){
					send {%BackKey% down}
				}
				sleep, 200*MoveSpeedFactor
				send {%LeftKey% up}
				send {%RightKey% up}
				send {%FwdKey% up}
				send {%BackKey% up}
				click up
				saturatorFinder := nm_imgSearch(imgName,50)
			}
		} ;else if(not (saturatorFinder[2] >= winleft && saturatorFinder[2] <= winRight && saturatorFinder[3] >= winUp && saturatorFinder[3] <= winDown)){
			;ba_fieldDriftCompensation()
		;}
	}
}
;move function
nm_Move(MoveTime, MoveKey1, MoveKey2:="None"){
	SetKeyDelay, (5)
	send, {%MoveKey1% down}
	if(MoveKey2!="None")
		send, {%MoveKey2% down}
	sleep, %MoveTime%
	send, {%MoveKey1% up}
	if(MoveKey2!="None")
		send, {%MoveKey2% up}
}
nm_releaseKeys(){
	global state
	global CurrentFieldNum
	GuiControlGet, FieldPatternShift%CurrentFieldNum%
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	send, {%FwdKey% up}
	send, {%LeftKey% up}
	send, {%BackKey% up}
	send, {%RightKey% up}
	send, {space up}
	send, {click up}
	if(state="Gathering" && FieldPatternShift%CurrentFieldNum%)
		send, {shift}
}
DisconnectCheck(){
	global FwdKey
	global RightKey
	global MoveSpeedFactor
	global LastClock
	global KeyDelay
	global WindowedScreen
	global Roblox
	GuiControlGet, PrivServer
	if(not RegExMatch(PrivServer, "i)^((http(s)?):\/\/)?((www|web)\.)?roblox\.com\/games\/1537690962\?privateServerLinkCode=\d{32}$")){
		;null out the private server link for this disconnect
		PrivServer:=
		nm_setStatus("Error", "Private Server Link Invalid")
	}
	global ReloadRobloxSecs
	global TotalDisconnects, SessionDisconnects
	PublicServer:="https://www.roblox.com/games/4189852503?privateServerLinkCode=94175309348158422142147035472390"
	while(1){
		If (nm_imgSearch("disconnected.png",25, "center")[1] = 1 && WinExist("Roblox")){
			return 0
		}
		if (!ReloadRobloxSecs || ReloadRobloxSecs=0)
			ReloadRobloxSecs:=60
		nm_setStatus("Disconnected", "Reconnecting")
		if(A_Index=1){
			TotalDisconnects:=TotalDisconnects+1
			SessionDisconnects:=SessionDisconnects+1
			IniWrite, %TotalDisconnects%, nm_config.ini, Status, TotalDisconnects
			IniWrite, %SessionDisconnects%, nm_config.ini, Status, SessionDisconnects
		}
		StringLen, linklen, PrivServer
		if (linklen > 0 && A_Index<10){
			WinClose, Roblox
			run, %PrivServer%
		} else {
			WinClose, Roblox
			run, %PublicServer%
			sleep, ReloadRobloxSecs * 1000
		}
		sleep, ReloadRobloxSecs * 1000
		;if (linklen > 0){
			browsers := ["msedge.exe","chrome.exe","ieplore.exe","firefox.exe","opera.exe","brave.exe"]
			for i, value in browsers {
				if (WinExist("ahk_exe "value)){
					winactivate, ahk_exe %value%
					winwaitactive, ahk_exe %value%
					send ^w
				}
			}
		;}
		sleep, 3000
		if WinExist("Roblox"){
			WinActivate, Roblox
			WinWaitActive, Roblox
			send {LWin down}
			send {Up down}
			sleep 50
			send {LWin up}
			send {Up up}
			break
		}
	}
	halt:=0
	loop 10 {
		winactivate, Roblox
		;reset
		if(A_Index>1) {
			SetKeyDelay , (170+KeyDelay)
			send {esc}
			sleep, 100
			send r
			sleep, 100
			send {enter}
			sleep,7000
		}
		SetKeyDelay , (100+KeyDelay)
		;look for hive slot
		nm_Move(10000*MoveSpeedFactor, FwdKey)
		nm_Move(7000*MoveSpeedFactor, RightKey)
		nm_findHiveslot()
		;set hiveslot
		If (nm_imgSearch("e_button.png",30,"high")[1] = 0){
			LastClock:=nowUnix()
			IniWrite, %LastClock%, nm_config.ini, Collect, LastClock
			HiveSlot:=6
			IniWrite, %HiveSlot%, nm_config.ini, Settings, HiveSlot
			break
		}
		if(A_Index=10){
			halt:=1
		}
	}
	if(halt){
		;MsgBox "Unable to Log into Roblox Server."
		;pause
	}
	send e
	return 1
}
nm_deathCheck(){
	global resetTime
	global youDied
	if ((nowUnix()-ResetTime)>10) {
		searchRet := nm_imgSearch("died.png",50,"lowright")
		If (searchRet[1] = 0) {
			youDied:=1
			nm_setStatus("You Died")
		}
	}
	
}
nm_activeHoney(){
	global HiveBees
	WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
    x1 := (windowWidth/2)-65
    x2 := (windowWidth/2)
    PixelSearch, bx2, by2, x1, 0, x2, 65, 0x80E3FF, 10, Fast
	;PixelSearch, bx2, by2, x1, 0, x2, 65, 0xF3DB7E, 20, RGB Fast
    if not ErrorLevel
	{
        return 1
	} else {
		if(HiveBees<25){
			x1 := (windowWidth/2)+235
			x2 := (windowWidth/2)+275
			PixelSearch, bx2, by2, x1, 0, x2, 65, 0xFFFFFF, 10, Fast
			;PixelSearch, bx2, by2, x1, 0, x2, 65, 0xFFFFFF, 10, RGB Fast
			
			if not ErrorLevel
			{
				return 1
			} else {
				return 0
			}
		}else{
		; return 0
		}
    }
}
nm_searchForE(){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global MoveSpeedFactor
	dist:=500
	size:=0
	loop 4 {
		size:=size+1
		loop %size% {
			nm_Move(dist*MoveSpeedFactor, FwdKey)
			sleep, 100
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				return 1
			}
		}
		loop %size% {
			nm_Move(dist*MoveSpeedFactor, LeftKey)
			sleep, 100
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				return 1
			}
		}
		size:=size+1
		loop %size% {
			nm_Move(dist*MoveSpeedFactor, BackKey)
			sleep, 100
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				return 1
			}
		}
		loop %size% {
			nm_Move(dist*MoveSpeedFactor, RightKey)
			sleep, 100
			If (nm_imgSearch("e_button.png",30,"high")[1] = 0) {
				return 1
			}
		}
	}
	return 0
}
nm_dayOrNight(){
	global confirm
	global dayOrNight
	global disableDayorNight
	global VBState ;0=no VB, 1=searching for VB, 2=VB found
	global StingerCheck
	global NightLastDetected
	global VBLastKilled
	GuiControl, Text, VBState, %VBState%
	if (disableDayorNight || !StingerCheck)
		return
	if(((VBState=1) && ((nowUnix()-NightLastDetected)>(6*60) || (nowUnix()-NightLastDetected)<0)) || ((VBState=2) && ((nowUnix()-VBLastKilled)>(5*60) || (nowUnix()-VBLastKilled)<0))) {
		VBState:=0
	}
	searchRet := nm_imgSearch("grassD.png",5,"low")
	If (searchRet[1] = 0) {
		dayOrNight:="Day"
	} else {
		searchRet := nm_imgSearch("grassN.png",5,"low")
		If (searchRet[1] = 0) {
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
		if((nowUnix()-NightLastDetected)>(5*60) || (nowUnix()-NightLastDetected)<0) { ;at least 5 minutes since last time it was night
			NightLastDetected:=nowUnix()
			IniWrite, %NightLastDetected%, nm_config.ini, Collect, NightLastDetected
			if(StingerCheck && VBState=0)
				VBState:=1 ;0=no VB, 1=searching for VB, 2=VB found
		}
	}
	GuiControl,Text, timeOfDay, %dayOrNight%
	if(winexist("Timers"))
		IniWrite, %dayOrNight%, nm_config.ini, gui, DayOrNight
}
nm_ViciousCheck(){
	global VBState ;0=no VB, 1=searching for VB, 2=VB found
	global VBLastKilled
	global TotalViciousKills, SessionViciousKills
	send, /
	send, {Enter}
	sleep, 100
	if(VBState=1){
		if(nm_imgSearch("VBfoundSymbol2.png", 50, "highright")[1]=0){
			VBState:=2
			VBLastKilled:=nowUnix()
			IniWrite, %VBLastKilled%, nm_config.ini, Collect, VBLastKilled
			nm_setStatus("Attacking")
		}
		;check if VB was already killed by someone else
		if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
			VBState:=0
			nm_setStatus("Defeated")
			VBLastKilled:=nowUnix()
			IniWrite, %VBLastKilled%, nm_config.ini, Collect, VBLastKilled
		}
	}
	if(VBState=2){
		if((nowUnix()-VBLastKilled)<(5*60)) { ;it has been less than 5 minutes since VB was found
			if(nm_imgSearch("VBdeadSymbol2.png",1, "highright")[1]=0){
				VBState:=0
				nm_setStatus("Defeated")
				VBLastKilled:=nowUnix()
				IniWrite, %VBLastKilled%, nm_config.ini, Collect, VBLastKilled
				TotalViciousKills:=TotalViciousKills+1
				SessionViciousKills:=SessionViciousKills+1
				IniWrite, %TotalViciousKills%, nm_config.ini, Status, TotalViciousKills
				IniWrite, %SessionViciousKills%, nm_config.ini, Status, SessionViciousKills
			}
		} else if((nowUnix()-VBLastKilled)>(5*60)) { ;it has been greater than 5 minutes since VB was found
				VBState:=0
				nm_setStatus("Timed-Out")
		}
	}
}

nm_locateVB(){
	global VBState
	global StingerCheck
	if(not StingerCheck) {
		VBState:=0
		return
	}
	global StingerPepperCheck
	global StingerMountainTopCheck
	global StingerRoseCheck
	global StingerCactusCheck
	global StingerSpiderCheck
	global StingerCloverCheck
	global NightLastDetected
	global VBLastKilled
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global MoveSpeedFactor
	global MoveMethod
	global objective
	global DisableToolUse
	if(((nowUnix()-NightLastDetected)<(5*60) || (nowUnix()-NightLastDetected)<0)) { ;no more than 5 minutes since NightLastDetected
		loop, 1 {
			if(VBState=1){
				nm_setStatus("Confirming", "Night")
				;confirm it is actually night and not a false positive
				nm_Reset(0)
				loop 3 {
				send, {%RotRight%}
				}
				loop 3 {
				send, {PgDn}
				}
				findImg := nm_imgSearch("nightsky.png", 50, "abovebuff")
				if(findImg[1]=0){
					;night confirmed, proceed!
					loop 3 {
						send, {%RotLeft%}
					}
					loop 3 {
						send, {PgUp}
					}
					nm_setStatus("Searching")
					goto VBPepperBypass
				} else If (findImg[1]=1) {
					;false positive, ABORT!
					NightLastDetected:=nowUnix()-5*60-1 ;make NightLastDetected older than 5 minutes
					IniWrite, %NightLastDetected%, nm_config.ini, Collect, NightLastDetected
					;msgbox false alarm!
					break
				}
			}
			startTime:=nowUnix()
			;Check PEPPER
			VBPepperStart:
			if(VBState=0)
				break
			if(not StingerPepperCheck)
				goto VBMountainTopStart
			;fieldName:="Pepper"
			nm_Reset(0)
			VBPepperBypass:
			battleDist:=1000
			if(not StingerPepperCheck)
				goto VBMountainTopSBypass
			objective:="Vicious Bee (Pepper)"
			nm_gotoRamp()
			if(MoveMethod="walk") {
				nm_walkTo("pepper")
			} else {
				nm_gotoCannon()
				nm_cannonTo("pepper")
			}
			nm_setStatus("Searching")

			;configure
			reps:=2
			leftOrRightDist:=4000
			forwardOrBackDist:=900
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(1700*MoveSpeedFactor, RightKey)
			nm_Move(1700*MoveSpeedFactor, FwdKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBPepperStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<reps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBPepperStart
					nm_ViciousCheck()
				}
				if(VBState=2){
					nm_Move((forwardOrBackDist*2*(reps-0.5)*MoveSpeedFactor), FwdKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
				}
			}
			;battle pattern
			;configure
			breps:=1
			leftOrRightDist:=3000
			forwardOrBackDist:=1000
			if(VBState=2){
				while (VBState=2) {
					loop, %breps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBPepperStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<breps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBPepperStart
					nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
			click, up
			;Check MOUNTAIN TOP
			VBMountainTopStart:
			if(VBState=0)
				break
			if(not StingerMountainTopCheck)
				goto VBRoseStart
			nm_Reset(0)
			VBMountainTopSBypass:
			objective:="Vicious Bee (Mountain Top)"
			nm_gotoRamp()
			if(MoveMethod="walk") {
				nm_walkTo("mountain top")
			} else {
				nm_gotoCannon()
				nm_cannonTo("mountain top")
				loop 2 {
					send {%RotLeft%}
				}
			}
			nm_setStatus("Searching")
			;configure
			reps:=1
			leftOrRightDist:=3500
			forwardOrBackDist:=1500
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(2000*MoveSpeedFactor, RightKey)
			nm_Move(1600*MoveSpeedFactor, FwdKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(not nm_activeHoney())
						goto VBMountainTopStart
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					if(not nm_activeHoney())
						goto VBMountainTopStart
					nm_ViciousCheck()
				}
				if(VBState=2){
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, FwdKey)
				}
			}
			;battle pattern
			if(VBState=2){
				;configure
				breps:=1
				leftOrRightDist:=3000
				forwardOrBackDist:=1000
				while (VBState=2) {
					loop, %breps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBMountainTopStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<breps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBMountainTopStart
					nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
			click, up
			;Check ROSE
			VBRoseStart:
			if(VBState=0)
				break
			if(not StingerRoseCheck)
				goto VBCactusStart
			nm_Reset(0)
			objective:="Vicious Bee (Rose)"
			nm_gotoRamp()
			if(MoveMethod="walk") {
				nm_walkTo("rose")
			} else {
				nm_gotoCannon()
				nm_cannonTo("rose")
			}
			nm_setStatus("Searching")
			;configure
			reps:=2
			leftOrRightDist:=2750
			forwardOrBackDist:=1500
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(1200*MoveSpeedFactor, RightKey)
			nm_Move(1875*MoveSpeedFactor, FwdKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBRoseStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<reps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBRoseStart
					nm_ViciousCheck()
				}
				if(VBState=2){
					nm_Move((forwardOrBackDist*2*(reps)*MoveSpeedFactor), FwdKey)
					nm_Move((forwardOrBackDist*MoveSpeedFactor), BackKey)
				}
			}
			;battle pattern
			;configure
			breps:=1
			leftOrRightDist:=2500
			forwardOrBackDist:=1000
			if(VBState=2){
				while (VBState=2) {
					loop, %breps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBRoseStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<breps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBRoseStart
					nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
			click, up
			;Check CACTUS
			VBCactusStart:
			if(VBState=0)
				break
			if(not StingerCactusCheck) {
				nm_Reset(0)
				objective:="Vicious Bee (Spider)"
				nm_gotoRamp()
				if(MoveMethod="walk") {
					nm_walkTo("spider")
				} else {
					nm_gotoCannon()
					nm_cannonTo("spider")
				}
				nm_setStatus("Searching")
				if(!DisableToolUse)
					click, down
				nm_Move(4500*MoveSpeedFactor, FwdKey)
				nm_Move(3000*MoveSpeedFactor, LeftKey)
				goto VBSpiderStart
			}
			nm_Reset(0)
			objective:="Vicious Bee (Cactus)"
			nm_gotoRamp()
			if(MoveMethod="walk") {
				nm_walkTo("cactus")
			} else {
				nm_gotoCannon()
				nm_cannonTo("cactus")
			}
			nm_setStatus("Searching")
			;configure
			reps:=1
			leftOrRightDist:=5000
			forwardOrBackDist:=1500
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(2000*MoveSpeedFactor, RightKey)
			nm_Move(600*MoveSpeedFactor, FwdKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBCactusStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<reps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBCactusStart
					nm_ViciousCheck()
				}
				nm_Move((forwardOrBackDist*2*(reps-0.5)*MoveSpeedFactor), FwdKey)
			}
			nm_ViciousCheck()
			;battle pattern
			;configure
			breps:=1
			leftOrRightDist:=3250
			forwardOrBackDist:=750
			if(VBState=2){
				while (VBState=2) {
					loop, %breps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBCactusStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<breps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBCactusStart
					nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
			click, up
			;Check SPIDER
			if(VBState=0)
				break
			;walk to Spider from Cactus
			objective:="Vicious Bee (Spider)"
			nm_Move(7000*MoveSpeedFactor, LeftKey)
			nm_Move(2500*MoveSpeedFactor, FwdKey)
			loop 4 {
				send {%RotLeft%}
			}
			nm_Move(2000*MoveSpeedFactor, RightKey)
			nm_Move(3500*MoveSpeedFactor, FwdKey)
			nm_Move(2000*MoveSpeedFactor, LeftKey)
			;configure
			reps:=2
			leftOrRightDist:=3750
			forwardOrBackDist:=1500
			VBSpiderStart:
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(1000*MoveSpeedFactor, RightKey)
			nm_Move(1000*MoveSpeedFactor, BackKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<reps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
						if(not nm_activeHoney()) {
							nm_Reset(0)
							nm_gotoRamp()
							if(MoveMethod="walk") {
								nm_walkTo("spider")
							} else {
								nm_gotoCannon()
								nm_cannonTo("spider")
							}
							nm_Move(4500*MoveSpeedFactor, FwdKey)
							nm_Move(3000*MoveSpeedFactor, LeftKey)
							goto VBSpiderStart
						}
						nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney()) {
						nm_Reset(0)
						nm_gotoRamp()
						if(MoveMethod="walk") {
							nm_walkTo("spider")
						} else {
							nm_gotoCannon()
							nm_cannonTo("spider")
						}
						nm_Move(4500*MoveSpeedFactor, FwdKey)
						nm_Move(3000*MoveSpeedFactor, LeftKey)
						goto VBSpiderStart
					}
					nm_ViciousCheck()
				}
				if(VBState=2){
					nm_Move((forwardOrBackDist*2*(reps-0.5)*MoveSpeedFactor), FwdKey)
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move((forwardOrBackDist*MoveSpeedFactor), BackKey)
				}
			}
			;battle pattern
			;configure
			breps:=1
			leftOrRightDist:=2500
			forwardOrBackDist:=1000
			if(VBState=2){
				while (VBState=2) {
					loop, %breps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					nm_Move((forwardOrBackDist*MoveSpeedFactor), BackKey)
					if(not nm_activeHoney()) {
						nm_Reset(0)
						nm_gotoRamp()
						if(MoveMethod="walk") {
							nm_walkTo("spider")
						} else {
							nm_gotoCannon()
							nm_cannonTo("spider")
						}
						nm_Move(4500*MoveSpeedFactor, FwdKey)
						nm_Move(3000*MoveSpeedFactor, LeftKey)
						goto VBSpiderStart
					}
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					if(A_Index<breps) {
						nm_Move((forwardOrBackDist*MoveSpeedFactor), BackKey)
					}
					if(not nm_activeHoney()) {
						nm_Reset(0)
						nm_gotoRamp()
						if(MoveMethod="walk") {
							nm_walkTo("spider")
						} else {
							nm_gotoCannon()
							nm_cannonTo("spider")
						}
						nm_Move(4500*MoveSpeedFactor, FwdKey)
						nm_Move(3000*MoveSpeedFactor, LeftKey)
						goto VBSpiderStart
					}
					nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
			click, up
			;Check CLOVER
			VBCloverStart:
			if(VBState=0)
				break
			if(not StingerCloverCheck)
				break
			nm_Reset(0)
			objective:="Vicious Bee (Clover)"
			nm_gotoRamp()
			if(MoveMethod="walk") {
				nm_walkTo("clover")
			} else {
				nm_gotoCannon()
				nm_cannonTo("clover")
			}
			nm_setStatus("Searching")
			;configure
			reps:=2
			leftOrRightDist:=3000
			forwardOrBackDist:=1000
			;starting point
			if(!DisableToolUse)
				click, down
			nm_Move(1500*MoveSpeedFactor, RightKey)
			nm_Move(1500*MoveSpeedFactor, FwdKey)
			;search pattern
			if(VBState=1){
				loop, %reps% {
					nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					if(not nm_activeHoney())
						goto VBCloverStart
					nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
					if(A_Index<reps) {
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
					}
					if(not nm_activeHoney())
						goto VBCloverStart
					nm_ViciousCheck()
				}
				if(VBState=2){
					nm_Move((forwardOrBackDist*2*(reps-0.5)*MoveSpeedFactor), FwdKey)
					nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
				}
			}
			;battle pattern
			;configure
			breps:=1
			leftOrRightDist:=1800
			forwardOrBackDist:=1000
			if(VBState=2){
				while (VBState=2) {
					loop, %breps% {
						nm_Move(leftOrRightDist*MoveSpeedFactor, LeftKey)
						nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
						if(not nm_activeHoney())
							goto VBCloverStart
						nm_Move(leftOrRightDist*MoveSpeedFactor, RightKey)
						if(A_Index<breps) {
							nm_Move(forwardOrBackDist*MoveSpeedFactor, BackKey)
						}
						if(not nm_activeHoney())
							goto VBCloverStart
						nm_ViciousCheck()
					}
					nm_Move((forwardOrBackDist*2*(breps-0.5)*MoveSpeedFactor), FwdKey)
				}
			}
		}
		click, up
		VBState:=0 ;0=no VB, 1=searching for VB, 2=VB found
		stopTime:=nowUnix()
		cycleTime:=stopTime-startTime
		return
	} else { ;it has been more than 5 minutes since NightLastDetected
		if((nowUnix()-VBLastKilled)>(5*60) || (nowUnix()-VBLastKilled)<0) { ;more than 5 minutes since VBLastKilled
			VBState:=0
			return
		}
	}
}
nm_hotbar(){
	global state
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
			Iniwrite, %LastHotkeyN%, nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;attacking
		else if(state="Attacking" && ActiveHotkeys[key][1]="Attacking" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;gathering
		else if(state="Gathering" && ActiveHotkeys[key][1]="Gathering" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
		;at hive
		else if(state="Converting" && ActiveHotkeys[key][1]="At Hive" && (nowUnix()-ActiveHotkeys[key][4])>ActiveHotkeys[key][3]) {
			HotkeyNum:=ActiveHotkeys[key][2]
			send {%HotkeyNum%}
			LastHotkeyN:=nowUnix()
			Iniwrite, %LastHotkeyN%, nm_config.ini, Boost, LastHotkey%HotkeyNum%
			ActiveHotkeys[key][4]:=LastHotkeyN
			break
		}
	}
}
nm_HoneyQuest(){
	global HoneyStart:=[]
	global HoneyQuestCheck
	global HoneyQuestComplete:=1
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global Roblox
	global state
	if(!HoneyQuestCheck)
		return
	imgPos := nm_imgSearch("questlog.png",10, "left")
	If (imgPos[1] != 0){
		MouseMove, 140, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep 50
		MouseMove, 350, (Roblox[3]+70)
	}
	;search for Honey Bee Quest
	imgPos := nm_imgSearch("honeyhunt.png",10, "quest")
	If (imgPos[1]=0){ ;honey bee quest found
		Qfound:=imgPos
	} else { ;honey bee quest not found
		;scroll through log to find quest
		MouseMove, 30, (Roblox[3]+225), 5
		Loop, 30 {
			send, {WheelUp 1}
			Sleep, 50
		}
		Loop, 25 {
			;search for Honey Bee Quest
			imgPos := nm_imgSearch("honeyhunt.png",100, "quest")
			If (imgPos[1]=0) { ;honey bee quest found
				Qfound:=imgPos
				break
			}
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 350
		}
	}
	if(Qfound[1]=0){
		MouseMove, 350, (Roblox[3]+70)
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
		xi := 0
		yi := Qfound[3]
		ww := windowWidth / 2
		wh := windowHeight
		fileName:="questlog.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if (ErrorLevel = 2){
				MsgBox Image file %filename% was not found in:`nnm_image_assets\
				pause
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		HoneyStart:=[ErrorLevel, FoundX, FoundY+3]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := HoneyStart[3]+15
			ww := windowWidth / 2
			wh := HoneyStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-HoneyStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := HoneyStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbarinset.png
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
		GuiControl,,HoneyQuestProgress, %honeyProgress%
	}
	if(HoneyQuestComplete)
		nm_gotoQuestgiver("honey")
	;close quest menu
	imgPos := nm_imgSearch("questlog.png",10, "left")
	If (imgPos[1] = 0){
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep 50
		MouseMove, 350, (Roblox[3]+70)
	}
}
nm_PolarQuestProg(){
	global PolarQuestCheck
	global PolarBear
	global PolarQuest
	global PolarStart
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
	global Roblox
	global state
	if(!PolarQuestCheck)
		return
	imgPos := nm_imgSearch("questlog.png",10, "left")
	If (imgPos[1] != 0){
		MouseMove, 140, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 350, (Roblox[3]+70)
	}
	;search for Polar Quest
	imgPos := nm_imgSearch("polar_bear.png",10, "left")
	imgPos2 := nm_imgSearch("polar_bear2.png",10, "left")
	If (imgPos[1]=0 || imgPos2[1]=0){ ;polar quest found
		If (imgPos[1]=0){
			Qfound:=imgPos
		} else if (imgPos2[1]=0) {
			Qfound:=imgPos2
		}
	} else { ;polar quest not found
		;scroll through log to find quest
		MouseMove, 30, (Roblox[3]+225), 5
		Loop, 30 {
			send, {WheelUp 1}
			Sleep, 50
		}
		Loop, 25 {
			;search for Polar Quest
			imgPos := nm_imgSearch("polar_bear.png",10, "left")
			imgPos2 := nm_imgSearch("polar_bear2.png",10, "left")
			If (imgPos[1]=0 || imgPos2[1]=0){ ;polar quest found
				If (imgPos[1]=0){
					Qfound:=imgPos
					break
				} else if (imgPos2[1]=0) {
					Qfound:=imgPos2
					break
				}
			}
			if(Qfound[1]=0)
				break
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 350
		}
	}
	if(Qfound[1]=0){
		MouseMove, 350, (Roblox[3]+70)
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
		xi := 0
		yi := Qfound[3]
		ww := windowWidth / 2
		wh := windowHeight
		fileName:="questlog.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if (ErrorLevel = 2){
				MsgBox Image file %filename% was not found in:`nnm_image_assets\
				pause
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		PolarStart:=[ErrorLevel, FoundX, FoundY+3]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := PolarStart[3]+15
			ww := windowWidth / 2
			wh := PolarStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-PolarStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := PolarStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbarinset.png
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
		yi := PolarStart[3]-30
		ww := windowWidth / 2
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
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *10 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, (Roblox[3]+225)
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, (Roblox[3]+70)
						break
					}
				}
			}
		}
		;Update Polar quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		newLine:="`n"
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
				polarProgress:=(PolarQuest . newline . action . " " . where . ": " . completeness)
			else
				polarProgress:=(polarProgress . newline . action . " " . where . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		GuiControl,,PolarQuestProgress, %polarProgress%
		polarProgressIni := StrReplace(polarProgress, "`n" , "|")
		IniWrite, %polarProgressIni%, nm_config.ini, Quests, PolarQuestProgress
		if(QuestLadybugs=0 && QuestRhinoBeetles=0 && QuestSpider=0 && QuestMantis=0 && QuestScorpions=0 && QuestWerewolf=0 && QuestGatherField="None") {
			PolarQuestComplete:=1
		}
	}
}
nm_PolarQuest(){
	global PolarQuestCheck, PolarQuest
	global QuestGatherField
	global QuestLadybugs
	global QuestRhinoBeetles
	global QuestSpider
	global QuestMantis
	global QuestScorpions
	global QuestWerewolf
	global LastBugrunLadybugs
	global LastBugrunRhinoBeetles
	global LastBugrunSpider
	global LastBugrunMantis
	global LastBugrunScorpions
	global LastBugrunWerewolf
	global GiftedViciousCheck
	global PolarQuestComplete
	global RotateQuest
	global Roblox
	if(!PolarQuestCheck)
		return
	RotateQuest:="Polar"
	nm_PolarQuestProg()
	if(PolarQuestComplete) {
		nm_gotoQuestgiver("polar")
		nm_PolarQuestProg()
		if(!PolarQuestComplete){
			nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
		}
	}
	;do quest stuff
	while(QuestGatherField!="None" || (QuestLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || (QuestRhinoBeetlesbugs && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || (QuestSpider && (nowUnix()-LastBugrunSpider)>floor(1830*(1-GiftedViciousCheck*.15))) || (QuestMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15))) || (QuestScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15))) || (QuestWerewolf && (nowUnix()-LastWerewolf)>floor(3600*(1-GiftedViciousCheck*.15)))){
		nm_Bugrun()
		nm_PolarQuestProg()
		while(QuestGatherField!="None") {
			nm_questGather("polar")
			nm_PolarQuestProg()
		}
		if(PolarQuestComplete) {
			nm_gotoQuestgiver("polar")
			nm_PolarQuestProg()
			if(!PolarQuestComplete){
				nm_setStatus("Starting", "Polar Quest: " . PolarQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
	;close quest menu
	imgPos := nm_imgSearch("questlog.png",10, "left")
	If (imgPos[1] = 0){
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 350, (Roblox[3]+70)
	}
}
nm_QuestRotate(){
	global RotateQuest
	global BlackQuestCheck, BlackQuestComplete, LastBlackQuest, BuckoQuestCheck, BuckoQuestComplete, RileyQuestCheck, RileyQuestComplete
	;polar bear
	nm_PolarQuest()
	;black bear quest first
	nm_BlackQuest()
	;black bear quest is complete but not yet time to turn in, move onto next quest
	if(BlackQuestCheck=0 || (BlackQuestComplete && (nowUnix()-LastBlackQuest)<3600)) {
		;bucko quest
		;msgbox move onto bucko quests!
		nm_BuckoQuest()
		if(BuckoQuestCheck=0 || BuckoQuestComplete=2) {
			nm_RileyQuest()
		}
	}
	;honey bee quest
	nm_HoneyQuest()
	
}
nm_Feed(food){
	global Roblox
	WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	nm_Reset()
	imgPos := nm_imgSearch("ItemMenu.png",10, "left")
	If (imgPos[1]=1){
		MouseMove, 30, (Roblox[3]+120)
		Click
		MouseMove, 350, (Roblox[3]+70)
		sleep, 500
	}
	;check if food is already visible
	itemPos := nm_imgSearch(food . ".png", 50, "left")
	If (itemPos[1]=0){
		MouseClickDrag, Left, 30, (itemPos[3]+30), (windowWidth/2), (windowHeight/2), 5
		sleep, 1000
		imgPos := nm_imgSearch("feeder.png",30)
		If (imgPos[1]=0){
			SetKeyDelay, 50
			MouseMove, imgPos[2],imgPos[3]
			sleep 100
			Click
			sleep 100
			send 100
			SetKeyDelay, 10
			sleep 1000
			imgPos := nm_imgSearch("feed.png",30)
			If (imgPos[1]=0){
				MouseMove, imgPos[2],imgPos[3]
				Click
			}
			MouseMove, 350, (Roblox[3]+70)
		}	
	} else { ;scroll through menu to find food
		loop, 2 {
			MouseMove, 30, (Roblox[2]+200), 5
		}
		MouseMove, 30, (Roblox[2]+200), 5
	    Loop, 50 {
			send, {WheelUp 1}
			Sleep, 50
		}
		MouseMove, 30, (Roblox[2]+200), 5
		Loop, 50 {
			itemPos := nm_imgSearch(food . ".png", 50, "left")
			If (itemPos[1]=0){
				MouseClickDrag, Left, (itemPos[2]-60), (itemPos[3]+40), (windowWidth/2), (windowHeight/2), 5
				sleep, 1000
				imgPos := nm_imgSearch("feeder.png",30)
				If (imgPos[1]=0){
					SetKeyDelay, 50
					MouseMove, imgPos[2],imgPos[3]
					sleep 100
					Click
					sleep 100
					send 100
					SetKeyDelay, 10
					sleep 1000
					imgPos := nm_imgSearch("feed.png",30)
					If (imgPos[1]=0){
						MouseMove, imgPos[2],imgPos[3]
						Click
					}
					MouseMove, 350, (Roblox[3]+70)
				}	
			}
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 350
		}
	}
}
nm_RileyQuestProg(){
	global RileyQuestCheck, RileyBee, RileyQuest, RileyStart, HiveBees, FieldName1, LastAntPass, LastRedBoost, RileyLadybugs, RileyScorpions, RileyAll
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global RileyQuestComplete:=1
	global QuestAnt:=0
	global QuestRedBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global Roblox
	global state
	if(!RileyQuestCheck)
		return
	imgPos := nm_imgSearch("questlog.png",10, "quest")
	If (imgPos[1] != 0){
		MouseMove, 140, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 350, (Roblox[3]+70)
		sleep, 1000
	}
	;search for Riley Quest
	imgPos := nm_imgSearch("riley.png",100, "left")
	imgPos2 := nm_imgSearch("riley2.png",100, "left")
	If (imgPos[1]=0 || imgPos2[1]=0){ ;Riley quest found
		If (imgPos[1]=0){
			Qfound:=imgPos
		} else if (imgPos2[1]=0) {
			Qfound:=imgPos2
		}
	} else { ;Riley quest not found
		;scroll through log to find quest
		MouseMove, 5, (Roblox[3]+225), 5
		Loop, 30 {
			send, {WheelUp 1}
			Sleep, 50
		}
		Loop, 25 {
			;search for Riley Quest
			imgPos := nm_imgSearch("riley.png",100, "left")
			imgPos2 := nm_imgSearch("riley2.png",100, "left")
			If (imgPos[1]=0 || imgPos2[1]=0){ ;Riley quest found
				If (imgPos[1]=0){
					Qfound:=imgPos
					break
				} else if (imgPos2[1]=0) {
					Qfound:=imgPos2
					break
				}
			}
			if(Qfound[1]=0) {
				continue
			}
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 750
		}
	}
	if(Qfound[1]=0){
		MouseMove, 350, (Roblox[3]+70)
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
		xi := 0
		yi := Qfound[3]
		ww := windowWidth / 2
		wh := windowHeight
		fileName:="questlog.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if (ErrorLevel = 2){
				MsgBox Image file %filename% was not found in:`nnm_image_assets\
				pause
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		RileyStart:=[ErrorLevel, FoundX, FoundY+3]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := RileyStart[3]+15
			ww := windowWidth / 2
			wh := RileyStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-RileyStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := RileyStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbarinset.png
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
		yi := RileyStart[3]-30
		ww := windowWidth / 2
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
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *10 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, (Roblox[3]+225)
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, (Roblox[3]+70)
						break
					}
				}
				Break
			}
		}
		if(missing) {
			nm_setStatus("Error", "Cannot Locate Quest Name")
		}
		;Update Riley quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		RileyLadybugs:=0
		RileyScorpions:=0
		newLine:="`n"
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
						where:=FieldName1
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
				rileyProgress:=(RileyQuest . newline . action . " " . where . ": " . completeness)
			else
				rileyProgress:=(rileyProgress . newline . action . " " . where . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		GuiControl,,RileyQuestProgress, %rileyProgress%
		rileyProgressIni := StrReplace(rileyProgress, "`n" , "|")
		IniWrite, %rileyProgressIni%, nm_config.ini, Quests, RileyQuestProgress
		if(RileyLadybugs=0 && RileyScorpions=0 && RileyAll=0 && QuestGatherField="None" && QuestAnt=0 && QuestRedBoost=0 && QuestFeed="None") {
				RileyQuestComplete:=1
			} else { ;check if all doable things are done and everything else is on cooldown
				if(((QuestAnt && (nowUnix()-LastAntPass)<7200) || (RileyLadybugs && (nowUnix()-LastBugrunLadybugs)<floor(330*(1-GiftedViciousCheck*.15))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)<floor(1230*(1-GiftedViciousCheck*.15))))) { ;there is at least one thing no longer on cooldown
					RileyQuestComplete:=0
				} else {
					RileyQuestComplete:=2
				}
			}
	} else {
		nm_setStatus("Error", "Cannot Find RileyBee Quest")
	}
}
nm_RileyQuest(){
	global RileyQuestCheck, RileyQuestComplete, RotateQuest, QuestGatherField, Roblox, QuestAnt, QuestRedBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, GiftedViciousCheck, RileyLadybugs, RileyScorpions
	if(!RileyQuestCheck)
		return
	RotateQuest:="Riley"
	nm_RileyQuestProg()
	if(RileyQuestComplete=1) {
		nm_gotoQuestgiver("Riley")
		nm_RileyQuestProg()
		if(RileyQuestComplete!=1){
			nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
		}
	}
	if(RileyQuestComplete!=1){
		if(QuestFeed!="none")
			nm_feed(QuestFeed)
		if(QuestAnt)
			nm_toCollect()
		if(QuestRedBoost)
			nm_ToAnyBooster()
		if((RileyLadybugs && (nowUnix()-LastBugrunLadybugs)>floor(330*(1-GiftedViciousCheck*.15))) || (RileyScorpions && (nowUnix()-LastBugrunScorpions)>floor(1230*(1-GiftedViciousCheck*.15)))) {
			nm_Bugrun()
		}
		nm_RileyQuestProg()
		if(RileyQuestComplete=1) {
			nm_gotoQuestgiver("Riley")
			nm_RileyQuestProg()
			if(!RileyQuestComplete){
				nm_setStatus("Starting", "Riley Quest: " . RileyQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
}
nm_BuckoQuestProg(){
	global BuckoQuestCheck, BuckoBee, BuckoQuest, BuckoStart, HiveBees, FieldName1, LastAntPass, LastBlueBoost, BuckoRhinoBeetles, BuckoMantis
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BuckoQuestComplete:=1
	global QuestAnt:=0
	global QuestBlueBoost:=0
	global QuestFeed:="None"
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global Roblox
	global state
	if(!BuckoQuestCheck)
		return
	imgPos := nm_imgSearch("questlog.png",10, "quest")
	If (imgPos[1] != 0){
		MouseMove, 140, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 350, (Roblox[3]+70)
		sleep, 1000
	}
	;search for Bucko Quest
	imgPos := nm_imgSearch("bucko.png",100, "left")
	imgPos2 := nm_imgSearch("bucko2.png",100, "left")
	If (imgPos[1]=0 || imgPos2[1]=0){ ;bucko quest found
		If (imgPos[1]=0){
			Qfound:=imgPos
		} else if (imgPos2[1]=0) {
			Qfound:=imgPos2
		}
	} else { ;bucko quest not found
		;scroll through log to find quest
		MouseMove, 5, (Roblox[3]+225), 5
		Loop, 30 {
			send, {WheelUp 1}
			Sleep, 50
		}
		Loop, 25 {
			;search for Bucko Quest
			imgPos := nm_imgSearch("bucko.png",100, "left")
			imgPos2 := nm_imgSearch("bucko2.png",100, "left")
			If (imgPos[1]=0 || imgPos2[1]=0){ ;bucko quest found
				If (imgPos[1]=0){
					Qfound:=imgPos
					break
				} else if (imgPos2[1]=0) {
					Qfound:=imgPos2
					break
				}
			}
			if(Qfound[1]=0) {
				continue
			}
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 750
		}
	}
	if(Qfound[1]=0){
		MouseMove, 350, (Roblox[3]+70)
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
		xi := 0
		yi := Qfound[3]
		ww := windowWidth / 2
		wh := windowHeight
		fileName:="questlog.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if (ErrorLevel = 2){
				MsgBox Image file %filename% was not found in:`nnm_image_assets\
				pause
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BuckoStart:=[ErrorLevel, FoundX, FoundY+3]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := BuckoStart[3]+15
			ww := windowWidth / 2
			wh := BuckoStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-BuckoStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := BuckoStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbarinset.png
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
		yi := BuckoStart[3]-30
		ww := windowWidth / 2
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
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *10 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, (Roblox[3]+225)
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, (Roblox[3]+70)
						break
					}
				}
				Break
			}
		}
		if(missing) {
			nm_setStatus("Error", "Cannot Locate Quest Name")
		}
		;Update Bucko quest progress in GUI
		;also set next steps
		BuckoRhinoBeetles:=0
		BuckoMantis:=0
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		newLine:="`n"
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
						where:=FieldName1
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
				buckoProgress:=(BuckoQuest . newline . action . " " . where . ": " . completeness)
			else
				buckoProgress:=(buckoProgress . newline . action . " " . where . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		GuiControl,,BuckoQuestProgress, %buckoProgress%
		buckoProgressIni := StrReplace(buckoProgress, "`n" , "|")
		IniWrite, %buckoProgressIni%, nm_config.ini, Quests, BuckoQuestProgress
		if(BuckoRhinoBeetles=0 && BuckoMantis=0 && QuestGatherField="None" && QuestAnt=0 && QuestBlueBoost=0 && QuestFeed="None") {
				BuckoQuestComplete:=1
			} else { ;check if all doable things are done and everything else is on cooldown
				if(((QuestAnt && (nowUnix()-LastAntPass)<7200) || (BuckoRhinoBeetles && (nowUnix()-LastBugrunRhinoBeetles)<floor(330*(1-GiftedViciousCheck*.15))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)<floor(1230*(1-GiftedViciousCheck*.15))))) { ;there is at least one thing no longer on cooldown
					BuckoQuestComplete:=0
				} else {
					BuckoQuestComplete:=2
				}
			}
	} else {
		nm_setStatus("Error", "Cannot Find BuckoBee Quest")
	}
}
nm_BuckoQuest(){
	global BuckoQuestCheck, BuckoQuestComplete, RotateQuest, QuestGatherField, Roblox, QuestAnt, QuestBlueBoost, QuestFeed, LastBugrunLadybugs, LastBugrunRhinoBeetles, LastBugrunSpider, LastBugrunMantis, LastBugrunScorpions, LastBugrunWerewolf, GiftedViciousCheck
	global BuckoRhinoBeetles, BuckoMantis
	if(!BuckoQuestCheck)
		return
	RotateQuest:="Bucko"
	nm_BuckoQuestProg()
	if(BuckoQuestComplete=1) {
		nm_gotoQuestgiver("bucko")
		nm_BuckoQuestProg()
		if(BuckoQuestComplete!=1){
			nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
		}
	}
	if(BuckoQuestComplete!=1){
		if(QuestFeed!="none")
			nm_feed(QuestFeed)
		if(QuestAnt)
			nm_toCollect()
		if(QuestBlueBoost)
			nm_ToAnyBooster()
		if((BuckoRhinoBeetlesbugs && (nowUnix()-LastBugrunRhinoBeetles)>floor(330*(1-GiftedViciousCheck*.15))) || (BuckoMantis && (nowUnix()-LastBugrunMantis)>floor(1230*(1-GiftedViciousCheck*.15)))) {
			nm_Bugrun()
		}
		nm_BuckoQuestProg()
		if(BuckoQuestComplete=1) {
			nm_gotoQuestgiver("bucko")
			nm_BuckoQuestProg()
			if(!BuckoQuestComplete){
				nm_setStatus("Starting", "Bucko Quest: " . BuckoQuest)
				TotalQuestsComplete:=TotalQuestsComplete+1
				SessionQuestsComplete:=SessionQuestsComplete+1
				IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
				IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
			}
		}
	}
}
nm_BlackQuestProg(){
	global BlackQuestCheck, BlackBear, BlackQuest, BlackStart, HiveBees, FieldName1
	global QuestGatherField:="None"
	global QuestGatherFieldSlot:=0
	global BlackQuestComplete:=1
	global QuestBarSize
	global QuestBarGapSize
	global QuestBarInset
	global Roblox
	global state
	if(!BlackQuestCheck)
		return
	imgPos := nm_imgSearch("questlog.png",10, "quest")
	If (imgPos[1] != 0){
		MouseMove, 140, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 85, (Roblox[3]+120)
		Click
		sleep, 50
		MouseMove, 350, (Roblox[3]+70)
		sleep, 1000
	}
	;search for Black Quest
	imgPos := nm_imgSearch("black_bear.png",100, "left")
	imgPos2 := nm_imgSearch("black_bear2.png",100, "left")
	imgPos3 := nm_imgSearch("black_bear3.png",100, "left")
	imgPos4 := nm_imgSearch("black_bear4.png",100, "left")
	If (imgPos[1]=0 || imgPos2[1]=0 || imgPos3[1]=0 || imgPos4[1]=0){ ;black quest found
		If (imgPos[1]=0){
			Qfound:=imgPos
		} else if (imgPos2[1]=0) {
			Qfound:=imgPos2
		} else if (imgPos3[1]=0) {
			Qfound:=imgPos3
		} else if (imgPos4[1]=0) {
			Qfound:=imgPos4
		}
	} else { ;black quest not found
		;scroll through log to find quest
		MouseMove, 5, (Roblox[3]+225), 5
		Loop, 30 {
			send, {WheelUp 1}
			Sleep, 50
		}
		Loop, 25 {
			;search for Black Quest
			imgPos := nm_imgSearch("black_bear.png",100, "left")
			imgPos2 := nm_imgSearch("black_bear2.png",100, "left")
			imgPos3 := nm_imgSearch("black_bear3.png",100, "left")
			imgPos4 := nm_imgSearch("black_bear4.png",100, "left")
			If (imgPos[1]=0 || imgPos2[1]=0 || imgPos3[1]=0 || imgPos4[1]=0){ ;black quest found
				If (imgPos[1]=0){
					Qfound:=imgPos
					break
				} else if (imgPos2[1]=0) {
					Qfound:=imgPos2
					break
				} else if (imgPos3[1]=0) {
					Qfound:=imgPos3
					break
				} else if (imgPos4[1]=0) {
					Qfound:=imgPos4
					break
				}
			}
			if(Qfound[1]=0) {
				continue
			}
			loop, 2 {
				send, {WheelDown 1}
				Sleep, 50
			}
			sleep, 750
		}
	}
	if(Qfound[1]=0){
		MouseMove, 350, (Roblox[3]+70)
		;locate exact bottom of quest title bar coordinates
		;titlebar = 30 pixels high
		;quest objective bar spacing = 10 pixels
		;quest objective bar height = 40 pixels
		WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
		xi := 0
		yi := Qfound[3]
		ww := windowWidth / 2
		wh := windowHeight
		fileName:="questlog.png"
		IfExist, %A_ScriptDir%\nm_image_assets\
		{	
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\%fileName%
			if (ErrorLevel = 2){
				MsgBox Image file %filename% was not found in:`nnm_image_assets\
				pause
			}
		} else {
			MsgBox Folder location cannot be found:`n%A_ScriptDir%\nm_image_assets\
		}
		BlackStart:=[ErrorLevel, FoundX, FoundY+3]
		;determine quest bar sizes and spacing
		if(QuestBarGapSize=0 || QuestBarSize=0 || QuestBarInset=0) {
			xi := 0
			yi := BlackStart[3]+15
			ww := windowWidth / 2
			wh := BlackStart[3]+100
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
			if(ErrorLevel=0) {
				QuestBarSize:=FoundY-BlackStart[3]
				QuestBarGapSize:=3
				QuestBarInset:=3
				NextY:=FoundY+1
				NextX:=FoundX+1
				loop 20 {
					ImageSearch, FoundX, FoundY, %FoundX%, %NextY%, %ww%, %wh%, *10 nm_image_assets\questbargap.png
					if(ErrorLevel=0) {
						NextY:=FoundY+1
						QuestBarGapSize:=QuestBarGapSize+1
					} else {
						break
					}
				}
				wh := BlackStart[3]+200
				loop 20 {
					ImageSearch, FoundX, FoundY, %NextX%, %yi%, %ww%, %wh%, *10 nm_image_assets\questbarinset.png
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
		yi := BlackStart[3]-30
		ww := windowWidth / 2
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
						ImageSearch, FoundX, FoundY, QuestBarInset, NextY, QuestBarInset+300, NextY+QuestBarGapSize, *10 nm_image_assets\questbargap.png
						if(ErrorLevel=0) {
							NextY:=NextY+QuestBarSize
							found:=found+1
						} else {
							break
						}
					}
					if(found<questSteps) {
						MouseMove, 30, (Roblox[3]+225)
						Sleep, 50
						send, {WheelDown 1}
						Sleep, 50
					} else {
						MouseMove, 350, (Roblox[3]+70)
						break
					}
				}
				Break
			}
		}
		if(missing) {
			nm_setStatus("Error", "Cannot Locate Quest Name")
			;msgbox Black Bear Questname cannot be found!
		}
		;Update Black quest progress in GUI
		;also set next steps
		QuestGatherField:="None"
		QuestGatherFieldSlot:=0
		newLine:="`n"
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
					where:=FieldName1
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
				blackProgress:=(BlackQuest . newline . action . " " . where . ": " . completeness)
			else
				blackProgress:=(blackProgress . newline . action . " " . where . ": " . completeness)
		}
;msgbox Bar1=%temp1%`nBar2=%temp2%`nBar3=%temp3%`nBar4=%temp4%`nBar5=%temp5%`nBar6=%temp6%
		GuiControl,,BlackQuestProgress, %blackProgress%
		blackProgressIni := StrReplace(blackProgress, "`n" , "|")
		IniWrite, %blackProgressIni%, nm_config.ini, Quests, BlackQuestProgress
		if(QuestGatherField="None") {
			BlackQuestComplete:=1
		}
	} else {
		nm_setStatus("Error", "Cannot Find Black Bear Quest")
		;msgbox Black Bear quest cannot be found!
	}
}
nm_BlackQuest(){
	global BlackQuestCheck
	global QuestGatherField
	global BlackQuestComplete, LastBlackQuest, RotateQuest
	global Roblox
	if(!BlackQuestCheck)
		return
	RotateQuest:="Black"
	nm_BlackQuestProg()
	if(BlackQuestComplete && (nowUnix()-LastBlackQuest)>3600) {
		nm_gotoQuestgiver("black")
		nm_BlackQuestProg()
		if(!BlackQuestComplete){
			nm_setStatus("Starting", "Black Bear Quest: " . BlackQuest)
			TotalQuestsComplete:=TotalQuestsComplete+1
			SessionQuestsComplete:=SessionQuestsComplete+1
			IniWrite, %TotalQuestsComplete%, nm_config.ini, Status, TotalQuestsComplete
			IniWrite, %SessionQuestsComplete%, nm_config.ini, Status, SessionQuestsComplete
		}
		LastBlackQuest:=nowUnix()
		IniWrite, %LastBlackQuest%, nm_config.ini, Quests, LastBlackQuest
	}
}
nm_questGather(quest){
	global QuestGatherField
	global QuestGatherFieldSlot
	global PolarStart, PolarQuest, PolarQuestComplete, BlackStart, BlackQuest, BlackQuestComplete
	global MoveMethod
	global BackpackPercentFiltered
	global TCFBKey
	global AFCFBKey
	global TCLRKey
	global AFCLRKey
	global YouDied
	thisfield:=QuestGatherField
	if(QuestGatherField="none")
		return
	;set direction keys
	TCFBKey:=FwdKey
	AFCFBKey:=BackKey
	TCLRKey:=LeftKey
	AFCLRKey:=RightKey
	;reset
	nm_Reset()
	objective:=("Polar Quest: " . QuestGatherField)
	nm_gotoRamp()
	;goto field
	if(MoveMethod="Walk"){
		nm_walkTo(QuestGatherField)
	} else if (MoveMethod="Cannon"){
		nm_gotoCannon()
		nm_cannonTo(QuestGatherField)
	} else {
		msgbox QuestGather: MoveMethod undefined!
	}
	;set sprinkler
	sleep, 1000
	nm_setSprinkler(1)
	;rotate
	num:=FieldDefault[QuestGatherField]["camera"][2]
	if(FieldDefault[QuestGatherField]["camera"][1]="left") {
		loop %num% {
			send {%RotLeft%}
		}
	} else if(FieldDefault[QuestGatherField]["camera"][1]="right") {
		loop %num% {
			send {%RotRight%}
		}
	}
	;send {1}
	;gather loop
	bypass:=0
	nm_setStatus("Gathering")
	gatherStart:=nowUnix() ; used to track gathering time for this cycle
	;GatherStartTime:=nowUnix() ;used to track total and session time metrics
	qpattern:=FieldDefault[QuestGatherField]["pattern"][1]
	qsize:=FieldDefault[QuestGatherField]["pattern"][2]
	qreps:=FieldDefault[QuestGatherField]["pattern"][3]
	while((BackpackPercentFiltered<100) && ((nowUnix()-gatherStart)<(300))){
		nm_gather(qpattern, qsize, qreps)
		nm_fieldDriftCompensation()
		if(quest="polar") {
			nm_PolarQuestProg()
			;interrupt if
			if (thisfield!=QuestGatherField || QuestGatherField="none" || PolarQuestComplete || YouDied){ ;change fields or this field is complete
				;msgbox QuestGatherField=%QuestGatherField%`,PolarQuestComplete=%PolarQuestComplete%
				if(DisconnectCheck())
					nm_setStatus("Interupted", "Disconnect")
				else if (youDied)
					nm_setStatus("Interupted", "You Died!")
				break
			}
		} else if(quest="black") {
			nm_BlackQuestProg()
			;interrupt if
			if (thisfield!=QuestGatherField || QuestGatherField="none" || BlackQuestComplete || YouDied){ ;change fields or this field is complete
				if(DisconnectCheck())
					nm_setStatus("Interupted", "Disconnect")
				else if (youDied)
					nm_setStatus("Interupted", "You Died!")
				break
			}
		}
		;active honey
		if(not nm_activeHoney()){
			nm_setStatus("Interupted", "Inactive Honey")
			break
		}
		
		;temp1:=(nowUnix()-gatherStart)
		;msgbox BackpackPercentFiltered=%BackpackPercentFiltered%`n(nowUnix()-gatherStart)=%temp1%
	}
	;rotate back
	num:=FieldDefault[QuestGatherField]["camera"][2]
	if(FieldDefault[QuestGatherField]["camera"][1]="right") {
		loop %num% {
			send {%RotLeft%}
		}
	} else if(FieldDefault[QuestGatherField]["camera"][1]="left") {
		loop %num% {
			send {%RotRight%}
		}
	}
}
nm_gotoQuestgiver(giver){
	global FwdKey
	global LeftKey
	global BackKey
	global RightKey
	global RotLeft
	global RotRight
	global KeyDelay
	global MoveSpeedFactor
	global MoveMethod
	global QuestGatherField, LastBlackQuest
	success:=0
	loop 2 {
		;reset
		nm_Reset()
		objective:=("Questgiver: " . giver)
		nm_gotoRamp()
		if(giver="polar"){
			;goto polar bear
			if(MoveMethod="Walk"){
				nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
				loop 4 {
					send, {%RotRight%}
				}
				nm_Move(7000*MoveSpeedFactor, FwdKey)
				nm_Move(2000*MoveSpeedFactor, LeftKey)
				nm_Move(2000*MoveSpeedFactor, BackKey)
				nm_Move(13000*MoveSpeedFactor, LeftKey)
				nm_Move(11000*MoveSpeedFactor, FwdKey)
				nm_Move(750*MoveSpeedFactor, LeftKey)
				nm_Move(8000*MoveSpeedFactor, FwdKey)
				nm_Move(14000*MoveSpeedFactor, RightKey)
				nm_Move(14000*MoveSpeedFactor, BackKey)
				nm_Move(2000*MoveSpeedFactor, LeftKey)
				nm_Move(500*MoveSpeedFactor, FwdKey, RightKey)
			} else if (MoveMethod="Cannon"){
				nm_gotoCannon()
				send, {e}
				sleep, 50
				send {%RightKey% down}
				send {%BackKey% down}
				sleep, 1200 
				send {space}
				send {space}
				sleep, 1250
				send {space}
				send {%RightKey% up}
				send {%BackKey% up}
				loop 4 {
					send {%RotLeft%}
				}
				sleep, 2500 ;4250
				nm_Move(1500*MoveSpeedFactor, BackKey, LeftKey)
				nm_Move(500*MoveSpeedFactor, FwdKey, RightKey)
			} else {
				msgbox GotoQuestGiver: MoveMethod undefined!
			}
		} else if(giver="honey"){
			;goto honey bee
			if(MoveMethod="Walk"){
				nm_Move(15000*MoveSpeedFactor, BackKey, LeftKey)
				loop 4 {
					send, {%RotRight%}
				}
				nm_Move(7000*MoveSpeedFactor, FwdKey)
				nm_Move(2000*MoveSpeedFactor, LeftKey)
				nm_Move(2000*MoveSpeedFactor, BackKey)
				nm_Move(13000*MoveSpeedFactor, LeftKey)
				nm_Move(11000*MoveSpeedFactor, FwdKey)
				nm_Move(500*MoveSpeedFactor, BackKey, LeftKey)
				nm_Move(8000*MoveSpeedFactor, LeftKey)
				send, {%LeftKey% down}
				sleep, 200
				send, {space down}
				sleep, 200
				send, {space up}
				sleep, 800
				send, {%FwdKey% down}
				sleep, 200
				send, {space down}
				sleep, 200
				send, {space up}
				sleep, 5000*MoveSpeedFactor
				send, {%LeftKey% up}
				sleep, 200
				send, {space down}
				sleep, 200
				send, {space up}
				sleep, 800
				send, {%FwdKey% up}
				nm_Move(5000*MoveSpeedFactor, FwdKey)
				nm_Move(500*MoveSpeedFactor, BackKey)
				repeat:=1
				loop 10 {
					searchRet := nm_imgSearch("e_button.png",30,"high")
					If (searchRet[1] = 0) {
						sleep, 200
						searchRet := nm_imgSearch("e_button.png",30,"high")
						If (searchRet[1] = 0) {
							repeat:=0
							break
						}
					}
					nm_Move(400*MoveSpeedFactor, BackKey, RightKey)
				}
			} else if (MoveMethod="Cannon"){
				nm_gotoCannon()
				send {e}
				sleep, 50
				send {%RightKey% down}
				send {%BackKey% down}
				sleep, 1200 
				send {space}
				send {space}
				sleep, 4000
				send {%BackKey% up}
				sleep 4000
				send {%RightKey% up}
				send {space}
				loop 2 {
					send, {%RotRight%}
				}
				sleep, 2000
				;walk to honey bee platform
				send, {%FwdKey% down}
				sleep, 200
				send, {space down}
				sleep, 200
				send, {space up}
				sleep, 200
				send, {%FwdKey% up}
				repeat:=1
				loop 10 {
					searchRet := nm_imgSearch("e_button.png",30,"high")
					If (searchRet[1] = 0) {
						sleep, 200
						searchRet := nm_imgSearch("e_button.png",30,"high")
						If (searchRet[1] = 0) {
							repeat:=0
							break
						}
					}
					nm_Move(400*MoveSpeedFactor, FwdKey)
				}
			} else {
				msgbox GotoQuestGiver: MoveMethod undefined!
			}
		}
		;goto black bear
		else if(giver="black"){
			nm_Move(3000*MoveSpeedFactor, BackKey)
			nm_Move(2500*MoveSpeedFactor, RightKey)
			loop 10 {
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					sleep, 200
					searchRet := nm_imgSearch("e_button.png",30,"high")
					If (searchRet[1] = 0) {
						repeat:=0
						break
					}
				}
				nm_Move(400*MoveSpeedFactor, RightKey)
			}
		}
		;goto bucko bee
		else if(giver="bucko"){
			if(MoveMethod="walk"){
				nm_walkTo("blue flower")
			} else if(MoveMethod="cannon"){
				nm_gotoCannon()
				send, {e}
				sleep, 50
				send {%LeftKey% down}
				sleep, 700
				send {space}
				send {space}
				sleep, 4450
				send {%LeftKey% up}
				send {space}
				sleep, 1000
				loop 2 {
					send, {%RotLeft%}
				}
			}
			nm_Move(10000*MoveSpeedFactor, FwdKey)
			send {%FwdKey% down}
			sleep, 200
			send, {space down}
			sleep 200
			send, {space up}
			sleep, 500
			send {%FwdKey% up}
			nm_Move(4000*MoveSpeedFactor, RightKey)
			nm_Move(6000*MoveSpeedFactor, BackKey)
			nm_Move(750*MoveSpeedFactor, FwdKey, LeftKey)
			nm_Move(1600*MoveSpeedFactor, LeftKey)
			nm_Move(2000*MoveSpeedFactor, FwdKey)
			send, {%FwdKey% down}
			sleep, 200
			send, {space down}
			sleep, 200
			send, {space up}
			send, {%FwdKey% up}
			sleep 800
			loop 5 {
				searchRet := nm_imgSearch("e_button.png",30,"high")
				If (searchRet[1] = 0) {
					repeat:=0
					break
				}
				nm_Move(200*MoveSpeedFactor, FwdKey)
			}
		}
		;goto riley bee
		else if(giver="riley"){
			if(MoveMethod="walk"){
				nm_walkTo("rose")
				nm_Move(2000*MoveSpeedFactor, BackKey)
				nm_Move(3500*MoveSpeedFactor, BackKey, RightKey)
				nm_Move(6800*MoveSpeedFactor, LeftKey)
				nm_Move(5300*MoveSpeedFactor, FwdKey)
				nm_Move(5100*MoveSpeedFactor, LeftKey)
				nm_Move(1475*MoveSpeedFactor, BackKey)
				nm_Move(4500*MoveSpeedFactor, RightKey)
				nm_Move(1000*MoveSpeedFactor, FwdKey)
				send, {%FwdKey% down}
				sleep, 200
				send, {space down}
				sleep, 200
				send, {space up}
				send, {%FwdKey% up}
				sleep 800
				loop 5 {
					searchRet := nm_imgSearch("e_button.png",50,"high")
					If (searchRet[1] = 0) {
						repeat:=0
						break
					}
					nm_Move(200*MoveSpeedFactor, FwdKey)
				}
			} else if(MoveMethod="cannon"){
				nm_gotoCannon()
				send, {e}
				sleep, 50
				send {%FwdKey% down}
				send {%RightKey% down}
				sleep, 600
				send {space}
				send {space}
				sleep, 1750
				send {%FwdKey% up}
				sleep, 2250
				send {%RightKey% up}
				send {space}
				loop 2 {
					send, {%RotRight%}
				}
				sleep, 1500
				searchRet := nm_imgSearch("e_button.png",50,"high")
				If (searchRet[1] = 0) {
					repeat:=0
				}
			}
		}
		;turn-in / get next quest
		loop 2 {
			sleep, 500
			searchRet := nm_imgSearch("e_button.png",30,"high")
			If (searchRet[1] = 0) {
				success:=1
				send {e}
				sleep, 2000
				;check to make sure you are not at a planter on accident
				imgPos := nm_imgSearch("no.png",30)
				If (imgPos[1] = 0){
					MouseMove, (imgPos[2]), (imgPos[3])
					Click
					MouseMove, 350, (Roblox[3]+70)
				}
				dialog := nm_imgSearch("dialog.png",30,"center")
				If (dialog[1] = 0) {
					while(dialog[1] = 0){
						MouseMove, dialog[2],dialog[3]
						click
						MouseMove, -30, 0, 0, R
						dialog := nm_imgSearch("dialog.png",30,"center")
						sleep, 100
					}
					MouseMove, 350, (Roblox[3]+70)
				}
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
			IniWrite, %LastBugrunLadybugs%, nm_config.ini, Collect, LastBugrunLadybugs
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;rhino beetles
	else if(InStr(objective,"blue flower") || InStr(objective,"bamboo")) {
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, nm_config.ini, Collect, LastBugrunRhinoBeetles
			if(InStr(objective,"bamboo")) {
				TotalBugKills:=TotalBugKills+2
				SessionBugKills:=SessionBugKills+2
			} else {
				TotalBugKills:=TotalBugKills+1
				SessionBugKills:=SessionBugKills+1
			}
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;spider
	else if(InStr(objective,"spider")) {
		searchRet := nm_imgSearch("spider.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunSpider:=nowUnix()
			IniWrite, %LastBugrunSpider%, nm_config.ini, Collect, LastBugrunSpider
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;mantis/rhino beetle
	else if(InStr(objective,"pineapple")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite, %LastBugrunMantis%, nm_config.ini, Collect, LastBugrunMantis
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
		searchRet := nm_imgSearch("rhino.png",30,"lowright")
		If (searchRet[1] = 0) {
			if(!BugrunMantisCheck)
				BugDeathCheckLockout:=nowUnix()
			LastBugrunRhinoBeetles:=nowUnix()
			IniWrite, %LastBugrunRhinoBeetles%, nm_config.ini, Collect, LastBugrunRhinoBeetles
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;mantis/werewolf
	else if(InStr(objective,"pine tree")) {
		searchRet := nm_imgSearch("mantis.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunMantis:=nowUnix()
			IniWrite, %LastBugrunMantis%, nm_config.ini, Collect, LastBugrunMantis
			TotalBugKills:=TotalBugKills+2
			SessionBugKills:=SessionBugKills+2
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite, %LastBugrunWerewolf%, nm_config.ini, Collect, LastBugrunWerewolf
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;werewolf
	else if(InStr(objective,"pumpkin") || InStr(objective,"cactus")) {
		searchRet := nm_imgSearch("werewolf.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunWerewolf:=nowUnix()
			IniWrite, %LastBugrunWerewolf%, nm_config.ini, Collect, LastBugrunWerewolf
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
	;scorpions
	else if(InStr(objective,"rose")) {
		searchRet := nm_imgSearch("scorpion.png",30,"lowright")
		If (searchRet[1] = 0) {
			BugDeathCheckLockout:=nowUnix()
			LastBugrunScorpions:=nowUnix()
			IniWrite, %LastBugrunScorpions%, nm_config.ini, Collect, LastBugrunScorpions
			TotalBugKills:=TotalBugKills+1
			SessionBugKills:=SessionBugKills+1
			IniWrite, %TotalBugKills%, nm_config.ini, Status, TotalBugKills
			IniWrite, %SessionBugKills%, nm_config.ini, Status, SessionBugKills
		}
	}
}
nm_resetConfig(){
	if(fileexist("nm_config.ini")) {
		FileDelete nm_config.ini
	}
		FileAppend,
    (
[Gui]
dayOrNight=Day

[Settings]
GuiTheme=MacLion3
GuiTransparency=0
AlwaysOnTop=0
WindowedScreen=0
MoveSpeed=28
MoveSpeedFactor=0.64
MoveMethod=Cannon
SprinklerType=Supreme
ConvertBalloon=Always
ConvertMins=30
LastConvertBalloon=1
DisableToolUse=0
HiveSlot=6
HiveVariation=20
HiveBees=25
PrivServer=0
ReloadRobloxSecs=60
GuiX=0
GuiY=0
GuiMode=0

[Status]
StatusLogReverse=0
TotalRuntime=0
SessionRuntime=0
TotalGatherTime=0
SessionGatherTime=0
TotalConvertTime=0
SessionConvertTime=0
TotalViciousKills=0
SessionViciousKills=0
TotalBossKills=0
SessionBossKills=0
TotalBugKills=0
SessionBugKills=0
TotalPlantersCollected=0
SessionPlantersCollected=0
TotalQuestsComplete=0
SessionQuestsComplete=0
TotalDisconnects=0
SessionDisconnects=0
Webhook=
WebhookCheck=0
ssCooldown=0

[Keys]
KeyboardLayout=qwerty
FwdKey=w
BackKey=s
LeftKey=a
RightKey=d
RotLeft=,
RotRight=.
ZoomIn=i
ZoomOut=o
KeyDelay=20

[Gather]
FieldName1=Sunflower
FieldName2=None
FieldName3=None
FieldPattern1=Squares
FieldPattern2=Squares
FieldPattern3=Squares
FieldPatternSize1=M
FieldPatternSize2=M
FieldPatternSize3=M
FieldPatternReps1=3
FieldPatternReps2=3
FieldPatternReps3=3
FieldPatternShift1=0
FieldPatternShift2=0
FieldPatternShift3=0
FieldUntilMins1=20
FieldUntilMins2=20
FieldUntilMins3=20
FieldUntilPack1=100
FieldUntilPack2=100
FieldUntilPack3=100
FieldReturnType1=Walk
FieldReturnType2=Walk
FieldReturnType3=Walk
FieldSprinklerLoc1=Center
FieldSprinklerLoc2=Center
FieldSprinklerLoc3=Center
FieldSprinklerDist1=10
FieldSprinklerDist2=10
FieldSprinklerDist3=10
FieldRotateDirection1=None
FieldRotateDirection2=None
FieldRotateDirection3=None
FieldRotateTimes1=1
FieldRotateTimes2=1
FieldRotateTimes3=1
FieldDriftCheck1=1
FieldDriftCheck2=1
FieldDriftCheck3=1
CurrentFieldNum=1

[Collect]
ClockCheck=0
LastClock=1
MondoBuffCheck=0
MondoAction=Buff
LastMondoBuff=1
AntPassCheck=0
AntPassAction=Pass
LastAntPass=1
HoneyDisCheck=0
LastHoneyDis=1
TreatDisCheck=0
LastTreatDis=1
BlueberryDisCheck=0
LastBlueberryDis=1
StrawberryDisCheck=0
LastStrawberryDis=1
CoconutDisCheck=0
LastCoconutDis=1
RoyalJellyDisCheck=0
LastRoyalJellyDis=1
GlueDisCheck=0
LastGlueDis=1
BlueBoostCheck=1
LastBlueBoost=1
RedBoostCheck=0
LastRedBoost=1
MountainBoostCheck=0
LastMountainBoost=1
StockingsCheck=0
LastStockings=1
WreathCheck=0
LastWreath=1
FeastCheck=0
LastFeast=1
CandlesCheck=0
LastCandles=1
SamovarCheck=0
LastSamovar=1
LidArtCheck=0
LastLidArt=1
BugRunCheck=0
GiftedViciousCheck=0
BugrunInterruptCheck=0
BugrunLadybugsCheck=0
BugrunLadybugsLoot=0
LastBugrunLadybugs=1
BugrunRhinoBeetlesCheck=0
BugrunRhinoBeetlesLoot=0
LastBugrunRhinoBeetles=1
BugrunSpiderCheck=0
BugrunSpiderLoot=0
LastBugrunSpider=1
BugrunMantisCheck=0
BugrunMantisLoot=0
LastBugrunMantis=1
BugrunScorpionsCheck=0
BugrunScorpionsLoot=0
LastBugrunScorpions=1
BugrunWerewolfCheck=0
BugrunWerewolfLoot=0
LastBugrunWerewolf=1
StingerCheck=0
TunnelBearCheck=0
TunnelBearBabyCheck=0
LastTunnelBear=1
KingBeetleCheck=0
KingBeetleBabyCheck=0
LastKingBeetle=1
StingerPepperCheck=1
StingerMountainTopCheck=1
StingerRoseCheck=1
StingerCactusCheck=1
StingerSpiderCheck=1
StingerCloverCheck=1
NightLastDetected=1
VBLastKilled=1

[Boost]
FieldBoostStacks=0
FieldBooster3=None
FieldBooster2=None
FieldBooster1=None
BoostChaserCheck=0
HotkeyWhile2=Never
HotkeyWhile3=Never
HotkeyWhile4=Never
HotkeyWhile5=Never
HotkeyWhile6=Never
HotkeyWhile7=Never
FieldBoosterMins=15
HotkeyTime2=30
HotkeyTime3=30
HotkeyTime4=30
HotkeyTime5=30
HotkeyTime6=30
HotkeyTime7=30
HotkeyTimeUnits2=Mins
HotkeyTimeUnits3=Mins
HotkeyTimeUnits4=Mins
HotkeyTimeUnits5=Mins
HotkeyTimeUnits6=Mins
HotkeyTimeUnits7=Mins
LastHotkey2=1
LastHotkey3=1
LastHotkey4=1
LastHotkey5=1
LastHotkey6=1
LastHotkey7=1
LastWhirligig=1
LastEnzymes=1
LastBlueBoost=1
LastRedBoost=1
LastMountainBoost=1
AutoFieldBoostActive=0
AutoFieldBoostRefresh=12.5
AFBDiceEnable=0
AFBGlitterEnable=0
AFBFieldEnable=0
AFBDiceHotbar=None
AFBGlitterHotbar=None
AFBDiceLimitEnable=1
AFBGlitterLimitEnable=1
AFBHoursLimitEnable=0
AFBDiceLimit=1
AFBGlitterLimit=1
AFBHoursLimit=.01
FieldLastBoosted=1
FieldLastBoostedBy=None
FieldNextBoostedBy=None
FieldBoostStacks=0
AFBdiceUsed=0
AFBglitterUsed=0
LastMicroConverter=1

[Quests]
QuestGatherMins=5
PolarQuestCheck=0
PolarQuestGatherInterruptCheck=1
PolarQuestName=None
PolarQuestProgress=Unknown
HoneyQuestCheck=0
BlackQuestCheck=0
BlackQuestName=None
BlackQuestProgress=Unknown
LastBlackQuest=1
BuckoQuestCheck=0
BuckoQuestGatherInterruptCheck=1
BuckoQuestName=None
BuckoQuestProgress=Unknown
RileyQuestCheck=0
RileyQuestGatherInterruptCheck=1
RileyQuestName=None
RileyQuestProgress=Unknown

[Planters]
PlanterName1=None
PlanterName2=None
PlanterName3=None
PlanterField1=None
PlanterField2=None
PlanterField3=None
PlanterPlacedTime1=1
PlanterPlacedTime2=1
PlanterPlacedTime3=1
PlanterGrowTime1=1
PlanterGrowTime2=1
PlanterGrowTime3=1
PlanterNectar1=None
PlanterNectar2=None
PlanterNectar3=None
PlanterBonus1=0
PlanterBonus2=0
PlanterBonus3=0
PlanterLastNum1=1
PlanterLastNum2=1
PlanterLastNum3=1
PlanterSelectedName1=Plastic
PlanterSelectedName2=None
PlanterSelectedName3=Automatic
PlanterPlacedBy1=Inventory
PlanterPlacedBy2=Hotkey
PlanterPlacedBy3=Inventory
PlanterHotkeySlot1=2
PlanterHotkeySlot2=3
PlanterHotkeySlot3=4
Planter1Field1=Dandelion
Planter1Field2=None
Planter1Field3=None
Planter1Field4=None
Planter2Field1=BlueFlower
Planter2Field2=None
Planter2Field3=None
Planter2Field4=None
Planter3Field1=None
Planter3Field2=None
Planter3Field3=None
Planter3Field4=None
Planter1Until1=2
Planter1Until2=0.5
Planter1Until3=Full
Planter1Until4=2
Planter2Until1=2
Planter2Until2=2
Planter2Until3=2
Planter2Until4=2
Planter3Until1=2
Planter3Until2=2
Planter3Until3=2
Planter3Until4=2
LastComfortingField=None
LastRefreshingField=None
LastSatisfyingField=None
LastMotivatingField=None
LastInvigoratingField=None
), nm_config.ini
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; NATRO ENHANCEMENT FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ba_enableSwitch(){
	;global resolutionKey
	GuiControlGet, EnablePlantersPlus
	GuiControlGet, MaxAllowedPlanters
	/*
	IniRead, resolution, config.ini, gui, resolution
	if(EnablePlantersPlus && resolution!=720 && resolution!=1080) {
		msgbox Graphics Resolution: %resolution% is not supported by Planters+`n`nSupported resolutions are:`n720`n1080
		Guicontrol,, EnablePlantersPlus, 0
		IniWrite, 0, ba_config.ini, gui, EnablePlantersPlus
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
    IniWrite, 1, ba_config.ini, other, n1Switch
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
    IniWrite, 1, ba_config.ini, other, n2Switch
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
    IniWrite, 1, ba_config.ini, other, n3Switch
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
    IniWrite, 1, ba_config.ini, other, n4Switch
    GuiControlGet, n4priority
	GuiControl,chooseString,n5priority,None
	GuiControl,chooseString,n5minPercent,10
    GuiControl,chooseString,nectarPreset,None
	;nectarS_()
	ba_nectarstring()
    ba_saveConfig_()
}
ba_N5unswitch_(){
    IniWrite, 1, ba_config.ini, other, n5Switch
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
		GuiControl, Hide, HarvestIntervalNum
		GuiControl, Hide, FullText
		GuiControl, Show, AutoText
		GuiControl,, HarvestFullGrown, 0
	} else {
		GuiControl, Show, HarvestIntervalNum
	}
	ba_saveConfig_()
}
ba_HarvestFullGrownSwitch_(){
	GuiControlGet, HarvestFullGrown
	if(HarvestFullGrown) {
		GuiControl, Hide, HarvestIntervalNum
		GuiControl, Hide, AutoText
		GuiControl, Show, FullText
		GuiControl,, AutomaticHarvestInterval, 0
	} else {
		GuiControl, Show, HarvestIntervalNum
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
		GuiControl,chooseString,n2minPercent,90 ;MOT
		GuiControl,chooseString,n3minPercent,90 ;SAT
		GuiControl,chooseString,n4minPercent,90 ;REF
		GuiControl,chooseString,n5minPercent,10 ;INV
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
		GuiControl,chooseString,n2minPercent,90 ;REF
		GuiControl,chooseString,n3minPercent,90 ;MOT
		GuiControl,chooseString,n4minPercent,90 ;SAT
		GuiControl,chooseString,n5minPercent,10 ;COM
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
		GuiControl,chooseString,n2minPercent,90 ;MOT
		GuiControl,chooseString,n3minPercent,90 ;REF
		GuiControl,chooseString,n4minPercent,90 ;COM
		GuiControl,chooseString,n5minPercent,10 ;INV
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
	global n1string
	global n2string
	global n3string
	global n4string
	global n5string
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
	GuiControlGet, HarvestIntervalNum
	GuiControlGet, AutomaticHarvestInterval
	GuiControlGet, HarvestFullGrown
	GuiControlGet, GotoPlanterField
	;GuiControlGet, HiveDistance
	;GuiControlGet, MoveSpeedFactor
	GuiControlGet, PlasticPlanterCheck
	GuiControlGet, CandyPlanterCheck
	GuiControlGet, BlueClayPlanterCheck
	GuiControlGet, RedClayPlanterCheck
	GuiControlGet, TackyPlanterCheck
	GuiControlGet, PesticidePlanterCheck
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
	IniWrite, %nPreset%, ba_config.ini, gui, nPreset
    IniWrite, %n1priority%, ba_config.ini, gui, n1priority
	IniWrite, %n2priority%, ba_config.ini, gui, n2priority
	IniWrite, %n3priority%, ba_config.ini, gui, n3priority
	IniWrite, %n4priority%, ba_config.ini, gui, n4priority
	IniWrite, %n5priority%, ba_config.ini, gui, n5priority
	IniWrite, %n1string%, ba_config.ini, gui, n1string
	IniWrite, %n2string%, ba_config.ini, gui, n2string
	IniWrite, %n3string%, ba_config.ini, gui, n3string
	IniWrite, %n4string%, ba_config.ini, gui, n4string
	IniWrite, %n5string%, ba_config.ini, gui, n5string
	IniWrite, %n1minPercent%, ba_config.ini, gui, n1minPercent
	IniWrite, %n2minPercent%, ba_config.ini, gui, n2minPercent
	IniWrite, %n3minPercent%, ba_config.ini, gui, n3minPercent
	IniWrite, %n4minPercent%, ba_config.ini, gui, n4minPercent
	IniWrite, %n5minPercent%, ba_config.ini, gui, n5minPercent
	IniWrite, %PlasticPlanterCheck%, ba_config.ini, gui, PlasticPlanterCheck
	IniWrite, %CandyPlanterCheck%, ba_config.ini, gui, CandyPlanterCheck
	IniWrite, %BlueClayPlanterCheck%, ba_config.ini, gui, BlueClayPlanterCheck
	IniWrite, %RedClayPlanterCheck%, ba_config.ini, gui, RedClayPlanterCheck
	IniWrite, %TackyPlanterCheck%, ba_config.ini, gui, TackyPlanterCheck
	IniWrite, %PesticidePlanterCheck%, ba_config.ini, gui, PesticidePlanterCheck
	IniWrite, %PetalPlanterCheck%, ba_config.ini, gui, PetalPlanterCheck
	IniWrite, %PaperPlanterCheck%, ba_config.ini, gui, PaperPlanterCheck
	IniWrite, %TicketPlanterCheck%, ba_config.ini, gui, TicketPlanterCheck
	IniWrite, %PlanterOfPlentyCheck%, ba_config.ini, gui, PlanterOfPlentyCheck
	IniWrite, %BambooFieldCheck%, ba_config.ini, gui, BambooFieldCheck
	IniWrite, %BlueFlowerFieldCheck%, ba_config.ini, gui, BlueFlowerFieldCheck
	IniWrite, %CactusFieldCheck%, ba_config.ini, gui, CactusFieldCheck
	IniWrite, %CloverFieldCheck%, ba_config.ini, gui, CloverFieldCheck
	IniWrite, %CoconutFieldCheck%, ba_config.ini, gui, CoconutFieldCheck
	IniWrite, %DandelionFieldCheck%, ba_config.ini, gui, DandelionFieldCheck
	IniWrite, %MountainTopFieldCheck%, ba_config.ini, gui, MountainTopFieldCheck
	IniWrite, %MushroomFieldCheck%, ba_config.ini, gui, MushroomFieldCheck
	IniWrite, %PepperFieldCheck%, ba_config.ini, gui, PepperFieldCheck
	IniWrite, %PineTreeFieldCheck%, ba_config.ini, gui, PineTreeFieldCheck
	IniWrite, %PineappleFieldCheck%, ba_config.ini, gui, PineappleFieldCheck
	IniWrite, %PumpkinFieldCheck%, ba_config.ini, gui, PumpkinFieldCheck
	IniWrite, %RoseFieldCheck%, ba_config.ini, gui, RoseFieldCheck
	IniWrite, %SpiderFieldCheck%, ba_config.ini, gui, SpiderFieldCheck
	IniWrite, %StrawberryFieldCheck%, ba_config.ini, gui, StrawberryFieldCheck
	IniWrite, %StumpFieldCheck%, ba_config.ini, gui, StumpFieldCheck
	IniWrite, %SunflowerFieldCheck%, ba_config.ini, gui, SunflowerFieldCheck
	IniWrite, %EnablePlantersPlus%, ba_config.ini, gui, EnablePlantersPlus
	IniWrite, %MaxAllowedPlanters%, ba_config.ini, gui, MaxAllowedPlanters
	IniWrite, %HarvestIntervalNum%, ba_config.ini, gui, HarvestInterval
	IniWrite, %AutomaticHarvestInterval%, ba_config.ini, gui, AutomaticHarvestInterval
	IniWrite, %HarvestFullGrown%, ba_config.ini, gui, HarvestFullGrown
	IniWrite, %GotoPlanterField%, ba_config.ini, gui, GotoPlanterField
	;IniWrite, %HiveDistance%, ba_config.ini, gui, HiveDistance
	;IniWrite, %MoveSpeedFactor%, ba_config.ini, gui, MoveSpeedFactor
	;IniWrite, %StingerCheck%, ba_config.ini, gui, StingerCheck
	IniWrite, %FDCMoveDirFB%, ba_config.ini, gui, FDCMoveDirFB
	IniWrite, %FDCMoveDirLR%, ba_config.ini, gui, FDCMoveDirLR
	IniWrite, %FDCMoveDurFB%, ba_config.ini, gui, FDCMoveDurFB
	IniWrite, %FDCMoveDurLR%, ba_config.ini, gui, FDCMoveDurLR
	IniWrite, %AltPineStart%, ba_config.ini, gui, AltPineStart
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
		guicontrol,, n2priority, |
		guicontrol,, n2priority, %n2priority%%n2string%
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
		guicontrol,, n3priority, |
		guicontrol,, n3priority, %n3priority%%n3string%
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
		guicontrol,, n4priority, |
		guicontrol,, n4priority, %n4priority%%n4string%
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
		guicontrol,, n5priority, |
		guicontrol,, n5priority, %n5priority%%n5string%
	} else {
		guicontrol, hide, n5priority
		guicontrol, hide, n5minPercent
		n5string:="||None"
	}
	return
}
ba_harvestInterval(){
	global HarvestInterval
	GuiControlGet, HarvestIntervalNum
	if HarvestIntervalNum is number
	{
		if HarvestIntervalNum>0 
		{
		HarvestInterval:=HarvestIntervalNum
		ba_saveConfig_()
		} else {
		GuiControl, Text, HarvestIntervalNum , %HarvestInterval%
	}
	} else {
		GuiControl, Text, HarvestIntervalNum , %HarvestInterval%
	}
}
ba_planter()
{
	global planternames
	global nectarnames
	global CurrentField ;zez parameter
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
	GuiControlGet, MaxAllowedPlanters
	GuiControlGet, GotoPlanterField
	global LostPlanters
	global Roblox
	;IniRead, Roblox, ba_config.ini, gui, Roblox
	GuiControlGet, EnablePlantersPlus
	GuiControlGet, HarvestInterval
	GuiControlGet, HarvestFullGrown
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
	GuiControlGet, PlasticPlanterCheck
	GuiControlGet, CandyPlanterCheck
	GuiControlGet, BlueClayPlanterCheck
	GuiControlGet, RedClayPlanterCheck
	GuiControlGet, TackyPlanterCheck
	GuiControlGet, PesticidePlanterCheck
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
	loop, 3 {
	IniRead, PlanterName%A_Index%, ba_config.ini, Planters, PlanterName%A_Index%
	IniRead, PlanterField%A_Index%, ba_config.ini, Planters, PlanterField%A_Index%
	IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
	IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
	IniRead, PlanterEstPercent%A_Index%, ba_config.ini, Planters, PlanterEstPercent%A_Index%
	}
	if (not EnablePlantersPlus){
		return
	}
	else { ;disable Zez Planters
		;GuiControl,choosestring,p1choice1,None
		;GuiControl,choosestring,p1choice2,None
		;GuiControl,choosestring,p1choice3,None
		;GuiControl,choosestring,p2choice1,None
		;GuiControl,choosestring,p2choice2,None
		;GuiControl,choosestring,p2choice3,None
		;GuiControl,choosestring,p3choice1,None
		;GuiControl,choosestring,p3choice2,None
		;GuiControl,choosestring,p3choice3,None
		;P1unswitch_()
		;P2unswitch_()
		;P3unswitch_()
	}
	;determine menu offset
	;ImageSearch, FoundX, FoundY, 0, 0, 1920, 1080, *100 roblox.png
	;Roblox:=ba_wrappedSearch("roblox.png",100,"high")
	Roblox:=nm_imgSearch("roblox2.png",10,"buff")
	;(failsafe) default to hard-coded values if image not found
	if(Roblox[1]!=0)
		Roblox:=[0, 21, 9]

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
		if (currentFieldNectar=val){
			break
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
				if(currentNectar=currentFieldNectar && not HarvestFullGrown) {
					loop, 3 { ;3 max positions
						if(currentField!=PlanterField%A_Index% && currentFieldNectar=PlanterNectar%A_Index%) {
							temp1:=PlanterField%A_Index%
							PlanterHarvestTime%A_Index% := nowUnix()-1
							PlanterHarvestTimeN:=PlanterHarvestTime%A_Index%
							IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
							IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
						}
					}
				}
				;recover planters that will overfill nectars
				if (not HarvestFullGrown && ((nectarPercent>99)||(nectarPercent>90 && (nectarPercent+estimatedNectarPercent)>110)||(nectarPercent+estimatedNectarPercent)>120)){
					loop, 3 { ;3 max positions
						planterNectar:=PlanterNectar%A_Index%
						if (PlanterNectar=currentNectar) {
							PlanterHarvestTime%A_Index% := nowUnix()-1
							PlanterHarvestTimeN:=PlanterHarvestTime%A_Index%
							IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
							IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
						}
					}
				}
			} else {
				break
			}
		}
		;recover placed planters here
		loop, 3 {
			if(PlanterHarvestTime%A_Index% < nowUnix()){
				ba_harvestPlanter(A_Index)
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
			IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
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
				if(currentNectar=currentFieldNectar && not GotoPlanterField){ ;always place planter in field you are collecting from
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
								;msgbox already a planter here trying next field
							} else if(success=3){ ;3 planters have been placed already
								return
							} else if(success=4){ ;not in a field
								;do nothing and try again
							} else if(success=0){ ;cannot find planter
								nextPlanter:=ba_getNextPlanter(nextField)
								if (nextPlanter[1]="none")
									break
							;msgbox cannot find planter, trying another one
								success:=ba_placeInventoryPlanter(nextPlanter[1], planterNum)
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
			IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
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
			if(currentNectar=currentFieldNectar && not GotoPlanterField){
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
							;msgbox already a planter here trying next field
						} else if(success=3){ ;3 planters have been placed already
							return
						} else if(success=4){ ;not in a field
								;do nothing and try again
						} else if(success=0){ ;cannot find planter
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
								break
						;msgbox cannot find planter, trying another one
							success:=ba_placeInventoryPlanter(nextPlanter[1], planterNum)
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
									;msgbox already a planter here trying next field
								} else if(success=3){ ;3 planters have been placed already
									return
								} else if(success=4){ ;not in a field
								;do nothing and try again
								} else if(success=0){ ;cannot find planter
									nextPlanter:=ba_getNextPlanter(nextField)
									if (nextPlanter[1]="none")
										break
								;msgbox cannot find planter, trying another one
									success:=ba_placeInventoryPlanter(nextPlanter[1], planterNum)
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
			IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
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
				if(currentNectar=currentFieldNectar && not GotoPlanterField){
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
							;msgbox already a planter here trying next field
						} else if(success=3){ ;3 planters have been placed already
							return
						} else if(success=4){ ;not in a field
								;do nothing and try again
						} else if(success=0){ ;cannot find planter
							nextPlanter:=ba_getNextPlanter(nextField)
							if (nextPlanter[1]="none")
								break
						;msgbox cannot find planter, trying another one
							success:=ba_placeInventoryPlanter(nextPlanter[1], planterNum)
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
			coordmode, pixel, Relative
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
	;global LastComfortingField
	;global LastRefreshingField
	;global LastSatisfyingField
	;global LastMotivatingField
	;global LastInvigoratingField
	guicontrolget, BambooFieldCheck
	guicontrolget, BlueFlowerFieldCheck
	guicontrolget, CactusFieldCheck
	guicontrolget, CloverFieldCheck
	guicontrolget, CoconutFieldCheck
	guicontrolget, DandelionFieldCheck
	guicontrolget, MountainTopFieldCheck
	guicontrolget, MushroomFieldCheck
	guicontrolget, PepperFieldCheck
	guicontrolget, PineTreeFieldCheck
	guicontrolget, PineappleFieldCheck
	guicontrolget, PumpkinFieldCheck
	guicontrolget, RoseFieldCheck
	guicontrolget, SpiderFieldCheck
	guicontrolget, StrawberryFieldCheck
	guicontrolget, StumpFieldCheck
	guicontrolget, SunflowerFieldCheck
	loop, 3 {
		IniRead, PlanterField%A_Index%, ba_config.ini, Planters, PlanterField%A_Index%
	}
	IniRead, LastComfortingField, ba_config.ini, Planters, LastComfortingField
	IniRead, LastRefreshingField, ba_config.ini, Planters, LastRefreshingField
	IniRead, LastSatisfyingField, ba_config.ini, Planters, LastSatisfyingField
	IniRead, LastMotivatingField, ba_config.ini, Planters, LastMotivatingField
	IniRead, LastInvigoratingField, ba_config.ini, Planters, LastInvigoratingField
	
	availablefields:=[]
	;determine allowed fields
	for key, value in %currentnectar%Fields {
		tempfieldname := StrReplace(value, " ", "")
		if(%tempfieldname%FieldCheck && value!=PlanterField1 && value!=PlanterField2 && value!=PlanterField3)
			availablefields.Push(value)
	}
	arraylen:=availablefields.Length()
	;no allowed fields exist for this nectar
	if(arraylen=0)
		return [Last%currentnectar%Field, "none"]
	;find index of last nectar field
	for key, value in availablefields {
		checkfield:=availablefields[key]
		;found index of last nectar field in availablefields
		if (Last%currentnectar%Field=checkfield) {
			if(key=arraylen){
				nextfield:=availablefields[1]
			} else {
				nextfield:=availablefields[key+1]
			}
			return [Last%currentnectar%Field, nextfield]
		}
		;last nectar field does not exist in availablefields: default to first in availablefields
		else if (key=arraylen) {
			nextfield:=availablefields[1]
			return [Last%currentnectar%Field, nextfield]
		}
	}
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
	GuiControlGet, PlasticPlanterCheck
	GuiControlGet, CandyPlanterCheck
	GuiControlGet, BlueClayPlanterCheck
	GuiControlGet, RedClayPlanterCheck
	GuiControlGet, TackyPlanterCheck
	GuiControlGet, PesticidePlanterCheck
	GuiControlGet, PetalPlanterCheck
	GuiControlGet, PaperPlanterCheck
	GuiControlGet, TicketPlanterCheck
	GuiControlGet, PlanterOfPlentyCheck
	loop, 3 {
		IniRead, PlanterName%A_Index%, ba_config.ini, Planters, PlanterName%A_Index%
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
		tempPlanter:=%tempfieldname%Planters[A_Index][1]
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
ba_placePlanter(fieldName, planter, planterNum){
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
	;temp1:=planter[1]
	;temp2:=planter[2]
	;temp3:=planter[3]
	;temp4:=planter[4]
	;msgbox Attempting to Place %temp1% in %fieldname%`n NectarBonus=%temp2% GrowBonue=%temp3% Hours=%temp4%
	;goto specified field
	;ba_locateVB()
	nm_Reset()
	;nm_setObjective(planter[1] . "(" . fieldName . ")")
	objective:=(planter[1] . "(" . fieldName . ")")
	nm_gotoRamp()
	nm_gotoCannon()
	nm_cannonTo(fieldName)
	global MyField:=fieldName
	sleep, 1000
	;place next sprinkler
	success:=ba_placeInventoryPlanter(planter[1], planterNum)
	if(success=1){
		;msgbox Placing %temp% in %fieldname%`n Bonus=%temp2% Hours=%temp3%
		;ba_SavePlacedPlanter(fieldName, planter, planterNum, nectar)
		return 1
	} else if(success=2){
		;tempFieldName := StrReplace(fieldName, " ", "")
		;%tempFieldName%FieldCheck:=0
		;GuiControl,, %tempFieldName%FieldCheck , 0
		;ba_saveConfig_()
		return 2
	} else if(success=3){
		return 3
	} else if(success=4){
		return 4
	} else if (success=0){
		return 0
	} else {
		return -1
	}
}
ba_placeInventoryPlanter(planterName, planterNum){
	nm_setStatus("Placing", planterName)
	global MaxAllowedPlanters
	global LostPlanters
	global Roblox
	global WindowedScreen
	planterImg:= (planterName . ".png")
	WinActivate, Roblox
	WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
	imgPos := nm_imgSearch("ItemMenu.png",10, "left")
	If (imgPos[1] != 0){
		MouseMove, 30, (Roblox[3]+120)
		Click
		MouseMove, 350, (Roblox[3]+70)
		sleep, 500
	}
	;check if planter is already visible
	planterPos := nm_imgSearch(planterImg, 50, "left")
	If (planterPos[1] = 0){
		while (planterPos[1] = 0){
			;MouseMove, (planterPos[2]-60), (planterPos[3]+40)
			MouseClickDrag, Left, (planterPos[2]-60), (planterPos[3]+40), (windowWidth/2), (windowHeight/2), 5
			planterPos := nm_imgSearch(planterImg, 50, "left")
			sleep, 200
		}	
		sleep, 1000
		imgPos := nm_imgSearch("yes.png",30)
		If (imgPos[1] = 0){
			;MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
			MouseMove, (imgPos[2]), (imgPos[3])
			Click
			MouseMove, 350, (Roblox[3]+70)
			sleep, 750
			loop, 3{
				imgPos := nm_imgSearch("3Planters.png",30,"lowright")
				If (imgPos[1] = 0){
					MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
					select:=MaxAllowedPlanters
					GuiControl,chooseString,MaxAllowedPlanters,%select%
					ba_saveConfig_()
					MouseMove, 30, (Roblox[2]+100)
					Click
					MouseMove, 350, (Roblox[3]+70)
					return 3
				}
				imgPos := nm_imgSearch("planteralready.png",30,"lowright")
				If (imgPos[1] = 0){
					MouseMove, 30, (Roblox[2]+100)
					Click
					MouseMove, 350, (Roblox[3]+70)
					return 2
				}
				imgPos := nm_imgSearch("standing.png",30,"lowright")
				If (imgPos[1] = 0){
					MouseMove, 30, (Roblox[2]+100)
					Click
					MouseMove, 350, (Roblox[3]+70)
					return 4
				}
				sleep, 500
			}
			MouseMove, 30, (Roblox[2]+100)
			Click
			MouseMove, 350, (Roblox[3]+70)
			return 1
		}	
	} else { ;scroll through menu to find planter
		loop, 2 {
			MouseMove, 30, (Roblox[2]+200), 5
		}
		MouseMove, 30, (Roblox[2]+200), 5
	    Loop, 100 {
			;MouseGetPos, xpos, ypos
			;if(xpos!=30 || ypos!=200)
				;MouseMove, 30, (Roblox[2]+200), 5
			;SendEvent, {Click, WheelDown, 500}
			send, {WheelDown 1}
			Sleep, 50
		}
		MouseMove, 30, (Roblox[2]+200), 5
		Loop, 25 {
			planterPos := nm_imgSearch(planterImg, 100, "left")
			If (planterPos[1] = 0){
				while (planterPos[1] = 0){
					;MouseMove, (planterPos[2]-60), (planterPos[3]+40)
					MouseClickDrag, Left, planterPos[2]-60, planterPos[3]+40, windowWidth/2, windowHeight/2, 5
					planterPos := nm_imgSearch(planterImg, 100, "left")
					sleep, 200
				}
				sleep, 1000
				imgPos := nm_imgSearch("yes.png",30)
				If (imgPos[1] = 0){
					;MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
					MouseMove, (imgPos[2]), (imgPos[3])
					Click
					MouseMove, 350, (Roblox[3]+70)
					sleep, 750
					loop, 3{
						imgPos := nm_imgSearch("3Planters.png",30,"lowright")
						If (imgPos[1] = 0){
							MaxAllowedPlanters:=max(0, MaxAllowedPlanters-1)
							select:=MaxAllowedPlanters
							GuiControl,chooseString,MaxAllowedPlanters,%select%
							ba_saveConfig_()
							MouseMove, 30, (Roblox[2]+100)
							Click
							MouseMove, 350, (Roblox[3]+70)
							return 3
						}
						imgPos := nm_imgSearch("planteralready.png",30,"lowright")
						If (imgPos[1] = 0){
							MouseMove, 30, (Roblox[2]+100)
							Click
							MouseMove, 350, (Roblox[3]+70)
							return 2
						}
						imgPos := nm_imgSearch("standing.png",30,"lowright")
						If (imgPos[1] = 0){
							MouseMove, 30, (Roblox[2]+100)
							Click
							MouseMove, 350, (Roblox[3]+70)
							return 4
						}
					}
					MouseMove, 30, (Roblox[2]+100)
					Click
					MouseMove, 350, (Roblox[3]+70)
					return 1
				}
			}
			;MouseGetPos, xpos, ypos
			;if(xpos!=30 || ypos!=200)
				;MouseMove, 30, (Roblox[2]+200), 5
			;SendEvent, {Click, WheelUp, 200}
			loop, 2 {
				send, {WheelUp 1}
				Sleep, 50
			}
			sleep, 350
		}
	}
	;%plantername%Check:=0
	;Guicontrol,,%plantername%Check,0
	LostPlanters:=LostPlanters . planterName
	ba_saveConfig_()
	MouseMove, 30, (Roblox[2]+100)
	Click
	MouseMove, 350, (Roblox[3]+70)
	return 0
}
ba_harvestPlanter(planterNum){
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
	global Roblox
	global BackKey
	global RightKey
	global MovespeedFactor
	global objective
	global WindowedScreen
	global TotalPlantersCollected, SessionPlantersCollected
	GuiControlGet, HarvestFullGrown
	;goto specified field
	;ba_locateVB()
	nm_Reset()
	objective:=(PlanterName%planterNum% . " (" . PlanterField%planterNum% . ")")
	nm_gotoRamp()
	nm_gotoCannon()
	planterName:=PlanterName%planterNum%
	fieldName:=PlanterField%planterNum%
	nm_setStatus("Collecting", (planterName . " (" . fieldName . ")"))
	nm_cannonTo(fieldName)

	sleep, 1000
	findPlanter := nm_imgSearch("e_button.png",10)
    if (findPlanter[1] = 1){
		findPlanter := nm_searchForE()
	}
	if (not findPlanter){
		;check for phantom planter
		IniRead, PlanterName%planterNum%, ba_config.ini, Planters, PlanterName%planterNum%
		planterName:=PlanterName%planterNum%
		planterImg:= (planterName . ".png")
		nm_setStatus("Checking", "Phantom Planter: " . planterName)
		WinActivate, Roblox
		WinGetPos , windowX, windowY, windowWidth, windowHeight, Roblox
		;open item menu
		imgPos := nm_imgSearch("ItemMenu.png",10, "left")
		If (imgPos[1] != 0){
			MouseMove, 30, (Roblox[2]+100)
			Click
			MouseMove, 350, (Roblox[3]+70)
		}
		;scroll through menu to find planter
		loop, 2 {
			MouseMove, 30, (Roblox[2]+200), 5
		}
		MouseMove, 30, (Roblox[2]+200), 5
	    Loop, 100 {
			send, {WheelDown 1}
			Sleep, 50
		}
		MouseMove, 30, (Roblox[2]+200), 5
		Loop, 25 {
			planterPos := nm_imgSearch(planterImg, 100, "left")
			If (planterPos[1] = 0){ ;found planter in inventory planter is a phantom
				nm_setObjective(planterName . " found. Clearing Data.")
				;statusUpdate("Phantom Planter: " . planterName . " found. Clearing Data.")
				;clear phantom planter data
				IniWrite, "None", ba_config.ini, Planters, PlanterName%planterNum%
				IniWrite, "None", ba_config.ini, Planters, PlanterField%planterNum%
				IniWrite, "None", ba_config.ini, Planters, PlanterNectar%planterNum%
				IniWrite, 20211106000000, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
				IniWrite, 0, ba_config.ini, Planters, PlanterEstPercent%planterNum%
				;readback ini values
				IniRead, PlanterName%planterNum%, ba_config.ini, Planters, PlanterName%planterNum%
				IniRead, PlanterField%planterNum%, ba_config.ini, Planters, PlanterField%planterNum%
				IniRead, PlanterNectar%planterNum%, ba_config.ini, Planters, PlanterNectar%planterNum%
				IniRead, PlanterHarvestTime%planterNum%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
				IniRead, PlanterEstPercent%planterNum%, ba_config.ini, Planters, PlanterEstPercent%planterNum%
				break
			}
			loop, 2 {
				send, {WheelUp 1}
				Sleep, 50
			}
			sleep, 350
		}
	}
	sleep, 100
	planterConfirm1:=nm_imgSearch("planterConfirm1.png",0,"center")
	planterConfirm2:=nm_imgSearch("planterConfirm2.png",0,"center")
	planterConfirm3:=nm_imgSearch("planterConfirm3.png",0,"center")
	temp1:=planterConfirm1[1]
	temp2:=planterConfirm2[1]
	temp3:=planterConfirm3[1]
	;msgbox 1=%temp1% 2=%temp2% 3=%temp3%
	if (findPlanter && (planterConfirm1[1]=0 || planterConfirm2[1]=0 || planterConfirm3[1]=0)){
		findPlanter := nm_imgSearch("e_button.png",10)
		if (findPlanter[1] = 1){
			return
		}
        send, e
		sleep, 500
		imgPos := nm_imgSearch("yes.png",30)
        If (imgPos[1] = 0){
			;check Full Grown setting
			if(HarvestFullGrown) { ;press no and advance ready timer by 10 minutes
				newtime:=nowUnix()+10*60
				PlanterHarvestTime%planterNum%:=newtime
				IniWrite, %newtime%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
				imgPos := nm_imgSearch("no.png",30)
				If (imgPos[1] = 0){
					MouseMove, (imgPos[2]), (imgPos[3])
					Click
					MouseMove, 350, (Roblox[3]+70)
				}
			}
            ;MouseMove, (imgPos[2] + 10), (imgPos[3] + 10)
			MouseMove, (imgPos[2]), (imgPos[3])
            Click
			MouseMove, 350, (Roblox[3]+70)
        }
		sleep, 500
		findPlanter := nm_imgSearch("e_button.png",10)
		if (findPlanter[1] = 1){
			;reset values
			PlanterName%planterNum%:="None"
			PlanterField%planterNum%:="None"
			PlanterNectar%planterNum%:="None"
			PlanterHarvestTime%planterNum%:=20211106000000
			PlanterEstPercent%planterNum%:=0
			PlanterNameN:=PlanterName%planterNum%
			PlanterFieldN:=PlanterField%planterNum%
			PlanterNectarN:=PlanterNectar%planterNum%
			PlanterHarvestTimeN:=PlanterHarvestTime%planterNum%
			PlanterEstPercentN:=PlanterEstPercent%planterNum%
			;save changes
			IniWrite, %PlanterNameN%, ba_config.ini, Planters, PlanterName%planterNum%
			IniWrite, %PlanterFieldN%, ba_config.ini, Planters, PlanterField%planterNum%
			IniWrite, %PlanterNectarN%, ba_config.ini, Planters, PlanterNectar%planterNum%
			IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
			IniWrite, %PlanterEstPercentN%, ba_config.ini, Planters, PlanterEstPercent%planterNum%
			;readback ini values
			IniRead, PlanterName%planterNum%, ba_config.ini, Planters, PlanterName%planterNum%
			IniRead, PlanterField%planterNum%, ba_config.ini, Planters, PlanterField%planterNum%
			IniRead, PlanterNectar%planterNum%, ba_config.ini, Planters, PlanterNectar%planterNum%
			IniRead, PlanterHarvestTime%planterNum%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
			IniRead, PlanterEstPercent%planterNum%, ba_config.ini, Planters, PlanterEstPercent%planterNum%
			TotalPlantersCollected:=TotalPlantersCollected+1
			SessionPlantersCollected:=SessionPlantersCollected+1
			IniWrite, %TotalPlantersCollected%, nm_config.ini, Status, TotalPlantersCollected
			IniWrite, %SessionPlantersCollected%, nm_config.ini, Status, SessionPlantersCollected
			;gather loot
			nm_setStatus("Looting", planterName . " Loot")
			sleep, 4000
			nm_Move(1500*MoveSpeedFactor, BackKey, RightKey)
			nm_loot(2000, 5, "left")
		}
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
	GuiControlGet, HarvestIntervalNum
	HarvestInterval:=HarvestIntervalNum
	loop, 3{
		IniRead, PlanterName%A_Index%, ba_config.ini, Planters, PlanterName%A_Index%
		IniRead, PlanterField%A_Index%, ba_config.ini, Planters, PlanterField%A_Index%
		IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
		IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
		IniRead, PlanterEstPercent%A_Index%, ba_config.ini, Planters, PlanterEstPercent%A_Index%
	}
	IniRead, HarvestInterval, ba_config.ini, gui, HarvestInterval
	GuiControlGet, PlasticPlanterCheck
	GuiControlGet, CandyPlanterCheck
	GuiControlGet, BlueClayPlanterCheck
	GuiControlGet, RedClayPlanterCheck
	GuiControlGet, TackyPlanterCheck
	GuiControlGet, PesticidePlanterCheck
	GuiControlGet, PetalPlanterCheck
	GuiControlGet, PaperPlanterCheck
	GuiControlGet, TicketPlanterCheck
	GuiControlGet, PlanterOfPlentyCheck
	GuiControlGet, n1minPercent
	GuiControlGet, n2minPercent
	GuiControlGet, n3minPercent
	GuiControlGet, n4minPercent
	GuiControlGet, n5minPercent
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
	IniWrite, %PlanterNameN%, ba_config.ini, Planters, PlanterName%planterNum%
	IniWrite, %PlanterFieldN%, ba_config.ini, Planters, PlanterField%planterNum%
	IniWrite, %PlanterNectarN%, ba_config.ini, Planters, PlanterNectar%planterNum%

	;make all harvest times equal
	loop, 3 {
		if(not HarvestFullGrown && PlanterHarvestTime%A_Index% > PlanterHarvestTimeN && PlanterHarvestTime%A_Index% < 20211106000000)
			IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
		else if(A_Index=planterNum)
			IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
	}

	;IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime%planterNum%
	IniWrite, %PlanterEstPercentN%, ba_config.ini, Planters, PlanterEstPercent%planterNum%
	IniWrite, %fieldname%, ba_config.ini, Planters, Last%nectar%Field
}
ba_showPlanterTimers(){
	run, PlanterTimers.ahk
}
ba_resetConfig(){
	if(fileexist("ba_config.ini")) {
		FileDelete ba_config.ini
	}
		FileAppend,
    (
;this is the BA config file
[Planters]
;nectar fields ordered from best to worst (will round-robin rotate but always starting in this order)
ComfortingFields=Dandelion, Bamboo, Pine Tree
RefreshingFields=Coconut, Strawberry, Blue Flower
SatisfyingFields=Pineapple, Sunflower, Pumpkin
MotivatingFields=Stump, Spider, Mushroom, Rose
InvigoratingFields=Pepper, Mountain Top, Clover, Cactus
LastComfortingField=Pine Tree
LastRefreshingField=Blue Flower
LastSatisfyingField=Pumpkin
LastMotivatingField=Rose
LastInvigoratingField=Cactus
;field planters ordered from best to worst (will always try to pick the best planter for the field)
;planters that provide no bonuses at all are ordered by worst to best so it can preserve the "better" planters for other nectar types
;planters array: [1] planter name, [2] nectar bonus, [3] speed bonus, [4] hours to complete growth (no field degradation is assumed)
BambooPlanters=PetalPlanter, 1.5, 1.16, 12.12; PlanterOfPlenty, 1.5, 1, 16; BlueClayPlanter, 1.2, 1.17, 5.12; PesticidePlanter, 1, 1.3, 7.69; TackyPlanter, 1.25, 1, 8; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; RedClayPlanter, 1, 1, 6; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
BlueFlowerPlanters=PlanterOfPlenty, 1.5, 1, 16; BlueClayPlanter, 1.2, 1.17, 5.12; TackyPlanter, 1, 1.25, 6.4; PetalPlanter, 1, 1.16, 12.12; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; RedClayPlanter, 1, 1, 6; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
CactusPlanters=PlanterOfPlenty, 1.5, 1, 16; RedClayPlanter, 1.2, 1.11, 5.42; BlueClayPlanter, 1, 1.13, 5.33; PetalPlanter, 1, 1.04, 13.53; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; TackyPlanter, 1, 1, 8; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
CloverPlanters=PlanterOfPlenty, 1.5, 1, 16; RedClayPlanter, 1.2, 1.09, 5.53; TackyPlanter, 1, 1.25, 6.4; PetalPlanter, 1, 1.16, 12.07; BlueClayPlanter, 1, 1.09, 5.53; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
CoconutPlanters=PlanterOfPlenty, 1.5, 1.5, 10.67; PetalPlanter, 1, 1.45, 9.68; CandyPlanter, 1, 1.25, 3.2; BlueClayPlanter, 1.2,  1.01, 5.93; RedClayPlanter, 1, 1.02, 5.91; PlasticPlanter, 1, 1, 2; TackyPlanter, 1, 1, 8; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
DandelionPlanters=PetalPlanter, 1.5, 1.43, 9.82; TackyPlanter, 1.25, 1.25, 6.4; PlanterOfPlenty, 1.5, 1, 16; BlueClayPlanter, 1.2, 1.03, 5.85; RedClayPlanter, 1, 1.01, 5.93; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
MountainTopPlanters=PlanterOfPlenty, 1.5, 1.5, 10.67; RedClayPlanter, 1.2, 1.13, 5.33; BlueClayPlanter, 1, 1.13, 5.33; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; TackyPlanter, 1, 1, 8; PesticidePlanter, 1, 1, 10; PetalPlanter, 1, 1, 14; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
MushroomPlanters=PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1.3, 1, 10; TackyPlanter, 1, 1.25, 6.4; CandyPlanter, 1.2, 1, 4; RedClayPlanter, 1, 1.19, 5.11; PetalPlanter, 1, 1.15, 12.17; PlasticPlanter, 1, 1, 2; BlueClayPlanter, 1, 1, 6; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
PepperPlanters=PlanterOfPlenty, 1.5, 1.5, 10.67; RedClayPlanter, 1.2, 1.23, 4.88; PetalPlanter, 1, 1.04, 13.46; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; BlueClayPlanter, 1, 1, 6; TackyPlanter, 1, 1, 8; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
PineTreePlanters=PetalPlanter, 1.5, 1.08, 12.96; PlanterOfPlenty, 1.5, 1, 16; BlueClayPlanter, 1.2, 1.21, 4.96; TackyPlanter, 1.25, 1, 8; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; RedClayPlanter, 1, 1, 6; PesticidePlanter, 1, 1, 10; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
PineapplePlanters=PetalPlanter, 1.5, 1.45, 9.69; PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1.3, 1, 10; CandyPlanter, 1, 1.25, 3.2; TackyPlanter, 1.25, 1, 8; RedClayPlanter, 1.2, 1.02, 5.91; BlueClayPlanter, 1, 1.01, 5.93; PlasticPlanter, 1, 1, 2; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
PumpkinPlanters=PetalPlanter, 1.5, 1.29, 10.89; PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1.3, 1, 10; RedClayPlanter, 1.2, 1.06, 5.69; TackyPlanter, 1.25, 1, 8; BlueClayPlanter, 1, 1.05, 5.7; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
RosePlanters=PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1.3, 1, 10; RedClayPlanter, 1, 1.2, 4.98; CandyPlanter, 1.2, 1, 4; PetalPlanter, 1, 1.09, 12.84; PlasticPlanter, 1, 1, 2; BlueClayPlanter, 1, 1, 6; TackyPlanter, 1, 1, 8; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
SpiderPlanters=PesticidePlanter, 1.3, 1.3, 7.69; PetalPlanter, 1, 1.5, 9.33; PlanterOfPlenty, 1.5, 1, 16; CandyPlanter, 1.2, 1, 4; PlasticPlanter, 1, 1, 2; BlueClayPlanter, 1, 1, 6; RedClayPlanter, 1, 1, 6; TackyPlanter, 1, 1, 8; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
StrawberryPlanters=PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1, 1.3, 7.69; CandyPlanter, 1, 1.25, 3.2; BlueClayPlanter, 1.2, 1, 6; RedClayPlanter, 1, 1.17, 5.12; PetalPlanter, 1, 1.16, 12.12; PlasticPlanter, 1, 1, 2; TackyPlanter, 1, 1, 8; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
StumpPlanters=PlanterOfPlenty, 1.5, 1.5, 10.67; PesticidePlanter, 1.3, 1, 10; CandyPlanter, 1.2, 1, 4; BlueClayPlanter, 1, 1.19, 5.05; PetalPlanter, 1, 1.1, 12.79; RedClayPlanter, 1, 1.02, 5.91; PlasticPlanter, 1, 1, 2; TackyPlanter, 1, 1, 8; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
SunflowerPlanters=PetalPlanter, 1.5, 1.36, 10.33; TackyPlanter, 1.25, 1.25, 6.4; PlanterOfPlenty, 1.5, 1, 16; PesticidePlanter, 1.3, 1, 10; RedClayPlanter, 1.2, 1.04, 5.8; BlueClayPlanter, 1, 1.04, 5.78; PlasticPlanter, 1, 1, 2; CandyPlanter, 1, 1, 4; PaperPlanter, .75, 1, 1; TicketPlanter, 2, 1, 2
PlanterName1=None
PlanterName2=None
PlanterName3=None
PlanterField1=None
PlanterField2=None
PlanterField3=None
PlanterHarvestTime1=20211106000000
PlanterHarvestTime2=20211106000000
PlanterHarvestTime3=20211106000000
PlanterNectar1=None
PlanterNectar2=None
PlanterNectar3=None
PlanterEstPercent1=0
PlanterEstPercent2=0
PlanterEstPercent3=0

[FieldBoost]
FieldLastBoosted=20211106000000
FieldLastBoostedBy=None
FieldNextBoostedBy=None
FieldBoostStacks=0
AFBdiceUsed=0
AFBglitterUsed=0

[gui]
EnablePlantersPlus=0
nPreset=Blue
MaxAllowedPlanters=3
n1priority=Comforting
n2priority=Motivating
n3priority=Satisfying
n4priority=Refreshing
n5priority=Invigorating
n1string=||None|Comforting|Refreshing|Satisfying|Motivating|Invigorating
n2string=||None|Refreshing|Satisfying|Motivating|Invigorating
n3string=||None|Refreshing|Satisfying|Invigorating
n4string=||None|Refreshing|Invigorating
n5string=||None|Invigorating
n1minPercent=90
n2minPercent=90
n3minPercent=90
n4minPercent=90
n5minPercent=10
HarvestInterval=2
AutomaticHarvestInterval=0
HarvestFullGrown=0
GotoPlanterField=0
PlasticPlanterCheck=1
CandyPlanterCheck=1
BlueClayPlanterCheck=1
RedClayPlanterCheck=1
TackyPlanterCheck=1
PesticidePlanterCheck=1
PetalPlanterCheck=0
PaperPlanterCheck=0
TicketPlanterCheck=0
PlanterOfPlentyCheck=0
BambooFieldCheck=0
BlueFlowerFieldCheck=1
CactusFieldCheck=1
CloverFieldCheck=1
CoconutFieldCheck=0
DandelionFieldCheck=1
MountainTopFieldCheck=0
MushroomFieldCheck=0
PepperFieldCheck=1
PineTreeFieldCheck=1
PineappleFieldCheck=1
PumpkinFieldCheck=0
RoseFieldCheck=1
SpiderFieldCheck=1
StrawberryFieldCheck=1
StumpFieldCheck=0
SunflowerFieldCheck=1
MaxPlanters=3
TimerGuiTransparency=30
TimerX=150
TimerY=150
TimerW=500
TimerH=100
TimersOpen=0
HiveDistance=450
MoveSpeedFactor=1
MoveSpeed=28
DayOrNight=Day
NightLastDetected=20211106000000
VBLastKilled=20211106000000
StingerCheck=0
StingerPepperCheck=1
StingerMountainTopCheck=1
StingerRoseCheck=1
StingerCactusCheck=1
StingerSpiderCheck=1
StingerCloverCheck=1
StatusLogReverse=0
FieldDriftCompensation=0
FDCMoveDirFB=Fwd
FDCMoveDirLR=Left
FDCMoveDurFB=250
FDCMoveDurLR=250
AutoFieldBoostActive=0
AutoFieldBoostRefresh=12.5
AFBDiceEnable=0
AFBGlitterEnable=0
AFBFieldEnable=0
AFBDiceHotbar=None
AFBGlitterHotbar=None
AFBDiceLimitEnable=1
AFBGlitterLimitEnable=1
AFBHoursLimitEnable=1
AFBDiceLimit=1
AFBGlitterLimit=1
AFBHoursLimit=.01
AltPineStart=0

[other]
n1Switch=1
n2switch=1
n3Switch=1
n4Switch=1
n5Switch=1
), ba_config.ini
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LABELS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getout:
GuiClose:
if(winexist("Timers") && not pass) {
if(fileexist("ba_config.ini"))
    IniWrite, 1, ba_config.ini, gui, TimersOpen
    winclose, Timers
    pass:=1
} else if (not winexist("Timers") && not pass){
if(fileexist("ba_config.ini"))
    IniWrite, 0, ba_config.ini, gui, TimersOpen
    pass:=1
}
nm_SaveGui()
ExitApp

StartBackground:
settimer, Background, 2000
bg:=1
Background:
if(bg)
	bg:=0
else
	msgbox bakground task took too long
global disableDayorNight, AFBrollingDice, BackpackPercentFiltered
;auto field boost
if (AFBrollingDice && not disableDayorNight&& state!="Disconnected")
    nm_fieldBoostDice()
;death check
if(state="Gathering" || state="Attacking" || state="Searching")
	nm_deathCheck()
;day or night check
nm_dayOrNight()
;backpack percent
if(state="Gathering" || state="Converting") {
	nm_backpackPercentFilter()
} 
;use/check hotbar boosts
nm_hotbar()
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
send ^{Alt}
nm_setStatus("Begin", "Macro")
; CHECK FULL SCREEN MODE
if(not WinExist("Roblox")) {
	disconnectCheck()
}
WinActivate, Roblox
WinWaitActive, Roblox
Roblox:=[]
Roblox:=nm_imgSearch("roblox2.png",10,"buff")
global WindowedScreen
If(Roblox[3]>30)
	WindowedScreen:=1
else
	WindowedScreen:=0
IniWrite, %WindowedScreen%, nm_config.ini, Settings, WindowedScreen
MouseMove, 350, (Roblox[3]+70)
;set stats
MacroRunning:=1
MacroStartTime:=nowUnix()
global lastHourlyUpdate:=0
global PausedRuntime:=0
;lock tabs
nm_TabGatherLock()
nm_TabCollectLock()
nm_TabBoostLock()
nm_TabPlantersPlusLock()
nm_TabSettingsLock()
GuiControl, show, LockedText
;set globals
nm_setStatus(0, "Setting Globals")
global SessionRuntime:=0
global TotalGatherTime
global SessionGatherTime:=0
global TotalConvertTime
global SessionConvertTime:=0
global TotalViciousKills
global SessionViciousKills:=0
global TotalBossKills
global SessionBossKills:=0
global TotalBugKills
global SessionBugKills:=0
global TotalPlantersCollected
global SessionPlantersCollected:=0
global TotalQuestsComplete
global SessionQuestsComplete:=0
global TotalDisconnects
global SessionDisconnects:=0
global CurrentField
global FwdKey
global LeftKey
global BackKey
global RightKey
global RotLeft
global RotRight
global KeyDelay
global MoveSpeedFactor
global ZoomIn
global ZoomOut
global MoveMethod
global HiveVariation
global HiveSlot
global DisableToolUse
global ClockCheck
global MondoBuffCheck
global MondoAction
global AntPassCheck, AntPassAction
global HoneyDisCheck
global TreatDisCheck
global BlueberryDisCheck
global StrawberryDisCheck
global CoconutDisCheck
global RoyalJellyDisCheck
global GlueDisCheck
global FieldBooster1
global FieldBooster2
global FieldBooster3
global FieldBoosterMins
global GiftedViciousCheck
global BugrunInterruptCheck
global BugDeathCheckLockout:=0
global BugrunLadybugsCheck
global BugrunRhinoBeetlesCheck
global BugrunSpiderCheck
global BugrunMantisCheck
global BugrunScorpionsCheck
global BugrunWerewolfCheck
global BugrunLadybugsLoot
global BugrunRhinoBeetlesLoot
global BugrunSpiderLoot
global BugrunMantisLoot
global BugrunScorpionsLoot
global BugrunWerewolfLoot
global StingerCheck
global StingerPepperCheck
global StingerMountainTopCheck
global StingerRoseCheck
global StingerCactusCheck
global StingerSpiderCheck
global StingerCloverCheck
global TunnelBearCheck
global TunnelBearBabyCheck
global LastTunnelBear
global KingBeetleCheck
global KingBeetleBabyCheck
global LastKingBeetle
global LastClock
global LastMondoBuff
global LastAntPass
global LastHoneyDis
global LastTreatDis
global LastBlueberryDis
global LastStrawberryDis
global LastCoconutDis
global LastRoyalJellyDis
global LastGlueDis
global LastBlueBoost
global LastRedBoost
global LastMountainBoost
global LastStockings
global LastWreath
global LastFeast
global LastCandles
global LastSamovar
global LastLidArt
global LastBugrunLadybugs
global LastBugrunRhinoBeetles
global LastBugrunSpider
global LastBugrunMantis
global LastBugrunScorpions
global LastBugrunWerewolf
global NightLastDetected
global VBLastKilled
global FieldName1
global FieldName2
global FieldName3
global FieldPattern1
global FieldPattern2
global FieldPattern3
global FieldPatternSize1
global FieldPatternSize2
global FieldPatternSize3
global FieldPatternReps1
global FieldPatternReps2
global FieldPatternReps3
global FieldPatternShift1
global FieldPatternShift2
global FieldPatternShift3
global FieldUntilMins1
global FieldUntilMins2
global FieldUntilMins3
global FieldUntilPack1
global FieldUntilPack2
global FieldUntilPack3
global FieldReturnType1
global FieldReturnType2
global FieldReturnType3
global FieldSprinklerLoc1
global FieldSprinklerLoc2
global FieldSprinklerLoc3
global FieldSprinklerDist1
global FieldSprinklerDist2
global FieldSprinklerDist3
global FieldRotateDirection1
global FieldRotateDirection2
global FieldRotateDirection3
global FieldRotateTimes1
global FieldRotateTimes2
global FieldRotateTimes3
global FieldDriftCheck1
global FieldDriftCheck2
global FieldDriftCheck3
global HotkeyTime2
global HotkeyTime3
global HotkeyTime4
global HotkeyTime5
global HotkeyTime6
global HotkeyTime7
global HotkeyTimeUnits2
global HotkeyTimeUnits3
global HotkeyTimeUnits4
global HotkeyTimeUnits5
global HotkeyTimeUnits6
global HotkeyTimeUnits7
global HotkeyWhile2
global HotkeyWhile3
global HotkeyWhile4
global HotkeyWhile5
global HotkeyWhile6
global HotkeyWhile7
global LastMicroConverter
global LastWhirligig
global LastEnzymes
global AutoFieldBoostActive
global FieldLastBoosted
global FieldLastBoostedBy
global FieldNextBoostedBy
global FieldBoostStacks
global AutoFieldBoostRefresh
global AFBHoursLimitEnable
global AFBHoursLimit
global AFBFieldEnable
global AFBDiceEnable
global AFBGlitterEnable
global AFBrollingDice:=0
global AFBuseGlitter:=0
global AFBuseBooster:=0
global AFBdiceUsed
global AFBglitterUsed
global AFBDiceLimit
global AFBDiceLimitEnable
global AFBDiceHotbar
global AFBglitterHotbar
global AFBGlitterLimit
global AFBGlitterLimitEnable
global PolarQuestCheck
global PolarQuestGatherInterruptCheck, BuckoQuestGatherInterruptCheck, RileyQuestGatherInterruptCheck, QuestGatherMins
global BlackQuestCheck, BuckoQuestCheck, RileyQuestCheck, HoneyQuestCheck
global LastBlackQuest
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
global MyField:=None
global ReloadRobloxSecs
global Webhook
global BoostChaserCheck
GuiControlGet, CurrentField
GuiControlGet, MoveMethod
GuiControlGet, FwdKey
GuiControlGet, LeftKey
GuiControlGet, BackKey
GuiControlGet, RightKey
GuiControlGet, RotLeft
GuiControlGet, RotRight
GuiControlGet, KeyDelay
GuiControlGet, ZoomIn
GuiControlGet, ZoomOut
IniRead, MoveSpeedFactor, nm_config.ini, Settings, MoveSpeedFactor
GuiControlGet, HiveVariation
GuiControlGet, HiveSlot
GuiControlGet, DisableToolUse
GuiControlGet, ClockCheck
GuiControlGet, MondoBuffCheck
GuiControlGet, MondoAction
GuiControlGet, AntPassCheck
GuiControlGet, AntPassAction
GuiControlGet, HoneyDisCheck
GuiControlGet, TreatDisCheck
GuiControlGet, BlueberryDisCheck
GuiControlGet, StrawberryDisCheck
GuiControlGet, CoconutDisCheck
GuiControlGet, RoyalJellyDisCheck
GuiControlGet, GlueDisCheck
GuiControlGet, FieldBooster1
GuiControlGet, FieldBooster2
GuiControlGet, FieldBooster3
GuiControlGet, FieldBoosterMins
GuiControlGet, GiftedViciousCheck
GuiControlGet, BugrunInterruptCheck
GuiControlGet, BugrunLadybugsCheck
GuiControlGet, BugrunRhinoBeetlesCheck
GuiControlGet, BugrunSpiderCheck
GuiControlGet, BugrunMantisCheck
GuiControlGet, BugrunScorpionsCheck
GuiControlGet, BugrunWerewolfCheck
GuiControlGet, BugrunLadybugsLoot
GuiControlGet, BugrunRhinoBeetlesLoot
GuiControlGet, BugrunSpiderLoot
GuiControlGet, BugrunMantisLoot
GuiControlGet, BugrunScorpionsLoot
GuiControlGet, BugrunWerewolfLoot
GuiControlGet, StingerCheck
GuiControlGet, TunnelBearCheck
GuiControlGet, TunnelBearBabyCheck
GuiControlGet, KingBeetleCheck
GuiControlGet, KingBeetleBabyCheck
GuiControlGet, QuestGatherMins
GuiControlGet, PolarQuestCheck
GuiControlGet, PolarQuestGatherInterruptCheck
GuiControlGet, BuckoQuestGatherInterruptCheck
GuiControlGet, RileyQuestGatherInterruptCheck
GuiControlGet, HoneyQuestCheck
GuiControlGet, BlackQuestCheck
GuiControlGet, BuckoQuestCheck
GuiControlGet, RileyQuestCheck
GuiControlGet, ReloadRobloxSecs
GuiControlGet, Webhook
GuiControlGet, BoostChaserCheck
loop 3 {
	GuiControlGet, FieldName%A_Index%
	GuiControlGet, FieldPattern%A_Index%
	GuiControlGet, FieldPatternSize%A_Index%
	GuiControlGet, FieldPatternReps%A_Index%
	GuiControlGet, FieldPatternShift%A_Index%
	GuiControlGet, FieldUntilMins%A_Index%
	GuiControlGet, FieldUntilPack%A_Index%
	GuiControlGet, FieldReturnType%A_Index%
	GuiControlGet, FieldSprinklerLoc%A_Index%
	GuiControlGet, FieldSprinklerDist%A_Index%
	GuiControlGet, FieldRotateDirection%A_Index%
	GuiControlGet, FieldRotateTimes%A_Index%
	GuiControlGet, FieldDriftCheck%A_Index%
}
IniRead, StingerPepperCheck, nm_config.ini, Collect, StingerPepperCheck
IniRead, StingerMountainTopCheck, nm_config.ini, Collect, StingerMountainTopCheck
IniRead, StingerRoseCheck, nm_config.ini, Collect, StingerRoseCheck
IniRead, StingerCactusCheck, nm_config.ini, Collect, StingerCactusCheck
IniRead, StingerSpiderCheck, nm_config.ini, Collect, StingerSpiderCheck
IniRead, StingerCloverCheck, nm_config.ini, Collect, StingerCloverCheck
IniRead, LastTunnelBear, nm_config.ini, Collect, LastTunnelBear
IniRead, LastKingBeetle, nm_config.ini, Collect, LastKingBeetle
IniRead, LastClock, nm_config.ini, Collect, LastClock
IniRead, LastMondoBuff, nm_config.ini, Collect, LastMondoBuff
IniRead, LastAntPass, nm_config.ini, Collect, LastAntPass
IniRead, LastHoneyDis, nm_config.ini, Collect, LastHoneyDis
IniRead, LastTreatDis, nm_config.ini, Collect, LastTreatDis
IniRead, LastBlueberryDis, nm_config.ini, Collect, LastBlueberryDis
IniRead, LastStrawberryDis, nm_config.ini, Collect, LastStrawberryDis
IniRead, LastCoconutDis, nm_config.ini, Collect, LastCoconutDis
IniRead, LastRoyalJellyDis, nm_config.ini, Collect, LastRoyalJellyDis
IniRead, LastGlueDis, nm_config.ini, Collect, LastGlueDis
IniRead, LastBlueBoost, nm_config.ini, Boost, LastBlueBoost
IniRead, LastRedBoost, nm_config.ini, Boost, LastRedBoost
IniRead, LastMountainBoost, nm_config.ini, Boost, LastMountainBoost
IniRead, LastStockings, nm_config.ini, Collect, LastStockings
IniRead, LastWreath, nm_config.ini, Collect, LastWreath
IniRead, LastFeast, nm_config.ini, Collect, LastFeast
IniRead, LastCandles, nm_config.ini, Collect, LastCandles
IniRead, LastSamovar, nm_config.ini, Collect, LastSamovar
IniRead, LastLidArt, nm_config.ini, Collect, LastLidArt
IniRead, LastBugrunLadybugs, nm_config.ini, Collect, LastBugrunLadybugs
IniRead, LastBugrunRhinoBeetles, nm_config.ini, Collect, LastBugrunRhinoBeetles
IniRead, LastBugrunSpider, nm_config.ini, Collect, LastBugrunSpider
IniRead, LastBugrunMantis, nm_config.ini, Collect, LastBugrunMantis
IniRead, LastBugrunScorpions, nm_config.ini, Collect, LastBugrunScorpions
IniRead, LastBugrunWerewolf, nm_config.ini, Collect, LastBugrunWerewolf
IniRead, NightLastDetected, nm_config.ini, Collect, NightLastDetected
IniRead, VBLastKilled, nm_config.ini, Collect, VBLastKilled
IniRead, AutoFieldBoostActive, nm_config.ini, Boost, AutoFieldBoostActive
IniRead, FieldLastBoosted, nm_config.ini, Boost, FieldLastBoosted
IniRead, FieldLastBoostedBy, nm_config.ini, Boost, FieldLastBoostedBy
IniRead, FieldNextBoostedBy, nm_config.ini, Boost, FieldNextBoostedBy
IniRead, FieldBoostStacks, nm_config.ini, Boost, FieldBoostStacks
IniRead, AutoFieldBoostRefresh, nm_config.ini, Boost, AutoFieldBoostRefresh
IniRead, AFBHoursLimitEnable, nm_config.ini, Boost, AFBHoursLimitEnable
IniRead, AFBHoursLimit, nm_config.ini, Boost, AFBHoursLimit
IniRead, AFBFieldEnable, nm_config.ini, Boost, AFBFieldEnable
IniRead, AFBDiceEnable, nm_config.ini, Boost, AFBDiceEnable
IniRead, AFBGlitterEnable, nm_config.ini, Boost, AFBGlitterEnable
IniRead, AFBdiceUsed, nm_config.ini, Boost, AFBdiceUsed
IniRead, AFBglitterUsed, nm_config.ini, Boost, AFBglitterUsed
IniRead, AFBDiceLimit, nm_config.ini, Boost, AFBDiceLimit
IniRead, AFBDiceLimitEnable, nm_config.ini, Boost, AFBDiceLimitEnable
IniRead, AFBdiceHotbar, nm_config.ini, Boost, AFBdiceHotbar
IniRead, AFBglitterHotbar, nm_config.ini, Boost, AFBglitterHotbar
IniRead, AFBGlitterLimit, nm_config.ini, Boost, AFBGlitterLimit
IniRead, AFBGlitterLimitEnable, nm_config.ini, Boost, AFBGlitterLimitEnable
;set ActiveHotkeys[]
global ActiveHotkeys
ActiveHotkeys:=[]
GuiControlGet HotkeyTime2
GuiControlGet HotkeyTime3
GuiControlGet HotkeyTime4
GuiControlGet HotkeyTime5
GuiControlGet HotkeyTime6
GuiControlGet HotkeyTime7
GuiControlGet HotkeyTimeUnits2
GuiControlGet HotkeyTimeUnits3
GuiControlGet HotkeyTimeUnits4
GuiControlGet HotkeyTimeUnits5
GuiControlGet HotkeyTimeUnits6
GuiControlGet HotkeyTimeUnits7
GuiControlGet HotkeyWhile2
GuiControlGet HotkeyWhile3
GuiControlGet HotkeyWhile4
GuiControlGet HotkeyWhile5
GuiControlGet HotkeyWhile6
GuiControlGet HotkeyWhile7
IniRead, LastHotkey2, nm_config.ini, Boost, LastHotkey2
IniRead, LastHotkey3, nm_config.ini, Boost, LastHotkey3
IniRead, LastHotkey4, nm_config.ini, Boost, LastHotkey4
IniRead, LastHotkey5, nm_config.ini, Boost, LastHotkey5
IniRead, LastHotkey6, nm_config.ini, Boost, LastHotkey6
IniRead, LastHotkey7, nm_config.ini, Boost, LastHotkey7
IniRead, LastMicroConverter, nm_config.ini, Boost, LastMicroConverter
IniRead, LastWhirligig, nm_config.ini, Boost, LastWhirligig
IniRead, LastEnzymes, nm_config.ini, Boost, LastEnzymes
IniRead, TotalGatherTime, nm_config.ini, Status, TotalGatherTime
IniRead, TotalConvertTime, nm_config.ini, Status, TotalConvertTime
IniRead, TotalViciousKills, nm_config.ini, Status, TotalViciousKills
IniRead, TotalBossKills, nm_config.ini, Status, TotalBossKills
IniRead, TotalBugKills, nm_config.ini, Status, TotalBugKills
IniRead, TotalPlantersCollected, nm_config.ini, Status, TotalPlantersCollected
IniRead, TotalQuestsComplete, nm_config.ini, Status, TotalQuestsComplete
IniRead, TotalDisconnects, nm_config.ini, Status, TotalDisconnects
IniRead, LastBlackQuest, nm_config.ini, Quests, LastBlackQuest
whileNames:=["Always", "Attacking", "Gathering", "At Hive"]
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
    msgbox, 257, WARNING!!,"Automatic Field Boost" is ACTIVATED.`n------------------------------------------------------------------------------------`nIf you continue the following quantity of items can be used:`nDice: %futureDice%`nGlitter: %futureGlitter%`n`nHIGHLY RECOMMENDED:`nDisable any non-essential tasks such as quests, bug runs, stingers, etc. Any time away from your gathering field can result in the loss of your field boost.
    IfMsgBox Ok
    {} else {
        return
    }
}

;start main loop
;nm_setObjective("Main Loop")
nm_setStatus(0, "Main Loop")
nm_Start()
return
;STOP MACRO
f3::
global TotalGatherTime, SessionGatherTime, TotalConvertTime, SessionConvertTime
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
IniWrite, %TotalRuntime%, nm_config.ini, Status, TotalRuntime
MacroRunning:=0
send {%FwdKey% up}
send {%BackKey% up}
send {%LeftKey% up}
send {%RightKey% up}
send {space up}
click up
;nm_releaseKeys()
IniWrite, %SessionRuntime%, nm_config.ini, Status, SessionRuntime
IniWrite, %TotalGatherTime%, nm_config.ini, Status, TotalGatherTime
IniWrite, %SessionGatherTime%, nm_config.ini, Status, SessionGatherTime
IniWrite, %TotalConvertTime%, nm_config.ini, Status, TotalConvertTime
IniWrite, %SessionConvertTime%, nm_config.ini, Status, SessionConvertTime
nm_setStatus("End", "Macro")
Reload
return
;PAUSE MACRO
f2::
global state
if(state="startup")
	return
if(A_IsPaused) {
	if(FwdKeyState)
		send {%FwdKey% down}
	if(BackKeyState)
		send {%BackKey% down}
	if(LeftKeyState)
		send {%LeftKey% down}
	if(RightKeyState)
		send {%RightKey% down}
	if(SpaceKeyState)
		send {space down}
	nm_setStatus(PauseState, PauseObjective)
	MacroRunning:=1
	;manage runtimes
	MacroStartTime:=nowUnix()
	GatherStartTime:=nowUnix()
} else {
	FwdKeyState:=GetKeyState(FwdKey)
	BackKeyState:=GetKeyState(BackKey)
	LeftKeyState:=GetKeyState(LeftKey)
	RightKeyState:=GetKeyState(RightKey)
	SpaceKeyState:=GetKeyState(Space)
	PauseState:=state
	PauseObjective:=objective
	send {%FwdKey% up}
	send {%BackKey% up}
	send {%LeftKey% up}
	send {%RightKey% up}
	send {space up}
	click up
	MacroRunning:=0
	;manage runtimes
	TotalRuntime:=TotalRuntime+(nowUnix()-MacroStartTime)
	PausedRuntime:=PausedRuntime+(nowUnix()-MacroStartTime)
	SessionRuntime:=SessionRuntime+(nowUnix()-MacroStartTime)
	if(GatherStartTime) {
		TotalGatherTime:=TotalGatherTime+(nowUnix()-GatherStartTime)
		SessionGatherTime:=SessionGatherTime+(nowUnix()-GatherStartTime)
	}
	IniWrite, %TotalRuntime%, nm_config.ini, Status, TotalRuntime
	nm_setStatus("Paused", "Press F2 to Continue")
}
Pause, Toggle, 1
return
f4::
loop, 1000 {
	click
	sleep, 10
}
return

