if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(44.75, BackKey, LeftKey) ; 47.25
	nm_Walk(52.5, LeftKey)
	nm_Walk(2.8, BackKey, RightKey)
	nm_Walk(6.7, BackKey)
	nm_Walk(40.5, LeftKey)
	nm_Walk(5, BackKey)
	send "{" RotRight " 2}"
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" LeftKey " down}{" FwdKey " down}"
	HyperSleep(1180)
	send "{space 2}"
	HyperSleep(5000)
	send "{" FwdKey " up}{" LeftKey " up}{space}"
	Sleep 1500
	nm_Walk(10, FwdKey, LeftKey)
	nm_Walk(10, BackKey)
	nm_Walk(7, BackKey, RightKey)
	nm_Walk(9, BackKey)
	send "{" RotRight " 2}"
}
Sleep 250
;path 230630 noobyguy
