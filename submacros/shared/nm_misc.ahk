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