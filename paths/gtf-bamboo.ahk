if (MoveMethod = "Cannon") {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}"
    HyperSleep(1250)
    send "{space 2}"
    HyperSleep(1000)
    send "{" LeftKey " up}"
    HyperSleep(1200)
    send "{space}{" RotLeft " 2}"
    Sleep 2000
} else {
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(23.5, FwdKey)
    nm_Walk(31.5, FwdKey, RightKey)
    nm_Walk(10, RightKey)
    send "{" RotRight " 2}"
}
;walk path 230212 zaappiix - adjusted line 9 and line 13 delays
;cannon path 230630 nooby - updated line 7 and 8
