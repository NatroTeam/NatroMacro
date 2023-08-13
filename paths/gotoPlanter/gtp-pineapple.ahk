paths["pineapple"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
HyperSleep(500)
send {e}
HyperSleep(2500)
send {" RotRight " 3}
" nm_Walk(8, BackKey) "
" nm_Walk(10, BackKey, RightKey) "
" nm_Walk(27, RightKey) "
" nm_Walk(6, BackKey, RightKey) "
send {" FwdKey " down}{" LeftKey " down}
send {space down}
HyperSleep(300)
send {space up}
HyperSleep(300)
send {space down}
HyperSleep(300)
send {space up}
HyperSleep(2000)
Walk(13)
send {" LeftKey " up}
" nm_Walk(12, RightKey) "
send {" FwdKey " up}
" nm_Walk(12, BackKey) "
HyperSleep(100)
)"