nm_Walk(12, FwdKey)
nm_Walk(20, LeftKey)
nm_Walk(8, RightKey)
send "{" RotLeft " 2}"
nm_Walk(35, LeftKey)
nm_Walk(41, FwdKey)
nm_Walk(9, LeftKey)
nm_Walk(28, FwdKey)
nm_Walk(8, LeftKey)
nm_Walk(6, FwdKey, LeftKey)
nm_Walk(6, FwdKey)
nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
nm_Walk(35, RightKey) ;walk to ramp
nm_Walk(2.7, BackKey) ;center with hive pads

;path 230212 zaappiix
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
