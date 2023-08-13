paths["pine tree"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(925)
send {space 2}
HyperSleep(4500)
send {" BackKey " up}
HyperSleep(500)
send {" RightKey " up}{space}
Sleep, 1000
send {" RotRight " 3}{" FwdKey " down}{space down}
HyperSleep(300)
send {space up}
send {space}
HyperSleep(3000)
send {" FwdKey " up}
send {" RotLeft " 1}
" nm_walk(16, LeftKey) "
" nm_walk(4, BackKey) "
)"