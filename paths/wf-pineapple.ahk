﻿paths["pineapple"] := "
(LTrim Join`r`n
" nm_Walk(18, FwdKey) "
" nm_Walk(31.5, RightKey) "
" nm_Walk(4, LeftKey) "
" nm_Walk(10, BackKey) "
" nm_Walk(4, RightKey) "
send {" RotLeft " 4}
" nm_Walk(60, FwdKey) "
" nm_Walk(5.5, BackKey) "
" nm_Walk(10, RightKey) "
if (" HiveBees " < 12) { 
	" nm_Walk(12, FwdKey) "
	" nm_Walk(8, RightKey) "
	send {" RotRight " 2}
	send {" FwdKey " down}
	send {space down}
	Hypersleep(200)
	send {space up}
	send {" FwdKey " up}
	" nm_walk(30, FwdKey) "
	" nm_walk(3, BackKey) "
	send {" RotLeft " 2}
	" nm_walk(30, FwdKey) "
	" nm_Walk(4.5, BackKey) "
	" nm_Walk(40.5, RightKey) "
	" nm_Walk(40.5, FwdKey) "
	" nm_Walk(34.5, RightKey) "
	" nm_Walk(27, FwdKey) "

	switch % " HiveSlot "
		{
		case 3:
		" nm_Walk(2.7, BackKey) " ;center on hive pad 3

		default:
		" nm_Walk(1.5, BackKey) " ;walk backwards to avoid thicker hives
		" nm_Walk(35, RightKey) " ;walk to ramp
		" nm_Walk(2.7, BackKey) " ;center with hive pads
		}
	}
else {
    send {space down}
    Hypersleep(50)
    send {space up}
    " nm_walk(4, rightkey) "
    Hypersleep(1100)
    send {e down}
    HyperSleep(100)
    send {e up}
    Hypersleep(3000)
    " nm_Walk(34, FwdKey) "

	switch % " HiveSlot "
		{
		case 3:
		" nm_Walk(2.7, BackKey) " ;center on hive pad 3

		default:
		" nm_Walk(1.5, BackKey) " ;walk backwards to avoid thicker hives
		" nm_Walk(35, RightKey) " ;walk to ramp
		" nm_Walk(2.7, BackKey) " ;center with hive pads
		}
    }
)"

; added walk path if <12 bees, misc 17/11/23
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
; [2024-01-15/rpertusio] Aligns with default SpawnLocation, saves walking if player chose Hive 3