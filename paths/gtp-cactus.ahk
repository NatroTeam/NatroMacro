paths["cactus"] := "
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
" nm_Walk(15, FwdKey, RightKey) "
" nm_Walk(22, RightKey) "
" nm_Walk(30, BackKey) "
" nm_Walk(7, LeftKey) " 
)"