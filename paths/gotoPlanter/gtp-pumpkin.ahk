paths["pumpkin"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
HyperSleep(400)
send {e}
HyperSleep(50)
send {" RightKey " down}{" BackKey " down}
HyperSleep(940)
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