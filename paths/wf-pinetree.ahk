If ((HiveBees < 25) || (MoveMethod = "Walk")) {
	paths["pine tree"] := "
	(LTrim Join`r`n
	" nm_Walk(31, FwdKey) "
	" nm_Walk(75, RightKey) "
	send {" RotLeft " 4}
	" nm_Walk(42, FwdKey) "
	" nm_Walk(6, FwdKey, RightKey) "
	" nm_Walk(4, RightKey) "
	send {" FwdKey " down}
	Walk(6)
	send {" SC_Space " down}
	HyperSleep(200)
	send {" SC_Space " up}
	Walk(108)
	send {" FwdKey " up}
	switch % " HiveSlot "
		{
		case 3:
		" nm_Walk(4.2, BackKey) "

		default:
		" nm_Walk(23, RightKey) "
		" nm_Walk(2, FwdKey) "
		}
	)"
	}
else {
	paths["pine tree"] := "
	(LTrim Join`r`n
	" nm_Walk(31, FwdKey) "
	" nm_Walk(75, RightKey) "
	send {" RotLeft " 4}
	" nm_Walk(42, FwdKey) "
	" nm_Walk(6, FwdKey, RightKey) "
	" nm_Walk(4, RightKey) "
	send {" FwdKey " down}
	Walk(6)
	send {" SC_Space " down}
	HyperSleep(200)
	send {" SC_Space " up}
	HyperSleep(150)
	send {" SC_Space " down}
	HyperSleep(200)
	send {" SC_Space " up}
	HyperSleep(3000)
	send {" FwdKey " up}
	HyperSleep(2600)
	" nm_Walk(13, FwdKey) "
	switch % " HiveSlot "
		{
		case 3:
		" nm_Walk(4.2, BackKey) "

		default:
		" nm_Walk(23, RightKey) "
		" nm_Walk(2, FwdKey) "
		}
	)"
	}

;added MoveMethod condition to no-glider option misc 181123
;slightly altered tile measurements and optimised glider deployment SP 230405
;path with and without glider zaappiix 230212