if (MoveMethod = "walk")
{
	paths["riley"] := "
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
	" nm_Walk(30.6, LeftKey) "
	" nm_Walk(23.85, FwdKey) "
	" nm_Walk(22.95, LeftKey) "
	" nm_Walk(6.6375, BackKey) "
	" nm_Walk(20.25, RightKey) "
	" nm_Walk(4.5, FwdKey) "
	send {" FwdKey " down}
	HyperSleep(200)
	send {space down}
	HyperSleep(200)
	send {space up}{" FwdKey " up}
	HyperSleep(800)
	" nm_Walk(2, FwdKey) "
	)"
}
else
{
	paths["riley"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" FwdKey " down}{" RightKey " down}
	HyperSleep(600)
	send {space 2}
	HyperSleep(1800)
	send {" FwdKey " up}
	HyperSleep(2250)
	send {" RightKey " up}{space}{" RotRight " 2}
	HyperSleep(1500)
	)"
}