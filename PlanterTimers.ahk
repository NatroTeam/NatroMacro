;Enhancement Version 0.2.0
#SingleInstance force
global TimerGuiTransparency:=30
global TimerX:=150
global TimerY:=150
global TimerW:=500
global TimerH:=100
global diceUsed:=0
global glitterUsed:=0
Menu, tray, Icon, auryn.ico, 1, 1
gui ptimers:+AlwaysOnTop +border +resize +minsize50x30
gui ptimers:font, s8 w1000 cBlack
gui ptimers:color, FFFFFF
gui ptimers:+lastfound
gui ptimers:add, text,x120 y15 w185 vp1info +left +BackgroundTrans,%PlanterName1% in %PlanterField1%: 
gui ptimers:add, text,x120 y35 w185 vp2info +left +BackgroundTrans,%PlanterName2% in %PlanterField2%: 
gui ptimers:add, text,x120 y55 w185 vp3info +left +BackgroundTrans,%PlanterName3% in %PlanterField3%:
gui ptimers:add, text,x305 y15 w30 vp1nectar +left +BackgroundTrans,""
gui ptimers:add, text,x305 y35 w30 vp2nectar +left +BackgroundTrans,""
gui ptimers:add, text,x305 y55 w30 vp3nectar +left +BackgroundTrans,""
gui ptimers:add, text,x335 y15 w75 vp1timer +right +BackgroundTrans,h m s
gui ptimers:add, text,x335 y35 w75 vp2timer +right +BackgroundTrans,h m s
gui ptimers:add, text,x335 y55 w75 vp3timer +right +BackgroundTrans,h m s
gui ptimers:add, text,x5 y2 w40 +center +BackgroundTrans,Time
gui ptimers:add, text,x5 y15 w40 vtimeOfDay +center +BackgroundTrans,00:00:00
gui ptimers:add, text,x0 y22 w185 +left +BackgroundTrans,. . . . . . . .
gui ptimers:add, text,x0 y36 w60 +center +BackgroundTrans,Mondo
gui ptimers:add, text,x0 y50 w60 vmondoTimerB +center +BackgroundTrans,h m s
gui ptimers:add, text,x0 y50 w60 cRED vmondoTimerR +center +BackgroundTrans,h m s
gui ptimers:add, text,x0 y57 w185 +left +BackgroundTrans,. . . . . . . .
gui ptimers:add, text,x0 y70 w60 +center +BackgroundTrans,Puffs
gui ptimers:add, text,x0 y85 w60 vpuffTimerB +center +BackgroundTrans,h m s
gui ptimers:add, text,x0 y85 w60 cRED vpuffTimerR +center +BackgroundTrans,h m s
gui ptimers:font, s8 w400 cBlack
gui ptimers:add, text,x0 y-12 w185 +left +BackgroundTrans,__________________________________________________________________________________
gui ptimers:font, s8 w700 cBlack
gui, ptimers:add, text,x58 y-1 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y9 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y19 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y29 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y39 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y49 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y59 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y69 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y79 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x58 y89 w1 +left +BackgroundTrans,|


;gui ptimers:add, text,x120 y18 w185 +left +BackgroundTrans,_____________________________________________________
gui ptimers:add, text,x63 y2 w25 +center +BackgroundTrans,AFB:
gui ptimers:font, s6 w700 cBlack
gui ptimers:add, text,x91 y5 w25 cRED +left +BackgroundTrans vAFBon,[ON]
gui ptimers:add, text,x91 y5 w25 cGREEN +left +BackgroundTrans vAFBoff,[OFF]
gui ptimers:font, s8 w700 cBlack
gui ptimers:add, text,x58 y7 w185 +left +BackgroundTrans,. . . . . . . .
gui ptimers:add, text,x58 y53 w60 +center +BackgroundTrans vboostTimerItem,Re-Buff
gui ptimers:add, text,x58 y67 w60 vboostTimer +center +BackgroundTrans,h m s
gui ptimers:add, text,x58 y67 w60 cRED vboostTimerR +center +BackgroundTrans,h m s
gui ptimers:add, text,x58 y42 w185 +left +BackgroundTrans,. . . . . . . .
gui ptimers:font, s6 w700 cBlack
gui ptimers:add, text,x72 y20 w30 +right +BackgroundTrans,USED
gui ptimers:font, s8 w400 cBlack
gui ptimers:add, text,x58 y28 w33 +right +BackgroundTrans,Dice:
gui ptimers:add, text,x91 y28 w30 +left +BackgroundTrans vdiceUsed,9999
gui ptimers:add, text,x58 y38 w33 +right +BackgroundTrans,Glitter:
gui ptimers:add, text,x91 y38 w40 +left +BackgroundTrans vglitterUsed,9999
;gui, ptimers:add, text,x175 y18 w1 +left +BackgroundTrans,|
;gui, ptimers:add, text,x175 y8 w1 +left +BackgroundTrans,|
;gui, ptimers:add, text,x175 y-2 w1 +left +BackgroundTrans,|
gui ptimers:font, s6 w800 cBlack
gui ptimers:add, text,x425 y85 w40  +left +BackgroundTrans,Trans:
gui ptimers:font, s8 w1000 cBlack
Gui ptimers:Add, edit, x454 y83 w40 h16 Limit2 Number ReadOnly -border
if(fileexist("ba_config.ini"))
	IniRead, TimerGuiTransparency, ba_config.ini, gui, TimerGuiTransparency
Gui ptimers:Add, updown, Range0-80 vtimerGuiTransparency gsetTimerGuiTransparency, %TimerGuiTransparency%
guicontrol, ptimers:hide, mondoTimerR
guicontrol, ptimers:hide, puffTimerR
setTimerGuiTransparency()
Gui, ptimers:Add, Button, x413 y15 w43 h15 gba_resetPlanterTimer1, Ready
Gui, ptimers:Add, Button, x413 y35 w43 h15 gba_resetPlanterTimer2, Ready
Gui, ptimers:Add, Button, x413 y55 w43 h15 gba_resetPlanterTimer3, Ready
Gui, ptimers:Add, Button, x456 y15 w40 h15 gba_resetPlanterData1, Clear
Gui, ptimers:Add, Button, x456 y35 w40 h15 gba_resetPlanterData2, Clear
Gui, ptimers:Add, Button, x456 y55 w40 h15 gba_resetPlanterData3, Clear
gui, ptimers:add, text,x115 y-1 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y9 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y19 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y29 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y39 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y49 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y59 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y69 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y79 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x115 y89 w1 +left +BackgroundTrans,|

gui ptimers:add, text,x58 y85 w60 +Center +BackgroundTrans vdayOrNight,Day
gui, ptimers:add, text,x60 y70 w185 +left +BackgroundTrans,______________________________________________________________
;gui, ptimers:add, text,x163 y80 w1 +left +BackgroundTrans,|
;gui, ptimers:add, text,x163 y90 w1 +left +BackgroundTrans,|
gui, ptimers:add, text,x120 y85 w380 vpstatus +left +BackgroundTrans, Status: unknown

if(fileexist("ba_config.ini")){
	IniRead, TimerX, ba_config.ini, gui, TimerX
	IniRead, TimerY, ba_config.ini, gui, TimerY
	IniRead, TimerW, ba_config.ini, gui, TimerW
	IniRead, TimerH, ba_config.ini, gui, TimerH
}
;msgbox x=%TimerX% y=%TimerY%
gui ptimers:show, x%TimerX% y%TimerY% w%TimerW% h%TimerH%,Timers
;OnExit("ba_timersExit")
;IniRead, themeKey, config.ini, gui, themeSelect
;SkinForm(Apply, A_ScriptDir . "\styles\USkin.dll", A_ScriptDir . "\styles\" . themeKey . ".msstyles")

while(1){
	loop, 3{
		IniRead, PlanterName%A_Index%, ba_config.ini, Planters, PlanterName%A_Index%
		IniRead, PlanterField%A_Index%, ba_config.ini, Planters, PlanterField%A_Index%
		IniRead, PlanterNectar%A_Index%, ba_config.ini, Planters, PlanterNectar%A_Index%
		IniRead, PlanterHarvestTime%A_Index%, ba_config.ini, Planters, PlanterHarvestTime%A_Index%
		IniRead, PlanterEstPercent%A_Index%, ba_config.ini, Planters, PlanterEstPercent%A_Index%
	}
	IniRead, dayOrNight, nm_config.ini, gui, dayOrNight
	GuiControl,ptimers:,dayOrNight,%dayOrNight%
	;get state from main GUI
	ControlGetText, val, static4, Natro Macro
	p1timer:=PlanterHarvestTime1-toUnix_()
	p1hours:=floor(p1timer/3600)
	p1mins:=floor((p1timer-p1hours*3600)/60)
	p1secs:=p1timer-3600*P1hours-60*p1mins
	p2timer:=PlanterHarvestTime2-toUnix_()
	p2hours:=floor(p2timer/3600)
	p2mins:=floor((p2timer-p2hours*3600)/60)
	p2secs:=p2timer-3600*p2hours-60*p2mins
	p3timer:=PlanterHarvestTime3-toUnix_()
	p3hours:=floor(p3timer/3600)
	p3mins:=floor((p3timer-p3hours*3600)/60)
	p3secs:=p3timer-3600*p3hours-60*p3mins
	
	IniRead, AutoFieldBoostActive, nm_config.ini, Boost, AutoFieldBoostActive
	IniRead, diceUsed, nm_config.ini, Boost, AFBdiceUsed
	IniRead, glitterUsed, nm_config.ini, Boost, AFBglitterUsed
	GuiControl,ptimers:,diceUsed,%diceUsed%
	GuiControl,ptimers:,glitterUsed,%glitterUsed%
	;set on/off state
	if(AutoFieldBoostActive) {
		guicontrol, ptimers:hide, AFBoff
		guicontrol, ptimers:show, AFBon
		IniRead, FieldLastBoosted, nm_config.ini, Boost, FieldLastBoosted
		IniRead, FieldNextBoostedBy, nm_config.ini, Boost, FieldNextBoostedBy
		IniRead, AutoFieldBoostRefresh, nm_config.ini, Boost, AutoFieldBoostRefresh
		;calculate Auto Field Boost timer
		btimer:=(AutoFieldBoostRefresh*60)-(toUnix_()-FieldLastBoosted) ;seconds until next re-boost
		btimerstring:=""
		if (btimer>=0){
			guicontrol, ptimers:hide, boostTimerR
			guicontrol, ptimers:show, boostTimer
			bhours:=floor(btimer/3600)
			if (bhours>0)
				btimerstring:=btimerstring . round(bhours) . "h "
			bmins:=floor((btimer-bhours*3600)/60)
			if (bmins>0 || (bmins=0 && bhours>0))
				btimerstring:=btimerstring . round(abs(bmins)) . "m "
			bsecs:=(btimer-bhours*3600-bmins*60)
			if (bsecs>=0 || (bsecs=0 && bmins>0))
				btimerstring:=btimerstring . round(abs(bsecs)) . "s"
		} else {
			guicontrol, ptimers:hide, boostTimer
			guicontrol, ptimers:show, boostTimerR
			btimerstring:=btimerstring . "-"
			bhours:=floor(btimer/3600)
			if ((abs(bhours)-1)>0)
				btimerstring:=btimerstring . round(abs(bhours)-1) . "h "
			bmins:=floor((btimer-bhours*3600)/60)
			if ((59-abs(bmins))>0 || ((59-abs(bmins))=0 && (abs(bhours)-1)>0))
				btimerstring:=btimerstring . round(59-abs(bmins)) . "m "
			bsecs:=round(btimer-bhours*3600-bmins*60,0)
			if (abs(bsecs)>0 || (abs(bsecs)=0 && abs(bmins)>0))
				btimerstring:=btimerstring . round(59-abs(bsecs)) . "s"
		}
		;Determine next Auto Field Boost Item
		if(btimer>=86400 || btimer <= -86400) {
			GuiControl,ptimers:,boostTimerItem,----
			guicontrol, ptimers:hide, boostTimerR
			guicontrol, ptimers:show, boostTimer
			btimerstring:=("----")
		} else if(FieldNextBoostedBy="bbooster" || FieldNextBoostedBy="rbooster" || FieldNextBoostedBy="mbooster")
			GuiControl,ptimers:,boostTimerItem,Re-Boost
		else if(FieldNextBoostedBy="dice")
			GuiControl,ptimers:,boostTimerItem,Re-Dice
		else if(FieldNextBoostedBy="glitter")
			GuiControl,ptimers:,boostTimerItem,Re-Glitter
		GuiControl,ptimers:,boostTimer,%btimerstring%
		GuiControl,ptimers:,boostTimerR,%btimerstring%
	} else {
		guicontrol, ptimers:hide, AFBon
		guicontrol, ptimers:show, AFBoff
		guicontrol, ptimers:hide, boostTimerR
		guicontrol, ptimers:show, boostTimer
		GuiControl,ptimers:,boostTimerItem,----
		GuiControl,ptimers:,boostTimer,----
		GuiControl,ptimers:,boostTimerR,----
	}
	

	
	GuiControl,ptimers:,p1info,%PlanterName1% in %PlanterField1%:
	GuiControl,ptimers:,p2info,%PlanterName2% in %PlanterField2%:
	GuiControl,ptimers:,p3info,%PlanterName3% in %PlanterField3%:
	loop, 3{
		if (p%A_Index%hours<0 || p%A_Index%mins<0 || p%A_Index%secs<0) {
			p%A_Index%timerstring:="Ready"
		} else if (p%A_Index%hours>100){
			p%A_Index%timerstring:="-----"
		} else {
			p%A_Index%timerstring:=""
			if (p%A_Index%hours>0)
				p%A_Index%timerstring:=p%A_Index%timerstring . p%A_Index%hours . "h "
			if (p%A_Index%mins>0 || (p%A_Index%mins=0 && p%A_Index%hours>0))
				p%A_Index%timerstring:=p%A_Index%timerstring . p%A_Index%mins . "m "
			if (p%A_Index%secs>0 || (p%A_Index%secs=0 && p%A_Index%mins>0))
				p%A_Index%timerstring:=p%A_Index%timerstring . p%A_Index%secs . "s"
		}
	}
	loop, 3 {
		p%A_Index%nectar:=""
		if(PlanterNectar%A_Index%="Comforting")
			p%A_Index%nectar:="COM"
		if(PlanterNectar%A_Index%="Motivating")
			p%A_Index%nectar:="MOT"
		if(PlanterNectar%A_Index%="Satisfying")
			p%A_Index%nectar:="SAT"
		if(PlanterNectar%A_Index%="Refreshing")
			p%A_Index%nectar:="REF"
		if(PlanterNectar%A_Index%="Invigorating")
			p%A_Index%nectar:="INV"
	}
	if (A_Min>=0 && A_Min<15)
		mondoTimeString:="Now"
	else {
		if(A_Min!=0)
			mondoTimeString:=(60-A_Min)-1 . "m " (60-A_Sec) . "s"
		else
			mondoTimeString:=(60-A_Sec)-1 . "s"
	}
	if ((A_Min>=15 && A_Min<20) || (A_Min>=45 && A_Min<50))
		puffTimeString:="Now"
	else {
		puffTimeString:=30-mod(A_Min+15, 30)-1 . "m " . (60-A_Sec) . "s"
	}
	if (mondoTimeString="Now") {
		guicontrol, ptimers:hide, mondoTimerB
		guicontrol, ptimers:show, mondoTimerR
	} else {
		guicontrol, ptimers:show, mondoTimerB
		guicontrol, ptimers:hide, mondoTimerR
	}
	if (puffTimeString="Now") {
		guicontrol, ptimers:hide, puffTimerB
		guicontrol, ptimers:show, puffTimerR
	} else {
		guicontrol, ptimers:show, puffTimerB
		guicontrol, ptimers:hide, puffTimerR
	}
	GuiControl,ptimers:,p1timer,%p1timerstring%
	GuiControl,ptimers:,p2timer,%p2timerstring%
	GuiControl,ptimers:,p3timer,%p3timerstring%
	GuiControl,ptimers:,p1nectar,%p1nectar%
	GuiControl,ptimers:,p2nectar,%p2nectar%
	GuiControl,ptimers:,p3nectar,%p3nectar%
	GuiControl,ptimers:,timeOfDay,% A_Hour . ":" . A_Min . ":" . A_Sec
	GuiControl,ptimers:,mondoTimerB,%mondoTimeString%
	GuiControl,ptimers:,puffTimerB,%puffTimeString%
	GuiControl,ptimers:,mondoTimerR,%mondoTimeString%
	GuiControl,ptimers:,puffTimerR,%puffTimeString%
	GuiControl,ptimers:,pstatus,%val%
	
	sleep, 1000
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
	if(fileexist("ba_config.ini"))
		IniWrite, %TimerGuiTransparency%, ba_config.ini, gui, TimerGuiTransparency
}
ba_resetPlanterTimer1(){
	PlanterHarvestTime1 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime1
	IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime1
	IniRead, PlanterHarvestTime1, ba_config.ini, Planters, PlanterHarvestTime1
}
ba_resetPlanterTimer2(){
	PlanterHarvestTime2 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime2
	IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime2
	IniRead, PlanterHarvestTime2, ba_config.ini, Planters, PlanterHarvestTime2
}
ba_resetPlanterTimer3(){
	PlanterHarvestTime3 := toUnix_()-1
	PlanterHarvestTimeN:=PlanterHarvestTime3
	IniWrite, %PlanterHarvestTimeN%, ba_config.ini, Planters, PlanterHarvestTime3
	IniRead, PlanterHarvestTime3, ba_config.ini, Planters, PlanterHarvestTime3
}
ba_resetPlanterData1(){
	;save changes
	IniWrite, "None", ba_config.ini, Planters, PlanterName1
	IniWrite, "None", ba_config.ini, Planters, PlanterField1
	IniWrite, "None", ba_config.ini, Planters, PlanterNectar1
	IniWrite, 20211106000000, ba_config.ini, Planters, PlanterHarvestTime1
	IniWrite, 0, ba_config.ini, Planters, PlanterEstPercent1
	;readback ini values
	IniRead, PlanterName1, ba_config.ini, Planters, PlanterName1
	IniRead, PlanterField1, ba_config.ini, Planters, PlanterField1
	IniRead, PlanterNectar1, ba_config.ini, Planters, PlanterNectar1
	IniRead, PlanterHarvestTime1, ba_config.ini, Planters, PlanterHarvestTime1
	IniRead, PlanterEstPercent1, ba_config.ini, Planters, PlanterEstPercent1
}
ba_resetPlanterData2(){
	;save changes
	IniWrite, "None", ba_config.ini, Planters, PlanterName2
	IniWrite, "None", ba_config.ini, Planters, PlanterField2
	IniWrite, "None", ba_config.ini, Planters, PlanterNectar2
	IniWrite, 20211106000000, ba_config.ini, Planters, PlanterHarvestTime2
	IniWrite, 0, ba_config.ini, Planters, PlanterEstPercent2
	;readback ini values
	IniRead, PlanterName2, ba_config.ini, Planters, PlanterName2
	IniRead, PlanterField2, ba_config.ini, Planters, PlanterField2
	IniRead, PlanterNectar2, ba_config.ini, Planters, PlanterNectar2
	IniRead, PlanterHarvestTime2, ba_config.ini, Planters, PlanterHarvestTime2
	IniRead, PlanterEstPercent2, ba_config.ini, Planters, PlanterEstPercent2
}
ba_resetPlanterData3(){
	;save changes
	IniWrite, "None", ba_config.ini, Planters, PlanterName3
	IniWrite, "None", ba_config.ini, Planters, PlanterField3
	IniWrite, "None", ba_config.ini, Planters, PlanterNectar3
	IniWrite, 20211106000000, ba_config.ini, Planters, PlanterHarvestTime3
	IniWrite, 0, ba_config.ini, Planters, PlanterEstPercent3
	;readback ini values
	IniRead, PlanterName3, ba_config.ini, Planters, PlanterName3
	IniRead, PlanterField3, ba_config.ini, Planters, PlanterField3
	IniRead, PlanterNectar3, ba_config.ini, Planters, PlanterNectar3
	IniRead, PlanterHarvestTime3, ba_config.ini, Planters, PlanterHarvestTime3
	IniRead, PlanterEstPercent3, ba_config.ini, Planters, PlanterEstPercent3
}
ba_saveTimerGui(){
	global TimerX
	global TimerY
	global TimerW
	global TimerH
	global TimerGuiTransparency
	WinGetPos, windowX, windowY, windowWidth, windowHeight, Timers
	;msgbox X=%TimerX% y=%TimerY% W=%TimerW% H=%TimerH%`nX=%windowX% y=%windowY% W=%windowWidth% H=%windowHeight%
	if(fileexist("ba_config.ini")){
		if (windowX > 0)
			IniWrite, %windowX%, ba_config.ini, gui, TimerX
		if (windowY > 0)
			IniWrite, %windowY%, ba_config.ini, gui, TimerY
		;if (windowWidth > 0)
		;    IniWrite, %windowWidth%, ba_config.ini, gui, TimerW
		;if (windowHeight > 0)
		;    IniWrite, %windowHeight%, ba_config.ini, gui, TimerH
		IniWrite, %TimerGuiTransparency%, ba_config.ini, gui, TimerGuiTransparency
	}
}
ba_timersExit(){
	ba_saveTimerGui()
	ExitApp
}

PtimersGuiClose:
ba_timersExit()
return
PtimersGuiSize:
ba_saveTimerGui()
return