if (MoveMethod = "walk")
{
	paths["blue"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(88.875, BackKey, LeftKey) "
	" nm_Walk(27, LeftKey) "
	send {" RotLeft " 2}
	" nm_Walk(45, FwdKey) "
	send {" FwdKey " down}
	HyperSleep(200)
	send {space down}
	HyperSleep(200)
	send {space up}
	HyperSleep(500)
	send {" FwdKey " up}
	" nm_Walk(18, RightKey) "
	" nm_Walk(27, BackKey) "
	" nm_Walk(3.375, FwdKey, LeftKey) "
	" nm_Walk(18, LeftKey) "
	)"
}
else
{
	paths["blue"] := "
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
	" nm_Walk(4.5, RightKey) "
	" nm_Walk(6.75, FwdKey, RightKey) "
	" nm_Walk(4.5, RightKey) "
	" nm_Walk(2.25, BackKey, LeftKey) "
	" nm_Walk(6, LeftKey) "
	" nm_Walk(45, FwdKey) "
	send {" FwdKey " down}
	HyperSleep(200)
	send {space down}
	HyperSleep(200)
	send {space up}
	HyperSleep(500)
	send {" FwdKey " up}
	" nm_Walk(18, RightKey) "
	" nm_Walk(27, BackKey) "
	" nm_Walk(3.375, FwdKey, LeftKey) "
	" nm_Walk(18, LeftKey) "
	)"
}