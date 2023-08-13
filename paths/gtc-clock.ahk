if (MoveMethod = "walk")
{
	paths["clock"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(47.25, BackKey, LeftKey) "
	" nm_Walk(40.5, LeftKey) "
	" nm_Walk(8.1, BackKey) "
	" nm_Walk(22.5, LeftKey) "
	send {" RotLeft " 2}
	" nm_Walk(27, FwdKey) "
	" nm_Walk(9, RightKey, FwdKey) "
	" nm_Walk(2.25, RightKey) "
	" nm_Walk(4, FwdKey) "
	" nm_Walk(5.625, LeftKey) "
	" nm_Walk(10.125, FwdKey) "
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
	Send {e up}{" LeftKey " down}{" FwdKey " down}
	HyperSleep(850)
	send {space 2}
	HyperSleep(2475)
	send {" FwdKey " up}
	HyperSleep(500)
	send {" LeftKey " up}
	HyperSleep(3500)
	send {space}
	HyperSleep(1000)
	send {" LeftKey " down}
	HyperSleep(1000)
	send {" LeftKey " up}
	)"
}