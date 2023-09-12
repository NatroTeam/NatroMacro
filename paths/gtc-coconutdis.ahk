if (MoveMethod = "walk")
{
	paths["coconutdis"] := "
	(LTrim Join`r`n
	;gotoramp
    Send {space down}
    HyperSleep(300)
    Send {space up}
    " nm_Walk(36, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(4, RightKey) "
    " nm_Walk(6, FwdKey) "
    " nm_Walk(3, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(6, FwdKey) "
    " nm_Walk(2, LeftKey, FwdKey) "
    " nm_Walk(8, FwdKey) "
    Send {" FwdKey " down}{" RightKey " down}
    Walk(11)
    send {space down}{" RightKey " up}
    HyperSleep(200)
    send {space up}
    HyperSleep(1100)
    send {space down}
    HyperSleep(200)
    send {space up}
	" nm_Walk(4, FwdKey)"
	send {" RotLeft " 1}
	" nm_Walk(30, FwdKey)"
	sleep 100
	send {" RotRight " 1}
	" nm_Walk(15.7, LeftKey)"
	" nm_Walk(8, FwdKey)"
	)"
}
else
{
	paths["coconutdis"] := "
	(LTrim Join`r`n
	;gotoramp
    Send {space down}
    HyperSleep(300)
    Send {space up}
    " nm_Walk(36, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(4, RightKey) "
    " nm_Walk(6, FwdKey) "
    " nm_Walk(3, RightKey) "
    send {space down}
    HyperSleep(300)
    send {space up}
    " nm_Walk(6, FwdKey) "
    " nm_Walk(2, LeftKey, FwdKey) "
    " nm_Walk(8, FwdKey) "
    Send {" FwdKey " down}{" RightKey " down}
    Walk(11)
    send {space down}{" RightKey " up}
    HyperSleep(200)
    send {space up}
    HyperSleep(1100)
    send {space down}
    HyperSleep(200)
    send {space up}
	" nm_Walk(4, FwdKey)"
	send {" RotLeft " 1}
	" nm_Walk(30, FwdKey)"
	sleep 100
	send {" RotRight " 1}
	" nm_Walk(15.7, LeftKey)"
	" nm_Walk(8, FwdKey)"
	)"
}
;paths 230629 noobyguy