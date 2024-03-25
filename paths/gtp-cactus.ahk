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
    nm_Walk(49.5, FwdKey)
    send "{" RotRight " 2}"
    nm_Walk(35.5, FwdKey)
    nm_Walk(3, RightKey)
    nm_Walk(7, BackKey)
    send "{" RotRight " 2}"
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
    nm_Walk(15, FwdKey, RightKey)
    nm_Walk(22, RightKey)
    nm_Walk(30, BackKey)
    nm_Walk(7, LeftKey)
    send "{" RotLeft " 4}"
}
;path 230729 noobyguy
