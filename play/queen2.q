export function w $print(l %t0) {
@L0
	%_board =l alloc8 8
	storel %t0, %_board
	%_i =l alloc4 4
	%_j =l alloc4 4
	storew 0, %_j
@L1
	%t4 =w loadw %_j
	%t5 =w loadw $g1
	%t3 =w csltw %t4, %t5
	jnz %t3, @L2, @L3
@L2
	storew 0, %_i
@L4
	%t9 =w loadw %_i
	%t10 =w loadw $g1
	%t8 =w csltw %t9, %t10
	jnz %t8, @L5, @L6
@L5
	%t15 =l loadl %_board
	%t16 =w loadw %_i
	%t17 =l extsw %t16
	%t18 =l mul 8, %t17
	%t14 =l add %t15, %t18
	%t13 =l loadl %t14
	%t19 =w loadw %_j
	%t20 =l extsw %t19
	%t21 =l mul 4, %t20
	%t12 =l add %t13, %t21
	%t11 =w loadw %t12
	jnz %t11, @L7, @L8
@L7
	%t22 =w call $printf(l $g3, ...)
	jmp @L9
@L8
	%t24 =w call $printf(l $g4, ...)
@L9
	%t27 =w loadw %_i
	%t26 =w add %t27, 1
	storew %t26, %_i
	jmp @L4
@L6
	%t28 =w call $printf(l $g5, ...)
	%t31 =w loadw %_j
	%t30 =w add %t31, 1
	storew %t30, %_j
	jmp @L1
@L3
	%t32 =w call $printf(l $g6, ...)
	ret 0
}

export function w $chk(w %t0, w %t1, l %t2) {
@L10
	%_i =l alloc4 4
	storew %t0, %_i
	%_j =l alloc4 4
	storew %t1, %_j
	%_board =l alloc8 8
	storel %t2, %_board
	%_k =l alloc4 4
	%_r =l alloc4 4
	storew 0, %_k
	storew 0, %_r
@L11
	%t7 =w loadw %_k
	%t8 =w loadw $g1
	%t6 =w csltw %t7, %t8
	jnz %t6, @L12, @L13
@L12
	%t11 =w loadw %_r
	%t16 =l loadl %_board
	%t17 =w loadw %_i
	%t18 =l extsw %t17
	%t19 =l mul 8, %t18
	%t15 =l add %t16, %t19
	%t14 =l loadl %t15
	%t20 =w loadw %_k
	%t21 =l extsw %t20
	%t22 =l mul 4, %t21
	%t13 =l add %t14, %t22
	%t12 =w loadw %t13
	%t10 =w add %t11, %t12
	storew %t10, %_r
	%t25 =w loadw %_r
	%t30 =l loadl %_board
	%t31 =w loadw %_k
	%t32 =l extsw %t31
	%t33 =l mul 8, %t32
	%t29 =l add %t30, %t33
	%t28 =l loadl %t29
	%t34 =w loadw %_j
	%t35 =l extsw %t34
	%t36 =l mul 4, %t35
	%t27 =l add %t28, %t36
	%t26 =w loadw %t27
	%t24 =w add %t25, %t26
	storew %t24, %_r
	%t40 =w loadw %_i
	%t41 =w loadw %_k
	%t39 =w add %t40, %t41
	%t42 =w loadw $g1
	%t38 =w csltw %t39, %t42
	%t45 =w loadw %_j
	%t46 =w loadw %_k
	%t44 =w add %t45, %t46
	%t47 =w loadw $g1
	%t43 =w csltw %t44, %t47
	%t37 =w and %t38, %t43
	jnz %t37, @L14, @L15
@L14
	%t50 =w loadw %_r
	%t55 =l loadl %_board
	%t57 =w loadw %_i
	%t58 =w loadw %_k
	%t56 =w add %t57, %t58
	%t59 =l extsw %t56
	%t60 =l mul 8, %t59
	%t54 =l add %t55, %t60
	%t53 =l loadl %t54
	%t62 =w loadw %_j
	%t63 =w loadw %_k
	%t61 =w add %t62, %t63
	%t64 =l extsw %t61
	%t65 =l mul 4, %t64
	%t52 =l add %t53, %t65
	%t51 =w loadw %t52
	%t49 =w add %t50, %t51
	storew %t49, %_r
@L15
	%t69 =w loadw %_i
	%t70 =w loadw %_k
	%t68 =w add %t69, %t70
	%t71 =w loadw $g1
	%t67 =w csltw %t68, %t71
	%t75 =w loadw %_j
	%t76 =w loadw %_k
	%t74 =w sub %t75, %t76
	%t72 =w cslew 0, %t74
	%t66 =w and %t67, %t72
	jnz %t66, @L16, @L17
@L16
	%t79 =w loadw %_r
	%t84 =l loadl %_board
	%t86 =w loadw %_i
	%t87 =w loadw %_k
	%t85 =w add %t86, %t87
	%t88 =l extsw %t85
	%t89 =l mul 8, %t88
	%t83 =l add %t84, %t89
	%t82 =l loadl %t83
	%t91 =w loadw %_j
	%t92 =w loadw %_k
	%t90 =w sub %t91, %t92
	%t93 =l extsw %t90
	%t94 =l mul 4, %t93
	%t81 =l add %t82, %t94
	%t80 =w loadw %t81
	%t78 =w add %t79, %t80
	storew %t78, %_r
@L17
	%t99 =w loadw %_i
	%t100 =w loadw %_k
	%t98 =w sub %t99, %t100
	%t96 =w cslew 0, %t98
	%t103 =w loadw %_j
	%t104 =w loadw %_k
	%t102 =w add %t103, %t104
	%t105 =w loadw $g1
	%t101 =w csltw %t102, %t105
	%t95 =w and %t96, %t101
	jnz %t95, @L18, @L19
@L18
	%t108 =w loadw %_r
	%t113 =l loadl %_board
	%t115 =w loadw %_i
	%t116 =w loadw %_k
	%t114 =w sub %t115, %t116
	%t117 =l extsw %t114
	%t118 =l mul 8, %t117
	%t112 =l add %t113, %t118
	%t111 =l loadl %t112
	%t120 =w loadw %_j
	%t121 =w loadw %_k
	%t119 =w add %t120, %t121
	%t122 =l extsw %t119
	%t123 =l mul 4, %t122
	%t110 =l add %t111, %t123
	%t109 =w loadw %t110
	%t107 =w add %t108, %t109
	storew %t107, %_r
@L19
	%t128 =w loadw %_i
	%t129 =w loadw %_k
	%t127 =w sub %t128, %t129
	%t125 =w cslew 0, %t127
	%t133 =w loadw %_j
	%t134 =w loadw %_k
	%t132 =w sub %t133, %t134
	%t130 =w cslew 0, %t132
	%t124 =w and %t125, %t130
	jnz %t124, @L20, @L21
@L20
	%t137 =w loadw %_r
	%t142 =l loadl %_board
	%t144 =w loadw %_i
	%t145 =w loadw %_k
	%t143 =w sub %t144, %t145
	%t146 =l extsw %t143
	%t147 =l mul 8, %t146
	%t141 =l add %t142, %t147
	%t140 =l loadl %t141
	%t149 =w loadw %_j
	%t150 =w loadw %_k
	%t148 =w sub %t149, %t150
	%t151 =l extsw %t148
	%t152 =l mul 4, %t151
	%t139 =l add %t140, %t152
	%t138 =w loadw %t139
	%t136 =w add %t137, %t138
	storew %t136, %_r
@L21
	%t154 =w loadw %_k
	%t153 =w add %t154, 1
	storew %t153, %_k
	jmp @L11
@L13
	%t155 =w loadw %_r
	ret %t155
}

export function w $go(w %t0, l %t1) {
@L22
	%_j =l alloc4 4
	storew %t0, %_j
	%_board =l alloc8 8
	storel %t1, %_board
	%_i =l alloc4 4
	%t3 =w loadw %_j
	%t4 =w loadw $g1
	%t2 =w ceqw %t3, %t4
	jnz %t2, @L23, @L24
@L23
	%t6 =l loadl %_board
	%t5 =w call $print(l %t6, ...)
	%t8 =w loadw $g2
	%t7 =w add %t8, 1
	storew %t7, $g2
	ret 0
@L24
	storew 0, %_i
@L25
	%t13 =w loadw %_i
	%t14 =w loadw $g1
	%t12 =w csltw %t13, %t14
	jnz %t12, @L26, @L27
@L26
	%t17 =w loadw %_i
	%t18 =w loadw %_j
	%t19 =l loadl %_board
	%t16 =w call $chk(w %t17, w %t18, l %t19, ...)
	%t15 =w ceqw %t16, 0
	jnz %t15, @L28, @L29
@L28
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
@L29
	%t51 =w loadw %_i
	%t50 =w add %t51, 1
	storew %t50, %_i
	jmp @L25
@L27
	ret 0
}

export function w $main(w %t0, l %t1) {
@L30
	%_ac =l alloc4 4
	storew %t0, %_ac
	%_av =l alloc8 8
	storel %t1, %_av
	%_i =l alloc4 4
	%_board =l alloc8 8
	%_a =l alloc8 8
	%t4 =d swtof 3
	stored %t4, %_a
	%t7 =d loadd %_a
	%t9 =d swtof 1
	%t6 =d add %t7, %t9
	stored %t6, %_a
	storew 8, $g1
	%t14 =w loadw %_ac
	%t12 =w cslew 2, %t14
	jnz %t12, @L31, @L32
@L31
	%t19 =l loadl %_av
	%t18 =l add %t19, 8
	%t17 =l loadl %t18
	%t16 =w call $atoi(l %t17, ...)
	storew %t16, $g1
@L32
	%t23 =w loadw $g1
	%t22 =l call $calloc(w %t23, w 8, ...)
	storel %t22, %_board
	storew 0, %_i
@L33
	%t28 =w loadw %_i
	%t29 =w loadw $g1
	%t27 =w csltw %t28, %t29
	jnz %t27, @L34, @L35
@L34
	%t32 =w loadw $g1
	%t31 =l call $calloc(w %t32, w 4, ...)
	%t35 =l loadl %_board
	%t36 =w loadw %_i
	%t37 =l extsw %t36
	%t38 =l mul 8, %t37
	%t34 =l add %t35, %t38
	storel %t31, %t34
	%t40 =w loadw %_i
	%t39 =w add %t40, 1
	storew %t39, %_i
	jmp @L33
@L35
	%t43 =l loadl %_board
	%t41 =w call $go(w 0, l %t43, ...)
	%t46 =w loadw $g2
	%t44 =w call $printf(l $g7, w %t46, ...)
	%t49 =d loadd %_a
	%t47 =w call $printf(l $g8, d %t49, ...)
	ret 0
}

data $g1 = { w 0 }
data $g2 = { w 0 }
data $g3 = { b " Q", b 0 }
data $g4 = { b " .", b 0 }
data $g5 = { b "\n", b 0 }
data $g6 = { b "\n", b 0 }
data $g7 = { b "found %d solutions\n", b 0 }
data $g8 = { b "my float %f\n", b 0 }
