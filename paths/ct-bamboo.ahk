paths["bamboo"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
send {e down}
HyperSleep(100)
send {e up}{" LeftKey " down}
HyperSleep(1200)
send {space 2}
HyperSleep(1000)
send {" LeftKey " up}
HyperSleep(1000)
send {space}{" RotLeft " 2}
Sleep, 2000
)"