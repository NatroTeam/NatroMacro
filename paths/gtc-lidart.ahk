if (MoveMethod = "walk")
{
	paths["lidart"] := "
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
	" nm_Walk(54, RightKey) "
	" nm_Walk(54, BackKey) "
	" nm_Walk(58.5, RightKey) "
	" nm_Walk(57, FwdKey) "
	" nm_Walk(2, BackKey) "
	" nm_Walk(20, LeftKey) "
	" nm_Walk(4, LeftKey, FwdKey) "
	" nm_Walk(4, RightKey) "
	send {" FwdKey " down}{space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(15)
	send {" FwdKey " up}
	" nm_Walk(10, BackKey) "
	)"
}
else
{
	paths["lidart"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	HyperSleep(100)
	send {e down}
	HyperSleep(100)
	send {e up}{" LeftKey " down}{" BackKey " down}
	HyperSleep(1575)
	send {space 2}
	HyperSleep(1100)
	send {" LeftKey " up}
	HyperSleep(650)
	send {" BackKey " up}{space}{" RotRight " 4}
	HyperSleep(1500)
	" nm_Walk(4, RightKey, FwdKey) "
	" nm_Walk(25, FwdKey) "
	" nm_Walk(2, BackKey) "
	" nm_Walk(20, LeftKey) "
	" nm_Walk(4, LeftKey, FwdKey) "
	" nm_Walk(4, RightKey) "
	send {" FwdKey " down}{space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(10)
	send {space down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(300)
	send {space up}
	Walk(15)
	send {" FwdKey " up}
	" nm_Walk(10, BackKey) "
	)"
}