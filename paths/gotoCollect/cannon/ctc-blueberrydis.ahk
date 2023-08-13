paths["blueberrydis"] := "
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
" nm_Walk(9, FwdKey) "
" nm_Walk(12.5, FwdKey, RightKey) "
)"