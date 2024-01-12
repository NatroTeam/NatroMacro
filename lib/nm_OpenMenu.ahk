nm_OpenMenu(menu:="", refresh:=0){
	global bitmaps
	static x := {"itemmenu":30, "questlog":85, "beemenu":140, "badgelist":195, "settingsmenu":250, "shopmenu": 305}, open:=""

	if (hwnd := GetRobloxHWND())
		WinActivate, Roblox
	else
		return 0
	offsetY := GetYOffset(hwnd)

	if ((menu = "") || (refresh = 1)) ; close
	{
		if open ; close the open menu
		{
			Loop, 10
			{
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+offsetY+120
				Click
				MouseMove, windowX+350, windowY+offsetY+100
				sleep, 500
			}
		}
		else ; close any open menu
		{
			for k,v in x
			{
				Loop, 10
				{
					WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
					if (Gdip_ImageSearch(pBMScreen, bitmaps[k], , , , , , 2) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					MouseMove, windowX+v, windowY+offsetY+120
					Click
					MouseMove, windowX+350, windowY+offsetY+100
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
				WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				MouseMove, windowX+x[open], windowY+offsetY+120
				Click
				MouseMove, windowX+350, windowY+offsetY+100
				sleep, 500
			}
		}
		; open the desired menu
		Loop, 10
		{
			WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[menu], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				open := menu
				break
			}
			Gdip_DisposeImage(pBMScreen)
			MouseMove, windowX+x[menu], windowY+offsetY+120
			Click
			MouseMove, windowX+350, windowY+offsetY+100
			sleep, 500
		}
	}
}
