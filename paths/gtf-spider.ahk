if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}{" BackKey " down}"
    HyperSleep(100)
    send "{e up}"
    HyperSleep(1075)
    send "{space 2}{" BackKey " up}"
    HyperSleep(300)
    send "{space}{" RotRight " 4}"
    sleep 2000
} else {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31.5, FwdKey)
    nm_Walk(13, LeftKey, FwdKey)
    ;path 230630 noobyguy adjusted line 7
    ;path 250927 dully176 - calibrated cannon path
}
