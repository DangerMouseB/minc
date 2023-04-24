export function w $add2_1(w %t0, w %t1) {
@L0
	%_a =l alloc4 4
	storew %t0, %_a
	%_b =l alloc4 4
	storew %t1, %_b
	%t3 =w loadw %_a
	%t4 =w loadw %_b
	%t2 =w add %t3, %t4
	ret %t2
}

export function w $add2_2(d %t0, d %t1) {
@L1
	%_a =l alloc8 8
	stored %t0, %_a
	%_b =l alloc8 8
	stored %t1, %_b
	%t3 =d loadd %_a
	%t4 =d loadd %_b
	%t2 =d add %t3, %t4
	ret %t2
}

