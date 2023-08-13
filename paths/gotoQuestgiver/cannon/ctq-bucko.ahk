paths["bucko"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" LeftKey " down}
HyperSleep(750)
send {space 2}
HyperSleep(4450)
send {" LeftKey " up}{space}
HyperSleep(1000)
send {" RotLeft " 2}
" nm_Walk(4.5, RightKey) "
" nm_Walk(6.75, FwdKey, RightKey) "
" nm_Walk(4.5, RightKey) "
" nm_Walk(2.25, BackKey, LeftKey) "
" nm_Walk(6, LeftKey) "
" nm_Walk(45, FwdKey) "
send {" FwdKey " down}
HyperSleep(200)
send {space down}
HyperSleep(200)
send {space up}
HyperSleep(500)
send {" FwdKey " up}
" nm_Walk(18, RightKey) "
" nm_Walk(27, BackKey) "
" nm_Walk(3.375, FwdKey, LeftKey) "
" nm_Walk(7.2, LeftKey) "
" nm_Walk(9, FwdKey) "
send {" FwdKey " down}
HyperSleep(200)
send {space down}
HyperSleep(200)
send {space up}{" FwdKey " up}
HyperSleep(800)
" nm_Walk(2, FwdKey) "
)"