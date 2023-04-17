export function $sally_add2_1(d %a, d %b) {
@l0
	%t4 =d add %a, %b
	%t2 =w call $printf(l $glo1, ..., d %t4)
	ret
}

data $glo1 = { b "One pi and another pi make %f!\n", b 0 }
