if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(69, BackKey, LeftKey)
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
	nm_Walk(15, FwdKey, LeftKey)
	nm_Walk(8, LeftKey)
	nm_Walk(15, FwdKey, LeftKey)
	nm_Walk(3.5, RightKey)
	nm_Walk(11, BackKey)
	send "{" RotLeft " 2}"
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}"
	HyperSleep(2500)
	nm_Walk(30, FwdKey)
	nm_Walk(2, BackKey)
	nm_Walk(22, LeftKey)
	nm_Walk(12, RightKey)
	nm_Walk(3, LeftKey)
	nm_Walk(5, FwdKey)
	send "{" RotRight " 2}"
}
Sleep 1000
;path 230630 noobyguy - walk updated
;adjusted for memory match OAC
