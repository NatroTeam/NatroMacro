paths["clock"] := "
(LTrim Join`r`n
;gotoramp
;gotocannon
Send {e}
HyperSleep(50)
send {" LeftKey " down}{" FwdKey " down}
HyperSleep(900)
send {space 2}
HyperSleep(2475)
send {" FwdKey " up}
HyperSleep(500)
send {" LeftKey " up}
HyperSleep(3500)
send {space}
HyperSleep(1000)
send {" LeftKey " down}
HyperSleep(1000)
send {" LeftKey " up}
)"