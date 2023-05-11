export function w $main() {
@Lstart.1
@Lbody.2
	%_n =l alloc4 4
	%_t =l alloc4 4
	%_c =l alloc4 4
	%_p =l alloc4 4
	storew 0, %_c
	storew 2, %_n
@L3
	%.6 =w loadw %_n
	%.5 =w csltw %.6, 5000
	jnz %.5, @L4, @L5
@L4
	storew 2, %_t
	storew 1, %_p
@L6
	%.14 =w loadw %_t
	%.15 =w loadw %_t
	%.13 =w mul %.14, %.15
	%.16 =w loadw %_n
	%.12 =w cslew %.13, %.16
	jnz %.12, @L7, @L8
@L7
	%.19 =w loadw %_n
	%.20 =w loadw %_t
	%.18 =w rem %.19, %.20
	%.17 =w ceqw %.18, 0
	jnz %.17, @L9, @L10
@L9
	storew 0, %_p
@L10
	%.25 =w loadw %_t
	%.24 =w add %.25, 1
	storew %.24, %_t
	jmp @L6
@L8
	%.26 =w loadw %_p
	jnz %.26, @L11, @L12
@L11
	%.28 =w loadw %_c
	%.31 =w loadw %_c
	%.30 =w rem %.31, 10
	%.29 =w ceqw %.30, 0
	%.27 =w add %.28, %.29
	jnz %.27, @L13, @L14
@L13
	%.34 =w call $printf(l $g2)
@L14
	%.38 =w loadw %_n
	%.36 =w call $printf(l $g3, ..., w %.38)
	%.40 =w loadw %_c
	%.39 =w add %.40, 1
	storew %.39, %_c
@L12
	%.42 =w loadw %_n
	%.41 =w add %.42, 1
	storew %.41, %_n
	jmp @L3
@L5
	%.43 =w call $printf(l $g4)
	ret
}

data $g2 = { b "\n", b 0 }
data $g3 = { b "%4d ", b 0 }
data $g4 = { b "\n", b 0 }
