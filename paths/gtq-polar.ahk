if (MoveMethod = "walk")
{
	paths["polar"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(67.5, BackKey, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(31.5, FwdKey) "
	" nm_Walk(9, LeftKey) "
	" nm_Walk(9, BackKey) "
	" nm_Walk(58.5, LeftKey) "
	" nm_Walk(49.5, FwdKey) "
	" nm_Walk(3.375, LeftKey) "
	" nm_Walk(36, FwdKey) "
	" nm_Walk(60, RightKey) "
	" nm_Walk(60, BackKey) "
	" nm_Walk(9, LeftKey) "
	" nm_Walk(3, FwdKey, RightKey) "
	)"
}
else
{
	paths["polar"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" RightKey " down}
	HyperSleep(1430)
	send {space 2}
	HyperSleep(1375)
	send {space}{" RightKey " up}{" RotLeft " 4}
	HyperSleep(2500)
	)"
}