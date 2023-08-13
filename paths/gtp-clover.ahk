paths["clover"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}{" FwdKey " down}
HyperSleep(525)
send {space 2}
HyperSleep(1250)
send {" FwdKey " up}
HyperSleep(3850)
send {" LeftKey " up}{space}
HyperSleep(1000)
" nm_Walk(10, FwdKey, LeftKey) "
" nm_Walk(15, LeftKey) "
" nm_Walk(7, FwdKey) "
" nm_Walk(7, BackKey, RightKey) "
" nm_Walk(12, RightKey) "
)"