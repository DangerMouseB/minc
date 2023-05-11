export function w $main() {
@Lstart.1
@Lbody.2
	%_i =l alloc4 4
	%_a =l alloc4 4
	%_b =l alloc4 4
	%_c =l alloc4 4
	%_d =l alloc4 4
	storew 1, %_a
@L3
	%.4 =w loadw %_a
	%.3 =w csltw %.4, 1000
	jnz %.3, @L4, @L5
@L4
	%.8 =w loadw %_a
	%.7 =w add %.8, 1
	storew %.7, %_b
@L6
	%.11 =w loadw %_b
	%.10 =w csltw %.11, 1000
	jnz %.10, @L7, @L8
@L7
	%.16 =w loadw %_a
	%.17 =w loadw %_a
	%.15 =w mul %.16, %.17
	%.19 =w loadw %_b
	%.20 =w loadw %_b
	%.18 =w mul %.19, %.20
	%.14 =w add %.15, %.18
	storew %.14, %_d
	storew 0, %_i
@L9
	%.24 =w loadw %_i
	%.23 =w csltw %.24, 1000
	jnz %.23, @L10, @L11
@L10
	%.28 =w loadw %_i
	%.29 =w loadw %_i
	%.27 =w mul %.28, %.29
	%.30 =w loadw %_d
	%.26 =w ceqw %.27, %.30
	jnz %.26, @L12, @L13
@L12
	%.32 =w loadw %_i
	storew %.32, %_c
	%.35 =w loadw %_b
	%.36 =w loadw %_c
	%.34 =w csltw %.35, %.36
	%.40 =w loadw %_a
	%.41 =w loadw %_b
	%.39 =w add %.40, %.41
	%.42 =w loadw %_c
	%.38 =w add %.39, %.42
	%.37 =w ceqw %.38, 1000
	%.33 =w add %.34, %.37
	jnz %.33, @L14, @L15
@L14
	%.48 =w loadw %_a
	%.49 =w loadw %_b
	%.47 =w mul %.48, %.49
	%.50 =w loadw %_c
	%.46 =w mul %.47, %.50
	%.44 =w call $printf(l $g2, ..., w %.46)
	ret 0
@L15
	jmp @L11
@L13
	%.53 =w loadw %_i
	%.52 =w add %.53, 1
	storew %.52, %_i
	jmp @L9
@L11
	%.55 =w loadw %_b
	%.54 =w add %.55, 1
	storew %.54, %_b
	jmp @L6
@L8
	%.57 =w loadw %_a
	%.56 =w add %.57, 1
	storew %.56, %_a
	jmp @L3
@L5
	ret
}

data $g2 = { b "%d\n", b 0 }
