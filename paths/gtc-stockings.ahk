switch HiveSlot
{
	case 3:
		paths["stockings"] := "
		(LTrim Join`r`n
		" nm_Walk(36, BackKey, LeftKey) "
		" nm_Walk(22, LeftKey) "
		" nm_Walk(10, FwdKey) "
		" nm_Walk(1, RightKey) "
		" nm_Walk(6, BackKey) "
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(17)
		send {" LeftKey " up}
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(32.5)
		Send {" LeftKey " up}
		)"

	case 4:
		paths["stockings"] := "
		(LTrim Join`r`n
		" nm_Walk(9, LeftKey) "
		" nm_Walk(23, BackKey) "
		" nm_Walk(30, LeftKey) "
		" nm_Walk(10, FwdKey) "
		" nm_Walk(1, RightKey) "
		" nm_Walk(6, BackKey) "
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(17)
		send {" LeftKey " up}
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(32.5)
		Send {" LeftKey " up}
		)"

	case 5:
		paths["stockings"] := "
		(LTrim Join`r`n
		" nm_Walk(23, BackKey) "
		" nm_Walk(30, LeftKey) "
		" nm_Walk(10, FwdKey) "
		" nm_Walk(1, RightKey) "
		" nm_Walk(6, BackKey) "
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(17)
		send {" LeftKey " up}
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(32.5)
		Send {" LeftKey " up}
		)"

	case 6:
		paths["stockings"] := "
		(LTrim Join`r`n
		" nm_Walk(8, RightKey) "
		" nm_Walk(23, BackKey) "
		" nm_Walk(30, LeftKey) "
		" nm_Walk(10, FwdKey) "
		" nm_Walk(1, RightKey) "
		" nm_Walk(6, BackKey) "
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(17)
		send {" LeftKey " up}
		HyperSleep(800)
		send {space down}{" LeftKey " down}
		HyperSleep(250)
		send {space up}
		Walk(32.5)
		Send {" LeftKey " up}
		)"

	default:
		paths["stockings"] := "
		(LTrim Join`r`n
		;gotoramp
		;gotocannon
		send {e down}
		HyperSleep(100)
		send {e up}{" LeftKey " down}{" FwdKey " down}
		HyperSleep(1200)
		send {space 2}
		HyperSleep(5000)
		send {" FwdKey " up}{" LeftKey " up}{space}
		Sleep, 1500
		)"
}