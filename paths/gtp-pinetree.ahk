paths["pine tree"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" RightKey " down}{" BackKey " down}
HyperSleep(925)
send {space 2}
HyperSleep(5000)
send {" BackKey " up}{" RightKey " up}{space}
Sleep, 1000
send {" RotRight " 3}{" FwdKey " down}{space down}
HyperSleep(300)
send {space up}
send {space}
HyperSleep(2000)
send {" FwdKey " up}{" RotLeft " 1}
" nm_Walk(15, RightKey) "
" nm_Walk(15, FwdKey) "
" nm_walk(16, LeftKey) "
" nm_walk(5, BackKey) "
send {" RotRight " 2}
)"
;path 230212 zaappiix