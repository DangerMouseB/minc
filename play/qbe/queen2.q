export function $print(l %.1) {
@start.1
    %_board =l alloc8 8
    storel %.1, %_board
@body.2
    %_i =l alloc4 4
    %_j =l alloc4 4
    storew 0, %_j
@while.cond.3
    %.5 =w loadw %_j
    %.6 =w loadw $Q
    %.4 =w csltw %.5, %.6
    jnz %.4, @while.body.4, @while.end.5
@while.body.4
    storew 0, %_i
@while.cond.6
    %.10 =w loadw %_i
    %.11 =w loadw $Q
    %.9 =w csltw %.10, %.11
    jnz %.9, @while.body.7, @while.end.8
@while.body.7
@if.else.9
    %.16 =l loadl %_board
    %.17 =w loadw %_i
    %.18 =l extsw %.17
    %.19 =l mul 8, %.18
    %.15 =l add %.16, %.19
    %.14 =l loadl %.15
    %.20 =w loadw %_j
    %.21 =l extsw %.20
    %.22 =l mul 4, %.21
    %.13 =l add %.14, %.22
    %.12 =w loadw %.13
    jnz %.12, @true.10, @false.11
@true.10
    %.23 =w call extern $printf(l $.s1)
    jmp @if.end.12
@false.11
    %.25 =w call extern $printf(l $.s2)
@if.end.12
    %.28 =w loadw %_i
    %.27 =w add %.28, 1
    storew %.27, %_i
    jmp @while.cond.6
@while.end.8
    %.29 =w call extern $printf(l $.s3)
    %.32 =w loadw %_j
    %.31 =w add %.32, 1
    storew %.31, %_j
    jmp @while.cond.3
@while.end.5
    %.33 =w call extern $printf(l $.s4)
    ret
}

export function w $chk(w %.1, w %.2, l %.3) {
@start.13
    %_i =l alloc4 4
    storew %.1, %_i
    %_j =l alloc4 4
    storew %.2, %_j
    %_board =l alloc8 8
    storel %.3, %_board
@body.14
    %_k =l alloc4 4
    %_r =l alloc4 4
    storew 0, %_k
    storew 0, %_r
@while.cond.15
    %.8 =w loadw %_k
    %.9 =w loadw $Q
    %.7 =w csltw %.8, %.9
    jnz %.7, @while.body.16, @while.end.17
@while.body.16
    %.12 =w loadw %_r
    %.17 =l loadl %_board
    %.18 =w loadw %_i
    %.19 =l extsw %.18
    %.20 =l mul 8, %.19
    %.16 =l add %.17, %.20
    %.15 =l loadl %.16
    %.21 =w loadw %_k
    %.22 =l extsw %.21
    %.23 =l mul 4, %.22
    %.14 =l add %.15, %.23
    %.13 =w loadw %.14
    %.11 =w add %.12, %.13
    storew %.11, %_r
    %.26 =w loadw %_r
    %.31 =l loadl %_board
    %.32 =w loadw %_k
    %.33 =l extsw %.32
    %.34 =l mul 8, %.33
    %.30 =l add %.31, %.34
    %.29 =l loadl %.30
    %.35 =w loadw %_j
    %.36 =l extsw %.35
    %.37 =l mul 4, %.36
    %.28 =l add %.29, %.37
    %.27 =w loadw %.28
    %.25 =w add %.26, %.27
    storew %.25, %_r
@if.18
    %.41 =w loadw %_i
    %.42 =w loadw %_k
    %.40 =w add %.41, %.42
    %.43 =w loadw $Q
    %.39 =w csltw %.40, %.43
    %.46 =w loadw %_j
    %.47 =w loadw %_k
    %.45 =w add %.46, %.47
    %.48 =w loadw $Q
    %.44 =w csltw %.45, %.48
    %.38 =w and %.39, %.44
    jnz %.38, @true.19, @false.20
@true.19
    %.51 =w loadw %_r
    %.56 =l loadl %_board
    %.58 =w loadw %_i
    %.59 =w loadw %_k
    %.57 =w add %.58, %.59
    %.60 =l extsw %.57
    %.61 =l mul 8, %.60
    %.55 =l add %.56, %.61
    %.54 =l loadl %.55
    %.63 =w loadw %_j
    %.64 =w loadw %_k
    %.62 =w add %.63, %.64
    %.65 =l extsw %.62
    %.66 =l mul 4, %.65
    %.53 =l add %.54, %.66
    %.52 =w loadw %.53
    %.50 =w add %.51, %.52
    storew %.50, %_r
@false.20
@if.21
    %.70 =w loadw %_i
    %.71 =w loadw %_k
    %.69 =w add %.70, %.71
    %.72 =w loadw $Q
    %.68 =w csltw %.69, %.72
    %.76 =w loadw %_j
    %.77 =w loadw %_k
    %.75 =w sub %.76, %.77
    %.73 =w cslew 0, %.75
    %.67 =w and %.68, %.73
    jnz %.67, @true.22, @false.23
@true.22
    %.80 =w loadw %_r
    %.85 =l loadl %_board
    %.87 =w loadw %_i
    %.88 =w loadw %_k
    %.86 =w add %.87, %.88
    %.89 =l extsw %.86
    %.90 =l mul 8, %.89
    %.84 =l add %.85, %.90
    %.83 =l loadl %.84
    %.92 =w loadw %_j
    %.93 =w loadw %_k
    %.91 =w sub %.92, %.93
    %.94 =l extsw %.91
    %.95 =l mul 4, %.94
    %.82 =l add %.83, %.95
    %.81 =w loadw %.82
    %.79 =w add %.80, %.81
    storew %.79, %_r
@false.23
@if.24
    %.100 =w loadw %_i
    %.101 =w loadw %_k
    %.99 =w sub %.100, %.101
    %.97 =w cslew 0, %.99
    %.104 =w loadw %_j
    %.105 =w loadw %_k
    %.103 =w add %.104, %.105
    %.106 =w loadw $Q
    %.102 =w csltw %.103, %.106
    %.96 =w and %.97, %.102
    jnz %.96, @true.25, @false.26
@true.25
    %.109 =w loadw %_r
    %.114 =l loadl %_board
    %.116 =w loadw %_i
    %.117 =w loadw %_k
    %.115 =w sub %.116, %.117
    %.118 =l extsw %.115
    %.119 =l mul 8, %.118
    %.113 =l add %.114, %.119
    %.112 =l loadl %.113
    %.121 =w loadw %_j
    %.122 =w loadw %_k
    %.120 =w add %.121, %.122
    %.123 =l extsw %.120
    %.124 =l mul 4, %.123
    %.111 =l add %.112, %.124
    %.110 =w loadw %.111
    %.108 =w add %.109, %.110
    storew %.108, %_r
@false.26
@if.27
    %.129 =w loadw %_i
    %.130 =w loadw %_k
    %.128 =w sub %.129, %.130
    %.126 =w cslew 0, %.128
    %.134 =w loadw %_j
    %.135 =w loadw %_k
    %.133 =w sub %.134, %.135
    %.131 =w cslew 0, %.133
    %.125 =w and %.126, %.131
    jnz %.125, @true.28, @false.29
@true.28
    %.138 =w loadw %_r
    %.143 =l loadl %_board
    %.145 =w loadw %_i
    %.146 =w loadw %_k
    %.144 =w sub %.145, %.146
    %.147 =l extsw %.144
    %.148 =l mul 8, %.147
    %.142 =l add %.143, %.148
    %.141 =l loadl %.142
    %.150 =w loadw %_j
    %.151 =w loadw %_k
    %.149 =w sub %.150, %.151
    %.152 =l extsw %.149
    %.153 =l mul 4, %.152
    %.140 =l add %.141, %.153
    %.139 =w loadw %.140
    %.137 =w add %.138, %.139
    storew %.137, %_r
@false.29
    %.155 =w loadw %_k
    %.154 =w add %.155, 1
    storew %.154, %_k
    jmp @while.cond.15
@while.end.17
    %.156 =w loadw %_r
    ret %.156
}

export function w $go(w %.1, l %.2, w %.3) {
@start.30
    %_j =l alloc4 4
    storew %.1, %_j
    %_board =l alloc8 8
    storel %.2, %_board
    %_nSolutions =l alloc4 4
    storew %.3, %_nSolutions
@body.31
    %_i =l alloc4 4
@if.32
    %.5 =w loadw %_j
    %.6 =w loadw $Q
    %.4 =w ceqw %.5, %.6
    jnz %.4, @true.33, @false.34
@true.33
    %.8 =l loadl %_board
    call $print(l %.8)
    %.10 =w loadw %_nSolutions
    %.9 =w add %.10, 1
    ret %.9
@false.34
    storew 0, %_i
@while.cond.35
    %.15 =w loadw %_i
    %.16 =w loadw $Q
    %.14 =w csltw %.15, %.16
    jnz %.14, @while.body.36, @while.end.37
@while.body.36
@if.38
    %.19 =w loadw %_i
    %.20 =w loadw %_j
    %.21 =l loadl %_board
    %.18 =w call $chk(w %.19, w %.20, l %.21)
    %.17 =w ceqw %.18, 0
    jnz %.17, @true.39, @false.40
@true.39
    %.27 =l loadl %_board
    %.28 =w loadw %_i
    %.29 =l extsw %.28
    %.30 =l mul 8, %.29
    %.26 =l add %.27, %.30
    %.25 =l loadl %.26
    %.31 =w loadw %_j
    %.32 =l extsw %.31
    %.33 =l mul 4, %.32
    %.24 =l add %.25, %.33
    %.34 =w loadw %.24
    %.23 =w add %.34, 1
    storew %.23, %.24
    %.38 =w loadw %_j
    %.37 =w add %.38, 1
    %.40 =l loadl %_board
    %.41 =w loadw %_nSolutions
    %.36 =w call $go(w %.37, l %.40, w %.41)
    storew %.36, %_nSolutions
    %.46 =l loadl %_board
    %.47 =w loadw %_i
    %.48 =l extsw %.47
    %.49 =l mul 8, %.48
    %.45 =l add %.46, %.49
    %.44 =l loadl %.45
    %.50 =w loadw %_j
    %.51 =l extsw %.50
    %.52 =l mul 4, %.51
    %.43 =l add %.44, %.52
    %.53 =w loadw %.43
    %.42 =w sub %.53, 1
    storew %.42, %.43
@false.40
    %.55 =w loadw %_i
    %.54 =w add %.55, 1
    storew %.54, %_i
    jmp @while.cond.35
@while.end.37
    %.56 =w loadw %_nSolutions
    ret %.56
}

export function l $newBoard(w %.1) {
@start.41
    %_N =l alloc4 4
    storew %.1, %_N
@body.42
    %_answer =l alloc8 8
    %_i =l alloc4 4
    %.4 =w loadw %_N
    %.3 =l call extern $calloc(w %.4, w 8)
    storel %.3, %_answer
    storew 0, %_i
@while.cond.43
    %.9 =w loadw %_i
    %.10 =w loadw %_N
    %.8 =w csltw %.9, %.10
    jnz %.8, @while.body.44, @while.end.45
@while.body.44
    %.13 =w loadw %_N
    %.12 =l call extern $calloc(w %.13, w 8)
    %.16 =l loadl %_answer
    %.17 =w loadw %_i
    %.18 =l extsw %.17
    %.19 =l mul 8, %.18
    %.15 =l add %.16, %.19
    storel %.12, %.15
    %.21 =w loadw %_i
    %.20 =w add %.21, 1
    storew %.20, %_i
    jmp @while.cond.43
@while.end.45
    %.22 =l loadl %_answer
    ret %.22
}

export function w $main(w %.1, l %.2) {
@start.46
    %_ac =l alloc4 4
    storew %.1, %_ac
    %_av =l alloc8 8
    storel %.2, %_av
@body.47
    %_board =l alloc8 8
    %_nSolutions =l alloc4 4
    storew 8, $Q
@if.48
    %.7 =w loadw %_ac
    %.5 =w cslew 2, %.7
    jnz %.5, @true.49, @false.50
@true.49
    %.12 =l loadl %_av
    %.11 =l add %.12, 8
    %.10 =l loadl %.11
    %.9 =w call extern $atoi(l %.10)
    storew %.9, $Q
@false.50
    %.16 =w loadw $Q
    %.15 =l call $newBoard(w %.16)
    storel %.15, %_board
    %.20 =l loadl %_board
    %.18 =w call $go(w 0, l %.20, w 0)
    storew %.18, %_nSolutions
    %.24 =w loadw %_nSolutions
    %.22 =w call extern $printf(l $.s5, ..., w %.24)
    ret
}


# GLOBAL VARIABLES
data $Q = { w 0 }

# STRING CONSTANTS
data $.s1 = { b " Q", b 0 }
data $.s2 = { b " .", b 0 }
data $.s3 = { b "\n", b 0 }
data $.s4 = { b "\n", b 0 }
data $.s5 = { b "found %d solutions\n", b 0 }
