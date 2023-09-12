if (MoveMethod = "walk")
{
	paths["honeystorm"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(47.25, BackKey, LeftKey) "
	" nm_Walk(52.5, LeftKey) "
	" nm_Walk(2.2, BackKey, RightKey) "
	" nm_Walk(6.7, BackKey)"
	" nm_Walk(40.5, LeftKey) "
	" nm_Walk(5, BackKey) "
	send {" RotRight " 2}
	)"
}
else
{
	paths["honeystorm"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" LeftKey " down}{" FwdKey " down}
	HyperSleep(1180)
	send {space 2}
	HyperSleep(5000)
	send {" FwdKey " up}{" LeftKey " up}{space}
	Sleep, 1500
	" nm_Walk(10, FwdKey, LeftKey) "
	" nm_Walk(4, RightKey) "
	" nm_Walk(22.5, BackKey) "
	send {" RotRight " 2}
	)"
}
;path 230630 noobyguy