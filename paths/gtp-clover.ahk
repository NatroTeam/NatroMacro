if (MoveMethod = "walk")
{
    nm_gotoramp()
    nm_Walk(44.75, BackKey, LeftKey) ; 47.25
    nm_Walk(52.5, LeftKey)
    nm_Walk(2.8, BackKey, RightKey)
    nm_Walk(6.7, BackKey) ; 6.7
    nm_Walk(25.5, LeftKey)
    nm_Walk(35, FwdKey, LeftKey)
    nm_Walk(7, BackKey, RightKey)
    nm_Walk(12, RightKey)
}
else
{
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}{" FwdKey " down}"
    HyperSleep(525)
    send "{space 2}"
    HyperSleep(1250)
    send "{" FwdKey " up}"
    HyperSleep(3850)
    send "{" LeftKey " up}{space}"
    HyperSleep(1000)
    nm_Walk(10, FwdKey, LeftKey)
    nm_Walk(15, LeftKey)
    nm_Walk(7, FwdKey)
    nm_Walk(7, BackKey, RightKey)
    nm_Walk(12, RightKey)
}
;path 230729 noobyguy
