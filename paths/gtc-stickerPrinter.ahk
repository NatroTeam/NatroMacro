if (MoveMethod = "walk")
{
	paths["sticker"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(44.75, BackKey, LeftKey) " ; 47.25
	" nm_Walk(52.5, LeftKey) "
	" nm_Walk(2.8, BackKey, RightKey) "
	" nm_Walk(6.7, BackKey)"
	" nm_Walk(40.5, LeftKey) "
	" nm_Walk(5, BackKey) "
	send {" RotRight " 2}
	)"
}
else
{
	paths["stickerPrinter"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}
	Sleep, 4000
	" nm_Walk(31, LeftKey) "
	Sleep, 200
	send {s down}
	Sleep, 300
	send {s up}
	)"
}
;path idkwhatimdoing money_mountain