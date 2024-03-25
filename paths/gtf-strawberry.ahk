if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(700)
    send "{space 2}"
    HyperSleep(1700)
    send "{" RightKey " up}{" BackKey " up}{space}{" RotRight " 2}"
    Sleep 2000
} else {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31, FwdKey)
    nm_Walk(7, FwdKey, LeftKey)
    nm_Walk(33.25, LeftKey)
    nm_Walk(6.75, FwdKey, LeftKey)
    send "{" RotLeft " 2}"
    ;path 230630 noobyguy adjusted line 7
}
