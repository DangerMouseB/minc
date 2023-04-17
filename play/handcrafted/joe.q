
export data $t_joe_add2_1 = { b "i*f64^f64", b 0 }
export function w $joe_add2_1(w %t0, w %t1) {
@start
	%a =l alloc4 4
	storew %t0, %a
	%b =l alloc4 4
	storew %t1, %b
	%t3 =w loadw %a
	%t4 =w loadw %b
	%t2 =w add %t3, %t4
	ret %t2
}

export function w $main() {
@start
#    $add2_27 =l $sally_add2_1
#    %dummy =w call $set_add2_27(l $sally_add2_1)

#    %f =l alloc8 8
#    storel $sally_add2_1, %f

#    %f =l cast $sally_add2_1    nope

	%t2 =w call $joe_add2_1(w 1, w 1, ...)
	%t0 =w call $printf(l $glo1, ..., w %t2)

	%t0 =w call $printf(l $fmt1, ..., l $sally_add2_1)

	# 3 ways of getting a function pointer
    %f =l copy $sally_add2_1
	%t0 =w call $printf(l $fmt1, ..., l %f)
	%t5 =w call %f(d d_3.14, d d_3.14)

    %f =l add $sally_add2_1, 0          # add(l,l) -> l
	%t0 =w call $printf(l $fmt1, ..., l %f)
	%t5 =w call %f(d d_3.14, d d_3.14)

    storel $sally_add2_1, $p_add2_27    # storel(l) -> m
    %f =l loadl $p_add2_27              # loadl(m) -> l
	%t0 =w call $printf(l $fmt1, ..., l %f)
	%t5 =w call %f(d d_3.14, d d_3.14)

#    %f =l cast $sally_add2_1           # doesn't work
#	%t0 =w call $printf(l $fmt1, ..., l %f)
#	%t5 =w call %f(d d_3.14, d d_3.14)

    %t6 =w add 4294967295, 0            # 2^32 - 1
    %t7 =w sub 0, 1
    %t0 =w call $printf(l $glo1, ..., w %t6)
	%t0 =w call $printf(l $glo1, ..., w %t7)

	ret
}

data $fmt1 = { b "Addr: %d\n", b 0 }
data $glo1 = { b "One and one make %d!\n", b 0 }
export data $p_add2_27 = align 8 { l 0 }
export data $t_add2_27 = { b "f64*f64^f64", b 0 }
