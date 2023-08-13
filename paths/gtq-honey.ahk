if (MoveMethod = "walk")
{
	paths["honey"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(67.5, BackKey, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(31.5, FwdKey) "
	" nm_Walk(9, LeftKey) "
	" nm_Walk(9, BackKey) "
	" nm_Walk(58.5, LeftKey) "
	" nm_Walk(49.5, FwdKey) "
	" nm_Walk(2.25, BackKey, LeftKey) "
	" nm_Walk(36, LeftKey) "
	send, {" LeftKey " down}
	HyperSleep(200)
	send, {space down}
	HyperSleep(200)
	send, {space up}
	HyperSleep(800)
	send, {" FwdKey " down}
	HyperSleep(200)
	send, {space down}
	HyperSleep(200)
	send, {space up}
	Walk(22.5)
	send, {" LeftKey " up}
	HyperSleep(200)
	send, {space down}
	HyperSleep(200)
	send, {space up}
	HyperSleep(800)
	send, {" FwdKey " up}
	" nm_Walk(14, FwdKey) "
	" nm_Walk(8.5, BackKey, RightKey) "
	)"
}
else
{
	paths["honey"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" RightKey " down}{" BackKey " down}
	HyperSleep(1150)
	send {space 2}
	HyperSleep(4050)
	send {" BackKey " up}
	HyperSleep(4000)
	send {" RightKey " up}{space}{" RotRight " 2}
	HyperSleep(200)
	send {space down}
	HyperSleep(100)
	send {space up}
	" nm_Walk(10.5, FwdKey) "
	)"
}