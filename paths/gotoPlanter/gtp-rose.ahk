paths["rose"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
HyperSleep(500)
send {e}
HyperSleep(50)
send {" RightKey " down}
HyperSleep(600)
send {space 2}
HyperSleep(2500)
send {" RightKey " up}{space}{" RotLeft " 4}
HyperSleep(1000)
" nm_Walk(17, FwdKey) "
" nm_Walk(10, RightKey) "
" nm_Walk(8, FwdKey, RightKey) "
" nm_Walk(8, FwdKey) "
" nm_Walk(7, BackKey, LeftKey) "		
)"