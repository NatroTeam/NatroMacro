paths["strawberry"] := "
(LTrim Join`r`n
;gotoramp
send {" RotRight " 1} 
" nm_Walk(41, BackKey) "
send {" RotRight " 3}{" FwdKey " down}
send {space down}
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
send {" FwdKey " down}
send {space down}
HyperSleep(150)
send {space up}
Walk(4)
send {" FwdKey " up}
HyperSleep(50)
send {" RotLeft " 2}{" FwdKey " down}
" nm_Walk(2, RightKey) "
Walk(17)
" nm_Walk(10, RightKey) "
Walk(17)
send {" FwdKey " up}
" nm_Walk(10, LeftKey) "
" nm_Walk(10, BackKey, RightKey) "
)"