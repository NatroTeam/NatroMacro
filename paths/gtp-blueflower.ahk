if (MoveMethod = "walk" ) {
	nm_gotoramp()
	nm_Walk(88.875, BackKey, LeftKey)
	nm_Walk(27, LeftKey)
	HyperSleep(50)
	send "{" RotLeft " 2}"
	nm_Walk(15, FwdKey) 
	nm_Walk(20, LeftKey)
	nm_Walk(20, FwdKey)
	nm_Walk(10, BackKey)
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
	nm_Walk(20, LeftKey)
	nm_Walk(20, FwdKey)
	nm_Walk(10, BackKey)
}
;path 230729 noobyguy
; edited by Lorddrak