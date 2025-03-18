if (MoveMethod = "walk"){
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
	nm_Walk(9, FwdKey)
}else{
	nm_gotoramp()
	nm_gotocannon()
	send "{" RotLeft " 4}"
	sleep 100
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" FwdKey " down}"
	HyperSleep(800)
	send "{" FwdKey " up}{space 2}"
	HyperSleep(2100)
	send "{space}"
	sleep 1000
	nm_Walk(7, BackKey, LeftKey)
	nm_Walk(9, LeftKey, FwdKey)
	nm_Walk(5, FwdKey)	
}
nm_Walk(5, BackKey)
nm_Walk(2, RightKey)
