#NoEnv
#SingleInstance force
;SetBatchLines -1

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

;run testmacro.ahk, .. ;this works!
;if WinExist("natro_macro.ahk  ahk_class AutoHotkey") {
;	;SendMessage, 0x4242, 40, 42
;	PostMessage, 0x4242, 40, 42
;}
;msgbox A_PtrSize=%A_PtrSize% A_IsUnicode=%A_IsUnicode%
fieldnames:=["PineTree", "Stump", "Bamboo", "BlueFlower", "MountainTop", "Cactus", "Coconut", "Pineapple", "Spider", "Pumpkin", "Dandelion", "Sunflower", "Clover", "Pepper", "Rose", "Strawberry", "Mushroom"]
CoordMode, Pixel, Relative
;CoordMode, Pixel, Screen
WinGetPos, windowX, windowY, windowWidth, windowHeight, Roblox
DetectHiddenWindows On
SetTitleMatchMode 2
imgfolder:="..\nm_image_assets"
;lower right
xi:=windowWidth/2
yi:=windowHeight/2
while 1 {
	GSfound:=0
	ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_icon1.png
	if(ErrorLevel=0){
		GSfound:=1
	} else {
		ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_icon2.png
		if(ErrorLevel=0){
			GSfound:=1
		}
	}
	if(GSfound){
		for key, value in fieldnames {
			ImageSearch, FoundX, FoundY, %xi%, %yi%, %windowWidth%, %windowHeight%, *50 %imgfolder%\guiding_star_%value%.png
			if(ErrorLevel=0){
				if WinExist("natro_macro.ahk ahk_class AutoHotkey") {
					StringToSend:=value
					;set up string send
					VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area.
					SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
					NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; OS requires that this be done.
					NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself.
					;send the address to the string
					;SendMessage, 0x4242, 1, &CopyDataStruct
					SendMessage, 0x004A, 1, &CopyDataStruct
					sleep 10000
					break
				}
			}
		}
	}
	sleep 1000
}