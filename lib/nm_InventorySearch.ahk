Scroll(direction:="Down", repeat:=1) {
	Loop repeat
	{
		SendInput "{Wheel" direction "}"
	}
}

; item: string of item
; direction: down or up
; prescroll: number of scrolls before direction switch
; prescrolldir: direction to prescroll, set blank for same as direction
; scrolltoend: set 0 to omit scrolling to top/bottom after prescrolls
; max: number of scrolls in total
nm_InventorySearch(item, direction:="down", prescroll:=0, prescrolldir:="", scrolltoend:=1, max:=70){
	global bitmaps
	static hRoblox:=0
	pos := 0
	scrollDir := ((A_Index <= prescroll && prescrolldir) ? ((prescrolldir = "Down") ? "Down" : "Up") : ((direction = "down") ? "Down" : "Up"))
	
	nm_OpenMenu("itemmenu")

	; Activate roblox window and get it's current position and height
	if (hwnd := GetRobloxHWND())
	{
		if (hwnd != hRoblox)
		{
			ActivateRoblox()
			GetRobloxClientPos(hwnd)
			hRoblox := hwnd
		}
	}
	else
		return 0 ; no roblox
	offsetY := GetYOffset(hwnd)

	; search inventory
	TopText := ""
	idx := 0
	Loop max
	{
		idx += 1
		ActivateRoblox()
		GetRobloxClientPos(hwnd)
		
		TextInRegion := findTextInRegion(item,, windowX, windowY, 360, windowHeight, true)
		
		TopEntry := ""
		if idx > 10 {
			for _, word in TextInRegion["Words"] {
				if word.BoundingRect.x > 100 && word.BoundingRect.h > 15 {
					TopEntry := word
					break
				}
			}
		}

		if TextInRegion.Has("Word") {
			word := TextInRegion["Word"]
			pos := [word.BoundingRect.x, word.BoundingRect.w, word.BoundingRect.y, word.BoundingRect.h]
			break ; item found
		} else if TopEntry && TopEntry.Text == TopText && TopText != "" {
			break ; at the top of inventory
		}
		if TopEntry {
			TopText := TopEntry.Text
		}
		
		switch A_Index
		{
			case (prescroll+1): ; scroll entire inventory on (prescroll+1)th search
			if (scrolltoend = 1)
			{
				Loop 10
				{
					SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
					Scroll(((direction = "down") ? "Up" : "Down"), 100)
					Sleep 50
				}
			}
			default: ; scroll once
			SendEvent "{Click " windowX+30 " " windowY+offsetY+200 " 0}"
			Scroll(scrollDir, 3)
			Sleep 50
		}
		Sleep 500 ; wait for scroll to finish
		
	}
	
	return pos ; return list of coordinates for dragging
}
