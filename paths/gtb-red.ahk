if (MoveMethod = "walk")
{
	paths["red"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(67.5, BackKey, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(31.5, FwdKey) "
	" nm_Walk(9, LeftKey) "
	" nm_Walk(9, BackKey) "
	" nm_Walk(58.5, LeftKey) "
	" nm_Walk(49.5, FwdKey) "
	" nm_Walk(20.25, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(60.75, FwdKey) "
	send {" RotRight " 2}
	" nm_Walk(9, BackKey) "
	" nm_Walk(15.75, BackKey, RightKey) "
	" nm_Walk(29.7, LeftKey) "
	" nm_Walk(11.25, FwdKey) "
	" nm_Walk(13.5, LeftKey) "
	)"
}
else
{
	paths["red"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" RightKey " down}
	HyperSleep(550)
	send {space 2}
	HyperSleep(2500)
	send {" RightKey " up}{space}{" RotLeft " 4}
	HyperSleep(1000)
	" nm_Walk(17, FwdKey) "
	" nm_Walk(10, RightKey) "
	" nm_Walk(8, FwdKey, RightKey) "
	" nm_Walk(8, FwdKey) "
	" nm_Walk(20, BackKey) "
	send {" RotRight " 4}
	" nm_Walk(22, FwdKey) "
	" nm_Walk(10, BackKey) "
	" nm_Walk(12, RightKey) "
	" nm_Walk(11.25, FwdKey) "
	)"
}