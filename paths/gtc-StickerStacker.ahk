if (MoveMethod = "cannon")
{
paths["Sticker"] := "
        (LTrim Join`r`n
        ;gotoramp
        ;gotocannon
        send {e down}
        HyperSleep(100)
        send {e up}{" RightKey " down}
        HyperSleep(1200)
        send {space 2}
        send {" RightKey " up}
        HyperSleep(6000)
        " nm_Walk(7, RightKey) "
        " nm_Walk(11, BackKey) "
        send {space down}
        " nm_Walk(1.5, BackKey) "
        send {space up}
        " nm_Walk(1.5, BackKey) "
        send {space down}
        " nm_Walk(1.5, BackKey) "
        send {space up}
        " nm_Walk(2, BackKey) "
        HyperSleep(2000)
        )"
}
