if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}"
    HyperSleep(1850)
    send "{space 2}"
    HyperSleep(2750)
    send "{" LeftKey " up}{" BackKey " down}"
    HyperSleep(1150)
    send "{" BackKey " up}{space}{" RotRight " 4}"
    Sleep 2000
} else {
    nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(30, FwdKey)
	nm_Walk(20, FwdKey, RightKey)
	send "{" RotRight " 2}"
	nm_Walk(43.5, FwdKey)
	nm_Walk(18, RightKey)
	nm_Walk(6, FwdKey)
	send "{" RotLeft " 2}"
	nm_Walk(65.5, FwdKey)
    nm_Walk(1.5, RightKey)
    ;path 230630 noobyguy
}
