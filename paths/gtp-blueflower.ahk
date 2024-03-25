if (MoveMethod = "walk" ) {
	nm_gotoramp()
	nm_Walk(88.875, BackKey, LeftKey)
	nm_Walk(27, LeftKey)
	HyperSleep(50)
	send "{" RotLeft " 2}"
	nm_Walk(17, FwdKey) 
	nm_Walk(17, LeftKey)
	nm_Walk(18, FwdKey)
	nm_Walk(10, BackKey)
	nm_Walk(7, BackKey, RightKey)
}
else {
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
	nm_Walk(19, LeftKey)
	nm_Walk(18, FwdKey)
	nm_Walk(10, BackKey)
	nm_Walk(7, BackKey, RightKey)
}
;path 230729 noobyguy
