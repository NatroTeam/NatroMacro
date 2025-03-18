nm_gotoramp()
send("{" SC_Space " down}"), sleep(100)
send("{" SC_Space " up}")
nm_Walk(2, RightKey)
nm_Walk(1.8, FwdKey, RightKey)
nm_Walk(32, RightKey)
send("{" SC_Space " down}"), HyperSleep(300)
send("{" SC_Space " up}")
nm_Walk(2, RightKey)
nm_Walk(6, RightKey, FwdKey)
nm_Walk(3, RightKey)
send("{" RotRight " 2}"), Sleep(100)
send "{" FwdKey " down}"
send("{" SC_Space " down}"), HyperSleep(300)
send "{" FwdKey " up}"
send("{" SC_Space " up}")
nm_Walk(2, FwdKey), Sleep(1000)
send("{" SC_Space " down}{" Rightkey " down}"), HyperSleep(100)
send("{" SC_Space " up}"), HyperSleep(100)
send("{" SC_Space " down}"),HyperSleep(100), send("{" SC_Space " up}"), HyperSleep(100)
send "{space}{" RightKey " up}"
sleep 100
send "{space up}"
sleep 1000
nm_Walk(1, FwdKey, RightKey)
nm_Walk(20, RightKey)
nm_Walk(2, FwdKey)
nm_Walk(12, FwdKey, RightKey)
nm_Walk(10, FwdKey)
nm_Walk(6, BackKey)
send("{" RotRight " 2}"), Sleep(100)
nm_Walk(5, FwdKey)
sleep 100
send("{" SC_Space " down}"), HyperSleep(300)
send("{" SC_Space " up}"), nm_Walk(6, FwdKey)
sleep 300
; 12/23/2024 - dully176 - Reworked Path.
