export function w $main() {
@start.1
@body.2
    %_n =l alloc4 4
    %_t =l alloc4 4
    %_c =l alloc4 4
    %_p =l alloc4 4
    storew 0, %_c
    storew 2, %_n
@while.cond.3
    %.6 =w loadw %_n
    %.5 =w csltw %.6, 5000
    jnz %.5, @while.body.4, @while.end.5
@while.body.4
    storew 2, %_t
    storew 1, %_p
@while.cond.6
    %.14 =w loadw %_t
    %.15 =w loadw %_t
    %.13 =w mul %.14, %.15
    %.16 =w loadw %_n
    %.12 =w cslew %.13, %.16
    jnz %.12, @while.body.7, @while.end.8
@while.body.7
@if.9
    %.19 =w loadw %_n
    %.20 =w loadw %_t
    %.18 =w rem %.19, %.20
    %.17 =w ceqw %.18, 0
    jnz %.17, @true.10, @false.11
@true.10
    storew 0, %_p
@false.11
    %.25 =w loadw %_t
    %.24 =w add %.25, 1
    storew %.24, %_t
    jmp @while.cond.6
@while.end.8
@if.12
    %.26 =w loadw %_p
    jnz %.26, @true.13, @false.14
@true.13
@if.15
    %.28 =w loadw %_c
    %.31 =w loadw %_c
    %.30 =w rem %.31, 10
    %.29 =w ceqw %.30, 0
    %.27 =w add %.28, %.29
    jnz %.27, @true.16, @false.17
@true.16
    %.34 =w call extern $printf(l $.s1)
@false.17
    %.38 =w loadw %_n
    %.36 =w call extern $printf(l $.s2, ..., w %.38)
    %.40 =w loadw %_c
    %.39 =w add %.40, 1
    storew %.39, %_c
@false.14
    %.42 =w loadw %_n
    %.41 =w add %.42, 1
    storew %.41, %_n
    jmp @while.cond.3
@while.end.5
    %.43 =w call extern $printf(l $.s3)
    ret
}


# STRING CONSTANTS
data $.s1 = { b "\n", b 0 }
data $.s2 = { b "%4d ", b 0 }
data $.s3 = { b "\n", b 0 }
