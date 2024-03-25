if (MoveMethod = "walk") 
{
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(23.5, FwdKey)
    nm_Walk(31.5, FwdKey, RightKey)
    nm_Walk(10, RightKey)
    send "{" RotRight " 2}"
    nm_Walk(20, FwdKey)
    nm_Walk(5, FwdKey, LeftKey)
    nm_Walk(7, LeftKey)
    nm_Walk(1, FwdKey)
    nm_Walk(8, RightKey)
    nm_Walk(14, BackKey)
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{" RotLeft " 2}{e down}"
    HyperSleep(100)
    send "{e up}{" FwdKey " down}"
    HyperSleep(800)
    send "{" SC_space " 2}"
    HyperSleep(3000)
    send "{" FwdKey " up}{" LeftKey " down}"
    HyperSleep(1000)
    send "{" SC_space "}"
    send "{" LeftKey " up}"
    HyperSleep(1000)
    nm_Walk(20, LeftKey)
    nm_Walk(30, FwdKey)
    nm_Walk(8, RightKey)
    nm_Walk(14, BackKey)
}
;path 230729 noobyguy
