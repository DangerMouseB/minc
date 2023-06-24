export function w $main() {
@start.1
@body.2
@if.3
    jnz 1, @if.3.true, @or.5.false
@or.5.false
    jnz 0, @if.3.true, @or.4.false
@or.4.false
    jnz 3, @if.3.true, @if.3.end
@if.3.true
    %.4 =w call extern $printf(l $.s1)
@if.3.end
    ret
}


# STRING CONSTANTS
data $.s1 = { b "true\n", b 0 }
