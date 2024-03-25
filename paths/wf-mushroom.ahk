nm_Walk(13.5, FwdKey)   ;move to rear of mushroom field
nm_Walk(27, LeftKey)    ;walk to corner near fence
send "{" RotLeft " 4}"
nm_Walk(11.5, LeftKey)  ;align with SpawnLocation
nm_Walk(72, FwdKey)     ;walk towards hives

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
