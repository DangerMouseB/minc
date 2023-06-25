export function w $scalarProduct(l %t0, l %t1, w %t2, w %t3) {
@L0
    %_rowA =l alloc8 8
    storel %t0, %_rowA
    %_B =l alloc8 8
    storel %t1, %_B
    %_mA =l alloc4 4
    storew %t2, %_mA
    %_j =l alloc4 4
    storew %t3, %_j
    %_answer =l alloc8 8
    %_k =l alloc4 4
    %_a =l alloc8 8
    %_b =l alloc8 8
    %t6 =d swtof 0
    stored %t6, %_answer
    storew 0, %_k
@L1
    %t10 =w loadw %_k
    %t11 =w loadw %_mA
    %t9 =w csltw %t10, %t11
    jnz %t9, @L2, @L3
@L2
    %t14 =d loadd %_answer
    %t18 =l loadl %_rowA
    %t19 =w loadw %_k
    %t20 =l extsw %t19
    %t21 =l mul 8, %t20
    %t17 =l add %t18, %t21
    %t16 =d loadd %t17
    %t26 =l loadl %_B
    %t27 =w loadw %_k
    %t28 =l extsw %t27
    %t29 =l mul 8, %t28
    %t25 =l add %t26, %t29
    %t24 =l loadl %t25
    %t30 =w loadw %_j
    %t31 =l extsw %t30
    %t32 =l mul 8, %t31
    %t23 =l add %t24, %t32
    %t22 =d loadd %t23
    %t15 =d mul %t16, %t22
    %t13 =d add %t14, %t15
    stored %t13, %_answer
    %t34 =w loadw %_k
    %t33 =w add %t34, 1
    storew %t33, %_k
    jmp @L1
@L3
    ret 0
}

export function w $mmul(l %t0, l %t1, w %t2, w %t3, w %t4, l %t5) {
@L4
    %_A =l alloc8 8
    storel %t0, %_A
    %_B =l alloc8 8
    storel %t1, %_B
    %_nA =l alloc4 4
    storew %t2, %_nA
    %_mA =l alloc4 4
    storew %t3, %_mA
    %_mB =l alloc4 4
    storew %t4, %_mB
    %_out =l alloc8 8
    storel %t5, %_out
    %_i =l alloc4 4
    %_j =l alloc4 4
    storew 0, %_i
@L5
    %t9 =w loadw %_i
    %t10 =w loadw %_nA
    %t8 =w csltw %t9, %t10
    jnz %t8, @L6, @L7
@L6
    storew 0, %_j
@L8
    %t14 =w loadw %_j
    %t15 =w loadw %_mB
    %t13 =w csltw %t14, %t15
    jnz %t13, @L9, @L10
@L9
    %t20 =l loadl %_A
    %t21 =w loadw %_i
    %t22 =l extsw %t21
    %t23 =l mul 8, %t22
    %t19 =l add %t20, %t23
    %t18 =l loadl %t19
    %t24 =l loadl %_B
    %t25 =w loadw %_mA
    %t26 =w loadw %_j
    %t17 =w call $scalarProduct(l %t18, l %t24, w %t25, w %t26, ...)
    %t30 =l loadl %_out
    %t31 =w loadw %_i
    %t32 =l extsw %t31
    %t33 =l mul 8, %t32
    %t29 =l add %t30, %t33
    %t28 =l loadl %t29
    %t34 =w loadw %_j
    %t35 =l extsw %t34
    %t36 =l mul 8, %t35
    %t27 =l add %t28, %t36
    %t37 =d swtof %t17
    stored %t37, %t27
    %t39 =w loadw %_j
    %t38 =w add %t39, 1
    storew %t38, %_j
    jmp @L8
@L10
    %t41 =w loadw %_i
    %t40 =w add %t41, 1
    storew %t40, %_i
    jmp @L5
@L7
    ret 0
}

export function w $mmul2(l %t0, l %t1, w %t2, w %t3, w %t4, l %t5) {
@L11
    %_A =l alloc8 8
    storel %t0, %_A
    %_B =l alloc8 8
    storel %t1, %_B
    %_nA =l alloc4 4
    storew %t2, %_nA
    %_mA =l alloc4 4
    storew %t3, %_mA
    %_mB =l alloc4 4
    storew %t4, %_mB
    %_out =l alloc8 8
    storel %t5, %_out
    %_i =l alloc4 4
    %_j =l alloc4 4
    %_k =l alloc4 4
    %_rowA =l alloc8 8
    storew 0, %_i
@L12
    %t9 =w loadw %_i
    %t10 =w loadw %_nA
    %t8 =w csltw %t9, %t10
    jnz %t8, @L13, @L14
@L13
    storew 0, %_j
@L15
    %t14 =w loadw %_j
    %t15 =w loadw %_mB
    %t13 =w csltw %t14, %t15
    jnz %t13, @L16, @L17
@L16
    %t21 =l loadl %_out
    %t22 =w loadw %_i
    %t23 =l extsw %t22
    %t24 =l mul 8, %t23
    %t20 =l add %t21, %t24
    %t19 =l loadl %t20
    %t25 =w loadw %_j
    %t26 =l extsw %t25
    %t27 =l mul 8, %t26
    %t18 =l add %t19, %t27
    %t28 =d swtof 0
    stored %t28, %t18
    %t32 =l loadl %_A
    %t33 =w loadw %_i
    %t34 =l extsw %t33
    %t35 =l mul 8, %t34
    %t31 =l add %t32, %t35
    %t30 =l loadl %t31
    storel %t30, %_rowA
    storew 0, %_k
@L18
    %t39 =w loadw %_k
    %t40 =w loadw %_mA
    %t38 =w csltw %t39, %t40
    jnz %t38, @L19, @L20
@L19
    %t47 =l loadl %_out
    %t48 =w loadw %_i
    %t49 =l extsw %t48
    %t50 =l mul 8, %t49
    %t46 =l add %t47, %t50
    %t45 =l loadl %t46
    %t51 =w loadw %_j
    %t52 =l extsw %t51
    %t53 =l mul 8, %t52
    %t44 =l add %t45, %t53
    %t43 =d loadd %t44
    %t57 =l loadl %_rowA
    %t58 =w loadw %_k
    %t59 =l extsw %t58
    %t60 =l mul 8, %t59
    %t56 =l add %t57, %t60
    %t55 =d loadd %t56
    %t65 =l loadl %_B
    %t66 =w loadw %_k
    %t67 =l extsw %t66
    %t68 =l mul 8, %t67
    %t64 =l add %t65, %t68
    %t63 =l loadl %t64
    %t69 =w loadw %_j
    %t70 =l extsw %t69
    %t71 =l mul 8, %t70
    %t62 =l add %t63, %t71
    %t61 =d loadd %t62
    %t54 =d mul %t55, %t61
    %t42 =d add %t43, %t54
    %t75 =l loadl %_out
    %t76 =w loadw %_i
    %t77 =l extsw %t76
    %t78 =l mul 8, %t77
    %t74 =l add %t75, %t78
    %t73 =l loadl %t74
    %t79 =w loadw %_j
    %t80 =l extsw %t79
    %t81 =l mul 8, %t80
    %t72 =l add %t73, %t81
    stored %t42, %t72
    %t83 =w loadw %_k
    %t82 =w add %t83, 1
    storew %t82, %_k
    jmp @L18
@L20
    %t85 =w loadw %_j
    %t84 =w add %t85, 1
    storew %t84, %_j
    jmp @L15
@L17
    %t87 =w loadw %_i
    %t86 =w add %t87, 1
    storew %t86, %_i
    jmp @L12
@L14
    ret 0
}

data $g1 = { w 0 }
