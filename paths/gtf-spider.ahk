if (MoveMethod = "Cannon") {
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
} else {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31.5, FwdKey)
    nm_Walk(13, LeftKey, FwdKey)
    ;path 230630 noobyguy adjusted line 7
}
