; going to blue portal
nm_Walk(15, LeftKey)
nm_Walk(25, FwdKey)
nm_Walk(7, RightKey)
nm_Walk(5, BackKey)
nm_Walk(50, RightKey)
nm_Walk(8, LeftKey)
nm_Walk(45, FwdKey)
nm_Walk(10, RightKey)
nm_Walk(4, BackKey)
nm_Walk(3, LeftKey)

; blue portal
send("{" RotRight " 2}")
Sleep(200)
send("{" SC_E " down}")
Sleep(50)
send("{" SC_E " up}")
HyperSleep(1500)

; going to hive
nm_Walk(5, RightKey)
nm_Walk(8, BackKey)
nm_Walk(18.5, LeftKey)
nm_Walk(4, BackKey)
nm_Walk(10, LeftKey)

; hive
nm_Walk(10, RightKey)
nm_Walk(5, FwdKey)
nm_Walk(4, BackKey)

; made by Lorddrak