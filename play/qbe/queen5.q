export function $print(l %.1, w %.2, l %.3) {
@start.1
    %_board =l alloc8 8
    storel %.1, %_board
    %_Q =l alloc4 4
    storew %.2, %_Q
    %_s =l alloc8 8
    storel %.3, %_s
@body.2
    %_i =l alloc4 4
    %_j =l alloc4 4
    storew 0, %_j
@while.cond.3
    %.7 =w loadw %_j
    %.8 =w loadw %_Q
    %.6 =w csltw %.7, %.8
    jnz %.6, @while.body.4, @while.end.5
@while.body.4
    storew 0, %_i
@while.cond.6
    %.12 =w loadw %_i
    %.13 =w loadw %_Q
    %.11 =w csltw %.12, %.13
    jnz %.11, @while.body.7, @while.end.8
@while.body.7
@if.else.9
    %.18 =l loadl %_board
    %.19 =w loadw %_i
    %.20 =l extsw %.19
    %.21 =l mul 8, %.20
    %.17 =l add %.18, %.21
    %.16 =l loadl %.17
    %.22 =w loadw %_j
    %.23 =l extsw %.22
    %.24 =l mul 4, %.23
    %.15 =l add %.16, %.24
    %.14 =w loadw %.15
    jnz %.14, @true.10, @false.11
@true.10
    %.26 =l loadl %_s
    %.25 =w call extern $fprintf(l %.26, l $.s1)
    jmp @if.end.12
@false.11
    %.29 =l loadl %_s
    %.28 =w call extern $fprintf(l %.29, l $.s2)
@if.end.12
    %.32 =w loadw %_i
    %.31 =w add %.32, 1
    storew %.31, %_i
    jmp @while.cond.6
@while.end.8
    %.34 =l loadl %_s
    %.33 =w call extern $fprintf(l %.34, l $.s3)
    %.37 =w loadw %_j
    %.36 =w add %.37, 1
    storew %.36, %_j
    jmp @while.cond.3
@while.end.5
    %.39 =l loadl %_s
    %.38 =w call extern $fprintf(l %.39, l $.s4)
    ret
}

export function w $chk(w %.1, w %.2, l %.3, w %.4) {
@start.13
    %_i =l alloc4 4
    storew %.1, %_i
    %_j =l alloc4 4
    storew %.2, %_j
    %_board =l alloc8 8
    storel %.3, %_board
    %_Q =l alloc4 4
    storew %.4, %_Q
@body.14
    %_k =l alloc4 4
    %_r =l alloc4 4
    storew 0, %_k
    storew 0, %_r
@while.cond.15
    %.9 =w loadw %_k
    %.10 =w loadw %_Q
    %.8 =w csltw %.9, %.10
    jnz %.8, @while.body.16, @while.end.17
@while.body.16
    %.13 =w loadw %_r
    %.18 =l loadl %_board
    %.19 =w loadw %_i
    %.20 =l extsw %.19
    %.21 =l mul 8, %.20
    %.17 =l add %.18, %.21
    %.16 =l loadl %.17
    %.22 =w loadw %_k
    %.23 =l extsw %.22
    %.24 =l mul 4, %.23
    %.15 =l add %.16, %.24
    %.14 =w loadw %.15
    %.12 =w add %.13, %.14
    storew %.12, %_r
    %.27 =w loadw %_r
    %.32 =l loadl %_board
    %.33 =w loadw %_k
    %.34 =l extsw %.33
    %.35 =l mul 8, %.34
    %.31 =l add %.32, %.35
    %.30 =l loadl %.31
    %.36 =w loadw %_j
    %.37 =l extsw %.36
    %.38 =l mul 4, %.37
    %.29 =l add %.30, %.38
    %.28 =w loadw %.29
    %.26 =w add %.27, %.28
    storew %.26, %_r
@if.18
    %.42 =w loadw %_i
    %.43 =w loadw %_k
    %.41 =w add %.42, %.43
    %.44 =w loadw %_Q
    %.40 =w csltw %.41, %.44
    %.47 =w loadw %_j
    %.48 =w loadw %_k
    %.46 =w add %.47, %.48
    %.49 =w loadw %_Q
    %.45 =w csltw %.46, %.49
    %.39 =w and %.40, %.45
    jnz %.39, @true.19, @false.20
@true.19
    %.52 =w loadw %_r
    %.57 =l loadl %_board
    %.59 =w loadw %_i
    %.60 =w loadw %_k
    %.58 =w add %.59, %.60
    %.61 =l extsw %.58
    %.62 =l mul 8, %.61
    %.56 =l add %.57, %.62
    %.55 =l loadl %.56
    %.64 =w loadw %_j
    %.65 =w loadw %_k
    %.63 =w add %.64, %.65
    %.66 =l extsw %.63
    %.67 =l mul 4, %.66
    %.54 =l add %.55, %.67
    %.53 =w loadw %.54
    %.51 =w add %.52, %.53
    storew %.51, %_r
@false.20
@if.21
    %.71 =w loadw %_i
    %.72 =w loadw %_k
    %.70 =w add %.71, %.72
    %.73 =w loadw %_Q
    %.69 =w csltw %.70, %.73
    %.77 =w loadw %_j
    %.78 =w loadw %_k
    %.76 =w sub %.77, %.78
    %.74 =w cslew 0, %.76
    %.68 =w and %.69, %.74
    jnz %.68, @true.22, @false.23
@true.22
    %.81 =w loadw %_r
    %.86 =l loadl %_board
    %.88 =w loadw %_i
    %.89 =w loadw %_k
    %.87 =w add %.88, %.89
    %.90 =l extsw %.87
    %.91 =l mul 8, %.90
    %.85 =l add %.86, %.91
    %.84 =l loadl %.85
    %.93 =w loadw %_j
    %.94 =w loadw %_k
    %.92 =w sub %.93, %.94
    %.95 =l extsw %.92
    %.96 =l mul 4, %.95
    %.83 =l add %.84, %.96
    %.82 =w loadw %.83
    %.80 =w add %.81, %.82
    storew %.80, %_r
@false.23
@if.24
    %.101 =w loadw %_i
    %.102 =w loadw %_k
    %.100 =w sub %.101, %.102
    %.98 =w cslew 0, %.100
    %.105 =w loadw %_j
    %.106 =w loadw %_k
    %.104 =w add %.105, %.106
    %.107 =w loadw %_Q
    %.103 =w csltw %.104, %.107
    %.97 =w and %.98, %.103
    jnz %.97, @true.25, @false.26
@true.25
    %.110 =w loadw %_r
    %.115 =l loadl %_board
    %.117 =w loadw %_i
    %.118 =w loadw %_k
    %.116 =w sub %.117, %.118
    %.119 =l extsw %.116
    %.120 =l mul 8, %.119
    %.114 =l add %.115, %.120
    %.113 =l loadl %.114
    %.122 =w loadw %_j
    %.123 =w loadw %_k
    %.121 =w add %.122, %.123
    %.124 =l extsw %.121
    %.125 =l mul 4, %.124
    %.112 =l add %.113, %.125
    %.111 =w loadw %.112
    %.109 =w add %.110, %.111
    storew %.109, %_r
@false.26
@if.27
    %.130 =w loadw %_i
    %.131 =w loadw %_k
    %.129 =w sub %.130, %.131
    %.127 =w cslew 0, %.129
    %.135 =w loadw %_j
    %.136 =w loadw %_k
    %.134 =w sub %.135, %.136
    %.132 =w cslew 0, %.134
    %.126 =w and %.127, %.132
    jnz %.126, @true.28, @false.29
@true.28
    %.139 =w loadw %_r
    %.144 =l loadl %_board
    %.146 =w loadw %_i
    %.147 =w loadw %_k
    %.145 =w sub %.146, %.147
    %.148 =l extsw %.145
    %.149 =l mul 8, %.148
    %.143 =l add %.144, %.149
    %.142 =l loadl %.143
    %.151 =w loadw %_j
    %.152 =w loadw %_k
    %.150 =w sub %.151, %.152
    %.153 =l extsw %.150
    %.154 =l mul 4, %.153
    %.141 =l add %.142, %.154
    %.140 =w loadw %.141
    %.138 =w add %.139, %.140
    storew %.138, %_r
@false.29
    %.156 =w loadw %_k
    %.155 =w add %.156, 1
    storew %.155, %_k
    jmp @while.cond.15
@while.end.17
    %.157 =w loadw %_r
    ret %.157
}

export function w $go(w %.1, l %.2, w %.3, l %.4) {
@start.30
    %_j =l alloc4 4
    storew %.1, %_j
    %_board =l alloc8 8
    storel %.2, %_board
    %_Q =l alloc4 4
    storew %.3, %_Q
    %_s =l alloc8 8
    storel %.4, %_s
@body.31
    %_i =l alloc4 4
    %_nSolutions =l alloc4 4
    storew 0, %_nSolutions
@if.32
    %.8 =w loadw %_j
    %.9 =w loadw %_Q
    %.7 =w ceqw %.8, %.9
    jnz %.7, @true.33, @false.34
@true.33
    %.11 =l loadl %_board
    %.12 =w loadw %_Q
    %.13 =l loadl %_s
    call $print(l %.11, w %.12, l %.13)
    ret 1
@false.34
    storew 0, %_i
@while.cond.35
    %.18 =w loadw %_i
    %.19 =w loadw %_Q
    %.17 =w csltw %.18, %.19
    jnz %.17, @while.body.36, @while.end.37
@while.body.36
@if.38
    %.22 =w loadw %_i
    %.23 =w loadw %_j
    %.24 =l loadl %_board
    %.25 =w loadw %_Q
    %.21 =w call $chk(w %.22, w %.23, l %.24, w %.25)
    %.20 =w ceqw %.21, 0
    jnz %.20, @true.39, @false.40
@true.39
    %.31 =l loadl %_board
    %.32 =w loadw %_i
    %.33 =l extsw %.32
    %.34 =l mul 8, %.33
    %.30 =l add %.31, %.34
    %.29 =l loadl %.30
    %.35 =w loadw %_j
    %.36 =l extsw %.35
    %.37 =l mul 4, %.36
    %.28 =l add %.29, %.37
    %.38 =w loadw %.28
    %.27 =w add %.38, 1
    storew %.27, %.28
    %.41 =w loadw %_nSolutions
    %.44 =w loadw %_j
    %.43 =w add %.44, 1
    %.46 =l loadl %_board
    %.47 =w loadw %_Q
    %.48 =l loadl %_s
    %.42 =w call $go(w %.43, l %.46, w %.47, l %.48)
    %.40 =w add %.41, %.42
    storew %.40, %_nSolutions
    %.53 =l loadl %_board
    %.54 =w loadw %_i
    %.55 =l extsw %.54
    %.56 =l mul 8, %.55
    %.52 =l add %.53, %.56
    %.51 =l loadl %.52
    %.57 =w loadw %_j
    %.58 =l extsw %.57
    %.59 =l mul 4, %.58
    %.50 =l add %.51, %.59
    %.60 =w loadw %.50
    %.49 =w sub %.60, 1
    storew %.49, %.50
@false.40
    %.62 =w loadw %_i
    %.61 =w add %.62, 1
    storew %.61, %_i
    jmp @while.cond.35
@while.end.37
    %.63 =w loadw %_nSolutions
    ret %.63
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
    %_Q =l alloc4 4
    storew 8, %_Q
@if.48
    %.7 =w loadw %_ac
    %.5 =w cslew 2, %.7
    jnz %.5, @true.49, @false.50
@true.49
    %.12 =l loadl %_av
    %.11 =l add %.12, 8
    %.10 =l loadl %.11
    %.9 =w call extern $atoi(l %.10)
    storew %.9, %_Q
@false.50
    %.16 =w loadw %_Q
    %.15 =l call $newBoard(w %.16)
    storel %.15, %_board
    %.20 =l loadl %_board
    %.21 =w loadw %_Q
    %.22 =l loadl extern $__stdoutp
    %.18 =w call $go(w 0, l %.20, w %.21, l %.22)
    storew %.18, %_nSolutions
    %.24 =l loadl extern $__stdoutp
    %.26 =w loadw %_nSolutions
    %.23 =w call extern $fprintf(l %.24, l $.s5, ..., w %.26)
    ret
}


# STRING CONSTANTS
data $.s1 = { b " Q", b 0 }
data $.s2 = { b " .", b 0 }
data $.s3 = { b "\n", b 0 }
data $.s4 = { b "\n", b 0 }
data $.s5 = { b "found %d solutions\n", b 0 }
