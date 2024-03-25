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
	nm_Walk(54, RightKey)
	nm_Walk(54, BackKey)
	nm_Walk(58.5, RightKey)
	nm_Walk(15.75, FwdKey, LeftKey)
	nm_Walk(13.5, FwdKey)
	send "{" RotRight " 4}"
	nm_Walk(27, RightKey)
	nm_Walk(18, BackKey)
	nm_Walk(27, RightKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}"
	Sleep 3000
	nm_Walk(40.5, RightKey)
}
