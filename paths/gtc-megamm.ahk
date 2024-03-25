if (MoveMethod = "walk")
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
    nm_Walk(38, FwdKey)
    send "{" RotLeft " 4}"
    nm_Walk(14, RightKey)
    nm_Walk(15, FwdKey, LeftKey)
}
else
{
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" RightKey " down}{" BackKey " down}"
    HyperSleep(925)
    send "{space 2}"
    HyperSleep(2850)
    send "{" BackKey " up}"
    HyperSleep(1450)
    send "{space}{" RightKey " up}"
    HyperSleep(600)
    ;corner align
    nm_Walk(10, FwdKey, LeftKey)
    nm_Walk(10, LeftKey, FwdKey)
}
nm_Walk(1, BackKey)
HyperSleep(200)
nm_Walk(25, RightKey)
Hypersleep(200)
send "{" RotRight " 2}"
Hypersleep(200)
;inside badge shop
nm_Walk(15, FwdKey)
nm_Walk(1, FwdKey, RightKey)
;align with corner
nm_Walk(7, FwdKey)
nm_Walk(4, BackKey)
nm_Walk(3, LeftKey)
Sleep 1000
;path 230630 noobyguy - walk updated
;adjusted for memory match OAC
