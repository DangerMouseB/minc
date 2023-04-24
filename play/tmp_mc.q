export function w $go(w %t0, l %t1) {
@L0
	%_j =l alloc4 4
	storew %t0, %_j
	%_board =l alloc8 8
	storel %t1, %_board
	%_i =l alloc4 4
	%t3 =w loadw %_j
	%t4 =w loadw $g1
	%t2 =w ceqw %t3, %t4
	jnz %t2, @L1, @L2
@L1
	%t6 =l loadl %_board
	%t5 =w call $print(l %t6, ...)
	%t8 =w loadw $g2
	%t7 =w add %t8, 1
	storew %t7, $g2
	ret 0
@L2
	storew 0, %_i
@L3
	%t13 =w loadw %_i
	%t14 =w loadw $g1
	%t12 =w csltw %t13, %t14
	jnz %t12, @L4, @L5
@L4
	%t17 =w loadw %_i
	%t18 =w loadw %_j
	%t19 =l loadl %_board
	%t16 =w call $chk(w %t17, w %t18, l %t19, ...)
	%t15 =w ceqw %t16, 0
	jnz %t15, @L6, @L7
@L6
	%t25 =l loadl %_board
	%t26 =w loadw %_i
	%t27 =l extsw %t26
	%t28 =l mul 8, %t27
	%t24 =l add %t25, %t28
	%t23 =l loadl %t24
	%t29 =w loadw %_j
	%t30 =l extsw %t29
	%t31 =l mul 4, %t30
	%t22 =l add %t23, %t31
	%t32 =w loadw %t22
	%t21 =w add %t32, 1
	storew %t21, %t22
	%t35 =w loadw %_j
	%t34 =w add %t35, 1
	%t37 =l loadl %_board
	%t33 =w call $go(w %t34, l %t37, ...)
	%t42 =l loadl %_board
	%t43 =w loadw %_i
	%t44 =l extsw %t43
	%t45 =l mul 8, %t44
	%t41 =l add %t42, %t45
	%t40 =l loadl %t41
	%t46 =w loadw %_j
	%t47 =l extsw %t46
	%t48 =l mul 4, %t47
	%t39 =l add %t40, %t48
	%t49 =w loadw %t39
	%t38 =w sub %t49, 1
	storew %t38, %t39
@L7
	%t51 =w loadw %_i
	%t50 =w add %t51, 1
	storew %t50, %_i
	jmp @L3
@L5
	ret 0
}

data $g1 = { w 0 }
data $g2 = { w 0 }
