export function w $board() {
@L0
	%_x =l alloc4 4
	%_y =l alloc4 4
	storew 0, %_y
@L1
	%t3 =w loadw %_y
	%t2 =w csltw %t3, 8
	jnz %t2, @L2, @L3
@L2
	storew 0, %_x
@L4
	%t8 =w loadw %_x
	%t7 =w csltw %t8, 8
	jnz %t7, @L5, @L6
@L5
	%t16 =l loadl $g2
	%t17 =w loadw %_x
	%t18 =l extsw %t17
	%t19 =l mul 8, %t18
	%t15 =l add %t16, %t19
	%t14 =l loadl %t15
	%t20 =w loadw %_y
	%t21 =l extsw %t20
	%t22 =l mul 4, %t21
	%t13 =l add %t14, %t22
	%t12 =w loadw %t13
	%t10 =w call $printf(l $g3, w %t12, ...)
	%t24 =w loadw %_x
	%t23 =w add %t24, 1
	storew %t23, %_x
	jmp @L4
@L6
	%t25 =w call $printf(l $g4, ...)
	%t28 =w loadw %_y
	%t27 =w add %t28, 1
	storew %t27, %_y
	jmp @L1
@L3
	%t29 =w call $printf(l $g5, ...)
	ret 0
}

export function w $chk(w %t0, w %t1) {
@L7
	%_x =l alloc4 4
	storew %t0, %_x
	%_y =l alloc4 4
	storew %t1, %_y
	%t3 =w loadw %_x
	%t2 =w csltw %t3, 0
	jnz %t2, @L8, @L12
@L12
	%t7 =w loadw %_x
	%t5 =w csltw 7, %t7
	jnz %t5, @L8, @L11
@L11
	%t9 =w loadw %_y
	%t8 =w csltw %t9, 0
	jnz %t8, @L8, @L10
@L10
	%t13 =w loadw %_y
	%t11 =w csltw 7, %t13
	jnz %t11, @L8, @L9
@L8
	ret 0
@L9
	%t20 =l loadl $g2
	%t21 =w loadw %_x
	%t22 =l extsw %t21
	%t23 =l mul 8, %t22
	%t19 =l add %t20, %t23
	%t18 =l loadl %t19
	%t24 =w loadw %_y
	%t25 =l extsw %t24
	%t26 =l mul 4, %t25
	%t17 =l add %t18, %t26
	%t16 =w loadw %t17
	%t15 =w ceqw %t16, 0
	ret %t15
}

export function w $go(w %t0, w %t1, w %t2) {
@L13
	%_k =l alloc4 4
	storew %t0, %_k
	%_x =l alloc4 4
	storew %t1, %_x
	%_y =l alloc4 4
	storew %t2, %_y
	%_i =l alloc4 4
	%_j =l alloc4 4
	%t4 =w loadw %_k
	%t8 =l loadl $g2
	%t9 =w loadw %_x
	%t10 =l extsw %t9
	%t11 =l mul 8, %t10
	%t7 =l add %t8, %t11
	%t6 =l loadl %t7
	%t12 =w loadw %_y
	%t13 =l extsw %t12
	%t14 =l mul 4, %t13
	%t5 =l add %t6, %t14
	storew %t4, %t5
	%t16 =w loadw %_k
	%t15 =w ceqw %t16, 64
	jnz %t15, @L14, @L15
@L14
	%t19 =w loadw %_x
	%t18 =w cnew %t19, 2
	jnz %t18, @L20, @L18
@L20
	%t22 =w loadw %_y
	%t21 =w cnew %t22, 0
	jnz %t21, @L19, @L18
@L19
	%t28 =w loadw %_x
	%t27 =w sub %t28, 2
	%t26 =w call $abs(w %t27, ...)
	%t31 =w loadw %_y
	%t30 =w call $abs(w %t31, ...)
	%t25 =w add %t26, %t30
	%t24 =w ceqw %t25, 3
	jnz %t24, @L17, @L18
@L17
	%t33 =w call $board(...)
	%t35 =w loadw $g1
	%t34 =w add %t35, 1
	storew %t34, $g1
	%t37 =w loadw $g1
	%t36 =w ceqw %t37, 10
	jnz %t36, @L21, @L22
@L21
	%t39 =w call $exit(w 0, ...)
@L22
@L18
	jmp @L16
@L15
	%t42 =w sub 0, 2
	storew %t42, %_i
@L23
	%t46 =w loadw %_i
	%t45 =w cslew %t46, 2
	jnz %t45, @L24, @L25
@L24
	%t49 =w sub 0, 2
	storew %t49, %_j
@L26
	%t53 =w loadw %_j
	%t52 =w cslew %t53, 2
	jnz %t52, @L27, @L28
@L27
	%t58 =w loadw %_i
	%t57 =w call $abs(w %t58, ...)
	%t60 =w loadw %_j
	%t59 =w call $abs(w %t60, ...)
	%t56 =w add %t57, %t59
	%t55 =w ceqw %t56, 3
	jnz %t55, @L31, @L30
@L31
	%t64 =w loadw %_x
	%t65 =w loadw %_i
	%t63 =w add %t64, %t65
	%t67 =w loadw %_y
	%t68 =w loadw %_j
	%t66 =w add %t67, %t68
	%t62 =w call $chk(w %t63, w %t66, ...)
	jnz %t62, @L29, @L30
@L29
	%t71 =w loadw %_k
	%t70 =w add %t71, 1
	%t74 =w loadw %_x
	%t75 =w loadw %_i
	%t73 =w add %t74, %t75
	%t77 =w loadw %_y
	%t78 =w loadw %_j
	%t76 =w add %t77, %t78
	%t69 =w call $go(w %t70, w %t73, w %t76, ...)
@L30
	%t80 =w loadw %_j
	%t79 =w add %t80, 1
	storew %t79, %_j
	jmp @L26
@L28
	%t82 =w loadw %_i
	%t81 =w add %t82, 1
	storew %t81, %_i
	jmp @L23
@L25
@L16
	%t88 =l loadl $g2
	%t89 =w loadw %_x
	%t90 =l extsw %t89
	%t91 =l mul 8, %t90
	%t87 =l add %t88, %t91
	%t86 =l loadl %t87
	%t92 =w loadw %_y
	%t93 =l extsw %t92
	%t94 =l mul 4, %t93
	%t85 =l add %t86, %t94
	storew 0, %t85
	ret 0
}

export function w $main() {
@L32
	%_i =l alloc4 4
	%t1 =l call $calloc(w 8, w 8, ...)
	storel %t1, $g2
	storew 0, %_i
@L33
	%t7 =w loadw %_i
	%t6 =w csltw %t7, 8
	jnz %t6, @L34, @L35
@L34
	%t10 =l call $calloc(w 8, w 4, ...)
	%t14 =l loadl $g2
	%t15 =w loadw %_i
	%t16 =l extsw %t15
	%t17 =l mul 8, %t16
	%t13 =l add %t14, %t17
	storel %t10, %t13
	%t19 =w loadw %_i
	%t18 =w add %t19, 1
	storew %t18, %_i
	jmp @L33
@L35
	%t20 =w call $go(w 1, w 2, w 0, ...)
	ret 0
}

data $g1 = { w 0 }
data $g2 = { l 0 }
data $g3 = { b " %02d", b 0 }
data $g4 = { b "\n", b 0 }
data $g5 = { b "\n", b 0 }
