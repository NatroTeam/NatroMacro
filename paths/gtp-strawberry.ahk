if (MoveMethod = "walk") {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31, FwdKey)
    nm_Walk(7, FwdKey, LeftKey)
    nm_Walk(30.25, LeftKey)
    nm_Walk(30, FwdKey, LeftKey)
    send "{" RotLeft " 2}"
    nm_Walk(10, BackKey, LeftKey)
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(750)
    send "{space 2}"
    HyperSleep(1000)
    send "{" RightKey " up}{" BackKey " up}"
    HyperSleep(800)
    send "{space}{" RotRight " 2}"
    Sleep 2000
    nm_Walk(10, FwdKey, RightKey)
    nm_Walk(15, RightKey)
    nm_Walk(15, FwdKey)
    nm_Walk(10, BackKey, LeftKey)
}
;path 230729 noobyguy
