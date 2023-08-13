paths["coconutdis"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" FwdKey " down}
HyperSleep(500)
send {space 2}
send {" RightKey " down}
HyperSleep(3850)
send {" RightKey " up}
HyperSleep(2000)
send {" RightKey " down}
HyperSleep(2000)
send {" RightKey " up}
send {space down}
HyperSleep(50)
send {space up}
HyperSleep(750)
send {space down}
HyperSleep(50)
send {space up}
HyperSleep(750)
send {space down}
HyperSleep(50)
send {space up}
Walk(3000*9/2000)
send {" FwdKey " up}{" LeftKey " down}
Walk(3000*9/2000)
send {" LeftKey " up}
" nm_Walk(18, FwdKey, LeftKey) "
" nm_Walk(11.25, LeftKey) "
" nm_Walk(18, FwdKey, RightKey) "
" nm_Walk(3.375, BackKey, LeftKey) "
)"