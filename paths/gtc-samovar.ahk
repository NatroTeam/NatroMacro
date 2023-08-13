if (MoveMethod = "walk")
{
	paths["samovar"] := "
	(LTrim Join`r`n
	;gotoramp
	" nm_Walk(67.5, BackKey, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(45, FwdKey) "
	send {" RotRight " 2}
	" nm_Walk(58.5, FwdKey) "
	" nm_Walk(18, RightKey) "
	send {" FwdKey " down}
	HyperSleep(200)
	send {space down}
	HyperSleep(100)
	send {space up}
	HyperSleep(800)
	send {" FwdKey " up}{" RotLeft " 2}
	" nm_Walk(63, FwdKey) "
	send {" RotRight " 2}
	" nm_Walk(45, FwdKey) "
	" nm_Walk(9, RightKey) "
	send {" RotLeft " 2}{" FwdKey " down}
	Walk(45)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(3)
	send {" RightKey " down}
	Walk(14)
	send {" RightKey " up}{" LeftKey " down}
	Walk(8)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(2)
	send {" LeftKey " up}{" RotRight " 1}
	HyperSleep(1200)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(7)
	send {" FwdKey " up}
	)"
}
else
{
	paths["samovar"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	HyperSleep(300)
	send {" RotLeft " 2}
	HyperSleep(300)
	send {e down}
	HyperSleep(100)
	send {e up}{" FwdKey " down}
	HyperSleep(2000)
	send {space 2}
	HyperSleep(2800)
	send {" FwdKey " down}{" LeftKey " down}
	HyperSleep(900)
	send {" LeftKey " up}
	HyperSleep(1650)
	send {" FwdKey " up}{space}
	HyperSleep(1000)
	send {" RotLeft " 2}{" FwdKey " down}
	Walk(45)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(3)
	send {" RightKey " down}
	Walk(14)
	send {" RightKey " up}{" LeftKey " down}
	Walk(8)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(2)
	send {" LeftKey " up}{" RotRight " 1}
	HyperSleep(1200)
	send {space down}
	HyperSleep(150)
	send {space up}
	Walk(7)
	send {" FwdKey " up}
	)"
}