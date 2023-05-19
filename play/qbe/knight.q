export function w $board() {
@start.1
@body.2
	%_x =l alloc4 4
	%_y =l alloc4 4
	storew 0, %_y
@while.cond.3
	%.4 =w loadw %_y
	%.3 =w csltw %.4, 8
	jnz %.3, @while.body.4, @while.end.5
@while.body.4
	storew 0, %_x
@while.cond.6
	%.9 =w loadw %_x
	%.8 =w csltw %.9, 8
	jnz %.8, @while.body.7, @while.end.8
@while.body.7
	%.17 =l loadl $g10
	%.18 =w loadw %_x
	%.19 =l extsw %.18
	%.20 =l mul 8, %.19
	%.16 =l add %.17, %.20
	%.15 =l loadl %.16
	%.21 =w loadw %_y
	%.22 =l extsw %.21
	%.23 =l mul 4, %.22
	%.14 =l add %.15, %.23
	%.13 =w loadw %.14
	%.11 =w call $printf(l $g11, ..., w %.13)
	%.25 =w loadw %_x
	%.24 =w add %.25, 1
	storew %.24, %_x
	jmp @while.cond.6
@while.end.8
	%.26 =w call $printf(l $g12)
	%.29 =w loadw %_y
	%.28 =w add %.29, 1
	storew %.28, %_y
	jmp @while.cond.3
@while.end.5
	%.30 =w call $printf(l $g13)
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
	%.6 =w csltw %.7, 0
	%.11 =w loadw %_x
	%.9 =w csltw 7, %.11
	%.5 =w add %.6, %.9
	%.13 =w loadw %_y
	%.12 =w csltw %.13, 0
	%.4 =w add %.5, %.12
	%.17 =w loadw %_y
	%.15 =w csltw 7, %.17
	%.3 =w add %.4, %.15
	jnz %.3, @true.12, @false.13
@true.12
	ret 0
@false.13
	%.24 =l loadl $g10
	%.25 =w loadw %_x
	%.26 =l extsw %.25
	%.27 =l mul 8, %.26
	%.23 =l add %.24, %.27
	%.22 =l loadl %.23
	%.28 =w loadw %_y
	%.29 =l extsw %.28
	%.30 =l mul 4, %.29
	%.21 =l add %.22, %.30
	%.20 =w loadw %.21
	%.19 =w ceqw %.20, 0
	ret %.19
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
	%.9 =l loadl $g10
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
	%.22 =w loadw %_x
	%.21 =w cnew %.22, 2
	%.25 =w loadw %_y
	%.24 =w cnew %.25, 0
	%.20 =w add %.21, %.24
	%.31 =w loadw %_x
	%.30 =w sub %.31, 2
	%.29 =w call extern $abs(w %.30)
	%.34 =w loadw %_y
	%.33 =w call extern $abs(w %.34)
	%.28 =w add %.29, %.33
	%.27 =w ceqw %.28, 3
	%.19 =w add %.20, %.27
	jnz %.19, @true.21, @false.22
@true.21
	%.36 =w call $board()
	%.38 =w loadw $g9
	%.37 =w add %.38, 1
	storew %.37, $g9
@if.23
	%.40 =w loadw $g9
	%.39 =w ceqw %.40, 10
	jnz %.39, @true.24, @false.25
@true.24
	call extern $exit(w 0)
@false.25
@false.22
	jmp @if.end.19
@false.18
	%.46 =w sub 0, 2
	storew %.46, %_i
@while.cond.26
	%.50 =w loadw %_i
	%.49 =w cslew %.50, 2
	jnz %.49, @while.body.27, @while.end.28
@while.body.27
	%.54 =w sub 0, 2
	storew %.54, %_j
@while.cond.29
	%.58 =w loadw %_j
	%.57 =w cslew %.58, 2
	jnz %.57, @while.body.30, @while.end.31
@while.body.30
@if.32
	%.64 =w loadw %_i
	%.63 =w call extern $abs(w %.64)
	%.66 =w loadw %_j
	%.65 =w call extern $abs(w %.66)
	%.62 =w add %.63, %.65
	%.61 =w ceqw %.62, 3
	%.70 =w loadw %_x
	%.71 =w loadw %_i
	%.69 =w add %.70, %.71
	%.73 =w loadw %_y
	%.74 =w loadw %_j
	%.72 =w add %.73, %.74
	%.68 =w call $chk(w %.69, w %.72)
	%.60 =w add %.61, %.68
	jnz %.60, @true.33, @false.34
@true.33
	%.77 =w loadw %_k
	%.76 =w add %.77, 1
	%.80 =w loadw %_x
	%.81 =w loadw %_i
	%.79 =w add %.80, %.81
	%.83 =w loadw %_y
	%.84 =w loadw %_j
	%.82 =w add %.83, %.84
	%.75 =w call $go(w %.76, w %.79, w %.82)
@false.34
	%.86 =w loadw %_j
	%.85 =w add %.86, 1
	storew %.85, %_j
	jmp @while.cond.29
@while.end.31
	%.88 =w loadw %_i
	%.87 =w add %.88, 1
	storew %.87, %_i
	jmp @while.cond.26
@while.end.28
@if.end.19
	%.94 =l loadl $g10
	%.95 =w loadw %_x
	%.96 =l extsw %.95
	%.97 =l mul 8, %.96
	%.93 =l add %.94, %.97
	%.92 =l loadl %.93
	%.98 =w loadw %_y
	%.99 =l extsw %.98
	%.100 =l mul 4, %.99
	%.91 =l add %.92, %.100
	storew 0, %.91
	ret 0
}

export function w $main() {
@start.35
@body.36
	%_i =l alloc4 4
	%.2 =l call extern $calloc(w 8, w 8)
	storel %.2, $g10
	storew 0, %_i
@while.cond.37
	%.8 =w loadw %_i
	%.7 =w csltw %.8, 8
	jnz %.7, @while.body.38, @while.end.39
@while.body.38
	%.11 =l call extern $calloc(w 8, w 8)
	%.15 =l loadl $g10
	%.16 =w loadw %_i
	%.17 =l extsw %.16
	%.18 =l mul 8, %.17
	%.14 =l add %.15, %.18
	storel %.11, %.14
	%.20 =w loadw %_i
	%.19 =w add %.20, 1
	storew %.19, %_i
	jmp @while.cond.37
@while.end.39
	%.21 =w call $go(w 1, w 2, w 0)
	ret
}


# GLOBAL VARIABLES
data $g9 = { w 0 }
data $g10 = { l 0 }

# STRING CONSTANTS
data $g11 = { b " %02d", b 0 }
data $g12 = { b "\n", b 0 }
data $g13 = { b "\n", b 0 }
