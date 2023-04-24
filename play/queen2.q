export function $print(w %t1) {
@L0
	%_ =l alloc4 4
	storew %t1, %_
	%_i =l alloc4 4
	%_j =l alloc4 4
	storew 0, %_j
	storew 0, %_j
@L1
	%t6 =w loadw %_j
	%t7 =w loadw $g2
	%t5 =w csltw %t6, %t7
	jnz %t5, @L2, @L3
@L2
	storew 0, %_i
	storew 0, %_i
@L4
	%t12 =w loadw %_i
	%t13 =w loadw $g2
	%t11 =w csltw %t12, %t13
	jnz %t11, @L5, @L6
@L5
	%t14 =w loadw %_j
	jnz %t14, @L7, @L8
@L7
	jmp @L9
@L8
@L9
	%t18 =w loadw %_i
	%t17 =w add %t18, 1
	storew %t17, %_i
	jmp @L4
@L6
	%t21 =w loadw %_j
	%t20 =w add %t21, 1
	storew %t20, %_j
	jmp @L1
@L3
	ret
}

export function w $chk(w %t1, w %t2) {
@L10
	%_ =l alloc4 4
	storew %t1, %_
	%_ =l alloc4 4
	storew %t2, %_
	%_k =l alloc4 4
	%_r =l alloc4 4
	storew 0, %_k
	storew 0, %_k
	storew 0, %_r
	storew 0, %_r
@L11
	%t9 =w loadw %_k
	%t10 =w loadw $g2
	%t8 =w csltw %t9, %t10
	jnz %t8, @L12, @L13
@L12
	%t14 =w loadw %_r
	%t15 =w loadw %_k
	%t13 =w add %t14, %t15
	storew %t13, %_r
	storew %t13, %_r
	%t19 =w loadw %_r
	%t20 =w loadw %_j
	%t18 =w add %t19, %t20
	storew %t18, %_r
	storew %t18, %_r
	%t24 =w loadw %_i
	%t25 =w loadw %_k
	%t23 =w add %t24, %t25
	%t26 =w loadw $g2
	%t22 =w csltw %t23, %t26
	%t29 =w loadw %_j
	%t30 =w loadw %_k
	%t28 =w add %t29, %t30
	%t31 =w loadw $g2
	%t27 =w csltw %t28, %t31
	%t21 =w and %t22, %t27
	jnz %t21, @L14, @L15
@L14
	%t35 =w loadw %_r
	%t36 =w loadw %_k
	%t34 =w add %t35, %t36
	storew %t34, %_r
	storew %t34, %_r
@L15
	%t40 =w loadw %_i
	%t41 =w loadw %_k
	%t39 =w add %t40, %t41
	%t42 =w loadw $g2
	%t38 =w csltw %t39, %t42
	%t46 =w loadw %_j
	%t47 =w loadw %_k
	%t45 =w sub %t46, %t47
	%t43 =w cslew 0, %t45
	%t37 =w and %t38, %t43
	jnz %t37, @L16, @L17
@L16
	%t51 =w loadw %_r
	%t52 =w loadw %_k
	%t50 =w add %t51, %t52
	storew %t50, %_r
	storew %t50, %_r
@L17
	%t57 =w loadw %_i
	%t58 =w loadw %_k
	%t56 =w sub %t57, %t58
	%t54 =w cslew 0, %t56
	%t61 =w loadw %_j
	%t62 =w loadw %_k
	%t60 =w add %t61, %t62
	%t63 =w loadw $g2
	%t59 =w csltw %t60, %t63
	%t53 =w and %t54, %t59
	jnz %t53, @L18, @L19
@L18
	%t67 =w loadw %_r
	%t68 =w loadw %_k
	%t66 =w add %t67, %t68
	storew %t66, %_r
	storew %t66, %_r
@L19
	%t73 =w loadw %_i
	%t74 =w loadw %_k
	%t72 =w sub %t73, %t74
	%t70 =w cslew 0, %t72
	%t78 =w loadw %_j
	%t79 =w loadw %_k
	%t77 =w sub %t78, %t79
	%t75 =w cslew 0, %t77
	%t69 =w and %t70, %t75
	jnz %t69, @L20, @L21
@L20
	%t83 =w loadw %_r
	%t84 =w loadw %_k
	%t82 =w add %t83, %t84
	storew %t82, %_r
	storew %t82, %_r
@L21
	%t86 =w loadw %_k
	%t85 =w add %t86, 1
	storew %t85, %_k
	jmp @L11
@L13
	%t87 =w loadw %_r
	ret %t87
}

export function $go(w %t1, w %t2) {
@L22
	%_ =l alloc4 4
	storew %t1, %_
	%_ =l alloc4 4
	storew %t2, %_
	%_i =l alloc4 4
	%t4 =w loadw %_j
	%t5 =w loadw $g2
	%t3 =w ceqw %t4, %t5
	jnz %t3, @L23, @L24
@L23
