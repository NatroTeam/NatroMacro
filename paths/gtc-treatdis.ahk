if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(30, FwdKey)
	nm_Walk(20, FwdKey, RightKey)
	send "{" RotRight " 2}"
	nm_Walk(43.5, FwdKey)
	nm_Walk(16, RightKey)
	send "{" FwdKey " down}"
	HyperSleep(200)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	HyperSleep(800)
	send "{" FwdKey " up}{" RotLeft " 2}"
	nm_Walk(29.25, FwdKey)
	nm_Walk(17, FwdKey, LeftKey)
	nm_Walk(3, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" LeftKey " down}"
	HyperSleep(1810)
	send "{space 2}"
	HyperSleep(1925)
	send "{" LeftKey " up}{space}{" RotRight " 4}"
	Sleep 1500
}
;path 230630 noobyguy - walk updated
