paths["pumpkin"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(890)
send {space 2}
HyperSleep(2500)
send {" RightKey " up}
HyperSleep(1100)
send {" BackKey " up}{space}{" RotLeft " 4}
HyperSleep(600)
" nm_Walk(15, FwdKey) "
" nm_Walk(24, RightKey) "
" nm_Walk(5, LeftKey) " 
)"