if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(950)
    send "{space 2}"
    HyperSleep(1700)
    send "{" RightKey " up}{" BackKey " up}"
    HyperSleep(1000)
    send "{space}"
    Sleep 2000
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
}
