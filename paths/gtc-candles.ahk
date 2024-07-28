nm_gotoramp()
Send "{space down}{" RightKey " down}"
Sleep 100
Send "{space up}"
Walk(2)
Send "{" FwdKey " down}"
Walk(1.8)
Send "{" FwdKey " up}"
Walk(30)
send "{space down}"
HyperSleep(300)
send "{space up}{" FwdKey " down}"
Walk(4)
send "{" FwdKey " up}"
Walk(3)
send "{" RightKey " up}{" RotRight " 2}"
Sleep 200
send "{space down}"
HyperSleep(100)
send "{space up}"
nm_Walk(3, FwdKey)
Sleep 1000
send "{space down}{" RightKey " down}"
HyperSleep(100)
send "{space up}"
HyperSleep(300)
send "{space}{" RightKey " up}"
HyperSleep(1000)
nm_Walk(4, RightKey)
nm_Walk(14, FwdKey)
nm_Walk(8, RightKey)
nm_Walk(5, LeftKey)
