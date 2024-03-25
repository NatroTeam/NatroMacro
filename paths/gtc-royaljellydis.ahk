nm_gotoramp()
nm_gotocannon()
send "{e down}"
HyperSleep(100)
send "{e up}{" LeftKey " down}"
HyperSleep(750)
send "{space 2}"
HyperSleep(2250) ; 1900
send "{" FwdKey " down}"
HyperSleep(1000)
send "{" LeftKey " up}"
Sleep 1000
send "{" FwdKey " up}"
Sleep 2000
nm_Walk(13, FwdKey)
