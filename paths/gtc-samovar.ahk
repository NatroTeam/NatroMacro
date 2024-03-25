if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(67.5, BackKey, LeftKey)
	send "{" RotRight " 4}"
	nm_Walk(45, FwdKey)
	send "{" RotRight " 2}"
	nm_Walk(58.5, FwdKey)
	nm_Walk(18, RightKey)
	send "{" FwdKey " down}"
	HyperSleep(200)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	HyperSleep(800)
	send "{" FwdKey " up}{" RotLeft " 2}"
	nm_Walk(63, FwdKey)
	send "{" RotRight " 2}"
	nm_Walk(45, FwdKey)
	send "{" RotLeft " 2}"
	nm_Walk(27, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(3, FwdKey)
	nm_Walk(10, FwdKey, RightKey)
	nm_Walk(8, FwdKey, LeftKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(3.5, FwdKey, LeftKey)
	send "{" RotRight " 1}"
	nm_Walk(3, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(6, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{" RotLeft " 2}{e down}"
	HyperSleep(100)
	send "{e up}{" FwdKey " down}"
	HyperSleep(2000)
	send "{space 2}"
	HyperSleep(2800)
	send "{" LeftKey " down}"
	HyperSleep(900)
	send "{" LeftKey " up}"
	HyperSleep(1000)
	send "{" FwdKey " up}"
	HyperSleep(650)
	send "{space}"
	HyperSleep(1000)
	send "{" RotLeft " 2}"
	nm_Walk(36, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(3, FwdKey)
	nm_Walk(10, FwdKey, RightKey)
	nm_Walk(8, FwdKey, LeftKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(3.5, FwdKey, LeftKey)
	send "{" RotRight " 1}"
	nm_Walk(3, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(6, FwdKey)
}
