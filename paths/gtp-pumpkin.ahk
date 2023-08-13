paths["pumpkin"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(890)
send {space 2}
HyperSleep(2600)
send {" RightKey " up}
HyperSleep(1100)
send {" BackKey " up}{space}{" RotLeft " 4}
HyperSleep(600)
send {space}
HyperSleep(500)
" nm_Walk(15, FwdKey) "
" nm_walk(3.5, Backkey) "
" nm_Walk(18, rightKey) "
" nm_Walk(7, BackKey, LeftKey) "
)"