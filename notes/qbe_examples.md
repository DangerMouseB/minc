Intention here is to provide clarifying examples for beginners.

```
# Calling a function pointer and returning an unsigned char
export function w $main() {
@body.1
    %.1 =l add extern $printf, 0
	call %.1(l $.s1)
	%.lf =ub call $LF()
	call %.1(l $.s2, ..., ub %.lf)
	ret 0
}

data $.s1 = { b "hello", b 0 }
data $.s2 = { b "%c", b 0 }

function ub $LF() {
@body.2
    ret 10
}
```
