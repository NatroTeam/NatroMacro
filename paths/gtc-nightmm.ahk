if (MoveMethod = "walk")
{
    nm_gotoramp()
    nm_Walk(67.5, BackKey, LeftKey)
    send "{" RotRight " 4}"
    nm_Walk(31.5, FwdKey)
    nm_Walk(9, LeftKey)
    nm_Walk(9, BackKey)
    nm_Walk(58.5, LeftKey)
    nm_Walk(49.5, FwdKey)
    nm_Walk(3.375, LeftKey)
    nm_Walk(36, FwdKey)
    nm_Walk(54, RightKey)
    nm_Walk(54, BackKey)
    nm_Walk(58.5, RightKey)
    nm_Walk(3, LeftKey)
    nm_Walk(57, FwdKey)
    nm_Walk(16, LeftKey)
}
else
{
    nm_gotoramp()
    nm_gotocannon()
    send "{" SC_E " down}"
    HyperSleep(100)
    send "{" SC_E " up}{" LeftKey " down}{" BackKey " down}"
    HyperSleep(1400)
    send "{" SC_Space " 2}"
    HyperSleep(1100)
    send "{" LeftKey " up}"
    HyperSleep(650)
    send "{" BackKey " up}{" SC_Space "}{" RotRight " 4}"
    Sleep 1500
    nm_Walk(4, RightKey, FwdKey)
    nm_Walk(23, FwdKey)
    nm_Walk(9, LeftKey)
}
nm_Walk(3, FwdKey)
nm_Walk(8, LeftKey)
nm_Walk(3.6, RightKey)
nm_Walk(41, FwdKey)
send "{" SC_Space " down}"
HyperSleep(100)
send "{" SC_Space " up}"
nm_Walk(8.8, FwdKey)
send "{" RotRight " 2}"
nm_Walk(25.6, FwdKey)

; moon jumps
Jump([5, FwdKey])
send "{" RotRight "}"
nm_Walk(2, FwdKey)
Jump([5, FwdKey])
send "{" RotRight "}"
nm_Walk(1.5, FwdKey, LeftKey)
nm_Walk(2, FwdKey)
Jump([2.5, FwdKey], [2.5, FwdKey, LeftKey])
nm_Walk(2, FwdKey)
Jump([5, FwdKey])
nm_Walk(2, FwdKey)
Jump([2, FwdKey, RightKey], [3, FwdKey])
send "{" RotRight "}"
nm_Walk(2, FwdKey)
Jump([2.5, FwdKey, LeftKey], [2, FwdKey])
nm_Walk(2, FwdKey)
Jump([5, FwdKey])
nm_Walk(2, FwdKey)
Jump([4, FwdKey])
send "{" RotRight "}"
nm_Walk(2, FwdKey)
Jump([8, FwdKey])
nm_Walk(4, FwdKey)
nm_Walk(8, FwdKey, LeftKey)
nm_Walk(7, RightKey)
send "{" RotLeft " 2}"
nm_Walk(3, BackKey, RightKey)
nm_Walk(10, RightKey)
nm_Walk(6, FwdKey, RightKey)
Jump([3, FwdKey, RightKey], [1, RightKey])
Sleep 500

; jump function
Jump(movements*) {
    DllCall("GetSystemTimeAsFileTime", "int64p", &jumped:=0)
    send "{" SC_Space " down}"
    Sleep 100
    send "{" SC_Space " up}"
    for params in movements
        nm_Walk(params*)
    DllCall("GetSystemTimeAsFileTime", "int64p", &current:=0)
    Sleep Max(1400-(current-jumped)//10000, -1)
}

; [3 Mar 2024 / SP] First version of gtc-nightmm, first half from gtc-lidart zaappiix
