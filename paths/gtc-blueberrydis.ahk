if (MoveMethod = "walk")
{
	paths["blueberrydis"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(88.875, BackKey, LeftKey) "
	" nm_Walk(27, LeftKey) "
	send {" RotLeft " 2}
	" nm_Walk(14, LeftKey) "
	" nm_Walk(26, FwdKey) "
	" nm_Walk(5, BackKey) "	
	" nm_Walk(7.5, RightKey) "
	" nm_Walk(9, FwdKey) "
	" nm_Walk(14, FwdKey, RightKey) "
	)"
}
else
{
	paths["blueberrydis"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" LeftKey " down}
	HyperSleep(700)
	send {space 2}
	HyperSleep(4450)
	send {" LeftKey " up}{space}
	HyperSleep(1000)
	send {" RotLeft " 2}
	" nm_Walk(19, LeftKey) "
	" nm_Walk(17, FwdKey) "
	" nm_Walk(5, BackKey) "	
	" nm_Walk(7.5, RightKey) "
	" nm_Walk(9, FwdKey) "
	" nm_Walk(14, FwdKey, RightKey) "
	)"
}