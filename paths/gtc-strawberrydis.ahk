if (HiveBees > 25) {
    nm_gotoramp()
    Send "{space down}{" RightKey " down}"
    Sleep 100
    Send "{space up}"
    Walk(2)
    Send "{" FwdKey " down}"
    Walk(1.8)
    Send "{" FwdKey " up}"
    Walk(30)
    send "{" RightKey " up}{space down}"
    HyperSleep(300)
    send "{space up}"
    nm_Walk(6, RightKey)
    HyperSleep(500)
    send "{" RotRight " 2}"
    send "{space down}"
    HyperSleep(100)
    send "{space up}"
    nm_Walk(3, FwdKey)
    HyperSleep(1000)
    send "{space down}{" RightKey " down}"
    HyperSleep(100)
    send "{space up}"
    HyperSleep(300)
    send "{space}{" RightKey " up}"
    HyperSleep(1000)
    nm_Walk(7.5, Backkey, RightKey)
}
else {
    nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(31.5, FwdKey)
	nm_Walk(9, LeftKey)
	nm_Walk(9, BackKey)
	nm_Walk(58.5, LeftKey)
	nm_Walk(49.5, FwdKey)
	nm_Walk(20.25, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(60.75, FwdKey)
	send "{" RotRight " 2}"
	nm_Walk(9, BackKey)
	nm_Walk(15.75, BackKey, RightKey)
	nm_Walk(30, LeftKey)
	nm_Walk(36, FwdKey)
	nm_Walk(28, LeftKey)
	nm_Walk(5, RightKey)
	nm_Walk(3.5, BackKey)
	nm_Walk(23.5, LeftKey)
	nm_Walk(3, BackKey)
	nm_Walk(10, RightKey)
	nm_Walk(3, LeftKey)
	nm_Walk(8, BackKey)
}
;dual path 230629 noobyguy
