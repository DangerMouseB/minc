export function w $board() {
@start.1
@body.2
	%_x =l alloc4 4
	%_y =l alloc4 4
	storew 0, %_y
@while.cond.3
	%.4 =w loadw %_y
	%.6 =l extsw %.4
	%.3 =w csltl %.6, 8
	jnz %.3, @while.body.4, @while.end.5
@while.body.4
	storew 0, %_x
@while.cond.6
	%.10 =w loadw %_x
	%.12 =l extsw %.10
	%.9 =w csltl %.12, 8
	jnz %.9, @while.body.7, @while.end.8
@while.body.7
	%.19 =l loadl $g8
	%.20 =w loadw %_x
	%.21 =l extsw %.20
	%.22 =l mul 8, %.21
	%.18 =l add %.19, %.22
	%.17 =l loadl %.18
	%.23 =w loadw %_y
	%.24 =l extsw %.23
	%.25 =l mul 4, %.24
	%.16 =l add %.17, %.25
	%.15 =w loadw %.16
	%.13 =w call $printf(l $g9, ..., w %.15)
	%.27 =w loadw %_x
	%.26 =w add %.27, 1
	storew %.26, %_x
	jmp @while.cond.6
@while.end.8
	%.28 =w call $printf(l $g10)
	%.31 =w loadw %_y
	%.30 =w add %.31, 1
	storew %.30, %_y
	jmp @while.cond.3
@while.end.5
	%.32 =w call $printf(l $g11)
	ret 0
}

export function w $chk(w %.1, w %.2) {
@start.9
	%_x =l alloc4 4
	storew %.1, %_x
	%_y =l alloc4 4
	storew %.2, %_y
@body.10
@if.11
	%.7 =w loadw %_x
	%.9 =l extsw %.7
	%.6 =w csltl %.9, 0
	%.12 =w loadw %_x
	%.13 =l extsw %.12
	%.10 =w csltl 7, %.13
	%.5 =w add %.6, %.10
	%.15 =w loadw %_y
	%.17 =l extsw %.15
	%.14 =w csltl %.17, 0
	%.4 =w add %.5, %.14
	%.20 =w loadw %_y
	%.21 =l extsw %.20
	%.18 =w csltl 7, %.21
	%.3 =w add %.4, %.18
	jnz %.3, @true.12, @false.13
@true.12
	ret 0
@false.13
	%.28 =l loadl $g8
	%.29 =w loadw %_x
	%.30 =l extsw %.29
	%.31 =l mul 8, %.30
	%.27 =l add %.28, %.31
	%.26 =l loadl %.27
	%.32 =w loadw %_y
	%.33 =l extsw %.32
	%.34 =l mul 4, %.33
	%.25 =l add %.26, %.34
	%.24 =w loadw %.25
	%.36 =l extsw %.24
	%.23 =w ceql %.36, 0
	ret %.23
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
	%.5 =w loadw %_k
	%.9 =l loadl $g8
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
	%.19 =l extsw %.17
	%.16 =w ceql %.19, 64
	jnz %.16, @true.17, @false.18
@true.17
@if.20
	%.23 =w loadw %_x
	%.25 =l extsw %.23
	%.22 =w cnel %.25, 2
	%.27 =w loadw %_y
	%.29 =l extsw %.27
	%.26 =w cnel %.29, 0
	%.21 =w add %.22, %.26
	%.34 =w loadw %_x
	%.36 =l extsw %.34
	%.33 =l sub %.36, 2
	%.32 =w call $abs(l %.33)
	%.38 =w loadw %_y
	%.37 =w call $abs(w %.38)
	%.31 =w add %.32, %.37
	%.40 =l extsw %.31
	%.30 =w ceql %.40, 3
	%.20 =w add %.21, %.30
	jnz %.20, @true.21, @false.22
@true.21
	%.41 =w call $board()
	%.43 =w loadw $g7
	%.42 =w add %.43, 1
	storew %.42, $g7
@if.23
	%.45 =w loadw $g7
	%.47 =l extsw %.45
	%.44 =w ceql %.47, 10
	jnz %.44, @true.24, @false.25
@true.24
	call $exit(l 0)
@false.25
@false.22
	jmp @L.19
@false.18
	%.52 =l sub 0, 2
	storew %.52, %_i
@while.cond.26
	%.56 =w loadw %_i
	%.58 =l extsw %.56
	%.55 =w cslel %.58, 2
	jnz %.55, @while.body.27, @while.end.28
@while.body.27
	%.61 =l sub 0, 2
	storew %.61, %_j
@while.cond.29
	%.65 =w loadw %_j
	%.67 =l extsw %.65
	%.64 =w cslel %.67, 2
	jnz %.64, @while.body.30, @while.end.31
@while.body.30
@if.32
	%.72 =w loadw %_i
	%.71 =w call $abs(w %.72)
	%.74 =w loadw %_j
	%.73 =w call $abs(w %.74)
	%.70 =w add %.71, %.73
	%.76 =l extsw %.70
	%.69 =w ceql %.76, 3
	%.79 =w loadw %_x
	%.80 =w loadw %_i
	%.78 =w add %.79, %.80
	%.82 =w loadw %_y
	%.83 =w loadw %_j
	%.81 =w add %.82, %.83
	%.77 =w call $chk(w %.78, w %.81)
	%.68 =w add %.69, %.77
	jnz %.68, @true.33, @false.34
@true.33
	%.86 =w loadw %_k
	%.88 =l extsw %.86
	%.85 =l add %.88, 1
	%.90 =w loadw %_x
	%.91 =w loadw %_i
	%.89 =w add %.90, %.91
	%.93 =w loadw %_y
	%.94 =w loadw %_j
	%.92 =w add %.93, %.94
	%.84 =w call $go(l %.85, w %.89, w %.92)
@false.34
	%.96 =w loadw %_j
	%.95 =w add %.96, 1
	storew %.95, %_j
	jmp @while.cond.29
@while.end.31
	%.98 =w loadw %_i
	%.97 =w add %.98, 1
	storew %.97, %_i
	jmp @while.cond.26
@while.end.28
@L.19
	%.104 =l loadl $g8
	%.105 =w loadw %_x
	%.106 =l extsw %.105
	%.107 =l mul 8, %.106
	%.103 =l add %.104, %.107
	%.102 =l loadl %.103
	%.108 =w loadw %_y
	%.109 =l extsw %.108
	%.110 =l mul 4, %.109
	%.101 =l add %.102, %.110
	storew 0, %.101
	ret 0
}

export function w $main() {
@start.35
@body.36
	%_i =l alloc4 4
	%.2 =l call $calloc(l 8, l 8)
	storel %.2, $g8
	storew 0, %_i
@while.cond.37
	%.8 =w loadw %_i
	%.10 =l extsw %.8
	%.7 =w csltl %.10, 8
	jnz %.7, @while.body.38, @while.end.39
@while.body.38
	%.12 =l call $calloc(l 8, l 8)
	%.16 =l loadl $g8
	%.17 =w loadw %_i
	%.18 =l extsw %.17
	%.19 =l mul 8, %.18
	%.15 =l add %.16, %.19
	storel %.12, %.15
	%.21 =w loadw %_i
	%.20 =w add %.21, 1
	storew %.20, %_i
	jmp @while.cond.37
@while.end.39
	%.22 =w call $go(l 1, l 2, l 0)
	ret
}

data $g7 = { w 0 }
data $g8 = { l 0 }
data $g9 = { b " %02d", b 0 }
data $g10 = { b "\n", b 0 }
data $g11 = { b "\n", b 0 }
