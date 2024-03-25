nm_gotoramp()
nm_gotocannon()
send "{e down}"
HyperSleep(100)
send "{e up}{" RightKey " down}"
HyperSleep(530)
send "{space 2}"
send "{" RightKey " up}"
HyperSleep(3500)
send "{space}"
Sleep 1200
nm_Walk(20, RightKey, FwdKey)
nm_Walk(8.5, BackKey)
send "{space down}"
HyperSleep(200)
send "{space up}{" RightKey " down}"
HyperSleep(250)
send "{" RightKey " up}"
Sleep 1000
