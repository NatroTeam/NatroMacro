nm_Walk(9, RightKey)
send "{" RotLeft " 4}"
nm_Walk(9, BackKey)
send "{" BackKey " down}"
send "{" LeftKey " down}"
HyperSleep(2000)
send "{space down}"
HyperSleep(200)
send "{space up}"
HyperSleep(2000)
send "{" BackKey " up}"
send "{" LeftKey " up}"
nm_Walk(36, FwdKey)
nm_Walk(4.5, FwdKey, RightKey)
nm_Walk(4.5, FwdKey, LeftKey)
nm_Walk(27, FwdKey)
nm_Walk(3, FwdKey, LeftKey)
nm_Walk(85.5, FwdKey)

switch HiveSlot
    {
    case 3:
    nm_Walk(2.7, BackKey) ;center on hive pad 3

    default:
    nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
    nm_Walk(35, RightKey) ;walk to ramp
    nm_Walk(2.7, BackKey) ;center with hive pads
    }
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
; [2024-01-15/rpertusio] Aligns with default SpawnLocation, saves walking if player chose Hive 3
