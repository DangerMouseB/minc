export function w $add2_1(w %t1, w %t2) {
@L1
	%_a =l alloc4 4
	storew %t0, %_a
	%_b =l alloc4 4
	storew %t1, %_b
	%t4 =w loadw %_a
	%t5 =w loadw %_b
	%t3 =w add %t4, %t5
	ret %t3
}

export function d $add2_2(d %t1, d %t2) {
@L2
	%_a =l alloc8 8
	stored %t0, %_a
	%_b =l alloc8 8
	stored %t1, %_b
	%t4 =d loadd %_a
	%t5 =d loadd %_b
	%t3 =d add %t4, %t5
	ret %t3
}

