if (MoveMethod = "cannon")
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" RightKey " down}"
	HyperSleep(1200)
	send "{space 2}"
	send "{" RightKey " up}"
	HyperSleep(6000)
	nm_Walk(7, RightKey)
	nm_Walk(11, BackKey)
	send "{space down}"
	nm_Walk(1.5, BackKey)
	send "{space up}"
	nm_Walk(1.5, BackKey)
	send "{space down}"
	nm_Walk(1.5, BackKey)
	send "{space up}"
	nm_Walk(2, BackKey)
	HyperSleep(2000)
}
else
{
	nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(31.5, FwdKey)
	nm_Walk(9, LeftKey)
	nm_Walk(9, BackKey)
	nm_Walk(58.5, LeftKey)
	nm_Walk(49.5, FwdKey)
	nm_Walk(2.25, BackKey, LeftKey)
	nm_Walk(36, LeftKey)
	send "{" RotLeft " 2}"
	send "{" FwdKey " down}"
	send "{space down}"
	HyperSleep(300)
	send "{space up}"
	HyperSleep(500)
	send "{" RotRight " 2}"
	HyperSleep(1000)
	send "{space down}"
	HyperSleep(300)
	send "{space up}"
	Walk(6)
	send "{" FwdKey " up}"
	nm_Walk(6, RightKey)
	nm_Walk(7, FwdKey)
	nm_Walk(6, LeftKey)
	nm_Walk(3, RightKey)
	nm_Walk(32, FwdKey)
	nm_Walk(4, BackKey)
    nm_Walk(8, LeftKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(4, LeftKey)
    Sleep 500
    send "{space down}"
	HyperSleep(100)
	send "{space up}"
    nm_Walk(6, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(12, FwdKey)
    send "{space down}"
	HyperSleep(100)
	send "{space up}"
    nm_Walk(14, FwdKey, LeftKey)
    nm_Walk(3, FwdKey)
}
