if (MoveMethod = "walk")
{
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
	nm_Walk(54, RightKey)
	nm_Walk(54, BackKey)
	nm_Walk(58.5, RightKey)
	nm_Walk(3, LeftKey)
	nm_Walk(57, FwdKey)
	nm_Walk(16, LeftKey)
	nm_Walk(3, FwdKey)
	nm_Walk(8, LeftKey)
	nm_Walk(2, RightKey)
	nm_Walk(13, FwdKey)
	send "{" RotLeft " 2}"
	nm_Walk(1.5, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(8.5, FwdKey)
	nm_Walk(3, LeftKey)
	nm_Walk(20, FwdKey)
	Sleep 500
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" LeftKey " down}{" BackKey " down}"
	HyperSleep(1400)
	send "{space 2}"
	HyperSleep(1100)
	send "{" LeftKey " up}"
	HyperSleep(650)
	send "{" BackKey " up}{space}{" RotRight " 4}"
	Sleep 1500
	nm_Walk(4, RightKey, FwdKey)
	nm_Walk(23, FwdKey)
	nm_Walk(9, LeftKey)
	nm_Walk(3, FwdKey)
	nm_Walk(8, LeftKey)
	nm_Walk(2, RightKey)
	nm_Walk(13, FwdKey)
	send "{" RotLeft " 2}"
	nm_Walk(1.5, FwdKey)
	send "{space down}"
	HyperSleep(100)
	send "{space up}"
	nm_Walk(8.5, FwdKey)
	nm_Walk(3, LeftKey)
	nm_Walk(20, FwdKey)
	Sleep 500
}
;path 230629 noobyguy | 230909 reverted cannon path -noobyguy
