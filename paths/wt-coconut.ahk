    paths["coconut"] := "
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
    sleep 100
    " nm_Walk(20, FwdKey) "
    " nm_walk(14, LeftKey) "
    )"
    ;path 230212 zaappiix
