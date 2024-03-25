If (MoveMethod = "walk")
{
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
    nm_Walk(45, FwdKey)
    nm_Walk(47, LeftKey, FwdKey)
    send "{" RotLeft " 2}"
    nm_Walk(9, RightKey)
    nm_Walk(9, FwdKey)
    nm_walk(16, LeftKey)
    nm_walk(5, BackKey)
    send "{" RotRight " 2}"
}
else {
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(925)
    send "{space 2}"
    HyperSleep(5000)
    send "{" BackKey " up}{" RightKey " up}{space}"
    Sleep 1000
    send "{" RotRight " 3}{" FwdKey " down}{space down}"
    HyperSleep(300)
    send "{space up}"
    send "{space}"
    HyperSleep(2000)
    send "{" FwdKey " up}{" RotLeft " 1}"
    nm_Walk(15, RightKey)
    nm_Walk(15, FwdKey)
    nm_walk(16, LeftKey)
    nm_walk(5, BackKey)
    send "{" RotRight " 2}"
}
;path 230212 zaappiix
;path 230729 noobyguy
