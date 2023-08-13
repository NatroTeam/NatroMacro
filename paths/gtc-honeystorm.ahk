if (MoveMethod = "walk")
{
	paths["honeystorm"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(47.25, BackKey, LeftKey) "
	" nm_Walk(40.5, LeftKey) "
	" nm_Walk(8.5, BackKey) "
	" nm_Walk(44, LeftKey) "
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
	HyperSleep(4950)
	send {" FwdKey " up}{" LeftKey " up}{space}
	Sleep, 1500
	" nm_Walk(2, BackKey, LeftKey) "
	" nm_Walk(16, BackKey) "
	send {" RotRight " 2}
	)"
}