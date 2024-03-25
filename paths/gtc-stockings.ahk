if (MoveMethod = "walk")
{
	nm_gotoramp()
	nm_Walk(47.25, BackKey, LeftKey)
	nm_Walk(40.5, LeftKey)
	nm_Walk(8.5, BackKey)
	nm_Walk(43, LeftKey)
	nm_Walk(13, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{e down}"
	HyperSleep(100)
	send "{e up}{" LeftKey " down}{" FwdKey " down}"
	HyperSleep(1180)
	send "{space 2}"
	HyperSleep(4950)
	send "{" FwdKey " up}{" LeftKey " up}{space}"
	Sleep 1500
}