Intention here is to provide clarifying examples for beginners.

```
# Calling a function pointer and returning an unsigned char
export function w $main() {
@body.1
    %.1 =l copy $printf
	call %.1(l $str_hello)
	%.lf =w call $LF()
	call %.1(l $str_a_char, ..., ub %.lf)
	ret 0
}

data $str_hello = { b "hello", b 0 }
data $str_a_char = { b "%c", b 0 }

# replace w with ub once fix tested
function w $LF() {
@body.2
    ret 10
}
```
