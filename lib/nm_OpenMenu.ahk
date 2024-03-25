nm_OpenMenu(tab:="", refresh:=0){
	global bitmaps
	static x := Map("itemmenu",30, "questlog",85, "beemenu",140, "badgelist",195, "settingsmenu",250, "shopmenu",305), open:=""

	if (hwnd := GetRobloxHWND())
		ActivateRoblox()
	else
		return 0
	offsetY := GetYOffset(hwnd)

	if ((tab = "") || (refresh = 1)) ; close
	{
		if open ; close the open tab
		{
			Loop 10
			{
				GetRobloxClientPos(hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " windowX+x[open] " " windowY+offsetY+120 " 0}"
				Click
				SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
				sleep 500
			}
		}
		else ; close any open tab
		{
			for k,v in x
			{
				Loop 10
				{
					GetRobloxClientPos(hwnd)
					pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
					if (Gdip_ImageSearch(pBMScreen, bitmaps[k], , , , , , 2) != 1) {
						Gdip_DisposeImage(pBMScreen)
						break
					}
					Gdip_DisposeImage(pBMScreen)
					SendEvent "{Click " windowX+v " " windowY+offsetY+120 " 0}"
					Click
					SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
					sleep 500
				}
			}
			open := ""
		}
	}
	else
	{
		if ((tab != open) && open) ; close the open tab
		{
			Loop 10
			{
				GetRobloxClientPos(hwnd)
				pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
				if (Gdip_ImageSearch(pBMScreen, bitmaps[open], , , , , , 2) != 1) {
					Gdip_DisposeImage(pBMScreen)
					open := ""
					break
				}
				Gdip_DisposeImage(pBMScreen)
				SendEvent "{Click " windowX+x[open] " " windowY+offsetY+120 " 0}"
				Click
				SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
				sleep 500
			}
		}
		; open the desired tab
		Loop 10
		{
			GetRobloxClientPos(hwnd)
			pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY+offsetY+72 "|350|80")
			if (Gdip_ImageSearch(pBMScreen, bitmaps[tab], , , , , , 2) = 1) {
				Gdip_DisposeImage(pBMScreen)
				open := tab
				break
			}
			Gdip_DisposeImage(pBMScreen)
			SendEvent "{Click " windowX+x[tab] " " windowY+offsetY+120 " 0}"
			Click
			SendEvent "{Click " windowX+350 " " windowY+offsetY+100 " 0}"
			sleep 500
		}
	}
}
