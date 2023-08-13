if (MoveMethod = "walk")
{
	paths["coconutdis"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {" RightKey " down}
	Walk(22.5)
	send {space down}
	HyperSleep(200)
	send {space up}
	Walk(2.25)
	send {" FwdKey " down}
	Walk(1.8)
	send {" FwdKey " up}
	Walk(3.375)
	send {space down}
	HyperSleep(200)
	send {space up}
	Walk(4.5)
	send {" RightKey " up}{" FwdKey " down}
	send {space down}
	HyperSleep(100)
	send {space up}
	Walk(0.9)
	send {" RightKey " down}
	Walk(22.5)
	send {" FwdKey " up}
	Walk(4.5)
	send {space down}
	HyperSleep(100)
	send {space up}
	HyperSleep(800)
	send {" RightKey " up}{" FwdKey " down}{" LeftKey " down}{space down}
	HyperSleep(100)
	send {space up}
	Walk(15.75)
	send {" FwdKey " up}
	Walk(4.5)
	send {space down}
	HyperSleep(100)
	send {space up}
	Walk(27)
	send {" LeftKey " up}
	" nm_Walk(18, FwdKey, LeftKey) "
	" nm_Walk(11.25, LeftKey) "
	" nm_Walk(18, FwdKey, RightKey) "
	" nm_Walk(3.375, BackKey, LeftKey) "
	)"
}
else
{
	paths["coconutdis"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	send {e down}
	HyperSleep(100)
	send {e up}{" FwdKey " down}
	HyperSleep(450)
	send {space 2}
	send {" RightKey " down}
	HyperSleep(3850)
	send {" RightKey " up}
	HyperSleep(2000)
	send {" RightKey " down}
	HyperSleep(2000)
	send {" RightKey " up}
	send {space down}
	HyperSleep(50)
	send {space up}
	HyperSleep(750)
	send {space down}
	HyperSleep(50)
	send {space up}
	HyperSleep(750)
	send {space down}
	HyperSleep(50)
	send {space up}
	Walk(3000*9/2000)
	send {" FwdKey " up}{" LeftKey " down}
	Walk(3000*9/2000)
	send {" LeftKey " up}
	" nm_Walk(18, FwdKey, LeftKey) "
	" nm_Walk(11.25, LeftKey) "
	" nm_Walk(18, FwdKey, RightKey) "
	" nm_Walk(3.375, BackKey, LeftKey) "
	)"
}