if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{" RotLeft " 1}"
    send "{e down}{" FwdKey " down}"
    HyperSleep(100)
    send "{e up}"
    HyperSleep(1100)
    send "{space 2}{" FwdKey " up}"
    HyperSleep(3767) ; OH MY GOD SIX SEVEEEEN
    send "{space}"
    send "{" RotRight " 1}"
    HyperSleep(1500)
} else {
    nm_gotoramp()
    nm_Walk(44.75, BackKey, LeftKey) ; 47.25
    nm_Walk(52.5, LeftKey)
    nm_Walk(2.8, BackKey, RightKey)
    nm_Walk(7.7, BackKey)
    nm_Walk(20.5, LeftKey)
    nm_Walk(5.5, FwdKey)
    ;path 230212 zaappiix
    ;path 230630 noobyguy - changed line 6, 7, 8
    ;path 250927 dully176 - calibrated cannon path
}

; edited by Lorddrak