paths["treatdis"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e}
HyperSleep(50)
send {" LeftKey " down}
HyperSleep(1860)
send {space 2}
HyperSleep(1925)
send {" LeftKey " up}{space}{" RotRight " 4}
Sleep, 1500
)"