paths["coconut"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" FwdKey " down}{" RightKey " down}
HyperSleep(550)
send {space 2}
HyperSleep(3800)
send {" RightKey " up}
HyperSleep(2050)
send {" RightKey " down}
HyperSleep(2000)
send {" RightKey " up}{" FwdKey " up}
send {space down}
HyperSleep(50)
send {space up}
" nm_Walk(3, FwdKey) "
HyperSleep(750)
send {space down}
HyperSleep(50)
send {space up}
" nm_Walk(3, FwdKey) "
HyperSleep(750)
send {space down}
HyperSleep(50)
send {space up}
" nm_Walk(13, FwdKey) "
" nm_Walk(13.5, LeftKey) "
)"