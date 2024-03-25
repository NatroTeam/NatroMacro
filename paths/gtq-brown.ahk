if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(44.75, BackKey, LeftKey)
	nm_Walk(42.5, LeftKey)
	nm_Walk(8.5, BackKey)
	nm_Walk(22.5, LeftKey)
	send "{" RotLeft " 2}"
	nm_Walk(40, FwdKey)
	nm_Walk(1.2, BackKey)
	nm_Walk(15, RightKey)
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
	nm_Walk(20, RightKey)
	nm_Walk(8, LeftKey)
	nm_Walk(3, RightKey, BackKey)
	nm_Walk(2, BackKey)
}
