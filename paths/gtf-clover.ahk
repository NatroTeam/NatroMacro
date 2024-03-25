if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}{" FwdKey " down}"
    HyperSleep(525)
    send "{space 2}"
    HyperSleep(1250)
    send "{" FwdKey " up}"
    HyperSleep(1850)
    send "{" LeftKey " up}"
    HyperSleep(1000)
    send "{space}"
    Sleep 1000
} else {
    nm_gotoramp()
    nm_Walk(44.75, BackKey, LeftKey) ; 47.25
    nm_Walk(52.5, LeftKey)
    nm_Walk(2.8, BackKey, RightKey)
    nm_Walk(6.7, BackKey)
    nm_Walk(20.5, LeftKey)
    nm_Walk(4.5, FwdKey)
    ;path 230212 zaappiix
    ;path 230630 noobyguy - changed line 6, 7, 8
}
