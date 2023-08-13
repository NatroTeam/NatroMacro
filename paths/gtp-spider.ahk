paths["spider"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" BackKey " down}
HyperSleep(1050)
send {space 2}
HyperSleep(300)
send {" BackKey " up}{space}{" RotLeft " 4}
Sleep, 1500
" nm_Walk(20, FwdKey) "
" nm_Walk(10, FwdKey, LeftKey) "
" nm_Walk(10, LeftKey) "
" nm_Walk(9, BackKey, RightKey) "
)"