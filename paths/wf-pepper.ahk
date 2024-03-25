nm_Walk(42, RightKey)
send "{" RotLeft " 4}"
nm_Walk(45, FwdKey)
nm_Walk(50, LeftKey)
nm_Walk(49, FwdKey)
send "{" RotRight " 2}"
nm_Walk(13.5, FwdKey)
nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
nm_Walk(10, RightKey) ;walk to ramp
nm_Walk(2.7, BackKey) ;center with hive pads

; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
; [2024-01-15/rpertusio] Updated camera angle to 'follow' user to hive, less disorienting
