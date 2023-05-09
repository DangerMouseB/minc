export function w $main() {
@body.1
    storel $printf, $pprintf
	call $printf(l $str_hello)
	ret 0
}

data $pprintf = { l 0 }
data $str_hello = { b "hello\n", b 0 }
