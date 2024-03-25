if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(88.875, BackKey, LeftKey)
	nm_Walk(27, LeftKey)
	HyperSleep(50)
	send "{" RotLeft " 2}"
	HyperSleep(50)
	nm_Walk(30, FwdKey)
	nm_Walk(11.5, FwdKey, RightKey)
	nm_Walk(2, RightKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" LeftKey " down}"
	HyperSleep(700)
	send "{space 2}"
	HyperSleep(4450)
	send "{" LeftKey " up}{space}"
	HyperSleep(1000)
	send "{" RotLeft " 2}"
	nm_Walk(10, LeftKey)
	nm_Walk(8, RightKey)
	;inside
	nm_Walk(10, FwdKey)
	send "{" RotRight " 1}"
	HyperSleep(100)
	nm_Walk(1.6, FwdKey)
	send "{FwdKey down}{space down}"
	HyperSleep(300)
	send "{space up}"
	send "{space}"
	HyperSleep(1300)
}
;path 230629 noobyguy