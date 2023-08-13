paths["pepper"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" FwdKey " down}{" RightKey " down}
HyperSleep(500)
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
send {" RightKey " down}{" FwdKey " down}{space down}
HyperSleep(50)
send {space up}
Walk(5000*9/2000)
send {space down}
HyperSleep(100)
send {space up}
Walk(1500*9/2000)
send {" FwdKey " up}
Walk(2000*9/2000)
send {space down}
HyperSleep(100)
send {space up}
Walk(1000*9/2000)
send {" RightKey " up}{" FwdKey " up}{" RotRight " 2}
" nm_Walk(1900*9/2000, FwdKey) "
)"