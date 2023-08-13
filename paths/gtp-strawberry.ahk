paths["strawberry"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(750)
send {space 2}
HyperSleep(1000)
send {" RightKey " up}{" BackKey " up}
HyperSleep(800)
send {space}{" RotRight " 2}
Sleep, 2000
" nm_Walk(20, FwdKey, RightKey) "
" nm_Walk(10, BackKey, LeftKey) "
)"