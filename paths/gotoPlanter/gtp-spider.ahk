paths["spider"] := "
(LTrim Join`r`n
;gotoramp
send {" RotRight " 1} 
" nm_Walk(41, BackKey) "
send {" RotRight " 3}{" FwdKey " down}{space down}
HyperSleep(300)
send {space up}
HyperSleep(300)
send {space down}
HyperSleep(300)
send {space up}
HyperSleep(1000)
send {space down}
HyperSleep(300)
send {space up}
HyperSleep(300)
send {space down}
HyperSleep(300)
send {space up}
Walk(35)
send {" FwdKey " up}
" nm_Walk(5, LeftKey) "
send {" FwdKey " down}{space down}
HyperSleep(150)
send {space up}
Walk(5)
" nm_Walk(12, RightKey) "
Walk(7)
" nm_Walk(18, LeftKey) "
Walk(16)
send {" FwdKey " up}
" nm_Walk(9, BackKey, RightKey) "
)"