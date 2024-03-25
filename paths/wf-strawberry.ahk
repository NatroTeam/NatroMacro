Send "{" RotLeft " 2}"
nm_Walk(12, BackKey)            ;walk back against wall
nm_Walk(15, BackKey, LeftKey)   ;move to corner (betwen strawberry & vicious bee)
nm_Walk(18, LeftKey)            ;ensure against vicious bee platform
nm_Walk(15, FwdKey)             ;move forward past vicious bee platform
nm_Walk(6, LeftKey)             ;align with SpawnLocation
nm_Walk(95, FwdKey)             ;walk towards hives

switch HiveSlot
    {
    case 3:
    nm_Walk(2.7, BackKey) ;center on hive pad 3

    default:
    nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
    nm_Walk(35, RightKey) ;walk to ramp
    nm_Walk(2.7, BackKey) ;center with hive pads
    }

;zaappiix 230203
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
; [2024-01-15/rpertusio] No longer uses the Instant Converter corner to align
; [2024-01-15/rpertusio] Aligns with default SpawnLocation, saves walking if player chose Hive 3
