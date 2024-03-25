if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}"
    HyperSleep(675)
    send "{space 2}"
    HyperSleep(2000)
    send "{" LeftKey " up}"
    HyperSleep(1250)
    send "{space}{" RotLeft " 2}"
    Sleep 1000
} else {
    nm_gotoramp()
    nm_Walk(86.875, BackKey, LeftKey) ; 88.875
    nm_Walk(28, LeftKey) ; 27
    send "{" RotLeft " 2}"
}
