export function w $main() {
@L0
	%_n =l alloc4 4
	%_t =l alloc4 4
	%_c =l alloc4 4
	%_p =l alloc4 4
	storew 0, %_c
	storew 2, %_n
@L1
	%t5 =w loadw %_n
	%t4 =w csltw %t5, 5000
	jnz %t4, @L2, @L3
@L2
	storew 2, %_t
	storew 1, %_p
@L4
	%t13 =w loadw %_t
	%t14 =w loadw %_t
	%t12 =w mul %t13, %t14
	%t15 =w loadw %_n
	%t11 =w cslew %t12, %t15
	jnz %t11, @L5, @L6
@L5
	%t18 =w loadw %_n
	%t19 =w loadw %_t
	%t17 =w rem %t18, %t19
	%t16 =w ceqw %t17, 0
	jnz %t16, @L7, @L8
@L7
	storew 0, %_p
@L8
	%t24 =w loadw %_t
	%t23 =w add %t24, 1
	storew %t23, %_t
	jmp @L4
@L6
	%t25 =w loadw %_p
	jnz %t25, @L9, @L10
@L9
	%t26 =w loadw %_c
	jnz %t26, @L13, @L12
@L13
	%t29 =w loadw %_c
	%t28 =w rem %t29, 10
	%t27 =w ceqw %t28, 0
	jnz %t27, @L11, @L12
@L11
	%t32 =w call $printf(l $g1, ...)
@L12
	%t36 =w loadw %_n
	%t34 =w call $printf(l $g2, ..., w %t36)
	%t38 =w loadw %_c
	%t37 =w add %t38, 1
	storew %t37, %_c
@L10
	%t40 =w loadw %_n
	%t39 =w add %t40, 1
	storew %t39, %_n
	jmp @L1
@L3
	%t41 =w call $printf(l $g3, ...)
	ret 0
}

data $g1 = { b "\n", b 0 }
data $g2 = { b "%4d ", b 0 }
data $g3 = { b "\n", b 0 }
