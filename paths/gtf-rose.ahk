if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}"
    HyperSleep(550)
    send "{space 2}"
    HyperSleep(2000)
    send "{" RightKey " up}"
    HyperSleep(1000)
    send "{space}{" RotRight " 2}"
    Sleep 1000
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
    nm_Walk(3.75, RightKey)
    nm_Walk(38, FwdKey)
    send "{" RotLeft " 4}"
    nm_Walk(14, RightKey)
    nm_Walk(15, FwdKey, LeftKey)
    nm_Walk(1, BackKey)
    HyperSleep(200)
    nm_Walk(16, RightKey)
    nm_Walk(49, FwdKey)
    send "{" RotRight " 2}"
    ;path 230630 noobyguy
}
