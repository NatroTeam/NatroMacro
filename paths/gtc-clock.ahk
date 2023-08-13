if (MoveMethod = "walk")
{
	paths["clock"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(47.25, BackKey, LeftKey) "
	" nm_Walk(40.5, LeftKey) "
	" nm_Walk(8.5, BackKey) "
	" nm_Walk(22.5, LeftKey) "
	send {" RotLeft " 2}
	" nm_Walk(27, FwdKey) "
	" nm_Walk(9, RightKey, FwdKey) "
	" nm_Walk(2.25, RightKey) "
	" nm_Walk(4, FwdKey) "
	" nm_Walk(5.625, LeftKey) "
	" nm_Walk(10.125, FwdKey) "
	send {" RotRight " 2}
	)"
}
else
{
	paths["clock"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	Send {e down}
	HyperSleep(100)
	Send {e up}{" FwdKey " down}{" LeftKey " down}
	HyperSleep(1500)
	send {space 2}
	Sleep 8000
	Send {" FwdKey " up}{" LeftKey " up}
	" nm_Walk(15, BackKey) "
	" nm_Walk(3.5, RightKey) "
	" nm_Walk(2, RightKey, BackKey) "
	" nm_Walk(1, BackKey) "
	)"
}