if (MoveMethod = "walk")
{
    nm_gotoramp()
    nm_Walk(44.75, BackKey, LeftKey) ; 47.25
    nm_Walk(52.5, LeftKey)
    nm_Walk(2.8, BackKey, RightKey)
    nm_Walk(7.7, BackKey)
    nm_Walk(20.5, LeftKey)
    nm_Walk(6.5, FwdKey)

    ; going to corner
    nm_Walk(20, FwdKey, LeftKey)
    nm_Walk(3, FwdKey)
    nm_Walk(3, LeftKey)

    ; out of corner
    nm_Walk(5, RightKey)
    nm_Walk(10, RightKey, FwdKey)
    nm_Walk(3, BackKey)
}
else
{
    nm_gotoramp()
    nm_gotocannon()
    send "{e down}"
    HyperSleep(100)
    send "{e up}{" LeftKey " down}{" FwdKey " down}"
    HyperSleep(525) ; change to 625? idea
    send "{space 2}"
    HyperSleep(1250)
    send "{" FwdKey " up}"
    HyperSleep(3000)
    send "{" LeftKey " up}{space}"
    HyperSleep(700)

    ; going to corner
    nm_Walk(20, FwdKey, LeftKey)
    nm_Walk(3, FwdKey)
    nm_Walk(3, LeftKey)

    ; out of corner
    nm_Walk(5, RightKey)
    nm_Walk(10, RightKey, FwdKey)
    nm_Walk(3, BackKey)
}
; by Lorddrak for beesmas (stockings pmo)
