if (MoveMethod = "walk")
{
	paths["candles"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	HyperSleep(900)
	Send {" RightKey " down}
	Walk(17)
	Send {" RightKey " up}
	HyperSleep(800)
	send {space down}{" RightKey " down}
	HyperSleep(200)
	send {space up}
	Walk(6)
	Send {" RightKey " up}{" RotRight " 2}
	HyperSleep(1100)
	send {space down}{" FwdKey " down}
	HyperSleep(200)
	send {space up}
	Walk(3)
	Send {" FwdKey " up}
	HyperSleep(1000)
	send {space down}{" RightKey " down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(500)
	send {space up}
	HyperSleep(500)
	send {" RightKey " up}
	" nm_Walk(1, RightKey) "
	" nm_Walk(14, FwdKey) "
	)"
}
else
{
	paths["candles"] := "
	(LTrim Join`r`n
	;gotoramp
	;gotocannon
	HyperSleep(900)
	Send {" RightKey " down}
	Walk(17)
	Send {" RightKey " up}
	HyperSleep(800)
	send {space down}{" RightKey " down}
	HyperSleep(200)
	send {space up}
	Walk(6)
	Send {" RightKey " up}{" RotRight " 2}
	HyperSleep(1100)
	send {space down}{" FwdKey " down}
	HyperSleep(200)
	send {space up}
	Walk(3)
	Send {" FwdKey " up}
	HyperSleep(1000)
	send {space down}{" RightKey " down}
	HyperSleep(300)
	send {space up}
	HyperSleep(300)
	send {space down}
	HyperSleep(500)
	send {space up}
	HyperSleep(500)
	send {" RightKey " up}
	" nm_Walk(1, RightKey) "
	" nm_Walk(14, FwdKey) "
	)"
}