send "{" RotLeft " 2}"
nm_Walk(13.5, RightKey) ;walk to edge of field
nm_Walk(45, FwdKey)     ;walk to corner (special sprout)
nm_Walk(2.25, BackKey)  ;back out of corner
nm_Walk(25, FwdKey, LeftKey) ;move diagonally towards hives
nm_Walk(13.5, FwdKey)   ;walk towards hives
nm_Walk(1.5, BackKey) ;walk backwards to avoid thicker hives
nm_Walk(10, RightKey) ;walk to ramp
nm_Walk(2.7, BackKey) ;center with hive pads
; [2024-01-15/rpertusio] Avoid using corner (Hive 1 and ramp) where character gets stuck after 2024-01-12 BSS update
