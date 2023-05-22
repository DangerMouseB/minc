export function w $main() {
@start.1
@body.2
    %_n =l alloc4 4
    %_nv =l alloc4 4
    %_c =l alloc4 4
    %_cmax =l alloc4 4
    %_mem =l alloc8 8
    %.3 =w mul 8, 4000
    %.2 =l call extern $malloc(w %.3)
    storel %.2, %_mem
    storew 0, %_cmax
    storew 1, %_nv
@while.cond.3
    %.11 =w loadw %_nv
    %.10 =w csltw %.11, 1000
    jnz %.10, @while.body.4, @while.end.5
@while.body.4
    %.14 =w loadw %_nv
    storew %.14, %_n
    storew 0, %_c
@while.cond.6
    %.18 =w loadw %_n
    %.17 =w cnew %.18, 1
    jnz %.17, @while.body.7, @while.end.8
@while.body.7
@if.9
    %.21 =w loadw %_n
    %.22 =w loadw %_nv
    %.20 =w csltw %.21, %.22
    jnz %.20, @true.10, @false.11
@true.10
    %.25 =w loadw %_c
    %.28 =l loadl %_mem
    %.29 =w loadw %_n
    %.30 =l extsw %.29
    %.31 =l mul 4, %.30
    %.27 =l add %.28, %.31
    %.26 =w loadw %.27
    %.24 =w add %.25, %.26
    storew %.24, %_c
    jmp @false.8
@false.11
@if.else.12
    %.33 =w loadw %_n
    %.32 =w and %.33, 1
    jnz %.32, @true.13, @false.14
@true.13
    %.39 =w loadw %_n
    %.37 =w mul 3, %.39
    %.36 =w add %.37, 1
    storew %.36, %_n
    jmp @if.end.15
@false.14
    %.43 =w loadw %_n
    %.42 =w div %.43, 2
    storew %.42, %_n
@if.end.15
    %.46 =w loadw %_c
    %.45 =w add %.46, 1
    storew %.45, %_c
    jmp @while.cond.6
@while.end.8
    %.48 =w loadw %_c
    %.50 =l loadl %_mem
    %.51 =w loadw %_nv
    %.52 =l extsw %.51
    %.53 =l mul 4, %.52
    %.49 =l add %.50, %.53
    storew %.48, %.49
@if.16
    %.55 =w loadw %_cmax
    %.56 =w loadw %_c
    %.54 =w csltw %.55, %.56
    jnz %.54, @true.17, @false.18
@true.17
    %.58 =w loadw %_c
    storew %.58, %_cmax
@false.18
    %.60 =w loadw %_nv
    %.59 =w add %.60, 1
    storew %.59, %_nv
    jmp @while.cond.3
@while.end.5
    %.63 =w loadw %_cmax
    %.61 =w call extern $printf(l $.s1, ..., w %.63)
    ret
}


# STRING CONSTANTS
data $.s1 = { b "should print 178: %d\n", b 0 }
