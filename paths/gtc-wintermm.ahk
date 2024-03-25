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
	nm_Walk(2.25, BackKey, LeftKey)
	nm_Walk(36, LeftKey)
	send "{" RotLeft " 2}"
	send "{" FwdKey " down}"
	send "{space down}"
	HyperSleep(300)
	send "{space up}"
	HyperSleep(500)
	send "{" RotRight " 2}"
	HyperSleep(1000)
	send "{space down}"
	HyperSleep(300)
	send "{space up}"
	Walk(6)
	send "{" FwdKey " up}"
	nm_Walk(6, RightKey)
	nm_Walk(7, FwdKey)
	nm_Walk(6, LeftKey)
	nm_Walk(3, RightKey)
	nm_Walk(32, FwdKey)
	nm_Walk(8.5, BackKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" RightKey " down}{" BackKey " down}"
	HyperSleep(1150)
	send "{space 2}"
	HyperSleep(4050)
	send "{" BackKey " up}"
	HyperSleep(1000)
	send "{" RightKey " up}"
	Sleep 2200
	send "{" RotRight " 4}"
	nm_Walk(14, LeftKey)
	nm_Walk(4, FwdKey)
	nm_Walk(3, BackKey)
	nm_Walk(11, RightKey)
}
