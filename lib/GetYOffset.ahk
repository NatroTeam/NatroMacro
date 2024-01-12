GetYOffset(hwnd, ByRef fail:="")
{
	global bitmaps
	static hRoblox, offset := 0

	if (hwnd = hRoblox)
		return offset
	else
	{
		WinActivate, Roblox
		WinGetClientPos(windowX, windowY, windowWidth, windowHeight, "ahk_id " hwnd)
		pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")

		Loop, 20 ; for red vignette effect
		{ 
			if ((Gdip_ImageSearch(pBMScreen, bitmaps["toppollen"], pos, , , , , 20) = 1)
				&& (Gdip_ImageSearch(pBMScreen, bitmaps["toppollenfill"], , x := SubStr(pos, 1, (comma := InStr(pos, ",")) - 1), y := SubStr(pos, comma + 1), x + 41, y + 10, 20) = 0))
			{
				Gdip_DisposeImage(pBMScreen)
				hRoblox := hwnd
				return (offset := y - 14), (fail := 0)
			}
			else
			{
				if (A_Index = 20)
				{
					Gdip_DisposeImage(pBMScreen)
					return 0 ; default offset, change this if needed
						, (fail := 1)
				}
				else
				{
					Sleep, 50
					Gdip_DisposeImage(pBMScreen)
					pBMScreen := Gdip_BitmapFromScreen(windowX+windowWidth//2 "|" windowY "|60|100")
				}				
			}
		}
	}
}
