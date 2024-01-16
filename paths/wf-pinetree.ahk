﻿If ((HiveBees < 25) || (MoveMethod = "Walk")) {
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
		" nm_Walk(2.7, BackKey) " ;center on hive pad 3

		default:
		" nm_Walk(1.5, BackKey) " ;walk backwards to avoid thicker hives
		" nm_Walk(35, RightKey) " ;walk to ramp
		" nm_Walk(2.7, BackKey) " ;center with hive pads
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
		" nm_Walk(2.7, BackKey) " ;center on hive pad 3

		default:
		" nm_Walk(1.5, BackKey) " ;walk backwards to avoid thicker hives
		" nm_Walk(35, RightKey) " ;walk to ramp
		" nm_Walk(2.7, BackKey) " ;center with hive pads
		}
	)"
	}

;added MoveMethod condition to no-glider option misc 181123
;slightly altered tile measurements and optimised glider deployment SP 230405
;path with and without glider zaappiix 230212
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
; [2024-01-15/rpertusio] Aligns with default SpawnLocation, saves walking if player chose Hive 3