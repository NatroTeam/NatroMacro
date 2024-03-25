if (MoveMethod = "walk")
{
	switch HiveSlot
	{
		case 2:
			nm_gotoramp()
			nm_Walk(41, BackKey, LeftKey)
			nm_Walk(48, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)

		case 3:
			nm_Walk(36, BackKey, LeftKey)
			nm_Walk(22, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)

		case 4:
			nm_Walk(9, LeftKey)
			nm_Walk(23, BackKey)
			nm_Walk(30, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)

		case 5:
			nm_Walk(23, BackKey)
			nm_Walk(30, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)

		case 6:
			nm_Walk(8, RightKey)
			nm_Walk(23, BackKey)
			nm_Walk(30, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)

		default:
			nm_gotoramp()
			nm_Walk(41, LeftKey, BackKey)
			nm_Walk(48, LeftKey)
			nm_Walk(10, FwdKey)
			nm_Walk(1, RightKey)
			nm_Walk(6, BackKey)
	}
	
	HyperSleep(800)
	send "{space down}{" LeftKey " down}"
	HyperSleep(250)
	send "{space up}"
	Walk(17)
	send "{" LeftKey " up}"
	HyperSleep(800)
	send "{space down}{" LeftKey " down}"
	HyperSleep(250)
	send "{space up}"
	Walk(40)
	Send "{" LeftKey " up}"
	nm_Walk(8, FwdKey)
	HyperSleep(250)
	send "{space down}{" LeftKey " down}"
	HyperSleep(150)
	send "{space up}"
	Walk(15)
	Send "{" LeftKey " up}"
	nm_Walk(16.5, BackKey)
	send "{" RotLeft " 4}{" FwdKey " down}"
	HyperSleep(150)
	send "{space down}"
	HyperSleep(300)
	send "{space up}"
	HyperSleep(300)
	send "{space down}"
	HyperSleep(500)
	send "{space up}"
	HyperSleep(500)
	Walk(9)
	Send "{" FwdKey " up}{" RotLeft " 2}"
	nm_Walk(3, FwdKey)
}
else
{
	nm_gotoramp()
	nm_gotocannon()
	send "{" RotLeft " 2}{e down}"
	HyperSleep(100)
	send "{e up}{" FwdKey " down}"
	HyperSleep(1250)
	send "{space 2}"
	HyperSleep(2200)
	send "{" RightKey " down}"
	HyperSleep(2650)
	send "{space}{" FwdKey " up}{" RightKey " up}{" RotLeft " 4}"
	Sleep 1500
}
