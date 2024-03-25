If (HiveBees >= 25) && (MoveMethod = "cannon")
{
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}"
    HyperSleep(500)
    send "{" RotRight " 4}{" RightKey " down}"
    HyperSleep(1000)
    send "{space}"
    HyperSleep(500)
    send "{space}"
    HyperSleep(2900)
    send "{" RightKey " up}{" FwdKey " down}{" LeftKey " down}"
    HyperSleep(1600)
    send "{space}"
    HyperSleep(1000)
    nm_Walk(14, FwdKey, LeftKey)
    nm_Walk(10, FwdKey)
    nm_Walk(7, BackKey, RightKey)
}
else {
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
    nm_Walk(66, FwdKey)
    nm_Walk(19, FwdKey, LeftKey)
    nm_Walk(7, BackKey, RightKey)
}
;path 230212 zaappiix
;path 230729 noobyguy: If (HiveBees < 25) && (MoveMethod = "cannon") & walk path
;path ferox7274: cannon path
