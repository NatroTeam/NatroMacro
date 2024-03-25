if (MoveMethod = "walk") {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(37.5, FwdKey)
    nm_Walk(38, LeftKey, FwdKey)
    nm_Walk(9, BackKey, RightKey)
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" BackKey " down}"
    HyperSleep(1050)
    send "{space 2}"
    HyperSleep(300)
    send "{" BackKey " up}{space}{" RotLeft " 4}"
    Sleep 1500
    nm_Walk(20, FwdKey)
    nm_Walk(10, FwdKey, LeftKey)
    nm_Walk(10, LeftKey)
    nm_Walk(9, BackKey, RightKey)
}
;path 230729 noobyguy
