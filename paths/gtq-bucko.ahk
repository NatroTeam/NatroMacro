if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(88.875, BackKey, LeftKey)
	nm_Walk(27, LeftKey)
	HyperSleep(50)
	send "{" RotLeft " 2}"
	HyperSleep(50)
	nm_Walk(50, FwdKey)
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
	nm_Walk(4, BackKey, LeftKey)
	nm_Walk(8, FwdKey, LeftKey)
	nm_Walk(6, FwdKey)
	nm_Walk(5, BackKey)
	nm_Walk(8, RightKey)
	;inside
	nm_Walk(30, FwdKey)
}
send "{space down}"
HyperSleep(100)
send "{space up}"
nm_Walk(6, FwdKey)
nm_Walk(5, RightKey)
nm_Walk(9, RightKey, BackKey)
nm_Walk(4, RightKey)
nm_Walk(2, LeftKey)
nm_Walk(28, BackKey)
nm_Walk(1.75, FwdKey)
nm_Walk(9.5, LeftKey)
nm_Walk(6.5, FwdKey)
sleep 100
send "{space down}"
Hypersleep(300)
send "{space up}"
nm_Walk(5, FwdKey)
;path 230630 noobyguy
