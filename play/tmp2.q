export function w $main() {
@body.1
    storel $fred, $pfred    # stores the address of fred into pfred
    %.1 =l loadl $pfred     # loads an address from pfred
	call %.1(l $str_hello)
	%.lf =w call $LF()
	call $printf(l $str_a_char, ..., ub %.lf)

#    storel $printf, $pfred
#    %.2 =l loadl $pfred
#    call %.2(l $str_a_char, ..., ub %.lf)

	ret 0
}

function ub $LF() {
@body.1
    ret 10
}

function $fred(l %.1) {
@body.1
    call $printf(l %.1)
    ret
}

data $pfred = { l 0 }
data $str_hello = { b "hello", b 0 }
data $str_a_char = { b "%c", b 0 }
