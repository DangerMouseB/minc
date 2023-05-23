export function w $main() {
@start.1
@body.2
@if.3
    jnz 1, @true.4, @or.false.7
@or.false.7
    jnz 0, @true.4, @or.false.6
@or.false.6
    jnz 3, @true.4, @false.5
@true.4
    %.4 =w call extern $printf(l $.s1)
@false.5
    ret
}


# STRING CONSTANTS
data $.s1 = { b "true\n", b 0 }
