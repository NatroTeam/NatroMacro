paths["strawberrydis"] := "
(LTrim Join`r`n
if (" HiveBees " > 25) {
    ;gotoramp
    send {space down}
    HyperSleep(300)
    Send {space up}
    " nm_Walk(36, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(6, RightKey) "
    HyperSleep(500)
    send {" RotRight " 2}
    send {space down}
    HyperSleep(100)
    send {space up}
    " nm_Walk(3, FwdKey) "
    HyperSleep(1000)
    send {space down}{" RightKey " down}
    HyperSleep(100)
    send {space up}
    HyperSleep(300)
    send {space}{" RightKey " up}
    HyperSleep(1000)
    " nm_Walk(7.5, Backkey, RightKey)"
}
else {

    ;gotoramp
	" nm_Walk(67.5, BackKey, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(31.5, FwdKey) "
	" nm_Walk(9, LeftKey) "
	" nm_Walk(9, BackKey) "
	" nm_Walk(58.5, LeftKey) "
	" nm_Walk(49.5, FwdKey) "
	" nm_Walk(20.25, LeftKey) "
	send {" RotRight " 4}
	" nm_Walk(60.75, FwdKey) "
	send {" RotRight " 2}
	" nm_Walk(9, BackKey) "
	" nm_Walk(15.75, BackKey, RightKey) "
	" nm_Walk(29.7, LeftKey) "
	" nm_Walk(23.85, FwdKey) "
	" nm_Walk(22.95, LeftKey) "
	" nm_Walk(11.25, BackKey) "
}
)"
;dual path 230629 noobyguy