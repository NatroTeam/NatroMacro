if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{" RotRight " 3}"
    send "{e down}{" FwdKey " down}"
    HyperSleep(100)
    send "{e up}"
    HyperSleep(967)
    send "{space 2}{" FwdKey " up}"
    HyperSleep(2600)
    send "{space}"
    HyperSleep(1500)
    send "{" RotLeft " 3}"
} else {
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
    send "{" RotRight " 4}"
    nm_Walk(13.5, LeftKey)
    ;path 230630 noobyguy
    ;path 250927 dully176 - calibrated cannon path
}
