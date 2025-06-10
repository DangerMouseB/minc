export data $N = align 4 { w 0, }
data $.Lstring.2 = align 1 { b "t: %s\012\000", }
data $.Lstring.3 = align 1 { b " %02d\000", }
data $.Lstring.4 = align 1 { b "\012\000", }
export
function w $board() {
@start.1
    %.1 =l alloc4 4
    %.2 =l alloc4 4
@body.2
    %.3 =l loadl $t
    call $time(l %.3)
    %.4 =l loadl $t
    %.5 =l call $ctime(l %.4)
    %.6 =w call $printf(l $.Lstring.2, ..., l %.5)
    storew 0, %.2
@for_cond.3
    %.7 =w loadw %.2
    %.8 =w csltw %.7, 8
    jnz %.8, @for_body.4, @for_join.6
@for_body.4
    storew 0, %.1
@for_cond.7
    %.9 =w loadw %.1
    %.10 =w csltw %.9, 8
    jnz %.10, @for_body.8, @for_join.10
@for_body.8
    %.11 =l loadl $b
    %.12 =w loadw %.1
    %.13 =l extsw %.12
    %.14 =l mul %.13, 8
    %.15 =l add %.11, %.14
    %.16 =l loadl %.15
    %.17 =w loadw %.2
    %.18 =l extsw %.17
    %.19 =l mul %.18, 4
    %.20 =l add %.16, %.19
    %.21 =w loadw %.20
    %.22 =w call $printf(l $.Lstring.3, ..., w %.21)
@for_cont.9
    %.23 =w loadw %.1
    %.24 =w add %.23, 1
    storew %.24, %.1
    jmp @for_cond.7
@for_join.10
    %.25 =w call $printf(l $.Lstring.4)
@for_cont.5
    %.26 =w loadw %.2
    %.27 =w add %.26, 1
    storew %.27, %.2
    jmp @for_cond.3
@for_join.6
    %.28 =w call $printf(l $.Lstring.4)
    ret 0
}
export
function w $chk(w %.1, w %.3) {
@start.11
    %.2 =l alloc4 4
    storew %.1, %.2
    %.4 =l alloc4 4
    storew %.3, %.4
@body.12
    %.5 =w loadw %.2
    %.6 =w csltw %.5, 0
    jnz %.6, @logic_join.14, @logic_right.13
@logic_right.13
    %.7 =w loadw %.2
    %.8 =w csgtw %.7, 7
    %.9 =w cnew %.8, 0
@logic_join.14
    %.10 =w phi @body.12 1, @logic_right.13 %.9
    jnz %.10, @logic_join.16, @logic_right.15
@logic_right.15
    %.11 =w loadw %.4
    %.12 =w csltw %.11, 0
    %.13 =w cnew %.12, 0
@logic_join.16
    %.14 =w phi @logic_join.14 1, @logic_right.15 %.13
    jnz %.14, @logic_join.18, @logic_right.17
@logic_right.17
    %.15 =w loadw %.4
    %.16 =w csgtw %.15, 7
    %.17 =w cnew %.16, 0
@logic_join.18
    %.18 =w phi @logic_join.16 1, @logic_right.17 %.17
    jnz %.18, @if_true.19, @if_false.20
@if_true.19
    ret 0
@if_false.20
    %.19 =l loadl $b
    %.20 =w loadw %.2
    %.21 =l extsw %.20
    %.22 =l mul %.21, 8
    %.23 =l add %.19, %.22
    %.24 =l loadl %.23
    %.25 =w loadw %.4
    %.26 =l extsw %.25
    %.27 =l mul %.26, 4
    %.28 =l add %.24, %.27
    %.29 =w loadw %.28
    %.30 =w ceqw %.29, 0
    ret %.30
}
export
function w $go(w %.1, w %.3, w %.5) {
@start.21
    %.2 =l alloc4 4
    storew %.1, %.2
    %.4 =l alloc4 4
    storew %.3, %.4
    %.6 =l alloc4 4
    storew %.5, %.6
    %.7 =l alloc4 4
    %.8 =l alloc4 4
    %.9 =l alloc4 4
    %.10 =l alloc4 4
    %.11 =l alloc4 4
@body.22
    %.12 =w loadw %.2
    %.13 =l loadl $b
    %.14 =w loadw %.4
    %.15 =l extsw %.14
    %.16 =l mul %.15, 8
    %.17 =l add %.13, %.16
    %.18 =l loadl %.17
    %.19 =w loadw %.6
    %.20 =l extsw %.19
    %.21 =l mul %.20, 4
    %.22 =l add %.18, %.21
    storew %.12, %.22
    %.23 =w loadw %.2
    %.24 =w ceqw %.23, 64
    jnz %.24, @if_true.23, @if_false.24
@if_true.23
    %.25 =w loadw %.4
    %.26 =w cnew %.25, 2
    jnz %.26, @logic_right.25, @logic_join.26
@logic_right.25
    %.27 =w loadw %.6
    %.28 =w cnew %.27, 0
    %.29 =w cnew %.28, 0
@logic_join.26
    %.30 =w phi @if_true.23 0, @logic_right.25 %.29
    jnz %.30, @logic_right.27, @logic_join.28
@logic_right.27
    %.31 =w loadw %.4
    %.32 =w sub %.31, 2
    %.33 =w call $abs(w %.32)
    %.34 =w loadw %.6
    %.35 =w call $abs(w %.34)
    %.36 =w add %.33, %.35
    %.37 =w ceqw %.36, 3
    %.38 =w cnew %.37, 0
@logic_join.28
    %.39 =w phi @logic_join.26 0, @logic_right.27 %.38
    jnz %.39, @if_true.29, @if_false.30
@if_true.29
    %.40 =w call $board()
    %.41 =w loadw $N
    %.42 =w add %.41, 1
    storew %.42, $N
    %.43 =w loadw $N
    %.44 =w ceqw %.43, 10
    jnz %.44, @if_true.31, @if_false.32
@if_true.31
    call $exit(w 0)
@if_false.32
@if_false.30
    jmp @if_join.33
@if_false.24
    %.45 =w neg 2
    storew %.45, %.7
@for_cond.34
    %.46 =w loadw %.7
    %.47 =w cslew %.46, 2
    jnz %.47, @for_body.35, @for_join.37
@for_body.35
    %.48 =w neg 2
    storew %.48, %.8
@for_cond.38
    %.49 =w loadw %.8
    %.50 =w cslew %.49, 2
    jnz %.50, @for_body.39, @for_join.41
@for_body.39
    %.51 =w loadw %.7
    %.52 =w call $abs(w %.51)
    %.53 =w loadw %.8
    %.54 =w call $abs(w %.53)
    %.55 =w add %.52, %.54
    %.56 =w ceqw %.55, 3
    jnz %.56, @logic_right.42, @logic_join.43
@logic_right.42
    %.57 =w loadw %.4
    %.58 =w loadw %.7
    %.59 =w add %.57, %.58
    %.60 =w loadw %.6
    %.61 =w loadw %.8
    %.62 =w add %.60, %.61
    %.63 =w call $chk(w %.59, w %.62)
    %.64 =w cnew %.63, 0
@logic_join.43
    %.65 =w phi @for_body.39 0, @logic_right.42 %.64
    jnz %.65, @if_true.44, @if_false.45
@if_true.44
    %.66 =w loadw %.2
    %.67 =w add %.66, 1
    %.68 =w loadw %.4
    %.69 =w loadw %.7
    %.70 =w add %.68, %.69
    %.71 =w loadw %.6
    %.72 =w loadw %.8
    %.73 =w add %.71, %.72
    %.74 =w call $go(w %.67, w %.70, w %.73)
@if_false.45
@for_cont.40
    %.75 =w loadw %.8
    %.76 =w add %.75, 1
    storew %.76, %.8
    jmp @for_cond.38
@for_join.41
@for_cont.36
    %.77 =w loadw %.7
    %.78 =w add %.77, 1
    storew %.78, %.7
    jmp @for_cond.34
@for_join.37
@if_join.33
    %.79 =l loadl $b
    %.80 =w loadw %.4
    %.81 =l extsw %.80
    %.82 =l mul %.81, 8
    %.83 =l add %.79, %.82
    %.84 =l loadl %.83
    %.85 =w loadw %.6
    %.86 =l extsw %.85
    %.87 =l mul %.86, 4
    %.88 =l add %.84, %.87
    storew 0, %.88
    ret 0
}
export
function w $main() {
@start.46
    %.1 =l alloc4 4
@body.47
    %.2 =l extsw 8
    %.3 =l call $malloc(l %.2)
    storel %.3, $t
    %.4 =l loadl $t
    call $time(l %.4)
    %.5 =l loadl $t
    %.6 =l call $ctime(l %.5)
    %.7 =w call $printf(l $.Lstring.2, ..., l %.6)
    %.8 =l extsw 8
    %.9 =l call $calloc(l %.8, l 8)
    storel %.9, $b
    storew 0, %.1
@for_cond.48
    %.10 =w loadw %.1
    %.11 =w csltw %.10, 8
    jnz %.11, @for_body.49, @for_join.51
@for_body.49
    %.12 =l extsw 8
    %.13 =l call $calloc(l %.12, l 4)
    %.14 =l loadl $b
    %.15 =w loadw %.1
    %.16 =l extsw %.15
    %.17 =l mul %.16, 8
    %.18 =l add %.14, %.17
    storel %.13, %.18
@for_cont.50
    %.19 =w loadw %.1
    %.20 =w add %.19, 1
    storew %.20, %.1
    jmp @for_cond.48
@for_join.51
    %.21 =w call $go(w 1, w 2, w 0)
    ret 0
}
export data $b = align 8 { z 8 }
export data $t = align 8 { z 8 }
