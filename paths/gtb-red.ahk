if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(31.5, FwdKey)
	nm_Walk(9, LeftKey)
	nm_Walk(9, BackKey)
	nm_Walk(58.5, LeftKey)
	nm_Walk(49.5, FwdKey)
	nm_Walk(20.25, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(60.75, FwdKey)
	send "{" RotRight " 2}"
	nm_Walk(9, BackKey)
	nm_Walk(15.75, BackKey, RightKey)
	nm_Walk(29.7, LeftKey)
	nm_Walk(11.25, FwdKey)
	nm_Walk(13.5, LeftKey)
}
else
{
	nm_gotoramp()
	Send "{space down}{" RightKey " down}"
	Sleep 100
	Send "{space up}"
	Walk(2)
	Send "{" FwdKey " down}"
	Walk(1.8)
	Send "{" FwdKey " up}"
	Walk(30)
	send "{space down}"
	HyperSleep(300)
	send "{space up}{" FwdKey " down}"
	Walk(4)
	send "{" FwdKey " up}"
	Walk(3)
	send "{" RightKey " up}{" RotRight " 2}{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(3, FwdKey)
	HyperSleep(1000)
	send "{space down}{" RightKey " down}"
	HyperSleep(100)
	send "{space up}"
	HyperSleep(300)
	send "{space}{" RightKey " up}"
	HyperSleep(1000)
	nm_Walk(8, FwdKey, RightKey)
	nm_Walk(1, FwdKey)
	nm_Walk(6.75, RightKey)
	HyperSleep(1000)
	send "{" RotRight " 4}"
	HyperSleep(100)
	nm_Walk(9, FwdKey)
	nm_Walk(3, FwdKey, LeftKey)
	nm_Walk(5, FwdKey, RightKey)
}
;path 230629 noobyguy
