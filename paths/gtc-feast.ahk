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
	nm_Walk(3.375, LeftKey)
	nm_Walk(36, FwdKey)
	nm_Walk(60, RightKey)
	nm_Walk(60, BackKey)
	nm_Walk(9, LeftKey)
	nm_Walk(3.5, FwdKey, RightKey)
	nm_Walk(8.5, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{" RotLeft " 4}"
	HyperSleep(100)
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" FwdKey " down}"
	HyperSleep(760)
	send "{space 2}"
	HyperSleep(2100)
	send "{" LeftKey " down}"
	HyperSleep(100)	
	send "{space}{" FwdKey " up}{" LeftKey " up}"
	nm_Walk(10, LeftKey)
	nm_Walk(6, FwdKey)	
	nm_Walk(2.2, RightKey)
	nm_Walk(2, FwdKey)
}
Send "{space down}"
HyperSleep(100)
Send "{space up}"
nm_Walk(5, FwdKey)
Sleep 1000
