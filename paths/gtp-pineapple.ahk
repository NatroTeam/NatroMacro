paths["pineapple"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}
Sleep, 2500
send {" RotRight " 3}
" nm_Walk(8, BackKey) "
" nm_Walk(10, BackKey, RightKey) "
" nm_Walk(10, RightKey) "
" nm_Walk(13, RightKey, FwdKey) "
" nm_Walk(8, BackKey, RightKey) "
send {" FwdKey " down}{" LeftKey " down}
Walk(12)
send {" LeftKey " up}
" nm_Walk(10, RightKey) "
send {" FwdKey " up}
" nm_Walk(12, BackKey) "
send {" RotRight " 1}
HyperSleep(100)
)"