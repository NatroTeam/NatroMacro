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
    nm_Walk(85, FwdKey)
    nm_Walk(45, RightKey)
    nm_Walk(50, BackKey)
    nm_Walk(60, RightKey)
    nm_Walk(5, LeftKey)
    nm_Walk(7, FwdKey)
    nm_Walk(9, FwdKey, LeftKey)
    nm_Walk(16.5, FwdKey)
    send "{" RotRight " 4}"
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}"
    Sleep 2750
}
;path 230729 noobyguy
