if (MoveMethod = "walk")
{
	paths["gluedis"] := "
	(LTrim Join`r`n
	" nm_Walk(3, FwdKey) "
	" nm_Walk(52, LeftKey) "
	" nm_Walk(3, FwdKey) "
	send {" FwdKey " down}{space down}
	HyperSleep(300)
	send {space up}
	" nm_Walk(5, RightKey) "
	send {space down}
	HyperSleep(300)
	send {space up}{" FwdKey " up}
	HyperSleep(500)
	" nm_Walk(2, FwdKey) "
	" nm_Walk(15, RightKey) "
	" nm_Walk(6, FwdKey, RightKey) "
	" nm_Walk(7, FwdKey) "
	" nm_Walk(5, BackKey, LeftKey) "
	" nm_Walk(23, FwdKey) "
	" nm_Walk(12, LeftKey) "
	" nm_Walk(27, FwdKey, LeftKey) "
	" nm_Walk(20, LeftKey) "
	" nm_Walk(40, FwdKey) "
	send {" RotRight " 2}
	" nm_Walk(55, FwdKey) "
	" nm_Walk(10, LeftKey) "
	send {" RotRight " 2}
	" nm_Walk(5.79, FwdKey, RightKey) "
	" nm_Walk(39, FwdKey) "
	send {space down}
	Hypersleep(300)
	send {space up}
	" nm_Walk(6.36, FwdKey) "
	send {" RotLeft " 4}
	Sleep, 1500
	)"
}
else
{
	paths["gluedis"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" FwdKey " down}
	HyperSleep(1170)
	send {space 2}{" FwdKey " up}
	HyperSleep(6750)
	" nm_Walk(18, FwdKey) "
	" nm_Walk(6, LeftKey) "
	Sleep, 1500
	)"
}
;path 230630 noobyguy - walk updated