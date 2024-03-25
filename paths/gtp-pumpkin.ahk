if (MoveMethod = "walk")
{
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31, FwdKey)
    nm_Walk(7.8, LeftKey)
    nm_Walk(10, BackKey)
    nm_Walk(5, RightKey)
    nm_Walk(1.5, FwdKey)
    nm_Walk(60, LeftKey)
    nm_Walk(3.75, RightKey)
    nm_Walk(45, FwdKey)
    nm_Walk(34, RightKey, FwdKey)
    nm_Walk(10, RightKey)
    nm_Walk(12, LeftKey) 
    nm_Walk(3, BackKey)
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(890)
    send "{space 2}"
    HyperSleep(2500)
    send "{" RightKey " up}"
    HyperSleep(1100)
    send "{" BackKey " up}{space}{" RotLeft " 4}"
    HyperSleep(600)
    nm_Walk(15, FwdKey)
    nm_Walk(24, RightKey)
    nm_Walk(12, LeftKey) 
    nm_Walk(3, BackKey)
}
;path 230729 noobyguy
