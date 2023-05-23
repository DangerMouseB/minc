export function w $board() {
@start.1
@body.2
    %_x =l alloc4 4
    %_y =l alloc4 4
    %.2 =l loadl $t
    call extern $time(l %.2)
    %.6 =l loadl $t
    %.5 =l call extern $ctime(l %.6)
    %.3 =w call extern $printf(l $.s1, ..., l %.5)
    storew 0, %_y
@while.cond.3
    %.10 =w loadw %_y
    %.9 =w csltw %.10, 8
    jnz %.9, @while.body.4, @while.end.5
@while.body.4
    storew 0, %_x
@while.cond.6
    %.15 =w loadw %_x
    %.14 =w csltw %.15, 8
    jnz %.14, @while.body.7, @while.end.8
@while.body.7
    %.23 =l loadl $b
    %.24 =w loadw %_x
    %.25 =l extsw %.24
    %.26 =l mul 8, %.25
    %.22 =l add %.23, %.26
    %.21 =l loadl %.22
    %.27 =w loadw %_y
    %.28 =l extsw %.27
    %.29 =l mul 4, %.28
    %.20 =l add %.21, %.29
    %.19 =w loadw %.20
    %.17 =w call extern $printf(l $.s2, ..., w %.19)
    %.31 =w loadw %_x
    %.30 =w add %.31, 1
    storew %.30, %_x
    jmp @while.cond.6
@while.end.8
    %.32 =w call extern $printf(l $.s3)
    %.35 =w loadw %_y
    %.34 =w add %.35, 1
    storew %.34, %_y
    jmp @while.cond.3
@while.end.5
    %.36 =w call extern $printf(l $.s4)
    ret 0
}

export function w $chk(w %.1, w %.2) {
@start.9
    %_x =l alloc4 4
    storew %.1, %_x
    %_y =l alloc4 4
    storew %.2, %_y
@body.10
    %_no =l alloc4 4
    storew 0, %_no
    %.7 =w loadw %_no
    %.9 =w loadw %_x
    %.8 =w csltw %.9, 0
    %.6 =w add %.7, %.8
    storew %.6, %_no
    %.13 =w loadw %_no
    %.16 =w loadw %_x
    %.14 =w csltw 7, %.16
    %.12 =w add %.13, %.14
    storew %.12, %_no
    %.19 =w loadw %_no
    %.21 =w loadw %_y
    %.20 =w csltw %.21, 0
    %.18 =w add %.19, %.20
    storew %.18, %_no
    %.25 =w loadw %_no
    %.28 =w loadw %_y
    %.26 =w csltw 7, %.28
    %.24 =w add %.25, %.26
    storew %.24, %_no
@if.11
    %.29 =w loadw %_no
    jnz %.29, @true.12, @false.13
@true.12
    ret 0
@false.13
    %.33 =w loadw %_no
    %.38 =l loadl $b
    %.39 =w loadw %_x
    %.40 =l extsw %.39
    %.41 =l mul 8, %.40
    %.37 =l add %.38, %.41
    %.36 =l loadl %.37
    %.42 =w loadw %_y
    %.43 =l extsw %.42
    %.44 =l mul 4, %.43
    %.35 =l add %.36, %.44
    %.34 =w loadw %.35
    %.32 =w add %.33, %.34
    storew %.32, %_no
    %.46 =w loadw %_no
    %.45 =w ceqw %.46, 0
    ret %.45
}

export function w $go(w %.1, w %.2, w %.3) {
@start.14
    %_k =l alloc4 4
    storew %.1, %_k
    %_x =l alloc4 4
    storew %.2, %_x
    %_y =l alloc4 4
    storew %.3, %_y
@body.15
    %_i =l alloc4 4
    %_j =l alloc4 4
    %_no =l alloc4 4
    %_x1 =l alloc4 4
    %_y1 =l alloc4 4
    %.5 =w loadw %_k
    %.9 =l loadl $b
    %.10 =w loadw %_x
    %.11 =l extsw %.10
    %.12 =l mul 8, %.11
    %.8 =l add %.9, %.12
    %.7 =l loadl %.8
    %.13 =w loadw %_y
    %.14 =l extsw %.13
    %.15 =l mul 4, %.14
    %.6 =l add %.7, %.15
    storew %.5, %.6
@if.else.16
    %.17 =w loadw %_k
    %.16 =w ceqw %.17, 64
    jnz %.16, @true.17, @false.18
@true.17
@if.20
    %.20 =w loadw %_x
    %.19 =w cnew %.20, 2
    jnz %.19, @and.true.24, @false.22
@and.true.24
    %.23 =w loadw %_y
    %.22 =w cnew %.23, 0
    jnz %.22, @and.true.23, @false.22
@and.true.23
    %.29 =w loadw %_x
    %.28 =w sub %.29, 2
    %.27 =w call extern $abs(w %.28)
    %.32 =w loadw %_y
    %.31 =w call extern $abs(w %.32)
    %.26 =w add %.27, %.31
    %.25 =w ceqw %.26, 3
    jnz %.25, @true.21, @false.22
@true.21
    %.34 =w call $board()
    %.36 =w loadw $N
    %.35 =w add %.36, 1
    storew %.35, $N
@if.25
    %.38 =w loadw $N
    %.37 =w ceqw %.38, 10
    jnz %.37, @true.26, @false.27
@true.26
    call extern $exit(w 0)
@false.27
@false.22
    jmp @if.end.19
@false.18
    %.44 =w sub 0, 2
    storew %.44, %_i
@while.cond.28
    %.48 =w loadw %_i
    %.47 =w cslew %.48, 2
    jnz %.47, @while.body.29, @while.end.30
@while.body.29
    %.52 =w sub 0, 2
    storew %.52, %_j
@while.cond.31
    %.56 =w loadw %_j
    %.55 =w cslew %.56, 2
    jnz %.55, @while.body.32, @while.end.33
@while.body.32
@if.34
    %.61 =w loadw %_i
    %.60 =w call extern $abs(w %.61)
    %.63 =w loadw %_j
    %.62 =w call extern $abs(w %.63)
    %.59 =w add %.60, %.62
    %.58 =w ceqw %.59, 3
    jnz %.58, @and.true.37, @false.36
@and.true.37
    %.67 =w loadw %_x
    %.68 =w loadw %_i
    %.66 =w add %.67, %.68
    %.70 =w loadw %_y
    %.71 =w loadw %_j
    %.69 =w add %.70, %.71
    %.65 =w call $chk(w %.66, w %.69)
    jnz %.65, @true.35, @false.36
@true.35
    %.74 =w loadw %_k
    %.73 =w add %.74, 1
    %.77 =w loadw %_x
    %.78 =w loadw %_i
    %.76 =w add %.77, %.78
    %.80 =w loadw %_y
    %.81 =w loadw %_j
    %.79 =w add %.80, %.81
    %.72 =w call $go(w %.73, w %.76, w %.79)
@false.36
    %.83 =w loadw %_j
    %.82 =w add %.83, 1
    storew %.82, %_j
    jmp @while.cond.31
@while.end.33
    %.85 =w loadw %_i
    %.84 =w add %.85, 1
    storew %.84, %_i
    jmp @while.cond.28
@while.end.30
@if.end.19
    %.91 =l loadl $b
    %.92 =w loadw %_x
    %.93 =l extsw %.92
    %.94 =l mul 8, %.93
    %.90 =l add %.91, %.94
    %.89 =l loadl %.90
    %.95 =w loadw %_y
    %.96 =l extsw %.95
    %.97 =l mul 4, %.96
    %.88 =l add %.89, %.97
    storew 0, %.88
    ret 0
}

export function w $main() {
@start.38
@body.39
    %_i =l alloc4 4
    %.2 =l call extern $malloc(w 8)
    storel %.2, $t
    %.5 =l loadl $t
    call extern $time(l %.5)
    %.9 =l loadl $t
    %.8 =l call extern $ctime(l %.9)
    %.6 =w call extern $printf(l $.s5, ..., l %.8)
    %.11 =l call extern $calloc(w 8, w 8)
    storel %.11, $b
    storew 0, %_i
@while.cond.40
    %.17 =w loadw %_i
    %.16 =w csltw %.17, 8
    jnz %.16, @while.body.41, @while.end.42
@while.body.41
    %.20 =l call extern $calloc(w 8, w 8)
    %.24 =l loadl $b
    %.25 =w loadw %_i
    %.26 =l extsw %.25
    %.27 =l mul 8, %.26
    %.23 =l add %.24, %.27
    storel %.20, %.23
    %.29 =w loadw %_i
    %.28 =w add %.29, 1
    storew %.28, %_i
    jmp @while.cond.40
@while.end.42
    %.30 =w call $go(w 1, w 2, w 0)
    ret
}


# GLOBAL VARIABLES
data $N = { w 0 }
data $b = { l 0 }
data $t = { l 0 }

# STRING CONSTANTS
data $.s1 = { b "t: %s\n", b 0 }
data $.s2 = { b " %02d", b 0 }
data $.s3 = { b "\n", b 0 }
data $.s4 = { b "\n", b 0 }
data $.s5 = { b "t: %s\n", b 0 }
