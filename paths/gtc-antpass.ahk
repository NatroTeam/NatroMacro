if (MoveMethod = "walk")
{
	paths["antpass"] := "
	(LTrim Join`r`n
	" nm_Walk(50, LeftKey) "
	send {" FwdKey " down}
	HyperSleep(50)
	send {space down}
	HyperSleep(400)
	send {" FwdKey " up}{space up}
	HyperSleep(600)
	send {" FwdKey " down}{space down}
	HyperSleep(200)
	send {space up}
	HyperSleep(600)
	send {" FwdKey " up}
	" nm_Walk(0.5, FwdKey, RightKey) "
	" nm_Walk(31.5, FwdKey) "
	" nm_Walk(45, LeftKey) "
	" nm_Walk(6, RightKey) "
	)"
}
else
{
	paths["antpass"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" FwdKey " down}{" LeftKey " down}
	HyperSleep(1050)
	send {space 2}
	HyperSleep(1500)
	send {" LeftKey " up}
	HyperSleep(4300)
	send {" LeftKey " down}
	HyperSleep(1400)
	send {" FwdKey " up}{" LeftKey " up}
	send {space}
	HyperSleep(1400)
	" nm_Walk(5, BackKey, LeftKey) "
	)"
}