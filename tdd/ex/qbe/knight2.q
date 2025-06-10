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
@while.3.cond
    %.10 =w loadw %_y
    %.9 =w csltw %.10, 8
    jnz %.9, @while.3.body, @while.3.end
@while.3.body
    storew 0, %_x
@while.4.cond
    %.15 =w loadw %_x
    %.14 =w csltw %.15, 8
    jnz %.14, @while.4.body, @while.4.end
@while.4.body
    %.21 =l loadl $b
    %.25 =w loadw %_x
    %.23 =w mul 8, %.25
    %.26 =w loadw %_y
    %.22 =w add %.23, %.26
    %.27 =l extsw %.22
    %.28 =l mul 4, %.27
    %.20 =l add %.21, %.28
    %.19 =w loadw %.20
    %.17 =w call extern $printf(l $.s2, ..., w %.19)
    %.30 =w loadw %_x
    %.29 =w add %.30, 1
    storew %.29, %_x
    jmp @while.4.cond
@while.4.end
    %.31 =w call extern $printf(l $.s3)
    %.34 =w loadw %_y
    %.33 =w add %.34, 1
    storew %.33, %_y
    jmp @while.3.cond
@while.3.end
    %.35 =w call extern $printf(l $.s4)
    ret 0
}

export function w $chk(w %.1, w %.2) {
@start.5
    %_x =l alloc4 4
    storew %.1, %_x
    %_y =l alloc4 4
    storew %.2, %_y
@body.6
@if.7
    %.4 =w loadw %_x
    %.3 =w csltw %.4, 0
    jnz %.3, @if.7.true, @or.10.false
@or.10.false
    %.8 =w loadw %_x
    %.6 =w csltw 7, %.8
    jnz %.6, @if.7.true, @or.9.false
@or.9.false
    %.10 =w loadw %_y
    %.9 =w csltw %.10, 0
    jnz %.9, @if.7.true, @or.8.false
@or.8.false
    %.14 =w loadw %_y
    %.12 =w csltw 7, %.14
    jnz %.12, @if.7.true, @if.7.end
@if.7.true
    ret 0
@if.7.end
    %.19 =l loadl $b
    %.23 =w loadw %_x
    %.21 =w mul 8, %.23
    %.24 =w loadw %_y
    %.20 =w add %.21, %.24
    %.25 =l extsw %.20
    %.26 =l mul 4, %.25
    %.18 =l add %.19, %.26
    %.17 =w loadw %.18
    %.16 =w ceqw %.17, 0
    ret %.16
}

export function w $go(w %.1, w %.2, w %.3) {
@start.11
    %_k =l alloc4 4
    storew %.1, %_k
    %_x =l alloc4 4
    storew %.2, %_x
    %_y =l alloc4 4
    storew %.3, %_y
@body.12
    %_i =l alloc4 4
    %_j =l alloc4 4
    %.5 =w loadw %_k
    %.7 =l loadl $b
    %.11 =w loadw %_x
    %.9 =w mul 8, %.11
    %.12 =w loadw %_y
    %.8 =w add %.9, %.12
    %.13 =l extsw %.8
    %.14 =l mul 4, %.13
    %.6 =l add %.7, %.14
    storew %.5, %.6
@if.13
    %.16 =w loadw %_k
    %.15 =w ceqw %.16, 64
    jnz %.15, @if.13.true, @if.13.false
@if.13.true
@if.14
    %.19 =w loadw %_x
    %.18 =w cnew %.19, 2
    jnz %.18, @and.16.true, @if.14.end
@and.16.true
    %.22 =w loadw %_y
    %.21 =w cnew %.22, 0
    jnz %.21, @and.15.true, @if.14.end
@and.15.true
    %.28 =w loadw %_x
    %.27 =w sub %.28, 2
    %.26 =w call extern $abs(w %.27)
    %.31 =w loadw %_y
    %.30 =w call extern $abs(w %.31)
    %.25 =w add %.26, %.30
    %.24 =w ceqw %.25, 3
    jnz %.24, @if.14.true, @if.14.end
@if.14.true
    %.33 =w call $board()
    %.35 =w loadw $N
    %.34 =w add %.35, 1
    storew %.34, $N
@if.17
    %.37 =w loadw $N
    %.36 =w ceqw %.37, 10
    jnz %.36, @if.17.true, @if.17.end
@if.17.true
    call extern $exit(w 0)
@if.17.end
@if.14.end
    jmp @if.13.end
@if.13.false
    %.43 =w sub 0, 2
    storew %.43, %_i
@while.18.cond
    %.47 =w loadw %_i
    %.46 =w cslew %.47, 2
    jnz %.46, @while.18.body, @while.18.end
@while.18.body
    %.51 =w sub 0, 2
    storew %.51, %_j
@while.19.cond
    %.55 =w loadw %_j
    %.54 =w cslew %.55, 2
    jnz %.54, @while.19.body, @while.19.end
@while.19.body
@if.20
    %.60 =w loadw %_i
    %.59 =w call extern $abs(w %.60)
    %.62 =w loadw %_j
    %.61 =w call extern $abs(w %.62)
    %.58 =w add %.59, %.61
    %.57 =w ceqw %.58, 3
    jnz %.57, @and.21.true, @if.20.end
@and.21.true
    %.66 =w loadw %_x
    %.67 =w loadw %_i
    %.65 =w add %.66, %.67
    %.69 =w loadw %_y
    %.70 =w loadw %_j
    %.68 =w add %.69, %.70
    %.64 =w call $chk(w %.65, w %.68)
    jnz %.64, @if.20.true, @if.20.end
@if.20.true
    %.73 =w loadw %_k
    %.72 =w add %.73, 1
    %.76 =w loadw %_x
    %.77 =w loadw %_i
    %.75 =w add %.76, %.77
    %.79 =w loadw %_y
    %.80 =w loadw %_j
    %.78 =w add %.79, %.80
    %.71 =w call $go(w %.72, w %.75, w %.78)
@if.20.end
    %.82 =w loadw %_j
    %.81 =w add %.82, 1
    storew %.81, %_j
    jmp @while.19.cond
@while.19.end
    %.84 =w loadw %_i
    %.83 =w add %.84, 1
    storew %.83, %_i
    jmp @while.18.cond
@while.18.end
@if.13.end
    %.88 =l loadl $b
    %.92 =w loadw %_x
    %.90 =w mul 8, %.92
    %.93 =w loadw %_y
    %.89 =w add %.90, %.93
    %.94 =l extsw %.89
    %.95 =l mul 4, %.94
    %.87 =l add %.88, %.95
    storew 0, %.87
    ret 0
}

export function w $main() {
@start.22
@body.23
    %_i =l alloc4 4
    %.2 =l call extern $malloc(w 42)
    storel %.2, $gen
    %.5 =l loadl $gen
    %.4 =l call $initBuckets(l %.5, w 4096)
    %.8 =l call extern $malloc(w 8)
    storel %.8, $t
    %.11 =l loadl $t
    call extern $time(l %.11)
    %.15 =l loadl $t
    %.14 =l call extern $ctime(l %.15)
    %.12 =w call extern $printf(l $.s5, ..., l %.14)
    %.18 =l loadl $gen
    %.19 =w mul 64, 8
    %.17 =l call $allocInBuckets(l %.18, w %.19, w 8)
    storel %.17, $b
    %.23 =w call $go(w 1, w 2, w 0)
    ret
}


# GLOBAL VARIABLES
data $N = { w 0 }
data $b = { l 0 }
data $t = { l 0 }
data $gen = { l 0 }

# STRING CONSTANTS
data $.s1 = { b "t: %s\n", b 0 }
data $.s2 = { b " %02d", b 0 }
data $.s3 = { b "\n", b 0 }
data $.s4 = { b "\n", b 0 }
data $.s5 = { b "t: %s\n", b 0 }
