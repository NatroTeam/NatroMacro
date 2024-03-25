if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(44.75, BackKey, LeftKey) ; 47.25
	nm_Walk(42.5, LeftKey)
	nm_Walk(8.5, BackKey)
	nm_Walk(22.5, LeftKey)
	send "{" RotLeft " 2}"
	nm_Walk(40, FwdKey)
	nm_Walk(3, BackKey)
	nm_Walk(7, RightKey) ; 2.25
	send "{" FwdKey " down}"
	Walk(3)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	Walk(5)
	send "{" FwdKey " up}"
	nm_Walk(5, LeftKey)
	nm_Walk(4, FwdKey)
	nm_Walk(4, RightKey)
	nm_Walk(10, FwdKey)
	nm_Walk(4, BackKey)
	nm_Walk(3, LeftKey)	
	send "{" RotRight " 2}"
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	Send "{e down}"
	HyperSleep(100)
	Send "{e up}{" FwdKey " down}{" LeftKey " down}"
	HyperSleep(1500)
	send "{space 2}"
	Sleep 8000
	Send "{" FwdKey " up}{" LeftKey " up}"
	nm_Walk(15, BackKey)
	nm_Walk(3.5, RightKey)
	nm_Walk(2, RightKey, BackKey)
	nm_Walk(1, BackKey)
}
