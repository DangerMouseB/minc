export function w $main() {
@body.1
#	call $fprintf(l $__stdoutp, l $str_hello)
	call $printf(l $str_hello)
	ret 0
}

data $str_hello = { b "hello\n", b 0 }
