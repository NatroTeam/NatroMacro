paths["cactus"] := "
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
" nm_Walk(15, FwdKey) "
" nm_walk(3.5, Backkey) "
" nm_Walk(18, rightKey) "
" nm_Walk(8, leftKey) "
HyperSleep(300)
send {" BackKey " down}{space down}
HyperSleep(300)
send {space up}
send {space}
HyperSleep(1000)
send {space down}
HyperSleep(300)
send {space up}
send {space}
HyperSleep(1000)
send {" BackKey " up}
" nm_Walk(10, BackKey) "
" nm_Walk(10, FwdKey, RightKey) " 
)"