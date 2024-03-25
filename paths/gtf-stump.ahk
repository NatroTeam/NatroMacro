if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}"
    HyperSleep(1850)
    send "{space 2}"
    HyperSleep(2750)
    send "{" LeftKey " up}{" RotLeft " 2}{" FwdKey " down}{" LeftKey " down}"
    HyperSleep(900)
    send "{" LeftKey " up}"
    HyperSleep(1650)
    send "{" FwdKey " up}{space}"
    Sleep 1000
} else {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(30, FwdKey)
    nm_Walk(20, FwdKey, RightKey)
    send "{" RotRight " 2}"
    nm_Walk(43.5, FwdKey)
    nm_Walk(18, RightKey)
    nm_Walk(6, FwdKey)
    send "{" RotLeft " 2}"
    nm_Walk(43, FwdKey)
    nm_Walk(30, FwdKey, RightKey)
    nm_Walk(24, RightKey)
    nm_Walk(10, BackKey)
    send "{" RotRight " 2}"
    ;path 230630 noobyguy
}
