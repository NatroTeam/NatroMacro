paths["blue flower"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}
HyperSleep(675)
send {space 2}
HyperSleep(3250)
send {" LeftKey " up}{space}{" RotLeft " 2}
Sleep, 1000
" nm_Walk(10, LeftKey) "
" nm_Walk(18, RightKey) "
" nm_Walk(10, BackKey) "
" nm_Walk(3, LeftKey) "
)"