paths["dandelion"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}
HyperSleep(250)
send {space 2}
HyperSleep(700)
send {" LeftKey " up}
HyperSleep(1000)
send {space}{" RotLeft " 2}
Sleep, 1500
)"